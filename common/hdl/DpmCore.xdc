#-------------------------------------------------------------------------------
#-- Title         : Common DPM Core Constraints
#-- File          : DpmCore.xdc
#-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
#-- Created       : 11/14/2013
#-------------------------------------------------------------------------------
#-- Description:
#-- Common top level constraints for DPM
#-------------------------------------------------------------------------------
#-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
#-------------------------------------------------------------------------------
#-- Modification history:
#-- 11/14/2013: created.
#-------------------------------------------------------------------------------

# Clocks
create_clock -name fclkClk0 -period 10 \
   [get_pins U_DpmCore/U_ArmRceG3Top/U_ArmRceG3Cpu/U_PS7/PS7_i/FCLKCLK[0]]

create_clock -name eth_txoutclk -period 16 \
   [get_pins U_DpmCore/U_ZynqEthernet/core_wrapper/transceiver_inst/gtwizard_inst/GTWIZARD_i/gt0_GTWIZARD_i/gtxe2_i/TXOUTCLK]

create_clock -name dtmClk -period 5 [get_ports U_DpmCore/dtmClk[0]]

set_clock_groups -physically_exclusive -group [get_clocks fclkClk0]   -group [get_clocks CLKOUT0]
set_clock_groups -physically_exclusive -group [get_clocks fclkClk0]   -group [get_clocks CLKOUT1]
set_clock_groups -physically_exclusive -group [get_clocks CLKOUT0]    -group [get_clocks CLKOUT1]
set_clock_groups -physically_exclusive -group [get_clocks CLKOUT0]    -group [get_clocks dtmClk]
set_clock_groups -physically_exclusive -group [get_clocks CLKOUT1]    -group [get_clocks CLKOUT0]
set_clock_groups -physically_exclusive -group [get_clocks CLKOUT1]    -group [get_clocks CLKOUT0_1]
set_clock_groups -physically_exclusive -group [get_clocks CLKOUT1]    -group [get_clocks CLKOUT1_1]
set_clock_groups -physically_exclusive -group [get_clocks CLKOUT0_1]  -group [get_clocks CLKOUT1]
set_clock_groups -physically_exclusive -group [get_clocks CLKOUT1_1]  -group [get_clocks CLKOUT1]

# StdLib
set_property ASYNC_REG TRUE [get_cells -hierarchical *crossDomainSyncReg_reg*]

# Locations
set_property PACKAGE_PIN AA28 [get_ports led[0]]
set_property PACKAGE_PIN AB26 [get_ports led[1]]

set_property PACKAGE_PIN AC29 [get_ports i2cScl]
set_property PACKAGE_PIN AD30 [get_ports i2cSda]

set_property PACKAGE_PIN AH10 [get_ports ethRxP[0]]
set_property PACKAGE_PIN AH9  [get_ports ethRxM[0]]
set_property PACKAGE_PIN AK10 [get_ports ethTxP[0]]
set_property PACKAGE_PIN AK9  [get_ports ethTxM[0]]
set_property PACKAGE_PIN AJ8  [get_ports ethRxP[1]]
set_property PACKAGE_PIN AJ7  [get_ports ethRxM[1]]
set_property PACKAGE_PIN AK6  [get_ports ethTxP[1]]
set_property PACKAGE_PIN AK5  [get_ports ethTxM[1]]
set_property PACKAGE_PIN AG8  [get_ports ethRxP[2]]
set_property PACKAGE_PIN AG7  [get_ports ethRxM[2]]
set_property PACKAGE_PIN AJ4  [get_ports ethTxP[2]]
set_property PACKAGE_PIN AJ3  [get_ports ethTxM[2]]
set_property PACKAGE_PIN AE8  [get_ports ethRxP[3]]
set_property PACKAGE_PIN AE7  [get_ports ethRxM[3]]
set_property PACKAGE_PIN AK2  [get_ports ethTxP[3]]
set_property PACKAGE_PIN AK1  [get_ports ethTxM[3]]

set_property PACKAGE_PIN AA8 [get_ports locRefClkP[0]]
set_property PACKAGE_PIN AA7 [get_ports locRefClkM[0]]
set_property PACKAGE_PIN U8  [get_ports locRefClkP[1]]
set_property PACKAGE_PIN U7  [get_ports locRefClkM[1]]
set_property PACKAGE_PIN W8  [get_ports dtmRefClkP]
set_property PACKAGE_PIN W7  [get_ports dtmRefClkM]

set_property PACKAGE_PIN AE28 [get_ports dtmClkP[0]]
set_property PACKAGE_PIN AF28 [get_ports dtmClkM[0]]
set_property PACKAGE_PIN AC28 [get_ports dtmClkP[1]]
set_property PACKAGE_PIN AD28 [get_ports dtmClkM[1]]
set_property PACKAGE_PIN AE25 [get_ports dtmFbP]
set_property PACKAGE_PIN AF25 [get_ports dtmFbM]

set_property PACKAGE_PIN AK27 [get_ports clkSelA[0]]
set_property PACKAGE_PIN AA25 [get_ports clkSelA[0]]
set_property PACKAGE_PIN AK28 [get_ports clkSelB[0]]
set_property PACKAGE_PIN AH26 [get_ports clkSelA[1]]
set_property PACKAGE_PIN AH27 [get_ports clkSelB[1]]

set_property PACKAGE_PIN AH2 [get_ports dpmToRtmHsP[0]]
set_property PACKAGE_PIN AH1 [get_ports dpmToRtmHsM[0]]
set_property PACKAGE_PIN AH6 [get_ports rtmToDpmHsP[0]]
set_property PACKAGE_PIN AH5 [get_ports rtmToDpmHsM[0]]
set_property PACKAGE_PIN AF2 [get_ports dpmToRtmHsP[1]]
set_property PACKAGE_PIN AF1 [get_ports dpmToRtmHsM[1]]
set_property PACKAGE_PIN AG4 [get_ports rtmToDpmHsP[1]]
set_property PACKAGE_PIN AG3 [get_ports rtmToDpmHsM[1]]
set_property PACKAGE_PIN AE4 [get_ports dpmToRtmHsP[2]]
set_property PACKAGE_PIN AE3 [get_ports dpmToRtmHsM[2]]
set_property PACKAGE_PIN AF6 [get_ports rtmToDpmHsP[2]]
set_property PACKAGE_PIN AF5 [get_ports rtmToDpmHsM[2]]
set_property PACKAGE_PIN AD2 [get_ports dpmToRtmHsP[3]]
set_property PACKAGE_PIN AD1 [get_ports dpmToRtmHsM[3]]
set_property PACKAGE_PIN AD6 [get_ports rtmToDpmHsP[3]]
set_property PACKAGE_PIN AD5 [get_ports rtmToDpmHsM[3]]
set_property PACKAGE_PIN AB2 [get_ports dpmToRtmHsP[4]]
set_property PACKAGE_PIN AB1 [get_ports dpmToRtmHsM[4]]
set_property PACKAGE_PIN AC4 [get_ports rtmToDpmHsP[4]]
set_property PACKAGE_PIN AC3 [get_ports rtmToDpmHsM[4]]
set_property PACKAGE_PIN Y2  [get_ports dpmToRtmHsP[5]]
set_property PACKAGE_PIN Y1  [get_ports dpmToRtmHsM[5]]
set_property PACKAGE_PIN AB6 [get_ports rtmToDpmHsP[5]]
set_property PACKAGE_PIN AB5 [get_ports rtmToDpmHsM[5]]
set_property PACKAGE_PIN W4  [get_ports dpmToRtmHsP[6]]
set_property PACKAGE_PIN W3  [get_ports dpmToRtmHsM[6]]
set_property PACKAGE_PIN Y6  [get_ports rtmToDpmHsP[6]]
set_property PACKAGE_PIN Y5  [get_ports rtmToDpmHsM[6]]
set_property PACKAGE_PIN V2  [get_ports dpmToRtmHsP[7]]
set_property PACKAGE_PIN V1  [get_ports dpmToRtmHsM[7]]
set_property PACKAGE_PIN AA4 [get_ports rtmToDpmHsP[7]]
set_property PACKAGE_PIN AA3 [get_ports rtmToDpmHsM[7]]
set_property PACKAGE_PIN T2  [get_ports dpmToRtmHsP[8]]
set_property PACKAGE_PIN T1  [get_ports dpmToRtmHsM[8]]
set_property PACKAGE_PIN V6  [get_ports rtmToDpmHsP[8]]
set_property PACKAGE_PIN V5  [get_ports rtmToDpmHsM[8]]
set_property PACKAGE_PIN R4  [get_ports dpmToRtmHsP[9]]
set_property PACKAGE_PIN R3  [get_ports dpmToRtmHsM[9]]
set_property PACKAGE_PIN U4  [get_ports rtmToDpmHsP[9]]
set_property PACKAGE_PIN U3  [get_ports rtmToDpmHsM[9]]
set_property PACKAGE_PIN P2  [get_ports dpmToRtmHsP[10]]
set_property PACKAGE_PIN P1  [get_ports dpmToRtmHsM[10]]
set_property PACKAGE_PIN T6  [get_ports rtmToDpmHsP[10]]
set_property PACKAGE_PIN T5  [get_ports rtmToDpmHsM[10]]
set_property PACKAGE_PIN N4  [get_ports dpmToRtmHsP[11]]
set_property PACKAGE_PIN N3  [get_ports dpmToRtmHsM[11]]
set_property PACKAGE_PIN P6  [get_ports rtmToDpmHsP[11]]
set_property PACKAGE_PIN P5  [get_ports rtmToDpmHsM[11]]

# IO Standard
set_property IOSTANDARD LVCMOS25 [get_ports led]

set_property IOSTANDARD LVCMOS25 [get_ports i2cScl]
set_property IOSTANDARD LVCMOS25 [get_ports i2cSda]

set_property IOSTANDARD LVDS_25 [get_ports dtmClkP]
set_property IOSTANDARD LVDS_25 [get_ports dtmClkM]

set_property IOSTANDARD LVDS_25 [get_ports dtmFbP]
set_property IOSTANDARD LVDS_25 [get_ports dtmFbM]

set_property IOSTANDARD LVCMOS25 [get_ports clkSelA]
set_property IOSTANDARD LVCMOS25 [get_ports clkSelB]

