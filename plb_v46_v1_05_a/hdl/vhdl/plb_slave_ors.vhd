-------------------------------------------------------------------------------
--  $Id: plb_slave_ors.vhd,v 1.1.2.1 2010/07/13 16:33:57 srid Exp $
-------------------------------------------------------------------------------
-- plb_slave_ors.vhd - entity/architecture pair
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
-- Filename:        plb_slave_ors.vhd
-- Version:         v1.04a
-- Description:     This file contains the OR gates for the slave inputs
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
--  FLO         06/01/05        
-- ^^^^^^
-- Start of changes for plb_v46.
-- -PLB_MErr split into PLB_MRdErr and PLB_MWrErr (Rd and Wr versions).
-- -Sl_MErr split into Sl_MRdErr and Sl_MWrErr.
-- -PLB_SMErr split into PLB_SMRdErr and PLB_SMWrErr.
-- -Removed component declarations in favor of direct entity instantiation.
-- ~~~~~~
--  FLO         06/08/05        
-- ^^^^^^
-- Start of changes for plb_v46.
-- -Eliminated aspects related to the watchdog timer completing hanshakes on
--  timeout.
-- -Changed structure section to a reference to plb_v46.vhd.
-- ~~~~~~
--  FLO         06/09/05        
-- ^^^^^^
-- -Implemented ports and functionality for new signals Sl_MIRQ and PLB_MIRQ.
-- ~~~~~~
--  FLO         06/15/05        
-- ^^^^^^
-- -Now using selected names in direct-entity instantiations.
-- ~~~~~~
--  FLO         06/16/05        
-- ^^^^^^
-- -Added generic C_FAMILY
-- ~~~~~~
--  FLO         07/19/05        
-- ^^^^^^
-- -Changed to active low WdtMTimeout_n
-- ~~~~~~
--  FLO         08/26/05        
-- ^^^^^^
-- -Removed gating by WdtMTimeout_n on signals plb_srearbitrate_i and
--  plb_saddrack_i.
-- ~~~~~~
--  JLJ         09/14/07    v1.01a  
-- ^^^^^^
--  Update to v1.01a.
-- ~~~~~~
--  JLJ         10/09/07    v1.02a  
-- ^^^^^^
--  Update to v1.02a.
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

library plb_v46_v1_05_a;
use plb_v46_v1_05_a.or_gate;

-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Generics:
--          C_NUM_MASTERS
--          C_NUM_SLAVES                -- number of slaves
--          C_PLB_DWIDTH                -- data bus width
--          C_FAMILY                    -- target FPGA family
--
-- Definition of Ports:
--      --  Slave signals
--          input Sl_addrAck(0 to C_NUM_SLAVES-1)
--          input Sl_MRdErr(0 to C_NUM_SLAVES*C_NUM_MASTERS-1)
--          input Sl_MWrErr(0 to C_NUM_SLAVES*C_NUM_MASTERS-1)
--          input Sl_MBusy(0 to C_NUM_SLAVES*C_NUM_MASTERS-1)
--          input Sl_rdBTerm(0 to C_NUM_SLAVES-1)
--          input Sl_rdComp(0 to C_NUM_SLAVES-1)
--          input Sl_rdDAck(0 to C_NUM_SLAVES-1)
--          input Sl_rdDBus(0 to C_NUM_SLAVES*C_PLB_DWIDTH-1)
--          input Sl_rdWdAddr(0 to C_NUM_SLAVES*4-1)
--          input Sl_rearbitrate(0 to C_NUM_SLAVES-1)
--          input Sl_SSize(0 to C_NUM_SLAVES*2-1)
--          input Sl_wait(0 to C_NUM_SLAVES-1)
--          input Sl_wrBTerm(0 to C_NUM_SLAVES-1)
--          input Sl_wrComp(0 to C_NUM_SLAVES-1)
--          input Sl_wrDAck(0 to C_NUM_SLAVES-1)
--
--          input WdtMTimeout_n  -- One cycle timeout pulse
--
--      -- PLB signals (output of slave OR gate)
--          output PLB_SaddrAck
--          output PLB_SMRdErr(0 to C_NUM_MASTERS-1)
--          output PLB_SMWrErr(0 to C_NUM_MASTERS-1)
--          output PLB_SMBusy(0 to C_NUM_MASTERS-1)
--          output PLB_SrdBTerm
--          output PLB_SrdComp
--          output PLB_SrdDAck
--          output PLB_SrdDBus(0 to C_PLB_DWIDTH-1)
--          output PLB_SrdWdAddr(0 to3)
--          output PLB_Srearbitrate
--          output PLB_Sssize(0 to 1)
--          output PLB_Swait
--          output PLB_SwrBTerm
--          output PLB_SwrComp
--          output PLB_SwrDAck
--
-------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------
entity plb_slave_ors is
  generic ( C_NUM_MASTERS   : integer   := 8;
            C_NUM_SLAVES    : integer   := 8;
            C_PLB_DWIDTH    : integer   := 128;
            C_FAMILY        : string
          );
  port (
        Sl_addrAck      : in std_logic_vector(0 to C_NUM_SLAVES - 1 );
        Sl_MRdErr       : in std_logic_vector(0 to C_NUM_SLAVES*C_NUM_MASTERS - 1 );
        Sl_MWrErr       : in std_logic_vector(0 to C_NUM_SLAVES*C_NUM_MASTERS - 1 );
        Sl_MBusy        : in std_logic_vector(0 to C_NUM_SLAVES*C_NUM_MASTERS - 1 );
        Sl_rdBTerm      : in std_logic_vector(0 to C_NUM_SLAVES - 1);
        Sl_rdComp       : in std_logic_vector(0 to C_NUM_SLAVES - 1);
        Sl_rdDAck       : in std_logic_vector(0 to C_NUM_SLAVES - 1);
        Sl_rdDBus       : in std_logic_vector(0 to C_NUM_SLAVES*C_PLB_DWIDTH - 1 );
        Sl_rdWdAddr     : in std_logic_vector(0 to C_NUM_SLAVES*4 - 1 );
        Sl_rearbitrate  : in std_logic_vector(0 to C_NUM_SLAVES - 1 );
        Sl_SSize        : in std_logic_vector(0 to C_NUM_SLAVES*2 - 1 );
        Sl_wait         : in std_logic_vector(0 to C_NUM_SLAVES - 1 );
        Sl_wrBTerm      : in std_logic_vector(0 to C_NUM_SLAVES - 1 );
        Sl_wrComp       : in std_logic_vector(0 to C_NUM_SLAVES - 1 );
        Sl_wrDAck       : in std_logic_vector(0 to C_NUM_SLAVES - 1 );
        WdtMTimeout_n   : in std_logic;
        Sl_MIRQ         : in std_logic_vector(0 to C_NUM_SLAVES*C_NUM_MASTERS - 1 );
        
        PLB_SaddrAck    : out std_logic;
        PLB_SMRdErr     : out std_logic_vector(0 to C_NUM_MASTERS-1);   
        PLB_SMWrErr     : out std_logic_vector(0 to C_NUM_MASTERS-1);   
        PLB_SMBusy      : out std_logic_vector(0 to C_NUM_MASTERS-1);   
        PLB_SrdBTerm    : out std_logic;   
        PLB_SrdComp     : out std_logic;
        PLB_SrdDAck     : out std_logic;
        PLB_SrdDBus     : out std_logic_vector(0 to C_PLB_DWIDTH-1);   
        PLB_SrdWdAddr   : out std_logic_vector(0 to 3);
        PLB_Srearbitrate: out std_logic;
        PLB_Sssize      : out std_logic_vector(0 to 1);
        PLB_Swait       : out std_logic;
        PLB_SwrBTerm    : out std_logic;
        PLB_SwrComp     : out std_logic;
        PLB_SwrDAck     : out std_logic;
        PLB_MIRQ        : out std_logic_vector(0 to C_NUM_MASTERS-1)
        
        );

end plb_slave_ors;
 
 
-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture implementation of plb_slave_ors is

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------
signal plb_saddrack_i       : std_logic_vector(0 to 0);
signal plb_smrderr_i        : std_logic_vector(0 to C_NUM_MASTERS-1); 
signal plb_smwrerr_i        : std_logic_vector(0 to C_NUM_MASTERS-1); 
signal plb_smbusy_i         : std_logic_vector(0 to C_NUM_MASTERS-1); 
signal plb_smirq_i          : std_logic_vector(0 to C_NUM_MASTERS-1); 
signal plb_srdbterm_i       : std_logic_vector(0 to 0);   
signal plb_srdcomp_i        : std_logic_vector(0 to 0);
signal plb_srddack_i        : std_logic_vector(0 to 0);
signal plb_srddbus_i        : std_logic_vector(0 to C_PLB_DWIDTH-1);  
signal plb_srdwdaddr_i      : std_logic_vector(0 to 3);
signal plb_srearbitrate_i   : std_logic_vector(0 to 0);
signal plb_sssize_i         : std_logic_vector(0 to 1);
signal plb_swait_i          : std_logic_vector(0 to 0);
signal plb_swrbterm_i       : std_logic_vector(0 to 0);
signal plb_swrcomp_i        : std_logic_vector(0 to 0);
signal plb_swrdack_i        : std_logic_vector(0 to 0);

-------------------------------------------------------------------------------
-- Component Declarations
-------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin
-- assign internal signals to output ports
PLB_SaddrAck        <=   plb_saddrack_i(0);    
PLB_SMRdErr         <=   plb_smrderr_i;       
PLB_SMWrErr         <=   plb_smwrerr_i;       
PLB_SMBusy          <=   plb_smbusy_i;      
PLB_MIRQ            <=   plb_smirq_i;      
PLB_SrdBTerm        <=   plb_srdbterm_i(0);    
PLB_SrdComp         <=   plb_srdcomp_i(0);     
PLB_SrdDAck         <=   plb_srddack_i(0);     
PLB_SrdDBus         <=   plb_srddbus_i;     
PLB_SrdWdAddr       <=   plb_srdwdaddr_i;  
PLB_Srearbitrate    <=   plb_srearbitrate_i(0);
PLB_Sssize          <=   plb_sssize_i ;     
PLB_Swait           <=   plb_swait_i(0);       
PLB_SwrBTerm        <=   plb_swrbterm_i(0);    
PLB_SwrComp         <=   plb_swrcomp_i(0);     
PLB_SwrDAck         <=   plb_swrdack_i(0);     

-------------------------------------------------------------------------------
-- Component Instantiations
-------------------------------------------------------------------------------
-- Set the generics on the OR gates to use MUXCY, not LUTs

-- Instantiate the Slave OR gates for Sl_addrAck
ADDRACK_OR: entity or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => 1,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_addrAck,
                  Y => plb_saddrack_i);

-- Instantiate the Slave OR gates for Sl_MRdErr
MRDERR_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => C_NUM_MASTERS,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_MRdErr,
                  Y => plb_smrderr_i);                  

-- Instantiate the Slave OR gates for Sl_MWrErr
MWRERR_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => C_NUM_MASTERS,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_MWrErr,
                  Y => plb_smwrerr_i);                  

-- Instantiate the Slave OR gates for Sl_MBusy
MBUSY_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => C_NUM_MASTERS,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_MBusy,
                  Y => plb_smbusy_i);

-- Instantiate the Slave OR gates for Sl_rdBTerm
RDBTERM_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => 1,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_rdBTerm,
                  Y => plb_srdbterm_i); 

-- Instantiate the Slave OR gates for Sl_rdComp
RDCOMP_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => 1,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_rdComp,
                  Y => plb_srdcomp_i);

-- Instantiate the Slave OR gates for Sl_rdDAck
RDDACK_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => 1,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_rdDAck,
                  Y => plb_srddack_i);

-- Instantiate the Slave OR gates for Sl_rdDBus
-- For now, simply OR the busses - this assumes 64-bit PLB and 64-bit slaves
-- NEED TO ADD BUS MIRRORING LOGIC!!!
RDBUS_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => C_PLB_DWIDTH,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_rdDBus,
                  Y => plb_srddbus_i);

-- Instantiate the Slave OR gates for Sl_rdWdAddr
RDWDADDR_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => 4,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_rdWdAddr,
                  Y => plb_srdwdaddr_i);

REARB_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => 1,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_rearbitrate,
                  Y => plb_srearbitrate_i);

-- Instantiate the Slave OR gates for Sl_SSize
SSIZE_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => 2,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_SSize,
                  Y => plb_sssize_i);

-- Instantiate the Slave OR gates for Sl_wait
WAIT_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => 1,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_wait,
                  Y => plb_swait_i);

-- Instantiate the Slave OR gates for Sl_wrBTerm
WRBTERM_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => 1,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_wrBTerm,
                  Y => plb_swrbterm_i);

-- Instantiate the Slave OR gates for Sl_wrComp
WRCOMP_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => 1,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_wrComp,
                  Y => plb_swrcomp_i);

-- Instantiate the Slave OR gates for Sl_wrDAck
WRDACK_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => 1,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_wrDAck,
                  Y => plb_swrdack_i);
                  
-- Instantiate the Slave OR gates for Sl_MIRQ
MIRQ_OR: entity plb_v46_v1_05_a.or_gate
    generic map (C_OR_WIDTH     => C_NUM_SLAVES,
                 C_BUS_WIDTH    => C_NUM_MASTERS,
                 C_USE_LUT_OR   => TRUE)
    port map    ( A => Sl_MIRQ,
                  Y => plb_smirq_i);

end implementation;

