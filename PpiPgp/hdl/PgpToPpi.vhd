-------------------------------------------------------------------------------
-- Title         : PGP to PPI Block, Inbound receiver.
-- File          : PgpToPpi.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to receive inbound AXI Stream Frames.
-- First quad word of PPI frame contains control data:
--    Bits 03:00 = Dest
--    Bits 09    = SOF
--    Bits 16    = EOFE
--    Bit  24    = Inbound overflow occured
--    Bits 25    = Header only frame
--    Bits 26    = End of Frame
--    Bits 27    = Pause occured
--    Bits 63:32 = Length in bytes
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE PPI Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE PPI Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.PpiPkg.all;
use work.Pgp2bPkg.all;
use work.SsiPkg.all;
use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;

entity PgpToPpi is
   generic (
      TPD_G                : time                := 1 ns;

      -- AXIS Settings
      AXIS_ADDR_WIDTH_G    : integer             := 9;
      AXIS_PAUSE_THRESH_G  : integer             := 500;
      AXIS_CASCADE_SIZE_G  : integer             := 1;

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
      axisIbCtrl      : out AxiStreamCtrlType;

      -- Status
      rxFrameCntEn    : out sl;
      rxOverflow      : out sl
   );
begin
end PgpToPpi;

architecture structure of PgpToPpi is

   -- Constants
   constant BYTE_COUNT_BITS_C    : integer := bitSize(PPI_MAX_FRAME_SIZE_G);
   constant HEADER_DATA_WIDTH_C  : integer := BYTE_COUNT_BITS_C + 7;

   -- Header FIFO type
   type HeaderFifoType is record
      dest      : slv(3 downto 0);
      sof       : sl;
      eofe      : sl;
      byteCnt   : slv(BYTE_COUNT_BITS_C-1 downto 0);
      eof       : sl;
      valid     : sl;
   end record HeaderFifoType;

   constant HEADER_FIFO_INIT_C : HeaderFifoType := (
      dest      => (others=>'0'),
      sof       => '0',
      eofe      => '0',
      byteCnt   => (others=>'0'),
      eof       => '0',
      valid     => '0'
   );

   signal headerOut      : HeaderFifoType;
   signal headerIn       : HeaderFifoType;
   signal headerOutSlv   : slv(HEADER_DATA_WIDTH_C-1 downto 0);
   signal headerOutValid : sl;
   signal headerInSlv    : slv(HEADER_DATA_WIDTH_C-1 downto 0);

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
      headerEn     : sl;
      dataIn       : DataFifoType;
      dirty        : sl;
      headerIn     : HeaderFifoType;  
      nextHeader   : HeaderFifoType;  
      intIbSlave   : AxiStreamSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      headerEn     => '0',
      dirty        => '0',
      dataIn       => DATA_FIFO_INIT_C,
      headerIn     => HEADER_FIFO_INIT_C,
      nextHeader   => HEADER_FIFO_INIT_C,
      intIbSlave   => AXI_STREAM_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   -- PPI Output Type
   type MoveStateType is (IDLE_S, HEADER_S, DATA_S, LAST_S);

   type RegMoveType is record
      state       : MoveStateType;
      byteCnt     : slv(BYTE_COUNT_BITS_C-1 downto 0);
      overflow    : sl;
      pause       : sl;
      err         : sl;
      dataRead    : sl;
      headerRead  : sl;
      regIbMaster : AxiStreamMasterType;
   end record RegMoveType;

   constant REG_MOVE_INIT_C : RegMoveType := (
      state          => IDLE_S,
      byteCnt        => (others=>'0'),
      overflow       => '0',
      pause          => '0',
      err            => '0',
      dataRead       => '0',
      headerRead     => '0',
      regIbMaster    => AXI_STREAM_MASTER_INIT_C
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
   signal intPause        : sl;
   signal headerAFull     : sl;
   signal headerRead      : sl;
   signal dataAFull       : sl;
   signal dataRead        : sl;

begin

   assert (DATA_ADDR_WIDTH_G >= bitSize(PPI_MAX_FRAME_SIZE_G))
      report "DATA_ADDR_WIDTH_C is not wide enough for PPI_MAX_FRAME_SIZE_G" severity failure;

   -------------------------
   -- Input FIFO, ASYNC
   -------------------------
   U_InputFifo : entity work.AxiStreamFifo 
      generic map (
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 0,
         SLAVE_READY_EN_G    => false,
         VALID_THOLD_G       => 1,
         BRAM_EN_G           => true,
         XIL_DEVICE_G        => "7SERIES",
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => false,
         CASCADE_SIZE_G      => AXIS_CASCADE_SIZE_G,
         FIFO_ADDR_WIDTH_G   => AXIS_ADDR_WIDTH_G,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => AXIS_PAUSE_THRESH_G,
         SLAVE_AXI_CONFIG_G  => SSI_PGP2B_CONFIG_C,
         MASTER_AXI_CONFIG_G => SSI_PGP2B_CONFIG_C
      ) port map (
         sAxisClk    => axisIbClk,
         sAxisRst    => axisIbClkRst,
         sAxisMaster => axisIbMaster,
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

   -- Generate pause pulse in ppi clock domain
   U_SyncPause : entity work.SynchronizerOneShot 
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
         dataIn  => iaxisIbCtrl.pause,
         dataOut => intPause
      );

   rxOverflow <= intOverflow;
   axisIbCtrl <= iaxisIbCtrl;


   -------------------------
   -- Data/Header Split
   -------------------------

   -- Sync
   process (ppiClk) is
   begin
      if (rising_edge(ppiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (dataAFull, headerAFull, intIbMaster, ppiClkRst, ppiState, r) is
      variable v : RegType;
   begin
      v := r;

      -- Init
      v.dataIn.valid      := '0';
      v.headerIn.valid    := '0';
      v.intIbSlave.tReady := (not headerAFull) and (not dataAFull);

      -- Writing header
      if r.headerEn = '1' then
         v.headerIn          := r.nextHeader;
         v.headerIn.valid    := '1';
         v.nextHeader        := HEADER_FIFO_INIT_C;
         v.intIbSlave.tReady := '0';
         v.headerEn          := '0';
         v.dirty             := '0';

      -- Data is valid
      elsif intIbMaster.tValid = '1' then

         -- Destination has changed and length is non zero, write header
         if r.nextHeader.byteCnt /= 0 and intIbMaster.tDest /= r.nextHeader.dest then
            v.headerEn          := '1';
            v.intIbSlave.tReady := '0';
            v.dataIn.valid      := r.dirty;
         end if;

         -- valid is asserted
         if v.intIbSlave.tReady = '1' then
            v.nextHeader.byteCnt := r.nextHeader.byteCnt + 2;
            v.nextHeader.eofe    := ssiGetUserEofe(SSI_PGP2B_CONFIG_C,intIbmaster);
            v.nextHeader.eof     := intIbMaster.tLast;
            v.dirty              := '1';

            -- Interleave mode supported for 16-bit PGP frames
            if r.nextHeader.byteCnt(2 downto 1) = 0 then
               v.dataIn.data(15 downto 0) := intIbMaster.tData(15 downto 0);
            elsif r.nextHeader.byteCnt(2 downto 1) = 1 then
               v.dataIn.data(31 downto 16) := intIbMaster.tData(15 downto 0);
            elsif r.nextHeader.byteCnt(2 downto 1) = 2 then
               v.dataIn.data(47 downto 32) := intIbMaster.tData(15 downto 0);
            else
               v.dataIn.data(63 downto 48) := intIbMaster.tData(15 downto 0);
               v.dataIn.valid := '1';
               v.dirty        := '0';
            end if;

            -- First data
            if r.nextHeader.byteCnt = 0 then
               v.nextHeader.sof  := ssiGetUserSof(SSI_PGP2B_CONFIG_C,intIbmaster);
               v.nextHeader.dest := intIbMaster.tDest(3 downto 0);
            end if;

            -- Last is asserted or max frame size is reached. Total size include 8-byte header
            -- Current count does not include current 16-bit transfer. So subtract 10.
            if intIbMaster.tLast = '1' or r.nextHeader.byteCnt >= (PPI_MAX_FRAME_SIZE_G-10) then
               v.headerEn     := '1';
               v.dataIn.valid := '1';
               v.dirty        := '0';
            end if;
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
      intIbSlave    <= v.intIbSlave;

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
         FULL_THRES_G       => 1,
         EMPTY_THRES_G      => 1
      ) port map (
         rst                => ppiClkRst,
         wr_clk             => ppiClk,
         wr_en              => headerIn.valid,
         din                => headerInSlv,
         almost_full        => headerAFull,
         rd_clk             => ppiClk,
         rd_en              => headerRead,
         dout               => headerOutSlv,
         valid              => headerOutValid
      );

   process ( headerIn ) is
      variable ret : slv(HEADER_DATA_WIDTH_C-1 downto 0);
   begin

      ret(3 downto 0) := headerIn.dest;
      ret(4)          := headerIn.sof;
      ret(5)          := headerIn.eofe;
      ret(6)          := headerIn.eof;

      ret((BYTE_COUNT_BITS_C-1)+7 downto 7) := headerIn.byteCnt;

      headerInSlv <= ret;
   end process;

   process ( headerOutSlv, headerOutValid ) is
      variable ret : HeaderFifoType;
   begin

      ret.dest := headerOutSlv(3 downto 0);
      ret.sof  := headerOutSlv(4);
      ret.eofe := headerOutSlv(5);
      ret.eof  := headerOutSlv(6);

      ret.byteCnt := headerOutSlv((BYTE_COUNT_BITS_C-1)+7 downto 7);

      ret.valid := headerOutValid;
      headerOut <= ret;
   end process;

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
         almost_full   => dataAFull,
         rd_clk        => ppiClk,
         rd_en         => dataRead,
         dout          => dataOut.data,
         valid         => dataOut.valid
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
   process (dataOut, headerOut, intOverflow, intPause, ppiClkRst, regIbSlave, rm) is
      variable v : RegMoveType;
   begin
      v := rm;

      v.headerRead := '0';
      v.dataRead   := '0';

      if intOverflow = '1' then
         v.overflow := '1';
      end if;

      if intPause = '1' then
         v.pause := '1';
      end if;

      case rm.state is

         when IDLE_S =>
            v.err         := '0';
            v.byteCnt     := (others=>'0');
            v.regIbMaster := AXI_STREAM_MASTER_INIT_C;

            -- Header FIFO is ready
            if headerOut.valid = '1' then
               v.state := HEADER_S;
            end if;

         when HEADER_S =>
            v.regIbMaster.tData(3 downto 0) := headerOut.dest;
            v.regIbMaster.tData(9)          := headerOut.sof;
            v.regIbMaster.tData(16)         := headerOut.eofe;

            v.regIbMaster.tData(BYTE_COUNT_BITS_C+31 downto 32) := headerOut.byteCnt;

            v.regIbMaster.tData(27) := rm.pause;
            v.regIbMaster.tData(26) := headerOut.eof;
            v.regIbMaster.tData(24) := rm.overflow;
            v.regIbMaster.tValid    := '1';
            v.headerRead            := '1';
            v.byteCnt               := headerOut.byteCnt;
            v.pause                 := '0';
            v.state                 := DATA_S;

            -- Full frame fits in header
            if headerOut.byteCnt <= PPI_MAX_HEADER_C and headerOut.sof = '1' and headerOut.eof = '1' then
               v.regIbMaster.tData(25) := '1';
            else
               axiStreamSetUserBit(PPI_AXIS_CONFIG_INIT_C, v.regIbMaster, PPI_EOH_C, '1');
            end if;

            v.err := headerOut.eofe;

         when DATA_S =>

            -- Advance pipeline
            if regIbSlave.tReady = '1' then
               v.regIbMaster.tUser              := (others=>'0');
               v.regIbMaster.tData(63 downto 0) := dataOut.data;

               v.dataRead := '1';
               v.byteCnt  := rm.byteCnt - 8;

               -- Last quad word
               if rm.byteCnt <= 8 then
                  axiStreamSetUserBit(PPI_AXIS_CONFIG_INIT_C, v.regIbMaster, PPI_ERR_C, rm.err);

                  if rm.byteCnt < 8 then
                     v.regIbMaster.tKeep := genTKeep(conv_integer(rm.byteCnt));
                  end if;

                  v.state             := LAST_S;
                  v.regIbMaster.tLast := '1';
               end if;
            end if;

         when LAST_S =>

            -- Advance pipeline
            if regIbSlave.tReady = '1' then
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

