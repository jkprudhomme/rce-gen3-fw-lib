library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiPkg.all;

architecture Sim of RceG3Cpu is

begin

   ---------------------------------------
   -- Unused signals
   ---------------------------------------
   -- armInt
   -- armEtcRx
   armEthTx <= (others=>ARM_ETH_TX_INIT_C);

   ---------------------------------------
   -- Clock and reset generation
   ---------------------------------------

   -- Reset
   process begin
      fclkRst0  <= '0';
      fclkRst1  <= '0';
      fclkRst2  <= '0';
      fclkRst3  <= '0';
      wait for (10.0 ns);
      fclkRst0 <= '1';
      fclkRst1 <= '1';
      fclkRst2 <= '1';
      fclkRst3 <= '1';
      wait for (10.0 ns * 20);
      fclkRst0 <= '0';
      fclkRst1 <= '0';
      fclkRst2 <= '0';
      fclkRst3 <= '0';
      wait;
   end process;

   -- 100Mhz
   process begin
      fclkClk0 <= '0';
      fclkClk1 <= '0';
      fclkClk2 <= '0';
      fclkClk3 <= '0';
      wait for (10.0 ns / 2);
      fclkClk0 <= '1';
      fclkClk1 <= '1';
      fclkClk2 <= '1';
      fclkClk3 <= '1';
      wait for (10.0 ns / 2);
   end process;

   ---------------------------------------
   -- Master GP
   ---------------------------------------
   U_MasterGpGen : for i in 0 to 1 generate

      U_MasterGP : entity work.AxiSimMasterWrap 
         generic map (
            TPD_G       => TPD_G,
            MASTER_ID_G => i
         ) port map (
            axiClk            => mGpAxiClk(i),
            mstAxiReadMaster  => mGpReadMaster(i),
            mstAxiReadSlave   => mGpReadSlave(i),
            mstAxiWriteMaster => mGpWriteMaster(i),
            mstAxiWriteSlave  => mGpWriteSlave(i)
         );

   end generate;

   ---------------------------------------
   -- Slave GP
   ---------------------------------------
   U_SlaveGpGen : for i in 0 to 1 generate

      U_SlaveGp: entity work.AxiSimSlaveWrap 
         generic map (
            TPD_G      => TPD_G,
            SLAVE_ID_G => i+2
         ) port map (
            axiClk            => sGpAxiClk(i),
            slvAxiReadMaster  => sGpReadMaster(i),
            slvAxiReadSlave   => sGpReadSlave(i),
            slvAxiWriteMaster => sGpWriteMaster(i),
            slvAxiWriteSlave  => sGpWriteSlave(i)
         );

   end generate;

   ---------------------------------------
   -- Slave ACP
   ---------------------------------------
   U_SlaveAcp: entity work.AxiSimSlaveWrap 
      generic map (
         TPD_G      => TPD_G,
         SLAVE_ID_G => 4
      ) port map (
         axiClk            => acpAxiClk,
         slvAxiReadMaster  => acpReadMaster,
         slvAxiReadSlave   => acpReadSlave,
         slvAxiWriteMaster => acpWriteMaster,
         slvAxiWriteSlave  => acpWriteSlave
      );


   ---------------------------------------
   -- Slave HP
   ---------------------------------------
   U_SlaveHpGen : for i in 0 to 3 generate

      U_SlaveHp: entity work.AxiSimSlaveWrap 
         generic map (
            TPD_G      => TPD_G,
            SLAVE_ID_G => i+5
         ) port map (
            axiClk            => hpAxiClk(i),
            slvAxiReadMaster  => hpReadMaster(i),
            slvAxiReadSlave   => hpReadSlave(i),
            slvAxiWriteMaster => hpWriteMaster(i),
            slvAxiWriteSlave  => hpWriteSlave(i)
         );

   end generate;

end architecture Sim;

