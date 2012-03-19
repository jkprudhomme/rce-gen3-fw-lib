-------------------------------------------------------------------------------
--  $Id: or_bits.vhd,v 1.1.2.1 2010/07/13 16:33:55 srid Exp $
-------------------------------------------------------------------------------
-- or_bits.vhd - entity/architecture pair
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
--  Filename:        or_bits.vhd
--  Version:         v1.04a
--  Description:     This file is used to OR together consecutive bits within
--                   sections of a bus and a single bit input signal (Sig).
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:  (see plb_v46.vhd)
--
-------------------------------------------------------------------------------
--  Author:      JLJ
--  History:
--  JLJ         09/05/08        -- v1.04a
-- ~~~~~~
--  JLJ         09/05/08        -- v1.04a    
-- ^^^^^^
--  Added to plb_v46 core.
-- ~~~~~~
--  JLJ         09/10/08        -- v1.04a    
-- ^^^^^^
--  Update disclaimer of liability.
-- ~~~~~~
--
--
-- -----------------------------------------------------------------------------
--  Naming Conventions:
--       active low signals:                     "*_n"
--       clock signals:                          "clk", "clk_div#", "clk_#x"
--       reset signals:                          "rst", "rst_n"
--       generics:                               "C_*"
--       user defined types:                     "*_TYPE"
--       state machine next state:               "*_ns"
--       state machine current state:            "*_cs"
--       combinatorial signals:                  "*_cmb"
--       pipelined or register delay signals:    "*_d#"
--       counter signals:                        "*cnt*"
--       clock enable signals:                   "*_ce"
--       internal version of output port         "*_i"
--       device pins:                            "*_pin"
--       ports:                                  - Names begin with Uppercase
--       processes:                              "*_PROCESS"
--       component instantiations:               "<ENTITY_>I_<#|FUNC>
-- -----------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;

 
-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------

entity or_bits is
generic ( 
    C_NUM_BITS    : integer;
    C_START_BIT   : integer;
    C_BUS_SIZE    : integer
    );
    
port (
        
    In_Bus              : in std_logic_vector (0 to C_BUS_SIZE-1);
    Sig                 : in std_logic;
    Or_out              : out std_logic
    );
    
end or_bits;

 
-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture implementation of or_bits is

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin


OR_BITS_PROCESS: process (In_Bus, Sig)        
        
variable partial_or : std_logic_vector(0 to C_NUM_BITS-1);
        
begin
                  
    for k in 0 to C_NUM_BITS-1 loop
            
        if (k = 0) then
            partial_or(k) := In_Bus(C_START_BIT) or Sig;
        else
            partial_or(k) := In_Bus(C_START_BIT+k) or partial_or(k-1);
        end if;
            
    end loop;
            
    Or_out <= partial_or(C_NUM_BITS-1);
            
end process OR_BITS_PROCESS;


end implementation;

