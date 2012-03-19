-------------------------------------------------------------------------------
--  $Id: qual_priority.vhd,v 1.1.2.1 2010/07/13 16:33:58 srid Exp $
-------------------------------------------------------------------------------
-- qual_priority.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
-- *************************************************************************
--
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2008 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--
--
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        qual_priority.vhd
-- Version:         v1.04a
-- Description:     This file decodes the master's priority bits if its request
--                  is asserted. Unlike QualReq, this file doesn't examine the
--                  master's abort signal or the master disable register.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:  (see plb_v46.vhd)
--
-------------------------------------------------------------------------------
-- Author:      ALS
-- History:
--      ALS     02/20/02        -- created from plb_arbiter_v1_01_a
--      ALS     04/16/02        -- Version v1.01a
-- ^^^^^^
--  FLO         06/03/05        
-- ^^^^^^
-- Start of changes for plb_v46.
-- -Added port RNW_has_exp_value.
-- -Changed structure section to a reference to plb_v46.vhd.
-- ~~~~~~
--  JLJ         09/14/07    v1.01a  
-- ^^^^^^
--  Update to v1.01a.
-- ~~~~~~
--  JLJ         10/09/07    v1.02a  
-- ^^^^^^
--  Update to v1.02a.
-- ~~~~~~
--  JLJ         10/31/07    v1.02a  
-- ^^^^^^
--  Add code coverage off/on.
-- ~~~~~~
--  JLJ         03/17/08    v1.03a  
-- ^^^^^^
--  Upgraded to v1.03a. 
-- ~~~~~~
--  JLJ         05/15/08    v1.04a  
-- ^^^^^^
--  Updated to v1.04a (to migrate using proc_common_v3_00_a) in EDK L.
-- ~~~~~~
--  JLJ         09/12/08    v1.04a  
-- ^^^^^^
--  Update disclaimer of liability.
-- ~~~~~~
-------------------------------------------------------------------------------
-- 
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x" 
--      reset signals:                          "rst", "rst_n" 
--      generics:                               "C_*" 
--      user defined types:                     "*_TYPE" 
--      state machine next state:               "*_ns" 
--      state machine current state:            "*_cs" 
--      combinatorial signals:                  "*_com" 
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
-- Port Declaration
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Generics:
--      No generics used              
--
-- Definition of Ports:
--      input Request               -- master's request signal
--      RNW_has_exp_value           -- Allows for R/W differentiation
--      input Priority              -- master's priority signals
--
--      output Lvl1_n               -- master's priority was lvl 1 (active low)
--      output Lvl2_n               -- master's priority was lvl 2 (active low)
--      output Lvl3_n               -- master's priority was lvl 3 (active low)
-------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------
entity qual_priority is
  port (
        Request : in std_logic;
        RNW_has_exp_value : boolean;
        Priority : in std_logic_vector(0 to 1 );
        Lvl1_n : out std_logic;
        Lvl2_n : out std_logic;
        Lvl3_n : out std_logic
        );
end qual_priority;
 
 
-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture qual_priority of qual_priority is


-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin

-------------------------------------------------------------------------------
-- QUALPRI_PROCESS
-------------------------------------------------------------------------------
-- This process decodes the priority bits of the masters which are currently
-- requesting the bus
-------------------------------------------------------------------------------

QUALPRI_PROCESS:process(Request, Priority, RNW_has_exp_value)
  begin   
    
    -- set default values
    lvl1_n <= '1';
    lvl2_n <= '1';
    lvl3_n <= '1';
    
    if (request)='1' and RNW_has_exp_value then
      case Priority is
 
        when "00" =>
          null;
 
        when "01" =>
          lvl1_n <= '0';
 
        when "10" =>
          lvl2_n <= '0';
 
        when "11" =>
          lvl3_n <= '0';
 
--coverage off
        when others  =>
          lvl1_n <= 'X';
          lvl2_n <= 'X';
          lvl3_n <= 'X';
--coverage on 

      end case;
    end if;
  end process QUALPRI_PROCESS;
 
 
end ;

