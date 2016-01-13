#-------------------------------------------------------------------------------
#-- Title         : Common Eval Core Constraints
#-- File          : EvalCore.xdc
#-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
#-- Created       : 11/14/2013
#-------------------------------------------------------------------------------
#-- Description:
#-- Common top level constraints for Eval
#-------------------------------------------------------------------------------
## This file is part of 'SLAC RCE Eval Core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'SLAC RCE Eval Core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
#-------------------------------------------------------------------------------
#-- Modification history:
#-- 11/14/2013: created.
#-------------------------------------------------------------------------------

# CPU Clock
set fclk0Pin [get_pins U_EvalCore/U_RceG3Top/U_RceG3Cpu/U_PS7/inst/PS7_i/FCLKCLK[0]]
create_clock -name fclk0 -period 10 $fclk0Pin

# Arm Core Clocks
create_generated_clock -name dmaClk -source $fclk0Pin \
    -multiply_by 1 [get_pins U_EvalCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT0]

create_generated_clock -name sysClk200 -source $fclk0Pin \   
    -multiply_by 2 [get_pins U_EvalCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT1]

create_generated_clock -name sysClk125 -source $fclk0Pin \
    -multiply_by 5 -divide_by 4 [get_pins U_EvalCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT2]

# Set Asynchronous Paths
set_clock_groups -asynchronous \
    -group [get_clocks fclk0] \
    -group [get_clocks -include_generated_clocks sysClk200] \
    -group [get_clocks -include_generated_clocks sysClk125] \
    -group [get_clocks -include_generated_clocks dmaClk]

# StdLib
set_property ASYNC_REG TRUE [get_cells -hierarchical *crossDomainSyncReg_reg*]

# Locations
set_property PACKAGE_PIN Y11  [get_ports i2cScl]
set_property PACKAGE_PIN AA11 [get_ports i2cSda]

# Standards
set_property IOSTANDARD LVCMOS25 [get_ports i2cScl]
set_property IOSTANDARD LVCMOS25 [get_ports i2cSda]

