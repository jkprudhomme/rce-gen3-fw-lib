# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code
loadSource -dir "$::DIR_PATH/hdl/"
loadIpCore -dir "$::DIR_PATH/coregen/processing_system7_0/"
# loadSource -sim_only -path "$::DIR_PATH/tb/RceG3CpuSim.vhd"
# loadSource -sim_only -path "$::DIR_PATH/tb/RceG3SimConfig.vhd"
loadSource -sim_only -path "$::DIR_PATH/tb/rceg3_tb.vhd"