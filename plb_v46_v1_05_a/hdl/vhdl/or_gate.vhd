-------------------------------------------------------------------------------
-- $Id: or_gate.vhd,v 1.1.2.1 2010/07/13 16:33:55 srid Exp $
-------------------------------------------------------------------------------
-- or_gate.vhd - entity/architecture pair
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
-- Filename:        or_gate.vhd
-- Version:         v1.04a
-- Description:     OR gate implementation
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:  (see plb_v46.vhd)
--
-------------------------------------------------------------------------------
-- Author:          B.L. Tise
-- History:
--   BLT           2001-05-23    First Version
-- ^^^^^^
--      First version of OPB Bus.
-- ~~~~~~
--  JLJ         09/14/07    v1.01a  
-- ^^^^^^
--  Update to v1.01a.
-- ~~~~~~
--  JLJ         10/09/07    v1.02a  
-- ^^^^^^
--  Update to v1.02a.
-- ~~~~~~
--  JLJ         12/11/07    v1.02a  
-- ^^^^^^
--  Modified proc_common usage.
-- ~~~~~~
--  JLJ         03/17/08    v1.03a  
-- ^^^^^^
--  Upgraded to v1.03a. 
-- ~~~~~~
--  JLJ         05/14/08    v1.04a  
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library proc_common_v3_00_a;

-------------------------------------------------------------------------------
-- Definition of Generics:
--   C_OR_WIDTH           -- Which Xilinx FPGA family to target when
--                           syntesizing, affect the RLOC string values 
--   C_BUS_WIDTH          -- Which Y position the RLOC should start from
--
-- Definition of Ports:
--   A                    -- Input.  Input buses are concatenated together to
--                           form input A. Example: to OR buses R, S, and T,
--                           assign A <= R & S & T;
--   Y                    -- Output. Same width as input buses.
--
-------------------------------------------------------------------------------
entity or_gate is
  generic (
    C_OR_WIDTH   : natural range 1 to 32 := 17;
    C_BUS_WIDTH  : natural range 1 to 128 := 1;
    C_USE_LUT_OR : boolean := TRUE
    );
  port (
    A : in  std_logic_vector(0 to C_OR_WIDTH*C_BUS_WIDTH-1);
    Y : out std_logic_vector(0 to C_BUS_WIDTH-1)
    );
end entity or_gate;

    
architecture imp of or_gate is

-------------------------------------------------------------------------------
-- Component Declarations
-------------------------------------------------------------------------------


signal test : std_logic_vector(0 to C_BUS_WIDTH-1);
-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------

begin
  USE_LUT_OR_GEN: if C_USE_LUT_OR generate
    OR_PROCESS: process( A ) is
    variable yi : std_logic_vector(0 to (C_OR_WIDTH));
    begin
      for j in 0 to C_BUS_WIDTH-1 loop
        yi(0) := '0';
        for i in 0 to C_OR_WIDTH-1 loop
          yi(i+1) := yi(i) or A(i*C_BUS_WIDTH+j);
        end loop;
        Y(j) <= yi(C_OR_WIDTH);
      end loop;
    end process OR_PROCESS;
  end generate USE_LUT_OR_GEN;

  USE_MUXCY_OR_GEN: if not C_USE_LUT_OR generate
    BUS_WIDTH_FOR_GEN: for i in 0 to C_BUS_WIDTH-1 generate
      signal in_Bus : std_logic_vector(0 to C_OR_WIDTH-1);
    begin
      ORDER_INPUT_BUS_PROCESS: process( A ) is
      begin
        for k in 0 to C_OR_WIDTH-1 loop
          in_Bus(k) <=  A(k*C_BUS_WIDTH+i);
        end loop;
      end process ORDER_INPUT_BUS_PROCESS;
      OR_BITS_I: entity proc_common_v3_00_a.or_muxcy_f
        generic map (
          C_NUM_BITS      => C_OR_WIDTH
          -- With C_FAMILY defaulted to nofamily,
          -- implementation of the OR will be inferred.
          )  
        port map (
          In_bus          => in_Bus,    --[in]
          Or_out          => Y(i)       --[out]
          );
     end generate BUS_WIDTH_FOR_GEN;
   end generate USE_MUXCY_OR_GEN;

end architecture imp;
