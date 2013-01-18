
# The package naming convention is <core_name>_xmdf
package provide endpoint_blk_plus_v1_15_xmdf 1.0

# This includes some utilities that support common XMDF operations
package require utilities_xmdf

# Define a namespace for this package. The name of the name space
# is <core_name>_xmdf
namespace eval ::endpoint_blk_plus_v1_15_xmdf {
# Use this to define any statics
}

# Function called by client to rebuild the params and port arrays
# Optional when the use context does not require the param or ports
# arrays to be available.
proc ::endpoint_blk_plus_v1_15_xmdf::xmdfInit { instance } {
# Variable containg name of library into which module is compiled
# Recommendation: <module_name>
# Required
utilities_xmdf::xmdfSetData $instance Module Attributes Name endpoint_blk_plus_v1_15
}
# ::endpoint_blk_plus_v1_15_xmdf::xmdfInit

# Function called by client to fill in all the xmdf* data variables
# based on the current settings of the parameters
proc ::endpoint_blk_plus_v1_15_xmdf::xmdfApplyParams { instance } {

set fcount 0
# Array containing libraries that are assumed to exist
# Examples include unisim and xilinxcorelib
# Optional
# In this example, we assume that the unisim library will
# be magically
# available to the simulation and synthesis tool
utilities_xmdf::xmdfSetData $instance FileSet $fcount type logical_library
utilities_xmdf::xmdfSetData $instance FileSet $fcount logical_library unisim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/doc/pcie_blk_plus_ds551.pdf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/doc/pcie_blk_plus_gsg343.pdf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/doc/pcie_blk_plus_ug341.pdf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/pcie_blk_plus_v1_15_readme.txt
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount



# PIO VHDL Example design files
utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/example_design/EP_MEM.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/example_design/pci_exp_64b_app.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/example_design/PIO_64_RX_ENGINE.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/example_design/PIO_64_TX_ENGINE.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/example_design/PIO_64.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/example_design/PIO_EP_MEM_ACCESS.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/example_design/PIO_EP.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/example_design/PIO_TO_CTRL.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/example_design/PIO.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/example_design/xilinx_pci_exp_ep.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount


utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/gtx_tx_sync_rate_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/gtx_wrapper_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pcie_gtx_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pcie_bram_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pcie_brams_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pcie_bram_top_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pcie_pipe_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pcie_pipe_misc_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pcie_pipe_lane_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pcie_clocking_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pcie_reset_delay_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pci_exp_usrapp_pl.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pci_exp_expect_tasks.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pci_exp_usrapp_com.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pcie_2_0_rport_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/xilinx_pcie_2_0_rport_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilogsim
incr fcount


# VHDL simulation files

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pci_exp_usrapp_tx.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdlsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pci_exp_usrapp_rx.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdlsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/pci_exp_usrapp_cfg.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdlsim
incr fcount


# VHDL simulation files
utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/dsport/test_interface.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdlsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/tests/tests.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdlsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/functional/rport_rtl.f
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/functional/rport_rtl_x01.f
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/functional/board_rtl.f
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/functional/board_rtl_x01.f
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/functional/xilinx_lib_mti.f
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/functional/xilinx_lib_vcs.f
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/functional/xilinx_lib_vnc.f
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/functional/simulate_mti.do
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/functional/simulate_ncsim.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/functional/simulate_vcs.do
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/functional/wave.do
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/functional/wave.sv
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/board.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdlsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/sys_clk_gen_ds.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdlsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/sys_clk_gen.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdlsim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/source_rtl.f
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/simulation/xilinx_pci_exp_cor_ep.f
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/example_design/xilinx_pci_exp_blk_plus_1_lane_ep_xc5vfx70t-ff1136-2.ucf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type ucf
utilities_xmdf::xmdfSetData $instance FileSet $fcount associated_module xilinx_pci_exp_ep.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount associated_module xilinx_pci_exp_ep.vhd
incr fcount

# Implementation scripts and project files
utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/implement/implement.bat
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/implement/implement.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/implement/xilinx_pci_exp_1_lane_ep_inc.xst
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/implement/xst.scr
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount



# Verilog Source files
utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/bram_common.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/cmm_decoder.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/cmm_errman_cnt_en.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/cmm_errman_cnt_nfl_en.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/cmm_errman_cor.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/cmm_errman_cpl.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/cmm_errman_ftl.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/cmm_errman_nfl.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/cmm_errman_ram4x26.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/cmm_errman_ram8x26.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/cmm_intr.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/endpoint_blk_plus_v1_15.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/extend_clk.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_cf.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_cf_arb.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_cf_err.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_cf_mgmt.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_cf_pwr.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_if.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_ll.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_ll_arb.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_ll_credit.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_ll_oqbqfifo.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_ll_tx.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_ll_tx_arb.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_plus_ll_rx.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_blk_plus_ll_tx.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_clocking.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_ep.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_gt_wrapper.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_gt_wrapper_top.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_gtx_wrapper.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_mim_wrapper.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_reset_logic.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_soft_int.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/pcie_top.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/prod_fixes.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/sync_fifo.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/tlm_rx_data_snk.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/tlm_rx_data_snk_bar.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/tlm_rx_data_snk_mal.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/tlm_rx_data_snk_pwr_mgmt.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/tx_sync_gtp.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/tx_sync_gtx.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15/source/use_newinterrupt.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount


utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15.vho
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl_template
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15.xco
utilities_xmdf::xmdfSetData $instance FileSet $fcount type coregen_ip
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path endpoint_blk_plus_v1_15_xmdf.tcl
utilities_xmdf::xmdfSetData $instance FileSet $fcount type AnyView
incr fcount


}

# ::gen_comp_name_xmdf::xmdfApplyParams
