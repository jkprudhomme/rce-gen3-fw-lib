-------------------------------------------------------------------------------
--
-- (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
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
--
-------------------------------------------------------------------------------
-- Project    : Series-7 Integrated Block for PCI Express
-- File       : xilinx_pcie_2_1_ep_7x.vhd
-- Version    : 1.9
--
-- Description:  PCI Express Endpoint example FPGA design
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity xilinx_pcie_2_1_ep_7x is
  generic (
  REF_CLK_FREQ                  : integer    := 0;                                   -- 0 - 100 MHz, 1 - 125 MHz,  2 - 250 MHz
  PCIE_EXT_CLK                  : string     := "FALSE"; -- Use External Clocking Module
  PL_FAST_TRAIN                 : string     := "FALSE";
  ALLOW_X8_GEN2                 : string     := "FALSE";
  C_DATA_WIDTH                  : integer    := 64;
  LINK_CAP_MAX_LINK_WIDTH       : bit_vector := X"08";
  DEVICE_ID                     : bit_vector := X"506F";
  LINK_CAP_MAX_LINK_SPEED       : bit_vector := X"1";
  LINK_CTRL2_TARGET_LINK_SPEED  : bit_vector := X"1";
  DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer    := 1;
  USER_CLK_FREQ                 : integer    := 3;
  USER_CLK2_DIV2                : string     := "FALSE";
  TRN_DW                        : string     := "FALSE";
  VC0_TX_LASTPACKET             : integer    := 28;
  VC0_RX_RAM_LIMIT              : bit_vector := X"03ff";
  VC0_CPL_INFINITE              : string     := "TRUE";
  VC0_TOTAL_CREDITS_PD          : integer    := 154;
  VC0_TOTAL_CREDITS_CD          : integer    := 154;
  LINK_CAP_MAX_LINK_WIDTH_int   : integer    := 8;
  LINK_CAP_MAX_LINK_SPEED_int   : integer    := 1
  );
  port (
  pci_exp_txp                   : out std_logic_vector(0 downto 0);
  pci_exp_txn                   : out std_logic_vector(0 downto 0);
  pci_exp_rxp                   : in std_logic_vector(0 downto 0);
  pci_exp_rxn                   : in std_logic_vector(0 downto 0);

  sys_clk_p                     : in std_logic;
  sys_clk_n                     : in std_logic;
  sys_rst_n                     : in std_logic

);
end xilinx_pcie_2_1_ep_7x;

architecture rtl of xilinx_pcie_2_1_ep_7x is



  component pcie_2_1_ep_7x
    generic (

    REF_CLK_FREQ                  : integer                 := 0;
    PCIE_EXT_CLK                  : string                  := "FALSE";
    PL_FAST_TRAIN                 : string                  := "TRUE";
    ALLOW_X8_GEN2                 : string                  := "FALSE";
    C_DATA_WIDTH                  : integer range 64 to 128 := 64;
    LINK_CAP_MAX_LINK_WIDTH       : bit_vector              := X"08";
    LINK_CAP_MAX_LINK_SPEED       : bit_vector              := X"1";
    LINK_CTRL2_TARGET_LINK_SPEED  : bit_vector              := X"1";
    DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer                 := 2;
    USER_CLK_FREQ                 : integer                 := 1;
    USER_CLK2_DIV2                : string                  := "FALSE";
    TRN_DW                        : string                  := "FALSE";
    VC0_TX_LASTPACKET             : integer                 := 29;
    VC0_RX_RAM_LIMIT              : bit_vector              := X"7FF";
    VC0_CPL_INFINITE              : string                  := "TRUE";
    VC0_TOTAL_CREDITS_PD          : integer                 := 437;
    VC0_TOTAL_CREDITS_CD          : integer                 := 461;
    LINK_CAP_MAX_LINK_WIDTH_int   : integer                 := 8;
    LINK_CAP_MAX_LINK_SPEED_int   : integer                 := 1
    );
    port (
     -------------------------------------------------------------------------------------------------------------------
     -- 1. PCI Express (pci_exp) Interface                                                                            --
     -------------------------------------------------------------------------------------------------------------------
      pci_exp_txp                                : out std_logic_vector(0 downto 0);
      pci_exp_txn                                : out std_logic_vector(0 downto 0);
      pci_exp_rxp                                : in std_logic_vector(0 downto 0);
      pci_exp_rxn                                : in std_logic_vector(0 downto 0);

     -------------------------------------------------------------------------------------------------------------------
     -- 2. Clocking Interface                                                                                         --
     -------------------------------------------------------------------------------------------------------------------
      PIPE_PCLK_IN                               : in std_logic;
      PIPE_RXUSRCLK_IN                           : in std_logic;
      PIPE_RXOUTCLK_IN                           : in std_logic_vector(0 downto 0);
      PIPE_DCLK_IN                               : in std_logic;
      PIPE_USERCLK1_IN                           : in std_logic;
      PIPE_USERCLK2_IN                           : in std_logic;
      PIPE_OOBCLK_IN                             : in std_logic;
      PIPE_MMCM_LOCK_IN                          : in std_logic;

      PIPE_TXOUTCLK_OUT                          : out std_logic;
      PIPE_RXOUTCLK_OUT                          : out std_logic_vector(0 downto 0);
      PIPE_PCLK_SEL_OUT                          : out std_logic_vector(0 downto 0);
      PIPE_GEN3_OUT                              : out std_logic;

     -------------------------------------------------------------------------------------------------------------------
     -- 3. AXI-S Interface                                                                                            --
     -------------------------------------------------------------------------------------------------------------------
      -- Common
      user_clk_out                               : out std_logic;
      user_reset_out                             : out std_logic;
      user_lnk_up                                : out std_logic;

      -- TX
      tx_buf_av                                  : out std_logic_vector(5 downto 0);
      tx_cfg_req                                 : out std_logic;
      tx_err_drop                                : out std_logic;
      s_axis_tx_tready                           : out std_logic;
      s_axis_tx_tdata                            : in std_logic_vector((C_DATA_WIDTH - 1) downto 0);
      s_axis_tx_tkeep                            : in std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
      s_axis_tx_tlast                            : in std_logic;
      s_axis_tx_tvalid                           : in std_logic;
      s_axis_tx_tuser                            : in std_logic_vector(3 downto 0);
      tx_cfg_gnt                                 : in std_logic;

      -- RX
      m_axis_rx_tdata                            : out std_logic_vector((C_DATA_WIDTH - 1) downto 0);
      m_axis_rx_tkeep                            : out std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
      m_axis_rx_tlast                            : out std_logic;
      m_axis_rx_tvalid                           : out std_logic;
      m_axis_rx_tready                           : in std_logic;
      m_axis_rx_tuser                            : out std_logic_vector(21 downto 0);
      rx_np_ok                                   : in std_logic;
      rx_np_req                                  : in std_logic;

      -- Flow Control
      fc_cpld                                    : out std_logic_vector(11 downto 0);
      fc_cplh                                    : out std_logic_vector(7 downto 0);
      fc_npd                                     : out std_logic_vector(11 downto 0);
      fc_nph                                     : out std_logic_vector(7 downto 0);
      fc_pd                                      : out std_logic_vector(11 downto 0);
      fc_ph                                      : out std_logic_vector(7 downto 0);
      fc_sel                                     : in std_logic_vector(2 downto 0);

     -------------------------------------------------------------------------------------------------------------------
     -- 4. Configuration (CFG) Interface                                                                              --
     -------------------------------------------------------------------------------------------------------------------
     ---------------------------------------------------------------------
      -- EP and RP                                                      --
     ---------------------------------------------------------------------
      cfg_mgmt_do                                : out std_logic_vector (31 downto 0);
      cfg_mgmt_rd_wr_done                        : out std_logic;

      cfg_status                                 : out std_logic_vector(15 downto 0);
      cfg_command                                : out std_logic_vector(15 downto 0);
      cfg_dstatus                                : out std_logic_vector(15 downto 0);
      cfg_dcommand                               : out std_logic_vector(15 downto 0);
      cfg_lstatus                                : out std_logic_vector(15 downto 0);
      cfg_lcommand                               : out std_logic_vector(15 downto 0);
      cfg_dcommand2                              : out std_logic_vector(15 downto 0);
      cfg_pcie_link_state                        : out std_logic_vector(2 downto 0);

      cfg_pmcsr_pme_en                           : out std_logic;
      cfg_pmcsr_powerstate                       : out std_logic_vector(1 downto 0);
      cfg_pmcsr_pme_status                       : out std_logic;
      cfg_received_func_lvl_rst                  : out std_logic;

      -- Management Interface
      cfg_mgmt_di                                : in std_logic_vector (31 downto 0);
      cfg_mgmt_byte_en                           : in std_logic_vector (3 downto 0);
      cfg_mgmt_dwaddr                            : in std_logic_vector (9 downto 0);
      cfg_mgmt_wr_en                             : in std_logic;
      cfg_mgmt_rd_en                             : in std_logic;
      cfg_mgmt_wr_readonly                       : in std_logic;

      -- Error Reporting Interface
      cfg_err_ecrc                               : in std_logic;
      cfg_err_ur                                 : in std_logic;
      cfg_err_cpl_timeout                        : in std_logic;
      cfg_err_cpl_unexpect                       : in std_logic;
      cfg_err_cpl_abort                          : in std_logic;
      cfg_err_posted                             : in std_logic;
      cfg_err_cor                                : in std_logic;
      cfg_err_atomic_egress_blocked              : in std_logic;
      cfg_err_internal_cor                       : in std_logic;
      cfg_err_malformed                          : in std_logic;
      cfg_err_mc_blocked                         : in std_logic;
      cfg_err_poisoned                           : in std_logic;
      cfg_err_norecovery                         : in std_logic;
      cfg_err_tlp_cpl_header                     : in std_logic_vector(47 downto 0);
      cfg_err_cpl_rdy                            : out std_logic;
      cfg_err_locked                             : in std_logic;
      cfg_err_acs                                : in std_logic;
      cfg_err_internal_uncor                     : in std_logic;
      cfg_trn_pending                            : in std_logic;
      cfg_pm_halt_aspm_l0s                       : in std_logic;
      cfg_pm_halt_aspm_l1                        : in std_logic;
      cfg_pm_force_state_en                      : in std_logic;
      cfg_pm_force_state                         : std_logic_vector(1 downto 0);
      cfg_dsn                                    : std_logic_vector(63 downto 0);

     ---------------------------------------------------------------------
      -- EP Only                                                        --
     ---------------------------------------------------------------------
      cfg_interrupt                              : in std_logic;
      cfg_interrupt_rdy                          : out std_logic;
      cfg_interrupt_assert                       : in std_logic;
      cfg_interrupt_di                           : in std_logic_vector(7 downto 0);
      cfg_interrupt_do                           : out std_logic_vector(7 downto 0);
      cfg_interrupt_mmenable                     : out std_logic_vector(2 downto 0);
      cfg_interrupt_msienable                    : out std_logic;
      cfg_interrupt_msixenable                   : out std_logic;
      cfg_interrupt_msixfm                       : out std_logic;
      cfg_interrupt_stat                         : in std_logic;
      cfg_pciecap_interrupt_msgnum               : in std_logic_vector(4 downto 0);
      cfg_to_turnoff                             : out std_logic;
      cfg_turnoff_ok                             : in std_logic;
      cfg_bus_number                             : out std_logic_vector(7 downto 0);
      cfg_device_number                          : out std_logic_vector(4 downto 0);
      cfg_function_number                        : out std_logic_vector(2 downto 0);
      cfg_pm_wake                                : in std_logic;

     ---------------------------------------------------------------------
      -- RP Only                                                        --
     ---------------------------------------------------------------------
      cfg_pm_send_pme_to                         : in std_logic;
      cfg_ds_bus_number                          : in std_logic_vector(7 downto 0);
      cfg_ds_device_number                       : in std_logic_vector(4 downto 0);
      cfg_ds_function_number                     : in std_logic_vector(2 downto 0);

      cfg_mgmt_wr_rw1c_as_rw                     : in std_logic;
      cfg_msg_received                           : out std_logic;
      cfg_msg_data                               : out std_logic_vector(15 downto 0);

      cfg_bridge_serr_en                         : out std_logic;
      cfg_slot_control_electromech_il_ctl_pulse  : out std_logic;
      cfg_root_control_syserr_corr_err_en        : out std_logic;
      cfg_root_control_syserr_non_fatal_err_en   : out std_logic;
      cfg_root_control_syserr_fatal_err_en       : out std_logic;
      cfg_root_control_pme_int_en                : out std_logic;
      cfg_aer_rooterr_corr_err_reporting_en      : out std_logic;
      cfg_aer_rooterr_non_fatal_err_reporting_en : out std_logic;
      cfg_aer_rooterr_fatal_err_reporting_en     : out std_logic;
      cfg_aer_rooterr_corr_err_received          : out std_logic;
      cfg_aer_rooterr_non_fatal_err_received     : out std_logic;
      cfg_aer_rooterr_fatal_err_received         : out std_logic;

      cfg_msg_received_err_cor                   : out std_logic;
      cfg_msg_received_err_non_fatal             : out std_logic;
      cfg_msg_received_err_fatal                 : out std_logic;
      cfg_msg_received_pm_as_nak                 : out std_logic;
      cfg_msg_received_pm_pme                    : out std_logic;
      cfg_msg_received_pme_to_ack                : out std_logic;
      cfg_msg_received_assert_int_a              : out std_logic;
      cfg_msg_received_assert_int_b              : out std_logic;
      cfg_msg_received_assert_int_c              : out std_logic;
      cfg_msg_received_assert_int_d              : out std_logic;
      cfg_msg_received_deassert_int_a            : out std_logic;
      cfg_msg_received_deassert_int_b            : out std_logic;
      cfg_msg_received_deassert_int_c            : out std_logic;
      cfg_msg_received_deassert_int_d            : out std_logic;
      cfg_msg_received_setslotpowerlimit         : out std_logic;

     -------------------------------------------------------------------------------------------------------------------
     -- 5. Physical Layer Control and Status (PL) Interface                                                           --
     -------------------------------------------------------------------------------------------------------------------
      pl_directed_link_change                    : in std_logic_vector(1 downto 0);
      pl_directed_link_width                     : in std_logic_vector(1 downto 0);
      pl_directed_link_speed                     : in std_logic;
      pl_directed_link_auton                     : in std_logic;
      pl_upstream_prefer_deemph                  : in std_logic;

      pl_sel_lnk_rate                            : out std_logic;
      pl_sel_lnk_width                           : out std_logic_vector(1 downto 0);
      pl_ltssm_state                             : out std_logic_vector(5 downto 0);
      pl_lane_reversal_mode                      : out std_logic_vector(1 downto 0);

      pl_phy_lnk_up                              : out std_logic;
      pl_tx_pm_state                             : out std_logic_vector(2 downto 0);
      pl_rx_pm_state                             : out std_logic_vector(1 downto 0);

      pl_link_upcfg_cap                          : out std_logic;
      pl_link_gen2_cap                           : out std_logic;
      pl_link_partner_gen2_supported             : out std_logic;
      pl_initial_link_width                      : out std_logic_vector(2 downto 0);

      pl_directed_change_done                    : out std_logic;

     ---------------------------------------------------------------------
      -- EP Only                                                        --
     ---------------------------------------------------------------------
      pl_received_hot_rst                        : out std_logic;
     ---------------------------------------------------------------------
      -- RP Only                                                        --
     ---------------------------------------------------------------------
      pl_transmit_hot_rst                        : in std_logic;
      pl_downstream_deemph_source                : in std_logic;
     -------------------------------------------------------------------------------------------------------------------
     -- 6. AER interface                                                                                              --
     -------------------------------------------------------------------------------------------------------------------
      cfg_err_aer_headerlog                      : in std_logic_vector(127 downto 0);
      cfg_aer_interrupt_msgnum                   : in std_logic_vector(4 downto 0);
      cfg_err_aer_headerlog_set                  : out std_logic;
      cfg_aer_ecrc_check_en                      : out std_logic;
      cfg_aer_ecrc_gen_en                        : out std_logic;
     -------------------------------------------------------------------------------------------------------------------
     -- 7. VC interface                                                                                               --
     -------------------------------------------------------------------------------------------------------------------
      cfg_vc_tcvc_map                            : out std_logic_vector(6 downto 0);

     -------------------------------------------------------------------------------------------------------------------
     -- 8. System(SYS) Interface                                                                                      --
     -------------------------------------------------------------------------------------------------------------------
      PIPE_MMCM_RST_N                            : in std_logic;   --     // Async      | Async
      sys_clk                                    : in std_logic;
      sys_rst_n                                  : in std_logic);
  end component;

  component pcie_app_7x
    generic (
      C_DATA_WIDTH : integer range 64 to 128 := 64;
  --    KEEP_WIDTH   : integer range 8 to 16   := C_DATA_WIDTH / 8
      TCQ          : time                    := 1 ps
    );
    port  (
      user_clk                       : in std_logic;
      user_reset                     : in std_logic;
      user_lnk_up                    : in std_logic;
      s_axis_tx_tdata                : out std_logic_vector((C_DATA_WIDTH - 1) downto 0);
      s_axis_tx_tkeep                : out std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
      s_axis_tx_tlast                : out std_logic;
      s_axis_tx_tvalid               : out std_logic;
      s_axis_tx_tready               : in std_logic;
      s_axis_tx_tuser                : out std_logic_vector(3 downto 0);
      tx_cfg_req                     : in std_logic;
      tx_cfg_gnt                     : out std_logic;
      tx_err_drop                    : in std_logic;
      tx_buf_av                      : in std_logic_vector(5 downto 0);
      m_axis_rx_tdata                : in std_logic_vector((C_DATA_WIDTH - 1) downto 0);
      m_axis_rx_tkeep                : in std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
      m_axis_rx_tlast                : in std_logic;
      m_axis_rx_tvalid               : in std_logic;
      m_axis_rx_tready               : out std_logic;
      m_axis_rx_tuser                : in std_logic_vector(21 downto 0);
      rx_np_ok                       : out std_logic;
      rx_np_req                      : out std_logic;
      fc_nph                         : in std_logic_vector(7 downto 0);
      fc_npd                         : in std_logic_vector(11 downto 0);
      fc_ph                          : in std_logic_vector(7 downto 0);
      fc_pd                          : in std_logic_vector(11 downto 0);
      fc_cplh                        : in std_logic_vector(7 downto 0);
      fc_cpld                        : in std_logic_vector(11 downto 0);
      fc_sel                         : out std_logic_vector(2 downto 0);
      cfg_err_cor                    : out std_logic;
      cfg_err_ur                     : out std_logic;
      cfg_err_cpl_rdy                : in std_logic;
      cfg_err_ecrc                   : out std_logic;
      cfg_err_cpl_timeout            : out std_logic;
      cfg_err_cpl_abort              : out std_logic;
      cfg_err_cpl_unexpect           : out std_logic;
      cfg_err_posted                 : out std_logic;
      cfg_err_locked                 : out std_logic;
      cfg_err_atomic_egress_blocked  : out std_logic;
      cfg_err_internal_cor           : out std_logic;
      cfg_err_malformed              : out std_logic;
      cfg_err_mc_blocked             : out std_logic;
      cfg_err_poisoned               : out std_logic;
      cfg_err_norecovery             : out std_logic;
      cfg_err_acs                    : out std_logic;
      cfg_err_internal_uncor         : out std_logic;
      cfg_err_aer_headerlog          : out std_logic_vector(127 downto 0);
      cfg_aer_interrupt_msgnum       : out std_logic_vector(4 downto 0);
      cfg_err_aer_headerlog_set      : in  std_logic;
      cfg_aer_ecrc_check_en          : in  std_logic;
      cfg_aer_ecrc_gen_en            : in  std_logic;
      cfg_interrupt                  : out std_logic;
      cfg_interrupt_rdy              : in std_logic;
      cfg_interrupt_assert           : out std_logic;
      cfg_interrupt_di               : out std_logic_vector(7 downto 0);
      cfg_interrupt_do               : in  std_logic_vector(7 downto 0);
      cfg_interrupt_mmenable         : in  std_logic_vector(2 downto 0);
      cfg_interrupt_msienable        : in  std_logic;
      cfg_interrupt_msixenable       : in  std_logic;
      cfg_interrupt_msixfm           : in  std_logic;
      cfg_interrupt_stat             : out std_logic;
      cfg_pciecap_interrupt_msgnum   : out std_logic_vector( 4 downto 0);
      cfg_turnoff_ok                 : out std_logic;
      cfg_to_turnoff                 : in std_logic;
      cfg_pm_wake                    : out std_logic;
      cfg_pm_force_state_en          : out std_logic;
      cfg_pm_force_state             : out std_logic_vector( 1 downto 0);
      cfg_pm_halt_aspm_l0s           : out std_logic;
      cfg_pm_halt_aspm_l1            : out std_logic;
      cfg_pcie_link_state            : in std_logic_vector(2 downto 0);
      cfg_trn_pending                : out std_logic;
      cfg_err_tlp_cpl_header         : out std_logic_vector(47 downto 0);
      cfg_bus_number                 : in std_logic_vector(7 downto 0);
      cfg_device_number              : in std_logic_vector(4 downto 0);
      cfg_function_number            : in std_logic_vector(2 downto 0);
      cfg_status                     : in std_logic_vector(15 downto 0);
      cfg_command                    : in std_logic_vector(15 downto 0);
      cfg_dstatus                    : in std_logic_vector(15 downto 0);
      cfg_dcommand                   : in std_logic_vector(15 downto 0);
      cfg_lstatus                    : in std_logic_vector(15 downto 0);
      cfg_lcommand                   : in std_logic_vector(15 downto 0);
      cfg_dcommand2                  : in std_logic_vector(15 downto 0);
      cfg_mgmt_di                    : out std_logic_vector(31 downto 0);
      cfg_mgmt_byte_en               : out std_logic_vector( 3 downto 0);
      cfg_mgmt_dwaddr                : out std_logic_vector( 9 downto 0);
      cfg_mgmt_wr_en                 : out std_logic;
      cfg_mgmt_rd_en                 : out std_logic;
      cfg_mgmt_wr_readonly           : out std_logic;
      pl_directed_link_change        : out std_logic_vector(1 downto 0);
      pl_ltssm_state                 : in std_logic_vector(5 downto 0);
      pl_directed_link_width         : out std_logic_vector(1 downto 0);
      pl_directed_link_speed         : out std_logic;
      pl_directed_link_auton         : out std_logic;
      pl_upstream_prefer_deemph      : out std_logic;
      pl_sel_lnk_width               : in std_logic_vector(1 downto 0);
      pl_sel_lnk_rate                : in std_logic;
      pl_link_gen2_cap               : in std_logic;
      pl_link_partner_gen2_supported : in std_logic;
      pl_initial_link_width          : in std_logic_vector(2 downto 0);
      pl_link_upcfg_cap              : in std_logic;
      pl_lane_reversal_mode          : in std_logic_vector(1 downto 0);
      pl_received_hot_rst            : in std_logic;
      cfg_dsn                        : out std_logic_vector(63 downto 0));
  end component;

  component pcie_7x_v1_9_pipe_clock
    generic (
          PCIE_ASYNC_EN                : string  :=   "FALSE";     -- PCIe async enable
          PCIE_TXBUF_EN                : string  :=   "FALSE";     -- PCIe TX buffer enable for Gen1/Gen2 only
          PCIE_LANE                    : integer :=   1;           -- PCIe number of lanes
          PCIE_LINK_SPEED              : integer :=   3;           -- PCIe link speed
          PCIE_REFCLK_FREQ             : integer :=   0;           -- PCIe reference clock frequency
          PCIE_USERCLK1_FREQ           : integer :=   3;           -- PCIe user clock 1 frequency
          PCIE_USERCLK2_FREQ           : integer :=   3;           -- PCIe user clock 2 frequency
          PCIE_DEBUG_MODE              : integer :=   0            -- PCIe Debug Mode
    );
    port  (

          ------------ Input -------------------------------------
          CLK_CLK                        : in std_logic;
          CLK_TXOUTCLK                   : in std_logic;
          CLK_RXOUTCLK_IN                : in std_logic_vector(0 downto 0);
          CLK_RST_N                      : in std_logic;
          CLK_PCLK_SEL                   : std_logic_vector(0 downto 0);
          CLK_GEN3                       : in std_logic;

          ------------ Output ------------------------------------
          CLK_PCLK                       : out std_logic;
          CLK_RXUSRCLK                   : out std_logic;
          CLK_RXOUTCLK_OUT               : out std_logic_vector(0 downto 0);
          CLK_DCLK                       : out std_logic;
          CLK_USERCLK1                   : out std_logic;
          CLK_USERCLK2                   : out std_logic;
          CLK_OOBCLK                     : out std_logic;
          CLK_MMCM_LOCK                  : out std_logic);
  end component;

  constant TCQ                  : time           := 1 ps;

   function get_userClk2 (
    DIV2   : string;
    UC_FREQ  : integer)
    return integer is
  begin  -- wr_mode
    if (DIV2 = "TRUE") then
      if (UC_FREQ = 4) then
        return 3;
      elsif (UC_FREQ = 3) then
        return 2;
      else
        return UC_FREQ;
      end if;
    else
      return UC_FREQ;
    end if;
  end get_userClk2;

   -- purpose: Determine Link Speed Configuration for GT
   function get_gt_lnk_spd_cfg (
     constant simulation : string)
     return integer is
   begin  -- get_gt_lnk_spd_cfg
     if (simulation = "TRUE") then
       return 2;
     else
       return 3;
     end if;
   end get_gt_lnk_spd_cfg;

  constant USERCLK2_FREQ        : integer := get_userClk2(USER_CLK2_DIV2,USER_CLK_FREQ);
  constant LNK_SPD              : integer := get_gt_lnk_spd_cfg(PL_FAST_TRAIN);

  -- Common
  signal user_lnk_up            : std_logic;
  signal user_lnk_up_q          : std_logic;
  signal user_clk               : std_logic;
  signal user_reset             : std_logic;
  signal user_reset_q           : std_logic;

  -- Tx
  signal tx_buf_av              : std_logic_vector(5 downto 0);
  signal tx_cfg_req             : std_logic;
  signal tx_err_drop            : std_logic;
  signal tx_cfg_gnt             : std_logic;
  signal s_axis_tx_tready       : std_logic;
  signal s_axis_tx_tuser        : std_logic_vector (3 downto 0);
  signal s_axis_tx_tdata        : std_logic_vector((C_DATA_WIDTH - 1) downto 0);
  signal s_axis_tx_tkeep        : std_logic_vector((C_DATA_WIDTH/8 - 1) downto 0);
  signal s_axis_tx_tlast        : std_logic;
  signal s_axis_tx_tvalid       : std_logic;

  -- Rx
  signal m_axis_rx_tdata        : std_logic_vector((C_DATA_WIDTH - 1) downto 0);
  signal m_axis_rx_tkeep        : std_logic_vector((C_DATA_WIDTH/8- 1) downto 0);
  signal m_axis_rx_tlast        : std_logic;
  signal m_axis_rx_tvalid       : std_logic;
  signal m_axis_rx_tready       : std_logic;
  signal m_axis_rx_tuser        : std_logic_vector (21 downto 0);
  signal rx_np_ok               : std_logic;
  signal rx_np_req              : std_logic;

  -- Flow Control
  signal fc_cpld                : std_logic_vector(11 downto 0);
  signal fc_cplh                : std_logic_vector(7 downto 0);
  signal fc_npd                 : std_logic_vector(11 downto 0);
  signal fc_nph                 : std_logic_vector(7 downto 0);
  signal fc_pd                  : std_logic_vector(11 downto 0);
  signal fc_ph                  : std_logic_vector(7 downto 0);
  signal fc_sel                 : std_logic_vector(2 downto 0);

  ---------------------------------------------------------
  -- 3. Configuration (CFG) Interface
  ---------------------------------------------------------
  signal cfg_err_cor                   : std_logic;
  signal cfg_err_ur                    : std_logic;
  signal cfg_err_ecrc                  : std_logic;
  signal cfg_err_cpl_timeout           : std_logic;
  signal cfg_err_cpl_abort             : std_logic;
  signal cfg_err_cpl_unexpect          : std_logic;
  signal cfg_err_posted                : std_logic;
  signal cfg_err_locked                : std_logic;
  signal cfg_err_tlp_cpl_header        : std_logic_vector(47 downto 0);
  signal cfg_err_cpl_rdy               : std_logic;
  signal cfg_err_atomic_egress_blocked : std_logic;
  signal cfg_err_internal_cor          : std_logic;
  signal cfg_err_malformed             : std_logic;
  signal cfg_err_mc_blocked            : std_logic;
  signal cfg_err_poisoned              : std_logic;
  signal cfg_err_norecovery            : std_logic;
  signal cfg_err_acs                   : std_logic;
  signal cfg_err_internal_uncor        : std_logic;
  signal cfg_interrupt                 : std_logic;
  signal cfg_interrupt_rdy             : std_logic;
  signal cfg_interrupt_assert          : std_logic;
  signal cfg_interrupt_di              : std_logic_vector(7 downto 0);
  signal cfg_interrupt_do              : std_logic_vector(7 downto 0);
  signal cfg_interrupt_mmenable        : std_logic_vector(2 downto 0);
  signal cfg_interrupt_msienable       : std_logic;
  signal cfg_interrupt_msixenable      : std_logic;
  signal cfg_interrupt_msixfm          : std_logic;
  signal cfg_interrupt_stat            : std_logic;
  signal cfg_pciecap_interrupt_msgnum  : std_logic_vector(4 downto 0);
  signal cfg_turnoff_ok                : std_logic;
  signal cfg_to_turnoff                : std_logic;
  signal cfg_trn_pending               : std_logic;
  signal cfg_pm_halt_aspm_l0s          : std_logic;
  signal cfg_pm_halt_aspm_l1           : std_logic;
  signal cfg_pm_force_state_en         : std_logic;
  signal cfg_pm_force_state            : std_logic_vector(1 downto 0);
  signal cfg_pm_wake                   : std_logic;
  signal cfg_bus_number                : std_logic_vector(7 downto 0);
  signal cfg_device_number             : std_logic_vector(4 downto 0);
  signal cfg_function_number           : std_logic_vector(2 downto 0);
  signal cfg_status                    : std_logic_vector(15 downto 0);
  signal cfg_command                   : std_logic_vector(15 downto 0);
  signal cfg_dstatus                   : std_logic_vector(15 downto 0);
  signal cfg_dcommand                  : std_logic_vector(15 downto 0);
  signal cfg_lstatus                   : std_logic_vector(15 downto 0);
  signal cfg_lcommand                  : std_logic_vector(15 downto 0);
  signal cfg_dcommand2                 : std_logic_vector(15 downto 0);
  signal cfg_pcie_link_state           : std_logic_vector(2 downto 0);
  signal cfg_dsn                       : std_logic_vector(63 downto 0);
  signal cfg_err_aer_headerlog         : std_logic_vector(127 downto 0);
  signal cfg_aer_interrupt_msgnum      : std_logic_vector(4 downto 0);
  signal cfg_err_aer_headerlog_set     : std_logic;
  signal cfg_aer_ecrc_check_en         : std_logic;
  signal cfg_aer_ecrc_gen_en           : std_logic;

  signal cfg_mgmt_di                   : std_logic_vector(31 downto 0);
  signal cfg_mgmt_byte_en              : std_logic_vector(3 downto 0);
  signal cfg_mgmt_dwaddr               : std_logic_vector(9 downto 0);
  signal cfg_mgmt_wr_en                : std_logic;
  signal cfg_mgmt_rd_en                : std_logic;
  signal cfg_mgmt_wr_readonly          : std_logic;

  ---------------------------------------------------------
  -- 4. Physical Layer Control and Status (PL) Interface
  ---------------------------------------------------------

  signal pl_initial_link_width          : std_logic_vector(2 downto 0);
  signal pl_lane_reversal_mode          : std_logic_vector(1 downto 0);
  signal pl_link_gen2_cap               : std_logic;
  signal pl_link_partner_gen2_supported : std_logic;
  signal pl_link_upcfg_cap              : std_logic;
  signal pl_ltssm_state                 : std_logic_vector(5 downto 0);
  signal pl_received_hot_rst            : std_logic;
  signal pl_sel_lnk_rate                : std_logic;
  signal pl_sel_lnk_width               : std_logic_vector(1 downto 0);
  signal pl_directed_link_auton         : std_logic;
  signal pl_directed_link_change        : std_logic_vector(1 downto 0);
  signal pl_directed_link_speed         : std_logic;
  signal pl_directed_link_width         : std_logic_vector(1 downto 0);
  signal pl_upstream_prefer_deemph      : std_logic;

  signal sys_clk                        : std_logic;
  signal sys_rst_n_c                    : std_logic;
  signal sys_reset_c                    : std_logic;
  signal sys_rst                        : std_logic;

  -- Wires used for external clocking connectivity
  signal PIPE_PCLK_IN                   : std_logic;
  signal PIPE_RXUSRCLK_IN               : std_logic;
  signal PIPE_RXOUTCLK_IN               : std_logic_vector(0 downto 0);
  signal PIPE_DCLK_IN                   : std_logic;
  signal PIPE_USERCLK1_IN               : std_logic;
  signal PIPE_USERCLK2_IN               : std_logic;
  signal PIPE_OOBCLK_IN                 : std_logic;
  signal PIPE_MMCM_LOCK_IN              : std_logic;

  signal PIPE_TXOUTCLK_OUT              : std_logic;
  signal PIPE_RXOUTCLK_OUT              : std_logic_vector(0 downto 0);
  signal PIPE_PCLK_SEL_OUT              : std_logic_vector(0 downto 0);
  signal PIPE_GEN3_OUT                  : std_logic;
  signal PIPE_MMCM_RST_N                : std_logic := '1';
  -------------------------------------------------------
begin

  process(user_clk)
  begin
    if (user_clk'event and user_clk='1') then
      user_reset_q  <= user_reset after TCQ;
      user_lnk_up_q <= user_lnk_up after TCQ;
    end if;
  end process;

  sys_rst     <= not sys_rst_n;
  sys_rst_n_c <= sys_rst_n;


  -- Generate External Clock Module if External Clocking is selected
  ext_clk: if (PCIE_EXT_CLK = "TRUE") generate
  pipe_clock_i : pcie_7x_v1_9_pipe_clock
  generic map(
          PCIE_ASYNC_EN                  => "FALSE",             -- PCIe async enable
          PCIE_TXBUF_EN                  => "FALSE",             -- PCIe TX buffer enable for Gen1/Gen2 only
          PCIE_LANE                      => 1,              -- PCIe number of lanes
          PCIE_LINK_SPEED                => LNK_SPD ,            -- PCIe link speed
          PCIE_REFCLK_FREQ               => 0,             -- PCIe reference clock frequency
          PCIE_USERCLK1_FREQ             => (USER_CLK_FREQ +1),  -- PCIe user clock 1 frequency
          PCIE_USERCLK2_FREQ             => (USERCLK2_FREQ +1),  -- PCIe user clock 2 frequency
          PCIE_DEBUG_MODE                => 0 )                  -- PCIe Debug Mode
  port map(
          ------------ Input -------------------------------------
          CLK_CLK                        => sys_clk,
          CLK_TXOUTCLK                   => PIPE_TXOUTCLK_OUT,       -- Reference clock from lane 0
          CLK_RXOUTCLK_IN                => PIPE_RXOUTCLK_OUT,
        -- CLK_RST_N                      => '1',
          CLK_RST_N                      => PIPE_MMCM_RST_N,
          CLK_PCLK_SEL                   => PIPE_PCLK_SEL_OUT,
          CLK_GEN3                       => PIPE_GEN3_OUT,

          ------------ Output ------------------------------------
          CLK_PCLK                       => PIPE_PCLK_IN,
          CLK_RXUSRCLK                   => PIPE_RXUSRCLK_IN,
          CLK_RXOUTCLK_OUT               => PIPE_RXOUTCLK_IN,
          CLK_DCLK                       => PIPE_DCLK_IN,
          CLK_USERCLK1                   => PIPE_USERCLK1_IN,
          CLK_USERCLK2                   => PIPE_USERCLK2_IN,
          CLK_OOBCLK                     => PIPE_OOBCLK_IN,
          CLK_MMCM_LOCK                  => PIPE_MMCM_LOCK_IN);
  end generate;

  int_clk: if (not(PCIE_EXT_CLK = "TRUE")) generate
    PIPE_PCLK_IN        <= '0';
    PIPE_RXUSRCLK_IN    <= '0';
    PIPE_RXOUTCLK_IN    <= (others => '0');
    PIPE_DCLK_IN        <= '0';
    PIPE_USERCLK1_IN    <= '0';
    PIPE_USERCLK2_IN    <= '0';
    PIPE_OOBCLK_IN      <= '0';
    PIPE_MMCM_LOCK_IN   <= '0';
  end generate;

  ep : pcie_2_1_ep_7x
  generic map(
    REF_CLK_FREQ                  => REF_CLK_FREQ                 ,
    PCIE_EXT_CLK                  => PCIE_EXT_CLK                 ,
    PL_FAST_TRAIN                 => PL_FAST_TRAIN                ,
    ALLOW_X8_GEN2                 => ALLOW_X8_GEN2                ,
    C_DATA_WIDTH                  => C_DATA_WIDTH                 ,
    LINK_CAP_MAX_LINK_WIDTH       => LINK_CAP_MAX_LINK_WIDTH      ,
    LINK_CAP_MAX_LINK_SPEED       => LINK_CAP_MAX_LINK_SPEED      ,
    LINK_CTRL2_TARGET_LINK_SPEED  => LINK_CTRL2_TARGET_LINK_SPEED ,
    DEV_CAP_MAX_PAYLOAD_SUPPORTED => DEV_CAP_MAX_PAYLOAD_SUPPORTED,
    USER_CLK_FREQ                 => USER_CLK_FREQ                ,
    USER_CLK2_DIV2                => USER_CLK2_DIV2               ,
    TRN_DW                        => TRN_DW                       ,
    VC0_TX_LASTPACKET             => VC0_TX_LASTPACKET            ,
    VC0_RX_RAM_LIMIT              => VC0_RX_RAM_LIMIT             ,
    VC0_CPL_INFINITE              => VC0_CPL_INFINITE             ,
    VC0_TOTAL_CREDITS_PD          => VC0_TOTAL_CREDITS_PD         ,
    VC0_TOTAL_CREDITS_CD          => VC0_TOTAL_CREDITS_CD         ,
    LINK_CAP_MAX_LINK_WIDTH_int   => LINK_CAP_MAX_LINK_WIDTH_int  ,
    LINK_CAP_MAX_LINK_SPEED_int   => LINK_CAP_MAX_LINK_SPEED_int
    )
  port map(
  -------------------------------------------------------------------------------------------------------------------
  -- 1. PCI Express (pci_exp) Interface                                                                            --
  -------------------------------------------------------------------------------------------------------------------
  -- TX
  pci_exp_txp                               => pci_exp_txp,
  pci_exp_txn                               => pci_exp_txn,
  -- RX
  pci_exp_rxp                               => pci_exp_rxp,
  pci_exp_rxn                               => pci_exp_rxn,

  -------------------------------------------------------------------------------------------------------------------
  -- 2. Clocking Interface - For Partial Reconfig Support                                                          --
  -------------------------------------------------------------------------------------------------------------------
  PIPE_PCLK_IN                               => PIPE_PCLK_IN,
  PIPE_RXUSRCLK_IN                           => PIPE_RXUSRCLK_IN,
  PIPE_RXOUTCLK_IN                           => PIPE_RXOUTCLK_IN,
  PIPE_DCLK_IN                               => PIPE_DCLK_IN,
  PIPE_USERCLK1_IN                           => PIPE_USERCLK1_IN,
  PIPE_USERCLK2_IN                           => PIPE_USERCLK2_IN,
  PIPE_OOBCLK_IN                             => PIPE_OOBCLK_IN,
  PIPE_MMCM_LOCK_IN                          => PIPE_MMCM_LOCK_IN,
  PIPE_TXOUTCLK_OUT                          => PIPE_TXOUTCLK_OUT,
  PIPE_RXOUTCLK_OUT                          => PIPE_RXOUTCLK_OUT,
  PIPE_PCLK_SEL_OUT                          => PIPE_PCLK_SEL_OUT,
  PIPE_GEN3_OUT                              => PIPE_GEN3_OUT,

  -------------------------------------------------------------------------------------------------------------------
  -- 3. AXI-S Interface                                                                                            --
  -------------------------------------------------------------------------------------------------------------------
  -- Common
  user_clk_out                               => user_clk ,
  user_reset_out                             => user_reset,
  user_lnk_up                                => user_lnk_up,

  -- TX
  tx_buf_av                                  => tx_buf_av ,
  tx_cfg_req                                 => tx_cfg_req ,
  tx_err_drop                                => tx_err_drop ,
  s_axis_tx_tready                           => s_axis_tx_tready ,
  s_axis_tx_tdata                            => s_axis_tx_tdata ,
  s_axis_tx_tkeep                            => s_axis_tx_tkeep ,
  s_axis_tx_tlast                            => s_axis_tx_tlast ,
  s_axis_tx_tvalid                           => s_axis_tx_tvalid ,
  s_axis_tx_tuser                            => s_axis_tx_tuser,
  tx_cfg_gnt                                 => tx_cfg_gnt ,

  -- RX
  m_axis_rx_tdata                            => m_axis_rx_tdata ,
  m_axis_rx_tkeep                            => m_axis_rx_tkeep ,
  m_axis_rx_tlast                            => m_axis_rx_tlast ,
  m_axis_rx_tvalid                           => m_axis_rx_tvalid ,
  m_axis_rx_tready                           => m_axis_rx_tready ,
  m_axis_rx_tuser                            => m_axis_rx_tuser,
  rx_np_ok                                   => rx_np_ok ,
  rx_np_req                                  => rx_np_req ,

  -- Flow Control
  fc_cpld                                    => fc_cpld ,
  fc_cplh                                    => fc_cplh ,
  fc_npd                                     => fc_npd ,
  fc_nph                                     => fc_nph ,
  fc_pd                                      => fc_pd ,
  fc_ph                                      => fc_ph ,
  fc_sel                                     => fc_sel ,

  -------------------------------------------------------------------------------------------------------------------
  -- 4. Configuration (CFG) Interface                                                                              --
  -------------------------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------
   -- EP and RP                                                      --
  ---------------------------------------------------------------------

  cfg_mgmt_do                                => open ,
  cfg_mgmt_rd_wr_done                        => open ,

  cfg_status                                 => cfg_status ,
  cfg_command                                => cfg_command ,
  cfg_dstatus                                => cfg_dstatus ,
  cfg_dcommand                               => cfg_dcommand ,
  cfg_lstatus                                => cfg_lstatus ,
  cfg_lcommand                               => cfg_lcommand ,
  cfg_dcommand2                              => cfg_dcommand2 ,
  cfg_pcie_link_state                        => cfg_pcie_link_state ,

  cfg_pmcsr_pme_en                           => open ,
  cfg_pmcsr_pme_status                       => open ,
  cfg_pmcsr_powerstate                       => open ,
  cfg_received_func_lvl_rst                  => open ,

  cfg_mgmt_di                                => cfg_mgmt_di ,
  cfg_mgmt_byte_en                           => cfg_mgmt_byte_en ,
  cfg_mgmt_dwaddr                            => cfg_mgmt_dwaddr ,
  cfg_mgmt_wr_en                             => cfg_mgmt_wr_en ,
  cfg_mgmt_rd_en                             => cfg_mgmt_rd_en ,
  cfg_mgmt_wr_readonly                       => cfg_mgmt_wr_readonly ,

  cfg_err_ecrc                               => cfg_err_ecrc ,
  cfg_err_ur                                 => cfg_err_ur ,
  cfg_err_cpl_timeout                        => cfg_err_cpl_timeout ,
  cfg_err_cpl_unexpect                       => cfg_err_cpl_unexpect ,
  cfg_err_cpl_abort                          => cfg_err_cpl_abort ,
  cfg_err_posted                             => cfg_err_posted ,
  cfg_err_cor                                => cfg_err_cor ,
  cfg_err_atomic_egress_blocked              => cfg_err_atomic_egress_blocked ,
  cfg_err_internal_cor                       => cfg_err_internal_cor ,
  cfg_err_malformed                          => cfg_err_malformed ,
  cfg_err_mc_blocked                         => cfg_err_mc_blocked ,
  cfg_err_poisoned                           => cfg_err_poisoned ,
  cfg_err_norecovery                         => cfg_err_norecovery ,
  cfg_err_tlp_cpl_header                     => cfg_err_tlp_cpl_header,
  cfg_err_cpl_rdy                            => cfg_err_cpl_rdy ,
  cfg_err_locked                             => cfg_err_locked ,
  cfg_err_acs                                => cfg_err_acs ,
  cfg_err_internal_uncor                     => cfg_err_internal_uncor ,

  cfg_trn_pending                            => cfg_trn_pending ,
  cfg_pm_halt_aspm_l0s                       => cfg_pm_halt_aspm_l0s ,
  cfg_pm_halt_aspm_l1                        => cfg_pm_halt_aspm_l1 ,
  cfg_pm_force_state_en                      => cfg_pm_force_state_en ,
  cfg_pm_force_state                         => cfg_pm_force_state ,

  ---------------------------------------------------------------------
   -- EP Only                                                        --
  ---------------------------------------------------------------------

  cfg_interrupt                              => cfg_interrupt ,
  cfg_interrupt_rdy                          => cfg_interrupt_rdy ,
  cfg_interrupt_assert                       => cfg_interrupt_assert ,
  cfg_interrupt_di                           => cfg_interrupt_di ,
  cfg_interrupt_do                           => cfg_interrupt_do ,
  cfg_interrupt_mmenable                     => cfg_interrupt_mmenable ,
  cfg_interrupt_msienable                    => cfg_interrupt_msienable ,
  cfg_interrupt_msixenable                   => cfg_interrupt_msixenable ,
  cfg_interrupt_msixfm                       => cfg_interrupt_msixfm ,
  cfg_interrupt_stat                         => cfg_interrupt_stat ,
  cfg_pciecap_interrupt_msgnum               => cfg_pciecap_interrupt_msgnum ,
  cfg_to_turnoff                             => cfg_to_turnoff ,
  cfg_turnoff_ok                             => cfg_turnoff_ok ,
  cfg_bus_number                             => cfg_bus_number ,
  cfg_device_number                          => cfg_device_number ,
  cfg_function_number                        => cfg_function_number ,
  cfg_pm_wake                                => cfg_pm_wake ,

  ---------------------------------------------------------------------
   -- RP Only                                                        --
  ---------------------------------------------------------------------
  cfg_pm_send_pme_to                         => '0' ,
  cfg_ds_bus_number                          => x"00" ,
  cfg_ds_device_number                       => "00000" ,
  cfg_ds_function_number                     => "000" ,
  cfg_mgmt_wr_rw1c_as_rw                     => '0' ,
  cfg_msg_received                           => open ,
  cfg_msg_data                               => open ,

  cfg_bridge_serr_en                         => open ,
  cfg_slot_control_electromech_il_ctl_pulse  => open ,
  cfg_root_control_syserr_corr_err_en        => open ,
  cfg_root_control_syserr_non_fatal_err_en   => open ,
  cfg_root_control_syserr_fatal_err_en       => open ,
  cfg_root_control_pme_int_en                => open ,
  cfg_aer_rooterr_corr_err_reporting_en      => open ,
  cfg_aer_rooterr_non_fatal_err_reporting_en => open ,
  cfg_aer_rooterr_fatal_err_reporting_en     => open ,
  cfg_aer_rooterr_corr_err_received          => open ,
  cfg_aer_rooterr_non_fatal_err_received     => open ,
  cfg_aer_rooterr_fatal_err_received         => open ,

  cfg_msg_received_err_cor                   => open ,
  cfg_msg_received_err_non_fatal             => open ,
  cfg_msg_received_err_fatal                 => open ,
  cfg_msg_received_pm_as_nak                 => open ,
  cfg_msg_received_pm_pme                    => open ,
  cfg_msg_received_pme_to_ack                => open ,
  cfg_msg_received_assert_int_a              => open ,
  cfg_msg_received_assert_int_b              => open ,
  cfg_msg_received_assert_int_c              => open ,
  cfg_msg_received_assert_int_d              => open ,
  cfg_msg_received_deassert_int_a            => open ,
  cfg_msg_received_deassert_int_b            => open ,
  cfg_msg_received_deassert_int_c            => open ,
  cfg_msg_received_deassert_int_d            => open ,

  -------------------------------------------------------------------------------------------------------------------
  -- 5. Physical Layer Control and Status (PL) Interface                                                           --
  -------------------------------------------------------------------------------------------------------------------
  pl_directed_link_auton                     => pl_directed_link_auton ,
  pl_directed_link_change                    => pl_directed_link_change ,
  pl_directed_link_speed                     => pl_directed_link_speed ,
  pl_directed_link_width                     => pl_directed_link_width ,
  pl_upstream_prefer_deemph                  => pl_upstream_prefer_deemph ,

  pl_sel_lnk_rate                            => pl_sel_lnk_rate ,
  pl_sel_lnk_width                           => pl_sel_lnk_width ,
  pl_ltssm_state                             => pl_ltssm_state ,
  pl_lane_reversal_mode                      => pl_lane_reversal_mode ,

  pl_phy_lnk_up                              => open ,
  pl_tx_pm_state                             => open ,
  pl_rx_pm_state                             => open ,

  cfg_dsn                                    => cfg_dsn ,

  pl_link_upcfg_cap                          => pl_link_upcfg_cap ,
  pl_link_gen2_cap                           => pl_link_gen2_cap ,
  pl_link_partner_gen2_supported             => pl_link_partner_gen2_supported ,
  pl_initial_link_width                      => pl_initial_link_width ,

  pl_directed_change_done                    => open ,

  ---------------------------------------------------------------------
   -- EP Only                                                        --
  ---------------------------------------------------------------------
  pl_received_hot_rst                        => pl_received_hot_rst ,

  ---------------------------------------------------------------------
   -- RP Only                                                        --
  ---------------------------------------------------------------------
  pl_transmit_hot_rst                        => '0' ,
  pl_downstream_deemph_source                => '0' ,

  -------------------------------------------------------------------------------------------------------------------
  -- 6. AER interface                                                                                              --
  -------------------------------------------------------------------------------------------------------------------
  cfg_err_aer_headerlog                      => cfg_err_aer_headerlog ,
  cfg_aer_interrupt_msgnum                   => cfg_aer_interrupt_msgnum ,
  cfg_err_aer_headerlog_set                  => cfg_err_aer_headerlog_set ,
  cfg_aer_ecrc_check_en                      => cfg_aer_ecrc_check_en ,
  cfg_aer_ecrc_gen_en                        => cfg_aer_ecrc_gen_en ,

  -------------------------------------------------------------------------------------------------------------------
  -- 7. VC interface                                                                                               --
  -------------------------------------------------------------------------------------------------------------------
  cfg_vc_tcvc_map                            => open ,


  -------------------------------------------------------------------------------------------------------------------
  -- 8. System(SYS) Interface                                                                                      --
  -------------------------------------------------------------------------------------------------------------------
  PIPE_MMCM_RST_N                            =>  PIPE_MMCM_RST_N ,        -- Async      | Async
  sys_clk                                    => sys_clk_p ,
  sys_rst_n                                  => sys_rst_n_c

);

app : pcie_app_7x
  generic map
  (
    C_DATA_WIDTH => C_DATA_WIDTH,
    TCQ          => TCQ
  )
  port map(

  -------------------------------------------------------------------------------------------------------------------
  -- 1. AXI-S Interface                                                                                            --
  -------------------------------------------------------------------------------------------------------------------
  -- Common
  user_clk                       => user_clk ,
  user_reset                     => user_reset_q ,
  user_lnk_up                    => user_lnk_up_q ,

  -- TX
  tx_buf_av                      => tx_buf_av ,
  tx_cfg_req                     => tx_cfg_req ,
  tx_err_drop                    => tx_err_drop ,
  s_axis_tx_tready               => s_axis_tx_tready ,
  s_axis_tx_tdata                => s_axis_tx_tdata ,
  s_axis_tx_tkeep                => s_axis_tx_tkeep ,
  s_axis_tx_tlast                => s_axis_tx_tlast ,
  s_axis_tx_tvalid               => s_axis_tx_tvalid ,
  s_axis_tx_tuser                => s_axis_tx_tuser,
  tx_cfg_gnt                     => tx_cfg_gnt ,

  -- RX
  m_axis_rx_tdata                => m_axis_rx_tdata ,
  m_axis_rx_tkeep                => m_axis_rx_tkeep ,
  m_axis_rx_tlast                => m_axis_rx_tlast ,
  m_axis_rx_tvalid               => m_axis_rx_tvalid ,
  m_axis_rx_tuser                => m_axis_rx_tuser,
  m_axis_rx_tready               => m_axis_rx_tready ,
  rx_np_ok                       => rx_np_ok ,
  rx_np_req                       => rx_np_req ,

  -- Flow Control
  fc_cpld                        => fc_cpld ,
  fc_cplh                        => fc_cplh ,
  fc_npd                         => fc_npd ,
  fc_nph                         => fc_nph ,
  fc_pd                          => fc_pd ,
  fc_ph                          => fc_ph ,
  fc_sel                         => fc_sel ,

  --------------------------------------------------------------------------------------------------------------------
  -- 2. Configuration (CFG) Interface                                                                               --
  --------------------------------------------------------------------------------------------------------------------
  cfg_err_cor                    => cfg_err_cor ,
  cfg_err_atomic_egress_blocked  => cfg_err_atomic_egress_blocked ,
  cfg_err_internal_cor           => cfg_err_internal_cor ,
  cfg_err_malformed              => cfg_err_malformed ,
  cfg_err_mc_blocked             => cfg_err_mc_blocked ,
  cfg_err_poisoned               => cfg_err_poisoned ,
  cfg_err_norecovery             => cfg_err_norecovery ,
  cfg_err_ur                     => cfg_err_ur ,
  cfg_err_ecrc                   => cfg_err_ecrc ,
  cfg_err_cpl_timeout            => cfg_err_cpl_timeout ,
  cfg_err_cpl_abort              => cfg_err_cpl_abort ,
  cfg_err_cpl_unexpect           => cfg_err_cpl_unexpect ,
  cfg_err_posted                 => cfg_err_posted ,
  cfg_err_locked                 => cfg_err_locked ,
  cfg_err_acs                    => cfg_err_acs ,
  cfg_err_internal_uncor         => cfg_err_internal_uncor ,
  cfg_err_tlp_cpl_header         => cfg_err_tlp_cpl_header ,
  cfg_err_cpl_rdy                => cfg_err_cpl_rdy ,
  cfg_interrupt                  => cfg_interrupt ,
  cfg_interrupt_rdy              => cfg_interrupt_rdy ,
  cfg_interrupt_assert           => cfg_interrupt_assert ,
  cfg_interrupt_di               => cfg_interrupt_di ,
  cfg_interrupt_do               => cfg_interrupt_do ,
  cfg_interrupt_mmenable         => cfg_interrupt_mmenable ,
  cfg_interrupt_msienable        => cfg_interrupt_msienable ,
  cfg_interrupt_msixenable       => cfg_interrupt_msixenable ,
  cfg_interrupt_msixfm           => cfg_interrupt_msixfm ,
  cfg_interrupt_stat             => cfg_interrupt_stat ,
  cfg_pciecap_interrupt_msgnum   => cfg_pciecap_interrupt_msgnum ,
  cfg_turnoff_ok                 => cfg_turnoff_ok ,
  cfg_to_turnoff                 => cfg_to_turnoff ,

  cfg_trn_pending                => cfg_trn_pending ,
  cfg_pm_halt_aspm_l0s           => cfg_pm_halt_aspm_l0s ,
  cfg_pm_halt_aspm_l1            => cfg_pm_halt_aspm_l1 ,
  cfg_pm_force_state_en          => cfg_pm_force_state_en ,
  cfg_pm_force_state             => cfg_pm_force_state ,

  cfg_pm_wake                    => cfg_pm_wake ,
  cfg_bus_number                 => cfg_bus_number ,
  cfg_device_number              => cfg_device_number ,
  cfg_function_number            => cfg_function_number ,
  cfg_status                     => cfg_status ,
  cfg_command                    => cfg_command ,
  cfg_dstatus                    => cfg_dstatus ,
  cfg_dcommand                   => cfg_dcommand ,
  cfg_lstatus                    => cfg_lstatus ,
  cfg_lcommand                   => cfg_lcommand ,
  cfg_dcommand2                  => cfg_dcommand2 ,
  cfg_pcie_link_state            => cfg_pcie_link_state ,
  cfg_dsn                        => cfg_dsn ,

  --------------------------------------------------------------------------------------------------------------------
  -- 3. Management (MGMT) Interface                                                                                 --
  --------------------------------------------------------------------------------------------------------------------
  cfg_mgmt_di                    => cfg_mgmt_di ,
  cfg_mgmt_byte_en               => cfg_mgmt_byte_en ,
  cfg_mgmt_dwaddr                => cfg_mgmt_dwaddr ,
  cfg_mgmt_wr_en                 => cfg_mgmt_wr_en ,
  cfg_mgmt_rd_en                 => cfg_mgmt_rd_en ,
  cfg_mgmt_wr_readonly           => cfg_mgmt_wr_readonly ,

  -------------------------------------------------------------------------------------------------------------------
  -- 3. Advanced Error Reporting (AER) Interface                                                                   --
  -------------------------------------------------------------------------------------------------------------------
  cfg_err_aer_headerlog          => cfg_err_aer_headerlog ,
  cfg_aer_interrupt_msgnum       => cfg_aer_interrupt_msgnum ,
  cfg_err_aer_headerlog_set      => cfg_err_aer_headerlog_set ,
  cfg_aer_ecrc_check_en          => cfg_aer_ecrc_check_en ,
  cfg_aer_ecrc_gen_en            => cfg_aer_ecrc_gen_en ,

  -------------------------------------------------------------------------------------------------------------------
  -- 4. Physical Layer Control and Status (PL) Interface                                                           --
  -------------------------------------------------------------------------------------------------------------------
  pl_initial_link_width          => pl_initial_link_width ,
  pl_lane_reversal_mode          => pl_lane_reversal_mode ,
  pl_link_gen2_cap               => pl_link_gen2_cap ,
  pl_link_partner_gen2_supported => pl_link_partner_gen2_supported ,
  pl_link_upcfg_cap              => pl_link_upcfg_cap ,
  pl_ltssm_state                 => pl_ltssm_state ,
  pl_received_hot_rst            => pl_received_hot_rst ,
  pl_sel_lnk_rate                => pl_sel_lnk_rate ,
  pl_sel_lnk_width               => pl_sel_lnk_width ,
  pl_directed_link_auton         => pl_directed_link_auton ,
  pl_directed_link_change        => pl_directed_link_change ,
  pl_directed_link_speed         => pl_directed_link_speed ,
  pl_directed_link_width         => pl_directed_link_width ,
  pl_upstream_prefer_deemph      => pl_upstream_prefer_deemph);

end rtl;
