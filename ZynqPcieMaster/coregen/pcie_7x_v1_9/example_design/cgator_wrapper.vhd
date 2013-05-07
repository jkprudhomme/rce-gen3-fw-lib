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
-- File       : cgator_wrapper.vhd
-- Version    : 1.9
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

entity cgator_wrapper is
   generic (
      -- Configurator parameters
      TCQ                                       : integer := 1;
      EXTRA_PIPELINE                            : integer := 1;
      ROM_FILE                                  : string := "cgator_cfg_rom.data";
      ROM_SIZE                                  : integer := 32;
      REQUESTER_ID                              : std_logic_vector(15 downto 0) := X"10EE";
      PL_FAST_TRAIN                             : string := "FALSE";
      C_DATA_WIDTH                              : INTEGER := 64;
      KEEP_WIDTH                                : INTEGER := 8
   );
   port (
      ---------------------------------------------------------
      -- 0. Configurator I/Os
      ---------------------------------------------------------
      start_config                              : in std_logic;
      finished_config                           : out std_logic;
      failed_config                             : out std_logic;

      ---------------------------------------------------------
      -- 1. PCI Express (pci_exp) Interface
      ---------------------------------------------------------

      -- Tx
      pci_exp_txp                               : out std_logic_vector(0 downto 0);
      pci_exp_txn                               : out std_logic_vector(0 downto 0);

      -- Rx
      pci_exp_rxp                               : in std_logic_vector(0 downto 0);
      pci_exp_rxn                               : in std_logic_vector(0 downto 0);

     -----------------------------------------------------------------------------------------------------------
     -- 2. AXI-S Interface                                                                                    --
     -----------------------------------------------------------------------------------------------------------
      user_clk_out                              : out std_logic;
      user_reset_out                            : out std_logic;
      user_lnk_up                               : out std_logic;

      -- TX
      tx_buf_av                                 : out std_logic_vector(5 downto 0);
      tx_err_drop                               : out std_logic;
      tx_cfg_req                                : out std_logic;
      s_axis_tx_tready                          : out std_logic;
      s_axis_tx_tdata                           : in  std_logic_vector((C_DATA_WIDTH-1) downto 0);
      s_axis_tx_tuser                           : in  std_logic_vector (3 downto 0);
      s_axis_tx_tkeep                           : in  std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
      s_axis_tx_tlast                           : in  std_logic;
      s_axis_tx_tvalid                          : in  std_logic;
      tx_cfg_gnt                                : in  std_logic;

      -- RX
      m_axis_rx_tdata                           : out std_logic_vector((C_DATA_WIDTH-1) downto 0);
      m_axis_rx_tkeep                           : out std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
      m_axis_rx_tlast                           : out std_logic;
      m_axis_rx_tvalid                          : out std_logic;
      m_axis_rx_tuser                           : out std_logic_vector(21 downto 0);

      -- Flow Control
      fc_cpld                                   : out std_logic_vector(11 downto 0);
      fc_cplh                                   : out std_logic_vector(7 downto 0);
      fc_npd                                    : out std_logic_vector(11 downto 0);
      fc_nph                                    : out std_logic_vector(7 downto 0);
      fc_pd                                     : out std_logic_vector(11 downto 0);
      fc_ph                                     : out std_logic_vector(7 downto 0);
      fc_sel                                    : in  std_logic_vector(2 downto 0);

      ---------------------------------------------------------
      -- 3. Configuration (CFG) Interface
      ---------------------------------------------------------
      cfg_do                                    : out std_logic_vector(31 downto 0);
      cfg_rd_wr_done                            : out std_logic;

      cfg_status                                : out std_logic_vector(15 downto 0);
      cfg_command                               : out std_logic_vector(15 downto 0);
      cfg_dstatus                               : out std_logic_vector(15 downto 0);
      cfg_dcommand                              : out std_logic_vector(15 downto 0);
      cfg_lstatus                               : out std_logic_vector(15 downto 0);
      cfg_lcommand                              : out std_logic_vector(15 downto 0);
      cfg_dcommand2                             : out std_logic_vector(15 downto 0);
      cfg_pcie_link_state                       : out std_logic_vector(2 downto 0);

      cfg_pmcsr_pme_en                          : out std_logic;
      cfg_pmcsr_powerstate                      : out std_logic_vector(1 downto 0);
      cfg_pmcsr_pme_status                      : out std_logic;
      cfg_received_func_lvl_rst                 : out std_logic;

      -- Management Interface
      cfg_di                                    : in std_logic_vector(31 downto 0);
      cfg_byte_en                               : in std_logic_vector(3 downto 0);
      cfg_dwaddr                                : in std_logic_vector(9 downto 0);
      cfg_wr_en                                 : in std_logic;
      cfg_rd_en                                 : in std_logic;
      cfg_wr_readonly                           : in std_logic;

      -- Error Reporting Interface
      cfg_err_ecrc                              : in std_logic;
      cfg_err_ur                                : in std_logic;
      cfg_err_cpl_timeout                       : in std_logic;
      cfg_err_cpl_unexpect                      : in std_logic;
      cfg_err_cpl_abort                         : in std_logic;
      cfg_err_posted                            : in std_logic;
      cfg_err_cor                               : in std_logic;
      cfg_err_atomic_egress_blocked             : in std_logic;
      cfg_err_internal_cor                      : in std_logic;
      cfg_err_malformed                         : in std_logic;
      cfg_err_mc_blocked                        : in std_logic;
      cfg_err_poisoned                          : in std_logic;
      cfg_err_norecovery                        : in std_logic;
      cfg_err_tlp_cpl_header                    : in std_logic_vector(47 downto 0);
      cfg_err_cpl_rdy                           : out std_logic;
      cfg_err_locked                            : in std_logic;
      cfg_err_acs                               : in std_logic;
      cfg_err_internal_uncor                    : in std_logic;
      cfg_pm_halt_aspm_l0s                      : in std_logic;
      cfg_pm_halt_aspm_l1                       : in std_logic;
      cfg_pm_force_state_en                     : in std_logic;
      cfg_pm_force_state                        : in std_logic_vector(1 downto 0);
      cfg_dsn                                   : in  std_logic_vector(63 downto 0);

      ---------------------------------------------------------------------
      -- EP Only                                                         --
      ---------------------------------------------------------------------
      cfg_interrupt                             : in std_logic;
      cfg_interrupt_rdy                         : out std_logic;
      cfg_interrupt_assert                      : in std_logic;
      cfg_interrupt_di                          : in std_logic_vector(7 downto 0);
      cfg_interrupt_do                          : out std_logic_vector(7 downto 0);
      cfg_interrupt_mmenable                    : out std_logic_vector(2 downto 0);
      cfg_interrupt_msienable                   : out std_logic;
      cfg_interrupt_msixenable                  : out std_logic;
      cfg_interrupt_msixfm                      : out std_logic;
      cfg_interrupt_stat                        : in std_logic;
      cfg_pciecap_interrupt_msgnum              : in std_logic_vector(4 downto 0);
      cfg_to_turnoff                            : out std_logic;
      cfg_turnoff_ok                            : in std_logic;
      cfg_bus_number                            : out std_logic_vector(7 downto 0);
      cfg_device_number                         : out std_logic_vector(4 downto 0);
      cfg_function_number                       : out std_logic_vector(2 downto 0);
      cfg_pm_wake                               : in std_logic;

      ---------------------------------------------------------------------
      -- RP Only                                                         --
      ---------------------------------------------------------------------
      cfg_pm_send_pme_to                        : in std_logic;
      cfg_ds_bus_number                         : in std_logic_vector(7 downto 0);
      cfg_ds_device_number                      : in std_logic_vector(4 downto 0);
      cfg_ds_function_number                    : in std_logic_vector(2 downto 0);

      cfg_wr_rw1c_as_rw                         : in std_logic;

      cfg_msg_received                          : out std_logic;
      cfg_msg_data                              : out std_logic_vector(15 downto 0);

      cfg_bridge_serr_en                        : out std_logic;
      cfg_slot_control_electromech_il_ctl_pulse : out std_logic;
      cfg_root_control_syserr_corr_err_en       : out std_logic;
      cfg_root_control_syserr_non_fatal_err_en  : out std_logic;
      cfg_root_control_syserr_fatal_err_en      : out std_logic;
      cfg_root_control_pme_int_en               : out std_logic;
      cfg_aer_rooterr_corr_err_reporting_en     : out std_logic;
      cfg_aer_rooterr_non_fatal_err_reporting_en: out std_logic;
      cfg_aer_rooterr_fatal_err_reporting_en    : out std_logic;
      cfg_aer_rooterr_corr_err_received         : out std_logic;
      cfg_aer_rooterr_non_fatal_err_received    : out std_logic;
      cfg_aer_rooterr_fatal_err_received        : out std_logic;


      cfg_msg_received_err_cor                  : out std_logic;
      cfg_msg_received_err_non_fatal            : out std_logic;
      cfg_msg_received_err_fatal                : out std_logic;
      cfg_msg_received_pm_as_nak                : out std_logic;
      cfg_msg_received_pm_pme                   : out std_logic;
      cfg_msg_received_pme_to_ack               : out std_logic;
      cfg_msg_received_assert_inta              : out std_logic;
      cfg_msg_received_assert_intb              : out std_logic;
      cfg_msg_received_assert_intc              : out std_logic;
      cfg_msg_received_assert_intd              : out std_logic;
      cfg_msg_received_deassert_inta            : out std_logic;
      cfg_msg_received_deassert_intb            : out std_logic;
      cfg_msg_received_deassert_intc            : out std_logic;
      cfg_msg_received_deassert_intd            : out std_logic;
      cfg_msg_received_setslotpowerlimit        : out std_logic;

      -----------------------------------------------------------------------------------------------------------
      -- 4. Physical Layer Control and Status (PL) Interface                                                   --
      -----------------------------------------------------------------------------------------------------------
      pl_directed_link_change                   : in std_logic_vector(1 downto 0);
      pl_directed_link_width                    : in std_logic_vector(1 downto 0);
      pl_directed_link_speed                    : in std_logic;
      pl_directed_link_auton                    : in std_logic;
      pl_upstream_prefer_deemph                 : in std_logic;

      pl_sel_link_rate                          : out std_logic;
      pl_sel_link_width                         : out std_logic_vector(1 downto 0);
      pl_ltssm_state                            : out std_logic_vector(5 downto 0);
      pl_lane_reversal_mode                     : out std_logic_vector(1 downto 0);

      pl_phy_lnk_up                             : out std_logic;
      pl_tx_pm_state                            : out std_logic_vector(2 downto 0);
      pl_rx_pm_state                            : out std_logic_vector(1 downto 0);

      pl_link_upcfg_capable                     : out std_logic;
      pl_link_gen2_capable                      : out std_logic;
      pl_link_partner_gen2_supported            : out std_logic;
      pl_initial_link_width                     : out std_logic_vector(2 downto 0);

      pl_directed_change_done                   : out std_logic;

      cfg_trn_pending                           : in std_logic;

      ---------------------------------------------------------------------
      -- EP Only                                                         --
      ---------------------------------------------------------------------
      pl_received_hot_rst                       : out std_logic;
      ---------------------------------------------------------------------
      -- RP Only                                                        --
      ---------------------------------------------------------------------
      pl_transmit_hot_rst                       : in std_logic;
      pl_downstream_deemph_source               : in std_logic;

      -----------------------------------------------------------------------------------------------------------
      -- 5. AER interface                                                                                      --
      -----------------------------------------------------------------------------------------------------------
      cfg_err_aer_headerlog                     : in std_logic_vector(127 downto 0);
      cfg_aer_interrupt_msgnum                  : in std_logic_vector(4 downto 0);
      cfg_err_aer_headerlog_set                 : out std_logic;
      cfg_aer_ecrc_check_en                     : out std_logic;
      cfg_aer_ecrc_gen_en                       : out std_logic;
      -----------------------------------------------------------------------------------------------------------
      -- 6. VC interface                                                                                       --
      -----------------------------------------------------------------------------------------------------------
      cfg_vc_tcvc_map                           : out std_logic_vector(6 downto 0);


      PIPE_MMCM_RST_N                           : in std_logic;   --     // Async      | Async
      sys_clk                                   : in std_logic;
      sys_rst_n                                 : in std_logic
   );
end cgator_wrapper;

architecture sevenx_pcie of cgator_wrapper is

  component pcie_7x_v1_9    generic (
      PCIE_EXT_CLK                             : string  := "FALSE";
      PL_FAST_TRAIN                            : string  := "FALSE"; -- Simulation Speedup
      C_DATA_WIDTH                             : integer    := 64
      );
    port (
      ----------------------------------------------------------------------------------------------------------
      -- 1. PCI Express (pci_exp) Interface                                                                   --
      ----------------------------------------------------------------------------------------------------------
      pci_exp_txp                               : out std_logic_vector(0 downto 0);
      pci_exp_txn                               : out std_logic_vector(0 downto 0);
      pci_exp_rxp                               : in  std_logic_vector(0 downto 0);
      pci_exp_rxn                               : in  std_logic_vector(0 downto 0);

     -----------------------------------------------------------------------------------------------------------
     -- 2. Clocking Interface - For Partial Reconfig Support                                                  --
     -----------------------------------------------------------------------------------------------------------
      PIPE_PCLK_IN                              : in std_logic;
      PIPE_RXUSRCLK_IN                          : in std_logic;
      PIPE_RXOUTCLK_IN                          : in std_logic_vector(0 downto 0);
      PIPE_DCLK_IN                              : in std_logic;
      PIPE_USERCLK1_IN                          : in std_logic;
      PIPE_USERCLK2_IN                          : in std_logic;
      PIPE_OOBCLK_IN                            : in std_logic;
      PIPE_MMCM_LOCK_IN                         : in std_logic;

      PIPE_TXOUTCLK_OUT                         : out std_logic;
      PIPE_RXOUTCLK_OUT                         : out std_logic_vector(0 downto 0);
      PIPE_PCLK_SEL_OUT                         : out std_logic_vector(0 downto 0);
      PIPE_GEN3_OUT                             : out std_logic;

     -----------------------------------------------------------------------------------------------------------
     -- 3. AXI-S Interface                                                                                    --
     -----------------------------------------------------------------------------------------------------------
      user_clk_out                              : out std_logic;
      user_reset_out                            : out std_logic;
      user_lnk_up                               : out std_logic;

      -- TX
      tx_buf_av                                 : out std_logic_vector(5 downto 0);
      tx_cfg_req                                : out std_logic;
      tx_err_drop                               : out std_logic;
      s_axis_tx_tready                          : out std_logic;
      s_axis_tx_tdata                           : in  std_logic_vector((C_DATA_WIDTH-1) downto 0);
      s_axis_tx_tkeep                           : in  std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
      s_axis_tx_tlast                           : in  std_logic;
      s_axis_tx_tvalid                          : in  std_logic;
      s_axis_tx_tuser                           : in  std_logic_vector (3 downto 0);
      tx_cfg_gnt                                : in  std_logic;

      -- RX
      m_axis_rx_tdata                           : out std_logic_vector((C_DATA_WIDTH-1) downto 0);
      m_axis_rx_tkeep                           : out std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
      m_axis_rx_tlast                           : out std_logic;
      m_axis_rx_tvalid                          : out std_logic;
      m_axis_rx_tuser                           : out std_logic_vector(21 downto 0);
      m_axis_rx_tready                          : in  std_logic;
      rx_np_ok                                  : in  std_logic;
      rx_np_req                                 : in  std_logic;

      -- Flow Control
      fc_cpld                                   : out std_logic_vector(11 downto 0);
      fc_cplh                                   : out std_logic_vector(7 downto 0);
      fc_npd                                    : out std_logic_vector(11 downto 0);
      fc_nph                                    : out std_logic_vector(7 downto 0);
      fc_pd                                     : out std_logic_vector(11 downto 0);
      fc_ph                                     : out std_logic_vector(7 downto 0);
      fc_sel                                    : in  std_logic_vector(2 downto 0);

     -----------------------------------------------------------------------------------------------------------
     -- 4. Configuration (CFG) Interface                                                                      --
     -----------------------------------------------------------------------------------------------------------
     ---------------------------------------------------------------------
      -- EP and RP                                                      --
     ---------------------------------------------------------------------
      cfg_mgmt_do                               : out std_logic_vector(31 downto 0);
      cfg_mgmt_rd_wr_done                       : out std_logic;

      cfg_status                                : out std_logic_vector(15 downto 0);
      cfg_command                               : out std_logic_vector(15 downto 0);
      cfg_dstatus                               : out std_logic_vector(15 downto 0);
      cfg_dcommand                              : out std_logic_vector(15 downto 0);
      cfg_lstatus                               : out std_logic_vector(15 downto 0);
      cfg_lcommand                              : out std_logic_vector(15 downto 0);
      cfg_dcommand2                             : out std_logic_vector(15 downto 0);
      cfg_pcie_link_state                       : out std_logic_vector(2 downto 0);

      cfg_pmcsr_pme_en                          : out std_logic;
      cfg_pmcsr_powerstate                      : out std_logic_vector(1 downto 0);
      cfg_pmcsr_pme_status                      : out std_logic;
      cfg_received_func_lvl_rst                 : out std_logic;

      -- Management Interface
      cfg_mgmt_di                               : in  std_logic_vector(31 downto 0);
      cfg_mgmt_byte_en                          : in  std_logic_vector(3 downto 0);
      cfg_mgmt_dwaddr                           : in  std_logic_vector(9 downto 0);
      cfg_mgmt_wr_en                            : in  std_logic;
      cfg_mgmt_rd_en                            : in  std_logic;
      cfg_mgmt_wr_readonly                      : in  std_logic;

      -- Error Reporting Interface
      cfg_err_ecrc                              : in  std_logic;
      cfg_err_ur                                : in  std_logic;
      cfg_err_cpl_timeout                       : in  std_logic;
      cfg_err_cpl_unexpect                      : in  std_logic;
      cfg_err_cpl_abort                         : in  std_logic;
      cfg_err_posted                            : in  std_logic;
      cfg_err_cor                               : in  std_logic;
      cfg_err_atomic_egress_blocked             : in std_logic;
      cfg_err_internal_cor                      : in std_logic;
      cfg_err_malformed                         : in std_logic;
      cfg_err_mc_blocked                        : in std_logic;
      cfg_err_poisoned                          : in std_logic;
      cfg_err_norecovery                        : in std_logic;
      cfg_err_tlp_cpl_header                    : in std_logic_vector(47 downto 0);
      cfg_err_cpl_rdy                           : out std_logic;
      cfg_err_locked                            : in std_logic;
      cfg_err_acs                               : in std_logic;
      cfg_err_internal_uncor                    : in std_logic;
      cfg_trn_pending                           : in std_logic;
      cfg_pm_halt_aspm_l0s                      : in std_logic;
      cfg_pm_halt_aspm_l1                       : in std_logic;
      cfg_pm_force_state_en                     : in std_logic;
      cfg_pm_force_state                        : in std_logic_vector(1 downto 0);
      cfg_dsn                                   : in std_logic_vector(63 downto 0);

     ---------------------------------------------------------------------
      -- EP Only                                                        --
     ---------------------------------------------------------------------
      cfg_interrupt                             : in  std_logic;
      cfg_interrupt_rdy                         : out std_logic;
      cfg_interrupt_assert                      : in  std_logic;
      cfg_interrupt_di                          : in  std_logic_vector(7 downto 0);
      cfg_interrupt_do                          : out std_logic_vector(7 downto 0);
      cfg_interrupt_mmenable                    : out std_logic_vector(2 downto 0);
      cfg_interrupt_msienable                   : out std_logic;
      cfg_interrupt_msixenable                  : out std_logic;
      cfg_interrupt_msixfm                      : out std_logic;

      cfg_interrupt_stat                        : in std_logic;
      cfg_pciecap_interrupt_msgnum              : in std_logic_vector(4 downto 0);
      cfg_to_turnoff                            : out std_logic;
      cfg_turnoff_ok                            : in std_logic;
      cfg_bus_number                            : out std_logic_vector(7 downto 0);
      cfg_device_number                         : out std_logic_vector(4 downto 0);
      cfg_function_number                       : out std_logic_vector(2 downto 0);
      cfg_pm_wake                               : in std_logic;

     ---------------------------------------------------------------------
      -- RP Only                                                        --
     ---------------------------------------------------------------------
      cfg_pm_send_pme_to                        : in std_logic;
      cfg_ds_bus_number                         : in std_logic_vector(7 downto 0);
      cfg_ds_device_number                      : in std_logic_vector(4 downto 0);
      cfg_ds_function_number                    : in std_logic_vector(2 downto 0);

      cfg_mgmt_wr_rw1c_as_rw                    : in std_logic;
      cfg_msg_received                          : out std_logic;
      cfg_msg_data                              : out std_logic_vector(15 downto 0);

      cfg_bridge_serr_en                        : out std_logic;
      cfg_slot_control_electromech_il_ctl_pulse : out std_logic;
      cfg_root_control_syserr_corr_err_en       : out std_logic;
      cfg_root_control_syserr_non_fatal_err_en  : out std_logic;
      cfg_root_control_syserr_fatal_err_en      : out std_logic;
      cfg_root_control_pme_int_en               : out std_logic;
      cfg_aer_rooterr_corr_err_reporting_en     : out std_logic;
      cfg_aer_rooterr_non_fatal_err_reporting_en: out std_logic;
      cfg_aer_rooterr_fatal_err_reporting_en    : out std_logic;
      cfg_aer_rooterr_corr_err_received         : out std_logic;
      cfg_aer_rooterr_non_fatal_err_received    : out std_logic;
      cfg_aer_rooterr_fatal_err_received        : out std_logic;

      cfg_msg_received_err_cor                  : out std_logic;
      cfg_msg_received_err_non_fatal            : out std_logic;
      cfg_msg_received_err_fatal                : out std_logic;
      cfg_msg_received_pm_as_nak                : out std_logic;
      cfg_msg_received_pm_pme                   : out std_logic;
      cfg_msg_received_pme_to_ack               : out std_logic;
      cfg_msg_received_assert_int_a             : out std_logic;
      cfg_msg_received_assert_int_b             : out std_logic;
      cfg_msg_received_assert_int_c             : out std_logic;
      cfg_msg_received_assert_int_d             : out std_logic;
      cfg_msg_received_deassert_int_a           : out std_logic;
      cfg_msg_received_deassert_int_b           : out std_logic;
      cfg_msg_received_deassert_int_c           : out std_logic;
      cfg_msg_received_deassert_int_d           : out std_logic;
      cfg_msg_received_setslotpowerlimit        : out std_logic;

     -----------------------------------------------------------------------------------------------------------
     -- 5. Physical Layer Control and Status (PL) Interface                                                   --
     -----------------------------------------------------------------------------------------------------------
      pl_directed_link_change                   : in  std_logic_vector(1 downto 0);
      pl_directed_link_width                    : in  std_logic_vector(1 downto 0);
      pl_directed_link_speed                    : in  std_logic;
      pl_directed_link_auton                    : in  std_logic;
      pl_upstream_prefer_deemph                 : in  std_logic;

      pl_sel_lnk_rate                           : out std_logic;
      pl_sel_lnk_width                          : out std_logic_vector(1 downto 0);
      pl_ltssm_state                            : out std_logic_vector(5 downto 0);
      pl_lane_reversal_mode                     : out std_logic_vector(1 downto 0);

      pl_phy_lnk_up                             : out std_logic;
      pl_tx_pm_state                            : out std_logic_vector(2 downto 0);
      pl_rx_pm_state                            : out std_logic_vector(1 downto 0);

      pl_link_upcfg_cap                         : out std_logic;
      pl_link_gen2_cap                          : out std_logic;
      pl_link_partner_gen2_supported            : out std_logic;
      pl_initial_link_width                     : out std_logic_vector(2 downto 0);

      pl_directed_change_done                   : out std_logic;

     ---------------------------------------------------------------------
      -- EP Only                                                        --
     ---------------------------------------------------------------------
      pl_received_hot_rst                       : out std_logic;
     ---------------------------------------------------------------------
      -- RP Only                                                        --
     ---------------------------------------------------------------------
      pl_transmit_hot_rst                       : in std_logic;
      pl_downstream_deemph_source               : in std_logic;
     -----------------------------------------------------------------------------------------------------------
     -- 6. AER interface                                                                                      --
     -----------------------------------------------------------------------------------------------------------
      cfg_err_aer_headerlog                     : in std_logic_vector(127 downto 0);
      cfg_aer_interrupt_msgnum                  : in std_logic_vector(4 downto 0);
      cfg_err_aer_headerlog_set                 : out std_logic;
      cfg_aer_ecrc_check_en                     : out std_logic;
      cfg_aer_ecrc_gen_en                       : out std_logic;
     -----------------------------------------------------------------------------------------------------------
     -- 7. VC interface                                                                                       --
     -----------------------------------------------------------------------------------------------------------
      cfg_vc_tcvc_map                           : out std_logic_vector(6 downto 0);

      PIPE_MMCM_RST_N                           : in std_logic;   --     // Async      | Async
      sys_clk                                   : in  std_logic;
      sys_rst_n                                 : in  std_logic);
  end component;

  component cgator is
      generic (
         TCQ                                    : integer := 1;
         EXTRA_PIPELINE                         : integer := 1;
         ROM_FILE                               : string  := "cgator_cfg_rom.data";
         ROM_SIZE                               : integer := 32;
         REQUESTER_ID                           : std_logic_vector(15 downto 0) := "0001000011101110";
         C_DATA_WIDTH                           : integer := 64;
         KEEP_WIDTH                             : integer := 8
      );
      port (
         user_clk                               : in std_logic;
         reset                                  : in std_logic;
         start_config                           : in std_logic;
         finished_config                        : out std_logic;
         failed_config                          : out std_logic;

         rport_s_axis_tx_tlast                  : out std_logic;
         rport_s_axis_tx_tdata                  : out std_logic_vector((C_DATA_WIDTH-1) downto 0);
         rport_s_axis_tx_tkeep                  : out std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
         rport_s_axis_tx_tvalid                 : out std_logic;
         rport_s_axis_tx_tready                 : in std_logic;
         rport_tx_cfg_req                       : in std_logic;
         rport_tx_cfg_gnt                       : out std_logic;
         rport_tx_buf_av                        : in std_logic_vector(5 downto 0);
         rport_tx_err_drop                      : in std_logic;
         rport_s_axis_tx_tuser                  : out std_logic_vector(3 downto 0);

         rport_m_axis_rx_tlast                  : in std_logic;
         rport_m_axis_rx_tdata                  : in std_logic_vector((C_DATA_WIDTH-1) downto 0);
         rport_m_axis_rx_tkeep                  : in std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
         rport_m_axis_rx_tvalid                 : in std_logic;
         rport_m_axis_rx_tready                 : out std_logic;
         rport_m_axis_rx_tuser                  : in std_logic_vector(21 downto 0);
         rport_rx_np_ok                         : out std_logic;

         usr_s_axis_tx_tlast                    : in std_logic;
         usr_s_axis_tx_tdata                    : in std_logic_vector((C_DATA_WIDTH-1) downto 0);
         usr_s_axis_tx_tkeep                    : in std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
         usr_s_axis_tx_tuser                    : in std_logic_vector(3 downto 0);
         usr_s_axis_tx_tvalid                   : in std_logic;
         usr_s_axis_tx_tready                   : out std_logic;
         usr_tx_cfg_req                         : out std_logic;
         usr_tx_cfg_gnt                         : in std_logic;
         usr_tx_buf_av                          : out std_logic_vector(5 downto 0);
         usr_tx_err_drop                        : out std_logic;

         usr_m_axis_rx_tlast                    : out std_logic;
         usr_m_axis_rx_tdata                    : out std_logic_vector((C_DATA_WIDTH-1) downto 0);
         usr_m_axis_rx_tkeep                    : out std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
         usr_m_axis_rx_tvalid                   : out std_logic;
         usr_m_axis_rx_tuser                    : out std_logic_vector(21 downto 0);

         rport_cfg_do                           : in std_logic_vector(31 downto 0);
         rport_cfg_rd_wr_done                   : in std_logic;
         rport_cfg_di                           : out std_logic_vector(31 downto 0);
         rport_cfg_byte_en                      : out std_logic_vector(3 downto 0);
         rport_cfg_dwaddr                       : out std_logic_vector(9 downto 0);
         rport_cfg_wr_en                        : out std_logic;
         rport_cfg_wr_rw1c_as_rw                : out std_logic;
         rport_cfg_rd_en                        : out std_logic;
         usr_cfg_do                             : out std_logic_vector(31 downto 0);
         usr_cfg_rd_wr_done                     : out std_logic;
         usr_cfg_di                             : in std_logic_vector(31 downto 0);
         usr_cfg_byte_en                        : in std_logic_vector(3 downto 0);
         usr_cfg_dwaddr                         : in std_logic_vector(9 downto 0);
         usr_cfg_wr_en                          : in std_logic;
         usr_cfg_wr_rw1c_as_rw                  : in std_logic;
         usr_cfg_rd_en                          : in std_logic;
         rport_pl_link_gen2_capable             : in std_logic
      );
   end component;


   -- Connections between Root Port and Configurator
   signal rport_s_axis_tx_tlast                 : std_logic;
   signal rport_s_axis_tx_tdata                 : std_logic_vector((C_DATA_WIDTH-1) downto 0);
   signal rport_s_axis_tx_tkeep                 : std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
   signal rport_s_axis_tx_tvalid                : std_logic;
   signal rport_s_axis_tx_tready                : std_logic;
   signal rport_s_axis_tx_tuser                 : std_logic_vector (3 downto 0);

   signal rport_tx_cfg_req                      : std_logic;
   signal rport_tx_cfg_gnt                      : std_logic;
   signal rport_tx_err_drop                     : std_logic;
   signal rport_tx_buf_av                       : std_logic_vector(5 downto 0);

   signal rport_m_axis_rx_tlast                 : std_logic;
   signal rport_m_axis_rx_tdata                 : std_logic_vector((C_DATA_WIDTH-1) downto 0);
   signal rport_m_axis_rx_tkeep                 : std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
   signal rport_m_axis_rx_tvalid                : std_logic;
   signal rport_m_axis_rx_tready                : std_logic;
   signal rport_m_axis_rx_tuser                 : std_logic_vector (21 downto 0);
   signal rport_rx_np_ok                        : std_logic;
   signal rport_rx_np_req                       : std_logic;

   signal rport_cfg_do                          : std_logic_vector(31 downto 0);
   signal rport_cfg_rd_wr_done                  : std_logic;
   signal rport_cfg_di                          : std_logic_vector(31 downto 0);
   signal rport_cfg_byte_en                     : std_logic_vector(3 downto 0);
   signal rport_cfg_dwaddr                      : std_logic_vector(9 downto 0);
   signal rport_cfg_wr_en                       : std_logic;
   signal rport_cfg_wr_rw1c_as_rw               : std_logic;
   signal rport_cfg_rd_en                       : std_logic;
   -- X-HDL generated signals

   -- signal sys_reset : std_logic;

   -- Declare intermediate signals for referenced outputs
   signal user_clk_out_int                      : std_logic;
   signal user_reset_out_int                    : std_logic;
   signal pl_link_gen2_capable_int              : std_logic;


   -- Tie offs for external clocking inputs
   signal PIPE_PCLK_IN                          : std_logic;
   signal PIPE_RXUSRCLK_IN                      : std_logic;
   signal PIPE_RXOUTCLK_IN                      : std_logic_vector(0 downto 0);
   signal PIPE_DCLK_IN                          : std_logic;
   signal PIPE_USERCLK1_IN                      : std_logic;
   signal PIPE_USERCLK2_IN                      : std_logic;
   signal PIPE_OOBCLK_IN                        : std_logic;
   signal PIPE_MMCM_LOCK_IN                     : std_logic;

begin

   -- Drive referenced outputs
   user_clk_out <= user_clk_out_int;
   user_reset_out <= user_reset_out_int;
   pl_link_gen2_capable <= pl_link_gen2_capable_int;

   -- sys_reset <= not(sys_reset_n);

   PIPE_PCLK_IN      <= '0';
   PIPE_RXUSRCLK_IN  <= '0';
   PIPE_RXOUTCLK_IN  <= (others => '0');
   PIPE_DCLK_IN      <= '0';
   PIPE_USERCLK1_IN  <= '0';
   PIPE_USERCLK2_IN  <= '0';
   PIPE_OOBCLK_IN    <= '0';
   PIPE_MMCM_LOCK_IN <= '0';

   --
   -- Instantiate Root Port wrapper
   --


   rport : pcie_7x_v1_9      generic map (
         PCIE_EXT_CLK                    => "FALSE",
         PL_FAST_TRAIN                   => PL_FAST_TRAIN,
         C_DATA_WIDTH                    => C_DATA_WIDTH
      )
      port map (
         ---------------------------------------------------------
         -- 1. PCI Express (pci_exp) Interface
         ---------------------------------------------------------
         -- Tx
         pci_exp_txp                     => pci_exp_txp,
         pci_exp_txn                     => pci_exp_txn,

         -- Rx
         pci_exp_rxp                     => pci_exp_rxp,
         pci_exp_rxn                     => pci_exp_rxn,

         ------------------------------------------------------------------------------------------------------
         -- 2. Clocking Interface - For Partial Reconfig Support                                             --
         ------------------------------------------------------------------------------------------------------
         PIPE_PCLK_IN                    => PIPE_PCLK_IN,
         PIPE_RXUSRCLK_IN                => PIPE_RXUSRCLK_IN,
         PIPE_RXOUTCLK_IN                => PIPE_RXOUTCLK_IN,
         PIPE_DCLK_IN                    => PIPE_DCLK_IN,
         PIPE_USERCLK1_IN                => PIPE_USERCLK1_IN,
         PIPE_USERCLK2_IN                => PIPE_USERCLK2_IN,
         PIPE_OOBCLK_IN                  => PIPE_OOBCLK_IN,
         PIPE_MMCM_LOCK_IN               => PIPE_MMCM_LOCK_IN,

         PIPE_TXOUTCLK_OUT               => open,
         PIPE_RXOUTCLK_OUT               => open,
         PIPE_PCLK_SEL_OUT               => open,
         PIPE_GEN3_OUT                   => open,

         ------------------------------------------------------------------------------------------------------
         -- 3. AXI-S Interface                                                                               --
         ------------------------------------------------------------------------------------------------------

         -- Common
         user_clk_out                    => user_clk_out_int,
         user_reset_out                  => user_reset_out_int,
         user_lnk_up                     => user_lnk_up,

         -- Tx
         tx_buf_av                       => rport_tx_buf_av,
         tx_cfg_req                      => rport_tx_cfg_req,
         tx_err_drop                     => rport_tx_err_drop,
         s_axis_tx_tready                => rport_s_axis_tx_tready,
         s_axis_tx_tdata                 => rport_s_axis_tx_tdata,
         s_axis_tx_tkeep                 => rport_s_axis_tx_tkeep,
         s_axis_tx_tlast                 => rport_s_axis_tx_tlast,
         s_axis_tx_tvalid                => rport_s_axis_tx_tvalid,
         s_axis_tx_tuser                 => rport_s_axis_tx_tuser,
         tx_cfg_gnt                      => rport_tx_cfg_gnt,

         -- Rx
         m_axis_rx_tdata                 => rport_m_axis_rx_tdata,
         m_axis_rx_tkeep                 => rport_m_axis_rx_tkeep,
         m_axis_rx_tlast                 => rport_m_axis_rx_tlast,
         m_axis_rx_tvalid                => rport_m_axis_rx_tvalid,
         m_axis_rx_tready                => rport_m_axis_rx_tready,
         m_axis_rx_tuser                 => rport_m_axis_rx_tuser,
         rx_np_ok                        => rport_rx_np_ok,
         rx_np_req                       => rport_rx_np_req,

         -- Flow Control
         fc_cpld                         => fc_cpld,
         fc_cplh                         => fc_cplh,
         fc_npd                          => fc_npd,
         fc_nph                          => fc_nph,
         fc_pd                           => fc_pd,
         fc_ph                           => fc_ph,
         fc_sel                          => fc_sel,

         ---------------------------------------------------------
         -- 3. Configuration (CFG) Interface
         ---------------------------------------------------------

         cfg_mgmt_do                     => rport_cfg_do,
         cfg_mgmt_rd_wr_done             => rport_cfg_rd_wr_done,

         cfg_status                      => cfg_status,
         cfg_command                     => cfg_command,
         cfg_dstatus                     => cfg_dstatus,
         cfg_dcommand                    => cfg_dcommand,
         cfg_lstatus                     => cfg_lstatus,
         cfg_lcommand                    => cfg_lcommand,
         cfg_dcommand2                   => cfg_dcommand2,
         cfg_pcie_link_state             => cfg_pcie_link_state,

         cfg_pmcsr_pme_en                => cfg_pmcsr_pme_en,
         cfg_pmcsr_powerstate            => cfg_pmcsr_powerstate,
         cfg_pmcsr_pme_status            => cfg_pmcsr_pme_status,
         cfg_received_func_lvl_rst       => cfg_received_func_lvl_rst,

         -- Management Interface
         cfg_mgmt_di                     => rport_cfg_di,
         cfg_mgmt_byte_en                => rport_cfg_byte_en,
         cfg_mgmt_dwaddr                 => rport_cfg_dwaddr,
         cfg_mgmt_wr_en                  => rport_cfg_wr_en,
         cfg_mgmt_rd_en                  => rport_cfg_rd_en,
         cfg_mgmt_wr_readonly            => cfg_wr_readonly,

         -- Error Reporting Interface
         cfg_err_ecrc                    => cfg_err_ecrc,
         cfg_err_ur                      => cfg_err_ur,
         cfg_err_cpl_timeout             => cfg_err_cpl_timeout,
         cfg_err_cpl_unexpect            => cfg_err_cpl_unexpect,
         cfg_err_cpl_abort               => cfg_err_cpl_abort,
         cfg_err_posted                  => cfg_err_posted,
         cfg_err_cor                     => cfg_err_cor,
         cfg_err_atomic_egress_blocked   => cfg_err_atomic_egress_blocked,
         cfg_err_internal_cor            => cfg_err_internal_cor,
         cfg_err_malformed               => cfg_err_malformed,
         cfg_err_mc_blocked              => cfg_err_mc_blocked,
         cfg_err_poisoned                => cfg_err_poisoned,
         cfg_err_norecovery              => cfg_err_norecovery,
         cfg_err_tlp_cpl_header          => cfg_err_tlp_cpl_header,
         cfg_err_cpl_rdy                 => cfg_err_cpl_rdy,
         cfg_err_locked                  => cfg_err_locked,
         cfg_err_acs                     => cfg_err_acs,
         cfg_err_internal_uncor          => cfg_err_internal_uncor,
         cfg_trn_pending                 => cfg_trn_pending,
         cfg_pm_halt_aspm_l0s            => cfg_pm_halt_aspm_l0s,
         cfg_pm_halt_aspm_l1             => cfg_pm_halt_aspm_l1,
         cfg_pm_force_state_en           => cfg_pm_force_state_en,
         cfg_pm_force_state              => cfg_pm_force_state,
         cfg_dsn                         => cfg_dsn,

        ---------------------------------------------------------------------
         -- EP Only                                                        --
        ---------------------------------------------------------------------
         cfg_interrupt                   => cfg_interrupt,
         cfg_interrupt_rdy               => cfg_interrupt_rdy,
         cfg_interrupt_assert            => cfg_interrupt_assert,
         cfg_interrupt_di                => cfg_interrupt_di,
         cfg_interrupt_do                => cfg_interrupt_do,
         cfg_interrupt_mmenable          => cfg_interrupt_mmenable,
         cfg_interrupt_msienable         => cfg_interrupt_msienable,
         cfg_interrupt_msixenable        => cfg_interrupt_msixenable,
         cfg_interrupt_msixfm            => cfg_interrupt_msixfm,
         cfg_interrupt_stat              => cfg_interrupt_stat,
         cfg_pciecap_interrupt_msgnum    => cfg_pciecap_interrupt_msgnum,
         cfg_to_turnoff                  => cfg_to_turnoff,
         cfg_turnoff_ok                  => cfg_turnoff_ok,
         cfg_bus_number                  => cfg_bus_number,
         cfg_device_number               => cfg_device_number,
         cfg_function_number             => cfg_function_number,
         cfg_pm_wake                     => cfg_pm_wake,

        ---------------------------------------------------------------------
         -- RP Only                                                        --
        ---------------------------------------------------------------------
         cfg_pm_send_pme_to              => cfg_pm_send_pme_to,
         cfg_ds_bus_number               => cfg_ds_bus_number,
         cfg_ds_device_number            => cfg_ds_device_number,
         cfg_ds_function_number          => cfg_ds_function_number,

         cfg_mgmt_wr_rw1c_as_rw          => rport_cfg_wr_rw1c_as_rw,

         cfg_msg_received                => cfg_msg_received,
         cfg_msg_data                    => cfg_msg_data,

         cfg_bridge_serr_en                         => cfg_bridge_serr_en,
         cfg_slot_control_electromech_il_ctl_pulse  => cfg_slot_control_electromech_il_ctl_pulse,
         cfg_root_control_syserr_corr_err_en        => cfg_root_control_syserr_corr_err_en,
         cfg_root_control_syserr_non_fatal_err_en   => cfg_root_control_syserr_non_fatal_err_en,
         cfg_root_control_syserr_fatal_err_en       => cfg_root_control_syserr_fatal_err_en,
         cfg_root_control_pme_int_en                => cfg_root_control_pme_int_en,
         cfg_aer_rooterr_corr_err_reporting_en      => cfg_aer_rooterr_corr_err_reporting_en,
         cfg_aer_rooterr_non_fatal_err_reporting_en => cfg_aer_rooterr_non_fatal_err_reporting_en,
         cfg_aer_rooterr_fatal_err_reporting_en     => cfg_aer_rooterr_fatal_err_reporting_en,
         cfg_aer_rooterr_corr_err_received          => cfg_aer_rooterr_corr_err_received,
         cfg_aer_rooterr_non_fatal_err_received     => cfg_aer_rooterr_non_fatal_err_received,
         cfg_aer_rooterr_fatal_err_received         => cfg_aer_rooterr_fatal_err_received,

         cfg_msg_received_err_cor        => cfg_msg_received_err_cor,
         cfg_msg_received_err_non_fatal  => cfg_msg_received_err_non_fatal,
         cfg_msg_received_err_fatal      => cfg_msg_received_err_fatal,
         cfg_msg_received_pm_as_nak      => cfg_msg_received_pm_as_nak,
         cfg_msg_received_pm_pme         => cfg_msg_received_pm_pme,
         cfg_msg_received_pme_to_ack     => cfg_msg_received_pme_to_ack,
         cfg_msg_received_assert_int_a   => cfg_msg_received_assert_inta,
         cfg_msg_received_assert_int_b   => cfg_msg_received_assert_intb,
         cfg_msg_received_assert_int_c   => cfg_msg_received_assert_intc,
         cfg_msg_received_assert_int_d   => cfg_msg_received_assert_intd,
         cfg_msg_received_deassert_int_a => cfg_msg_received_deassert_inta,
         cfg_msg_received_deassert_int_b => cfg_msg_received_deassert_intb,
         cfg_msg_received_deassert_int_c => cfg_msg_received_deassert_intc,
         cfg_msg_received_deassert_int_d => cfg_msg_received_deassert_intd,
         cfg_msg_received_setslotpowerlimit => cfg_msg_received_setslotpowerlimit,

        -----------------------------------------------------------------------------------------------------------
        -- 5. Physical Layer Control and Status (PL) Interface                                                   --
        -----------------------------------------------------------------------------------------------------------
         pl_directed_link_change         => pl_directed_link_change,
         pl_directed_link_width          => pl_directed_link_width,
         pl_directed_link_speed          => pl_directed_link_speed,
         pl_directed_link_auton          => pl_directed_link_auton,
         pl_upstream_prefer_deemph       => pl_upstream_prefer_deemph,

         pl_sel_lnk_rate                 => pl_sel_link_rate,
         pl_sel_lnk_width                => pl_sel_link_width,
         pl_ltssm_state                  => pl_ltssm_state,
         pl_lane_reversal_mode           => pl_lane_reversal_mode,

         pl_phy_lnk_up                   => pl_phy_lnk_up,
         pl_tx_pm_state                  => pl_tx_pm_state,
         pl_rx_pm_state                  => pl_rx_pm_state,

         pl_link_upcfg_cap               => pl_link_upcfg_capable,
         pl_link_gen2_cap                => pl_link_gen2_capable_int,
         pl_link_partner_gen2_supported  => pl_link_partner_gen2_supported,
         pl_initial_link_width           => pl_initial_link_width,

         pl_directed_change_done         => pl_directed_change_done,

        ---------------------------------------------------------------------
         -- EP Only                                                        --
        ---------------------------------------------------------------------
         pl_received_hot_rst             => pl_received_hot_rst,
        ---------------------------------------------------------------------
         -- RP Only                                                        --
        ---------------------------------------------------------------------
         pl_transmit_hot_rst             => pl_transmit_hot_rst,
         pl_downstream_deemph_source     => pl_downstream_deemph_source,
        -----------------------------------------------------------------------------------------------------------
        -- 6. AER interface                                                                                      --
        -----------------------------------------------------------------------------------------------------------
         cfg_err_aer_headerlog           => cfg_err_aer_headerlog,
         cfg_aer_interrupt_msgnum        => cfg_aer_interrupt_msgnum,
         cfg_err_aer_headerlog_set       => cfg_err_aer_headerlog_set,
         cfg_aer_ecrc_check_en           => cfg_aer_ecrc_check_en,
         cfg_aer_ecrc_gen_en             => cfg_aer_ecrc_gen_en,
        -----------------------------------------------------------------------------------------------------------
        -- 7. VC interface                                                                                       --
        -----------------------------------------------------------------------------------------------------------
         cfg_vc_tcvc_map                 => cfg_vc_tcvc_map,

         ---------------------------------------------------------
         -- 8. System  (SYS) Interface
         ---------------------------------------------------------
         PIPE_MMCM_RST_N                 => PIPE_MMCM_RST_N,        -- Async      | Async
         sys_clk                         => sys_clk,
         sys_rst_n                       => sys_rst_n
      );

   --
   -- Instantiate Configurator design
   --

   -- globals
   cgator_i : cgator
      generic map (
         TCQ                   => TCQ,
         EXTRA_PIPELINE        => EXTRA_PIPELINE,
         ROM_SIZE              => ROM_SIZE,
         ROM_FILE              => ROM_FILE,
         REQUESTER_ID          => REQUESTER_ID,
         C_DATA_WIDTH          => C_DATA_WIDTH,
         KEEP_WIDTH            => KEEP_WIDTH
      )
      port map (
         user_clk                        => user_clk_out_int,
         reset                           => user_reset_out_int,

         -- User interface for configuration
         start_config                    => start_config,
         finished_config                 => finished_config,
         failed_config                   => failed_config,

         -- Rport AXI interfaces
         rport_s_axis_tx_tlast           => rport_s_axis_tx_tlast,
         rport_s_axis_tx_tdata           => rport_s_axis_tx_tdata,
         rport_s_axis_tx_tkeep           => rport_s_axis_tx_tkeep,
         rport_s_axis_tx_tvalid          => rport_s_axis_tx_tvalid,
         rport_s_axis_tx_tready          => rport_s_axis_tx_tready,
         rport_s_axis_tx_tuser           => rport_s_axis_tx_tuser,
         rport_tx_cfg_req                => rport_tx_cfg_req,
         rport_tx_cfg_gnt                => rport_tx_cfg_gnt,
         rport_tx_buf_av                 => rport_tx_buf_av,
         rport_tx_err_drop               => rport_tx_err_drop,

         rport_m_axis_rx_tlast           => rport_m_axis_rx_tlast,
         rport_m_axis_rx_tdata           => rport_m_axis_rx_tdata,
         rport_m_axis_rx_tkeep           => rport_m_axis_rx_tkeep,
         rport_m_axis_rx_tvalid          => rport_m_axis_rx_tvalid,
         rport_m_axis_rx_tready          => rport_m_axis_rx_tready,
         rport_m_axis_rx_tuser           => rport_m_axis_rx_tuser,
         rport_rx_np_ok                  => rport_rx_np_ok,

         -- User AXI interfaces

         -- TX
         usr_s_axis_tx_tlast             => s_axis_tx_tlast,
         usr_s_axis_tx_tdata             => s_axis_tx_tdata,
         usr_s_axis_tx_tkeep             => s_axis_tx_tkeep,
         usr_s_axis_tx_tuser             => s_axis_tx_tuser,
         usr_s_axis_tx_tvalid            => s_axis_tx_tvalid,
         usr_s_axis_tx_tready            => s_axis_tx_tready,
         usr_tx_cfg_req                  => tx_cfg_req,
         usr_tx_cfg_gnt                  => tx_cfg_gnt,
         usr_tx_buf_av                   => tx_buf_av,
         usr_tx_err_drop                 => tx_err_drop,

         -- RX
         usr_m_axis_rx_tlast             => m_axis_rx_tlast,
         usr_m_axis_rx_tdata             => m_axis_rx_tdata,
         usr_m_axis_rx_tkeep             => m_axis_rx_tkeep,
         usr_m_axis_rx_tvalid            => m_axis_rx_tvalid,
         usr_m_axis_rx_tuser             => m_axis_rx_tuser,


         -- Rport CFG interface
         rport_cfg_do                    => rport_cfg_do,
         rport_cfg_rd_wr_done            => rport_cfg_rd_wr_done,
         rport_cfg_di                    => rport_cfg_di,
         rport_cfg_byte_en               => rport_cfg_byte_en,
         rport_cfg_dwaddr                => rport_cfg_dwaddr,
         rport_cfg_wr_en                 => rport_cfg_wr_en,
         rport_cfg_wr_rw1c_as_rw         => rport_cfg_wr_rw1c_as_rw,
         rport_cfg_rd_en                 => rport_cfg_rd_en,

         -- User CFG interface
         usr_cfg_do                      => cfg_do,
         usr_cfg_rd_wr_done              => cfg_rd_wr_done,
         usr_cfg_di                      => cfg_di,
         usr_cfg_byte_en                 => cfg_byte_en,
         usr_cfg_dwaddr                  => cfg_dwaddr,
         usr_cfg_wr_en                   => cfg_wr_en,
         usr_cfg_wr_rw1c_as_rw           => cfg_wr_rw1c_as_rw,
         usr_cfg_rd_en                   => cfg_rd_en,

         -- Rport PL interface
         rport_pl_link_gen2_capable      => pl_link_gen2_capable_int
      );

end sevenx_pcie;

-- cgator_wrapper
