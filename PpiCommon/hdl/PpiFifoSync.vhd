-------------------------------------------------------------------------------
-- Title         : General Purpopse PPI FIFO
-- File          : PpiFifoSync.vhd
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

entity PpiFifoSync is
   generic (
      TPD_G           : time                       := 1 ns;
      BRAM_EN_G       : boolean                    := true;
      USE_DSP48_G     : string                     := "no";
      ADDR_WIDTH_G    : integer range 2 to 48      := 9;
      PAUSE_THOLD_G   : integer range 1 to (2**24) := 255;
      READY_THOLD_G   : integer range 0 to 511     := 0;
      FIFO_TYPE_EN_G  : boolean                    := false
   );
   port (

      -- PPI Clock
      ppiClk           : in  sl;
      ppiClkRst        : in  sl;

      -- Write Interface
      ppiWriteToFifo   : in  PpiWriteToFifoType;
      ppiWriteFromFifo : out PpiWriteFromFifoType;

      -- Read Interface
      ppiReadToFifo    : in  PpiReadToFifoType;
      ppiReadFromFifo  : out PpiReadFromFifoType
   );
end PpiFifoSync;

architecture structure of PpiFifoSync is

   constant FIFO_WIDTH_C : integer := ite(FIFO_TYPE_EN_G, 74, 70);

   -- Local signals
   signal intWriteFromFifo : PpiWriteFromFifoType;
   signal intReadFromFifo  : PpiReadFromFifoType;
   signal fifoDin          : slv(FIFO_WIDTH_C-1 downto 0);
   signal fifoDout         : slv(FIFO_WIDTH_C-1 downto 0);
   signal fifoWrEn         : sl;
   signal fifoWrEof        : sl;
   signal fifoRdEof        : sl;
   signal fifoEofEmpty     : sl;
   signal fifoRdEn         : sl;
   signal fifoValid        : sl;
   signal fifoPFull        : sl;
   signal fifoRdCount      : slv(ADDR_WIDTH_G-1 downto 0);

begin

   fifoDin(63 downto  0)  <= ppiWriteToFifo.data;
   fifoDin(64)            <= ppiWriteToFifo.eof;
   fifoDin(65)            <= ppiWriteToFifo.eoh;
   fifoDin(66)            <= ppiWriteToFifo.err;
   fifoDin(69 downto 67)  <= ppiWriteToFifo.size;
   fifoWrEn               <= ppiWriteToFifo.valid;
   fifoWrEof              <= ppiWriteToFifo.eof and ppiWriteToFifo.valid;

   U_TypeInGen : if FIFO_TYPE_EN_G = true generate
      fifoDin(73 downto 70) <= ppiWriteToFifo.ftype;
   end generate;

   ppiWriteFromFifo.pause <= fifoPFull;

   -- Data FIFO
   U_Fifo: entity work.FifoSync 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         BRAM_EN_G      => BRAM_EN_G,
         FWFT_EN_G      => true,
         USE_DSP48_G    => USE_DSP48_G,
         ALTERA_SYN_G   => false,
         ALTERA_RAM_G   => "M9K",
         DATA_WIDTH_G   => FIFO_WIDTH_C,
         ADDR_WIDTH_G   => ADDR_WIDTH_G,
         INIT_G         => "0",
         FULL_THRES_G   => PAUSE_THOLD_G,
         EMPTY_THRES_G  => 1
      ) port map (
         rst           => ppiClkRst,
         clk           => ppiClk,
         wr_en         => fifoWrEn,
         din           => fifoDin,
         wr_ack        => open,
         overflow      => open,
         prog_full     => fifoPFull,
         almost_full   => open,
         full          => open,
         not_full      => open,
         rd_en         => fifoRdEn,
         dout          => fifoDout,
         data_count    => fifoRdCount,
         valid         => fifoValid,
         underflow     => open,
         prog_empty    => open,
         almost_empty  => open,
         empty         => open
      );

   -- Frame Counter
   U_EofFifo: entity work.FifoSync 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         BRAM_EN_G      => BRAM_EN_G,
         FWFT_EN_G      => true,
         USE_DSP48_G    => USE_DSP48_G,
         ALTERA_SYN_G   => false,
         ALTERA_RAM_G   => "M9K",
         DATA_WIDTH_G   => 1,
         ADDR_WIDTH_G   => ADDR_WIDTH_G,
         INIT_G         => "0",
         FULL_THRES_G   => PAUSE_THOLD_G,
         EMPTY_THRES_G  => 1
      ) port map (
         rst           => ppiClkRst,
         clk           => ppiClk,
         wr_en         => fifoWrEof,
         din           => "0",
         data_count    => open,
         wr_ack        => open,
         overflow      => open,
         prog_full     => open,
         almost_full   => open,
         full          => open,
         not_full      => open,
         rd_en         => fifoRdEof,
         dout          => open,
         valid         => open,
         underflow     => open,
         prog_empty    => open,
         almost_empty  => open,
         empty         => fifoEofEmpty
      );

   ppiReadFromFifo.data   <= fifoDout(63 downto  0);
   ppiReadFromFifo.eof    <= fifoDout(64);
   ppiReadFromFifo.eoh    <= fifoDout(65);
   ppiReadFromFifo.err    <= fifoDout(66);
   ppiReadFromFifo.size   <= fifoDout(69 downto 67);

   U_TypeOutEnGen : if FIFO_TYPE_EN_G = true generate
      ppiReadFromFifo.ftype <= fifoDout(73 downto 70);
   end generate;

   U_TypeOutDisGen : if FIFO_TYPE_EN_G = false generate
      ppiReadFromFifo.ftype <= (others=>'0');
   end generate;

   ppiReadFromFifo.valid  <= fifoValid;

   fifoRdEof <= fifoDout(64) and ppiReadToFifo.read;
   fifoRdEn  <= ppiReadToFifo.read;

   process (ppiClk) begin 
      if rising_edge (ppiClk) then
         if fifoEofEmpty = '0' or (READY_THOLD_G > 0 and fifoRdCount >= READY_THOLD_G) then
            ppiReadFromFifo.ready <= '1' after TPD_G;
         else
            ppiReadFromFifo.ready <= '0' after TPD_G;
         end if;
      end if;
   end process;

end architecture structure;

