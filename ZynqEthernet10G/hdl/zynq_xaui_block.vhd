-------------------------------------------------------------------------------
-- Title      :Block level wrapper
-- Project    : XAUI
-------------------------------------------------------------------------------
-- File       : zynq_xaui_block.vhd
-------------------------------------------------------------------------------
-- Description: This file is a wrapper for the XAUI core. It contains the XAUI
-- core, the transceivers and some transceiver logic.
-------------------------------------------------------------------------------
--
-- (c) Copyright 2002 - 2012 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity zynq_xaui_block is
    generic (
      WRAPPER_SIM_GTRESET_SPEEDUP : string := "FALSE"
      );
    port (
      dclk             : in  std_logic;
      clk156           : in  std_logic;
      refclk           : in  std_logic;
      reset            : in  std_logic;
      reset156         : in  std_logic;
      txoutclk         : out std_logic;
      xgmii_txd        : in  std_logic_vector(63 downto 0);
      xgmii_txc        : in  std_logic_vector(7 downto 0);
      xgmii_rxd        : out std_logic_vector(63 downto 0);
      xgmii_rxc        : out std_logic_vector(7 downto 0);
      xaui_tx_l0_p     : out std_logic;
      xaui_tx_l0_n     : out std_logic;
      xaui_tx_l1_p     : out std_logic;
      xaui_tx_l1_n     : out std_logic;
      xaui_tx_l2_p     : out std_logic;
      xaui_tx_l2_n     : out std_logic;
      xaui_tx_l3_p     : out std_logic;
      xaui_tx_l3_n     : out std_logic;
      xaui_rx_l0_p     : in  std_logic;
      xaui_rx_l0_n     : in  std_logic;
      xaui_rx_l1_p     : in  std_logic;
      xaui_rx_l1_n     : in  std_logic;
      xaui_rx_l2_p     : in  std_logic;
      xaui_rx_l2_n     : in  std_logic;
      xaui_rx_l3_p     : in  std_logic;
      xaui_rx_l3_n     : in  std_logic;
      txlock           : out std_logic;
      mmcm_lock        : in  std_logic;
      signal_detect    : in  std_logic_vector(3 downto 0);
      align_status     : out std_logic;
      sync_status      : out std_logic_vector(3 downto 0);
      drp_addr         : in  std_logic_vector(8 downto 0);
      drp_en           : in  std_logic_vector(3 downto 0);
      drp_i            : in  std_logic_vector(15 downto 0);
      drp_o            : out std_logic_vector(63 downto 0);
      drp_rdy          : out std_logic_vector(3 downto 0);
      drp_we           : in  std_logic_vector(3 downto 0);
      mgt_tx_ready     : out std_logic;
      configuration_vector : in  std_logic_vector(6 downto 0);
      status_vector        : out std_logic_vector(7 downto 0)
);
end zynq_xaui_block;

library ieee;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

architecture wrapper of zynq_xaui_block is

----------------------------------------------------------------------------
-- Component Declaration for the XAUI core.
----------------------------------------------------------------------------

   component zynq_xaui
      port (
      reset            : in  std_logic;
      xgmii_txd        : in  std_logic_vector(63 downto 0);
      xgmii_txc        : in  std_logic_vector(7 downto 0);
      xgmii_rxd        : out std_logic_vector(63 downto 0);
      xgmii_rxc        : out std_logic_vector(7 downto 0);
      usrclk           : in  std_logic;
      mgt_txdata       : out std_logic_vector(63 downto 0);
      mgt_txcharisk    : out std_logic_vector(7 downto 0);
      mgt_rxdata       : in  std_logic_vector(63 downto 0);
      mgt_rxcharisk    : in  std_logic_vector(7 downto 0);
      mgt_codevalid    : in  std_logic_vector(7 downto 0);
      mgt_codecomma    : in  std_logic_vector(7 downto 0);
      mgt_enable_align : out std_logic_vector(3 downto 0);
      mgt_enchansync   : out std_logic;
      mgt_syncok       : in  std_logic_vector(3 downto 0);
      mgt_rxlock       : in  std_logic_vector(3 downto 0);
      mgt_loopback     : out std_logic;
      mgt_powerdown    : out std_logic;
      mgt_tx_reset     : in  std_logic_vector(3 downto 0);
      mgt_rx_reset     : in  std_logic_vector(3 downto 0);
      signal_detect    : in  std_logic_vector(3 downto 0);
      align_status     : out std_logic;
      sync_status      : out std_logic_vector(3 downto 0);
      configuration_vector : in  std_logic_vector(6 downto 0);
      status_vector    : out std_logic_vector(7 downto 0));
  end component;

 --------------------------------------------------------------------------
 -- Component declaration for the GTX transceiver container
 --------------------------------------------------------------------------

component zynq_xaui_gt_wrapper is
generic
(
    -- Simulation attributes
    WRAPPER_SIM_GTRESET_SPEEDUP    : string    := "FALSE" -- Set to 1 to speed up sim reset
);
port
(

    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT4  (X0ERROR)
    --____________________________CHANNEL PORTS________________________________
    ---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
    GT0_DRPADDR_IN                          : in   std_logic_vector(8 downto 0);
    GT0_DRPCLK_IN                           : in   std_logic;
    GT0_DRPDI_IN                            : in   std_logic_vector(15 downto 0);
    GT0_DRPDO_OUT                           : out  std_logic_vector(15 downto 0);
    GT0_DRPEN_IN                            : in   std_logic;
    GT0_DRPRDY_OUT                          : out  std_logic;
    GT0_DRPWE_IN                            : in   std_logic;
    ------------------------------- Eye Scan Ports -----------------------------
    GT0_EYESCANDATAERROR_OUT                : out  std_logic;
    ------------------------ Loopback and Powerdown Ports ----------------------
    GT0_LOOPBACK_IN                         : in   std_logic_vector(2 downto 0);
    GT0_RXPD_IN                             : in   std_logic_vector(1 downto 0);
    GT0_TXPD_IN                             : in   std_logic_vector(1 downto 0);
    ------------------------------- Receive Ports ------------------------------
    GT0_RXUSERRDY_IN                        : in   std_logic;
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GT0_RXCHARISCOMMA_OUT                   : out  std_logic_vector(1 downto 0);
    GT0_RXCHARISK_OUT                       : out  std_logic_vector(1 downto 0);
    GT0_RXDISPERR_OUT                       : out  std_logic_vector(1 downto 0);
    GT0_RXNOTINTABLE_OUT                    : out  std_logic_vector(1 downto 0);
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    GT0_RXCHANBONDSEQ_OUT                   : out  std_logic;
    GT0_RXCHBONDEN_IN                       : in   std_logic;
    GT0_RXCHBONDI_IN                        : in   std_logic_vector(4 downto 0);
    GT0_RXCHBONDLEVEL_IN                    : in   std_logic_vector(2 downto 0);
    GT0_RXCHBONDMASTER_IN                   : in   std_logic;
    GT0_RXCHBONDO_OUT                       : out  std_logic_vector(4 downto 0);
    GT0_RXCHBONDSLAVE_IN                    : in   std_logic;
    ------------------- Receive Ports - Channel Bonding Ports  -----------------
    GT0_RXCHANISALIGNED_OUT                 : out  std_logic;
    GT0_RXCHANREALIGN_OUT                   : out  std_logic;
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GT0_RXCLKCORCNT_OUT                     : out  std_logic_vector(1 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GT0_RXBYTEISALIGNED_OUT                 : out  std_logic;
    GT0_RXBYTEREALIGN_OUT                   : out  std_logic;
    GT0_RXCOMMADET_OUT                      : out  std_logic;
    GT0_RXMCOMMAALIGNEN_IN                  : in   std_logic;
    GT0_RXPCOMMAALIGNEN_IN                  : in   std_logic;
    ----------------------- Receive Ports - PRBS Detection ---------------------
    GT0_RXPRBSCNTRESET_IN                   : in   std_logic;
    GT0_RXPRBSERR_OUT                       : out  std_logic;
    GT0_RXPRBSSEL_IN                        : in   std_logic_vector(2 downto 0);
    ------------------- Receive Ports - RX Data Path interface -----------------
    GT0_GTRXRESET_IN                        : in   std_logic;
    GT0_RXDATA_OUT                          : out  std_logic_vector(15 downto 0);
    GT0_RXOUTCLK_OUT                        : out  std_logic;
    GT0_RXPCSRESET_IN                       : in   std_logic;
    GT0_RXUSRCLK_IN                         : in   std_logic;
    GT0_RXUSRCLK2_IN                        : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GT0_GTXRXN_IN                           : in   std_logic;
    GT0_GTXRXP_IN                           : in   std_logic;
    GT0_RXCDRLOCK_OUT                       : out  std_logic;
    GT0_RXELECIDLE_OUT                      : out  std_logic;
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    GT0_RXBUFRESET_IN                       : in   std_logic;
    GT0_RXBUFSTATUS_OUT                     : out  std_logic_vector(2 downto 0);
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GT0_RXRESETDONE_OUT                     : out  std_logic;
    ------------------------------- Transmit Ports -----------------------------
    GT0_TXPOSTCURSOR_IN                     : in   std_logic_vector(4 downto 0);
    GT0_TXPRECURSOR_IN                      : in   std_logic_vector(4 downto 0);
    GT0_TXUSERRDY_IN                        : in   std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GT0_TXCHARISK_IN                        : in   std_logic_vector(1 downto 0);
    ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
    GT0_TXDLYEN_IN                          : in   std_logic;
    GT0_TXDLYSRESET_IN                      : in   std_logic;
    GT0_TXDLYSRESETDONE_OUT                 : out  std_logic;
    GT0_TXPHALIGN_IN                        : in   std_logic;
    GT0_TXPHALIGNDONE_OUT                   : out  std_logic;
    GT0_TXPHALIGNEN_IN                      : in   std_logic;
    GT0_TXPHDLYRESET_IN                     : in   std_logic;
    GT0_TXPHINIT_IN                         : in   std_logic;
    GT0_TXPHINITDONE_OUT                    : out  std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT0_GTTXRESET_IN                        : in   std_logic;
    GT0_TXDATA_IN                           : in   std_logic_vector(15 downto 0);
    GT0_TXOUTCLK_OUT                        : out  std_logic;
    GT0_TXOUTCLKFABRIC_OUT                  : out  std_logic;
    GT0_TXOUTCLKPCS_OUT                     : out  std_logic;
    GT0_TXPCSRESET_IN                       : in   std_logic;
    GT0_TXUSRCLK_IN                         : in   std_logic;
    GT0_TXUSRCLK2_IN                        : in   std_logic;
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GT0_GTXTXN_OUT                          : out  std_logic;
    GT0_GTXTXP_OUT                          : out  std_logic;
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GT0_TXRESETDONE_OUT                     : out  std_logic;
    --------------------- Transmit Ports - TX PRBS Generator -------------------
    GT0_TXPRBSFORCEERR_IN                   : in   std_logic;
    GT0_TXPRBSSEL_IN                        : in   std_logic_vector(2 downto 0);
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    GT0_TXELECIDLE_IN                       : in   std_logic;

    --____________________________CHANNEL PORTS________________________________
    ---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
    GT1_DRPADDR_IN                          : in   std_logic_vector(8 downto 0);
    GT1_DRPCLK_IN                           : in   std_logic;
    GT1_DRPDI_IN                            : in   std_logic_vector(15 downto 0);
    GT1_DRPDO_OUT                           : out  std_logic_vector(15 downto 0);
    GT1_DRPEN_IN                            : in   std_logic;
    GT1_DRPRDY_OUT                          : out  std_logic;
    GT1_DRPWE_IN                            : in   std_logic;
    ------------------------------- Eye Scan Ports -----------------------------
    GT1_EYESCANDATAERROR_OUT                : out  std_logic;
    ------------------------ Loopback and Powerdown Ports ----------------------
    GT1_LOOPBACK_IN                         : in   std_logic_vector(2 downto 0);
    GT1_RXPD_IN                             : in   std_logic_vector(1 downto 0);
    GT1_TXPD_IN                             : in   std_logic_vector(1 downto 0);
    ------------------------------- Receive Ports ------------------------------
    GT1_RXUSERRDY_IN                        : in   std_logic;
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GT1_RXCHARISCOMMA_OUT                   : out  std_logic_vector(1 downto 0);
    GT1_RXCHARISK_OUT                       : out  std_logic_vector(1 downto 0);
    GT1_RXDISPERR_OUT                       : out  std_logic_vector(1 downto 0);
    GT1_RXNOTINTABLE_OUT                    : out  std_logic_vector(1 downto 0);
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    GT1_RXCHANBONDSEQ_OUT                   : out  std_logic;
    GT1_RXCHBONDEN_IN                       : in   std_logic;
    GT1_RXCHBONDI_IN                        : in   std_logic_vector(4 downto 0);
    GT1_RXCHBONDLEVEL_IN                    : in   std_logic_vector(2 downto 0);
    GT1_RXCHBONDMASTER_IN                   : in   std_logic;
    GT1_RXCHBONDO_OUT                       : out  std_logic_vector(4 downto 0);
    GT1_RXCHBONDSLAVE_IN                    : in   std_logic;
    ------------------- Receive Ports - Channel Bonding Ports  -----------------
    GT1_RXCHANISALIGNED_OUT                 : out  std_logic;
    GT1_RXCHANREALIGN_OUT                   : out  std_logic;
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GT1_RXCLKCORCNT_OUT                     : out  std_logic_vector(1 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GT1_RXBYTEISALIGNED_OUT                 : out  std_logic;
    GT1_RXBYTEREALIGN_OUT                   : out  std_logic;
    GT1_RXCOMMADET_OUT                      : out  std_logic;
    GT1_RXMCOMMAALIGNEN_IN                  : in   std_logic;
    GT1_RXPCOMMAALIGNEN_IN                  : in   std_logic;
    ----------------------- Receive Ports - PRBS Detection ---------------------
    GT1_RXPRBSCNTRESET_IN                   : in   std_logic;
    GT1_RXPRBSERR_OUT                       : out  std_logic;
    GT1_RXPRBSSEL_IN                        : in   std_logic_vector(2 downto 0);
    ------------------- Receive Ports - RX Data Path interface -----------------
    GT1_GTRXRESET_IN                        : in   std_logic;
    GT1_RXDATA_OUT                          : out  std_logic_vector(15 downto 0);
    GT1_RXOUTCLK_OUT                        : out  std_logic;    
    GT1_RXPCSRESET_IN                       : in   std_logic;
    GT1_RXUSRCLK_IN                         : in   std_logic;
    GT1_RXUSRCLK2_IN                        : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GT1_GTXRXN_IN                           : in   std_logic;
    GT1_GTXRXP_IN                           : in   std_logic;
    GT1_RXCDRLOCK_OUT                       : out  std_logic;
    GT1_RXELECIDLE_OUT                      : out  std_logic;
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    GT1_RXBUFRESET_IN                       : in   std_logic;
    GT1_RXBUFSTATUS_OUT                     : out  std_logic_vector(2 downto 0);
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GT1_RXRESETDONE_OUT                     : out  std_logic;
    ------------------------------- Transmit Ports -----------------------------
    GT1_TXPOSTCURSOR_IN                     : in   std_logic_vector(4 downto 0);
    GT1_TXPRECURSOR_IN                      : in   std_logic_vector(4 downto 0);
    GT1_TXUSERRDY_IN                        : in   std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GT1_TXCHARISK_IN                        : in   std_logic_vector(1 downto 0);
    ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
    GT1_TXDLYEN_IN                          : in   std_logic;
    GT1_TXDLYSRESET_IN                      : in   std_logic;
    GT1_TXDLYSRESETDONE_OUT                 : out  std_logic;
    GT1_TXPHALIGN_IN                        : in   std_logic;
    GT1_TXPHALIGNDONE_OUT                   : out  std_logic;
    GT1_TXPHALIGNEN_IN                      : in   std_logic;
    GT1_TXPHDLYRESET_IN                     : in   std_logic;
    GT1_TXPHINIT_IN                         : in   std_logic;
    GT1_TXPHINITDONE_OUT                    : out  std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT1_GTTXRESET_IN                        : in   std_logic;
    GT1_TXDATA_IN                           : in   std_logic_vector(15 downto 0);
    GT1_TXOUTCLK_OUT                        : out  std_logic;
    GT1_TXOUTCLKFABRIC_OUT                  : out  std_logic;
    GT1_TXOUTCLKPCS_OUT                     : out  std_logic;
    GT1_TXPCSRESET_IN                       : in   std_logic;
    GT1_TXUSRCLK_IN                         : in   std_logic;
    GT1_TXUSRCLK2_IN                        : in   std_logic;
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GT1_GTXTXN_OUT                          : out  std_logic;
    GT1_GTXTXP_OUT                          : out  std_logic;
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GT1_TXRESETDONE_OUT                     : out  std_logic;
    --------------------- Transmit Ports - TX PRBS Generator -------------------
    GT1_TXPRBSFORCEERR_IN                   : in   std_logic;
    GT1_TXPRBSSEL_IN                        : in   std_logic_vector(2 downto 0);
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    GT1_TXELECIDLE_IN                       : in   std_logic;

    --____________________________CHANNEL PORTS________________________________
    ---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
    GT2_DRPADDR_IN                          : in   std_logic_vector(8 downto 0);
    GT2_DRPCLK_IN                           : in   std_logic;
    GT2_DRPDI_IN                            : in   std_logic_vector(15 downto 0);
    GT2_DRPDO_OUT                           : out  std_logic_vector(15 downto 0);
    GT2_DRPEN_IN                            : in   std_logic;
    GT2_DRPRDY_OUT                          : out  std_logic;
    GT2_DRPWE_IN                            : in   std_logic;
    ------------------------------- Eye Scan Ports -----------------------------
    GT2_EYESCANDATAERROR_OUT                : out  std_logic;
    ------------------------ Loopback and Powerdown Ports ----------------------
    GT2_LOOPBACK_IN                         : in   std_logic_vector(2 downto 0);
    GT2_RXPD_IN                             : in   std_logic_vector(1 downto 0);
    GT2_TXPD_IN                             : in   std_logic_vector(1 downto 0);
    ------------------------------- Receive Ports ------------------------------
    GT2_RXUSERRDY_IN                        : in   std_logic;
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GT2_RXCHARISCOMMA_OUT                   : out  std_logic_vector(1 downto 0);
    GT2_RXCHARISK_OUT                       : out  std_logic_vector(1 downto 0);
    GT2_RXDISPERR_OUT                       : out  std_logic_vector(1 downto 0);
    GT2_RXNOTINTABLE_OUT                    : out  std_logic_vector(1 downto 0);
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    GT2_RXCHANBONDSEQ_OUT                   : out  std_logic;
    GT2_RXCHBONDEN_IN                       : in   std_logic;
    GT2_RXCHBONDI_IN                        : in   std_logic_vector(4 downto 0);
    GT2_RXCHBONDLEVEL_IN                    : in   std_logic_vector(2 downto 0);
    GT2_RXCHBONDMASTER_IN                   : in   std_logic;
    GT2_RXCHBONDO_OUT                       : out  std_logic_vector(4 downto 0);
    GT2_RXCHBONDSLAVE_IN                    : in   std_logic;
    ------------------- Receive Ports - Channel Bonding Ports  -----------------
    GT2_RXCHANISALIGNED_OUT                 : out  std_logic;
    GT2_RXCHANREALIGN_OUT                   : out  std_logic;
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GT2_RXCLKCORCNT_OUT                     : out  std_logic_vector(1 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GT2_RXBYTEISALIGNED_OUT                 : out  std_logic;
    GT2_RXBYTEREALIGN_OUT                   : out  std_logic;
    GT2_RXCOMMADET_OUT                      : out  std_logic;
    GT2_RXMCOMMAALIGNEN_IN                  : in   std_logic;
    GT2_RXPCOMMAALIGNEN_IN                  : in   std_logic;
    ----------------------- Receive Ports - PRBS Detection ---------------------
    GT2_RXPRBSCNTRESET_IN                   : in   std_logic;
    GT2_RXPRBSERR_OUT                       : out  std_logic;
    GT2_RXPRBSSEL_IN                        : in   std_logic_vector(2 downto 0);
    ------------------- Receive Ports - RX Data Path interface -----------------
    GT2_GTRXRESET_IN                        : in   std_logic;
    GT2_RXDATA_OUT                          : out  std_logic_vector(15 downto 0);
    GT2_RXOUTCLK_OUT                        : out  std_logic;    
    GT2_RXPCSRESET_IN                       : in   std_logic;
    GT2_RXUSRCLK_IN                         : in   std_logic;
    GT2_RXUSRCLK2_IN                        : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GT2_GTXRXN_IN                           : in   std_logic;
    GT2_GTXRXP_IN                           : in   std_logic;
    GT2_RXCDRLOCK_OUT                       : out  std_logic;
    GT2_RXELECIDLE_OUT                      : out  std_logic;
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    GT2_RXBUFRESET_IN                       : in   std_logic;
    GT2_RXBUFSTATUS_OUT                     : out  std_logic_vector(2 downto 0);
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GT2_RXRESETDONE_OUT                     : out  std_logic;
    ------------------------------- Transmit Ports -----------------------------
    GT2_TXPOSTCURSOR_IN                     : in   std_logic_vector(4 downto 0);
    GT2_TXPRECURSOR_IN                      : in   std_logic_vector(4 downto 0);
    GT2_TXUSERRDY_IN                        : in   std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GT2_TXCHARISK_IN                        : in   std_logic_vector(1 downto 0);
    ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
    GT2_TXDLYEN_IN                          : in   std_logic;
    GT2_TXDLYSRESET_IN                      : in   std_logic;
    GT2_TXDLYSRESETDONE_OUT                 : out  std_logic;
    GT2_TXPHALIGN_IN                        : in   std_logic;
    GT2_TXPHALIGNDONE_OUT                   : out  std_logic;
    GT2_TXPHALIGNEN_IN                      : in   std_logic;
    GT2_TXPHDLYRESET_IN                     : in   std_logic;
    GT2_TXPHINIT_IN                         : in   std_logic;
    GT2_TXPHINITDONE_OUT                    : out  std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT2_GTTXRESET_IN                        : in   std_logic;
    GT2_TXDATA_IN                           : in   std_logic_vector(15 downto 0);
    GT2_TXOUTCLK_OUT                        : out  std_logic;
    GT2_TXOUTCLKFABRIC_OUT                  : out  std_logic;
    GT2_TXOUTCLKPCS_OUT                     : out  std_logic;
    GT2_TXPCSRESET_IN                       : in   std_logic;
    GT2_TXUSRCLK_IN                         : in   std_logic;
    GT2_TXUSRCLK2_IN                        : in   std_logic;
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GT2_GTXTXN_OUT                          : out  std_logic;
    GT2_GTXTXP_OUT                          : out  std_logic;
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GT2_TXRESETDONE_OUT                     : out  std_logic;
    --------------------- Transmit Ports - TX PRBS Generator -------------------
    GT2_TXPRBSFORCEERR_IN                   : in   std_logic;
    GT2_TXPRBSSEL_IN                        : in   std_logic_vector(2 downto 0);
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    GT2_TXELECIDLE_IN                       : in   std_logic;

    --____________________________CHANNEL PORTS________________________________
    ---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
    GT3_DRPADDR_IN                          : in   std_logic_vector(8 downto 0);
    GT3_DRPCLK_IN                           : in   std_logic;
    GT3_DRPDI_IN                            : in   std_logic_vector(15 downto 0);
    GT3_DRPDO_OUT                           : out  std_logic_vector(15 downto 0);
    GT3_DRPEN_IN                            : in   std_logic;
    GT3_DRPRDY_OUT                          : out  std_logic;
    GT3_DRPWE_IN                            : in   std_logic;
    ------------------------------- Eye Scan Ports -----------------------------
    GT3_EYESCANDATAERROR_OUT                : out  std_logic;
    ------------------------ Loopback and Powerdown Ports ----------------------
    GT3_LOOPBACK_IN                         : in   std_logic_vector(2 downto 0);
    GT3_RXPD_IN                             : in   std_logic_vector(1 downto 0);
    GT3_TXPD_IN                             : in   std_logic_vector(1 downto 0);
    ------------------------------- Receive Ports ------------------------------
    GT3_RXUSERRDY_IN                        : in   std_logic;
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GT3_RXCHARISCOMMA_OUT                   : out  std_logic_vector(1 downto 0);
    GT3_RXCHARISK_OUT                       : out  std_logic_vector(1 downto 0);
    GT3_RXDISPERR_OUT                       : out  std_logic_vector(1 downto 0);
    GT3_RXNOTINTABLE_OUT                    : out  std_logic_vector(1 downto 0);
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    GT3_RXCHANBONDSEQ_OUT                   : out  std_logic;
    GT3_RXCHBONDEN_IN                       : in   std_logic;
    GT3_RXCHBONDI_IN                        : in   std_logic_vector(4 downto 0);
    GT3_RXCHBONDLEVEL_IN                    : in   std_logic_vector(2 downto 0);
    GT3_RXCHBONDMASTER_IN                   : in   std_logic;
    GT3_RXCHBONDO_OUT                       : out  std_logic_vector(4 downto 0);
    GT3_RXCHBONDSLAVE_IN                    : in   std_logic;
    ------------------- Receive Ports - Channel Bonding Ports  -----------------
    GT3_RXCHANISALIGNED_OUT                 : out  std_logic;
    GT3_RXCHANREALIGN_OUT                   : out  std_logic;
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GT3_RXCLKCORCNT_OUT                     : out  std_logic_vector(1 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GT3_RXBYTEISALIGNED_OUT                 : out  std_logic;
    GT3_RXBYTEREALIGN_OUT                   : out  std_logic;
    GT3_RXCOMMADET_OUT                      : out  std_logic;
    GT3_RXMCOMMAALIGNEN_IN                  : in   std_logic;
    GT3_RXPCOMMAALIGNEN_IN                  : in   std_logic;
    ----------------------- Receive Ports - PRBS Detection ---------------------
    GT3_RXPRBSCNTRESET_IN                   : in   std_logic;
    GT3_RXPRBSERR_OUT                       : out  std_logic;
    GT3_RXPRBSSEL_IN                        : in   std_logic_vector(2 downto 0);
    ------------------- Receive Ports - RX Data Path interface -----------------
    GT3_GTRXRESET_IN                        : in   std_logic;
    GT3_RXDATA_OUT                          : out  std_logic_vector(15 downto 0);
    GT3_RXOUTCLK_OUT                        : out  std_logic;    
    GT3_RXPCSRESET_IN                       : in   std_logic;
    GT3_RXUSRCLK_IN                         : in   std_logic;
    GT3_RXUSRCLK2_IN                        : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GT3_GTXRXN_IN                           : in   std_logic;
    GT3_GTXRXP_IN                           : in   std_logic;
    GT3_RXCDRLOCK_OUT                       : out  std_logic;
    GT3_RXELECIDLE_OUT                      : out  std_logic;
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    GT3_RXBUFRESET_IN                       : in   std_logic;
    GT3_RXBUFSTATUS_OUT                     : out  std_logic_vector(2 downto 0);
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GT3_RXRESETDONE_OUT                     : out  std_logic;
    ------------------------------- Transmit Ports -----------------------------
    GT3_TXPOSTCURSOR_IN                     : in   std_logic_vector(4 downto 0);
    GT3_TXPRECURSOR_IN                      : in   std_logic_vector(4 downto 0);
    GT3_TXUSERRDY_IN                        : in   std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GT3_TXCHARISK_IN                        : in   std_logic_vector(1 downto 0);
    ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
    GT3_TXDLYEN_IN                          : in   std_logic;
    GT3_TXDLYSRESET_IN                      : in   std_logic;
    GT3_TXDLYSRESETDONE_OUT                 : out  std_logic;
    GT3_TXPHALIGN_IN                        : in   std_logic;
    GT3_TXPHALIGNDONE_OUT                   : out  std_logic;
    GT3_TXPHALIGNEN_IN                      : in   std_logic;
    GT3_TXPHDLYRESET_IN                     : in   std_logic;
    GT3_TXPHINIT_IN                         : in   std_logic;
    GT3_TXPHINITDONE_OUT                    : out  std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT3_GTTXRESET_IN                        : in   std_logic;
    GT3_TXDATA_IN                           : in   std_logic_vector(15 downto 0);
    GT3_TXOUTCLK_OUT                        : out  std_logic;
    GT3_TXOUTCLKFABRIC_OUT                  : out  std_logic;
    GT3_TXOUTCLKPCS_OUT                     : out  std_logic;
    GT3_TXPCSRESET_IN                       : in   std_logic;
    GT3_TXUSRCLK_IN                         : in   std_logic;
    GT3_TXUSRCLK2_IN                        : in   std_logic;
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GT3_GTXTXN_OUT                          : out  std_logic;
    GT3_GTXTXP_OUT                          : out  std_logic;
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GT3_TXRESETDONE_OUT                     : out  std_logic;
    --------------------- Transmit Ports - TX PRBS Generator -------------------
    GT3_TXPRBSFORCEERR_IN                   : in   std_logic;
    GT3_TXPRBSSEL_IN                        : in   std_logic_vector(2 downto 0);
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    GT3_TXELECIDLE_IN                       : in   std_logic;
    --____________________________COMMON PORTS________________________________
    ---------------------- Common Block  - Ref Clock Ports ---------------------
    GT0_GTREFCLK0_COMMON_IN                 : in   std_logic;
    ------------------------- Common Block - QPLL Ports ------------------------
    GT0_QPLLLOCK_OUT                        : out  std_logic;
    GT0_QPLLLOCKDETCLK_IN                   : in   std_logic;
    GT0_QPLLREFCLKLOST_OUT                  : out  std_logic;
    GT0_QPLLRESET_IN                        : in   std_logic

);
end component;

  component zynq_xaui_chanbond_monitor is
  port
  (
    CLK                     :  in  std_logic;
    RST                     :  in  std_logic;
    COMMA_ALIGN_DONE        :  in  std_logic;
    CORE_ENCHANSYNC         :  in  std_logic;
    CHANBOND_DONE           :  in  std_logic;
    RXRESET                 :  out std_logic
  );
  end component;

  component zynq_xaui_gt_wrapper_tx_sync_manual
   generic
   ( NUM_SLAVES    : integer := 10
   );
   port
   (
       M_GT_TXUSRCLK                    : in  std_logic;
       M_GT_TXRESETDONE                 : in  std_logic;
       M_GT_TXDLYSRESET                 : out std_logic;
       M_GT_TXDLYSRESETDONE             : in  std_logic;
       M_GT_TXPHINIT                    : out std_logic;
       M_GT_TXPHINITDONE                : in  std_logic;
       M_GT_TXDLYEN                     : out std_logic;
       M_GT_TXPHALIGN                   : out std_logic;
       M_GT_TXPHALIGNDONE               : in  std_logic;
       START                            : in  std_logic;
       PHASE_ALIGN_COMPLETE             : out std_logic;
       S_GT_TXDLYSRESET                 : out std_logic_vector (NUM_SLAVES-1 downto 0);
       S_GT_TXDLYSRESETDONE             : in  std_logic_vector (NUM_SLAVES-1 downto 0);
       S_GT_TXPHINIT                    : out std_logic_vector (NUM_SLAVES-1 downto 0);
       S_GT_TXPHINITDONE                : in  std_logic_vector (NUM_SLAVES-1 downto 0);
       S_GT_TXPHALIGN                   : out std_logic_vector (NUM_SLAVES-1 downto 0);
       S_GT_TXPHALIGNDONE               : in  std_logic_vector (NUM_SLAVES-1 downto 0)
   );
   end component;

  constant SYNC_COUNT_LENGTH       : integer := 16;
  constant RESET_COUNT_LENGTH      : integer := 128;

----------------------------------------------------------------------------
-- Signal declarations.
---------------------------------------------------------------------------

  signal mgt_txdata         : std_logic_vector(63 downto 0);
  signal mgt_txcharisk      : std_logic_vector(7 downto 0);
  signal mgt_rxdata         : std_logic_vector(63 downto 0);
  signal mgt_rxcharisk      : std_logic_vector(7 downto 0);
  signal mgt_enable_align   : std_logic_vector(3 downto 0);
  signal mgt_enchansync     : std_logic;
  signal mgt_enchansync_reg : std_logic;
  signal mgt_syncok         : std_logic_vector(3 downto 0);
  signal mgt_rxdisperr      : std_logic_vector(7 downto 0);
  signal mgt_rxnotintable   : std_logic_vector(7 downto 0);
  signal mgt_rx_reset       : std_logic;
  signal mgt_tx_reset       : std_logic;
  signal mgt_codevalid      : std_logic_vector(7 downto 0);
  signal mgt_rxchariscomma  : std_logic_vector(7 downto 0);
  signal mgt_rxdata_reg       : std_logic_vector(63 downto 0);
  signal mgt_rxcharisk_reg0 : std_logic;
  signal mgt_rxcharisk_reg1 : std_logic;
  signal mgt_rxcharisk_reg2 : std_logic;
  signal mgt_rxcharisk_reg3 : std_logic;
  signal mgt_rxcharisk_reg4 : std_logic;
  signal mgt_rxcharisk_reg5 : std_logic;
  signal mgt_rxcharisk_reg6 : std_logic;
  signal mgt_rxcharisk_reg7 : std_logic;
  signal mgt_rxcharisk_reg : std_logic_vector(7 downto 0);
  signal mgt_rxlock_reg       : std_logic_vector(3 downto 0);
  signal mgt_rxlock_r1        : std_logic_vector(3 downto 0);
  signal mgt_rxnotintable_reg0 : std_logic;
  signal mgt_rxnotintable_reg1 : std_logic;
  signal mgt_rxnotintable_reg2 : std_logic;
  signal mgt_rxnotintable_reg3 : std_logic;
  signal mgt_rxnotintable_reg4 : std_logic;
  signal mgt_rxnotintable_reg5 : std_logic;
  signal mgt_rxnotintable_reg6 : std_logic;
  signal mgt_rxnotintable_reg7 : std_logic;
  signal mgt_rxdisperr_reg0 : std_logic;
  signal mgt_rxdisperr_reg1 : std_logic;
  signal mgt_rxdisperr_reg2 : std_logic;
  signal mgt_rxdisperr_reg3 : std_logic;
  signal mgt_rxdisperr_reg4 : std_logic;
  signal mgt_rxdisperr_reg5 : std_logic;
  signal mgt_rxdisperr_reg6 : std_logic;
  signal mgt_rxdisperr_reg7 : std_logic;
  signal mgt_codecomma_reg0 : std_logic;
  signal mgt_codecomma_reg1 : std_logic;
  signal mgt_codecomma_reg2 : std_logic;
  signal mgt_codecomma_reg3 : std_logic;
  signal mgt_codecomma_reg4 : std_logic;
  signal mgt_codecomma_reg5 : std_logic;
  signal mgt_codecomma_reg6 : std_logic;
  signal mgt_codecomma_reg7 : std_logic;
  signal mgt_codecomma_reg  : std_logic_vector(7 downto 0);
  signal mgt_rxbuf_reset     : std_logic_vector(3 downto 0) := "0000";
  signal mgt_tx_fault        : std_logic_vector(3 downto 0);
  signal mgt_loopback       : std_logic;
  signal mgt_powerdown      : std_logic;
  signal mgt_powerdown_2    : std_logic_vector(1 downto 0);
  signal mgt_powerdown_r    : std_logic;
  signal mgt_powerdown_falling : std_logic;
  signal mgt_plllocked      : std_logic;
  signal txlock_i            : std_logic;
  signal mgt_rxresetdone     : std_logic_vector(3 downto 0);
  signal mgt_rxresetdone_reg : std_logic_vector(3 downto 0);
  signal mgt_rxbuferr        : std_logic_vector(3 downto 0);
  signal mgt_rxbufstatus_reg : std_logic_vector(11 downto 0);
  signal mgt_rxbufstatus     : std_logic_vector(11 downto 0);
  signal mgt_txresetdone     : std_logic_vector(3 downto 0);
  signal mgt_txresetdone_reg : std_logic_vector(3 downto 0);
  signal loopback_int        : std_logic_vector(2 downto 0);
  signal cbm_rx_reset        : std_logic;
  signal mgt_txuserrdy       : std_logic;
  signal mgt_rxuserrdy       : std_logic;


  signal gt0_txoutclk_i     : std_logic;

  -------------------------- Channel Bonding Wires ---------------------------
  signal    gt0_rxchbondo_i : std_logic_vector(4 downto 0);
  signal    gt1_rxchbondo_i : std_logic_vector(4 downto 0);
  signal    gt2_rxchbondo_i : std_logic_vector(4 downto 0);
  signal    gt3_rxchbondo_i : std_logic_vector(4 downto 0);

  --CHANBOND_MONITOR signals
  signal mgt_rxchanisaligned   : std_logic_vector(3 downto 0);
  signal mgt_rxchanisaligned_r : std_logic_vector(3 downto 0) := "0000";
  signal comma_align_done      : std_logic;
  signal sync_status_i         : std_logic_vector(3 downto 0);
  signal align_status_i        : std_logic;

  signal  m_gt_txdlyen             : std_logic;
  signal  m_gt_txdlysreset         : std_logic;
  signal  m_gt_txdlysresetdone     : std_logic;
  signal  m_gt_txphinit            : std_logic;
  signal  m_gt_txphinitdone        : std_logic;
  signal  m_gt_txphalign           : std_logic;
  signal  m_gt_txphaligndone       : std_logic;
  signal  s_gt_txdlysreset         : std_logic_vector(2 downto 0);
  signal  s_gt_txdlysresetdone     : std_logic_vector(2 downto 0);
  signal  s_gt_txphinit            : std_logic_vector(2 downto 0);
  signal  s_gt_txphinitdone        : std_logic_vector(2 downto 0);
  signal  s_gt_txphalign           : std_logic_vector(2 downto 0);
  signal  s_gt_txphaligndone       : std_logic_vector(2 downto 0);
  signal  txsync_start_phase_align : std_logic_vector(1 downto 0);
  signal  phase_align_complete     : std_logic;

  signal reset_counter             : std_logic_vector(RESET_COUNT_LENGTH - 1 downto 0) := (others => '0');
  signal sync_counter              : unsigned(SYNC_COUNT_LENGTH - 1 downto 0)  := (others => '0');
  signal reset_count_done          : std_logic := '0';
  signal first_reset               : std_logic := '0';
  signal pll_reset                : std_logic;

  --ASYNC_REG attributes
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of mgt_rxlock_r1 : signal is "TRUE";
----------------------------------------------------------------------------
-- Function declarations.
---------------------------------------------------------------------------
function IsBufError (bufStatus:std_logic_vector(2 downto 0)) return std_logic is
  variable result : std_logic;
begin
  if bufStatus = "101" or bufStatus = "110" then
    result := '1';
  else
    result := '0';
  end if;
  return result;
end;

begin

  xaui_core : zynq_xaui
    port map (
      reset            => reset156,
      xgmii_txd        => xgmii_txd,
      xgmii_txc        => xgmii_txc,
      xgmii_rxd        => xgmii_rxd,
      xgmii_rxc        => xgmii_rxc,
      usrclk           => clk156,
      mgt_txdata       => mgt_txdata,
      mgt_txcharisk    => mgt_txcharisk,
      mgt_rxdata       => mgt_rxdata_reg,
      mgt_rxcharisk    => mgt_rxcharisk_reg,
      mgt_codevalid    => mgt_codevalid,
      mgt_codecomma    => mgt_codecomma_reg,
      mgt_enable_align => mgt_enable_align,
      mgt_enchansync   => mgt_enchansync,
      mgt_syncok       => mgt_syncok,
      mgt_rxlock       => mgt_rxlock_reg,
      mgt_loopback     => mgt_loopback,
      mgt_powerdown    => mgt_powerdown,
      mgt_tx_reset     => mgt_tx_fault,
      mgt_rx_reset     => mgt_rxbuf_reset,
      signal_detect    => signal_detect,
      align_status     => align_status_i,
      sync_status      => sync_status_i,
      configuration_vector => configuration_vector,
      status_vector        => status_vector);

  ----------------------------------------------------------------------
   -- Transceiver instances
   gt_wrapper_i : zynq_xaui_gt_wrapper
    generic map (
      WRAPPER_SIM_GTRESET_SPEEDUP => WRAPPER_SIM_GTRESET_SPEEDUP
    )
    port map (

    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT0  (X0Y0)
    --____________________________CHANNEL PORTS________________________________
    ---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
    GT0_DRPADDR_IN                          => drp_addr,
    GT0_DRPCLK_IN                           => dclk,
    GT0_DRPDI_IN                            => drp_i,
    GT0_DRPDO_OUT                           => drp_o(15 downto 0),
    GT0_DRPEN_IN                            => drp_en(0),
    GT0_DRPRDY_OUT                          => drp_rdy(0),
    GT0_DRPWE_IN                            => drp_we(0),
    ------------------------------- Eye Scan Ports -----------------------------
    GT0_EYESCANDATAERROR_OUT                => open,
    ------------------------ Loopback and Powerdown Ports ----------------------
    GT0_LOOPBACK_IN                         => loopback_int,
    GT0_RXPD_IN                             => mgt_powerdown_2,
    GT0_TXPD_IN                             => mgt_powerdown_2,
    ------------------------------- Receive Ports ------------------------------
    GT0_RXUSERRDY_IN                        => mgt_rxuserrdy,
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GT0_RXCHARISCOMMA_OUT                   => mgt_rxchariscomma(1 downto 0),
    GT0_RXCHARISK_OUT                       => mgt_rxcharisk(1 downto 0),
    GT0_RXDISPERR_OUT                       => mgt_rxdisperr(1 downto 0),
    GT0_RXNOTINTABLE_OUT                    => mgt_rxnotintable(1 downto 0),
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    GT0_RXCHANBONDSEQ_OUT                   => open,
    GT0_RXCHBONDEN_IN                       => mgt_enchansync_reg,
    GT0_RXCHBONDI_IN                        => gt1_rxchbondo_i,
    GT0_RXCHBONDLEVEL_IN                    => "000",
    GT0_RXCHBONDMASTER_IN                   => '0',
    GT0_RXCHBONDO_OUT                       => gt0_rxchbondo_i,
    GT0_RXCHBONDSLAVE_IN                    => '1',
    ------------------- Receive Ports - Channel Bonding Ports  -----------------
    GT0_RXCHANISALIGNED_OUT                 => mgt_rxchanisaligned(0),
    GT0_RXCHANREALIGN_OUT                   => open,
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GT0_RXCLKCORCNT_OUT                     => open,
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GT0_RXBYTEISALIGNED_OUT                 => open,
    GT0_RXBYTEREALIGN_OUT                   => open,
    GT0_RXCOMMADET_OUT                      => open,
    GT0_RXMCOMMAALIGNEN_IN                  => mgt_enable_align(0),
    GT0_RXPCOMMAALIGNEN_IN                  => mgt_enable_align(0),
    ----------------------- Receive Ports - PRBS Detection ---------------------
    GT0_RXPRBSCNTRESET_IN                   => '0',
    GT0_RXPRBSERR_OUT                       => open,
    GT0_RXPRBSSEL_IN                        => "000",
    ------------------- Receive Ports - RX Data Path interface -----------------
    GT0_GTRXRESET_IN                        => mgt_rx_reset,
    GT0_RXDATA_OUT                          => mgt_rxdata(15 downto 0),
    GT0_RXOUTCLK_OUT                        => open,    
    GT0_RXPCSRESET_IN                       => '0',
    GT0_RXUSRCLK_IN                         => clk156,
    GT0_RXUSRCLK2_IN                        => clk156,
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GT0_GTXRXN_IN                           => xaui_rx_l0_n,
    GT0_GTXRXP_IN                           => xaui_rx_l0_p,
    GT0_RXCDRLOCK_OUT                       => open,
    GT0_RXELECIDLE_OUT                      => open,
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    GT0_RXBUFRESET_IN                       => mgt_rxbuf_reset(0),
    GT0_RXBUFSTATUS_OUT                     => mgt_rxbufstatus(2 downto 0),
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GT0_RXRESETDONE_OUT                     => mgt_rxresetdone(0),
    ------------------------------- Transmit Ports -----------------------------
    GT0_TXPOSTCURSOR_IN                     => "00000",
    GT0_TXPRECURSOR_IN                      => "00000",
    GT0_TXUSERRDY_IN                        => mgt_txuserrdy,
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GT0_TXCHARISK_IN                        => mgt_txcharisk(1 downto 0),
    ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
    GT0_TXDLYEN_IN                          => m_gt_txdlyen,
    GT0_TXDLYSRESET_IN                      => m_gt_txdlysreset,
    GT0_TXDLYSRESETDONE_OUT                 => m_gt_txdlysresetdone,
    GT0_TXPHALIGN_IN                        => m_gt_txphalign,
    GT0_TXPHALIGNDONE_OUT                   => m_gt_txphaligndone,
    GT0_TXPHALIGNEN_IN                      => '1',
    GT0_TXPHDLYRESET_IN                     => '0',
    GT0_TXPHINIT_IN                         => m_gt_txphinit,
    GT0_TXPHINITDONE_OUT                    => m_gt_txphinitdone,
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT0_GTTXRESET_IN                        => mgt_tx_reset,
    GT0_TXDATA_IN                           => mgt_txdata(15 downto 0),
    GT0_TXOUTCLK_OUT                        => gt0_txoutclk_i,
    GT0_TXOUTCLKFABRIC_OUT                  => open,
    GT0_TXOUTCLKPCS_OUT                     => open,
    GT0_TXPCSRESET_IN                       => '0',
    GT0_TXUSRCLK_IN                         => clk156,
    GT0_TXUSRCLK2_IN                        => clk156,
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GT0_GTXTXN_OUT                          => xaui_tx_l0_n,
    GT0_GTXTXP_OUT                          => xaui_tx_l0_p,
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GT0_TXRESETDONE_OUT                     => mgt_txresetdone(0),
    --------------------- Transmit Ports - TX PRBS Generator -------------------
    GT0_TXPRBSFORCEERR_IN                   => '0',
    GT0_TXPRBSSEL_IN                        => "000",
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    GT0_TXELECIDLE_IN                       => mgt_powerdown_r,


    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT1  (X0Y1)
    --____________________________CHANNEL PORTS________________________________
    ---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
    GT1_DRPADDR_IN                          => drp_addr,
    GT1_DRPCLK_IN                           => dclk,
    GT1_DRPDI_IN                            => drp_i,
    GT1_DRPDO_OUT                           => drp_o(31 downto 16),
    GT1_DRPEN_IN                            => drp_en(1),
    GT1_DRPRDY_OUT                          => drp_rdy(1),
    GT1_DRPWE_IN                            => drp_we(1),
    ------------------------------- Eye Scan Ports -----------------------------
    GT1_EYESCANDATAERROR_OUT                => open,
    ------------------------ Loopback and Powerdown Ports ----------------------
    GT1_LOOPBACK_IN                         => loopback_int,
    GT1_RXPD_IN                             => mgt_powerdown_2,
    GT1_TXPD_IN                             => mgt_powerdown_2,
    ------------------------------- Receive Ports ------------------------------
    GT1_RXUSERRDY_IN                        => mgt_rxuserrdy,
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GT1_RXCHARISCOMMA_OUT                   => mgt_rxchariscomma(3 downto 2),
    GT1_RXCHARISK_OUT                       => mgt_rxcharisk(3 downto 2),
    GT1_RXDISPERR_OUT                       => mgt_rxdisperr(3 downto 2),
    GT1_RXNOTINTABLE_OUT                    => mgt_rxnotintable(3 downto 2),
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    GT1_RXCHANBONDSEQ_OUT                   => open,
    GT1_RXCHBONDEN_IN                       => mgt_enchansync_reg,
    GT1_RXCHBONDI_IN                        => gt2_rxchbondo_i,
    GT1_RXCHBONDLEVEL_IN                    => "001",
    GT1_RXCHBONDMASTER_IN                   => '0',
    GT1_RXCHBONDO_OUT                       => gt1_rxchbondo_i,
    GT1_RXCHBONDSLAVE_IN                    => '1',
    ------------------- Receive Ports - Channel Bonding Ports  -----------------
    GT1_RXCHANISALIGNED_OUT                 => mgt_rxchanisaligned(1),
    GT1_RXCHANREALIGN_OUT                   => open,
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GT1_RXCLKCORCNT_OUT                     => open,
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GT1_RXBYTEISALIGNED_OUT                 => open,
    GT1_RXBYTEREALIGN_OUT                   => open,
    GT1_RXCOMMADET_OUT                      => open,
    GT1_RXMCOMMAALIGNEN_IN                  => mgt_enable_align(1),
    GT1_RXPCOMMAALIGNEN_IN                  => mgt_enable_align(1),
    ----------------------- Receive Ports - PRBS Detection ---------------------
    GT1_RXPRBSCNTRESET_IN                   => '0',
    GT1_RXPRBSERR_OUT                       => open,
    GT1_RXPRBSSEL_IN                        => "000",
    ------------------- Receive Ports - RX Data Path interface -----------------
    GT1_GTRXRESET_IN                        => mgt_rx_reset,
    GT1_RXDATA_OUT                          => mgt_rxdata(31 downto 16),
    GT1_RXOUTCLK_OUT                        => open,    
    GT1_RXPCSRESET_IN                       => '0',
    GT1_RXUSRCLK_IN                         => clk156,
    GT1_RXUSRCLK2_IN                        => clk156,
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GT1_GTXRXN_IN                           => xaui_rx_l1_n,
    GT1_GTXRXP_IN                           => xaui_rx_l1_p,
    GT1_RXCDRLOCK_OUT                       => open,
    GT1_RXELECIDLE_OUT                      => open,
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    GT1_RXBUFRESET_IN                       => mgt_rxbuf_reset(1),
    GT1_RXBUFSTATUS_OUT                     => mgt_rxbufstatus(5 downto 3),
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GT1_RXRESETDONE_OUT                     => mgt_rxresetdone(1),
    ------------------------------- Transmit Ports -----------------------------
    GT1_TXPOSTCURSOR_IN                     => "00000",
    GT1_TXPRECURSOR_IN                      => "00000",
    GT1_TXUSERRDY_IN                        => mgt_txuserrdy,
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GT1_TXCHARISK_IN                        => mgt_txcharisk(3 downto 2),
    ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
    GT1_TXDLYEN_IN                          => '0',
    GT1_TXDLYSRESET_IN                      => s_gt_txdlysreset(0),
    GT1_TXDLYSRESETDONE_OUT                 => s_gt_txdlysresetdone(0),
    GT1_TXPHALIGN_IN                        => s_gt_txphalign(0),
    GT1_TXPHALIGNDONE_OUT                   => s_gt_txphaligndone(0),
    GT1_TXPHALIGNEN_IN                      => '1',
    GT1_TXPHDLYRESET_IN                     => '0',
    GT1_TXPHINIT_IN                         => s_gt_txphinit(0),
    GT1_TXPHINITDONE_OUT                    => s_gt_txphinitdone(0),
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT1_GTTXRESET_IN                        => mgt_tx_reset,
    GT1_TXDATA_IN                           => mgt_txdata(31 downto 16),
    GT1_TXOUTCLK_OUT                        => open,
    GT1_TXOUTCLKFABRIC_OUT                  => open,
    GT1_TXOUTCLKPCS_OUT                     => open,
    GT1_TXPCSRESET_IN                       => '0',
    GT1_TXUSRCLK_IN                         => clk156,
    GT1_TXUSRCLK2_IN                        => clk156,
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GT1_GTXTXN_OUT                          => xaui_tx_l1_n,
    GT1_GTXTXP_OUT                          => xaui_tx_l1_p,
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GT1_TXRESETDONE_OUT                     => mgt_txresetdone(1),
    --------------------- Transmit Ports - TX PRBS Generator -------------------
    GT1_TXPRBSFORCEERR_IN                   => '0',
    GT1_TXPRBSSEL_IN                        => "000",
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    GT1_TXELECIDLE_IN                       => mgt_powerdown_r,


    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT2  (X0Y2)
    --____________________________CHANNEL PORTS________________________________
    ---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
    GT2_DRPADDR_IN                          => drp_addr,
    GT2_DRPCLK_IN                           => dclk,
    GT2_DRPDI_IN                            => drp_i,
    GT2_DRPDO_OUT                           => drp_o(47 downto 32),
    GT2_DRPEN_IN                            => drp_en(2),
    GT2_DRPRDY_OUT                          => drp_rdy(2),
    GT2_DRPWE_IN                            => drp_we(2),
    ------------------------------- Eye Scan Ports -----------------------------
    GT2_EYESCANDATAERROR_OUT                => open,
    ------------------------ Loopback and Powerdown Ports ----------------------
    GT2_LOOPBACK_IN                         => loopback_int,
    GT2_RXPD_IN                             => mgt_powerdown_2,
    GT2_TXPD_IN                             => mgt_powerdown_2,
    ------------------------------- Receive Ports ------------------------------
    GT2_RXUSERRDY_IN                        => mgt_rxuserrdy,
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GT2_RXCHARISCOMMA_OUT                   => mgt_rxchariscomma(5 downto 4),
    GT2_RXCHARISK_OUT                       => mgt_rxcharisk(5 downto 4),
    GT2_RXDISPERR_OUT                       => mgt_rxdisperr(5 downto 4),
    GT2_RXNOTINTABLE_OUT                    => mgt_rxnotintable(5 downto 4),
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    GT2_RXCHANBONDSEQ_OUT                   => open,
    GT2_RXCHBONDEN_IN                       => mgt_enchansync_reg,
    GT2_RXCHBONDI_IN                        => (others => '0'),
    GT2_RXCHBONDLEVEL_IN                    => "010",
    GT2_RXCHBONDMASTER_IN                   => '1',
    GT2_RXCHBONDO_OUT                       => gt2_rxchbondo_i,
    GT2_RXCHBONDSLAVE_IN                    => '0',
    ------------------- Receive Ports - Channel Bonding Ports  -----------------
    GT2_RXCHANISALIGNED_OUT                 => mgt_rxchanisaligned(2),
    GT2_RXCHANREALIGN_OUT                   => open,
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GT2_RXCLKCORCNT_OUT                     => open,
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GT2_RXBYTEISALIGNED_OUT                 => open,
    GT2_RXBYTEREALIGN_OUT                   => open,
    GT2_RXCOMMADET_OUT                      => open,
    GT2_RXMCOMMAALIGNEN_IN                  => mgt_enable_align(2),
    GT2_RXPCOMMAALIGNEN_IN                  => mgt_enable_align(2),
    ----------------------- Receive Ports - PRBS Detection ---------------------
    GT2_RXPRBSCNTRESET_IN                   => '0',
    GT2_RXPRBSERR_OUT                       => open,
    GT2_RXPRBSSEL_IN                        => "000",
    ------------------- Receive Ports - RX Data Path interface -----------------
    GT2_GTRXRESET_IN                        => mgt_rx_reset,
    GT2_RXDATA_OUT                          => mgt_rxdata(47 downto 32),
    GT2_RXOUTCLK_OUT                        => open,    
    GT2_RXPCSRESET_IN                       => '0',
    GT2_RXUSRCLK_IN                         => clk156,
    GT2_RXUSRCLK2_IN                        => clk156,
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GT2_GTXRXN_IN                           => xaui_rx_l2_n,
    GT2_GTXRXP_IN                           => xaui_rx_l2_p,
    GT2_RXCDRLOCK_OUT                       => open,
    GT2_RXELECIDLE_OUT                      => open,
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    GT2_RXBUFRESET_IN                       => mgt_rxbuf_reset(2),
    GT2_RXBUFSTATUS_OUT                     => mgt_rxbufstatus(8 downto 6),
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GT2_RXRESETDONE_OUT                     => mgt_rxresetdone(2),
    ------------------------------- Transmit Ports -----------------------------
    GT2_TXPOSTCURSOR_IN                     => "00000",
    GT2_TXPRECURSOR_IN                      => "00000",
    GT2_TXUSERRDY_IN                        => mgt_txuserrdy,
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GT2_TXCHARISK_IN                        => mgt_txcharisk(5 downto 4),
    ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
    GT2_TXDLYEN_IN                          => '0',
    GT2_TXDLYSRESET_IN                      => s_gt_txdlysreset(1),
    GT2_TXDLYSRESETDONE_OUT                 => s_gt_txdlysresetdone(1),
    GT2_TXPHALIGN_IN                        => s_gt_txphalign(1),
    GT2_TXPHALIGNDONE_OUT                   => s_gt_txphaligndone(1),
    GT2_TXPHALIGNEN_IN                      => '1',
    GT2_TXPHDLYRESET_IN                     => '0',
    GT2_TXPHINIT_IN                         => s_gt_txphinit(1),
    GT2_TXPHINITDONE_OUT                    => s_gt_txphinitdone(1),
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT2_GTTXRESET_IN                        => mgt_tx_reset,
    GT2_TXDATA_IN                           => mgt_txdata(47 downto 32),
    GT2_TXOUTCLK_OUT                        => open,
    GT2_TXOUTCLKFABRIC_OUT                  => open,
    GT2_TXOUTCLKPCS_OUT                     => open,
    GT2_TXPCSRESET_IN                       => '0',
    GT2_TXUSRCLK_IN                         => clk156,
    GT2_TXUSRCLK2_IN                        => clk156,
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GT2_GTXTXN_OUT                          => xaui_tx_l2_n,
    GT2_GTXTXP_OUT                          => xaui_tx_l2_p,
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GT2_TXRESETDONE_OUT                     => mgt_txresetdone(2),
    --------------------- Transmit Ports - TX PRBS Generator -------------------
    GT2_TXPRBSFORCEERR_IN                   => '0',
    GT2_TXPRBSSEL_IN                        => "000",
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    GT2_TXELECIDLE_IN                       => mgt_powerdown_r,


    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT3  (X0Y3)
    --____________________________CHANNEL PORTS________________________________
    ---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
    GT3_DRPADDR_IN                          => drp_addr,
    GT3_DRPCLK_IN                           => dclk,
    GT3_DRPDI_IN                            => drp_i,
    GT3_DRPDO_OUT                           => drp_o(63 downto 48),
    GT3_DRPEN_IN                            => drp_en(3),
    GT3_DRPRDY_OUT                          => drp_rdy(3),
    GT3_DRPWE_IN                            => drp_we(3),
    ------------------------------- Eye Scan Ports -----------------------------
    GT3_EYESCANDATAERROR_OUT                => open,
    ------------------------ Loopback and Powerdown Ports ----------------------
    GT3_LOOPBACK_IN                         => loopback_int,
    GT3_RXPD_IN                             => mgt_powerdown_2,
    GT3_TXPD_IN                             => mgt_powerdown_2,
    ------------------------------- Receive Ports ------------------------------
    GT3_RXUSERRDY_IN                        => mgt_rxuserrdy,
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GT3_RXCHARISCOMMA_OUT                   => mgt_rxchariscomma(7 downto 6),
    GT3_RXCHARISK_OUT                       => mgt_rxcharisk(7 downto 6),
    GT3_RXDISPERR_OUT                       => mgt_rxdisperr(7 downto 6),
    GT3_RXNOTINTABLE_OUT                    => mgt_rxnotintable(7 downto 6),
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    GT3_RXCHANBONDSEQ_OUT                   => open,
    GT3_RXCHBONDEN_IN                       => mgt_enchansync_reg,
    GT3_RXCHBONDI_IN                        => gt2_rxchbondo_i,
    GT3_RXCHBONDLEVEL_IN                    => "001",
    GT3_RXCHBONDMASTER_IN                   => '0',
    GT3_RXCHBONDO_OUT                       => gt3_rxchbondo_i,
    GT3_RXCHBONDSLAVE_IN                    => '1',
    ------------------- Receive Ports - Channel Bonding Ports  -----------------
    GT3_RXCHANISALIGNED_OUT                 => mgt_rxchanisaligned(3),
    GT3_RXCHANREALIGN_OUT                   => open,
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GT3_RXCLKCORCNT_OUT                     => open,
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GT3_RXBYTEISALIGNED_OUT                 => open,
    GT3_RXBYTEREALIGN_OUT                   => open,
    GT3_RXCOMMADET_OUT                      => open,
    GT3_RXMCOMMAALIGNEN_IN                  => mgt_enable_align(3),
    GT3_RXPCOMMAALIGNEN_IN                  => mgt_enable_align(3),
    ----------------------- Receive Ports - PRBS Detection ---------------------
    GT3_RXPRBSCNTRESET_IN                   => '0',
    GT3_RXPRBSERR_OUT                       => open,
    GT3_RXPRBSSEL_IN                        => "000",
    ------------------- Receive Ports - RX Data Path interface -----------------
    GT3_GTRXRESET_IN                        => mgt_rx_reset,
    GT3_RXDATA_OUT                          => mgt_rxdata(63 downto 48),
    GT3_RXOUTCLK_OUT                        => open,    
    GT3_RXPCSRESET_IN                       => '0',
    GT3_RXUSRCLK_IN                         => clk156,
    GT3_RXUSRCLK2_IN                        => clk156,
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GT3_GTXRXN_IN                           => xaui_rx_l3_n,
    GT3_GTXRXP_IN                           => xaui_rx_l3_p,
    GT3_RXCDRLOCK_OUT                       => open,
    GT3_RXELECIDLE_OUT                      => open,
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    GT3_RXBUFRESET_IN                       => mgt_rxbuf_reset(3),
    GT3_RXBUFSTATUS_OUT                     => mgt_rxbufstatus(11 downto 9),
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GT3_RXRESETDONE_OUT                     => mgt_rxresetdone(3),
    ------------------------------- Transmit Ports -----------------------------
    GT3_TXPOSTCURSOR_IN                     => "00000",
    GT3_TXPRECURSOR_IN                      => "00000",
    GT3_TXUSERRDY_IN                        => mgt_txuserrdy,
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GT3_TXCHARISK_IN                        => mgt_txcharisk(7 downto 6),
    ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
    GT3_TXDLYEN_IN                          => '0',
    GT3_TXDLYSRESET_IN                      => s_gt_txdlysreset(2),
    GT3_TXDLYSRESETDONE_OUT                 => s_gt_txdlysresetdone(2),
    GT3_TXPHALIGN_IN                        => s_gt_txphalign(2),
    GT3_TXPHALIGNDONE_OUT                   => s_gt_txphaligndone(2),
    GT3_TXPHALIGNEN_IN                      => '1',
    GT3_TXPHDLYRESET_IN                     => '0',
    GT3_TXPHINIT_IN                         => s_gt_txphinit(2),
    GT3_TXPHINITDONE_OUT                    => s_gt_txphinitdone(2),
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT3_GTTXRESET_IN                        => mgt_tx_reset,
    GT3_TXDATA_IN                           => mgt_txdata(63 downto 48),
    GT3_TXOUTCLK_OUT                        => open,
    GT3_TXOUTCLKFABRIC_OUT                  => open,
    GT3_TXOUTCLKPCS_OUT                     => open,
    GT3_TXPCSRESET_IN                       => '0',
    GT3_TXUSRCLK_IN                         => clk156,
    GT3_TXUSRCLK2_IN                        => clk156,
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GT3_GTXTXN_OUT                          => xaui_tx_l3_n,
    GT3_GTXTXP_OUT                          => xaui_tx_l3_p,
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GT3_TXRESETDONE_OUT                     => mgt_txresetdone(3),
    --------------------- Transmit Ports - TX PRBS Generator -------------------
    GT3_TXPRBSFORCEERR_IN                   => '0',
    GT3_TXPRBSSEL_IN                        => "000",
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    GT3_TXELECIDLE_IN                       => mgt_powerdown_r,
    --____________________________COMMON PORTS________________________________
    ---------------------- Common Block  - Ref Clock Ports ---------------------
    GT0_GTREFCLK0_COMMON_IN                 => refclk,
    ------------------------- Common Block - QPLL Ports ------------------------
    GT0_QPLLLOCK_OUT                        => mgt_plllocked,
    GT0_QPLLLOCKDETCLK_IN                   => dclk,
    GT0_QPLLREFCLKLOST_OUT                  => open,
    GT0_QPLLRESET_IN                        => pll_reset
    );

  mgt_codecomma_reg <= (mgt_codecomma_reg7 & mgt_codecomma_reg6 & mgt_codecomma_reg5 & mgt_codecomma_reg4 & mgt_codecomma_reg3 & mgt_codecomma_reg2 & mgt_codecomma_reg1 & mgt_codecomma_reg0);
  mgt_rxcharisk_reg <= (mgt_rxcharisk_reg7 & mgt_rxcharisk_reg6 & mgt_rxcharisk_reg5 & mgt_rxcharisk_reg4 & mgt_rxcharisk_reg3 & mgt_rxcharisk_reg2 & mgt_rxcharisk_reg1 & mgt_rxcharisk_reg0);

  txoutclk <= gt0_txoutclk_i;
  sync_status      <= sync_status_i;
  align_status     <= align_status_i;
  txlock           <= txlock_i;
  mgt_codevalid    <= not ((mgt_rxnotintable_reg7 & mgt_rxnotintable_reg6 & mgt_rxnotintable_reg5 & mgt_rxnotintable_reg4 & mgt_rxnotintable_reg3 & mgt_rxnotintable_reg2 & mgt_rxnotintable_reg1 & mgt_rxnotintable_reg0) or (mgt_rxdisperr_reg7 & mgt_rxdisperr_reg6 & mgt_rxdisperr_reg5 & mgt_rxdisperr_reg4 & mgt_rxdisperr_reg3 & mgt_rxdisperr_reg2 & mgt_rxdisperr_reg1 & mgt_rxdisperr_reg0));
  loopback_int     <= "010" when mgt_loopback = '1' else "000";
  mgt_powerdown_2  <= mgt_powerdown_r & mgt_powerdown_r;
  mgt_txuserrdy    <= mmcm_lock;
  mgt_rxuserrdy    <= mmcm_lock;
  mgt_syncok       <= "1111";
  mgt_tx_ready     <= phase_align_complete;

  -- Detect falling edge of mgt_powerdown
  p_powerdown_r : process(clk156)
  begin
    if rising_edge(clk156) then
      mgt_powerdown_r <= mgt_powerdown;
    end if;
  end process;

  p_powerdown_falling : process(clk156, reset156)
  begin
    if (reset156 = '1') then
        mgt_powerdown_falling <= '0';
    elsif rising_edge(clk156) then
      if mgt_powerdown_r = '1' and mgt_powerdown = '0' then
        mgt_powerdown_falling <= '1';
      else
        mgt_powerdown_falling <= '0';
      end if;
    end if;
  end process;

  RXBUFERR_P: process (mgt_rxbufstatus_reg)
  begin
    for i in 0 to 3 loop
      mgt_rxbuferr(i) <= IsBufError(mgt_rxbufstatus_reg(i*3+2 downto i*3));
    end loop;
  end process;

  -- reset logic - Implement counter to hold resets for 500 ns after GSR
  -- This counter is based on a 50MHz DCLK - modify as appropriate for your design
  process(dclk) begin
    if rising_edge(dclk) then
      if (reset_count_done = '0') then
	    reset_counter <= reset_counter(RESET_COUNT_LENGTH-2 downto 0) & '1';
      end if;
    end if;
  end process;
  
  process(dclk) begin
    if rising_edge(dclk) then
	  reset_count_done <= reset_counter(RESET_COUNT_LENGTH-1);
	end if;
  end process;
  
  process(dclk) begin
    if rising_edge(dclk) then
	  if (reset_count_done = '0' and reset_counter(RESET_COUNT_LENGTH-1) = '1') then
	    first_reset <= '1';
      else
	    first_reset <= '0';
	  end if;
	end if;
  end process;

  -- sync timeout counter. GT requires a reset if the far end powers down.
  process (clk156) begin
    if rising_edge(clk156) then
      if (sync_counter(SYNC_COUNT_LENGTH - 1) = '1') then
        sync_counter <= (others => '0');
      elsif (sync_status_i /= "1111") then
        sync_counter <= sync_counter + 1;
      else
        sync_counter <= (others => '0');
      end if;
    end if;
  end process;

  -- reset logic
  txlock_i     <= mgt_plllocked;
  mgt_tx_fault <= "1111" when phase_align_complete = '0' else "0000";
  pll_reset    <= (reset and reset_count_done) or first_reset;
  mgt_rx_reset <= (cbm_rx_reset or reset156 or (not txlock_i) or mgt_powerdown_falling or sync_counter(SYNC_COUNT_LENGTH - 1)) and reset_count_done;
  mgt_tx_reset <= (reset156 or (not txlock_i) or mgt_powerdown_falling) and reset_count_done;

  -- reset the rx side when the buffer overflows / underflows or on a falling
  -- edge of powerdown
  process (clk156)
  begin
    if rising_edge(clk156) then
      if mgt_rxbuferr /= "0000" and mgt_rxresetdone_reg = "1111" then
        mgt_rxbuf_reset <= "1111";
      else
        mgt_rxbuf_reset <= "0000";
      end if;
    end if;
  end process;

  p_mgt_reg : process(clk156)
  begin
    if rising_edge(clk156) then
        mgt_rxlock_reg       <= mgt_rxlock_r1;
        mgt_rxlock_r1        <= mgt_plllocked & mgt_plllocked & mgt_plllocked & mgt_plllocked;
        mgt_rxdata_reg       <= mgt_rxdata;
        mgt_rxcharisk_reg0    <= mgt_rxcharisk(0);
        mgt_rxcharisk_reg1    <= mgt_rxcharisk(1);
        mgt_rxcharisk_reg2    <= mgt_rxcharisk(2);
        mgt_rxcharisk_reg3    <= mgt_rxcharisk(3);
        mgt_rxcharisk_reg4    <= mgt_rxcharisk(4);
        mgt_rxcharisk_reg5    <= mgt_rxcharisk(5);
        mgt_rxcharisk_reg6    <= mgt_rxcharisk(6);
        mgt_rxcharisk_reg7    <= mgt_rxcharisk(7);
        mgt_rxnotintable_reg0 <= mgt_rxnotintable(0);
        mgt_rxnotintable_reg1 <= mgt_rxnotintable(1);
        mgt_rxnotintable_reg2 <= mgt_rxnotintable(2);
        mgt_rxnotintable_reg3 <= mgt_rxnotintable(3);
        mgt_rxnotintable_reg4 <= mgt_rxnotintable(4);
        mgt_rxnotintable_reg5 <= mgt_rxnotintable(5);
        mgt_rxnotintable_reg6 <= mgt_rxnotintable(6);
        mgt_rxnotintable_reg7 <= mgt_rxnotintable(7);
        mgt_rxdisperr_reg0    <= mgt_rxdisperr(0);
        mgt_rxdisperr_reg1    <= mgt_rxdisperr(1);
        mgt_rxdisperr_reg2    <= mgt_rxdisperr(2);
        mgt_rxdisperr_reg3    <= mgt_rxdisperr(3);
        mgt_rxdisperr_reg4    <= mgt_rxdisperr(4);
        mgt_rxdisperr_reg5    <= mgt_rxdisperr(5);
        mgt_rxdisperr_reg6    <= mgt_rxdisperr(6);
        mgt_rxdisperr_reg7    <= mgt_rxdisperr(7);
        mgt_codecomma_reg0    <= mgt_rxchariscomma(0);
        mgt_codecomma_reg1    <= mgt_rxchariscomma(1);
        mgt_codecomma_reg2    <= mgt_rxchariscomma(2);
        mgt_codecomma_reg3    <= mgt_rxchariscomma(3);
        mgt_codecomma_reg4    <= mgt_rxchariscomma(4);
        mgt_codecomma_reg5    <= mgt_rxchariscomma(5);
        mgt_codecomma_reg6    <= mgt_rxchariscomma(6);
        mgt_codecomma_reg7    <= mgt_rxchariscomma(7);
        mgt_rxchanisaligned_r <= mgt_rxchanisaligned;
        mgt_rxbufstatus_reg   <= mgt_rxbufstatus;
        mgt_txresetdone_reg   <= mgt_txresetdone;
        mgt_enchansync_reg    <= mgt_enchansync;
        mgt_rxresetdone_reg   <= mgt_rxresetdone;
    end if;
  end process p_mgt_reg;

  comma_align_done <= '1' when sync_status_i = "1111" else '0';

  chanbond_monitor_i : zynq_xaui_chanbond_monitor
  port map (
    CLK                 => clk156,
    RST                 => reset156,
    COMMA_ALIGN_DONE    => comma_align_done,
    CORE_ENCHANSYNC     => mgt_enchansync_reg,
    CHANBOND_DONE       => align_status_i,
    RXRESET             => cbm_rx_reset
  );

    --------------------------- TX Buffer Bypass Logic --------------------
    -- The TX SYNC Module drives the ports needed to Bypass the TX Buffer.
   txsync_i : zynq_xaui_gt_wrapper_tx_sync_manual
   generic map
   ( NUM_SLAVES	  => 3 )
   port map
   (
        M_GT_TXUSRCLK                   =>      clk156,
        M_GT_TXRESETDONE                =>      mgt_txresetdone_reg(0),
        M_GT_TXDLYSRESET                =>      m_gt_txdlysreset,
        M_GT_TXDLYSRESETDONE            =>      m_gt_txdlysresetdone,
        M_GT_TXPHINIT                   =>      m_gt_txphinit,
        M_GT_TXPHINITDONE               =>      m_gt_txphinitdone,
        M_GT_TXDLYEN                    =>      m_gt_txdlyen,
        M_GT_TXPHALIGN                  =>      m_gt_txphalign,
        M_GT_TXPHALIGNDONE              =>      m_gt_txphaligndone,
        START                           =>      txsync_start_phase_align(0),
        PHASE_ALIGN_COMPLETE            =>      phase_align_complete,
        S_GT_TXDLYSRESET                =>      s_gt_txdlysreset,
        S_GT_TXDLYSRESETDONE            =>      s_gt_txdlysresetdone,
        S_GT_TXPHINIT                   =>      s_gt_txphinit,
        S_GT_TXPHINITDONE               =>      s_gt_txphinitdone,
        S_GT_TXPHALIGN                  =>      s_gt_txphalign,
        S_GT_TXPHALIGNDONE              =>      s_gt_txphaligndone
   );

    process( clk156, mgt_txresetdone_reg(0)) begin
      if( mgt_txresetdone_reg(0) = '0') then
        txsync_start_phase_align <= "10";
      elsif(rising_edge(clk156)) then
	    if (reset_count_done = '1') then
          txsync_start_phase_align(0) <=  txsync_start_phase_align(1);
          txsync_start_phase_align(1) <=  '0';
		end if;
      end if;
    end process;
end wrapper;
