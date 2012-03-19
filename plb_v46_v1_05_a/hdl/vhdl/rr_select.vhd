-------------------------------------------------------------------------------
--  $Id: rr_select.vhd,v 1.1.2.1 2010/07/13 16:33:58 srid Exp $
-------------------------------------------------------------------------------
-- rr_select.vhd - entity/architecture pair
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
-- Filename:        rr_select.vhd
-- Version:         v1.04a
-- Description:     This file contains the logic for round robin arbitration.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:  (see plb_v46.vhd)
--
-------------------------------------------------------------------------------
-- Author:      JLJ
-- History:
--  JLJ         09/14/07        
-- ~~~~~~
--  JLJ         10/02/07    v1.01a  
-- ^^^^^^
--  Change RR implementation.  Instead of rotating dedicated highest priority
--  master to lowest priority, the master that previously won arbitration is
--  now the lowest priority master.
-- ~~~~~~
--  JLJ         10/19/07    v1.02a  
-- ^^^^^^
--  Update to v1.02a (and merge with edits to v1.01a).
-- ~~~~~~
--  JLJ         10/29/07    v1.02a  
-- ^^^^^^
--  Change reset state of curr_mstr signal.
-- ~~~~~~
--  JLJ         10/31/07    v1.02a  
-- ^^^^^^
--  Modify if/else clauses (simplify) for next_rr_master logic.
--  Clean up unused ports.
-- ~~~~~~
--  JLJ         11/06/07    v1.02a  
-- ^^^^^^
--  Remove get_mstr_int_num function usage and replace with process stmt.
-- ~~~~~~
--  JLJ         12/18/07    v1.02a  
-- ^^^^^^
--  Code cleanup.
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
--  VSD         07/12/10    v1.05a  
-- ^^^^^^
--  addtion: "mstr_index <= 0;" - to remove latch in process, GET_ID_NUM
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
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;


-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_NUM_MASTERS       -- Number of masters on the PLB
--      C_FAMILY            -- Target FPGA family
--
-- Definition of Ports:
--      Clk                 -- PLB Clock
--      ArbReset            -- System Rst
--      M_request           -- Master request from all master devices
--      LoadAddrSelReg      -- Assign new PLB master
--      ArbDisMReqReg       -- Disable vector for all master devices
--      PrioencdrOutput     -- Next master to be granted the PLB
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------
entity rr_select is
generic (
    C_NUM_MASTERS       : integer   := 8;
    C_FAMILY            : string
);
port
(
    Clk                 : in  std_logic;
    ArbReset            : in  std_logic;
    M_request           : in  std_logic_vector(0 to C_NUM_MASTERS-1);
    LoadAddrSelReg      : in  std_logic;
    ArbDisMReqReg       : in  std_logic_vector(0 to C_NUM_MASTERS-1);
    PrioencdrOutput     : out std_logic_vector(0 to C_NUM_MASTERS-1)
    );
    
end rr_select;


-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture implementation of rr_select is

type RR_MASTER_TYPE is array (0 to C_NUM_MASTERS-1) of std_logic_vector (0 to C_NUM_MASTERS-1);

-------------------------------------------------------------------------------
-- Function Declarations
-------------------------------------------------------------------------------
function get_rr_array return RR_MASTER_TYPE is
variable rr_array_v : RR_MASTER_TYPE;
begin
    
    -- Loop for each vector in the array
    for i in 0 to C_NUM_MASTERS-1 loop   
    
        -- Loop for each bit in the vector
        for j in 0 to C_NUM_MASTERS-1 loop
        
            if (i = j) then rr_array_v(i)(j) := '1';
            else rr_array_v(i)(j) := '0';
            end if;
            
        end loop;
    end loop;
    return rr_array_v;
    
end function get_rr_array;        

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Signal and Type Declarations
-------------------------------------------------------------------------------
signal next_rr_mstr_qual_req : std_logic_vector (0 to C_NUM_MASTERS-1) := (others => '0');
signal next_rr_mstr_qual_reqn : std_logic_vector (0 to C_NUM_MASTERS-1) := (others => '0');
signal init_rr_master : RR_MASTER_TYPE := get_rr_array;
signal next_rr_master : RR_MASTER_TYPE;
signal carry_out : RR_MASTER_TYPE;
signal curr_mstr : std_logic_vector (0 to C_NUM_MASTERS-1);
signal mstr_index : integer range 0 to C_NUM_MASTERS-1 := 0;

type RR_REQ_TYPE is array (0 to C_NUM_MASTERS-1) of std_logic_vector (0 to 0);
signal mstr_request : RR_REQ_TYPE;
signal dis_request : RR_REQ_TYPE;
signal LoadAddrSelReg_d1 : std_logic;
signal new_mstr_index : std_logic_vector (0 to C_NUM_MASTERS-1) := (others => '0');

-------------------------------------------------------------------------------
-- Component Declarations
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin

-------------------------------------------------------------------------------
-- Component Instantiations
-------------------------------------------------------------------------------

-- Create process to generate next RR master
-- RR value gets updated on each arbitration cycle
GEN_RR_MSTR: for i in 0 to C_NUM_MASTERS-1 generate

    RR_PROCESS: process (Clk)
    begin
        if (Clk'event and Clk = '1') then
            if (ArbReset = RESET_ACTIVE) then
                next_rr_master(i) <= init_rr_master(i);
                
            -- Advance RR scheme
            elsif (LoadAddrSelReg_d1 = '1') then
                                
                -- If selected master is already at the bottom of
                -- queue, no change is necessary.
                if (new_mstr_index(C_NUM_MASTERS-1) = '1') then
                    next_rr_master(i) <= next_rr_master(i);                
                
                -- If selected master was at top of queue
                -- then shift each index up by one and assign
                -- bottom of queue with current selected master.
                elsif (new_mstr_index(0) = '1') then
                    
                    if (i = C_NUM_MASTERS-1) then
                        next_rr_master(i) <= curr_mstr;                        
                    else
                        next_rr_master(i) <= next_rr_master(i+1);
                    end if;
                    
                -- No need to check for else clause here, should fall into if
                -- mstr_index > 0 and < C_NUM_MASTERS-1.
                else
                    
                    if (i = C_NUM_MASTERS-1) then
                        next_rr_master(i) <= curr_mstr;
                    
                    -- Need to fill bottom of queue with top entries
                    -- in previous queue ordering
                    elsif (i > (C_NUM_MASTERS - 1 - (mstr_index + 1))) then
                        next_rr_master(i) <= next_rr_master(i - (C_NUM_MASTERS-1-mstr_index));
                    
                    -- Need to move up queue master numbers below currently selected
                    -- master number
                    else
                        next_rr_master(i) <= next_rr_master(mstr_index+i+1);
                    end if;
                end if;
                
            end if;
        end if;
    end process RR_PROCESS;
   
end generate GEN_RR_MSTR;

-- Determine if each master in current priority scheme has a
-- pending request
GEN_QUAL_REQ: for i in 0 to C_NUM_MASTERS-1 generate

     MSTR_REQ_MUX: entity proc_common_v3_00_a.mux_onehot_f
     generic map (   C_DW        => 1,
                     C_NB        => C_NUM_MASTERS,
                     C_FAMILY    => C_FAMILY)
     port map    (
                     D       => M_Request,
                     S       => next_rr_master(i),
                     Y       => mstr_request(i)(0 to 0));
 
 
     DIS_REQ_MUX: entity proc_common_v3_00_a.mux_onehot_f
     generic map (   C_DW        => 1,
                     C_NB        => C_NUM_MASTERS,
                     C_FAMILY    => C_FAMILY)
     port map    (
                     D       => ArbDisMReqReg,
                     S       => next_rr_master(i),
                     Y       => dis_request(i)(0 to 0));
 
     next_rr_mstr_qual_req(i) <= mstr_request(i)(0) and 
                                 not (dis_request(i)(0));

end generate GEN_QUAL_REQ;


-- Use carry chain MUXCY components to prioritize request signals
-- Sequence through the created RR vector that is already in order
-- Number of levels of select is based on number of masters in system
GEN_ARB_SELECT: for i in 0 to C_NUM_MASTERS-1 generate
        
    -- First level of muxing is unique
    -- Need to create both select data values
    -- This level is the lowest priority level
    I0: if (i = C_NUM_MASTERS-1) generate 
                        
        FIRSTMUX: process (next_rr_mstr_qual_req, next_rr_master(i))
        begin
            if (next_rr_mstr_qual_req(i) = '1') then
                carry_out(i) <= next_rr_master(i);           
            else
                carry_out(i) <= (others => '0');
            end if;
        end process FIRSTMUX;                
     
    end generate I0;
    
    -- Generate carry chain for other muxes in chain
    NI0: if (i < C_NUM_MASTERS-1) generate
           
       MUXS: process (next_rr_mstr_qual_req, next_rr_master(i), carry_out(i+1))
       begin
           if (next_rr_mstr_qual_req(i) = '1') then
               carry_out(i) <= next_rr_master(i);           
           else
               carry_out(i) <= carry_out(i+1);           
           end if;
       end process MUXS;
       
    end generate NI0;
        
end generate GEN_ARB_SELECT;
   
-- Winning master is carried through or blocked by higher level muxes of
-- requesting masters to top of chain.
PrioencdrOutput <= carry_out(0);

REG_MSTR_ID: process (Clk)
begin
    if (Clk'event and Clk = '1') then
        if (ArbReset = RESET_ACTIVE) then
            -- Create different init value for curr_mstr 
            -- Needs to be assigned M0 one-hot value
            -- Fix from init state of all 0's
            curr_mstr <= next_rr_master(0);            
        elsif (LoadAddrSelReg = '1') then
            curr_mstr <= carry_out(0);
        else
            curr_mstr <= curr_mstr;
        end if;
    end if;
end process REG_MSTR_ID;

-- Convert one-hot vector into integer to 
-- be used when re-assigning RR array
GET_ID_NUM: process (new_mstr_index)
begin
    mstr_index <= 0;
    for i in 0 to C_NUM_MASTERS-1 loop           
        if (new_mstr_index(i) = '1') then
            mstr_index <= i;
        end if;          
    end loop;  
end process GET_ID_NUM;

-- Create one-hot bit vector which indicates index in
-- RR array of current master
GEN_MSTR_INDEX: for i in 0 to C_NUM_MASTERS-1 generate

    REG_MSTR_INDEX: process (Clk)
    begin
        if (Clk'event and Clk = '1') then
            if (ArbReset = RESET_ACTIVE) then
                new_mstr_index(i) <= '0';
            elsif (LoadAddrSelReg = '1') then
                
                if (carry_out(0) = next_rr_master(i)) then
                    new_mstr_index(i) <= '1';
                else
                    new_mstr_index(i) <= '0';
                end if;
            else
                new_mstr_index(i) <= new_mstr_index(i);
            end if;
        end if;
    end process REG_MSTR_INDEX;

end generate GEN_MSTR_INDEX;

-- Use registered delayed LoadAddrSelReg to advance RR queue
REG_ARBSEL: process (Clk)
begin
    if (Clk'event and Clk = '1') then
        if (ArbReset = RESET_ACTIVE) then
            LoadAddrSelReg_d1 <= '0';
        else
            LoadAddrSelReg_d1 <= LoadAddrSelReg;
        end if;
    end if;
end process REG_ARBSEL;

     
end implementation;
