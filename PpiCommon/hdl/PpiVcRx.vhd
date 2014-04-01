-------------------------------------------------------------------------------
-- Title         : PPI To VC Block, Data Receive
-- File          : PpiVcRx.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to receive VC Frames.
-- First word of PPI frame contains control data:
--    Bits 07:00 = VC
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
use work.VcPkg.all;

entity PpiVcRx is
   generic (
      TPD_G                : time := 1 ns;
      VC_WIDTH_G           : integer range 1 to 4       := 1; -- 3 not allowed
      PPI_ADDR_WIDTH_G     : integer range 2 to 48      := 9;
      PPI_PAUSE_THOLD_G    : integer range 2 to (2**24) := 255;
      PPI_READY_THOLD_G    : integer range 0 to 511     := 0;
      PPI_MAX_FRAME_G      : integer range 1 to (2**12) := 256*8; -- In bytes
      HEADER_ADDR_WIDTH_G  : integer range 2 to 48      := 8;
      HEADER_AFULL_THOLD_G : integer range 1 to (2**24) := 100;
      HEADER_FULL_THOLD_G  : integer range 1 to (2**24) := 150;
      DATA_ADDR_WIDTH_G    : integer range 1 to 48      := 9;
      DATA_AFULL_THOLD_G   : integer range 1 to (2**24) := 200;
      DATA_FULL_THOLD_G    : integer range 1 to (2**24) := 400
   );
   port (

      -- PPI Interface
      ppiClk           : in  sl;
      ppiClkRst        : in  sl;
      ppiOnline        : in  sl;
      ppiReadToFifo    : in  PpiReadToFifoType;
      ppiReadFromFifo  : out PpiReadFromFifoType;

      -- RX PGP Interface
      vcRxClk         : in  sl;
      vcRxClkRst      : in  sl;
      vcRxCommonOut   : in  VcRxCommonOutType;
      vcRxQuadOut     : in  VcRxQuadOutType;fr

      -- Flow control passed to PpiVcTx block
      locBuffFull     : out sl;  -- Local buffer status
      locBuffAFull    : out sl;  -- Local buffer status
      remBuffFull     : out slv(3 downto 0); -- Received from vcRxQuadOut record
      remBuffAFull    : out slv(3 downto 0); -- Received from vcRxQuadOut record

      -- Status
      rxFrameCntEn    : out sl;
      rxDropCountEn   : out sl;
      rxOverflow      : out sl
   );
begin
   assert (VC_WIDTH_G = 3) report "VC_WIDTH_G must not be = 3" severity failure;
end PpiVcRx;

architecture structure of PpiVcRx is

   constant HEADER_OVERFLOW_THOLD_C : integer := (2**HEADER_ADDR_WIDTH_G) - 10;
   constant DATA_OVERFLOW_THOLD_C   : integer := (2**DATA_ADDR_WIDTH_G) - 10;
   constant DATA_FIFO_WIDTH_C       : integer := (VC_WIDTH_G*16);
   constant BYTE_COUNT_INCR_C       : integer := (VC_WIDTH_G*2);

   -- Local signals
   signal intWriteToFifo   : PpiWriteToFifoType;
   signal intWriteFromFifo : PpiWriteFromFifoType;
   signal intOnline        : sl;
   signal headerCount      : slv(HEADER_ADDR_WIDTH_G-1 downto 0);
   signal headerBuffFull   : sl;
   signal headerBuffAFull  : sl;
   signal headerOverflow   : sl;
   signal dataCount        : slv(DATA_ADDR_WIDTH_G-1 downto 0);
   signal dataBuffFull     : sl;
   signal dataBuffAFull    : sl;
   signal dataOverflow     : sl;
   signal headerRead       : sl;
   signal dataRead         : sl;

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

   type HeaderFifoType is record
      vc       : slv(1 downto 0);
      sof      : sl;
      eof      : sl;
      eofe     : sl;
      valid    : sl;
      overflow : sl;
      byteCnt  : slv(11 downto 0);
   end record HeaderFifoType;

   constant HEADER_FIFO_INIT_C : HeaderFifoType := (
      vc       => (others=>'0'),
      sof      => '0',
      eof      => '0',
      eofe     => '0',
      valid    => '0',
      overflow => '0',
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
      ppiWriteToFifo => PpiWriteToFifoInit
   );

   signal rm   : RegMoveType := REG_MOVE_INIT_C;
   signal rmin : RegMoveType;

   type RegType is record
      sof             : sl;
      eof             : sl;
      eofe            : sl;
      vc              : slv(1 downto 0);
      dirty           : sl;
      overflow        : sl;
      dropVc          : slv(3 downto 0);
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
      overflow        => '0',
      dropVc          => (others=>'0'),
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
   locBuffFull  <= headerBuffFull  or dataBuffAFull;
   locBuffAFull <= headerBuffAFull or dataBuffAFull;

   U_FcGen : for i in 0 to 3 generate
      remBuffAFull(i) <= vcRxQuadOut(i).remBuffAFull;
      remBuffFull(i)  <= vcRxQuadOut(i).remBuffFull;
   end generate;


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
         clk     => vcRxClk,
         rst     => vcRxClkRst,
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

      v.ppiWriteToFifo := PpiWriteToFifoInit;
      v.headerRead     := '0';
      v.dataRead       := '0';

      case rm.state is

         when S_IDLE =>
            v := REG_MOVE_INIT_C;

            -- Init counter
            v.byteCnt := conv_std_logic_vector(BYTE_COUNT_INCR_C,12); 

            -- Header is valid and no flow control
            if headerOut.valid = '1' and intWriteFromFifo.pause = '0' and ppiOnline = '1' then
               v.ppiWriteToFifo.data(43 downto 32) := headerOut.byteCnt;
               v.ppiWriteToFifo.data(11)           := headerOut.overflow;
               v.ppiWriteToFifo.data(10)           := headerOut.eofe;
               v.ppiWriteToFifo.data(9)            := headerOut.eof;
               v.ppiWriteToFifo.data(8)            := headerOut.sof;
               v.ppiWriteToFifo.data(1 downto 0)   := headerOut.vc;
               v.ppiWriteToFifo.size               := "111";
               v.ppiWriteToFifo.eof                := '0';
               v.ppiWriteToFifo.eoh                := '1';
               v.ppiWriteToFifo.err                := '0';
               v.ppiWriteToFifo.valid              := '1';

               case VC_WIDTH_G is
                 when 1      => v.state := S_VC16_0;
                 when 2      => v.state := S_VC32_0;
                 when 4      => v.state := S_VC64;
                 when others => v.state := S_IDLE;
               end case;
            end if;

         when S_VC16_0 =>
            v.ppiWriteToFifo.data(15 downto 0) := dataOut.data(15 downto 0);
            v.ppiWriteToFifo.size              := "001";
            v.ppiWriteToFifo.eof               := '0';
            v.ppiWriteToFifo.eoh               := '0';
            v.ppiWriteToFifo.err               := '0';

            v.byteCnt  := r.byteCnt + 2;
            v.dataRead := '1';
            v.state    := S_VC16_1;

            -- Last value
            if r.byteCnt = headerOut.byteCnt then
               v.ppiWriteToFifo.valid := '1';
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.overflow;
               v.headerRead           := '1';
               v.state                := S_IDLE;
            end if;

         when S_VC16_1 =>
            v.ppiWriteToFifo.data(31 downto 16) := dataOut.data(15 downto 0);
            v.ppiWriteToFifo.size               := "011";
            v.ppiWriteToFifo.eof                := '0';
            v.ppiWriteToFifo.eoh                := '0';
            v.ppiWriteToFifo.err                := '0';

            v.byteCnt  := r.byteCnt + 2;
            v.dataRead := '1';
            v.state    := S_VC16_2;

            -- Last value
            if r.byteCnt = headerOut.byteCnt then
               v.ppiWriteToFifo.valid := '1';
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.overflow;
               v.headerRead           := '1';
               v.state                := S_IDLE;
            end if;

         when S_VC16_2 =>
            v.ppiWriteToFifo.data(47 downto 32) := dataOut.data(15 downto 0);
            v.ppiWriteToFifo.size               := "101";
            v.ppiWriteToFifo.eof                := '0';
            v.ppiWriteToFifo.eoh                := '0';
            v.ppiWriteToFifo.err                := '0';

            v.byteCnt  := r.byteCnt + 2;
            v.dataRead := '1';
            v.state    := S_VC16_3;

            -- Last value
            if r.byteCnt = headerOut.byteCnt then
               v.ppiWriteToFifo.valid := '1';
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.overflow;
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

            v.byteCnt  := r.byteCnt + 2;
            v.dataRead := '1';
            v.state    := S_VC16_0;

            -- Last value
            if r.byteCnt = headerOut.byteCnt then
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.overflow;
               v.headerRead           := '1';
               v.state                := S_IDLE;
            end if;

         when S_VC32_0 =>
            v.ppiWriteToFifo.data(31 downto  0) := dataOut.data(31 downto 0);
            v.ppiWriteToFifo.size               := "011";
            v.ppiWriteToFifo.eof                := '0';
            v.ppiWriteToFifo.eoh                := '0';
            v.ppiWriteToFifo.err                := '0';

            v.byteCnt  := r.byteCnt + 4;
            v.dataRead := '1';
            v.state    := S_VC32_1;

            -- Last value
            if r.byteCnt = headerOut.byteCnt then
               v.ppiWriteToFifo.valid := '1';
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.overflow;
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

            v.byteCnt  := r.byteCnt + 4;
            v.dataRead := '1';
            v.state    := S_VC32_0;

            -- Last value
            if r.byteCnt = headerOut.byteCnt then
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.overflow;
               v.headerRead           := '1';
               v.state                := S_IDLE;
            end if;

         when S_VC64 =>
            v.ppiWriteToFifo.data  := dataOut.data;
            v.ppiWriteToFifo.size  := "111";
            v.ppiWriteToFifo.eof   := '0';
            v.ppiWriteToFifo.eoh   := '0';
            v.ppiWriteToFifo.err   := '0';
            v.ppiWriteToFifo.valid := '1';

            v.byteCnt  := r.byteCnt + 8;
            v.dataRead := '1';

            -- Last value
            if r.byteCnt = headerOut.byteCnt then
               v.ppiWriteToFifo.eof   := '1';
               v.ppiWriteToFifo.err   := headerOut.eofe or headerOut.overflow;
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
         DATA_WIDTH_G   => 18,
         ADDR_WIDTH_G   => HEADER_ADDR_WIDTH_G,
         INIT_G         => "0",
         FULL_THRES_G   => 1,
         EMPTY_THRES_G  => 0
      ) port map (
         rst                => ppiClkRst,
         wr_clk             => vcRxClk,
         wr_en              => headerIn.valid,
         din(11 downto  0)  => headerIn.byteCnt,
         din(13 downto 12)  => headerIn.vc,
         din(14)            => headerIn.overflow,
         din(15)            => headerIn.eofe,
         din(16)            => headerIn.eof,
         din(17)            => headerIn.sof,
         wr_data_count      => headerCount,
         wr_ack             => open,
         overflow           => open,
         prog_full          => open,
         almost_full        => open,
         full               => open,
         not_full           => open,
         rd_clk             => ppiClk,
         rd_en              => headerRead,
         dout(11 downto  0) => headerOut.byteCnt,
         dout(13 downto 12) => headerOut.vc,
         dout(14)           => headerOut.overflow,
         dout(15)           => headerOut.eofe,
         dout(16)           => headerOut.eof,
         dout(17)           => headerOut.sof,
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
         FULL_THRES_G   => 1,
         EMPTY_THRES_G  => 0
      ) port map (
         rst           => ppiClkRst,
         wr_clk        => vcRxClk,
         wr_en         => dataIn.valid,
         din           => dataIn.data(DATA_FIFO_WIDTH_C-1 downto 0),
         wr_data_count => dataCount,
         wr_ack        => open,
         overflow      => open,
         prog_full     => open,
         almost_full   => open,
         full          => open,
         not_full      => open,
         rd_clk        => ppiClk,
         rd_en         => dataRead,
         dout          => dataOut.data(DATA_FIFO_WIDTH_C-1 downto 0),
         rd_data_count => open,
         valid         => dataOut.valid,
         underflow     => open,
         prog_empty    => open,
         almost_empty  => open,
         empty         => open
      );

   U_FDATA_GEN : if DATA_FIFO_WIDTH_C /= 64 generate
      dataOut.data(63 downto DATA_FIFO_WIDTH_C) <= (others=>'0');
   end generate;

   -- Flow control
   process (vcRxClk) begin
      if (rising_edge(vcRxClk)) then
         if vcRxClkRst = '1' then
            headerBuffAFull <= '0' after TPD_G;
            headerBuffFull  <= '0' after TPD_G;
            headerOverflow  <= '0' after TPD_G;
            dataBuffAFull   <= '0' after TPD_G;
            dataBuffAFull   <= '0' after TPD_G;
            dataOverflow    <= '0' after TPD_G;
         else

            if headerCount > HEADER_OVERFLOW_THOLD_C then
               headerOverflow  <= '1' after TPD_G;
               headerBuffAFull <= '1' after TPD_G;
               headerBuffFull  <= '1' after TPD_G;
            elsif headerCount > HEADER_FULL_THOLD_G then
               headerOverflow  <= '0' after TPD_G;
               headerBuffAFull <= '1' after TPD_G;
               headerBuffFull  <= '1' after TPD_G;
            elsif headerCount > HEADER_AFULL_THOLD_G then
               headerOverflow  <= '0' after TPD_G;
               headerBuffAFull <= '1' after TPD_G;
               headerBuffFull  <= '0' after TPD_G;
            else
               headerOverflow  <= '0' after TPD_G;
               headerBuffAFull <= '0' after TPD_G;
               headerBuffFull  <= '0' after TPD_G;
            end if;

            if dataCount > DATA_OVERFLOW_THOLD_C then
               dataOverflow  <= '1' after TPD_G;
               dataBuffAFull <= '1' after TPD_G;
               dataBuffFull  <= '1' after TPD_G;
            elsif dataCount > DATA_FULL_THOLD_G then
               dataOverflow  <= '0' after TPD_G;
               dataBuffAFull <= '1' after TPD_G;
               dataBuffFull  <= '1' after TPD_G;
            elsif dataCount > DATA_AFULL_THOLD_G then
               dataOverflow  <= '0' after TPD_G;
               dataBuffAFull <= '1' after TPD_G;
               dataBuffFull  <= '0' after TPD_G;
            else
               dataOverflow  <= '0' after TPD_G;
               dataBuffAFull <= '0' after TPD_G;
               dataBuffFull  <= '0' after TPD_G;
            end if;

         end if;
      end if;
   end process;


   ------------------------------------
   -- Frame Receiver
   ------------------------------------

   -- Sync
   process (vcRxClk) is
   begin
      if (rising_edge(vcRxClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (vcRxClkRst, r, vcRxCommonOut, vcRxQuadOut, dataOverflow, headerOverflow, intOnline ) is
      variable v          : RegType;
      variable rxValid    : sl;
      variable newFrame   : boolean;
   begin
      v := r;

      -- Init
      v.frameCountEn   := '0';
      v.dropCountEn    := '0';
      v.headerIn.valid := '0';
      v.dataIn.valid   := '0';
      newFrame         := false;
      rxValid          := '0';

      -- Overflow potential, mark overflow flag
      if dataOverflow = '1' or headerOverflow = '1' then
         v.overflow := '1';
      elsif dataOverflow = '0' and headerOverflow = '0' then
         v.overflow := '0';
      end if;

      -- Pass data
      v.dataIn.data(15 downto  0) := vcRxCommonOut.data(0);
      v.dataIn.data(31 downto 16) := vcRxCommonOut.data(1);
      v.dataIn.data(47 downto 32) := vcRxCommonOut.data(2);
      v.dataIn.data(63 downto 48) := vcRxCommonOut.data(3);

      -- VC is valid
      if vcRxQuadOut(0).valid = '1' then
         v.vc    := "00";
         rxValid := '1';
      elsif vcRxQuadOut(1).valid = '1' then
         v.vc    := "01";
         rxValid := '1';
      elsif vcRxQuadOut(2).valid = '1' then
         v.vc    := "10";
         rxValid := '1';
      elsif vcRxQuadOut(3).valid = '1' then
         v.vc    := "11";
         rxValid := '1';
      end if;

      -- VC has changed, last EOF, max ppi frame size or in overflow
      if r.overflow = '1' or v.vc /= r.vc or r.eof = '1' or r.byteCnt >= PPI_MAX_FRAME_G then

         -- Init Tracking
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
         v.headerIn.overflow := r.overflow;
         v.headerIn.byteCnt  := r.byteCnt;
         v.headerIn.valid    := r.dirty and (not r.dropVc(conv_integer(r.vc)));

         -- Mark VC as in overflow
         if r.dirty = '1' then
            v.dropVc(conv_integer(r.vc)) := '1';
         end if;
      end if;

      -- Count drops
      if rxValid = '1' and r.dropVc(conv_integer(v.vc)) = '1' and vcRxCommonOut.eof = '1' then
         v.dropCountEn := '1';
      end if;

      -- Valid frame that is not being dropped
      if rxValid = '1' and r.dropVc(conv_integer(v.vc)) = '0' then
         if vcRxCommonOut.sof = '1' then
            v.sof := '1';
         end if;
         if vcRxCommonOut.eof = '1' then
            v.eof := '1';
         end if;
         if vcRxCommonOut.eofe = '1' then
            v.eofe := '1';
         end if;

         -- frame counter
         v.frameCountEn := vcRxCommonOut.eof;

         -- Data
         v.dataIn.valid := '1';
         v.dirty        := '1';

      end if;

      -- Clear vc drop when overflow is clear and vc eof is seen
      if rxValid = '1' and v.overflow = '0' and vcRxCommonOut.eof = '1' then
         v.dropVc(conv_integer(v.vc)) := '0';
      end if;

      -- Byte counter
      if newFrame = true then
         v.byteCnt := conv_std_logic_vector(BYTE_COUNT_INCR_C,32);
      elsif v.dataIn.valid = '1' then
         v.byteCnt := r.byteCnt + BYTE_COUNT_INCR_C;
      end if;

      -- Reset
      if vcRxClkRst = '1' or intOnline = '0' then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      dataIn        <= r.dataIn;
      headerIn      <= r.headerIn;
      rxFrameCntEn  <= r.frameCountEn;
      rxDropCountEn <= r.dropCountEn;
      rxOverflow    <= r.overflow;

   end process;

end architecture structure;
