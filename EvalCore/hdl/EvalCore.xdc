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

# Arm Core Clocks
create_clock -name fclkClk0 -period 10 \
   [get_pins U_EvalCore/U_ArmRceG3Top/U_ArmRceG3Cpu/U_PS7/U0/PS7_i/FCLKCLK[0]]
set axiClkGroup    [get_clocks -of_objects \
   [get_pins U_EvalCore/U_ArmRceG3Top/U_ArmRceG3Clocks/U_ClockGen/CLKOUT0]]
set sysClk200Group [get_clocks -of_objects \
   [get_pins U_EvalCore/U_ArmRceG3Top/U_ArmRceG3Clocks/U_ClockGen/CLKOUT1]]
set sysClk125Group [get_clocks -of_objects \
   [get_pins U_EvalCore/U_ArmRceG3Top/U_ArmRceG3Clocks/U_ClockGen/CLKOUT2]]

# StdLib
set_property ASYNC_REG TRUE [get_cells -hierarchical *crossDomainSyncReg_reg*]

# Reset Fanout
set_property MAX_FANOUT 100 [get_nets U_EvalCore/U_ArmRceG3Top/U_ArmRceG3Clocks/axiClkRst]
set_property MAX_FANOUT 100 [get_nets U_EvalCore/U_ArmRceG3Top/U_ArmRceG3Clocks/sysClk200Rst]
set_property MAX_FANOUT 100 [get_nets U_EvalCore/U_ArmRceG3Top/U_ArmRceG3Clocks/sysClk125Rst]

# Locations
set_property PACKAGE_PIN Y11  [get_ports i2cScl]
set_property PACKAGE_PIN AA11 [get_ports i2cSda]

# Standards
set_property IOSTANDARD LVCMOS25 [get_ports i2cScl]
set_property IOSTANDARD LVCMOS25 [get_ports i2cSda]

