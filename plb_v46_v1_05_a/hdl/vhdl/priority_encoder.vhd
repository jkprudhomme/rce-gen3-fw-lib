-------------------------------------------------------------------------------
--  $Id: priority_encoder.vhd,v 1.1.2.1 2010/07/13 16:33:58 srid Exp $
-------------------------------------------------------------------------------
-- priority_encoder.vhd - entity/architecture pair
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
-- Filename:        priority_encoder.vhd
-- Version:         v1.04a
-- Description:     This file contains the carry-chain, parameterizable
--                  implementation of the priority encoder. The priority
--                  encoder selects the master with the highest priority bits.
--                  If there is more than one master with the highest priority
--                  bits, then the priority is fixed with Master 0 being the
--                  highest priority, then Master 1, Master 2, etc.
--
--                  Note that this code is parameterized for a number of masters
--                  which is divisible by 4. The number of masters passed into
--                  this file from PLB_PRIORITY_ENCODER.vhd has been padded to
--                  the nearest power of 2 and therefore meets this requirement.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:  (see plb_v46.vhd)
--
-------------------------------------------------------------------------------
-- Author:      ALS
-- History:
---     ALS     02/20/02        -- created from plb_arbiter_v1_01_a
--      ALS     04/16/02        -- Version v1.01a
-- ~~~~~~
--  FLO         06/08/05        
-- ^^^^^^
-- Start of changes for plb_v46.
-- -Switched to v2_00_a for proc_common.
-- -Changed structure section to a reference to plb_v46.vhd.
-- ~~~~~~
--  LCW Oct 15, 2004      -- updated for NCSim
-- ~~~~~~
--  ALS 04/29/05 (FLO 07/19/05)
-- ^^^^^^
--  Corrected the equation for lutout for master 3 in the zero mux in
--  a non-zero quad.
-- ~~~~~~
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
--  Remove M_abort input signal and usage.
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

-- The unisim library is required when instantiating Xilinx primitives.
library unisim;
use unisim.vcomponents.all;

library plb_v46_v1_05_a;
use plb_v46_v1_05_a.qual_request;



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
--      -- Arbiter interface signals
--          input   ArbDisMReqReg       -- indicates when masters requests are
--                                      -- disabled
--      -- Output
--          output  PrioencdrOutput     -- 1-hot register indicating who won
--                                      -- priority
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------
entity priority_encoder is
generic (
    C_NUM_MASTERS       : integer   := 8
);
port (
    M_request           : in    std_logic_vector(0 to C_NUM_MASTERS-1);
    M_priority          : in    std_logic_vector(0 to C_NUM_MASTERS*2-1);
    ArbDisMReqReg       : in    std_logic_vector(0 to C_NUM_MASTERS-1);
    PrioencdrOutput     : out   std_logic_vector(0 to C_NUM_MASTERS-1)
    );
    
end priority_encoder;


-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture simulation of priority_encoder is

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
-- number of MUXCYs in a carry chain
constant NUM_MUX            : integer   := 7;

-- number of master quadrants
constant NUM_QUADS          : integer   := C_NUM_MASTERS/4;
-------------------------------------------------------------------------------
-- Signal and Type Declarations
-------------------------------------------------------------------------------
-- Decoded master levels
-- Single array arranged by M0_lvl0, M0_lvl1, M0_lvl2, M0_lvl3, M1_lvl0, M1_lvl1,
-- M1_lvl2, M1_lvl3, etc. where M#_lvl# are outputs from the QUAL_REQUEST blocks.
signal m_lvl                : std_logic_vector(0 to C_NUM_MASTERS*4-1);

-- Quadrant level signals
-- stores whether any master in each quadrant had a request of a certain level
-- there are 4 priority levels - these signals are active low
type QUAD_LVL_TYPE is array (0 to NUM_QUADS-1) of std_logic_vector(0 to 3);
signal q_lvl_n              : QUAD_LVL_TYPE;

-- Quadrant select signals
-- stores the MUXCY selects for the carry chains in the quadrant
-- there are NUM_MUX MUXCYs in each carry chain
type QUAD_SEL_TYPE is array (0 to NUM_QUADS -1) of std_logic_vector(0 to NUM_MUX-1);
signal q_sel                : QUAD_SEL_TYPE;

type TEMP_SEL_TYPE is array (0 to NUM_QUADS*NUM_MUX-1) of std_logic_vector(0 to NUM_QUADS-1);
signal temp_sel             : TEMP_SEL_TYPE;

-- Carry chain input signals
-- this data type is used for the DI, CI inputs to the MUXCYs
-- there are NUM_MUX MUXCYs in each chain and 4 masters in each quadrant
-- these signals only need to be stored for each quadrant
type MUXCY_DIN_TYPE is array (0 to 3) of std_logic_vector(0 to NUM_MUX-1);
type QUAD_MUXCY_TYPE is array (0 to NUM_QUADS-1) of MUXCY_DIN_TYPE;
signal lutout               : QUAD_MUXCY_TYPE;
signal cyout                : QUAD_MUXCY_TYPE;

-- Define signals for '1' and '0'
signal zero                 : std_logic := '0';
signal one                  : std_logic := '1';

-------------------------------------------------------------------------------
-- Component Declarations
-------------------------------------------------------------------------------

-- QUAL_REQUEST decodes the master's priority bits into the lvl signal IF the
-- master's request and abort is negated and the request is not disabled

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin

-------------------------------------------------------------------------------
-- Component Instantiations
-------------------------------------------------------------------------------
-- Instantiate the qual_request components for the secondary read/write
-- signals and the masters
-------------------------------------------------------------------------------

MASTER_LVLS: for n in 0 to C_NUM_MASTERS-1 generate

        I_QUAL_MASTERS_REQUEST: entity plb_v46_v1_05_a.qual_request
            port map (
                    Request         => M_request(n),
                    ArbDisReqReg    => ArbDisMReqReg(n),
                    Priority        => M_priority(2*n to (2*n)+1),
                    Lvl0            => m_lvl(n*4),
                    Lvl1            => m_lvl(n*4 + 1),
                    Lvl2            => m_lvl(n*4 + 2),
                    Lvl3            => m_lvl(n*4 + 3)
                    );
end generate MASTER_LVLS;

-------------------------------------------------------------------------------
-- Generate the logic to determine whether a master in a quadrant has a certain
-- priority level. If any master in a quadrant has a priority level 3, then the
-- lvl3_n signal (active low) is asserted. This is true for each priority level
-- in each quadrant
-------------------------------------------------------------------------------

QUAD_LVL_GEN: for i in 0 to NUM_QUADS -1 generate -- loop through quadrants

    LVLS_GEN: for n in 0 to 3 generate    -- loop through levels

        q_lvl_n(i)(n) <= not(m_lvl(i*16+n) or m_lvl(i*16+4+n) or
                             m_lvl(i*16+8+n) or m_lvl(i*16+12+n));
    end generate LVLS_GEN;
end generate QUAD_LVL_GEN;

-------------------------------------------------------------------------------
-- Generate the mux select signals for the quadrants
-------------------------------------------------------------------------------
QUAD_SEL_GEN: for i in 0 to NUM_QUADS -1 generate -- loop through quadrants

   MUXLOOP: for j in 0 to NUM_MUX-1 generate -- loop through muxes

        EVEN_SELS: if (j mod 2 = 0) generate  -- handle evens

                    EVEN_ZERO_SEL: if i = 0 generate
                                --q_sel(i)(j) <= q_sel(i)(j) and q_lvl_n(i)(j/2);
                                q_sel(i)(j) <= q_lvl_n(i)(j/2);
                    end generate EVEN_ZERO_SEL;

                    EVEN_NONZERO_SEL: if i /= 0 generate
                           E_MUXSEL: for k in 0 to (i-1) generate
                                ZERO_K: if k = 0 generate
                                    temp_sel(i*NUM_MUX+j)(k) <= q_lvl_n(k)(j/2);
                                end generate ZERO_K;
                                NZ_K: if k /= 0 generate
                                    temp_sel(i*NUM_MUX+j)(k) <= temp_sel(i*NUM_MUX+j)(k-1) and q_lvl_n(k)(j/2);
                                end generate NZ_K;
                           end generate E_MUXSEL;
                           q_sel(i)(j) <= temp_sel(i*NUM_MUX+j)(i-1);
                    end generate EVEN_NONZERO_SEL;

        end generate EVEN_SELS;

        ODD_SELS: if (j mod 2 /= 0) generate -- handle odds

                ODD_ZERO_SELS: if i = 0 generate

                    -- if there is only one quadrant, then there are not q_lvl_n signals for
                    -- the select lines of the odd muxes. In fact, these "odd" muxes are not
                    -- required, therefore, set the select lines to '1' to allow the previous
                    -- mux output to flow through and the muxes to be optimized away in
                    -- synthesis.

                    ONEQUAD_GEN: if NUM_QUADS = 1 generate
                        q_sel(i)(j) <= '1';
                    end generate ONEQUAD_GEN;

                    MULTQUAD_GEN: if NUM_QUADS > 1 generate
                        OZ_MUX_SELS: for k in i+1 to NUM_QUADS-1 generate
                            ONE_ZK: if k = i+1 generate
                                temp_sel(i*NUM_MUX+j)(k) <= q_lvl_n(k)((j+1)/2);
                            end generate ONE_ZK;
                            OTHER_ZK: if k > i+1 generate
                                temp_sel(i*NUM_MUX+j)(k) <= temp_sel(i*NUM_MUX+j)(k-1) and q_lvl_n(k)((j+1)/2);
                            end generate OTHER_ZK;
                        end generate OZ_MUX_SELS;
                        q_sel(i)(j) <= temp_sel(i*NUM_MUX+j)(NUM_QUADS-1);
                    end generate MULTQUAD_GEN;

                end generate ODD_ZERO_SELS;

                ODD_NONZERO_SELS:  if i /= 0 generate
                        O_MUXSEL: for k in i to NUM_QUADS -1 generate
                            ONE_NZK: if k = i generate
                                temp_sel(i*NUM_MUX+j)(k) <= q_lvl_n(k)((j+1)/2);
                            end generate ONE_NZK;
                            OTHER_NZK: if k > i generate
                                temp_sel(i*NUM_MUX+j)(k) <= temp_sel(i*NUM_MUX+j)(k-1) and q_lvl_n(k)((j+1)/2);
                            end generate OTHER_NZK;
                        end generate O_MUXSEL;
                        q_sel(i)(j) <= temp_sel(i*NUM_MUX+j)(NUM_QUADS-1);
                end generate ODD_NONZERO_SELS;

        end generate ODD_SELS;

    end generate MUXLOOP;
end generate QUAD_SEL_GEN;

-------------------------------------------------------------------------------
-- Generate the lut outputs
-------------------------------------------------------------------------------
LUTOUT_GEN: for i in 0 to NUM_QUADS-1 generate -- loop through quadrants

        MSTRLOOP: for j in 0 to 3 generate            -- loop through each master in quad

            MUXCY_LOOP: for n in 0 to 6 generate

                QUAD_ZERO:if i = 0 generate       -- quadrant 0 uses chain differently

                        EVEN_QUAD_ZERO: if n mod 2 = 0 generate -- even indexes

                            MASTER_ZERO: if j=0 generate     -- master 0 is highest priority
                                lutout(i)(j)(n) <= m_lvl(n/2);
                            end generate MASTER_ZERO;

                            MASTER_ONE: if j=1 generate     -- determine priority for master1
                                lutout(i)(j)(n) <= not(m_lvl(n/2)) and m_lvl(n/2+4);
                            end generate MASTER_ONE;

                            MASTER_TWO: if j=2 generate     -- determine priority for master2
                                lutout(i)(j)(n) <= not(m_lvl(n/2)) and not(m_lvl((n/2)+4))
                                                and m_lvl((n/2)+8);
                            end generate MASTER_TWO;

                            MASTER_THREE: if j=3 generate     -- determine priority for master3
                                lutout(i)(j)(n) <= not (m_lvl(n/2)) and not(m_lvl(n/2+4))
                                            and not(m_lvl(n/2+8)) and m_lvl(n/2+12);
                            end generate MASTER_THREE;
                        end generate EVEN_QUAD_ZERO;

                        ODD_QUAD_ZERO: if n mod 2 = 1 generate -- odd indexes
                            lutout(i)(j)(n) <= zero;
                        end generate ODD_QUAD_ZERO;

                end generate QUAD_ZERO;

                OTHER_QUADS: if i /= 0 generate      -- assign values for other quadrants

                        ZEROMUX_NZ_QUAD: if n=0 generate

                            ZERO_MASTER: if j=0 generate     -- master 0 of this quad is highest priority
                                lutout(i)(j)(n) <= m_lvl(i*16+(n/2));
                            end generate ZERO_MASTER;

                            ONE_MASTER: if j=1 generate     -- determine priority for master1 in this quad
                                lutout(i)(j)(n) <= not(m_lvl(i*16+(n/2))) and m_lvl(i*16+(n/2)+4);
                            end generate ONE_MASTER;

                            TWO_MASTER: if j=2 generate     -- determine priority for master2 in this quad
                                lutout(i)(j)(n) <= not(m_lvl(i*16+(n/2))) and not(m_lvl(i*16+(n/2)+4))
                                            and m_lvl(i*16+(n/2)+8);
                            end generate TWO_MASTER;

                            THREE_MASTER: if j=3 generate     -- determine priority for master3 in this quad
                            --    lutout(i)(j)(n) <= not (m_lvl(i*16+(n/2))) and not(m_lvl((n/2)+4))
                            --                and not(m_lvl((n/2)+8)) and m_lvl(i*16+(n/2)+12);
                                lutout(i)(j)(n) <= not (m_lvl(i*16+(n/2))) and not(m_lvl(i*16+(n/2)+4))
                                            and not(m_lvl(i*16+(n/2)+8)) and m_lvl(i*16+(n/2)+12);
                            end generate THREE_MASTER;
                        end generate ZEROMUX_NZ_QUAD;

                        ODDMUX_NZ_QUAD: if n mod 2 = 1 generate

                            ZERO_MASTER: if j=0 generate     -- master 0 of this quad is highest priority
                                lutout(i)(j)(n) <= m_lvl(i*16+(n+1)/2);
                            end generate ZERO_MASTER;

                            ONE_MASTER: if j=1 generate     -- determine priority for master1
                                lutout(i)(j)(n) <= not(m_lvl(i*16+((n+1)/2))) and m_lvl(i*16+((n+1)/2)+4);
                            end generate ONE_MASTER;

                            TWO_MASTER: if j=2 generate     -- determine priority for master2
                                lutout(i)(j)(n) <= not(m_lvl(i*16+((n+1)/2))) and not(m_lvl(i*16+((n+1)/2)+4))
                                            and m_lvl(i*16+((n+1)/2)+8);
                            end generate TWO_MASTER;

                            THREE_MASTER: if j=3 generate     -- determine priority for master3
                                lutout(i)(j)(n) <= not (m_lvl(i*16+((n+1)/2))) and not(m_lvl(i*16+((n+1)/2)+4))
                                            and not(m_lvl(i*16+((n+1)/2)+8)) and m_lvl(i*16+((n+1)/2)+12);
                            end generate THREE_MASTER;
                        end generate ODDMUX_NZ_QUAD;

                        EVEN_NONZERO_QUAD: if n/=0 and n mod 2 =0 generate
                            lutout(i)(j)(n) <= zero;
                        end generate EVEN_NONZERO_QUAD;

                end generate OTHER_QUADS;

            end generate MUXCY_LOOP;

        end generate MSTRLOOP;
end generate LUTOUT_GEN;

-------------------------------------------------------------------------------
-- Generate the carry chains
-------------------------------------------------------------------------------
MUXCY_GEN: for i in 0 to NUM_QUADS-1 generate -- loop through each quadrant

        QZ: if i = 0 generate           -- quadrant 0 is special

                QZ_MSTRS: for j in 0 to 3 generate    -- loop through each master in each quadrant

                    FIRSTMUX: MUXCY         -- first mux is special
                        port map (CI => zero,
                              DI => lutout(i)(j)(0),
                              S => q_sel(i)(0),
                              O => cyout(i)(j)(0)
                              );

                    OTHERMUXES: for n in 1 to NUM_MUX-1 generate

                        MUXES: MUXCY
                            port map (CI => cyout(i)(j)(n-1),
                                  DI => lutout(i)(j)(n),
                                  S => q_sel(i)(n),
                                  O => cyout(i)(j)(n)
                                  );
                    end generate OTHERMUXES;

                    prioencdrOutput(i*4+j) <= cyout(i)(j)(NUM_MUX-1);

            end generate QZ_MSTRS;

        end generate QZ;

        QNZ: if i /= 0 generate           -- quadrant 0 is special

            QNZ_MSTRS: for j in 0 to 3 generate    -- loop through each master in each quadrant

                    MUXFIRST: MUXCY         -- first mux is special
                        port map (CI => lutout(i)(j)(0),
                              DI => zero,
                              S => q_sel(i)(0),
                              O => cyout(i)(j)(0)
                              );

                    RESTMUXES: for n in 1 to NUM_MUX-1 generate

                        MUXES: MUXCY
                            port map (CI => cyout(i)(j)(n-1),
                                  DI => lutout(i)(j)(n),
                                  S => q_sel(i)(n),
                                  O  => cyout(i)(j)(n)
                                  );
                    end generate RESTMUXES;

                prioencdrOutput(i*4+j) <= cyout(i)(j)(NUM_MUX-1);

            end generate QNZ_MSTRS;

        end generate QNZ;

end generate MUXCY_GEN;

end simulation;
