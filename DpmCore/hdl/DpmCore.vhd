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
      TPD_G        : time             := 1 ns;
      ETH_10G_EN_G : boolean          := false;
      RCE_DMA_MODE_G : RceDmaModeType := RCE_DMA_PPI_C
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
      dmaClk                  : in    slv(2 downto 0);
      dmaClkRst               : in    slv(2 downto 0);
      dmaState                : out   RceDmaStateArray(2 downto 0);
      dmaObMaster             : out   AxiStreamMasterArray(2 downto 0);
      dmaObSlave              : in    AxiStreamSlaveArray(2 downto 0);
      dmaIbMaster             : in    AxiStreamMasterArray(2 downto 0);
      dmaIbSlave              : out   AxiStreamSlaveArray(2 downto 0)
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

begin

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
   idmaClk(2 downto 0)      <= dmaClk;
   idmaClkRst(2 downto 0)   <= dmaClkRst;
   dmaState                 <= idmaState(2 downto 0);
   dmaObMaster              <= idmaObMaster(2 downto 0);
   idmaObSlave(2 downto 0)  <= dmaObSlave;
   idmaIbMaster(2 downto 0) <= dmaIbMaster;
   dmaIbSlave               <= idmaIbSlave(2 downto 0);


   --------------------------------------------------
   -- RCE Core
   --------------------------------------------------
   U_RceG3Top: entity work.RceG3Top
      generic map (
         TPD_G          => TPD_G,
         RCE_DMA_MODE_G => RCE_DMA_MODE_G,
         DMA_CLKDIV_G   => 5.0
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
         armEthTx            => armEthTx,
         armEthRx            => armEthRx,
         clkSelA             => open,
         clkSelB             => open
      );


   -- Osc 0 = 156.25
   clkSelA(0) <= '0';
   clkSelB(0) <= '0';

   -- Osc 1 = 250
   clkSelA(1) <= '1';
   clkSelB(1) <= '1';

   -------------------------------------
   -- AXI Lite Terminator
   -------------------------------------
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

      idmaClk(3)         <= isysClk125;
      idmaClkRst(3)      <= isysClk125Rst;
      idmaObSlave(3)     <= AXI_STREAM_SLAVE_INIT_C;
      idmaIbMaster(3)    <= AXI_STREAM_MASTER_INIT_C;
      ethTxP(3 downto 1) <= (others=>'0');
      ethTxM(3 downto 1) <= (others=>'0');
      armEthRx(1)        <= ARM_ETH_RX_INIT_C;
   end generate;

end architecture STRUCTURE;

