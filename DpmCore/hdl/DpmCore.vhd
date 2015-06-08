-------------------------------------------------------------------------------
-- Title         : Common DPM Core Module
-- File          : DpmCore.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 11/14/2013
-------------------------------------------------------------------------------
-- Description:
-- Common top level module for DPM
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 11/14/2013: created.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity DpmCore is
   generic (
      TPD_G          : time                  := 1 ns;
      ETH_10G_EN_G   : boolean               := false;
      RCE_DMA_MODE_G : RceDmaModeType        := RCE_DMA_PPI_C;
      OLD_BSI_MODE_G : boolean               := false;
      AXI_ST_COUNT_G : natural range 3 to 4  := 3
   );
   port (

      -- I2C
      i2cSda                  : inout sl;
      i2cScl                  : inout sl;

      -- Ethernet
      ethRxP                  : in    slv(3 downto 0);
      ethRxM                  : in    slv(3 downto 0);
      ethTxP                  : out   slv(3 downto 0);
      ethTxM                  : out   slv(3 downto 0);
      ethRefClkP              : in    sl;
      ethRefClkM              : in    sl;

      -- Clock Select
      clkSelA                 : out   slv(1 downto 0);
      clkSelB                 : out   slv(1 downto 0);

      -- Clocks
      sysClk125               : out   sl;
      sysClk125Rst            : out   sl;
      sysClk200               : out   sl;
      sysClk200Rst            : out   sl;

      -- External Axi Bus, 0xA0000000 - 0xAFFFFFFF
      axiClk                  : out   sl;
      axiClkRst               : out   sl;
      extAxilReadMaster       : out   AxiLiteReadMasterType;
      extAxilReadSlave        : in    AxiLiteReadSlaveType;
      extAxilWriteMaster      : out   AxiLiteWriteMasterType;
      extAxilWriteSlave       : in    AxiLiteWriteSlaveType;

      -- DMA Interfaces
      dmaClk                  : in    slv(AXI_ST_COUNT_G-1 downto 0);
      dmaClkRst               : in    slv(AXI_ST_COUNT_G-1 downto 0);
      dmaState                : out   RceDmaStateArray(AXI_ST_COUNT_G-1 downto 0);
      dmaObMaster             : out   AxiStreamMasterArray(AXI_ST_COUNT_G-1 downto 0);
      dmaObSlave              : in    AxiStreamSlaveArray(AXI_ST_COUNT_G-1 downto 0);
      dmaIbMaster             : in    AxiStreamMasterArray(AXI_ST_COUNT_G-1 downto 0);
      dmaIbSlave              : out   AxiStreamSlaveArray(AXI_ST_COUNT_G-1 downto 0);

      -- User Interrupts
      userInterrupt            : in    slv(USER_INT_COUNT_C-1 downto 0)

   );
end DpmCore;

architecture STRUCTURE of DpmCore is

   signal iaxiClk             : sl;
   signal iaxiClkRst          : sl;
   signal isysClk125          : sl;
   signal isysClk125Rst       : sl;
   signal isysClk200          : sl;
   signal isysClk200Rst       : sl;
   signal idmaClk             : slv(3 downto 0);
   signal idmaClkRst          : slv(3 downto 0);
   signal idmaState           : RceDmaStateArray(3 downto 0);
   signal idmaObMaster        : AxiStreamMasterArray(3 downto 0);
   signal idmaObSlave         : AxiStreamSlaveArray(3 downto 0);
   signal idmaIbMaster        : AxiStreamMasterArray(3 downto 0);
   signal idmaIbSlave         : AxiStreamSlaveArray(3 downto 0);
   signal coreAxilReadMaster  : AxiLiteReadMasterType;
   signal coreAxilReadSlave   : AxiLiteReadSlaveType;
   signal coreAxilWriteMaster : AxiLiteWriteMasterType;
   signal coreAxilWriteSlave  : AxiLiteWriteSlaveType;
   signal armEthTx            : ArmEthTxArray(1 downto 0);
   signal armEthRx            : ArmEthRxArray(1 downto 0);
   signal armEthMode          : slv(31 downto 0);

begin
   
   --------------------------------------------------
   -- Assertions to validate the configuration
   --------------------------------------------------
   
   assert (RCE_DMA_MODE_G = RCE_DMA_CUSTOM_C and AXI_ST_COUNT_G = 4) or RCE_DMA_MODE_G /= RCE_DMA_CUSTOM_C
      report "Only AXI_ST_COUNT_G = 4 is supported when RCE_DMA_MODE_G = RCE_DMA_CUSTOM_C" 
      severity failure;
   assert (RCE_DMA_MODE_G = RCE_DMA_CUSTOM_C and ETH_10G_EN_G = false) or RCE_DMA_MODE_G /= RCE_DMA_CUSTOM_C
      report "RCE_DMA_MODE_G = RCE_DMA_CUSTOM_C is not supported when ETH_10G_EN_G = true"
      severity failure;
      
   -- more assertion checks should be added e.g. ETH_10G_EN_G = true only with RCE_DMA_MODE_G = RCE_DMA_PPI_C ???
   -- my 3rd assertion can be removed when the above check is added
   
   --------------------------------------------------
   -- Inputs/Outputs
   --------------------------------------------------
   axiClk          <= iaxiClk;
   axiClkRst       <= iaxiClkRst;
   sysClk125       <= isysClk125;
   sysClk125Rst    <= isysClk125Rst;
   sysClk200       <= isysClk200;
   sysClk200Rst    <= isysClk200Rst;

   -- DMA Interfaces
   idmaClk(2 downto 0)      <= dmaClk(2 downto 0);
   idmaClkRst(2 downto 0)   <= dmaClkRst(2 downto 0);
   dmaState(2 downto 0)     <= idmaState(2 downto 0);
   dmaObMaster(2 downto 0)  <= idmaObMaster(2 downto 0);
   idmaObSlave(2 downto 0)  <= dmaObSlave(2 downto 0);
   idmaIbMaster(2 downto 0) <= dmaIbMaster(2 downto 0);
   dmaIbSlave(2 downto 0)   <= idmaIbSlave(2 downto 0);


   --------------------------------------------------
   -- RCE Core
   --------------------------------------------------
   U_RceG3Top: entity work.RceG3Top
      generic map (
         TPD_G          => TPD_G,
         RCE_DMA_MODE_G => RCE_DMA_MODE_G,
         OLD_BSI_MODE_G => OLD_BSI_MODE_G
      ) port map (
         i2cSda              => i2cSda,
         i2cScl              => i2cScl,
         sysClk125           => isysClk125,
         sysClk125Rst        => isysClk125Rst,
         sysClk200           => isysClk200,
         sysClk200Rst        => isysClk200Rst,
         axiClk              => iaxiClk,
         axiClkRst           => iaxiClkRst,
         extAxilReadMaster   => extAxilReadMaster,
         extAxilReadSlave    => extAxilReadSlave ,
         extAxilWriteMaster  => extAxilWriteMaster,
         extAxilWriteSlave   => extAxilWriteSlave ,
         coreAxilReadMaster  => coreAxilReadMaster,
         coreAxilReadSlave   => coreAxilReadSlave,
         coreAxilWriteMaster => coreAxilWriteMaster,
         coreAxilWriteSlave  => coreAxilWriteSlave,
         dmaClk              => idmaClk,
         dmaClkRst           => idmaClkRst,
         dmaState            => idmaState,
         dmaObMaster         => idmaObMaster,
         dmaObSlave          => idmaObSlave,
         dmaIbMaster         => idmaIbMaster,
         dmaIbSlave          => idmaIbSlave,
         userInterrupt       => userInterrupt,
         armEthTx            => armEthTx,
         armEthRx            => armEthRx,
         armEthMode          => armEthMode,
         clkSelA             => open,
         clkSelB             => open
      );


   -- Osc 0 = 156.25
   clkSelA(0) <= '0';
   clkSelB(0) <= '0';

   -- Osc 1 = 250
   clkSelA(1) <= '1';
   clkSelB(1) <= '1';

   --------------------------------------------------
   -- Ethernet
   --------------------------------------------------
   U_Eth1gGen: if ETH_10G_EN_G = false generate 
      U_ZynqEthernet : entity work.ZynqEthernet 
         port map (
            sysClk125          => isysClk125,
            sysClk200          => isysClk200,
            sysClk200Rst       => isysClk200Rst,
            armEthTx           => armEthTx(0),
            armEthRx           => armEthRx(0),
            ethRxP             => ethRxP(0),
            ethRxM             => ethRxM(0),
            ethTxP             => ethTxP(0),
            ethTxM             => ethTxM(0)
         );
      
      U_CustomDmaGen : if RCE_DMA_MODE_G = RCE_DMA_CUSTOM_C generate
         idmaClk(3)         <= dmaClk(AXI_ST_COUNT_G-1);
         idmaClkRst(3)      <= dmaClkRst(AXI_ST_COUNT_G-1);
         idmaObSlave(3)     <= dmaObSlave(AXI_ST_COUNT_G-1);
         idmaIbMaster(3)    <= dmaIbMaster(AXI_ST_COUNT_G-1);
         dmaState(AXI_ST_COUNT_G-1)    <= idmaState(3);
         dmaObMaster(AXI_ST_COUNT_G-1) <= idmaObMaster(3);
         dmaIbSlave(AXI_ST_COUNT_G-1)  <= idmaIbSlave(3);
      end generate;
      U_NoCustomDmaGen : if RCE_DMA_MODE_G /= RCE_DMA_CUSTOM_C generate
         idmaClk(3)         <= isysClk125;
         idmaClkRst(3)      <= isysClk125Rst;
         idmaObSlave(3)     <= AXI_STREAM_SLAVE_INIT_C;
         idmaIbMaster(3)    <= AXI_STREAM_MASTER_INIT_C;
      end generate;
      
      ethTxP(3 downto 1) <= (others=>'0');
      ethTxM(3 downto 1) <= (others=>'0');
      armEthRx(1)        <= ARM_ETH_RX_INIT_C;
      armEthMode         <= x"00000001"; -- 1 Gig on lane 0

      U_AxiLiteEmpty : entity work.AxiLiteEmpty
         generic map (
            TPD_G  => TPD_G
         ) port map (
            axiClk          => iaxiClk,
            axiClkRst       => iaxiClkRst,
            axiReadMaster   => coreAxilReadMaster,
            axiReadSlave    => coreAxilReadSlave,
            axiWriteMaster  => coreAxilWriteMaster,
            axiWriteSlave   => coreAxilWriteSlave
         );
   end generate;

   U_Eth10gGen: if ETH_10G_EN_G = true generate 
      U_ZynqEthernet10G : entity work.ZynqEthernet10G 
         generic map (
            TPD_G  => TPD_G
         ) port map (
            sysClk200          => isysClk200,
            sysClk200Rst       => isysClk200Rst,
            ppiClk             => idmaClk(3),
            ppiClkRst          => idmaClkRst(3),
            ppiState           => idmaState(3),
            ppiIbMaster        => idmaIbMaster(3),
            ppiIbSlave         => idmaIbSlave(3),
            ppiObMaster        => idmaObMaster(3),
            ppiObSlave         => idmaObSlave(3),
            axilClk            => iaxiClk,
            axilClkRst         => iaxiClkRst,
            axilWriteMaster    => coreAxilWriteMaster,
            axilWriteSlave     => coreAxilWriteSlave,
            axilReadMaster     => coreAxilReadMaster,
            axilReadSlave      => coreAxilReadSlave,
            ethRefClkP         => ethRefClkP,
            ethRefClkM         => ethRefClkM,
            ethRxP             => ethRxP,
            ethRxM             => ethRxM,
            ethTxP             => ethTxP,
            ethTxM             => ethTxM
         );

      armEthRx   <= (others=>ARM_ETH_RX_INIT_C);
      armEthMode <= x"03030303"; -- XAUI on lanes 3:0

   end generate;

end architecture STRUCTURE;

