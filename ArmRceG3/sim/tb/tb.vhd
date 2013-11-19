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

   signal axiClk          : sl;
   signal i2cSda          : sl;
   signal i2cScl          : sl;
   signal obPpiClk        : slv(3 downto 0);
   signal obPpiToFifo     : ObPpiToFifoVector(3 downto 0);
   signal obPpiFromFifo   : ObPpiFromFifoVector(3 downto 0);
   signal ibPpiClk        : slv(3 downto 0);
   signal ibPpiToFifo     : IbPpiToFifoVector(3 downto 0);
   signal ibPpiFromFifo   : IbPpiFromFifoVector(3 downto 0);

begin

   -- Core
   U_ArmRceG3Top: entity work.ArmRceG3Top
      port map (
         i2cSda             => i2cSda,
         i2cScl             => i2cScl,
         axiClk             => axiClk,
         axiClkRst          => open,
         sysClk125          => open,
         sysClk125Rst       => open,
         sysClk200          => open,
         sysClk200Rst       => open,
         localBusMaster     => open,
         localBusSlave      => (others=>LocalBusSlaveInit),
         ethFromArm         => open,
         ethToArm           => (others=>EthToArmInit),
         obPpiClk           => obPpiClk,
         obPpiToFifo        => obPpiToFifo,
         obPpiFromFifo      => obPpiFromFifo,
         ibPpiClk           => ibPpiClk,
         ibPpiToFifo        => ibPpiToFifo,
         ibPpiFromFifo      => ibPpiFromFifo,
         clkSelA            => open,
         clkSelB            => open,
         psSrstB            => '0',
         psClk              => '0',
         psPorB             => '0'
      );

   i2cSda <= '1';
   i2cScl <= '1';

   --------------------------------------------------
   -- PPI Loopback
   --------------------------------------------------
   U_LoopGen : for i in 0 to 3 generate

      ibPpiClk(i) <= axiClk;
      obPpiClk(i) <= axiClk;

      ibPpiToFifo(i).data    <= obPpiFromFifo(i).data;
      ibPpiToFifo(i).size    <= obPpiFromFifo(i).size;
      ibPpiToFifo(i).ftype   <= obPpiFromFifo(i).ftype;
      ibPpiToFifo(i).mgmt    <= obPpiFromFifo(i).mgmt;
      ibPpiToFifo(i).eoh     <= obPpiFromFifo(i).eoh;
      ibPpiToFifo(i).eof     <= obPpiFromFifo(i).eof;
      ibPpiToFifo(i).err     <= '0';
      ibPpiToFifo(i).id      <= (others=>'0');
      ibPpiToFifo(i).version <= (others=>'0');
      ibPpiToFifo(i).configA <= (others=>'0');
      ibPpiToFifo(i).configB <= (others=>'0');

      ibPpiToFifo(i).valid   <= obPpiFromFifo(i).valid;

      obPpiToFifo(i).read    <= obPpiFromFifo(i).valid;
      obPpiToFifo(i).id      <= (others=>'0');
      obPpiToFifo(i).version <= (others=>'0');
      obPpiToFifo(i).configA <= (others=>'0');
      obPpiToFifo(i).configB <= (others=>'0');

   end generate;

end tb;
