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
-- File       : pcie_7x_v1_9_fast_cfg_init_cntr.vhd
-- Version    : 1.9
--
-- Description:  PCIe Fast Configuration Init Counter
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pcie_7x_v1_9_fast_cfg_init_cntr is
  generic (
    PATTERN_WIDTH : integer                      := 8;
    INIT_PATTERN1 : std_logic_vector(7 downto 0) := X"12";
    INIT_PATTERN2 : std_logic_vector(7 downto 0) := X"9a";
    INIT_PATTERN  : std_logic_vector(7 downto 0) := X"34";
    TCQ           : time                         := 1 ns
  );
  port (
    clk                      : in std_logic;
    rst                      : in std_logic;
  
    pattern_o                : out std_logic_vector(PATTERN_WIDTH-1 downto 0)
  );

end pcie_7x_v1_9_fast_cfg_init_cntr;

architecture rtl of pcie_7x_v1_9_fast_cfg_init_cntr is

  signal init_pattern1_reg    : std_logic_vector(PATTERN_WIDTH-1 downto 0) := (others => '0');
  signal init_pattern2_reg    : std_logic_vector(PATTERN_WIDTH-1 downto 0) := (others => '0');
  signal init_toggle          : std_logic                                  := '0';
  signal pattern_o_int        : std_logic_vector(PATTERN_WIDTH-1 downto 0) := (others => '0');
  signal init_pattern_bus_pre : std_logic_vector(PATTERN_WIDTH-1 downto 0) := (others => '0');

  attribute KEEP : boolean;
  attribute KEEP of init_pattern1_reg    : signal is true;  
  attribute KEEP of init_pattern2_reg    : signal is true;  
  attribute KEEP of init_toggle          : signal is true;  
  attribute KEEP of init_pattern_bus_pre : signal is true;  
  attribute KEEP of pattern_o_int        : signal is true;  

  begin
  
    -----------------------------------------------
    --  Implement counter
    -----------------------------------------------
    process(clk)
    begin

      if rising_edge(clk) then
        if rst = '1' then
           init_pattern1_reg    <= (NOT INIT_PATTERN1) after TCQ;
           init_pattern2_reg    <= (NOT INIT_PATTERN2) after TCQ;
           init_toggle          <= '0' after TCQ;
           init_pattern_bus_pre <= (others => '0') after TCQ;
           pattern_o_int        <= (others => '0') after TCQ;
        else
           init_pattern1_reg    <= INIT_PATTERN1 after TCQ;
           init_pattern2_reg    <= INIT_PATTERN2 after TCQ;
           init_toggle          <= (NOT init_toggle) after TCQ;
             if init_toggle = '1' then
                init_pattern_bus_pre <= init_pattern1_reg after TCQ;
             else
                init_pattern_bus_pre <= init_pattern2_reg after TCQ;
             end if;
           pattern_o_int         <= init_pattern_bus_pre after TCQ;
        end if;
      end if;
    end process;

    pattern_o <= pattern_o_int;

end rtl;
