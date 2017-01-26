# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load the dependent source code
loadRuckusTcl "$::DIR_PATH/../CobTiming"
loadRuckusTcl "$::DIR_PATH/../PpiCommon"
loadRuckusTcl "$::DIR_PATH/../PpiPgp"
loadRuckusTcl "$::DIR_PATH/../RceG3"
loadRuckusTcl "$::DIR_PATH/../ZynqEthernet"
loadRuckusTcl "$::DIR_PATH/../ZynqPcieMaster"

# Load local Source Code and constraints
loadSource      -dir "$::DIR_PATH/hdl/"
loadIpCore      -dir "$::DIR_PATH/coregen/GmiiToRgmiiCore/"
loadConstraints -dir "$::DIR_PATH/hdl/"