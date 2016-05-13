#-------------------------------------------------------------------------------
#-- Title         : Common DTM Core Constraints
#-- File          : DtmCore.xdc
#-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
#-- Created       : 11/14/2013
#-------------------------------------------------------------------------------
#-- Description:
#-- Common top level constraints for DTM
#-------------------------------------------------------------------------------
## This file is part of 'SLAC RCE DTM Core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'SLAC RCE DTM Core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
#-------------------------------------------------------------------------------
#-- Modification history:
#-- 11/14/2013: created.
#-- 01/20/2014: Added GMII-To-RGMII Switch
#-------------------------------------------------------------------------------

# CPU Clock
set fclk0Pin [get_pins U_DtmCore/U_RceG3Top/U_SimModeDis.U_RceG3Cpu/U_PS7/inst/PS7_i/FCLKCLK[0]]
create_clock -name fclk0 -period 10 ${fclk0Pin}

# Arm Core Clocks
create_generated_clock -name dmaClk -source ${fclk0Pin} \
    -multiply_by 2 [get_pins U_DtmCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT0]

create_generated_clock -name sysClk200 -source ${fclk0Pin} \
    -multiply_by 2 [get_pins U_DtmCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT1]

create_generated_clock -name sysClk125 -source ${fclk0Pin} \
    -multiply_by 5 -divide_by 4 [get_pins U_DtmCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT2]

# Arm Core clocks are treated as asynchronous to each other
set_clock_groups -asynchronous \
    -group [get_clocks fclk0] \
    -group [get_clocks -include_generated_clocks dmaClk] \
    -group [get_clocks -include_generated_clocks sysClk200] \
    -group [get_clocks -include_generated_clocks sysClk125] \

# Local 1G Ethernet Clocks
set eth_txoutclk_pin [get_pins U_DtmCore/U_ZynqEthernet/core_wrapper/transceiver_inst/gtwizard_inst/GTWIZARD_i/gt0_GTWIZARD_i/gtxe2_i/TXOUTCLK]
create_clock -name eth_txoutclk -period 16 ${eth_txoutclk_pin}

create_generated_clock -name intEthClk0 -source ${eth_txoutclk_pin} \
    -multiply_by 2 [get_pins U_DtmCore/U_ZynqEthernet/mmcm_adv_inst/CLKOUT0]

create_generated_clock -name intEthClk1 -source ${eth_txoutclk_pin} \
    -multiply_by 1 [get_pins U_DtmCore/U_ZynqEthernet/mmcm_adv_inst/CLKOUT1]

create_clock -add -name rgmii_rxc0 -period 8.000 [get_ports ethRxClk[0]]
create_clock -add -name rgmii_rxc1 -period 8.000 [get_ports ethRxClk[1]]


set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks fclk0] \
    -group [get_clocks -include_generated_clocks eth_txoutclk]

set sysClk200Pin [get_pins -of_objects [get_clocks sysClk200]]

# External 1G Ethernet Clocks
#create_clock -name ethRxClk0 -period 8 [get_ports ethRxClk[0]]
#create_clock -name ethRxClk1 -period 8 [get_ports ethRxClk[1]]
#
#set sysClk200Pin [get_pins -of_objects [get_clocks sysClk200]]
#
#create_generated_clock -name extEthClk125A -source ${sysClk200Pin} \
#    -multiply_by 5 -divide_by 8 \
#    [get_pins U_DtmCore/U_HsioEnGen.U_GmiiToRgmii/U_CoreGen[0].GmiiToRgmiiCore_Inst/U0/i_GmiiToRgmiiCore_clocking/mmcm_adv_inst/CLKOUT0]
#
#create_generated_clock -name extEthClk125B -source ${sysClk200Pin} \
#    -multiply_by 5 -divide_by 8 \
#    [get_pins U_DtmCore/U_HsioEnGen.U_GmiiToRgmii/U_CoreGen[1].GmiiToRgmiiCore_Inst/U0/i_GmiiToRgmiiCore_clocking/mmcm_adv_inst/CLKOUT0]
#
#create_generated_clock -name extEthClk25A -source ${sysClk200Pin} \
#    -divide_by 8 \
#    [get_pins U_DtmCore/U_HsioEnGen.U_GmiiToRgmii/U_CoreGen[0].GmiiToRgmiiCore_Inst/U0/i_GmiiToRgmiiCore_clocking/mmcm_adv_inst/CLKOUT1]
#
#create_generated_clock -name extEthClk25B -source ${sysClk200Pin} \
#    -divide_by 8 \
#    [get_pins U_DtmCore/U_HsioEnGen.U_GmiiToRgmii/U_CoreGen[1].GmiiToRgmiiCore_Inst/U0/i_GmiiToRgmiiCore_clocking/mmcm_adv_inst/CLKOUT1]
#
#create_generated_clock -name extEthClk10A -source ${sysClk200Pin} \
#    -divide_by 20 \
#    [get_pins U_DtmCore/U_HsioEnGen.U_GmiiToRgmii/U_CoreGen[0].GmiiToRgmiiCore_Inst/U0/i_GmiiToRgmiiCore_clocking/mmcm_adv_inst/CLKOUT2]
#
#create_generated_clock -name extEthClk10B -source ${sysClk200Pin} \
#    -divide_by 20 \
#    [get_pins U_DtmCore/U_HsioEnGen.U_GmiiToRgmii/U_CoreGen[1].GmiiToRgmiiCore_Inst/U0/i_GmiiToRgmiiCore_clocking/mmcm_adv_inst/CLKOUT2]
#
#create_generated_clock -name extEthClk2_5A -source [get_pins -of_objects [get_clocks extEthClk10]] \
#    -divide_by 4 \
#    [get_pins U_DtmCore/U_HsioEnGen.U_GmiiToRgmii/U_CoreGen[0].GmiiToRgmiiCore_Inst/U0/i_GmiiToRgmiiCore_clocking/clk10_div_buf/O]
#
#create_generated_clock -name extEthClk2_5B -source [get_pins -of_objects [get_clocks extEthClk10]] \
#    -divide_by 4 \
#    [get_pins U_DtmCore/U_HsioEnGen.U_GmiiToRgmii/U_CoreGen[1].GmiiToRgmiiCore_Inst/U0/i_GmiiToRgmiiCore_clocking/clk10_div_buf/O]
#
#set_max_delay 10 -datapath_only -from [get_clocks -include_generated_clocks {ethRxClk0}] \
#    -to [get_clocks -include_generated_clocks {sysClk200}]
#
#set_max_delay 10 -datapath_only -from [get_clocks -include_generated_clocks {ethRxClk1}] \
#    -to [get_clocks -include_generated_clocks {sysClk200}]

# DNA Primitive Clock
create_clock -period 64.000 -name dnaClk [get_pins  {U_DtmCore/U_RceG3Top/U_RceG3AxiCntl/U_DeviceDna/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}]
set_clock_groups -asynchronous \
    -group [get_clocks dnaClk] \
    -group [get_clocks sysClk125] 

# PCI-Express Timing
set_false_path -through [get_pins  -hier -filter {name =~ *pcie_block_i/PLPHYLNKUPN*}]
set_false_path -through [get_pins  -hier -filter {name =~ *pcie_block_i/PLRECEIVEDHOTRST*}]
set_false_path -through [get_nets  -hier -filter {name =~ *pipe_wrapper_i/user_resetdone*}]
set_false_path -through [get_nets  -hier -filter {name =~ *pipe_wrapper_i/pipe_lane[0].pipe_rate.pipe_rate_i/*}]
set_false_path -through [get_cells -hier -filter {name =~ *pipe_wrapper_i/pipe_reset.pipe_reset_i/cpllreset_reg*}]
set_false_path -to      [get_pins  -hier -filter {name =~ *pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S*}]
set_false_path -through [get_nets  -hier -filter {name =~ *pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_sel*}]

# GMII To RGMII 
# Set the select line for the clock muxes so that the timing analysis is done on the fastest clock
set_case_analysis 0 [get_pins -hier -filter {name =~ *i_bufgmux_gmii_clk_25m_2_5m/CE0}]
set_case_analysis 0 [get_pins -hier -filter {name =~ *i_bufgmux_gmii_clk_25m_2_5m/S0}]

set_case_analysis 1 [get_pins -hier -filter {name =~ *i_bufgmux_gmii_clk_25m_2_5m/CE1}]
set_case_analysis 1 [get_pins -hier -filter {name =~ *i_bufgmux_gmii_clk_25m_2_5m/S1}]

# GMII To RGMII 
# False path constraints to async inputs coming directly to synchronizer
set_false_path -to [get_pins -of [get_cells -hier -filter { name =~ *i_MANAGEMENT/SYNC_*/data_sync* } ]  -filter { name =~ *D } ]
set_false_path -to [get_pins -hier -filter {name =~ *reset_sync*/PRE }]
set_false_path -to [get_pins -hier -filter {name =~ *idelayctrl_reset_gen/*reset_sync*/PRE }]

# GMII To RGMII 
# False path constraints from Control Register outputs
set_false_path -from [get_pins -hier -filter {name =~ *i_MANAGEMENT/DUPLEX_MODE_REG*/C }]
set_false_path -from [get_pins -hier -filter {name =~ *i_MANAGEMENT/SPEED_SELECTION_REG*/C }]

# GMII-To-RGMII IODELAY Groups
set_property IDELAY_VALUE  "16"               [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_core/*delay_rgmii_rx_ctl}]
set_property IDELAY_VALUE  "16"               [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_core/*delay_rgmii_rxd*}]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *U_CoreGen[0]*GmiiToRgmiiCore_core/*delay_rgmii_rx_ctl}]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *U_CoreGen[0]*GmiiToRgmiiCore_core/*delay_rgmii_rxd*}]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *U_CoreGen[1]*GmiiToRgmiiCore_core/*delay_rgmii_rx_ctl}]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *U_CoreGen[1]*GmiiToRgmiiCore_core/*delay_rgmii_rxd*}]
set_property ODELAY_VALUE  "26"  [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_core/*oddr_rgmii_txc              }]
set_property ODELAY_VALUE  "0"   [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_core/*oddr_rgmii_tx_ctl           }]
set_property ODELAY_VALUE  "0"   [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_core/*oddr_rgmii_txd*             }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *U_CoreGen[0]*GmiiToRgmiiCore_core/*oddr_rgmii_txc }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *U_CoreGen[0]*GmiiToRgmiiCore_core/*oddr_rgmii_tx_ctl }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *U_CoreGen[0]*GmiiToRgmiiCore_core/*oddr_rgmii_txd* }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *U_CoreGen[1]*GmiiToRgmiiCore_core/*oddr_rgmii_txc }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *U_CoreGen[1]*GmiiToRgmiiCore_core/*oddr_rgmii_tx_ctl }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *U_CoreGen[1]*GmiiToRgmiiCore_core/*oddr_rgmii_txd* }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *U_CoreGen[0]*i_GmiiToRgmiiCore_idelayctrl}]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *U_CoreGen[1]*i_GmiiToRgmiiCore_idelayctrl}]

# Identify RGMII Rx Pads only.  
# Receiver clock period constraints: please do not relax
set rx_clk0 [get_clocks -include_generated_clocks -of [get_ports ethRxClk[0]]]
set rx_clk1 [get_clocks -include_generated_clocks -of [get_ports ethRxClk[1]]]

# define a virtual clock to simplify the timing constraints
create_clock -name GmiiToRgmiiCore_rgmii_rx_clk -period 8

# Identify RGMII Rx Pads only.  
# This prevents setup/hold analysis being performed on false inputs,
# eg, the configuration_vector inputs.

set_input_delay -clock [get_clocks GmiiToRgmiiCore_rgmii_rx_clk] -max -1.7 [get_ports {ethRxDataA[0] ethRxDataB[0] ethRxDataC[0] ethRxDataD[0] ethRxCtrl[0]}]
set_input_delay -clock [get_clocks GmiiToRgmiiCore_rgmii_rx_clk] -min -2.5 [get_ports {ethRxDataA[0] ethRxDataB[0] ethRxDataC[0] ethRxDataD[0] ethRxCtrl[0]}]
set_input_delay -clock [get_clocks GmiiToRgmiiCore_rgmii_rx_clk] -clock_fall -max -1.7 -add_delay [get_ports {ethRxDataA[0] ethRxDataB[0] ethRxDataC[0] ethRxDataD[0] ethRxCtrl[0]}]
set_input_delay -clock [get_clocks GmiiToRgmiiCore_rgmii_rx_clk] -clock_fall -min -2.5 -add_delay [get_ports {ethRxDataA[0] ethRxDataB[0] ethRxDataC[0] ethRxDataD[0] ethRxCtrl[0]}]

set_false_path -rise_from [get_clocks GmiiToRgmiiCore_rgmii_rx_clk] -fall_to $rx_clk0 -setup
set_false_path -fall_from [get_clocks GmiiToRgmiiCore_rgmii_rx_clk] -rise_to $rx_clk0 -setup
set_false_path -rise_from [get_clocks GmiiToRgmiiCore_rgmii_rx_clk] -rise_to [get_clocks $rx_clk0] -hold
set_false_path -fall_from [get_clocks GmiiToRgmiiCore_rgmii_rx_clk] -fall_to $rx_clk0 -hold

set_multicycle_path -from [get_clocks GmiiToRgmiiCore_rgmii_rx_clk] -to $rx_clk0 -setup 0
set_multicycle_path -from [get_clocks GmiiToRgmiiCore_rgmii_rx_clk] -to $rx_clk0 -hold -1

# Identify RGMII Tx Pads only.  
set ip_gtx_clk     [get_clocks -include_generated_clocks -of_objects [get_pins -of [get_cells -hier -filter {name =~ *i_bufgmux_gmii_clk}] -filter {name =~ *O}]]
create_generated_clock -add -name rgmii_tx_clk -divide_by 1 -source [get_pins -of [get_cells -hier -filter {name =~ *rgmii_txc_out}] -filter {name =~ *C}] -master_clock [get_clocks gmii_clk_125m_*] [get_ports ethTxClk[0]]


set_false_path -rise_from $ip_gtx_clk -fall_to [get_clocks rgmii_tx_clk] -setup
set_false_path -fall_from $ip_gtx_clk -rise_to [get_clocks rgmii_tx_clk] -setup
set_false_path -rise_from $ip_gtx_clk -rise_to [get_clocks rgmii_tx_clk] -hold
set_false_path -fall_from $ip_gtx_clk -fall_to [get_clocks rgmii_tx_clk] -hold

set_output_delay -1.0 -max -clock [get_clocks rgmii_tx_clk] [get_ports {ethTxDataA[0] ethTxDataB[0] ethTxDataC[0] ethTxDataD[0] ethTxCtrl[0]}]
set_output_delay -2.6 -min -clock [get_clocks rgmii_tx_clk] [get_ports {ethTxDataA[0] ethTxDataB[0] ethTxDataC[0] ethTxDataD[0] ethTxCtrl[0]}] -add_delay 
set_output_delay -1.0 -max -clock [get_clocks rgmii_tx_clk] [get_ports {ethTxDataA[0] ethTxDataB[0] ethTxDataC[0] ethTxDataD[0] ethTxCtrl[0]}] -clock_fall
set_output_delay -2.6 -min -clock [get_clocks rgmii_tx_clk] [get_ports {ethTxDataA[0] ethTxDataB[0] ethTxDataC[0] ethTxDataD[0] ethTxCtrl[0]}] -clock_fall 

set_multicycle_path 0 -setup -end -rise_from $ip_gtx_clk -rise_to [get_clocks rgmii_tx_clk]
set_multicycle_path 0 -setup -end -fall_from $ip_gtx_clk -fall_to [get_clocks rgmii_tx_clk]

# define a virtual clock to simplify the timing constraints
create_clock -name GmiiToRgmiiCore_rgmii_rx_clk2 -period 8

# Identify RGMII Rx Pads only.  
# This prevents setup/hold analysis being performed on false inputs,
# eg, the configuration_vector inputs.

set_input_delay -clock [get_clocks GmiiToRgmiiCore_rgmii_rx_clk2] -max -1.7 [get_ports {ethRxDataA[1] ethRxDataB[1] ethRxDataC[1] ethRxDataD[1] ethRxCtrl[1]}]
set_input_delay -clock [get_clocks GmiiToRgmiiCore_rgmii_rx_clk2] -min -2.5 [get_ports {ethRxDataA[1] ethRxDataB[1] ethRxDataC[1] ethRxDataD[1] ethRxCtrl[1]}]
set_input_delay -clock [get_clocks GmiiToRgmiiCore_rgmii_rx_clk2] -clock_fall -max -1.7 -add_delay [get_ports {ethRxDataA[1] ethRxDataB[1] ethRxDataC[1] ethRxDataD[1] ethRxCtrl[1]}]
set_input_delay -clock [get_clocks GmiiToRgmiiCore_rgmii_rx_clk2] -clock_fall -min -2.5 -add_delay [get_ports {ethRxDataA[1] ethRxDataB[1] ethRxDataC[1] ethRxDataD[1] ethRxCtrl[1]}]

set_false_path -rise_from [get_clocks GmiiToRgmiiCore_rgmii_rx_clk2] -fall_to $rx_clk1 -setup
set_false_path -fall_from [get_clocks GmiiToRgmiiCore_rgmii_rx_clk2] -rise_to $rx_clk1 -setup
set_false_path -rise_from [get_clocks GmiiToRgmiiCore_rgmii_rx_clk2] -rise_to [get_clocks $rx_clk1] -hold
set_false_path -fall_from [get_clocks GmiiToRgmiiCore_rgmii_rx_clk2] -fall_to $rx_clk1 -hold

set_multicycle_path -from [get_clocks GmiiToRgmiiCore_rgmii_rx_clk2] -to $rx_clk1 -setup 0
set_multicycle_path -from [get_clocks GmiiToRgmiiCore_rgmii_rx_clk2] -to $rx_clk1 -hold -1

# Identify RGMII Tx Pads only.  
create_generated_clock -add -name rgmii_tx_clk2 -divide_by 1 -source [get_pins -of [get_cells -hier -filter {name =~ *rgmii_txc_out}] -filter {name =~ *C}] -master_clock [get_clocks gmii_clk_125m_*] [get_ports ethTxClk[1]]


set_false_path -rise_from $ip_gtx_clk -fall_to [get_clocks rgmii_tx_clk2] -setup
set_false_path -fall_from $ip_gtx_clk -rise_to [get_clocks rgmii_tx_clk2] -setup
set_false_path -rise_from $ip_gtx_clk -rise_to [get_clocks rgmii_tx_clk2] -hold
set_false_path -fall_from $ip_gtx_clk -fall_to [get_clocks rgmii_tx_clk2] -hold

set_output_delay -1.0 -max -clock [get_clocks rgmii_tx_clk2] [get_ports {ethTxDataA[1] ethTxDataB[1] ethTxDataC[1] ethTxDataD[1] ethTxCtrl[1]}]
set_output_delay -2.6 -min -clock [get_clocks rgmii_tx_clk2] [get_ports {ethTxDataA[1] ethTxDataB[1] ethTxDataC[1] ethTxDataD[1] ethTxCtrl[1]}] -add_delay 
set_output_delay -1.0 -max -clock [get_clocks rgmii_tx_clk2] [get_ports {ethTxDataA[1] ethTxDataB[1] ethTxDataC[1] ethTxDataD[1] ethTxCtrl[1]}] -clock_fall
set_output_delay -2.6 -min -clock [get_clocks rgmii_tx_clk2] [get_ports {ethTxDataA[1] ethTxDataB[1] ethTxDataC[1] ethTxDataD[1] ethTxCtrl[1]}] -clock_fall 

set_multicycle_path 0 -setup -end -rise_from $ip_gtx_clk -rise_to [get_clocks rgmii_tx_clk2]
set_multicycle_path 0 -setup -end -fall_from $ip_gtx_clk -fall_to [get_clocks rgmii_tx_clk2]
# StdLib
set_property ASYNC_REG TRUE [get_cells -hierarchical *crossDomainSyncReg_reg*]

#########################################################
# Pin Locations. All Defined Here
#########################################################

set_property PACKAGE_PIN AA19 [get_ports led[0]]
set_property PACKAGE_PIN T15  [get_ports led[1]]

set_property PACKAGE_PIN AB13 [get_ports i2cScl]
set_property PACKAGE_PIN AA10 [get_ports i2cSda]

set_property PACKAGE_PIN U6  [get_ports pciRefClkP]
set_property PACKAGE_PIN U5  [get_ports pciRefClkM]
#set_property PACKAGE_PIN T4  [get_ports pciRxP]
#set_property PACKAGE_PIN T3  [get_ports pciRxM]
#set_property PACKAGE_PIN U2  [get_ports pciTxP]
#set_property PACKAGE_PIN U1  [get_ports pciTxM]
set_property PACKAGE_PIN T14 [get_ports pciResetL]

set_property PACKAGE_PIN AA6 [get_ports ethRxP]
set_property PACKAGE_PIN AA5 [get_ports ethRxM]
set_property PACKAGE_PIN AB4 [get_ports ethTxP]
set_property PACKAGE_PIN AB3 [get_ports ethTxM]
#set_property PACKAGE_PIN V4 [get_ports ethRxP]
#set_property PACKAGE_PIN V3 [get_ports ethRxM]
#set_property PACKAGE_PIN W2 [get_ports ethTxP]
#set_property PACKAGE_PIN W1 [get_ports ethTxM]

set_property PACKAGE_PIN W2  [get_ports dtmToRtmHsP]
set_property PACKAGE_PIN W1  [get_ports dtmToRtmHsM]
set_property PACKAGE_PIN V4  [get_ports rtmToDtmHsP]
set_property PACKAGE_PIN V3  [get_ports rtmToDtmHsM]
#set_property PACKAGE_PIN AB4 [get_ports dtmToRtmHsP]
#set_property PACKAGE_PIN AB3 [get_ports dtmToRtmHsM]
#set_property PACKAGE_PIN AA6 [get_ports rtmToDtmHsP]
#set_property PACKAGE_PIN AA5 [get_ports rtmToDtmHsM]

set_property PACKAGE_PIN W6  [get_ports locRefClkP]
set_property PACKAGE_PIN W5  [get_ports locRefClkM]

set_property PACKAGE_PIN U9   [get_ports dpmClkP[2]]
set_property PACKAGE_PIN U8   [get_ports dpmClkM[2]]
set_property PACKAGE_PIN W9   [get_ports dpmClkP[1]]
set_property PACKAGE_PIN Y8   [get_ports dpmClkM[1]]
set_property PACKAGE_PIN AA14 [get_ports dpmClkP[0]]
set_property PACKAGE_PIN AB14 [get_ports dpmClkM[0]]

set_property PACKAGE_PIN V8  [get_ports busyOutP]
set_property PACKAGE_PIN W8  [get_ports busyOutM]
set_property IOSTANDARD LVDS_25  [get_ports busyOutP]
set_property IOSTANDARD LVDS_25  [get_ports busyOutM]
set_property PACKAGE_PIN T20  [get_ports sdInP]
set_property PACKAGE_PIN U20  [get_ports sdInM]
set_property IOSTANDARD LVDS_25  [get_ports sdInP]
set_property IOSTANDARD LVDS_25  [get_ports sdInM]
set_property PACKAGE_PIN R17  [get_ports lolInP]
set_property PACKAGE_PIN R18  [get_ports lolInM]
set_property IOSTANDARD LVDS_25  [get_ports lolInP]
set_property IOSTANDARD LVDS_25  [get_ports lolInM]

#set_property PACKAGE_PIN V8  [get_ports dtmToRtmLsP[5]]
#set_property PACKAGE_PIN W8  [get_ports dtmToRtmLsM[5]]
#set_property PACKAGE_PIN U10 [get_ports dtmToRtmLsP[4]]
#set_property PACKAGE_PIN V10 [get_ports dtmToRtmLsM[4]]
#set_property PACKAGE_PIN T20 [get_ports dtmToRtmLsP[3]]
#set_property PACKAGE_PIN U20 [get_ports dtmToRtmLsM[3]]
#set_property PACKAGE_PIN R17 [get_ports dtmToRtmLsP[2]]
#set_property PACKAGE_PIN R18 [get_ports dtmToRtmLsM[2]]
#set_property PACKAGE_PIN R19 [get_ports dtmToRtmLsP[1]]
#set_property PACKAGE_PIN T19 [get_ports dtmToRtmLsM[1]]
#set_property PACKAGE_PIN T17 [get_ports dtmToRtmLsP[0]]
#set_property PACKAGE_PIN U17 [get_ports dtmToRtmLsM[0]]

set_property PACKAGE_PIN R22  [get_ports idpmFbP[3]]
set_property PACKAGE_PIN T22  [get_ports idpmFbM[3]]
set_property PACKAGE_PIN N21  [get_ports idpmFbP[2]]
set_property PACKAGE_PIN N22  [get_ports idpmFbM[2]]
set_property PACKAGE_PIN W19  [get_ports idpmFbP[1]]
set_property PACKAGE_PIN W20  [get_ports idpmFbM[1]]
set_property PACKAGE_PIN V21  [get_ports idpmFbP[0]]
set_property PACKAGE_PIN V22  [get_ports idpmFbM[0]]
set_property PACKAGE_PIN W21  [get_ports odpmFbP[3]]
set_property PACKAGE_PIN Y22  [get_ports odpmFbM[3]]
set_property PACKAGE_PIN AA20 [get_ports odpmFbP[2]]
set_property PACKAGE_PIN AB20 [get_ports odpmFbM[2]]
set_property PACKAGE_PIN Y21  [get_ports odpmFbP[1]]
set_property PACKAGE_PIN AA21 [get_ports odpmFbM[1]]
set_property PACKAGE_PIN AA22 [get_ports odpmFbP[0]]
set_property PACKAGE_PIN AB22 [get_ports odpmFbM[0]]

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

set_property PACKAGE_PIN F2 [get_ports ethRxCtrl[1]]
set_property PACKAGE_PIN J5 [get_ports ethRxClk[1]]
set_property PACKAGE_PIN J3 [get_ports ethRxDataA[1]]
set_property PACKAGE_PIN H3 [get_ports ethRxDataB[1]]
set_property PACKAGE_PIN H2 [get_ports ethRxDataC[1]]
set_property PACKAGE_PIN H1 [get_ports ethRxDataD[1]]
set_property PACKAGE_PIN F4 [get_ports ethTxCtrl[1]]
set_property PACKAGE_PIN F5 [get_ports ethTxClk[1]]
set_property PACKAGE_PIN H7 [get_ports ethTxDataA[1]]
set_property PACKAGE_PIN G7 [get_ports ethTxDataB[1]]
set_property PACKAGE_PIN F7 [get_ports ethTxDataC[1]]
set_property PACKAGE_PIN F6 [get_ports ethTxDataD[1]]
set_property PACKAGE_PIN G4 [get_ports ethMdc[1]]
set_property PACKAGE_PIN J6 [get_ports ethMio[1]]
set_property PACKAGE_PIN H6 [get_ports ethResetL[1]]

set_property PACKAGE_PIN N3 [get_ports ethRxCtrl[0]]
set_property PACKAGE_PIN M5 [get_ports ethRxClk[0]]
set_property PACKAGE_PIN N2 [get_ports ethRxDataA[0]]
set_property PACKAGE_PIN L2 [get_ports ethRxDataB[0]]
set_property PACKAGE_PIN L1 [get_ports ethRxDataC[0]]
set_property PACKAGE_PIN P1 [get_ports ethRxDataD[0]]
set_property PACKAGE_PIN L7 [get_ports ethTxCtrl[0]]
set_property PACKAGE_PIN M4 [get_ports ethTxClk[0]]
set_property PACKAGE_PIN L6 [get_ports ethTxDataA[0]]
set_property PACKAGE_PIN P4 [get_ports ethTxDataB[0]]
set_property PACKAGE_PIN M2 [get_ports ethTxDataC[0]]
set_property PACKAGE_PIN K3 [get_ports ethTxDataD[0]]
set_property PACKAGE_PIN K7 [get_ports ethMdc[0]]
set_property PACKAGE_PIN K6 [get_ports ethMio[0]]
set_property PACKAGE_PIN N5 [get_ports ethResetL[0]]

#########################################################
# Common IO Types
#########################################################

set_property IOSTANDARD LVCMOS25 [get_ports i2cScl]
set_property IOSTANDARD LVCMOS25 [get_ports i2cSda]

set_property IOSTANDARD LVCMOS25 [get_ports pciResetL]

set_property IOSTANDARD LVCMOS25 [get_ports clkSelA]
set_property IOSTANDARD LVCMOS25 [get_ports clkSelB]

set_property IOSTANDARD LVCMOS25 [get_ports bpClkIn]
set_property IOSTANDARD LVCMOS25 [get_ports bpClkOut]

set_property IOSTANDARD LVCMOS25 [get_ports dtmToIpmiP]
set_property IOSTANDARD LVCMOS25 [get_ports dtmToIpmiM]

set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethRxCtrl]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethRxClk]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethRxDataA]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethRxDataB]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethRxDataC]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethRxDataD]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethTxCtrl]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethTxClk]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethTxDataA]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethTxDataB]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethTxDataC]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethTxDataD]
set_property IOSTANDARD LVCMOS18        [get_ports ethMdc]
set_property IOSTANDARD LVCMOS18        [get_ports ethMio]
set_property IOSTANDARD LVCMOS18        [get_ports ethResetL]

set_property IOSTANDARD LVDS_25         [get_ports dpmClkP]
set_property IOSTANDARD LVDS_25         [get_ports dpmClkM]
set_property IOSTANDARD LVDS_25         [get_ports idpmFbP]
set_property IOSTANDARD LVDS_25         [get_ports idpmFbM]
set_property IOSTANDARD LVDS_25         [get_ports odpmFbP]
set_property IOSTANDARD LVDS_25         [get_ports odpmFbM]
set_property IOSTANDARD LVCMOS25        [get_ports led]


#########################################################
# Top Level IO Types, To Be Defined At Top Level
#########################################################

#set_property IOSTANDARD LVDS_25 [get_ports dtmToRtmLsP]
#set_property IOSTANDARD LVDS_25 [get_ports dtmToRtmLsM]

#set_property IOSTANDARD LVDS_25 [get_ports plSpareP]
#set_property IOSTANDARD LVDS_25 [get_ports plSpareM]
