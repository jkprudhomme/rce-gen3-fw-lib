--*****************************************************************************
-- Copyright (c) 2006-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, Inc.
-- All Rights Reserved
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: $Name:  $
--  \   \         Application: MIG
--  /   /         Filename: idelay_ctrl.v
-- /___/   /\     Date Last Modified: $Date: 2007/08/28 06:46:24 $
-- \   \  /  \    Date Created: Wed Aug 16 2006
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR2
--Purpose:
--   This module instantiates the IDELAYCTRL primitive of the Virtex-5 device
--   which continously calibrates the IDELAY elements in the region in case of
--   varying operating conditions. It takes a 200MHz clock as an input
--Reference:
--Revision History:
--   Rev 1.1 - Translated from Verilog to VHDL. 7/30/07
--   Rev 1.2 - Updated copyright MD 8/27/07
--*****************************************************************************

--*****************************************************************************
--$Id: idelay_ctrl.vhd,v 1.2 2007/08/28 06:46:24 richc Exp $
--$Date: 2007/08/28 06:46:24 $
--$Author: richc $
--$Revision: 1.2 $
--$Source: /devl/xcs/repo/groups/apd_mem/Virtex5/designs/2_0/ddr2/rtl/vhdl/idelay_ctrl.vhd,v $
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity idelay_ctrl is
  generic (
    -- Following parameters are for 72-bit RDIMM design (for ML561 Reference
    -- board design). Actual values may be different. Actual parameters values
    -- are passed from design top module mig_31 module. Please refer to
    -- the mig_31 module for actual values.
    IODELAY_GRP    : string  := "IODELAY_MIG"
    );
  port (
    clk200           : in std_logic;
    rst200           : in std_logic;
    idelay_ctrl_rdy  : out std_logic
  );
end entity idelay_ctrl;

architecture syn of idelay_ctrl is
  
  attribute IODELAY_GROUP : string;
  attribute IODELAY_GROUP of u_idelayctrl : label is IODELAY_GRP;
begin
  
  u_idelayctrl : IDELAYCTRL
    port map (
      rdy     => idelay_ctrl_rdy,
      refclk  => clk200,
      rst     => rst200
    );
  
end architecture syn;
