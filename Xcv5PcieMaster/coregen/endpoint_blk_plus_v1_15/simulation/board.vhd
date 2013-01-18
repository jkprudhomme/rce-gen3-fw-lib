

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
-- File       : board.vhd
----
---- Description:  Top level testbench
----
----
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;


entity board is
generic (
           REF_CLK_FREQ   : INTEGER := 1     -- 0 - 100 MHz, 1 - 250 MHz
);
end board;

architecture rtl of board is


component XILINX_PCI_EXP_EP is
generic (

  FAST_SIMULATION   : INTEGER := 0

) ;

port  (

  sys_clk_p         : in std_logic;
  sys_clk_n         : in std_logic;
  sys_reset_n       : in std_logic;

  pci_exp_rxn       : in std_logic_vector((1 - 1) downto 0);
  pci_exp_rxp       : in std_logic_vector((1 - 1) downto 0);
  pci_exp_txn       : out std_logic_vector((1 - 1) downto 0);
  pci_exp_txp       : out std_logic_vector((1 - 1) downto 0)

);

end component;


component xilinx_pcie_2_0_rport_v6 is
generic (
          REF_CLK_FREQ   : integer;          -- 0 - 100 MHz, 1 - 125 MHz,  2 - 250 MHz
          ALLOW_X8_GEN2  : string;
          PL_FAST_TRAIN  : string;
          LINK_CAP_MAX_LINK_WIDTH  : integer;
          DEVICE_ID : bit_vector;
          LINK_CAP_MAX_LINK_SPEED : integer;
          LINK_CTRL2_TARGET_LINK_SPEED  : integer;
          DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer;
          USER_CLK_FREQ : integer;
          VC0_TX_LASTPACKET : integer;
          VC0_RX_RAM_LIMIT : integer;
          VC0_CPL_INFINITE : string;
          VC0_TOTAL_CREDITS_PD : integer;
          VC0_TOTAL_CREDITS_CD : integer

);
port  (

  sys_clk : in std_logic;
  sys_reset_n : in std_logic;

  pci_exp_rxn : in std_logic_vector((1 - 1) downto 0);
  pci_exp_rxp : in std_logic_vector((1 - 1) downto 0);
  pci_exp_txn : out std_logic_vector((1 - 1) downto 0);
  pci_exp_txp : out std_logic_vector((1 - 1) downto 0)

);
end component;

component sys_clk_gen
generic (

  CLK_FREQ: INTEGER := 250

);
port (

  sys_clk : out std_logic

);
end component;


component sys_clk_gen_ds
generic (

  CLK_FREQ: INTEGER := 250

);
port (

  sys_clk_p : out std_logic;
  sys_clk_n : out std_logic

);
end component;


signal cor_sys_reset_n : std_logic := '1';
signal cor_sys_clk_p : std_logic;
signal cor_sys_clk_n : std_logic;
signal rp_sys_clk : std_logic;


signal cor_pci_exp_txn : std_logic_vector((1 - 1) downto 0);
signal cor_pci_exp_txp : std_logic_vector((1 - 1) downto 0);
signal cor_pci_exp_rxn : std_logic_vector((1 - 1) downto 0);
signal cor_pci_exp_rxp : std_logic_vector((1 - 1) downto 0);

shared variable i          : INTEGER;

--************************************************************
--     Proc : writeNowToScreen
--     Inputs : Text String
--     Outputs : None
--     Description : Displays current simulation time and text string to
--          standard output.
--   *************************************************************

procedure writeNowToScreen (

  text_string                 : in string

) is

  variable L      : line;

begin

  write (L, String'("[ "));
  write (L, now);
  write (L, String'(" ] : "));
  write (L, text_string);
  writeline (output, L);

end writeNowToScreen;



begin

EP_INST : XILINX_PCI_EXP_EP generic map (

  FAST_SIMULATION => 1

)
port  map (

  sys_clk_p => cor_sys_clk_p,
  sys_clk_n => cor_sys_clk_n,

        --PCI-Express Interface
  pci_exp_rxn => cor_pci_exp_rxn,
  pci_exp_rxp => cor_pci_exp_rxp,
  pci_exp_txn => cor_pci_exp_txn,
  pci_exp_txp => cor_pci_exp_txp,

  sys_reset_n => cor_sys_reset_n

);


RP : xilinx_pcie_2_0_rport_v6
generic map (
      REF_CLK_FREQ => (2),
      PL_FAST_TRAIN => ("TRUE"),
      LINK_CAP_MAX_LINK_WIDTH => (1),
      DEVICE_ID => (X"0007"),
      ALLOW_X8_GEN2 => ("FALSE"),
      LINK_CAP_MAX_LINK_SPEED => (1),
      LINK_CTRL2_TARGET_LINK_SPEED => (1),
      DEV_CAP_MAX_PAYLOAD_SUPPORTED => (2),
      VC0_TX_LASTPACKET => (29),
      VC0_RX_RAM_LIMIT => (2047),
      VC0_CPL_INFINITE => ("TRUE"),
      VC0_TOTAL_CREDITS_PD => (308),
      VC0_TOTAL_CREDITS_CD => (308),
      USER_CLK_FREQ => (0+1)

)
port map (

  sys_clk => rp_sys_clk,
  sys_reset_n => cor_sys_reset_n,

  pci_exp_txn => cor_pci_exp_rxn,
  pci_exp_txp => cor_pci_exp_rxp,
  pci_exp_rxn => cor_pci_exp_txn,
  pci_exp_rxp => cor_pci_exp_txp


);

sys_clk_gen_ds_inst : sys_clk_gen
generic map (CLK_FREQ => 250)
port map (

  sys_clk => rp_sys_clk

);


sys_clk_gen_cor_inst : sys_clk_gen_ds
generic map (CLK_FREQ => 250)
port map (

  sys_clk_p => cor_sys_clk_p,
  sys_clk_n => cor_sys_clk_n

);

BOARD_INIT : process
begin

  writeNowToScreen(String'("System Reset Asserted..."));

  cor_sys_reset_n <= '0';

  for i in 0 to (500 - 1) loop

    wait until (cor_sys_clk_p'event and cor_sys_clk_p = '1');

  end loop;

  writeNowToScreen(String'("System Reset De-asserted..."));

  cor_sys_reset_n <= '1';

  wait;

end process BOARD_INIT;


end; -- board
