onerror {resume}
quietly WaveActivateNextPane {} 0
view wave
add wave -noupdate -divider {SYS signals}
add wave -noupdate -format Literal /board/DSPORT_INST/sys_clk_p
add wave -noupdate -format Literal /board/DSPORT_INST/sys_clk_n
add wave -noupdate -format Logic /board/DSPORT_INST/sys_reset_n
add wave -noupdate -format Literal /board/cor_sys_clk_p
add wave -noupdate -format Literal /board/cor_sys_clk_n
add wave -noupdate -format Literal /board/SYS_CLK_GEN_DS_INST/CLK_FREQ
add wave -noupdate -format Literal /board/SYS_CLK_GEN_COR_INST/CLK_FREQ
add wave -noupdate -divider {DSPORT TRN signals}
add wave -noupdate -format Logic /board/DSPORT_INST/trn_clk
add wave -noupdate -format Logic /board/DSPORT_INST/trn_reset_n
add wave -noupdate -format Logic /board/DSPORT_INST/trn_lnk_up_n
add wave -noupdate -format Literal /board/DSPORT_INST/trn_td
add wave -noupdate -format Logic /board/DSPORT_INST/trn_tsof_n
add wave -noupdate -format Logic /board/DSPORT_INST/trn_teof_n
add wave -noupdate -format Logic /board/DSPORT_INST/trn_tsrc_rdy_n
add wave -noupdate -format Logic /board/DSPORT_INST/trn_tdst_rdy_n
add wave -noupdate -format Literal /board/DSPORT_INST/trn_rd
add wave -noupdate -format Logic /board/DSPORT_INST/trn_rsof_n
add wave -noupdate -format Logic /board/DSPORT_INST/trn_reof_n
add wave -noupdate -format Logic /board/DSPORT_INST/trn_rsrc_rdy_n
add wave -noupdate -format Logic /board/DSPORT_INST/trn_rdst_rdy_n
add wave -noupdate -divider {PIO TRN signals}
add wave -noupdate -format Logic /board/EP_INST/trn_clk_c
add wave -noupdate -format Logic /board/EP_INST/trn_reset_n_c
add wave -noupdate -format Logic /board/EP_INST/trn_lnk_up_n_c
add wave -noupdate -format Literal /board/EP_INST/trn_td_c
add wave -noupdate -format Logic /board/EP_INST/trn_tsof_n_c
add wave -noupdate -format Logic /board/EP_INST/trn_teof_n_c
add wave -noupdate -format Logic /board/EP_INST/trn_tsrc_rdy_n_c
add wave -noupdate -format Logic /board/EP_INST/trn_tdst_rdy_n_c
add wave -noupdate -format Literal /board/EP_INST/trn_rd_c
add wave -noupdate -format Logic /board/EP_INST/trn_rsof_n_c
add wave -noupdate -format Logic /board/EP_INST/trn_reof_n_c
add wave -noupdate -format Logic /board/EP_INST/trn_rsrc_rdy_n_c
add wave -noupdate -format Logic /board/EP_INST/trn_rdst_rdy_n_c
add wave -noupdate -format Logic /board/EP_INST/trn_rbar_hit_n_c

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3291822 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 138
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {1799575 ps} {5382954 ps}
run -all
