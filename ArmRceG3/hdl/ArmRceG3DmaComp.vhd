-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Completion FIFOs
-- File          : ArmRceG3DmaComp.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 09/03/2013
-------------------------------------------------------------------------------
-- Description:
-- Completion Data Mover and completion FIFOs
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
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

entity ArmRceG3DmaComp is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clock
      axiClk                  : in  sl;
      axiClkRst               : in  sl;

      -- Completion FIFOs
      compFromFifo            : in  CompFromFifoVector(7 downto 0);
      compToFifo              : out CompToFifoVector(7 downto 0);

      -- FIFO Read 
      compFifoSel             : in  slv(3  downto 0);
      compFifoData            : out slv(31 downto 0);
      compFifoRd              : in  sl;
      compFifoRdValid         : out sl;

      -- FIFO Interrupts
      compInt                 : out slv(10 downto 0)

   );
end ArmRceG3DmaComp;

architecture structure of ArmRceG3DmaComp is

   -- Local Signals
   signal fifoCount     : slv(2 downto 0);
   signal fifoRead      : slv(7 downto 0);
   signal compHold      : CompFromFifoVector(7 downto 0);
   signal compWrite     : Slv16Array(7 downto 0);
   signal compDest      : Slv4Array(7 downto 0);
   signal compValid     : slv(7 downto 0);
   signal compFifoDout  : Slv36Array(10 downto 0);
   signal compFifoDin   : slv(35 downto 0);
   signal compFifoWrEn  : slv(10 downto 0);
   signal compFifoRdEn  : slv(10 downto 0);
   signal compFifoRdDly : sl;
   signal compFifoPFull : slv(10 downto 0);
   signal compFifoValid : slv(10 downto 0);

   -- Mark For Debug
   --attribute mark_debug                  : string;
   --attribute mark_debug of fifoCount     : signal is "true";
   --attribute mark_debug of fifoRead      : signal is "true";
   --attribute mark_debug of compHold      : signal is "true";
   --attribute mark_debug of compWrite     : signal is "true";
   --attribute mark_debug of compDest      : signal is "true";
   --attribute mark_debug of compValid     : signal is "true";
   --attribute mark_debug of compFifoDin   : signal is "true";
   --attribute mark_debug of compFifoWrEn  : signal is "true";
   --attribute mark_debug of compFifoRdEn  : signal is "true";
   --attribute mark_debug of compFifoRdDly : signal is "true";
   --attribute mark_debug of compFifoPFull : signal is "true";
   --attribute mark_debug of compFifoValid : signal is "true";

begin

   -- Holding location for FIFO outputs
   -- 8 Clocks are available for update
   U_HoldGen: for i in 0 to 7 generate
      process ( axiClk, axiClkRst ) begin
         if axiClkRst = '1' then
            compHold(i)  <= CompFromFifoInit after TPD_G;
            compValid(i) <= '0'              after TPD_G;
            compWrite(i) <= (others=>'0')    after TPD_G;
         elsif rising_edge(axiClk) then

            -- Copy of FIFO data
            compHold(i) <= compFromFifo(i) after TPD_G;

            -- Determine if source and destination is ready, set valid bit
            compValid(i) <= compFromFifo(i).valid and 
                            (not compFifoPFull(conv_integer(compDest(i)))) after TPD_G;

            -- Generate write vector
            compWrite(i)                            <= (others=>'0') after TPD_G;
            compWrite(i)(conv_integer(compDest(i))) <= '1'           after TPD_G;

         end if;
      end process;

      -- Filter destination
      compDest(i) <= compFromFifo(i).index when compFromFifo(i).index < 12 else "0000";

      -- Ready output
      compToFifo(i).read <= fifoRead(i);

   end generate;


   -- Sync logic
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         compFifoDin  <= (others=>'0') after TPD_G;
         compFifoWrEn <= (others=>'0') after TPD_G;
         fifoRead     <= (others=>'0') after TPD_G;
         fifoCount    <= (others=>'0') after TPD_G;
      elsif rising_edge(axiClk) then
         compFifoDin(31 downto 0) <= compHold(conv_integer(fifoCount)).id  after TPD_G;

         -- Move data to output register
         for i in 0 to 10 loop
            compFifoWrEn(i) <= compValid(conv_integer(fifoCount)) and 
                               compWrite(conv_integer(fifoCount))(i) after TPD_G;
         end loop;

         -- Read from source fifo
         fifoRead                          <= (others=>'0')                      after TPD_G; 
         fifoRead(conv_integer(fifoCount)) <= compValid(conv_integer(fifoCount)) after TPD_G;

         -- Fifo counter
         fifoCount <= fifoCount + 1 after TPD_G;

      end if;
   end process;

   -----------------------------------------
   -- FIFOs
   -----------------------------------------
   U_FifoGen: for i in 0 to 10 generate
      U_CompFifo : entity work.FifoSyncBuiltIn 
         generic map (
            TPD_G          => TPD_G,
            RST_POLARITY_G => '1',
            FWFT_EN_G      => true,
            USE_DSP48_G    => "no",
            XIL_DEVICE_G   => "7SERIES",
            DATA_WIDTH_G   => 36,
            ADDR_WIDTH_G   => 9,
            FULL_THRES_G   => 479,
            EMPTY_THRES_G  => 1
         ) port map (
            rst               => axiClkRst,
            clk               => axiClk,
            wr_en             => compFifoWrEn(i),
            din               => compFifoDin,
            data_count        => open,
            wr_ack            => open,
            overflow          => open,
            prog_full         => compFifoPFull(i),
            almost_full       => open,
            full              => open,
            not_full          => open,
            rd_en             => compFifoRdEn(i),
            dout              => compFifoDout(i),
            valid             => compFifoValid(i),
            underflow         => open,
            prog_empty        => open,
            almost_empty      => open,
            empty             => open
         );
   end generate;

   -----------------------------------------
   -- FIFO Read
   -----------------------------------------
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         compFifoRdValid <= '0'           after TPD_G;
         compInt         <= (others=>'0') after TPD_G;
         compFifoRdEn    <= (others=>'0') after TPD_G;
         compFifoRdDly   <= '0'           after TPD_G;
         compFifoData    <= (others=>'0') after TPD_G;
      elsif rising_edge(axiClk) then
         compFifoRdDly   <= compFifoRd    after TPD_G;
         compFifoRdValid <= compFifoRdDly after TPD_G;
         compInt         <= compFifoValid after TPD_G;
         compFifoRdEn    <= (others=>'0') after TPD_G;

         if compFifoSel < 11 then
            compFifoRdEn(conv_integer(compFifoSel)) <= compFifoRd after TPD_G;
         end if;

         if compFifoSel < 11 then
            compFifoData <= compFifoDout(conv_integer(compFifoSel))(31 downto 0) after TPD_G;
         else
            compFifoData <= (others=>'0') after TPD_G;
         end if;

      end if;
   end process;

end architecture structure;

