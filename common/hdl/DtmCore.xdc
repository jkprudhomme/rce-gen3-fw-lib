#-------------------------------------------------------------------------------
#-- Title         : Common DTM Core Constraints
#-- File          : DtmCore.xdc
#-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
#-- Created       : 11/14/2013
#-------------------------------------------------------------------------------
#-- Description:
#-- Common top level constraints for DTM
#-------------------------------------------------------------------------------
#-- Copyright [c] 2014 by Ryan Herbst. All rights reserved.
#-------------------------------------------------------------------------------
#-- Modification history:
#-- 11/14/2013: created.
#-- 01/20/2014: Added GMII-To-RGMII Switch
#-------------------------------------------------------------------------------

# Clocks
create_clock -name fclkClk0 -period 10 \
   [get_pins U_DtmCore/U_ArmRceG3Top/U_ArmRceG3Cpu/U_PS7/PS7_i/FCLKCLK[0]]

create_clock -name eth_txoutclk -period 16 \
   [get_pins U_DtmCore/U_ZynqEthernet/core_wrapper/transceiver_inst/gtwizard_inst/GTWIZARD_i/gt0_GTWIZARD_i/gtxe2_i/TXOUTCLK]

create_clock -name pci_txoutclk -period 10 \
   [get_pins U_DtmCore/U_ZynqPcieMaster/U_Pcie/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtx_channel.gtxe2_channel_i/TXOUTCLK]

set_clock_groups -asynchronous -group [get_clocks {fclkClk0}]     -group [get_clocks {eth_txoutclk}]
set_clock_groups -asynchronous -group [get_clocks {fclkClk0}]     -group [get_clocks {pci_txoutclk}]
set_clock_groups -asynchronous -group [get_clocks {eth_txoutclk}] -group [get_clocks {fclkClk0}]
set_clock_groups -asynchronous -group [get_clocks {eth_txoutclk}] -group [get_clocks {pci_txoutclk}]
set_clock_groups -asynchronous -group [get_clocks {pci_txoutclk}] -group [get_clocks {fclkClk0}]
set_clock_groups -asynchronous -group [get_clocks {pci_txoutclk}] -group [get_clocks {eth_txoutclk}]
set_clock_groups -asynchronous -group [get_clocks clk_125mhz]     -group [get_clocks CLKOUT0]
set_clock_groups -asynchronous -group [get_clocks clk_250mhz]     -group [get_clocks CLKOUT0]
set_clock_groups -asynchronous -group [get_clocks {CLKOUT0}]      -group [get_clocks {clk_125mhz}]
set_clock_groups -asynchronous -group [get_clocks {CLKOUT0}]      -group [get_clocks {clk_250mhz}]
set_clock_groups -asynchronous -group [get_clocks {CLKOUT0}]      -group [get_clocks {userclk2}]
set_clock_groups -asynchronous -group [get_clocks CLKOUT0_1]      -group [get_clocks CLKOUT1]
set_clock_groups -asynchronous -group [get_clocks CLKOUT1]        -group [get_clocks CLKOUT0_1]
set_clock_groups -asynchronous -group [get_clocks CLKOUT1]        -group [get_clocks CLKOUT1_1]
set_clock_groups -asynchronous -group [get_clocks CLKOUT1_1]      -group [get_clocks CLKOUT1]
set_clock_groups -asynchronous -group [get_clocks userclk2]       -group [get_clocks CLKOUT0]

set_clock_groups -logically_exclusive -group [get_clocks {CLKOUT0}]  -group [get_clocks {CLKOUT1}]
set_clock_groups -logically_exclusive -group [get_clocks {CLKOUT1}]  -group [get_clocks {CLKOUT0}]
set_clock_groups -logically_exclusive -group [get_clocks {fclkClk0}] -group [get_clocks {CLKOUT0}]
set_clock_groups -logically_exclusive -group [get_clocks {fclkClk0}] -group [get_clocks {CLKOUT1}]

set_clock_groups -name PcieClkMux -physically_exclusive -group [get_clocks clk_125mhz] -group [get_clocks clk_250mhz]

set_false_path -through [get_pins  -hier -filter {name =~ *pcie_block_i/PLPHYLNKUPN*}]
set_false_path -through [get_pins  -hier -filter {name =~ *pcie_block_i/PLRECEIVEDHOTRST*}]
set_false_path -through [get_nets  -hier -filter {name =~ *pipe_wrapper_i/user_resetdone*}]
set_false_path -through [get_nets  -hier -filter {name =~ *pipe_wrapper_i/pipe_lane[0].pipe_rate.pipe_rate_i/*}]
set_false_path -through [get_cells -hier -filter {name =~ *pipe_wrapper_i/pipe_reset.pipe_reset_i/cpllreset_reg*}]
set_false_path -to      [get_pins  -hier -filter {name =~ *pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S*}]

# DTM IODELAY Groups
set_property IODELAY_GROUP "DtmTimingGrp" [get_cells {U_DtmTiming/U_DlyCntrl}]
set_property IODELAY_GROUP "DtmTimingGrp" [get_cells -hier -filter {name =~ *U_OpCodeSink/IDELAYE2_inst}]

# GMII-To-RGMII IODELAY Groups
set_property IDELAY_VALUE  "0"              [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_core/*delay_rgmii_rx_ctl}]
set_property IDELAY_VALUE  "0"              [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_core/*delay_rgmii_rxd*}]
set_property IODELAY_GROUP "GmiiToRgmiiGrp" [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_core/*delay_rgmii_rx_ctl}]
set_property IODELAY_GROUP "GmiiToRgmiiGrp" [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_core/*delay_rgmii_rxd*}]
set_property IODELAY_GROUP "GmiiToRgmiiGrp" [get_cells -hier -filter {name =~ *i_GmiiToRgmiiCore_idelayctrl}]

# StdLib
set_property ASYNC_REG TRUE [get_cells -hierarchical *crossDomainSyncReg_reg*]

# Locations
set_property PACKAGE_PIN AA19 [get_ports led[0]]
set_property PACKAGE_PIN T15  [get_ports led[1]]

set_property PACKAGE_PIN AB13 [get_ports i2cScl]
set_property PACKAGE_PIN AA10 [get_ports i2cSda]

set_property PACKAGE_PIN U6  [get_ports pciRefClkP]
set_property PACKAGE_PIN U5  [get_ports pciRefClkM]
set_property PACKAGE_PIN T4  [get_ports pciRxP]
set_property PACKAGE_PIN T3  [get_ports pciRxM]
set_property PACKAGE_PIN U2  [get_ports pciTxP]
set_property PACKAGE_PIN U1  [get_ports pciTxM]
set_property PACKAGE_PIN T14 [get_ports pciResetL]

set_property PACKAGE_PIN AA6 [get_ports ethRxP]
set_property PACKAGE_PIN AA5 [get_ports ethRxM]
set_property PACKAGE_PIN AB4 [get_ports ethTxP]
set_property PACKAGE_PIN AB3 [get_ports ethTxM]

set_property PACKAGE_PIN AA2 [get_ports dtmToRtmHsP[0]]
set_property PACKAGE_PIN AA1 [get_ports dtmToRtmHsM[0]]
set_property PACKAGE_PIN Y4  [get_ports rtmToDtmHsP[0]]
set_property PACKAGE_PIN Y3  [get_ports rtmToDtmHsM[0]]
set_property PACKAGE_PIN W2  [get_ports dtmToRtmHsP[1]]
set_property PACKAGE_PIN W1  [get_ports dtmToRtmHsM[1]]
set_property PACKAGE_PIN V4  [get_ports rtmToDtmHsP[1]]
set_property PACKAGE_PIN V3  [get_ports rtmToDtmHsM[1]]

set_property PACKAGE_PIN W6  [get_ports locRefClkP]
set_property PACKAGE_PIN W5  [get_ports locRefClkM]

# Old DTM
set_property PACKAGE_PIN W9   [get_ports dpmClkP[2]]
set_property PACKAGE_PIN Y8   [get_ports dpmClkM[2]]
set_property PACKAGE_PIN V8   [get_ports dpmClkP[1]]
set_property PACKAGE_PIN W8   [get_ports dpmClkM[1]]
set_property PACKAGE_PIN U10  [get_ports dpmClkP[0]]
set_property PACKAGE_PIN V10  [get_ports dpmClkM[0]]

# Old DTM
set_property PACKAGE_PIN U9   [get_ports dtmToRtmLsP[5]]
set_property PACKAGE_PIN U8   [get_ports dtmToRtmLsM[5]]
set_property PACKAGE_PIN AA14 [get_ports dtmToRtmLsP[4]]
set_property PACKAGE_PIN AB14 [get_ports dtmToRtmLsM[4]]
set_property PACKAGE_PIN T20  [get_ports dtmToRtmLsP[3]]
set_property PACKAGE_PIN U20  [get_ports dtmToRtmLsM[3]]
set_property PACKAGE_PIN R17  [get_ports dtmToRtmLsP[2]]
set_property PACKAGE_PIN R18  [get_ports dtmToRtmLsM[2]]
set_property PACKAGE_PIN R19  [get_ports dtmToRtmLsP[1]]
set_property PACKAGE_PIN T19  [get_ports dtmToRtmLsM[1]]
set_property PACKAGE_PIN T17  [get_ports dtmToRtmLsP[0]]
set_property PACKAGE_PIN U17  [get_ports dtmToRtmLsM[0]]

# Old DTM
set_property PACKAGE_PIN R22  [get_ports dpmFbP[4]]
set_property PACKAGE_PIN T22  [get_ports dpmFbM[4]]
set_property PACKAGE_PIN N21  [get_ports dpmFbP[5]]
set_property PACKAGE_PIN N22  [get_ports dpmFbM[5]]
set_property PACKAGE_PIN W19  [get_ports dpmFbP[6]]
set_property PACKAGE_PIN W20  [get_ports dpmFbM[6]]
set_property PACKAGE_PIN V21  [get_ports dpmFbP[7]]
set_property PACKAGE_PIN V22  [get_ports dpmFbM[7]]
set_property PACKAGE_PIN W21  [get_ports dpmFbP[0]]
set_property PACKAGE_PIN Y22  [get_ports dpmFbM[0]]
set_property PACKAGE_PIN AA20 [get_ports dpmFbP[1]]
set_property PACKAGE_PIN AB20 [get_ports dpmFbM[1]]
set_property PACKAGE_PIN Y21  [get_ports dpmFbP[2]]
set_property PACKAGE_PIN AA21 [get_ports dpmFbM[2]]
set_property PACKAGE_PIN AA22 [get_ports dpmFbP[3]]
set_property PACKAGE_PIN AB22 [get_ports dpmFbM[3]]

# # New DTM
# set_property PACKAGE_PIN U9   [get_ports dpmClkP[2]]
# set_property PACKAGE_PIN U8   [get_ports dpmClkM[2]]
# set_property PACKAGE_PIN W9   [get_ports dpmClkP[1]]
# set_property PACKAGE_PIN Y8   [get_ports dpmClkM[1]]
# set_property PACKAGE_PIN AA14 [get_ports dpmClkP[0]]
# set_property PACKAGE_PIN AB14 [get_ports dpmClkM[0]]

# # New DTM
# set_property PACKAGE_PIN V8  [get_ports dtmToRtmLsP[5]]
# set_property PACKAGE_PIN W8  [get_ports dtmToRtmLsM[5]]
# set_property PACKAGE_PIN U10 [get_ports dtmToRtmLsP[4]]
# set_property PACKAGE_PIN V10 [get_ports dtmToRtmLsM[4]]
# set_property PACKAGE_PIN T20 [get_ports dtmToRtmLsP[3]]
# set_property PACKAGE_PIN U20 [get_ports dtmToRtmLsM[3]]
# set_property PACKAGE_PIN R17 [get_ports dtmToRtmLsP[2]]
# set_property PACKAGE_PIN R18 [get_ports dtmToRtmLsM[2]]
# set_property PACKAGE_PIN R19 [get_ports dtmToRtmLsP[1]]
# set_property PACKAGE_PIN T19 [get_ports dtmToRtmLsM[1]]
# set_property PACKAGE_PIN T17 [get_ports dtmToRtmLsP[0]]
# set_property PACKAGE_PIN U17 [get_ports dtmToRtmLsM[0]]

# # New DTM
# set_property PACKAGE_PIN R22  [get_ports dpmFbP[7]]
# set_property PACKAGE_PIN T22  [get_ports dpmFbM[7]]
# set_property PACKAGE_PIN N21  [get_ports dpmFbP[6]]
# set_property PACKAGE_PIN N22  [get_ports dpmFbM[6]]
# set_property PACKAGE_PIN W19  [get_ports dpmFbP[5]]
# set_property PACKAGE_PIN W20  [get_ports dpmFbM[5]]
# set_property PACKAGE_PIN V21  [get_ports dpmFbP[4]]
# set_property PACKAGE_PIN V22  [get_ports dpmFbM[4]]
# set_property PACKAGE_PIN W21  [get_ports dpmFbP[3]]
# set_property PACKAGE_PIN Y22  [get_ports dpmFbM[3]]
# set_property PACKAGE_PIN AA20 [get_ports dpmFbP[2]]
# set_property PACKAGE_PIN AB20 [get_ports dpmFbM[2]]
# set_property PACKAGE_PIN Y21  [get_ports dpmFbP[1]]
# set_property PACKAGE_PIN AA21 [get_ports dpmFbM[1]]
# set_property PACKAGE_PIN AA22 [get_ports dpmFbP[0]]
# set_property PACKAGE_PIN AB22 [get_ports dpmFbM[0]]

set_property PACKAGE_PIN W18 [get_ports clkSelA]
set_property PACKAGE_PIN V17 [get_ports clkSelB]

set_property PACKAGE_PIN N17  [get_ports plSpareP[4]]
set_property PACKAGE_PIN N18  [get_ports plSpareM[4]]
set_property PACKAGE_PIN N20  [get_ports plSpareP[3]]
set_property PACKAGE_PIN P20  [get_ports plSpareM[3]]
set_property PACKAGE_PIN AA17 [get_ports plSpareP[2]]
set_property PACKAGE_PIN AB17 [get_ports plSpareM[2]]
set_property PACKAGE_PIN AA15 [get_ports plSpareP[1]]
set_property PACKAGE_PIN AB15 [get_ports plSpareM[1]]
set_property PACKAGE_PIN V15  [get_ports plSpareP[0]]
set_property PACKAGE_PIN W15  [get_ports plSpareM[0]]

set_property PACKAGE_PIN AA12 [get_ports bpClkIn[5]]
set_property PACKAGE_PIN Y16  [get_ports bpClkIn[4]]
set_property PACKAGE_PIN W11  [get_ports bpClkIn[3]]
set_property PACKAGE_PIN Y14  [get_ports bpClkIn[2]]
set_property PACKAGE_PIN Y12  [get_ports bpClkIn[1]]
set_property PACKAGE_PIN W14  [get_ports bpClkIn[0]]

set_property PACKAGE_PIN T12 [get_ports bpClkOut[5]]
set_property PACKAGE_PIN V16 [get_ports bpClkOut[4]]
set_property PACKAGE_PIN U13 [get_ports bpClkOut[3]]
set_property PACKAGE_PIN U15 [get_ports bpClkOut[2]]
set_property PACKAGE_PIN V12 [get_ports bpClkOut[1]]
set_property PACKAGE_PIN T11 [get_ports bpClkOut[0]]

set_property PACKAGE_PIN T10 [get_ports dtmToIpmiP[1]]
set_property PACKAGE_PIN T9  [get_ports dtmToIpmiM[1]]
set_property PACKAGE_PIN Y9  [get_ports dtmToIpmiP[0]]
set_property PACKAGE_PIN AA9 [get_ports dtmToIpmiM[0]]

set_property PACKAGE_PIN F2 [get_ports ethRxCtrl[0]]
set_property PACKAGE_PIN J5 [get_ports ethRxClk[0]]
set_property PACKAGE_PIN J3 [get_ports ethRxDataA[0]]
set_property PACKAGE_PIN H3 [get_ports ethRxDataB[0]]
set_property PACKAGE_PIN H2 [get_ports ethRxDataC[0]]
set_property PACKAGE_PIN H1 [get_ports ethRxDataD[0]]
set_property PACKAGE_PIN F4 [get_ports ethTxCtrl[0]]
set_property PACKAGE_PIN F5 [get_ports ethTxClk[0]]
set_property PACKAGE_PIN H7 [get_ports ethTxDataA[0]]
set_property PACKAGE_PIN G7 [get_ports ethTxDataB[0]]
set_property PACKAGE_PIN F7 [get_ports ethTxDataC[0]]
set_property PACKAGE_PIN F6 [get_ports ethTxDataD[0]]
set_property PACKAGE_PIN G4 [get_ports ethMdc[0]]
set_property PACKAGE_PIN J6 [get_ports ethMio[0]]
set_property PACKAGE_PIN H6 [get_ports ethResetL[0]]

set_property PACKAGE_PIN N3 [get_ports ethRxCtrl[1]]
set_property PACKAGE_PIN M5 [get_ports ethRxClk[1]]
set_property PACKAGE_PIN N2 [get_ports ethRxDataA[1]]
set_property PACKAGE_PIN L2 [get_ports ethRxDataB[1]]
set_property PACKAGE_PIN L1 [get_ports ethRxDataC[1]]
set_property PACKAGE_PIN P1 [get_ports ethRxDataD[1]]
set_property PACKAGE_PIN L7 [get_ports ethTxCtrl[1]]
set_property PACKAGE_PIN M4 [get_ports ethTxClk[1]]
set_property PACKAGE_PIN L6 [get_ports ethTxDataA[1]]
set_property PACKAGE_PIN P4 [get_ports ethTxDataB[1]]
set_property PACKAGE_PIN M2 [get_ports ethTxDataC[1]]
set_property PACKAGE_PIN K3 [get_ports ethTxDataD[1]]
set_property PACKAGE_PIN K7 [get_ports ethMdc[1]]
set_property PACKAGE_PIN K6 [get_ports ethMio[1]]
set_property PACKAGE_PIN N5 [get_ports ethResetL[1]]

# Types
set_property IOSTANDARD LVCMOS25 [get_ports led]

set_property IOSTANDARD LVCMOS25 [get_ports i2cScl]
set_property IOSTANDARD LVCMOS25 [get_ports i2cSda]

set_property IOSTANDARD LVCMOS25 [get_ports pciResetL]

set_property IOSTANDARD LVCMOS25 [get_ports dtmToRtmLsP]
set_property IOSTANDARD LVCMOS25 [get_ports dtmToRtmLsM]

set_property IOSTANDARD LVDS_25 [get_ports dpmClkP]
set_property IOSTANDARD LVDS_25 [get_ports dpmClkM]

set_property IOSTANDARD LVDS_25 [get_ports dpmFbP]
set_property IOSTANDARD LVDS_25 [get_ports dpmFbM]

set_property IOSTANDARD LVCMOS25 [get_ports clkSelA]
set_property IOSTANDARD LVCMOS25 [get_ports clkSelB]

set_property IOSTANDARD LVDS_25 [get_ports plSpareP]
set_property IOSTANDARD LVDS_25 [get_ports plSpareM]

set_property IOSTANDARD LVCMOS25 [get_ports bpClkIn]
set_property IOSTANDARD LVCMOS25 [get_ports bpClkOut]

set_property IOSTANDARD LVCMOS25 [get_ports dtmToIpmiP]
set_property IOSTANDARD LVCMOS25 [get_ports dtmToIpmiM]

set_property IOSTANDARD LVCMOS18 [get_ports ethRxCtrl]
set_property IOSTANDARD LVCMOS18 [get_ports ethRxClk]
set_property IOSTANDARD LVCMOS18 [get_ports ethRxDataA]
set_property IOSTANDARD LVCMOS18 [get_ports ethRxDataB]
set_property IOSTANDARD LVCMOS18 [get_ports ethRxDataC]
set_property IOSTANDARD LVCMOS18 [get_ports ethRxDataD]
set_property IOSTANDARD LVCMOS18 [get_ports ethTxCtrl]
set_property IOSTANDARD LVCMOS18 [get_ports ethTxClk]
set_property IOSTANDARD LVCMOS18 [get_ports ethTxDataA]
set_property IOSTANDARD LVCMOS18 [get_ports ethTxDataB]
set_property IOSTANDARD LVCMOS18 [get_ports ethTxDataC]
set_property IOSTANDARD LVCMOS18 [get_ports ethTxDataD]
set_property IOSTANDARD LVCMOS18 [get_ports ethMdc]
set_property IOSTANDARD LVCMOS18 [get_ports ethMio]
set_property IOSTANDARD LVCMOS18 [get_ports ethResetL]

