-------------------------------------------------------------------------------
--  $Id: arb_control_sm.vhd,v 1.1.2.1 2010/07/13 16:33:54 srid Exp $
-------------------------------------------------------------------------------
-- arb_control_sm.vhd - entity/architecture pair
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
-- Filename:        arb_control_sm.vhd
-- Version:         v1.04a
-- Description:     This file contains the arbiter control state machine which
--                  controls the PLB bus. It asserts PAValid and SAValid at
--                  the appropriate times and generates the bus state signals
--                  for arb_registers.
-- 
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:  (see plb_v46.vhd)
--
-------------------------------------------------------------------------------
-- Author:      BLT
-- History:
--      ALS     02/20/02        -- created from plb_arbiter_v1_01_a
--      ALS     04/16/02        -- Version v1.01a
-- ^^^^^^
--  MLL         02/20/04        -- Version v1.01a
-- ^^^^^^
--  Fix to make compatible with OPB IPIF architecture. In arb_control_sm.vhd,
--  added counter to block clearing of mask in arbitration if plb2opb bridge
--  asserts rearbitrate on a read operation. This required adding
--  C_NUM_OPBCLK_PLB2OPB_REARB generic and PLB2OPB_rearb vector signal at this
--  level and passed down to arb_control_sm.vhd. Also rev'd to v2.00a.
-- ~~~~~~
--  FLO         06/08/05        
-- ^^^^^^
-- Start of changes for plb_v46.
-- -Switched to v2_00_a for proc_common.
-- -Eliminated aspects related to the watchdog timer completing hanshakes on
--  timeout.
-- -Changed structure section to a reference to plb_v46.vhd.
-- ~~~~~~
--  FLO         06/16/05        
-- ^^^^^^
-- -Changed generic name: C_NUM_OPBCLK_PLB2OPB_REARB -> C_NUM_CLK_PLB2OPB_REARB
-- ~~~~~~
--  FLO         07/19/05        
-- ^^^^^^
-- -Changed to active low WdtMTimeout_n
-- ~~~~~~
--  FLO         09/01/05        
-- ^^^^^^
-- -To consolidate state information for optimization evaluations,
--  arb_registers and bus_lock_sm incorporated locally in arb_control_sm.
-- ~~~~~
--  FLO         09/03/05        
-- ^^^^^^
-- -Optimization work on fsm to reduce latency by on clock for 1-master case.
--  Probably not in final form, yet.
-- ~~~~~
--  FLO         09/09/05        
-- ^^^^^^
-- -Request-to-PAValid 1-cycle (when 1 master) and 2-cycle latencies supported.
-- -Fixed timeout handling.
-- ~~~~~
--  FLO         06/10/06        
-- ^^^^^^
-- -Removed no-longer-needed simulation monitor.
-- ~~~~~
--  JLJ         05/04/07    v1.00a   
-- ^^^^^^
--  Created signal to detect re-arbitrated operation and allow subsequent write
--  operation mux select signal to get asserted.  CR # 436559.
-- ~~~~~
--  JLJ         05/10/07    v1.00a   
-- ^^^^^^
--  Update LoadPriWr signal assertion to update wrBurst mux select when the
--  the previous write transaction completes.  Added logic in the following states:
--      => on transition from "01" IDLE to "08" MASTERSEL, or
--      => on transition from "08" MASTERSEL to "10" RD_STATE, or
--      => in "10" RD_STATE
-- ~~~~~
--  JLJ         05/22/07    v1.00a   
-- ^^^^^^
--  Removed reset on WrBurst_Mux_Idle in IDLE state.
-- ~~~~~
--  JLJ         05/23/07    v1.00a   
-- ^^^^^^
--  Found corner cases when WrBurst_Mux_Idle needed to be asserted in SM.
-- ~~~~~
--  JLJ         06/13/07    v1.00a   
-- ^^^^^^
--  Found corner cases when WrBurst_Mux_Idle should not be asserted due to 
--  a pending secondary write pending request.  
-- ~~~~~
--  JLJ         07/16/07    v1.00a   
-- ^^^^^^
--  CR 442962. Change default setting of C_ADDR_PIPELINING_TYPE to be 1.  
-- ~~~~~
--  JLJ         09/14/07    v1.01a  
-- ^^^^^^
--  Update to v1.01a.
-- ~~~~~~
--  JLJ         10/03/07    v1.01a  
-- ^^^^^^
--  Add check in BUSLOCK_STATE if plb_buslock is negated.  If so, release disables.
-- ~~~~~~
--  JLJ         10/14/07    v1.01a  
-- ^^^^^^
--  Change SM so that M_Request disable logic is only utilized in fixed priority 
--  arbitration (ie. C_ARB_TYPE =0).
--  Added C_ARB_TYPE to top level port parameters.
-- ~~~~~~
--  JLJ         10/19/07    v1.02a  
-- ^^^^^^
--  Update to v1.02a (and merge with edits to v1.01a).
-- ~~~~~~
--  JLJ         10/25/07    v1.02a  
-- ^^^^^^
--  Add check in IDLE state when C_ADDR_PIPELINE_TYPE = 1 that address arbitration
--  cycle indicator does not get asserted if both read/write buses are busy.
-- ~~~~~~
--  JLJ         10/31/07    v1.02a  
-- ^^^^^^
--  Clean up unused ports.
--  Remove use of PLB_abort input signal (and remove from top level).
-- ~~~~~~
--  JLJ         11/30/07    v1.02a  
-- ^^^^^^
--  Code coverage clean up.
-- ~~~~~~
--  JLJ         12/11/07    v1.02a  
-- ^^^^^^
--  Added coverage off/on statements.
--  Modified proc_common include statement.
--  Code cleanup.  Remove OPB rearb counter logic.
-- ~~~~~~
--  JLJ         03/14/08    v1.03a  
-- ^^^^^^
--  Upgraded to v1.03a. 
--  Fixed condition in IDLE state when previously requested master
--  keeps RNW signal asserted, which determines when the next
--  arbitration cycle can be.  Added new logic in SM to advance
--  RR ordering scheme and check new RNW to ensure we don't go beyond
--  two pipeline stages.
-- ~~~~~~
--  JLJ         05/14/08    v1.04a  
-- ^^^^^^
--  Updated to v1.04a (to migrate using proc_common_v3_00_a) in EDK L.
-- ~~~~~~
--  JLJ         09/12/08    v1.04a  
-- ^^^^^^
--  Update disclaimer of liability.
-- ~~~~~~
--
---------------------------------------------------------------------------------
-- 
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
 
library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.RESET_ACTIVE;

-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_NUM_MASTERS               -- number of masters
--
-- Definition of Ports:
--      input  Sl_addrAck           -- slave address ack
--      input  ArbAddrSelReg        -- master controlling bus
--      output ArbRdDBusBusyReg     -- read data bus busy
--      output ArbWrDBusBusyReg     -- write data bus busy
--      output ArbSecRdInProgReg    -- secondary read in progress
--      output ArbSecWrInProgReg    -- secondary write in progress
--      output SM_busLock           -- PLB buslock condition
--      output PLB_busLock          -- PLB buslock signal
--      input  Clk                  -- clock
--      input  QualReq              -- =1 if any master has a qualified request
--      input  PLB_RNW              -- PLB_RNW
--      input  Sl_rearbitrate       -- slave re-arbitrate 
--      input  ArbReset             -- reset
--      input  Reset                -- reset
--      input  Sl_rdComp            -- slave read complete
--      input  Sl_wrComp            -- slave write complete
--      input  WdtMTimeout_n        -- watchdog timer timeout
--
--      output LoadAddrSelReg       -- load priority encoder output into register
--      output PAValid              -- primary address valid
--      output SAValid              -- secondary address valid
--      input  PLB_reqPri           -- current priority of active transaction
--      input  ArbBurstReq          -- current transaction burst status
--      output ArbDisMReqReg        -- disabled masters
--      output ArbPriRdBurstReg     -- primary read transaction burst status
--      output ArbPriRdMasterReg    -- primary read transaction master
--      output ArbPriRdMasterRegReg -- primary read transaction master, delayed
--      output ArbPriWrMasterReg    -- primary write transaction master
--      output ArbSecRdInProgPriorReg -- priority of secondary read transaction
--      output ArbSecRdMasterReg    -- secondary read transaction master
--      output ArbSecWrInProgPriorReg -- priority of secondary write transaction
--      output ArbSecWrMasterReg    -- secondary write transaction master
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------
entity arb_control_sm is
  generic (C_NUM_MASTERS            : integer   := 8;
           C_OPTIMIZE_1M            : boolean;
           C_ADDR_PIPELINING_TYPE   : integer := 1; -- 0:none, 1:2-level
           C_ARB_TYPE               : integer );
  port (
        Sl_addrAck          : in std_logic;
        ArbAddrSelReg       : in std_logic_vector(0 to C_NUM_MASTERS-1 );
        ArbRdDBusBusyReg    : out std_logic;
        ArbWrDBusBusyReg    : out std_logic;
        ArbSecRdInProgReg   : out std_logic;
        ArbSecWrInProgReg   : out std_logic;
        SM_busLock          : out std_logic;
        PLB_busLock         : out std_logic;
        Mstr_buslock        : in  std_logic;
        Mstr_Request        : in  std_logic;
        Clk                 : in std_logic;
        QualReq             : in std_logic;
        PLB_RNW             : in std_logic;
        Sl_rearbitrate      : in std_logic;
        ArbReset            : in std_logic;
        Sl_rdComp           : in std_logic;
        Sl_wrComp           : in std_logic;
        WdtMTimeout_n       : in std_logic;
        LoadAddrSelReg      : out std_logic;
        PAValid             : out std_logic;
        SAValid             : out std_logic;
        PLB_reqPri          : in std_logic_vector(0 to 1);
        ArbBurstReq         : in std_logic;
        ArbDisMReqReg       : out std_logic_vector(0 to C_NUM_MASTERS-1 );
        ArbPriRdBurstReg        : out std_logic;
        ArbPriRdMasterReg       : out std_logic_vector(0 to C_NUM_MASTERS-1 );
        ArbPriRdMasterRegReg    : out std_logic_vector(0 to C_NUM_MASTERS-1 );
        ArbPriWrMasterReg       : out std_logic_vector(0 to C_NUM_MASTERS-1 );
        ArbSecRdInProgPriorReg  : out std_logic_vector(0 to 1);
        ArbSecRdMasterReg       : out std_logic_vector(0 to C_NUM_MASTERS-1 );
        ArbSecWrInProgPriorReg  : out std_logic_vector(0 to 1);
        ArbSecWrMasterReg       : out std_logic_vector(0 to C_NUM_MASTERS-1 )
        );
end arb_control_sm;
 
 
-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture simulation of arb_control_sm is

constant DISABLE_ADDR_PIPELINING : boolean := C_ADDR_PIPELINING_TYPE = 0;
-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------
-- state machine signals
type ARB_SM_TYPE is (IDLE, MASTERSEL, BUSLOCK, LOST_BUSLOCK,  
                     REL_DISABLES, SET_DISABLES, RD_STATE, WR_STATE, REARB);
signal arbctrl_sm_cs, arbctrl_sm_ns : ARB_SM_TYPE;

-- combinational versions of PAValid and SAValid 
signal pavalid_cmb : std_logic;
signal savalid_cmb : std_logic;
signal pavalid_i    : std_logic;
signal savalid_reg  : std_logic;

signal sm_buslock_i : std_logic;
signal plb_buslock_i : std_logic;
signal Set_disables_state  : std_logic;

signal arbRdDBusBusyReg_i : std_logic;
signal arbSecRdInProgReg_i : std_logic;
signal arbSecWrInProgReg_i : std_logic;
signal arbWrDBusBusyReg_i : std_logic;

signal LoadDisReg          : std_logic;
signal LoadPriRd           : std_logic;
signal LoadPriWr           : std_logic;
signal LoadSecRd           : std_logic;
signal LoadSecRdPriReg     : std_logic;
signal LoadSecWr           : std_logic;
signal LoadSecWrPriReg     : std_logic;
signal RecomputeRdBits     : std_logic;
signal RecomputeWrBits     : std_logic;
signal arbDisMReqReg_cmb   : std_logic_vector(0 to C_NUM_MASTERS-1 );
signal PrevTrnsReArb       : std_logic;
signal PrevTrnsReArb_set   : std_logic;
signal PrevTrnsReArb_rst   : std_logic;

signal WrBurst_Mux_Idle_cmb  : std_logic;
signal WrBurst_Mux_Idle_reg  : std_logic;

signal in_buslock : std_logic;
signal exec_trns, exec_trns_cmb : std_logic;
signal hold_rr, hold_rr_cmb   : std_logic;

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin
ArbRdDBusBusyReg   <= arbRdDBusBusyReg_i;
ArbSecRdInProgReg  <= arbSecRdInProgReg_i;
ArbSecWrInProgReg  <= arbSecWrInProgReg_i;
ArbWrDBusBusyReg   <= arbWrDBusBusyReg_i;

-------------------------------------------------------------------------------
-- Output state condition
-------------------------------------------------------------------------------
Set_disables_state  <= '1' when arbctrl_sm_cs = SET_DISABLES
                        else '0';
                        
in_buslock <= '1' when arbctrl_sm_cs = BUSLOCK
                        else '0';                       
                        
-------------------------------------------------------------------------------
-- Arbiter Control State Machine
--
-- ARBCTRL_SM_CMB_PROCESS:      combinational next-state logic
-- ARBCTRL_SM_REGS_PROCESS:     registered process of the state machine
-------------------------------------------------------------------------------
-- These processes control the bus transactions and state of the PLB

ARBCTRL_SM_CMB_PROCESS: process (QualReq, sm_buslock_i, 
                                plb_buslock_i,  
                                arbRdDBusBusyReg_i, arbSecRdInProgReg_i, 
                                arbWrDBusBusyReg_i, arbSecWrInProgReg_i, 
                                arbAddrSelReg, PLB_RNW, 
                                Sl_rdComp, Sl_addrAck, WdtMTimeout_n, 
                                Sl_rearbitrate, Sl_wrComp,
                                arbctrl_sm_cs,
                                PrevTrnsReArb,
                                WrBurst_Mux_Idle_reg,
                                savalid_reg,
                                Mstr_buslock, Mstr_Request,
                                exec_trns, hold_rr
                                )
                                
begin

-- assign default values for state machine outputs
arbDisMReqReg_cmb <= (others => '0');
LoadDisReg <= '0';    
LoadPriRd <= '0';
LoadPriWr <= '0';    
LoadSecRd <= '0';    
LoadSecRdPriReg <= '0';    
LoadSecWr <= '0';    
LoadSecWrPriReg <= '0';    
loadAddrSelReg <= '0';    
pavalid_cmb <= '0';    
RecomputeRdBits <= '0';    
RecomputeWrBits <= '0';    
savalid_cmb <= '0';    
PrevTrnsReArb_set <= '0';
PrevTrnsReArb_rst <= '0';
WrBurst_Mux_Idle_cmb <= WrBurst_Mux_Idle_reg;
exec_trns_cmb <= exec_trns;
hold_rr_cmb <= hold_rr;
arbctrl_sm_ns <= arbctrl_sm_cs;

case arbctrl_sm_cs is

        ----------------------------- IDLE State --------------------------------
        when IDLE =>
          
            -- Multiple masters, both states IDLE and MASTERSEL
            if not (C_NUM_MASTERS = 1 and C_OPTIMIZE_1M) then                   

                -- If previous write transaction completes
                -- Update wrBurst mux select signal by asserting LoadPriWr
                -- Assert flag to indicate WrBurst Mux is IDLE and allow the WrBurst
                -- Mux to follow the Addr Mux
                if (arbWrDBusBusyReg_i and (Sl_wrComp)) = '1' then
                    LoadPriWr <= '1';

                    -- Can only assert wrBurst mux IDLE if not secondary write burst is pending
                    if (arbSecWrInProgReg_i = '0') then
                        WrBurst_Mux_Idle_cmb <= '1';
                    end if;

                end if;

                if (QualReq = '0') then
                    arbctrl_sm_ns <= IDLE;

                    -- Insure that masters are disabled only one clock after buslock negates
                    -- by resetting the disable request register
                    if (plb_buslock_i = '0') then
                        if (C_ARB_TYPE = 0) then
                            arbDisMReqReg_cmb <= (others => '0');
                            LoadDisReg <= '1';
                        else
                            hold_rr_cmb <= '0';
                        end if;
                    end if;

--                elsif (QualReq = '1' and Sl_addrAck = '0' and Sl_rearbitrate = '0') then
                elsif (QualReq = '1') then
                    -- At least one master is requesting
                    -- load priority encoder output and transition to master select state
                    arbctrl_sm_ns <= MASTERSEL;
                                        
                    -- Indicate address arbitration cycle
                    if (C_ARB_TYPE = 0) then
                        loadAddrSelReg <= '1';
                    else
                        -- If address pipelining is enabled
                        -- And if doing a read, but both buses are busy (and no rdComp)
                        -- then do not assert loadAddrSelReg.
                        if C_ADDR_PIPELINING_TYPE = 1 then
                        
                            --  if ((arbRdDBusBusyReg_i and arbSecRdInProgReg_i and not(Sl_rdComp)) or
                            --      (arbWrDBusBusyReg_i and arbSecWrInProgReg_i and not(Sl_wrComp))) = '1' then                                
                            --      if exec_trns = '1' then
                            --          loadAddrSelReg <= '1';
                            --          exec_trns_cmb <= '0'; 
                            --      end if;
                        
                            -- Remove 3/14/08
                            if ((PLB_RNW and arbRdDBusBusyReg_i and arbSecRdInProgReg_i and not(Sl_rdComp))  or
                                (not(PLB_RNW) and arbWrDBusBusyReg_i and arbSecWrInProgReg_i and not(Sl_wrComp))) = '1' then
                                loadAddrSelReg <= '0';
                                
                            -- Insert check here for 3rd pipeline stage.
                            -- Advance RR ordering scheme
                            -- Hold off assertion of subsequent SAValid depending on R/W of next master
                                                      
                            elsif exec_trns = '1' then
                                if (hold_rr = '0') or (Mstr_buslock = '0') then
                                    loadAddrSelReg <= '1';
                                    exec_trns_cmb <= '0';       -- Clear flag that transaction has been processed.
                                end if;
                            end if;
                        
                        -- If no address pipelining, check BusLock condition    
                        elsif C_ADDR_PIPELINING_TYPE = 0 then                        
                            if (hold_rr = '0') or (Mstr_buslock = '0') then
                                loadAddrSelReg <= '1';
                                exec_trns_cmb <= '0';       -- Clear flag that transaction has been processed.
                            end if;
                        end if;
                    end if;
                                        
                    if (sm_buslock_i = '0') then
                        if (C_ARB_TYPE = 0) then            
                            -- bus is not locked, reset master disable register
                            arbDisMReqReg_cmb <= (others => '0');
                            LoadDisReg <= '1';     
                        else
                            hold_rr_cmb <= '0';
                        end if;
                    end if;
                    --arbctrl_sm_ns <= MASTERSEL;
                else
                    arbctrl_sm_ns <= IDLE;
                end if;

           end if;  -- not C_OPTIMIZE_1M
      
           -- Single master, combine IDLE and MASTERSEL into the IDLE state
           -- and leave MASTERSEL unreachable so that it can be optimized away.
           -- There is no need to drive loadAddrSelReg when there is one master.
           if (C_NUM_MASTERS = 1 and C_OPTIMIZE_1M) then
               
               if (QualReq = '0') then
                   arbctrl_sm_ns <= IDLE;

                   -- Insure that masters are disabled only one clock after buslock negates
                   -- by resetting the disable request register
                   if (plb_buslock_i='0') then
                        if (C_ARB_TYPE = 0) then
                            arbDisMReqReg_cmb <= (others => '0');
                            LoadDisReg <= '1';
                        end if;
                   end if;

                elsif (QualReq = '1') then
                
                    -- At least one master is requesting 
                    if (sm_buslock_i = '0' and C_ARB_TYPE = 0) then            
                        -- Bus is not locked, reset master disable register
                        arbDisMReqReg_cmb <= (others => '0');
                        LoadDisReg <= '1';
                    end if;

                    -- Primary write transaction
                    if (not(PLB_RNW) and not(arbWrDBusBusyReg_i) and not(arbSecWrInProgReg_i)) = '1' then
                        LoadPriWr <= '1'; 
                    end if;

                    -- Secondary write transaction
                    if (not(PLB_RNW) and arbWrDBusBusyReg_i and not(arbSecWrInProgReg_i)) = '1' then
                        LoadSecWr <= '1';
                        LoadSecWrPriReg <= '1';
                    end if;

                    -- Both buses are busy, go back to IDLE
                    if ((PLB_RNW and arbRdDBusBusyReg_i and arbSecRdInProgReg_i) or 
                        (not(PLB_RNW) and arbWrDBusBusyReg_i and arbSecWrInProgReg_i)) ='1' then
                        arbctrl_sm_ns <= IDLE;

                    -- 11/30/07 code coverage clean up
                    -- Will never hit this condition due to 1M configuration
                    -- BusLock will not get asserted
                    --elsif (sm_buslock_i='1') then        
                    --    arbctrl_sm_ns <= BUSLOCK;

                    -- Read transaction and either a primary or secondary slot is free
                    elsif (PLB_RNW and not (arbRdDBusBusyReg_i and arbSecRdInProgReg_i)) = '1' then
                        arbctrl_sm_ns <= RD_STATE;

                        -- Primary transaction, assert PAValid
                        if (not(arbRdDBusBusyReg_i) or (arbRdDBusBusyReg_i and (Sl_rdComp))) = '1' then
                            pavalid_cmb <= '1';
                        end if;

                        -- Secondary transaction, assert SAValid
                        if not DISABLE_ADDR_PIPELINING and
                           (arbRdDBusBusyReg_i and not(arbSecRdInProgReg_i) and not(Sl_rdComp)) = '1' then
                            savalid_cmb <= '1';
                        end if;

                        -- If transaction completes in one clock, load register
                        if (arbRdDBusBusyReg_i and (Sl_rdComp)) = '1' then
                            LoadPriRd <= '1';
                        end if;

                    -- Write transaction and either a primary or secondary slot is free
                    elsif (not(PLB_RNW) and not(arbWrDBusBusyReg_i and arbSecWrInProgReg_i)) = '1' then
                        arbctrl_sm_ns <= WR_STATE;

                        -- Primary transaction that has not yet completed, assert PAValid
                        if (not(arbWrDBusBusyReg_i) or (arbWrDBusBusyReg_i 
                            and (Sl_wrComp))) = '1' then
                            pavalid_cmb <= '1';
                        end if;

                        -- Secondary transaction, assert SAValid
                        if not DISABLE_ADDR_PIPELINING and
                           (arbWrDBusBusyReg_i and not(arbSecWrInProgReg_i) and
                            not(Sl_wrComp)) = '1' then
                            savalid_cmb <= '1';
                        end if;

                        -- If transaction completes in one clock, load register
                        if (arbWrDBusBusyReg_i and (Sl_wrComp)) = '1' then                            
                            LoadPriWr <= '1';
                        end if;

                    end if;

                else
                    arbctrl_sm_ns <= IDLE;
                end if;
            end if; -- C_OPTIMIZE_1M
            

        ----------------------------- MASTERSEL State --------------------------
        when MASTERSEL =>
  
            PrevTrnsReArb_rst <= '1';
  
            if (sm_buslock_i = '0') then
                if (C_ARB_TYPE = 0) then            
                    -- Bus is not locked, reset master disable register
                    arbDisMReqReg_cmb <= (others => '0');
                    LoadDisReg <= '1';     
                else
                    hold_rr_cmb <= '0';
                end if;
            end if;

            -- If previous operation was ReArbitrated or WrBurst Mux is IDLE
            -- Need to reload wrburst mux
            if (WrBurst_Mux_Idle_reg = '1') or (PrevTrnsReArb = '1') then
                LoadPriWr <= '1'; 
            end if;        

            if ((not(PLB_RNW) and not(arbWrDBusBusyReg_i) and not(arbSecWrInProgReg_i)) = '1') then           
                LoadPriWr <= '1';                   -- primary write transaction
                WrBurst_Mux_Idle_cmb <= '0';        -- only reset flag once start of new write operation
            end if;

            -- Secondary write transaction
            if (not(PLB_RNW) and arbWrDBusBusyReg_i and not(arbSecWrInProgReg_i)) = '1' then
                LoadSecWr <= '1';
                LoadSecWrPriReg <= '1';
            end if;

            -- If both buses are busy, go back to IDLE
            if ((PLB_RNW and arbRdDBusBusyReg_i and arbSecRdInProgReg_i)
               or (not(PLB_RNW) and arbWrDBusBusyReg_i and arbSecWrInProgReg_i)) = '1' then
                arbctrl_sm_ns <= IDLE;

            -- If detect buslock scenario
            elsif (sm_buslock_i = '1') then 
            
                arbctrl_sm_ns <= BUSLOCK;   
                
                -- Added for RR, since transaction is processed after waiting for buses
                -- to be free when BusLock is detected.
                -- If previous transaction completes, load register
                if (arbWrDBusBusyReg_i and (Sl_wrComp)) = '1' then
                    LoadPriWr <= '1';                
                    WrBurst_Mux_Idle_cmb <= '0';    -- If going to service a write request
                                                    -- wrBurst mux is not idle
                end if;

            -- Read transaction and either a primary or secondary slot is free
            elsif (PLB_RNW and not (arbRdDBusBusyReg_i and arbSecRdInProgReg_i)) = '1' then
                
                arbctrl_sm_ns <= RD_STATE;

                -- Primary transaction, assert PAValid
                if (not(arbRdDBusBusyReg_i) or (arbRdDBusBusyReg_i and (Sl_rdComp))) = '1' then                   
                    pavalid_cmb <= '1';
                end if;

                -- Secondary transaction, assert SAValid
                if not DISABLE_ADDR_PIPELINING and
                   (arbRdDBusBusyReg_i and not(arbSecRdInProgReg_i) and not(Sl_rdComp)) = '1' then                    
                    savalid_cmb <= '1';
                end if;

                -- If transaction completes in one clock, load register
                if (arbRdDBusBusyReg_i and (Sl_rdComp)) = '1' then                    
                    LoadPriRd <= '1';
                end if;

                -- If previous write transaction completes
                -- Update wrBurst mux select signal by asserting LoadPriWr
                if (arbWrDBusBusyReg_i and (Sl_wrComp)) = '1' then
                    LoadPriWr <= '1';

                    -- Can only assert wrBurst mux IDLE if not secondary write burst is pending
                    if (arbSecWrInProgReg_i = '0') then
                        WrBurst_Mux_Idle_cmb <= '1';
                    end if;
                end if;

            elsif (not(PLB_RNW) and not(arbWrDBusBusyReg_i and arbSecWrInProgReg_i)) = '1' then
                
                -- Write transaction and either a primary or secondary slot is free
                arbctrl_sm_ns <= WR_STATE;

                -- Primary transaction that has not yet completed, assert PAValid
                if (not(arbWrDBusBusyReg_i) or (arbWrDBusBusyReg_i and (Sl_wrComp))) = '1' then                    
                    pavalid_cmb <= '1';
                end if;

                -- Secondary transaction, assert SAValid
                if not DISABLE_ADDR_PIPELINING and
                   (arbWrDBusBusyReg_i and not(arbSecWrInProgReg_i) and not(Sl_wrComp)) = '1' then
                    savalid_cmb <= '1';
                end if;

                -- If previous write transaction completes
                -- Update wrBurst mux select signal by asserting LoadPriWr
                if (arbWrDBusBusyReg_i and (Sl_wrComp)) = '1' then
                    LoadPriWr <= '1';                
                    WrBurst_Mux_Idle_cmb <= '0';                                                        
                end if;
            end if;

        ----------------------------- BUSLOCK -----------------------------
        when BUSLOCK =>

            -- If previous write transaction completes
            -- Update wrBurst mux select signal by asserting LoadPriWr
            if (arbWrDBusBusyReg_i and (Sl_wrComp)) = '1' then
                LoadPriWr <= '1';
            end if;

            -- Design different logic for handling BusLock scenario in RR arbitration
            -- In RR arbitration, the RR queue is only advanced once
            if (C_ARB_TYPE = 1) then

                -- Check if buslock is deasserted
                if (sm_buslock_i = '0') then
                    
                    if (exec_trns = '1') then
                        arbctrl_sm_ns <= REL_DISABLES; 
                    else
                        arbctrl_sm_ns <= SET_DISABLES;
                    end if;

                end if;

                if (not(arbRdDBusBusyReg_i) and not(arbSecRdInProgReg_i) and
                    not(arbWrDBusBusyReg_i) and not(arbSecWrInProgReg_i)) = '1' then              
                    arbctrl_sm_ns <= SET_DISABLES;
                end if;

            -- Fixed priority arbitration
            -- In BusLock situation, the requests from other masters are disabled
            else
                if (not(arbRdDBusBusyReg_i) and not(arbSecRdInProgReg_i) and
                       not(arbWrDBusBusyReg_i) and not(arbSecWrInProgReg_i)) = '1' then                   

                    -- Check if buslock is deasserted, go back to IDLE
                    if (sm_buslock_i = '0') then
                        arbctrl_sm_ns <= REL_DISABLES; 
                    else
                         -- both buses are idle, disable other masters
                        arbctrl_sm_ns <= SET_DISABLES;
                    end if;
                end if;              
            end if;        

        ------------------------------- REL_DISABLES ----------------------------
        when REL_DISABLES =>
            
            if (C_ARB_TYPE = 0) then
                arbDisMReqReg_cmb <= (others => '0');
                LoadDisReg <= '1';
            else
                hold_rr_cmb <= '0';
            end if;
            arbctrl_sm_ns <= IDLE;

        ------------------------------- SET_DISABLES ----------------------------
        when SET_DISABLES =>
            
            -- Only set disables if reached here when buslock is asserted
            if (sm_buslock_i = '1') then
                if (C_ARB_TYPE = 1) then
                    hold_rr_cmb <= '1';
                else
                    arbDisMReqReg_cmb <= not(arbAddrSelReg);
                    LoadDisReg <= '1';
                end if;
            end if;

            -- If arbitrated master has already been executed on the bus
            -- and buslock negates, go back to re-arbitrate.
            if (sm_buslock_i = '0' and exec_trns = '1') then
                arbctrl_sm_ns <= REL_DISABLES; 
            end if;

            -- If previous write transaction completes
            -- Update wrBurst mux select signal by asserting LoadPriWr
            if (arbWrDBusBusyReg_i and (Sl_wrComp)) = '1' then
                LoadPriWr <= '1';                
                WrBurst_Mux_Idle_cmb <= '0';                                                        
            end if;

            if (Mstr_Request = '1') then

                -- If going to execute write, wait for either primary or secondary write
                -- bus to be idle
                if (not(PLB_RNW) and not(arbWrDBusBusyReg_i and arbSecWrInProgReg_i)) = '1' then                

                    if (not(arbWrDBusBusyReg_i) or (arbWrDBusBusyReg_i and
                         (Sl_wrComp))) = '1' then
                        pavalid_cmb <= '1'; 
                    end if;

                    if not DISABLE_ADDR_PIPELINING and
                        (arbWrDBusBusyReg_i and not(arbSecWrInProgReg_i) and
                            not(Sl_wrComp)) = '1' then
                        savalid_cmb <= '1';
                    end if;

                    arbctrl_sm_ns <= WR_STATE;

                -- Read transaction, wait for either a primary or secondary slot is free
                elsif (PLB_RNW and not (arbRdDBusBusyReg_i and arbSecRdInProgReg_i)) = '1' then
                
                     if (not(arbRdDBusBusyReg_i) or 
                        (arbRdDBusBusyReg_i and (Sl_rdComp))) = '1' then
                        pavalid_cmb <= '1';
                     end if;

                     if not DISABLE_ADDR_PIPELINING and
                        (arbRdDBusBusyReg_i and not(arbSecRdInProgReg_i) and
                        not(Sl_rdComp)) = '1' then
                        savalid_cmb <= '1';
                     end if;

                     if (arbRdDBusBusyReg_i and (Sl_rdComp)) = '1' then
                        LoadPriRd <= '1';
                     end if;
                     arbctrl_sm_ns <= RD_STATE;

                end if;
            end if;

        ------------------------------ RD_STATE --------------------------------
        when RD_STATE =>
            
            -- Assert flag that transaction has been processed
            exec_trns_cmb <= '1';

            -- If previous write transaction completes
            -- Update wrBurst mux select signal by asserting LoadPriWr
            if (arbWrDBusBusyReg_i and (Sl_wrComp)) = '1' then
                LoadPriWr <= '1';

                -- If previous write finishes here, assert this flag that the WrBurst
                -- Mux is IDLE and allow the WrBurst mux to follow the Addr Mux            
                -- Can only assert wrBurst mux IDLE if not secondary write burst is pending
                if (arbSecWrInProgReg_i = '0') then
                    WrBurst_Mux_Idle_cmb <= '1';
                end if;
            end if;

            if (not(arbRdDBusBusyReg_i) or (Sl_rdComp)) = '1' then
                pavalid_cmb <= '1';
            end if;

            if not DISABLE_ADDR_PIPELINING and
               (arbRdDBusBusyReg_i and not(arbSecRdInProgReg_i) and
                not(Sl_rdComp)) = '1' then
                savalid_cmb <= '1';
            end if;

            if (arbRdDBusBusyReg_i and (Sl_rdComp)) = '1' then
                LoadPriRd <= '1';
            end if;

            if (not WdtMTimeout_n) = '1' then
                pavalid_cmb <= '0';
                savalid_cmb <= '0';
                arbctrl_sm_ns <= IDLE;

            elsif (Sl_addrAck = '1') then
                pavalid_cmb <= '0';
                savalid_cmb <= '0';
                RecomputeRdBits <= '1';

                if ((not(arbRdDBusBusyReg_i) and not(arbSecRdInProgReg_i)) or 
                    (arbRdDBusBusyReg_i and (Sl_rdComp))) = '1' then
                    LoadPriRd <= '1';
                end if;

                if (arbRdDBusBusyReg_i and not(arbSecRdInProgReg_i) and
                    not(Sl_rdComp)) = '1' then
                    LoadSecRd <= '1';
                    LoadSecRdPriReg <= '1';
                end if;
                arbctrl_sm_ns <= IDLE;

            elsif (Sl_rearbitrate) = '1' then
                pavalid_cmb <= '0';
                savalid_cmb <= '0';
                arbctrl_sm_ns <= REARB; 
            else
                arbctrl_sm_ns <= RD_STATE;
            end if;

        --------------------------------- WR_STATE -------------------------------
        when WR_STATE =>

            -- Assert flag that transaction has been processed
            exec_trns_cmb <= '1';

            if (not(arbWrDBusBusyReg_i) or Sl_wrComp) = '1' then
                pavalid_cmb <= '1';
            end if;

            if not DISABLE_ADDR_PIPELINING and
                (arbWrDBusBusyReg_i and not(arbSecWrInProgReg_i) and
                not(Sl_wrComp)) = '1' then
                savalid_cmb <= '1';
            end if;

            if (arbWrDBusBusyReg_i and (Sl_wrComp)) = '1' then
                LoadPriWr <= '1';
            end if;

            if (not WdtMTimeout_n) = '1' then
                pavalid_cmb <= '0';
                arbctrl_sm_ns <= IDLE;

            elsif (Sl_addrAck = '1') then
                pavalid_cmb <= '0';
                savalid_cmb <= '0';
                RecomputeWrBits <= '1';

                if ((not(arbWrDBusBusyReg_i) and not(arbSecWrInProgReg_i)) 
                    or (arbWrDBusBusyReg_i and (Sl_wrComp))) = '1' then
                    LoadPriWr <= '1';
                end if;

                if (arbWrDBusBusyReg_i and not(arbSecWrInProgReg_i) and
                    not (Sl_wrComp)) = '1' then
                    LoadSecWr <= '1';
                    LoadSecWrPriReg <= '1';
                end if;                
                arbctrl_sm_ns <= IDLE;
                
            elsif (Sl_rearbitrate) = '1' then
                pavalid_cmb <= '0';
                savalid_cmb <= '0';
                arbctrl_sm_ns <= REARB;
                  
                -- Only keep track of previous transaction ReArbs if for PAValid
                -- If SAValid is re-arbitrated then requesting master will correctly
                -- drive wrBurst
                if (savalid_reg = '0') then
                    PrevTrnsReArb_set <= '1';
                end if;
            else
                arbctrl_sm_ns <= WR_STATE;
            end if;

        ------------------------------- REARB -------------------------------
        when REARB =>        
        
            if (C_ARB_TYPE = 0) then
                -- Disable current master to being re-granted the bus
                arbDisMReqReg_cmb <= arbAddrSelReg;
                LoadDisReg <= '1';                 
            end if;
            arbctrl_sm_ns <= IDLE;

--coverage off
        ------------------------------- Default --------------------------------
        when others =>
            arbctrl_sm_ns <= IDLE;
--coverage on

    end case;
end process ARBCTRL_SM_CMB_PROCESS;

PAValid <= pavalid_i;
SAValid <= savalid_reg;

ARBCTRL_SM_REG_PROCESS: process (Clk)
begin
 
    if (Clk'event and Clk = '1' ) then
      if (ArbReset = RESET_ACTIVE) then
        pavalid_i <= '0';
        savalid_reg <= '0';
        arbctrl_sm_cs <= IDLE;
        WrBurst_Mux_Idle_reg <= '0';
        exec_trns <= '1';
        hold_rr <= '0';
      else
        pavalid_i <= pavalid_cmb;
        savalid_reg <= savalid_cmb;
        arbctrl_sm_cs <= arbctrl_sm_ns;
        WrBurst_Mux_Idle_reg <= WrBurst_Mux_Idle_cmb;
        exec_trns <= exec_trns_cmb;
        hold_rr <= hold_rr_cmb;

      end if;
    end if;
end process ARBCTRL_SM_REG_PROCESS;


DETECT_REARB_REG_PROCESS: process (Clk)
begin 
    if (Clk'event and Clk = '1' ) then
      if (ArbReset = RESET_ACTIVE) or (PrevTrnsReArb_rst = '1') then
        PrevTrnsReArb <= '0';
      elsif (PrevTrnsReArb_set = '1') then
        PrevTrnsReArb <= '1';
      else
        PrevTrnsReArb <= PrevTrnsReArb;
      end if;
    end if;
end process DETECT_REARB_REG_PROCESS;
  

ARB_REGISTERS_BLK : block

  signal arbPriRdMasterReg_i    : std_logic_vector(0 to C_NUM_MASTERS-1 );
  signal arbSecRdMasterReg_i    : std_logic_vector(0 to C_NUM_MASTERS-1 );
  signal arbSecWrMasterReg_i    : std_logic_vector(0 to C_NUM_MASTERS-1 );

  signal priRdBurstEn           : std_logic;
  signal priRdEn                : std_logic;
  signal priWrEn                : std_logic;
  signal promoteRead            : std_logic;
  signal promoteWrite           : std_logic;
  signal arbPriRdBurstIn        : std_logic;
  signal arbPriRdMasterIn       : std_logic_vector(0 to C_NUM_MASTERS-1 );
  signal arbPriWrMasterIn       : std_logic_vector(0 to C_NUM_MASTERS-1 );
  signal arbSecRdBurstReg       : std_logic;

  signal arbRdDBusBusyReg_cmb   : std_logic;
  signal arbSecRdInProgReg_cmb  : std_logic;
  signal arbWrDBusBusyReg_cmb   : std_logic;
  signal arbSecWrInProgReg_cmb  : std_logic;

begin

-------------------------------------------------------------------------------
-- Signal assignments
-------------------------------------------------------------------------------
-- assign outputs to internal versions
arbPriRdMasterReg     <= arbPriRdMasterReg_i;
arbSecWrMasterReg     <= arbSecWrMasterReg_i;
arbSecRdMasterReg     <= arbSecRdMasterReg_i;

-- assign register enable signals
priWrEn         <= LoadPriWr or promoteWrite;
priRdEn         <= LoadPriRd or promoteRead;
priRdBurstEn    <= LoadPriRd or promoteRead;


    arbRdDBusBusyReg_cmb <=
                  (not Sl_rdComp and arbRdDbusBusyReg_i)
               or (RecomputeRdBits and (not Sl_rdComp or arbRdDbusBusyReg_i)) 
               or arbSecRdInProgReg_i;
  
    arbSecRdInProgReg_cmb <=
                   not Sl_rdComp
               and (   (arbRdDbusBusyReg_i and RecomputeRdBits)
                    or arbSecRdInProgReg_i
                   );
  
    promoteRead <= arbRdDbusBusyReg_i and arbSecRdInProgReg_i and Sl_rdComp;


    arbWrDbusBusyReg_cmb <=
                  (not Sl_wrComp and arbWrDbusBusyReg_i)
               or (RecomputeWrBits and (not Sl_wrComp or arbWrDbusBusyReg_i)) 
               or arbSecWrInProgReg_i;
                 
    arbSecWrInProgReg_cmb <=
                   not Sl_wrComp
               and (   
               
               (arbWrDbusBusyReg_i and RecomputeWrBits)
                    or arbSecWrInProgReg_i
                   )
                   ;
  
    promoteWrite <= arbWrDBusBusyReg_i and arbSecWrInProgReg_i and Sl_wrComp;

  
-------------------------------------------------------------------------------
-- Register Processes
-------------------------------------------------------------------------------
-- The following processes define the various registers which maintain the
-- state of the PLB.

ARBPRIRDMASTERREG_I_GEN : if not (C_OPTIMIZE_1M and (C_NUM_MASTERS = 1)) generate
PRI_RDMSTR_REG:  process (Clk)
begin
    if (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
            arbPriRdMasterReg_i <= (others => '0');
        else
            if (priRdEn) = '1' then
                arbPriRdMasterReg_i <= arbPriRdMasterIn;
            end if;
        end if;
    end if;
end process PRI_RDMSTR_REG;
end generate;

ARBPRIRDMASTERREG_I_1M_GEN : if (C_OPTIMIZE_1M and (C_NUM_MASTERS = 1)) generate
    arbPriRdMasterReg_i(0) <= '1';
end generate;


ARBPRIRDMASTERREGREG_I_GEN : if not (C_OPTIMIZE_1M and (C_NUM_MASTERS = 1)) generate
PRI_RDMSTR_REGREG:  process (Clk)
begin
    if (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
            arbPriRdMasterRegReg <= (others => '0');
        else
            arbPriRdMasterRegReg <= arbPriRdMasterReg_i;
        end if;
    end if;
end process ;
end generate;

ARBPRIRDMASTERREGREG_I_1M_GEN : if (C_OPTIMIZE_1M and (C_NUM_MASTERS = 1)) generate
    arbPriRdMasterRegReg(0) <= '1';
end generate;


ARBSECRDMASTERREG_I_GEN : if not (C_OPTIMIZE_1M and (C_NUM_MASTERS = 1)) generate
SEC_RDMSTR_REG:  process (Clk)
begin
    if (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
            arbSecRdMasterReg_i <= (others => '0');
        else
            if (LoadSecRd) = '1' then
                arbSecRdMasterReg_i <= arbAddrSelReg;
            end if;
        end if;
    end if;
end process SEC_RDMSTR_REG;
end generate;

ARBSECRDMASTERREG_I_1M_GEN : if (C_OPTIMIZE_1M and (C_NUM_MASTERS = 1)) generate
    arbSecRdMasterReg_i(0) <= '1';
end generate;


RD_DBUSBUSY_PROCESS:  process (Clk)
begin
    if (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
            arbRdDBusBusyReg_i <= '0';
        else
            arbRdDBusBusyReg_i <= arbRdDBusBusyReg_cmb;
        end if;
    end if;
end process RD_DBUSBUSY_PROCESS;


ARBSECRDINPROGREG_GEN : if not DISABLE_ADDR_PIPELINING generate
SEC_RDINPROGREG_PROCESS:  process (Clk)
begin
    if  (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
            arbSecRdInProgReg_i <= '0';
        else
            arbSecRdInProgReg_i <= arbSecRdInProgReg_cmb;
        end if;
    end if;
end process SEC_RDINPROGREG_PROCESS;
end generate;

ARBSECRDINPROGREG_NOPIPE_GEN : if DISABLE_ADDR_PIPELINING generate
    arbSecRdInProgReg_i <= '0';
end generate;


ARBPRIWRMASTERREG_GEN : if not (C_OPTIMIZE_1M and (C_NUM_MASTERS = 1)) generate
PRI_WRMSTRREG_PROCESS:  process (Clk)
begin
    if (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
            arbPriWrMasterReg <= (others => '0');
        else
            if (priWrEn) = '1' then
                arbPriWrMasterReg <= arbPriWrMasterIn;
            end if;
        end if;
    end if;
end process PRI_WRMSTRREG_PROCESS;
end generate;

ARBPRIWRMASTERREG_1M_GEN : if (C_OPTIMIZE_1M and (C_NUM_MASTERS = 1)) generate
    arbPriWrMasterReg(0) <= '1';
end generate;


ARBSECWRMASTERREG_I_GEN : if not (C_OPTIMIZE_1M and (C_NUM_MASTERS = 1)) generate
SEC_WRMSTRREG_PROCESS:  process (Clk)
begin
    if (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
          arbSecWrMasterReg_i <= (others => '0');
        else
            if (LoadSecWr) = '1' then
                arbSecWrMasterReg_i <= arbAddrSelReg;
            end if;
        end if;
    end if;
end process SEC_WRMSTRREG_PROCESS;
end generate;

ARBSECWRMASTERREG_I_1M_GEN: if (C_OPTIMIZE_1M and (C_NUM_MASTERS = 1)) generate
    arbSecWrMasterReg_i(0) <= '1';
end generate;

WR_DBUS_BUSYREG:  process (Clk)
begin
    if (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
            arbWrDBusBusyReg_i <= '0';
        else
            arbWrDBusBusyReg_i <= arbWrDBusBusyReg_cmb;
        end if;
    end if;
end process WR_DBUS_BUSYREG;


ARBSECWRINPROGREG_GEN : if not DISABLE_ADDR_PIPELINING generate
SEC_WRINPROG_REG_PROCESS:  process (Clk)
begin
    if (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
            arbSecWrInProgReg_i <= '0';
        else
            arbSecWrInProgReg_i <= arbSecWrInProgReg_cmb;
        end if;
    end if;
end process SEC_WRINPROG_REG_PROCESS;
end generate;

ARBSECWRINPROGREG_NOPIPE_GEN : if DISABLE_ADDR_PIPELINING generate
    arbSecWrInProgReg_i <= '0';
end generate;

DIS_REQREG_PROCESS:  process (Clk)
begin
    if (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
            arbDisMReqReg <= (others => '0');
        else
            if (LoadDisReg) = '1' then
                arbDisMReqReg <= arbDisMReqReg_cmb;
            end if;
        end if;
    end if;
end process;

PRI_RDMSTRIN_PROCESS:  process (promoteRead, arbAddrSelReg, arbSecRdMasterReg_i)
begin
    case promoteRead is
      when '0' =>
        arbPriRdMasterIn <= arbAddrSelReg;
      when others  =>
        arbPriRdMasterIn <= arbSecRdMasterReg_i;
    end case ;
end process;

PRI_WRMSTRIN_PROCESS:  process (promoteWrite, arbAddrSelReg, arbSecWrMasterReg_i)
begin
    case promoteWrite is
      when '0' =>
        arbPriWrMasterIn <= arbAddrSelReg;
      when others  =>
        arbPriWrMasterIn <= arbSecWrMasterReg_i;
    end case ;
end process;

SEC_RDPRIORREG_PROCESS:  process (Clk)
begin
    if  (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
            arbSecRdInProgPriorReg <= (others => '0');
        else
            if (LoadSecRdPriReg) = '1' then
                arbSecRdInProgPriorReg <= PLB_reqPri;
            end if;
        end if;
    end if;
end process SEC_RDPRIORREG_PROCESS;

SEC_WRPRIORREG_PROCESS:  process (Clk)
begin
    if (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
            arbSecWrInProgPriorReg <= (others => '0');
        else
            if (LoadSecWrPriReg) = '1' then
                arbSecWrInProgPriorReg <= PLB_reqPri;
            end if;
        end if;
    end if;
end process SEC_WRPRIORREG_PROCESS;

PRI_RDBURSTIN_PROCESS:  process (promoteRead, arbBurstReq, arbSecRdBurstReg)
begin
    case promoteRead is
      when '0' =>
        arbPriRdBurstIn <= arbBurstReq;
      when others  =>
        arbPriRdBurstIn <= arbSecRdBurstReg;
    end case  ;
end process PRI_RDBURSTIN_PROCESS;

PRI_RDBURSTREG_PROCESS:  process (Clk)
begin
    if (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
            ArbPriRdBurstReg <= '0';
        else
            if (priRdBurstEn) = '1' then
                ArbPriRdBurstReg <= arbPriRdBurstIn;
            end if;
        end if;
    end if;
end process PRI_RDBURSTREG_PROCESS;


SEC_RDBURSTREG_PROCESS:  process(Clk)
begin
    if (Clk'event and Clk = '1' ) then
        if (ArbReset = RESET_ACTIVE) then
            ArbSecRdBurstReg <= '0';
        else
            if (LoadSecRd) = '1' then
                ArbSecRdBurstReg <= ArbBurstReq;
            end if;
        end if;
    end if;
end process SEC_RDBURSTREG_PROCESS;

end block ARB_REGISTERS_BLK;


-------------------------------------------------------------------------------
-- bus_lock_sm
-------------------------------------------------------------------------------
-- PLB_busLock Generation
--
-- PLB_busLock must assert when PAValid asserts and must negate when the 
-- selected master negates its Mn_buslock signal. It also must negate whenever
-- a rearbitrate condition has been asserted. Therefore, PLB_busLock will
-- assert whenever the arb_control_sm is in the Set_disables_state. If the 
-- slave issues a rearbitrate, PLB_busLock must
-- negate. Otherwise, PLB_busLock stays asserted until the master negates its
-- bus lock signal.
--
-- In order to not incur a register delay when a master negates its buslock, a
-- register is used to generate a registered version of PLB_busLock. The output
-- of this register is then gated with the master's buslock signal.
--
------------------------------------------------------------------------------- 
BUS_LOCK_SM_BLK : block

signal plb_buslock_reg  : std_logic;
signal sm_buslock_reg   : std_logic;

begin 

PLBBUSLOCK_REG_PROCESS: process (Clk)
begin

    if (Clk'event and Clk = '1') then
        if (ArbReset = RESET_ACTIVE) then
            plb_buslock_reg <= '0';
        else
            
            if (C_ARB_TYPE = 0) then
                plb_buslock_reg <= 
                    not (Sl_rearbitrate and not Sl_addrAck)  
                    and Mstr_buslock
                    and (plb_buslock_reg or Set_disables_state);
                
            else
               plb_buslock_reg <= 
                    not (Sl_rearbitrate and not Sl_addrAck)  
                    and Mstr_buslock
                    and (plb_buslock_reg or in_buslock);
            end if;                
                
        end if;
    end if;
end process PLBBUSLOCK_REG_PROCESS;

plb_buslock_i <= plb_buslock_reg and Mstr_buslock;
PLB_busLock   <= plb_buslock_i ;

-------------------------------------------------------------------------------
-- SM_busLock Generation
--
-- The SM_buslock signal will assert when the selected master's busLock signal
-- asserts but will negate one clock later. This signal is used by the 
-- arb_control_sm to correctly handle bus lock situations. Note that this signal
-- doesn't reflect the actual locked state of the bus since the PLB doesn't
-- consider the bus truly locked until the slave addrAcks the buslock request.
-- This signal will assert when the Master asserts busLock - it does not wait
-- for the slave addrAck. This is so the arb_control_sm can correctly wait for
-- both buses to be idle before issuing PAValid. This signal does wait to negate
-- for one clock after the Master bus lock negates so that the arb_control_sm will
-- still see the bus as locked even though the master's signal has been negated.
-- The PLB specification requires that the bus remain locked for one clock after
-- the master's buslock signal is negated.
-------------------------------------------------------------------------------
SMBUSLOCK_REG_PROCESS: process (Clk)
begin
    if (Clk'event and Clk = '1') then
        if (ArbReset = RESET_ACTIVE) then
            sm_buslock_reg <= '0';
        else
            sm_buslock_reg <= Mstr_buslock;
        end if;
    end if;
end process SMBUSLOCK_REG_PROCESS;

sm_buslock_i <= sm_buslock_reg or Mstr_buslock;
SM_busLock   <= sm_buslock_i;

end block BUS_LOCK_SM_BLK;

end simulation;

