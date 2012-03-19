-------------------------------------------------------------------------------
--  $Id: plb_arbiter_logic.vhd,v 1.1.2.1 2010/07/13 16:33:56 srid Exp $
-------------------------------------------------------------------------------
-- plb_arbiter_logic.vhd - entity/architecture pair
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
-- Filename:        plb_arbiter_logic.vhd
-- Version:         v1.04a
-- Description:     This file contains the arbitration and bus control logic
--                  for the PLB. The main bus control is done in the
--                  arb_registers and arb_control_sm modules. This file also
--                  contains the priority encoder, the watchdog timer, and
--                  all of the signal multiplexors.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:  (see plb_v46.vhd)
--
-------------------------------------------------------------------------------
-- Author:      BLT
--
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
--  LCW Oct 15, 2004      -- updated for NCSim
-- ~~~~~~
--  FLO         06/01/05        
-- ^^^^^^
-- Start of changes for plb_v46.
-- -PLB_MErr split into PLB_MRdErr and PLB_MWrErr (Rd and Wr versions).
-- -Sl_MErr split into Sl_MRdErr and Sl_MWrErr.
-- -Removed component declarations in favor of direct entity instantiation.
-- ~~~~~~
--  FLO         06/03/05        
-- ^^^^^^
-- -PLB_pendPri split into PLB_rdPendPri and PLB_wrPendPri (Rd and Wr versions).
-- -PLB_pendReq split into PLB_rdPendReq and PLB_wrPendReq (Rd and Wr versions).
-- -Changed structure section to a reference to plb_v46.vhd.
-- ~~~~~~
--  FLO         06/08/05        
-- ^^^^^^
-- -Switched to v2_00_a for proc_common.
-- -Eliminated aspects related to the watchdog timer completing hanshakes on
--  timeout.
-- ~~~~~~
--  FLO         06/16/05        
-- ^^^^^^
-- -Changed generic name: C_NUM_OPBCLK_PLB2OPB_REARB -> C_NUM_CLK_PLB2OPB_REARB
-- ~~~~~~
--  FLO         07/19/05        
-- ^^^^^^
-- -Changed to active low WdtMTimeout_n
-- ~~~~~~
--  FLO         08/26/05        
-- ^^^^^^
-- -Accomodate new generics and signals in instances.
-- ~~~~~~
--  FLO         08/01/05        
-- ^^^^^^
-- -To consolidate state information for optimization evaluations,
--  arb_registers and bus_lock_sm incorporated locally in arb_control_sm.
-- ~~~~~~
--  FLO         09/09/05        
-- ^^^^^^
-- -Added UABus.
-- -Vectorized PLB_rdPrim and PLB_wrPrim to the number of slaves.
-- ~~~~~~
--  FLO         11/24/05        
-- ^^^^^^
-- -Removed the ArbAddrVldReg output port.
-- ~~~~~~
--  FLO         12/02/05        
-- ^^^^^^
-- -Added C_FAMILY generic.
-- -Passing C_FAMILY to lower-level components that instantiate mux_onehot_f.
-- ~~~~~
--  JLJ         04/11/07    
-- ^^^^^^
--  Added register process on select output signals.
--  Remove register on PLB_PAValid output.
-- ~~~~~
--  JLJ         04/17/07    
-- ^^^^^^
--  Remove register on PLB_SAValid & PLB_abort outputs.
-- ~~~~~
--  JLJ         05/10/07    
-- ^^^^^^
--  Added Sl_wrComp to muxed_signals module.
-- ~~~~~
--  JLJ         06/07/07    
-- ^^^^^^
--  Fix Questa 6.3 load bug evaluating UABus.  Fix @ 32-bits wide.
-- ~~~~~
--  JLJ         07/17/07    v1.00a   
-- ^^^^^^
--  CR 442962. Change default setting of C_ADDR_PIPELINING_TYPE to be 1.  
--
--  Add C_SIZE parameter to watchdog_timer module.  In shared bus mode, the counter 
--  value is set to 4, for up to 16 clock cycles to occur before a timeout condition.
-- ~~~~~
--  JLJ         09/14/07    v1.01a  
-- ^^^^^^
--  Update to v1.01a.  plb_priority_encoder module renamed to plb_arb_encoder.
-- ~~~~~~
--  JLJ         10/19/07    v1.02a  
-- ^^^^^^
--  Update to v1.02a (and merge with edits to v1.01a).
-- ~~~~~~
--  JLJ         10/31/07    v1.02a  
-- ^^^^^^
--  Clean up unused ports on sub-modules.
--  Remove generate of PLB_abort.
--  Clean up Abort usage on sub-modules.
--  Remove input signal, M_abort.
--  Set default output state of PLB_abort = '0'.
-- ~~~~~~
--  JLJ         12/11/07    v1.02a  
-- ^^^^^^
--  Code cleanup.
-- ~~~~~~
--  JLJ         03/17/08    v1.03a  
-- ^^^^^^
--  Upgraded to v1.03a. 
-- ~~~~~~
--  JLJ         05/14/08    v1.04a  
-- ^^^^^^
--  Updated to v1.04a (to migrate using proc_common_v3_00_a) in EDK L.
--  Remove PLB_abort (set default at top level).
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

-- PROC_COMMON_PKG contains the function that creates NUM_MSTRS_PAD which is
-- the number of masters rounded up to the next power of 2
library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

library unisim;
use unisim.vcomponents.all;

library plb_v46_v1_05_a;


-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_NUM_MASTERS        -- number of masters
--      C_NUM_SLAVES         -- number of masters
--      C_MID_BITS           -- number of bits required to encode master IDs
--      C_PLB_AWIDTH         -- address bus width
--      C_PLB_DWIDTH         -- data bus width
--      C_DCR_INTFCE         -- include DCR interface
--      C_DCR_AWIDTH         -- DCR address width
--      C_DCR_DWIDTH         -- DCR data width
--      C_BASEADDR           -- DCR base address
--      C_HIGHADDR           -- DCR high address
--      C_IRQ_ACTIVE         -- active edge for interrupt (rising or falling)
--
-- Definition of Ports:
--      -- Masters' signals
--      input  M_RNW
--      input  M_busLock
--      input  M_lockErr
--      input  M_priority
--      input  M_rdBurst
--      input  M_request
--      input  M_wrBurst
--
--      -- PLB signals
--      input  PLB_ABus
--      input  PLB_UABus
--      input  PLB_BE
--      output PLB_MAddrAck
--      output WdtMTimeout_n
--      output PLB_MTimeout
--      output PLB_MBusy
--      output PLB_MRdErr
--      output PLB_MWrErr
--      output PLB_MRdBTerm
--      output PLB_MRearbitrate
--      output PLB_MWrBTerm
--      output PLB_MSSize
--      output PLB_PAValid
--      output PLB_SAValid
--      output PLB_masterID
--      output PLB_rdPendPri
--      output PLB_wrPendPri
--      output PLB_rdPrim
--      output PLB_reqPri
--      output PLB_wrPrim
--      output PLB_RNW
--      output PLB_busLock
--      output PLB_rdPendReq
--      output PLB_wrPendReq
--      output PLB_rdBurst
--      input  PLB_size
--      input  PLB_type
--      output PLB_wrBurst
--
--      -- Slave signals
--      input  Sl_MBusy
--      input  Sl_MRdErr
--      input  Sl_MWrErr
--      input  Sl_rdBTerm
--      input  Sl_SSize
--      input  Sl_wrBTerm
--      input  Sl_wrComp
--      input  Sl_addrAck
--      input  Sl_rdComp
--      input  Sl_rearbitrate
--      input  Sl_wait
--
--      -- Arbiter signals
--      output ArbAddrSelReg
--      input  ArbBurstReq
--      output ArbPriRdMasterRegReg
--      output ArbPriWrMasterReg
--
--      -- DCR signals
--      input  DCR_ABus
--      input  DCR_Read
--      input  DCR_Write
--      output PLB_dcrAck
--      output PLB_dcrDBus
--      input  DCR_DBus
--
--      -- Watch Dog Timer signals
--
--      -- Clock and reset
--      input  Clk
--      input  Rst
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------
entity plb_arbiter_logic is
  generic (
           C_NUM_MASTERS            : integer;
           C_NUM_SLAVES             : integer;
           C_MID_BITS               : integer;
           C_PLB_AWIDTH             : integer   := 32;
           C_PLB_DWIDTH             : integer   := 128;
           C_DCR_INTFCE             : integer   := 1;
           C_DCR_AWIDTH             : integer   := 10;
           C_DCR_DWIDTH             : integer   := 32;
           C_BASEADDR               : std_logic_vector;
           C_HIGHADDR               : std_logic_vector;
           C_IRQ_ACTIVE             : std_logic := '1';
           C_OPTIMIZE_1M            : boolean;
           C_ADDR_PIPELINING_TYPE   : integer   := 1;   -- 0:none, 1:2-level
           C_FAMILY                 : string;
           C_ARB_TYPE               : integer   := 0    -- 0: fixed, 1: round-robin
           );
  port (
        M_RNW                   : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
        M_busLock               : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
        M_lockErr               : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
        M_priority              : in std_logic_vector(0 to (C_NUM_MASTERS * 2) - 1 );
        M_rdBurst               : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
        M_request               : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
        M_wrBurst               : in std_logic_vector(0 to C_NUM_MASTERS - 1 );

        PLB_ABus                : in std_logic_vector(0 to 31 );
        PLB_UABus               : in std_logic_vector(0 to C_PLB_AWIDTH - 1 );
        PLB_BE                  : in std_logic_vector(0 to C_PLB_DWIDTH/8 -1);
        PLB_MAddrAck            : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
        WdtMTimeout_n           : out std_logic;
        PLB_MTimeout            : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
        PLB_MBusy               : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
        PLB_MRdErr              : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
        PLB_MWrErr              : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
        PLB_MRdBTerm            : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
        PLB_MRearbitrate        : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
        PLB_MWrBTerm            : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
        PLB_MSSize              : out std_logic_vector(0 to (C_NUM_MASTERS * 2) - 1 );
        PLB_PAValid             : out std_logic;
        PLB_SAValid             : out std_logic;
        PLB_masterID            : out std_logic_vector(0 to C_MID_BITS-1 );
        PLB_rdPendPri           : out std_logic_vector(0 to 1 );
        PLB_wrPendPri           : out std_logic_vector(0 to 1 );
        PLB_rdPrim              : out std_logic_vector(0 to C_NUM_SLAVES - 1 );
        PLB_reqPri              : out std_logic_vector(0 to 1 );
        PLB_wrPrim              : out std_logic_vector(0 to C_NUM_SLAVES - 1 );
        PLB_RNW                 : out std_logic;
        PLB_busLock             : out std_logic;
        PLB_rdPendReq           : out std_logic;
        PLB_wrPendReq           : out std_logic;
        PLB_rdBurst             : out std_logic;
        PLB_size                : in std_logic_vector(0 to 3 );
        PLB_type                : in std_logic_vector(0 to 2);
        PLB_wrBurst             : out std_logic;

        Sl_MBusy                : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
        Sl_MRdErr               : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
        Sl_MWrErr               : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
        Sl_rdBTerm              : in std_logic;
        Sl_SSize                : in std_logic_vector(0 to 1 );
        Sl_wrBTerm              : in std_logic;
        Sl_wrComp               : in std_logic;
        Sl_addrAck              : in std_logic;
        Sl_rdComp               : in std_logic;
        Sl_rearbitrate          : in std_logic;
        Sl_wait                 : in std_logic;

        ArbAddrSelReg           : out std_logic_vector(0 to C_NUM_MASTERS-1 );
        ArbBurstReq             : in std_logic;
        ArbPriRdMasterRegReg    : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
        ArbPriWrMasterReg       : out std_logic_vector(0 to C_NUM_MASTERS-1 );

        DCR_ABus                : in std_logic_vector (0 to C_DCR_AWIDTH-1);
        DCR_Read                : in std_logic;
        DCR_Write               : in std_logic;
        PLB_dcrAck              : out std_logic;
        PLB_dcrDBus             : out std_logic_vector (0 to C_DCR_DWIDTH-1);
        DCR_DBus                : in std_logic_vector (0 to C_DCR_DWIDTH-1);

        Bus_Error_Det           : out std_logic;
        Clk                     : in std_logic;
        Rst                     : in std_logic
        );
end plb_arbiter_logic;


-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture implementation of plb_arbiter_logic is

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
constant NUM_MSTRS_PAD  : integer   := (((pad_power2(C_NUM_MASTERS)-1)/4)+1)*4;

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------

-- define internal versions of output signals
signal plb_pavalid_i          : std_logic;
signal plb_savalid_i          : std_logic;
signal plb_rnw_i              : std_logic;
signal plb_rdPendreq_i        : std_logic;
signal plb_wrPendreq_i        : std_logic;
signal plb_rdburst_i          : std_logic;
signal plb_wrburst_i          : std_logic;
signal arbreset_i             : std_logic;
signal arbaddrselreg_i        : std_logic_vector(0 to C_NUM_MASTERS-1);
signal arbPriRdMasterRegReg_i : std_logic_vector(0 to C_NUM_MASTERS-1);
signal arbPriWrMasterReg_i    : std_logic_vector(0 to C_NUM_MASTERS-1);
signal plb_reqpri_i           : std_logic_vector(0 to 1);
signal plb_rdprimreg_i        : std_logic;
signal plb_buslock_i          : std_logic;
signal plb_masterid_i         : std_logic_vector(0 to C_MID_BITS-1);

-- define padded buses
signal m_request_pad          : std_logic_vector(0 to NUM_MSTRS_PAD-1);
signal m_buslock_pad          : std_logic_vector(0 to NUM_MSTRS_PAD-1);
signal m_priority_pad         : std_logic_vector(0 to 2*NUM_MSTRS_PAD-1);
signal arbaddrselreg_pad      : std_logic_vector(0 to NUM_MSTRS_PAD-1);
signal arbDisMReqReg_pad      : std_logic_vector(0 to NUM_MSTRS_PAD-1);

signal mstr_buslock           : std_logic;
signal sm_buslock             : std_logic;

signal qualReq                : std_logic;
signal arbAValid              : std_logic;
signal arbDisMReqReg          : std_logic_vector(0 to C_NUM_MASTERS-1 );
signal arbDisMReqRegIn        : std_logic_vector(0 to C_NUM_MASTERS-1 );
signal arbPriRdBurstReg       : std_logic;
signal arbPriRdMasterReg      : std_logic_vector(0 to C_NUM_MASTERS-1 );
signal arbRdDBusBusyReg       : std_logic;
signal arbSecRdInProgPriorReg : std_logic_vector(0 to 1 );
signal arbSecRdInProgReg      : std_logic;
signal arbSecRdMasterReg      : std_logic_vector(0 to C_NUM_MASTERS-1 );
signal arbSecWrInProgPriorReg : std_logic_vector(0 to 1 );
signal arbSecWrInProgReg      : std_logic;
signal arbSecWrMasterReg      : std_logic_vector(0 to C_NUM_MASTERS-1 );
signal arbWrDBusBusyReg       : std_logic;
signal loadAddrSelReg         : std_logic;
signal rdPrimIn               : std_logic;
signal rdPrimReg              : std_logic;

-- Watch Dog Timer signals
signal wdtMTimeout_n_i        : std_logic;
signal wdtMTimeout_n_p1_i     : std_logic;
signal wrPrimIn               : std_logic;
signal rdPrim                 : std_logic;
signal wrPrim                 : std_logic;

-- interrupt enable and sw reset
signal intr_en                : std_logic;
signal sw_rst                 : std_logic;
signal mstr_request           : std_logic_vector (0 to 0);

-------------------------------------------------------------------------------
-- Component Declarations
-------------------------------------------------------------------------------
-- Priority encoder selects master with highest priority bits. If there are two
-- masters with the same priority inputs, Master 0 has the highest priority
-- followed by Master 1, Master 2, etc.

-- Arbiter Control state machine controls the PLB transactions and the assertion
-- of PAValid, SAValid, etc.

-- gen_qual_req determines if any of the masters have request asserted without abort or
-- being disabled due to a bus lock

-- The muxed_signals block contains all of the signal multiplexors for the PLB control
-- signals and transaction qualifiers

-- ArbRegisters maintain the current state of the bus, i.e. whether primary and/or
-- secondary transactions are in progress

-- The watchdog timer will assert the addrAck if the slave has not responded within 16
-- clock cycles from the assertion of PAValid or SAValid. It will then assert the
-- appropriate number of dataAcks along with Merr to complete the transaction.

-- dcr_regs contain the PLB control registers with a DCR interface.  If
-- the design is parameterized to not include the DCR interface, zero
-- the DCR output signals and pass the bus through.

-- The bus_lock_sm asserts PLB_buslock when a master locks the bus
-- when PAValid asserts and negates PLB_buslock with the master's buslock signal.
-- It also generates a buslock signal for use by the arb_control_sm which asserts
-- with the master's buslock signal, but negates one clock later.

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin

-------------------------------------------------------------------------------
-- assign internal signals to outputs
-------------------------------------------------------------------------------

PLB_PAValid         <= plb_pavalid_i;
PLB_wrBurst         <= plb_wrburst_i;
PLB_rdBurst         <= plb_rdburst_i;
PLB_rdPendReq       <= plb_rdPendreq_i;
PLB_wrPendReq       <= plb_wrPendreq_i;
PLB_reqPri          <= plb_reqpri_i;
PLB_SAValid         <= plb_savalid_i;
ArbAddrSelReg       <= arbaddrselreg_i;
ArbPriRdMasterRegReg <= arbPriRdMasterRegReg_i;
ArbPriWrMasterReg   <= arbPriWrMasterReg_i;
PLB_busLock         <= plb_buslock_i;
WdtMTimeout_n       <= wdtMTimeout_n_i;

-- Add register stage on select output signals
REG_PROCESS: process (Clk)
begin 
    if (Clk'event and Clk = '1' ) then
        if (Rst = RESET_ACTIVE) then
            PLB_masterID <= (others => '0');
            PLB_RNW <= '0';
        else 
            PLB_masterID <= plb_masterid_i;
            PLB_RNW <= plb_rnw_i;
        end if;
    end if;
end process REG_PROCESS;



-------------------------------------------------------------------------------
-- set extra bits in padded buses to '0'
-------------------------------------------------------------------------------

m_request_pad(0 to C_NUM_MASTERS-1) <= M_request;
REQPAD_GEN: if C_NUM_MASTERS /= NUM_MSTRS_PAD generate
    m_request_pad(C_NUM_MASTERS to NUM_MSTRS_PAD-1) <= (others => '0');
end generate REQPAD_GEN;

m_priority_pad(0 to C_NUM_MASTERS*2-1) <= M_priority;
PRIORITYPAD_GEN: if C_NUM_MASTERS /= NUM_MSTRS_PAD generate
 m_priority_pad(C_NUM_MASTERS*2 to NUM_MSTRS_PAD*2-1) <= (others => '0');
end generate PRIORITYPAD_GEN;

arbaddrselreg_pad(0 to C_NUM_MASTERS-1) <= arbaddrselreg_i;
ADDRSELPAD_GEN: if C_NUM_MASTERS /= NUM_MSTRS_PAD generate
 arbaddrselreg_pad(C_NUM_MASTERS to NUM_MSTRS_PAD-1) <= (others => '0');
end generate ADDRSELPAD_GEN;

arbDisMReqReg_pad(0 to C_NUM_MASTERS-1) <= ArbDisMReqReg;
DISMREQ_GEN: if C_NUM_MASTERS /= NUM_MSTRS_PAD generate
 arbDisMReqReg_pad(C_NUM_MASTERS to NUM_MSTRS_PAD-1) <= (others => '0');
end generate DISMREQ_GEN;

m_buslock_pad(0 to C_NUM_MASTERS-1) <= M_busLock;
LOCKPAD_GEN: if C_NUM_MASTERS /= NUM_MSTRS_PAD generate
    m_buslock_pad(C_NUM_MASTERS to NUM_MSTRS_PAD-1) <= (others => '0');
end generate LOCKPAD_GEN;

-------------------------------------------------------------------------------
-- ARBRESET_PROCESS
-------------------------------------------------------------------------------
-- This process registers the system reset to create arbreset.
-------------------------------------------------------------------------------
ARBRESET_PROCESS: process (Clk)

begin

      if (Clk'event and Clk = '1') then
          arbreset_i <= Rst or sw_rst;
      end if;

end process ARBRESET_PROCESS;


-------------------------------------------------------------------------------
-- RDPRIMREG_PROCESS
-------------------------------------------------------------------------------
-- This process creates the registered component of the PLB_rdPrim output.
-------------------------------------------------------------------------------
rdPrimIn <= (Sl_rdComp) and (Sl_addrAck) and (arbRdDBusBusyReg) and
              (plb_savalid_i) and (plb_rnw_i);

RDPRIMREG_PROCESS: process(Clk, arbreset_i)

begin

  if (Clk'event and Clk = '1' ) then

      if arbreset_i= RESET_ACTIVE then
          plb_rdprimreg_i <= '0';
      else
          plb_rdprimreg_i <= rdPrimIn;
      end if ;

  end if;

end process RDPRIMREG_PROCESS;

-------------------------------------------------------------------------------
-- Combinatorial Logic
-------------------------------------------------------------------------------
-- The following statements define the various combinatorial PLB arbiter signals
-------------------------------------------------------------------------------


rdPrim <= (((Sl_rdComp) and (arbSecRdInProgReg))) or ((plb_rdprimreg_i));

wrPrimIn <= (Sl_wrComp) and (Sl_addrAck) and (arbWrDBusBusyReg) and
              (plb_savalid_i) and (not(plb_rnw_i));

wrPrim <= (((Sl_wrComp) and (arbSecWrInProgReg))) or ((wrPrimIn));

--------------------------------------------------------------------------------
-- As long as only 2-deep address pipelining is supported, the rdPrim
-- and wrPrim signals can be farmed out to all slaves.
--------------------------------------------------------------------------------
PLB_RDPRIM_GEN : for i in PLB_rdPrim'range generate
    PLB_rdPrim(i) <= rdPrim;
end generate;

PLB_WRPRIM_GEN : for i in PLB_wrPrim'range generate
    PLB_wrPrim(i) <= wrPrim;
end generate;



-------------------------------------------------------------------------------
-- Component Instantiations
-------------------------------------------------------------------------------
-- Arbitration encoder selects PLB master
I_ARB_ENCODER: entity plb_v46_v1_05_a.plb_arb_encoder
  generic map (  C_NUM_MASTERS      => C_NUM_MASTERS,
                 C_NUM_MSTRS_PAD    => NUM_MSTRS_PAD,
                 C_OPTIMIZE_1M      => C_OPTIMIZE_1M,
                 C_FAMILY           => C_FAMILY,
                 C_ARB_TYPE         => C_ARB_TYPE )
  port map (
          M_busLock             =>  m_buslock_pad,
          M_priority            =>  m_priority_pad,
          M_request             =>  m_request_pad,
          M_RNW                 =>  M_RNW,
          LoadAddrSelReg        =>  loadAddrSelReg,
          ArbDisMReqReg         =>  arbDisMReqReg_pad,
          ArbSecRdInProgReg     =>  arbSecRdInProgReg,
          SecRdInProgPriorReg   =>  arbSecRdInProgPriorReg,
          ArbSecWrInProgReg     =>  arbSecWrInProgReg,
          SecWrInProgPriorReg   =>  arbSecWrInProgPriorReg,
          ArbAddrSelReg         =>  arbaddrselreg_i,
          PLB_rdPendPri         =>  PLB_rdPendPri,
          PLB_wrPendPri         =>  PLB_wrPendPri,
          PLB_rdPendReq         =>  plb_rdPendreq_i,
          PLB_wrPendReq         =>  plb_wrPendreq_i,
          PLB_reqPri            =>  plb_reqpri_i,
          Clk                   =>  Clk,
          ArbReset              =>  arbreset_i
          );

-- Arbiter Control state machine controls the PLB transactions and the assertion
-- of PAValid, SAValid, etc.
I_ARBCONTROL_SM: entity plb_v46_v1_05_a.arb_control_sm
    generic map (C_NUM_MASTERS              => C_NUM_MASTERS,
                 C_OPTIMIZE_1M              => C_OPTIMIZE_1M,
                 C_ADDR_PIPELINING_TYPE     => C_ADDR_PIPELINING_TYPE,
                 C_ARB_TYPE                 => C_ARB_TYPE )
  port map (
            Sl_addrAck          => Sl_addrAck,
            ArbAddrSelReg       => arbaddrselreg_i,
            ArbRdDBusBusyReg    => arbRdDBusBusyReg,
            ArbWrDBusBusyReg    => arbWrDBusBusyReg,
            ArbSecRdInProgReg   => arbSecRdInProgReg,
            ArbSecWrInProgReg   => arbSecWrInProgReg,
            SM_busLock          => sm_buslock,
            Mstr_buslock        => mstr_buslock,
            PLB_busLock         => plb_buslock_i,
            Mstr_Request        => mstr_request(0),
            Clk                 => Clk,
            QualReq             => qualReq,
            PLB_RNW             => plb_rnw_i,
            Sl_rearbitrate      => Sl_rearbitrate,
            ArbReset            => arbreset_i,
            Sl_rdComp           => Sl_rdComp,
            Sl_wrComp           => Sl_wrComp,
            WdtMTimeout_n       => wdtMTimeout_n_i,
            loadAddrSelReg      => loadAddrSelReg,
            PAValid             => plb_pavalid_i,
            SAValid             => plb_savalid_i,
            PLB_reqPri          => plb_reqpri_i,
            ArbBurstReq         => arbBurstReq,
            ArbDisMReqReg       => arbDisMReqReg,
            ArbPriRdBurstReg    => arbPriRdBurstReg,
            ArbPriRdMasterReg   => arbPriRdMasterReg,
            ArbPriRdMasterRegReg => arbPriRdMasterRegReg_i,
            ArbPriWrMasterReg   => arbPriWrMasterReg_i,
            ArbSecRdInProgPriorReg => arbSecRdInProgPriorReg,
            ArbSecRdMasterReg   => arbSecRdMasterReg,
            ArbSecWrInProgPriorReg => arbSecWrInProgPriorReg,
            ArbSecWrMasterReg   => arbSecWrMasterReg
           );

-- gen_qual_req determines if any of the masters have request asserted without abort or
-- being disabled due to a bus lock
I_GENQUALREQ: entity plb_v46_v1_05_a.gen_qual_req
    generic map ( C_NUM_MASTERS => C_NUM_MASTERS)
    port map (
                QualReq         => qualReq,
                M_request       => M_request,
                arbDisMReqReg   => arbDisMReqReg
                );
                

MSTR_REQ_MUX: entity proc_common_v3_00_a.mux_onehot_f
    generic map (   C_DW    => 1,
                    C_NB    => C_NUM_MASTERS,
                    C_FAMILY => C_FAMILY)
    port map    (
                    D       => M_request,
                    S       => arbaddrselreg_i,
                    Y       => mstr_request(0 to 0) );


-- The muxed_signals block contains all of the signal multiplexors for the PLB control
-- signals and transaction qualifiers
I_MUXEDSIGNALS: entity plb_v46_v1_05_a.muxed_signals
    generic map ( C_NUM_MASTERS     => C_NUM_MASTERS,
                  C_NUM_MSTRS_PAD   => NUM_MSTRS_PAD,
                  C_MID_BITS        => C_MID_BITS,
                  C_FAMILY          => C_FAMILY
                )

  port map (
            M_busLock               => M_busLock,
            M_RNW                   => M_RNW,
            --M_abort                 => M_abort,
            Sl_addrAck              => Sl_addrAck,
            Sl_SSize                => Sl_SSize,
            Sl_rearbitrate          => Sl_rearbitrate,
            Sl_MBusy                => Sl_MBusy,
            M_rdBurst               => M_rdBurst,
            Sl_rdBTerm              => Sl_rdBTerm,
            M_wrBurst               => M_wrBurst,
            Sl_wrBTerm              => Sl_wrBTerm,
            Sl_MRdErr               => Sl_MRdErr,
            Sl_MWrErr               => Sl_MWrErr,
            Sl_wrComp               => Sl_wrComp,
            WdtMTimeout_n           => wdtMTimeout_n_i,
            ArbAddrSelReg           => arbaddrselreg_i,
            ArbAddrSelRegPad        => arbaddrselreg_pad,
            PLB_PAValid             => plb_pavalid_i,
            PLB_SAValid             => plb_savalid_i,
            ArbPriRdMasterReg       => arbPriRdMasterReg,
            ArbPriRdMasterRegReg    => arbPriRdMasterRegReg_i,
            ArbPriWrMasterReg       => arbPriWrMasterReg_i,
            ArbWrDBusBusyReg        => arbWrDBusBusyReg,
            Mstr_buslock            => mstr_buslock,
            PLB_masterID            => plb_masterid_i,
            PLB_RNW                 => plb_rnw_i,
            PLB_MAddrAck            => PLB_MAddrAck,
            PLB_MTimeout            => PLB_MTimeout,
            PLB_MSSize              => PLB_MSSize,
            PLB_MRearbitrate        => PLB_MRearbitrate,
            PLB_MBusy               => PLB_MBusy,
            PLB_rdBurst             => plb_rdburst_i,
            PLB_rdPrimReg           => plb_rdprimreg_i,
            PLB_MRdBTerm            => PLB_MRdBTerm,
            PLB_wrBurst             => plb_wrburst_i,
            PLB_MWrBTerm            => PLB_MWrBTerm,
            PLB_MRdErr              => PLB_MRdErr,
            PLB_MWrErr              => PLB_MWrErr,
            ArbPriRdBurstReg        => arbPriRdBurstReg,
            Clk                     => Clk,
            ArbReset                => arbreset_i
            );

-- The watchdog timer will assert the addrAck if the slave has not responded within 16
-- clock cycles from the assertion of PAValid.
I_WDT: entity plb_v46_v1_05_a.watchdog_timer
  generic map (
            C_SIZE  => 4
  )
  port map (
            Clk                 => Clk,
            ArbReset            => arbreset_i,
            PLB_PAValid         => plb_pavalid_i,
            Sl_addrAck          => Sl_addrAck,
            Sl_rearbitrate      => Sl_rearbitrate,
            Sl_wait             => Sl_wait,
            WdtMTimeout_n       => wdtMTimeout_n_i,
            WdtMTimeout_n_p1    => wdtMTimeout_n_p1_i
           );

-- dcr_regs contain the PLB control registers with a DCR interface. If the design
-- is parameterized not to include a DCR interface, set the DCR ACK to zero and
-- pass the DCR data bus through.
DCR_GEN: if C_DCR_INTFCE = 1 generate
    I_DCR: entity plb_v46_v1_05_a.dcr_regs
      generic map ( C_NUM_MASTERS   => C_NUM_MASTERS,
                    C_PLB_AWIDTH    => C_PLB_AWIDTH,
                    C_PLB_DWIDTH    => C_PLB_DWIDTH,
                    C_DCR_AWIDTH    => C_DCR_AWIDTH,
                    C_DCR_DWIDTH    => C_DCR_DWIDTH,
                    C_BASEADDR      => C_BASEADDR,
                    C_HIGHADDR      => C_HIGHADDR
                  )
      port map (
                Clk                 => Clk,
                ArbReset            => arbreset_i,
                DCR_Write           => DCR_Write,
                DCR_Read            => DCR_Read,
                DCR_ABus            => DCR_ABus,
                DCR_DBus            => DCR_DBus,
                PLB_dcrAck          => PLB_dcrAck,
                PLB_dcrDBus         => PLB_dcrDBus,
                WdtMTimeout_n       => wdtMTimeout_n_i,
                ArbAddrSelReg       => arbaddrselreg_i,
                PLB_RNW             => plb_rnw_i,
                PLB_ABus            => PLB_ABus,
                PLB_UABus           => PLB_UABus,
                PLB_BE              => PLB_BE,
                PLB_size            => PLB_size,
                PLB_type            => PLB_type,
                M_lockErr           => M_lockErr,
                Intr_en             => intr_en,
                SW_Rst              => sw_rst
                );
                
end generate DCR_GEN ;


NO_DCR_GEN: if C_DCR_INTFCE = 0 generate
    PLB_dcrAck  <= '0';
    PLB_dcrDBus <= DCR_DBus;
    sw_rst      <= '0';
    intr_en     <= '1';
end generate  NO_DCR_GEN;

PLB_INTR_I: entity plb_v46_v1_05_a.plb_interrupt
    generic map ( C_IRQ_ACTIVE => C_IRQ_ACTIVE)
  port map (
        Clk             =>  Clk,
        Rst             =>  arbreset_i,
        WdtMTimeout_n   =>  wdtMTimeout_n_i,
        Intr_en         =>  intr_en,
        Bus_Error_Det   =>  Bus_Error_Det
        );


end implementation;

