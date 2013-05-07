
set device xc7z045-ffg900-2
set projName pcie_7x_v1_9
set design pcie_7x_v1_9
set projDir  [file dirname [info script]]

set projDir [file dirname [info script]]
create_project $projName $projDir/results/$projName -part $device -force
set_property design_mode RTL [current_fileset -srcset]


set top_module xilinx_pcie_2_1_rport_7x
set_property top xilinx_pcie_2_1_rport_7x [get_property srcset [current_run]]

add_files -norecurse {../../source/pcie_7x_v1_9_gt_rx_valid_filter_7x.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_gt_top.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_pcie_bram_top_7x.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_pcie_brams_7x.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_pcie_bram_7x.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_pcie_7x.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_pcie_pipe_pipeline.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_pcie_pipe_lane.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_pcie_pipe_misc.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_axi_basic_tx_thrtl_ctl.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_axi_basic_rx.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_axi_basic_rx_null_gen.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_axi_basic_rx_pipeline.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_axi_basic_tx_pipeline.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_axi_basic_tx.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_axi_basic_top.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_pcie_top.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9.vhd}
add_files -norecurse {../../source/pcie_7x_v1_9_gt_wrapper.v}
add_files -norecurse {../../source/pcie_7x_v1_9_gtp_pipe_reset.v}
add_files -norecurse {../../source/pcie_7x_v1_9_gtp_pipe_rate.v}
add_files -norecurse {../../source/pcie_7x_v1_9_qpll_wrapper.v}
add_files -norecurse {../../source/pcie_7x_v1_9_qpll_drp.v}
add_files -norecurse {../../source/pcie_7x_v1_9_qpll_reset.v}
add_files -norecurse {../../source/pcie_7x_v1_9_rxeq_scan.v}
add_files -norecurse {../../source/pcie_7x_v1_9_pipe_eq.v}
add_files -norecurse {../../source/pcie_7x_v1_9_pipe_clock.v}
add_files -norecurse {../../source/pcie_7x_v1_9_pipe_drp.v}
add_files -norecurse {../../source/pcie_7x_v1_9_pipe_rate.v}
add_files -norecurse {../../source/pcie_7x_v1_9_pipe_reset.v}
add_files -norecurse {../../source/pcie_7x_v1_9_pipe_user.v}
add_files -norecurse {../../source/pcie_7x_v1_9_pipe_sync.v}
add_files -norecurse {../../source/pcie_7x_v1_9_pipe_wrapper.v}
add_files -norecurse {../../example_design/xilinx_pcie_2_1_rport_7x.vhd}
add_files -norecurse {../../example_design/cgator_wrapper.vhd}
add_files -norecurse {../../example_design/cgator.vhd}
add_files -norecurse {../../example_design/cgator_controller.vhd}
add_files -norecurse {../../example_design/cgator_cpl_decoder.vhd}
add_files -norecurse {../../example_design/cgator_pkt_generator.vhd}
add_files -norecurse {../../example_design/cgator_tx_mux.vhd}
add_files -norecurse {../../example_design/pio_master.vhd}
add_files -norecurse {../../example_design/pio_master_controller.vhd}
add_files -norecurse {../../example_design/pio_master_checker.vhd}
add_files -norecurse {../../example_design/pio_master_pkt_generator.vhd}
read_xdc ../../example_design/xilinx_pcie_2_1_rport_7x_01_lane_gen1_xc7z045-ffg900-2-PCIE_X0Y0.xdc
synth_design -flatten_hierarchy none
opt_design
place_design
route_design
set_param sta.dlyMediator true
write_sdf -rename_top_module xilinx_pcie_2_1_ep_7x -file routed.sdf
write_vhdl -nolib -mode sim -file routed.vhd
report_timing -nworst 30 -path_type full -file routed.twr
report_drc
