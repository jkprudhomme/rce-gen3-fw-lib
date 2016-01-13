-------------------------------------------------------------------------------
-- Title         : Zynq 10 Gige Ethernet Core
-- File          : ZynqEthernet10G.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 09/03/2013
-------------------------------------------------------------------------------
-- Description:
-- Wrapper file for Zynq ethernet 10G core.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE 10G Ethernet Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE 10G Ethernet Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 09/03/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.PpiPkg.all;
use work.RceG3Pkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.StdRtlPkg.all;
use work.EthMacPkg.all;

entity ZynqEthernet10G is
   generic (
      TPD_G           : time             := 1 ns;
      RCE_DMA_MODE_G  : RceDmaModeType   := RCE_DMA_PPI_C;
      USER_ETH_EN_G   : boolean          := false;
      USER_ETH_TYPE_G : slv(15 downto 0) := x"0000"
   );
   port (

      -- Clocks
      sysClk200               : in  sl;
      sysClk200Rst            : in  sl;

      -- PPI Interface
      dmaClk                  : out sl;
      dmaClkRst               : out sl;
      dmaState                : in  RceDmaStateType;
      dmaIbMaster             : out AxiStreamMasterType;
      dmaIbSlave              : in  AxiStreamSlaveType;
      dmaObMaster             : in  AxiStreamMasterType;
      dmaObSlave              : out AxiStreamSlaveType;

      -- User interface
      userEthClk              : out sl;
      userEthClkRst           : out sl;
      userEthObMaster         : in  AxiStreamMasterType;
      userEthObSlave          : out AxiStreamSlaveType;
      userEthIbMaster         : out AxiStreamMasterType;
      userEthIbCtrl           : in  AxiStreamCtrlType;

      -- AXI Lite Busses
      axilClk                 : in  sl;
      axilClkRst              : in  sl;
      axilWriteMaster         : in  AxiLiteWriteMasterType;
      axilWriteSlave          : out AxiLiteWriteSlaveType;
      axilReadMaster          : in  AxiLiteReadMasterType;
      axilReadSlave           : out AxiLiteReadSlaveType;

      -- Ref Clock
      ethRefClkP              : in  sl;
      ethRefClkM              : in  sl;

      -- Ethernet Lines
      ethRxP                  : in  slv(3 downto 0);
      ethRxM                  : in  slv(3 downto 0);
      ethTxP                  : out slv(3 downto 0);
      ethTxM                  : out slv(3 downto 0)
   );
end ZynqEthernet10G;

architecture structure of ZynqEthernet10G is

   constant HEADER_SIZE_C : integer := 16;
   constant AXIS_CONFIG_C : AxiStreamConfigType := ite(RCE_DMA_MODE_G = RCE_DMA_PPI_C, 
                                                       PPI_AXIS_CONFIG_INIT_C,
                                                       RCEG3_AXIS_DMA_CONFIG_C);

   COMPONENT zynq_10g_xaui
      PORT (
         dclk                 : in sl;
         reset                : in sl;
         clk156_out           : out sl;
         refclk_p             : in sl;
         refclk_n             : in sl;
         clk156_lock          : out sl;
         xgmii_txd            : in slv(63 downto 0);
         xgmii_txc            : in slv(7 downto 0);
         xgmii_rxd            : out slv(63 downto 0);
         xgmii_rxc            : out slv(7 downto 0);
         xaui_tx_l0_p         : out sl;
         xaui_tx_l0_n         : out sl;
         xaui_tx_l1_p         : out sl;
         xaui_tx_l1_n         : out sl;
         xaui_tx_l2_p         : out sl;
         xaui_tx_l2_n         : out sl;
         xaui_tx_l3_p         : out sl;
         xaui_tx_l3_n         : out sl;
         xaui_rx_l0_p         : in sl;
         xaui_rx_l0_n         : in sl;
         xaui_rx_l1_p         : in sl;
         xaui_rx_l1_n         : in sl;
         xaui_rx_l2_p         : in sl;
         xaui_rx_l2_n         : in sl;
         xaui_rx_l3_p         : in sl;
         xaui_rx_l3_n         : in sl;
         signal_detect        : in slv(3 downto 0);
         debug                : out slv(5 downto 0);
         configuration_vector : in slv(6 downto 0);
         status_vector        : out slv(7 downto 0)
      );
   END COMPONENT;

   signal xauiRxd           : slv(63 downto 0);
   signal xauiRxc           : slv(7  downto 0);
   signal xauiTxd           : slv(63 downto 0);
   signal xauiTxc           : slv(7  downto 0);
   signal phyStatus         : slv(7  downto 0);
   signal phyDebug          : slv(5  downto 0);
   signal phyConfig         : slv(6  downto 0);
   signal ethClk            : sl;
   signal ethClkRst         : sl;
   signal ethClkLock        : sl;
   signal phyReset          : sl;
   signal macConfig         : EthMacConfigType;
   signal macStatus         : EthMacStatusType;
   signal macIbMaster       : AxiStreamMasterType;
   signal macIbCtrl         : AxiStreamCtrlType;
   signal macObMaster       : AxiStreamMasterType;
   signal macObSlave        : AxiStreamSlaveType;
   signal ppiIbMaster       : AxiStreamMasterType;
   signal writeCount        : slv(15 downto 0);
   signal cfgPhyReset       : sl;
   signal onlineSync        : sl;

begin

   -- Select DMA clock
   dmaClk    <= sysClk200;
   dmaClkRst <= sysClk200Rst;

   -------------------------------------------
   -- Register Space
   -------------------------------------------
   U_Reg: entity work.ZynqEthernet10GReg 
      generic map (
         TPD_G => TPD_G
      ) port map (
         axilClk         => axilClk,
         axilClkRst      => axilClkRst,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         ethClk          => ethClk,
         ethClkRst       => ethClkRst,
         phyStatus       => phyStatus,
         phyDebug        => phyDebug,
         phyReset        => cfgPhyReset,
         phyConfig       => phyConfig,
         macConfig       => macConfig,
         macStatus       => macStatus
      );


   -------------------------------------------
   -- XAUI
   -------------------------------------------
   --U_OnlineSync: entity work.Synchronizer 
   --   generic map (
   --      TPD_G  => TPD_G
   --   ) port map (
   --      clk     => ethClk,
   --      rst     => ethClkRst,
   --      dataIn  => dmaState.online,
   --      dataOut => onlineSync
   --   );
   onlineSync <= dmaState.online;

   phyReset <= cfgPhyReset or not onlineSync;

   U_ZynqXaui: zynq_10g_xaui
      PORT map (
         dclk                  => axilClk,
         reset                 => phyReset,
         clk156_out            => ethClk,
         refclk_p              => ethRefClkP,
         refclk_n              => ethRefClkM,
         clk156_lock           => ethClkLock,
         xgmii_txd             => xauiTxd,
         xgmii_txc             => xauiTxc,
         xgmii_rxd             => xauiRxd,
         xgmii_rxc             => xauiRxc,
         xaui_tx_l0_p          => ethTxP(0), 
         xaui_tx_l0_n          => ethTxM(0), 
         xaui_tx_l1_p          => ethTxP(1), 
         xaui_tx_l1_n          => ethTxM(1), 
         xaui_tx_l2_p          => ethTxP(2), 
         xaui_tx_l2_n          => ethTxM(2), 
         xaui_tx_l3_p          => ethTxP(3), 
         xaui_tx_l3_n          => ethTxM(3), 
         xaui_rx_l0_p          => ethRxP(0), 
         xaui_rx_l0_n          => ethRxM(0), 
         xaui_rx_l1_p          => ethRxP(1), 
         xaui_rx_l1_n          => ethRxM(1), 
         xaui_rx_l2_p          => ethRxP(2), 
         xaui_rx_l2_n          => ethRxM(2), 
         xaui_rx_l3_p          => ethRxP(3), 
         xaui_rx_l3_n          => ethRxM(3), 
         signal_detect         => (others=>'1'),
         debug                 => phyDebug,
         configuration_vector  => phyConfig,
         status_vector         => phyStatus
      );

   -- Status Vector 0x20
   -- 0   = Tx Local Fault
   -- 1   = Rx Local Fault
   -- 5:2 = Sync Status
   -- 6   = Alignment
   -- 7   = Rx Link Status

   -- Config Vector 0x8
   -- 0   = Loopback
   -- 1   = Power Down
   -- 2   = Reset Local Fault
   -- 3   = Reset Rx Link Status
   -- 4   = Test Enable
   -- 6:5 = Test Pattern

   -- Debug  Vector 0x24
   -- 5   = Align Status
   -- 4:1 = Sync Status
   -- 0   = TX Phase Complete

   -- Generate reset for eth clock
   U_EthClkRst : entity work.RstSync
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '0',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 3
      ) port map (
         clk      => ethClk,
         asyncRst => ethClkLock,
         syncRst  => ethClkRst
      );


   -------------------------------------------
   -- Eth MAC
   -------------------------------------------
   U_EthMacTop: entity work.EthMacTop
      generic map (
         TPD_G           => TPD_G,
         PAUSE_512BITS_G => 8,
         VLAN_CNT_G      => 1,
         VLAN_EN_G       => false,
         BYP_EN_G        => USER_ETH_EN_G,
         BYP_ETH_TYPE_G  => USER_ETH_TYPE_G,
         SHIFT_EN_G      => true,
         FILT_EN_G       => true,
         CSUM_EN_G       => true
      ) port map ( 
         ethClk         => ethClk,
         ethClkRst      => ethClkRst,
         sPrimMaster    => macObMaster,
         sPrimSlave     => macObSlave,
         mPrimMaster    => macIbMaster,
         mPrimCtrl      => macIbCtrl,
         sBypMaster     => userEthObMaster,
         sBypSlave      => userEthObSlave,
         mBypMaster     => userEthIbMaster,
         mBypCtrl       => userEthIbCtrl,
         phyTxd         => xauiTxd,
         phyTxc         => xauiTxc,
         phyRxd         => xauiRxd,
         phyRxc         => xauiRxc,
         phyReady       => phyStatus(7),
         ethConfig      => macConfig,
         ethStatus      => macStatus
      );

   userEthClk    <= ethClk;
   userEthClkRst <= ethClkRst;

   -------------------------------------------
   -- TX FIFO
   -------------------------------------------

   U_MacTxFifo : entity work.AxiStreamFifo
      generic map (
         TPD_G               => TPD_G,
         FIFO_ADDR_WIDTH_G   => 9,
         VALID_THOLD_G       => 255,
         SLAVE_AXI_CONFIG_G  => AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => EMAC_AXIS_CONFIG_C
      ) port map (
         sAxisClk    => sysClk200,
         sAxisRst    => sysClk200Rst,
         sAxisMaster => dmaObMaster,
         sAxisSlave  => dmaObSlave,
         mAxisClk    => ethClk,
         mAxisRst    => ethClkRst,
         mAxisMaster => macObMaster,
         mAxisSlave  => macObSlave
      );

   -------------------------------------------
   -- PPI support
   -------------------------------------------
   process ( ethClk, macIbMaster ) is
      variable varMaster : AxiStreamMasterType;
      variable eofe      : sl;
   begin

      -- Word counter
      if rising_edge(ethClk) then
         if ethClkRst = '1' or (macIbMaster.tValid = '1' and macIbMaster.tLast = '1') then
            writeCount <= (others=>'0') after TPD_G;
         elsif macIbMaster.tValid = '1' then
            writeCount <= writeCount + 1 after TPD_G;
         end if;
      end if;

      varMaster := macIbMaster;
      eofe      := axiStreamGetUserBit(EMAC_AXIS_CONFIG_C, macIbMaster, EMAC_EOFE_BIT_C);

      -- PPI Override
      if RCE_DMA_MODE_G = RCE_DMA_PPI_C then

         -- Clear user field
         varMaster.tUser := (others=>'0');

         -- Set EOH if neccessary
         if writeCount = (HEADER_SIZE_C-1) then
            axiStreamSetUserBit(EMAC_AXIS_CONFIG_C, varMaster, PPI_EOH_C, '1');
         end if;

         -- Update ERR bit with EOFE
         if macIbMaster.tLast = '1' then
            axiStreamSetUserBit(EMAC_AXIS_CONFIG_C, varMaster, PPI_ERR_C, eofe);
         end if;
      end if;

      ppiIbMaster <= varMaster;

   end process;

   -------------------------------------------
   -- RX FIFO
   -------------------------------------------
   U_MacRxFifo : entity work.AxiStreamFifo
      generic map (
         TPD_G               => TPD_G,
         FIFO_ADDR_WIDTH_G   => 11,
         SLAVE_READY_EN_G    => false,
         FIFO_PAUSE_THRESH_G => 512,
         SLAVE_AXI_CONFIG_G  => EMAC_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => AXIS_CONFIG_C
      ) port map (
         sAxisClk    => ethClk,
         sAxisRst    => ethClkRst,
         sAxisMaster => ppiIbMaster,
         sAxisCtrl   => macIbCtrl,
         mAxisClk    => sysClk200,
         mAxisRst    => sysClk200Rst,
         mAxisMaster => dmaIbMaster,
         mAxisSlave  => dmaIbSlave
      );

end architecture structure;

