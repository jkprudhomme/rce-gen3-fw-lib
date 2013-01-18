
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
-- File       : pci_exp_usrapp_tx.vhd

---- Filename: pci_exp_usrapp_tx.vhd
----
---- Description:  PCI Express dsport Tx interface.
----
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

entity pci_exp_usrapp_tx is

port (

  trn_td                   : out std_logic_vector ((64 - 1) downto 0 );
  trn_trem_n               : out std_logic_vector ((8 - 1) downto 0 );
  trn_tsof_n               : out std_logic;
  trn_teof_n               : out std_logic;
  trn_terrfwd_n	           : out std_logic;
  trn_tsrc_rdy_n           : out std_logic;
  trn_tsrc_dsc_n           : out std_logic;
  trn_clk                  : in std_logic;
  trn_reset_n              : in std_logic;
  trn_lnk_up_n             : in std_logic;
  trn_tdst_rdy_n           : in std_logic;
  trn_tdst_dsc_n           : in std_logic;
  trn_tbuf_av              : in std_logic_vector ((5 - 1) downto 0);
  rx_tx_read_data          : in std_logic_vector(31 downto 0);
  rx_tx_read_data_valid    : in std_logic;
  tx_rx_read_data_valid    : out std_logic

);

end pci_exp_usrapp_tx;

architecture rtl of pci_exp_usrapp_tx is

component tests
generic (
  test_selector : in string  := String'("sample_smoke_test0")
 );
port (

  trn_td                   : out std_logic_vector ((64 - 1) downto 0 );
  trn_trem_n               : out std_logic_vector ((8 - 1) downto 0 );
  trn_tsof_n               : out std_logic;
  trn_teof_n               : out std_logic;
  trn_terrfwd_n	           : out std_logic;
  trn_tsrc_rdy_n           : out std_logic;
  trn_tsrc_dsc_n           : out std_logic;
  trn_clk                  : in std_logic;
  trn_reset_n              : in std_logic;
  trn_lnk_up_n             : in std_logic;
  trn_tdst_rdy_n           : in std_logic;
  trn_tdst_dsc_n           : in std_logic;
  trn_tbuf_av              : in std_logic_vector ((5 - 1) downto 0);
  rx_tx_read_data          : in std_logic_vector(31 downto 0);
  rx_tx_read_data_valid    : in std_logic;
  tx_rx_read_data_valid    : out std_logic

);

end component;


begin

 TESTS_INST :  tests
generic map (

  test_selector => String'("pio_writeReadBack_test0")

 )
port map (

  trn_td => trn_td,
    trn_trem_n => trn_trem_n,
  trn_tsof_n => trn_tsof_n,
  trn_teof_n => trn_teof_n,
  trn_terrfwd_n => trn_terrfwd_n,
  trn_tsrc_rdy_n => trn_tsrc_rdy_n,
  trn_tsrc_dsc_n => trn_tsrc_dsc_n,
  trn_clk => trn_clk,
  trn_reset_n => trn_reset_n,
  trn_lnk_up_n => trn_lnk_up_n,
  trn_tdst_rdy_n => trn_tdst_rdy_n,
  trn_tdst_dsc_n => trn_tdst_dsc_n,
  trn_tbuf_av => trn_tbuf_av,

  rx_tx_read_data => rx_tx_read_data,
  rx_tx_read_data_valid => rx_tx_read_data_valid,
  tx_rx_read_data_valid => tx_rx_read_data_valid

);

end; -- pci_exp_usrapp_tx
