-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Top Level
-- File          : RceG3Top.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Top level file for ARM based rce generation 3 processor core.
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

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;

entity RceG3Top is
   generic (
      TPD_G                 : time                  := 1 ns;
      DMA_CLKDIV_EN_G       : boolean               := false;
      DMA_CLKDIV_G          : real                  := 5.0;
      RCE_DMA_MODE_G        : RceDmaModeType        := RCE_DMA_PPI_C;
      OLD_BSI_MODE_G        : boolean               := false;
      SIM_MODEL_G           : boolean               := false
   );
   port (

      -- I2C
      i2cSda                   : inout sl;
      i2cScl                   : inout sl;

      -- Clocks
      sysClk125                : out   sl;
      sysClk125Rst             : out   sl;
      sysClk200                : out   sl;
      sysClk200Rst             : out   sl;

      -- AXI Bus Clock
      axiClk                   : out   sl;
      axiClkRst                : out   sl;

      -- External Axi Bus, 0xA0000000 - 0xAFFFFFFF
      extAxilReadMaster        : out   AxiLiteReadMasterType;
      extAxilReadSlave         : in    AxiLiteReadSlaveType;
      extAxilWriteMaster       : out   AxiLiteWriteMasterType;
      extAxilWriteSlave        : in    AxiLiteWriteSlaveType;

      -- Core Axi Bus, 0xB0000000 - 0xBFFFFFFF
      coreAxilReadMaster       : out   AxiLiteReadMasterType;
      coreAxilReadSlave        : in    AxiLiteReadSlaveType;
      coreAxilWriteMaster      : out   AxiLiteWriteMasterType;
      coreAxilWriteSlave       : in    AxiLiteWriteSlaveType;

      -- DMA Interfaces
      dmaClk                   : in    slv(3 downto 0);
      dmaClkRst                : in    slv(3 downto 0);
      dmaState                 : out   RceDmaStateArray(3 downto 0);
      dmaObMaster              : out   AxiStreamMasterArray(3 downto 0);
      dmaObSlave               : in    AxiStreamSlaveArray(3 downto 0);
      dmaIbMaster              : in    AxiStreamMasterArray(3 downto 0);
      dmaIbSlave               : out   AxiStreamSlaveArray(3 downto 0);

      -- User Interrupts
      userInterrupt            : in    slv(USER_INT_COUNT_C-1 downto 0);

      -- Ethernet
      armEthTx                 : out   ArmEthTxArray(1 downto 0);
      armEthRx                 : in    ArmEthRxArray(1 downto 0);
      armEthMode               : in    slv(31 downto 0);

      -- Programmable Clock Select
      clkSelA                  : out   slv(1 downto 0);
      clkSelB                  : out   slv(1 downto 0)
   );
end RceG3Top;

architecture structure of RceG3Top is

   -- Local signals
   signal fclkClk3            : sl;
   signal fclkClk2            : sl;
   signal fclkClk1            : sl;
   signal fclkClk0            : sl;
   signal fclkRst3            : sl;
   signal fclkRst2            : sl;
   signal fclkRst1            : sl;
   signal fclkRst0            : sl;
   signal isysClk125          : sl;
   signal isysClk125Rst       : sl;
   signal isysClk200          : sl;
   signal isysClk200Rst       : sl;
   signal axiDmaClk           : sl;
   signal axiDmaRst           : sl;
   signal mGpWriteMaster      : AxiWriteMasterArray(1 downto 0);
   signal mGpWriteSlave       : AxiWriteSlaveArray(1 downto 0);
   signal mGpReadMaster       : AxiReadMasterArray(1 downto 0);
   signal mGpReadSlave        : AxiReadSlaveArray(1 downto 0);
   signal acpWriteSlave       : AxiWriteSlaveType;
   signal acpWriteMaster      : AxiWriteMasterType;
   signal acpReadSlave        : AxiReadSlaveType;
   signal acpReadMaster       : AxiReadMasterType;
   signal hpWriteSlave        : AxiWriteSlaveArray(3 downto 0);
   signal hpWriteMaster       : AxiWriteMasterArray(3 downto 0);
   signal hpReadSlave         : AxiReadSlaveArray(3 downto 0);
   signal hpReadMaster        : AxiReadMasterArray(3 downto 0);
   signal bsiAxilReadMaster   : AxiLiteReadMasterArray(1 downto 0);
   signal bsiAxilReadSlave    : AxiLiteReadSlaveArray(1 downto 0);
   signal bsiAxilWriteMaster  : AxiLiteWriteMasterArray(1 downto 0);
   signal bsiAxilWriteSlave   : AxiLiteWriteSlaveArray(1 downto 0);
   signal dmaAxilReadMaster   : AxiLiteReadMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
   signal dmaAxilReadSlave    : AxiLiteReadSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);
   signal dmaAxilWriteMaster  : AxiLiteWriteMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
   signal dmaAxilWriteSlave   : AxiLiteWriteSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);
   signal icAxilReadMaster    : AxiLiteReadMasterType;
   signal icAxilReadSlave     : AxiLiteReadSlaveType;
   signal icAxilWriteMaster   : AxiLiteWriteMasterType;
   signal icAxilWriteSlave    : AxiLiteWriteSlaveType;
   signal bsiAcpWriteSlave    : AxiWriteSlaveType;
   signal bsiAcpWriteMaster   : AxiWriteMasterType;
   signal dmaAcpWriteSlave    : AxiWriteSlaveType;
   signal dmaAcpWriteMaster   : AxiWriteMasterType;
   signal armInterrupt        : slv(15 downto 0);
   signal dmaInterrupt        : slv(DMA_INT_COUNT_C-1 downto 0);
   signal bsiInterrupt        : sl;
   signal eFuseValue          : slv(31 downto 0);
   signal deviceDna           : slv(63 downto 0);

   attribute KEEP_HIERARCHY : string;
   attribute KEEP_HIERARCHY of
      U_RceG3Clocks,
      U_RceG3AxiCntl,
      U_RceG3Bsi,
      U_RceG3Dma,
      U_RceG3IntCntl : label is "TRUE";    
   
begin

   --------------------------------------------
   -- Processor Core
   --------------------------------------------

   U_SimModeDis : if SIM_MODEL_G = false generate
      U_RceG3Cpu : entity work.RceG3Cpu
         generic map (
            TPD_G => TPD_G
         ) port map (
            fclkClk3             => fclkClk3,
            fclkClk2             => fclkClk2,
            fclkClk1             => fclkClk1,
            fclkClk0             => fclkClk0,
            fclkRst3             => fclkRst3,
            fclkRst2             => fclkRst2,
            fclkRst1             => fclkRst1,
            fclkRst0             => fclkRst0,
            armInterrupt         => armInterrupt,
            mGpAxiClk(0)         => axiDmaClk,
            mGpAxiClk(1)         => isysClk125,
            mGpWriteMaster       => mGpWriteMaster,
            mGpWriteSlave        => mGpWriteSlave,
            mGpReadMaster        => mGpReadMaster,
            mGpReadSlave         => mGpReadSlave,
            sGpAxiClk(0)         => axiDmaClk,
            sGpAxiClk(1)         => axiDmaClk,
            sGpWriteSlave        => open,
            sGpWriteMaster       => (others=>AXI_WRITE_MASTER_INIT_C),
            sGpReadSlave         => open,
            sGpReadMaster        => (others=>AXI_READ_MASTER_INIT_C),
            acpAxiClk            => axiDmaClk,
            acpWriteSlave        => acpWriteSlave,
            acpWriteMaster       => acpWriteMaster,
            acpReadSlave         => acpReadSlave,
            acpReadMaster        => acpReadMaster,
            hpAxiClk(0)          => axiDmaClk,
            hpAxiClk(1)          => axiDmaClk,
            hpAxiClk(2)          => axiDmaClk,
            hpAxiClk(3)          => axiDmaClk,
            hpWriteSlave         => hpWriteSlave,
            hpWriteMaster        => hpWriteMaster,
            hpReadSlave          => hpReadSlave,
            hpReadMaster         => hpReadMaster,
            armEthTx             => armEthTx,
            armEthRx             => armEthRx
         );
   end generate;

   U_SimModeEn : if SIM_MODEL_G = true generate
      U_RceG3Cpu : entity work.RceG3CpuSim
         generic map (
            TPD_G => TPD_G
         ) port map (
            fclkClk3             => fclkClk3,
            fclkClk2             => fclkClk2,
            fclkClk1             => fclkClk1,
            fclkClk0             => fclkClk0,
            fclkRst3             => fclkRst3,
            fclkRst2             => fclkRst2,
            fclkRst1             => fclkRst1,
            fclkRst0             => fclkRst0,
            armInterrupt         => armInterrupt,
            mGpAxiClk(0)         => axiDmaClk,
            mGpAxiClk(1)         => isysClk125,
            mGpWriteMaster       => mGpWriteMaster,
            mGpWriteSlave        => mGpWriteSlave,
            mGpReadMaster        => mGpReadMaster,
            mGpReadSlave         => mGpReadSlave,
            sGpAxiClk(0)         => axiDmaClk,
            sGpAxiClk(1)         => axiDmaClk,
            sGpWriteSlave        => open,
            sGpWriteMaster       => (others=>AXI_WRITE_MASTER_INIT_C),
            sGpReadSlave         => open,
            sGpReadMaster        => (others=>AXI_READ_MASTER_INIT_C),
            acpAxiClk            => axiDmaClk,
            acpWriteSlave        => acpWriteSlave,
            acpWriteMaster       => acpWriteMaster,
            acpReadSlave         => acpReadSlave,
            acpReadMaster        => acpReadMaster,
            hpAxiClk(0)          => axiDmaClk,
            hpAxiClk(1)          => axiDmaClk,
            hpAxiClk(2)          => axiDmaClk,
            hpAxiClk(3)          => axiDmaClk,
            hpWriteSlave         => hpWriteSlave,
            hpWriteMaster        => hpWriteMaster,
            hpReadSlave          => hpReadSlave,
            hpReadMaster         => hpReadMaster,
            armEthTx             => armEthTx,
            armEthRx             => armEthRx
         );
   end generate;


   -- ACP connection MUX
   acpWriteMaster   <= bsiAcpWriteMaster when OLD_BSI_MODE_G = true  else dmaAcpWriteMaster;
   bsiAcpWriteSlave <= acpWriteSlave     when OLD_BSI_MODE_G = true  else AXI_WRITE_SLAVE_INIT_C;
   dmaAcpWriteSlave <= acpWriteSlave     when OLD_BSI_MODE_G = false else AXI_WRITE_SLAVE_INIT_C;

   assert OLD_BSI_MODE_G = false or RCE_DMA_MODE_G = RCE_DMA_AXIS_C 
      report "OLD_BSI_MODE_G must be false when using PPI DMA" severity failure;


   --------------------------------------------
   -- Clock Generation
   --------------------------------------------
   U_RceG3Clocks: entity work.RceG3Clocks
      generic map (
         TPD_G            => TPD_G,
         DMA_CLKDIV_EN_G  => DMA_CLKDIV_EN_G,
         DMA_CLKDIV_G     => DMA_CLKDIV_G
      ) port map (
         fclkClk3                 => fclkClk3,
         fclkClk2                 => fclkClk2,
         fclkClk1                 => fclkClk1,
         fclkClk0                 => fclkClk0,
         fclkRst3                 => fclkRst3,
         fclkRst2                 => fclkRst2,
         fclkRst1                 => fclkRst1,
         fclkRst0                 => fclkRst0,
         axiDmaClk                => axiDmaClk,
         axiDmaRst                => axiDmaRst,
         sysClk125                => isysClk125,
         sysClk125Rst             => isysClk125Rst,
         sysClk200                => isysClk200,
         sysClk200Rst             => isysClk200Rst
      );

   -- Output clocks
   sysClk125    <= isysClk125;
   sysClk125Rst <= isysClk125Rst;
   sysClk200    <= isysClk200;
   sysClk200Rst <= isysClk200Rst;
   axiClk       <= isysClk125;
   axiClkRst    <= isysClk125Rst;


   --------------------------------------------
   -- AXI Lite Bus
   --------------------------------------------
   U_RceG3AxiCntl: entity work.RceG3AxiCntl 
      generic map (
         TPD_G            => TPD_G,
         RCE_DMA_MODE_G   => RCE_DMA_MODE_G
      ) port map (
         mGpReadMaster        => mGpReadMaster,
         mGpReadSlave         => mGpReadSlave,
         mGpWriteMaster       => mGpWriteMaster,
         mGpWriteSlave        => mGpWriteSlave,
         axiDmaClk            => axiDmaClk,
         axiDmaRst            => axiDmaRst,
         icAxilReadMaster     => icAxilReadMaster,
         icAxilReadSlave      => icAxilReadSlave,
         icAxilWriteMaster    => icAxilWriteMaster,
         icAxilWriteSlave     => icAxilWriteSlave,
         dmaAxilReadMaster    => dmaAxilReadMaster,
         dmaAxilReadSlave     => dmaAxilReadSlave,
         dmaAxilWriteMaster   => dmaAxilWriteMaster,
         dmaAxilWriteSlave    => dmaAxilWriteSlave,
         axiClk               => isysClk125,
         axiClkRst            => isysClk125Rst,
         bsiAxilReadMaster    => bsiAxilReadMaster,
         bsiAxilReadSlave     => bsiAxilReadSlave,
         bsiAxilWriteMaster   => bsiAxilWriteMaster,
         bsiAxilWriteSlave    => bsiAxilWriteSlave,
         extAxilReadMaster    => extAxilReadMaster,
         extAxilReadSlave     => extAxilReadSlave,
         extAxilWriteMaster   => extAxilWriteMaster,
         extAxilWriteSlave    => extAxilWriteSlave,
         coreAxilReadMaster   => coreAxilReadMaster,
         coreAxilReadSlave    => coreAxilReadSlave,
         coreAxilWriteMaster  => coreAxilWriteMaster,
         coreAxilWriteSlave   => coreAxilWriteSlave,
         clkSelA              => clkSelA,
         clkSelB              => clkSelB,
         armEthMode           => armEthMode,
         eFuseValue           => eFuseValue,
         deviceDna            => deviceDna
      );


   --------------------------------------------
   -- BSI Controller
   --------------------------------------------
   U_RceG3Bsi : entity work.RceG3Bsi
      generic map (
         TPD_G => TPD_G
      ) port map (
         axiClk           => isysClk125,
         axiClkRst        => isysClk125Rst,
         axiDmaClk        => axiDmaClk,
         axiDmaRst        => axiDmaRst,
         axilReadMaster   => bsiAxilReadMaster,
         axilReadSlave    => bsiAxilReadSlave,
         axilWriteMaster  => bsiAxilWriteMaster,
         axilWriteSlave   => bsiAxilWriteSlave,
         acpWriteMaster   => bsiAcpWriteMaster,
         acpWriteSlave    => bsiAcpWriteSlave,
         bsiInterrupt     => bsiInterrupt,
         armEthMode       => armEthMode,
         eFuseValue       => eFuseValue,
         deviceDna        => deviceDna,
         i2cSda           => i2cSda,
         i2cScl           => i2cScl
      );


   --------------------------------------------
   -- DMA Controller
   --------------------------------------------
   U_RceG3Dma: entity work.RceG3Dma 
      generic map (
         TPD_G                 => TPD_G,
         RCE_DMA_MODE_G        => RCE_DMA_MODE_G
      ) port map (
         axiDmaClk            => axiDmaClk,
         axiDmaRst            => axiDmaRst,
         acpWriteSlave        => dmaAcpWriteSlave,
         acpWriteMaster       => dmaAcpWriteMaster,
         acpReadSlave         => acpReadSlave,
         acpReadMaster        => acpReadMaster,
         hpWriteSlave         => hpWriteSlave,
         hpWriteMaster        => hpWriteMaster,
         hpReadSlave          => hpReadSlave,
         hpReadMaster         => hpReadMaster,
         dmaAxilReadMaster    => dmaAxilReadMaster,
         dmaAxilReadSlave     => dmaAxilReadSlave,
         dmaAxilWriteMaster   => dmaAxilWriteMaster,
         dmaAxilWriteSlave    => dmaAxilWriteSlave,
         dmaInterrupt         => dmaInterrupt,
         dmaClk               => dmaClk,
         dmaClkRst            => dmaClkRst,
         dmaState             => dmaState,
         dmaObMaster          => dmaObMaster,
         dmaObSlave           => dmaObSlave,
         dmaIbMaster          => dmaIbMaster,
         dmaIbSlave           => dmaIbSlave
      );


   --------------------------------------------
   -- Interrupt Controller
   --------------------------------------------
   U_RceG3IntCntl: entity work.RceG3IntCntl 
      generic map (
         TPD_G                 => TPD_G,
         RCE_DMA_MODE_G        => RCE_DMA_MODE_G
      ) port map (
         axiDmaClk            => axiDmaClk,
         axiDmaRst            => axiDmaRst,
         icAxilReadMaster     => icAxilReadMaster,
         icAxilReadSlave      => icAxilReadSlave,
         icAxilWriteMaster    => icAxilWriteMaster,
         icAxilWriteSlave     => icAxilWriteSlave,
         dmaInterrupt         => dmaInterrupt,
         bsiInterrupt         => bsiInterrupt,
         userInterrupt        => userInterrupt,
         armInterrupt         => armInterrupt
      );

end architecture structure;

