# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load Source Code
loadSource -dir "$::DIR_PATH/hdl/"
# loadSource -sim_only -dir "$::DIR_PATH/tb/"