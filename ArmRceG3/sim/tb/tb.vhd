LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
Library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;

entity tb is end tb;

-- Define architecture
architecture tb of tb is

   signal i2cSda : std_logic;
   signal i2cScl : std_logic;

begin

   -- Core
   U_ArmRceG3Top: entity work.ArmRceG3Top
      port map (
         i2cSda             => i2cSda,
         i2cScl             => i2cScl,
         axiClk             => open,
         axiClkRst          => open,
         sysClk125          => open,
         sysClk125Rst       => open,
         sysClk200          => open,
         sysClk200Rst       => open,
         localBusMaster     => open,
         localBusSlave      => (others=>LocalBusSlaveInit),
         ethFromArm         => open,
         ethToArm           => (others=>EthToArmInit)
      );

   i2cSda <= '1';
   i2cScl <= '1';

end tb;

