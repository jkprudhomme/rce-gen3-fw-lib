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
-- File       : board.vhd
-- Version    : 1.9
--
-- Description:  Top level testbench
--
-- Hierarchy   : board
--               |
--               |--xilinx_pcie_2_1_rport_7x
--               |  |
--               |  |--cgator_wrapper
--               |  |  |
--               |  |  |--pcie_2_1_rport_7x (in source directory)
--               |  |  |  |
--               |  |  |  |--<various>
--               |  |  |
--               |  |  |--cgator
--               |  |     |
--               |  |     |--cgator_cpl_decoder
--               |  |     |--cgator_pkt_generator
--               |  |     |--cgator_tx_mux
--               |  |     |--cgator_gen2_enabler
--               |  |     |--cgator_controller
--               |  |        |--<cgator_cfg_rom.data> (specified by ROM_FILE)
--               |  |
--               |  |--pio_master
--               |     |
--               |     |--pio_master_controller
--               |     |--pio_master_checker
--               |     |--pio_master_pkt_generator
--               |
--               |--xilinx_pcie_2_1_ep_7x
--                  |
--                  |--<various>
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

entity board is
generic (
   LINK_CAP_MAX_LINK_WIDTH_int    : integer    := 1;
   REF_CLK_FREQ   : integer       := 0  -- 0 - 100 MHz, 1 - 125 MHz, 2 - 250 MHz
);
end board;

architecture rtl of board is

component xilinx_pcie_2_1_rport_7x is
generic (
  TCQ          : integer;
  SIMULATION   : integer;
  C_DATA_WIDTH : integer range 64 to 128;
  REF_CLK_FREQ : integer;
  ROM_FILE     : string;
  ROM_SIZE     : integer;
  USER_CLK_FREQ: integer;
  PL_FAST_TRAIN: string
  );
port  (

  sys_clk_p         : in std_logic;
  sys_clk_n         : in std_logic;

  free_clk          : in std_logic;

  sys_rst_n         : in std_logic;

  RXN               : in std_logic_vector(0 downto 0);
  RXP               : in std_logic_vector(0 downto 0);
  TXN               : out std_logic_vector(0 downto 0);
  TXP               : out std_logic_vector(0 downto 0);

  -- Status outputs
  led_2           : out std_logic;  -- user_lnk_up
  led_3           : out std_logic;  -- pio_test_finished
  led_4           : out std_logic;  -- finished_config
  led_5           : out std_logic;  -- failed_config OR pio_test_failed
  led_6           : out std_logic;  -- pl_sel_link_rate

  link_retrain_sw   : in std_logic;
  pio_restart_sw    : in std_logic;
  full_test_sw      : in std_logic

  );

end component;

component xilinx_pcie_2_1_ep_7x is
  generic (
  REF_CLK_FREQ                  : integer    ;
  PCIE_EXT_CLK                  : string     ;
  PL_FAST_TRAIN                 : string     ;
  ALLOW_X8_GEN2                 : string     ;
  C_DATA_WIDTH                  : integer    ;
  LINK_CAP_MAX_LINK_WIDTH       : bit_vector ;
  DEVICE_ID                     : bit_vector ;
  LINK_CAP_MAX_LINK_SPEED       : bit_vector ;

  LINK_CTRL2_TARGET_LINK_SPEED  : bit_vector ;
  DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer    ;
  USER_CLK_FREQ                 : integer    ;
  USER_CLK2_DIV2                : string     ;
  TRN_DW                        : string     ;
  VC0_TX_LASTPACKET             : integer    ;
  VC0_RX_RAM_LIMIT              : bit_vector ;
  VC0_CPL_INFINITE              : string     ;
  VC0_TOTAL_CREDITS_PD          : integer    ;
  VC0_TOTAL_CREDITS_CD          : integer    ;
  LINK_CAP_MAX_LINK_WIDTH_int   : integer    ;
  LINK_CAP_MAX_LINK_SPEED_int   : integer    
);
port  (

  pci_exp_txp                   : out std_logic_vector(LINK_CAP_MAX_LINK_WIDTH_int-1 downto 0);
  pci_exp_txn                   : out std_logic_vector(LINK_CAP_MAX_LINK_WIDTH_int-1 downto 0);
  pci_exp_rxp                   : in  std_logic_vector(LINK_CAP_MAX_LINK_WIDTH_int-1 downto 0);
  pci_exp_rxn                   : in  std_logic_vector(LINK_CAP_MAX_LINK_WIDTH_int-1 downto 0);

  sys_clk_p                     : in std_logic;
  sys_clk_n                     : in std_logic;
  sys_rst_n                     : in std_logic

);
end component;


component sys_clk_gen
generic (
  CLK_FREQ: integer
);
port (

  sys_clk : out std_logic

);
end component;

function pad_gen (
   in_vec   : bit_vector;
   op_len   : integer)
   return bit_vector is
   variable ret : bit_vector(op_len-1 downto 0) := (others => '0');
   constant len : integer := in_vec'length;  -- length of input vector
begin  -- pad_gen
   for i in 0 to op_len-1 loop
      if (i < len) then
         ret(i) := in_vec(len-i-1);
      else
         ret(i) := '0';
      end if;
   end loop;  -- i
   return ret;
end pad_gen;



signal sys_rst_n        : std_logic := '1';
signal sys_clk          : std_logic;
signal sys_clk_n        : std_logic;

signal ep_pci_exp_txn   : std_logic_vector(0 downto 0);
signal ep_pci_exp_txp   : std_logic_vector(0 downto 0);
signal rp_pci_exp_txn   : std_logic_vector(0 downto 0);
signal rp_pci_exp_txp   : std_logic_vector(0 downto 0);

signal link_up_led      : std_logic;
signal rx_check_ok_led  : std_logic;
signal cfg_done_led     : std_logic;
--signal link_x8_led      : std_logic;
--signal link_x4_led      : std_logic;
--signal link_x2_led      : std_logic;
--signal link_x1_led      : std_logic;
signal pl_sel_link_rate : std_logic;
signal link_gen2_led    : std_logic;
signal error_led        : std_logic;

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

--************************************************************
--  Proc : FINISH
--  Inputs : None
--  Outputs : None
--  Description : Ends simulation with successful message
--*************************************************************/

procedure FINISH is

  variable  L : line;

begin

  assert (false)
    report "Simulation Stopped."
    severity failure;

end FINISH;


--************************************************************
--  Proc : FINISH_FAILURE
--  Inputs : None
--  Outputs : None
--  Description : Ends simulation with failure message
--*************************************************************/

procedure FINISH_FAILURE is

  variable  L : line;

begin

  assert (false)
    report "Simulation Ended With 1 or more failures"
    severity failure;

end FINISH_FAILURE;


begin


RP : xilinx_pcie_2_1_rport_7x
generic map (
  TCQ          => 1,
  SIMULATION   => 1,
  C_DATA_WIDTH => 64,
  REF_CLK_FREQ => REF_CLK_FREQ,
  ROM_FILE     => "../../example_design/cgator_cfg_rom.data",
  ROM_SIZE     => 32,
  USER_CLK_FREQ=> 1,
  PL_FAST_TRAIN=>"TRUE"
  )
port map (

  -- Reference clock
  sys_clk_p   => sys_clk,
  sys_clk_n   => sys_clk_n,

  -- Free-running clock input
  free_clk    => sys_clk,

  -- System-level reset input
  sys_rst_n   => sys_rst_n,

  -- PCI Express interface
  RXN         => ep_pci_exp_txn,
  RXP         => ep_pci_exp_txp,
  TXN         => rp_pci_exp_txn,
  TXP         => rp_pci_exp_txp,

  -- Status outputs
  led_2       => link_up_led,        -- user_lnk_up
  led_3       => rx_check_ok_led,    -- pio_test_finished
  led_4       => cfg_done_led,       -- finished_config
  led_5       => error_led,          -- failed_config OR pio_test_failed
  led_6       => pl_sel_link_rate,   -- pl_sel_link_rate

  -- Control inputs
  link_retrain_sw => '0',
  pio_restart_sw  => '0',
  full_test_sw    => '0'
);

link_gen2_led <= ( pl_sel_link_rate AND link_up_led );

EP : xilinx_pcie_2_1_ep_7x generic map (

  REF_CLK_FREQ                  => 0,
  PCIE_EXT_CLK                  => "FALSE",
  PL_FAST_TRAIN                 => "TRUE",
  ALLOW_X8_GEN2                 => "FALSE",
  C_DATA_WIDTH                  => 64,

  LINK_CAP_MAX_LINK_WIDTH       => X"01",
  DEVICE_ID                     => X"7100",
  LINK_CAP_MAX_LINK_SPEED       => X"1",
  LINK_CTRL2_TARGET_LINK_SPEED  => X"1",
  DEV_CAP_MAX_PAYLOAD_SUPPORTED => 0,
  USER_CLK_FREQ                 => 1,
  USER_CLK2_DIV2                => "FALSE",
  TRN_DW                        => "FALSE",
  VC0_TX_LASTPACKET             => 25,
  VC0_RX_RAM_LIMIT              => pad_gen(X"1FF", 13),
  VC0_CPL_INFINITE              => "TRUE",
  VC0_TOTAL_CREDITS_PD          => 32,
  VC0_TOTAL_CREDITS_CD          => 114,
  LINK_CAP_MAX_LINK_WIDTH_int   => 1,
  LINK_CAP_MAX_LINK_SPEED_int   => 1)
port  map (

  pci_exp_txp           => ep_pci_exp_txp,
  pci_exp_txn           => ep_pci_exp_txn,
  pci_exp_rxp           => rp_pci_exp_txp,
  pci_exp_rxn           => rp_pci_exp_txn,

  sys_clk_p             => sys_clk,
  sys_clk_n             => sys_clk_n,
  sys_rst_n             => sys_rst_n


);



CLK_GEN : sys_clk_gen
generic map (CLK_FREQ => 100)
port map (
  sys_clk => sys_clk
);

  sys_clk_n <= not(sys_clk);

BOARD_INIT : process
begin

  writeNowToScreen(String'("System Reset Asserted..."));

  sys_rst_n <= '0';

  for i in 0 to (500 - 1) loop

    wait until (sys_clk'event and sys_clk = '1');

  end loop;

  writeNowToScreen(String'("System Reset De-asserted..."));

  sys_rst_n <= '1';

  wait;

end process BOARD_INIT;

-- purpose: Message and simulation control : Trn Reset Deassertion
--TRN_RST: process
--begin  -- process TRN_RST
--
--  wait for 200 ns;
--
--  wait until (trn_reset_n'event and trn_reset_n = '1');
--
--  writeNowToScreen(String'("TRN Reset De-asserted"));
--
--end process TRN_RST;

-- purpose: Message and simulation control : Link Up
TRN_LNK_UP: process
begin  -- process TRN_LNK_UP

  wait for 200 ns;

  wait until (link_up_led'event and link_up_led = '1');

  writeNowToScreen(String'("Link Up"));

end process TRN_LNK_UP;


-- purpose: Message and simulation control : Link Rate 5.0 GT/s
PL_LNK_50: process
begin  -- process PL_LNK_50

  wait for 200 ns;

  wait until (link_gen2_led'event and link_gen2_led = '1');

  writeNowToScreen(String'("Link Trained up to 5.0 GT/s"));

end process PL_LNK_50;


-- purpose: Message and simulation control : Configuration Succeeded
Cfg_Success: process
begin  -- process Cfg_Success

  wait for 200 ns;

  wait until (cfg_done_led'event and cfg_done_led = '1');

  writeNowToScreen(String'("Configuration Succeeded"));

end process Cfg_Success;


-- purpose: Message and simulation control : PIO Test Passes
PIO_Pass: process
begin  -- process PIO_Pass

  wait for 200 ns;

  wait until (rx_check_ok_led'event and rx_check_ok_led = '1');

  writeNowToScreen(String'("PIO TEST PASSED"));
  writeNowToScreen(String'("Test Completed Successfully"));
  FINISH;

end process PIO_Pass;


-- purpose: Message and simulation control : Configuration / PIO Test Failed
Test_Failed: process
begin  -- process Test_Failed

  wait for 200 ns;

  wait until (error_led'event and error_led = '1');

  writeNowToScreen(String'("Configuration / PIO TEST FAILED"));
  FINISH_FAILURE;

end process Test_Failed;


-- purpose: Message and simulation control : Simulation Timeout
Sim_Timeout: process
begin  -- process Sim_Timeout

  wait for 200 us;

  writeNowToScreen(String'("Simulation timeout. TEST FAILED"));
  FINISH_FAILURE;

end process Sim_Timeout;


end; -- board
