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
      duplexStatus : slv(1 downto 0);
   signal speedMode,
      clockSpeed : Slv2Array(1 downto 0);
      
begin

   U_CoreGen: for i in 0 to 0 generate

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
            rgmii_txc         => ethTxClk(i),
            rgmii_tx_ctl      => ethTxCtrl(i),
            rgmii_txd(0)      => ethTxDataA(i),
            rgmii_txd(1)      => ethTxDataB(i),
            rgmii_txd(2)      => ethTxDataC(i),
            rgmii_txd(3)      => ethTxDataD(i),
            -- RGMII_TX Signals
            rgmii_rxc         => ethRxClk(i),
            rgmii_rx_ctl      => ethRxCtrl(i),
            rgmii_rxd(0)      => ethRxDataA(i),
            rgmii_rxd(1)      => ethRxDataB(i),
            rgmii_rxd(2)      => ethRxDataC(i),
            rgmii_rxd(3)      => ethRxDataD(i),
            -- RGMII_MIO Signals
            mdio_phy_mdc      => ethMdc(i),
            mdio_phy_i        => ethMioI(i),
            mdio_phy_o        => ethMioO(i),
            mdio_phy_t        => ethMioT(i),
            -- GMII_TX Signals
            gmii_tx_clk       => armEthRx(i).enetGmiiTxClk,
            gmii_tx_en        => armEthTx(i).enetGmiiTxEn,
            gmii_tx_er        => armEthTx(i).enetGmiiTxEr,
            gmii_txd          => armEthTx(i).enetGmiiTxD,
            -- GMII_RX Signals
            gmii_rx_clk       => armEthRx(i).enetGmiiRxClk,
            gmii_rx_dv        => armEthRx(i).enetGmiiRxDv,
            gmii_rx_er        => armEthRx(i).enetGmiiRxEr,
            gmii_rxd          => armEthRx(i).enetGmiiRxd,
            -- GMII_MIO Signals
            mdio_gem_mdc      => armEthTx(i).enetMdioMdc,
            mdio_gem_i        => armEthRx(i).enetMdioI,
            mdio_gem_o        => armEthTx(i).enetMdioO,
            mdio_gem_t        => armEthTx(i).enetMdioT,
            -- GMII_MISC Signals
            gmii_crs          => armEthRx(i).enetGmiiCrs,
            gmii_col          => armEthRx(i).enetGmiiCol,
            -- Status Signals         
            link_status       => linkStatus(i),
            clock_speed       => clockSpeed(i),
            duplex_status     => duplexStatus(i),
            speed_mode        => speedMode(i));

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

   armEthRx(1)     <= ARM_ETH_RX_INIT_C;
   ethTxCtrl(1)    <= '0';
   ethTxClk(1)     <= '0';
   ethTxDataA(1)   <= '0';
   ethTxDataB(1)   <= '0';
   ethTxDataC(1)   <= '0';
   ethTxDataD(1)   <= '0';
   ethMdc(1)       <= '0';
   ethResetL(1)    <= '1';

end mapping;

