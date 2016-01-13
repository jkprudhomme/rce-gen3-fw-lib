-------------------------------------------------------------------------------
-- Title         : Version Constant File
-- Project       : COB DPM
-------------------------------------------------------------------------------
-- File          : Version.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/03/2013
-------------------------------------------------------------------------------
-- Description:
-- Version Constant Module
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE PPI Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE PPI Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package Version is

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"F1000103"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "Sim Test";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 04/03/2013 (0xF1000001): Initial Version
-- 04/18/2013 (0xF1000003): Added event test
-- 04/22/2013 (0xF1000004): Changed signals
-- 04/23/2013 (0xF1000005): Modified event control with handshake
-- 04/23/2013 (0xF1000006): Cleaned up eventI generation
-- 04/23/2013 (0xF1000007): Added debug
-- 04/24/2013 (0xF1000008): Added debug
-- 04/25/2013 (0xF1000009): Setup user flag
-- 04/28/2013 (0xF100000A): Added I2C
-- 04/30/2013 (0xF1000010): New structure, new FIFO interface
-- 05/03/2013 (0xF1000012): Interrupts added
-- 05/03/2013 (0xF1000100): Updated FIFO block
-- 05/03/2013 (0xF1000101): PCIexpress and ethernet hooks.
-- 05/03/2013 (0xF1000102): Fixed FIFO interrupts
-- 06/14/2013 (0xF1000103): Changed buffer structure per Mike
-------------------------------------------------------------------------------

