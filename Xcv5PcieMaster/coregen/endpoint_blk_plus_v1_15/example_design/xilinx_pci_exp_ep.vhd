
-------------------------------------------------------------------------------
--
-- (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
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
-- Project    : V5-Block Plus for PCI Express
-- File       : xilinx_pci_exp_ep.vhd
--
-- Description:  PCI Express Dual Endpoint Core example design top level wrapper.
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity XILINX_PCI_EXP_EP is

generic (FAST_SIMULATION: INTEGER := 0);
port  (

  sys_clk_p         : in std_logic;
  sys_clk_n         : in std_logic;

  sys_reset_n       : in std_logic;


  refclkout         : out std_logic;


  pci_exp_rxn       : in std_logic_vector((1 - 1) downto 0);
  pci_exp_rxp       : in std_logic_vector((1 - 1) downto 0);
  pci_exp_txn       : out std_logic_vector((1 - 1) downto 0);
  pci_exp_txp       : out std_logic_vector((1 - 1) downto 0)

);

end XILINX_PCI_EXP_EP;

architecture rtl of   XILINX_PCI_EXP_EP is


component pci_exp_64b_app
port  (

	    --
    -- Common
    --

    trn_clk : in std_logic;
    trn_reset_n : in std_logic;
    trn_lnk_up_n : in std_logic;

    --
    -- Tx
    --

    trn_td : out std_logic_vector((64 - 1) downto 0);
    trn_trem_n : out std_logic_vector(7 downto 0);
    trn_tsof_n : out std_logic;
    trn_teof_n : out std_logic;
    trn_tsrc_rdy_n : out std_logic;
    trn_tdst_rdy_n : in std_logic;
    trn_tsrc_dsc_n : out std_logic;
    trn_terrfwd_n : out std_logic;
    trn_tdst_dsc_n : in std_logic;
    trn_tbuf_av : in std_logic_vector((4 - 1) downto 0);

    --
    -- Rx
    --

    trn_rd : in std_logic_vector((64 - 1) downto 0);
    trn_rrem_n: in std_logic_vector(7 downto 0);
    trn_rsof_n : in std_logic;
    trn_reof_n : in std_logic;
    trn_rsrc_rdy_n : in std_logic;
    trn_rsrc_dsc_n : in std_logic;
    trn_rdst_rdy_n : out std_logic;
    trn_rerrfwd_n : in std_logic;
    trn_rnp_ok_n : out std_logic;

    trn_rbar_hit_n : in std_logic_vector(6 downto 0);
    trn_rfc_nph_av : in std_logic_vector(7 downto 0);
    trn_rfc_npd_av : in std_logic_vector(11 downto 0);
    trn_rfc_ph_av : in std_logic_vector(7 downto 0)     ;
    trn_rfc_pd_av : in std_logic_vector(11 downto 0)    ;
    trn_rcpl_streaming_n      : out std_logic;

    ---------------------------------------------------------
    -- 3. Host (CFG) Interface
    ---------------------------------------------------------

    cfg_do : in std_logic_vector(31 downto 0);
    cfg_di : out std_logic_vector(31 downto 0);
    cfg_byte_en_n : out std_logic_vector(3 downto 0);
    cfg_dwaddr : out std_logic_vector(9 downto 0);
    cfg_rd_wr_done_n : in std_logic;
    cfg_wr_en_n : out std_logic;
    cfg_rd_en_n : out std_logic;
    cfg_err_cor_n : out std_logic;
    cfg_err_ur_n : out std_logic;
    cfg_err_cpl_rdy_n : in std_logic;
    cfg_err_ecrc_n : out std_logic;
    cfg_err_cpl_timeout_n : out std_logic;
    cfg_err_cpl_abort_n : out std_logic;
    cfg_err_cpl_unexpect_n : out std_logic;
    cfg_err_posted_n : out std_logic;
    cfg_interrupt_n : out std_logic;
    cfg_interrupt_rdy_n : in std_logic;

    cfg_interrupt_assert_n : out std_logic;
    cfg_interrupt_di : out std_logic_vector(7 downto 0);
    cfg_interrupt_do : in  std_logic_vector(7 downto 0);
    cfg_interrupt_mmenable : in  std_logic_vector(2 downto 0);
    cfg_interrupt_msienable: in  std_logic;

    cfg_turnoff_ok_n : out std_logic;
    cfg_to_turnoff_n : in std_logic;
    cfg_pm_wake_n : out std_logic;
    cfg_pcie_link_state_n : in std_logic_vector(2 downto 0);
    cfg_trn_pending_n : out std_logic;
    cfg_err_tlp_cpl_header : out std_logic_vector(47 downto 0);

    cfg_bus_number : in std_logic_vector(7 downto 0);
    cfg_device_number : in std_logic_vector(4 downto 0);
    cfg_function_number : in std_logic_vector(2 downto 0);
    cfg_status : in std_logic_vector(15 downto 0);
    cfg_command : in std_logic_vector(15 downto 0);
    cfg_dstatus : in std_logic_vector(15 downto 0);
    cfg_dcommand : in std_logic_vector(15 downto 0);
    cfg_lstatus : in std_logic_vector(15 downto 0);
    cfg_lcommand : in std_logic_vector(15 downto 0)
 
);
end component;

component endpoint_blk_plus_v1_15
  port (
    pci_exp_rxn : in std_logic_vector((1 - 1) downto 0);
    pci_exp_rxp : in std_logic_vector((1 - 1) downto 0);
    pci_exp_txn : out std_logic_vector((1 - 1) downto 0);
    pci_exp_txp : out std_logic_vector((1 - 1) downto 0);

    sys_clk : in STD_LOGIC;
    sys_reset_n : in STD_LOGIC;

  refclkout         : out std_logic;


    trn_clk : out STD_LOGIC; 
    trn_reset_n : out STD_LOGIC; 
    trn_lnk_up_n : out STD_LOGIC; 

    trn_td : in STD_LOGIC_VECTOR((64 - 1) downto 0);
    trn_trem_n: in STD_LOGIC_VECTOR (7 downto 0);
    trn_tsof_n : in STD_LOGIC;
    trn_teof_n : in STD_LOGIC;
    trn_tsrc_dsc_n : in STD_LOGIC;
    trn_tsrc_rdy_n : in STD_LOGIC;
    trn_tdst_dsc_n : out STD_LOGIC;
    trn_tdst_rdy_n : out STD_LOGIC;
    trn_terrfwd_n : in STD_LOGIC ;
    trn_tbuf_av : out STD_LOGIC_VECTOR (( 4 -1 ) downto 0 );

    trn_rd : out STD_LOGIC_VECTOR((64 - 1) downto 0);
    trn_rrem_n: out STD_LOGIC_VECTOR (7 downto 0);
    trn_rsof_n : out STD_LOGIC;
    trn_reof_n : out STD_LOGIC; 
    trn_rsrc_dsc_n : out STD_LOGIC; 
    trn_rsrc_rdy_n : out STD_LOGIC; 
    trn_rbar_hit_n : out STD_LOGIC_VECTOR ( 6 downto 0 );
    trn_rdst_rdy_n : in STD_LOGIC; 
    trn_rerrfwd_n : out STD_LOGIC; 
    trn_rnp_ok_n : in STD_LOGIC; 
    trn_rfc_npd_av : out STD_LOGIC_VECTOR ( 11 downto 0 ); 
    trn_rfc_nph_av : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    trn_rfc_pd_av : out STD_LOGIC_VECTOR ( 11 downto 0 ); 
    trn_rfc_ph_av : out STD_LOGIC_VECTOR ( 7 downto 0 );
    trn_rcpl_streaming_n      : in STD_LOGIC;

    cfg_do : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_rd_wr_done_n : out STD_LOGIC; 
    cfg_di : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
    cfg_byte_en_n : in STD_LOGIC_VECTOR ( 3 downto 0 ); 
    cfg_dwaddr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    cfg_wr_en_n : in STD_LOGIC;
    cfg_rd_en_n : in STD_LOGIC; 

    cfg_err_cor_n : in STD_LOGIC; 
    cfg_err_cpl_abort_n : in STD_LOGIC; 
    cfg_err_cpl_timeout_n : in STD_LOGIC; 
    cfg_err_cpl_unexpect_n : in STD_LOGIC; 
    cfg_err_ecrc_n : in STD_LOGIC; 
    cfg_err_posted_n : in STD_LOGIC; 
    cfg_err_tlp_cpl_header : in STD_LOGIC_VECTOR ( 47 downto 0 ); 
    cfg_err_ur_n : in STD_LOGIC;
    cfg_err_cpl_rdy_n : out STD_LOGIC;
    cfg_err_locked_n : in STD_LOGIC; 
    cfg_interrupt_n : in STD_LOGIC;
    cfg_interrupt_rdy_n : out STD_LOGIC;
    cfg_pm_wake_n : in STD_LOGIC;
    cfg_pcie_link_state_n : out STD_LOGIC_VECTOR ( 2 downto 0 ); 
    cfg_to_turnoff_n : out STD_LOGIC;
    cfg_interrupt_assert_n : in  STD_LOGIC;
    cfg_interrupt_di : in  STD_LOGIC_VECTOR(7 downto 0);
    cfg_interrupt_do : out STD_LOGIC_VECTOR(7 downto 0);
    cfg_interrupt_mmenable : out STD_LOGIC_VECTOR(2 downto 0);
    cfg_interrupt_msienable: out STD_LOGIC;

    cfg_trn_pending_n : in STD_LOGIC;
    cfg_bus_number : out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_device_number : out STD_LOGIC_VECTOR ( 4 downto 0 );
    cfg_function_number : out STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_status : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_command : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_dstatus : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_dcommand : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_lstatus : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_lcommand : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_dsn: in STD_LOGIC_VECTOR (63 downto 0 );

    fast_train_simulation_only : in STD_LOGIC

  );

end component;


signal     sys_clk_c : std_logic;

signal     sys_reset_n_c : std_logic;
signal     trn_clk_c : std_logic;
signal     trn_reset_n_c : std_logic;
signal     trn_lnk_up_n_c : std_logic;
signal     cfg_trn_pending_n_c : std_logic;
signal     trn_tsof_n_c : std_logic;
signal     trn_teof_n_c : std_logic;
signal     trn_tsrc_rdy_n_c : std_logic;
signal     trn_tdst_rdy_n_c : std_logic;
signal     trn_tsrc_dsc_n_c : std_logic;
signal     trn_terrfwd_n_c : std_logic;
signal     trn_tdst_dsc_n_c : std_logic;
signal     trn_td_c : std_logic_vector((64 - 1) downto 0);
signal     trn_trem_n_c : std_logic_vector(7 downto 0);
signal     trn_tbuf_av_c : std_logic_vector(( 4 -1 )  downto 0);
signal     trn_rsof_n_c : std_logic;
signal     trn_reof_n_c : std_logic;
signal     trn_rsrc_rdy_n_c : std_logic;
signal     trn_rsrc_dsc_n_c : std_logic;
signal     trn_rdst_rdy_n_c : std_logic;
signal     trn_rerrfwd_n_c : std_logic;
signal     trn_rnp_ok_n_c : std_logic;
signal     trn_rd_c : std_logic_vector((64 - 1) downto 0);
signal     trn_rrem_n_c : std_logic_vector(7 downto 0);
signal     trn_rbar_hit_n_c : std_logic_vector(6 downto 0);
signal     trn_rfc_nph_av_c : std_logic_vector(7 downto 0);
signal     trn_rfc_npd_av_c : std_logic_vector(11 downto 0);
signal     trn_rfc_ph_av_c : std_logic_vector(7 downto 0);
signal     trn_rfc_pd_av_c : std_logic_vector(11 downto 0);
signal     trn_rcpl_streaming_n_c      : std_logic;

signal     cfg_do_c : std_logic_vector(31 downto 0);
signal     cfg_di_c : std_logic_vector(31 downto 0);
signal     cfg_dwaddr_c : std_logic_vector(9 downto 0) ;
signal     cfg_byte_en_n_c : std_logic_vector(3 downto 0);
signal     cfg_err_tlp_cpl_header_c : std_logic_vector(47 downto 0);
signal     cfg_wr_en_n_c : std_logic;
signal     cfg_rd_en_n_c : std_logic;
signal     cfg_rd_wr_done_n_c : std_logic;
signal     cfg_err_cor_n_c : std_logic;
signal     cfg_err_ur_n_c : std_logic;
signal     cfg_err_ecrc_n_c : std_logic;
signal     cfg_err_cpl_timeout_n_c : std_logic;
signal     cfg_err_cpl_abort_n_c : std_logic;
signal     cfg_err_cpl_unexpect_n_c : std_logic;
signal     cfg_err_posted_n_c : std_logic;

signal     cfg_err_cpl_rdy_n_c : std_logic;  
signal     cfg_interrupt_n_c : std_logic;
signal     cfg_interrupt_rdy_n_c : std_logic;

signal     cfg_interrupt_assert_n_c : std_logic;
signal     cfg_interrupt_di_c : std_logic_vector(7 downto 0);
signal     cfg_interrupt_do_c : std_logic_vector(7 downto 0);
signal     cfg_interrupt_mmenable_c : std_logic_vector(2 downto 0);
signal     cfg_interrupt_msienable_c: std_logic;

signal     cfg_turnoff_ok_n_c : std_logic;
signal     cfg_to_turnoff_n_c : std_logic;
signal     cfg_pm_wake_n_c : std_logic;
signal     cfg_pcie_link_state_n_c : std_logic_vector(2 downto 0);
signal     cfg_bus_number_c : std_logic_vector(7 downto 0);
signal     cfg_device_number_c : std_logic_vector(4 downto 0);
signal     cfg_function_number_c : std_logic_vector(2 downto 0);
signal     cfg_status_c : std_logic_vector(15 downto 0);
signal     cfg_command_c : std_logic_vector(15 downto 0);
signal     cfg_dstatus_c : std_logic_vector(15 downto 0);
signal     cfg_dcommand_c : std_logic_vector(15 downto 0);
signal     cfg_lstatus_c : std_logic_vector(15 downto 0);
signal     cfg_lcommand_c : std_logic_vector(15 downto 0);
signal     unsigned_fast_simulation: unsigned(0 downto 0);
signal     vector_fast_simulation: std_logic_vector(0 downto 0);



--attribute BOX_TYPE : string;
--attribute BOX_TYPE of endpoint_blk_plus_v1_15 : component is "BLACK_BOX";


begin


-- convert generic FAST_SIMULATION and pass to express core
  unsigned_fast_simulation <= to_unsigned(FAST_SIMULATION,1);
  vector_fast_simulation <= std_logic_vector(unsigned_fast_simulation);


  ---------------------------------------------------------
  -- Endpoint Implementation Application
  ---------------------------------------------------------
app : pci_exp_64b_app port map (


--
-- Transaction ( TRN ) Interface
--
  trn_clk => trn_clk_c,                   -- I
  trn_reset_n => trn_reset_n_c,           -- I
  trn_lnk_up_n => trn_lnk_up_n_c,         -- I

-- Tx Local-Link
  trn_td => trn_td_c,                     -- O (63/31:0)
  trn_trem_n => trn_trem_n_c,                -- I
  trn_tsof_n => trn_tsof_n_c,             -- O
  trn_teof_n => trn_teof_n_c,             -- O
  trn_tsrc_rdy_n => trn_tsrc_rdy_n_c,     -- O
  trn_tsrc_dsc_n => trn_tsrc_dsc_n_c,     -- O
  trn_tdst_rdy_n => trn_tdst_rdy_n_c,     -- I
  trn_tdst_dsc_n => trn_tdst_dsc_n_c,     -- I
  trn_terrfwd_n => trn_terrfwd_n_c,       -- O
  trn_tbuf_av => trn_tbuf_av_c,           -- I (4/3:0)

-- Rx Local-Link
  trn_rd => trn_rd_c,                     -- I (63/31:0)
  trn_rrem_n => trn_rrem_n_c,                -- I
  trn_rsof_n => trn_rsof_n_c,             -- I
  trn_reof_n => trn_reof_n_c,             -- I
  trn_rsrc_rdy_n => trn_rsrc_rdy_n_c,     -- I
  trn_rsrc_dsc_n => trn_rsrc_dsc_n_c,     -- I
  trn_rdst_rdy_n => trn_rdst_rdy_n_c,     -- O
  trn_rerrfwd_n => trn_rerrfwd_n_c,       -- I
  trn_rnp_ok_n => trn_rnp_ok_n_c,         -- O
  trn_rbar_hit_n => trn_rbar_hit_n_c,     -- I (6:0)
  trn_rfc_npd_av => trn_rfc_npd_av_c,     -- I (11:0)
  trn_rfc_nph_av => trn_rfc_nph_av_c,     -- I (7:0)
  trn_rfc_pd_av => trn_rfc_pd_av_c,       -- I (11:0)
  trn_rfc_ph_av => trn_rfc_ph_av_c,       -- I (7:0)
  trn_rcpl_streaming_n => trn_rcpl_streaming_n_c,

--
-- Host ( CFG ) Interface
--

  cfg_do => cfg_do_c,                                   -- I (31:0)
  cfg_rd_wr_done_n => cfg_rd_wr_done_n_c,               -- I
  cfg_di => cfg_di_c,                                   -- O (31:0)
  cfg_byte_en_n => cfg_byte_en_n_c,                     -- O
  cfg_dwaddr => cfg_dwaddr_c,                           -- O
  cfg_wr_en_n => cfg_wr_en_n_c,                         -- O
  cfg_rd_en_n => cfg_rd_en_n_c,                         -- O
  cfg_err_cor_n => cfg_err_cor_n_c,                     -- O
  cfg_err_ur_n => cfg_err_ur_n_c,                       -- O
  cfg_err_cpl_rdy_n => cfg_err_cpl_rdy_n_c,             -- I
  cfg_err_ecrc_n => cfg_err_ecrc_n_c,                   -- O
  cfg_err_cpl_timeout_n => cfg_err_cpl_timeout_n_c,     -- O
  cfg_err_cpl_abort_n => cfg_err_cpl_abort_n_c,         -- O
  cfg_err_cpl_unexpect_n => cfg_err_cpl_unexpect_n_c,   -- O
  cfg_err_posted_n => cfg_err_posted_n_c,               -- O
  cfg_err_tlp_cpl_header => cfg_err_tlp_cpl_header_c,   -- O (47:0)
  cfg_interrupt_n => cfg_interrupt_n_c,                 -- O
  cfg_interrupt_rdy_n => cfg_interrupt_rdy_n_c,         -- I

  cfg_interrupt_assert_n => cfg_interrupt_assert_n_c,   -- O
  cfg_interrupt_di       => cfg_interrupt_di_c,         -- O [7:0]
  cfg_interrupt_do       => cfg_interrupt_do_c,         -- I [7:0]
  cfg_interrupt_mmenable => cfg_interrupt_mmenable_c,   -- I [2:0]
  cfg_interrupt_msienable=> cfg_interrupt_msienable_c,  -- I
  cfg_to_turnoff_n => cfg_to_turnoff_n_c,               -- I
  cfg_pm_wake_n => cfg_pm_wake_n_c,                     -- O
  cfg_pcie_link_state_n => cfg_pcie_link_state_n_c,     -- I (2:0)
  cfg_trn_pending_n => cfg_trn_pending_n_c,             -- O
  cfg_bus_number => cfg_bus_number_c,                   -- I (7:0)
  cfg_device_number => cfg_device_number_c,             -- I (4:0)
  cfg_function_number => cfg_function_number_c,         -- I (2:0)
  cfg_status => cfg_status_c,                           -- I (15:0)
  cfg_command => cfg_command_c,                         -- I (15:0)
  cfg_dstatus => cfg_dstatus_c,                         -- I (15:0)
  cfg_dcommand => cfg_dcommand_c,                       -- I (15:0)
  cfg_lstatus => cfg_lstatus_c,                         -- I (15:0)
  cfg_lcommand => cfg_lcommand_c                        -- I (15:0)

);


 ep : endpoint_blk_plus_v1_15 port map  (

--
-- PCI Express Fabric Interface
--

  pci_exp_txp => pci_exp_txp,             -- O (7/3/0:0)
  pci_exp_txn => pci_exp_txn,             -- O (7/3/0:0)
  pci_exp_rxp => pci_exp_rxp,             -- O (7/3/0:0)
  pci_exp_rxn => pci_exp_rxn,             -- O (7/3/0:0)


--
-- System ( SYS ) Interface
--
  sys_clk => sys_clk_c,                                 -- I

  sys_reset_n => sys_reset_n_c,                          -- I

  refclkout => refclkout,                          -- O

--
-- Transaction ( TRN ) Interface
--

  trn_clk => trn_clk_c,                   -- O
  trn_reset_n => trn_reset_n_c,           -- O
  trn_lnk_up_n => trn_lnk_up_n_c,         -- O

-- Tx Local-Link

  trn_td => trn_td_c,                     -- I (63/31:0)
    trn_trem_n => trn_trem_n_c,
  trn_tsof_n => trn_tsof_n_c,             -- I
  trn_teof_n => trn_teof_n_c,             -- I
  trn_tsrc_rdy_n => trn_tsrc_rdy_n_c,     -- I
  trn_tsrc_dsc_n => trn_tsrc_dsc_n_c,     -- I
  trn_tdst_rdy_n => trn_tdst_rdy_n_c,     -- O
  trn_tdst_dsc_n => trn_tdst_dsc_n_c,     -- O
  trn_terrfwd_n => trn_terrfwd_n_c,       -- I
  trn_tbuf_av => trn_tbuf_av_c,           -- O (4/3:0)

-- Rx Local-Link

  trn_rd => trn_rd_c,                     -- O (63/31:0)
    trn_rrem_n => trn_rrem_n_c,
  trn_rsof_n => trn_rsof_n_c,             -- O
  trn_reof_n => trn_reof_n_c,             -- O
  trn_rsrc_rdy_n => trn_rsrc_rdy_n_c,     -- O
  trn_rsrc_dsc_n => trn_rsrc_dsc_n_c,     -- O
  trn_rdst_rdy_n => trn_rdst_rdy_n_c,     -- I
  trn_rerrfwd_n => trn_rerrfwd_n_c,       -- O
  trn_rnp_ok_n => trn_rnp_ok_n_c,         -- I
  trn_rbar_hit_n => trn_rbar_hit_n_c,     -- O (6:0)
  trn_rfc_nph_av => trn_rfc_nph_av_c,     -- O (11:0)
  trn_rfc_npd_av => trn_rfc_npd_av_c,     -- O (7:0)
  trn_rfc_ph_av => trn_rfc_ph_av_c,       -- O (11:0)
  trn_rfc_pd_av => trn_rfc_pd_av_c,       -- O (7:0)
  trn_rcpl_streaming_n => trn_rcpl_streaming_n_c,

--
-- Host ( CFG ) Interface
--

  cfg_do => cfg_do_c,                                    -- O (31:0)
  cfg_rd_wr_done_n => cfg_rd_wr_done_n_c,                -- O
  cfg_di => cfg_di_c,                                    -- I (31:0)
  cfg_byte_en_n => cfg_byte_en_n_c,                      -- I (3:0)
  cfg_dwaddr => cfg_dwaddr_c,                            -- I (9:0)
  cfg_wr_en_n => cfg_wr_en_n_c,                          -- I
  cfg_rd_en_n => cfg_rd_en_n_c,                          -- I
  cfg_err_cor_n => cfg_err_cor_n_c,                      -- I
  cfg_err_ur_n => cfg_err_ur_n_c,                        -- I
  cfg_err_ecrc_n => cfg_err_ecrc_n_c,                    -- I
  cfg_err_cpl_timeout_n => cfg_err_cpl_timeout_n_c,      -- I
  cfg_err_cpl_abort_n => cfg_err_cpl_abort_n_c,          -- I
  cfg_err_cpl_unexpect_n => cfg_err_cpl_unexpect_n_c,    -- I
  cfg_err_posted_n => cfg_err_posted_n_c,                -- I
  cfg_err_cpl_rdy_n => cfg_err_cpl_rdy_n_c,              -- O
  cfg_err_locked_n => '1',                -- I
  cfg_err_tlp_cpl_header => cfg_err_tlp_cpl_header_c,    -- I (47:0)
  cfg_interrupt_n => cfg_interrupt_n_c,                  -- I
  cfg_interrupt_rdy_n => cfg_interrupt_rdy_n_c,          -- O

  cfg_interrupt_assert_n => cfg_interrupt_assert_n_c,    -- I
  cfg_interrupt_di       => cfg_interrupt_di_c,          -- I [7:0]
  cfg_interrupt_do       => cfg_interrupt_do_c,          -- O [7:0]
  cfg_interrupt_mmenable => cfg_interrupt_mmenable_c,    -- O [2:0]
  cfg_interrupt_msienable=> cfg_interrupt_msienable_c,   -- O
  cfg_to_turnoff_n => cfg_to_turnoff_n_c,                -- O
  cfg_pm_wake_n => cfg_pm_wake_n_c,                      -- I
  cfg_pcie_link_state_n => cfg_pcie_link_state_n_c,      -- O (2:0)
  cfg_trn_pending_n => cfg_trn_pending_n_c,              -- I
  cfg_bus_number => cfg_bus_number_c,                    -- O (7:0)
  cfg_device_number => cfg_device_number_c,              -- O (4:0)
  cfg_function_number => cfg_function_number_c,          -- O (2:0)
  cfg_status => cfg_status_c,                            -- O (15:0)
  cfg_command => cfg_command_c,                          -- O (15:0)
  cfg_dstatus => cfg_dstatus_c,                          -- O (15:0)
  cfg_dcommand => cfg_dcommand_c,                        -- O (15:0)
  cfg_lstatus => cfg_lstatus_c,                          -- O (15:0)
  cfg_lcommand => cfg_lcommand_c,                        -- O (15:0)
  cfg_dsn => (others => '0'),

 fast_train_simulation_only => vector_fast_simulation(0)

);

-------------------------------------------------------
-- Virtex5-FX Global Clock Buffer
-------------------------------------------------------
refclk_ibuf : IBUFDS port map (

  O => sys_clk_c,
  I => sys_clk_p,
  IB => sys_clk_n

);


sys_reset_n_ibuf : IBUF port map (

  O => sys_reset_n_c,
  I => sys_reset_n

);



end; -- XILINX_PCI_EXP_EP
