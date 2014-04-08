-------------------------------------------------------------------------------
-- Title         : PPI To VC Block, Inbound receiver.
-- File          : PpiIbVc.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to receive inbound VC Frames.
-- First word of PPI frame contains control data:
--    Bits 03:00 = VC
--    Bits 8     = SOF
--    Bits 9     = EOF
--    Bits 10    = EOFE
--    Bits 11    = Frame dropped
--    Bits 47:32 = Length in bytes
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

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;
use work.Vc64Pkg.all;

entity PpiIbVc is
   generic (
      TPD_G                : time := 1 ns;
      VC_WIDTH_G           : integer range 16 to 64     := 16;    -- Bits: 16, 32 or 64
      PPI_ADDR_WIDTH_G     : integer range 2 to 48      := 9;     -- (2**9) * 64bits = 4096 bytes
      PPI_PAUSE_THOLD_G    : integer range 2 to (2**24) := 256;   -- 256 * 64bits = 2048 bytes
      PPI_READY_THOLD_G    : integer range 0 to 511     := 0;     -- 0 * 64bits = 0 bytes
      PPI_MAX_FRAME_G      : integer range 1 to (2**12) := 1024;  -- 1024 bytes
      HEADER_ADDR_WIDTH_G  : integer range 2 to 48      := 8;     -- (2**8) = 256 headers
      HEADER_AFULL_THOLD_G : integer range 1 to (2**24) := 100;   -- 100 headers
      DATA_ADDR_WIDTH_G    : integer range 1 to 48      := 10;    -- (2**10) * 16bits(VC_WIDTH_G) = 2048 bytes
      DATA_AFULL_THOLD_G   : integer range 1 to (2**24) := 520    -- 520 * 16bits(VC_WIDTH_G) = 1040 Bytes
   );
   port (

      -- PPI Interface
      ppiClk           : in  sl;
      ppiClkRst        : in  sl;
      ppiOnline        : in  sl;
      ppiReadToFifo    : in  PpiReadToFifoType;
      ppiReadFromFifo  : out PpiReadFromFifoType;

      -- Inbound VC Interface
      -- Ready is always '1'
      ibVcClk         : in  sl;
      ibVcClkRst      : in  sl;
      ibVcData        : in  Vc64DataType;
      ibVcCtrl        : out Vc64CtrlType;

      -- Status
      rxFrameCntEn    : out sl;
      rxDropCountEn   : out sl;
      rxOverflow      : out sl
   );
begin
   assert (VC_WIDTH_G = 16 or VC_WIDTH_G = 32 or VC_WIDTH_G = 64 ) 
      report "VC_WIDTH_G must not be = 16, 32 or 64" severity failure;
   assert (DATA_AFULL_THOLD_G*(VC_WIDTH_G/8) > PPI_MAX_FRAME_G) 
      report "Max frame size is less than data almost full thold" severity failure;
end PpiIbVc;

architecture structure of PpiIbVc is

   constant HEADER_OVERFLOW_THOLD_C : integer := (2**HEADER_ADDR_WIDTH_G) - 10;
   constant DATA_OVERFLOW_THOLD_C   : integer := (2**DATA_ADDR_WIDTH_G) - 10;
   constant DATA_FIFO_WIDTH_C       : integer := VC_WIDTH_G + 1;

   -- Local signals
   signal intWriteToFifo   : PpiWriteToFifoType;
   signal intWriteFromFifo : PpiWriteFromFifoType;
   signal intOnline        : sl;
   signal headerCount      : slv(HEADER_ADDR_WIDTH_G-1 downto 0);
   signal headerPFull      : sl;
   signal headerAFull      : sl;
   signal headerFull       : sl;
   signal dataCount        : slv(DATA_ADDR_WIDTH_G-1 downto 0);
   signal dataPFull        : sl;
   signal dataAFull        : sl;
   signal dataFull         : sl;
   signal headerRead       : sl;
   signal dataRead         : sl;
   signal overflow   : sl;
   signal dfifoDin         : slv(DATA_FIFO_WIDTH_C-1 downto 0);
   signal dfifoDout        : slv(DATA_FIFO_WIDTH_C-1 downto 0);

   type DataFifoType is record
      data  : slv(63 downto 0);
      size  : sl;
      valid : sl;
   end record DataFifoType;

   constant DATA_FIFO_INIT_C : DataFifoType := (
      data  => (others=>'0'),
      size  => '0',
      valid => '0'
   );

   signal dataOut : DataFifoType;
   signal dataIn  : DataFifoType;

   type HeaderFifoType is record
      vc       : slv(3 downto 0);
      sof      : sl;
      eof      : sl;
      eofe     : sl;
      valid    : sl;
      dropped  : sl;
      byteCnt  : slv(11 downto 0);
   end record HeaderFifoType;

   constant HEADER_FIFO_INIT_C : HeaderFifoType := (
      vc       => (others=>'0'),
      sof      => '0',
      eof      => '0',
      eofe     => '0',
      valid    => '0',
      dropped  => '0',
      byteCnt  => (others=>'0')
   );

   signal headerOut : HeaderFifoType;
   signal headerIn  : HeaderFifoType;

   type MoveStateType is (S_IDLE, S_VC16_0, S_VC16_1, S_VC16_2, S_VC16_3, S_VC32_0, S_VC32_1, S_VC64);

   type RegMoveType is record
      state          : MoveStateType;
      byteCnt        : slv(11 downto 0);
      dataRead       : sl;
      headerRead     : sl;
      ppiWriteToFifo : PpiWriteToFifoType;
   end record RegMoveType;

   constant REG_MOVE_INIT_C : RegMoveType := (
      state          => S_IDLE,
      byteCnt        => (others=>'0'),
      dataRead       => '0',
      headerRead     => '0',
      ppiWriteToFifo => PPI_WRITE_TO_FIFO_INIT_C
   );

   signal rm   : RegMoveType := REG_MOVE_INIT_C;
   signal rmin : RegMoveType;

   type RegType is record
      sof             : sl;
      eof             : sl;
      eofe            : sl;
      vc              : slv(3 downto 0);
      dirty           : sl;
      droppedVc       : slv(15 downto 0);
      dropCountEn     : sl;
      dataIn          : DataFifoType;
      headerIn        : HeaderFifoType;  
      byteCnt         : slv(11 downto 0);
      frameCountEn    : sl;
   end record RegType;

   constant REG_INIT_C : RegType := (
      sof             => '0',
      eof             => '0',
      eofe            => '0',
      vc              => (others=>'0'),
      dirty           => '0',
      droppedVc       => (others=>'0'),
      dropCountEn     => '0',
      dataIn          => DATA_FIFO_INIT_C,
      headerIn        => HEADER_FIFO_INIT_C,
      byteCnt         => (others=>'0'),
      frameCountEn    => '0'
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin


   ------------------------------------
   -- Flow Control
   ------------------------------------

   -- Flow Control
   ibVcCtrl.overflow   <= overflow;
   ibVcCtrl.almostFull <= (headerPFull or dataPFull);
   ibVcCtrl.ready      <= '1';


   ------------------------------------
   -- Sync Online
   ------------------------------------

   U_SyncOnline : entity work.Synchronizer 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         OUT_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 2,
         INIT_G         => "0"
      ) port map (
         clk     => ibVcClk,
         rst     => ibVcClkRst,
         dataIn  => ppiOnline,
         dataOut => intOnline
      );


   ------------------------------------
   -- PPI FIFO
   ------------------------------------

   U_InFifo : entity work.PpiFifoSync
      generic map (
         TPD_G              => TPD_G,
         BRAM_EN_G          => true,
         USE_DSP48_G        => "no",
         ADDR_WIDTH_G       => PPI_ADDR_WIDTH_G,
         PAUSE_THOLD_G      => PPI_PAUSE_THOLD_G,
         READY_THOLD_G      => PPI_READY_THOLD_G,
         FIFO_TYPE_EN_G     => false
      ) port map (
         ppiClk           => ppiClk,
         ppiClkRst        => ppiClkRst,
         ppiWriteToFifo   => intWriteToFifo,
         ppiWriteFromFifo => intWriteFromFifo,
         ppiReadToFifo    => ppiReadToFifo,
         ppiReadFromFifo  => ppiReadFromFifo
      );


   --------------------------------------------------
   -- Move Data From Header/Data FIFOs to PPI FIFO
   --------------------------------------------------

   -- Sync
   process (ppiClk) is
   begin
      if (rising_edge(ppiClk)) then
         rm <= rmin after TPD_G;
      end if;
   end process;

   -- Async
   process (ppiClkRst, rm, intWriteFromFifo, ppiOnline, headerOut, dataOut ) is
      variable v : RegMoveType;
   begin
      v := rm;

      v.ppiWriteToFifo.valid := '0';
      v.headerRead           := '0';
      v.dataRead             := '0';

      case rm.state is

         when S_IDLE =>
            v := REG_MOVE_INIT_C;

            -- Init counter
            v.byteCnt := conv_std_logic_vector(VC_WIDTH_G/8,12);

            -- Header is valid and no flow control
            if headerOut.valid = '1' and intWriteFromFifo.pause = '0' and ppiOnline = '1' then
               v.ppiWriteToFifo.data(43 downto 32) := headerOut.byteCnt;
               v.ppiWriteToFifo.data(11)           := headerOut.dropped;
               v.ppiWriteToFifo.data(10)           := headerOut.eofe;
               v.ppiWriteToFifo.data(9)            := headerOut.eof;
               v.ppiWriteToFifo.data(8)            := headerOut.sof;
               v.ppiWriteToFifo.data(3 downto 0)   := headerOut.vc;
               v.ppiWriteToFifo.size               := "111";
               v.ppiWriteToFifo.eof                := '0';
               v.ppiWriteToFifo.eoh                := '1';
               v.ppiWriteToFifo.err                := '0';
               v.ppiWriteToFifo.valid              := '1';

               case VC_WIDTH_G is
                 when 16     => v.state := S_VC16_0;
                 when 32     => v.state := S_VC32_0;
                 when 64     => v.state := S_VC64;
                 when others => v.state := S_IDLE;
               end case;
            end if;

         when S_VC16_0 =>
            v.ppiWriteToFifo.data(15 downto 0) := dataOut.data(15 downto 0);
            v.ppiWriteToFifo.size              := "001";
            v.ppiWriteToFifo.eof               := '0';
            v.ppiWriteToFifo.eoh               := '0';
            v.ppiWriteToFifo.err               := '0';

            v.byteCnt  := rm.byteCnt + 2;
            v.dataRead := '1';
            v.state    := S_VC16_1;

            -- Last value
            if rm.byteCnt >= headerOut.byteCnt then
               v.ppiWriteToFifo.valid := '1';
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.dropped;
               v.headerRead           := '1';
               v.state                := S_IDLE;
            end if;

         when S_VC16_1 =>
            v.ppiWriteToFifo.data(31 downto 16) := dataOut.data(15 downto 0);
            v.ppiWriteToFifo.size               := "011";
            v.ppiWriteToFifo.eof                := '0';
            v.ppiWriteToFifo.eoh                := '0';
            v.ppiWriteToFifo.err                := '0';

            v.byteCnt  := rm.byteCnt + 2;
            v.dataRead := '1';
            v.state    := S_VC16_2;

            -- Last value
            if rm.byteCnt >= headerOut.byteCnt then
               v.ppiWriteToFifo.valid := '1';
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.dropped;
               v.headerRead           := '1';
               v.state                := S_IDLE;
            end if;

         when S_VC16_2 =>
            v.ppiWriteToFifo.data(47 downto 32) := dataOut.data(15 downto 0);
            v.ppiWriteToFifo.size               := "101";
            v.ppiWriteToFifo.eof                := '0';
            v.ppiWriteToFifo.eoh                := '0';
            v.ppiWriteToFifo.err                := '0';

            v.byteCnt  := rm.byteCnt + 2;
            v.dataRead := '1';
            v.state    := S_VC16_3;

            -- Last value
            if rm.byteCnt >= headerOut.byteCnt then
               v.ppiWriteToFifo.valid := '1';
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.dropped;
               v.headerRead           := '1';
               v.state                := S_IDLE;
            end if;

         when S_VC16_3 =>
            v.ppiWriteToFifo.data(63 downto 48) := dataOut.data(15 downto 0);
            v.ppiWriteToFifo.size               := "111";
            v.ppiWriteToFifo.eof                := '0';
            v.ppiWriteToFifo.eoh                := '0';
            v.ppiWriteToFifo.err                := '0';
            v.ppiWriteToFifo.valid              := '1';

            v.byteCnt  := rm.byteCnt + 2;
            v.dataRead := '1';
            v.state    := S_VC16_0;

            -- Last value
            if rm.byteCnt >= headerOut.byteCnt then
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.dropped;
               v.headerRead           := '1';
               v.state                := S_IDLE;
            end if;

         when S_VC32_0 =>
            v.ppiWriteToFifo.data(31 downto  0) := dataOut.data(31 downto 0);
            v.ppiWriteToFifo.size               := "011";
            v.ppiWriteToFifo.eof                := '0';
            v.ppiWriteToFifo.eoh                := '0';
            v.ppiWriteToFifo.err                := '0';

            v.byteCnt  := rm.byteCnt + 4;
            v.dataRead := '1';
            v.state    := S_VC32_1;

            -- Last value
            if rm.byteCnt >= headerOut.byteCnt then
               v.ppiWriteToFifo.valid := '1';
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.dropped;
               v.headerRead           := '1';
               v.state                := S_IDLE;
            end if;

         when S_VC32_1 =>
            v.ppiWriteToFifo.data(63 downto 32) := dataOut.data(31 downto 0);
            v.ppiWriteToFifo.size               := "111";
            v.ppiWriteToFifo.eof                := '0';
            v.ppiWriteToFifo.eoh                := '0';
            v.ppiWriteToFifo.err                := '0';
            v.ppiWriteToFifo.valid              := '1';

            v.byteCnt  := rm.byteCnt + 4;
            v.dataRead := '1';
            v.state    := S_VC32_0;

            -- Last value
            if rm.byteCnt >= headerOut.byteCnt then
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.dropped;
               v.headerRead           := '1';
               v.state                := S_IDLE;
            end if;

         when S_VC64 =>
            v.ppiWriteToFifo.data  := dataOut.data;
            v.ppiWriteToFifo.size  := dataOut.size & "11";
            v.ppiWriteToFifo.eof   := '0';
            v.ppiWriteToFifo.eoh   := '0';
            v.ppiWriteToFifo.err   := '0';
            v.ppiWriteToFifo.valid := '1';

            v.byteCnt  := rm.byteCnt + 8;
            v.dataRead := '1';

            -- Last value
            if rm.byteCnt >= headerOut.byteCnt then
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.dropped;
               v.headerRead           := '1';
               v.state                := S_IDLE;
            end if;

      end case;

      -- Reset
      if ppiClkRst = '1' then
         v := REG_MOVE_INIT_C;
      end if;

      -- Next register assignment
      rmin <= v;

      -- Outputs
      intWriteToFifo <= rm.ppiWriteToFifo;
      headerRead     <= v.headerRead;
      dataRead       <= v.dataRead;
   end process;


   ------------------------------------
   -- Data And Header FIFOs
   ------------------------------------

   -- Header FIFO
   U_HeadFifo : entity work.FifoASync 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         BRAM_EN_G      => true,
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         ALTERA_SYN_G   => false,
         ALTERA_RAM_G   => "M9K",
         SYNC_STAGES_G  => 3,
         DATA_WIDTH_G   => 20,
         ADDR_WIDTH_G   => HEADER_ADDR_WIDTH_G,
         INIT_G         => "0",
         FULL_THRES_G   => HEADER_AFULL_THOLD_G,
         EMPTY_THRES_G  => 1
      ) port map (
         rst                => ppiClkRst,
         wr_clk             => ibVcClk,
         wr_en              => headerIn.valid,
         din(11 downto  0)  => headerIn.byteCnt,
         din(15 downto 12)  => headerIn.vc,
         din(16)            => headerIn.dropped,
         din(17)            => headerIn.eofe,
         din(18)            => headerIn.eof,
         din(19)            => headerIn.sof,
         wr_data_count      => headerCount,
         wr_ack             => open,
         overflow           => open,
         prog_full          => headerPFull,
         almost_full        => headerAFull,
         full               => headerFull,
         not_full           => open,
         rd_clk             => ppiClk,
         rd_en              => headerRead,
         dout(11 downto  0) => headerOut.byteCnt,
         dout(15 downto 12) => headerOut.vc,
         dout(16)           => headerOut.dropped,
         dout(17)           => headerOut.eofe,
         dout(18)           => headerOut.eof,
         dout(19)           => headerOut.sof,
         rd_data_count      => open,
         valid              => headerOut.valid,
         underflow          => open,
         prog_empty         => open,
         almost_empty       => open,
         empty              => open
      );


   -- Data FIFO
   U_DataFifo : entity work.FifoASync 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         BRAM_EN_G      => true,
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         ALTERA_SYN_G   => false,
         ALTERA_RAM_G   => "M9K",
         SYNC_STAGES_G  => 3,
         DATA_WIDTH_G   => DATA_FIFO_WIDTH_C,
         ADDR_WIDTH_G   => DATA_ADDR_WIDTH_G,
         INIT_G         => "0",
         FULL_THRES_G   => DATA_AFULL_THOLD_G,
         EMPTY_THRES_G  => 1
      ) port map (
         rst           => ppiClkRst,
         wr_clk        => ibVcClk,
         wr_en         => dataIn.valid,
         din           => dFifoDin,
         wr_data_count => dataCount,
         wr_ack        => open,
         overflow      => open,
         prog_full     => dataPFull,
         almost_full   => dataAFull,
         full          => dataFull,
         not_full      => open,
         rd_clk        => ppiClk,
         rd_en         => dataRead,
         dout          => dFifoDout,
         rd_data_count => open,
         valid         => dataOut.valid,
         underflow     => open,
         prog_empty    => open,
         almost_empty  => open,
         empty         => open
      );

   dFifoDin(DATA_FIFO_WIDTH_C-2 downto 0) <= dataIn.data(DATA_FIFO_WIDTH_C-2 downto 0);
   dFifoDin(DATA_FIFO_WIDTH_C-1)          <= dataIn.size;

   dataOut.data(DATA_FIFO_WIDTH_C-2 downto 0) <= dFifoDout(DATA_FIFO_WIDTH_C-2 downto 0);
   dataOut.size                               <= dFifoDout(DATA_FIFO_WIDTH_C-1);

   U_FDATA_GEN : if DATA_FIFO_WIDTH_C /= 65 generate
      dataOut.data(63 downto DATA_FIFO_WIDTH_C-1) <= (others=>'0');
   end generate;

   -- Overflow tracking
   process ( ibVcClk ) begin
      if rising_edge (ibVcClk) then
         if ibVcClkRst = '1' then
            overflow <= '0' after TPD_G;
         elsif headerCount > HEADER_OVERFLOW_THOLD_C or dataCount > DATA_OVERFLOW_THOLD_C then
            overflow <= '1' after TPD_G;
         elsif headerCount = 0 and dataCount = 0 then
            overflow <= '0' after TPD_G;
         end if;
      end if;
   end process;

   rxOverflow <= overflow;

   ------------------------------------
   -- Frame Receiver
   ------------------------------------

   -- Sync
   process (ibVcClk) is
   begin
      if (rising_edge(ibVcClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (ibVcClkRst, r, ibVcData, overflow, intOnline ) is
      variable v          : RegType;
      variable newFrame   : boolean;
      variable byteSize   : slv(3 downto 0);
   begin
      v := r;

      -- Init
      v.frameCountEn   := '0';
      v.dropCountEn    := '0';
      v.headerIn.valid := '0';
      v.dataIn.valid   := '0';
      newFrame         := false;

      -- Pass data
      v.dataIn.data := ibVcData.data;
      v.dataIn.size := ibVcData.size or not(ibVcData.eof); -- always 1 unless eof

      -- Determine increment
      case VC_WIDTH_G is
         when 16 => byteSize := "0010"; -- 2 bytes
         when 32 => byteSize := "0100"; -- 4 bytes
         when 64 => 
            if ibVcData.size = '1' then
               byteSize := "1000"; -- 8 bytes
            else
               byteSize := "0111"; -- 7 bytes
            end if;
         when others => 
            byteSize := "1111"; -- 7 bytes
      end case;

      -- EOF was seen, valid data and vc change or max size, or in overflow
      if overflow = '1' or 
         (r.dirty = '1' and r.eof = '1') or 
         (ibVcData.valid = '1' and (ibVcData.vc /= r.vc or r.byteCnt >= PPI_MAX_FRAME_G)) then

         -- Init Tracking, new frame
         v.sof      := '0';
         v.eof      := '0';
         v.eofe     := '0';
         v.dirty    := '0';
         newFrame   := true;

         -- Write header
         v.headerIn.vc       := r.vc;
         v.headerIn.sof      := r.sof;
         v.headerIn.eof      := r.eof;
         v.headerIn.eofe     := r.eofe;
         v.headerIn.dropped  := r.droppedVc(conv_integer(r.vc));
         v.headerIn.byteCnt  := r.byteCnt;
         v.headerIn.valid    := r.dirty;

         -- Clear vc dropped flag after finishing a frame
         if v.headerIn.valid = '1' and v.headerIn.eof = '1' then
            v.droppedVc(conv_integer(r.vc)) := '0';
         end if;

      end if;

      -- Track drops
      if ibVcData.valid = '1' and overflow = '1' then
         v.droppedVc(conv_integer(ibVcData.vc)) := '1';
         v.dropCountEn                          := ibVcData.eof;
      end if;

      -- Valid frame that is not being dropped
      if ibVcData.valid = '1' and overflow = '0' then
         if ibVcData.sof = '1' then
            v.sof := '1';
         end if;
         if ibVcData.eof = '1' then
            v.eof := '1';
         end if;
         if ibVcData.eofe = '1' then
            v.eofe := '1';
         end if;

         -- frame counter
         v.frameCountEn := ibVcData.eof;

         -- Data
         v.dataIn.valid := '1';
         v.dirty        := '1';
         v.vc           := ibVcData.vc;

      end if;

      -- Byte counter
      if newFrame = true then
         if v.dataIn.valid = '1' then
            v.byteCnt := x"00" & byteSize;
         else
            v.byteCnt := (others=>'0');
         end if;
      elsif v.dataIn.valid = '1' then
         v.byteCnt := r.byteCnt + byteSize;
      end if;

      -- Reset
      if ibVcClkRst = '1' or intOnline = '0' then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      dataIn        <= r.dataIn;
      headerIn      <= r.headerIn;
      rxFrameCntEn  <= r.frameCountEn;
      rxDropCountEn <= r.dropCountEn;

   end process;

end architecture structure;
