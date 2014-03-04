-------------------------------------------------------------------------------
-- Title         : Local Bus Mux
-- File          : ArmRceG3LocalBusDecMux.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/12/2013
-------------------------------------------------------------------------------
-- Description:
-- Local Bus Decode/Mux Block
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/12/2013: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.std_logic_arith.all;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;

entity ArmRceG3LocalBusDec is
   generic (
      TPD_G   : time    := 1 ns;
      COUNT_G : integer := 1
   );
   port (

      -- Clocks & Reset
      axiClk                  : in     sl;
      axiClkRst               : in     sl;

      -- Local bus upstream
      usLocalBusMaster        : in     LocalBusMasterType;
      usLocalBusSlave         : out    LocalBusSlaveType;

      -- Local bus downstream
      dsLocalBusMaster        : out    LocalBusMasterVector(COUNT_G-1 downto 0);
      dsLocalBusSlave         : in     LocalBusSlaveVector(COUNT_G-1 downto 0)
   );
end ArmRceG3LocalBusDec;

architecture structure of ArmRceG3LocalBusDec is

   -- Local signals
   signal dsSelect     : slv(7 downto 0);
   signal axiClkRstInt : sl := '1';

   attribute mark_debug : string;
   attribute mark_debug of axiClkRstInt : signal is "true";

   attribute INIT : string;
   attribute INIT of axiClkRstInt : signal is "1";

begin

   -- Reset registration
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         axiClkRstInt <= axiClkRst after TPD_G;
      end if;
   end process;

   -- Decode transactions on the way down
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            dsLocalBusMaster <= (others=>localBusMasterInit) after TPD_G;
            dsSelect         <= (others=>'0')                after TPD_G;
         else

            -- Init 
            dsSelect <= (others=>'0') after TPD_G;

            -- Each downstream client
            for i in 0 to COUNT_G-1 loop
               dsLocalBusMaster(i).addr        <= usLocalBusMaster.addr      after TPD_G;
               dsLocalBusMaster(i).writeData   <= usLocalBusMaster.writeData after TPD_G;
               dsLocalBusMaster(i).writeEnable <= '0'                        after TPD_G;
               dsLocalBusMaster(i).readEnable  <= '0'                        after TPD_G;

               -- Match address
               if (usLocalBusMaster.addr and dsLocalBusSlave(i).addrMask) = dsLocalBusSlave(i).addrBase then
                  dsLocalBusMaster(i).writeEnable <= usLocalBusMaster.writeEnable after TPD_G;
                  dsLocalBusMaster(i).readEnable  <= usLocalBusMaster.readEnable  after TPD_G;
                  dsSelect                        <= conv_std_logic_vector(i,8)   after TPD_G;
               end if;
            end loop;
         end if;
      end if;
   end process;

   -- Mux transactions on the way up
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            usLocalBusSlave <= localBusSlaveInit after TPD_G;
         else

            usLocalBusSlave <= dsLocalBusSlave(conv_integer(dsSelect)) after TPD_G;

            -- Init
            --usLocalBusSlave <= localBusSlaveInit after TPD_G;

            -- Each downstream client
            --for i in 0 to COUNT_G-1 loop
               --if dsEnable(i) = '1' then
                  --usLocalBusSlave <= dsLocalBusSlave(i) after TPD_G;
               --end if;
            --end loop;
         end if;
      end if;
   end process;

end architecture structure;

