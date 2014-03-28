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
      TPD_G           : time                       := 1 ns;
      BRAM_EN_G       : boolean                    := true;
      USE_DSP48_G     : string                     := "no";
      SYNC_STAGES_G   : integer range 3 to (2**24) := 3;
      ADDR_WIDTH_G    : integer range 2 to 48      := 9;
      PAUSE_THOLD_G   : integer range 1 to (2**24) := 255;
      READY_THOLD_G   : integer range 0 to (2**24) := 0;
      FIFO_TYPE_EN_G  : boolean                    := false
   );
   port (

      -- Write Interface
      ppiWrClk         : in  sl;
      ppiWrClkRst      : in  sl;
      ppiWrOnline      : in  sl;
      ppiWriteToFifo   : in  PpiWriteToFifoType;
      ppiWriteFromFifo : out PpiWriteFromFifoType;

      -- Read Interface
      ppiRdClk         : in  sl;
      ppiRdClkRst      : in  sl;
      ppiRdOnline      : out sl;
      ppiReadToFifo    : in  PpiReadToFifoType;
      ppiReadFromFifo  : out PpiReadFromFifoType
   );
end PpiFifoAsync;

architecture structure of PpiFifoAsync is

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
   signal fifoRst          : sl;
   signal fifoRdCount      : slv(ADDR_WIDTH_G-1 downto 0);

begin

   -- Online Sync
   U_OnlineSync : entity work.Synchronizer 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         OUT_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 2,
         INIT_G         => "0"
      ) port map (
         clk     => ppiRdClk,
         rst     => ppiRdClkRst,
         dataIn  => ppiWrOnline,
         dataOut => ppiRdOnline
      );

   -- FIFO reset
   fifoRst <= ppiWrClkRst or ppiRdClkRst;

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
         DATA_WIDTH_G   => FIFO_WIDTH_C,
         ADDR_WIDTH_G   => ADDR_WIDTH_G,
         INIT_G         => "0",
         FULL_THRES_G   => PAUSE_THOLD_G,
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
         rd_data_count => fifoRdCount,
         valid         => fifoValid,
         underflow     => open,
         prog_empty    => open,
         almost_empty  => open,
         empty         => open
      );

   -- Frame Counter
   U_EofFifo: entity work.FifoAsync 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         BRAM_EN_G      => BRAM_EN_G,
         FWFT_EN_G      => true,
         USE_DSP48_G    => USE_DSP48_G,
         ALTERA_SYN_G   => false,
         ALTERA_RAM_G   => "M9K",
         SYNC_STAGES_G  => SYNC_STAGES_G,
         DATA_WIDTH_G   => 1,
         ADDR_WIDTH_G   => ADDR_WIDTH_G,
         INIT_G         => "0",
         FULL_THRES_G   => PAUSE_THOLD_G,
         EMPTY_THRES_G  => 0
      ) port map (
         rst           => fifoRst,
         wr_clk        => ppiWrClk,
         wr_en         => fifoWrEof,
         din           => "0",
         wr_data_count => open,
         wr_ack        => open,
         overflow      => open,
         prog_full     => open,
         almost_full   => open,
         full          => open,
         not_full      => open,
         rd_clk        => ppiRdClk,
         rd_en         => fifoRdEof,
         dout          => open,
         rd_data_count => open,
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

   fifoRdEof <= fifoDout(68) and ppiReadToFifo.read;
   fifoRdEn  <= ppiReadToFifo.read;

   process (ppiRdClk) begin 
      if rising_edge (ppiRdClk) then
         if fifoEofEmpty = '0' or (READY_THOLD_G > 0 and fifoRdCount > READY_THOLD_G) then
            ppiReadFromFifo.ready <= '1' after TPD_G;
         else
            ppiReadFromFifo.ready <= '0' after TPD_G;
         end if;
      end if;
   end process;

end architecture structure;

