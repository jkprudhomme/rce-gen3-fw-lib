
proc update_lvds_dwidth { param_handle } {

    set retval  4

    set mhsinst [xget_hw_parent_handle $param_handle]
    set display_interface [xget_hw_parameter_value $mhsinst "C_DISPLAY_INTERFACE"]

    ## PARAMETER C_DISPLAY_INTERFACE = 0, DT = INTEGER, RANGE = (0,1,2,3,4,5), VALUES = (0=parallel only, 1=ITU656, 2=LVDS 4bit, 3=camera link 4bit, 4=LVDS 3bit, 5=DVI), DESC = "Display interface"

    if {($display_interface == 4)} {
        set retval  3
    }

	return $retval

}

proc iplevel_update_lvds_dwidth { param_handle } {

    set retval [update_lvds_dwidth $param_handle]

    return $retval
}
