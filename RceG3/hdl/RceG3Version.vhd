-------------------------------------------------------------------------------
-- Title         : RCE Generation 3, Version File
-- File          : RceG3Version.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 10/26/2013
-------------------------------------------------------------------------------
-- Description:
-- Version file for ARM based rce generation 3 processor core.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 10/26/2013: created.
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package RceG3Version is

constant RCE_G3_VERSION_C : std_logic_vector(31 downto 0) := x"00000013";

end RceG3Version;

----------------------------------------------------------------------------------
-- Revision History:
-- 10/26/2013 (0x00000001): Initial Version
-- 11/05/2013 (0x00000002): Changed outbound free list FIFO implementation.
-- 03/07/2014 (0x00000003): Updated register structure and map.
-- 03/25/2014 (0x00000004): PPI Interface Change
-- 05/08/2014 (0x00000010): Complete PPI re-write
-- 08/01/2014 (0x00000011): Added E-Fuse
-- 08/19/2014 (0x00000012): Added Ethernet Mode, Added E-Fuse and EthMode to BSI
-- 02/22/2017 (0x00000013): Added new build system fields to version registers.
----------------------------------------------------------------------------------

