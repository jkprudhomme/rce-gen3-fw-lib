LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
Library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity tb is end tb;

-- Define architecture
architecture tb of tb is

   signal axiClk           : sl;
   signal i2cSda           : sl;
   signal i2cScl           : sl;
   signal ppiClk           : slv(3 downto 0);
   signal ppiReadToFifo    : PpiReadToFifoArray(3 downto 0);
   signal ppiReadFromFifo  : PpiReadFromFifoArray(3 downto 0);
   signal ppiWriteToFifo   : PpiWriteToFifoArray(3 downto 0);
   signal ppiWriteFromFifo : PpiWriteFromFifoArray(3 downto 0);
   signal sysClk125        : sl;
   signal sysClk125Rst     : sl;

begin

   -- Core
   U_ArmRceG3Top: entity work.ArmRceG3Top
      port map (
         i2cSda             => i2cSda,
         i2cScl               => i2cScl,
         axiClk               => axiClk,
         axiClkRst            => open,
         sysClk125            => sysClk125,
         sysClk125Rst         => sysCLk125Rst,
         sysClk200            => open,
         sysClk200Rst         => open,
         localAxiReadMaster   => open,
         localAxiReadSlave    => AXI_READ_SLAVE_INIT_C, 
         localAxiWriteMaster  => open,
         localAxiWriteSlave   => AXI_WRITE_SLAVE_INIT_C,
         ethFromArm           => open,
         ethToArm             => (others=>EthToArmInit),
         ppiClk               => ppiClk,
         ppiOnline            => open,
         ppiReadToFifo        => ppiReadToFifo,
         ppiReadFromFifo      => ppiReadFromFifo,
         ppiWriteToFifo       => ppiWriteToFifo,
         ppiWriteFromFifo     => ppiWriteFromFifo,
         clkSelA              => open,
         clkSelB              => open
      );

   i2cSda <= '1';
   i2cScl <= '1';

   --------------------------------------------------
   -- PPI Loopback
   --------------------------------------------------
   U_LoopGen : for i in 0 to 2 generate

      ppiClk(i) <= sysCLk125;

      ppiWriteToFifo(i).data    <= ppiReadFromFifo(i).data;
      ppiWriteToFifo(i).size    <= ppiReadFromFifo(i).size;
      ppiWriteToFifo(i).ftype   <= ppiReadFromFifo(i).ftype;
      ppiWriteToFifo(i).eoh     <= ppiReadFromFifo(i).eoh;
      ppiWriteToFifo(i).eof     <= ppiReadFromFifo(i).eof;
      ppiWriteToFifo(i).err     <= '0';

      ppiWriteToFifo(i).valid   <= ppiReadFromFifo(i).valid;

      ppiReadToFifo(i).read     <= ppiReadFromFifo(i).valid;

   end generate;


   --------------------------------------------------
   -- Register Test
   --------------------------------------------------













   U_RegTest: entity work.RegTest
      generic map (
         TPD_G        => 1 ns
      ) port map (
         axiClk           => sysClk125,
         axiClkRst        => sysClk125Rst,
         ppiClk           => sysClk125,
         ppiClkRst        => sysClk125Rst,
         ppiOnline        => '1',
         ppiReadToFifo    => ppiReadToFifo(3),
         ppiReadFromFifo  => ppiReadFromFifo(3),
         ppiWriteToFifo   => ppiWriteToFifo(3),
         ppiWriteFromFifo => ppiWriteFromFifo(3)
      );

      ppiClk(3) <= sysCLk125;

end tb;

