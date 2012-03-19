-------------------------------------------------------------------------------
-- rx_fifo_control.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--  ***************************************************************************
--  ** DISCLAIMER OF LIABILITY                                               **
--  **                                                                       **
--  **  This file contains proprietary and confidential information of       **
--  **  Xilinx, Inc. ("Xilinx"), that is distributed under a license         **
--  **  from Xilinx, and may be used, copied and/or disclosed only           **
--  **  pursuant to the terms of a valid license agreement with Xilinx.      **
--  **                                                                       **
--  **  XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION                **
--  **  ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER           **
--  **  EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT                  **
--  **  LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,            **
--  **  MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx        **
--  **  does not warrant that functions included in the Materials will       **
--  **  meet the requirements of Licensee, or that the operation of the      **
--  **  Materials will be uninterrupted or error-free, or that defects       **
--  **  in the Materials will be corrected. Furthermore, Xilinx does         **
--  **  not warrant or make any representations regarding use, or the        **
--  **  results of the use, of the Materials in terms of correctness,        **
--  **  accuracy, reliability or otherwise.                                  **
--  **                                                                       **
--  **  Xilinx products are not designed or intended to be fail-safe,        **
--  **  or for use in any application requiring fail-safe performance,       **
--  **  such as life-support or safety devices or systems, Class III         **
--  **  medical devices, nuclear facilities, applications related to         **
--  **  the deployment of airbags, or any other applications that could      **
--  **  lead to death, personal injury or severe property or                 **
--  **  environmental damage (individually and collectively, "critical       **
--  **  applications"). Customer assumes the sole risk and liability         **
--  **  of any use of Xilinx products in critical applications,              **
--  **  subject only to applicable laws and regulations governing            **
--  **  limitations on product liability.                                    **
--  **                                                                       **
--  **  Copyright 2007, 2008, 2009 Xilinx, Inc.                              **
--  **  All rights reserved.                                                 **
--  **                                                                       **
--  **  This disclaimer and copyright notice must be retained as part        **
--  **  of this file at all times.                                           **
--  ***************************************************************************
-------------------------------------------------------------------------------
-- Filename:        rx_fifo_control.vhd
-- Version:         v3.00a
-- Description:     Contains UART rx FIFO control logic
--
-- VHDL-Standard:   VHDL'93
--
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
-- Structure:   
--                  xps_uart16550.vhd
--                      -- xuart.vhd
--                          -- plbv46_slave_single.vhd
--                          -- ipic_if.vhd
--                          -- uart16550.vhd
--                              -- rx16550.vhd
--                              -- tx16550.vhd
--                              -- xuart_tx_load_sm.vhd
--                              -- tx_fifo_block.vhd
--                              -- rx_fifo_block.vhd
--                                  -- rx_fifo_control.vhd
-------------------------------------------------------------------------------
---- Revisions  :
-- ~~~~~~~~~~~~~~
--   PVK                8/28/08         v2.01.a
-- ^^^^^^^
--  First version of rx_fifo_control
--  Integrated this code in rx_fifo_block.
-- ~~~~~~~
--  PVK                05/25/09     
-- ^^^^^^^
--  Updated to new version v3.00.a 
-- ~~~~~~~
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x" 
--      reset signals:                          "rst", "rst_n" 
--      generics:                               "C_*" 
--      user defined types:                     "*_TYPE" 
--      state machine next state:               "*_ns" 
--      state machine current state:            "*_cs" 
--      combinatorial signals:                  "*_cmb" 
--      pipelined or register delay signals:    "*_d#" 
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce" 
--      internal version of output port         "*_i"
--      device pins:                            "*_pin" 
--      ports:                                  - Names begin with Uppercase 
--      processes:                              "*_PROCESS" 
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned."+";

-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------
entity rx_fifo_control is
generic (
    C_FAMILY         : string := "virtex5");              -- XILINX FPGA family
  port (
    Rst              : in  std_logic;                     -- Rst
    Sys_clk          : in  std_logic;                     -- Sys Clock
    Rclk             : in  std_logic;                     -- Receiver clock  
    Fcr              : in  std_logic_vector(7 downto 0 ); -- Fifo Control reg
    Rx_fifo_empty    : in  std_logic;                     -- Rx fifo empty
    Rx_fifo_count    : in  std_logic_vector(3 downto 0 ); -- Rx fifo count
    Rx_fifo_rd_en    : in  std_logic;                     -- Rx fifo read en
    Rx_fifo_wr_en    : in  std_logic;                     -- Rx fifo write en
    Rx_fifo_data_in  : in  std_logic_vector(10 downto 0); -- Rx fifo data in
    Rx_fifo_trigger  : out std_logic;                     -- Rx fifo trigger
    Rx_fifo_timeout  : out std_logic;                     -- Rx fifo timeout
    Rx_error_in_fifo : out std_logic;                     -- Rx error in fifo
    Rx_fifo_rst      : in  std_logic                      -- Rx fifo rst
    );

end rx_fifo_control;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------
architecture implementation of rx_fifo_control is
  
-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------
  signal trigger_level_in        : std_logic_vector(1 downto 0 );
  signal fifo_trigger_level      : std_logic_vector(3 downto 0 );
  signal fifo_trigger_level_flag : std_logic;
  signal character_counter       : std_logic_vector(9 downto 0);
  signal character_counter_rst   : std_logic;
  signal character_counter_en    : std_logic;
  
begin

  trigger_level_in <= fcr(7) & fcr(6);

  -----------------------------------------------------------------------------
  -- PROCESS: FIFO_TRIGGER_LEVEL_DECODE_PROCESS
  -- purpose: rx_fifo trigger level generation
  -----------------------------------------------------------------------------
  FIFO_TRIGGER_LEVEL_DECODE_PROCESS : process (trigger_level_in)
  begin  -- process
    case trigger_level_in is
      when "00" =>
        fifo_trigger_level <= "0000";   
      when "01" =>                      
        fifo_trigger_level <= "0011";   
      when "10" =>                      
        fifo_trigger_level <= "0111";   
      when "11" =>                      
        fifo_trigger_level <= "1101";   
      when others =>
        fifo_trigger_level <= "0000"; 
    end case;
  end process;

  fifo_trigger_level_flag <= '1' when ( rx_fifo_empty = '0' and 
                                ((rx_fifo_count >= fifo_trigger_level) = TRUE))
                                else '0';

  -----------------------------------------------------------------------------
  -- PROCESS: FIFO_TRIGGER_LEVEL_PROC
  -- purpose: rx_fifo trigger flag generation
  -----------------------------------------------------------------------------
  FIFO_TRIGGER_LEVEL_PROC : process (Sys_clk)
  begin  -- process
    if Sys_clk'EVENT and Sys_clk = '1' then
      if Rst = '1' then                  -- asynchronous reset (active high)
        rx_fifo_trigger <= '0';
      else
        rx_fifo_trigger <= fifo_trigger_level_flag;
      end if;  
    end if;
  end process;

  -- Character counter reset
  character_counter_rst <= '1' when (rx_fifo_rd_en = '1' or rx_fifo_wr_en = '1'
                                  or rx_fifo_empty = '1' or rx_fifo_rst = '1')
                                  else 
                           '0';
                           
  -- Character counter enable
  character_counter_en  <= '1' when (character_counter(9) = '0' or 
                                     character_counter(8) = '0') else 
                           '0';
                       
  -- rx_fifo timeout 
  rx_fifo_timeout       <= '1' when (character_counter(9) = '1' and 
                                     character_counter(8) = '1' and 
                                     rx_fifo_empty = '0')       else 
                           '0';

  -----------------------------------------------------------------------------
  -- PROCESS: FIFO_CHARACTER_TIMEOUT
  -- purpose: character counter timeout
  -----------------------------------------------------------------------------
  FIFO_CHARACTER_TIMEOUT : process (Sys_clk)
  begin
    if Sys_clk'EVENT and Sys_clk = '1' then
      if character_counter_rst = '1' then
        character_counter <= "0000000000";
      elsif rclk = '1' and character_counter_en = '1' then
        character_counter <= character_counter + "0000000001";
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- PROCESS: RX_ERROR_IN_FIFO_PROC
  -- purpose: tracks parity, framing and break errors in rx fifo
  -----------------------------------------------------------------------------
  RX_ERROR_IN_FIFO_PROC : process (Sys_clk) is
  begin  -- process RX_ERROR_IN_FIFO_PROC
    if Sys_clk'EVENT and Sys_clk = '1' then  -- rising clock edge
      if Rst = '1' then                  -- asynchronous reset (active high)
        rx_error_in_fifo <= '0';
      else
        rx_error_in_fifo <= (rx_fifo_data_in(10) or rx_fifo_data_in(9) or 
                             rx_fifo_data_in(8)) and rx_fifo_wr_en;
      end if;
    end if;
  end process RX_ERROR_IN_FIFO_PROC;

end implementation;

