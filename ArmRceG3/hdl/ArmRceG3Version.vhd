-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Version File
-- File          : ArmRceG3Version.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 10/26/2013
-------------------------------------------------------------------------------
-- Description:
-- Version file for ARM based rce generation 3 processor core.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 10/26/2013: created.
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package ArmRceG3Version is

constant ArmRceG3Version : std_logic_vector(31 downto 0) := x"00000004";

end ArmRceG3Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 10/26/2013 (0x00000001): Initial Version
-- 11/05/2013 (0x00000002): Changed outbound free list FIFO implementation.
-- 03/07/2014 (0x00000003): Updated register structure and map.
-- 03/25/2014 (0x00000004): PPI Interface Change
-------------------------------------------------------------------------------

