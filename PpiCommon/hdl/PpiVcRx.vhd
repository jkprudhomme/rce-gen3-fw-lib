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
--    Bits 15:08 = Lane (ignored)
--    Bits 16    = SOF
--    Bits 17    = EOF
--    Bits 18    = EOFE
--    Bits 19    = Frame dropped
--    Bits 63:32 = Length
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
      PPI_READY_THOLD_G    : integer range 0 to (2**24) := 0;
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
      vcRxQuadOut     : in  VcRxQuadOutType;

      -- Flow control passed to PpiVcTx block
      locBuffFull     : out sl;
      locBuffAFull    : out sl;
      remBuffFull     : out slv(3 downto 0);
      remBuffAFull    : out slv(3 downto 0);

      -- Frame Counter
      rxFrameCntEn    : out sl
   );
begin
   assert (VC_WIDTH_G = 3) report "VC_WIDTH_G must not be = 3" severity failure;
end PpiVcRx;

architecture structure of PpiVcRx is

   constant HEADER_OVERFLOW_THOLD_C : integer := (2**HEADER_ADDR_WIDTH_G) - 10;
   constant DATA_OVERFLOW_THOLD_C   : integer := (2**DATA_ADDR_WIDTH_G) - 10;

   -- Local signals
   signal intWriteToFifo   : PpiWriteToFifoType;
   signal intWriteFromFifo : PpiWriteFromFifoType;
   signal intOnline        : sl;
   signal headerCount      : slv(HEADER_ADDR_WIDTH_G-1 downto 0);
   signal headerBuffFull   : sl;
   signal headerBuffAFull  : sl;
   signal headerOverflow   : sl;
   signal headerEmpty      : sl;
   signal dataCount        : slv(DATA_ADDR_WIDTH_G-1 downto 0);
   signal dataBuffFull     : sl;
   signal dataBuffAFull    : sl;
   signal dataOverflow     : sl;
   signal dataEmpty        : sl;
   signal headerOut        : slv(63 downto 0);
   signal headerIn         : slv(63 downto 0);
   signal headerWrite      : sl;
   signal headerValid      : sl;
   signal headerRead       : sl;
   signal dataRead         : sl;

   type DataFifoType is record
      data  : slv(63 downto 0);
      size  : slv(2  downto 0);
      eof   : sl;
      eofe  : sl;
      valid : sl;
   end record DataFifoType;

   constant DATA_FIFO_INIT_C : DataFifoType := (
      data  => (others=>'0'),
      size  => (others=>'0'),
      eof   => '0',
      eofe  => '0',
      valid => '0'
   );

   signal dataOut : DataFifoType;
   signal dataIn  : DataFifoType;

   type RegMoveType is record
      inFrame        : sl;
      dataRead       : sl;
      headerRead     : sl;
      ppiWriteToFifo : PpiWriteToFifoType;
   end record RegMoveType;


   constant REG_MOVE_INIT_C : RegMoveType := (
      inFrame        => '0',
      dataRead       => '0',
      headerRead     => '0',
      ppiWriteToFifo => PpiWriteToFifoInit
   );

   signal rm   : RegMoveType := REG_MOVE_INIT_C;
   signal rmin : RegMoveType;

   type RegType is record
      sof            : sl;
      eof            : sl;
      eofe           : sl;
      vc             : slv(1 downto 0);
      headerPend     : sl;
      drop           : sl;
      dropVc         : slv(3 downto 0);
      dataIn         : DataFifoType;
      headerIn       : slv(63 downto 0);
      headerWrite    : sl;
      count          : slv(31 downto 0);
      frameCountEn   : sl;
   end record RegType;

   constant REG_INIT_C : RegType := (
      sof            => '0',
      eof            => '0',
      eofe           => '0',
      vc             => (others=>'0'),
      headerPend     => '0',
      drop           => '0',
      dropVc         => (others=>'0'),
      dataIn         => DATA_FIFO_INIT_C,
      headerIn       => (others=>'0'),
      headerWrite    => '0', 
      count          => (others=>'0'),
      frameCountEn   => '0'
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

   U_InFifo : entity work.PpiFifoAsync
      generic map (
         TPD_G              => TPD_G,
         BRAM_EN_G          => true,
         USE_DSP48_G        => "no",
         SYNC_STAGES_G      => 3,
         ADDR_WIDTH_G       => PPI_ADDR_WIDTH_G,
         PAUSE_THOLD_G      => PPI_PAUSE_THOLD_G,
         READY_THOLD_G      => PPI_READY_THOLD_G,
         FIFO_TYPE_EN_G     => false
      ) port map (
         ppiWrClk         => vcRxClk,
         ppiWrClkRst      => vcRxClkRst,
         ppiWrOnline      => '0',
         ppiWriteToFifo   => intWriteToFifo,
         ppiWriteFromFifo => intWriteFromFifo,
         ppiRdClk         => ppiClk,
         ppiRdClkRst      => ppiClkRst,
         ppiRdOnline      => open,
         ppiReadToFifo    => ppiReadToFifo,
         ppiReadFromFifo  => ppiReadFromFifo
      );


   --------------------------------------------------
   -- Move Data From Header/Data FIFOs to PPI FIFO
   --------------------------------------------------

   -- Sync
   process (vcRxClk) is
   begin
      if (rising_edge(vcRxClk)) then
         rm <= rmin after TPD_G;
      end if;
   end process;

   -- Async
   process (vcRxClkRst, rm, intWriteFromFifo, intOnline, headerOut, headerValid, dataOut ) is
      variable v : RegMoveType;
   begin
      v := rm;

      v.ppiWriteToFifo := PpiWriteToFifoInit;
      v.headerRead     := '0';
      v.dataRead       := '0';

      if rm.inFrame = '0' then
         if headerValid = '1' and intWriteFromFifo.pause = '0' then
            v.ppiWriteToFifo.data  := headerOut;
            v.ppiWriteToFifo.size  := "111";
            v.ppiWriteToFifo.eof   := '0';
            v.ppiWriteToFifo.eoh   := '1';
            v.ppiWriteToFifo.valid := '1';
            v.headerRead           := '1';
            v.inFrame              := '1';
         end if;
      else
         v.ppiWriteToFifo.data  := dataOut.data;
         v.ppiWriteToFifo.size  := dataOut.size;
         v.ppiWriteToFifo.eof   := dataOut.eof;
         v.ppiWriteToFifo.eofe  := dataOut.eofe;
         v.ppiWriteToFifo.eoh   := '0';
         v.ppiWriteToFifo.valid := '1';
         v.dataRead             := '1';

         if dataOut.eof = '1' then
            v.inFrame := '0';
         end if;
      end if;

      -- Reset
      if vcRxClkRst = '1' or intOnline = '0' then
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
   U_HeadFifo : entity work.FifoSync 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         BRAM_EN_G      => true,
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         ALTERA_SYN_G   => false,
         ALTERA_RAM_G   => "M9K",
         DATA_WIDTH_G   => 64,
         ADDR_WIDTH_G   => HEADER_ADDR_WIDTH_G,
         INIT_G         => "0",
         FULL_THRES_G   => 1,
         EMPTY_THRES_G  => 0
      ) port map (
         rst          => vcRxClkRst,
         clk          => vcRxClk,
         wr_en        => headerWrite,
         rd_en        => headerRead,
         din          => headerIn,
         dout         => headerOut,
         data_count   => headerCount,
         wr_ack       => open,
         valid        => headerValid,
         overflow     => open,
         underflow    => open,
         prog_full    => open,
         prog_empty   => open,
         almost_full  => open,
         almost_empty => open,
         full         => open,
         not_full     => open,
         empty        => open
      );

   -- Data FIFO
   U_DataFifo : entity work.FifoSync 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         BRAM_EN_G      => true,
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         ALTERA_SYN_G   => false,
         ALTERA_RAM_G   => "M9K",
         DATA_WIDTH_G   => 69,
         ADDR_WIDTH_G   => DATA_ADDR_WIDTH_G,
         INIT_G         => "0",
         FULL_THRES_G   => 1,
         EMPTY_THRES_G  => 0
      ) port map (
         rst                => vcRxClkRst,
         clk                => vcRxClk,
         wr_en              => dataIn.valid,
         rd_en              => dataRead,
         din(63 downto  0)  => dataIn.data,
         din(66 downto 64)  => dataIn.size,
         din(67)            => dataIn.eof,
         din(68)            => dataIn.eofe,
         dout(63 downto  0) => dataOut.data,
         dout(66 downto 64) => dataOut.size,
         dout(67)           => dataOut.eof,
         dout(68)           => dataOut.eofe,
         data_count         => dataCount,
         wr_ack             => open,
         valid              => dataOut.valid,
         overflow           => open,
         underflow          => open,
         prog_full          => open,
         prog_empty         => open,
         almost_full        => open,
         almost_empty       => open,
         full               => open,
         not_full           => open,
         empty              => open
      );

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
      variable v         : RegType;
      variable nextWrite : sl;
      variable nextSize  : slv(2  downto 0);
      variable nextInc   : integer;
      variable nextRx    : sl;
   begin
      v := r;

      -- Init
      v.frameCountEn := '0';
      v.headerWrite  := '0';
      v.headerPend   := '0';
      v.dataIn.valid := '0';

      -- Overflow potential, mark drop flags
      if dataOverflow = '1' or headerOverflow = '1' then
         v.drop := '1';
      elsif dataOverflow = '0' and headerOverflow = '0' then
         v.drop := '0';
      end if;

      -- Determine data destination, size and write
      case VC_WIDTH_G is
         when 1 =>
            nextInc := 2;
            case r.count(1 downto 0) is
               when "00" =>
                  v.dataIn.data(15 downto 0) := r.vcRxCommonOut.data(0);
                  nextSize  := "001";
                  nextWrite := '0';
               when "01" =>
                  v.dataIn.data(31 downto 16) := r.vcRxCommonOut.data(0);
                  nextSize  := "011";
                  nextWrite := '0';
               when "10" =>
                  v.dataIn.data(47 downto 32) := r.vcRxCommonOut.data(0);
                  nextSize  := "101";
                  nextWrite := '0';
               when "11" =>
                  v.dataIn.data(63 downto 48) := r.vcRxCommonOut.data(0);
                  nextSize  := "111";
                  nextWrite := '1';
               when others =>
                  nextSize  := "000";
                  nextWrite := '0';
            end case;
         when 2 =>
            nextInc := 4;
            if r.count(0) = '0' then
               v.dataIn.data(31 downto 16) := r.vcRxCommonOut.data(1);
               v.dataIn.data(15 downto  0) := r.vcRxCommonOut.data(0);
               nextSize  := "011";
               nextWrite := '0';
            else
               v.dataIn.data(63 downto 48) := r.vcRxCommonOut.data(1);
               v.dataIn.data(47 downto 32) := r.vcRxCommonOut.data(0);
               nextSize  := "111";
               nextWrite := '1';
            end if;
         when 4 =>
            nextInc := 8;
            v.dataIn.data(63 downto 48) := r.vcRxCommonOut.data(3);
            v.dataIn.data(47 downto 32) := r.vcRxCommonOut.data(2);
            v.dataIn.data(31 downto 16) := r.vcRxCommonOut.data(1);
            v.dataIn.data(15 downto  0) := r.vcRxCommonOut.data(0);
            nextSize  := "111";
            nextWrite := '1';
         when others => 
            nextInc   := 0;
            nextSize  := "000";
            nextWrite := '0';
      end case;

      -- VC is valid
      if r.vcRxQuadOut(0).valid = '1' then
         v.vc   := "00";
         nextRx := '1';
      elsif r.vcRxQuadOut(1).valid = '1' then
         v.vc   := "01";
         nextRx := '1';
      elsif r.vcRxQuadOut(2).valid = '1' then
         v.vc   := "10";
         nextRx := '1';
      elsif r.vcRxQuadOut(3).valid = '1' then
         v.vc   := "11";
         nextRx := '1';
      else
         v.vc   := "00";
         nextRx := '0';
      end if;

      -- Frame in progress and not in drop mode
      if nextRx = '1' and r.drop = '0' then
         if r.regRxCommonOut.sof = '1' then
            v.sof := '1';
         end if;
         if r.regRxCommonOut.eof = '1' then
            v.eof := '1';
         end if;
         if r.regRxCommonOut.eofe = '1' then
            v.eofe := '1';
         end if;

         -- Increment
         v.count := r.count + nextInc;

         -- Data
         v.dataIn.valid := nextWrite;
         v.dataIn.size  := nextSize;
         v.dataIn.eof   := '0';

         -- Header is pending
         v.headerPend := '1';

         -- Force write of last value, look ahead one clock
         if vcRxQuadOut(conv_integer(v.vc)).valid = '0' then
            v.dataIn.eof   := '1';
            v.dataIn.eofe  := v.eofe;
            v.dataIn.valid := '1';
         end if;

         -- Overflow potential, end current frame and go into drop mode
         if dataOverflow = '1' or headerOverflow = '1' then
            v.eof          := '1';
            v.eofe         := '1';
            v.dataIn.eof   := '1';
            v.dataIn.eofe  := '1';
            v.dataIn.valid := '1';
            v.drop         := '1';
         end if;

      -- Header Write
      elsif r.headerPend = '1' then
         v.headerWrite           := '1';
         v.headerIn(1  downto 0) := r.vc;
         v.headerIn(16)          := r.sof;
         v.headerIn(17)          := r.eof;
         v.headerIn(18)          := r.eofe;
         v.headerIn(19)          := r.drop;
         v.count                 := (others=>'0');

         if r.eof = '1' then
            v.frameCountEn := '1';
         end if;
      end if;

      -- In drop mode and between frames, reset drop state if buffers are ok
      if nextRx = '0' and r.drop = '1' and dataOverflow = '0' and headerOverflow = '0' then
         v.drop := '0';
      end if;

      -- Reset
      if vcRxClkRst = '1' or intOnline = '0' then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      dataIn       <= r.dataIn;
      headerIn     <= r.headerIn;
      headerWrite  <= r.headerWrite;
      rxFrameCntEn <= r.frameCountEn;

   end process;

end architecture structure;

