-------------------------------------------------------------------------------
--  $Id: pend_request.vhd,v 1.1.2.1 2010/07/13 16:33:55 srid Exp $
-------------------------------------------------------------------------------
-- pend_request.vhd - entity/architecture pair
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
-- Filename:        pending_request.vhd
-- Version:         v1.04a
-- Description:     This file simply ORs together the Master's requests along
--                  with the state of the secondary read/write transactions
--                  to determine if there is a pending request.
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
-- ^^^^^^
--  FLO         06/03/05        
-- ^^^^^^
-- Start of changes for plb_v46.
-- -PLB_pendReq split into PLB_rdPendReq and PLB_wrPendReq (Rd and Wr versions).
-- -Added 'component' keyword in instantiations of unsim component, MUXCY.
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

-- UNISIM library is required when Xilinx primitives are instantiated
library unisim;
use unisim.vcomponents.all;

-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Generics:
--          C_NUM_MASTERS               -- number of PLB masters
--
-- Definition of Ports:
--
--      -- Master interface signals
--          input   M_request           -- array of masters requests
--
--      -- Secondary Read/Write signals
--          input   arbSecRdInProgReg   -- indicates there is a secondary read
--                                      -- in progress
--          input   arbSecWrInProgReg   -- indicates there is a secondary write
--                                      -- in progress
--      -- Output
--          output  PLB_rdPendReq         -- pending read  request
--          output  PLB_wrPendReq         -- pending write request
--      
-------------------------------------------------------------------------------
-- 
 
-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------
entity pend_request is
    generic (
            C_NUM_MASTERS       : integer   := 8
            );
    port    (
            M_request           : in    std_logic_vector(0 to C_NUM_MASTERS-1);
            M_RNW               : in    std_logic_vector(0 to C_NUM_MASTERS-1);
            ArbSecRdInProgReg   : in    std_logic;
            ArbSecWrInProgReg   : in    std_logic;
            PLB_rdPendReq       : out   std_logic;
            PLB_wrPendReq       : out   std_logic
            );
end pend_request;
 
 
-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture simulation of pend_request is
-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
-- No constants are required for this design
-------------------------------------------------------------------------------
-- Signal and Type Declarations
------------------------------------------------------------------------------- 
-- Carry chain mux outputs
-- the carry chain mux implements an OR of all of the master's request signals 
-- plus the secondary read and secondary write in progress signals
signal rd_req_mux      : std_logic_vector(0 to (C_NUM_MASTERS-1) +1);
signal wr_req_mux      : std_logic_vector(0 to (C_NUM_MASTERS-1) +1);

-- Select lines are the request signals and ArbSecRd/WrInProgReg NEGATED
signal arbSecRdInProgReg_n  : std_logic;
signal arbSecWrInProgReg_n  : std_logic;
signal m_request_n          : std_logic_vector(0 to C_NUM_MASTERS-1);

-- Define signals for '1' and '0'
constant zero                 : std_logic := '0';
constant one                  : std_logic := '1';

-------------------------------------------------------------------------------
-- Component Declarations
-------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin

-- generate negated signals for mux selects
arbSecRdInProgReg_n <= not(ArbSecRdInProgReg);
arbSecWrInProgReg_n <= not(ArbSecWrInProgReg);

-------------------------------------------------------------------------------
-- Generate the carry chain to determine if there is a pending request.
-- The carry chain essentially implements a wide OR. The first mux in the
-- chain is for the secondary write, followed by the secondary read, then
-- followed by masters 0 - C_NUM_MASTERS-1
-------------------------------------------------------------------------------  
-- generate the carry muxes for secondary rd and wr requests
I_RD_REQ_MUX1: component MUXCY
    port map (
            O   => rd_req_mux(0),
            CI  => zero,
            DI  => one,
            S   => arbSecRdInProgReg_n
            );
I_WR_REQ_MUX0: component MUXCY
    port map (
            O   => wr_req_mux(0),
            CI  => zero,
            DI  => one,
            S   => arbSecWrInProgReg_n
            );

-- generate the carry muxes for the masters
-- ToDo, can optimize these to handle multiple requests per LUT
-- (or change to inferred RTL).
RD_REQ_MASTERS_MUXES: for n in 1 to (C_NUM_MASTERS-1)+1 generate
    signal lutout : std_logic;
begin
        lutout <= not (M_request(n-1) and M_RNW(n-1));

        I_MASTER_RD_REQ_MUX: component MUXCY
            port map (
                    O   => rd_req_mux(n),
                    CI  => rd_req_mux(n-1),
                    DI  => one,
                    S   => lutout
                    );
end generate RD_REQ_MASTERS_MUXES;

WR_REQ_MASTERS_MUXES: for n in 1 to (C_NUM_MASTERS-1)+1 generate
    signal lutout : std_logic;
begin
        lutout <= not (M_request(n-1) and not M_RNW(n-1));

        I_MASTER_WR_REQ_MUX: component MUXCY
            port map (
                    O   => wr_req_mux(n),
                    CI  => wr_req_mux(n-1),
                    DI  => one,
                    S   => lutout
                    );
end generate WR_REQ_MASTERS_MUXES;

-------------------------------------------------------------------------------
-- Generate Pending Request output signal
-------------------------------------------------------------------------------
PLB_rdPendReq <= rd_req_mux((C_NUM_MASTERS-1)+1);
PLB_wrPendReq <= wr_req_mux((C_NUM_MASTERS-1)+1);

end ;

