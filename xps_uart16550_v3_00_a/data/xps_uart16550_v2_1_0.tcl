###############################################################################
##
## ## xps_uart16550_v2_1_0.tcl
##
###############################################################################
##  ***************************************************************************
##  ** DISCLAIMER OF LIABILITY						     **
##  **									     **
##  **  This file contains proprietary and confidential information of	     **
##  **  Xilinx, Inc. ("Xilinx"), that is distributed under a license	     **
##  **  from Xilinx, and may be used, copied and/or disclosed only	     **
##  **  pursuant to the terms of a valid license agreement with Xilinx.	     **
##  **  								     **
##  **  XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION		     **
##  **  ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER	     **
##  **  EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT		     **
##  **  LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,	     **
##  **  MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx	     **
##  **  does not warrant that functions included in the Materials will	     **
##  **  meet the requirements of Licensee, or that the operation of the	     **
##  **  Materials will be uninterrupted or error-free, or that defects	     **
##  **  in the Materials will be corrected. Furthermore, Xilinx does	     **
##  **  not warrant or make any representations regarding use, or the	     **
##  **  results of the use, of the Materials in terms of correctness,	     **
##  **  accuracy, reliability or otherwise.				     **
##  **  								     **
##  **  Xilinx products are not designed or intended to be fail-safe,	     **
##  **  or for use in any application requiring fail-safe performance,	     **
##  **  such as life-support or safety devices or systems, Class III	     **
##  **  medical devices, nuclear facilities, applications related to	     **
##  **  the deployment of airbags, or any other applications that could	     **
##  **  lead to death, personal injury or severe property or		     **
##  **  environmental damage (individually and collectively, "critical	     **
##  **  applications"). Customer assumes the sole risk and liability	     **
##  **  of any use of Xilinx products in critical applications,		     **
##  **  subject only to applicable laws and regulations governing	     **
##  **  limitations on product liability.				     **
##  **  								     **
##  **  Copyright 2007, 2008, 2009 Xilinx, Inc.	                             **
##  **  All rights reserved.						     **
##  **  								     **
##  **  This disclaimer and copyright notice must be retained as part	     **
##  **  of this file at all times.					     **
##  ***************************************************************************
###############################################################################


#***--------------------------------***------------------------------------***
#
# 		         IPLEVEL_UPDATE_VALUE_PROC
#
#***--------------------------------***------------------------------------***
#
# 1. check C_HAS_EXTERNAL_RCLK=1 if rclk is connected to a non-constant signal
# 2. check C_HAS_EXTERNAL_XIN=1  if xin is connected to a non-constant signal
#
proc check_iplevel_settings { mhsinst } {
    check_valid_connector $mhsinst "C_HAS_EXTERNAL_RCLK" "rclk"  
    check_valid_connector $mhsinst "C_HAS_EXTERNAL_XIN" "xin"  
}
#
#
proc check_valid_connector { mhsinst param_name pin } {
    set connector          [xget_hw_port_value      $mhsinst $pin]
    set has_external_value [xget_hw_parameter_value $mhsinst $param_name]
    set instname 	   [xget_hw_parameter_value $mhsinst "INSTANCE"]
    if {[llength $connector] != 0 && [string compare -nocase $connector "net_vcc"] != 0 && [string compare -nocase $connector "net_gnd"] != 0 && ![string match -nocase 0b* $connector] && ![string match -nocase 0x* $connector]} {
	if { $has_external_value == 0 } {
    	    puts  "\nWARNING: \n$instname port $pin is connected.  Parameter $param_name must be set to 1\n"
	}
    } else {
	if { $has_external_value != 0 } {
    	    error  "\n$instname port $pin is unconnected. Parameter $param_name must be set to 0 or port $pin must have proper clock connection.\n" "" "mdt_error"
	}
    }
}
