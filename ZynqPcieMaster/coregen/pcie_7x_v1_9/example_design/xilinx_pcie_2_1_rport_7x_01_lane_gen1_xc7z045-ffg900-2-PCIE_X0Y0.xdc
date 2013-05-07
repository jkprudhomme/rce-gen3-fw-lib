##-----------------------------------------------------------------------------
##
## (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
##-----------------------------------------------------------------------------
## Project    : Series-7 Integrated Block for PCI Express
## File       : xilinx_pcie_2_1_rport_7x_01_lane_gen1_xc7z045-ffg900-2-PCIE_X0Y0.xdc
## Version    : 1.9
#
###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################

###############################################################################
# User Physical Constraints
###############################################################################


###############################################################################
# Pinout and Related I/O Constraints
###############################################################################

#
# SYS reset (input) signal.  The sys_reset_n signal should be
# obtained from the PCI Express interface if possible.  For
# slot based form factors, a system reset signal is usually
# present on the connector.  For cable based form factors, a
# system reset signal may not be available.  In this case, the
# system reset signal must be generated locally by some form of
# supervisory circuit.  You may change the IOSTANDARD and LOC
# to suit your requirements and VCCO voltage banking rules.
# Some 7 series devices do not have 3.3 V I/Os available.
# Therefore the appropriate level shift is required to operate
# with these devices that contain only 1.8 V banks.
#

set_false_path -from [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]

#
#
# SYS clock 100 MHz (input) signal. The sys_clk_p and sys_clk_n
# signals are the PCI Express reference clock. Virtex-7 GT
# Transceiver architecture requires the use of a dedicated clock
# resources (FPGA input pins) associated with each GT Transceiver.
# To use these pins an IBUFDS primitive (refclk_ibuf) is
# instantiated in user's design.
# Please refer to the Virtex-7 GT Transceiver User Guide
# (UG) for guidelines regarding clock resource selection.
#

set_property LOC IBUFDS_GTE2_X0Y7 [get_cells refclk_ibuf]

#
# Transceiver instance placement.  This constraint selects the
# transceivers to be used, which also dictates the pinout for the
# transmit and receive differential pairs.  Please refer to the
# Virtex-7 GT Transceiver User Guide (UG) for more information.
#

# PCIe Lane 0
set_property LOC GTXE2_CHANNEL_X0Y15 [get_cells {cgator_wrapper_i/rport/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]


#
# PCI Express Block placement. This constraint selects the PCI Express
# Block to be used.
#

set_property LOC PCIE_X0Y0 [get_cells cgator_wrapper_i/rport/pcie_top_i/pcie_7x_i/pcie_block_i]

#
# BlockRAM placement
#
set_property LOC RAMB36_X6Y34 [get_cells {cgator_wrapper_i/rport/pcie_top_i/pcie_7x_i/pcie_bram_top/pcie_brams_rx/brams[0].ram/use_sdp.ramb36sdp/genblk*.ramb36_dp_bl.ram36sd_bl_2}]
set_property LOC RAMB36_X6Y31 [get_cells {cgator_wrapper_i/rport/pcie_top_i/pcie_7x_i/pcie_bram_top/pcie_brams_tx/brams[0].ram/use_sdp.ramb36sdp/genblk*.ramb36_dp_bl.ram36sd_bl_2}]

###############################################################################
# Timing Constraints
###############################################################################

#
# Timing requirements and related constraints.
#

create_clock -name sys_clk -period 10 [get_pins refclk_ibuf/O]

create_generated_clock -name clk_125mhz -source [get_pins refclk_ibuf/O] -edges {1 2 3} -edge_shift {0 -1 -2} [get_pins cgator_wrapper_i/rport/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT0]



create_generated_clock -name clk_userclk -source [get_pins refclk_ibuf/O] -edges {1 2 3} -edge_shift {0 3 6} [get_pins cgator_wrapper_i/rport/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT2]

create_generated_clock -name clk_userclk2 -source [get_pins refclk_ibuf/O] -edges {1 2 3} -edge_shift {0 3 6} [get_pins cgator_wrapper_i/rport/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]


set_false_path -through [get_pins {cgator_wrapper_i/rport/pcie_top_i/pcie_7x_i/pcie_block_i/PLPHYLNKUPN*}]
set_false_path -through [get_pins {cgator_wrapper_i/rport/pcie_top_i/pcie_7x_i/pcie_block_i/PLRECEIVEDHOTRST*}]

set_false_path -through [get_nets {cgator_wrapper_i/rport/gt_top_i/pipe_wrapper_i/user_resetdone*}]
set_false_path -through [get_nets {cgator_wrapper_i/rport/gt_top_i/pipe_wrapper_i/pipe_lane[0].pipe_rate.pipe_rate_i/*}]

set_false_path -through [get_nets {cgator_wrapper_i/rport/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_sel*}]

set_case_analysis 1 [get_pins {cgator_wrapper_i/rport/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S0}]
set_case_analysis 0 [get_pins {cgator_wrapper_i/rport/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S1}]

set_multicycle_path -from [get_cells cgator_wrapper_i/rport/user_reset_int_reg] -to [all_registers] 1
set_multicycle_path -from [get_cells cgator_wrapper_i/rport/user_lnk_up_int_reg] -to [get_cells cgator_wrapper_i/rport/pcie_top_i/axi_basic_top_i/tx_inst/xhdl12.tx_thrl_ctl_inst/tready_thrtl_xhdl1_reg] 1

set_false_path -through [get_cells {cgator_wrapper_i/rport/gt_top_i/pipe_wrapper_i/pipe_reset.pipe_reset_i/cpllreset_reg*}]


###############################################################################
# Physical Constraints
###############################################################################

###############################################################################
# End
###############################################################################
