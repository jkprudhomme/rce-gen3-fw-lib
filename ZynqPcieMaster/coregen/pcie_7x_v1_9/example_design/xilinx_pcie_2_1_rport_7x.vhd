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
-- File       : xilinx_pcie_2_1_rport_7x.vhd
-- Version    : 1.9
--
-- Description : Configurator Controller module - directs configuration of
--               Endpoint connected to the local Root Port. Configuration
--               steps are read from the file specified by the ROM_FILE
--               parameter. This module directs the Packet Generator module to
--               create downstream TLPs and receives decoded Completion TLP
--               information from the Completion Decoder module. Additionally,
--               in a Gen2-speec-capable system, the Gen2 Enabler module
--               directs the Root Port block to up-configure the link after
--               Link Training completes.
--
-- Hierarchy   : xilinx_pcie_2_1_rport_7x
--               |
--               |--cgator_wrapper
--               |  |
--               |  |--pcie_2_1_rport_7x (in source directory)
--               |  |  |
--               |  |  |--<various>
--               |  |
--               |  |--cgator
--               |     |
--               |     |--cgator_cpl_decoder
--               |     |--cgator_pkt_generator
--               |     |--cgator_tx_mux
--               |     |--cgator_gen2_enabler
--               |     |--cgator_controller
--               |        |--<cgator_cfg_rom.data> (specified by ROM_FILE)
--               |
--               |--pio_master
--                  |
--                  |--pio_master_controller
--                  |--pio_master_checker
--                  |--pio_master_pkt_generator
-------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;
   use ieee.std_logic_textio.all;
   use ieee.std_logic_arith.all;

library std;
use std.textio.all;

library unisim;
use unisim.vcomponents.all;

entity xilinx_pcie_2_1_rport_7x is

  generic (
    TCQ                          : integer := 1;
    SIMULATION                   : integer := 0;
    PL_FAST_TRAIN                : string  := "FALSE";
    ROM_FILE                     : string  := "cgator_cfg_rom.data";
    ROM_SIZE                     : integer := 32;
    REF_CLK_FREQ                 : integer := 0;                        -- 0 - 100 MHz, 1 - 125 MHz, 2 - 250 MHz;
    USER_CLK_FREQ                : integer := 1;
    C_DATA_WIDTH                 : integer := 64;
    LINK_CTRL2_TARGET_LINK_SPEED : bit_vector := X"0"
  );
  port (
    -- Board-level reference clock
    sys_clk_p       : in  std_logic;
    sys_clk_n       : in  std_logic;

    -- Free-running clock needed for link-retrain button
    free_clk        : in  std_logic;

    -- System-level reset input
    sys_rst_n       : in  std_logic;

    -- PCI Express interface
    RXN             : in  std_logic_vector(0 downto 0);
    RXP             : in  std_logic_vector(0 downto 0);
    TXN             : out std_logic_vector(0 downto 0);
    TXP             : out std_logic_vector(0 downto 0);

    -- Status outputs
    led_2           : out std_logic;  -- user_lnk_up
    led_3           : out std_logic;  -- pio_test_finished
    led_4           : out std_logic;  -- finished_config
    led_5           : out std_logic;  -- failed_config OR pio_test_failed
    led_6           : out std_logic;  -- pl_sel_link_rate

    -- Control inputs
    link_retrain_sw : in  std_logic;
    pio_restart_sw  : in  std_logic;
    full_test_sw    : in  std_logic);
end xilinx_pcie_2_1_rport_7x;

architecture rtl of xilinx_pcie_2_1_rport_7x is

  component cgator_wrapper
    generic (
      -- Configurator parameters
      TCQ                                       : integer;
      EXTRA_PIPELINE                            : integer;
      ROM_FILE                                  : string ;
      ROM_SIZE                                  : integer;
      PL_FAST_TRAIN                             : string;
      C_DATA_WIDTH                              : integer;
      KEEP_WIDTH                                : integer
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
      -- Common
      user_clk_out                              : out std_logic;
      user_reset_out                            : out std_logic;
      user_lnk_up                               : out std_logic;

      -- Tx
      tx_buf_av                                 : out std_logic_vector(5 downto 0);
      tx_err_drop                               : out std_logic;
      tx_cfg_req                                : out std_logic;
      s_axis_tx_tready                          : out std_logic;
      s_axis_tx_tdata                           : in std_logic_vector((C_DATA_WIDTH-1) downto 0);
      s_axis_tx_tuser                           : in std_logic_vector (3 downto 0);
      s_axis_tx_tkeep                           : in std_logic_vector((C_DATA_WIDTH/8 - 1) downto 0);
      s_axis_tx_tlast                           : in std_logic;
      s_axis_tx_tvalid                          : in std_logic;
      tx_cfg_gnt                                : in std_logic;


      -- Rx
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
      fc_sel                                    : in std_logic_vector(2 downto 0);

     -----------------------------------------------------------------------------------------------------------
     -- 3. Configuration (CFG) Interface                                                                      --
     -----------------------------------------------------------------------------------------------------------
     ---------------------------------------------------------------------
      -- EP and RP                                                      --
     ---------------------------------------------------------------------
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
      cfg_di                                    : in  std_logic_vector(31 downto 0);
      cfg_byte_en                               : in  std_logic_vector(3 downto 0);
      cfg_dwaddr                                : in  std_logic_vector(9 downto 0);
      cfg_wr_en                                 : in  std_logic;
      cfg_rd_en                                 : in  std_logic;
      cfg_wr_readonly                           : in std_logic;

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
      pl_directed_link_change                   : in  std_logic_vector(1 downto 0);
      pl_directed_link_width                    : in  std_logic_vector(1 downto 0);
      pl_directed_link_speed                    : in  std_logic;
      pl_directed_link_auton                    : in  std_logic;
      pl_upstream_prefer_deemph                 : in  std_logic;

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
      -- EP Only                                                        --
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
      sys_clk                                   : in  std_logic;
      sys_rst_n                                 : in  std_logic);

  end component;

  component pio_master
    generic (
      TCQ           : integer;
      BAR_A_ENABLED : integer;
      BAR_A_64BIT   : integer;
      BAR_A_IO      : integer;
      BAR_A_BASE    : std_logic_vector(63 downto 0);
      BAR_A_SIZE    : integer;
      BAR_B_ENABLED : integer;
      BAR_B_64BIT   : integer;
      BAR_B_IO      : integer;
      BAR_B_BASE    : std_logic_vector(63 downto 0);
      BAR_B_SIZE    : integer;
      BAR_C_ENABLED : integer;
      BAR_C_64BIT   : integer;
      BAR_C_IO      : integer;
      BAR_C_BASE    : std_logic_vector(63 downto 0);
      BAR_C_SIZE    : integer;
      BAR_D_ENABLED : integer;
      BAR_D_64BIT   : integer;
      BAR_D_IO      : integer;
      BAR_D_BASE    : std_logic_vector(63 downto 0);
      BAR_D_SIZE    : integer;
      C_DATA_WIDTH  : integer;
      KEEP_WIDTH    : integer
      );
    port (
      user_clk                                     : in  std_logic;
      reset                                        : in  std_logic;
      user_lnk_up                                  : in  std_logic;

      -- System information
      pio_test_restart                             : in  std_logic;
      pio_test_long                                : in  std_logic;   -- Unused for now
      pio_test_finished                            : out std_logic;
      pio_test_failed                              : out std_logic;

      -- Control configuration process
      start_config                                 : out std_logic;
      finished_config                              : in  std_logic;
      failed_config                                : in  std_logic;

      link_gen2_capable                            : in  std_logic;
      link_gen2                                    : in  std_logic;

      -- TRN interfaces
      s_axis_tx_tlast                              : out std_logic;
      s_axis_tx_tdata                              : out std_logic_vector((C_DATA_WIDTH-1) downto 0);
      s_axis_tx_tkeep                              : out std_logic_vector((C_DATA_WIDTH/8 - 1) downto 0);
      s_axis_tx_tvalid                             : out std_logic;
      s_axis_tx_tready                             : in  std_logic;
      s_axis_tx_tuser                              : out std_logic_vector(3 downto 0);

      tx_cfg_req                                   : in  std_logic;
      tx_cfg_gnt                                   : out std_logic;
      tx_buf_av                                    : in  std_logic_vector(5 downto 0);

      m_axis_rx_tlast                              : in  std_logic;
      m_axis_rx_tdata                              : in  std_logic_vector((C_DATA_WIDTH-1) downto 0);
      m_axis_rx_tkeep                              : in  std_logic_vector((C_DATA_WIDTH/8 - 1) downto 0);
      m_axis_rx_tvalid                             : in  std_logic;
      m_axis_rx_tuser                              : in  std_logic_vector (21 downto 0));
  end component;

   ---------------------------------------------------------
   -- 0. Configurator Control/Status Interface
   ---------------------------------------------------------

   signal start_config                                : std_logic;
   signal finished_config                             : std_logic;
   signal failed_config                               : std_logic;

   ----------------------------------------------------------------------------------------------------------
   -- 1. PCI Express (pci_exp) Interface                                                                   --
   ----------------------------------------------------------------------------------------------------------
   signal pci_exp_txp                                 : std_logic_vector(0 downto 0);
   signal pci_exp_txn                                 : std_logic_vector(0 downto 0);
   signal pci_exp_rxp                                 : std_logic_vector(0 downto 0);
   signal pci_exp_rxn                                 : std_logic_vector(0 downto 0);

    -----------------------------------------------------------------------------------------------------------
    -- 2. AXI-S Interface                                                                                    --
    -----------------------------------------------------------------------------------------------------------
   signal user_clk                                    : std_logic;
   signal user_reset                                  : std_logic;
   signal user_lnk_up                                 : std_logic;

     -- TX
   signal tx_buf_av                                   : std_logic_vector(5 downto 0);
   signal tx_cfg_req                                  : std_logic;
   signal tx_err_drop                                 : std_logic;
   signal s_axis_tx_tready                            : std_logic;
   signal s_axis_tx_tdata                             : std_logic_vector((C_DATA_WIDTH-1) downto 0);
   signal s_axis_tx_tkeep                             : std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
   signal s_axis_tx_tlast                             : std_logic;
   signal s_axis_tx_tvalid                            : std_logic;
   signal s_axis_tx_tuser                             : std_logic_vector (3 downto 0);
   signal tx_cfg_gnt                                  : std_logic;

     -- RX
   signal m_axis_rx_tdata                             : std_logic_vector((C_DATA_WIDTH-1) downto 0);
   signal m_axis_rx_tkeep                             : std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
   signal m_axis_rx_tlast                             : std_logic;
   signal m_axis_rx_tvalid                            : std_logic;
   signal m_axis_rx_tuser                             : std_logic_vector(21 downto 0);

     -- Flow Control
   signal fc_cpld                                     : std_logic_vector(11 downto 0);
   signal fc_cplh                                     : std_logic_vector(7 downto 0);
   signal fc_npd                                      : std_logic_vector(11 downto 0);
   signal fc_nph                                      : std_logic_vector(7 downto 0);
   signal fc_pd                                       : std_logic_vector(11 downto 0);
   signal fc_ph                                       : std_logic_vector(7 downto 0);
   signal fc_sel                                      : std_logic_vector(2 downto 0);

   -----------------------------------------------------------------------------------------------------------
   -- 3. Configuration (CFG) Interface                                                                      --
   -----------------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------
    -- EP and RP                                                      --
   ---------------------------------------------------------------------
   signal cfg_do                                      : std_logic_vector(31 downto 0);
   signal cfg_rd_wr_done                              : std_logic;

   signal cfg_status                                  : std_logic_vector(15 downto 0);
   signal cfg_command                                 : std_logic_vector(15 downto 0);
   signal cfg_dstatus                                 : std_logic_vector(15 downto 0);
   signal cfg_dcommand                                : std_logic_vector(15 downto 0);
   signal cfg_lstatus                                 : std_logic_vector(15 downto 0);
   signal cfg_lcommand                                : std_logic_vector(15 downto 0);
   signal cfg_dcommand2                               : std_logic_vector(15 downto 0);
   signal cfg_pcie_link_state                         : std_logic_vector(2 downto 0);

   signal cfg_pmcsr_pme_en                            : std_logic;
   signal cfg_pmcsr_powerstate                        : std_logic_vector(1 downto 0);
   signal cfg_pmcsr_pme_status                        : std_logic;
   signal cfg_received_func_lvl_rst                   : std_logic;

     -- Management Interface
   signal cfg_di                                      : std_logic_vector(31 downto 0);
   signal cfg_byte_en                                 : std_logic_vector(3 downto 0);
   signal cfg_dwaddr                                  : std_logic_vector(9 downto 0);
   signal cfg_wr_en                                   : std_logic;
   signal cfg_rd_en                                   : std_logic;
   signal cfg_wr_readonly                             : std_logic;

     -- Error Reporting Interface
   signal cfg_err_ecrc                                : std_logic;
   signal cfg_err_ur                                  : std_logic;
   signal cfg_err_cpl_timeout                         : std_logic;
   signal cfg_err_cpl_unexpect                        : std_logic;
   signal cfg_err_cpl_abort                           : std_logic;
   signal cfg_err_posted                              : std_logic;
   signal cfg_err_cor                                 : std_logic;
   signal cfg_err_atomic_egress_blocked               : std_logic;
   signal cfg_err_internal_cor                        : std_logic;
   signal cfg_err_malformed                           : std_logic;
   signal cfg_err_mc_blocked                          : std_logic;
   signal cfg_err_poisoned                            : std_logic;
   signal cfg_err_norecovery                          : std_logic;
   signal cfg_err_tlp_cpl_header                      : std_logic_vector(47 downto 0);
   signal cfg_err_cpl_rdy                             : std_logic;
   signal cfg_err_locked                              : std_logic;
   signal cfg_err_acs                                 : std_logic;
   signal cfg_err_internal_uncor                      : std_logic;
   signal cfg_trn_pending                             : std_logic;
   signal cfg_pm_halt_aspm_l0s                        : std_logic;
   signal cfg_pm_halt_aspm_l1                         : std_logic;
   signal cfg_pm_force_state_en                       : std_logic;
   signal cfg_pm_force_state                          : std_logic_vector(1 downto 0);
   signal cfg_dsn                                     : std_logic_vector(63 downto 0);

   ---------------------------------------------------------------------
    -- EP Only                                                        --
   ---------------------------------------------------------------------
   signal cfg_interrupt                               : std_logic;
   signal cfg_interrupt_rdy                           : std_logic;
   signal cfg_interrupt_assert                        : std_logic;
   signal cfg_interrupt_di                            : std_logic_vector(7 downto 0);
   signal cfg_interrupt_do                            : std_logic_vector(7 downto 0);
   signal cfg_interrupt_mmenable                      : std_logic_vector(2 downto 0);
   signal cfg_interrupt_msienable                     : std_logic;
   signal cfg_interrupt_msixenable                    : std_logic;
   signal cfg_interrupt_msixfm                        : std_logic;

   signal cfg_interrupt_stat                          : std_logic;
   signal cfg_pciecap_interrupt_msgnum                : std_logic_vector(4 downto 0);
   signal cfg_to_turnoff                              : std_logic;
   signal cfg_turnoff_ok                              : std_logic;
   signal cfg_bus_number                              : std_logic_vector(7 downto 0);
   signal cfg_device_number                           : std_logic_vector(4 downto 0);
   signal cfg_function_number                         : std_logic_vector(2 downto 0);
   signal cfg_pm_wake                                 : std_logic;

   ---------------------------------------------------------------------
    -- RP Only                                                        --
   ---------------------------------------------------------------------
   signal cfg_pm_send_pme_to                          : std_logic;
   signal cfg_ds_bus_number                           : std_logic_vector(7 downto 0);
   signal cfg_ds_device_number                        : std_logic_vector(4 downto 0);
   signal cfg_ds_function_number                      : std_logic_vector(2 downto 0);

   signal cfg_wr_rw1c_as_rw                      : std_logic;
   signal cfg_msg_received                            : std_logic;
   signal cfg_msg_data                                : std_logic_vector(15 downto 0);

   signal cfg_bridge_serr_en                          : std_logic;
   signal cfg_slot_control_electromech_il_ctl_pulse   : std_logic;
   signal cfg_root_control_syserr_corr_err_en         : std_logic;
   signal cfg_root_control_syserr_non_fatal_err_en    : std_logic;
   signal cfg_root_control_syserr_fatal_err_en        : std_logic;
   signal cfg_root_control_pme_int_en                 : std_logic;
   signal cfg_aer_rooterr_corr_err_reporting_en       : std_logic;
   signal cfg_aer_rooterr_non_fatal_err_reporting_en  : std_logic;
   signal cfg_aer_rooterr_fatal_err_reporting_en      : std_logic;
   signal cfg_aer_rooterr_corr_err_received           : std_logic;
   signal cfg_aer_rooterr_non_fatal_err_received      : std_logic;
   signal cfg_aer_rooterr_fatal_err_received          : std_logic;

   signal cfg_msg_received_err_cor                    : std_logic;
   signal cfg_msg_received_err_non_fatal              : std_logic;
   signal cfg_msg_received_err_fatal                  : std_logic;
   signal cfg_msg_received_pm_as_nak                  : std_logic;
   signal cfg_msg_received_pm_pme                     : std_logic;
   signal cfg_msg_received_pme_to_ack                 : std_logic;
   signal cfg_msg_received_assert_inta                : std_logic;
   signal cfg_msg_received_assert_intb                : std_logic;
   signal cfg_msg_received_assert_intc                : std_logic;
   signal cfg_msg_received_assert_intd                : std_logic;
   signal cfg_msg_received_deassert_inta              : std_logic;
   signal cfg_msg_received_deassert_intb              : std_logic;
   signal cfg_msg_received_deassert_intc              : std_logic;
   signal cfg_msg_received_deassert_intd              : std_logic;
   signal cfg_msg_received_setslotpowerlimit          : std_logic;

   -----------------------------------------------------------------------------------------------------------
   -- 4. Physical Layer Control and Status (PL) Interface                                                   --
   -----------------------------------------------------------------------------------------------------------
   signal pl_directed_link_change                     : std_logic_vector(1 downto 0);
   signal pl_directed_link_width                      : std_logic_vector(1 downto 0);
   signal pl_directed_link_speed                      : std_logic;
   signal pl_directed_link_auton                      : std_logic;
   signal pl_upstream_prefer_deemph                   : std_logic;

   signal pl_sel_link_rate                            : std_logic;
   signal pl_sel_link_width                           : std_logic_vector(1 downto 0);
   signal pl_ltssm_state                              : std_logic_vector(5 downto 0);
   signal pl_lane_reversal_mode                       : std_logic_vector(1 downto 0);

   signal pl_phy_lnk_up                               : std_logic;
   signal pl_tx_pm_state                              : std_logic_vector(2 downto 0);
   signal pl_rx_pm_state                              : std_logic_vector(1 downto 0);

   signal pl_link_upcfg_capable                       : std_logic;
   signal pl_link_gen2_capable                        : std_logic;
   signal pl_link_partner_gen2_supported              : std_logic;
   signal pl_initial_link_width                       : std_logic_vector(2 downto 0);

   signal pl_directed_change_done                     : std_logic;

   ---------------------------------------------------------------------
    -- EP Only                                                        --
   ---------------------------------------------------------------------
   signal pl_received_hot_rst                         : std_logic;
   ---------------------------------------------------------------------
    -- RP Only                                                        --
   ---------------------------------------------------------------------
   signal pl_transmit_hot_rst                         : std_logic;
   signal pl_downstream_deemph_source                 : std_logic;
   -----------------------------------------------------------------------------------------------------------
   -- 5. AER interface                                                                                      --
   -----------------------------------------------------------------------------------------------------------
   signal cfg_err_aer_headerlog                       : std_logic_vector(127 downto 0);
   signal cfg_aer_interrupt_msgnum                    : std_logic_vector(4 downto 0);
   signal cfg_err_aer_headerlog_set                   : std_logic;
   signal cfg_aer_ecrc_check_en                       : std_logic;
   signal cfg_aer_ecrc_gen_en                         : std_logic;
   -----------------------------------------------------------------------------------------------------------
   -- 6. VC interface                                                                                       --
   -----------------------------------------------------------------------------------------------------------
   signal cfg_vc_tcvc_map                             : std_logic_vector(6 downto 0);

   signal sys_clk                                     : std_logic;

   ---------------------------------------------------------
   -- Local signals
   ---------------------------------------------------------

   -- Button sampling
   signal link_retrain_cnt_hi                         : std_logic_vector(15 downto 0) := "0000000000000000";
   signal link_retrain_cnt_lo                         : std_logic_vector(12 downto 0) := "0000000000000";
   signal link_retrain_sw_q                           : std_logic := '0';
   signal link_retrain_sw_q2                          : std_logic := '0';
   signal link_retrain                                : std_logic := '0';
   signal pio_restart_cnt_hi                          : std_logic_vector(15 downto 0) := "0000000000000000";
   signal pio_restart_cnt_lo                          : std_logic_vector(12 downto 0) := "0000000000000";
   signal pio_restart_sw_q                            : std_logic := '0';
   signal pio_restart_sw_q1                           : std_logic := '0';
   signal pio_restart_sw_q2                           : std_logic := '0';
   signal pio_test_restart                            : std_logic := '0';

   -- LED output
   signal pl_sel_link_rate_q                          : std_logic;
   signal error_led_reg                               : std_logic;

   -- Local reset
   signal rp_reset_n                                  : std_logic;

   -- PIO I/Os
   signal pio_test_finished                           : std_logic;
   signal pio_test_failed                             : std_logic;
   signal free_clk_c                                  : std_logic;

   signal link_gen2_capable_i0                        : std_logic;
   signal link_gen2_capable_i1                        : std_logic;
   signal link_gen2_capable_i2                        : std_logic;
   signal link_gen2_i0                                : std_logic;
   signal link_gen2_i1                                : std_logic;
   signal link_gen2_i2                                : std_logic;

  function set_speed(link_spd : bit_vector) return std_logic is
  variable lnk_spd  : std_logic := '0';
  begin
    if link_spd = X"2" then
      lnk_spd := '1';
    else
      lnk_spd := '0';
    end if;

    return (lnk_spd);
  end set_speed;

  signal link_ctrl2_tgt_lnk_spd : std_logic :=  set_speed(LINK_CTRL2_TARGET_LINK_SPEED);

  -- KEEP_WIDTH is always C_DATA_WIDTH/8
  function get_keep_width(data_width : integer) return integer is
  begin
    return (data_width / 8);
  end get_keep_width;

  constant KEEP_WIDTH : integer := get_keep_width(C_DATA_WIDTH);

  -- Convert integer to string
  function fast_train_sim (sim : integer) return string is

  begin  -- fast_train_sim
    if (sim = 1) then
      return "TRUE" ;
    Else
      return "FALSE" ;
    end if;
  end fast_train_sim;

   -- Determine the high-bit of the counter to use, depending on the reference
   -- clock frequency (assumes free_clk is the same frequency as sys_clk)

   function fc_counter_hi_bit (
     ref_freq   : integer)
     return integer is
   begin  -- fc_counter_hi_bit
     if (ref_freq = 2) then
      return 12;  -- Total divider: 134M
     else
       return 11;  -- Total divider: 67M
     end if;
   end fc_counter_hi_bit;

   -- Determine the high-bit of the counter to use, depending on the user
   -- clock frequency

   function tc_counter_hi_bit (
     user_freq   : integer)
     return integer is
   begin  -- tc_counter_hi_bit
     if (user_freq = 3) then
       return 12;   -- 250 MHz   - Total divider: 134M
     elsif (user_freq = 2) then
       return 11;   -- 125 MHz   - Total divider: 67M
     elsif user_freq = 1 then
       return 10;   -- 62.5 MHz   - Total divider: 34M
     else
       return 9;   -- 31.25 MHz   - Total divider: 17M
     end if;
   end tc_counter_hi_bit;

   constant FC_HALF_SEC_MAX_BIT          : integer := fc_counter_hi_bit(REF_CLK_FREQ);

   constant TC_HALF_SEC_MAX_BIT          : integer := tc_counter_hi_bit(REF_CLK_FREQ);

   function pl_sel_link_width_check (
     user_lnk_up       : std_logic;
     pl_sel_link_width : std_logic_vector(1 downto 0);
     check_value       : std_logic_vector(1 downto 0))
     return std_logic is
     variable lnk_wdt  : std_logic := '0';
     variable ret      : std_logic := '0';
   begin  -- pl_sel_link_width_check
     if (pl_sel_link_width = check_value) then
       lnk_wdt := '1';
     else
       lnk_wdt := '0';
     end if;
     ret := user_lnk_up and lnk_wdt;
     return ret;
   end pl_sel_link_width_check;
begin

  refclk_ibuf : IBUFDS_GTE2
     port map(
       O       => sys_clk,
       ODIV2   => open,
       I       => sys_clk_p,
       IB      => sys_clk_n,
       CEB     => '0');

   xzz : BUFG
      port map (
         O  => free_clk_c,
         I  => free_clk
      );

   -- Constants
   fc_sel                        <= (others => '0');
   cfg_di                        <= (others => '0');
   cfg_byte_en                   <= (others => '0');
   cfg_dwaddr                    <= (others => '0');
   cfg_wr_en                     <= '0';
   cfg_wr_rw1c_as_rw             <= '0';
   cfg_rd_en                     <= '0';

   cfg_pciecap_interrupt_msgnum  <= (others => '0');
   cfg_wr_readonly               <= '0';
   cfg_err_atomic_egress_blocked <= '0';
   cfg_err_internal_cor          <= '0';
   cfg_err_malformed             <= '0';
   cfg_err_mc_blocked            <= '0';
   cfg_err_poisoned              <= '0';
   cfg_err_norecovery            <= '0';
   cfg_err_acs                   <= '0';
   cfg_err_internal_uncor        <= '0';
   cfg_pm_halt_aspm_l0s          <= '0';
   cfg_pm_halt_aspm_l1           <= '0';
   cfg_pm_force_state_en         <= '0';
   cfg_pm_force_state            <= (others => '0');
   cfg_interrupt_stat            <= '0';
   cfg_turnoff_ok                <= '0';
   cfg_pm_wake                   <= '0';
   cfg_ds_function_number        <= (others => '0');
   pl_downstream_deemph_source   <= '0';

   cfg_err_aer_headerlog         <= (others => '0');
   cfg_aer_interrupt_msgnum      <= (others => '0');
 ------------------------------------------------------------------------------------------------------------------------------------------
  process (user_clk)
  begin
    if (user_clk'event and user_clk = '1') then
       if (user_reset = '1') then
           link_gen2_i0           <= '0' after TCQ*1 ps;
           link_gen2_capable_i0   <= '0' after TCQ*1 ps;
           link_gen2_i1           <= '0' after TCQ*1 ps;
           link_gen2_capable_i1   <= '0' after TCQ*1 ps;
           link_gen2_i2           <= '0' after TCQ*1 ps;
           link_gen2_capable_i2   <= '0' after TCQ*1 ps;
       else
         if (pl_sel_link_rate = '1' and pl_ltssm_state = "010110") then
             link_gen2_i0 <= '1' after TCQ*1 ps ;
         end if;
           link_gen2_capable_i0 <= (pl_link_gen2_capable and pl_link_partner_gen2_supported and link_ctrl2_tgt_lnk_spd) after TCQ*1 ps;
           link_gen2_i1         <= link_gen2_i0 after TCQ*1 ps;
           link_gen2_capable_i1 <= link_gen2_capable_i0 after TCQ*1 ps;
           link_gen2_i2         <= link_gen2_i1 after TCQ*1 ps;
           link_gen2_capable_i2 <= link_gen2_capable_i1 after TCQ*1 ps;
       end if;
   end if;
  end process;
 ------------------------------------------------------------------------------------------------------------------------------------------
   -- Instantiate the Configurator wrapper, which includes the configurator
   -- block and the Integrated Root Port Block for PCI Express wrapper
  cgator_wrapper_i: cgator_wrapper
    generic map (
      TCQ            => TCQ,
      EXTRA_PIPELINE => 0,
      ROM_FILE       => ROM_FILE,
      ROM_SIZE       => ROM_SIZE,
      PL_FAST_TRAIN  => fast_train_sim(SIMULATION),
      C_DATA_WIDTH   => C_DATA_WIDTH,
      KEEP_WIDTH     => KEEP_WIDTH
      )
    port map (
      ---------------------------------------------------------
      -- 0. Configurator I/Os
      ---------------------------------------------------------
      start_config                    => start_config,
      finished_config                 => finished_config,
      failed_config                   => failed_config,

      ---------------------------------------------------------
      -- 1. PCI Express (pci_exp) Interface
      ---------------------------------------------------------
      -- Tx
      pci_exp_txp                     => TXP,
      pci_exp_txn                     => TXN,

      -- Rx
      pci_exp_rxp                     => RXP,
      pci_exp_rxn                     => RXN,

      ------------------------------------------------------------------------------------------------------
      -- 2. AXI-S Interface                                                                               --
      ------------------------------------------------------------------------------------------------------

      -- Common
      user_clk_out                    => user_clk,
      user_reset_out                  => user_reset,
      user_lnk_up                     => user_lnk_up,

      -- Tx
      tx_buf_av                       => tx_buf_av,
      tx_cfg_req                      => tx_cfg_req,
      tx_err_drop                     => tx_err_drop,
      s_axis_tx_tready                => s_axis_tx_tready,
      s_axis_tx_tdata                 => s_axis_tx_tdata,
      s_axis_tx_tkeep                 => s_axis_tx_tkeep,
      s_axis_tx_tlast                 => s_axis_tx_tlast,
      s_axis_tx_tvalid                => s_axis_tx_tvalid,
      s_axis_tx_tuser                 => s_axis_tx_tuser,
      tx_cfg_gnt                      => tx_cfg_gnt,

      -- Rx
      m_axis_rx_tdata                 => m_axis_rx_tdata,
      m_axis_rx_tkeep                 => m_axis_rx_tkeep,
      m_axis_rx_tlast                 => m_axis_rx_tlast,
      m_axis_rx_tvalid                => m_axis_rx_tvalid,
      m_axis_rx_tuser                 => m_axis_rx_tuser,

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

      cfg_do                          => cfg_do,
      cfg_rd_wr_done                  => cfg_rd_wr_done,

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
      cfg_di                          => cfg_di,
      cfg_byte_en                     => cfg_byte_en,
      cfg_dwaddr                      => cfg_dwaddr,
      cfg_wr_en                       => cfg_wr_en,
      cfg_rd_en                       => cfg_rd_en,
      cfg_wr_readonly                 => cfg_wr_readonly,

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

      --------------------------------------------------------------------
      -- EP Only                                                        --
      --------------------------------------------------------------------
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

      --------------------------------------------------------------------
      -- RP Only                                                        --
      --------------------------------------------------------------------
      cfg_pm_send_pme_to              => cfg_pm_send_pme_to,
      cfg_ds_bus_number               => cfg_ds_bus_number,
      cfg_ds_device_number            => cfg_ds_device_number,
      cfg_ds_function_number          => cfg_ds_function_number,

      cfg_wr_rw1c_as_rw          => cfg_wr_rw1c_as_rw,

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
      cfg_msg_received_assert_inta    => cfg_msg_received_assert_inta,
      cfg_msg_received_assert_intb    => cfg_msg_received_assert_intb,
      cfg_msg_received_assert_intc    => cfg_msg_received_assert_intc,
      cfg_msg_received_assert_intd    => cfg_msg_received_assert_intd,
      cfg_msg_received_deassert_inta  => cfg_msg_received_deassert_inta,
      cfg_msg_received_deassert_intb  => cfg_msg_received_deassert_intb,
      cfg_msg_received_deassert_intc  => cfg_msg_received_deassert_intc,
      cfg_msg_received_deassert_intd  => cfg_msg_received_deassert_intd,
      cfg_msg_received_setslotpowerlimit => cfg_msg_received_setslotpowerlimit,

      ----------------------------------------------------------------------------------------------------------
      -- 4. Physical Layer Control and Status (PL) Interface                                                   --
      ----------------------------------------------------------------------------------------------------------
      pl_directed_link_change         => pl_directed_link_change,
      pl_directed_link_width          => pl_directed_link_width,
      pl_directed_link_speed          => pl_directed_link_speed,
      pl_directed_link_auton          => pl_directed_link_auton,
      pl_upstream_prefer_deemph       => pl_upstream_prefer_deemph,

      pl_sel_link_rate                => pl_sel_link_rate,
      pl_sel_link_width               => pl_sel_link_width,
      pl_ltssm_state                  => pl_ltssm_state,
      pl_lane_reversal_mode           => pl_lane_reversal_mode,

      pl_phy_lnk_up                   => pl_phy_lnk_up,
      pl_tx_pm_state                  => pl_tx_pm_state,
      pl_rx_pm_state                  => pl_rx_pm_state,

      pl_link_upcfg_capable           => pl_link_upcfg_capable,
      pl_link_gen2_capable            => pl_link_gen2_capable,
      pl_link_partner_gen2_supported  => pl_link_partner_gen2_supported,
      pl_initial_link_width           => pl_initial_link_width,

      pl_directed_change_done         => pl_directed_change_done,

      --------------------------------------------------------------------
      -- EP Only                                                        --
      --------------------------------------------------------------------
      pl_received_hot_rst             => pl_received_hot_rst,
      --------------------------------------------------------------------
      -- RP Only                                                        --
      --------------------------------------------------------------------
      pl_transmit_hot_rst             => pl_transmit_hot_rst,
      pl_downstream_deemph_source     => pl_downstream_deemph_source,
      ----------------------------------------------------------------------------------------------------------
      -- 5. AER interface                                                                                      --
      ----------------------------------------------------------------------------------------------------------
      cfg_err_aer_headerlog           => cfg_err_aer_headerlog,
      cfg_aer_interrupt_msgnum        => cfg_aer_interrupt_msgnum,
      cfg_err_aer_headerlog_set       => cfg_err_aer_headerlog_set,
      cfg_aer_ecrc_check_en           => cfg_aer_ecrc_check_en,
      cfg_aer_ecrc_gen_en             => cfg_aer_ecrc_gen_en,
      ----------------------------------------------------------------------------------------------------------
      -- 6. VC interface                                                                                       --
      ----------------------------------------------------------------------------------------------------------
      cfg_vc_tcvc_map                 => cfg_vc_tcvc_map,

      ---------------------------------------------------------
      -- 7. System  (SYS) Interface
      ---------------------------------------------------------
      PIPE_MMCM_RST_N                 => '1' ,      -- Async      | Async
      sys_clk                         => sys_clk,
      sys_rst_n                       => rp_reset_n
      );

   --
   -- Instantiate PIO Master example design
   -- BARs in Endpoint are set by the Configurator. Settings are
   -- mirrored here
   --

  pio_master_i: pio_master
    generic map (
      TCQ           => TCQ,

    -- BAR A: 2 MB, 64-bit Memory BAR using BAR0-1
      BAR_A_ENABLED => 1,
      BAR_A_64BIT   => 1,
      BAR_A_IO      => 0,
      BAR_A_BASE    => X"1000000080000000",
      BAR_A_SIZE    => (2*1024*1024/4),

    -- BAR B: 512 kB, 32-bit Memory BAR using BAR2
      BAR_B_ENABLED => 1,
      BAR_B_64BIT   => 0,
      BAR_B_IO      => 0,
      BAR_B_BASE    => X"0000000020000000",
      BAR_B_SIZE    => (512*1024/4),

    -- BAR C: 32 MB, 32-bit Memory BAR using Expansion ROM BAR
      BAR_C_ENABLED => 1,
      BAR_C_64BIT   => 0,
      BAR_C_IO      => 0,
      BAR_C_BASE    => X"0000000080000000",
      BAR_C_SIZE    => (32*1024*1024/4),

    -- BAR D: Unused
      BAR_D_ENABLED => 0,
      BAR_D_64BIT   => 0,
      BAR_D_IO      => 0,
      BAR_D_BASE    => X"0000000000000000",
      BAR_D_SIZE    => 0,

      C_DATA_WIDTH  => C_DATA_WIDTH,
      KEEP_WIDTH    => KEEP_WIDTH
      )
    port map (
    -- System inputs
      user_clk          => user_clk,
      reset             => user_reset,
      user_lnk_up       => user_lnk_up,

    -- Board-level control/status
      pio_test_restart  => pio_test_restart,
      pio_test_long     => full_test_sw,
      pio_test_finished => pio_test_finished,
      pio_test_failed   => pio_test_failed,

    -- Control of Configurator
      start_config      => start_config,
      finished_config   => finished_config,
      failed_config     => failed_config,

      link_gen2_capable     => link_gen2_capable_i2,
      link_gen2             => link_gen2_i2,

    -- Transaction interfaces
      s_axis_tx_tready    => s_axis_tx_tready ,
      s_axis_tx_tdata     => s_axis_tx_tdata ,
      s_axis_tx_tkeep     => s_axis_tx_tkeep ,
      s_axis_tx_tuser     => s_axis_tx_tuser ,
      s_axis_tx_tlast     => s_axis_tx_tlast ,
      s_axis_tx_tvalid    => s_axis_tx_tvalid ,
      tx_cfg_gnt          => tx_cfg_gnt ,
      tx_cfg_req          => tx_cfg_req ,
      tx_buf_av           => tx_buf_av ,

      m_axis_rx_tdata     => m_axis_rx_tdata ,
      m_axis_rx_tkeep     => m_axis_rx_tkeep ,
      m_axis_rx_tlast     => m_axis_rx_tlast ,
      m_axis_rx_tvalid    => m_axis_rx_tvalid ,
      m_axis_rx_tuser     => m_axis_rx_tuser
    );

   --
   -- Static assignments to core I/Os
   --

   -- Configuration signals which are unused
  cfg_err_cor                <= '0';
  cfg_err_ur                 <= '0';
  cfg_err_ecrc               <= '0';
  cfg_err_cpl_timeout        <= '0';
  cfg_err_cpl_abort          <= '0';
  cfg_err_cpl_unexpect       <= '0';
  cfg_err_posted             <= '0';
  cfg_err_locked             <= '0';
  cfg_err_tlp_cpl_header     <= X"000000000000";
  cfg_interrupt              <= '0';
  cfg_interrupt_assert       <= '0';
  cfg_interrupt_di           <= X"00";
  cfg_trn_pending            <= '0';
  cfg_pm_send_pme_to         <= '0';
  cfg_dsn                    <= X"0000000000000000";
  cfg_ds_bus_number          <= X"00";
  cfg_ds_device_number       <= "00000";

  -- Physical Layer signals which are unused
  pl_directed_link_auton     <= '0';
  pl_directed_link_change    <= "00";
  pl_directed_link_speed     <= '0';
  pl_directed_link_width     <= "00";
  pl_upstream_prefer_deemph  <= '0';
  pl_transmit_hot_rst        <= '0';

  --
  -- De-bounce input buttons (require ~1/2 second steady-state)
  --

  Debounce: process (free_clk_c)
  begin  -- process Debounce
    if free_clk_c'event and free_clk_c = '1' then  -- rising clock edge
      if sys_rst_n = '0' then           -- synchronous reset (active low)
        -- Use sys_rst_n instead of user_reset since user_reset is an output
        -- of the core, and we're generating a reset input _to_ the core here
        link_retrain_cnt_hi  <= (others => '0') after TCQ*1 ps;
        link_retrain_cnt_lo  <= (others => '0') after TCQ*1 ps;
        link_retrain_sw_q    <= '0' after TCQ*1 ps;
        link_retrain_sw_q2   <= '0' after TCQ*1 ps;
        link_retrain         <= '0' after TCQ*1 ps;
      else
        -- Sample button input
        link_retrain_sw_q    <= link_retrain_sw after TCQ*1 ps;
        link_retrain_sw_q2   <= link_retrain_sw_q after TCQ*1 ps;

        if ((link_retrain_sw_q2 /= link_retrain_sw_q) or (link_retrain_cnt_hi(15) = '1')) then
          -- If button input has changed or terminal count is reached,
          -- restart de-bounce counter
          link_retrain_cnt_hi <= (others => '0') after TCQ*1 ps;
          link_retrain_cnt_lo <= (others => '0') after TCQ*1 ps;
        else
          -- Otherwise count up. When terminal count of low-half is reached,
          -- restart low-half and increment high-half
          if (link_retrain_cnt_lo(FC_HALF_SEC_MAX_BIT) = '1') then
            link_retrain_cnt_hi <= (link_retrain_cnt_hi + X"0001") after TCQ*1 ps;
            link_retrain_cnt_lo <= (others => '0') after TCQ*1 ps;
          else
            link_retrain_cnt_lo <= (link_retrain_cnt_lo + "0000000000001") after TCQ*1 ps;
          end if;
        end if;

        if link_retrain_cnt_hi(15) = '1' then
          -- If terminal count is reached, sample button value
          link_retrain <= link_retrain_sw_q2 after TCQ*1 ps;
        end if;
      end if;
    end if;
  end process Debounce;

  Debounce_PIO: process (user_clk)
  begin  -- process Debounce_PIO
    if user_clk'event and user_clk = '1' then  -- rising clock edge
      if user_reset = '1' then           -- synchronous reset (active low)
        pio_restart_cnt_hi  <= (others => '0') after TCQ*1 ps;
        pio_restart_cnt_lo  <= (others => '0') after TCQ*1 ps;
        pio_restart_sw_q    <= '0' after TCQ*1 ps;
        pio_restart_sw_q1   <= '0' after TCQ*1 ps;
        pio_restart_sw_q2   <= '0' after TCQ*1 ps;
        pio_test_restart    <= '0' after TCQ*1 ps;
      else
        -- Sample button input
        pio_restart_sw_q    <= pio_restart_sw after TCQ*1 ps;
        pio_restart_sw_q1   <= pio_restart_sw_q after TCQ*1 ps;
        pio_restart_sw_q2   <= pio_restart_sw_q1 after TCQ*1 ps;

        if ((pio_restart_sw_q2 /= pio_restart_sw_q1) or (pio_restart_cnt_hi(15) = '1')) then
          -- If button input has changed or terminal count is reached,
          -- restart de-bounce counter
          pio_restart_cnt_hi <= (others => '0') after TCQ*1 ps;
          pio_restart_cnt_lo <= (others => '0') after TCQ*1 ps;
        else
          -- Otherwise count up. When terminal count of low-half is reached,
          -- restart low-half and increment high-half
          if (pio_restart_cnt_lo(TC_HALF_SEC_MAX_BIT) = '1') then
            pio_restart_cnt_hi <= (pio_restart_cnt_hi + X"0001") after TCQ*1 ps;
            pio_restart_cnt_lo <= (others => '0') after TCQ*1 ps;
          else
            pio_restart_cnt_lo <= (pio_restart_cnt_lo + "0000000000001") after TCQ*1 ps;
          end if;
        end if;

        if pio_restart_cnt_hi(15) = '1' then
          -- If terminal count is reached, sample button value
          pio_test_restart <= pio_restart_sw_q2 after TCQ*1 ps;
        end if;
      end if;
    end if;
  end process Debounce_PIO;


   error_led_reg <= (failed_config or pio_test_failed);
   pl_sel_link_rate_q <= pl_sel_link_rate;

  led_2_obuf : OBUF
     port map(
       O       => led_2,
       I       => user_lnk_up);

  led_3_obuf : OBUF
     port map(
       O       => led_3,
       I       => pio_test_finished);

  led_4_obuf : OBUF
     port map(
       O       => led_4,
       I       => finished_config);

  led_5_obuf : OBUF
     port map(
       O       => led_5,
       I       => error_led_reg);

  led_6_obuf : OBUF
     port map(
       O       => led_6,
       I       => pl_sel_link_rate_q);


  -- Create reset to Root Port core
  -- This is a combination of the board-level reset input and the
  -- link-retrain button
  rp_reset_n <= sys_rst_n and not(link_retrain);

end rtl;
