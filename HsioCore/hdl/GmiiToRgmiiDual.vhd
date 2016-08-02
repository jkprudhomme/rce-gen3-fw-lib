-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : GmiiToRgmiiDual.vhd
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

entity GmiiToRgmiiDual is
   port (
      -- Clocks
      sysClk200    : in    sl;
      sysClk200Rst : in    sl;
      -- ARM Interface
      armEthTx     : in    ArmEthTxArray(1 downto 0);
      armEthRx     : out   ArmEthRxArray(1 downto 0);
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
end GmiiToRgmiiDual;

architecture mapping of GmiiToRgmiiDual is
   component GmiiToRgmiiCore
      port (
         tx_reset          : in  sl;
         rx_reset          : in  sl;
         clkin             : in  sl;
         ref_clk_out       : out sl;
         mmcm_locked_out : out sl;
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

    signal mmcm_locked : sl;

   signal ethMioI,
      ethMioO,
      ethMioT,
      linkStatus,
      duplexStatus : slv(1 downto 0);
   signal speedMode,
      clockSpeed : Slv2Array(1 downto 0);
   signal ref_clk, gmii_clk_125m, gmii_clk_25m, gmii_clk_2_5m: sl;   
   attribute mark_debug : string;
   attribute mark_debug of ethMioI,
      ethMioO,
      ethMioT,
      linkStatus,
      duplexStatus,
      speedMode,
      clockSpeed : signal is "TRUE";
      
begin


      GmiiToRgmiiCore_Inst : GmiiToRgmiiCore
         port map(
            --Clocks and Resets
            clkin             => sysClk200,
            ref_clk_out       => ref_clk,
            mmcm_locked_out => mmcm_locked,
            gmii_clk_125m_out => gmii_clk_125m,
            gmii_clk_25m_out  => gmii_clk_25m,
            gmii_clk_2_5m_out => gmii_clk_2_5m,
            tx_reset          => sysClk200Rst,
            rx_reset          => sysClk200Rst,
            -- RGMII_TX Signals
            rgmii_txc         => ethTxClk(0),
            rgmii_tx_ctl      => ethTxCtrl(0),
            rgmii_txd(0)      => ethTxDataA(0),
            rgmii_txd(1)      => ethTxDataB(0),
            rgmii_txd(2)      => ethTxDataC(0),
            rgmii_txd(3)      => ethTxDataD(0),
            -- RGMII_TX Signals
            rgmii_rxc         => ethRxClk(0),
            rgmii_rx_ctl      => ethRxCtrl(0),
            rgmii_rxd(0)      => ethRxDataA(0),
            rgmii_rxd(1)      => ethRxDataB(0),
            rgmii_rxd(2)      => ethRxDataC(0),
            rgmii_rxd(3)      => ethRxDataD(0),
            -- RGMII_MIO Signals
            mdio_phy_mdc      => ethMdc(0),
            mdio_phy_i        => ethMioI(0),
            mdio_phy_o        => ethMioO(0),
            mdio_phy_t        => ethMioT(0),
            -- GMII_TX Signals
            gmii_tx_clk       => armEthRx(0).enetGmiiTxClk,
            gmii_tx_en        => armEthTx(0).enetGmiiTxEn,
            gmii_tx_er        => armEthTx(0).enetGmiiTxEr,
            gmii_txd          => armEthTx(0).enetGmiiTxD,
            -- GMII_RX Signals
            gmii_rx_clk       => armEthRx(0).enetGmiiRxClk,
            gmii_rx_dv        => armEthRx(0).enetGmiiRxDv,
            gmii_rx_er        => armEthRx(0).enetGmiiRxEr,
            gmii_rxd          => armEthRx(0).enetGmiiRxd,
            -- GMII_MIO Signals
            mdio_gem_mdc      => armEthTx(0).enetMdioMdc,
            mdio_gem_i        => armEthRx(0).enetMdioI,
            mdio_gem_o        => armEthTx(0).enetMdioO,
            mdio_gem_t        => armEthTx(0).enetMdioT,
            -- GMII_MISC Signals
            gmii_crs          => armEthRx(0).enetGmiiCrs,
            gmii_col          => armEthRx(0).enetGmiiCol,
            -- Status Signals         
            link_status       => linkStatus(0),
            clock_speed       => clockSpeed(0),
            duplex_status     => duplexStatus(0),
            speed_mode        => speedMode(0));

      GmiiToRgmiiSlave_Inst : entity work.GmiiToRgmiiSlave
        PORT MAP (
            tx_reset => sysClk200Rst,
            rx_reset => sysClk200Rst,
            ref_clk_in => ref_clk,
            mmcm_locked_in => mmcm_locked,
            gmii_clk_125m_in => gmii_clk_125m,
            gmii_clk_25m_in => gmii_clk_25m,
            gmii_clk_2_5m_in => gmii_clk_2_5m,
            -- RGMII_TX Signals
            rgmii_txc         => ethTxClk(1),
            rgmii_tx_ctl      => ethTxCtrl(1),
            rgmii_txd(0)      => ethTxDataA(1),
            rgmii_txd(1)      => ethTxDataB(1),
            rgmii_txd(2)      => ethTxDataC(1),
            rgmii_txd(3)      => ethTxDataD(1),
            -- RGMII_TX Signals
            rgmii_rxc         => ethRxClk(1),
            rgmii_rx_ctl      => ethRxCtrl(1),
            rgmii_rxd(0)      => ethRxDataA(1),
            rgmii_rxd(1)      => ethRxDataB(1),
            rgmii_rxd(2)      => ethRxDataC(1),
            rgmii_rxd(3)      => ethRxDataD(1),
            -- RGMII_MIO Signals
            mdio_phy_mdc      => ethMdc(1),
            mdio_phy_i        => ethMioI(1),
            mdio_phy_o        => ethMioO(1),
            mdio_phy_t        => ethMioT(1),
            -- GMII_TX Signals
            gmii_tx_clk       => armEthRx(1).enetGmiiTxClk,
            gmii_tx_en        => armEthTx(1).enetGmiiTxEn,
            gmii_tx_er        => armEthTx(1).enetGmiiTxEr,
            gmii_txd          => armEthTx(1).enetGmiiTxD,
            -- GMII_RX Signals
            gmii_rx_clk       => armEthRx(1).enetGmiiRxClk,
            gmii_rx_dv        => armEthRx(1).enetGmiiRxDv,
            gmii_rx_er        => armEthRx(1).enetGmiiRxEr,
            gmii_rxd          => armEthRx(1).enetGmiiRxd,
            -- GMII_MIO Signals
            mdio_gem_mdc      => armEthTx(1).enetMdioMdc,
            mdio_gem_i        => armEthRx(1).enetMdioI,
            mdio_gem_o        => armEthTx(1).enetMdioO,
            mdio_gem_t        => armEthTx(1).enetMdioT,
            -- GMII_MISC Signals
            gmii_crs          => armEthRx(1).enetGmiiCrs,
            gmii_col          => armEthRx(1).enetGmiiCol,
            -- Status Signals         
            link_status       => linkStatus(1),
            clock_speed       => clockSpeed(1),
            duplex_status     => duplexStatus(1),
            speed_mode        => speedMode(1));

   U_CoreGen: for i in 0 to 1 generate
      IOBUF_inst : IOBUF
         port map (
            O  => ethMioI(i),   -- Buffer output
            IO => ethMio(i),    -- Buffer inout port (connect directly to top-level port)
            I  => ethMioO(i),   -- Buffer input
            T  => ethMioT(i));  -- 3-state enable input, high=input, low=output 

      -- Unused Interrupt Signal
      armEthRx(i).enetExtInitN <= '0';

      ethResetL(i)  <= not sysClk200Rst;

   end generate;

   --armEthRx(1)     <= ARM_ETH_RX_INIT_C;
   --ethTxCtrl(1)    <= '0';
   --ethTxClk(1)     <= '0';
   --ethTxDataA(1)   <= '0';
   --ethTxDataB(1)   <= '0';
   --ethTxDataC(1)   <= '0';
   --ethTxDataD(1)   <= '0';
   --ethMdc(1)       <= '0';
   ----ethResetL(1)    <= '1';
   --PwrUpRst_Inst : entity work.PwrUpRst
   --   generic map(
   --      OUT_POLARITY_G => '0')
   --   port map (
   --      clk    => sysClk200,
   --      rstOut => ethResetL(1));

end mapping;

