

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
-- File       : pci_exp_64b_app.vhd
--
-- Description:  PCI Express Endpoint Core 32 bit interface sample application
--               design.
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;


entity pci_exp_64b_app is

port  (

  -- Common

  trn_clk                   : in std_logic;
  trn_reset_n               : in std_logic;
  trn_lnk_up_n              : in std_logic;

  -- Tx

  trn_td                    : out std_logic_vector(63 downto 0);
  trn_trem_n                : out std_logic_vector(7 downto 0);
  trn_tsof_n                : out std_logic;
  trn_teof_n                : out std_logic;
  trn_tsrc_rdy_n            : out std_logic;
  trn_tdst_rdy_n            : in std_logic;
  trn_tsrc_dsc_n            : out std_logic;
  trn_terrfwd_n             : out std_logic;
  trn_tdst_dsc_n            : in std_logic;
  trn_tbuf_av               : in std_logic_vector((4 - 1) downto 0);

  -- Rx

  trn_rd                    : in std_logic_vector(63 downto 0);
  trn_rrem_n                : in std_logic_vector(7 downto 0);
  trn_rsof_n                : in std_logic;
  trn_reof_n                : in std_logic;
  trn_rsrc_rdy_n            : in std_logic;
  trn_rsrc_dsc_n            : in std_logic;
  trn_rdst_rdy_n            : out std_logic;
  trn_rerrfwd_n             : in std_logic;
  trn_rnp_ok_n              : out std_logic;
  trn_rbar_hit_n            : in std_logic_vector(6 downto 0);
  trn_rfc_nph_av            : in std_logic_vector(7 downto 0);
  trn_rfc_npd_av            : in std_logic_vector(11 downto 0);
  trn_rfc_ph_av             : in std_logic_vector(7 downto 0);
  trn_rfc_pd_av             : in std_logic_vector(11 downto 0);

  trn_rcpl_streaming_n      : out std_logic; 

  -- Host (CFG) Interface

  cfg_do                    : in std_logic_vector(31 downto 0);
  cfg_di                    : out std_logic_vector(31 downto 0);
  cfg_byte_en_n             : out std_logic_vector(3 downto 0);
  cfg_dwaddr                : out std_logic_vector(9 downto 0);
  cfg_rd_wr_done_n          : in std_logic;
  cfg_wr_en_n               : out std_logic;
  cfg_rd_en_n               : out std_logic;
  cfg_err_cor_n             : out std_logic;
  cfg_err_ur_n              : out std_logic;
  cfg_err_cpl_rdy_n         : in std_logic;
  cfg_err_ecrc_n            : out std_logic;
  cfg_err_cpl_timeout_n     : out std_logic;
  cfg_err_cpl_abort_n       : out std_logic;
  cfg_err_cpl_unexpect_n    : out std_logic;
  cfg_err_posted_n          : out std_logic;
  cfg_interrupt_n           : out std_logic;
  cfg_interrupt_rdy_n       : in std_logic;

  cfg_interrupt_assert_n    : out std_logic;
  cfg_interrupt_di          : out std_logic_vector(7 downto 0);
  cfg_interrupt_do          : in  std_logic_vector(7 downto 0);
  cfg_interrupt_mmenable    : in  std_logic_vector(2 downto 0);
  cfg_interrupt_msienable   : in  std_logic;

  cfg_turnoff_ok_n          : out std_logic;
  cfg_to_turnoff_n          : in std_logic;
  cfg_pm_wake_n             : out std_logic;
  cfg_pcie_link_state_n     : in std_logic_vector(2 downto 0);
  cfg_trn_pending_n         : out std_logic;
  cfg_err_tlp_cpl_header    : out std_logic_vector(47 downto 0);
  cfg_bus_number            : in std_logic_vector(7 downto 0);
  cfg_device_number         : in std_logic_vector(4 downto 0);
  cfg_function_number       : in std_logic_vector(2 downto 0);
  cfg_status                : in std_logic_vector(15 downto 0);
  cfg_command               : in std_logic_vector(15 downto 0);
  cfg_dstatus               : in std_logic_vector(15 downto 0);
  cfg_dcommand              : in std_logic_vector(15 downto 0);
  cfg_lstatus               : in std_logic_vector(15 downto 0);
  cfg_lcommand              : in std_logic_vector(15 downto 0)
    
);
end pci_exp_64b_app;

architecture endpoint_blk_plus_v1_15 of pci_exp_64b_app is

component PIO is

port (

  trn_clk                : in std_logic;
  trn_reset_n            : in std_logic;
  trn_lnk_up_n           : in std_logic;

  trn_td                 : out std_logic_vector((64 - 1) downto 0);
  trn_trem_n             : out std_logic_vector(7 downto 0);
  trn_tsof_n             : out std_logic;
  trn_teof_n             : out std_logic;
  trn_tsrc_rdy_n         : out std_logic;
  trn_tsrc_dsc_n         : out std_logic;
  trn_tdst_rdy_n         : in std_logic;
  trn_tdst_dsc_n         : in std_logic;

  trn_rd                 : in std_logic_vector((64 - 1) downto 0);
  trn_rrem_n             : in std_logic_vector(7 downto 0);
  trn_rsof_n             : in std_logic;
  trn_reof_n             : in std_logic;
  trn_rsrc_rdy_n         : in std_logic;
  trn_rsrc_dsc_n         : in std_logic;
  trn_rbar_hit_n         : in std_logic_vector(6 downto 0);
  trn_rdst_rdy_n         : out std_logic;

  cfg_to_turnoff_n       : in std_logic;
  cfg_turnoff_ok_n       : out std_logic;
  cfg_completer_id       : in std_logic_vector(15 downto 0);
  cfg_bus_mstr_enable    : in std_logic

);

end component;

-- Local wires 

signal cfg_completer_id       : std_logic_vector(15 downto 0);
signal cfg_bus_mstr_enable    : std_logic;


begin 

  -- Core input tie-offs

  trn_rnp_ok_n              <= '0';
  trn_rcpl_streaming_n      <= '1'; 
  trn_terrfwd_n             <= '1';

  cfg_err_cor_n             <= '1';
  cfg_err_ur_n              <= '1';
  cfg_err_ecrc_n            <= '1';
  cfg_err_cpl_timeout_n     <= '1';
  cfg_err_cpl_abort_n       <= '1';
  cfg_err_cpl_unexpect_n    <= '1';
  cfg_err_posted_n          <= '0';
  cfg_interrupt_n           <= '1';

  cfg_interrupt_assert_n <= '0';
  cfg_interrupt_di <= X"00";

  cfg_pm_wake_n             <= '1';
  cfg_trn_pending_n         <= '1';
  cfg_dwaddr                <= (others => '0');
  cfg_err_tlp_cpl_header    <= (others => '0');
  cfg_di                    <= (others => '0');
  cfg_byte_en_n             <= X"F"; -- 4-bit bus
  cfg_wr_en_n               <= '1';
  cfg_rd_en_n               <= '1';
  cfg_completer_id          <= (cfg_bus_number &
                                cfg_device_number &
                                cfg_function_number);
  cfg_bus_mstr_enable       <= cfg_command(2);

-- Programmable I/O Module

PIO_interface : PIO 

port map (

  trn_clk  =>  trn_clk,                       -- I
  trn_reset_n  =>  trn_reset_n,               -- I
  trn_lnk_up_n  =>  trn_lnk_up_n,             -- I

  trn_td  => trn_td,                          -- O (63:0)
  trn_tsof_n  => trn_tsof_n,
  trn_trem_n  => trn_trem_n,
  trn_teof_n  => trn_teof_n,                  -- O
  trn_tsrc_rdy_n  => trn_tsrc_rdy_n,          -- O
  trn_tsrc_dsc_n  => trn_tsrc_dsc_n,          -- O
  trn_tdst_rdy_n  => trn_tdst_rdy_n,          -- I
  trn_tdst_dsc_n  => trn_tdst_dsc_n,          -- I

  trn_rd  => trn_rd ,                         -- I (63:0)
  trn_rrem_n  => trn_rrem_n,
  trn_rsof_n  => trn_rsof_n,                  -- I
  trn_reof_n  => trn_reof_n,                  -- I
  trn_rsrc_rdy_n  => trn_rsrc_rdy_n,          -- I
  trn_rsrc_dsc_n  => trn_rsrc_dsc_n,          -- I
  trn_rbar_hit_n => trn_rbar_hit_n,           -- I (6:0)
  trn_rdst_rdy_n  => trn_rdst_rdy_n,          -- O

  cfg_to_turnoff_n  => cfg_to_turnoff_n,      -- I
  cfg_turnoff_ok_n => cfg_turnoff_ok_n,    -- O
  cfg_completer_id  => cfg_completer_id,      -- I (15:0)
  cfg_bus_mstr_enable => cfg_bus_mstr_enable  -- I

);

end; -- pci_exp_64b_app
