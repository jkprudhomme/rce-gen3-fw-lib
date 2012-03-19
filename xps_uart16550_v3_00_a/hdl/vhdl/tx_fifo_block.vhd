-------------------------------------------------------------------------------
-- tx_fifo_block.vhd - entity/architecture pair
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
-- Filename:        tx_fifo_block.vhd
-- Version:         v3.00a
-- Description:     Contains the uart transmitter fifo
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
--   BSB                9/22/06
-- ^^^^^^^
--  First version of tx_fifo_block
--  Integrated this code in xps_uart16550
-- ~~~~~~~
--   PVK                8/28/08
-- ^^^^^^^
--  Updated to new version v2.01.a.
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
use ieee.STD_LOGIC_1164.all;

-------------------------------------------------------------------------------
-- proc common package of the proc common library is used for different 
-- function declarations
-------------------------------------------------------------------------------
library proc_common_v3_00_a;
use proc_common_v3_00_a.srl_fifo_rbu_f;

-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------
entity tx_fifo_block is
  generic (
    C_FAMILY         : string := "virtex5");              -- XILINX FPGA family
  port (
    Tx_fifo_data_in  : in  STD_LOGIC_VECTOR(7 downto 0 ); -- Tx fifo data in
    Tx_fifo_wr_en    : in  STD_LOGIC;                     -- Tx fifo write en  
    Tx_fifo_data_out : out STD_LOGIC_VECTOR(7 downto 0 ); -- Tx fifo data out
    Tx_fifo_clk      : in  STD_LOGIC;                     -- Tx fifo clk
    Tx_fifo_rd_en    : in  STD_LOGIC;                     -- Tx fifo read en  
    Tx_fifo_rst      : in  STD_LOGIC;                     -- Tx fifo Rst   
    Tx_fifo_empty    : out STD_LOGIC;                     -- Tx fifo empty  
    Tx_fifo_full     : out STD_LOGIC                      -- Tx fifo full   
    );

end tx_fifo_block;


-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------
architecture implementation of tx_fifo_block is
 
  signal tx_fifo_empty_i : STD_LOGIC;
  signal tx_fifo_full_i  : STD_LOGIC;
  signal tx_fifo_rd_en_i : STD_LOGIC;
  signal tx_fifo_wr_en_i : STD_LOGIC;

begin
  Tx_fifo_empty   <= tx_fifo_empty_i;
  Tx_fifo_full    <= tx_fifo_full_i;
  tx_fifo_rd_en_i <= Tx_fifo_rd_en and (not tx_fifo_empty_i);
  tx_fifo_wr_en_i <= Tx_fifo_wr_en and (not tx_fifo_full_i);
 
 ---new code for v5 porting--avinash-04/17/06--
   srl_fifo_rbu_f_i1 : entity proc_common_v3_00_a.srl_fifo_rbu_f
     generic map (
       C_DWIDTH => 8,
       C_DEPTH  => 16,
       C_FAMILY => C_FAMILY
                 )
     port map (
       Clk           => Tx_fifo_clk,       -- [in]
       Reset         => Tx_fifo_rst,       -- [in]
       FIFO_Write    => tx_fifo_wr_en_i,   -- [in]
       Data_In       => Tx_fifo_data_in,   -- [in]
       FIFO_Read     => tx_fifo_rd_en_i,   -- [in]
       Data_Out      => Tx_fifo_data_out,  -- [out]
       FIFO_Full     => tx_fifo_full_i,    -- [out]
       FIFO_Empty    => tx_fifo_empty_i,   -- [out]
       Addr          => open,              -- [out]
       Num_To_Reread => X"0",              -- [in]
       Underflow     => open,              -- [out]
       Overflow      => open);             -- [out]
  -------------------------------------------    
end implementation;
