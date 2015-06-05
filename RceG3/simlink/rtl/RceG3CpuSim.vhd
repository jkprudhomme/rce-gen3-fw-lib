-------------------------------------------------------------------------------
-- Title         : RCE Generation 3, CPU Wrapper
-- File          : RceG3Cpu.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- CPU wrapper for ARM based rce generation 3 processor core.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library unisim;
use unisim.vcomponents.all;

use work.all;
use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiPkg.all;

entity RceG3CpuSim is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clocks
      fclkClk3            : out sl;
      fclkClk2            : out sl;
      fclkClk1            : out sl;
      fclkClk0            : out sl;
      fclkRst3            : out sl;
      fclkRst2            : out sl;
      fclkRst1            : out sl;
      fclkRst0            : out sl;

      -- Interrupts
      armInterrupt        : in  slv(15 downto 0);

      -- AXI GP Master
      mGpAxiClk           : in  slv(1 downto 0);
      mGpWriteMaster      : out AxiWriteMasterArray(1 downto 0);
      mGpWriteSlave       : in  AxiWriteSlaveArray(1 downto 0);
      mGpReadMaster       : out AxiReadMasterArray(1 downto 0);
      mGpReadSlave        : in  AxiReadSlaveArray(1 downto 0);

      -- AXI GP Slave
      sGpAxiClk           : in  slv(1 downto 0);
      sGpWriteSlave       : out AxiWriteSlaveArray(1 downto 0);
      sGpWriteMaster      : in  AxiWriteMasterArray(1 downto 0);
      sGpReadSlave        : out AxiReadSlaveArray(1 downto 0);
      sGpReadMaster       : in  AxiReadMasterArray(1 downto 0);

      -- AXI ACP Slave
      acpAxiClk           : in  sl;
      acpWriteSlave       : out AxiWriteSlaveType;
      acpWriteMaster      : in  AxiWriteMasterType;
      acpReadSlave        : out AxiReadSlaveType;
      acpReadMaster       : in  AxiReadMasterType;

      -- AXI HP Slave
      hpAxiClk            : in  slv(3 downto 0);
      hpWriteSlave        : out AxiWriteSlaveArray(3 downto 0);
      hpWriteMaster       : in  AxiWriteMasterArray(3 downto 0);
      hpReadSlave         : out AxiReadSlaveArray(3 downto 0);
      hpReadMaster        : in  AxiReadMasterArray(3 downto 0);

      -- Ethernet
      armEthTx            : out ArmEthTxArray(1 downto 0);
      armEthRx            : in  ArmEthRxArray(1 downto 0)
   );
end RceG3CpuSim;

architecture Sim of RceG3CpuSim is

begin

   ---------------------------------------
   -- Unused signals
   ---------------------------------------
   -- armInterrupt
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

