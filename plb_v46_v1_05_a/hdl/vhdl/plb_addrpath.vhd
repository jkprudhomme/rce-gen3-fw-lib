-------------------------------------------------------------------------------
--  $Id: plb_addrpath.vhd,v 1.1.2.1 2010/07/13 16:33:56 srid Exp $
-------------------------------------------------------------------------------
-- plb_addrpath.vhd - entity/architecture pair
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
-- Filename:        plb_addrpath.vhd
-- Version:         v1.04a
-- Description:     This file contains the address and transaction qualifier
--                  multiplexors.
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
-- -Switched to v2_00_a for proc_common.
-- -Changed structure section to a reference to plb_v46.vhd.
-- ~~~~~~
--  FLO         06/09/05        
-- ^^^^^^
-- -Added ports M_TAttribute and PLB_TAttribute and removed these signals
--  that are subsumed by 'TAttribure':   M_compress,   M_guarded,   M_ordered,
--                                     PLB_compress, PLB_guarded, PLB_ordered
-- -Removed component declarations in favor of direct entity instantiation.
-- ~~~~~~
--  FLO         09/09/05        
-- ^^^^^^
-- -Added UABus.
-- ~~~~~~
--  FLO         12/02/05        
-- ^^^^^^
-- -Added C_FAMILY generic.
-- -Changed mux_onehot instances to mux_onehot_f.
-- ~~~~~
--  JLJ         04/10/07    
-- ^^^^^^
--  Added register process on all output signals.
--  Required adding input signals, Clk & Rst.
-- ~~~~~
--  JLJ         06/07/07    
-- ^^^^^^
--  Fix Questa 6.3 load bug evaluating M_UABus as [0:-1]. Update port mapping 
--  allowable size values => always assume M_UABus = 32-bits wide.
-- ~~~~~
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


-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Generics:
--          C_NUM_MASTERS               -- number of masters
--          C_PLB_AWIDTH                -- address bus width
--          C_PLB_DWIDTH                -- data bus width
--
-- Definition of Ports:
--
--          input Clk
--          input Rst
--
--      --  Master signals
--          input M_TAttribute
--          input M_lockErr
--          input M_ABus
--          input M_UABus
--          input M_BE
--          input M_size
--          input M_type
--          input M_MSize
--
--      -- Arbitration signals
--          input ArbAddrSelReg         -- contains the ID of the bus master
--          output ArbBurstReq
--
--      -- PLB signals
--          output PLB_TAttribute
--          output PLB_lockErr
--          output PLB_ABus
--          output PLB_UABus
--          output PLB_BE
--          output PLB_size
--          output PLB_type
--          output PLB_MSize
--
-------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------
entity plb_addrpath is
  generic ( C_NUM_MASTERS   : integer;
            C_PLB_AWIDTH    : integer;
            C_PLB_DWIDTH    : integer;
            C_FAMILY        : string
          );
  port (
        Clk             : in std_logic;
        Rst             : in std_logic;
        M_TAttribute    : in std_logic_vector(0 to C_NUM_MASTERS * 16 - 1 );
        M_lockErr       : in std_logic_vector(0 to C_NUM_MASTERS - 1 );
        ArbAddrSelReg   : in std_logic_vector (0 to C_NUM_MASTERS - 1);
        M_ABus          : in std_logic_vector(0 to (C_NUM_MASTERS * 32) - 1 );
        --M_UABus         : in std_logic_vector(0 to (C_NUM_MASTERS *
        --                                            (C_PLB_AWIDTH-32)) - 1 );
        M_UABus         : in std_logic_vector(0 to (C_NUM_MASTERS * 32) - 1 ); 
        M_BE            : in std_logic_vector(0 to (C_NUM_MASTERS *
                                                    C_PLB_DWIDTH/8) - 1 );
        M_size          : in std_logic_vector(0 to (C_NUM_MASTERS * 4) - 1 );
        M_type          : in std_logic_vector(0 to (C_NUM_MASTERS * 3) - 1 );
        M_MSize         : in std_logic_vector(0 to (C_NUM_MASTERS * 2) - 1 );
        PLB_TAttribute  : out std_logic_vector(0 to 15 );
        PLB_lockErr     : out std_logic;
        ArbBurstReq     : out std_logic;
        PLB_ABus        : out std_logic_vector (0 to 31);
        --PLB_UABus       : out std_logic_vector (0 to C_PLB_AWIDTH-32 - 1 );
        PLB_UABus       : out std_logic_vector (0 to C_PLB_AWIDTH - 1 );
        PLB_BE          : out std_logic_vector(0 to C_PLB_DWIDTH/8 -1 );
        PLB_size        : out std_logic_vector(0 to 3 );
        PLB_type        : out std_logic_vector(0 to 2 );
        PLB_MSize       : out std_logic_vector(0 to 1 )
        );
end plb_addrpath;
 
 
-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture implementation of plb_addrpath is

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------

-- the following signal is declared as std logic vectors 0 to 0 so that the
-- type matches the type required by mux_onehot
signal plb_lockerr_i    : std_logic_vector(0 to 0);

-- internal signals from mux stage to output register stage
signal plb_abus_i       : std_logic_vector(0 to 31);
--signal plb_uabus_i      : std_logic_vector (0 to C_PLB_AWIDTH-32 - 1);
signal plb_uabus_i      : std_logic_vector (0 to C_PLB_AWIDTH - 1);
signal plb_be_i         : std_logic_vector(0 to C_PLB_DWIDTH/8 -1);
signal plb_size_i       : std_logic_vector(0 to 3);
signal plb_type_i       : std_logic_vector(0 to 2);
signal plb_tattribute_i : std_logic_vector(0 to 15);
signal plb_msize_i      : std_logic_vector(0 to 1);


-------------------------------------------------------------------------------
-- Component Declarations
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin
 
-- Assign output signals 
--PLB_size        <= plb_size_i;
--PLB_TAttribute  <= plb_tattribute_i;
--PLB_lockErr     <= plb_lockerr_i(0);

--    arbBurstReq generation
ArbBurstReq <= plb_size_i(0);
 
-- Add register stage on output signals
REG_PROCESS: process (Clk)
begin 
    if (Clk'event and Clk = '1' ) then
        if (Rst = RESET_ACTIVE) then
            PLB_ABus <= (others => '0');
            PLB_UABus <= (others => '0');
            PLB_BE <= (others => '0');
            PLB_size <= (others => '0');
            PLB_type <= (others => '0');
            PLB_TAttribute <= (others => '0');
            PLB_lockErr <= '0';
            PLB_MSize <= (others => '0');
        else 
            PLB_ABus <= plb_abus_i;
            PLB_UABus <= plb_uabus_i;
            PLB_BE <= plb_be_i;
            PLB_size <= plb_size_i;
            PLB_type <= plb_type_i;
            PLB_TAttribute <= plb_tattribute_i;
            PLB_lockErr <= plb_lockerr_i(0);
            PLB_MSize <= plb_msize_i;
        end if;
    end if;
end process REG_PROCESS;

-------------------------------------------------------------------------------
-- Component Instantiations
-------------------------------------------------------------------------------
-- Instantiate the one-hot carry mux to multiplex the winning master's abus
-- onto the PLB abus
I_PLBADDR_MUX: entity proc_common_v3_00_a.mux_onehot_f
    generic map ( C_DW  => 32,
                  C_NB  => C_NUM_MASTERS,
                  C_FAMILY => C_FAMILY
                )
    port map    ( D     => M_ABus,
                  S     => ArbAddrSelReg,
--                  Y     => PLB_ABus
                  Y     => plb_abus_i
                );
               
-- Instantiate the one-hot carry mux to multiplex the winning master's uabus
-- onto the PLB uabus
I_PLBUADDR_MUX: entity proc_common_v3_00_a.mux_onehot_f
    generic map ( --C_DW  => C_PLB_AWIDTH - 32,
                  C_DW  => 32,  
                  C_NB  => C_NUM_MASTERS,
                  C_FAMILY => C_FAMILY
                )
    port map    ( D     => M_UABus,
                  S     => ArbAddrSelReg,
--                  Y     => PLB_UABus
                  Y     => plb_uabus_i
                );
                
-- Instantiate the one-hot carry mux to multiplex the winning master's byte 
-- enables onto the PLB byte enables
I_PLBBE_MUX: entity proc_common_v3_00_a.mux_onehot_f
    generic map ( C_DW  => C_PLB_DWIDTH/8,
                  C_NB  => C_NUM_MASTERS,
                  C_FAMILY => C_FAMILY
                )
    port map    ( D     => M_BE,
                  S     => ArbAddrSelReg,
--                  Y     => PLB_BE
                  Y     => plb_be_i
                );
                
-- Instantiate the one-hot carry mux to multiplex the winning master's size
-- onto the PLB size
I_PLBSIZE_MUX: entity proc_common_v3_00_a.mux_onehot_f
    generic map ( C_DW  => 4,
                  C_NB  => C_NUM_MASTERS,
                  C_FAMILY => C_FAMILY
                )
    port map    ( D     => M_size,
                  S     => ArbAddrSelReg,
                  Y     => plb_size_i
                );
 
-- Instantiate the one-hot carry mux to multiplex the winning master's type
-- onto the PLB type
I_PLBTYPE_MUX: entity proc_common_v3_00_a.mux_onehot_f
    generic map ( C_DW  => 3,
                  C_NB  => C_NUM_MASTERS,
                  C_FAMILY => C_FAMILY
                )
    port map    ( D     => M_type,
                  S     => ArbAddrSelReg,
--                  Y     => PLB_type
                  Y     => plb_type_i
                );

-- Instantiate the one-hot carry mux to multiplex the winning master's compress
-- signal onto the PLB compress signal
I_PLBCMPRS_MUX: entity proc_common_v3_00_a.mux_onehot_f
    generic map ( C_DW  => 16,
                  C_NB  => C_NUM_MASTERS,
                  C_FAMILY => C_FAMILY
                )
    port map    ( D     => M_TAttribute,
                  S     => ArbAddrSelReg,
                  Y     => plb_tattribute_i
                );

-- Instantiate the one-hot carry mux to multiplex the winning master's lock
-- error signal onto the PLB lock error signal
I_PLBLOCKERR_MUX: entity proc_common_v3_00_a.mux_onehot_f
    generic map ( C_DW  => 1,
                  C_NB  => C_NUM_MASTERS,
                  C_FAMILY => C_FAMILY
                )
    port map    ( D     => M_lockErr,
                  S     => ArbAddrSelReg,
                  Y     => plb_lockerr_i(0 to 0)
                );
 
-- Instantiate the one-hot carry mux to multiplex the winning master's msize
-- signal onto the PLB msize signal
I_PLBMSIZE_MUX: entity proc_common_v3_00_a.mux_onehot_f
    generic map ( C_DW  => 2,
                  C_NB  => C_NUM_MASTERS,
                  C_FAMILY => C_FAMILY
                )
    port map    ( D     => M_MSize,
                  S     => ArbAddrSelReg,
--                  Y     => PLB_MSize
                  Y     => plb_msize_i
                );
 
end implementation;

