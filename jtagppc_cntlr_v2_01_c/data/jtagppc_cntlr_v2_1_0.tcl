############################################################################
##
## Copyright (c) 2004 Xilinx, Inc. All Rights Reserved.
## You may copy and modify these files for your own internal use solely with
## Xilinx programmable logic devices and  Xilinx EDK system or create IP
## modules solely for Xilinx programmable logic devices and Xilinx EDK system.
## No rights are granted to distribute any files unless they are distributed in
## Xilinx programmable logic devices.
##
## Purpose:
## Print a notice to users that for 2 PPC devices both must be in the chain.
## Will be made an error once C_DEVICE has been added to the IP.
##
#############################################################################

proc syslevel_update_ppc {param_handle} {
    set retval 0
    set jtag_handle [xget_hw_parent_handle $param_handle]
    set mhs_handle [xget_hw_parent_handle $jtag_handle]
    set list_inst [xget_hw_ipinst_handle $mhs_handle *]
    foreach inst_handle $list_inst {
      set special [xget_hw_option_value $inst_handle SPECIAL]
      if {[string compare -nocase -length 3 $special "PPC"] == 0} {
        incr retval
      }
    }
    return $retval
}

proc syslevel_drc_proc {mhsinst} {

    set known_ppc_devices {2VP4 2VP7 2VPX20 2VP20 2VP30 2VP40 2VP50 2VP70 2VPX70 2VP100 4VFX12 4VFX20 4VFX40 4VFX60 4VFX100 4VFX140 5VFX30T 5VFX70T 5VFX100T 5VFX115T 5VFX130T 5VFX200T }

    set single_ppc_devices {2VP4 2VP7 2VPX20 4VFX12 4VFX20 5VFX30T 5VFX70T}
    set dual_V2P_devices {2VP20 2VP30 2VP40 2VP50 2VP70 2VPX70 2VP100}

    set retval 0
    set tdo1_ppc405_handle ""
    set mhs_handle [xget_handle $mhsinst "parent"]

    set target_device [string toupper [ xget_hw_parameter_value $mhsinst "c_device" ] ]

    if {[llength $target_device ] == 0} {
	error "Parameter C_DEVICE is unassigned. This occurs when the target part is only specified by family (e.g. '-p virtex2p') in a generator call rather than a complete part name descriptor (e.g. '-p xc2vp7ff672-6'). Please relaunch tool with complete part name descriptor" "" "mdt_error"
    }

    if {[lsearch $known_ppc_devices [string trimleft $target_device ?QR?]] < 0} {
	error "Device $target_device does not contain PowerPC primitives." "" "mdt_error"
	incr retval 
    }

    set tdi0_connector [xget_value $mhsinst "port" "jtgc405tdi0"]

    ## detect designs that are not using transparent bus jtagppc0 on jtagppc_cntlr
    if { [llength $tdi0_connector] == 0 } {
	error "Port jtgc405tdi0 on JTAGPPC_CNTLR is unconnected. The core JTAGPPC_CNTLR requires that its transparent bus JTAGPPC0 is used whenever the core instantiated" "" "mdt_error"
	incr retval
    }

    set tdi0_ppc_port [xget_connected_ports_handle $mhs_handle $tdi0_connector "SINK" ]
    #Detect single ended connectors
    if {[llength $tdi0_ppc_port] == 0} {
	error "The connection to port jtgc405tdi0 on JTAGPPC_CNTLR is single-ended. Please connect all the JTAG signals for port0 to a PowerPC instance" "" "mdt_error"
	incr retval
    }
    set tdi0_ppc405_handle [xget_handle $tdi0_ppc_port "PARENT"]

    set tdo1_connector [xget_value $mhsinst "port" "c405jtgtdo1"]
    ## don't trace driver if not connected
    if { [llength $tdo1_connector] > 0 } {
	set tdo1_ppc_port [xget_connected_ports_handle $mhs_handle $tdo1_connector "SOURCE" ]
	#Detect single ended connectors
	if {[llength $tdo1_ppc_port] == 0} {
	    error "The connection to port jtgc405tdo1 on JTAGPPC_CNTLR is single-ended. Please remove all the JTAG connectors on port1, or make them connect to a second PowerPC instance" "" "mdt_error"
	    incr retval
	}
	set tdo1_ppc405_handle [xget_handle $tdo1_ppc_port "PARENT"]
    }
    set num_ppc [xget_hw_parameter_value $mhsinst "C_NUM_PPC_USED"]

    ## detect designs targeting 2 ppc devices where only one ppc is connected to jtagppc_cntlr
    if { [llength $tdo1_ppc405_handle] == 0 && $num_ppc >= 2} {
      puts "*********************************************************************** "
      puts "**                          PPC JTAG CHAIN ERROR!"
      puts "*********************************************************************** "
	puts "For devices that contain 2 PowerPCs, the jtagppc_cntlr chain must "
	puts "pass through both PowerPCs."
      puts "Your design instantiates both PowerPCs. But only one PowerPC is "
      puts "properly connected to the jtagppc_cntlr."
      puts "(If you are not using the second PowerPC, you may remove it from"
      puts "your design. EDK will then automatically connect the jtagppc chain"
      puts "through the second PPC in the device.)"
      puts "An example of a properly connected jtagppc chain follows: "
      puts "    BEGIN ppc405_virtex4"
      puts "     PARAMETER INSTANCE = ppc405_0"
      puts "     PARAMETER HW_VER = 2.00.x"
      puts "     BUS_INTERFACE JTAGPPC = jtagppc_0_0"
      puts "    END"
      puts "    BEGIN ppc405_virtex4"
      puts "     PARAMETER INSTANCE = ppc405_1"
      puts "     PARAMETER HW_VER = 2.00.x"
      puts "     BUS_INTERFACE JTAGPPC = jtagppc_0_1"
      puts "    END"
      puts "    BEGIN jtagppc_cntlr"
      puts "     PARAMETER INSTANCE = jtagppc_cntlr_0"
      puts "     PARAMETER HW_VER = 2.01.x"
      puts "     BUS_INTERFACE JTAGPPC0 = jtagppc_0_0"
      puts "     BUS_INTERFACE JTAGPPC1 = jtagppc_0_1"
      puts "    END"
        puts "*********************************************************************** "
        puts " "
        error "Incorrect connectivity of JTAGPPC_CNTLR in multi PPC device. Please refer to explanation above." "" "mdt_error"
	incr retval
    }

    return $retval

}

