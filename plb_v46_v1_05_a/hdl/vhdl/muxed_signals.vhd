-------------------------------------------------------------------------------
--  $Id: muxed_signals.vhd,v 1.1.2.1 2010/07/13 16:33:55 srid Exp $
-------------------------------------------------------------------------------
-- muxed_signals.vhd - entity/architecture pair
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
--  Filename:        muxed_signals.vhd
--  Version:         v1.04a
--  Description:     This file contains the multiplexors which route the 
--                   the controlling master's signals to the PLB bus and 
--                   the slave's signal to the controlling master.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:  (see plb_v46.vhd)
--
-------------------------------------------------------------------------------
--  Author:      Bert Tise
--  History:
--      ALS     02/20/02        -- created from plb_arbiter_v1_01_a
--      ALS     04/16/02        -- Version v1.01a
-- ~~~~~~
--  FLO         06/01/05        
-- ^^^^^^
-- Start of changes for plb_v46.
-- -PLB_MErr split into PLB_MRdErr and PLB_MWrErr (Rd and Wr versions).
-- -Sl_MErr split into Sl_MRdErr and Sl_MWrErr.
-- -Removed component declarations in favor of direct entity instantiation.
-- ~~~~~~
--  FLO         06/08/05        
-- ^^^^^^
-- -Switched to v2_00_a for proc_common.
-- -Eliminated aspects related to the watchdog timer completing hanshakes on
--  timeout.
-- -Changed structure section to a reference to plb_v46.vhd.
-- -Added generation of PLB_MTimeout.
-- ~~~~~~
--  FLO         06/15/05        
-- ^^^^^^
-- -Now using selected names in direct-entity instantiations.
-- ~~~~~~
--  FLO         07/19/05        
-- ^^^^^^
-- -Changed to active low WdtMTimeout_n
-- ~~~~~~
--  FLO         08/26/05        
-- ^^^^^^
-- -Removed signal ArbAValid.
-- -Signals PLB_MAddrAck and PLB_MRearbitrate no longer depend on
--  pavalid or savalid.
-- ~~~~~
--  FLO         12/02/05        
-- ^^^^^^
-- -Added C_FAMILY generic.
-- -Changed mux_onehot instances to mux_onehot_f.
-- ~~~~~
--  JLJ         05/10/07  
-- ^^^^^^
--  Added Sl_wrComp signal to wrBurst logic.
-- ~~~~~
--  JLJ         05/23/07  
-- ^^^^^^
--  Modified Sl_wrComp signal logic used in wrBurst logic.
-- ~~~~~
--  JLJ         05/24/07  
-- ^^^^^^
--  Added RNW to wrBurst logic (combined with PAValid).
-- ~~~~~
--  JLJ         05/30/07  
-- ^^^^^^
--  Update wrBurst logic to account for secondary write transactions.
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
--  Remove M_abort input signal, PLB_abort output signal and usage.
-- ~~~~~~
--  JLJ         12/11/07    v1.02a  
-- ^^^^^^
--  Modified proc_common include statements.
-- ~~~~~~
--  JLJ         03/17/08    v1.03a  
-- ^^^^^^
--  Upgraded to v1.03a. 
-- ~~~~~~
--  JLJ         05/14/08    v1.04a  
-- ^^^^^^
--  Updated to v1.04a (to migrate using proc_common_v3_00_a) in EDK L.
-- ~~~~~~
--  JLJ         05/22/08    v1.04a  
-- ^^^^^^
--  Redesign PLB Master ID signal assignment logic to remove usage of
--  or_bits from proc_common_v3_00_a library.
-- ~~~~~~
--  JLJ         09/05/08    v1.04a  
-- ^^^^^^
--  Further re-design of above edits for or_bits.  Synthesis errors
--  with update HDL.  Creating a local or_bits module which infers
--  the inner logic loop in creating the plb_masterid_i signal.
-- ~~~~~~
--  JLJ         09/10/08    v1.04a  
-- ^^^^^^
--  Added library statement for plb_v46_v1_05_a.or_bits.
--  Update disclaimer of liability.
-- ~~~~~~
--
-- -----------------------------------------------------------------------------
--  Naming Conventions:
--       active low signals:                     "*_n"
--       clock signals:                          "clk", "clk_div#", "clk_#x"
--       reset signals:                          "rst", "rst_n"
--       generics:                               "C_*"
--       user defined types:                     "*_TYPE"
--       state machine next state:               "*_ns"
--       state machine current state:            "*_cs"
--       combinatorial signals:                  "*_cmb"
--       pipelined or register delay signals:    "*_d#"
--       counter signals:                        "*cnt*"
--       clock enable signals:                   "*_ce"
--       internal version of output port         "*_i"
--       device pins:                            "*_pin"
--       ports:                                  - Names begin with Uppercase
--       processes:                              "*_PROCESS"
--       component instantiations:               "<ENTITY_>I_<#|FUNC>
-- -----------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.RESET_ACTIVE;
use proc_common_v3_00_a.proc_common_pkg.clog2;

library plb_v46_v1_05_a;
use plb_v46_v1_05_a.or_bits;


-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_NUM_MASTERS               -- number of masters
--      C_NUM_MSTRS_PAD             -- number of masters padded to power of 2
--      C_MID_BITS                  -- number of bits to encode master id
--
-- Definition of Ports:
--      -- Master signals
--      input  M_busLock
--      input  M_RNW    
--      input  M_rdBurst
--      input  M_wrBurst
--      
--      -- Slave signals
--      input  Sl_addrAck    
--      input  Sl_SSize      
--      input  Sl_rearbitrate
--      input  Sl_MBusy      
--      input  Sl_rdBTerm
--      input  Sl_wrBTerm
--      input  Sl_MRdErr
--      input  Sl_MWrErr
--
--      -- Arbiter signals
--      input  ArbAddrSelReg   
--      input  ArbAddrSelRegPad
--      input  ArbPriRdMasterReg   
--      input  ArbPriRdMasterRegReg
--      input  ArbPriWrMasterReg   
--      input  ArbWrDBusBusyReg
--      input  ArbPriRdBurstReg
--
--      -- Watchdog Timer signals
--      input  WdtMTimeout_n
--
--      -- PLB signals
--      input  PLB_PAValid
--      input  PLB_SAValid
--      input  PLB_rdPrimReg
--      output PLB_masterID     
--      output PLB_RNW          
--      output PLB_MAddrAck     
--      output PLB_MTimeout     
--      output PLB_MSSize           
--      output PLB_MRearbitrate 
--      output PLB_MBusy        
--      output PLB_rdBurst
--      output PLB_MRdBTerm     
--      output PLB_wrBurst      
--      output PLB_MWrBTerm     
--      output PLB_MRdErr  
--      output PLB_MWrErr  
--      output Mstr_buslock
-------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------
-- Entity Section
-------------------------------------------------------------------------------
entity muxed_signals is
    generic ( C_NUM_MASTERS     : integer;
              C_NUM_MSTRS_PAD   : integer;
              C_MID_BITS        : integer;
              C_FAMILY          : string
            );
    port (
        M_busLock           : in std_logic_vector (0 to C_NUM_MASTERS-1);
        M_RNW               : in std_logic_vector (0 to C_NUM_MASTERS-1);
        Sl_addrAck          : in std_logic;
        Sl_SSize            : in std_logic_vector (0 to 1);
        Sl_rearbitrate      : in std_logic;
        Sl_MBusy            : in std_logic_vector (0 to C_NUM_MASTERS-1);
        M_rdBurst           : in std_logic_vector (0 to C_NUM_MASTERS-1);
        Sl_rdBTerm          : in std_logic;
        M_wrBurst           : in std_logic_vector (0 to C_NUM_MASTERS-1);
        Sl_wrBTerm          : in std_logic;
        Sl_MRdErr           : in std_logic_vector (0 to C_NUM_MASTERS-1);
        Sl_MWrErr           : in std_logic_vector (0 to C_NUM_MASTERS-1);
        Sl_wrComp           : in std_logic;
        WdtMTimeout_n       : in std_logic;
        ArbAddrSelReg       : in std_logic_vector (0 to C_NUM_MASTERS-1);
        ArbAddrSelRegPad    : in std_logic_vector (0 to C_NUM_MSTRS_PAD-1);
        PLB_PAValid         : in std_logic;
        PLB_SAValid         : in std_logic;
        ArbPriRdMasterReg   : in std_logic_vector (0 to C_NUM_MASTERS-1);
        ArbPriRdMasterRegReg: in std_logic_vector (0 to C_NUM_MASTERS-1);
        ArbPriWrMasterReg   : in std_logic_vector (0 to C_NUM_MASTERS-1);
        ArbWrDBusBusyReg    : in std_logic;
        Mstr_buslock        : out std_logic;
        PLB_masterID        : out std_logic_vector (0 to C_MID_BITS-1);
        PLB_RNW             : out std_logic;
        PLB_MAddrAck        : out std_logic_vector (0 to C_NUM_MASTERS-1);
        PLB_MTimeout        : out std_logic_vector (0 to C_NUM_MASTERS-1);
        PLB_MSSize              : out std_logic_vector (0 to (C_NUM_MASTERS * 2)-1);
        PLB_MRearbitrate    : out std_logic_vector (0 to C_NUM_MASTERS-1);
        PLB_MBusy           : out std_logic_vector (0 to C_NUM_MASTERS-1);
        PLB_rdBurst         : out std_logic;
        PLB_rdPrimReg       : in  std_logic;
        PLB_MRdBTerm        : out std_logic_vector (0 to C_NUM_MASTERS-1);
        PLB_wrBurst         : out std_logic;
        PLB_MWrBTerm        : out std_logic_vector (0 to C_NUM_MASTERS-1);
        PLB_MRdErr          : out std_logic_vector (0 to C_NUM_MASTERS-1);
        PLB_MWrErr          : out std_logic_vector (0 to C_NUM_MASTERS-1);
        ArbPriRdBurstReg    : in std_logic;
        Clk                 : in std_logic;
        ArbReset            : in std_logic
        );
end muxed_signals;

 
-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------
architecture implementation of muxed_signals is

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------

-- when number of masters=2, a special case exists because 2 is a power of 2,
-- but is not a multiple of 4. Therefore, NUM_MSTRS_PAD =4 (padded to nearest
-- multiple of 4), but C_MID_BITS = 1 (log2(2)) not =2 (log2(4)). Therefore
-- the calculation of the master id doesn't work properly for this case. 
-- define an internal signal for the master id. When number of masters >2, the
-- output PLB_masterID will simply equal this signal, otherwise it will be
-- bit 1 of this signal.
signal plb_masterid_i   : std_logic_vector(0 to clog2(C_NUM_MSTRS_PAD)-1);

-- intermediate burst signals
signal rd_burst     : std_logic_vector(0 to 0);
signal wr_burst     : std_logic_vector(0 to 0);

-- create internal versions of output signals which need to be 
-- std_logic_vector(0 to 0) to properly attach to the mux_onehot_f
signal buslock_i    : std_logic_vector(0 to 0);
signal plb_rnw_i    : std_logic_vector(0 to 0);

signal wrburst_rst  : std_logic;

-------------------------------------------------------------------------------
-- Component Declarations
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin

-------------------------------------------------------------------------------
-- BusLock generation
-------------------------------------------------------------------------------
--
--  3-19-01 ALS - Removed qualification with PLB_PAValid
--  3-20-01 ALS - Change PLB_busLock to BusLock; arbiter control state machine
--                now generates PLB_busLock
--  5-01-01 ALS - Changed name of BusLock to Mstr_buslock
--
-- Use one-hot carry mux for BusLock generation

BUSLOCK_MUX: entity proc_common_v3_00_a.mux_onehot_f
    generic map (   C_DW    => 1,
                    C_NB    => C_NUM_MASTERS,
                    C_FAMILY => C_FAMILY)
    port map    (
                    D       => M_busLock,
                    S       => ArbAddrSelReg,
                    Y       => busLock_i(0 to 0)
                );
Mstr_buslock <= busLock_i(0);

-------------------------------------------------------------------------------
-- PLB_masterID generation
-------------------------------------------------------------------------------
-- Note this logic uses the padded version of C_NUM_MASTERS to insure that 
-- the calculations are on a constant which is a power of 2
-- Have to loop for the number of bits required for the padded number of masters

PLB_MID_GENERATE: for i in 0 to clog2(C_NUM_MSTRS_PAD)-1 generate

signal temp_or      : std_logic_vector(0 to 2**i) := (others => '0');

begin
    OR_GENERATE: for j in 1 to 2**i generate
        
        
        -- v1.04a 
        -- Remove usage of or_bits from proc_common_v3_00_a library
        -- Only optimized for FPGA architectures with LUT4 components
        -- Due to family differences, re-design this to let XST infer
        -- the optimal implementation.
        --
        -- BUS_OR: entity proc_common_v3_00_a.or_bits
        --     generic map ( C_NUM_BITS    => C_NUM_MSTRS_PAD/2**(i+1),
        --                   C_START_BIT   => C_NUM_MSTRS_PAD/2**(i+1)
        --                                     + (j-1)*C_NUM_MSTRS_PAD/2**i,
        --                   C_BUS_SIZE    => C_NUM_MSTRS_PAD
        --                 )
        --     port map (
        --                 In_Bus      => ArbAddrSelRegPad,
        --                 Sig         => temp_or(j-1),
        --                 Or_out      => temp_or(j)
        --              );
                                         

        -- Additional updates on v1.04a
        -- Synthesis errors introducted with inner loop of this process
        -- Attempts to change the variable from 'i' to 'k', but no solution.
        -- Create a seperate or_bits module which includes this inference statement below
        --
        -- OR_BITS_PROCESS: process (ArbAddrSelRegPad, temp_or(j-1), temp_or(j))        
        -- 
        -- variable C_START_BIT    : integer := C_NUM_MSTRS_PAD/2**(i+1) + (j-1)*C_NUM_MSTRS_PAD/2**i;
        -- variable C_NUM_BITS     : integer := C_NUM_MSTRS_PAD/2**(i+1);
        -- variable partial_or     : std_logic_vector(0 to C_NUM_BITS-1) := (others => '0');
        -- 
        -- begin
        --           
        --     for i in 0 to C_NUM_BITS-1 loop
        --     
        --         if(i = 0) then
        --             partial_or(i) := ArbAddrSelRegPad(C_START_BIT) or temp_or(j-1);
        --         else
        --             partial_or(i) := ArbAddrSelRegPad(C_START_BIT+i) or partial_or(i-1);
        --         end if;
        --     
        --     end loop;
        --     
        --     temp_or(j) <= partial_or(C_NUM_BITS-1);
        --     
        -- end process OR_BITS_PROCESS;



        -- New v1.04a HDL                    
        BUS_OR: entity plb_v46_v1_05_a.or_bits
        generic map ( C_NUM_BITS    => C_NUM_MSTRS_PAD/2**(i+1),
                      C_START_BIT   => C_NUM_MSTRS_PAD/2**(i+1)
                                        + (j-1)*C_NUM_MSTRS_PAD/2**i,
                      C_BUS_SIZE    => C_NUM_MSTRS_PAD
                      )
        port map (
                     In_Bus      => ArbAddrSelRegPad,
                     Sig         => temp_or(j-1),
                     Or_out      => temp_or(j)
                  );
                                        


                     
    end generate OR_GENERATE;
    
    
    plb_masterid_i(i) <= temp_or(2**i);

end generate PLB_MID_GENERATE;

-- If number of masters <= 2, then PLB_masterID is only 1 bit, so need to get
-- LSB from plb_masterid_i. Otherwise, PLB_masterID = plb_masterid_i.

TWOMSTR_GEN: if C_NUM_MASTERS <= 2 generate
    PLB_masterID(0) <= plb_masterid_i(1);
end generate TWOMSTR_GEN;

OTHERMSTR_GEN: if C_NUM_MASTERS > 2 generate
    PLB_masterID <= plb_masterid_i;
end generate OTHERMSTR_GEN; 

-------------------------------------------------------------------------------
-- PLB_RNW generation
-------------------------------------------------------------------------------
-- Use one-hot carry mux for PLB_RNW generation

RNW_MUX: entity proc_common_v3_00_a.mux_onehot_f
    generic map (   C_DW    => 1,
                    C_NB    => C_NUM_MASTERS,
                    C_FAMILY => C_FAMILY)
    port map    (
                    D       => M_RNW,
                    S       => ArbAddrSelReg,
                    Y       => plb_rnw_i(0 to 0)
                );
PLB_RNW <= plb_rnw_i(0);


-------------------------------------------------------------------------------
-- PLB_MAddrAck generation
-------------------------------------------------------------------------------
MADDRACK_GENERATE: for i in 0 to C_NUM_MASTERS-1 generate

    -- Since a slave may assert its addrack only in response to a valid
    -- primary or secondary address (PLB V4.6 spec, pg 16), there
    -- is no need to qualify PLB_MAddrAck by pavalid or savalid.
    PLB_MAddrAck(i) <= arbAddrSelReg(i) and Sl_addrAck;

end generate MADDRACK_GENERATE;

-------------------------------------------------------------------------------
-- PLB_MTimeout generation
-------------------------------------------------------------------------------
MTIMEOUT_GENERATE: for i in 0 to C_NUM_MASTERS-1 generate

    PLB_MTimeout(i) <= (not wdtMTimeout_n) and arbAddrSelReg(i);

end generate MTIMEOUT_GENERATE;

-------------------------------------------------------------------------------
-- PLB_MSSize     generation
-------------------------------------------------------------------------------
MSSIZE_GENERATE: for i in 0 to C_NUM_MASTERS-1 generate

    PLB_MSSize(i*2 to (i*2)+1) <= Sl_SSize when arbAddrSelReg(i) = '1'
                                    else (others => '0');

end generate MSSIZE_GENERATE;

-------------------------------------------------------------------------------
-- PLB_MRearbitrate generation
-------------------------------------------------------------------------------
MREARB_GENERATE: for i in 0 to C_NUM_MASTERS-1 generate

    -- Qualification with (PLB_PAValid or PLB_SAValid) not needed because a
    -- slave may assert sl_rearbitrate only when either PLB_PAValid or
    -- PLB_SAValid is true. Further, the rearbitrate condition must be
    -- passed from master to slave when either PLB_PAValid or PLB_SAValid
    -- is true (PLB V4.6 spec, pg 17).
    PLB_MRearbitrate(i) <= arbAddrSelReg(i) and Sl_rearbitrate;

end generate MREARB_GENERATE;

-------------------------------------------------------------------------------
-- PLB_MBusy generation
-------------------------------------------------------------------------------
MBUSY_GENERATE: for i in 0 to C_NUM_MASTERS-1 generate

    PLB_MBusy(i) <= Sl_MBusy(i);

end generate MBUSY_GENERATE;


-------------------------------------------------------------------------------
-- PLB_rdBurst generation
-------------------------------------------------------------------------------
-- Use one-hot carry mux for rd_burst generation then AND with arbPriRdBurstReg
-- 4-26-01 ALS
-- Added PLB_rdPrimReg term to PLB_rdBurst - PLB_rdBurst must assert 1 clock after
-- PLB_rdPrim. In most cases this occurs, however in the case where PLB_SAValid,
-- Sl_rdComp, Sl_addrAck,etc. all assert in the same clock, PLB_rdPrim is 
-- is registered so that it asserts one clock after addrAck. However, this then
-- aligns PLB_rdPrim with PLB_rdBurst. Since PLB_rdBurst must assert one clock
-- after PLB_rdPrim, check that PLB_rdPrimReg is zero before assertion. 
-- PLB_rdPrimReg only asserts for one clock, therefore in this situation, 
-- PLB_rdBurst will be delayed one clock.

RDBURST_MUX: entity proc_common_v3_00_a.mux_onehot_f
    generic map (   C_DW    => 1,
                    C_NB    => C_NUM_MASTERS,
                    C_FAMILY => C_FAMILY)
    port map    (
                    D       => M_rdBurst,
                    S       => ArbPriRdMasterReg,
                    Y       => rd_burst
                );

PLB_rdBurst <= '1' when rd_burst = "1" and arbPriRdBurstReg = '1' 
                   and PLB_rdPrimReg = '0'
                else '0';


-------------------------------------------------------------------------------
-- PLB_MRdBTerm generation
-------------------------------------------------------------------------------
MRDBTERM_GENERATE: for i in 0 to C_NUM_MASTERS-1 generate

  PLB_MRdBTerm(i) <= arbPriRdMasterReg(i) and ((Sl_rdBTerm));

end generate MRDBTERM_GENERATE;

-------------------------------------------------------------------------------
-- PLB_wrBurst generation
-------------------------------------------------------------------------------
-- Use one-hot carry mux for wr_burst generation then AND with PLB_PAValid
-- OR arbWrDBusBusyReg to generate PLB_wrBurst
--
-- Add arb_wr_sng to indicate if current arbWrDBusBusyReg is asserted during a write
-- burst or single write.  If single write, do not assert PLB_wrBurst.
-- Useful in case when same master requests burst following a single write request
-- M_wrBurst gets passed out to PLB before valid burst transaction slot.

WRBURST_MUX: entity proc_common_v3_00_a.mux_onehot_f
    generic map (   C_DW    => 1,
                    C_NB    => C_NUM_MASTERS,
                    C_FAMILY => C_FAMILY)
    port map    (
                    D       => M_wrBurst,
                    S       => ArbPriWrMasterReg,
                    Y       => wr_burst
                );
PLB_wrBurst <= '1' when ( wr_burst = "1" and 
                          ((PLB_PAValid = '1' and plb_rnw_i(0) = '0') or (arbWrDBusBusyReg = '1')) and
                          (wrburst_rst = '0'))
                          
                    else '0';
                    
-- Create reset for PLB_wrBurst in cases of same master requesting single write 
-- followed by burst write request
RST_WRBURST_PROCESS: process (Clk)
begin
    if (Clk'event and Clk = '1') then
        if (ArbReset = RESET_ACTIVE) or (Sl_wrComp = '1') then
            wrburst_rst <= '0';
            
        -- If new write operation is a non-burst transaction
        elsif (PLB_PAValid = '1' and Sl_addrAck = '1' and wr_burst = "0" and plb_rnw_i(0) = '0') then
            wrburst_rst <= '1';
        end if;
    end if;
end process RST_WRBURST_PROCESS;

                

-------------------------------------------------------------------------------
-- PLB_MWrBTerm generation
-------------------------------------------------------------------------------
MWRBTERM_GENERATE: for i in 0 to C_NUM_MASTERS-1 generate

  PLB_MWrBTerm(i) <= arbPriWrMasterReg(i) and ((Sl_wrBTerm));

end generate MWRBTERM_GENERATE;
                
-------------------------------------------------------------------------------
-- PLB_MRdErr generation
-------------------------------------------------------------------------------
MRDERR_GENERATE: for i in 0 to C_NUM_MASTERS-1 generate

  PLB_MRdErr(i) <= Sl_MRdErr(i);

end generate MRDERR_GENERATE;

-------------------------------------------------------------------------------
-- PLB_MWrErr generation
-------------------------------------------------------------------------------
MWRERR_GENERATE: for i in 0 to C_NUM_MASTERS-1 generate

  PLB_MWrErr(i) <= Sl_MWrErr(i);

end generate MWRERR_GENERATE;

 
end implementation;

