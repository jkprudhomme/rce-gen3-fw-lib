-------------------------------------------------------------------------------
-- Title         : General Purpopse PPI Router
-- File          : PpiRouter.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to move data from one upstream FIFO to one of a number of 
-- downstream FIFOs. Destination is selected using the type field.
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

entity PpiRouter is
   generic (
      TPD_G             : time                  := 1 ns;
      NUM_WRITE_SLOTS_G : natural range 1 to 16 := 4
   );
   port (

      -- PPI Clock
      ppiClk           : in  sl;
      ppiClkRst        : in  sl;
      ppiOnline        : in  sl;

      -- Upstream 
      ppiReadToFifo    : out PpiReadToFifoType;
      ppiReadFromFifo  : in  PpiReadFromFifoType;

      -- Downstream
      ppiWriteToFifo   : out PpiWriteToFifoArray(NUM_WRITE_SLOTS_G-1 downto 0);
      ppiWriteFromFifo : in  PpiWriteFromFifoArray(NUM_WRITE_SLOTS_G-1 downto 0)

   );
end PpiRouter;

architecture structure of PpiRouter is

   -- Local signals
   signal readEnable  : sl;
   signal writeEnable : slv(NUM_WRITE_SLOTS_G-1 downto 0);
   signal dest        : slv(3 downto 0);
   signal pause       : sl;
   signal inFrame     : sl;

begin

   dest <= ppiReadFromFifo.ftype;

   pause <= ppiWriteFromFifo(conv_integer(dest)).pause;

   readEnable <= ppiReadFromFifo.valid and ((not pause) or inFrame);

   process ( readEnable ) begin
      writeEnable                     <= (others=>'0');

      if dest < NUM_WRITE_SLOTS_G then
         writeEnable(conv_integer(dest)) <= readEnable;
      end if;
   end process;

   process ( ppiClk ) begin
      if rising_edge(ppiClk) then

         if ppiClkRst = '1' then
            ppiWriteToFifo <= (others=>PPI_WRITE_TO_FIFO_INIT_C) after TPD_G;
            inFrame        <= '0'                                after TPD_G;
         else

            if writeEnable /= 0 then
               if ppiReadFromFifo.eof = '1' then
                  inFrame <= '0' after TPD_G;
               else
                  inFrame <= '1' after TPD_G;
               end if;
            end if;

            for i in 0 to NUM_WRITE_SLOTS_G-1 loop
               ppiWriteToFifo(i).data    <= ppiReadFromFifo.data  after TPD_G;
               ppiWriteToFifo(i).size    <= ppiReadFromFifo.size  after TPD_G;
               ppiWriteToFifo(i).eof     <= ppiReadFromFifo.eof   after TPD_G;
               ppiWriteToFifo(i).eoh     <= ppiReadFromFifo.eoh   after TPD_G;
               ppiWriteToFifo(i).err     <= ppiReadFromFifo.err   after TPD_G;
               ppiWriteToFifo(i).ftype   <= ppiReadFromFifo.ftype after TPD_G;
               ppiWriteToFifo(i).valid   <= writeEnable(i)        after TPD_G;
            end loop;
         end if;
      end if;
   end process;

   ppiReadToFifo.read <= readEnable;

end architecture structure;

