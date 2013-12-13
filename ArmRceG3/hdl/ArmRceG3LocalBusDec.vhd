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
   signal dsEnable : slv(COUNT_G-1 downto 0);

begin

   -- Decode transactions on the way down
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         dsLocalBusMaster <= (others=>localBusMasterInit) after TPD_G;
         dsEnable         <= (others=>'0')                after TPD_G;
      elsif rising_edge(axiClk) then

         -- Each downstream client
         for i in 0 to COUNT_G-1 loop
            dsLocalBusMaster(i).addr        <= usLocalBusMaster.addr      after TPD_G;
            dsLocalBusMaster(i).writeData   <= usLocalBusMaster.writeData after TPD_G;
            dsLocalBusMaster(i).writeEnable <= '0'                        after TPD_G;
            dsLocalBusMaster(i).readEnable  <= '0'                        after TPD_G;
            dsEnable(i)                     <= '0'                        after TPD_G;

            -- Match address
            if (usLocalBusMaster.addr and dsLocalBusSlave(i).addrMask) = dsLocalBusSlave(i).addrBase then
               dsLocalBusMaster(i).writeEnable <= usLocalBusMaster.writeEnable after TPD_G;
               dsLocalBusMaster(i).readEnable  <= usLocalBusMaster.readEnable  after TPD_G;
               dsEnable(i)                     <= '1'                          after TPD_G;
            end if;
         end loop;
      end if;
   end process;

   -- Mux transactions on the way up
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         usLocalBusSlave <= localBusSlaveInit after TPD_G;
      elsif rising_edge(axiClk) then

         -- Init
         usLocalBusSlave <= localBusSlaveInit after TPD_G;

         -- Each downstream client
         for i in 0 to COUNT_G-1 loop
            if dsEnable(i) = '1' then
               usLocalBusSlave <= dsLocalBusSlave(i) after TPD_G;
            end if;
         end loop;
      end if;
   end process;

end architecture structure;

