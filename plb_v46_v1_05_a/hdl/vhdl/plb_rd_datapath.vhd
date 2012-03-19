-------------------------------------------------------------------------------
--  $Id: plb_rd_datapath.vhd,v 1.1.2.1 2010/07/13 16:33:57 srid Exp $
-------------------------------------------------------------------------------
-- plb_rd_datapath.vhd - entity/architecture pair
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
-- Filename:        plb_rd_datapath.vhd
-- Version:         v1.04a
-- Description:     This file contains the PLB read data bus, read data ack,
--                  and read word address routing logic. The slave read data
--                  bus and read word address signals are 
--                  routed back to all masters. Note this differs slightly from
--                  the IBM implementation which only routes the slave data 
--                  only back to the read master. This was done by IBM for power
--                  reasons and is not a necessary implementation for the 
--                  PLB specification. 
--
--                  The slave read data ack signal is only routed back to the
--                  read master as in the IBM implementation.
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
-- ~~~~~~
--  FLO         06/08/05        
-- ^^^^^^
-- Start of changes for plb_v46.
-- -Eliminated aspects related to the watchdog timer completing hanshakes on
--  timeout.
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
 
-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_NUM_MASTERS               -- number of masters
--      C_PLB_DWIDTH                -- data bus width
--
-- Definition of Ports:
--      input Sl_rdDack             -- slave read data acknowledge
--      input ArbPriRdMasterRegReg  -- register holding read master id
--      input Sl_rdWdAddr           -- slave read word address
--      input Sl_rdDBus             -- slave read data bus
--
--      output PLB_MRdDAck          -- read data ack to master
--      output PLB_RdDBus           -- read data bus to master
--      output PLB_MRdWdAddr        -- read word address to master
-------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------
entity plb_rd_datapath is
  generic ( C_NUM_MASTERS   : integer   := 8;
            C_PLB_DWIDTH    : integer   := 128);
  port (
        Sl_rdDAck               : in std_logic;
        ArbPriRdMasterRegReg    : in std_logic_vector(0 to C_NUM_MASTERS-1 );
        Sl_rdWdAddr             : in std_logic_vector(0 to 3 );
        PLB_MRdDAck             : out std_logic_vector(0 to C_NUM_MASTERS-1 );
        PLB_MRdDBus             : out std_logic_vector(0 to (C_NUM_MASTERS*C_PLB_DWIDTH) - 1 );
        PLB_MRdWdAddr           : out std_logic_vector(0 to (C_NUM_MASTERS * 4) - 1 );
        Sl_rdDBus               : in std_logic_vector(0 to C_PLB_DWIDTH - 1 )
        );
end plb_rd_datapath;
  
-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture simulation of plb_rd_datapath is
-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------
-- No internal signals required
-------------------------------------------------------------------------------
-- Component Declarations
-------------------------------------------------------------------------------
-- No components required


-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin
 
-- Set all master read data buses to the slave data buses
-- The AND that sets a bus to zero if not selected has been removed.

MSTR_RDBUS_GENERATE: for i in 0 to C_NUM_MASTERS-1 generate

    PLB_MRdDBus((i*C_PLB_DWIDTH) to ((i+1)*C_PLB_DWIDTH)-1) <= Sl_rdDBus(0 to C_PLB_DWIDTH-1);

end generate MSTR_RDBUS_GENERATE;

-- Set all master RdWdAddr buses to the slave data buses
-- The AND that sets a bus to zero if not selected has been removed
MSTR_RDWDADDR_GENERATE: for i in 0 to C_NUM_MASTERS-1 generate

    PLB_MRdWdAddr(i*4 to ((i+1)*4)-1) <= Sl_rdWdAddr(0 to 3);
    
end generate MSTR_RDWDADDR_GENERATE;

-- Send the rdDAck (from the slave or the WDT) to the winning master
MSTR_RDDACK_GENERATE: for i in 0 to C_NUM_MASTERS-1 generate
    
    PLB_MRdDAck(i) <= ArbPriRdMasterRegReg(i) and (Sl_rdDAck);

end generate MSTR_RDDACK_GENERATE;

                    
end simulation;

