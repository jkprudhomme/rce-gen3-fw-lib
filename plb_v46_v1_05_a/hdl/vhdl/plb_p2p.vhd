-------------------------------------------------------------------------------
--  $Id: plb_p2p.vhd,v 1.1.2.1 2010/07/13 16:33:57 srid Exp $
-------------------------------------------------------------------------------
-- plb_p2p.vhd - entity/architecture pair
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
-- Filename:        plb_p2p.vhd
-- Version:         v1.04a
-- Description:     This file contains the wired connection for P2P mode.
--                  Includes the logic necessary to support address pipelining
--                  in the optimized single master & single slave bus 
--                  configuration.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:  (see plb_v46.vhd)
--
-------------------------------------------------------------------------------
-- Author:      JLJ
--
-- History:
--  JLJ         04/12/07        
-- ^^^^^^
--  JLJ         04/12/07        -- Version v0.00a
-- ^^^^^^
--  New module creation.
-- ~~~~~~
--  JLJ         04/17/07        -- Version v1.00a
-- ^^^^^^
--  Roll back to v1.00a.
-- ~~~~~~
--  JLJ         04/18/07        -- Version v1.00a
-- ^^^^^^
--  Insert logic to hold off assertion of PAValid when read or write data bus
--  is already busy.
--  Need to improve this logic to utilize SAValid when read bus is busy.
-- ~~~~~~
--  JLJ         04/26/07        -- Version v1.00a
-- ^^^^^^
--  Modify timeout logic to use PAValid vs. M_Request.
-- ~~~~~~
--  JLJ         07/17/07    v1.00a   
-- ^^^^^^
--  Add C_SIZE parameter to watchdog_timer module.  In P2P mode, the counter value
--  is set to 8, for up to 256 clock cycles to occur before a timeout condition.
-- ~~~~~
--  JLJ         08/08/07    v1.00a   
-- ^^^^^^
--  Change C_SIZE parameter on watchdog_timer module to 4.
-- ~~~~~
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
--  Remove input signal, M_abort and usage.
--  Set default output for PLB_abort = '0'.
--  Update port mapping on watchdog_timer and remove PLB_abort signal.
-- ~~~~~~
--  JLJ         11/2/07     v1.02a  
-- ^^^^^^
--  Set PLB_busLock = '0' for all P2P configurations.
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

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

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
--      C_NUM_CLK_PLB2OPB_REARB -- number of clocks of master deferral
--
-- Definition of Ports:
--      -- Masters' signals
--      input  M_RNW
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
entity plb_p2p is
  generic (
        C_NUM_MASTERS           : integer   := 1;
        C_NUM_SLAVES            : integer   := 1;
        C_MID_BITS              : integer   := 1;
        C_PLB_AWIDTH            : integer   := 32;
        C_PLB_DWIDTH            : integer   := 128;
        C_IRQ_ACTIVE            : std_logic := '1';
        C_FAMILY                : string;
        C_ADDR_PIPELINING_TYPE  : integer   := 1         -- 0:none, 1:2-level
        );
  port (
          Clk               : in std_logic;
          Rst               : in std_logic;

          M_ABus            : in std_logic_vector(0 to (C_NUM_MASTERS * 32) - 1 );
          M_UABus           : in std_logic_vector(0 to (C_NUM_MASTERS * 32) - 1 );
          M_BE              : in std_logic_vector(0 to (C_NUM_MASTERS * (C_PLB_DWIDTH / 8)) - 1 );
          M_RNW             : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
          M_TAttribute      : in std_logic_vector(0 to C_NUM_MASTERS * 16 - 1 );
          M_lockErr         : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
          M_MSize           : in std_logic_vector(0 to (C_NUM_MASTERS * 2) - 1 );
          M_priority        : in std_logic_vector(0 to (C_NUM_MASTERS * 2) - 1 );
          M_rdBurst         : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
          M_request         : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
          M_size            : in std_logic_vector(0 to (C_NUM_MASTERS * 4) - 1 );
          M_type            : in std_logic_vector(0 to (C_NUM_MASTERS * 3) - 1 );
          M_wrBurst         : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
          M_wrDBus          : in std_logic_vector(0 to (C_NUM_MASTERS * C_PLB_DWIDTH) - 1 );

          PLB_ABus          : out std_logic_vector(0 to 31 );
          PLB_UABus         : out std_logic_vector(0 to 31 );
          PLB_BE            : out std_logic_vector(0 to (C_PLB_DWIDTH / 8) - 1 );
          PLB_MAddrAck      : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
          PLB_MTimeout      : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
          PLB_MBusy         : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
          PLB_MRdErr        : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
          PLB_MWrErr        : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
          PLB_MRdBTerm      : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
          PLB_MRdDAck       : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
          PLB_MRdDBus       : out std_logic_vector(0 to (C_NUM_MASTERS*C_PLB_DWIDTH)-1);
          PLB_MRdWdAddr     : out std_logic_vector(0 to (C_NUM_MASTERS * 4) - 1 );
          PLB_MRearbitrate  : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
          PLB_MWrBTerm      : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
          PLB_MWrDAck       : out std_logic_vector(0 to C_NUM_MASTERS - 1 );
          PLB_MSSize        : out std_logic_vector(0 to (C_NUM_MASTERS * 2) - 1 );
          PLB_PAValid       : out std_logic;
          PLB_RNW           : out std_logic;
          PLB_SAValid       : out std_logic;
          PLB_busLock       : out std_logic;
          PLB_TAttribute    : out std_logic_vector(0 to 15 );
          PLB_lockErr       : out std_logic;
          PLB_masterID      : out std_logic_vector(0 to C_MID_BITS-1);
          PLB_MSize         : out std_logic_vector(0 to 1 );
          PLB_rdPendPri     : out std_logic_vector(0 to 1 );
          PLB_wrPendPri     : out std_logic_vector(0 to 1 );
          PLB_rdPendReq     : out std_logic;
          PLB_wrPendReq     : out std_logic;
          PLB_rdBurst       : out std_logic;
          PLB_rdPrim        : out std_logic_vector(0 to C_NUM_SLAVES - 1 );
          PLB_reqPri        : out std_logic_vector(0 to 1 );
          PLB_size          : out std_logic_vector(0 to 3 );
          PLB_type          : out std_logic_vector(0 to 2 );
          PLB_wrBurst       : out std_logic;
          PLB_wrDBus        : out std_logic_vector(0 to C_PLB_DWIDTH - 1 );
          PLB_wrPrim        : out std_logic_vector(0 to C_NUM_SLAVES - 1 );

          Sl_addrAck        : in std_logic_vector(0 to C_NUM_SLAVES - 1 );
          Sl_MRdErr         : in std_logic_vector(0 to C_NUM_SLAVES*C_NUM_MASTERS - 1 );
          Sl_MWrErr         : in std_logic_vector(0 to C_NUM_SLAVES*C_NUM_MASTERS - 1 );
          Sl_MBusy          : in std_logic_vector(0 to C_NUM_SLAVES*C_NUM_MASTERS - 1 );
          Sl_rdBTerm        : in std_logic_vector(0 to C_NUM_SLAVES - 1);
          Sl_rdComp         : in std_logic_vector(0 to C_NUM_SLAVES - 1);
          Sl_rdDAck         : in std_logic_vector(0 to C_NUM_SLAVES - 1);
          Sl_rdDBus         : in std_logic_vector(0 to C_NUM_SLAVES*C_PLB_DWIDTH - 1 );
          Sl_rdWdAddr       : in std_logic_vector(0 to C_NUM_SLAVES*4 - 1 );
          Sl_rearbitrate    : in std_logic_vector(0 to C_NUM_SLAVES - 1 );
          Sl_SSize          : in std_logic_vector(0 to C_NUM_SLAVES*2 - 1 );
          Sl_wait           : in std_logic_vector(0 to C_NUM_SLAVES - 1 );
          Sl_wrBTerm        : in std_logic_vector(0 to C_NUM_SLAVES - 1 );
          Sl_wrComp         : in std_logic_vector(0 to C_NUM_SLAVES - 1 );
          Sl_wrDAck         : in std_logic_vector(0 to C_NUM_SLAVES - 1 );

          Sl_MIRQ           : in std_logic_vector(0 to C_NUM_SLAVES*C_NUM_MASTERS - 1 );
          PLB_MIRQ          : out std_logic_vector(0 to C_NUM_MASTERS-1);   

          -- Outputs of Slave OR gates are only used in simulation to connect
          -- to the IBM PLB Monitor
          PLB_SaddrAck      : out std_logic;
          PLB_SMRdErr       : out std_logic_vector(0 to C_NUM_MASTERS-1);   
          PLB_SMWrErr       : out std_logic_vector(0 to C_NUM_MASTERS-1);   
          PLB_SMBusy        : out std_logic_vector(0 to C_NUM_MASTERS-1);   
          PLB_SrdBTerm      : out std_logic;   
          PLB_SrdComp       : out std_logic;
          PLB_SrdDAck       : out std_logic;
          PLB_SrdDBus       : out std_logic_vector(0 to C_PLB_DWIDTH-1);   
          PLB_SrdWdAddr     : out std_logic_vector(0 to 3);
          PLB_Srearbitrate  : out std_logic;
          PLB_Sssize        : out std_logic_vector(0 to 1);
          PLB_Swait         : out std_logic;
          PLB_SwrBTerm      : out std_logic;
          PLB_SwrComp       : out std_logic;
          PLB_SwrDAck       : out std_logic

        );
        
end plb_p2p;


-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture implementation of plb_p2p is

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------

signal wdtMTimeout_n        : std_logic;
signal plb_pavalid_i        : std_logic;
signal plb_savalid_i        : std_logic;
signal plb_rdprim_i         : std_logic;
signal plb_wrprim_i         : std_logic;

-------------------------------------------------------------------------------
-- Component Declarations
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin

    -- Create optimized wired connection on PLB signals

    -- PLB output signals to Slave device
    PLB_PAValid         <= plb_pavalid_i;
    PLB_SAValid         <= plb_savalid_i;            

    PLB_ABus            <= M_ABus(0 to 31);
    PLB_UABus           <= M_UABus(0 to 31);
    PLB_BE              <= M_BE(0 to (C_PLB_DWIDTH/8) - 1);
    PLB_RNW             <= M_RNW(0);
    PLB_busLock         <= '0';             -- No buslock in P2P   
    PLB_TAttribute      <= M_TAttribute(0 to 15);
    PLB_lockErr         <= M_lockErr(0);
    PLB_masterID(0)     <= '0';             -- Only 1 Master in P2P
    PLB_MSize           <= M_MSize;
    PLB_rdPendPri       <= M_priority;
    PLB_wrPendPri       <= M_priority;
    PLB_rdPendReq       <= M_request(0) and M_RNW(0);
    PLB_wrPendReq       <= M_request(0) and (not M_RNW(0));
    PLB_rdBurst         <= M_rdBurst(0);
    PLB_rdPrim(0)       <= plb_rdprim_i;             
    PLB_reqPri          <= M_priority;
    PLB_size            <= M_size;
    PLB_type            <= M_type;
    PLB_wrBurst         <= M_wrBurst(0);
    PLB_wrDBus          <= M_wrDBus;
    PLB_wrPrim(0)       <= plb_wrprim_i;    

    -- PLB output signals to Master device
    PLB_MAddrAck(0)     <= Sl_addrAck(0);
    PLB_MTimeout(0)     <= (not wdtMTimeout_n);
    PLB_MBusy(0)        <= Sl_MBusy(0);
    PLB_MRdErr(0)       <= Sl_MRdErr(0);
    PLB_MWrErr(0)       <= Sl_MWrErr(0);
    PLB_MRdBTerm(0)     <= Sl_rdBTerm(0);
    PLB_MRdDAck(0)      <= Sl_rdDAck(0);
    PLB_MRdDBus         <= Sl_rdDBus;
    PLB_MRdWdAddr       <= Sl_rdWdAddr;
    PLB_MRearbitrate(0) <= Sl_rearbitrate(0);
    PLB_MWrBTerm(0)     <= Sl_wrBTerm(0);
    PLB_MWrDAck(0)      <= Sl_wrDAck(0);
    PLB_MSSize(0 to 1)  <= Sl_SSize;

    PLB_MIRQ(0)         <= Sl_MIRQ(0);      

    -- PLB signals to PLB monitor -- for simulation --
    PLB_SaddrAck        <=   Sl_addrAck(0);    
    PLB_SMRdErr(0)      <=   Sl_MRdErr(0);       
    PLB_SMWrErr(0)      <=   Sl_MWrErr(0);       
    PLB_SMBusy(0)       <=   Sl_MBusy(0);      
    PLB_SrdBTerm        <=   Sl_rdBTerm(0);    
    PLB_SrdComp         <=   Sl_rdComp(0);     
    PLB_SrdDAck         <=   Sl_rdDAck(0);     
    PLB_SrdDBus         <=   Sl_rdDBus;     
    PLB_SrdWdAddr       <=   Sl_rdWdAddr;  
    PLB_Srearbitrate    <=   Sl_rearbitrate(0);
    PLB_Sssize          <=   Sl_SSize;     
    PLB_Swait           <=   Sl_wait(0);       
    PLB_SwrBTerm        <=   Sl_wrBTerm(0);    
    PLB_SwrComp         <=   Sl_wrComp(0);     
    PLB_SwrDAck         <=   Sl_wrDAck(0);     


    -- The watchdog timer will assert the AddrAck if the slave has not 
    -- responded within 16 clock cycles from the assertion of PAValid
    I_WDT: entity plb_v46_v1_05_a.watchdog_timer
    generic map (
        C_SIZE  => 4
    )
    port map 
    (
        Clk                 => Clk,
        ArbReset            => Rst,
        PLB_PAValid         => plb_pavalid_i,
        Sl_addrAck          => Sl_addrAck(0),
        Sl_rearbitrate      => Sl_rearbitrate(0),
        Sl_wait             => Sl_wait(0),
        WdtMTimeout_n       => WdtMTimeout_n,
        WdtMTimeout_n_p1    => open
    );


    -- If address pipelining is disable
    -- No SAValid can be utilized
    NO_ADDR_PIPE: if (C_ADDR_PIPELINING_TYPE = 0) generate
    signal wrBus_Busy : std_logic;
    signal rdBus_Busy : std_logic;

    begin

        -- Only assert PAValid if read or write buses are not busy with the current transaction.
        -- Combinational output, but timing should not be affected with P2P connection.
        plb_pavalid_i       <= '1' when ((M_request(0) = '1') and ((M_RNW(0) = '0' and wrBus_Busy = '0') or
                                                                   (M_RNW(0) = '1' and rdBus_Busy = '0')))    
                                else '0';
                                
        -- SAValid is not utilized if address pipelining is disabled in P2P mode                        
        plb_savalid_i <= '0'; 
        
        -- No secondary address support
        plb_rdprim_i <= '0';             
        plb_wrprim_i <= '0';             


        -- Determine if write data bus is busy with current transaction
        WR_BUSY_PROCESS: process (Clk, Rst)
        begin
            if (Clk'event and Clk = '1') then   

                -- Reset wrBus_Busy when slave completes write transaction
                if ((Rst = RESET_ACTIVE) or (Sl_wrComp(0) = '1')) then
                    wrBus_Busy <= '0';

                -- Set wrBus_Busy when slave acknowledges write transaction
                elsif ((M_request(0) = '1') and (M_RNW(0) = '0') and (Sl_addrAck(0) = '1')) then
                    wrBus_Busy <= '1';            
                end if;
            end if;    
        end process WR_BUSY_PROCESS;


        -- Determine if read data bus is busy with current transaction
        RD_BUSY_PROCESS: process (Clk, Rst)
        begin
            if (Clk'event and Clk = '1') then   

                -- Reset rdBus_Busy when slave completes read transaction
                if ((Rst = RESET_ACTIVE) or (Sl_rdComp(0) = '1')) then
                    rdBus_Busy <= '0';

                -- Set rdBus_Busy when slave acknowledges read transaction
                elsif ((M_request(0) = '1') and (M_RNW(0) = '1') and (Sl_addrAck(0) = '1')) then
                    rdBus_Busy <= '1';            
                end if;
            end if;    
        end process RD_BUSY_PROCESS;   
    
    
    end generate NO_ADDR_PIPE;
    

    -- If address pipelining is enabled
    -- Then SAValid can be utilized & slave devices can assert Sl_AddrAck or Sl_ReArbitrate
    -- to secondary address on PLB
    W_ADDR_PIPE: if (C_ADDR_PIPELINING_TYPE = 1) generate
    
    signal pavalid_i, pavalid_cmb : std_logic;
    signal savalid_i, savalid_cmb : std_logic;
    signal arbWrDBusBusyReg     : std_logic;
    signal arbRdDBusBusyReg     : std_logic;
    signal arbSecWrInProgReg    : std_logic;
    signal arbSecRdInProgReg    : std_logic;
    signal RecomputeWrBits      : std_logic;
    signal RecomputeRdBits      : std_logic;    
    signal Request              : std_logic;
    signal RNW                  : std_logic;
    signal RdPrimReg            : std_logic;
    signal WrPrimReg            : std_logic;
   
    type ARB_SM_TYPE is (IDLE, RD_STATE, WR_STATE);
    signal arbctrl_sm_cs, arbctrl_sm_ns : ARB_SM_TYPE;
    
    begin

        plb_pavalid_i <= pavalid_i;
        plb_savalid_i <= savalid_i;
        
        Request <= M_Request(0);
        RNW <= M_RNW(0);
        
        plb_rdprim_i <= (Sl_rdComp(0) and arbRdDbusBusyReg and arbSecRdInProgReg) or RdPrimReg;
        plb_wrprim_i <= (Sl_wrComp(0) and arbWrDbusBusyReg and arbSecWrInProgReg) or --WrPrimReg;
                        (Sl_wrComp(0) and arbWrDbusBusyReg and RecomputeWrBits);

        -- Determine if primary write or read data buses are busy
        WRDBUS_BUSY_REG:  process (Clk)
        begin
            if (Clk'event and Clk = '1' ) then
                if (Rst = RESET_ACTIVE) then
                    arbWrDBusBusyReg <= '0';
                    arbRdDBusBusyReg <= '0';
                else
                    arbWrDBusBusyReg <= (not Sl_wrComp(0) and arbWrDBusBusyReg) or
                                        (RecomputeWrBits and (not Sl_wrComp(0) or arbWrDBusBusyReg)) or
                                        arbSecWrInProgReg;

                    arbRdDBusBusyReg <= (not Sl_rdComp(0) and arbRdDBusBusyReg) or
                                        (RecomputeRdBits and (not Sl_rdComp(0) or arbRdDBusBusyReg)) or
                                        arbSecRdInProgReg;
                end if;
            end if;
        end process WRDBUS_BUSY_REG;

        -- Asserted if secondary write or read is in progress
        SEC_WR_REG:  process (Clk)
        begin
            if (Clk'event and Clk = '1' ) then
                if (Rst = RESET_ACTIVE) then
                    arbSecWrInProgReg <= '0';
                    arbSecRdInProgReg <= '0';
                    RdPrimReg <= '0';
                    WrPrimReg <= '0';
                else
                    arbSecWrInProgReg <= not Sl_wrComp(0) and 
                                         ((arbWrDbusBusyReg and RecomputeWrBits)
                                          or arbSecWrInProgReg);

                    arbSecRdInProgReg <= not Sl_rdComp(0) and 
                                         ((arbRdDbusBusyReg and RecomputeRdBits)
                                          or arbSecRdInProgReg);
                                          
                    RdPrimReg <= Sl_rdComp(0) and arbRdDbusBusyReg and RecomputeRdBits;                
                    WrPrimReg <= Sl_wrComp(0) and arbWrDbusBusyReg and RecomputeWrBits;                
                                          
                end if;
            end if;
        end process SEC_WR_REG;

        --------------------------------------------------------------------------------
        -- ARBCTRL_SM_CMB: Combinatorial SM process
        -- ARBCTRL_SM_REG: Registered SM process
        --------------------------------------------------------------------------------
        ARBCTRL_SM_CMB: process (arbctrl_sm_cs,
                                 Request, RNW, 
                                 arbRdDBusBusyReg, arbSecRdInProgReg, 
                                 arbWrDBusBusyReg, arbSecWrInProgReg, 
                                 Sl_addrAck(0), Sl_rearbitrate(0), 
                                 WdtMTimeout_n,
                                 Sl_rdComp(0), Sl_wrComp(0))
        begin
        pavalid_cmb <= '0';    
        savalid_cmb <= '0';    
        RecomputeRdBits <= '0';    
        RecomputeWrBits <= '0';    
        arbctrl_sm_ns <= arbctrl_sm_cs;

        case arbctrl_sm_cs is

            ----------------------------- IDLE State --------------------------------
            when IDLE =>

                -- Wait for M_Request to be asserted by master
                if (Request = '1') then
                    
                    -- Read transaction and either primary or secondary bus is idle
                    if (RNW and not (arbRdDBusBusyReg and arbSecRdInProgReg)) = '1' then
            
                        arbctrl_sm_ns <= RD_STATE;

                        -- Primary read bus is idle, assert PAValid
                        -- or primary read operation is still in progress, keep PAValid asserted
                        if (not(arbRdDBusBusyReg) or (arbRdDBusBusyReg and (Sl_rdComp(0)))) = '1' then
                            pavalid_cmb <= '1';
                        end if;

                        -- Secondary transaction, assert SAValid
                        if (arbRdDBusBusyReg and not(arbSecRdInProgReg) and not(Sl_rdComp(0))) = '1' then
                            savalid_cmb <= '1';
                        end if;

                    -- Write transaction and either a primary or secondary bus is idle
                    elsif (not(RNW) and not(arbWrDBusBusyReg and arbSecWrInProgReg)) = '1' then
                        arbctrl_sm_ns <= WR_STATE;

                        -- Primary write bus is idle, assert PAValid
                        -- or primary write operation is still in progress, keep PAValid asserted
                        if (not(arbWrDBusBusyReg) or (arbWrDBusBusyReg and (Sl_wrComp(0)))) = '1' then
                            pavalid_cmb <= '1';
                        end if;

                        -- Secondary transaction, assert SAValid
                        if (arbWrDBusBusyReg and not(arbSecWrInProgReg) and not(Sl_wrComp(0))) = '1' then
                            savalid_cmb <= '1';
                        end if;
                    end if;
                end if; 


            ------------------------------ RD_STATE --------------------------------
            when RD_STATE =>

                if (not(arbRdDBusBusyReg) or (Sl_rdComp(0))) = '1' then
                    pavalid_cmb <= '1';
                end if;

                if (arbRdDBusBusyReg and not(arbSecRdInProgReg) and
                    not(Sl_rdComp(0))) = '1' then
                    savalid_cmb <= '1';
                end if;

                if (not WdtMTimeout_n) = '1' then
                    pavalid_cmb <= '0';
                    --savalid_cmb <= '0';
                    arbctrl_sm_ns <= IDLE;

                elsif (Sl_addrAck(0) = '1') then
                    pavalid_cmb <= '0';
                    savalid_cmb <= '0';
                    RecomputeRdBits <= '1';
                    arbctrl_sm_ns <= IDLE;

                elsif (Sl_rearbitrate(0)) = '1' then
                    pavalid_cmb <= '0';
                    savalid_cmb <= '0';
                    arbctrl_sm_ns <= IDLE; 

                end if;

            --------------------------------- WR_STATE -------------------------------
            when WR_STATE =>

                if (not(arbWrDBusBusyReg) or Sl_wrComp(0)) = '1' then
                    pavalid_cmb <= '1';
                end if;

                if (arbWrDBusBusyReg and not(arbSecWrInProgReg) and
                    not(Sl_wrComp(0))) = '1' then
                    savalid_cmb <= '1';
                end if;

                if (not WdtMTimeout_n) = '1' then
                    pavalid_cmb <= '0';
                    arbctrl_sm_ns <= IDLE;

                elsif (Sl_addrAck(0) = '1') then
                    pavalid_cmb <= '0';                        
                    savalid_cmb <= '0';  
                    RecomputeWrBits <= '1';
                    arbctrl_sm_ns <= IDLE;

                elsif (Sl_rearbitrate(0)) = '1' then
                    pavalid_cmb <= '0';   
                    savalid_cmb <= '0';
                    arbctrl_sm_ns <= IDLE;

                end if;

--coverage off
            ------------------------------- Default --------------------------------
            when others =>
                arbctrl_sm_ns <= IDLE;
--coverage on

            end case;
        end process ARBCTRL_SM_CMB;

        ARBCTRL_SM_REG: process (Clk)
        begin

            if (Clk'event and Clk = '1' ) then
              if (Rst = RESET_ACTIVE) then
                pavalid_i <= '0';
                savalid_i <= '0';
                arbctrl_sm_cs <= IDLE;
              else
                pavalid_i <= pavalid_cmb;
                savalid_i <= savalid_cmb;
                arbctrl_sm_cs <= arbctrl_sm_ns;
              end if;
            end if;
        end process ARBCTRL_SM_REG;

    end generate W_ADDR_PIPE;

end implementation;

