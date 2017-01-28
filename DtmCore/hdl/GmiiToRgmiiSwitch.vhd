-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : GmiiToRgmiiSwitch.vhd
-- Author     : Larry Ruckman  <ruckman@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2014-01-17
-- Last update: 2014-01-17
-- Platform   : Vivado2013.3
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This is a GigE to RGMII switch
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE DTM Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE DTM Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;

library unisim;
use unisim.vcomponents.all;

entity GmiiToRgmiiSwitch is
   generic (
      SELECT_CH1_G : boolean := false);
   port (
      -- Clocks
      sysClk200    : in    sl;
      sysClk200Rst : in    sl;
      -- ARM Interface
      armEthTx     : in    ArmEthTxType;
      armEthRx     : out   ArmEthRxType;
      -- Base Ethernet
      ethRxCtrl    : in    slv(1 downto 0);
      ethRxClk     : in    slv(1 downto 0);
      ethRxDataA   : in    Slv(1 downto 0);
      ethRxDataB   : in    Slv(1 downto 0);
      ethRxDataC   : in    Slv(1 downto 0);
      ethRxDataD   : in    Slv(1 downto 0);
      ethTxCtrl    : out   slv(1 downto 0);
      ethTxClk     : out   slv(1 downto 0);
      ethTxDataA   : out   Slv(1 downto 0);
      ethTxDataB   : out   Slv(1 downto 0);
      ethTxDataC   : out   Slv(1 downto 0);
      ethTxDataD   : out   Slv(1 downto 0);
      ethMdc       : out   Slv(1 downto 0);
      ethMio       : inout Slv(1 downto 0);
      ethResetL    : out   Slv(1 downto 0));
end GmiiToRgmiiSwitch;

architecture mapping of GmiiToRgmiiSwitch is
   constant EN_CH_C  : integer := ite(SELECT_CH1_G, 1, 0);
   constant DIS_CH_C : integer := ite(SELECT_CH1_G, 0, 1);

   component GmiiToRgmiiCore
      port (
         tx_reset          : in  sl;
         rx_reset          : in  sl;
         clkin             : in  sl;
         ref_clk_out       : out sl;
         gmii_clk_125m_out : out sl;
         gmii_clk_25m_out  : out sl;
         gmii_clk_2_5m_out : out sl;
         rgmii_txd         : out slv(3 downto 0);
         rgmii_tx_ctl      : out sl;
         rgmii_txc         : out sl;
         rgmii_rxd         : in  slv(3 downto 0);
         rgmii_rx_ctl      : in  sl;
         rgmii_rxc         : in  sl;
         link_status       : out sl;
         clock_speed       : out slv(1 downto 0);
         duplex_status     : out sl;
         mdio_gem_mdc      : in  sl;
         mdio_gem_i        : out sl;
         mdio_gem_o        : in  sl;
         mdio_gem_t        : in  sl;
         mdio_phy_mdc      : out sl;
         mdio_phy_i        : in  sl;
         mdio_phy_o        : out sl;
         mdio_phy_t        : out sl;
         gmii_txd          : in  slv(7 downto 0);
         gmii_tx_en        : in  sl;
         gmii_tx_er        : in  sl;
         gmii_tx_clk       : out sl;
         gmii_crs          : out sl;
         gmii_col          : out sl;
         gmii_rxd          : out slv(7 downto 0);
         gmii_rx_dv        : out sl;
         gmii_rx_er        : out sl;
         gmii_rx_clk       : out sl;
         speed_mode        : out slv(1 downto 0));
   end component;

   --attribute SYN_BLACK_BOX                    : boolean;
   --attribute SYN_BLACK_BOX of GmiiToRgmiiCore : component is true;

   --attribute BLACK_BOX_PAD_PIN                    : string;
   --attribute BLACK_BOX_PAD_PIN of GmiiToRgmiiCore : component is "tx_reset,rx_reset,clkin,ref_clk_out,gmii_clk_125m_out,gmii_clk_25m_out,gmii_clk_2_5m_out,rgmii_txd[3:0],rgmii_tx_ctl,rgmii_txc,rgmii_rxd[3:0],rgmii_rx_ctl,rgmii_rxc,link_status,clock_speed[1:0],duplex_status,mdio_gem_mdc,mdio_gem_i,mdio_gem_o,mdio_gem_t,mdio_phy_mdc,mdio_phy_i,mdio_phy_o,mdio_phy_t,gmii_txd[7:0],gmii_tx_en,gmii_tx_er,gmii_tx_clk,gmii_crs,gmii_col,gmii_rxd[7:0],gmii_rx_dv,gmii_rx_er,gmii_rx_clk,speed_mode[1:0]";

   signal ethMioI,
      ethMioO,
      ethMioT,
      linkStatus,
      duplexStatus : sl;
   signal speedMode,
      clockSpeed : slv(1 downto 0);
      
   attribute KEEP_HIERARCHY : string;
   attribute KEEP_HIERARCHY of
      GmiiToRgmiiCore_Inst : label is "TRUE";        
   
begin

   GmiiToRgmiiCore_Inst : GmiiToRgmiiCore
      port map(
         --Clocks and Resets
         clkin             => sysClk200,
         ref_clk_out       => open,
         gmii_clk_125m_out => open,
         gmii_clk_25m_out  => open,
         gmii_clk_2_5m_out => open,
         tx_reset          => sysClk200Rst,
         rx_reset          => sysClk200Rst,
         -- RGMII_TX Signals
         rgmii_txc         => ethTxClk(EN_CH_C),
         rgmii_tx_ctl      => ethTxCtrl(EN_CH_C),
         rgmii_txd(0)      => ethTxDataA(EN_CH_C),
         rgmii_txd(1)      => ethTxDataB(EN_CH_C),
         rgmii_txd(2)      => ethTxDataC(EN_CH_C),
         rgmii_txd(3)      => ethTxDataD(EN_CH_C),
         -- RGMII_TX Signals
         rgmii_rxc         => ethRxClk(EN_CH_C),
         rgmii_rx_ctl      => ethRxCtrl(EN_CH_C),
         rgmii_rxd(0)      => ethRxDataA(EN_CH_C),
         rgmii_rxd(1)      => ethRxDataB(EN_CH_C),
         rgmii_rxd(2)      => ethRxDataC(EN_CH_C),
         rgmii_rxd(3)      => ethRxDataD(EN_CH_C),
         -- RGMII_MIO Signals
         mdio_phy_mdc      => ethMdc(EN_CH_C),
         mdio_phy_i        => ethMioI,
         mdio_phy_o        => ethMioO,
         mdio_phy_t        => ethMioT,
         -- GMII_TX Signals
         gmii_tx_clk       => armEthRx.enetGmiiTxClk,
         gmii_tx_en        => armEthTx.enetGmiiTxEn,
         gmii_tx_er        => armEthTx.enetGmiiTxEr,
         gmii_txd          => armEthTx.enetGmiiTxD,
         -- GMII_RX Signals
         gmii_rx_clk       => armEthRx.enetGmiiRxClk,
         gmii_rx_dv        => armEthRx.enetGmiiRxDv,
         gmii_rx_er        => armEthRx.enetGmiiRxEr,
         gmii_rxd          => armEthRx.enetGmiiRxd,
         -- GMII_MIO Signals
         mdio_gem_mdc      => armEthTx.enetMdioMdc,
         mdio_gem_i        => armEthRx.enetMdioI,
         mdio_gem_o        => armEthTx.enetMdioO,
         mdio_gem_t        => armEthTx.enetMdioT,
         -- GMII_MISC Signals
         gmii_crs          => armEthRx.enetGmiiCrs,
         gmii_col          => armEthRx.enetGmiiCol,
         -- Status Signals         
         link_status       => linkStatus,
         clock_speed       => clockSpeed,
         duplex_status     => duplexStatus,
         speed_mode        => speedMode);

   IOBUF_inst : IOBUF
      port map (
         O  => ethMioI,        -- Buffer output
         IO => ethMio(EN_CH_C),-- Buffer inout port (connect directly to top-level port)
         I  => ethMioO,        -- Buffer input
         T  => ethMioT);       -- 3-state enable input, high=input, low=output 

   -- Unused Interrupt Signal
   armEthRx.enetExtInitN <= '0';

   -- Unused RGMII Ports       
   ethTxCtrl(DIS_CH_C)  <= 'Z';
   ethTxClk(DIS_CH_C)   <= 'Z';
   ethTxDataA(DIS_CH_C) <= 'Z';
   ethTxDataB(DIS_CH_C) <= 'Z';
   ethTxDataC(DIS_CH_C) <= 'Z';
   ethTxDataD(DIS_CH_C) <= 'Z';
   ethMdc(DIS_CH_C)     <= 'Z';
   ethMio(DIS_CH_C)     <= 'Z';
   ethResetL(DIS_CH_C)  <= 'Z';

   ethResetL(EN_CH_C)  <= not sysClk200Rst;
   
end mapping;
