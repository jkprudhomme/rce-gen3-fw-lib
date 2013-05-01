-------------------------------------------------------------------------------
-- Copyright (c) 2013 Xilinx, Inc.
-- All Rights Reserved
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor     : Xilinx
-- \   \   \/     Version    : 14.2
--  \   \         Application: XILINX CORE Generator
--  /   /         Filename   : zynq_icon.vhd
-- /___/   /\     Timestamp  : Wed Feb 13 15:23:13 PST 2013
-- \   \  /  \
--  \___\/\___\
--
-- Design Name: VHDL Synthesis Wrapper
-------------------------------------------------------------------------------
-- This wrapper is used to integrate with Project Navigator and PlanAhead

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY zynq_icon IS
  port (
    CONTROL0: inout std_logic_vector(35 downto 0));
END zynq_icon;

ARCHITECTURE zynq_icon_a OF zynq_icon IS
BEGIN

END zynq_icon_a;
