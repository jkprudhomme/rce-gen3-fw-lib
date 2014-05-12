library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiPkg.all;

architecture Sim of ArmRceG3Cpu is

begin

   ---------------------------------------
   -- Unused signals
   ---------------------------------------
   -- armInt    : in slv(15 downto 0);
   -- ethToArm  : in EthToArmType
   ethFromArm <= (others=>ETH_FROM_ARM_INIT_C);

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
            axiClk            => axiClk,
            mstAxiReadMaster  => axiGpMasterReadFromArm(i),
            mstAxiReadSlave   => axiGpMasterReadToArm(i),
            mstAxiWriteMaster => axiGpMasterWriteFromArm(i),
            mstAxiWriteSlave  => axiGpMasterWriteToArm(i)
         );

   end generate;

   ---------------------------------------
   -- Slave GP
   ---------------------------------------
   U_SlaveGpGen : for i in 0 to 1 generate

      U_SlaveGp: entity work.AxiSimSlaveWrap 
         generic map (
            TPD_G      => TPD_G,
            SLAVE_ID_G => i
         ) port map (
            axiClk            => axiClk,
            slvAxiReadMaster  => axiGpSlaveReadToArm(i),
            slvAxiReadSlave   => axiGpSlaveReadFromArm(i),
            slvAxiWriteMaster => axiGpSlaveWriteToArm(i),
            slvAxiWriteSlave  => axiGpSlaveWriteFromArm(i)
         );

   end generate;

   ---------------------------------------
   -- Slave ACP
   ---------------------------------------
   U_SlaveAcp: entity work.AxiSimSlaveWrap 
      generic map (
         TPD_G      => TPD_G,
         SLAVE_ID_G => 2
      ) port map (
         axiClk            => axiClk,
         slvAxiReadMaster  => axiAcpSlaveReadToArm,
         slvAxiReadSlave   => axiAcpSlaveReadFromArm,
         slvAxiWriteMaster => axiAcpSlaveWriteToArm,
         slvAxiWriteSlave  => axiAcpSlaveWriteFromArm
      );


   ---------------------------------------
   -- Slave HP
   ---------------------------------------
   U_SlaveHpGen : for i in 0 to 3 generate

      U_SlaveHp: entity work.AxiSimSlaveWrap 
         generic map (
            TPD_G      => TPD_G,
            SLAVE_ID_G => i+3
         ) port map (
            axiClk            => axiClk,
            slvAxiReadMaster  => axiHpSlaveReadToArm(i),
            slvAxiReadSlave   => axiHpSlaveReadFromArm(i),
            slvAxiWriteMaster => axiHpSlaveWriteToArm(i),
            slvAxiWriteSlave  => axiHpSlaveWriteFromArm(i)
         );

   end generate;

end architecture Sim;

