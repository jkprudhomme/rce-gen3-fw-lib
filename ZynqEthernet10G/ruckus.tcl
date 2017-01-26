# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code
loadSource -dir "$::DIR_PATH/hdl/"
loadIpCore -dir "$::DIR_PATH/coregen/zynq_10g_xaui/"