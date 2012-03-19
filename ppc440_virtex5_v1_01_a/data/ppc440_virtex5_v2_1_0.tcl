#############################################################################
##
## Copyright (c) 2007 Xilinx, Inc. All Rights Reserved.
##
## ppc405_virtex4_v2_1_0.tcl
##
#############################################################################

## @BEGIN_CHANGELOG EDK_K_SP2
## - Added DRC error if PARAMETER C_MPLB_WDOG_ENABLE is explicitly set to 1 in MHS.
## - Fixed MC clock frequency DRC rounding error.
## @END_CHANGELOG

#***--------------------------------***------------------------------------***
#
#			     IPLEVEL_DRC_PROC
#
#***--------------------------------***------------------------------------***

#
# {MPLB | PPC440MC} arbitration priority values must be unique
#
proc check_iplevel_settings { mhsinst } {

    set mplbList {C_MPLB_PRIO_ICU C_MPLB_PRIO_DCUW C_MPLB_PRIO_DCUR C_MPLB_PRIO_SPLB0 C_MPLB_PRIO_SPLB1}

    set ppc440mcList {C_PPC440MC_PRIO_ICU C_PPC440MC_PRIO_DCUW C_PPC440MC_PRIO_DCUR C_PPC440MC_PRIO_SPLB0 C_PPC440MC_PRIO_SPLB1}
 
    check_prio_value_unique     $mhsinst $mplbList
    check_prio_value_unique     $mhsinst $ppc440mcList
    check_mplb_wdog_not_set     $mhsinst
    check_mplb_round_robin     $mhsinst
}

proc check_prio_value_unique { mhsinst prioList } {

    set  nameList ""
    set  valueList  ""

    for {set i 0} {$i < [llength $prioList]} {incr i} {

        set     name      [lindex $prioList $i]
    	lappend nameList  $name
    	lappend valueList [xget_hw_parameter_value $mhsinst $name]
    }

    set  sortList [lsort $valueList]
    set  size     [expr [llength $sortList] - 1]

    for {set j 0} {$j < $size} {incr j} {

	set first  [lindex $sortList $j]
	set second [lindex $sortList [expr $j + 1]]

	if { [expr $second - $first] != 1 } {

	    error "\nThe parameters $nameList, they all must be set to a unique permutation of the values 0 through 4\n" "" "mdt_error"

	}
    }
}

proc check_mplb_wdog_not_set  {mhsinst} {
    set wdog_handle [xget_hw_parameter_handle $mhsinst C_MPLB_WDOG_ENABLE]
    set wdog_mhs_value [xget_hw_subproperty_value $wdog_handle MHS_VALUE]
    if { $wdog_mhs_value == 1 } {
      error "\nThe MPLB watchdog timer feature of ppc440_virtex5 is not supported due to hardware functionality issues. Please disable PARAMETER C_MPLB_WDOG_ENABLE in your MHS design, and please make sure your embedded software does not set the WDOG_ENA bit (bit #23) of the MPLB Configuration Register (CFG_PLBM at DCR offset 0x54).\n" "" "mdt_error"
    }
}

proc check_mplb_round_robin  {mhsinst} {
    set mplb_arb [xget_hw_parameter_value $mhsinst C_MPLB_ARB_MODE]
    set mplb_read_pipe [xget_hw_parameter_value $mhsinst C_MPLB_READ_PIPE_ENABLE]
    if { $mplb_arb == 1 && $mplb_read_pipe == 0 } {
      puts "\nWARNING: Parameter C_MPLB_ARB_MODE is set to 1 (round-robin) and parameter C_MPLB_READ_PIPE_ENABLE is set to 0. This combination is not advised, as it may allow one crossbar master to monopolize the MPLB bus under certain conditions."
    }
}

#***--------------------------------***-----------------------------------***
#
#			     SYSLEVEL_UPDATE_VALUE_PROC
#
#***--------------------------------***-----------------------------------***

#
# update the value of parameter C_PPC440MC_ADDR_BASE/C_PPC440MC_ADDR_HIGH 
# by tracing the connection on P2P bus PPC440MC and copying the value
# from the BASEADDR/HIGHADDR parameters on the connected memory
# controller instance
#

proc syslevel_update_ppc440mc_addr { param_handle } {

    set mhsinst [xget_hw_parent_handle $param_handle]
    set param   [xget_hw_name          $param_handle] 
    set type    [string range $param 16 19]

    # Get the connector name connected to PPC440MC
    set connector [xget_hw_busif_value   $mhsinst "PPC440MC"]

    if {[llength $connector] == 0} {
 
    	return [xget_hw_value $param_handle]	
    }

    set mhs_handle [xget_hw_parent_handle $mhsinst]
    set busifs     [xget_hw_connected_busifs_handle $mhs_handle $connector "target"]

    set busifs_name [xget_hw_name [lindex $busifs 0]]
    set ip_handle  [xget_hw_parent_handle [lindex $busifs 0]]
    set list_param [xget_hw_parameter_handle $ip_handle *]


    foreach pam_handle $list_param {

	set addr_handle [xget_hw_subproperty_handle $pam_handle "ADDRESS"]
	# ADDRESS tag must be valid
	if {[string length $addr_handle] == 0} {
	    continue	
	}

	# check ADDRESS = BASE only
	set addr_value [xget_hw_value $addr_handle]
	if {[string compare -nocase "BASE" $addr_value] != 0} {
	    continue	
	}

	# RESOLVED_ISVALID tag must be 1 
	set isvd_value [xget_hw_subproperty_value $pam_handle "RESOLVED_ISVALID"]
	if {$isvd_value == 0} {
	    continue	
	}

	# BUS tag must contain busifs_name 
	set bus_value   [xget_hw_subproperty_value $pam_handle "BUS"]
	if {[string first ":$busifs_name:" ":$bus_value:"] != -1} {

	    if {[string compare -nocase "BASE" $type] == 0} {

	    	return [xget_hw_value $pam_handle]

	    } elseif {[string compare -nocase "HIGH" $type] == 0} {

	        set high_name [xget_hw_subproperty_value $pam_handle "PAIR"]
    	        return [xget_hw_parameter_value $ip_handle $high_name]
		
	    }
	}
    }
}


#***--------------------------------***------------------------------------***
#
#			     SYSLEVEL_DRC_PROC
#
#***--------------------------------***------------------------------------***

#
#
proc check_syslevel_settings { mhsinst } {

    check_splb_num_masters $mhsinst "C_SPLB0_NUM_MASTERS"
    check_splb_num_masters $mhsinst "C_SPLB1_NUM_MASTERS"
    check_mc_freq $mhsinst
    check_clock_connectivity $mhsinst
}


#
# C_SPLBn_NUM_MASTERS must be <= 4, where n = 0, 1
#
proc check_splb_num_masters { mhsinst param } {

    set splb_num_masters [xget_hw_parameter_value $mhsinst $param]
    set bus_if "SPLB0"

    if { $splb_num_masters > 4 } {

        if { [string first "SPLB1" $param] != -1 } {
    	    set bus_if "SPLB1"
	}

    	error "\nMore than 4 masters connected to $bus_if interface.\n" "" "mdt_error"

   }

}

##
## Check that frequency of MC clock matches the native clock frequency of the connected mem-con.
##

proc check_mc_freq {mhsinst} {
    set mc_clk_handle [xget_hw_port_handle $mhsinst "CPMMCCLK"]
    set mc_clk_freq_hz [xget_hw_subproperty_value $mc_clk_handle "CLK_FREQ_HZ"]
    if { [llength $mc_clk_freq_hz] > 0 } {
      set connector [xget_hw_busif_value   $mhsinst "PPC440MC"]
      if {[llength $connector] > 0} {
        set mhs_handle [xget_hw_parent_handle $mhsinst]
        set busifs     [xget_hw_connected_busifs_handle $mhs_handle $connector "target"]
        set busifs_name [xget_hw_name [lindex $busifs 0]]
        set memcon_handle  [xget_hw_parent_handle [lindex $busifs 0]]
        set memcon_instname   [xget_hw_parameter_value $memcon_handle "INSTANCE"]
        ## Look for or MPMC-style period param
        set memcon_period_ps [xget_hw_parameter_value $memcon_handle "C_MPMC_CLK0_PERIOD_PS"]  
        if {[llength $memcon_period_ps] == 0} {
          ## Look for or ppc440mc_ddr2-style period param
          set memcon_period_ps [xget_hw_parameter_value $memcon_handle "C_MC_MIBCLK_PERIOD_PS"] 
        }
        if {[llength $memcon_period_ps] > 0} {
          set rate_diff [expr abs( [expr (1.0e12 / $mc_clk_freq_hz) - $memcon_period_ps] )]
	        if {$rate_diff > 1.0 } {
	        	set memcon_freq [expr 1000000000000 / $memcon_period_ps]
            error "\n The PPC440MC clock input (CPMMCCLK) must be driven by the same clock source as the connected memory controller. Found clock frequency ${memcon_freq} on instance ${memcon_instname} which does not match CPMMCCLK.\n" "" "mdt_error"
          }
        }
      }
    }
}

proc check_clock_connectivity {mhsinst} {
    set mplb_bus [xget_hw_busif_value   $mhsinst "MPLB"]
    set splb0_bus [xget_hw_busif_value   $mhsinst "SPLB0"]
    set splb1_bus [xget_hw_busif_value   $mhsinst "SPLB1"]
    set mc_bus [xget_hw_busif_value   $mhsinst "PPC440MC"]
    set dma0_bus [xget_hw_busif_value   $mhsinst "LLDMA0"]
    set dma1_bus [xget_hw_busif_value   $mhsinst "LLDMA1"]
    set dma2_bus [xget_hw_busif_value   $mhsinst "LLDMA2"]
    set dma3_bus [xget_hw_busif_value   $mhsinst "LLDMA3"]
    set mdcr_bus [xget_hw_busif_value   $mhsinst "MDCR"]
    set sdcr_bus [xget_hw_busif_value   $mhsinst "SDCR"]
    set fcb_bus [xget_hw_busif_value   $mhsinst "MFCB"]
    set fcm_bus [xget_hw_busif_value   $mhsinst "MFCM"]
    set cpu_clk [xget_hw_port_value   $mhsinst "CPMC440CLK"]
    set xbar_clk [xget_hw_port_value   $mhsinst "CPMINTERCONNECTCLK"]
    set mc_clk [xget_hw_port_value   $mhsinst "CPMMCCLK"]
    set dcr_clk [xget_hw_port_value   $mhsinst "CPMDCRCLK"]
    set fcm_clk [xget_hw_port_value   $mhsinst "CPMFCMCLK"]
    set dma0_clk [xget_hw_port_value   $mhsinst "CPMDMA0LLCLK"]
    set dma1_clk [xget_hw_port_value   $mhsinst "CPMDMA1LLCLK"]
    set dma2_clk [xget_hw_port_value   $mhsinst "CPMDMA2LLCLK"]
    set dma3_clk [xget_hw_port_value   $mhsinst "CPMDMA3LLCLK"]

    if {[llength $cpu_clk] == 0 && (
      [llength $mplb_bus] > 0 ||
      [llength $splb0_bus] > 0 ||
      [llength $splb1_bus] > 0 ||
      [llength $mc_bus] > 0 ||
      [llength $dma0_bus] > 0 ||
      [llength $dma1_bus] > 0 ||
      [llength $dma2_bus] > 0 ||
      [llength $dma3_bus] > 0 ||
      [llength $mdcr_bus] > 0 ||
      [llength $sdcr_bus] > 0 ||
      [llength $fcb_bus] > 0 ||
      [llength $fcm_bus] > 0 )} {
        error "\n The CPU clock input (CPMC440CLK) must be connected whenever any of the following bus interfaces are connected: MPLB, SPLB0/1, PPC440MC, LLDMA0-3, MDCR, SDCR, MFCB, MFCM.\n" "" "mdt_error"
    }

    if {[llength $xbar_clk] == 0 && (
      [llength $mplb_bus] > 0 ||
      [llength $splb0_bus] > 0 ||
      [llength $splb1_bus] > 0 ||
      [llength $mc_bus] > 0 ||
      [llength $dma0_bus] > 0 ||
      [llength $dma1_bus] > 0 ||
      [llength $dma2_bus] > 0 ||
      [llength $dma3_bus] > 0 )} {
        error "\n The crossbar clock input (CPMINTERCONNECTCLK) must be connected whenever any of the following bus interfaces are connected: MPLB, SPLB0/1, PPC440MC, LLDMA0-3.\n" "" "mdt_error"
    }

    if {[llength $mc_clk] == 0 && 
      [llength $mc_bus] > 0 } {
        error "\n The MC clock input (CPMMCCLK) must be connected whenever the PPC440MC bus interface is connected.\n" "" "mdt_error"
    }

    if {[llength $dcr_clk] == 0 && (
      [llength $mdcr_bus] > 0 ||
      [llength $sdcr_bus] > 0 )} {
        error "\n The DCR clock input (CPMDCRCLK) must be connected whenever any of the following bus interfaces are connected: MDCR, SDCR.\n" "" "mdt_error"
    }

    if {[llength $fcm_clk] == 0 && 
      [llength $fcm_bus] > 0 } {
        error "\n The FCM clock input (CPMFCMCLK) must be connected whenever the MFCM bus interface is connected.\n" "" "mdt_error"
    }

    if {[llength $dma0_clk] == 0 && 
      [llength $dma0_bus] > 0 } {
        error "\n The DMA0 clock input (CPMDMA0LLCLK) must be connected whenever any of the LLDMA0 bus interface is connected.\n" "" "mdt_error"
    }

    if {[llength $dma1_clk] == 0 && 
      [llength $dma1_bus] > 0 } {
        error "\n The DMA1 clock input (CPMDMA1LLCLK) must be connected whenever any of the LLDMA1 bus interface is connected.\n" "" "mdt_error"
    }

    if {[llength $dma2_clk] == 0 && 
      [llength $dma2_bus] > 0 } {
        error "\n The DMA2 clock input (CPMDMA2LLCLK) must be connected whenever any of the LLDMA2 bus interface is connected.\n" "" "mdt_error"
    }

    if {[llength $dma3_clk] == 0 && 
      [llength $dma3_bus] > 0 } {
        error "\n The DMA3 clock input (CPMDMA3LLCLK) must be connected whenever any of the LLDMA3 bus interface is connected.\n" "" "mdt_error"
    }
}

#***--------------------------------***------------------------------------***
#
#			     PLATGEN_SYSLEVEL_UPDATE_PROC
#
#***--------------------------------***------------------------------------***

##
## Generate TimeSpec constraining SPLB MBusy output path to 50% of PLB clock period,
##   if Xbar:SPLB clock ratio > 1:1
##

proc generate_corelevel_ucf {mhsinst} {
    # Create pcore UCF file
    set  filePath [xget_ncf_dir $mhsinst]
    file mkdir    $filePath
    set    instname   [xget_hw_parameter_value $mhsinst "INSTANCE"]
    set    name_lower [string   tolower   $instname]
    set    fileName   $name_lower
    append fileName   "_wrapper.ucf"
    append filePath   $fileName
    set    outputFile [open $filePath "w"]

    set enable_tspecs [xget_hw_parameter_value $mhsinst "C_GENERATE_PLB_TIMESPECS"]
    set xbar_clk_handle [xget_hw_port_handle $mhsinst "CPMINTERCONNECTCLK"]
    set xbar_clk_freq [xget_hw_subproperty_value $xbar_clk_handle "CLK_FREQ_HZ"]

    foreach i {0 1} {
      set connector [xget_hw_busif_value     $mhsinst "SPLB${i}"]
      if {[llength $connector] != 0} {  ## SPLBi is connected
        ## Define TimeGroup for this SPLB busif
        puts $outputFile "INST \"${instname}/*PPCS${i}PLBMBUSY_reg*\" TNM = \"${instname}_PPCS${i}PLBMBUSY\";"
      }
    }
    foreach i {0 1} {
      set connector [xget_hw_busif_value     $mhsinst "SPLB${i}"]
      if {[llength $connector] != 0} {  ## SPLBi is connected
        set splb_clk_handle [xget_hw_port_handle $mhsinst "CPMPPCS${i}PLBCLK"]
        set splb_clk_freq [xget_hw_subproperty_value $splb_clk_handle "CLK_FREQ_HZ"]
        if { [llength ${splb_clk_freq}] == 0 || [llength ${xbar_clk_freq}] == 0 } {
          puts "\nWARNING: Frequencies could not be determined for the Interconnect clock (CPMINTERCONNECTCLK) and/or the PLB bus connected to SPLB0 or SPLB1."
          puts "Therefore, TimeSpecs are not being generated for the pipeline flops on the PPCS*PLBMBUSY outputs."
          puts "If any master connected to SPLB0/1 relies on the MBusy signal, it is important to ensure that the PPCS*PLBMBUSY outputs of the PPC440 block arrive at their fabric pipeline registers within half of the PLB clock period."
          puts "This could be achieved by constraining the PPCS*PLBMBUSY_reg* D-input paths, as follows:"
          puts "  TIMESPEC \"TS_${instname}_PPCS0PLBMBUSY\" = FROM CPUS TO \"${instname}_PPCS0PLBMBUSY\" 5000 ps"
          puts "The value of this TimeSpec should be half of the SPLB clock period."
          puts "The TimeGroups \"${instname}_PPCS0PLBMBUSY\" and \"${instname}_PPCS1PLBMBUSY\" have been generated automatically (if connected)."
          puts "For automatic TimeSpec generation, please specify all Interconnect and SPLB clock frequencies in your design.\n"
          close $outputFile
          return
        }
        if { $splb_clk_freq < $xbar_clk_freq - 1 } {
          set splb_clk_half_period_ps [expr 500000000000 / $splb_clk_freq]
          if { $enable_tspecs > 0 } {
            ## Constrain MBusy flop to 50% SPLB clk period
            puts $outputFile "TIMESPEC \"TS_${instname}_PPCS${i}PLBMBUSY\" = FROM CPUS TO \
              \"${instname}_PPCS${i}PLBMBUSY\" ${splb_clk_half_period_ps} ps;"
            ## Note: If the SPLB:XBAR clock ratio is 1:1, generate no TimeSpec; pipeline flop will then
            ##   remain constrained to the original SPLB period.
          } else {
            puts "\nWARNING: Generation of PLB-related TimeSpecs has been disabled for PowerPC ${instname}." 
            puts "The PLB bus connected to SPLB${i} is clocked at a lower frequency than the Interconnect clock (CPMINTERCONNECTCLK)."
            puts "Therefore, if any master connected to SPLB${i} relies on the MBusy signal, it would be important to ensure that the PPCS${i}PLBMBUSY output of the PPC440 block arrives at its fabric pipeline register within half of the PLB clock period. "
            puts "This could be achieved by constraining the PPCS${i}PLBMBUSY_reg* D-input paths, as follows:"
            puts "  TIMESPEC \"TS_${instname}_PPCS${i}PLBMBUSY\" = FROM CPUS TO \"${instname}_PPCS${i}PLBMBUSY\" ${splb_clk_half_period_ps} ps;"
            puts "The value of this TimeSpec should be half of the SPLB${i} clock period. "
            puts "The TimeGroup \"${instname}_PPCS${i}PLBMBUSY\" has been generated automatically.\n"
          }
        }
      }
    }
    close $outputFile
}

