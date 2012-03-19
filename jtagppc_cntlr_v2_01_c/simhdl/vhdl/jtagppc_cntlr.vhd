--------------------------------------------------------------------------
-- $Id: jtagppc_cntlr.vhd,v 1.2 2008/07/08 04:23:48 jeffs Exp $
--------------------------------------------------------------------------
-- jtagppc_cntlr.vhd - entity/architecture
--------------------------------------------------------------------------
-- ** Copyright(C) 2004 by Xilinx, Inc. All rights reserved.
-- **
-- ** This text contains proprietary, confidential information of
-- ** Xilinx, Inc. , is distributed by under license from Xilinx, Inc.,
-- ** and may be used, copied and/or disclosed only pursuant to the
-- ** terms of a valid license agreement with Xilinx, Inc.
-- **
-- ** Unmodified source code is guaranteed to place and route,
-- ** function and run at speed according to the datasheet
-- ** specification. Source code is provided "as-is", with no
-- ** obligation on the part of Xilinx to provide support.
-- **
-- ** Xilinx Hotline support of source code IP shall only include
-- ** standard level Xilinx Hotline support, and will only address
-- ** issues and questions related to the standard released Netlist
-- ** version of the core (and thus indirectly, the original core source
-- **
-- ** The Xilinx Support Hotline does not have access to source
-- ** code and therefore cannot answer specific questions related
-- ** to source HDL. The Xilinx Support Hotline will only be able
-- ** to confirm the problem in the Netlist version of the core.
-- **
-- ** This copyright and support notice must be retained as part
-- ** of this text at all times.
-- -------------------------------------------------------------------------
-- Filename: jtagppc_cntlr.vhd
-- Description:
--   Dummy simulation model
-- -----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity jtagppc_cntlr is
  generic (
    C_DEVICE          :     string := "2vp4";
    C_NUM_PPC_USED    :     integer := 0
  );
  port (
    TRSTNEG           : in  std_logic;
    -- Halt control PPC 0
    HALTNEG0          : in  std_logic;
    DBGC405DEBUGHALT0 : out std_logic := '0';
    -- Halt control PPC 1
    HALTNEG1          : in  std_logic;
    DBGC405DEBUGHALT1 : out std_logic := '0';
    -- JTAG Port 0
    C405JTGTDO0       : in  std_logic;
    C405JTGTDOEN0     : in  std_logic;
    JTGC405TCK0       : out std_logic := '1';
    JTGC405TDI0       : out std_logic := '0';
    JTGC405TMS0       : out std_logic := '0';
    JTGC405TRSTNEG0   : out std_logic := '0';
    -- JTAG Port 1
    C405JTGTDO1       : in  std_logic;
    C405JTGTDOEN1     : in  std_logic;
    JTGC405TCK1       : out std_logic := '1';
    JTGC405TDI1       : out std_logic := '0';
    JTGC405TMS1       : out std_logic := '0';
    JTGC405TRSTNEG1   : out std_logic := '0'
    );
    
end jtagppc_cntlr;

architecture simulation of jtagppc_cntlr is
  begin

end simulation ;

