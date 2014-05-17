#-------------------------------------------------------------------------------
#-- Title         : Common Eval Core Constraints
#-- File          : EvalCore.xdc
#-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
#-- Created       : 11/14/2013
#-------------------------------------------------------------------------------
#-- Description:
#-- Common top level constraints for Eval
#-------------------------------------------------------------------------------
#-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
#-------------------------------------------------------------------------------
#-- Modification history:
#-- 11/14/2013: created.
#-------------------------------------------------------------------------------

# CPU Clock
create_clock -name fclk0 -period 10 [get_pins U_EvalCore/U_RceG3Top/U_RceG3Cpu/U_PS7/inst/PS7_i/FCLKCLK[0]]

# Arm Core Clocks
set fclk0Group     [get_clocks -of_objects \
   [get_pins U_EvalCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKIN1]]
set dmaClkGroup    [get_clocks -of_objects \
   [get_pins U_EvalCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT0]]
set sysClk200Group [get_clocks -of_objects \
   [get_pins U_EvalCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT1]]
set sysClk125Group [get_clocks -of_objects \
   [get_pins U_EvalCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT2]]

# Set Asynchronous Paths
set_clock_groups -asynchronous -group ${fclk0Group} \
                               -group ${dmaClkGroup} \
                               -group ${sysClk200Group} \
                               -group ${sysClk125Group} 

# StdLib
set_property ASYNC_REG TRUE [get_cells -hierarchical *crossDomainSyncReg_reg*]

# Locations
set_property PACKAGE_PIN Y11  [get_ports i2cScl]
set_property PACKAGE_PIN AA11 [get_ports i2cSda]

# Standards
set_property IOSTANDARD LVCMOS25 [get_ports i2cScl]
set_property IOSTANDARD LVCMOS25 [get_ports i2cSda]

