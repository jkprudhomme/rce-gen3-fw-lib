-------------------------------------------------------------------------------
--  $Id: qual_request.vhd,v 1.1.2.1 2010/07/13 16:33:58 srid Exp $
-------------------------------------------------------------------------------
-- qual_request.vhd - entity/architecture pair
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
-- Filename:        qual_request.vhd
-- Version:         v1.04a
-- Description:     This file qualifies a master request with the arbiter 
--                  disable request register. It
--                  then decodes the priority bits of that master, generating
--                  signals indicating which priority level the master is
--                  requesting.
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
--  Remove Abort input signal and usage.
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
-- Port Declaration
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Generics:
--      No generics used
--
-- Definition of Ports:
--      input Request               -- master's request signal
--      input ArbDisReqReg          -- bit indicating if this master is disabled
--      input Priority              -- master's priority bits
--
--      output Lvl0                 -- indicates master had a level 1 request
--      output Lvl1                 -- indicates master had a level 2 request
--      output Lvl2                 -- indicates master had a level 3 request
--      output Lvl3                 -- indicates master had a level 4 request
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------
entity qual_request is
    port (
          Request       : in std_logic;
          ArbDisReqReg  : in std_logic;
          Priority      : in std_logic_vector(0 to 1 );
          Lvl0          : out std_logic;
          Lvl1          : out std_logic;
          Lvl2          : out std_logic;
          Lvl3          : out std_logic
          );
 
end qual_request;
 
 
-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture simulation of qual_request is
 
 
-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
-- QUAL_REQ_PROCESS
-------------------------------------------------------------------------------
-- This process qualifies the master's request with ArbDisReqReg
-- and then decodes the master's priority into the appropriate priority level
-- signal
-------------------------------------------------------------------------------
QUAL_REQ_PROCESS:process (Request, ArbDisReqReg, Priority) 
begin   

-- initialize all level signals to 0
Lvl0 <= '0';
Lvl1 <= '0';
Lvl2 <= '0';
Lvl3 <= '0';

if (Request and not (ArbDisReqReg)) = '1' then
    
    -- valid request signal, decode the priority bits
    
    case Priority is

        when "00" =>
                Lvl0 <= '1';

        when "01" =>
                Lvl1 <= '1';

        when "10" =>
                Lvl2 <= '1';

        when "11" =>
                Lvl3 <= '1';

--coverage off
        when others  =>
                Lvl0 <= 'X';
                Lvl1 <= 'X';
                Lvl2 <= 'X';
                Lvl3 <= 'X';
--coverage on
    end case;
end if;

end process;

end simulation;

