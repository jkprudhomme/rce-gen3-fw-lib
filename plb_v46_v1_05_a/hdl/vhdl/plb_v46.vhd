-------------------------------------------------------------------------------
--  $Id: plb_v46.vhd,v 1.1.2.1 2010/07/13 16:33:57 srid Exp $
-------------------------------------------------------------------------------
-- plb_v46.vhd - entity/architecture pair
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
-- Filename:        plb_v46.vhd
-- Version:         v1.04a
-- Description:     This file is the top-level VHDL file for the Xilinx PLB
--                  arbiter. It instantiates the necessary components to 
--                  build the Xilinx PLB Arbiter Design.
-- 
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   
--          plb_v46.vhd
--              --  plb_p2p.vhd
--              --  plb_addrpath.vhd
--                  --  mux_onehot_f.vhd
--              --  plb_rd_datapath.vhd
--              --  plb_wr_datapath.vhd
--                  --  mux_onehot_f.vhd
--              --  plb_slave_ors.vhd
--              --  plb_arbiter_logic.vhd
--                  --  muxed_signals.vhd
--                      --  mux_onehot_f.vhd
--                      --  or_bits.vhd
--
--                  --  arb_control_sm.vhd (includes bus_lock_sm, arb_registers)
--                  --  plb_arb_encoder.vhd
--                      --  priority_encoder.vhd
--                          --  qual_request.vhd
--                      --  rr_select.vhd
--                      --  mux_onehot_f.vhd
--                      --  pend_request.vhd
--                      --  pending_priority.vhd
--                          --  qual_priority.vhd
--
--                  --  gen_qual_req.vhd
--                  --  watchdog_timer.vhd
--                      --  down_counter.vhd
--
--                  --  dcr_regs.vhd
--                  --  plb_interrupt.vhd
--
-------------------------------------------------------------------------------
-- Author:      ALS
-- History:
--  ALS         02/20/02        -- First version, created from plb_arbiter_v1_01_a 
--  ALS         02/22/02        
-- ^^^^^^
-- Added library declaration for max2 and log2 functions in port declaration of
-- PLB_MasterID. Changed Clk and Rst to PLB_Clk and PLB_Rst.
-- ~~~~~~
--  ALS         02/26/02
--  Added generic C_MID_WIDTH so that the max2 and log2 functions are no longer
--  required in the port declaration of PLB_masterID. This generic will be 
--  calculated by the GUI. Also added a power-up reset function. PLB_Rst is now
--  an output, changed ArbReset from an output to an input named SYS_Rst.
-- ^^^^^^
--  ALS         04/16/02        -- Version v1.01a
-- ^^^^^^
--  Changed generics C_MID_WIDTH, C_NUM_MASTERS, C_NUM_SLAVES to C_PLB_MID_WIDTH,
--  C_PLB_NUM_MASTERS, and C_PLB_NUM_SLAVES. Added max fan-out synthesis 
--  directives.
-- ^^^^^^
-- ^^^^^^
--  MLL         02/20/04        -- Version v1.01a
-- ^^^^^^
--  Fix to make compatible with OPB IPIF architecture. In arb_control_sm.vhd,
--  added counter to block clearing of mask in arbitration if plb2opb bridge
--  asserts rearbitrate on a read operation. This required adding
--  C_NUM_OPBCLK_PLB2OPB_REARB generic and PLB2OPB_rearb vector signal at this
--  level and passed down to arb_control_sm.vhd. Also rev'd to v1.02a.
--  asserted the rearbitration signal. Multiple plb2opb bridge were to be
--  supported with the parameter C_NUM_PLB2OPB_BRIDGE, but it was found that
--  edk support was not what was described to be and what was used in the design,
--  so a workaround was implemented to accomodate the real EDK device index
--  scheme. This plb v34 logic module is compatible with only plb2opb_bridge_v1_01_a.
-- ^^^^^^
--  FLO         05/26/05        -- plb_v46_v1_00_a derived from plb_v34_v1_02_a
-- ^^^^^^
--  FLO         06/01/05        
-- ^^^^^^
-- Start of changes for plb_v46.
-- -PLB_MErr split into PLB_MRdErr and PLB_MWrErr (Rd and Wr versions).
-- -Sl_MErr split into Sl_MRdErr and Sl_MWrErr.
-- -PLB_SMErr split into PLB_SMRdErr and PLB_SMWrErr.
-- -Removed component declarations in favor of direct entity instantiation.
-- ~~~~~~
--  FLO         06/03/05        
-- ^^^^^^
-- -PLB_pendPri split into PLB_rdPendPri and PLB_wrPendPri (Rd and Wr versions).
-- -PLB_pendReq split into PLB_rdPendReq and PLB_wrPendReq (Rd and Wr versions).
-- ~~~~~~
--  FLO         06/08/05        
-- ^^^^^^
-- -Eliminated aspects related to the watchdog timer completing hanshakes on
--  timeout.
-- -Added port PLB_MTimeout.
-- ~~~~~~
--  FLO         06/09/05        
-- ^^^^^^
-- -Added ports M_TAttribute and PLB_TAttribute and removed these signals
--  that are subsumed by 'TAttribure':   M_compress,   M_guarded,   M_ordered,
--                                     PLB_compress, PLB_guarded, PLB_ordered
-- -Added 'component' keyword to unisim instantiations (e.g. SRL16).
-- ~~~~~~
--  FLO         06/09/05        
-- ^^^^^^
-- -Implemented ports and functionality for new signals Sl_MIRQ and PLB_MIRQ.
-- ~~~~~~
--  FLO         06/15/05        
-- ^^^^^^
-- -Default value for generic C_DCR_INTFCE changed to 0.
-- ~~~~~~
--  FLO         06/16/05        
-- ^^^^^^
-- -Changed generic name: C_NUM_OPBCLK_PLB2OPB_REARB -> C_NUM_CLK_PLB2OPB_REARB
-- -Added generic C_FAMILY
-- ~~~~~~
--  FLO         07/19/05        
-- ^^^^^^
-- -Changed to active low WdtMTimeout_n
-- ~~~~~~
--  FLO         08/18/05        
-- ^^^^^^
-- -Changed default for generic C_PLB_AWIDTH from 32 to 36.
-- ~~~~~~
--  FLO         08/24/05        
-- ^^^^^^
-- -Put in switch to enable or disable 1-master optimization.
-- ~~~~~~
--  FLO         09/01/05        
-- ^^^^^^
-- -To consolidate state information for optimization evaluations,
--  arb_registers and bus_lock_sm incorporated locally in arb_control_sm,
--  which is reflected in a change to the structure-section comments.
-- ~~~~~~
--  FLO         09/03/05        
-- ^^^^^^
-- -Ignore--force to zero--M_busLock for the 1-master case.
--  then backed this out because it leads to plb bus monitor error msgs
-- ~~~~~~
--  FLO         09/09/05        
-- ^^^^^^
-- -Added UABus.
-- -Vectorized PLB_rdPrim and PLB_wrPrim to the number of slaves.
-- -Added generic C_ADDR_PIPELINING_TYPE with values 0:no addr pipelining
--  and 1:2-level addr pipelining.
-- -Changed top-level generics starting with C_PLB_ to C_PLBV46_
-- -Request-to-PAValid 1-cycle (when 1 master) and 2-cycle latencies supported.
-- -Fixed timeout handling.
-- ~~~~~~
--  FLO         11/21/05        
-- ^^^^^^
-- -Changed default for generic C_PLBV46_AWIDTH from 36 to 32.
-- ~~~~~~
--  FLO         11/24/05        
-- ^^^^^^
-- -Changed UABus to be (0 to 31), but with only the rightmost
--  C_PLBV46_AWIDTH-32 bits, if any, actually being used.
-- -Removed the ArbAddrVldReg output port.
-- ~~~~~~
--  FLO         12/02/05        
-- ^^^^^^
-- -Passing C_FAMILY to lower-level components that instantiate mux_onehot_f.
-- -Changed default C_PLBV46_AWIDTH and C_PLBV46_DWIDTH to 32 and 64,
--  respecively (were 36 and 128).
--  ~~~~~
--
--  DET         08/15/06        
-- ^^^^^^
--  - Added the missing generic C_PLB_DWIDTH and associated assignment to 
--    the arbiter logic instance.
--  ~~~~~
--  JLJ         04/10/07
-- ^^^^^^
--   Added new reset signals: SPLB_Rst and MPLB_Rst to reduce overall fanout
--   on reset signals.
--   Added registered output stage on PLB address qualifier signals to improve
--   timing paths.
--  ~~~~~
--  JLJ         06/07/07    
-- ^^^^^^
--  Fix Questa 6.3 load bug evaluating UABus as [0:-1]. Update port mapping 
--  allowable size values => always assume UABus = 32-bits wide.
-- ~~~~~
--  JLJ         07/17/07    v1.00a   
-- ^^^^^^
--  CR 442962. Change default setting of C_ADDR_PIPELINING_TYPE to be 1.  
-- ~~~~~
--  JLJ         09/14/07    v1.01a  
-- ^^^^^^
--  Update to v1.01a.
--  Added new parameter, C_ARB_TYPE with allowable values FIXED and ROUND_ROBIN.
--  Added support for round robin arbitration which is utilized regardless
--  of each request master priority level setting.  Useful in systems where FIXED
--  priority doesn't allow enough bus bandwidth to all requesting master devices.
-- ~~~~~~
--  JLJ         10/09/07    v1.02a  
-- ^^^^^^
--  Update to v1.02a.
--  Added C_ADDR_PIPELINING_TYPE parameter use in P2P module.
-- ~~~~~~
--  JLJ         10/31/07    v1.02a  
-- ^^^^^^
--  Remove M_abort input signal on plb_arbiter_logic module.
-- ~~~~~~
--  JLJ         11/07/07    v1.02a  
-- ^^^^^^
--  Remove C_NUM_CLK_PLB2OPB_REARB from top level port listing.
--  Remove input signal, PLB2OPB_rearb and set to constant value internally.
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
--  Removed all change log text into seperate HTML file.
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
-- 
-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Generics:
--          C_PLBV46_NUM_MASTERS   -- number of masters on the PLB
--          C_PLBV46_NUM_SLAVES    -- number of slaves on the PLB
--          C_PLBV46_MID_WIDTH     -- number of bits to encode the number of masters
--          C_PLBV46_AWIDTH        -- PLB address bus width
--          C_PLBV46_DWIDTH        -- PLB data bus width
--          C_DCR_INTFCE        -- include DCR interface
--          C_BASEADDR          -- DCR base address
--          C_HIGHADDR          -- DCR high address
--          C_DCR_AWIDTH        -- DCR address bus width
--          C_DCR_DWIDTH        -- DCR data bus width
--          C_EXT_RESET_HIGH    -- external reset is active high
--          C_IRQ_ACTIVE        -- active interrupt edge (rising or falling)
--          C_FAMILY            -- target FPGA family
--
-- Definition of Ports:
--
--      -- DCR signals
--          input DCR_ABus     
--          input DCR_Read          
--          input DCR_Write 
--          input DCR_DBus
--          output PLB_dcrAck 
--          output PLB_dcrDBus
--  
--      -- Master signals
--          input M_ABus            
--          input M_BE              
--          input M_RNW             
--          input M_abort           
--          input M_busLock         
--          input M_TAttribute        
--          input M_lockErr         
--          input M_MSize           
--          input M_priority        
--          input M_rdBurst         
--          input M_request         
--          input M_size            
--          input M_type            
--          input M_wrBurst         
--          input M_wrDBus          
--  
--      -- PLB signals
--          output PLB_ABus             
--          output PLB_BE           
--          output PLB_MAddrAck         
--          output PLB_MTimeout
--          output PLB_MBusy        
--          output PLB_MRdErr             
--          output PLB_MWrErr             
--          output PLB_MRdBTerm         
--          output PLB_MRdDAck      
--          output PLB_MRdDBus      
--          output PLB_MRdWdAddr    
--          output PLB_MRearbitrate 
--          output PLB_MWrBTerm         
--          output PLB_MWrDAck      
--          output PLB_MSSize           
--          output PLB_PAValid      
--          output PLB_RNW          
--          output PLB_SAValid      
--          output PLB_abort        
--          output PLB_busLock      
--          output PLB_TAttribute         
--          output PLB_lockErr      
--          output PLB_masterID         
--          output PLB_MSize        
--          output PLB_rdPendPri      
--          output PLB_wrPendPri      
--          output PLB_rdPendReq      
--          output PLB_wrPendReq      
--          output PLB_rdBurst      
--          output PLB_rdPrim       
--          output PLB_reqPri       
--          output PLB_size             
--          output PLB_type             
--          output PLB_wrBurst      
--          output PLB_wrDBus       
--          output PLB_wrPrim       
--  
--      -- Slave signals
--          input Sl_MBusy          
--          input Sl_MRdErr           
--          input Sl_MWrErr           
--          input Sl_addrAck        
--          input Sl_rdBTerm        
--          input Sl_rdComp         
--          input Sl_rdDAck         
--          input Sl_rdDBus         
--          input Sl_rdWdAddr       
--          input Sl_rearbitrate    
--          input Sl_SSize          
--          input Sl_wait           
--          input Sl_wrBTerm        
--          input Sl_wrComp         
--          input Sl_wrDAck        
--
--      -- Output from Slave OR gates
--          output PLB_SaddrAck     
--          output PLB_SRdMErr        
--          output PLB_SWrMErr        
--          output PLB_SMBusy       
--          output PLB_SrdBTerm     
--          output PLB_SrdComp      
--          output PLB_SrdDAck      
--          output PLB_SrdDBus      
--          output PLB_SrdWdAddr    
--          output PLB_Srearbitrate 
--          output PLB_Sssize       
--          output PLB_Swait        
--          output PLB_SwrBTerm     
--          output PLB_SwrComp      
--          output PLB_SwrDAck      
--
--      -- Clock, Interrupt, and Resets
--          input PLB_Clk
--          input SYS_Rst
--          output Bus_Error_Det
--          output PLB_Rst
--          output SPLB_Rst
--          output MPLB_Rst
--
-------------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;

library plb_v46_v1_05_a;

library unisim;
use unisim.vcomponents.SRL16;
use unisim.vcomponents.FDS;

-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------
entity plb_v46 is
    generic (
             C_PLBV46_NUM_MASTERS   : integer := 4;  
             C_PLBV46_NUM_SLAVES    : integer := 8;
             C_PLBV46_MID_WIDTH     : integer := 2;
             C_PLBV46_AWIDTH        : integer := 32;
             C_PLBV46_DWIDTH        : integer := 64; 
             C_DCR_INTFCE           : integer := 0;
             C_BASEADDR             : std_logic_vector := "1111111111"; 
             C_HIGHADDR             : std_logic_vector := "0000000000";
             C_DCR_AWIDTH           : integer := 10;
             C_DCR_DWIDTH           : integer := 32;        -- Must be 32
             C_EXT_RESET_HIGH       : integer   := 1;
             C_IRQ_ACTIVE           : std_logic := '1';
             C_ADDR_PIPELINING_TYPE : integer := 1;         -- 0:none, 1:2-level
             C_FAMILY               : string := "virtex5";
             C_P2P                  : integer   := 0;       -- 0 = shared bus mode, 1 = point to point mode (1M + 1S)
             C_ARB_TYPE             : integer   := 0        -- 0: fixed, 1: round-robin
             );
    port (
          DCR_ABus          : in std_logic_vector(0 to C_DCR_AWIDTH - 1 );
          DCR_DBus          : in std_logic_vector(0 to C_DCR_DWIDTH - 1 );
          DCR_Read          : in std_logic;
          DCR_Write         : in std_logic;
          PLB_dcrAck        : out std_logic;
          PLB_dcrDBus       : out std_logic_vector(0 to C_DCR_DWIDTH - 1 );
          M_ABus            : in std_logic_vector(0 to (C_PLBV46_NUM_MASTERS * 32) - 1 );
          M_UABus           : in std_logic_vector(0 to (C_PLBV46_NUM_MASTERS * 32) - 1 );
          M_BE              : in std_logic_vector(0 to (C_PLBV46_NUM_MASTERS * (C_PLBV46_DWIDTH / 8)) - 1 );
          M_RNW             : in std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          M_abort           : in std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          M_busLock         : in std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          M_TAttribute      : in std_logic_vector(0 to C_PLBV46_NUM_MASTERS * 16 - 1 );
          M_lockErr         : in std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          M_MSize           : in std_logic_vector(0 to (C_PLBV46_NUM_MASTERS * 2) - 1 );
          M_priority        : in std_logic_vector(0 to (C_PLBV46_NUM_MASTERS * 2) - 1 );
          M_rdBurst         : in std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          M_request         : in std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          M_size            : in std_logic_vector(0 to (C_PLBV46_NUM_MASTERS * 4) - 1 );
          M_type            : in std_logic_vector(0 to (C_PLBV46_NUM_MASTERS * 3) - 1 );
          M_wrBurst         : in std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          M_wrDBus          : in std_logic_vector(0 to (C_PLBV46_NUM_MASTERS * C_PLBV46_DWIDTH) - 1 );
          PLB_ABus          : out std_logic_vector(0 to 31 );
          PLB_UABus         : out std_logic_vector(0 to 31 );
          PLB_BE            : out std_logic_vector(0 to (C_PLBV46_DWIDTH / 8) - 1 );
          PLB_MAddrAck      : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          PLB_MTimeout      : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          PLB_MBusy         : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          PLB_MRdErr        : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          PLB_MWrErr        : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          PLB_MRdBTerm      : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          PLB_MRdDAck       : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          PLB_MRdDBus       : out std_logic_vector(0 to (C_PLBV46_NUM_MASTERS*C_PLBV46_DWIDTH)-1);
          PLB_MRdWdAddr     : out std_logic_vector(0 to (C_PLBV46_NUM_MASTERS * 4) - 1 );
          PLB_MRearbitrate  : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          PLB_MWrBTerm      : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          PLB_MWrDAck       : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
          PLB_MSSize        : out std_logic_vector(0 to (C_PLBV46_NUM_MASTERS * 2) - 1 );
          PLB_PAValid       : out std_logic;
          PLB_RNW           : out std_logic;
          PLB_SAValid       : out std_logic;
          PLB_abort         : out std_logic;
          PLB_busLock       : out std_logic;
          PLB_TAttribute    : out std_logic_vector(0 to 15 );
          PLB_lockErr       : out std_logic;
          PLB_masterID      : out std_logic_vector(0 to C_PLBV46_MID_WIDTH-1);
          PLB_MSize         : out std_logic_vector(0 to 1 );
          PLB_rdPendPri     : out std_logic_vector(0 to 1 );
          PLB_wrPendPri     : out std_logic_vector(0 to 1 );
          PLB_rdPendReq     : out std_logic;
          PLB_wrPendReq     : out std_logic;
          PLB_rdBurst       : out std_logic;
          PLB_rdPrim        : out std_logic_vector(0 to C_PLBV46_NUM_SLAVES - 1 );
          PLB_reqPri        : out std_logic_vector(0 to 1 );
          PLB_size          : out std_logic_vector(0 to 3 );
          PLB_type          : out std_logic_vector(0 to 2 );
          PLB_wrBurst       : out std_logic;
          PLB_wrDBus        : out std_logic_vector(0 to C_PLBV46_DWIDTH - 1 );
          PLB_wrPrim        : out std_logic_vector(0 to C_PLBV46_NUM_SLAVES - 1 );
          
          Sl_addrAck        : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES - 1 );
          Sl_MRdErr         : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES*C_PLBV46_NUM_MASTERS - 1 );
          Sl_MWrErr         : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES*C_PLBV46_NUM_MASTERS - 1 );
          Sl_MBusy          : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES*C_PLBV46_NUM_MASTERS - 1 );
          Sl_rdBTerm        : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES - 1);
          Sl_rdComp         : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES - 1);
          Sl_rdDAck         : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES - 1);
          Sl_rdDBus         : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES*C_PLBV46_DWIDTH - 1 );
          Sl_rdWdAddr       : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES*4 - 1 );
          Sl_rearbitrate    : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES - 1 );
          Sl_SSize          : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES*2 - 1 );
          Sl_wait           : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES - 1 );
          Sl_wrBTerm        : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES - 1 );
          Sl_wrComp         : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES - 1 );
          Sl_wrDAck         : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES - 1 );

          Sl_MIRQ           : in std_logic_vector(0 to C_PLBV46_NUM_SLAVES*C_PLBV46_NUM_MASTERS - 1 );
          PLB_MIRQ          : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS-1);   

          -- Outputs of Slave OR gates are only used in simulation to connect
          -- to the IBM PLB Monitor
          PLB_SaddrAck      : out std_logic;
          PLB_SMRdErr       : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS-1);   
          PLB_SMWrErr       : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS-1);   
          PLB_SMBusy        : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS-1);   
          PLB_SrdBTerm      : out std_logic;   
          PLB_SrdComp       : out std_logic;
          PLB_SrdDAck       : out std_logic;
          PLB_SrdDBus       : out std_logic_vector(0 to C_PLBV46_DWIDTH-1);   
          PLB_SrdWdAddr     : out std_logic_vector(0 to 3);
          PLB_Srearbitrate  : out std_logic;
          PLB_Sssize        : out std_logic_vector(0 to 1);
          PLB_Swait         : out std_logic;
          PLB_SwrBTerm      : out std_logic;
          PLB_SwrComp       : out std_logic;
          PLB_SwrDAck       : out std_logic;
          
          SYS_Rst           : in std_logic;
          Bus_Error_Det     : out std_logic;
          PLB_Rst           : out std_logic;
          SPLB_Rst          : out std_logic_vector(0 to C_PLBV46_NUM_SLAVES-1);
          MPLB_Rst          : out std_logic_vector(0 to C_PLBV46_NUM_MASTERS-1);
          PLB_Clk           : in std_logic
          );
 
    -- fan-out attributes for Synplicity
    attribute syn_maxfan                  : integer;
    attribute syn_maxfan   of PLB_Clk     : signal is 10000;
    attribute syn_maxfan   of PLB_Rst     : signal is 10000;
    attribute syn_maxfan   of SPLB_Rst    : signal is 10000;
    attribute syn_maxfan   of MPLB_Rst    : signal is 10000;
    
    --fan-out attributes for XST
    attribute MAX_FANOUT                  : string;
    attribute MAX_FANOUT   of PLB_Clk     : signal is "10000";
    attribute MAX_FANOUT   of PLB_Rst     : signal is "10000";
    attribute MAX_FANOUT   of SPLB_Rst    : signal is "10000";
    attribute MAX_FANOUT   of MPLB_Rst    : signal is "10000";
 
end plb_v46;
 
-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture simulation of plb_v46 is

-----------------------------------------------------------------------------
-- Constant Declarations
-----------------------------------------------------------------------------
constant C_OPTIMIZE_1M : boolean := true; -- Optimize for one master case


-----------------------------------------------------------------------------
-- Signal Declarations
-----------------------------------------------------------------------------
-- internal arbiter registers
signal arbAddrSelReg        : std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
signal arbBurstReq          : std_logic;
signal arbPriRdMasterRegReg : std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );
signal arbPriWrMasterReg    : std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );

--   internal versions of output signals
signal plb_abus_i           : std_logic_vector(0 to 31 );
signal plb_uabus_i          : std_logic_vector(0 to 31 );
signal plb_be_i             : std_logic_vector(0 to C_PLBV46_DWIDTH/8-1);
signal plb_size_i           : std_logic_vector(0 to 3 );
signal plb_type_i           : std_logic_vector(0 to 2);
signal plb_rst_i            : std_logic;
signal splb_rst_i           : std_logic_vector(0 to C_PLBV46_NUM_SLAVES-1);
signal mplb_rst_i           : std_logic_vector(0 to C_PLBV46_NUM_MASTERS-1);

signal plb_saddrack_i       : std_logic;   
signal plb_smrderr_i        : std_logic_vector(0 to C_PLBV46_NUM_MASTERS-1);
signal plb_smwrerr_i        : std_logic_vector(0 to C_PLBV46_NUM_MASTERS-1);
signal plb_smbusy_i         : std_logic_vector(0 to C_PLBV46_NUM_MASTERS-1);
signal plb_srdbterm_i       : std_logic;   
signal plb_srdcomp_i        : std_logic;
signal plb_srddack_i        : std_logic;
signal plb_srddbus_i        : std_logic_vector(0 to C_PLBV46_DWIDTH-1); 
signal plb_srdwdaddr_i      : std_logic_vector(0 to 3);
signal plb_srearbitrate_i   : std_logic;
signal plb_sssize_i         : std_logic_vector(0 to 1);
signal plb_swait_i          : std_logic;
signal plb_swrbterm_i       : std_logic;
signal plb_swrcomp_i        : std_logic;
signal plb_swrdack_i        : std_logic;

-- Power-on reset signals and attributes
signal srl_time_out         : std_logic; 
signal ext_rst_i            : std_logic; 
signal por_FF_out           : std_logic; 

signal wdtMTimeout_n        : std_logic;
signal m_buslock_qual       : std_logic_vector(0 to C_PLBV46_NUM_MASTERS - 1 );

-----------------------------------------------------------------------------
-- Component Declarations
-----------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin

--coverage off
  assert C_DCR_DWIDTH = 32
  report "C_DCR_DWIDTH is not 32, as required."
  severity failure;
--coverage on

--  M_busLock ignored if only one master
M_BUSLOCK_QUAL_GEN : for i in 0 to C_PLBV46_NUM_MASTERS-1 generate
    m_buslock_qual(i) <= '1' when M_busLock(i) = '1' else '0';
end generate;

--  Assign output signals to the internal signals
PLB_ABus    <= plb_abus_i;
PLB_UABus   <= plb_uabus_i;
PLB_BE      <= plb_be_i;
PLB_size    <= plb_size_i;
PLB_type    <= plb_type_i;
PLB_Rst     <= plb_rst_i;
SPLB_Rst    <= splb_rst_i;
MPLB_Rst    <= mplb_rst_i;

-- Set default signals
-- Abort is not supported, drive to '0'
PLB_abort <= '0';

-- Outputs of Slave OR gates are only used in simulation to connect to the
-- IBM PLB Monitor
PLB_SaddrAck        <= plb_saddrack_i;    
PLB_SMRdErr         <= plb_smrderr_i;       
PLB_SMWrErr         <= plb_smwrerr_i;       
PLB_SMBusy          <= plb_smbusy_i;      
PLB_SrdBTerm        <= plb_srdbterm_i;    
PLB_SrdComp         <= plb_srdcomp_i;     
PLB_SrdDAck         <= plb_srddack_i;     
PLB_SrdDBus         <= plb_srddbus_i;     
PLB_SrdWdAddr       <= plb_srdwdaddr_i;   
PLB_Srearbitrate    <= plb_srearbitrate_i;
PLB_Sssize          <= plb_sssize_i;      
PLB_Swait           <= plb_swait_i;       
PLB_SwrBTerm        <= plb_swrbterm_i;    
PLB_SwrComp         <= plb_swrcomp_i;     
PLB_SwrDAck         <= plb_swrdack_i;             

-----------------------------------------------------------------------------
-- Reset Process
-----------------------------------------------------------------------------
PLB_RST_PROCESS: process (SYS_Rst) is 
begin 
    if C_EXT_RESET_HIGH = 0 then 
        ext_rst_i <= not(SYS_Rst); 
    else 
        ext_rst_i <= SYS_Rst; 
    end if; 
end process PLB_RST_PROCESS; 

I_PLB_RST: component FDS 
port map ( 
    Q   => plb_rst_i, 
    D   => ext_rst_i, 
    C   => PLB_Clk, 
    S   => '0'
    ); 
  
-- Create additional Slave Reset vector outputs
GEN_SPLB_RST: for i in 0 to C_PLBV46_NUM_SLAVES-1 generate
begin
    I_SPLB_RST: component FDS 
    port map 
    ( 
        Q   => splb_rst_i(i), 
        D   => ext_rst_i, 
        C   => PLB_Clk, 
        S   => '0'
        ); 
end generate GEN_SPLB_RST;  
    
-- Create additional Master Reset vector outputs
GEN_MPLB_RST: for i in 0 to C_PLBV46_NUM_MASTERS-1 generate
begin
    I_MPLB_RST: component FDS 
    port map 
    ( 
        Q   => mplb_rst_i(i), 
        D   => ext_rst_i, 
        C   => PLB_Clk, 
        S   => '0'
        ); 
end generate GEN_MPLB_RST;

 
-----------------------------------------------------------------------------
-- Component Instantiations
-----------------------------------------------------------------------------
-- Create generate statement to determine if bus is configured in a P2P mode
GEN_P2P: if (C_P2P = 1) generate
begin

    -- Instantiate stand alone block that creates wired connection
    -- for Master to Slave signals in P2P mode
    -- Module: plb_p2p includes an address phase timeout counter
    -- and does not include any arbitration logic for optimized instantiation of PLB
    I_PLB_P2P: entity plb_v46_v1_05_a.plb_p2p
    generic map (
        C_NUM_MASTERS  => C_PLBV46_NUM_MASTERS,
        C_NUM_SLAVES   => C_PLBV46_NUM_SLAVES,
        C_MID_BITS     => C_PLBV46_MID_WIDTH,
        C_PLB_AWIDTH   => C_PLBV46_AWIDTH,
        C_PLB_DWIDTH   => C_PLBV46_DWIDTH,
        C_FAMILY       => C_FAMILY,
        C_ADDR_PIPELINING_TYPE => C_ADDR_PIPELINING_TYPE
        )
    port map (
        Clk               => PLB_Clk,
        Rst               => plb_rst_i,

        -- Master inputs to PLB
        M_ABus            => M_ABus,
        M_UABus           => M_UABus,
        M_BE              => M_BE,
        M_RNW             => M_RNW,
        M_TAttribute      => M_TAttribute,
        M_lockErr         => M_lockErr,
        M_MSize           => M_MSize,
        M_priority        => M_priority,      -- Unused in P2P mode
        M_rdBurst         => M_rdBurst,
        M_request         => M_request,
        M_size            => M_size,
        M_type            => M_type,
        M_wrBurst         => M_wrBurst,
        M_wrDBus          => M_wrDBus,

        -- PLB outputs to Master
        PLB_MAddrAck      => PLB_MAddrAck,
        PLB_MTimeout      => PLB_MTimeout,
        PLB_MBusy         => PLB_MBusy,
        PLB_MRdErr        => PLB_MRdErr,
        PLB_MWrErr        => PLB_MWrErr,
        PLB_MRdBTerm      => PLB_MRdBTerm,
        PLB_MRdDAck       => PLB_MRdDAck,
        PLB_MRdDBus       => PLB_MRdDBus,
        PLB_MRdWdAddr     => PLB_MRdWdAddr,
        PLB_MRearbitrate  => PLB_MRearbitrate,
        PLB_MWrBTerm      => PLB_MWrBTerm,
        PLB_MWrDAck       => PLB_MWrDAck,
        PLB_MSSize        => PLB_MSSize,
        PLB_MIRQ          => PLB_MIRQ,

        -- PLB outputs to Slave
        PLB_ABus          => plb_abus_i,
        PLB_UABus         => plb_uabus_i,
        PLB_BE            => plb_be_i,
        PLB_PAValid       => PLB_PAValid,
        PLB_SAValid       => PLB_SAValid,
        PLB_RNW           => PLB_RNW,
        PLB_busLock       => PLB_busLock,
        PLB_TAttribute    => PLB_TAttribute,
        PLB_lockErr       => PLB_lockErr,
        PLB_masterID      => PLB_masterID,
        PLB_MSize         => PLB_MSize,
        PLB_rdPendPri     => PLB_rdPendPri,
        PLB_wrPendPri     => PLB_wrPendPri,
        PLB_rdPendReq     => PLB_rdPendReq,
        PLB_wrPendReq     => PLB_wrPendReq,
        PLB_rdBurst       => PLB_rdBurst,
        PLB_rdPrim        => PLB_rdPrim,
        PLB_reqPri        => PLB_reqPri,
        PLB_size          => plb_size_i,
        PLB_type          => plb_type_i,
        PLB_wrBurst       => PLB_wrBurst,
        PLB_wrDBus        => PLB_wrDBus,
        PLB_wrPrim        => PLB_wrPrim,

        -- Slave inputs to PLB
        Sl_addrAck          => Sl_addrAck,     
        Sl_MRdErr           => Sl_MRdErr,        
        Sl_MWrErr           => Sl_MWrErr,        
        Sl_MBusy            => Sl_MBusy,        
        Sl_rdBTerm          => Sl_rdBTerm,     
        Sl_rdComp           => Sl_rdComp,      
        Sl_rdDAck           => Sl_rdDAck,       
        Sl_rdDBus           => Sl_rdDBus,      
        Sl_rdWdAddr         => Sl_rdWdAddr,    
        Sl_rearbitrate      => Sl_rearbitrate, 
        Sl_SSize            => Sl_SSize,       
        Sl_wait             => Sl_wait,         
        Sl_wrBTerm          => Sl_wrBTerm,     
        Sl_wrComp           => Sl_wrComp,      
        Sl_wrDAck           => Sl_wrDAck,       
        Sl_MIRQ             => Sl_MIRQ,

        -- Outputs of Slave signals that are only used in simulation 
        -- to connect to the IBM PLB Monitor
        PLB_SaddrAck        => plb_saddrack_i,    
        PLB_SMRderr         => plb_smrderr_i,       
        PLB_SMWrerr         => plb_smwrerr_i,       
        PLB_SMBusy          => plb_smbusy_i,      
        PLB_SrdBTerm        => plb_srdbterm_i,    
        PLB_SrdComp         => plb_srdcomp_i,     
        PLB_SrdDAck         => plb_srddack_i,     
        PLB_SrdDBus         => plb_srddbus_i,     
        PLB_SrdWdAddr       => plb_srdwdaddr_i,   
        PLB_Srearbitrate    => plb_srearbitrate_i,
        PLB_Sssize          => plb_sssize_i,      
        PLB_Swait           => plb_swait_i,       
        PLB_SwrBTerm        => plb_swrbterm_i,    
        PLB_SwrComp         => plb_swrcomp_i,     
        PLB_SwrDAck         => plb_swrdack_i
    
    );


end generate GEN_P2P;
 
 
-- Create generate statement to determine if bus is configured in a shared mode
GEN_SHARED: if (C_P2P = 0) generate
begin

    --   Instantiate the Address path multiplexors
    I_PLB_ADDRPATH: entity plb_v46_v1_05_a.plb_addrpath
        generic map (C_NUM_MASTERS  => C_PLBV46_NUM_MASTERS,
                     C_PLB_AWIDTH   => C_PLBV46_AWIDTH,
                     C_PLB_DWIDTH   => C_PLBV46_DWIDTH,
                     C_FAMILY       => C_FAMILY)
        port map (
                  Clk               => PLB_Clk,
                  Rst               => plb_rst_i,
                  M_TAttribute      => M_TAttribute,
                  M_lockErr         => M_lockErr,
                  ArbAddrSelReg     => arbAddrSelReg,
                  M_ABus            => M_ABus,
                  M_UABus           => M_UABus,
                  M_BE              => M_BE,
                  M_size            => M_size,
                  M_type            => M_type,
                  M_MSize           => M_MSize,
                  PLB_TAttribute    => PLB_TAttribute,
                  PLB_lockErr       => PLB_lockErr,
                  ArbBurstReq       => arbBurstReq,
                  PLB_ABus          => plb_abus_i,
                  PLB_UABus         => plb_uabus_i,
                  PLB_BE            => plb_be_i,
                  PLB_size          => plb_size_i,
                  PLB_type          => plb_type_i,
                  PLB_MSize         => PLB_MSize);

    --   Instantiate the Write databus multiplexors
    I_PLB_WR_DATAPATH: entity plb_v46_v1_05_a.plb_wr_datapath
        generic map (C_NUM_MASTERS  => C_PLBV46_NUM_MASTERS,
                     C_PLB_DWIDTH   => C_PLBV46_DWIDTH,
                     C_FAMILY       => C_FAMILY)
        port map (
                  Sl_wrDAck         => plb_swrdack_i,
                  ArbPriWrMasterReg => arbPriWrMasterReg,
                  M_wrDBus          => M_wrDBus,
                  PLB_MWrDAck       => PLB_MWrDAck,
                  PLB_wrDBus        => PLB_wrDBus);

    --   Instantiate the Read databus multiplexors
    I_PLB_RD_DATAPATH: entity plb_v46_v1_05_a.plb_rd_datapath
        generic map (C_NUM_MASTERS  => C_PLBV46_NUM_MASTERS,
                     C_PLB_DWIDTH   => C_PLBV46_DWIDTH)
        port map (
                  Sl_rdDAck         => plb_srddack_i,
                  ArbPriRdMasterRegReg => arbPriRdMasterRegReg,
                  Sl_rdWdAddr       => plb_srdwdaddr_i,
                  PLB_MRdDAck       => PLB_MRdDAck,
                  PLB_MRdDBus       => PLB_MRdDBus,
                  PLB_MRdWdAddr     => PLB_MRdWdAddr,
                  Sl_rdDBus         => plb_srddbus_i);

    --   Instantiate the Slave OR gates
    I_PLB_SLAVE_ORS: entity plb_v46_v1_05_a.plb_slave_ors 
      generic map(  C_NUM_MASTERS   => C_PLBV46_NUM_MASTERS,
                    C_NUM_SLAVES    => C_PLBV46_NUM_SLAVES,
                    C_PLB_DWIDTH    => C_PLBV46_DWIDTH,
                    C_FAMILY        => C_FAMILY )
      port map (
            Sl_addrAck          => Sl_addrAck,     
            Sl_MRdErr           => Sl_MRdErr,        
            Sl_MWrErr           => Sl_MWrErr,        
            Sl_MBusy            => Sl_MBusy,        
            Sl_rdBTerm          => Sl_rdBTerm,     
            Sl_rdComp           => Sl_rdComp,      
            Sl_rdDAck           => Sl_rdDAck,       
            Sl_rdDBus           => Sl_rdDBus,      
            Sl_rdWdAddr         => Sl_rdWdAddr,    
            Sl_rearbitrate      => Sl_rearbitrate, 
            Sl_SSize            => Sl_SSize,       
            Sl_wait             => Sl_wait,         
            Sl_wrBTerm          => Sl_wrBTerm,     
            Sl_wrComp           => Sl_wrComp,      
            Sl_wrDAck           => Sl_wrDAck,       
            WdtMTimeout_n       => wdtMTimeout_n,
            Sl_MIRQ             => Sl_MIRQ,
            PLB_SaddrAck        => plb_saddrack_i,    
            PLB_SMRderr         => plb_smrderr_i,       
            PLB_SMWrerr         => plb_smwrerr_i,       
            PLB_SMBusy          => plb_smbusy_i,      
            PLB_SrdBTerm        => plb_srdbterm_i,    
            PLB_SrdComp         => plb_srdcomp_i,     
            PLB_SrdDAck         => plb_srddack_i,     
            PLB_SrdDBus         => plb_srddbus_i,     
            PLB_SrdWdAddr       => plb_srdwdaddr_i,   
            PLB_Srearbitrate    => plb_srearbitrate_i,
            PLB_Sssize          => plb_sssize_i,      
            PLB_Swait           => plb_swait_i,       
            PLB_SwrBTerm        => plb_swrbterm_i,    
            PLB_SwrComp         => plb_swrcomp_i,     
            PLB_SwrDAck         => plb_swrdack_i,
            PLB_MIRQ            => PLB_MIRQ
            );

    --  Instantiate the PLB Arbiter
    I_PLB_ARBITER_LOGIC: entity plb_v46_v1_05_a.plb_arbiter_logic
        generic map (
            C_NUM_MASTERS           => C_PLBV46_NUM_MASTERS,
            C_NUM_SLAVES            => C_PLBV46_NUM_SLAVES,
            C_MID_BITS              => C_PLBV46_MID_WIDTH,
            C_PLB_AWIDTH            => C_PLBV46_AWIDTH,
            C_PLB_DWIDTH            => C_PLBV46_DWIDTH,  
            C_DCR_INTFCE            => C_DCR_INTFCE,
            C_DCR_AWIDTH            => C_DCR_AWIDTH,
            C_DCR_DWIDTH            => C_DCR_DWIDTH,
            C_BASEADDR              => C_BASEADDR,
            C_HIGHADDR              => C_HIGHADDR,
            C_IRQ_ACTIVE            => C_IRQ_ACTIVE,
            C_OPTIMIZE_1M           => C_OPTIMIZE_1M,
            C_ADDR_PIPELINING_TYPE  => C_ADDR_PIPELINING_TYPE,
            C_FAMILY                => C_FAMILY,
            C_ARB_TYPE              => C_ARB_TYPE 
            )
        port map (
                  M_RNW             => M_RNW,
                  M_busLock         => m_buslock_qual,
                  M_lockErr         => M_lockErr,
                  M_priority        => M_priority,
                  M_rdBurst         => M_rdBurst,
                  M_request         => M_request,
                  M_wrBurst         => M_wrBurst,
                  PLB_ABus          => plb_abus_i,
                  PLB_UABus         => plb_uabus_i,
                  PLB_BE            => plb_be_i,
                  PLB_MAddrAck      => PLB_MAddrAck,
                  WdtMTimeout_n     => wdtMTimeout_n,
                  PLB_MTimeout      => PLB_MTimeout,
                  PLB_MBusy         => PLB_MBusy,
                  PLB_MRdErr        => PLB_MRdErr,
                  PLB_MWrErr        => PLB_MWrErr,
                  PLB_MRdBTerm      => PLB_MRdBTerm,
                  PLB_MRearbitrate  => PLB_MRearbitrate,
                  PLB_MWrBTerm      => PLB_MWrBTerm,
                  PLB_MSSize        => PLB_MSSize,
                  PLB_PAValid       => PLB_PAValid,
                  PLB_SAValid       => PLB_SAValid,
                  PLB_masterID      => PLB_masterID,
                  PLB_rdPendPri     => PLB_rdPendPri,
                  PLB_wrPendPri     => PLB_wrPendPri,
                  PLB_rdPrim        => PLB_rdPrim,
                  PLB_reqPri        => PLB_reqPri,
                  PLB_wrPrim        => PLB_wrPrim,
                  PLB_RNW           => PLB_RNW,
                  PLB_busLock       => PLB_busLock,
                  PLB_rdPendReq     => PLB_rdPendReq,
                  PLB_wrPendReq     => PLB_wrPendReq,
                  PLB_rdBurst       => PLB_rdBurst,
                  PLB_size          => plb_size_i,
                  PLB_type          => plb_type_i,
                  PLB_wrBurst       => PLB_wrBurst,
                  Sl_MBusy          => plb_smbusy_i,
                  Sl_MRdErr         => plb_smrderr_i,
                  Sl_MWrErr         => plb_smwrerr_i,
                  Sl_rdBTerm        => plb_srdbterm_i,
                  Sl_SSize          => plb_sssize_i,
                  Sl_wrBTerm        => plb_swrbterm_i,
                  Sl_wrComp         => plb_swrcomp_i,
                  Sl_addrAck        => plb_saddrack_i,
                  Sl_rdComp         => plb_srdcomp_i,
                  Sl_rearbitrate    => plb_srearbitrate_i,
                  Sl_wait           => plb_swait_i,
                  ArbAddrSelReg     => arbAddrSelReg,
                  ArbBurstReq       => arbBurstReq,
                  ArbPriRdMasterRegReg => arbPriRdMasterRegReg,
                  ArbPriWrMasterReg => arbPriWrMasterReg,
                  DCR_ABus          => DCR_ABus,
                  DCR_Read          => DCR_Read,
                  DCR_Write         => DCR_Write,
                  PLB_dcrAck        => PLB_dcrAck,
                  PLB_dcrDBus       => PLB_dcrDBus,
                  DCR_DBus          => DCR_DBus,
                  Bus_Error_Det     => Bus_Error_Det,
                  Clk               => PLB_Clk,
                  Rst               => plb_rst_i);

end generate GEN_SHARED;    

end simulation;

