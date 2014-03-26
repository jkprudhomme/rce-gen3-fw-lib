-------------------------------------------------------------------------------
-- Title         : General Purpopse PPI FIFO
-- File          : PpiFifoAsync.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI FIFO block.
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

entity PpiFifoAsync is
   generic (
      TPD_G          : time                       := 1 ns;
      BRAM_EN_G      : boolean                    := true;
      USE_DSP48_G    : string                     := "no";
      SYNC_STAGES_G  : integer range 3 to (2**24) := 3;
      ADDR_WIDTH_G   : integer range 2 to 48      := 4;
      FULL_THRES_G   : integer range 1 to (2**24) := 1
   );
   port (

      -- Write Interface
      ppiWrClk         : in  sl;
      ppiWrClkRst      : in  sl;
      ppiWriteToFifo   : in  PpiWriteToFifoType;
      ppiWriteFromFifo : out PpiWriteFromFifoType;

      -- Read Interface
      ppiRdClk         : in  sl;
      ppiRdClkRst      : in  sl;
      ppiReadToFifo    : in  PpiReadToFifoType;
      ppiReadFromFifo  : out PpiReadFromFifoType
   );
end PpiFifoAsync;

architecture structure of PpiFifoAsync is

   -- Local signals
   signal intWriteFromFifo : PpiWriteFromFifoType;
   signal intReadFromFifo  : PpiReadFromFifoType;
   signal fifoDin          : slv(73 downto 0);
   signal fifoDout         : slv(73 downto 0);
   signal fifoWrEn         : sl;
   signal fifoWrEof        : sl;
   signal fifoRdEof        : sl;
   signal fifoEofEmpty     : sl;
   signal fifoRdEn         : sl;
   signal fifoValid        : sl;
   signal fifoPFull        : sl;
   signal fifoRst          : sl;

begin

   fifoRst <= ppiWrClkRst or ppiRdClkRst;

   fifoDin(63 downto  0)  <= ppiWriteToFifo.data;
   fifoDin(66 downto 64)  <= ppiWriteToFifo.ftype;
   fifoDin(67)            <= ppiWriteToFifo.mgmt;
   fifoDin(68)            <= ppiWriteToFifo.eof;
   fifoDin(69)            <= ppiWriteToFifo.eoh;
   fifoDin(70)            <= ppiWriteToFifo.err;
   fifoDin(73 downto 71)  <= ppiWriteToFifo.size;
   fifoWrEn               <= ppiWriteToFifo.valid;
   fifoWrEof              <= ppiWriteToFifo.eof;

   ppiWriteFromFifo.pause <= fifoPFull;


   U_Fifo: entity work.FifoAsync 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         BRAM_EN_G      => BRAM_EN_G,
         FWFT_EN_G      => true,
         USE_DSP48_G    => USE_DSP48_G,
         ALTERA_SYN_G   => false,
         ALTERA_RAM_G   => "M9K",
         SYNC_STAGES_G  => SYNC_STAGES_G,
         DATA_WIDTH_G   => 74,
         ADDR_WIDTH_G   => ADDR_WIDTH_G,
         INIT_G         => "0",
         FULL_THRES_G   => FULL_THRES_G,
         EMPTY_THRES_G  => 0
      ) port map (
         rst           => fifoRst,
         wr_clk        => ppiWrClk,
         wr_en         => fifoWrEn,
         din           => fifoDin,
         wr_data_count => open,
         wr_ack        => open,
         overflow      => open,
         prog_full     => fifoPFull,
         almost_full   => open,
         full          => open,
         not_full      => open,
         rd_clk        => ppiRdClk,
         rd_en         => fifoRdEn,
         dout          => fifoDout,
         rd_data_count => open,
         valid         => fifoValid,
         underflow     => open,
         prog_empty    => open,
         almost_empty  => open,
         empty         => open
      );


   U_EofFifo: entity work.FifoEofAsync 
      generic map (
         TPD_G         => TPD_G,
         USE_DSP48_G   => USE_DSP48_G,
         SYNC_STAGES_G => SYNC_STAGES_G,
         ADDR_WIDTH_G  => ADDR_WIDTH_G
      ) port map (
         rst           => fifoRst,
         wr_clk        => ppiWrClk,
         wr_en         => fifoWrEn,
         wr_eof        => fifoWrEof,
         rd_clk        => ppiRdClk,
         rd_en         => fifoRdEn,
         rd_eof        => fifoRdEof,
         empty         => fifoEofEmpty
      );


      ppiReadFromFifo.data   <= fifoDout(63 downto  0);
      ppiReadFromFifo.ftype  <= fifoDout(66 downto 64);
      ppiReadFromFifo.mgmt   <= fifoDout(67);
      ppiReadFromFifo.eof    <= fifoDout(68);
      ppiReadFromFifo.eoh    <= fifoDout(69);
      ppiReadFromFifo.err    <= fifoDout(70);
      ppiReadFromFifo.size   <= fifoDout(73 downto 71);

      ppiReadFromFifo.valid  <= fifoValid;
      ppiReadFromFifo.frame  <= not fifoEofEmpty;

      fifoRdEof <= fifoDout(68);
      fifoRdEn  <= ppiReadToFifo.read;

end architecture structure;

