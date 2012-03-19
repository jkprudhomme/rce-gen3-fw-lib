###############################################################################
##
## Copyright (c) 2007 Xilinx, Inc. All Rights Reserved.
##
## plb_v46_v2_1_0.tcl
##
###############################################################################


#***--------------------------------***-----------------------------------***
#
#			     IPLEVEL_DRC_PROC
#
#***--------------------------------***-----------------------------------***

proc check_iplevel_settings {mhsinst} {

    #check_rearb            $mhsinst
    check_DCR_connectivity $mhsinst
    check_num_ms			$mhsinst

}

# Remove checks for this parameter which is to be obsolete after EDK_K
# C_NUM_CLK_PLB2OPB_REARB >= 5
# proc check_rearb {mhsinst} {
# 
#     set num_clk [xget_hw_parameter_value $mhsinst "C_NUM_CLK_PLB2OPB_REARB"]
# 
#     if { $num_clk < 5 } {
# 
# 	error "\n C_NUM_CLK_PLB2OPB_REARB must be equal to or greater than 5\n" "" "mdt_error"
# 
#     }
# }

#-----------------------------------
# if C_DCR_INTFCE = 1, then 
# bus interface SDCR must be connected
#-----------------------------------
proc check_DCR_connectivity {mhsinst} {

    set instname   [xget_hw_parameter_value $mhsinst "INSTANCE"]
    set ipname     [xget_hw_option_value    $mhsinst "IPNAME"]
    set dcr_intfce [xget_hw_parameter_value $mhsinst "C_DCR_INTFCE"]
    set dcr_busif  [xget_hw_busif_value     $mhsinst "SDCR"]

    if {([string length $dcr_busif] == 0 && $dcr_intfce)} {

        puts  "\nWARNING:  $instname ($ipname) - \n      The parameter C_DCR_INTFCE is enabled but the SDCR bus interface is not set"
	
    }

    if {([string length $dcr_busif] != 0 && !$dcr_intfce)} {

        error  "\n The SDCR bus interface is connected but the parameter C_DCR_INTFCE is not enabled.\n" "" "mdt_error"
	
    }

}


# --------------------------------------------------------------------------------------------
# To fix CR # 476317
# Insert warning for condition when C_PLBV46_NUM_MASTERS > 16 or C_PLBV46_NUM_SLAVES > 16
# --------------------------------------------------------------------------------------------

proc check_num_ms {mhsinst} {

    set num_masters   [xget_hw_parameter_value 	  $mhsinst "C_PLBV46_NUM_MASTERS"]
    set num_slaves    [xget_hw_parameter_value    $mhsinst "C_PLBV46_NUM_SLAVES"]

    if { $num_masters > 16 } {

        puts  "\nWARNING:  $instname ($ipname) - \n      The parameter C_PLBV46_NUM_MASTERS is set to a value greater than 16 and is not supported in this IP core."
	
    }

    if { $num_slaves > 16 } {

        puts  "\nWARNING:  $instname ($ipname) - \n      The parameter C_PLBV46_NUM_SLAVES is set to a value greater than 16 and is not supported in this IP core."
	
    }

}
