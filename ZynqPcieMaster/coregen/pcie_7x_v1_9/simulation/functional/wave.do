onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {Root Port} -expand -group {System Interface} /board/RP/sys_clk
add wave -noupdate -expand -group {Root Port} -expand -group {System Interface} /board/RP/sys_rst_n
add wave -noupdate -expand -group {Root Port} -expand -group {System Interface} /board/RP/rp_reset_n
add wave -noupdate -expand -group {Root Port} -expand -group {System Interface} /board/RP/start_config
add wave -noupdate -expand -group {Root Port} -expand -group {System Interface} /board/RP/failed_config
add wave -noupdate -expand -group {Root Port} -expand -group {System Interface} /board/RP/finished_config
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Common} /board/RP/user_clk
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Common} /board/RP/user_reset
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Common} /board/RP/user_lnk_up
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Common} /board/RP/fc_sel
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Common} /board/RP/fc_cpld
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Common} /board/RP/fc_cplh
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Common} /board/RP/fc_npd
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Common} /board/RP/fc_nph
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Common} /board/RP/fc_pd
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Common} /board/RP/fc_ph
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Rx} /board/RP/m_axis_rx_tdata
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Rx} /board/RP/m_axis_rx_tvalid
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Rx} /board/RP/m_axis_rx_tlast
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Rx} /board/RP/m_axis_rx_tuser
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Tx} /board/RP/s_axis_tx_tdata
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Tx} /board/RP/s_axis_tx_tready
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Tx} /board/RP/s_axis_tx_tvalid
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Tx} /board/RP/s_axis_tx_tlast
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Tx} /board/RP/s_axis_tx_tuser
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Tx} /board/RP/tx_buf_av
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Tx} /board/RP/tx_err_drop
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Tx} /board/RP/tx_cfg_req
add wave -noupdate -expand -group {Root Port} -expand -group {AXI Tx} /board/RP/tx_cfg_gnt
add wave -noupdate -group {End Point} -group {System Interface} /board/EP/sys_rst_n
add wave -noupdate -group {End Point} -group {System Interface} /board/EP/sys_clk_p
add wave -noupdate -group {End Point} -group {AXI Common} /board/EP/user_clk
add wave -noupdate -group {End Point} -group {AXI Common} /board/EP/user_reset
add wave -noupdate -group {End Point} -group {AXI Common} /board/EP/user_lnk_up
add wave -noupdate -group {End Point} -group {AXI Common} /board/EP/fc_sel
add wave -noupdate -group {End Point} -group {AXI Common} /board/EP/fc_cpld
add wave -noupdate -group {End Point} -group {AXI Common} /board/EP/fc_cplh
add wave -noupdate -group {End Point} -group {AXI Common} /board/EP/fc_npd
add wave -noupdate -group {End Point} -group {AXI Common} /board/EP/fc_nph
add wave -noupdate -group {End Point} -group {AXI Common} /board/EP/fc_pd
add wave -noupdate -group {End Point} -group {AXI Common} /board/EP/fc_ph
add wave -noupdate -group {End Point} -group {AXI Rx} /board/EP/m_axis_rx_tdata
add wave -noupdate -group {End Point} -group {AXI Rx} /board/EP/m_axis_rx_tready
add wave -noupdate -group {End Point} -group {AXI Rx} /board/EP/m_axis_rx_tvalid
add wave -noupdate -group {End Point} -group {AXI Rx} /board/EP/m_axis_rx_tlast
add wave -noupdate -group {End Point} -group {AXI Rx} /board/EP/m_axis_rx_tuser
add wave -noupdate -group {End Point} -group {AXI Rx} /board/EP/rx_np_ok
add wave -noupdate -group {End Point} -group {AXI Tx} /board/EP/s_axis_tx_tdata
add wave -noupdate -group {End Point} -group {AXI Tx} /board/EP/s_axis_tx_tready
add wave -noupdate -group {End Point} -group {AXI Tx} /board/EP/s_axis_tx_tvalid
add wave -noupdate -group {End Point} -group {AXI Tx} /board/EP/s_axis_tx_tlast
add wave -noupdate -group {End Point} -group {AXI Tx} /board/EP/s_axis_tx_tuser
add wave -noupdate -group {End Point} -group {AXI Tx} /board/EP/tx_buf_av
add wave -noupdate -group {End Point} -group {AXI Tx} /board/EP/tx_err_drop
add wave -noupdate -group {End Point} -group {AXI Tx} /board/EP/tx_cfg_req
add wave -noupdate -group {End Point} -group {AXI Tx} /board/EP/tx_cfg_gnt

TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 215
update
