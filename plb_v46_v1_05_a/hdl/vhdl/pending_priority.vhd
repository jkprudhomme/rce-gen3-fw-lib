-------------------------------------------------------------------------------
--  $Id: pending_priority.vhd,v 1.1.2.1 2010/07/13 16:33:56 srid Exp $
-------------------------------------------------------------------------------
-- pending_priority.vhd - entity/architecture pair
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
-- Filename:        pending_priority.vhd
-- Version:         v1.04a
-- Description:     This file outputs the highest priority of all requesting
--                  master and the priorities of the secondary read/write
--                  transactions.
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
--  LCW Oct 15, 2004      -- updated for NCSim
-- ^^^^^^
--  FLO         06/03/05        
-- ^^^^^^
-- Start of changes for plb_v46.
-- -PLB_pendPri split into PLB_rdPendPri and PLB_wrPendPri (Rd and Wr versions).
-- -Added 'component' keyword to unisim instantiations (e.g. MUXCY).
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

-- UNISIM library is required whenever Xilinx primitives are instantiated
library unisim;
use unisim.vcomponents.all;

library plb_v46_v1_05_a;
use plb_v46_v1_05_a.qual_priority;


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
--          input   M_priority          -- array of masters priorities
--
--      -- Secondary Read/Write signals
--          input   ArbSecRdInProgReg   -- indicates there is a secondary read
--                                      -- in progress
--          input   SecRdInProgPriorReg -- priority of secondary read
--          input   ArbSecWrInProgReg   -- indicates there is a secondary write
--                                      -- in progress
--          input   SecWrInProgPriorReg -- priority of secondary write
--
--      -- Output
--          output  PLB_rdPendPri       -- pending priority
--          output  PLB_wrPendPri       -- pending priority
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------
entity pending_priority is
    generic (
            C_NUM_MASTERS       : integer   := 8
            );
    port    (
            M_request           : in    std_logic_vector(0 to C_NUM_MASTERS-1);
            M_RNW               : in    std_logic_vector(0 to C_NUM_MASTERS-1);
            M_priority          : in    std_logic_vector(0 to C_NUM_MASTERS*2-1);
            ArbSecRdInProgReg   : in    std_logic;
            SecRdInProgPriorReg : in    std_logic_vector(0 to 1);
            ArbSecWrInProgReg   : in    std_logic;
            SecWrInProgPriorReg : in    std_logic_vector(0 to 1);
            PLB_rdPendPri       : out   std_logic_vector(0 to 1);
            PLB_wrPendPri       : out   std_logic_vector(0 to 1)
            );
end pending_priority;


-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture simulation of pending_priority is

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
-- No constants are required for this design
-------------------------------------------------------------------------------
-- Signal and Type Declarations
-------------------------------------------------------------------------------
-- Decoded master levels
signal m_rd_lvl3_n             : std_logic_vector(0 to C_NUM_MASTERS-1);
signal m_rd_lvl2_n             : std_logic_vector(0 to C_NUM_MASTERS-1);
signal m_rd_lvl1_n             : std_logic_vector(0 to C_NUM_MASTERS-1);

signal m_wr_lvl3_n             : std_logic_vector(0 to C_NUM_MASTERS-1);
signal m_wr_lvl2_n             : std_logic_vector(0 to C_NUM_MASTERS-1);
signal m_wr_lvl1_n             : std_logic_vector(0 to C_NUM_MASTERS-1);

-- Secondary read/write levels
signal secrd_lvl3_n         : std_logic;
signal secrd_lvl2_n         : std_logic;
signal secrd_lvl1_n         : std_logic;

signal secwr_lvl3_n         : std_logic;
signal secwr_lvl2_n         : std_logic;
signal secwr_lvl1_n         : std_logic;

-- Carry chain mux outputs
-- the carry chain mux implements an OR of all of the master's level signals
-- plus the secondary read and secondary write level signals
signal lvl3_rd_mux             : std_logic_vector(0 to (C_NUM_MASTERS+1) -1);
signal lvl2_rd_mux             : std_logic_vector(0 to (C_NUM_MASTERS+1) -1);
signal lvl1_rd_mux             : std_logic_vector(0 to (C_NUM_MASTERS+1) -1);

signal lvl3_wr_mux             : std_logic_vector(0 to (C_NUM_MASTERS+1) -1);
signal lvl2_wr_mux             : std_logic_vector(0 to (C_NUM_MASTERS+1) -1);
signal lvl1_wr_mux             : std_logic_vector(0 to (C_NUM_MASTERS+1) -1);

-- Define signals for the output of the wide or gate
-- these signals represent whether there is any request at this level
signal rdpendpri_lvl3         : std_logic;
signal rdpendpri_lvl2         : std_logic;
signal rdpendpri_lvl1         : std_logic;

signal wrpendpri_lvl3         : std_logic;
signal wrpendpri_lvl2         : std_logic;
signal wrpendpri_lvl1         : std_logic;

-- Define signals for '1' and '0'
constant zero                 : std_logic := '0';
constant one                  : std_logic := '1';

-------------------------------------------------------------------------------
-- Component Declarations
-------------------------------------------------------------------------------
-- MUXCYs (carry chain muxes) are used to implement OR function of master's lvl
-- signals and the secondary read/write lvl signals

-- QUAL_PRIORITY decodes the master's priority bits into the lvl signal IF the
-- master's request is asserted

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin

-------------------------------------------------------------------------------
-- Component Instantiations
-------------------------------------------------------------------------------
-- Instantiate the qual_priority components for the secondary read/write
-- signals and the masters
-------------------------------------------------------------------------------
I_SECRD_LVL: entity plb_v46_v1_05_a.qual_priority
    port map (
            Request     => ArbSecRdInProgReg,
            RNW_has_exp_value => true,
            Priority    => SecRdInProgPriorReg,
            Lvl1_n      => secrd_lvl1_n,
            Lvl2_n      => secrd_lvl2_n,
            Lvl3_n      => secrd_lvl3_n
             );

I_SECWR_LVL: entity plb_v46_v1_05_a.qual_priority
    port map (
            Request     => ArbSecWrInProgReg,
            RNW_has_exp_value => true,
            Priority    => SecWrInProgPriorReg,
            Lvl1_n      => secwr_lvl1_n,
            Lvl2_n      => secwr_lvl2_n,
            Lvl3_n      => secwr_lvl3_n
             );

MASTER_RD_LVLS: for n in 0 to C_NUM_MASTERS-1 generate
    signal RNW_has_exp_value : boolean;
begin
        RNW_has_exp_value <= M_RNW(n) = '1';

        I_QUAL_MASTERS_PRIORITY: entity plb_v46_v1_05_a.qual_priority
            port map (
                    Request     => M_request(n),
                    RNW_has_exp_value => RNW_has_exp_value,
                    Priority    => M_priority(2*n to (2*n)+1),
                    Lvl1_n      => m_rd_lvl1_n(n),
                    Lvl2_n      => m_rd_lvl2_n(n),
                    Lvl3_n      => m_rd_lvl3_n(n)
                    );
end generate MASTER_RD_LVLS;

MASTER_WR_LVLS: for n in 0 to C_NUM_MASTERS-1 generate
    signal RNW_has_exp_value : boolean;
begin
        RNW_has_exp_value <= M_RNW(n) = '0';

        I_QUAL_MASTERS_PRIORITY: entity plb_v46_v1_05_a.qual_priority
            port map (
                    Request     => M_request(n),
                    RNW_has_exp_value => RNW_has_exp_value,
                    Priority    => M_priority(2*n to (2*n)+1),
                    Lvl1_n      => m_wr_lvl1_n(n),
                    Lvl2_n      => m_wr_lvl2_n(n),
                    Lvl3_n      => m_wr_lvl3_n(n)
                    );
end generate MASTER_WR_LVLS;

-------------------------------------------------------------------------------
-- Generate the carry chain to determine if there is a level3 request.
-- The Rd and Wr cases are handled with separate carry chains.
-- The carry chain implements a wide OR. The first mux in each
-- chain is for the secondary, followed by masters 0 to C_NUM_MASTERS-1.
-------------------------------------------------------------------------------
-- put the secondary at the beginning of the carry chain
I_LVL3_RD_MUX1: component MUXCY
    port map (
            O   => lvl3_rd_mux(0),
            CI  => zero,
            DI  => one,
            S   => secrd_lvl3_n
            );
I_LVL3_WR_MUX0: component MUXCY
    port map (
            O   => lvl3_wr_mux(0),
            CI  => zero,
            DI  => one,
            S   => secwr_lvl3_n
            );
-- generate the carry muxes for the masters
LVL3_MASTERS_RD_MUXES: for n in 1 to (C_NUM_MASTERS-1)+1 generate

        I_MASTER_MUX: component MUXCY
            port map (
                    O   => lvl3_rd_mux(n),
                    CI  => lvl3_rd_mux(n-1),
                    DI  => one,
                    S   => m_rd_lvl3_n(n-1)
                    );
end generate LVL3_MASTERS_RD_MUXES;
LVL3_MASTERS_WR_MUXES: for n in 1 to (C_NUM_MASTERS-1)+1 generate

        I_MASTER_MUX: component MUXCY
            port map (
                    O   => lvl3_wr_mux(n),
                    CI  => lvl3_wr_mux(n-1),
                    DI  => one,
                    S   => m_wr_lvl3_n(n-1)
                    );
end generate LVL3_MASTERS_WR_MUXES;

-------------------------------------------------------------------------------
-- Generate the carry chain to determine if there is a level2 request.
-- The Rd and Wr cases are handled with separate carry chains.
-- The carry chain implements a wide OR. The first mux in each
-- chain is for the secondary, followed by masters 0 to C_NUM_MASTERS-1.
-------------------------------------------------------------------------------
-- put the secondary at the beginning of the carry chain
I_LVL2_RD_MUX1: component MUXCY
    port map (
            O   => lvl2_rd_mux(0),
            CI  => zero,
            DI  => one,
            S   => secrd_lvl2_n
            );
I_LVL2_WR_MUX0: component MUXCY
    port map (
            O   => lvl2_wr_mux(0),
            CI  => zero,
            DI  => one,
            S   => secwr_lvl2_n
            );
-- generate the carry muxes for the masters
LVL2_MASTERS_RD_MUXES: for n in 1 to (C_NUM_MASTERS-1)+1 generate

        I_MASTER_MUX: component MUXCY
            port map (
                    O   => lvl2_rd_mux(n),
                    CI  => lvl2_rd_mux(n-1),
                    DI  => one,
                    S   => m_rd_lvl2_n(n-1)
                    );
end generate LVL2_MASTERS_RD_MUXES;
LVL2_MASTERS_WR_MUXES: for n in 1 to (C_NUM_MASTERS-1)+1 generate

        I_MASTER_MUX: component MUXCY
            port map (
                    O   => lvl2_wr_mux(n),
                    CI  => lvl2_wr_mux(n-1),
                    DI  => one,
                    S   => m_wr_lvl2_n(n-1)
                    );
end generate LVL2_MASTERS_WR_MUXES;

-------------------------------------------------------------------------------
-- Generate the carry chain to determine if there is a level1 request.
-- The Rd and Wr cases are handled with separate carry chains.
-- The carry chain implements a wide OR. The first mux in each
-- chain is for the secondary, followed by masters 0 to C_NUM_MASTERS-1.
-------------------------------------------------------------------------------
-- put the secondary at the beginning of the carry chain
I_LVL1_RD_MUX1: component MUXCY
    port map (
            O   => lvl1_rd_mux(0),
            CI  => zero,
            DI  => one,
            S   => secrd_lvl1_n
            );
I_LVL1_WR_MUX0: component MUXCY
    port map (
            O   => lvl1_wr_mux(0),
            CI  => zero,
            DI  => one,
            S   => secwr_lvl1_n
            );
-- generate the carry muxes for the masters
LVL1_MASTERS_RD_MUXES: for n in 1 to (C_NUM_MASTERS-1)+1 generate

        I_MASTER_MUX: component MUXCY
            port map (
                    O   => lvl1_rd_mux(n),
                    CI  => lvl1_rd_mux(n-1),
                    DI  => one,
                    S   => m_rd_lvl1_n(n-1)
                    );
end generate LVL1_MASTERS_RD_MUXES;
LVL1_MASTERS_WR_MUXES: for n in 1 to (C_NUM_MASTERS-1)+1 generate

        I_MASTER_MUX: component MUXCY
            port map (
                    O   => lvl1_wr_mux(n),
                    CI  => lvl1_wr_mux(n-1),
                    DI  => one,
                    S   => m_wr_lvl1_n(n-1)
                    );
end generate LVL1_MASTERS_WR_MUXES;


-------------------------------------------------------------------------------
-- Generate Pending Priority output signals
-------------------------------------------------------------------------------
rdpendpri_lvl3 <= lvl3_rd_mux((C_NUM_MASTERS-1)+1);
rdpendpri_lvl2 <= lvl2_rd_mux((C_NUM_MASTERS-1)+1);
rdpendpri_lvl1 <= lvl1_rd_mux((C_NUM_MASTERS-1)+1);

wrpendpri_lvl3 <= lvl3_wr_mux((C_NUM_MASTERS-1)+1);
wrpendpri_lvl2 <= lvl2_wr_mux((C_NUM_MASTERS-1)+1);
wrpendpri_lvl1 <= lvl1_wr_mux((C_NUM_MASTERS-1)+1);

PLB_rdPendPri(0) <= rdpendpri_lvl3 or rdpendpri_lvl2;
PLB_rdPendPri(1) <= rdpendpri_lvl3 or (rdpendpri_lvl1 and rdpendpri_lvl2);

PLB_wrPendPri(0) <= wrpendpri_lvl3 or wrpendpri_lvl2;
PLB_wrPendPri(1) <= wrpendpri_lvl3 or (wrpendpri_lvl1 and wrpendpri_lvl2);

end simulation;
