-------------------------------------------------------------------------------
-- Title         : AXI Stream to PPI Block, Inbound receiver.
-- File          : AxisToPpi.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to receive inbound AXI Stream Frames.
-- First quad word of PPI frame contains control data:
--    Bits 07:00 = Dest
--    Bits 15:08 = First User
--    Bits 23:16 = Last  User
--    Bit  24    = Inbound overflow occured
--    Bits 25    = Header only frame
--    Bits 26    = End of Frame
--    Bits 63:32 = Length in bytes
-------------------------------------------------------------------------------
-- Copyright (c) 2014 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 03/21/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.PpiPkg.all;
use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;

entity AxisToPpi is
   generic (
      TPD_G                : time                := 1 ns;

      -- AXIS Settings
      AXIS_CONFIG_G        : AxiStreamConfigType := AXI_STREAM_CONFIG_INIT_C;
      AXIS_READY_EN_G      : boolean             := false;
      AXIS_ADDR_WIDTH_G    : integer             := 9;
      AXIS_PAUSE_THRESH_G  : integer             := 500;
      AXIS_CASCADE_SIZE_G  : integer             := 1;
      AXIS_ERROR_EN_G      : boolean             := false;
      AXIS_ERROR_BIT_G     : integer             := 0;

      -- Header/data FIFOs
      DATA_ADDR_WIDTH_G    : integer             := 9;
      HEADER_ADDR_WIDTH_G  : integer             := 9;

      -- PPI Settings
      PPI_MAX_FRAME_SIZE_G : integer             := 2048
   );
   port (

      -- PPI Interface
      ppiClk          : in  sl;
      ppiClkRst       : in  sl;
      ppiState        : in  RceDmaStateType;
      ppiIbMaster     : out AxiStreamMasterType;
      ppiIbSlave      : in  AxiStreamSlaveType;

      -- Inbound AXI Stream Interface
      axisIbClk       : in  sl;
      axisIbClkRst    : in  sl;
      axisIbMaster    : in  AxiStreamMasterType;
      axisIbSlave     : out AxiStreamSlaveType;
      axisIbCtrl      : out AxiStreamCtrlType;

      -- Status
      rxFrameCntEn    : out sl;
      rxOverflow      : out sl
   );
begin
end AxisToPpi;

architecture structure of AxisToPpi is

   -- Constants
   constant BYTE_COUNT_BITS_C    : integer := bitSize(PPI_MAX_FRAME_SIZE_G);
   constant HEADER_DATA_WIDTH_G  : integer := BYTE_COUNT_BITS_C + 1 +
                                              (AXIS_CONFIG_G.TUSER_BITS_C*2) + 
                                              AXIS_CONFIG_G.TDEST_BITS_C;

   -- Internal AXIS configuration
   constant INT_AXIS_CONFIG_C : AxiStreamConfigType := {
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 8,
      TDEST_BITS_C  => AXIS_CONFIG_G.TDEST_BITS_C,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => AXIS_CONFIG_G.TUSER_BITS_C,
      TUSER_MODE_C  => AXIS_CONFIG_G.TUSER_FIRST_LAST_C
   };

   -- Header FIFO type
   type HeaderFifoType is record
      dest      : slv(AXIS_CONFIG_G.TDEST_BITS_C-1 downto 0);
      firstUser : slv(AXIS_CONFIG_G.TUSER_BITS_C-1 downto 0);
      lastUser  : slv(AXIS_CONFIG_G.TUSER_BITS_C-1 downto 0);
      byteCnt   : slv(BYTE_COUNT_BITS_C-1 downto 0);
      eof       : sl;
      valid     : sl;
   end record HeaderFifoType;

   constant HEADER_FIFO_INIT_C : HeaderFifoType := (
      dest      => (others=>'0'),
      firstUser => (others=>'0'),
      lastUser  => (others=>'0'),
      byteCnt   => (others=>'0'),
      eof       => '0',
      valid     => '0'
   );

   signal headerOut    : HeaderFifoType;
   signal headerIn     : HeaderFifoType;
   signal headerOutSlv : slv(HEADER_FIFO_SIZE_C-1 downto 0);
   signal headerInSlv  : slv(HEADER_FIFO_SIZE_C-1 downto 0);

   -- Data FIFO type
   type DataFifoType is record
      data  : slv(63 downto 0);
      valid : sl;
   end record DataFifoType;

   constant DATA_FIFO_INIT_C : DataFifoType := (
      data  => (others=>'0'),
      valid => '0'
   );

   signal dataOut : DataFifoType;
   signal dataIn  : DataFifoType;


   -- Header/Data Move Type
   type RegType is record
      inFrame      : sl;
      dataIn       : DataFifoType;
      headerIn     : HeaderFifoType;  
      nextHeader   : HeaderFifoType;  
   end record RegType;

   constant REG_INIT_C : RegType := (
      inFrame      => '0',
      dataIn       => DATA_FIFO_INIT_C,
      headerIn     => HEADER_FIFO_INIT_C,
      nextHeader   => HEADER_FIFO_INIT_C,
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   -- PPI Output Type
   type MoveStateType is (IDLE_S, HEADER_S, DATA_S, LAST_S);

   type RegMoveType is record
      state       : MoveStateType;
      byteCnt     : slv(BYTE_COUNT_BITS_C-1 downto 0);
      overflow    : sl;
      err         : sl;
      dataRead    : sl;
      headerRead  : sl;
      regIbMaster : AxiStreamMasterType;
   end record RegMoveType;

   constant REG_MOVE_INIT_C : RegMoveType := (
      state          => IDLE_S,
      byteCnt        => (others=>'0'),
      overflow       => '0',
      err            => '0',
      dataRead       => '0',
      headerRead     => '0',
      regIbMaster    => AXIS_STREAM_MASTER_INIT_C
   );

   signal rm   : RegMoveType := REG_MOVE_INIT_C;
   signal rmin : RegMoveType;

   -- Local signals
   signal intIbMaster     : AxiStreamMasterType;
   signal intIbSlave      : AxiStreamSlaveType;
   signal regIbMaster     : AxiStreamMasterType;
   signal regIbSlave      : AxiStreamSlaveType;
   signal iaxisIbCtrl     : AxiStreamCtrlType;
   signal intOverflow     : sl;
   signal headerAFull     : sl;
   signal headerRead      : sl;
   signal dataAFull       : sl;
   signal dataRead        : sl;

begin

   assert (AXIS_CONFIG_G.TSTRB_EN_C = false)
      report "TSTRB_EN_C must be false" severity failure;

   assert (AXIS_CONFIG_G.TID_BITS_C = 0)
      report "TID_BITS_C must be 0" severity failure;

   assert (AXIS_CONFIG_G.TUSER_MODE_C = TUSER_LAST_C or AXIS_CONFIG_G.TUSER_MODE_C = TUSER_FIRST_LAST_C)
      report "TUSER_MODE_C must be last or first_last" severity failure;

   assert (AXIS_ERROR_BIT_G < (AXIS_CONFIG_G.TUSER_BITS_C-1))
      report "AXIS_ERROR_BIT_G must be less than TUSER_BITS_C-1" severity failure;

   assert (DATA_ADDR_WIDTH_G >= bitSize(PPI_MAX_FRAME_SIZE_G))
      report "DATA_ADDR_WIDTH_G is not wide enough for PPI_MAX_FRAME_SIZE_G" severity failure;


   -------------------------
   -- Input FIFO, ASYNC
   -------------------------
   U_InputFifo : entity work.AxiStreamFifo 
      generic map (
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 0,
         SLAVE_READY_EN_G    => AXIS_READY_EN_G,
         VALID_THOLD_G       => 1,
         BRAM_EN_G           => true,
         XIL_DEVICE_G        => "7SERIES",
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => false,
         CASCADE_SIZE_G      => AXIS_CASCADE_SIZE_G,
         FIFO_ADDR_WIDTH_G   => AXIS_ADDR_WIDTH_G,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => AXIS_PAUSE_THRESH_G,
         SLAVE_AXI_CONFIG_G  => AXIS_CONFIG_G,
         MASTER_AXI_CONFIG_G => INT_AXIS_CONFIG_C
      ) port map (
         sAxisClk    => axisClk,
         sAxisRst    => axisClkRst,
         sAxisMaster => axisIbMaster,
         sAxisSlave  => axisIbSlave,
         sAxisCtrl   => iaxisIbCtrl,
         mAxisClk    => ppiClk,
         mAxisRst    => ppiClkRst,
         mAxisMaster => intIbMaster,
         mAxisSlave  => intIbSlave
      );

   -- Generate overflow pulse in ppi clock domain
   U_SyncOverflow : entity work.SynchronizerOneShot 
      generic map (
         RELEASE_DELAY_G => 3,
         BYPASS_SYNC_G   => false,
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         IN_POLARITY_G   => '1',
         OUT_POLARITY_G  => '1',
         RST_ASYNC_G     => false
      ) port map (
         clk     => ppiClk,
         rst     => ppiClkRst,
         dataIn  => iaxisIbCtrl.overflow,
         dataOut => intOverflow
      );

   rxOverflow <= intOverflow;
   axisIbCtrl <= iaxisIbCtrl;


   -------------------------
   -- Data/Header Split
   -------------------------

   -- Always move when there is space left in data and header FIFOs
   intIbSlave.tReady <= (not headerAFull) and (not dataAFull);

   -- Sync
   process (ppClk) is
   begin
      if (rising_edge(ppiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (ppiClkRst, r, intIbMaster, ppiState, intIbSlave ) is
      variable v : RegType;
   begin
      v := r;

      -- Init
      v.headerIn.valid := '0';
      v.dataIn.valid   := '0';

      -- Pass data
      v.dataIn.data := intIbMaster.tData(63 downto 0);

      -- Data is valid and ready is asserted
      if intIbMaster.tValid = '1' and intIbSlave.tReady = '1' then
         v.nextHeader.byteCnt  := r.nextHeader.byteSize + (onesCount(intIbMaster.tKeep(7 downto 0))+1);
         v.nextHeader.lastUser := intIbMaster.tUser(AXIS_CONFIG_G.TUSER_BITS_G-1 downto 0);
         v.nextHeader.eof      := intIbMaster.tLast;
         v.inFrame             := '1';
         v.dataIn.valid        := '1';

         -- Not in frame or destination has changed, current data is part of next frame, start a new header
         if (not r.inFrame) and intIbMaster.tDest /= r.headerIn.dest then
            v.headerIn             := r.nextHeader;
            v.nextHeader.byteCnt   := (onesCount(intIbMaster.tKeep(7 downto 0))+1);
            v.nextHeader.dest      := intIbMaster.tDest(AXIS_CONFIG_G.TDEST_BITS_G-1 downto 0);
            v.nextHeader.firstUser := intIbMaster.tUser(AXIS_CONFIG_G.TUSER_BITS_G-1 downto 0);
            v.headerIn.valid       := r.inFrame;

         -- Last is asserted or max frame size is reached.
         elsif intIbMaster.tLast = '1' or v.nextHeader.byteCnt = PPI_MAX_FRAME_SIZE_G then
            v.headerIn       := r.nextHeader;
            v.headerIn.valid := '1';
            v.inFrame        := '0';
         end if;
      end if;

      -- Reset
      if ppiClkRst = '1' or ppiState.online = '0' then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      dataIn        <= r.dataIn;
      headerIn      <= r.headerIn;
      rxFrameCntEn  <= r.headerIn.valid;

   end process;


   ------------------------------------
   -- Data And Header FIFOs, SYNC
   ------------------------------------

   -- Header FIFO
   U_HeadFifo : entity work.Fifo
      generic map (
         TPD_G              => TPD_G,
         RST_POLARITY_G     => '1',
         RST_ASYNC_G        => true,
         GEN_SYNC_FIFO_G    => true,
         BRAM_EN_G          => true,
         FWFT_EN_G          => true,
         USE_DSP48_G        => "no",
         USE_BUILT_IN_G     => false,
         XIL_DEVICE_G       => "7SERIES",
         SYNC_STAGES_G      => 3,
         DATA_WIDTH_G       => HEADER_DATA_WIDTH_C,
         ADDR_WIDTH_G       => HEADER_ADDR_WIDTH_G,
         INIT_G             => "0",
         FULL_THRES_G       => 1
         EMPTY_THRES_G      => 1
      ) port map (
         rst                => ppiClkRst,
         wr_clk             => ppiClk,
         wr_en              => headerIn.valid,
         din                => headerInSlv,
         wr_data_count      => open,
         wr_ack             => open,
         overflow           => open,
         prog_full          => open,
         almost_full        => headerAFull,
         full               => open,
         not_full           => open,
         rd_clk             => ppiClk,
         rd_en              => headerRead,
         dout               => headerOutSlv,
         rd_data_count      => open,
         valid              => headerOut.valid,
         underflow          => open,
         prog_empty         => open,
         almost_empty       => open,
         empty              => open
      );

   process ( headerIn ) is
      variable i   : integer;
      variable ret : slv(HEADER_FIFO_SIZE_C-1 downto 0);
   begin
      i := 0;

      ret((AXIS_CONFIG_G.TDEST_BITS_C-1)+i downto i) := headerIn.dest;
      i := i + AXIS_CONFIG_G.TDEST_BITS_C;

      ret((AXIS_CONFIG_G.TUSER_BITS_C-1)+i downto i) := headerIn.firstUser;
      i := i + AXIS_CONFIG_G.TUSER_BITS_C;

      ret((AXIS_CONFIG_G.TUSER_BITS_C-1)+i downto i) := headerIn.lastUser;
      i := i + AXIS_CONFIG_G.TUSER_BITS_C;

      ret((BYTE_COUNT_BITS-1)+i downto i) := headerIn.byteCnt;
      i := i + BYTE_COUNT_BITS;

      ret(i) := headerIn.eof;

      headerInSlv <= ret;
   end if;

   process ( headerOutSlv ) is
      variable i   : integer;
      variable ret : HeaderFifoType;
   begin
      i := 0;

      ret.dest := headerOutSlv((AXIS_CONFIG_G.TDEST_BITS_C-1)+i downto i);
      i := i + AXIS_CONFIG_G.TDEST_BITS_C;

      ret.firstUser := headerOutSlv((AXIS_CONFIG_G.TUSER_BITS_C-1)+i downto i);
      i := i + AXIS_CONFIG_G.TUSER_BITS_C;

      ret.lastUser := headerOutSlv((AXIS_CONFIG_G.TUSER_BITS_C-1)+i downto i);
      i := i + AXIS_CONFIG_G.TUSER_BITS_C;

      ret.byteCnt := headerOutSlv((BYTE_COUNT_BITS-1)+i downto i);
      i := i + BYTE_COUNT_BITS;

      ret.eof := headerOutSlv(i);

      headerOut <= ret;
   end if;

   -- Data FIFO
   U_DataFifo : entity work.Fifo
      generic map (
         TPD_G              => TPD_G,
         RST_POLARITY_G     => '1',
         RST_ASYNC_G        => true,
         GEN_SYNC_FIFO_G    => true,
         BRAM_EN_G          => true,
         FWFT_EN_G          => true,
         USE_DSP48_G        => "no",
         USE_BUILT_IN_G     => false,
         XIL_DEVICE_G       => "7SERIES",
         SYNC_STAGES_G      => 3,
         DATA_WIDTH_G       => 64,
         ADDR_WIDTH_G       => DATA_ADDR_WIDTH_G,
         INIT_G             => "0",
         FULL_THRES_G       => 1,
         EMPTY_THRES_G      => 1
      ) port map (
         rst           => ppiClkRst,
         wr_clk        => ppiClk,
         wr_en         => dataIn.valid,
         din           => dataIn.data,
         wr_data_count => open,
         wr_ack        => open,
         overflow      => open,
         prog_full     => open,
         almost_full   => dataAFull,
         full          => open,
         not_full      => open,
         rd_clk        => ppiClk,
         rd_en         => dataRead,
         dout          => dataOut.data,
         rd_data_count => open,
         valid         => dataOut.valid,
         underflow     => open,
         prog_empty    => open,
         almost_empty  => open,
         empty         => open
      );


   ------------------------------------
   -- PPI Frame Generation
   ------------------------------------

   -- Sync
   process (ppiClk) is
   begin
      if (rising_edge(ppiClk)) then
         rm <= rmin after TPD_G;
      end if;
   end process;

   -- Async
   process (ppiClkRst, rm, headerOut, dataOut, regIbSlave ) is
      variable v : RegMoveType;
   begin
      v := rm;

      v.headerRead := '0';
      v.dataRead   := '0';

      if intOverflow = '1' then
         v.overflow := '1';
      end if;

      case rm.state is

         when IDLE_S =>
            v.err         := '0';
            v.byteCnt     := (others=>'0');
            v.regIbMaster := AXIS_STREAM_MASTER_INIT_C;

            -- Header FIFO is ready
            if headerOut.valid = '1' then
               v.state := HEADER_S;
            end if;

         when HEADER_S =>
            v.regIbMaster.tData((AXIS_CONFIG_G.TDEST_BITS_C-1)    downto  0) := headerOut.dest;
            v.regIbMaster.tData((AXIS_CONFIG_G.TUSER_BITS_C-1)+8  downto  8) := headerOut.firstUser;
            v.regIbMaster.tData((AXIS_CONFIG_G.TUSER_BITS_C-1)+16 downto 16) := headerOut.lastUser;
            v.regIbMaster.tData(BYTE_COUNT_BITS_C+31 downto 32)              := headerOut.byteCnt;

            v.regIbMaster.tData(26) := headerOut.eof;
            v.regIbMaster.tData(24) := r.overflow;
            v.regIbMaster.tValid    := '1';
            v.headerRead            := '1';
            v.byteCnt               := headerOut.byteCnt;

            if headerOut.byteCnt <= PPI_MAX_HEADER_C then
               v.regIbMaster.tData(25) := '1';
            else
               axiStreamSetUserBit(PPI_AXIS_CONFIG_INIT_C, v.regIbMaster, EOH_BIT_G, '1');
            end if;

            if AXIS_ERROR_EN_G then
               v.err := headerOut.lastUser(AXIS_ERROR_BIT_G);
            end if;

         when DATA_S =>

            -- Advance pipeline
            if regIbSlave.tReady := '1' then
               v.regIbMaster.tUser              := (others=>'0');
               v.regIbMaster.tData(63 downto 0) := dataOut.data;

               v.dataRead := '1';
               v.byteCnt  := r.byteCnt - 8;

               -- Last quad word
               if r.byteCnt <= 8 then
                  axiStreamSetUserBit(PPI_AXIS_CONFIG_INIT_C, v.regIbMaster, ERR_BIT_G, r.err);

                  if r.byteCnt < 8 then
                     v.regIbMaster.tKeep(7 downto conv_integer(r.byteCnt)) := (others=>'0');
                  end if;

                  v.state := LAST_S;
               end if;
            end if;

         when LAST_S =>

            -- Advance pipeline
            if regIbSlave.tReady := '1' then
               v.regIbMaster.tValid := '0';
               v.state              := IDLE_S;
            end if;

      end case;

      -- Reset
      if ppiClkRst = '1' then
         v := REG_MOVE_INIT_C;
      end if;

      -- Next register assignment
      rmin <= v;

      -- Outputs
      regIbMaster <= rm.regIbMaster;
      headerRead  <= rm.headerRead;
      dataRead    <= v.dataRead;

   end process;


   ---------------------------------
   -- PPI Output Pipeline
   ---------------------------------
   U_Pipe : entity work.AxiStreamPipeline
      generic map (
         TPD_G          => TPD_G,
         PIPE_STAGES_G  => 2
         )
      port map (
         axisClk     => ppiClk,
         axisRst     => ppiClkRst,
         sAxisMaster => regIbMaster,
         sAxisSlave  => regIbSlave,
         mAxisMaster => ppiIbMaster,
         mAxisSlave  => ppiIbSlave
      );   

end architecture structure;

