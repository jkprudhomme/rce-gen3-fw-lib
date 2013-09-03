--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.58f
--  \   \         Application: netgen
--  /   /         Filename: zynq_xaui.vhd
-- /___/   /\     Timestamp: Tue Sep  3 12:33:16 2013
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -w -sim -ofmt vhdl /afs/slac.stanford.edu/u/ey/rherbst/projects/rce/dpm_stable/modules/ZynqEthernet10G/coregen/tmp/_cg/zynq_xaui.ngc /afs/slac.stanford.edu/u/ey/rherbst/projects/rce/dpm_stable/modules/ZynqEthernet10G/coregen/tmp/_cg/zynq_xaui.vhd 
-- Device	: 7z030fbg484-2
-- Input file	: /afs/slac.stanford.edu/u/ey/rherbst/projects/rce/dpm_stable/modules/ZynqEthernet10G/coregen/tmp/_cg/zynq_xaui.ngc
-- Output file	: /afs/slac.stanford.edu/u/ey/rherbst/projects/rce/dpm_stable/modules/ZynqEthernet10G/coregen/tmp/_cg/zynq_xaui.vhd
-- # of Entities	: 1
-- Design Name	: zynq_xaui
-- Xilinx	: /afs/slac.stanford.edu/g/reseng/vol15/Xilinx/14.5/ISE_DS/ISE/
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Command Line Tools User Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------


-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity zynq_xaui is
  port (
    reset : in STD_LOGIC := 'X'; 
    usrclk : in STD_LOGIC := 'X'; 
    mgt_enchansync : out STD_LOGIC; 
    mgt_loopback : out STD_LOGIC; 
    mgt_powerdown : out STD_LOGIC; 
    align_status : out STD_LOGIC; 
    xgmii_txd : in STD_LOGIC_VECTOR ( 63 downto 0 ); 
    xgmii_txc : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    mgt_rxdata : in STD_LOGIC_VECTOR ( 63 downto 0 ); 
    mgt_rxcharisk : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    mgt_codevalid : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    mgt_codecomma : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    mgt_syncok : in STD_LOGIC_VECTOR ( 3 downto 0 ); 
    mgt_rxlock : in STD_LOGIC_VECTOR ( 3 downto 0 ); 
    mgt_tx_reset : in STD_LOGIC_VECTOR ( 3 downto 0 ); 
    mgt_rx_reset : in STD_LOGIC_VECTOR ( 3 downto 0 ); 
    signal_detect : in STD_LOGIC_VECTOR ( 3 downto 0 ); 
    configuration_vector : in STD_LOGIC_VECTOR ( 6 downto 0 ); 
    xgmii_rxd : out STD_LOGIC_VECTOR ( 63 downto 0 ); 
    xgmii_rxc : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    mgt_txdata : out STD_LOGIC_VECTOR ( 63 downto 0 ); 
    mgt_txcharisk : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    mgt_enable_align : out STD_LOGIC_VECTOR ( 3 downto 0 ); 
    sync_status : out STD_LOGIC_VECTOR ( 3 downto 0 ); 
    status_vector : out STD_LOGIC_VECTOR ( 7 downto 0 ) 
  );
end zynq_xaui;

architecture STRUCTURE of zynq_xaui is
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_enable_align_327 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_enable_align_328 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_enable_align_329 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_enable_align_330 : STD_LOGIC; 
  signal NlwRenamedSig_OI_U0_status_vector_int_7_Q : STD_LOGIC; 
  signal NlwRenamedSig_OI_U0_status_vector_int_6_Q : STD_LOGIC; 
  signal NlwRenamedSig_OI_U0_status_vector_int_1_Q : STD_LOGIC; 
  signal NlwRenamedSig_OI_U0_status_vector_int_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync_339 : STD_LOGIC; 
  signal NlwRenamedSignal_U0_mgt_loopback_keep : STD_LOGIC; 
  signal NlwRenamedSignal_U0_mgt_powerdown_keep : STD_LOGIC; 
  signal N0 : STD_LOGIC; 
  signal U0_xaui_inst_align_status_int_inv : STD_LOGIC; 
  signal U0_xaui_inst_p_clear_aligned_edge_last_value_344 : STD_LOGIC; 
  signal U0_xaui_inst_clear_aligned_edge_345 : STD_LOGIC; 
  signal U0_xaui_inst_p_clear_local_fault_edge_last_value_346 : STD_LOGIC; 
  signal U0_xaui_inst_clear_local_fault_edge_347 : STD_LOGIC; 
  signal U0_xaui_inst_clear_aligned_348 : STD_LOGIC; 
  signal U0_xaui_inst_clear_local_fault_349 : STD_LOGIC; 
  signal U0_xaui_inst_usrclk_reset_350 : STD_LOGIC; 
  signal U0_xaui_inst_usrclk_reset_pipe_351 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txc_out_364 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_5_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_6_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_7_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txc_out_373 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_5_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_6_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_7_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txc_out_382 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_5_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_6_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_7_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txc_out_391 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_5_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_6_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_7_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txc_out_400 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_5_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_6_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_7_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txc_out_409 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_5_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_6_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_7_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txc_out_418 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_5_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_6_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_7_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txc_out_427 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_5_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_6_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_7_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_447 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT3211 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT1511 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT161 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT511 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT123 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT261_552 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT302 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT331 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT311 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT2911 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT631 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_5_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_6_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_7_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_8_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_9_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_10_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_11_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_12_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_13_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_14_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_15_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_16_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_17_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_18_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_19_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_20_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_21_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_22_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_23_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_24_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_25_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_26_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_27_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_28_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_29_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_30_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_31_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_32_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_33_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_34_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_35_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_36_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_37_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_38_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_39_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_40_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_41_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_42_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_43_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_44_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_45_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_46_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_47_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_48_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_49_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_50_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_51_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_52_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_53_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_54_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_55_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_56_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_57_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_58_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_59_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_60_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_61_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_62_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_63_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_7_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_8_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_9_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_10_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_11_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_12_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_13_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_14_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_15_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_16_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_17_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_18_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_19_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_20_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_21_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_22_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_23_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_24_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_25_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_26_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_27_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_28_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_29_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_30_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_31_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_align_n0051_inv : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_align_n0020_inv : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_align_prbs_6_prbs_7_XOR_49_o : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_align_extra_a_659 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_k_r_prbs_i_prbs_6_prbs_7_XOR_66_o : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_k_r_prbs_i_prbs_5_prbs_6_XOR_65_o : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_state_machine_is_idle_1_is_q_1_AND_15_o_0 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_0_1_680 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_state_machine_next_ifg_is_a_686 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_694 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_696 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_698 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_700 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_702 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_704 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_706 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_708 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_sync_status_int : STD_LOGIC; 
  signal U0_xaui_inst_receiver_sync_status_718 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_Mram_got_a_7_GND_18_o_Mux_10_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_Mram_got_a_3_GND_18_o_Mux_9_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync_i_norst_inv_0 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1_2_PWR_19_o_wide_mux_42_OUT_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1_2_PWR_19_o_wide_mux_42_OUT_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1_2_PWR_19_o_wide_mux_42_OUT_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_4_got_a_7_AND_50_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_0_got_a_3_AND_47_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_deskew_error_sliced_748 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_116_o2 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_110_o1 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_114_o1 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_112_o1 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_108_o_753 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_106_o_754 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_104_o_755 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_102_o_756 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxc_pipe_3_PWR_20_o_MUX_341_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxc_pipe_2_PWR_20_o_MUX_323_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxc_pipe_1_PWR_20_o_MUX_305_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxc_pipe_0_PWR_20_o_MUX_287_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_24_GND_19_o_MUX_339_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_25_PWR_20_o_MUX_338_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_26_PWR_20_o_MUX_337_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_27_PWR_20_o_MUX_336_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_28_PWR_20_o_MUX_335_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_29_PWR_20_o_MUX_334_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_30_PWR_20_o_MUX_333_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_31_PWR_20_o_MUX_332_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_16_GND_19_o_MUX_321_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_17_PWR_20_o_MUX_320_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_18_PWR_20_o_MUX_319_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_19_PWR_20_o_MUX_318_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_20_PWR_20_o_MUX_317_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_21_PWR_20_o_MUX_316_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_22_PWR_20_o_MUX_315_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_23_PWR_20_o_MUX_314_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_8_GND_19_o_MUX_303_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_9_PWR_20_o_MUX_302_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_10_PWR_20_o_MUX_301_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_11_PWR_20_o_MUX_300_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_12_PWR_20_o_MUX_299_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_13_PWR_20_o_MUX_298_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_14_PWR_20_o_MUX_297_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_15_PWR_20_o_MUX_296_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_0_GND_19_o_MUX_285_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_1_PWR_20_o_MUX_284_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_2_PWR_20_o_MUX_283_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_3_PWR_20_o_MUX_282_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_4_PWR_20_o_MUX_281_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_5_PWR_20_o_MUX_280_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_6_PWR_20_o_MUX_279_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe_7_PWR_20_o_MUX_278_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxc_half_pipe_0_PWR_20_o_MUX_215_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_0_GND_19_o_MUX_213_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_1_PWR_20_o_MUX_212_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_2_PWR_20_o_MUX_211_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_3_PWR_20_o_MUX_210_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_4_PWR_20_o_MUX_209_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_5_PWR_20_o_MUX_208_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_6_PWR_20_o_MUX_207_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_7_PWR_20_o_MUX_206_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxc_half_pipe_1_PWR_20_o_MUX_233_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_8_GND_19_o_MUX_231_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_9_PWR_20_o_MUX_230_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_10_PWR_20_o_MUX_229_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_11_PWR_20_o_MUX_228_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_12_PWR_20_o_MUX_227_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_13_PWR_20_o_MUX_226_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_14_PWR_20_o_MUX_225_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_15_PWR_20_o_MUX_224_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxc_half_pipe_2_PWR_20_o_MUX_251_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_16_GND_19_o_MUX_249_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_17_PWR_20_o_MUX_248_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_18_PWR_20_o_MUX_247_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_19_PWR_20_o_MUX_246_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_20_PWR_20_o_MUX_245_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_21_PWR_20_o_MUX_244_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_22_PWR_20_o_MUX_243_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_23_PWR_20_o_MUX_242_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxc_half_pipe_3_PWR_20_o_MUX_269_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_24_GND_19_o_MUX_267_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_25_PWR_20_o_MUX_266_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_26_PWR_20_o_MUX_265_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_27_PWR_20_o_MUX_264_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_28_PWR_20_o_MUX_263_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_29_PWR_20_o_MUX_262_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_30_PWR_20_o_MUX_261_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe_31_PWR_20_o_MUX_260_o : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_7_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_6_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_5_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_7_AND_204_o_840 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_6_AND_202_o_841 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_5_AND_200_o_842 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_4_AND_198_o_843 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_3_AND_196_o_844 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_2_AND_194_o_845 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_1_AND_192_o_846 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_0_AND_190_o_847 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_code_error_delay_0_890 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_code_error_delay_1_891 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_code_error_delay_2_892 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_code_error_delay_3_893 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_change_0 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_enable_align_i : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_last_995 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_change_0 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_enable_align_i : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_last_1017 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_change_0 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_enable_align_i : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_last_1039 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_change_0 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_enable_align_i : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_3_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_last_1061 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_q_comb_1_1_1066 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_q_comb_1_2_1067 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_idle_comb_1_1_1068 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_idle_comb_1_2_1069 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_idle_comb_1_3_1070 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_idle_comb_1_4_1071 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_idle_comb_1_5_1072 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_idle_comb_1_6_1073 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_q_comb_0_1_1074 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_q_comb_0_2_1075 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_idle_comb_0_1_1076 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_idle_comb_0_2_1077 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_idle_comb_0_3_1078 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_idle_comb_0_4_1079 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_idle_comb_0_5_1080 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tx_is_idle_comb_0_6_1081 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_1_1_1082 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_1_2_1083 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_1_3_1084 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_1_4_1085 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_1_5_1086 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_1_6_1087 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_1_7_1088 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_0_1_1089 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_0_2_1090 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_0_3_1091 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_0_4_1092 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_0_5_1093 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_0_6_1094 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_0_7_1095 : STD_LOGIC; 
  signal N4 : STD_LOGIC; 
  signal N6 : STD_LOGIC; 
  signal N10 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_6_o1_1099 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_6_o2_1100 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102 : STD_LOGIC; 
  signal N16 : STD_LOGIC; 
  signal N18 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_0_Q : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_0_2 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp4 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp41_1108 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp2 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o1_1110 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o1_1111 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o1_1112 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o1_1113 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o1_1114 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o1_1115 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o1_1116 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o1_1117 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_7_1_1118 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_7_2_1119 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_6_1_1120 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_6_2_1121 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_5_1_1122 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_5_2_1123 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_4_1_1124 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_4_2_1125 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_3_1_1126 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_3_2_1127 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_2_1_1128 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_2_2_1129 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_1_1_1130 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_1_2_1131 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_0_1_1132 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_code_error_0_2_1133 : STD_LOGIC; 
  signal N40 : STD_LOGIC; 
  signal N42 : STD_LOGIC; 
  signal N44 : STD_LOGIC; 
  signal N46 : STD_LOGIC; 
  signal N48 : STD_LOGIC; 
  signal N50 : STD_LOGIC; 
  signal N52 : STD_LOGIC; 
  signal N54 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_2_2_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_2_2_1_1143 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_2_2_2_1144 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_1_1_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_1_1_1_1146 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_1_1_2_1147 : STD_LOGIC; 
  signal N56 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_6_6_1 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_6_6_2_1150 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_5_5_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_7_7_Q : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_7_7_1_1153 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_error_lane_4_4_Q : STD_LOGIC; 
  signal N58 : STD_LOGIC; 
  signal N60 : STD_LOGIC; 
  signal N62 : STD_LOGIC; 
  signal N64 : STD_LOGIC; 
  signal N66 : STD_LOGIC; 
  signal N68 : STD_LOGIC; 
  signal N70 : STD_LOGIC; 
  signal N72 : STD_LOGIC; 
  signal N74 : STD_LOGIC; 
  signal N76 : STD_LOGIC; 
  signal N78 : STD_LOGIC; 
  signal N80 : STD_LOGIC; 
  signal N82 : STD_LOGIC; 
  signal N84 : STD_LOGIC; 
  signal N86 : STD_LOGIC; 
  signal N88 : STD_LOGIC; 
  signal N90 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24 : STD_LOGIC; 
  signal N92 : STD_LOGIC; 
  signal N94 : STD_LOGIC; 
  signal N96 : STD_LOGIC; 
  signal N98 : STD_LOGIC; 
  signal N100 : STD_LOGIC; 
  signal N102 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24 : STD_LOGIC; 
  signal N104 : STD_LOGIC; 
  signal N106 : STD_LOGIC; 
  signal N108 : STD_LOGIC; 
  signal N110 : STD_LOGIC; 
  signal N112 : STD_LOGIC; 
  signal N114 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24 : STD_LOGIC; 
  signal N116 : STD_LOGIC; 
  signal N118 : STD_LOGIC; 
  signal N120 : STD_LOGIC; 
  signal N122 : STD_LOGIC; 
  signal N124 : STD_LOGIC; 
  signal N126 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24 : STD_LOGIC; 
  signal N128 : STD_LOGIC; 
  signal U0_xaui_inst_aligned_sticky_glue_set_1199 : STD_LOGIC; 
  signal U0_xaui_inst_rx_local_fault_glue_set_1200 : STD_LOGIC; 
  signal U0_xaui_inst_tx_local_fault_glue_set_1201 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_txc_out_7_glue_set_1202 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_txc_out_6_glue_set_1203 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_txc_out_5_glue_set_1204 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_txc_out_4_glue_set_1205 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_txc_out_3_glue_set_1206 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_txc_out_2_glue_set_1207 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_txc_out_1_glue_set_1208 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_recoder_txc_out_0_glue_set_1209 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_align_extra_a_glue_set_1210 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_state_machine_next_ifg_is_a_glue_rst_1211 : STD_LOGIC; 
  signal U0_xaui_inst_clear_aligned_edge_rstpot_1212 : STD_LOGIC; 
  signal U0_xaui_inst_clear_local_fault_edge_rstpot_1213 : STD_LOGIC; 
  signal U0_xaui_inst_usrclk_reset_rstpot_1214 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync_rstpot_1215 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_rstpot_1216 : STD_LOGIC; 
  signal N130 : STD_LOGIC; 
  signal N132 : STD_LOGIC; 
  signal N134 : STD_LOGIC; 
  signal N136 : STD_LOGIC; 
  signal N138 : STD_LOGIC; 
  signal N140 : STD_LOGIC; 
  signal N142 : STD_LOGIC; 
  signal N144 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_7_rstpot_1225 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_6_rstpot_1226 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_5_rstpot_1227 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_4_rstpot_1228 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_3_rstpot_1229 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_2_rstpot_1230 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_1_rstpot_1231 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_0_rstpot_1232 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_7_rstpot_1233 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_6_rstpot_1234 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_5_rstpot_1235 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_4_rstpot_1236 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_3_rstpot_1237 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_2_rstpot_1238 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_1_rstpot_1239 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_0_rstpot_1240 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_7_rstpot_1241 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_6_rstpot_1242 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_5_rstpot_1243 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_4_rstpot_1244 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_3_rstpot_1245 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_2_rstpot_1246 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_1_rstpot_1247 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_0_rstpot_1248 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_7_rstpot_1249 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_6_rstpot_1250 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_5_rstpot_1251 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_4_rstpot_1252 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_3_rstpot_1253 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_2_rstpot_1254 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_1_rstpot_1255 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_0_rstpot_1256 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_7_rstpot_1257 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_6_rstpot_1258 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_5_rstpot_1259 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_4_rstpot_1260 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_3_rstpot_1261 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_2_rstpot_1262 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_1_rstpot_1263 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_0_rstpot_1264 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_7_rstpot_1265 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_6_rstpot_1266 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_5_rstpot_1267 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_4_rstpot_1268 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_3_rstpot_1269 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_2_rstpot_1270 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_1_rstpot_1271 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_0_rstpot_1272 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_7_rstpot_1273 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_6_rstpot_1274 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_5_rstpot_1275 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_4_rstpot_1276 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_3_rstpot_1277 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_2_rstpot_1278 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_1_rstpot_1279 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_0_rstpot_1280 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_7_rstpot_1281 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_6_rstpot_1282 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_5_rstpot_1283 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_4_rstpot_1284 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_3_rstpot_1285 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_2_rstpot_1286 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_1_rstpot_1287 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_0_rstpot_1288 : STD_LOGIC; 
  signal N146 : STD_LOGIC; 
  signal N147 : STD_LOGIC; 
  signal N149 : STD_LOGIC; 
  signal N150 : STD_LOGIC; 
  signal N152 : STD_LOGIC; 
  signal N153 : STD_LOGIC; 
  signal N155 : STD_LOGIC; 
  signal N156 : STD_LOGIC; 
  signal N170 : STD_LOGIC; 
  signal N171 : STD_LOGIC; 
  signal N173 : STD_LOGIC; 
  signal N174 : STD_LOGIC; 
  signal N176 : STD_LOGIC; 
  signal N177 : STD_LOGIC; 
  signal N179 : STD_LOGIC; 
  signal N180 : STD_LOGIC; 
  signal N194 : STD_LOGIC; 
  signal N195 : STD_LOGIC; 
  signal N197 : STD_LOGIC; 
  signal N198 : STD_LOGIC; 
  signal N200 : STD_LOGIC; 
  signal N201 : STD_LOGIC; 
  signal N203 : STD_LOGIC; 
  signal N204 : STD_LOGIC; 
  signal N206 : STD_LOGIC; 
  signal N207 : STD_LOGIC; 
  signal N209 : STD_LOGIC; 
  signal N210 : STD_LOGIC; 
  signal N212 : STD_LOGIC; 
  signal N213 : STD_LOGIC; 
  signal N215 : STD_LOGIC; 
  signal N216 : STD_LOGIC; 
  signal N218 : STD_LOGIC; 
  signal N219 : STD_LOGIC; 
  signal N221 : STD_LOGIC; 
  signal N222 : STD_LOGIC; 
  signal N224 : STD_LOGIC; 
  signal N225 : STD_LOGIC; 
  signal N227 : STD_LOGIC; 
  signal N228 : STD_LOGIC; 
  signal N232 : STD_LOGIC; 
  signal N234 : STD_LOGIC; 
  signal N236 : STD_LOGIC; 
  signal N238 : STD_LOGIC; 
  signal N240 : STD_LOGIC; 
  signal N242 : STD_LOGIC; 
  signal N244 : STD_LOGIC; 
  signal N246 : STD_LOGIC; 
  signal N248 : STD_LOGIC; 
  signal N249 : STD_LOGIC; 
  signal N251 : STD_LOGIC; 
  signal N252 : STD_LOGIC; 
  signal N254 : STD_LOGIC; 
  signal N255 : STD_LOGIC; 
  signal N257 : STD_LOGIC; 
  signal N258 : STD_LOGIC; 
  signal N259 : STD_LOGIC; 
  signal N261 : STD_LOGIC; 
  signal N262 : STD_LOGIC; 
  signal N264 : STD_LOGIC; 
  signal N265 : STD_LOGIC; 
  signal N271 : STD_LOGIC; 
  signal N272 : STD_LOGIC; 
  signal N274 : STD_LOGIC; 
  signal N275 : STD_LOGIC; 
  signal N277 : STD_LOGIC; 
  signal N278 : STD_LOGIC; 
  signal N280 : STD_LOGIC; 
  signal N281 : STD_LOGIC; 
  signal N283 : STD_LOGIC; 
  signal N284 : STD_LOGIC; 
  signal N290 : STD_LOGIC; 
  signal N291 : STD_LOGIC; 
  signal N293 : STD_LOGIC; 
  signal N294 : STD_LOGIC; 
  signal N296 : STD_LOGIC; 
  signal N297 : STD_LOGIC; 
  signal N299 : STD_LOGIC; 
  signal N300 : STD_LOGIC; 
  signal N302 : STD_LOGIC; 
  signal N303 : STD_LOGIC; 
  signal N309 : STD_LOGIC; 
  signal N310 : STD_LOGIC; 
  signal N312 : STD_LOGIC; 
  signal N313 : STD_LOGIC; 
  signal N315 : STD_LOGIC; 
  signal N316 : STD_LOGIC; 
  signal N318 : STD_LOGIC; 
  signal N319 : STD_LOGIC; 
  signal N321 : STD_LOGIC; 
  signal N322 : STD_LOGIC; 
  signal N328 : STD_LOGIC; 
  signal N329 : STD_LOGIC; 
  signal N331 : STD_LOGIC; 
  signal N332 : STD_LOGIC; 
  signal N334 : STD_LOGIC; 
  signal N335 : STD_LOGIC; 
  signal N337 : STD_LOGIC; 
  signal N338 : STD_LOGIC; 
  signal N340 : STD_LOGIC; 
  signal N341 : STD_LOGIC; 
  signal N347 : STD_LOGIC; 
  signal N348 : STD_LOGIC; 
  signal N350 : STD_LOGIC; 
  signal N351 : STD_LOGIC; 
  signal N353 : STD_LOGIC; 
  signal N354 : STD_LOGIC; 
  signal N356 : STD_LOGIC; 
  signal N357 : STD_LOGIC; 
  signal N359 : STD_LOGIC; 
  signal N360 : STD_LOGIC; 
  signal N366 : STD_LOGIC; 
  signal N367 : STD_LOGIC; 
  signal N369 : STD_LOGIC; 
  signal N370 : STD_LOGIC; 
  signal N372 : STD_LOGIC; 
  signal N373 : STD_LOGIC; 
  signal N375 : STD_LOGIC; 
  signal N376 : STD_LOGIC; 
  signal N378 : STD_LOGIC; 
  signal N379 : STD_LOGIC; 
  signal N385 : STD_LOGIC; 
  signal N386 : STD_LOGIC; 
  signal N388 : STD_LOGIC; 
  signal N389 : STD_LOGIC; 
  signal N391 : STD_LOGIC; 
  signal N392 : STD_LOGIC; 
  signal N394 : STD_LOGIC; 
  signal N395 : STD_LOGIC; 
  signal N397 : STD_LOGIC; 
  signal N398 : STD_LOGIC; 
  signal N404 : STD_LOGIC; 
  signal N405 : STD_LOGIC; 
  signal N407 : STD_LOGIC; 
  signal N408 : STD_LOGIC; 
  signal N410 : STD_LOGIC; 
  signal N411 : STD_LOGIC; 
  signal N413 : STD_LOGIC; 
  signal N414 : STD_LOGIC; 
  signal N424 : STD_LOGIC; 
  signal N425 : STD_LOGIC; 
  signal N427 : STD_LOGIC; 
  signal N428 : STD_LOGIC; 
  signal N430 : STD_LOGIC; 
  signal N431 : STD_LOGIC; 
  signal N433 : STD_LOGIC; 
  signal N434 : STD_LOGIC; 
  signal N436 : STD_LOGIC; 
  signal N437 : STD_LOGIC; 
  signal N438 : STD_LOGIC; 
  signal N439 : STD_LOGIC; 
  signal N441 : STD_LOGIC; 
  signal N443 : STD_LOGIC; 
  signal N445 : STD_LOGIC; 
  signal N447 : STD_LOGIC; 
  signal N449 : STD_LOGIC; 
  signal N451 : STD_LOGIC; 
  signal N453 : STD_LOGIC; 
  signal N455 : STD_LOGIC; 
  signal N457 : STD_LOGIC; 
  signal N458 : STD_LOGIC; 
  signal N459 : STD_LOGIC; 
  signal N461 : STD_LOGIC; 
  signal N463 : STD_LOGIC; 
  signal N465 : STD_LOGIC; 
  signal N467 : STD_LOGIC; 
  signal N469 : STD_LOGIC; 
  signal N471 : STD_LOGIC; 
  signal N473 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_1_41 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_1_61 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_0_41 : STD_LOGIC; 
  signal U0_xaui_inst_transmitter_is_terminate_0_61 : STD_LOGIC; 
  signal N475 : STD_LOGIC; 
  signal N476 : STD_LOGIC; 
  signal N477 : STD_LOGIC; 
  signal N478 : STD_LOGIC; 
  signal N479 : STD_LOGIC; 
  signal N480 : STD_LOGIC; 
  signal N481 : STD_LOGIC; 
  signal N482 : STD_LOGIC; 
  signal N483 : STD_LOGIC; 
  signal N484 : STD_LOGIC; 
  signal U0_xaui_inst_receiver_recoder_rxd_out : STD_LOGIC_VECTOR ( 63 downto 0 ); 
  signal U0_xaui_inst_receiver_recoder_rxc_out : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal U0_xaui_inst_transmitter_recoder_txd_out : STD_LOGIC_VECTOR ( 63 downto 0 ); 
  signal U0_xaui_inst_transmitter_recoder_txc_out : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal NlwRenamedSignal_U0_xaui_inst_sync : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal U0_xaui_inst_signal_detect_int : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal U0_xaui_inst_transmitter_tx_is_q_comb : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal U0_xaui_inst_transmitter_tx_is_idle_comb : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal U0_xaui_inst_transmitter_tx_is_idle : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal U0_xaui_inst_transmitter_tx_is_q : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal U0_xaui_inst_transmitter_tx_code_r : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal U0_xaui_inst_transmitter_tx_code_q : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal U0_xaui_inst_transmitter_tx_code_k : STD_LOGIC_VECTOR ( 1 downto 1 ); 
  signal U0_xaui_inst_transmitter_tx_code_a : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal U0_xaui_inst_transmitter_k_r_prbs_i_prbs : STD_LOGIC_VECTOR ( 8 downto 1 ); 
  signal U0_xaui_inst_transmitter_a_due : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal U0_xaui_inst_transmitter_last_qmsg : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg : STD_LOGIC_VECTOR ( 31 downto 7 ); 
  signal U0_xaui_inst_transmitter_txc_pipe : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal U0_xaui_inst_transmitter_txd_pipe : STD_LOGIC_VECTOR ( 63 downto 0 ); 
  signal U0_xaui_inst_transmitter_align_count : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal U0_xaui_inst_transmitter_align_prbs : STD_LOGIC_VECTOR ( 7 downto 1 ); 
  signal U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp : STD_LOGIC_VECTOR ( 2 downto 0 ); 
  signal U0_xaui_inst_transmitter_state_machine_state_1 : STD_LOGIC_VECTOR ( 2 downto 0 ); 
  signal U0_xaui_inst_transmitter_state_machine_state_0 : STD_LOGIC_VECTOR ( 2 downto 0 ); 
  signal U0_xaui_inst_receiver_code_error : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal U0_xaui_inst_receiver_sync_ok_int : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_p_state_comb_state_temp : STD_LOGIC_VECTOR ( 2 downto 0 ); 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1 : STD_LOGIC_VECTOR ( 2 downto 0 ); 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_got_align : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal U0_xaui_inst_receiver_G_SYNC_deskew_state_deskew_error : STD_LOGIC_VECTOR ( 1 downto 1 ); 
  signal U0_xaui_inst_receiver_recoder_lane_terminate : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_mux_97_OUT : STD_LOGIC_VECTOR ( 2 downto 1 ); 
  signal U0_xaui_inst_receiver_recoder_rxd_half_pipe : STD_LOGIC_VECTOR ( 31 downto 0 ); 
  signal U0_xaui_inst_receiver_recoder_lane_term_pipe : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal U0_xaui_inst_receiver_recoder_rxc_half_pipe : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal U0_xaui_inst_receiver_recoder_code_error_pipe : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal U0_xaui_inst_receiver_recoder_rxc_pipe : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal U0_xaui_inst_receiver_recoder_rxd_pipe : STD_LOGIC_VECTOR ( 63 downto 0 ); 
begin
  NlwRenamedSignal_U0_mgt_powerdown_keep <= configuration_vector(1);
  NlwRenamedSignal_U0_mgt_loopback_keep <= configuration_vector(0);
  xgmii_rxd(63) <= U0_xaui_inst_receiver_recoder_rxd_out(63);
  xgmii_rxd(62) <= U0_xaui_inst_receiver_recoder_rxd_out(62);
  xgmii_rxd(61) <= U0_xaui_inst_receiver_recoder_rxd_out(61);
  xgmii_rxd(60) <= U0_xaui_inst_receiver_recoder_rxd_out(60);
  xgmii_rxd(59) <= U0_xaui_inst_receiver_recoder_rxd_out(59);
  xgmii_rxd(58) <= U0_xaui_inst_receiver_recoder_rxd_out(58);
  xgmii_rxd(57) <= U0_xaui_inst_receiver_recoder_rxd_out(57);
  xgmii_rxd(56) <= U0_xaui_inst_receiver_recoder_rxd_out(56);
  xgmii_rxd(55) <= U0_xaui_inst_receiver_recoder_rxd_out(55);
  xgmii_rxd(54) <= U0_xaui_inst_receiver_recoder_rxd_out(54);
  xgmii_rxd(53) <= U0_xaui_inst_receiver_recoder_rxd_out(53);
  xgmii_rxd(52) <= U0_xaui_inst_receiver_recoder_rxd_out(52);
  xgmii_rxd(51) <= U0_xaui_inst_receiver_recoder_rxd_out(51);
  xgmii_rxd(50) <= U0_xaui_inst_receiver_recoder_rxd_out(50);
  xgmii_rxd(49) <= U0_xaui_inst_receiver_recoder_rxd_out(49);
  xgmii_rxd(48) <= U0_xaui_inst_receiver_recoder_rxd_out(48);
  xgmii_rxd(47) <= U0_xaui_inst_receiver_recoder_rxd_out(47);
  xgmii_rxd(46) <= U0_xaui_inst_receiver_recoder_rxd_out(46);
  xgmii_rxd(45) <= U0_xaui_inst_receiver_recoder_rxd_out(45);
  xgmii_rxd(44) <= U0_xaui_inst_receiver_recoder_rxd_out(44);
  xgmii_rxd(43) <= U0_xaui_inst_receiver_recoder_rxd_out(43);
  xgmii_rxd(42) <= U0_xaui_inst_receiver_recoder_rxd_out(42);
  xgmii_rxd(41) <= U0_xaui_inst_receiver_recoder_rxd_out(41);
  xgmii_rxd(40) <= U0_xaui_inst_receiver_recoder_rxd_out(40);
  xgmii_rxd(39) <= U0_xaui_inst_receiver_recoder_rxd_out(39);
  xgmii_rxd(38) <= U0_xaui_inst_receiver_recoder_rxd_out(38);
  xgmii_rxd(37) <= U0_xaui_inst_receiver_recoder_rxd_out(37);
  xgmii_rxd(36) <= U0_xaui_inst_receiver_recoder_rxd_out(36);
  xgmii_rxd(35) <= U0_xaui_inst_receiver_recoder_rxd_out(35);
  xgmii_rxd(34) <= U0_xaui_inst_receiver_recoder_rxd_out(34);
  xgmii_rxd(33) <= U0_xaui_inst_receiver_recoder_rxd_out(33);
  xgmii_rxd(32) <= U0_xaui_inst_receiver_recoder_rxd_out(32);
  xgmii_rxd(31) <= U0_xaui_inst_receiver_recoder_rxd_out(31);
  xgmii_rxd(30) <= U0_xaui_inst_receiver_recoder_rxd_out(30);
  xgmii_rxd(29) <= U0_xaui_inst_receiver_recoder_rxd_out(29);
  xgmii_rxd(28) <= U0_xaui_inst_receiver_recoder_rxd_out(28);
  xgmii_rxd(27) <= U0_xaui_inst_receiver_recoder_rxd_out(27);
  xgmii_rxd(26) <= U0_xaui_inst_receiver_recoder_rxd_out(26);
  xgmii_rxd(25) <= U0_xaui_inst_receiver_recoder_rxd_out(25);
  xgmii_rxd(24) <= U0_xaui_inst_receiver_recoder_rxd_out(24);
  xgmii_rxd(23) <= U0_xaui_inst_receiver_recoder_rxd_out(23);
  xgmii_rxd(22) <= U0_xaui_inst_receiver_recoder_rxd_out(22);
  xgmii_rxd(21) <= U0_xaui_inst_receiver_recoder_rxd_out(21);
  xgmii_rxd(20) <= U0_xaui_inst_receiver_recoder_rxd_out(20);
  xgmii_rxd(19) <= U0_xaui_inst_receiver_recoder_rxd_out(19);
  xgmii_rxd(18) <= U0_xaui_inst_receiver_recoder_rxd_out(18);
  xgmii_rxd(17) <= U0_xaui_inst_receiver_recoder_rxd_out(17);
  xgmii_rxd(16) <= U0_xaui_inst_receiver_recoder_rxd_out(16);
  xgmii_rxd(15) <= U0_xaui_inst_receiver_recoder_rxd_out(15);
  xgmii_rxd(14) <= U0_xaui_inst_receiver_recoder_rxd_out(14);
  xgmii_rxd(13) <= U0_xaui_inst_receiver_recoder_rxd_out(13);
  xgmii_rxd(12) <= U0_xaui_inst_receiver_recoder_rxd_out(12);
  xgmii_rxd(11) <= U0_xaui_inst_receiver_recoder_rxd_out(11);
  xgmii_rxd(10) <= U0_xaui_inst_receiver_recoder_rxd_out(10);
  xgmii_rxd(9) <= U0_xaui_inst_receiver_recoder_rxd_out(9);
  xgmii_rxd(8) <= U0_xaui_inst_receiver_recoder_rxd_out(8);
  xgmii_rxd(7) <= U0_xaui_inst_receiver_recoder_rxd_out(7);
  xgmii_rxd(6) <= U0_xaui_inst_receiver_recoder_rxd_out(6);
  xgmii_rxd(5) <= U0_xaui_inst_receiver_recoder_rxd_out(5);
  xgmii_rxd(4) <= U0_xaui_inst_receiver_recoder_rxd_out(4);
  xgmii_rxd(3) <= U0_xaui_inst_receiver_recoder_rxd_out(3);
  xgmii_rxd(2) <= U0_xaui_inst_receiver_recoder_rxd_out(2);
  xgmii_rxd(1) <= U0_xaui_inst_receiver_recoder_rxd_out(1);
  xgmii_rxd(0) <= U0_xaui_inst_receiver_recoder_rxd_out(0);
  xgmii_rxc(7) <= U0_xaui_inst_receiver_recoder_rxc_out(7);
  xgmii_rxc(6) <= U0_xaui_inst_receiver_recoder_rxc_out(6);
  xgmii_rxc(5) <= U0_xaui_inst_receiver_recoder_rxc_out(5);
  xgmii_rxc(4) <= U0_xaui_inst_receiver_recoder_rxc_out(4);
  xgmii_rxc(3) <= U0_xaui_inst_receiver_recoder_rxc_out(3);
  xgmii_rxc(2) <= U0_xaui_inst_receiver_recoder_rxc_out(2);
  xgmii_rxc(1) <= U0_xaui_inst_receiver_recoder_rxc_out(1);
  xgmii_rxc(0) <= U0_xaui_inst_receiver_recoder_rxc_out(0);
  mgt_txdata(63) <= U0_xaui_inst_transmitter_recoder_txd_out(63);
  mgt_txdata(62) <= U0_xaui_inst_transmitter_recoder_txd_out(62);
  mgt_txdata(61) <= U0_xaui_inst_transmitter_recoder_txd_out(61);
  mgt_txdata(60) <= U0_xaui_inst_transmitter_recoder_txd_out(60);
  mgt_txdata(59) <= U0_xaui_inst_transmitter_recoder_txd_out(59);
  mgt_txdata(58) <= U0_xaui_inst_transmitter_recoder_txd_out(58);
  mgt_txdata(57) <= U0_xaui_inst_transmitter_recoder_txd_out(57);
  mgt_txdata(56) <= U0_xaui_inst_transmitter_recoder_txd_out(56);
  mgt_txdata(55) <= U0_xaui_inst_transmitter_recoder_txd_out(31);
  mgt_txdata(54) <= U0_xaui_inst_transmitter_recoder_txd_out(30);
  mgt_txdata(53) <= U0_xaui_inst_transmitter_recoder_txd_out(29);
  mgt_txdata(52) <= U0_xaui_inst_transmitter_recoder_txd_out(28);
  mgt_txdata(51) <= U0_xaui_inst_transmitter_recoder_txd_out(27);
  mgt_txdata(50) <= U0_xaui_inst_transmitter_recoder_txd_out(26);
  mgt_txdata(49) <= U0_xaui_inst_transmitter_recoder_txd_out(25);
  mgt_txdata(48) <= U0_xaui_inst_transmitter_recoder_txd_out(24);
  mgt_txdata(47) <= U0_xaui_inst_transmitter_recoder_txd_out(55);
  mgt_txdata(46) <= U0_xaui_inst_transmitter_recoder_txd_out(54);
  mgt_txdata(45) <= U0_xaui_inst_transmitter_recoder_txd_out(53);
  mgt_txdata(44) <= U0_xaui_inst_transmitter_recoder_txd_out(52);
  mgt_txdata(43) <= U0_xaui_inst_transmitter_recoder_txd_out(51);
  mgt_txdata(42) <= U0_xaui_inst_transmitter_recoder_txd_out(50);
  mgt_txdata(41) <= U0_xaui_inst_transmitter_recoder_txd_out(49);
  mgt_txdata(40) <= U0_xaui_inst_transmitter_recoder_txd_out(48);
  mgt_txdata(39) <= U0_xaui_inst_transmitter_recoder_txd_out(23);
  mgt_txdata(38) <= U0_xaui_inst_transmitter_recoder_txd_out(22);
  mgt_txdata(37) <= U0_xaui_inst_transmitter_recoder_txd_out(21);
  mgt_txdata(36) <= U0_xaui_inst_transmitter_recoder_txd_out(20);
  mgt_txdata(35) <= U0_xaui_inst_transmitter_recoder_txd_out(19);
  mgt_txdata(34) <= U0_xaui_inst_transmitter_recoder_txd_out(18);
  mgt_txdata(33) <= U0_xaui_inst_transmitter_recoder_txd_out(17);
  mgt_txdata(32) <= U0_xaui_inst_transmitter_recoder_txd_out(16);
  mgt_txdata(31) <= U0_xaui_inst_transmitter_recoder_txd_out(47);
  mgt_txdata(30) <= U0_xaui_inst_transmitter_recoder_txd_out(46);
  mgt_txdata(29) <= U0_xaui_inst_transmitter_recoder_txd_out(45);
  mgt_txdata(28) <= U0_xaui_inst_transmitter_recoder_txd_out(44);
  mgt_txdata(27) <= U0_xaui_inst_transmitter_recoder_txd_out(43);
  mgt_txdata(26) <= U0_xaui_inst_transmitter_recoder_txd_out(42);
  mgt_txdata(25) <= U0_xaui_inst_transmitter_recoder_txd_out(41);
  mgt_txdata(24) <= U0_xaui_inst_transmitter_recoder_txd_out(40);
  mgt_txdata(23) <= U0_xaui_inst_transmitter_recoder_txd_out(15);
  mgt_txdata(22) <= U0_xaui_inst_transmitter_recoder_txd_out(14);
  mgt_txdata(21) <= U0_xaui_inst_transmitter_recoder_txd_out(13);
  mgt_txdata(20) <= U0_xaui_inst_transmitter_recoder_txd_out(12);
  mgt_txdata(19) <= U0_xaui_inst_transmitter_recoder_txd_out(11);
  mgt_txdata(18) <= U0_xaui_inst_transmitter_recoder_txd_out(10);
  mgt_txdata(17) <= U0_xaui_inst_transmitter_recoder_txd_out(9);
  mgt_txdata(16) <= U0_xaui_inst_transmitter_recoder_txd_out(8);
  mgt_txdata(15) <= U0_xaui_inst_transmitter_recoder_txd_out(39);
  mgt_txdata(14) <= U0_xaui_inst_transmitter_recoder_txd_out(38);
  mgt_txdata(13) <= U0_xaui_inst_transmitter_recoder_txd_out(37);
  mgt_txdata(12) <= U0_xaui_inst_transmitter_recoder_txd_out(36);
  mgt_txdata(11) <= U0_xaui_inst_transmitter_recoder_txd_out(35);
  mgt_txdata(10) <= U0_xaui_inst_transmitter_recoder_txd_out(34);
  mgt_txdata(9) <= U0_xaui_inst_transmitter_recoder_txd_out(33);
  mgt_txdata(8) <= U0_xaui_inst_transmitter_recoder_txd_out(32);
  mgt_txdata(7) <= U0_xaui_inst_transmitter_recoder_txd_out(7);
  mgt_txdata(6) <= U0_xaui_inst_transmitter_recoder_txd_out(6);
  mgt_txdata(5) <= U0_xaui_inst_transmitter_recoder_txd_out(5);
  mgt_txdata(4) <= U0_xaui_inst_transmitter_recoder_txd_out(4);
  mgt_txdata(3) <= U0_xaui_inst_transmitter_recoder_txd_out(3);
  mgt_txdata(2) <= U0_xaui_inst_transmitter_recoder_txd_out(2);
  mgt_txdata(1) <= U0_xaui_inst_transmitter_recoder_txd_out(1);
  mgt_txdata(0) <= U0_xaui_inst_transmitter_recoder_txd_out(0);
  mgt_txcharisk(7) <= U0_xaui_inst_transmitter_recoder_txc_out(7);
  mgt_txcharisk(6) <= U0_xaui_inst_transmitter_recoder_txc_out(3);
  mgt_txcharisk(5) <= U0_xaui_inst_transmitter_recoder_txc_out(6);
  mgt_txcharisk(4) <= U0_xaui_inst_transmitter_recoder_txc_out(2);
  mgt_txcharisk(3) <= U0_xaui_inst_transmitter_recoder_txc_out(5);
  mgt_txcharisk(2) <= U0_xaui_inst_transmitter_recoder_txc_out(1);
  mgt_txcharisk(1) <= U0_xaui_inst_transmitter_recoder_txc_out(4);
  mgt_txcharisk(0) <= U0_xaui_inst_transmitter_recoder_txc_out(0);
  mgt_enable_align(3) <= U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_enable_align_327;
  mgt_enable_align(2) <= U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_enable_align_328;
  mgt_enable_align(1) <= U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_enable_align_329;
  mgt_enable_align(0) <= U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_enable_align_330;
  sync_status(3) <= NlwRenamedSignal_U0_xaui_inst_sync(3);
  sync_status(2) <= NlwRenamedSignal_U0_xaui_inst_sync(2);
  sync_status(1) <= NlwRenamedSignal_U0_xaui_inst_sync(1);
  sync_status(0) <= NlwRenamedSignal_U0_xaui_inst_sync(0);
  status_vector(7) <= NlwRenamedSig_OI_U0_status_vector_int_7_Q;
  status_vector(6) <= NlwRenamedSig_OI_U0_status_vector_int_6_Q;
  status_vector(5) <= NlwRenamedSignal_U0_xaui_inst_sync(3);
  status_vector(4) <= NlwRenamedSignal_U0_xaui_inst_sync(2);
  status_vector(3) <= NlwRenamedSignal_U0_xaui_inst_sync(1);
  status_vector(2) <= NlwRenamedSignal_U0_xaui_inst_sync(0);
  status_vector(1) <= NlwRenamedSig_OI_U0_status_vector_int_1_Q;
  status_vector(0) <= NlwRenamedSig_OI_U0_status_vector_int_0_Q;
  mgt_enchansync <= U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync_339;
  mgt_loopback <= NlwRenamedSignal_U0_mgt_loopback_keep;
  mgt_powerdown <= NlwRenamedSignal_U0_mgt_powerdown_keep;
  align_status <= NlwRenamedSig_OI_U0_status_vector_int_6_Q;
  XST_VCC : VCC
    port map (
      P => N0
    );
  XST_GND : GND
    port map (
      G => U0_xaui_inst_transmitter_last_qmsg(0)
    );
  U0_xaui_inst_signal_detect_int_3 : FDS
    port map (
      C => usrclk,
      D => signal_detect(3),
      S => U0_xaui_inst_transmitter_last_qmsg(0),
      Q => U0_xaui_inst_signal_detect_int(3)
    );
  U0_xaui_inst_signal_detect_int_2 : FDS
    port map (
      C => usrclk,
      D => signal_detect(2),
      S => U0_xaui_inst_transmitter_last_qmsg(0),
      Q => U0_xaui_inst_signal_detect_int(2)
    );
  U0_xaui_inst_signal_detect_int_1 : FDS
    port map (
      C => usrclk,
      D => signal_detect(1),
      S => U0_xaui_inst_transmitter_last_qmsg(0),
      Q => U0_xaui_inst_signal_detect_int(1)
    );
  U0_xaui_inst_signal_detect_int_0 : FDS
    port map (
      C => usrclk,
      D => signal_detect(0),
      S => U0_xaui_inst_transmitter_last_qmsg(0),
      Q => U0_xaui_inst_signal_detect_int(0)
    );
  U0_xaui_inst_p_clear_aligned_edge_last_value : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_clear_aligned_348,
      R => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_p_clear_aligned_edge_last_value_344
    );
  U0_xaui_inst_p_clear_local_fault_edge_last_value : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_clear_local_fault_349,
      R => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_p_clear_local_fault_edge_last_value_346
    );
  U0_xaui_inst_clear_aligned : FD
    port map (
      C => usrclk,
      D => configuration_vector(3),
      Q => U0_xaui_inst_clear_aligned_348
    );
  U0_xaui_inst_clear_local_fault : FD
    port map (
      C => usrclk,
      D => configuration_vector(2),
      Q => U0_xaui_inst_clear_local_fault_349
    );
  U0_xaui_inst_usrclk_reset_pipe : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => reset,
      Q => U0_xaui_inst_usrclk_reset_pipe_351
    );
  U0_xaui_inst_transmitter_tx_is_idle_1 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_tx_is_idle_comb(1),
      Q => U0_xaui_inst_transmitter_tx_is_idle(1)
    );
  U0_xaui_inst_transmitter_tx_is_idle_0 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_tx_is_idle_comb(0),
      Q => U0_xaui_inst_transmitter_tx_is_idle(0)
    );
  U0_xaui_inst_transmitter_tx_is_q_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_tx_is_q_comb(1),
      Q => U0_xaui_inst_transmitter_tx_is_q(1)
    );
  U0_xaui_inst_transmitter_tx_is_q_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_tx_is_q_comb(0),
      Q => U0_xaui_inst_transmitter_tx_is_q(0)
    );
  U0_xaui_inst_transmitter_txc_pipe_7 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txc(7),
      Q => U0_xaui_inst_transmitter_txc_pipe(7)
    );
  U0_xaui_inst_transmitter_txc_pipe_6 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txc(6),
      Q => U0_xaui_inst_transmitter_txc_pipe(6)
    );
  U0_xaui_inst_transmitter_txc_pipe_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txc(5),
      Q => U0_xaui_inst_transmitter_txc_pipe(5)
    );
  U0_xaui_inst_transmitter_txc_pipe_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txc(4),
      Q => U0_xaui_inst_transmitter_txc_pipe(4)
    );
  U0_xaui_inst_transmitter_txc_pipe_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txc(3),
      Q => U0_xaui_inst_transmitter_txc_pipe(3)
    );
  U0_xaui_inst_transmitter_txc_pipe_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txc(2),
      Q => U0_xaui_inst_transmitter_txc_pipe(2)
    );
  U0_xaui_inst_transmitter_txc_pipe_1 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txc(1),
      Q => U0_xaui_inst_transmitter_txc_pipe(1)
    );
  U0_xaui_inst_transmitter_txc_pipe_0 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txc(0),
      Q => U0_xaui_inst_transmitter_txc_pipe(0)
    );
  U0_xaui_inst_transmitter_txd_pipe_63 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(63),
      Q => U0_xaui_inst_transmitter_txd_pipe(63)
    );
  U0_xaui_inst_transmitter_txd_pipe_62 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(62),
      Q => U0_xaui_inst_transmitter_txd_pipe(62)
    );
  U0_xaui_inst_transmitter_txd_pipe_61 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(61),
      Q => U0_xaui_inst_transmitter_txd_pipe(61)
    );
  U0_xaui_inst_transmitter_txd_pipe_60 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(60),
      Q => U0_xaui_inst_transmitter_txd_pipe(60)
    );
  U0_xaui_inst_transmitter_txd_pipe_59 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(59),
      Q => U0_xaui_inst_transmitter_txd_pipe(59)
    );
  U0_xaui_inst_transmitter_txd_pipe_58 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(58),
      Q => U0_xaui_inst_transmitter_txd_pipe(58)
    );
  U0_xaui_inst_transmitter_txd_pipe_57 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(57),
      Q => U0_xaui_inst_transmitter_txd_pipe(57)
    );
  U0_xaui_inst_transmitter_txd_pipe_56 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(56),
      Q => U0_xaui_inst_transmitter_txd_pipe(56)
    );
  U0_xaui_inst_transmitter_txd_pipe_55 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(55),
      Q => U0_xaui_inst_transmitter_txd_pipe(55)
    );
  U0_xaui_inst_transmitter_txd_pipe_54 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(54),
      Q => U0_xaui_inst_transmitter_txd_pipe(54)
    );
  U0_xaui_inst_transmitter_txd_pipe_53 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(53),
      Q => U0_xaui_inst_transmitter_txd_pipe(53)
    );
  U0_xaui_inst_transmitter_txd_pipe_52 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(52),
      Q => U0_xaui_inst_transmitter_txd_pipe(52)
    );
  U0_xaui_inst_transmitter_txd_pipe_51 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(51),
      Q => U0_xaui_inst_transmitter_txd_pipe(51)
    );
  U0_xaui_inst_transmitter_txd_pipe_50 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(50),
      Q => U0_xaui_inst_transmitter_txd_pipe(50)
    );
  U0_xaui_inst_transmitter_txd_pipe_49 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(49),
      Q => U0_xaui_inst_transmitter_txd_pipe(49)
    );
  U0_xaui_inst_transmitter_txd_pipe_48 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(48),
      Q => U0_xaui_inst_transmitter_txd_pipe(48)
    );
  U0_xaui_inst_transmitter_txd_pipe_47 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(47),
      Q => U0_xaui_inst_transmitter_txd_pipe(47)
    );
  U0_xaui_inst_transmitter_txd_pipe_46 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(46),
      Q => U0_xaui_inst_transmitter_txd_pipe(46)
    );
  U0_xaui_inst_transmitter_txd_pipe_45 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(45),
      Q => U0_xaui_inst_transmitter_txd_pipe(45)
    );
  U0_xaui_inst_transmitter_txd_pipe_44 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(44),
      Q => U0_xaui_inst_transmitter_txd_pipe(44)
    );
  U0_xaui_inst_transmitter_txd_pipe_43 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(43),
      Q => U0_xaui_inst_transmitter_txd_pipe(43)
    );
  U0_xaui_inst_transmitter_txd_pipe_42 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(42),
      Q => U0_xaui_inst_transmitter_txd_pipe(42)
    );
  U0_xaui_inst_transmitter_txd_pipe_41 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(41),
      Q => U0_xaui_inst_transmitter_txd_pipe(41)
    );
  U0_xaui_inst_transmitter_txd_pipe_40 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(40),
      Q => U0_xaui_inst_transmitter_txd_pipe(40)
    );
  U0_xaui_inst_transmitter_txd_pipe_39 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(39),
      Q => U0_xaui_inst_transmitter_txd_pipe(39)
    );
  U0_xaui_inst_transmitter_txd_pipe_38 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(38),
      Q => U0_xaui_inst_transmitter_txd_pipe(38)
    );
  U0_xaui_inst_transmitter_txd_pipe_37 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(37),
      Q => U0_xaui_inst_transmitter_txd_pipe(37)
    );
  U0_xaui_inst_transmitter_txd_pipe_36 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(36),
      Q => U0_xaui_inst_transmitter_txd_pipe(36)
    );
  U0_xaui_inst_transmitter_txd_pipe_35 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(35),
      Q => U0_xaui_inst_transmitter_txd_pipe(35)
    );
  U0_xaui_inst_transmitter_txd_pipe_34 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(34),
      Q => U0_xaui_inst_transmitter_txd_pipe(34)
    );
  U0_xaui_inst_transmitter_txd_pipe_33 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(33),
      Q => U0_xaui_inst_transmitter_txd_pipe(33)
    );
  U0_xaui_inst_transmitter_txd_pipe_32 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(32),
      Q => U0_xaui_inst_transmitter_txd_pipe(32)
    );
  U0_xaui_inst_transmitter_txd_pipe_31 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(31),
      Q => U0_xaui_inst_transmitter_txd_pipe(31)
    );
  U0_xaui_inst_transmitter_txd_pipe_30 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(30),
      Q => U0_xaui_inst_transmitter_txd_pipe(30)
    );
  U0_xaui_inst_transmitter_txd_pipe_29 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(29),
      Q => U0_xaui_inst_transmitter_txd_pipe(29)
    );
  U0_xaui_inst_transmitter_txd_pipe_28 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(28),
      Q => U0_xaui_inst_transmitter_txd_pipe(28)
    );
  U0_xaui_inst_transmitter_txd_pipe_27 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(27),
      Q => U0_xaui_inst_transmitter_txd_pipe(27)
    );
  U0_xaui_inst_transmitter_txd_pipe_26 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(26),
      Q => U0_xaui_inst_transmitter_txd_pipe(26)
    );
  U0_xaui_inst_transmitter_txd_pipe_25 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(25),
      Q => U0_xaui_inst_transmitter_txd_pipe(25)
    );
  U0_xaui_inst_transmitter_txd_pipe_24 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(24),
      Q => U0_xaui_inst_transmitter_txd_pipe(24)
    );
  U0_xaui_inst_transmitter_txd_pipe_23 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(23),
      Q => U0_xaui_inst_transmitter_txd_pipe(23)
    );
  U0_xaui_inst_transmitter_txd_pipe_22 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(22),
      Q => U0_xaui_inst_transmitter_txd_pipe(22)
    );
  U0_xaui_inst_transmitter_txd_pipe_21 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(21),
      Q => U0_xaui_inst_transmitter_txd_pipe(21)
    );
  U0_xaui_inst_transmitter_txd_pipe_20 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(20),
      Q => U0_xaui_inst_transmitter_txd_pipe(20)
    );
  U0_xaui_inst_transmitter_txd_pipe_19 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(19),
      Q => U0_xaui_inst_transmitter_txd_pipe(19)
    );
  U0_xaui_inst_transmitter_txd_pipe_18 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(18),
      Q => U0_xaui_inst_transmitter_txd_pipe(18)
    );
  U0_xaui_inst_transmitter_txd_pipe_17 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(17),
      Q => U0_xaui_inst_transmitter_txd_pipe(17)
    );
  U0_xaui_inst_transmitter_txd_pipe_16 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(16),
      Q => U0_xaui_inst_transmitter_txd_pipe(16)
    );
  U0_xaui_inst_transmitter_txd_pipe_15 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(15),
      Q => U0_xaui_inst_transmitter_txd_pipe(15)
    );
  U0_xaui_inst_transmitter_txd_pipe_14 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(14),
      Q => U0_xaui_inst_transmitter_txd_pipe(14)
    );
  U0_xaui_inst_transmitter_txd_pipe_13 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(13),
      Q => U0_xaui_inst_transmitter_txd_pipe(13)
    );
  U0_xaui_inst_transmitter_txd_pipe_12 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(12),
      Q => U0_xaui_inst_transmitter_txd_pipe(12)
    );
  U0_xaui_inst_transmitter_txd_pipe_11 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(11),
      Q => U0_xaui_inst_transmitter_txd_pipe(11)
    );
  U0_xaui_inst_transmitter_txd_pipe_10 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(10),
      Q => U0_xaui_inst_transmitter_txd_pipe(10)
    );
  U0_xaui_inst_transmitter_txd_pipe_9 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(9),
      Q => U0_xaui_inst_transmitter_txd_pipe(9)
    );
  U0_xaui_inst_transmitter_txd_pipe_8 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(8),
      Q => U0_xaui_inst_transmitter_txd_pipe(8)
    );
  U0_xaui_inst_transmitter_txd_pipe_7 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(7),
      Q => U0_xaui_inst_transmitter_txd_pipe(7)
    );
  U0_xaui_inst_transmitter_txd_pipe_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(6),
      Q => U0_xaui_inst_transmitter_txd_pipe(6)
    );
  U0_xaui_inst_transmitter_txd_pipe_5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(5),
      Q => U0_xaui_inst_transmitter_txd_pipe(5)
    );
  U0_xaui_inst_transmitter_txd_pipe_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(4),
      Q => U0_xaui_inst_transmitter_txd_pipe(4)
    );
  U0_xaui_inst_transmitter_txd_pipe_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(3),
      Q => U0_xaui_inst_transmitter_txd_pipe(3)
    );
  U0_xaui_inst_transmitter_txd_pipe_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(2),
      Q => U0_xaui_inst_transmitter_txd_pipe(2)
    );
  U0_xaui_inst_transmitter_txd_pipe_1 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(1),
      Q => U0_xaui_inst_transmitter_txd_pipe(1)
    );
  U0_xaui_inst_transmitter_txd_pipe_0 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => xgmii_txd(0),
      Q => U0_xaui_inst_transmitter_txd_pipe(0)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_63 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_63_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(63)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_62 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_62_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(62)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_61 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_61_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(61)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_60 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_60_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(60)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_59 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_59_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(59)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_58 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_58_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(58)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_57 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_57_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(57)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_56 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_56_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(56)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_55 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_55_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(55)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_54 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_54_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(54)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_53 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_53_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(53)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_52 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_52_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(52)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_51 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_51_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(51)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_50 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_50_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(50)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_49 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_49_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(49)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_48 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_48_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(48)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_47 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_47_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(47)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_46 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_46_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(46)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_45 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_45_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(45)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_44 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_44_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(44)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_43 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_43_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(43)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_42 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_42_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(42)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_41 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_41_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(41)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_40 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_40_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(40)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_39 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_39_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(39)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_38 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_38_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(38)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_37 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_37_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(37)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_36 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_36_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(36)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_35 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_35_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(35)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_34 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_34_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(34)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_33 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_33_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(33)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_32 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_32_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(32)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_31 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_31_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(31)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_30 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_30_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(30)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_29 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_29_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(29)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_28 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_28_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(28)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_27 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_27_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(27)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_26 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_26_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(26)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_25 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_25_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(25)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_24 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_24_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(24)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_23 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_23_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(23)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_22 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_22_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(22)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_21 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_21_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(21)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_20 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_20_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(20)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_19 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_19_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(19)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_18 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_18_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(18)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_17 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_17_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(17)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_16 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_16_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(16)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_15 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_15_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(15)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_14 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_14_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(14)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_13 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_13_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(13)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_12 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_12_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(12)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_11 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_11_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(11)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_10 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_10_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(10)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_9 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_9_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(9)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_8 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_8_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(8)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_7 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_7_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(7)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_6 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_6_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(6)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_5 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_5_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(5)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_4 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_4_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(4)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_3 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_3_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(3)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_2 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_2_Q,
      S => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(2)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_1 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_1_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(1)
    );
  U0_xaui_inst_transmitter_recoder_txd_out_0 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_0_Q,
      R => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      Q => U0_xaui_inst_transmitter_recoder_txd_out(0)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_31_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(31)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_30 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_30_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(30)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_29 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_29_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(29)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_28 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_28_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(28)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_27 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_27_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(27)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_26 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_26_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(26)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_25 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_25_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(25)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_24 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_24_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(24)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_23 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_23_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(23)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_22 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_22_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(22)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_21 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_21_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(21)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_20 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_20_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(20)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_19 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_19_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(19)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_18 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_18_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(18)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_17 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_17_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(17)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_16 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_16_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(16)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_15 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_15_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(15)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_14 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_14_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(14)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_13 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_13_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(13)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_12 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_12_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(12)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_11 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_11_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(11)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_10 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_10_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(10)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_9 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_9_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(9)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_8 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_8_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(8)
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_7 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_7_Q,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(7)
    );
  U0_xaui_inst_transmitter_align_count_4 : FDRE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_align_n0051_inv,
      D => U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_4_Q,
      R => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_align_count(4)
    );
  U0_xaui_inst_transmitter_align_count_3 : FDRE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_align_n0051_inv,
      D => U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_3_Q,
      R => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_align_count(3)
    );
  U0_xaui_inst_transmitter_align_count_2 : FDRE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_align_n0051_inv,
      D => U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_2_Q,
      R => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_align_count(2)
    );
  U0_xaui_inst_transmitter_align_count_1 : FDRE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_align_n0051_inv,
      D => U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_1_Q,
      R => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_align_count(1)
    );
  U0_xaui_inst_transmitter_align_count_0 : FDRE
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_align_n0051_inv,
      D => U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_0_Q,
      R => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_align_count(0)
    );
  U0_xaui_inst_transmitter_align_prbs_7 : FDSE
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_align_n0020_inv,
      D => U0_xaui_inst_transmitter_align_prbs(6),
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_align_prbs(7)
    );
  U0_xaui_inst_transmitter_align_prbs_6 : FDSE
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_align_n0020_inv,
      D => U0_xaui_inst_transmitter_align_prbs(5),
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_align_prbs(6)
    );
  U0_xaui_inst_transmitter_align_prbs_5 : FDSE
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_align_n0020_inv,
      D => U0_xaui_inst_transmitter_align_prbs(4),
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_align_prbs(5)
    );
  U0_xaui_inst_transmitter_align_prbs_4 : FDSE
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_align_n0020_inv,
      D => U0_xaui_inst_transmitter_align_prbs(3),
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_align_prbs(4)
    );
  U0_xaui_inst_transmitter_align_prbs_3 : FDSE
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_align_n0020_inv,
      D => U0_xaui_inst_transmitter_align_prbs(2),
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_align_prbs(3)
    );
  U0_xaui_inst_transmitter_align_prbs_2 : FDSE
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_align_n0020_inv,
      D => U0_xaui_inst_transmitter_align_prbs(1),
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_align_prbs(2)
    );
  U0_xaui_inst_transmitter_align_prbs_1 : FDSE
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      CE => U0_xaui_inst_transmitter_align_n0020_inv,
      D => U0_xaui_inst_transmitter_align_prbs_6_prbs_7_XOR_49_o,
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_align_prbs(1)
    );
  U0_xaui_inst_transmitter_k_r_prbs_i_prbs_8 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(6),
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(8)
    );
  U0_xaui_inst_transmitter_k_r_prbs_i_prbs_7 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(5),
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(7)
    );
  U0_xaui_inst_transmitter_k_r_prbs_i_prbs_6 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(4),
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(6)
    );
  U0_xaui_inst_transmitter_k_r_prbs_i_prbs_5 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(3),
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(5)
    );
  U0_xaui_inst_transmitter_k_r_prbs_i_prbs_4 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(2),
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(4)
    );
  U0_xaui_inst_transmitter_k_r_prbs_i_prbs_3 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(1),
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(3)
    );
  U0_xaui_inst_transmitter_k_r_prbs_i_prbs_2 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_k_r_prbs_i_prbs_6_prbs_7_XOR_66_o,
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(2)
    );
  U0_xaui_inst_transmitter_k_r_prbs_i_prbs_1 : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_k_r_prbs_i_prbs_5_prbs_6_XOR_65_o,
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(1)
    );
  U0_xaui_inst_transmitter_state_machine_state_0_2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(2),
      R => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_state_machine_state_0(2)
    );
  U0_xaui_inst_transmitter_state_machine_state_0_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(1),
      R => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_state_machine_state_0(1)
    );
  U0_xaui_inst_transmitter_state_machine_state_0_0 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(0),
      R => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_state_machine_state_0(0)
    );
  U0_xaui_inst_transmitter_state_machine_state_1_2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_2_Q,
      R => U0_xaui_inst_transmitter_state_machine_is_idle_1_is_q_1_AND_15_o_0,
      Q => U0_xaui_inst_transmitter_state_machine_state_1(2)
    );
  U0_xaui_inst_transmitter_state_machine_state_1_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_1_Q,
      R => U0_xaui_inst_transmitter_state_machine_is_idle_1_is_q_1_AND_15_o_0,
      Q => U0_xaui_inst_transmitter_state_machine_state_1(1)
    );
  U0_xaui_inst_transmitter_state_machine_state_1_0 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_0_1_680,
      R => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_state_machine_state_1(0)
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txc_out : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_txc_pipe(7),
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txc_out_364
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txc_out : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_txc_pipe(6),
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txc_out_373
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txc_out : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_txc_pipe(5),
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txc_out_382
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txc_out : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_txc_pipe(4),
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txc_out_391
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txc_out : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_txc_pipe(3),
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txc_out_400
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txc_out : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_txc_pipe(2),
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txc_out_409
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txc_out : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_txc_pipe(1),
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txc_out_418
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txc_out : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_txc_pipe(0),
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txc_out_427
    );
  U0_xaui_inst_receiver_sync_ok_3 : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_sync_ok_int(3),
      Q => NlwRenamedSignal_U0_xaui_inst_sync(3)
    );
  U0_xaui_inst_receiver_sync_ok_2 : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_sync_ok_int(2),
      Q => NlwRenamedSignal_U0_xaui_inst_sync(2)
    );
  U0_xaui_inst_receiver_sync_ok_1 : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_sync_ok_int(1),
      Q => NlwRenamedSignal_U0_xaui_inst_sync(1)
    );
  U0_xaui_inst_receiver_sync_ok_0 : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_sync_ok_int(0),
      Q => NlwRenamedSignal_U0_xaui_inst_sync(0)
    );
  U0_xaui_inst_receiver_sync_status : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_sync_status_int,
      Q => U0_xaui_inst_receiver_sync_status_718
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_align_status : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(2),
      Q => NlwRenamedSig_OI_U0_status_vector_int_6_Q
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1_2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1_2_PWR_19_o_wide_mux_42_OUT_2_Q,
      R => U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync_i_norst_inv_0,
      Q => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(2)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1_2_PWR_19_o_wide_mux_42_OUT_1_Q,
      R => U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync_i_norst_inv_0,
      Q => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(1)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1_0 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1_2_PWR_19_o_wide_mux_42_OUT_0_Q,
      R => U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync_i_norst_inv_0,
      Q => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(0)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_deskew_error_sliced : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_deskew_state_Mram_got_a_3_GND_18_o_Mux_9_o,
      Q => U0_xaui_inst_receiver_G_SYNC_deskew_state_deskew_error_sliced_748
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_deskew_error_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_deskew_state_Mram_got_a_7_GND_18_o_Mux_10_o,
      Q => U0_xaui_inst_receiver_G_SYNC_deskew_state_deskew_error(1)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_align_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_4_got_a_7_AND_50_o,
      Q => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_align(1)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_align_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_0_got_a_3_AND_47_o,
      Q => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_align(0)
    );
  U0_xaui_inst_receiver_recoder_rxc_out_7 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxc_pipe_3_PWR_20_o_MUX_341_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxc_out(7)
    );
  U0_xaui_inst_receiver_recoder_rxc_out_6 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxc_pipe_2_PWR_20_o_MUX_323_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxc_out(6)
    );
  U0_xaui_inst_receiver_recoder_rxc_out_5 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxc_pipe_1_PWR_20_o_MUX_305_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxc_out(5)
    );
  U0_xaui_inst_receiver_recoder_rxc_out_4 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxc_pipe_0_PWR_20_o_MUX_287_o,
      S => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxc_out(4)
    );
  U0_xaui_inst_receiver_recoder_rxc_out_3 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxc_half_pipe_3_PWR_20_o_MUX_269_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxc_out(3)
    );
  U0_xaui_inst_receiver_recoder_rxc_out_2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxc_half_pipe_2_PWR_20_o_MUX_251_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxc_out(2)
    );
  U0_xaui_inst_receiver_recoder_rxc_out_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxc_half_pipe_1_PWR_20_o_MUX_233_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxc_out(1)
    );
  U0_xaui_inst_receiver_recoder_rxc_out_0 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxc_half_pipe_0_PWR_20_o_MUX_215_o,
      S => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxc_out(0)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_63 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_31_PWR_20_o_MUX_332_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(63)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_62 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_30_PWR_20_o_MUX_333_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(62)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_61 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_29_PWR_20_o_MUX_334_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(61)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_60 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_28_PWR_20_o_MUX_335_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(60)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_59 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_27_PWR_20_o_MUX_336_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(59)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_58 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_26_PWR_20_o_MUX_337_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(58)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_57 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_25_PWR_20_o_MUX_338_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(57)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_56 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_24_GND_19_o_MUX_339_o,
      S => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(56)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_55 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_23_PWR_20_o_MUX_314_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(55)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_54 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_22_PWR_20_o_MUX_315_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(54)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_53 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_21_PWR_20_o_MUX_316_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(53)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_52 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_20_PWR_20_o_MUX_317_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(52)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_51 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_19_PWR_20_o_MUX_318_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(51)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_50 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_18_PWR_20_o_MUX_319_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(50)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_49 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_17_PWR_20_o_MUX_320_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(49)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_48 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_16_GND_19_o_MUX_321_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(48)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_47 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_15_PWR_20_o_MUX_296_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(47)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_46 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_14_PWR_20_o_MUX_297_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(46)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_45 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_13_PWR_20_o_MUX_298_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(45)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_44 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_12_PWR_20_o_MUX_299_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(44)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_43 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_11_PWR_20_o_MUX_300_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(43)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_42 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_10_PWR_20_o_MUX_301_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(42)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_41 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_9_PWR_20_o_MUX_302_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(41)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_40 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_8_GND_19_o_MUX_303_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(40)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_39 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_7_PWR_20_o_MUX_278_o,
      S => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(39)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_38 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_6_PWR_20_o_MUX_279_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(38)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_37 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_5_PWR_20_o_MUX_280_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(37)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_36 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_4_PWR_20_o_MUX_281_o,
      S => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(36)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_35 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_3_PWR_20_o_MUX_282_o,
      S => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(35)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_34 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_2_PWR_20_o_MUX_283_o,
      S => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(34)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_33 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_1_PWR_20_o_MUX_284_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(33)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_32 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe_0_GND_19_o_MUX_285_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(32)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_31 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_31_PWR_20_o_MUX_260_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(31)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_30 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_30_PWR_20_o_MUX_261_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(30)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_29 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_29_PWR_20_o_MUX_262_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(29)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_28 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_28_PWR_20_o_MUX_263_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(28)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_27 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_27_PWR_20_o_MUX_264_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(27)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_26 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_26_PWR_20_o_MUX_265_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(26)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_25 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_25_PWR_20_o_MUX_266_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(25)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_24 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_24_GND_19_o_MUX_267_o,
      S => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(24)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_23 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_23_PWR_20_o_MUX_242_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(23)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_22 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_22_PWR_20_o_MUX_243_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(22)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_21 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_21_PWR_20_o_MUX_244_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(21)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_20 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_20_PWR_20_o_MUX_245_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(20)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_19 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_19_PWR_20_o_MUX_246_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(19)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_18 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_18_PWR_20_o_MUX_247_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(18)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_17 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_17_PWR_20_o_MUX_248_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(17)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_16 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_16_GND_19_o_MUX_249_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(16)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_15 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_15_PWR_20_o_MUX_224_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(15)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_14 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_14_PWR_20_o_MUX_225_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(14)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_13 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_13_PWR_20_o_MUX_226_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(13)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_12 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_12_PWR_20_o_MUX_227_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(12)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_11 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_11_PWR_20_o_MUX_228_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(11)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_10 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_10_PWR_20_o_MUX_229_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(10)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_9 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_9_PWR_20_o_MUX_230_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(9)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_8 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_8_GND_19_o_MUX_231_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(8)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_7 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_7_PWR_20_o_MUX_206_o,
      S => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(7)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_6 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_6_PWR_20_o_MUX_207_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(6)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_5 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_5_PWR_20_o_MUX_208_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(5)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_4 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_4_PWR_20_o_MUX_209_o,
      S => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(4)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_3 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_3_PWR_20_o_MUX_210_o,
      S => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(3)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_2 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_2_PWR_20_o_MUX_211_o,
      S => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(2)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_1_PWR_20_o_MUX_212_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(1)
    );
  U0_xaui_inst_receiver_recoder_rxd_out_0 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_half_pipe_0_GND_19_o_MUX_213_o,
      R => U0_xaui_inst_align_status_int_inv,
      Q => U0_xaui_inst_receiver_recoder_rxd_out(0)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_31 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(63),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(31)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_30 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(62),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(30)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_29 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(61),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(29)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_28 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(60),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(28)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_27 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(59),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(27)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_26 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(58),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(26)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_25 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(57),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(25)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_24 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(56),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(24)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_23 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(55),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(23)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_22 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(54),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(22)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_21 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(53),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(21)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_20 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(52),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(20)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_19 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(51),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(19)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_18 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(50),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(18)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_17 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(49),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(17)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_16 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(48),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(16)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_15 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(47),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(15)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_14 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(46),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(14)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_13 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(45),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(13)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_12 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(44),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(12)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_11 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(43),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(11)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_10 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(42),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(10)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_9 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(41),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(9)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_8 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(40),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(8)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_7 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(39),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(7)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(38),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(6)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(37),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(5)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(36),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(4)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(35),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(3)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(34),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(2)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(33),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(1)
    );
  U0_xaui_inst_receiver_recoder_rxd_half_pipe_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxd_pipe(32),
      Q => U0_xaui_inst_receiver_recoder_rxd_half_pipe(0)
    );
  U0_xaui_inst_receiver_recoder_lane_term_pipe_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_lane_terminate(7),
      Q => U0_xaui_inst_receiver_recoder_lane_term_pipe(3)
    );
  U0_xaui_inst_receiver_recoder_lane_term_pipe_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_lane_terminate(6),
      Q => U0_xaui_inst_receiver_recoder_lane_term_pipe(2)
    );
  U0_xaui_inst_receiver_recoder_lane_term_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_lane_terminate(5),
      Q => U0_xaui_inst_receiver_recoder_lane_term_pipe(1)
    );
  U0_xaui_inst_receiver_recoder_lane_term_pipe_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_lane_terminate(4),
      Q => U0_xaui_inst_receiver_recoder_lane_term_pipe(0)
    );
  U0_xaui_inst_receiver_recoder_code_error_delay_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_code_error_pipe(4),
      Q => U0_xaui_inst_receiver_recoder_code_error_delay_0_890
    );
  U0_xaui_inst_receiver_recoder_code_error_delay_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_code_error_pipe(5),
      Q => U0_xaui_inst_receiver_recoder_code_error_delay_1_891
    );
  U0_xaui_inst_receiver_recoder_code_error_delay_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_code_error_pipe(7),
      Q => U0_xaui_inst_receiver_recoder_code_error_delay_3_893
    );
  U0_xaui_inst_receiver_recoder_rxc_half_pipe_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxc_pipe(7),
      Q => U0_xaui_inst_receiver_recoder_rxc_half_pipe(3)
    );
  U0_xaui_inst_receiver_recoder_rxc_half_pipe_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxc_pipe(6),
      Q => U0_xaui_inst_receiver_recoder_rxc_half_pipe(2)
    );
  U0_xaui_inst_receiver_recoder_rxc_half_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxc_pipe(5),
      Q => U0_xaui_inst_receiver_recoder_rxc_half_pipe(1)
    );
  U0_xaui_inst_receiver_recoder_rxc_half_pipe_0 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_rxc_pipe(4),
      Q => U0_xaui_inst_receiver_recoder_rxc_half_pipe(0)
    );
  U0_xaui_inst_receiver_recoder_code_error_delay_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_code_error_pipe(6),
      Q => U0_xaui_inst_receiver_recoder_code_error_delay_2_892
    );
  U0_xaui_inst_receiver_recoder_lane_terminate_7 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_7_AND_204_o_840,
      Q => U0_xaui_inst_receiver_recoder_lane_terminate(7)
    );
  U0_xaui_inst_receiver_recoder_lane_terminate_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_6_AND_202_o_841,
      Q => U0_xaui_inst_receiver_recoder_lane_terminate(6)
    );
  U0_xaui_inst_receiver_recoder_lane_terminate_5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_5_AND_200_o_842,
      Q => U0_xaui_inst_receiver_recoder_lane_terminate(5)
    );
  U0_xaui_inst_receiver_recoder_lane_terminate_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_4_AND_198_o_843,
      Q => U0_xaui_inst_receiver_recoder_lane_terminate(4)
    );
  U0_xaui_inst_receiver_recoder_lane_terminate_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_3_AND_196_o_844,
      Q => U0_xaui_inst_receiver_recoder_lane_terminate(3)
    );
  U0_xaui_inst_receiver_recoder_lane_terminate_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_2_AND_194_o_845,
      Q => U0_xaui_inst_receiver_recoder_lane_terminate(2)
    );
  U0_xaui_inst_receiver_recoder_lane_terminate_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_1_AND_192_o_846,
      Q => U0_xaui_inst_receiver_recoder_lane_terminate(1)
    );
  U0_xaui_inst_receiver_recoder_lane_terminate_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_0_AND_190_o_847,
      Q => U0_xaui_inst_receiver_recoder_lane_terminate(0)
    );
  U0_xaui_inst_receiver_recoder_rxc_pipe_7 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxcharisk(7),
      Q => U0_xaui_inst_receiver_recoder_rxc_pipe(7)
    );
  U0_xaui_inst_receiver_recoder_rxc_pipe_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxcharisk(5),
      Q => U0_xaui_inst_receiver_recoder_rxc_pipe(6)
    );
  U0_xaui_inst_receiver_recoder_rxc_pipe_5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxcharisk(3),
      Q => U0_xaui_inst_receiver_recoder_rxc_pipe(5)
    );
  U0_xaui_inst_receiver_recoder_rxc_pipe_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => mgt_rxcharisk(1),
      Q => U0_xaui_inst_receiver_recoder_rxc_pipe(4)
    );
  U0_xaui_inst_receiver_recoder_rxc_pipe_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxcharisk(6),
      Q => U0_xaui_inst_receiver_recoder_rxc_pipe(3)
    );
  U0_xaui_inst_receiver_recoder_rxc_pipe_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxcharisk(4),
      Q => U0_xaui_inst_receiver_recoder_rxc_pipe(2)
    );
  U0_xaui_inst_receiver_recoder_rxc_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxcharisk(2),
      Q => U0_xaui_inst_receiver_recoder_rxc_pipe(1)
    );
  U0_xaui_inst_receiver_recoder_rxc_pipe_0 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => mgt_rxcharisk(0),
      Q => U0_xaui_inst_receiver_recoder_rxc_pipe(0)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_63 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(63),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(63)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_62 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(62),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(62)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_61 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(61),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(61)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_60 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(60),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(60)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_59 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(59),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(59)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_58 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(58),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(58)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_57 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(57),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(57)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_56 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(56),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(56)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_55 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(47),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(55)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_54 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(46),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(54)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_53 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(45),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(53)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_52 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(44),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(52)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_51 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(43),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(51)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_50 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(42),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(50)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_49 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(41),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(49)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_48 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(40),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(48)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_47 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(31),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(47)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_46 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(30),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(46)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_45 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(29),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(45)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_44 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(28),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(44)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_43 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(27),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(43)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_42 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(26),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(42)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_41 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(25),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(41)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_40 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(24),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(40)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_39 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(15),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(39)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_38 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(14),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(38)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_37 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(13),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(37)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_36 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(12),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(36)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_35 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(11),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(35)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_34 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(10),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(34)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_33 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(9),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(33)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_32 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(8),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(32)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_31 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(55),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(31)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_30 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(54),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(30)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_29 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(53),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(29)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_28 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(52),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(28)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_27 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(51),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(27)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_26 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(50),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(26)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_25 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(49),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(25)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_24 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(48),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(24)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_23 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(39),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(23)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_22 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(38),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(22)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_21 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(37),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(21)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_20 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(36),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(20)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_19 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(35),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(19)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_18 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(34),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(18)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_17 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(33),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(17)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_16 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(32),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(16)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_15 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(23),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(15)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_14 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(22),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(14)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_13 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(21),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(13)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_12 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(20),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(12)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_11 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(19),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(11)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_10 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(18),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(10)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_9 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(17),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(9)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_8 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(16),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(8)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_7 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(7),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(7)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(6),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(6)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(5),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(5)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(4),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(4)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(3),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(3)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(2),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(2)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(1),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(1)
    );
  U0_xaui_inst_receiver_recoder_rxd_pipe_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_rxdata(0),
      Q => U0_xaui_inst_receiver_recoder_rxd_pipe(0)
    );
  U0_xaui_inst_receiver_recoder_code_error_pipe_7 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_code_error(7),
      Q => U0_xaui_inst_receiver_recoder_code_error_pipe(7)
    );
  U0_xaui_inst_receiver_recoder_code_error_pipe_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_code_error(6),
      Q => U0_xaui_inst_receiver_recoder_code_error_pipe(6)
    );
  U0_xaui_inst_receiver_recoder_code_error_pipe_5 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_code_error(5),
      Q => U0_xaui_inst_receiver_recoder_code_error_pipe(5)
    );
  U0_xaui_inst_receiver_recoder_code_error_pipe_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_code_error(4),
      Q => U0_xaui_inst_receiver_recoder_code_error_pipe(4)
    );
  U0_xaui_inst_receiver_recoder_code_error_pipe_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_code_error(3),
      Q => U0_xaui_inst_receiver_recoder_code_error_pipe(3)
    );
  U0_xaui_inst_receiver_recoder_code_error_pipe_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_code_error(2),
      Q => U0_xaui_inst_receiver_recoder_code_error_pipe(2)
    );
  U0_xaui_inst_receiver_recoder_code_error_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_code_error(1),
      Q => U0_xaui_inst_receiver_recoder_code_error_pipe(1)
    );
  U0_xaui_inst_receiver_recoder_code_error_pipe_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_code_error(0),
      Q => U0_xaui_inst_receiver_recoder_code_error_pipe(0)
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_4_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_3_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_2_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_1_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_0 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_0_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_enable_align : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_enable_align_i,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_enable_align_327
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codecomma(7),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codecomma(6),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codevalid(7),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codevalid(6),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_last : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_signal_detect_int(3),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_last_995
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_4_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_3 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_3_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_3_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_2_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_2_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_1_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_0 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_0_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_enable_align : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_enable_align_i,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_enable_align_328
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codecomma(5),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codecomma(4),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codevalid(5),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codevalid(4),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_last : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_signal_detect_int(2),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_last_1017
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_4_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_3 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_3_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_3_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_2_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_2_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_1_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_0 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_0_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_enable_align : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_enable_align_i,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_enable_align_329
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codecomma(3),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codecomma(2),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codevalid(3),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codevalid(2),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_last : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_signal_detect_int(1),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_last_1039
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_4_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_3 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_3_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_3_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_2_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_2_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_1_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_0 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_0_Q,
      R => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_change_0,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_enable_align : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_enable_align_i,
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_enable_align_330
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codecomma(1),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codecomma(0),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codevalid(1),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => mgt_codevalid(0),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_last : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_signal_detect_int(0),
      Q => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_last_1061
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT411 : LUT6
    generic map(
      INIT => X"FFFF8A808A808A80"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT3211,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(14),
      I2 => U0_xaui_inst_transmitter_tx_code_q(1),
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_6_Q,
      I4 => U0_xaui_inst_transmitter_tx_code_a(1),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT631,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_46_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT501 : LUT6
    generic map(
      INIT => X"FFFF8A808A808A80"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT3211,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(22),
      I2 => U0_xaui_inst_transmitter_tx_code_q(1),
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_6_Q,
      I4 => U0_xaui_inst_transmitter_tx_code_a(1),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT631,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_54_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT591 : LUT6
    generic map(
      INIT => X"FFFF8A808A808A80"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT3211,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(30),
      I2 => U0_xaui_inst_transmitter_tx_code_q(1),
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_6_Q,
      I4 => U0_xaui_inst_transmitter_tx_code_a(1),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT631,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_62_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT65 : LUT6
    generic map(
      INIT => X"FFFF8A808A808A80"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT1511,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(14),
      I2 => U0_xaui_inst_transmitter_tx_code_q(0),
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_6_Q,
      I4 => U0_xaui_inst_transmitter_tx_code_a(0),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT631,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_14_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT241 : LUT6
    generic map(
      INIT => X"FFFF8A808A808A80"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT1511,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(30),
      I2 => U0_xaui_inst_transmitter_tx_code_q(0),
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_6_Q,
      I4 => U0_xaui_inst_transmitter_tx_code_a(0),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT631,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_30_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT151 : LUT6
    generic map(
      INIT => X"FFFF8A808A808A80"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT1511,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(22),
      I2 => U0_xaui_inst_transmitter_tx_code_q(0),
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_6_Q,
      I4 => U0_xaui_inst_transmitter_tx_code_a(0),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT631,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_22_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT251 : LUT6
    generic map(
      INIT => X"FFFFFFFF10111000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_code_a(0),
      I1 => U0_xaui_inst_transmitter_tx_code_r(0),
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(31),
      I3 => U0_xaui_inst_transmitter_tx_code_q(0),
      I4 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_7_Q,
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT161,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_31_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT71 : LUT6
    generic map(
      INIT => X"FFFFFFFF10111000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_code_a(0),
      I1 => U0_xaui_inst_transmitter_tx_code_r(0),
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(15),
      I3 => U0_xaui_inst_transmitter_tx_code_q(0),
      I4 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_7_Q,
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT161,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_15_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT621 : LUT6
    generic map(
      INIT => X"FFFFFFFF10111000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_code_a(0),
      I1 => U0_xaui_inst_transmitter_tx_code_r(0),
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(7),
      I3 => U0_xaui_inst_transmitter_tx_code_q(0),
      I4 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_7_Q,
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT161,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_7_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT162 : LUT6
    generic map(
      INIT => X"FFFFFFFF10111000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_code_a(0),
      I1 => U0_xaui_inst_transmitter_tx_code_r(0),
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(23),
      I3 => U0_xaui_inst_transmitter_tx_code_q(0),
      I4 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_7_Q,
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT161,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_23_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT601 : LUT6
    generic map(
      INIT => X"FFFFFFFF10111000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_code_a(1),
      I1 => U0_xaui_inst_transmitter_tx_code_r(1),
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(31),
      I3 => U0_xaui_inst_transmitter_tx_code_q(1),
      I4 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_7_Q,
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT331,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_63_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT512 : LUT6
    generic map(
      INIT => X"FFFFFFFF10111000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_code_a(1),
      I1 => U0_xaui_inst_transmitter_tx_code_r(1),
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(23),
      I3 => U0_xaui_inst_transmitter_tx_code_q(1),
      I4 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_7_Q,
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT331,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_55_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT421 : LUT6
    generic map(
      INIT => X"FFFFFFFF10111000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_code_a(1),
      I1 => U0_xaui_inst_transmitter_tx_code_r(1),
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(15),
      I3 => U0_xaui_inst_transmitter_tx_code_q(1),
      I4 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_7_Q,
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT331,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_47_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT332 : LUT6
    generic map(
      INIT => X"FFFFFFFF10111000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_code_a(1),
      I1 => U0_xaui_inst_transmitter_tx_code_r(1),
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(7),
      I3 => U0_xaui_inst_transmitter_tx_code_q(1),
      I4 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_7_Q,
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT331,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_39_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT6351 : LUT3
    generic map(
      INIT => X"04"
    )
    port map (
      I0 => configuration_vector(6),
      I1 => configuration_vector(4),
      I2 => configuration_vector(5),
      O => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT6311 : LUT2
    generic map(
      INIT => X"D"
    )
    port map (
      I0 => configuration_vector(4),
      I1 => configuration_vector(5),
      O => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT631
    );
  U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o1 : LUT3
    generic map(
      INIT => X"20"
    )
    port map (
      I0 => configuration_vector(4),
      I1 => configuration_vector(6),
      I2 => configuration_vector(5),
      O => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o
    );
  U0_xaui_inst_transmitter_align_mux411 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFAAA9"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_align_count(4),
      I1 => U0_xaui_inst_transmitter_align_count(2),
      I2 => U0_xaui_inst_transmitter_align_count(3),
      I3 => U0_xaui_inst_transmitter_align_count(1),
      I4 => U0_xaui_inst_transmitter_tx_code_a(0),
      I5 => U0_xaui_inst_transmitter_tx_code_a(1),
      O => U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_4_Q
    );
  U0_xaui_inst_transmitter_align_mux311 : LUT6
    generic map(
      INIT => X"FEFEFEEF10101001"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_code_a(1),
      I1 => U0_xaui_inst_transmitter_tx_code_a(0),
      I2 => U0_xaui_inst_transmitter_align_count(3),
      I3 => U0_xaui_inst_transmitter_align_count(1),
      I4 => U0_xaui_inst_transmitter_align_count(2),
      I5 => U0_xaui_inst_transmitter_align_prbs(4),
      O => U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_3_Q
    );
  U0_xaui_inst_transmitter_align_Mxor_prbs_6_prbs_7_XOR_49_o_xo_0_1 : LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_align_prbs(6),
      I1 => U0_xaui_inst_transmitter_align_prbs(7),
      O => U0_xaui_inst_transmitter_align_prbs_6_prbs_7_XOR_49_o
    );
  U0_xaui_inst_transmitter_align_n0051_inv1 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFFFE"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_align_count(4),
      I1 => U0_xaui_inst_transmitter_align_count(3),
      I2 => U0_xaui_inst_transmitter_align_count(2),
      I3 => U0_xaui_inst_transmitter_align_count(1),
      I4 => U0_xaui_inst_transmitter_tx_code_a(0),
      I5 => U0_xaui_inst_transmitter_tx_code_a(1),
      O => U0_xaui_inst_transmitter_align_n0051_inv
    );
  U0_xaui_inst_transmitter_k_r_prbs_i_Mxor_prbs_5_prbs_6_XOR_65_o_xo_0_1 : LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(5),
      I1 => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(6),
      O => U0_xaui_inst_transmitter_k_r_prbs_i_prbs_5_prbs_6_XOR_65_o
    );
  U0_xaui_inst_transmitter_k_r_prbs_i_Mxor_prbs_6_prbs_7_XOR_66_o_xo_0_1 : LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(6),
      I1 => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(7),
      O => U0_xaui_inst_transmitter_k_r_prbs_i_prbs_6_prbs_7_XOR_66_o
    );
  U0_xaui_inst_transmitter_state_machine_tx_code_k_1_1 : LUT3
    generic map(
      INIT => X"41"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      O => U0_xaui_inst_transmitter_tx_code_k(1)
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp51 : LUT6
    generic map(
      INIT => X"EEE0E0EEEEE2E0EE"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_is_idle(0),
      I1 => U0_xaui_inst_transmitter_tx_is_q(0),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_447,
      O => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(2)
    );
  U0_xaui_inst_transmitter_state_machine_tx_code_q_1_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      O => U0_xaui_inst_transmitter_tx_code_q(1)
    );
  U0_xaui_inst_transmitter_state_machine_tx_code_a_1_1 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      O => U0_xaui_inst_transmitter_tx_code_a(1)
    );
  U0_xaui_inst_transmitter_state_machine_tx_code_a_0_1 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      O => U0_xaui_inst_transmitter_tx_code_a(0)
    );
  U0_xaui_inst_transmitter_state_machine_is_idle_1_is_q_1_AND_15_o_01 : LUT3
    generic map(
      INIT => X"AB"
    )
    port map (
      I0 => U0_xaui_inst_usrclk_reset_350,
      I1 => U0_xaui_inst_transmitter_tx_is_idle(1),
      I2 => U0_xaui_inst_transmitter_tx_is_q(1),
      O => U0_xaui_inst_transmitter_state_machine_is_idle_1_is_q_1_AND_15_o_0
    );
  U0_xaui_inst_transmitter_state_machine_tx_code_q_0_1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      O => U0_xaui_inst_transmitter_tx_code_q(0)
    );
  U0_xaui_inst_transmitter_state_machine_tx_code_r_1_2_1 : LUT3
    generic map(
      INIT => X"04"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      O => U0_xaui_inst_transmitter_tx_code_r(1)
    );
  U0_xaui_inst_transmitter_state_machine_tx_code_r_0_2_1 : LUT3
    generic map(
      INIT => X"04"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      O => U0_xaui_inst_transmitter_tx_code_r(0)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_Mmux_state_1_2_PWR_19_o_wide_mux_42_OUT21 : LUT5
    generic map(
      INIT => X"66148C44"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_deskew_state_deskew_error(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_deskew_state_p_state_comb_state_temp(1),
      I2 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_align(1),
      I3 => U0_xaui_inst_receiver_G_SYNC_deskew_state_p_state_comb_state_temp(2),
      I4 => U0_xaui_inst_receiver_G_SYNC_deskew_state_p_state_comb_state_temp(0),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1_2_PWR_19_o_wide_mux_42_OUT_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_Mmux_p_state_comb_state_temp_1_11 : LUT6
    generic map(
      INIT => X"282880A002202020"
    )
    port map (
      I0 => U0_xaui_inst_receiver_sync_status_718,
      I1 => U0_xaui_inst_receiver_G_SYNC_deskew_state_deskew_error_sliced_748,
      I2 => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(1),
      I3 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_align(0),
      I4 => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(0),
      I5 => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(2),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_p_state_comb_state_temp(1)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_Mmux_state_1_2_PWR_19_o_wide_mux_42_OUT11 : LUT5
    generic map(
      INIT => X"56520646"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_deskew_state_p_state_comb_state_temp(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_align(1),
      I2 => U0_xaui_inst_receiver_G_SYNC_deskew_state_deskew_error(1),
      I3 => U0_xaui_inst_receiver_G_SYNC_deskew_state_p_state_comb_state_temp(1),
      I4 => U0_xaui_inst_receiver_G_SYNC_deskew_state_p_state_comb_state_temp(2),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1_2_PWR_19_o_wide_mux_42_OUT_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_Mmux_p_state_comb_state_temp_0_11 : LUT6
    generic map(
      INIT => X"2200282822200828"
    )
    port map (
      I0 => U0_xaui_inst_receiver_sync_status_718,
      I1 => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(0),
      I2 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_align(0),
      I3 => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(2),
      I4 => U0_xaui_inst_receiver_G_SYNC_deskew_state_deskew_error_sliced_748,
      I5 => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(1),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_p_state_comb_state_temp(0)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_Mmux_p_state_comb_state_temp_2_11 : LUT6
    generic map(
      INIT => X"0888A88808888888"
    )
    port map (
      I0 => U0_xaui_inst_receiver_sync_status_718,
      I1 => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(2),
      I2 => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(1),
      I3 => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(0),
      I4 => U0_xaui_inst_receiver_G_SYNC_deskew_state_deskew_error_sliced_748,
      I5 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_align(0),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_p_state_comb_state_temp(2)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_Mram_got_a_7_GND_18_o_Mux_10_o11 : LUT4
    generic map(
      INIT => X"7FFE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(7),
      I1 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(4),
      I2 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(5),
      I3 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(6),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_Mram_got_a_7_GND_18_o_Mux_10_o
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_Mram_got_a_3_GND_18_o_Mux_9_o11 : LUT4
    generic map(
      INIT => X"7FFE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(3),
      I1 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(0),
      I2 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(1),
      I3 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(2),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_Mram_got_a_3_GND_18_o_Mux_9_o
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_Mmux_state_1_2_PWR_19_o_wide_mux_42_OUT31 : LUT5
    generic map(
      INIT => X"3AAA2AAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_deskew_state_p_state_comb_state_temp(2),
      I1 => U0_xaui_inst_receiver_G_SYNC_deskew_state_deskew_error(1),
      I2 => U0_xaui_inst_receiver_G_SYNC_deskew_state_p_state_comb_state_temp(0),
      I3 => U0_xaui_inst_receiver_G_SYNC_deskew_state_p_state_comb_state_temp(1),
      I4 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_align(1),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1_2_PWR_19_o_wide_mux_42_OUT_2_Q
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync_i_norst_inv_01 : LUT2
    generic map(
      INIT => X"D"
    )
    port map (
      I0 => U0_xaui_inst_receiver_sync_status_718,
      I1 => U0_xaui_inst_usrclk_reset_350,
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync_i_norst_inv_0
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_4_got_a_7_AND_50_o_4_1 : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(4),
      I1 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(5),
      I2 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(6),
      I3 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(7),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_4_got_a_7_AND_50_o
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_0_got_a_3_AND_47_o_0_1 : LUT4
    generic map(
      INIT => X"8000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(1),
      I2 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(2),
      I3 => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(3),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_0_got_a_3_AND_47_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_24_GND_19_o_MUX_339_o11 : LUT6
    generic map(
      INIT => X"00000000BEABAAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(24),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(31),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(30),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(29),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_116_o2,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_7_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_24_GND_19_o_MUX_339_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_25_PWR_20_o_MUX_338_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFF0882"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_116_o2,
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(29),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(30),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(31),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_7_Q,
      I5 => U0_xaui_inst_receiver_recoder_rxd_pipe(25),
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_25_PWR_20_o_MUX_338_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_27_PWR_20_o_MUX_336_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFF82A8AAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(27),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(31),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(30),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(29),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_116_o2,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_7_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_27_PWR_20_o_MUX_336_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_29_PWR_20_o_MUX_334_o11 : LUT5
    generic map(
      INIT => X"FFFFA22A"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(29),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_116_o2,
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(30),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(31),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_7_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_29_PWR_20_o_MUX_334_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_30_PWR_20_o_MUX_333_o11 : LUT5
    generic map(
      INIT => X"FFFF8AAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(30),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(31),
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_116_o2,
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(29),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_7_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_30_PWR_20_o_MUX_333_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_28_PWR_20_o_MUX_335_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFF82A8AAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(28),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(31),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(30),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(29),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_116_o2,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_7_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_28_PWR_20_o_MUX_335_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_16_GND_19_o_MUX_321_o11 : LUT6
    generic map(
      INIT => X"00000000AEEBAAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(16),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(21),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(23),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(22),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_114_o1,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_6_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_16_GND_19_o_MUX_321_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_19_PWR_20_o_MUX_318_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFF82A8AAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(19),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(23),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(22),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(21),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_114_o1,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_6_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_19_PWR_20_o_MUX_318_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_17_PWR_20_o_MUX_320_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFFAEEBAAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(17),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(21),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(23),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(22),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_114_o1,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_6_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_17_PWR_20_o_MUX_320_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_20_PWR_20_o_MUX_317_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFF82A8AAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(20),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(23),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(22),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(21),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_114_o1,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_6_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_20_PWR_20_o_MUX_317_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_8_GND_19_o_MUX_303_o11 : LUT6
    generic map(
      INIT => X"00000000BEABAAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(8),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(15),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(14),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(13),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_112_o1,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_5_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_8_GND_19_o_MUX_303_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_9_PWR_20_o_MUX_302_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFFBEABAAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(9),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(15),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(14),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(13),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_112_o1,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_5_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_9_PWR_20_o_MUX_302_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_12_PWR_20_o_MUX_299_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFF82A8AAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(12),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(15),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(14),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(13),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_112_o1,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_5_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_12_PWR_20_o_MUX_299_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_11_PWR_20_o_MUX_300_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFF82A8AAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(11),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(15),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(14),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(13),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_112_o1,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_5_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_11_PWR_20_o_MUX_300_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_0_GND_19_o_MUX_285_o11 : LUT6
    generic map(
      INIT => X"00000000BEABAAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(0),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(7),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(6),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(5),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_110_o1,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_4_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_0_GND_19_o_MUX_285_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_1_PWR_20_o_MUX_284_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFFBEABAAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(1),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(7),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(6),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(5),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_110_o1,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_4_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_1_PWR_20_o_MUX_284_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_3_PWR_20_o_MUX_282_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFF82A8AAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(3),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(7),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(6),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(5),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_110_o1,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_4_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_3_PWR_20_o_MUX_282_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_4_PWR_20_o_MUX_281_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFF82A8AAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(4),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(7),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(6),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(5),
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_110_o1,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_4_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_4_PWR_20_o_MUX_281_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_6_PWR_20_o_MUX_279_o11 : LUT5
    generic map(
      INIT => X"FFFF8AAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(6),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(7),
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_110_o1,
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(5),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_4_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_6_PWR_20_o_MUX_279_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_7_PWR_20_o_MUX_278_o11 : LUT5
    generic map(
      INIT => X"FFFF8AAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(7),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(6),
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_110_o1,
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(5),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_4_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_7_PWR_20_o_MUX_278_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_5_PWR_20_o_MUX_280_o11 : LUT5
    generic map(
      INIT => X"FFFFA22A"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(5),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_110_o1,
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(6),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(7),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_4_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_5_PWR_20_o_MUX_280_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_21_PWR_20_o_MUX_316_o11 : LUT5
    generic map(
      INIT => X"FFFFA22A"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(21),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_114_o1,
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(22),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(23),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_6_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_21_PWR_20_o_MUX_316_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_22_PWR_20_o_MUX_315_o11 : LUT5
    generic map(
      INIT => X"FFFF8AAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(22),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(23),
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_114_o1,
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(21),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_6_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_22_PWR_20_o_MUX_315_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_13_PWR_20_o_MUX_298_o11 : LUT5
    generic map(
      INIT => X"FFFFA22A"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(13),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_112_o1,
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(14),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(15),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_5_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_13_PWR_20_o_MUX_298_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_14_PWR_20_o_MUX_297_o11 : LUT5
    generic map(
      INIT => X"FFFF8AAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(14),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(15),
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_112_o1,
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(13),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_5_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_14_PWR_20_o_MUX_297_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_31_PWR_20_o_MUX_332_o11 : LUT5
    generic map(
      INIT => X"FFFF8AAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(31),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(30),
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_116_o2,
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(29),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_7_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_31_PWR_20_o_MUX_332_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_23_PWR_20_o_MUX_314_o11 : LUT5
    generic map(
      INIT => X"FFFF8AAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(23),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(22),
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_114_o1,
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(21),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_6_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_23_PWR_20_o_MUX_314_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_15_PWR_20_o_MUX_296_o11 : LUT5
    generic map(
      INIT => X"FFFF8AAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(15),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(14),
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_112_o1,
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(13),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_5_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_15_PWR_20_o_MUX_296_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_24_GND_19_o_MUX_267_o11 : LUT3
    generic map(
      INIT => X"0E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(24),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_108_o_753,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_3_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_24_GND_19_o_MUX_267_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_16_GND_19_o_MUX_249_o11 : LUT3
    generic map(
      INIT => X"0E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(16),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_106_o_754,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_2_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_16_GND_19_o_MUX_249_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_0_GND_19_o_MUX_213_o11 : LUT3
    generic map(
      INIT => X"0E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(0),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_102_o_756,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_0_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_0_GND_19_o_MUX_213_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_GND_19_o_GND_19_o_mux_97_OUT21 : LUT4
    generic map(
      INIT => X"1110"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_lane_terminate(0),
      I1 => U0_xaui_inst_receiver_recoder_lane_terminate(1),
      I2 => U0_xaui_inst_receiver_recoder_lane_terminate(2),
      I3 => U0_xaui_inst_receiver_recoder_lane_terminate(3),
      O => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_mux_97_OUT(1)
    );
  U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_116_o21 : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(28),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(27),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(26),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(25),
      I4 => U0_xaui_inst_receiver_recoder_rxd_pipe(24),
      I5 => U0_xaui_inst_receiver_recoder_rxc_pipe(3),
      O => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_116_o2
    );
  U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_110_o11 : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(4),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(3),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(2),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(1),
      I4 => U0_xaui_inst_receiver_recoder_rxd_pipe(0),
      I5 => U0_xaui_inst_receiver_recoder_rxc_pipe(0),
      O => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_110_o1
    );
  U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_114_o11 : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(20),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(19),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(18),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(17),
      I4 => U0_xaui_inst_receiver_recoder_rxd_pipe(16),
      I5 => U0_xaui_inst_receiver_recoder_rxc_pipe(2),
      O => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_114_o1
    );
  U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_112_o11 : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(12),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(11),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(10),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(9),
      I4 => U0_xaui_inst_receiver_recoder_rxd_pipe(8),
      I5 => U0_xaui_inst_receiver_recoder_rxc_pipe(1),
      O => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_112_o1
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_26_PWR_20_o_MUX_265_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(26),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_3_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_26_PWR_20_o_MUX_265_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_18_PWR_20_o_MUX_247_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(18),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_2_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_18_PWR_20_o_MUX_247_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_2_PWR_20_o_MUX_211_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(2),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_0_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_2_PWR_20_o_MUX_211_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxc_half_pipe_3_PWR_20_o_MUX_269_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxc_half_pipe(3),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_3_Q,
      O => U0_xaui_inst_receiver_recoder_rxc_half_pipe_3_PWR_20_o_MUX_269_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxc_half_pipe_2_PWR_20_o_MUX_251_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxc_half_pipe(2),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_2_Q,
      O => U0_xaui_inst_receiver_recoder_rxc_half_pipe_2_PWR_20_o_MUX_251_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxc_half_pipe_0_PWR_20_o_MUX_215_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxc_half_pipe(0),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_0_Q,
      O => U0_xaui_inst_receiver_recoder_rxc_half_pipe_0_PWR_20_o_MUX_215_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxc_pipe_3_PWR_20_o_MUX_341_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxc_pipe(3),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_7_Q,
      O => U0_xaui_inst_receiver_recoder_rxc_pipe_3_PWR_20_o_MUX_341_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxc_pipe_2_PWR_20_o_MUX_323_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxc_pipe(2),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_6_Q,
      O => U0_xaui_inst_receiver_recoder_rxc_pipe_2_PWR_20_o_MUX_323_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxc_pipe_1_PWR_20_o_MUX_305_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxc_pipe(1),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_5_Q,
      O => U0_xaui_inst_receiver_recoder_rxc_pipe_1_PWR_20_o_MUX_305_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxc_pipe_0_PWR_20_o_MUX_287_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxc_pipe(0),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_4_Q,
      O => U0_xaui_inst_receiver_recoder_rxc_pipe_0_PWR_20_o_MUX_287_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_26_PWR_20_o_MUX_337_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(26),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_7_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_26_PWR_20_o_MUX_337_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_18_PWR_20_o_MUX_319_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(18),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_6_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_18_PWR_20_o_MUX_319_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_10_PWR_20_o_MUX_301_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(10),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_5_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_10_PWR_20_o_MUX_301_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_pipe_2_PWR_20_o_MUX_283_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(2),
      I1 => U0_xaui_inst_receiver_recoder_error_lane_4_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_pipe_2_PWR_20_o_MUX_283_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_25_PWR_20_o_MUX_266_o11 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_108_o_753,
      I1 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(25),
      I2 => U0_xaui_inst_receiver_recoder_error_lane_3_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_25_PWR_20_o_MUX_266_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_27_PWR_20_o_MUX_264_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(27),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_108_o_753,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_3_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_27_PWR_20_o_MUX_264_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_28_PWR_20_o_MUX_263_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(28),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_108_o_753,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_3_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_28_PWR_20_o_MUX_263_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_29_PWR_20_o_MUX_262_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(29),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_108_o_753,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_3_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_29_PWR_20_o_MUX_262_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_30_PWR_20_o_MUX_261_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(30),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_108_o_753,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_3_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_30_PWR_20_o_MUX_261_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_31_PWR_20_o_MUX_260_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(31),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_108_o_753,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_3_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_31_PWR_20_o_MUX_260_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_17_PWR_20_o_MUX_248_o11 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_106_o_754,
      I1 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(17),
      I2 => U0_xaui_inst_receiver_recoder_error_lane_2_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_17_PWR_20_o_MUX_248_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_19_PWR_20_o_MUX_246_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(19),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_106_o_754,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_2_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_19_PWR_20_o_MUX_246_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_20_PWR_20_o_MUX_245_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(20),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_106_o_754,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_2_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_20_PWR_20_o_MUX_245_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_22_PWR_20_o_MUX_243_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(22),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_106_o_754,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_2_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_22_PWR_20_o_MUX_243_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_23_PWR_20_o_MUX_242_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(23),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_106_o_754,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_2_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_23_PWR_20_o_MUX_242_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_21_PWR_20_o_MUX_244_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(21),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_106_o_754,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_2_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_21_PWR_20_o_MUX_244_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_1_PWR_20_o_MUX_212_o11 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_102_o_756,
      I1 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(1),
      I2 => U0_xaui_inst_receiver_recoder_error_lane_0_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_1_PWR_20_o_MUX_212_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_3_PWR_20_o_MUX_210_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(3),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_102_o_756,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_0_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_3_PWR_20_o_MUX_210_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_5_PWR_20_o_MUX_208_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(5),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_102_o_756,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_0_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_5_PWR_20_o_MUX_208_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_6_PWR_20_o_MUX_207_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(6),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_102_o_756,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_0_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_6_PWR_20_o_MUX_207_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_4_PWR_20_o_MUX_209_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(4),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_102_o_756,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_0_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_4_PWR_20_o_MUX_209_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_7_PWR_20_o_MUX_206_o11 : LUT3
    generic map(
      INIT => X"F2"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(7),
      I1 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_102_o_756,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_0_Q,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_7_PWR_20_o_MUX_206_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_GND_19_o_GND_19_o_mux_97_OUT31 : LUT4
    generic map(
      INIT => X"0100"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_lane_terminate(0),
      I1 => U0_xaui_inst_receiver_recoder_lane_terminate(1),
      I2 => U0_xaui_inst_receiver_recoder_lane_terminate(2),
      I3 => U0_xaui_inst_receiver_recoder_lane_terminate(3),
      O => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_mux_97_OUT(2)
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_change_01 : LUT4
    generic map(
      INIT => X"EFFE"
    )
    port map (
      I0 => mgt_rx_reset(3),
      I1 => U0_xaui_inst_usrclk_reset_350,
      I2 => U0_xaui_inst_signal_detect_int(3),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_last_995,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_change_0
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mram_sync_ok11 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3_Q,
      O => U0_xaui_inst_receiver_sync_ok_int(3)
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_enable_align_i_4_1 : LUT5
    generic map(
      INIT => X"00000001"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_0_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_enable_align_i
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_change_01 : LUT4
    generic map(
      INIT => X"EFFE"
    )
    port map (
      I0 => mgt_rx_reset(2),
      I1 => U0_xaui_inst_usrclk_reset_350,
      I2 => U0_xaui_inst_signal_detect_int(2),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_last_1017,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_change_0
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mram_sync_ok11 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_2_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_3_Q,
      O => U0_xaui_inst_receiver_sync_ok_int(2)
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_enable_align_i_4_1 : LUT5
    generic map(
      INIT => X"00000001"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_3_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_2_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_0_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_enable_align_i
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_change_01 : LUT4
    generic map(
      INIT => X"EFFE"
    )
    port map (
      I0 => mgt_rx_reset(1),
      I1 => U0_xaui_inst_usrclk_reset_350,
      I2 => U0_xaui_inst_signal_detect_int(1),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_last_1039,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_change_0
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mram_sync_ok11 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_2_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_3_Q,
      O => U0_xaui_inst_receiver_sync_ok_int(1)
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_enable_align_i_4_1 : LUT5
    generic map(
      INIT => X"00000001"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_3_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_2_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_0_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_enable_align_i
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_change_01 : LUT4
    generic map(
      INIT => X"EFFE"
    )
    port map (
      I0 => mgt_rx_reset(0),
      I1 => U0_xaui_inst_usrclk_reset_350,
      I2 => U0_xaui_inst_signal_detect_int(0),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_last_1061,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_change_0
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mram_sync_ok11 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_2_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_3_Q,
      O => U0_xaui_inst_receiver_sync_ok_int(0)
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_enable_align_i_4_1 : LUT5
    generic map(
      INIT => X"00000001"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_3_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_2_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_0_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_enable_align_i
    );
  U0_xaui_inst_transmitter_tx_is_q_comb_1_1 : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => xgmii_txd(37),
      I1 => xgmii_txc(4),
      I2 => xgmii_txd(35),
      I3 => xgmii_txd(36),
      I4 => xgmii_txd(39),
      I5 => xgmii_txd(34),
      O => U0_xaui_inst_transmitter_tx_is_q_comb_1_1_1066
    );
  U0_xaui_inst_transmitter_tx_is_q_comb_1_2 : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => xgmii_txd(33),
      I1 => xgmii_txd(38),
      I2 => xgmii_txd(32),
      I3 => xgmii_txc(7),
      I4 => xgmii_txc(6),
      I5 => xgmii_txc(5),
      O => U0_xaui_inst_transmitter_tx_is_q_comb_1_2_1067
    );
  U0_xaui_inst_transmitter_tx_is_q_comb_1_3 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_is_q_comb_1_1_1066,
      I1 => U0_xaui_inst_transmitter_tx_is_q_comb_1_2_1067,
      O => U0_xaui_inst_transmitter_tx_is_q_comb(1)
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_1_1 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => xgmii_txd(33),
      I1 => xgmii_txd(40),
      I2 => xgmii_txc(7),
      I3 => xgmii_txd(32),
      I4 => xgmii_txc(5),
      I5 => xgmii_txc(6),
      O => U0_xaui_inst_transmitter_tx_is_idle_comb_1_1_1068
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_1_2 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => xgmii_txd(50),
      I1 => xgmii_txd(56),
      I2 => xgmii_txd(48),
      I3 => xgmii_txd(49),
      I4 => xgmii_txd(41),
      I5 => xgmii_txd(42),
      O => U0_xaui_inst_transmitter_tx_is_idle_comb_1_2_1069
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_1_3 : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => xgmii_txd(58),
      I1 => xgmii_txd(34),
      I2 => xgmii_txd(57),
      I3 => xgmii_txd(37),
      I4 => xgmii_txd(38),
      I5 => xgmii_txc(4),
      O => U0_xaui_inst_transmitter_tx_is_idle_comb_1_3_1070
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_1_4 : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => xgmii_txd(62),
      I1 => xgmii_txd(63),
      I2 => xgmii_txd(61),
      I3 => xgmii_txd(60),
      I4 => xgmii_txd(59),
      I5 => xgmii_txd(55),
      O => U0_xaui_inst_transmitter_tx_is_idle_comb_1_4_1071
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_1_5 : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => xgmii_txd(53),
      I1 => xgmii_txd(54),
      I2 => xgmii_txd(52),
      I3 => xgmii_txd(51),
      I4 => xgmii_txd(47),
      I5 => xgmii_txd(46),
      O => U0_xaui_inst_transmitter_tx_is_idle_comb_1_5_1072
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_1_6 : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => xgmii_txd(44),
      I1 => xgmii_txd(45),
      I2 => xgmii_txd(43),
      I3 => xgmii_txd(39),
      I4 => xgmii_txd(36),
      I5 => xgmii_txd(35),
      O => U0_xaui_inst_transmitter_tx_is_idle_comb_1_6_1073
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_1_7 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_is_idle_comb_1_1_1068,
      I1 => U0_xaui_inst_transmitter_tx_is_idle_comb_1_2_1069,
      I2 => U0_xaui_inst_transmitter_tx_is_idle_comb_1_3_1070,
      I3 => U0_xaui_inst_transmitter_tx_is_idle_comb_1_4_1071,
      I4 => U0_xaui_inst_transmitter_tx_is_idle_comb_1_5_1072,
      I5 => U0_xaui_inst_transmitter_tx_is_idle_comb_1_6_1073,
      O => U0_xaui_inst_transmitter_tx_is_idle_comb(1)
    );
  U0_xaui_inst_transmitter_tx_is_q_comb_0_1 : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => xgmii_txd(5),
      I1 => xgmii_txc(0),
      I2 => xgmii_txd(3),
      I3 => xgmii_txd(4),
      I4 => xgmii_txd(7),
      I5 => xgmii_txd(2),
      O => U0_xaui_inst_transmitter_tx_is_q_comb_0_1_1074
    );
  U0_xaui_inst_transmitter_tx_is_q_comb_0_2 : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => xgmii_txd(1),
      I1 => xgmii_txd(6),
      I2 => xgmii_txd(0),
      I3 => xgmii_txc(3),
      I4 => xgmii_txc(2),
      I5 => xgmii_txc(1),
      O => U0_xaui_inst_transmitter_tx_is_q_comb_0_2_1075
    );
  U0_xaui_inst_transmitter_tx_is_q_comb_0_3 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_is_q_comb_0_1_1074,
      I1 => U0_xaui_inst_transmitter_tx_is_q_comb_0_2_1075,
      O => U0_xaui_inst_transmitter_tx_is_q_comb(0)
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_0_1 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => xgmii_txd(10),
      I1 => xgmii_txd(16),
      I2 => xgmii_txc(3),
      I3 => xgmii_txd(0),
      I4 => xgmii_txc(1),
      I5 => xgmii_txc(2),
      O => U0_xaui_inst_transmitter_tx_is_idle_comb_0_1_1076
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_0_2 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => xgmii_txd(25),
      I1 => xgmii_txd(26),
      I2 => xgmii_txd(1),
      I3 => xgmii_txd(24),
      I4 => xgmii_txd(17),
      I5 => xgmii_txd(18),
      O => U0_xaui_inst_transmitter_tx_is_idle_comb_0_2_1077
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_0_3 : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => xgmii_txd(9),
      I1 => xgmii_txd(2),
      I2 => xgmii_txd(8),
      I3 => xgmii_txd(5),
      I4 => xgmii_txd(6),
      I5 => xgmii_txc(0),
      O => U0_xaui_inst_transmitter_tx_is_idle_comb_0_3_1078
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_0_4 : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => xgmii_txd(4),
      I1 => xgmii_txd(7),
      I2 => xgmii_txd(3),
      I3 => xgmii_txd(31),
      I4 => xgmii_txd(30),
      I5 => xgmii_txd(29),
      O => U0_xaui_inst_transmitter_tx_is_idle_comb_0_4_1079
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_0_5 : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => xgmii_txd(27),
      I1 => xgmii_txd(28),
      I2 => xgmii_txd(23),
      I3 => xgmii_txd(22),
      I4 => xgmii_txd(21),
      I5 => xgmii_txd(20),
      O => U0_xaui_inst_transmitter_tx_is_idle_comb_0_5_1080
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_0_6 : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => xgmii_txd(15),
      I1 => xgmii_txd(19),
      I2 => xgmii_txd(14),
      I3 => xgmii_txd(13),
      I4 => xgmii_txd(12),
      I5 => xgmii_txd(11),
      O => U0_xaui_inst_transmitter_tx_is_idle_comb_0_6_1081
    );
  U0_xaui_inst_transmitter_tx_is_idle_comb_0_7 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_is_idle_comb_0_1_1076,
      I1 => U0_xaui_inst_transmitter_tx_is_idle_comb_0_2_1077,
      I2 => U0_xaui_inst_transmitter_tx_is_idle_comb_0_3_1078,
      I3 => U0_xaui_inst_transmitter_tx_is_idle_comb_0_4_1079,
      I4 => U0_xaui_inst_transmitter_tx_is_idle_comb_0_5_1080,
      I5 => U0_xaui_inst_transmitter_tx_is_idle_comb_0_6_1081,
      O => U0_xaui_inst_transmitter_tx_is_idle_comb(0)
    );
  U0_xaui_inst_transmitter_is_terminate_1_1 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(60),
      I1 => U0_xaui_inst_transmitter_txd_pipe(59),
      I2 => U0_xaui_inst_transmitter_txd_pipe(62),
      I3 => U0_xaui_inst_transmitter_txd_pipe(61),
      I4 => U0_xaui_inst_transmitter_txc_pipe(7),
      I5 => U0_xaui_inst_transmitter_txd_pipe(63),
      O => U0_xaui_inst_transmitter_is_terminate_1_1_1082
    );
  U0_xaui_inst_transmitter_is_terminate_1_2 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(52),
      I1 => U0_xaui_inst_transmitter_txd_pipe(51),
      I2 => U0_xaui_inst_transmitter_txd_pipe(54),
      I3 => U0_xaui_inst_transmitter_txd_pipe(53),
      I4 => U0_xaui_inst_transmitter_txc_pipe(6),
      I5 => U0_xaui_inst_transmitter_txd_pipe(55),
      O => U0_xaui_inst_transmitter_is_terminate_1_2_1083
    );
  U0_xaui_inst_transmitter_is_terminate_1_3 : LUT3
    generic map(
      INIT => X"20"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(48),
      I1 => U0_xaui_inst_transmitter_txd_pipe(49),
      I2 => U0_xaui_inst_transmitter_txd_pipe(50),
      O => U0_xaui_inst_transmitter_is_terminate_1_3_1084
    );
  U0_xaui_inst_transmitter_is_terminate_1_4 : LUT6
    generic map(
      INIT => X"FF20FF0020200000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(56),
      I1 => U0_xaui_inst_transmitter_txd_pipe(57),
      I2 => U0_xaui_inst_transmitter_txd_pipe(58),
      I3 => U0_xaui_inst_transmitter_is_terminate_1_3_1084,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_1_1082,
      I5 => U0_xaui_inst_transmitter_is_terminate_1_2_1083,
      O => U0_xaui_inst_transmitter_is_terminate_1_4_1085
    );
  U0_xaui_inst_transmitter_is_terminate_1_5 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(36),
      I1 => U0_xaui_inst_transmitter_txd_pipe(35),
      I2 => U0_xaui_inst_transmitter_txd_pipe(38),
      I3 => U0_xaui_inst_transmitter_txd_pipe(37),
      I4 => U0_xaui_inst_transmitter_txc_pipe(4),
      I5 => U0_xaui_inst_transmitter_txd_pipe(39),
      O => U0_xaui_inst_transmitter_is_terminate_1_5_1086
    );
  U0_xaui_inst_transmitter_is_terminate_1_6 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(34),
      I1 => U0_xaui_inst_transmitter_txd_pipe(33),
      I2 => U0_xaui_inst_transmitter_txd_pipe(32),
      I3 => U0_xaui_inst_transmitter_is_terminate_1_5_1086,
      O => U0_xaui_inst_transmitter_is_terminate_1_6_1087
    );
  U0_xaui_inst_transmitter_is_terminate_1_7 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(44),
      I1 => U0_xaui_inst_transmitter_txd_pipe(43),
      I2 => U0_xaui_inst_transmitter_txd_pipe(46),
      I3 => U0_xaui_inst_transmitter_txd_pipe(45),
      I4 => U0_xaui_inst_transmitter_txc_pipe(5),
      I5 => U0_xaui_inst_transmitter_txd_pipe(47),
      O => U0_xaui_inst_transmitter_is_terminate_1_7_1088
    );
  U0_xaui_inst_transmitter_is_terminate_0_1 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(28),
      I1 => U0_xaui_inst_transmitter_txd_pipe(27),
      I2 => U0_xaui_inst_transmitter_txd_pipe(30),
      I3 => U0_xaui_inst_transmitter_txd_pipe(29),
      I4 => U0_xaui_inst_transmitter_txc_pipe(3),
      I5 => U0_xaui_inst_transmitter_txd_pipe(31),
      O => U0_xaui_inst_transmitter_is_terminate_0_1_1089
    );
  U0_xaui_inst_transmitter_is_terminate_0_2 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(20),
      I1 => U0_xaui_inst_transmitter_txd_pipe(19),
      I2 => U0_xaui_inst_transmitter_txd_pipe(22),
      I3 => U0_xaui_inst_transmitter_txd_pipe(21),
      I4 => U0_xaui_inst_transmitter_txc_pipe(2),
      I5 => U0_xaui_inst_transmitter_txd_pipe(23),
      O => U0_xaui_inst_transmitter_is_terminate_0_2_1090
    );
  U0_xaui_inst_transmitter_is_terminate_0_3 : LUT3
    generic map(
      INIT => X"20"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(16),
      I1 => U0_xaui_inst_transmitter_txd_pipe(17),
      I2 => U0_xaui_inst_transmitter_txd_pipe(18),
      O => U0_xaui_inst_transmitter_is_terminate_0_3_1091
    );
  U0_xaui_inst_transmitter_is_terminate_0_4 : LUT6
    generic map(
      INIT => X"FF20FF0020200000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(24),
      I1 => U0_xaui_inst_transmitter_txd_pipe(25),
      I2 => U0_xaui_inst_transmitter_txd_pipe(26),
      I3 => U0_xaui_inst_transmitter_is_terminate_0_3_1091,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_1_1089,
      I5 => U0_xaui_inst_transmitter_is_terminate_0_2_1090,
      O => U0_xaui_inst_transmitter_is_terminate_0_4_1092
    );
  U0_xaui_inst_transmitter_is_terminate_0_5 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(4),
      I1 => U0_xaui_inst_transmitter_txd_pipe(3),
      I2 => U0_xaui_inst_transmitter_txd_pipe(6),
      I3 => U0_xaui_inst_transmitter_txd_pipe(5),
      I4 => U0_xaui_inst_transmitter_txc_pipe(0),
      I5 => U0_xaui_inst_transmitter_txd_pipe(7),
      O => U0_xaui_inst_transmitter_is_terminate_0_5_1093
    );
  U0_xaui_inst_transmitter_is_terminate_0_6 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(2),
      I1 => U0_xaui_inst_transmitter_txd_pipe(1),
      I2 => U0_xaui_inst_transmitter_txd_pipe(0),
      I3 => U0_xaui_inst_transmitter_is_terminate_0_5_1093,
      O => U0_xaui_inst_transmitter_is_terminate_0_6_1094
    );
  U0_xaui_inst_transmitter_is_terminate_0_7 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(12),
      I1 => U0_xaui_inst_transmitter_txd_pipe(11),
      I2 => U0_xaui_inst_transmitter_txd_pipe(14),
      I3 => U0_xaui_inst_transmitter_txd_pipe(13),
      I4 => U0_xaui_inst_transmitter_txc_pipe(1),
      I5 => U0_xaui_inst_transmitter_txd_pipe(15),
      O => U0_xaui_inst_transmitter_is_terminate_0_7_1095
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_6_o1 : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txc_out_418,
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txc_out_427,
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_7_Q,
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_4_Q,
      I4 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_3_Q,
      I5 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_2_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_6_o1_1099
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_6_o2 : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txc_out_400,
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txc_out_409,
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_0_Q,
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_1_Q,
      I4 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_5_Q,
      I5 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_6_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_6_o2_1100
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1 : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txc_out_382,
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txc_out_391,
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_7_Q,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_4_Q,
      I4 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_3_Q,
      I5 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_2_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2 : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txc_out_364,
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txc_out_373,
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_0_Q,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_1_Q,
      I4 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_5_Q,
      I5 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_6_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102
    );
  U0_xaui_inst_transmitter_align_Mmux_a_cnt1_SW0 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_align_count(4),
      I1 => U0_xaui_inst_transmitter_align_count(3),
      I2 => U0_xaui_inst_transmitter_align_count(2),
      O => N16
    );
  U0_xaui_inst_transmitter_align_Mmux_a_cnt1 : LUT6
    generic map(
      INIT => X"00000000000000DF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_align_count(0),
      I1 => U0_xaui_inst_transmitter_align_extra_a_659,
      I2 => U0_xaui_inst_transmitter_align_count(1),
      I3 => N16,
      I4 => U0_xaui_inst_transmitter_tx_code_a(0),
      I5 => U0_xaui_inst_transmitter_tx_code_a(1),
      O => U0_xaui_inst_transmitter_a_due(0)
    );
  U0_xaui_inst_transmitter_align_Mmux_a_cnt2_SW0 : LUT3
    generic map(
      INIT => X"EF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_align_count(0),
      I1 => U0_xaui_inst_transmitter_align_count(1),
      I2 => U0_xaui_inst_transmitter_align_extra_a_659,
      O => N18
    );
  U0_xaui_inst_transmitter_align_Mmux_a_cnt2 : LUT6
    generic map(
      INIT => X"0000000000000111"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_align_count(4),
      I1 => U0_xaui_inst_transmitter_align_count(3),
      I2 => U0_xaui_inst_transmitter_align_count(2),
      I3 => N18,
      I4 => U0_xaui_inst_transmitter_tx_code_a(0),
      I5 => U0_xaui_inst_transmitter_tx_code_a(1),
      O => U0_xaui_inst_transmitter_a_due(1)
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_state_1_2_PWR_15_o_wide_mux_20_OUT2_SW0 : LUT3
    generic map(
      INIT => X"CE"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_is_q(1),
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_447,
      I2 => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(2),
      O => U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_0_2
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_state_1_2_PWR_15_o_wide_mux_20_OUT2 : LUT6
    generic map(
      INIT => X"0000F0F0EE00CC00"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_next_ifg_is_a_686,
      I1 => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(2),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_0_2,
      I3 => U0_xaui_inst_transmitter_a_due(1),
      I4 => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(0),
      I5 => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(1),
      O => U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_1_Q
    );
  U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_0_1 : LUT5
    generic map(
      INIT => X"11111F11"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_is_idle(1),
      I1 => U0_xaui_inst_transmitter_tx_is_q(1),
      I2 => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(7),
      I3 => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(2),
      I4 => U0_xaui_inst_transmitter_a_due(1),
      O => U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_0_Q
    );
  U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_0_3 : LUT6
    generic map(
      INIT => X"FFFF44F4FFFF0000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(7),
      I1 => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(2),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_0_2,
      I3 => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(0),
      I4 => U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_0_Q,
      I5 => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(1),
      O => U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_0_1_680
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp41 : LUT5
    generic map(
      INIT => X"FCA8FC00"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_next_ifg_is_a_686,
      I1 => U0_xaui_inst_transmitter_tx_is_idle(0),
      I2 => U0_xaui_inst_transmitter_tx_is_q(0),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I4 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      O => U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp4
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp42 : LUT4
    generic map(
      INIT => X"A8EC"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_447,
      I1 => U0_xaui_inst_transmitter_tx_is_q(0),
      I2 => U0_xaui_inst_transmitter_tx_is_idle(0),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      O => U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp41_1108
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp43 : LUT5
    generic map(
      INIT => X"75202020"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I2 => U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp41_1108,
      I3 => U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp4,
      I4 => U0_xaui_inst_transmitter_a_due(0),
      O => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(1)
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp21 : LUT6
    generic map(
      INIT => X"5500F5FC00000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(8),
      I1 => U0_xaui_inst_transmitter_tx_is_q(0),
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_447,
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I4 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I5 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      O => U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp2
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(62),
      I1 => U0_xaui_inst_transmitter_txd_pipe(63),
      I2 => U0_xaui_inst_transmitter_txd_pipe(61),
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o1_1110
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o2 : LUT6
    generic map(
      INIT => X"EFFFFFFF877FFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(57),
      I1 => U0_xaui_inst_transmitter_txd_pipe(56),
      I2 => U0_xaui_inst_transmitter_txd_pipe(59),
      I3 => U0_xaui_inst_transmitter_txd_pipe(58),
      I4 => U0_xaui_inst_transmitter_txd_pipe(60),
      I5 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o1_1110,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(54),
      I1 => U0_xaui_inst_transmitter_txd_pipe(55),
      I2 => U0_xaui_inst_transmitter_txd_pipe(53),
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o1_1111
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o2 : LUT6
    generic map(
      INIT => X"EFFFFFFF877FFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(49),
      I1 => U0_xaui_inst_transmitter_txd_pipe(48),
      I2 => U0_xaui_inst_transmitter_txd_pipe(51),
      I3 => U0_xaui_inst_transmitter_txd_pipe(50),
      I4 => U0_xaui_inst_transmitter_txd_pipe(52),
      I5 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o1_1111,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(46),
      I1 => U0_xaui_inst_transmitter_txd_pipe(47),
      I2 => U0_xaui_inst_transmitter_txd_pipe(45),
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o1_1112
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o2 : LUT6
    generic map(
      INIT => X"FDFFFFFF95FF7FFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(43),
      I1 => U0_xaui_inst_transmitter_txd_pipe(41),
      I2 => U0_xaui_inst_transmitter_txd_pipe(40),
      I3 => U0_xaui_inst_transmitter_txd_pipe(44),
      I4 => U0_xaui_inst_transmitter_txd_pipe(42),
      I5 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o1_1112,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(38),
      I1 => U0_xaui_inst_transmitter_txd_pipe(39),
      I2 => U0_xaui_inst_transmitter_txd_pipe(37),
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o1_1113
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o2 : LUT6
    generic map(
      INIT => X"EFFFFFFF877FFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(33),
      I1 => U0_xaui_inst_transmitter_txd_pipe(32),
      I2 => U0_xaui_inst_transmitter_txd_pipe(35),
      I3 => U0_xaui_inst_transmitter_txd_pipe(34),
      I4 => U0_xaui_inst_transmitter_txd_pipe(36),
      I5 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o1_1113,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(30),
      I1 => U0_xaui_inst_transmitter_txd_pipe(31),
      I2 => U0_xaui_inst_transmitter_txd_pipe(29),
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o1_1114
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o2 : LUT6
    generic map(
      INIT => X"EFFFFFFF877FFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(25),
      I1 => U0_xaui_inst_transmitter_txd_pipe(24),
      I2 => U0_xaui_inst_transmitter_txd_pipe(27),
      I3 => U0_xaui_inst_transmitter_txd_pipe(26),
      I4 => U0_xaui_inst_transmitter_txd_pipe(28),
      I5 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o1_1114,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(22),
      I1 => U0_xaui_inst_transmitter_txd_pipe(23),
      I2 => U0_xaui_inst_transmitter_txd_pipe(21),
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o1_1115
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o2 : LUT6
    generic map(
      INIT => X"EFFFFFFF877FFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(17),
      I1 => U0_xaui_inst_transmitter_txd_pipe(16),
      I2 => U0_xaui_inst_transmitter_txd_pipe(19),
      I3 => U0_xaui_inst_transmitter_txd_pipe(18),
      I4 => U0_xaui_inst_transmitter_txd_pipe(20),
      I5 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o1_1115,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(14),
      I1 => U0_xaui_inst_transmitter_txd_pipe(15),
      I2 => U0_xaui_inst_transmitter_txd_pipe(13),
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o1_1116
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o2 : LUT6
    generic map(
      INIT => X"FDFFFFFF95FF7FFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(11),
      I1 => U0_xaui_inst_transmitter_txd_pipe(9),
      I2 => U0_xaui_inst_transmitter_txd_pipe(8),
      I3 => U0_xaui_inst_transmitter_txd_pipe(12),
      I4 => U0_xaui_inst_transmitter_txd_pipe(10),
      I5 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o1_1116,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(6),
      I1 => U0_xaui_inst_transmitter_txd_pipe(7),
      I2 => U0_xaui_inst_transmitter_txd_pipe(5),
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o1_1117
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o2 : LUT6
    generic map(
      INIT => X"EFFFFFFF877FFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(1),
      I1 => U0_xaui_inst_transmitter_txd_pipe(0),
      I2 => U0_xaui_inst_transmitter_txd_pipe(3),
      I3 => U0_xaui_inst_transmitter_txd_pipe(2),
      I4 => U0_xaui_inst_transmitter_txd_pipe(4),
      I5 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o1_1117,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o
    );
  U0_xaui_inst_receiver_code_error_7_1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => mgt_rxdata(62),
      I1 => mgt_rxdata(63),
      I2 => mgt_rxdata(61),
      O => U0_xaui_inst_receiver_code_error_7_1_1118
    );
  U0_xaui_inst_receiver_code_error_7_2 : LUT6
    generic map(
      INIT => X"FFF79777FFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(58),
      I1 => mgt_rxdata(59),
      I2 => mgt_rxdata(56),
      I3 => mgt_rxdata(57),
      I4 => U0_xaui_inst_receiver_code_error_7_1_1118,
      I5 => mgt_rxdata(60),
      O => U0_xaui_inst_receiver_code_error_7_2_1119
    );
  U0_xaui_inst_receiver_code_error_7_3 : LUT3
    generic map(
      INIT => X"D5"
    )
    port map (
      I0 => mgt_codevalid(7),
      I1 => U0_xaui_inst_receiver_code_error_7_2_1119,
      I2 => mgt_rxcharisk(7),
      O => U0_xaui_inst_receiver_code_error(7)
    );
  U0_xaui_inst_receiver_code_error_6_1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => mgt_rxdata(46),
      I1 => mgt_rxdata(47),
      I2 => mgt_rxdata(45),
      O => U0_xaui_inst_receiver_code_error_6_1_1120
    );
  U0_xaui_inst_receiver_code_error_6_2 : LUT6
    generic map(
      INIT => X"FFF79777FFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(42),
      I1 => mgt_rxdata(43),
      I2 => mgt_rxdata(40),
      I3 => mgt_rxdata(41),
      I4 => U0_xaui_inst_receiver_code_error_6_1_1120,
      I5 => mgt_rxdata(44),
      O => U0_xaui_inst_receiver_code_error_6_2_1121
    );
  U0_xaui_inst_receiver_code_error_6_3 : LUT3
    generic map(
      INIT => X"D5"
    )
    port map (
      I0 => mgt_codevalid(5),
      I1 => U0_xaui_inst_receiver_code_error_6_2_1121,
      I2 => mgt_rxcharisk(5),
      O => U0_xaui_inst_receiver_code_error(6)
    );
  U0_xaui_inst_receiver_code_error_5_1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => mgt_rxdata(30),
      I1 => mgt_rxdata(31),
      I2 => mgt_rxdata(29),
      O => U0_xaui_inst_receiver_code_error_5_1_1122
    );
  U0_xaui_inst_receiver_code_error_5_2 : LUT6
    generic map(
      INIT => X"FFF79777FFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(26),
      I1 => mgt_rxdata(27),
      I2 => mgt_rxdata(24),
      I3 => mgt_rxdata(25),
      I4 => U0_xaui_inst_receiver_code_error_5_1_1122,
      I5 => mgt_rxdata(28),
      O => U0_xaui_inst_receiver_code_error_5_2_1123
    );
  U0_xaui_inst_receiver_code_error_5_3 : LUT3
    generic map(
      INIT => X"D5"
    )
    port map (
      I0 => mgt_codevalid(3),
      I1 => U0_xaui_inst_receiver_code_error_5_2_1123,
      I2 => mgt_rxcharisk(3),
      O => U0_xaui_inst_receiver_code_error(5)
    );
  U0_xaui_inst_receiver_code_error_4_1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => mgt_rxdata(14),
      I1 => mgt_rxdata(15),
      I2 => mgt_rxdata(13),
      O => U0_xaui_inst_receiver_code_error_4_1_1124
    );
  U0_xaui_inst_receiver_code_error_4_2 : LUT6
    generic map(
      INIT => X"FFF79777FFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(10),
      I1 => mgt_rxdata(11),
      I2 => mgt_rxdata(8),
      I3 => mgt_rxdata(9),
      I4 => U0_xaui_inst_receiver_code_error_4_1_1124,
      I5 => mgt_rxdata(12),
      O => U0_xaui_inst_receiver_code_error_4_2_1125
    );
  U0_xaui_inst_receiver_code_error_4_3 : LUT3
    generic map(
      INIT => X"D5"
    )
    port map (
      I0 => mgt_codevalid(1),
      I1 => U0_xaui_inst_receiver_code_error_4_2_1125,
      I2 => mgt_rxcharisk(1),
      O => U0_xaui_inst_receiver_code_error(4)
    );
  U0_xaui_inst_receiver_code_error_3_1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => mgt_rxdata(54),
      I1 => mgt_rxdata(55),
      I2 => mgt_rxdata(53),
      O => U0_xaui_inst_receiver_code_error_3_1_1126
    );
  U0_xaui_inst_receiver_code_error_3_2 : LUT6
    generic map(
      INIT => X"FFF79777FFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(50),
      I1 => mgt_rxdata(51),
      I2 => mgt_rxdata(48),
      I3 => mgt_rxdata(49),
      I4 => U0_xaui_inst_receiver_code_error_3_1_1126,
      I5 => mgt_rxdata(52),
      O => U0_xaui_inst_receiver_code_error_3_2_1127
    );
  U0_xaui_inst_receiver_code_error_3_3 : LUT3
    generic map(
      INIT => X"D5"
    )
    port map (
      I0 => mgt_codevalid(6),
      I1 => U0_xaui_inst_receiver_code_error_3_2_1127,
      I2 => mgt_rxcharisk(6),
      O => U0_xaui_inst_receiver_code_error(3)
    );
  U0_xaui_inst_receiver_code_error_2_1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => mgt_rxdata(38),
      I1 => mgt_rxdata(39),
      I2 => mgt_rxdata(37),
      O => U0_xaui_inst_receiver_code_error_2_1_1128
    );
  U0_xaui_inst_receiver_code_error_2_2 : LUT6
    generic map(
      INIT => X"FFF79777FFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(34),
      I1 => mgt_rxdata(35),
      I2 => mgt_rxdata(32),
      I3 => mgt_rxdata(33),
      I4 => U0_xaui_inst_receiver_code_error_2_1_1128,
      I5 => mgt_rxdata(36),
      O => U0_xaui_inst_receiver_code_error_2_2_1129
    );
  U0_xaui_inst_receiver_code_error_2_3 : LUT3
    generic map(
      INIT => X"D5"
    )
    port map (
      I0 => mgt_codevalid(4),
      I1 => U0_xaui_inst_receiver_code_error_2_2_1129,
      I2 => mgt_rxcharisk(4),
      O => U0_xaui_inst_receiver_code_error(2)
    );
  U0_xaui_inst_receiver_code_error_1_1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => mgt_rxdata(22),
      I1 => mgt_rxdata(23),
      I2 => mgt_rxdata(21),
      O => U0_xaui_inst_receiver_code_error_1_1_1130
    );
  U0_xaui_inst_receiver_code_error_1_2 : LUT6
    generic map(
      INIT => X"FFF79777FFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(18),
      I1 => mgt_rxdata(19),
      I2 => mgt_rxdata(16),
      I3 => mgt_rxdata(17),
      I4 => U0_xaui_inst_receiver_code_error_1_1_1130,
      I5 => mgt_rxdata(20),
      O => U0_xaui_inst_receiver_code_error_1_2_1131
    );
  U0_xaui_inst_receiver_code_error_1_3 : LUT3
    generic map(
      INIT => X"D5"
    )
    port map (
      I0 => mgt_codevalid(2),
      I1 => U0_xaui_inst_receiver_code_error_1_2_1131,
      I2 => mgt_rxcharisk(2),
      O => U0_xaui_inst_receiver_code_error(1)
    );
  U0_xaui_inst_receiver_code_error_0_1 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => mgt_rxdata(6),
      I1 => mgt_rxdata(7),
      I2 => mgt_rxdata(5),
      O => U0_xaui_inst_receiver_code_error_0_1_1132
    );
  U0_xaui_inst_receiver_code_error_0_2 : LUT6
    generic map(
      INIT => X"FFF79777FFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(2),
      I1 => mgt_rxdata(3),
      I2 => mgt_rxdata(0),
      I3 => mgt_rxdata(1),
      I4 => U0_xaui_inst_receiver_code_error_0_1_1132,
      I5 => mgt_rxdata(4),
      O => U0_xaui_inst_receiver_code_error_0_2_1133
    );
  U0_xaui_inst_receiver_code_error_0_3 : LUT3
    generic map(
      INIT => X"D5"
    )
    port map (
      I0 => mgt_codevalid(0),
      I1 => U0_xaui_inst_receiver_code_error_0_2_1133,
      I2 => mgt_rxcharisk(0),
      O => U0_xaui_inst_receiver_code_error(0)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_7_SW0 : LUT5
    generic map(
      INIT => X"EFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(56),
      I1 => mgt_rxdata(57),
      I2 => mgt_rxdata(58),
      I3 => mgt_rxcharisk(7),
      I4 => mgt_codevalid(7),
      O => N40
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_7_Q : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => mgt_rxdata(60),
      I1 => mgt_rxdata(59),
      I2 => mgt_rxdata(61),
      I3 => mgt_rxdata(63),
      I4 => N40,
      I5 => mgt_rxdata(62),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(7)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_6_SW0 : LUT5
    generic map(
      INIT => X"EFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(40),
      I1 => mgt_rxdata(41),
      I2 => mgt_rxdata(42),
      I3 => mgt_rxcharisk(5),
      I4 => mgt_codevalid(5),
      O => N42
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_6_Q : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => mgt_rxdata(44),
      I1 => mgt_rxdata(43),
      I2 => mgt_rxdata(45),
      I3 => mgt_rxdata(47),
      I4 => N42,
      I5 => mgt_rxdata(46),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(6)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_5_SW0 : LUT5
    generic map(
      INIT => X"EFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(24),
      I1 => mgt_rxdata(25),
      I2 => mgt_rxdata(26),
      I3 => mgt_rxcharisk(3),
      I4 => mgt_codevalid(3),
      O => N44
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_5_Q : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => mgt_rxdata(28),
      I1 => mgt_rxdata(27),
      I2 => mgt_rxdata(29),
      I3 => mgt_rxdata(31),
      I4 => N44,
      I5 => mgt_rxdata(30),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(5)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_4_SW0 : LUT5
    generic map(
      INIT => X"80000000"
    )
    port map (
      I0 => mgt_rxdata(12),
      I1 => mgt_rxdata(11),
      I2 => mgt_rxdata(10),
      I3 => mgt_rxcharisk(1),
      I4 => mgt_codevalid(1),
      O => N46
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_4_Q : LUT6
    generic map(
      INIT => X"0100000000000000"
    )
    port map (
      I0 => mgt_rxdata(9),
      I1 => mgt_rxdata(8),
      I2 => mgt_rxdata(15),
      I3 => mgt_rxdata(14),
      I4 => mgt_rxdata(13),
      I5 => N46,
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(4)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_3_SW0 : LUT5
    generic map(
      INIT => X"EFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(48),
      I1 => mgt_rxdata(49),
      I2 => mgt_rxdata(50),
      I3 => mgt_rxcharisk(6),
      I4 => mgt_codevalid(6),
      O => N48
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_3_Q : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => mgt_rxdata(52),
      I1 => mgt_rxdata(51),
      I2 => mgt_rxdata(53),
      I3 => mgt_rxdata(55),
      I4 => N48,
      I5 => mgt_rxdata(54),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(3)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_2_SW0 : LUT5
    generic map(
      INIT => X"EFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(32),
      I1 => mgt_rxdata(33),
      I2 => mgt_rxdata(34),
      I3 => mgt_rxcharisk(4),
      I4 => mgt_codevalid(4),
      O => N50
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_2_Q : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => mgt_rxdata(36),
      I1 => mgt_rxdata(35),
      I2 => mgt_rxdata(37),
      I3 => mgt_rxdata(39),
      I4 => N50,
      I5 => mgt_rxdata(38),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(2)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_1_SW0 : LUT5
    generic map(
      INIT => X"EFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(16),
      I1 => mgt_rxdata(17),
      I2 => mgt_rxdata(18),
      I3 => mgt_rxcharisk(2),
      I4 => mgt_codevalid(2),
      O => N52
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_1_Q : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => mgt_rxdata(20),
      I1 => mgt_rxdata(19),
      I2 => mgt_rxdata(21),
      I3 => mgt_rxdata(23),
      I4 => N52,
      I5 => mgt_rxdata(22),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(1)
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_0_SW0 : LUT5
    generic map(
      INIT => X"EFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(0),
      I1 => mgt_rxdata(1),
      I2 => mgt_rxdata(2),
      I3 => mgt_rxcharisk(0),
      I4 => mgt_codevalid(0),
      O => N54
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a_0_Q : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => mgt_rxdata(4),
      I1 => mgt_rxdata(3),
      I2 => mgt_rxdata(5),
      I3 => mgt_rxdata(7),
      I4 => N54,
      I5 => mgt_rxdata(6),
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_got_a(0)
    );
  U0_xaui_inst_receiver_recoder_error_lane_2_2_1 : LUT6
    generic map(
      INIT => X"EEEEEEEEEEEFEEEE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_lane_terminate(0),
      I1 => U0_xaui_inst_receiver_recoder_lane_terminate(1),
      I2 => U0_xaui_inst_receiver_recoder_lane_term_pipe(2),
      I3 => U0_xaui_inst_receiver_recoder_lane_term_pipe(0),
      I4 => U0_xaui_inst_receiver_recoder_lane_term_pipe(3),
      I5 => U0_xaui_inst_receiver_recoder_lane_term_pipe(1),
      O => U0_xaui_inst_receiver_recoder_error_lane_2_2_Q
    );
  U0_xaui_inst_receiver_recoder_error_lane_2_2_2 : LUT5
    generic map(
      INIT => X"FEAAFEFE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_code_error_delay_2_892,
      I1 => U0_xaui_inst_receiver_recoder_lane_terminate(0),
      I2 => U0_xaui_inst_receiver_recoder_lane_terminate(1),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(22),
      I4 => U0_xaui_inst_receiver_recoder_rxd_pipe(23),
      O => U0_xaui_inst_receiver_recoder_error_lane_2_2_1_1143
    );
  U0_xaui_inst_receiver_recoder_error_lane_2_2_3 : LUT6
    generic map(
      INIT => X"0010000000000010"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_lane_term_pipe(2),
      I1 => U0_xaui_inst_receiver_recoder_lane_term_pipe(0),
      I2 => U0_xaui_inst_receiver_recoder_lane_term_pipe(3),
      I3 => U0_xaui_inst_receiver_recoder_lane_term_pipe(1),
      I4 => U0_xaui_inst_receiver_recoder_rxd_pipe(23),
      I5 => U0_xaui_inst_receiver_recoder_rxd_pipe(22),
      O => U0_xaui_inst_receiver_recoder_error_lane_2_2_2_1144
    );
  U0_xaui_inst_receiver_recoder_error_lane_2_2_4 : LUT6
    generic map(
      INIT => X"FFFBFFF0FFFFFFF0"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_code_error_pipe(2),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(21),
      I2 => U0_xaui_inst_receiver_recoder_error_lane_2_2_1_1143,
      I3 => U0_xaui_inst_receiver_recoder_error_lane_2_2_2_1144,
      I4 => U0_xaui_inst_receiver_recoder_error_lane_2_2_Q,
      I5 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_114_o1,
      O => U0_xaui_inst_receiver_recoder_error_lane_2_Q
    );
  U0_xaui_inst_receiver_recoder_error_lane_1_1_1 : LUT6
    generic map(
      INIT => X"AAAAAA2AAAAAAAAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_lane_terminate(0),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(15),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(13),
      I3 => U0_xaui_inst_receiver_recoder_code_error_pipe(1),
      I4 => U0_xaui_inst_receiver_recoder_rxd_pipe(14),
      I5 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_112_o1,
      O => U0_xaui_inst_receiver_recoder_error_lane_1_1_Q
    );
  U0_xaui_inst_receiver_recoder_error_lane_1_1_2 : LUT4
    generic map(
      INIT => X"1110"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_lane_term_pipe(1),
      I1 => U0_xaui_inst_receiver_recoder_lane_term_pipe(0),
      I2 => U0_xaui_inst_receiver_recoder_lane_term_pipe(2),
      I3 => U0_xaui_inst_receiver_recoder_lane_term_pipe(3),
      O => U0_xaui_inst_receiver_recoder_error_lane_1_1_1_1146
    );
  U0_xaui_inst_receiver_recoder_error_lane_1_1_3 : LUT6
    generic map(
      INIT => X"EBFF0000FFFF0000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_code_error_pipe(1),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(14),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(15),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(13),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_1_1_1_1146,
      I5 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_112_o1,
      O => U0_xaui_inst_receiver_recoder_error_lane_1_1_2_1147
    );
  U0_xaui_inst_receiver_recoder_error_lane_3_3_SW0 : LUT4
    generic map(
      INIT => X"FFBF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(30),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(31),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(29),
      I3 => U0_xaui_inst_receiver_recoder_code_error_pipe(3),
      O => N56
    );
  U0_xaui_inst_receiver_recoder_error_lane_3_3_Q : LUT6
    generic map(
      INIT => X"FFFEAAAAFFFEFFFE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_code_error_delay_3_893,
      I1 => U0_xaui_inst_receiver_recoder_lane_terminate(2),
      I2 => U0_xaui_inst_receiver_recoder_lane_terminate(1),
      I3 => U0_xaui_inst_receiver_recoder_lane_terminate(0),
      I4 => N56,
      I5 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_116_o2,
      O => U0_xaui_inst_receiver_recoder_error_lane_3_Q
    );
  U0_xaui_inst_receiver_recoder_error_lane_6_6_2 : LUT6
    generic map(
      INIT => X"FFFFFFF7FFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(53),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(52),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(49),
      I3 => U0_xaui_inst_receiver_recoder_code_error_pipe(6),
      I4 => U0_xaui_inst_receiver_recoder_rxd_pipe(48),
      I5 => U0_xaui_inst_receiver_recoder_rxd_pipe(51),
      O => U0_xaui_inst_receiver_recoder_error_lane_6_6_1
    );
  U0_xaui_inst_receiver_recoder_error_lane_6_6_3 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxc_pipe(6),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(50),
      O => U0_xaui_inst_receiver_recoder_error_lane_6_6_2_1150
    );
  U0_xaui_inst_receiver_recoder_error_lane_5_5_1 : LUT6
    generic map(
      INIT => X"FFFFFFF7FFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(45),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(44),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(41),
      I3 => U0_xaui_inst_receiver_recoder_code_error_pipe(5),
      I4 => U0_xaui_inst_receiver_recoder_rxd_pipe(40),
      I5 => U0_xaui_inst_receiver_recoder_rxd_pipe(43),
      O => U0_xaui_inst_receiver_recoder_error_lane_5_5_Q
    );
  U0_xaui_inst_receiver_recoder_error_lane_7_7_1 : LUT6
    generic map(
      INIT => X"FFFFFFFDFFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(63),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(62),
      I2 => U0_xaui_inst_receiver_recoder_code_error_pipe(7),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(56),
      I4 => U0_xaui_inst_receiver_recoder_rxd_pipe(57),
      I5 => U0_xaui_inst_receiver_recoder_rxd_pipe(61),
      O => U0_xaui_inst_receiver_recoder_error_lane_7_7_Q
    );
  U0_xaui_inst_receiver_recoder_error_lane_7_7_2 : LUT4
    generic map(
      INIT => X"7FFF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(59),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(60),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(58),
      I3 => U0_xaui_inst_receiver_recoder_rxc_pipe(7),
      O => U0_xaui_inst_receiver_recoder_error_lane_7_7_1_1153
    );
  U0_xaui_inst_receiver_recoder_error_lane_7_7_3 : LUT6
    generic map(
      INIT => X"FFFEFFFEFFFECCCC"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_lane_terminate(6),
      I1 => U0_xaui_inst_receiver_recoder_code_error_pipe(3),
      I2 => U0_xaui_inst_receiver_recoder_lane_terminate(5),
      I3 => U0_xaui_inst_receiver_recoder_lane_terminate(4),
      I4 => U0_xaui_inst_receiver_recoder_error_lane_7_7_1_1153,
      I5 => U0_xaui_inst_receiver_recoder_error_lane_7_7_Q,
      O => U0_xaui_inst_receiver_recoder_error_lane_7_Q
    );
  U0_xaui_inst_receiver_recoder_error_lane_4_4_1 : LUT6
    generic map(
      INIT => X"FFFFFFF9FFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(38),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(39),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(33),
      I3 => U0_xaui_inst_receiver_recoder_code_error_pipe(4),
      I4 => U0_xaui_inst_receiver_recoder_rxd_pipe(32),
      I5 => U0_xaui_inst_receiver_recoder_rxd_pipe(37),
      O => U0_xaui_inst_receiver_recoder_error_lane_4_4_Q
    );
  U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_108_o_SW0 : LUT4
    generic map(
      INIT => X"FFBF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(25),
      I1 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(26),
      I2 => U0_xaui_inst_receiver_recoder_rxc_half_pipe(3),
      I3 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(24),
      O => N58
    );
  U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_108_o : LUT6
    generic map(
      INIT => X"0000000029000000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(29),
      I1 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(31),
      I2 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(30),
      I3 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(28),
      I4 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(27),
      I5 => N58,
      O => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_108_o_753
    );
  U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_106_o_SW0 : LUT4
    generic map(
      INIT => X"FFBF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(17),
      I1 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(18),
      I2 => U0_xaui_inst_receiver_recoder_rxc_half_pipe(2),
      I3 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(16),
      O => N60
    );
  U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_106_o : LUT6
    generic map(
      INIT => X"0000000029000000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(21),
      I1 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(23),
      I2 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(22),
      I3 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(20),
      I4 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(19),
      I5 => N60,
      O => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_106_o_754
    );
  U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_104_o_SW0 : LUT4
    generic map(
      INIT => X"FFBF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(9),
      I1 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(10),
      I2 => U0_xaui_inst_receiver_recoder_rxc_half_pipe(1),
      I3 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(8),
      O => N62
    );
  U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_104_o : LUT6
    generic map(
      INIT => X"0000000029000000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(13),
      I1 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(15),
      I2 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(14),
      I3 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(12),
      I4 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(11),
      I5 => N62,
      O => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_104_o_755
    );
  U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_102_o_SW0 : LUT4
    generic map(
      INIT => X"FFBF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(1),
      I1 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(2),
      I2 => U0_xaui_inst_receiver_recoder_rxc_half_pipe(0),
      I3 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(0),
      O => N64
    );
  U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_102_o : LUT6
    generic map(
      INIT => X"0000000029000000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(5),
      I1 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(7),
      I2 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(6),
      I3 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(4),
      I4 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(3),
      I5 => N64,
      O => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_102_o_756
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_7_AND_204_o : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => N66,
      I1 => mgt_rxdata(62),
      I2 => mgt_rxdata(61),
      I3 => mgt_rxdata(60),
      I4 => mgt_rxdata(59),
      I5 => mgt_rxdata(63),
      O => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_7_AND_204_o_840
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_6_AND_202_o : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => N68,
      I1 => mgt_rxdata(46),
      I2 => mgt_rxdata(45),
      I3 => mgt_rxdata(44),
      I4 => mgt_rxdata(43),
      I5 => mgt_rxdata(47),
      O => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_6_AND_202_o_841
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_5_AND_200_o : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => N70,
      I1 => mgt_rxdata(30),
      I2 => mgt_rxdata(29),
      I3 => mgt_rxdata(28),
      I4 => mgt_rxdata(27),
      I5 => mgt_rxdata(31),
      O => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_5_AND_200_o_842
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_4_AND_198_o : LUT6
    generic map(
      INIT => X"0000008000000000"
    )
    port map (
      I0 => mgt_rxdata(14),
      I1 => mgt_rxdata(13),
      I2 => mgt_rxdata(15),
      I3 => mgt_rxdata(9),
      I4 => N72,
      I5 => mgt_rxdata(8),
      O => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_4_AND_198_o_843
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_3_AND_196_o : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => N74,
      I1 => mgt_rxdata(54),
      I2 => mgt_rxdata(53),
      I3 => mgt_rxdata(52),
      I4 => mgt_rxdata(51),
      I5 => mgt_rxdata(55),
      O => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_3_AND_196_o_844
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_2_AND_194_o : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => N76,
      I1 => mgt_rxdata(38),
      I2 => mgt_rxdata(37),
      I3 => mgt_rxdata(36),
      I4 => mgt_rxdata(35),
      I5 => mgt_rxdata(39),
      O => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_2_AND_194_o_845
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_1_AND_192_o : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => N78,
      I1 => mgt_rxdata(22),
      I2 => mgt_rxdata(21),
      I3 => mgt_rxdata(20),
      I4 => mgt_rxdata(19),
      I5 => mgt_rxdata(23),
      O => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_1_AND_192_o_846
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_0_AND_190_o : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => N80,
      I1 => mgt_rxdata(6),
      I2 => mgt_rxdata(5),
      I3 => mgt_rxdata(4),
      I4 => mgt_rxdata(3),
      I5 => mgt_rxdata(7),
      O => U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_0_AND_190_o_847
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT2 : LUT6
    generic map(
      INIT => X"000F010E0F000F00"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I2 => N82,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_2_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_0_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_4_1_SW0 : LUT4
    generic map(
      INIT => X"8008"
    )
    port map (
      I0 => mgt_rxlock(3),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_last_995,
      I3 => U0_xaui_inst_signal_detect_int(3),
      O => N84
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_4_1 : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2_Q,
      I5 => N84,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_4_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_21_SW0 : LUT5
    generic map(
      INIT => X"99999995"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_0_Q,
      O => N86
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_21 : LUT6
    generic map(
      INIT => X"0000000000008200"
    )
    port map (
      I0 => mgt_rxlock(3),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_last_995,
      I2 => U0_xaui_inst_signal_detect_int(3),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      I5 => N86,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_22_SW0 : LUT6
    generic map(
      INIT => X"C0C03C7FFCFC03FF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_1_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q,
      O => N88
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_22 : LUT5
    generic map(
      INIT => X"00000082"
    )
    port map (
      I0 => mgt_rxlock(3),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_last_995,
      I2 => U0_xaui_inst_signal_detect_int(3),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      I4 => N88,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_2_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_27 : LUT6
    generic map(
      INIT => X"FFFF000000040FF0"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_28 : LUT5
    generic map(
      INIT => X"AAAA8008"
    )
    port map (
      I0 => mgt_rxlock(3),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24,
      I2 => U0_xaui_inst_signal_detect_int(3),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_last_995,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_3_1_SW0 : LUT5
    generic map(
      INIT => X"917FE01F"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q,
      O => N92
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_3_1 : LUT6
    generic map(
      INIT => X"80000080A20000A2"
    )
    port map (
      I0 => mgt_rxlock(3),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q,
      I3 => U0_xaui_inst_signal_detect_int(3),
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_last_995,
      I5 => N92,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_3_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT2 : LUT6
    generic map(
      INIT => X"000F010E0F000F00"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I2 => N94,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_2_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_0_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_4_1_SW0 : LUT4
    generic map(
      INIT => X"8008"
    )
    port map (
      I0 => mgt_rxlock(2),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_last_1017,
      I3 => U0_xaui_inst_signal_detect_int(2),
      O => N96
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_4_1 : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_2_Q,
      I5 => N96,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_4_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_21_SW0 : LUT5
    generic map(
      INIT => X"99999995"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_2_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_0_Q,
      O => N98
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_21 : LUT6
    generic map(
      INIT => X"0000000000008200"
    )
    port map (
      I0 => mgt_rxlock(2),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_last_1017,
      I2 => U0_xaui_inst_signal_detect_int(2),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q,
      I5 => N98,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_22_SW0 : LUT6
    generic map(
      INIT => X"C0C03C7FFCFC03FF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_1_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_2_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q,
      O => N100
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_22 : LUT5
    generic map(
      INIT => X"00000082"
    )
    port map (
      I0 => mgt_rxlock(2),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_last_1017,
      I2 => U0_xaui_inst_signal_detect_int(2),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q,
      I4 => N100,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_2_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_27 : LUT6
    generic map(
      INIT => X"FFFF000000040FF0"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_2_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_28 : LUT5
    generic map(
      INIT => X"AAAA8008"
    )
    port map (
      I0 => mgt_rxlock(2),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24,
      I2 => U0_xaui_inst_signal_detect_int(2),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_last_1017,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_3_1_SW0 : LUT5
    generic map(
      INIT => X"97A95755"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_3_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_0_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_2_Q,
      O => N104
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_3_1 : LUT6
    generic map(
      INIT => X"80000080A20000A2"
    )
    port map (
      I0 => mgt_rxlock(2),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q,
      I3 => U0_xaui_inst_signal_detect_int(2),
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_last_1017,
      I5 => N104,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_3_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT2 : LUT6
    generic map(
      INIT => X"000F010E0F000F00"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I2 => N106,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_2_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_0_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_4_1_SW0 : LUT4
    generic map(
      INIT => X"8008"
    )
    port map (
      I0 => mgt_rxlock(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_last_1039,
      I3 => U0_xaui_inst_signal_detect_int(1),
      O => N108
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_4_1 : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_2_Q,
      I5 => N108,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_4_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_21_SW0 : LUT5
    generic map(
      INIT => X"99999995"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_2_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_0_Q,
      O => N110
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_21 : LUT6
    generic map(
      INIT => X"0000000000008200"
    )
    port map (
      I0 => mgt_rxlock(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_last_1039,
      I2 => U0_xaui_inst_signal_detect_int(1),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q,
      I5 => N110,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_22_SW0 : LUT6
    generic map(
      INIT => X"C0C03C7FFCFC03FF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_1_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_2_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q,
      O => N112
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_22 : LUT5
    generic map(
      INIT => X"00000082"
    )
    port map (
      I0 => mgt_rxlock(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_last_1039,
      I2 => U0_xaui_inst_signal_detect_int(1),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q,
      I4 => N112,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_2_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_27 : LUT6
    generic map(
      INIT => X"FFFF000000040FF0"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_2_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_28 : LUT5
    generic map(
      INIT => X"AAAA8008"
    )
    port map (
      I0 => mgt_rxlock(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24,
      I2 => U0_xaui_inst_signal_detect_int(1),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_last_1039,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_3_1_SW0 : LUT5
    generic map(
      INIT => X"97A95755"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_3_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_0_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_2_Q,
      O => N116
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_3_1 : LUT6
    generic map(
      INIT => X"80000080A20000A2"
    )
    port map (
      I0 => mgt_rxlock(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q,
      I3 => U0_xaui_inst_signal_detect_int(1),
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_last_1039,
      I5 => N116,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_3_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT2 : LUT6
    generic map(
      INIT => X"000F010E0F000F00"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I2 => N118,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_2_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_0_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_4_1_SW0 : LUT4
    generic map(
      INIT => X"8008"
    )
    port map (
      I0 => mgt_rxlock(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_last_1061,
      I3 => U0_xaui_inst_signal_detect_int(0),
      O => N120
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_4_1 : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_2_Q,
      I5 => N120,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_4_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_21_SW0 : LUT5
    generic map(
      INIT => X"99999995"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_2_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_0_Q,
      O => N122
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_21 : LUT6
    generic map(
      INIT => X"0000000000008200"
    )
    port map (
      I0 => mgt_rxlock(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_last_1061,
      I2 => U0_xaui_inst_signal_detect_int(0),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q,
      I5 => N122,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_1_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_22_SW0 : LUT6
    generic map(
      INIT => X"C0C03C7FFCFC03FF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_1_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_2_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q,
      O => N124
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_22 : LUT5
    generic map(
      INIT => X"00000082"
    )
    port map (
      I0 => mgt_rxlock(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_last_1061,
      I2 => U0_xaui_inst_signal_detect_int(0),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q,
      I4 => N124,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_2_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_27 : LUT6
    generic map(
      INIT => X"FFFF000000040FF0"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_0_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_2_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_28 : LUT5
    generic map(
      INIT => X"AAAA8008"
    )
    port map (
      I0 => mgt_rxlock(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24,
      I2 => U0_xaui_inst_signal_detect_int(0),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_last_1061,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_3_1_SW0 : LUT5
    generic map(
      INIT => X"97A95755"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_3_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_0_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_2_Q,
      O => N128
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_3_1 : LUT6
    generic map(
      INIT => X"80000080A20000A2"
    )
    port map (
      I0 => mgt_rxlock(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q,
      I3 => U0_xaui_inst_signal_detect_int(0),
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_last_1061,
      I5 => N128,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_3_Q
    );
  U0_xaui_inst_aligned_sticky : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_aligned_sticky_glue_set_1199,
      R => U0_xaui_inst_usrclk_reset_350,
      Q => NlwRenamedSig_OI_U0_status_vector_int_7_Q
    );
  U0_xaui_inst_rx_local_fault : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_rx_local_fault_glue_set_1200,
      R => U0_xaui_inst_usrclk_reset_350,
      Q => NlwRenamedSig_OI_U0_status_vector_int_1_Q
    );
  U0_xaui_inst_tx_local_fault : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_tx_local_fault_glue_set_1201,
      R => U0_xaui_inst_usrclk_reset_350,
      Q => NlwRenamedSig_OI_U0_status_vector_int_0_Q
    );
  U0_xaui_inst_transmitter_recoder_txc_out_7 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_txc_out_7_glue_set_1202,
      R => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      Q => U0_xaui_inst_transmitter_recoder_txc_out(7)
    );
  U0_xaui_inst_transmitter_recoder_txc_out_6 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_txc_out_6_glue_set_1203,
      R => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      Q => U0_xaui_inst_transmitter_recoder_txc_out(6)
    );
  U0_xaui_inst_transmitter_recoder_txc_out_5 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_txc_out_5_glue_set_1204,
      R => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      Q => U0_xaui_inst_transmitter_recoder_txc_out(5)
    );
  U0_xaui_inst_transmitter_recoder_txc_out_4 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_txc_out_4_glue_set_1205,
      R => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      Q => U0_xaui_inst_transmitter_recoder_txc_out(4)
    );
  U0_xaui_inst_transmitter_recoder_txc_out_3 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_txc_out_3_glue_set_1206,
      R => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      Q => U0_xaui_inst_transmitter_recoder_txc_out(3)
    );
  U0_xaui_inst_transmitter_recoder_txc_out_2 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_txc_out_2_glue_set_1207,
      R => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      Q => U0_xaui_inst_transmitter_recoder_txc_out(2)
    );
  U0_xaui_inst_transmitter_recoder_txc_out_1 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_txc_out_1_glue_set_1208,
      R => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      Q => U0_xaui_inst_transmitter_recoder_txc_out(1)
    );
  U0_xaui_inst_transmitter_recoder_txc_out_0 : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_recoder_txc_out_0_glue_set_1209,
      R => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      Q => U0_xaui_inst_transmitter_recoder_txc_out(0)
    );
  U0_xaui_inst_transmitter_align_extra_a : FDR
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_align_extra_a_glue_set_1210,
      R => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_align_extra_a_659
    );
  U0_xaui_inst_transmitter_state_machine_next_ifg_is_a : FDS
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_state_machine_next_ifg_is_a_glue_rst_1211,
      S => U0_xaui_inst_usrclk_reset_350,
      Q => U0_xaui_inst_transmitter_state_machine_next_ifg_is_a_686
    );
  U0_xaui_inst_clear_aligned_edge : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_clear_aligned_edge_rstpot_1212,
      Q => U0_xaui_inst_clear_aligned_edge_345
    );
  U0_xaui_inst_clear_local_fault_edge : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_clear_local_fault_edge_rstpot_1213,
      Q => U0_xaui_inst_clear_local_fault_edge_347
    );
  U0_xaui_inst_usrclk_reset_rstpot : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_usrclk_reset_pipe_351,
      I1 => reset,
      O => U0_xaui_inst_usrclk_reset_rstpot_1214
    );
  U0_xaui_inst_usrclk_reset : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_usrclk_reset_rstpot_1214,
      Q => U0_xaui_inst_usrclk_reset_350
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync : FD
    port map (
      C => usrclk,
      D => U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync_rstpot_1215,
      Q => U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync_339
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_q_det : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_rstpot_1216,
      Q => U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_447
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_SW0_SW0 : LUT5
    generic map(
      INIT => X"F7FFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(56),
      I1 => U0_xaui_inst_transmitter_txd_pipe(57),
      I2 => U0_xaui_inst_transmitter_txd_pipe(59),
      I3 => U0_xaui_inst_transmitter_txd_pipe(58),
      I4 => U0_xaui_inst_transmitter_txc_pipe(7),
      O => N130
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_SW0_SW0 : LUT5
    generic map(
      INIT => X"FFFF7FFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(50),
      I1 => U0_xaui_inst_transmitter_txd_pipe(49),
      I2 => U0_xaui_inst_transmitter_txd_pipe(48),
      I3 => U0_xaui_inst_transmitter_txc_pipe(6),
      I4 => U0_xaui_inst_transmitter_txd_pipe(51),
      O => N132
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_SW0_SW0 : LUT5
    generic map(
      INIT => X"BFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(43),
      I1 => U0_xaui_inst_transmitter_txd_pipe(40),
      I2 => U0_xaui_inst_transmitter_txd_pipe(41),
      I3 => U0_xaui_inst_transmitter_txd_pipe(42),
      I4 => U0_xaui_inst_transmitter_txc_pipe(5),
      O => N134
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_SW0_SW0 : LUT5
    generic map(
      INIT => X"F7FFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(32),
      I1 => U0_xaui_inst_transmitter_txd_pipe(33),
      I2 => U0_xaui_inst_transmitter_txd_pipe(35),
      I3 => U0_xaui_inst_transmitter_txd_pipe(34),
      I4 => U0_xaui_inst_transmitter_txc_pipe(4),
      O => N136
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_SW0_SW0 : LUT5
    generic map(
      INIT => X"F7FFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(24),
      I1 => U0_xaui_inst_transmitter_txd_pipe(25),
      I2 => U0_xaui_inst_transmitter_txd_pipe(27),
      I3 => U0_xaui_inst_transmitter_txd_pipe(26),
      I4 => U0_xaui_inst_transmitter_txc_pipe(3),
      O => N138
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_SW0_SW0 : LUT5
    generic map(
      INIT => X"FFFF7FFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(18),
      I1 => U0_xaui_inst_transmitter_txd_pipe(17),
      I2 => U0_xaui_inst_transmitter_txd_pipe(16),
      I3 => U0_xaui_inst_transmitter_txc_pipe(2),
      I4 => U0_xaui_inst_transmitter_txd_pipe(19),
      O => N140
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_SW0_SW0 : LUT5
    generic map(
      INIT => X"BFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(11),
      I1 => U0_xaui_inst_transmitter_txd_pipe(8),
      I2 => U0_xaui_inst_transmitter_txd_pipe(9),
      I3 => U0_xaui_inst_transmitter_txd_pipe(10),
      I4 => U0_xaui_inst_transmitter_txc_pipe(1),
      O => N142
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_SW0_SW0 : LUT5
    generic map(
      INIT => X"F7FFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(0),
      I1 => U0_xaui_inst_transmitter_txd_pipe(1),
      I2 => U0_xaui_inst_transmitter_txd_pipe(3),
      I3 => U0_xaui_inst_transmitter_txd_pipe(2),
      I4 => U0_xaui_inst_transmitter_txc_pipe(0),
      O => N144
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_7 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_7_rstpot_1225,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_7_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_6_rstpot_1226,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_6_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_5_rstpot_1227,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_5_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_4_rstpot_1228,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_4_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_3_rstpot_1229,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_3_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_2_rstpot_1230,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_2_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_1_rstpot_1231,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_1_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_0_rstpot_1232,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_0_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_7 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_7_rstpot_1233,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_7_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_6_rstpot_1234,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_6_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_5_rstpot_1235,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_5_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_4_rstpot_1236,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_4_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_3_rstpot_1237,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_3_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_2_rstpot_1238,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_2_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_1_rstpot_1239,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_1_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_0_rstpot_1240,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_0_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_7 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_7_rstpot_1241,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_7_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_6_rstpot_1242,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_6_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_5_rstpot_1243,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_5_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_4_rstpot_1244,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_4_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_3_rstpot_1245,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_3_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_2_rstpot_1246,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_2_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_1_rstpot_1247,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_1_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_0_rstpot_1248,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_0_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_7 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_7_rstpot_1249,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_7_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_6_rstpot_1250,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_6_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_5_rstpot_1251,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_5_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_4_rstpot_1252,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_4_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_3_rstpot_1253,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_3_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_2_rstpot_1254,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_2_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_1_rstpot_1255,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_1_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_0_rstpot_1256,
      Q => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_0_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_7 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_7_rstpot_1257,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_7_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_6_rstpot_1258,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_6_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_5_rstpot_1259,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_5_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_4_rstpot_1260,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_4_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_3_rstpot_1261,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_3_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_2_rstpot_1262,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_2_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_1_rstpot_1263,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_1_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_0_rstpot_1264,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_0_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_7 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_7_rstpot_1265,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_7_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_6_rstpot_1266,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_6_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_5_rstpot_1267,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_5_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_4_rstpot_1268,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_4_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_3_rstpot_1269,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_3_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_2_rstpot_1270,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_2_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_1_rstpot_1271,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_1_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_0_rstpot_1272,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_0_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_7 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_7_rstpot_1273,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_7_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_6_rstpot_1274,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_6_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_5_rstpot_1275,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_5_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_4_rstpot_1276,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_4_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_3_rstpot_1277,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_3_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_2_rstpot_1278,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_2_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_1_rstpot_1279,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_1_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_0_rstpot_1280,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_0_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_7 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_7_rstpot_1281,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_7_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_6 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_6_rstpot_1282,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_6_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_5 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_5_rstpot_1283,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_5_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_4_rstpot_1284,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_4_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_3_rstpot_1285,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_3_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_2 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_2_rstpot_1286,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_2_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_1_rstpot_1287,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_1_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => usrclk,
      D => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_0_rstpot_1288,
      Q => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_0_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_6_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(62),
      I1 => U0_xaui_inst_transmitter_txc_pipe(7),
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_694,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_6_rstpot_1226
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_1_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(57),
      I1 => U0_xaui_inst_transmitter_txc_pipe(7),
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_694,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_1_rstpot_1231
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_6_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(54),
      I1 => U0_xaui_inst_transmitter_txc_pipe(6),
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_696,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_6_rstpot_1234
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_1_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(49),
      I1 => U0_xaui_inst_transmitter_txc_pipe(6),
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_696,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_1_rstpot_1239
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_6_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(46),
      I1 => U0_xaui_inst_transmitter_txc_pipe(5),
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_698,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_6_rstpot_1242
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_1_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(41),
      I1 => U0_xaui_inst_transmitter_txc_pipe(5),
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_698,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_1_rstpot_1247
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_6_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(38),
      I1 => U0_xaui_inst_transmitter_txc_pipe(4),
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_700,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_6_rstpot_1250
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_1_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(33),
      I1 => U0_xaui_inst_transmitter_txc_pipe(4),
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_700,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_1_rstpot_1255
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_6_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(30),
      I1 => U0_xaui_inst_transmitter_txc_pipe(3),
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_702,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_6_rstpot_1258
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_1_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(25),
      I1 => U0_xaui_inst_transmitter_txc_pipe(3),
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_702,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_1_rstpot_1263
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_6_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(22),
      I1 => U0_xaui_inst_transmitter_txc_pipe(2),
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_704,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_6_rstpot_1266
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_1_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(17),
      I1 => U0_xaui_inst_transmitter_txc_pipe(2),
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_704,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_1_rstpot_1271
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_6_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(14),
      I1 => U0_xaui_inst_transmitter_txc_pipe(1),
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_706,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_6_rstpot_1274
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_1_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(9),
      I1 => U0_xaui_inst_transmitter_txc_pipe(1),
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_706,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_1_rstpot_1279
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_6_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(6),
      I1 => U0_xaui_inst_transmitter_txc_pipe(0),
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_708,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_6_rstpot_1282
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_1_rstpot : LUT4
    generic map(
      INIT => X"00EA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(1),
      I1 => U0_xaui_inst_transmitter_txc_pipe(0),
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_708,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_1_rstpot_1287
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_26_SW0 : LUT6
    generic map(
      INIT => X"3377FFFF0337CF3F"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      O => N146
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_26_SW1 : LUT6
    generic map(
      INIT => X"0FF5FFFF0335C33D"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      O => N147
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_26 : LUT5
    generic map(
      INIT => X"00400141"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_last_995,
      I2 => U0_xaui_inst_signal_detect_int(3),
      I3 => N147,
      I4 => N146,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_26_SW0 : LUT6
    generic map(
      INIT => X"3377FFFF0337CF3F"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_2_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q,
      O => N149
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_26_SW1 : LUT6
    generic map(
      INIT => X"0FF5FFFF0335C33D"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_2_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q,
      O => N150
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_26 : LUT5
    generic map(
      INIT => X"00400141"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_last_1017,
      I2 => U0_xaui_inst_signal_detect_int(2),
      I3 => N150,
      I4 => N149,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_26_SW0 : LUT6
    generic map(
      INIT => X"3377FFFF0337CF3F"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_2_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q,
      O => N152
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_26_SW1 : LUT6
    generic map(
      INIT => X"0FF5FFFF0335C33D"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_2_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q,
      O => N153
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_26 : LUT5
    generic map(
      INIT => X"00400141"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_last_1039,
      I2 => U0_xaui_inst_signal_detect_int(1),
      I3 => N153,
      I4 => N152,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_26_SW0 : LUT6
    generic map(
      INIT => X"3377FFFF0337CF3F"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_2_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q,
      O => N155
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_26_SW1 : LUT6
    generic map(
      INIT => X"0FF5FFFF0335C33D"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_2_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q,
      O => N156
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_26 : LUT5
    generic map(
      INIT => X"00400141"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_0_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_last_1061,
      I2 => U0_xaui_inst_signal_detect_int(0),
      I3 => N156,
      I4 => N155,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT31_SW0 : LUT4
    generic map(
      INIT => X"AF48"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N170
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT31_SW1 : LUT5
    generic map(
      INIT => X"FF3307CF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N171
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT32 : LUT5
    generic map(
      INIT => X"02002220"
    )
    port map (
      I0 => mgt_rxlock(3),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_0_Q,
      I3 => N170,
      I4 => N171,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_2_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT31_SW0 : LUT4
    generic map(
      INIT => X"AF48"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N173
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT31_SW1 : LUT5
    generic map(
      INIT => X"FF3307CF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N174
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT32 : LUT5
    generic map(
      INIT => X"02002220"
    )
    port map (
      I0 => mgt_rxlock(2),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_0_Q,
      I3 => N173,
      I4 => N174,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_2_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT31_SW0 : LUT4
    generic map(
      INIT => X"AF48"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N176
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT31_SW1 : LUT5
    generic map(
      INIT => X"FF3307CF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N177
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT32 : LUT5
    generic map(
      INIT => X"02002220"
    )
    port map (
      I0 => mgt_rxlock(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_0_Q,
      I3 => N176,
      I4 => N177,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_2_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT31_SW0 : LUT4
    generic map(
      INIT => X"AF48"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N179
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT31_SW1 : LUT5
    generic map(
      INIT => X"FF3307CF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N180
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT32 : LUT5
    generic map(
      INIT => X"02002220"
    )
    port map (
      I0 => mgt_rxlock(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_0_Q,
      I3 => N179,
      I4 => N180,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_2_Q
    );
  U0_xaui_inst_transmitter_is_terminate_0_8_SW1 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(31),
      I1 => U0_xaui_inst_transmitter_txd_pipe(30),
      I2 => U0_xaui_inst_transmitter_txd_pipe(29),
      I3 => U0_xaui_inst_transmitter_txd_pipe(28),
      O => N195
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027 : LUT6
    generic map(
      INIT => X"1111111111110030"
    )
    port map (
      I0 => N195,
      I1 => N138,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N194,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I5 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_702
    );
  U0_xaui_inst_transmitter_is_terminate_0_8_SW3 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(23),
      I1 => U0_xaui_inst_transmitter_txd_pipe(22),
      I2 => U0_xaui_inst_transmitter_txd_pipe(21),
      I3 => U0_xaui_inst_transmitter_txd_pipe(20),
      O => N198
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027 : LUT6
    generic map(
      INIT => X"1111111111110030"
    )
    port map (
      I0 => N198,
      I1 => N140,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N197,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_61,
      I5 => U0_xaui_inst_transmitter_is_terminate_0_41,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_704
    );
  U0_xaui_inst_transmitter_is_terminate_0_8_SW5 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(15),
      I1 => U0_xaui_inst_transmitter_txd_pipe(14),
      I2 => U0_xaui_inst_transmitter_txd_pipe(13),
      I3 => U0_xaui_inst_transmitter_txd_pipe(12),
      O => N201
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027 : LUT6
    generic map(
      INIT => X"1111111111110030"
    )
    port map (
      I0 => N201,
      I1 => N142,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N200,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_61,
      I5 => U0_xaui_inst_transmitter_is_terminate_0_41,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_706
    );
  U0_xaui_inst_transmitter_is_terminate_0_8_SW7 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(7),
      I1 => U0_xaui_inst_transmitter_txd_pipe(6),
      I2 => U0_xaui_inst_transmitter_txd_pipe(5),
      I3 => U0_xaui_inst_transmitter_txd_pipe(4),
      O => N204
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027 : LUT6
    generic map(
      INIT => X"1111111111110030"
    )
    port map (
      I0 => N204,
      I1 => N144,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N203,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_61,
      I5 => U0_xaui_inst_transmitter_is_terminate_0_41,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_708
    );
  U0_xaui_inst_transmitter_is_terminate_1_8_SW1 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(63),
      I1 => U0_xaui_inst_transmitter_txd_pipe(62),
      I2 => U0_xaui_inst_transmitter_txd_pipe(61),
      I3 => U0_xaui_inst_transmitter_txd_pipe(60),
      O => N207
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027 : LUT6
    generic map(
      INIT => X"1111111111110030"
    )
    port map (
      I0 => N207,
      I1 => N130,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N206,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I5 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_694
    );
  U0_xaui_inst_transmitter_is_terminate_1_8_SW3 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(55),
      I1 => U0_xaui_inst_transmitter_txd_pipe(54),
      I2 => U0_xaui_inst_transmitter_txd_pipe(53),
      I3 => U0_xaui_inst_transmitter_txd_pipe(52),
      O => N210
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027 : LUT6
    generic map(
      INIT => X"1111111111110030"
    )
    port map (
      I0 => N210,
      I1 => N132,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N209,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_61,
      I5 => U0_xaui_inst_transmitter_is_terminate_1_41,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_696
    );
  U0_xaui_inst_transmitter_is_terminate_1_8_SW5 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(47),
      I1 => U0_xaui_inst_transmitter_txd_pipe(46),
      I2 => U0_xaui_inst_transmitter_txd_pipe(45),
      I3 => U0_xaui_inst_transmitter_txd_pipe(44),
      O => N213
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027 : LUT6
    generic map(
      INIT => X"1111111111110030"
    )
    port map (
      I0 => N213,
      I1 => N134,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N212,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_61,
      I5 => U0_xaui_inst_transmitter_is_terminate_1_41,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_698
    );
  U0_xaui_inst_transmitter_is_terminate_1_8_SW7 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(39),
      I1 => U0_xaui_inst_transmitter_txd_pipe(38),
      I2 => U0_xaui_inst_transmitter_txd_pipe(37),
      I3 => U0_xaui_inst_transmitter_txd_pipe(36),
      O => N216
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027 : LUT6
    generic map(
      INIT => X"1111111111110030"
    )
    port map (
      I0 => N216,
      I1 => N136,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N215,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_61,
      I5 => U0_xaui_inst_transmitter_is_terminate_1_41,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_700
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW0 : LUT6
    generic map(
      INIT => X"CCFFFF33FF8833A0"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_signal_detect_int(3),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N218
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14 : LUT6
    generic map(
      INIT => X"808A8A8A808A8080"
    )
    port map (
      I0 => mgt_rxlock(3),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I3 => N219,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_0_Q,
      I5 => N218,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW0 : LUT6
    generic map(
      INIT => X"CCFFFF33FF8833A0"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_signal_detect_int(2),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N221
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14 : LUT6
    generic map(
      INIT => X"808A8A8A808A8080"
    )
    port map (
      I0 => mgt_rxlock(2),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I3 => N222,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_0_Q,
      I5 => N221,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW0 : LUT6
    generic map(
      INIT => X"CCFFFF33FF8833A0"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_signal_detect_int(1),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N224
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14 : LUT6
    generic map(
      INIT => X"808A8A8A808A8080"
    )
    port map (
      I0 => mgt_rxlock(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I3 => N225,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_0_Q,
      I5 => N224,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_0_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW0 : LUT6
    generic map(
      INIT => X"CCFFFF33FF8833A0"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_signal_detect_int(0),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N227
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14 : LUT6
    generic map(
      INIT => X"808A8A8A808A8080"
    )
    port map (
      I0 => mgt_rxlock(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I3 => N228,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_0_Q,
      I5 => N227,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_0_Q
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_8_GND_19_o_MUX_231_o11 : LUT5
    generic map(
      INIT => X"00000032"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(8),
      I1 => U0_xaui_inst_receiver_recoder_code_error_delay_1_891,
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_104_o_755,
      I3 => U0_xaui_inst_receiver_recoder_error_lane_1_1_Q,
      I4 => U0_xaui_inst_receiver_recoder_error_lane_1_1_2_1147,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_8_GND_19_o_MUX_231_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_10_PWR_20_o_MUX_229_o11 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(10),
      I1 => U0_xaui_inst_receiver_recoder_code_error_delay_1_891,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_1_1_Q,
      I3 => U0_xaui_inst_receiver_recoder_error_lane_1_1_2_1147,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_10_PWR_20_o_MUX_229_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxc_half_pipe_1_PWR_20_o_MUX_233_o11 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxc_half_pipe(1),
      I1 => U0_xaui_inst_receiver_recoder_code_error_delay_1_891,
      I2 => U0_xaui_inst_receiver_recoder_error_lane_1_1_Q,
      I3 => U0_xaui_inst_receiver_recoder_error_lane_1_1_2_1147,
      O => U0_xaui_inst_receiver_recoder_rxc_half_pipe_1_PWR_20_o_MUX_233_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_9_PWR_20_o_MUX_230_o11 : LUT5
    generic map(
      INIT => X"FFFFFFFE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(9),
      I1 => U0_xaui_inst_receiver_recoder_code_error_delay_1_891,
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_104_o_755,
      I3 => U0_xaui_inst_receiver_recoder_error_lane_1_1_Q,
      I4 => U0_xaui_inst_receiver_recoder_error_lane_1_1_2_1147,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_9_PWR_20_o_MUX_230_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_11_PWR_20_o_MUX_228_o11 : LUT5
    generic map(
      INIT => X"FFFFFFCE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(11),
      I1 => U0_xaui_inst_receiver_recoder_code_error_delay_1_891,
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_104_o_755,
      I3 => U0_xaui_inst_receiver_recoder_error_lane_1_1_Q,
      I4 => U0_xaui_inst_receiver_recoder_error_lane_1_1_2_1147,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_11_PWR_20_o_MUX_228_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_12_PWR_20_o_MUX_227_o11 : LUT5
    generic map(
      INIT => X"FFFFFFCE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(12),
      I1 => U0_xaui_inst_receiver_recoder_code_error_delay_1_891,
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_104_o_755,
      I3 => U0_xaui_inst_receiver_recoder_error_lane_1_1_Q,
      I4 => U0_xaui_inst_receiver_recoder_error_lane_1_1_2_1147,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_12_PWR_20_o_MUX_227_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_13_PWR_20_o_MUX_226_o11 : LUT5
    generic map(
      INIT => X"FFFFFFCE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(13),
      I1 => U0_xaui_inst_receiver_recoder_code_error_delay_1_891,
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_104_o_755,
      I3 => U0_xaui_inst_receiver_recoder_error_lane_1_1_Q,
      I4 => U0_xaui_inst_receiver_recoder_error_lane_1_1_2_1147,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_13_PWR_20_o_MUX_226_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_14_PWR_20_o_MUX_225_o11 : LUT5
    generic map(
      INIT => X"FFFFFFCE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(14),
      I1 => U0_xaui_inst_receiver_recoder_code_error_delay_1_891,
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_104_o_755,
      I3 => U0_xaui_inst_receiver_recoder_error_lane_1_1_Q,
      I4 => U0_xaui_inst_receiver_recoder_error_lane_1_1_2_1147,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_14_PWR_20_o_MUX_225_o
    );
  U0_xaui_inst_receiver_recoder_Mmux_rxd_half_pipe_15_PWR_20_o_MUX_224_o11 : LUT5
    generic map(
      INIT => X"FFFFFFCE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_half_pipe(15),
      I1 => U0_xaui_inst_receiver_recoder_code_error_delay_1_891,
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_104_o_755,
      I3 => U0_xaui_inst_receiver_recoder_error_lane_1_1_Q,
      I4 => U0_xaui_inst_receiver_recoder_error_lane_1_1_2_1147,
      O => U0_xaui_inst_receiver_recoder_rxd_half_pipe_15_PWR_20_o_MUX_224_o
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT29111 : LUT6
    generic map(
      INIT => X"22F22222FFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => configuration_vector(4),
      I3 => configuration_vector(5),
      I4 => configuration_vector(6),
      I5 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      O => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT2911
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT1311 : LUT6
    generic map(
      INIT => X"22F22222FFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => configuration_vector(4),
      I3 => configuration_vector(5),
      I4 => configuration_vector(6),
      I5 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      O => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT5_SW0_SW0 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q,
      I1 => mgt_rxlock(3),
      O => N232
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT5_SW0 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFFF6"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_last_995,
      I1 => U0_xaui_inst_signal_detect_int(3),
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      I3 => N232,
      I4 => N86,
      I5 => N88,
      O => N90
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT5_SW0_SW0 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q,
      I1 => mgt_rxlock(2),
      O => N234
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT5_SW0 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFFF6"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_last_1017,
      I1 => U0_xaui_inst_signal_detect_int(2),
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q,
      I3 => N234,
      I4 => N98,
      I5 => N100,
      O => N102
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT5_SW0_SW0 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q,
      I1 => mgt_rxlock(1),
      O => N236
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT5_SW0 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFFF6"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_last_1039,
      I1 => U0_xaui_inst_signal_detect_int(1),
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q,
      I3 => N236,
      I4 => N110,
      I5 => N112,
      O => N114
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT5_SW0_SW0 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q,
      I1 => mgt_rxlock(0),
      O => N238
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT5_SW0 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFFF6"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_last_1061,
      I1 => U0_xaui_inst_signal_detect_int(0),
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q,
      I3 => N238,
      I4 => N122,
      I5 => N124,
      O => N126
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_4_1_SW1 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q,
      O => N240
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT2_SW0 : LUT6
    generic map(
      INIT => X"77F7777777777777"
    )
    port map (
      I0 => mgt_rxlock(3),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      I4 => N240,
      I5 => N84,
      O => N82
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_4_1_SW1 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_2_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q,
      O => N242
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT2_SW0 : LUT6
    generic map(
      INIT => X"77F7777777777777"
    )
    port map (
      I0 => mgt_rxlock(2),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q,
      I4 => N242,
      I5 => N96,
      O => N94
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_4_1_SW1 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_2_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q,
      O => N244
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT2_SW0 : LUT6
    generic map(
      INIT => X"77F7777777777777"
    )
    port map (
      I0 => mgt_rxlock(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q,
      I4 => N244,
      I5 => N108,
      O => N106
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_4_1_SW1 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_2_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q,
      O => N246
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT2_SW0 : LUT6
    generic map(
      INIT => X"77F7777777777777"
    )
    port map (
      I0 => mgt_rxlock(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q,
      I4 => N246,
      I5 => N120,
      O => N118
    );
  U0_xaui_inst_receiver_recoder_error_lane_0_0_1_SW0 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_lane_term_pipe(3),
      I1 => U0_xaui_inst_receiver_recoder_lane_term_pipe(2),
      I2 => U0_xaui_inst_receiver_recoder_lane_term_pipe(1),
      O => N248
    );
  U0_xaui_inst_receiver_recoder_error_lane_0_0_1_SW1 : LUT6
    generic map(
      INIT => X"FCCFFCCFFCCFA88A"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_lane_term_pipe(3),
      I1 => U0_xaui_inst_receiver_recoder_code_error_pipe(0),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(7),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(6),
      I4 => U0_xaui_inst_receiver_recoder_lane_term_pipe(2),
      I5 => U0_xaui_inst_receiver_recoder_lane_term_pipe(1),
      O => N249
    );
  U0_xaui_inst_receiver_recoder_error_lane_0_0_2 : LUT6
    generic map(
      INIT => X"BBBAABAABBAABBAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_code_error_delay_0_890,
      I1 => U0_xaui_inst_receiver_recoder_lane_term_pipe(0),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(5),
      I3 => N248,
      I4 => N249,
      I5 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_OR_110_o1,
      O => U0_xaui_inst_receiver_recoder_error_lane_0_Q
    );
  U0_xaui_inst_receiver_recoder_error_lane_4_4_2_SW0 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_lane_terminate(3),
      I1 => U0_xaui_inst_receiver_recoder_lane_terminate(2),
      I2 => U0_xaui_inst_receiver_recoder_lane_terminate(1),
      O => N251
    );
  U0_xaui_inst_receiver_recoder_error_lane_4_4_2_SW1 : LUT6
    generic map(
      INIT => X"3FFF3FFF3FFF2AAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_lane_terminate(3),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(35),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(34),
      I3 => U0_xaui_inst_receiver_recoder_rxc_pipe(4),
      I4 => U0_xaui_inst_receiver_recoder_lane_terminate(2),
      I5 => U0_xaui_inst_receiver_recoder_lane_terminate(1),
      O => N252
    );
  U0_xaui_inst_receiver_recoder_error_lane_4_4_3 : LUT6
    generic map(
      INIT => X"AFAAAFAEAFAAABAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_code_error_pipe(0),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(36),
      I2 => U0_xaui_inst_receiver_recoder_lane_terminate(0),
      I3 => N251,
      I4 => U0_xaui_inst_receiver_recoder_error_lane_4_4_Q,
      I5 => N252,
      O => U0_xaui_inst_receiver_recoder_error_lane_4_Q
    );
  U0_xaui_inst_receiver_recoder_error_lane_5_5_2_SW0 : LUT4
    generic map(
      INIT => X"F7FF"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(42),
      I1 => U0_xaui_inst_receiver_recoder_rxc_pipe(5),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(46),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(47),
      O => N254
    );
  U0_xaui_inst_receiver_recoder_error_lane_5_5_2_SW1 : LUT4
    generic map(
      INIT => X"F77F"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(42),
      I1 => U0_xaui_inst_receiver_recoder_rxc_pipe(5),
      I2 => U0_xaui_inst_receiver_recoder_rxd_pipe(47),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(46),
      O => N255
    );
  U0_xaui_inst_receiver_recoder_error_lane_5_5_3 : LUT6
    generic map(
      INIT => X"FFFFEEEEFEBAEEAA"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_code_error_pipe(1),
      I1 => U0_xaui_inst_receiver_recoder_lane_terminate(4),
      I2 => N255,
      I3 => N254,
      I4 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_mux_97_OUT(1),
      I5 => U0_xaui_inst_receiver_recoder_error_lane_5_5_Q,
      O => U0_xaui_inst_receiver_recoder_error_lane_5_Q
    );
  U0_xaui_inst_receiver_recoder_error_lane_6_6_1_SW0 : LUT5
    generic map(
      INIT => X"FEAAFEFE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_code_error_pipe(2),
      I1 => U0_xaui_inst_receiver_recoder_lane_terminate(5),
      I2 => U0_xaui_inst_receiver_recoder_lane_terminate(4),
      I3 => U0_xaui_inst_receiver_recoder_rxd_pipe(54),
      I4 => U0_xaui_inst_receiver_recoder_rxd_pipe(55),
      O => N257
    );
  U0_xaui_inst_receiver_recoder_error_lane_6_6_1_SW1 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_lane_terminate(5),
      I1 => U0_xaui_inst_receiver_recoder_lane_terminate(4),
      I2 => U0_xaui_inst_receiver_recoder_code_error_pipe(2),
      O => N258
    );
  U0_xaui_inst_receiver_recoder_error_lane_6_6_1_SW2 : LUT5
    generic map(
      INIT => X"FFFFDDD9"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_rxd_pipe(55),
      I1 => U0_xaui_inst_receiver_recoder_rxd_pipe(54),
      I2 => U0_xaui_inst_receiver_recoder_lane_terminate(5),
      I3 => U0_xaui_inst_receiver_recoder_lane_terminate(4),
      I4 => U0_xaui_inst_receiver_recoder_code_error_pipe(2),
      O => N259
    );
  U0_xaui_inst_receiver_recoder_error_lane_6_6_4 : LUT6
    generic map(
      INIT => X"FCFCFDADFCFCF8A8"
    )
    port map (
      I0 => U0_xaui_inst_receiver_recoder_error_lane_6_6_2_1150,
      I1 => N258,
      I2 => U0_xaui_inst_receiver_recoder_GND_19_o_GND_19_o_mux_97_OUT(2),
      I3 => N259,
      I4 => U0_xaui_inst_receiver_recoder_error_lane_6_6_1,
      I5 => N257,
      O => U0_xaui_inst_receiver_recoder_error_lane_6_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_SW0 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(39),
      I1 => N136,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N215,
      O => N261
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_7_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(4),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o,
      I2 => N262,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N261,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_7_rstpot_1249
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_SW2 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(37),
      I1 => N136,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N215,
      O => N264
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_5_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(4),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o,
      I2 => N265,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N264,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_5_rstpot_1251
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_SW7 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(35),
      I1 => N136,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N215,
      O => N271
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_3_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(4),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o,
      I2 => N272,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N271,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_3_rstpot_1253
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_SW9 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(34),
      I1 => N136,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N215,
      O => N274
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_2_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(4),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o,
      I2 => N275,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N274,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_2_rstpot_1254
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_SW11 : LUT4
    generic map(
      INIT => X"5575"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(32),
      I1 => N136,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N215,
      O => N277
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_0_rstpot : LUT6
    generic map(
      INIT => X"131313001313135F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(4),
      I1 => N278,
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N277,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_0_rstpot_1256
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_SW0 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(47),
      I1 => N134,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N212,
      O => N280
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_7_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(5),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o,
      I2 => N281,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N280,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_7_rstpot_1241
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_SW2 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(45),
      I1 => N134,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N212,
      O => N283
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_5_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(5),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o,
      I2 => N284,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N283,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_5_rstpot_1243
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_SW7 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(43),
      I1 => N134,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N212,
      O => N290
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_3_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(5),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o,
      I2 => N291,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N290,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_3_rstpot_1245
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_SW9 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(42),
      I1 => N134,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N212,
      O => N293
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_2_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(5),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o,
      I2 => N294,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N293,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_2_rstpot_1246
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_SW11 : LUT4
    generic map(
      INIT => X"5575"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(40),
      I1 => N134,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N212,
      O => N296
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_0_rstpot : LUT6
    generic map(
      INIT => X"131313001313135F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(5),
      I1 => N297,
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N296,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_0_rstpot_1248
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_SW0 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(55),
      I1 => N132,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N209,
      O => N299
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_7_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(6),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o,
      I2 => N300,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N299,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_7_rstpot_1233
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_SW2 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(53),
      I1 => N132,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N209,
      O => N302
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_5_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(6),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o,
      I2 => N303,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N302,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_5_rstpot_1235
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_SW7 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(51),
      I1 => N132,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N209,
      O => N309
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_3_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(6),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o,
      I2 => N310,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N309,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_3_rstpot_1237
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_SW9 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(50),
      I1 => N132,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N209,
      O => N312
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_2_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(6),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o,
      I2 => N313,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N312,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_2_rstpot_1238
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_SW11 : LUT4
    generic map(
      INIT => X"5575"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(48),
      I1 => N132,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N209,
      O => N315
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_0_rstpot : LUT6
    generic map(
      INIT => X"131313001313135F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(6),
      I1 => N316,
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N315,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_0_rstpot_1240
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_SW0 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(63),
      I1 => N130,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N206,
      O => N318
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_7_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(7),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o,
      I2 => N319,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N318,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_7_rstpot_1225
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_SW2 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(61),
      I1 => N130,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N206,
      O => N321
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_5_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(7),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o,
      I2 => N322,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N321,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_5_rstpot_1227
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_SW7 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(59),
      I1 => N130,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N206,
      O => N328
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_3_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(7),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o,
      I2 => N329,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N328,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_3_rstpot_1229
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_SW9 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(58),
      I1 => N130,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N206,
      O => N331
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_2_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(7),
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o,
      I2 => N332,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N331,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_2_rstpot_1230
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_SW11 : LUT4
    generic map(
      INIT => X"5575"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(56),
      I1 => N130,
      I2 => U0_xaui_inst_transmitter_is_terminate_1_7_1088,
      I3 => N206,
      O => N334
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_0_rstpot : LUT6
    generic map(
      INIT => X"131313001313135F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(7),
      I1 => N335,
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_is_terminate_1_6_1087,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_4_1085,
      I5 => N334,
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_0_rstpot_1232
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_SW0 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(7),
      I1 => N144,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N203,
      O => N337
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_7_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(0),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o,
      I2 => N338,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N337,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_7_rstpot_1281
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_SW2 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(5),
      I1 => N144,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N203,
      O => N340
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_5_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(0),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o,
      I2 => N341,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N340,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_5_rstpot_1283
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_SW7 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(3),
      I1 => N144,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N203,
      O => N347
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_3_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(0),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o,
      I2 => N348,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N347,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_3_rstpot_1285
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_SW9 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(2),
      I1 => N144,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N203,
      O => N350
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_2_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(0),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o,
      I2 => N351,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N350,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_2_rstpot_1286
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_SW11 : LUT4
    generic map(
      INIT => X"5575"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(0),
      I1 => N144,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N203,
      O => N353
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_0_rstpot : LUT6
    generic map(
      INIT => X"131313001313135F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(0),
      I1 => N354,
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N353,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_0_rstpot_1288
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_SW0 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(15),
      I1 => N142,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N200,
      O => N356
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_7_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(1),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o,
      I2 => N357,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N356,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_7_rstpot_1273
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_SW2 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(13),
      I1 => N142,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N200,
      O => N359
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_5_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(1),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o,
      I2 => N360,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N359,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_5_rstpot_1275
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_SW7 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(11),
      I1 => N142,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N200,
      O => N366
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_3_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(1),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o,
      I2 => N367,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N366,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_3_rstpot_1277
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_SW9 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(10),
      I1 => N142,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N200,
      O => N369
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_2_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(1),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o,
      I2 => N370,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N369,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_2_rstpot_1278
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_SW11 : LUT4
    generic map(
      INIT => X"5575"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(8),
      I1 => N142,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N200,
      O => N372
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_0_rstpot : LUT6
    generic map(
      INIT => X"131313001313135F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(1),
      I1 => N373,
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N372,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_0_rstpot_1280
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_SW0 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(23),
      I1 => N140,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N197,
      O => N375
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_7_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(2),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o,
      I2 => N376,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N375,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_7_rstpot_1265
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_SW2 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(21),
      I1 => N140,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N197,
      O => N378
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_5_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(2),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o,
      I2 => N379,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N378,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_5_rstpot_1267
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_SW7 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(19),
      I1 => N140,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N197,
      O => N385
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_3_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(2),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o,
      I2 => N386,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N385,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_3_rstpot_1269
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_SW9 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(18),
      I1 => N140,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N197,
      O => N388
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_2_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(2),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o,
      I2 => N389,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N388,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_2_rstpot_1270
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_SW11 : LUT4
    generic map(
      INIT => X"5575"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(16),
      I1 => N140,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N197,
      O => N391
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_0_rstpot : LUT6
    generic map(
      INIT => X"131313001313135F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(2),
      I1 => N392,
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N391,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_0_rstpot_1272
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_SW0 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(31),
      I1 => N138,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N194,
      O => N394
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_7_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(3),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o,
      I2 => N395,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N394,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_7_rstpot_1257
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_SW2 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(29),
      I1 => N138,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N194,
      O => N397
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_5_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(3),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o,
      I2 => N398,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N397,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_5_rstpot_1259
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_SW7 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(27),
      I1 => N138,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N194,
      O => N404
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_3_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(3),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o,
      I2 => N405,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N404,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_3_rstpot_1261
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_SW9 : LUT4
    generic map(
      INIT => X"AABA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(26),
      I1 => N138,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N194,
      O => N407
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_2_rstpot : LUT6
    generic map(
      INIT => X"F8F8F8FFF8F8F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(3),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o,
      I2 => N408,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N407,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_2_rstpot_1262
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_SW11 : LUT4
    generic map(
      INIT => X"5575"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(24),
      I1 => N138,
      I2 => U0_xaui_inst_transmitter_is_terminate_0_7_1095,
      I3 => N194,
      O => N410
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_0_rstpot : LUT6
    generic map(
      INIT => X"131313001313135F"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(3),
      I1 => N411,
      I2 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_GND_15_o_reduce_nor_14_o,
      I3 => U0_xaui_inst_transmitter_is_terminate_0_6_1094,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_4_1092,
      I5 => N410,
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_0_rstpot_1264
    );
  U0_xaui_inst_transmitter_align_Mmux_a_cnt1_SW2 : LUT4
    generic map(
      INIT => X"5703"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(8),
      I1 => U0_xaui_inst_transmitter_tx_is_idle(0),
      I2 => U0_xaui_inst_transmitter_tx_is_q(0),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      O => N414
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp22 : LUT6
    generic map(
      INIT => X"FFFFCCCDFFFFCCC8"
    )
    port map (
      I0 => N16,
      I1 => N414,
      I2 => U0_xaui_inst_transmitter_tx_code_a(0),
      I3 => U0_xaui_inst_transmitter_tx_code_a(1),
      I4 => U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp2,
      I5 => N413,
      O => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(0)
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT5 : LUT6
    generic map(
      INIT => X"000000000A000800"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23,
      I5 => N90,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_4_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT5 : LUT6
    generic map(
      INIT => X"000000000A000800"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23,
      I5 => N102,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_4_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT5 : LUT6
    generic map(
      INIT => X"000000000A000800"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23,
      I5 => N114,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_4_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT5 : LUT6
    generic map(
      INIT => X"000000000A000800"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_24,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_p_state_comb_state_temp_0_23,
      I5 => N126,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_4_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW1_SW0 : LUT5
    generic map(
      INIT => X"7FDFFFFF"
    )
    port map (
      I0 => mgt_rxlock(3),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_last_995,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q,
      I3 => U0_xaui_inst_signal_detect_int(3),
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      O => N424
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW1_SW1 : LUT5
    generic map(
      INIT => X"80208822"
    )
    port map (
      I0 => mgt_rxlock(3),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_signal_detect_last_995,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_0_Q,
      I3 => U0_xaui_inst_signal_detect_int(3),
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      O => N425
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW1 : LUT6
    generic map(
      INIT => X"BCBCCCBBCCBBFCB8"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => N424,
      I3 => N425,
      I4 => N92,
      I5 => N88,
      O => N219
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW1_SW0 : LUT5
    generic map(
      INIT => X"7FDFFFFF"
    )
    port map (
      I0 => mgt_rxlock(2),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_last_1017,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q,
      I3 => U0_xaui_inst_signal_detect_int(2),
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q,
      O => N427
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW1_SW1 : LUT5
    generic map(
      INIT => X"A00A2002"
    )
    port map (
      I0 => mgt_rxlock(2),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_Q,
      I2 => U0_xaui_inst_signal_detect_int(2),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_signal_detect_last_1017,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_0_Q,
      O => N428
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW1 : LUT6
    generic map(
      INIT => X"BCBCCCBBCCBBFCB8"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => N427,
      I3 => N428,
      I4 => N100,
      I5 => N104,
      O => N222
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW1_SW0 : LUT5
    generic map(
      INIT => X"7FDFFFFF"
    )
    port map (
      I0 => mgt_rxlock(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_last_1039,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q,
      I3 => U0_xaui_inst_signal_detect_int(1),
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q,
      O => N430
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW1_SW1 : LUT5
    generic map(
      INIT => X"A00A2002"
    )
    port map (
      I0 => mgt_rxlock(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_Q,
      I2 => U0_xaui_inst_signal_detect_int(1),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_signal_detect_last_1039,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_0_Q,
      O => N431
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW1 : LUT6
    generic map(
      INIT => X"BCBCCCBBCCBBFCB8"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => N430,
      I3 => N431,
      I4 => N112,
      I5 => N116,
      O => N225
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW1_SW0 : LUT5
    generic map(
      INIT => X"7FDFFFFF"
    )
    port map (
      I0 => mgt_rxlock(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_last_1061,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q,
      I3 => U0_xaui_inst_signal_detect_int(0),
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q,
      O => N433
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW1_SW1 : LUT5
    generic map(
      INIT => X"A00A2002"
    )
    port map (
      I0 => mgt_rxlock(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_Q,
      I2 => U0_xaui_inst_signal_detect_int(0),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_signal_detect_last_1061,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_0_Q,
      O => N434
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT14_SW1 : LUT6
    generic map(
      INIT => X"BCBCCCBBCCBBFCB8"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_comma_pipe_1_Q,
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_1_Q,
      I2 => N433,
      I3 => N434,
      I4 => N124,
      I5 => N128,
      O => N228
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp43_SW0 : LUT6
    generic map(
      INIT => X"FFFFFFFFF1FFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_is_q(1),
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_447,
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I4 => U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp41_1108,
      I5 => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(2),
      O => N436
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_state_1_2_PWR_15_o_wide_mux_20_OUT31 : LUT6
    generic map(
      INIT => X"CACAFFF0CACA0F00"
    )
    port map (
      I0 => N438,
      I1 => N439,
      I2 => U0_xaui_inst_transmitter_a_due(0),
      I3 => N436,
      I4 => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(0),
      I5 => N437,
      O => U0_xaui_inst_transmitter_state_machine_state_1_2_PWR_15_o_wide_mux_20_OUT_2_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv1 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_6_o2_1100,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_6_o1_1099,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_n0024_inv
    );
  U0_xaui_inst_transmitter_is_terminate_0_8_SW0 : MUXF7
    port map (
      I0 => N441,
      I1 => N0,
      S => U0_xaui_inst_transmitter_txd_pipe(31),
      O => N194
    );
  U0_xaui_inst_transmitter_is_terminate_0_8_SW0_F : LUT6
    generic map(
      INIT => X"FFFFFFFDFFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(8),
      I1 => U0_xaui_inst_transmitter_txd_pipe(29),
      I2 => U0_xaui_inst_transmitter_txd_pipe(28),
      I3 => U0_xaui_inst_transmitter_txd_pipe(9),
      I4 => U0_xaui_inst_transmitter_txd_pipe(30),
      I5 => U0_xaui_inst_transmitter_txd_pipe(10),
      O => N441
    );
  U0_xaui_inst_transmitter_is_terminate_0_8_SW2 : MUXF7
    port map (
      I0 => N443,
      I1 => N0,
      S => U0_xaui_inst_transmitter_txd_pipe(23),
      O => N197
    );
  U0_xaui_inst_transmitter_is_terminate_0_8_SW2_F : LUT6
    generic map(
      INIT => X"FFFFFFFDFFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(8),
      I1 => U0_xaui_inst_transmitter_txd_pipe(21),
      I2 => U0_xaui_inst_transmitter_txd_pipe(20),
      I3 => U0_xaui_inst_transmitter_txd_pipe(9),
      I4 => U0_xaui_inst_transmitter_txd_pipe(22),
      I5 => U0_xaui_inst_transmitter_txd_pipe(10),
      O => N443
    );
  U0_xaui_inst_transmitter_is_terminate_0_8_SW4 : MUXF7
    port map (
      I0 => N445,
      I1 => N0,
      S => U0_xaui_inst_transmitter_txd_pipe(15),
      O => N200
    );
  U0_xaui_inst_transmitter_is_terminate_0_8_SW4_F : LUT6
    generic map(
      INIT => X"FFFFFFFDFFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(8),
      I1 => U0_xaui_inst_transmitter_txd_pipe(13),
      I2 => U0_xaui_inst_transmitter_txd_pipe(12),
      I3 => U0_xaui_inst_transmitter_txd_pipe(9),
      I4 => U0_xaui_inst_transmitter_txd_pipe(14),
      I5 => U0_xaui_inst_transmitter_txd_pipe(10),
      O => N445
    );
  U0_xaui_inst_transmitter_is_terminate_0_8_SW6 : MUXF7
    port map (
      I0 => N447,
      I1 => N0,
      S => U0_xaui_inst_transmitter_txd_pipe(7),
      O => N203
    );
  U0_xaui_inst_transmitter_is_terminate_0_8_SW6_F : LUT6
    generic map(
      INIT => X"FFFFFFFDFFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(8),
      I1 => U0_xaui_inst_transmitter_txd_pipe(5),
      I2 => U0_xaui_inst_transmitter_txd_pipe(4),
      I3 => U0_xaui_inst_transmitter_txd_pipe(9),
      I4 => U0_xaui_inst_transmitter_txd_pipe(6),
      I5 => U0_xaui_inst_transmitter_txd_pipe(10),
      O => N447
    );
  U0_xaui_inst_transmitter_is_terminate_1_8_SW0 : MUXF7
    port map (
      I0 => N449,
      I1 => N0,
      S => U0_xaui_inst_transmitter_txd_pipe(63),
      O => N206
    );
  U0_xaui_inst_transmitter_is_terminate_1_8_SW0_F : LUT6
    generic map(
      INIT => X"FFFFFFFDFFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(42),
      I1 => U0_xaui_inst_transmitter_txd_pipe(61),
      I2 => U0_xaui_inst_transmitter_txd_pipe(60),
      I3 => U0_xaui_inst_transmitter_txd_pipe(62),
      I4 => U0_xaui_inst_transmitter_txd_pipe(41),
      I5 => U0_xaui_inst_transmitter_txd_pipe(40),
      O => N449
    );
  U0_xaui_inst_transmitter_is_terminate_1_8_SW2 : MUXF7
    port map (
      I0 => N451,
      I1 => N0,
      S => U0_xaui_inst_transmitter_txd_pipe(55),
      O => N209
    );
  U0_xaui_inst_transmitter_is_terminate_1_8_SW2_F : LUT6
    generic map(
      INIT => X"FFFFFFFDFFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(42),
      I1 => U0_xaui_inst_transmitter_txd_pipe(53),
      I2 => U0_xaui_inst_transmitter_txd_pipe(52),
      I3 => U0_xaui_inst_transmitter_txd_pipe(54),
      I4 => U0_xaui_inst_transmitter_txd_pipe(41),
      I5 => U0_xaui_inst_transmitter_txd_pipe(40),
      O => N451
    );
  U0_xaui_inst_transmitter_is_terminate_1_8_SW4 : MUXF7
    port map (
      I0 => N453,
      I1 => N0,
      S => U0_xaui_inst_transmitter_txd_pipe(47),
      O => N212
    );
  U0_xaui_inst_transmitter_is_terminate_1_8_SW4_F : LUT6
    generic map(
      INIT => X"FFFFFFFDFFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(42),
      I1 => U0_xaui_inst_transmitter_txd_pipe(45),
      I2 => U0_xaui_inst_transmitter_txd_pipe(44),
      I3 => U0_xaui_inst_transmitter_txd_pipe(46),
      I4 => U0_xaui_inst_transmitter_txd_pipe(41),
      I5 => U0_xaui_inst_transmitter_txd_pipe(40),
      O => N453
    );
  U0_xaui_inst_transmitter_is_terminate_1_8_SW6 : MUXF7
    port map (
      I0 => N455,
      I1 => N0,
      S => U0_xaui_inst_transmitter_txd_pipe(39),
      O => N215
    );
  U0_xaui_inst_transmitter_is_terminate_1_8_SW6_F : LUT6
    generic map(
      INIT => X"FFFFFFFDFFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(42),
      I1 => U0_xaui_inst_transmitter_txd_pipe(37),
      I2 => U0_xaui_inst_transmitter_txd_pipe(36),
      I3 => U0_xaui_inst_transmitter_txd_pipe(38),
      I4 => U0_xaui_inst_transmitter_txd_pipe(41),
      I5 => U0_xaui_inst_transmitter_txd_pipe(40),
      O => N455
    );
  U0_xaui_inst_transmitter_align_Mmux_a_cnt1_SW1 : MUXF7
    port map (
      I0 => N457,
      I1 => N458,
      S => U0_xaui_inst_transmitter_state_machine_state_1(2),
      O => N413
    );
  U0_xaui_inst_transmitter_align_Mmux_a_cnt1_SW1_F : LUT2
    generic map(
      INIT => X"1"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_is_q(0),
      I1 => U0_xaui_inst_transmitter_tx_is_idle(0),
      O => N457
    );
  U0_xaui_inst_transmitter_align_Mmux_a_cnt1_SW1_G : LUT6
    generic map(
      INIT => X"004000400040FFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_align_extra_a_659,
      I1 => U0_xaui_inst_transmitter_align_count(1),
      I2 => U0_xaui_inst_transmitter_align_count(0),
      I3 => U0_xaui_inst_transmitter_k_r_prbs_i_prbs(8),
      I4 => U0_xaui_inst_transmitter_tx_is_q(0),
      I5 => U0_xaui_inst_transmitter_tx_is_idle(0),
      O => N458
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp43_SW1 : MUXF7
    port map (
      I0 => N459,
      I1 => N0,
      S => U0_xaui_inst_transmitter_state_machine_p_state_comb_state_temp(2),
      O => N437
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp43_SW1_F : LUT6
    generic map(
      INIT => X"F111FF11F1FFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_is_q(1),
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_447,
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I4 => U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp41_1108,
      I5 => U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp4,
      O => N459
    );
  U0_xaui_inst_tx_local_fault_glue_set : LUT6
    generic map(
      INIT => X"FFFFFFFFFEFFFEFE"
    )
    port map (
      I0 => mgt_tx_reset(1),
      I1 => mgt_tx_reset(2),
      I2 => mgt_tx_reset(0),
      I3 => U0_xaui_inst_clear_local_fault_edge_347,
      I4 => NlwRenamedSig_OI_U0_status_vector_int_0_Q,
      I5 => mgt_tx_reset(3),
      O => U0_xaui_inst_tx_local_fault_glue_set_1201
    );
  U0_xaui_inst_transmitter_state_machine_next_ifg_is_a_glue_rst_SW0 : LUT3
    generic map(
      INIT => X"EF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      O => N461
    );
  U0_xaui_inst_rx_local_fault_glue_set_SW0 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => mgt_rx_reset(2),
      I1 => mgt_rx_reset(3),
      O => N463
    );
  U0_xaui_inst_rx_local_fault_glue_set : LUT6
    generic map(
      INIT => X"FFFFFFF2FFFFFFFF"
    )
    port map (
      I0 => NlwRenamedSig_OI_U0_status_vector_int_1_Q,
      I1 => U0_xaui_inst_clear_local_fault_edge_347,
      I2 => N463,
      I3 => mgt_rx_reset(0),
      I4 => mgt_rx_reset(1),
      I5 => NlwRenamedSig_OI_U0_status_vector_int_6_Q,
      O => U0_xaui_inst_rx_local_fault_glue_set_1200
    );
  U0_xaui_inst_clear_aligned_edge_rstpot : LUT3
    generic map(
      INIT => X"04"
    )
    port map (
      I0 => U0_xaui_inst_p_clear_aligned_edge_last_value_344,
      I1 => U0_xaui_inst_clear_aligned_348,
      I2 => U0_xaui_inst_usrclk_reset_350,
      O => U0_xaui_inst_clear_aligned_edge_rstpot_1212
    );
  U0_xaui_inst_clear_local_fault_edge_rstpot : LUT3
    generic map(
      INIT => X"04"
    )
    port map (
      I0 => U0_xaui_inst_p_clear_local_fault_edge_last_value_346,
      I1 => U0_xaui_inst_clear_local_fault_349,
      I2 => U0_xaui_inst_usrclk_reset_350,
      O => U0_xaui_inst_clear_local_fault_edge_rstpot_1213
    );
  U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync_rstpot : LUT4
    generic map(
      INIT => X"0100"
    )
    port map (
      I0 => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(0),
      I2 => U0_xaui_inst_receiver_G_SYNC_deskew_state_state_1(2),
      I3 => U0_xaui_inst_receiver_sync_status_718,
      O => U0_xaui_inst_receiver_G_SYNC_deskew_state_enchansync_rstpot_1215
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_rstpot : LUT6
    generic map(
      INIT => X"FFFF88F888F888F8"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_6_o1_1099,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_6_o2_1100,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_447,
      I3 => N465,
      I4 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_rstpot_1216
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT28_SW1 : LUT5
    generic map(
      INIT => X"04FF0404"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => configuration_vector(5),
      I4 => configuration_vector(4),
      O => N467
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT28 : LUT6
    generic map(
      INIT => X"FFFFFFFEFEFFFEFE"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_code_k(1),
      I1 => N467,
      I2 => U0_xaui_inst_transmitter_tx_code_a(1),
      I3 => U0_xaui_inst_transmitter_tx_code_q(1),
      I4 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_2_Q,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(7),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_34_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT1231 : LUT5
    generic map(
      INIT => X"8088A0AA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I1 => configuration_vector(5),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I4 => configuration_vector(4),
      O => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT123
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT2611 : LUT6
    generic map(
      INIT => X"80888888A0AAAAAA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => configuration_vector(5),
      I3 => configuration_vector(4),
      I4 => configuration_vector(6),
      I5 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      O => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT261_552
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT3021 : LUT5
    generic map(
      INIT => X"2FFF2F2F"
    )
    port map (
      I0 => configuration_vector(4),
      I1 => configuration_vector(5),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I4 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      O => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT302
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT15111 : LUT5
    generic map(
      INIT => X"FF0F2202"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I2 => configuration_vector(4),
      I3 => configuration_vector(5),
      I4 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      O => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT1511
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT1611 : LUT5
    generic map(
      INIT => X"4141FF41"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => configuration_vector(4),
      I4 => configuration_vector(5),
      O => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT161
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT5111 : LUT5
    generic map(
      INIT => X"6565FF65"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I3 => configuration_vector(4),
      I4 => configuration_vector(5),
      O => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT511
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT3311 : LUT5
    generic map(
      INIT => X"4141FF41"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => configuration_vector(4),
      I4 => configuration_vector(5),
      O => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT331
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT3111 : LUT5
    generic map(
      INIT => X"6565FF65"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I3 => configuration_vector(4),
      I4 => configuration_vector(5),
      O => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT311
    );
  U0_xaui_inst_transmitter_align_n0020_inv1 : LUT4
    generic map(
      INIT => X"22F2"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      O => U0_xaui_inst_transmitter_align_n0020_inv
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT1 : LUT6
    generic map(
      INIT => X"FFFFFFFF02000000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_0_Q,
      I4 => N469,
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_0_Q
    );
  U0_xaui_inst_transmitter_align_mux1111 : LUT6
    generic map(
      INIT => X"77F755F544045505"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_align_count(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I5 => U0_xaui_inst_transmitter_align_prbs(2),
      O => U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_1_Q
    );
  U0_xaui_inst_transmitter_align_mux111 : LUT6
    generic map(
      INIT => X"FFFF4F44B0BB0000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I4 => U0_xaui_inst_transmitter_align_count(0),
      I5 => U0_xaui_inst_transmitter_align_prbs(1),
      O => U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_0_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT28 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_2_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_2_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_10_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT33 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_3_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_3_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_11_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT41 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_4_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_4_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_12_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT51 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_5_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_5_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_13_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT61 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_6_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_6_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_14_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT71 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_7_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_7_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_15_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT81 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_0_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_0_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_16_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT91 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_1_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_1_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_17_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT101 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_2_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_2_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_18_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT111 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_3_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_3_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_19_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT131 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_4_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_4_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_20_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT141 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_5_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_5_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_21_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT151 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_6_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_6_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_22_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT161 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_7_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_7_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_23_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT171 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_0_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_0_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_24_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT181 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_1_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_1_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_25_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT191 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_2_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_2_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_26_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT201 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_3_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_3_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_27_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT211 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_4_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_4_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_28_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT221 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_5_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_5_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_29_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT241 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_6_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_6_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_30_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT251 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_7_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_7_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_31_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT301 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_7_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_7_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_7_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT311 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_0_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_0_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_8_Q
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_Mmux_last_qmsg_31_txd_in_63_mux_5_OUT321 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_1_Q,
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o1_1101,
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_PWR_9_o_GND_9_o_AND_5_o2_1102,
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_1_Q,
      O => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg_31_txd_in_63_mux_5_OUT_9_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT8_SW0 : LUT6
    generic map(
      INIT => X"F7F700F780800080"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(16),
      I3 => configuration_vector(6),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT631,
      I5 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_0_Q,
      O => N4
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT17_SW0 : LUT6
    generic map(
      INIT => X"F7F700F780800080"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(24),
      I3 => configuration_vector(6),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT631,
      I5 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_0_Q,
      O => N6
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT63_SW0 : LUT6
    generic map(
      INIT => X"F7F700F780800080"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I2 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(8),
      I3 => configuration_vector(4),
      I4 => configuration_vector(5),
      I5 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_0_Q,
      O => N10
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_SW1 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(39),
      I1 => U0_xaui_inst_transmitter_txd_pipe(36),
      I2 => U0_xaui_inst_transmitter_txd_pipe(37),
      I3 => U0_xaui_inst_transmitter_txd_pipe(38),
      I4 => N136,
      O => N262
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_SW3 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(37),
      I1 => U0_xaui_inst_transmitter_txd_pipe(36),
      I2 => U0_xaui_inst_transmitter_txd_pipe(38),
      I3 => U0_xaui_inst_transmitter_txd_pipe(39),
      I4 => N136,
      O => N265
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_SW12 : LUT6
    generic map(
      INIT => X"555555555555D555"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(32),
      I1 => U0_xaui_inst_transmitter_txd_pipe(34),
      I2 => U0_xaui_inst_transmitter_txd_pipe(33),
      I3 => U0_xaui_inst_transmitter_txc_pipe(4),
      I4 => U0_xaui_inst_transmitter_txd_pipe(35),
      I5 => N216,
      O => N278
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_SW1 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(47),
      I1 => U0_xaui_inst_transmitter_txd_pipe(44),
      I2 => U0_xaui_inst_transmitter_txd_pipe(45),
      I3 => U0_xaui_inst_transmitter_txd_pipe(46),
      I4 => N134,
      O => N281
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_SW3 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(45),
      I1 => U0_xaui_inst_transmitter_txd_pipe(44),
      I2 => U0_xaui_inst_transmitter_txd_pipe(46),
      I3 => U0_xaui_inst_transmitter_txd_pipe(47),
      I4 => N134,
      O => N284
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_SW12 : LUT6
    generic map(
      INIT => X"555555555555D555"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(40),
      I1 => U0_xaui_inst_transmitter_txd_pipe(42),
      I2 => U0_xaui_inst_transmitter_txd_pipe(41),
      I3 => U0_xaui_inst_transmitter_txc_pipe(5),
      I4 => U0_xaui_inst_transmitter_txd_pipe(43),
      I5 => N213,
      O => N297
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_SW1 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(55),
      I1 => U0_xaui_inst_transmitter_txd_pipe(52),
      I2 => U0_xaui_inst_transmitter_txd_pipe(53),
      I3 => U0_xaui_inst_transmitter_txd_pipe(54),
      I4 => N132,
      O => N300
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_SW3 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(53),
      I1 => U0_xaui_inst_transmitter_txd_pipe(52),
      I2 => U0_xaui_inst_transmitter_txd_pipe(54),
      I3 => U0_xaui_inst_transmitter_txd_pipe(55),
      I4 => N132,
      O => N303
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_SW12 : LUT6
    generic map(
      INIT => X"555555555555D555"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(48),
      I1 => U0_xaui_inst_transmitter_txd_pipe(49),
      I2 => U0_xaui_inst_transmitter_txd_pipe(50),
      I3 => U0_xaui_inst_transmitter_txc_pipe(6),
      I4 => U0_xaui_inst_transmitter_txd_pipe(51),
      I5 => N210,
      O => N316
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_SW1 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(63),
      I1 => U0_xaui_inst_transmitter_txd_pipe(60),
      I2 => U0_xaui_inst_transmitter_txd_pipe(61),
      I3 => U0_xaui_inst_transmitter_txd_pipe(62),
      I4 => N130,
      O => N319
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_SW3 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(61),
      I1 => U0_xaui_inst_transmitter_txd_pipe(60),
      I2 => U0_xaui_inst_transmitter_txd_pipe(62),
      I3 => U0_xaui_inst_transmitter_txd_pipe(63),
      I4 => N130,
      O => N322
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_SW12 : LUT6
    generic map(
      INIT => X"555555555555D555"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(56),
      I1 => U0_xaui_inst_transmitter_txd_pipe(58),
      I2 => U0_xaui_inst_transmitter_txd_pipe(57),
      I3 => U0_xaui_inst_transmitter_txc_pipe(7),
      I4 => U0_xaui_inst_transmitter_txd_pipe(59),
      I5 => N207,
      O => N335
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_SW1 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(7),
      I1 => U0_xaui_inst_transmitter_txd_pipe(4),
      I2 => U0_xaui_inst_transmitter_txd_pipe(5),
      I3 => U0_xaui_inst_transmitter_txd_pipe(6),
      I4 => N144,
      O => N338
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_SW3 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(5),
      I1 => U0_xaui_inst_transmitter_txd_pipe(4),
      I2 => U0_xaui_inst_transmitter_txd_pipe(6),
      I3 => U0_xaui_inst_transmitter_txd_pipe(7),
      I4 => N144,
      O => N341
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_SW12 : LUT6
    generic map(
      INIT => X"555555555555D555"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(0),
      I1 => U0_xaui_inst_transmitter_txd_pipe(2),
      I2 => U0_xaui_inst_transmitter_txd_pipe(1),
      I3 => U0_xaui_inst_transmitter_txc_pipe(0),
      I4 => U0_xaui_inst_transmitter_txd_pipe(3),
      I5 => N204,
      O => N354
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_SW1 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(15),
      I1 => U0_xaui_inst_transmitter_txd_pipe(12),
      I2 => U0_xaui_inst_transmitter_txd_pipe(13),
      I3 => U0_xaui_inst_transmitter_txd_pipe(14),
      I4 => N142,
      O => N357
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_SW3 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(13),
      I1 => U0_xaui_inst_transmitter_txd_pipe(12),
      I2 => U0_xaui_inst_transmitter_txd_pipe(14),
      I3 => U0_xaui_inst_transmitter_txd_pipe(15),
      I4 => N142,
      O => N360
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_SW12 : LUT6
    generic map(
      INIT => X"555555555555D555"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(8),
      I1 => U0_xaui_inst_transmitter_txd_pipe(9),
      I2 => U0_xaui_inst_transmitter_txc_pipe(1),
      I3 => U0_xaui_inst_transmitter_txd_pipe(10),
      I4 => U0_xaui_inst_transmitter_txd_pipe(11),
      I5 => N201,
      O => N373
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_SW1 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(23),
      I1 => U0_xaui_inst_transmitter_txd_pipe(20),
      I2 => U0_xaui_inst_transmitter_txd_pipe(21),
      I3 => U0_xaui_inst_transmitter_txd_pipe(22),
      I4 => N140,
      O => N376
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_SW3 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(21),
      I1 => U0_xaui_inst_transmitter_txd_pipe(20),
      I2 => U0_xaui_inst_transmitter_txd_pipe(22),
      I3 => U0_xaui_inst_transmitter_txd_pipe(23),
      I4 => N140,
      O => N379
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_SW12 : LUT6
    generic map(
      INIT => X"555555555555D555"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(16),
      I1 => U0_xaui_inst_transmitter_txd_pipe(17),
      I2 => U0_xaui_inst_transmitter_txd_pipe(18),
      I3 => U0_xaui_inst_transmitter_txc_pipe(2),
      I4 => U0_xaui_inst_transmitter_txd_pipe(19),
      I5 => N198,
      O => N392
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_SW1 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(31),
      I1 => U0_xaui_inst_transmitter_txd_pipe(28),
      I2 => U0_xaui_inst_transmitter_txd_pipe(29),
      I3 => U0_xaui_inst_transmitter_txd_pipe(30),
      I4 => N138,
      O => N395
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_SW3 : LUT5
    generic map(
      INIT => X"AAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(29),
      I1 => U0_xaui_inst_transmitter_txd_pipe(28),
      I2 => U0_xaui_inst_transmitter_txd_pipe(30),
      I3 => U0_xaui_inst_transmitter_txd_pipe(31),
      I4 => N138,
      O => N398
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_SW12 : LUT6
    generic map(
      INIT => X"555555555555D555"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(24),
      I1 => U0_xaui_inst_transmitter_txd_pipe(26),
      I2 => U0_xaui_inst_transmitter_txd_pipe(25),
      I3 => U0_xaui_inst_transmitter_txc_pipe(3),
      I4 => U0_xaui_inst_transmitter_txd_pipe(27),
      I5 => N195,
      O => N411
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT261 : LUT5
    generic map(
      INIT => X"FFFF0888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT261_552,
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_0_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_32_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT351 : LUT6
    generic map(
      INIT => X"FFFFFFFFA8880888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT261_552,
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_0_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(8),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_40_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT431 : LUT6
    generic map(
      INIT => X"FFFFFFFFA8880888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT261_552,
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_0_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(16),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_48_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT521 : LUT6
    generic map(
      INIT => X"FFFFFFFFA8880888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT261_552,
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_0_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(24),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_56_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT91 : LUT5
    generic map(
      INIT => X"A8880888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT123,
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_1_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I4 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(17),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_17_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT181 : LUT5
    generic map(
      INIT => X"A8880888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT123,
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_1_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I4 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(25),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_25_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT531 : LUT6
    generic map(
      INIT => X"2220202000202020"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT261_552,
      I1 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_1_Q,
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I4 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(25),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_57_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT441 : LUT6
    generic map(
      INIT => X"2220202000202020"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT261_552,
      I1 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_1_Q,
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I4 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(17),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_49_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT361 : LUT6
    generic map(
      INIT => X"2220202000202020"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT261_552,
      I1 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I2 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_1_Q,
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I4 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(9),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_41_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT271 : LUT6
    generic map(
      INIT => X"2020202020200020"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_1_Q,
      I1 => U0_xaui_inst_transmitter_tx_code_q(1),
      I2 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT261_552,
      I3 => configuration_vector(4),
      I4 => configuration_vector(5),
      I5 => configuration_vector(6),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_33_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT571 : LUT5
    generic map(
      INIT => X"FFFFEA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_4_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(28),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT302,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_60_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT541 : LUT5
    generic map(
      INIT => X"FFFFEA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_2_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(26),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT302,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_58_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT481 : LUT5
    generic map(
      INIT => X"FFFFEA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_4_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(20),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT302,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_52_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT461 : LUT5
    generic map(
      INIT => X"FFFFEA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_2_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(18),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT302,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_50_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT391 : LUT5
    generic map(
      INIT => X"FFFFEA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_4_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(12),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT302,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_44_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT371 : LUT5
    generic map(
      INIT => X"FFFFEA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_2_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(10),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT302,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_42_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT301 : LUT5
    generic map(
      INIT => X"FFFFEA2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_4_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(7),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT302,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_36_Q
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_SW8 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(35),
      I1 => U0_xaui_inst_transmitter_txd_pipe(36),
      I2 => U0_xaui_inst_transmitter_txd_pipe(37),
      I3 => U0_xaui_inst_transmitter_txd_pipe(38),
      I4 => U0_xaui_inst_transmitter_txd_pipe(39),
      I5 => N136,
      O => N272
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_n0027_SW10 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(34),
      I1 => U0_xaui_inst_transmitter_txd_pipe(36),
      I2 => U0_xaui_inst_transmitter_txd_pipe(37),
      I3 => U0_xaui_inst_transmitter_txd_pipe(38),
      I4 => U0_xaui_inst_transmitter_txd_pipe(39),
      I5 => N136,
      O => N275
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_SW8 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(43),
      I1 => U0_xaui_inst_transmitter_txd_pipe(44),
      I2 => U0_xaui_inst_transmitter_txd_pipe(45),
      I3 => U0_xaui_inst_transmitter_txd_pipe(46),
      I4 => U0_xaui_inst_transmitter_txd_pipe(47),
      I5 => N134,
      O => N291
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_n0027_SW10 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(42),
      I1 => U0_xaui_inst_transmitter_txd_pipe(44),
      I2 => U0_xaui_inst_transmitter_txd_pipe(45),
      I3 => U0_xaui_inst_transmitter_txd_pipe(46),
      I4 => U0_xaui_inst_transmitter_txd_pipe(47),
      I5 => N134,
      O => N294
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_SW8 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(51),
      I1 => U0_xaui_inst_transmitter_txd_pipe(52),
      I2 => U0_xaui_inst_transmitter_txd_pipe(53),
      I3 => U0_xaui_inst_transmitter_txd_pipe(54),
      I4 => U0_xaui_inst_transmitter_txd_pipe(55),
      I5 => N132,
      O => N310
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_n0027_SW10 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(50),
      I1 => U0_xaui_inst_transmitter_txd_pipe(52),
      I2 => U0_xaui_inst_transmitter_txd_pipe(53),
      I3 => U0_xaui_inst_transmitter_txd_pipe(54),
      I4 => U0_xaui_inst_transmitter_txd_pipe(55),
      I5 => N132,
      O => N313
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_SW8 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(59),
      I1 => U0_xaui_inst_transmitter_txd_pipe(60),
      I2 => U0_xaui_inst_transmitter_txd_pipe(61),
      I3 => U0_xaui_inst_transmitter_txd_pipe(62),
      I4 => U0_xaui_inst_transmitter_txd_pipe(63),
      I5 => N130,
      O => N329
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_n0027_SW10 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(58),
      I1 => U0_xaui_inst_transmitter_txd_pipe(60),
      I2 => U0_xaui_inst_transmitter_txd_pipe(61),
      I3 => U0_xaui_inst_transmitter_txd_pipe(62),
      I4 => U0_xaui_inst_transmitter_txd_pipe(63),
      I5 => N130,
      O => N332
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_SW8 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(3),
      I1 => U0_xaui_inst_transmitter_txd_pipe(4),
      I2 => U0_xaui_inst_transmitter_txd_pipe(5),
      I3 => U0_xaui_inst_transmitter_txd_pipe(6),
      I4 => U0_xaui_inst_transmitter_txd_pipe(7),
      I5 => N144,
      O => N348
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_n0027_SW10 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(2),
      I1 => U0_xaui_inst_transmitter_txd_pipe(4),
      I2 => U0_xaui_inst_transmitter_txd_pipe(5),
      I3 => U0_xaui_inst_transmitter_txd_pipe(6),
      I4 => U0_xaui_inst_transmitter_txd_pipe(7),
      I5 => N144,
      O => N351
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_SW8 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(11),
      I1 => U0_xaui_inst_transmitter_txd_pipe(12),
      I2 => U0_xaui_inst_transmitter_txd_pipe(13),
      I3 => U0_xaui_inst_transmitter_txd_pipe(14),
      I4 => U0_xaui_inst_transmitter_txd_pipe(15),
      I5 => N142,
      O => N367
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_n0027_SW10 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(10),
      I1 => U0_xaui_inst_transmitter_txd_pipe(12),
      I2 => U0_xaui_inst_transmitter_txd_pipe(13),
      I3 => U0_xaui_inst_transmitter_txd_pipe(14),
      I4 => U0_xaui_inst_transmitter_txd_pipe(15),
      I5 => N142,
      O => N370
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_SW8 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(19),
      I1 => U0_xaui_inst_transmitter_txd_pipe(20),
      I2 => U0_xaui_inst_transmitter_txd_pipe(21),
      I3 => U0_xaui_inst_transmitter_txd_pipe(22),
      I4 => U0_xaui_inst_transmitter_txd_pipe(23),
      I5 => N140,
      O => N386
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_n0027_SW10 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(18),
      I1 => U0_xaui_inst_transmitter_txd_pipe(20),
      I2 => U0_xaui_inst_transmitter_txd_pipe(21),
      I3 => U0_xaui_inst_transmitter_txd_pipe(22),
      I4 => U0_xaui_inst_transmitter_txd_pipe(23),
      I5 => N140,
      O => N389
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_SW8 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(27),
      I1 => U0_xaui_inst_transmitter_txd_pipe(28),
      I2 => U0_xaui_inst_transmitter_txd_pipe(29),
      I3 => U0_xaui_inst_transmitter_txd_pipe(30),
      I4 => U0_xaui_inst_transmitter_txd_pipe(31),
      I5 => N138,
      O => N405
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_n0027_SW10 : LUT6
    generic map(
      INIT => X"AAAAAAAAAAAAAAAB"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(26),
      I1 => U0_xaui_inst_transmitter_txd_pipe(28),
      I2 => U0_xaui_inst_transmitter_txd_pipe(29),
      I3 => U0_xaui_inst_transmitter_txd_pipe(30),
      I4 => U0_xaui_inst_transmitter_txd_pipe(31),
      I5 => N138,
      O => N408
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT210 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFEAFF2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_2_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I4 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(10),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_10_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT410 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFEAFF2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_4_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I4 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(12),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_12_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT231 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFEAFF2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_2_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I4 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(7),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_2_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT191 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFEAFF2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_2_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I4 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(26),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_26_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT451 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFEAFF2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_4_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I4 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(7),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_4_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT211 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFEAFF2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_4_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I4 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(28),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_28_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT132 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFEAFF2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_4_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I4 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(20),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_20_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT291 : LUT6
    generic map(
      INIT => X"5555544455550444"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_3_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT2911,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(7),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_35_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT381 : LUT6
    generic map(
      INIT => X"5555544455550444"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_3_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT2911,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(11),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_43_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT551 : LUT6
    generic map(
      INIT => X"5555544455550444"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_3_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT2911,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(27),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_59_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT471 : LUT6
    generic map(
      INIT => X"5555544455550444"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I1 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_3_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT2911,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(19),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_51_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT31 : LUT6
    generic map(
      INIT => X"5555544455550444"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_3_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(11),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_11_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT111 : LUT6
    generic map(
      INIT => X"5555544455550444"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_3_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(19),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_19_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT201 : LUT6
    generic map(
      INIT => X"5555544455550444"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_3_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(27),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_27_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT341 : LUT6
    generic map(
      INIT => X"5555544455550444"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_3_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(7),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_3_Q
    );
  U0_xaui_inst_transmitter_align_mux211 : LUT6
    generic map(
      INIT => X"FFBABAFF45000045"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_code_a(0),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I3 => U0_xaui_inst_transmitter_align_count(1),
      I4 => U0_xaui_inst_transmitter_align_count(2),
      I5 => U0_xaui_inst_transmitter_align_prbs(3),
      O => U0_xaui_inst_transmitter_align_count_4_PWR_11_o_mux_9_OUT_2_Q
    );
  U0_xaui_inst_receiver_sync_status_int_3_1 : LUT6
    generic map(
      INIT => X"8080808080808000"
    )
    port map (
      I0 => U0_xaui_inst_receiver_sync_ok_int(2),
      I1 => U0_xaui_inst_receiver_sync_ok_int(1),
      I2 => U0_xaui_inst_receiver_sync_ok_int(0),
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_2_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_3_Q,
      O => U0_xaui_inst_receiver_sync_status_int
    );
  U0_xaui_inst_transmitter_recoder_txc_out_7_glue_set : LUT5
    generic map(
      INIT => X"FFFFFF2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txc_out_364,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT2911,
      I4 => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      O => U0_xaui_inst_transmitter_recoder_txc_out_7_glue_set_1202
    );
  U0_xaui_inst_transmitter_recoder_txc_out_6_glue_set : LUT5
    generic map(
      INIT => X"FFFFFF2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txc_out_373,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT2911,
      I4 => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      O => U0_xaui_inst_transmitter_recoder_txc_out_6_glue_set_1203
    );
  U0_xaui_inst_transmitter_recoder_txc_out_5_glue_set : LUT5
    generic map(
      INIT => X"FFFFFF2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txc_out_382,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT2911,
      I4 => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      O => U0_xaui_inst_transmitter_recoder_txc_out_5_glue_set_1204
    );
  U0_xaui_inst_transmitter_recoder_txc_out_4_glue_set : LUT5
    generic map(
      INIT => X"FFFFFFEA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txc_out_391,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT2911,
      I4 => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      O => U0_xaui_inst_transmitter_recoder_txc_out_4_glue_set_1205
    );
  U0_xaui_inst_transmitter_recoder_txc_out_3_glue_set : LUT5
    generic map(
      INIT => X"FFFFFF2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txc_out_400,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      I4 => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      O => U0_xaui_inst_transmitter_recoder_txc_out_3_glue_set_1206
    );
  U0_xaui_inst_transmitter_recoder_txc_out_2_glue_set : LUT5
    generic map(
      INIT => X"FFFFFF2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txc_out_409,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      I4 => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      O => U0_xaui_inst_transmitter_recoder_txc_out_2_glue_set_1207
    );
  U0_xaui_inst_transmitter_recoder_txc_out_1_glue_set : LUT5
    generic map(
      INIT => X"FFFFFF2A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txc_out_418,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      I4 => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      O => U0_xaui_inst_transmitter_recoder_txc_out_1_glue_set_1208
    );
  U0_xaui_inst_transmitter_recoder_txc_out_0_glue_set : LUT5
    generic map(
      INIT => X"FFFFFFEA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txc_out_427,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT131,
      I4 => U0_xaui_inst_transmitter_recoder_test_pattern_en_GND_10_o_AND_7_o,
      O => U0_xaui_inst_transmitter_recoder_txc_out_0_glue_set_1209
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_7_AND_204_o_SW0 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFF7FFF"
    )
    port map (
      I0 => mgt_codevalid(7),
      I1 => mgt_rxcharisk(7),
      I2 => mgt_rxdata(58),
      I3 => mgt_rxdata(56),
      I4 => U0_xaui_inst_receiver_code_error_7_2_1119,
      I5 => mgt_rxdata(57),
      O => N66
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_6_AND_202_o_SW0 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFF7FFF"
    )
    port map (
      I0 => mgt_codevalid(5),
      I1 => mgt_rxcharisk(5),
      I2 => mgt_rxdata(42),
      I3 => mgt_rxdata(40),
      I4 => U0_xaui_inst_receiver_code_error_6_2_1121,
      I5 => mgt_rxdata(41),
      O => N68
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_5_AND_200_o_SW0 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFF7FFF"
    )
    port map (
      I0 => mgt_codevalid(3),
      I1 => mgt_rxcharisk(3),
      I2 => mgt_rxdata(26),
      I3 => mgt_rxdata(24),
      I4 => U0_xaui_inst_receiver_code_error_5_2_1123,
      I5 => mgt_rxdata(25),
      O => N70
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_4_AND_198_o_SW0 : LUT6
    generic map(
      INIT => X"FFFF7FFFFFFFFFFF"
    )
    port map (
      I0 => mgt_rxdata(12),
      I1 => mgt_rxdata(11),
      I2 => mgt_rxdata(10),
      I3 => mgt_rxcharisk(1),
      I4 => U0_xaui_inst_receiver_code_error_4_2_1125,
      I5 => mgt_codevalid(1),
      O => N72
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_3_AND_196_o_SW0 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFF7FFF"
    )
    port map (
      I0 => mgt_codevalid(6),
      I1 => mgt_rxcharisk(6),
      I2 => mgt_rxdata(50),
      I3 => mgt_rxdata(48),
      I4 => U0_xaui_inst_receiver_code_error_3_2_1127,
      I5 => mgt_rxdata(49),
      O => N74
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_2_AND_194_o_SW0 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFF7FFF"
    )
    port map (
      I0 => mgt_codevalid(4),
      I1 => mgt_rxcharisk(4),
      I2 => mgt_rxdata(34),
      I3 => mgt_rxdata(32),
      I4 => U0_xaui_inst_receiver_code_error_2_2_1129,
      I5 => mgt_rxdata(33),
      O => N76
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_1_AND_192_o_SW0 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFF7FFF"
    )
    port map (
      I0 => mgt_codevalid(2),
      I1 => mgt_rxcharisk(2),
      I2 => mgt_rxdata(18),
      I3 => mgt_rxdata(16),
      I4 => U0_xaui_inst_receiver_code_error_1_2_1131,
      I5 => mgt_rxdata(17),
      O => N78
    );
  U0_xaui_inst_receiver_recoder_PWR_20_o_code_error_0_AND_190_o_SW0 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFF7FFF"
    )
    port map (
      I0 => mgt_codevalid(0),
      I1 => mgt_rxcharisk(0),
      I2 => mgt_rxdata(2),
      I3 => mgt_rxdata(0),
      I4 => U0_xaui_inst_receiver_code_error_0_2_1133,
      I5 => mgt_rxdata(1),
      O => N80
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_4_rstpot : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(4),
      I1 => U0_xaui_inst_transmitter_txd_pipe(36),
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_4_rstpot_1252
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_4_rstpot : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(5),
      I1 => U0_xaui_inst_transmitter_txd_pipe(44),
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_4_rstpot_1244
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_4_rstpot : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(6),
      I1 => U0_xaui_inst_transmitter_txd_pipe(52),
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_4_rstpot_1236
    );
  U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_4_rstpot : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(7),
      I1 => U0_xaui_inst_transmitter_txd_pipe(60),
      O => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_4_rstpot_1228
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_4_rstpot : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(0),
      I1 => U0_xaui_inst_transmitter_txd_pipe(4),
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_4_rstpot_1284
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_4_rstpot : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(1),
      I1 => U0_xaui_inst_transmitter_txd_pipe(12),
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_4_rstpot_1276
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_4_rstpot : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(2),
      I1 => U0_xaui_inst_transmitter_txd_pipe(20),
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_4_rstpot_1268
    );
  U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_4_rstpot : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txc_pipe(3),
      I1 => U0_xaui_inst_transmitter_txd_pipe(28),
      O => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_4_rstpot_1260
    );
  U0_xaui_inst_transmitter_state_machine_next_ifg_is_a_glue_rst_SW1 : LUT4
    generic map(
      INIT => X"FF01"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I3 => U0_xaui_inst_transmitter_state_machine_next_ifg_is_a_686,
      O => N471
    );
  U0_xaui_inst_transmitter_state_machine_next_ifg_is_a_glue_rst : LUT6
    generic map(
      INIT => X"CCCCCCCF8880888A"
    )
    port map (
      I0 => N461,
      I1 => N471,
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I4 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I5 => U0_xaui_inst_usrclk_reset_350,
      O => U0_xaui_inst_transmitter_state_machine_next_ifg_is_a_glue_rst_1211
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT10_SW1 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => configuration_vector(5),
      I1 => configuration_vector(4),
      O => N473
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT10 : LUT6
    generic map(
      INIT => X"FFFFFE54FFFFFFFF"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_2_Q,
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I3 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(18),
      I4 => N473,
      I5 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_18_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT32111 : LUT5
    generic map(
      INIT => X"FF0F2202"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I2 => configuration_vector(4),
      I3 => configuration_vector(5),
      I4 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      O => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT3211
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT221 : LUT6
    generic map(
      INIT => X"FFFFEE8AFFFF228A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_3_filter_txd_out_5_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT511,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(29),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_29_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT141 : LUT6
    generic map(
      INIT => X"FFFFEE8AFFFF228A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_2_filter_txd_out_5_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT511,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(21),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_21_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT56 : LUT6
    generic map(
      INIT => X"FFFFEE8AFFFF228A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_5_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT511,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(13),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_13_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT401 : LUT6
    generic map(
      INIT => X"FFFFEE8AFFFF228A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_5_filter_txd_out_5_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT311,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(13),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_45_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT491 : LUT6
    generic map(
      INIT => X"FFFFEE8AFFFF228A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_6_filter_txd_out_5_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT311,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(21),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_53_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT581 : LUT6
    generic map(
      INIT => X"FFFFEE8AFFFF228A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_G_FILTER_HIGH_7_filter_txd_out_5_Q,
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT311,
      I5 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(29),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_61_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT121 : LUT6
    generic map(
      INIT => X"1000100000001000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_1_Q,
      I4 => configuration_vector(4),
      I5 => configuration_vector(5),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_1_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT17 : LUT6
    generic map(
      INIT => X"FFFFFFFF40400440"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_code_r(0),
      I1 => N6,
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I4 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_24_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT63 : LUT6
    generic map(
      INIT => X"FFFFFFFF40400440"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_code_r(0),
      I1 => N10,
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I4 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I5 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_8_Q
    );
  U0_xaui_inst_aligned_sticky_glue_set : LUT3
    generic map(
      INIT => X"A8"
    )
    port map (
      I0 => NlwRenamedSig_OI_U0_status_vector_int_6_Q,
      I1 => U0_xaui_inst_clear_aligned_edge_345,
      I2 => NlwRenamedSig_OI_U0_status_vector_int_7_Q,
      O => U0_xaui_inst_aligned_sticky_glue_set_1199
    );
  U0_xaui_inst_transmitter_tqmsg_capture_1_q_det_rstpot_SW0 : LUT4
    generic map(
      INIT => X"F888"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      O => N465
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT1_SW1 : LUT3
    generic map(
      INIT => X"F7"
    )
    port map (
      I0 => configuration_vector(6),
      I1 => configuration_vector(4),
      I2 => configuration_vector(5),
      O => N469
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT561 : LUT6
    generic map(
      INIT => X"5B4B5B4BFFFF5B4B"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_5_Q,
      I4 => configuration_vector(4),
      I5 => configuration_vector(5),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_5_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT312 : LUT6
    generic map(
      INIT => X"5B4B5B4BFFFF5B4B"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_5_Q,
      I4 => configuration_vector(4),
      I5 => configuration_vector(5),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_37_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT8 : LUT5
    generic map(
      INIT => X"FFFF8088"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I1 => N4,
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I4 => U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT635,
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_16_Q
    );
  U0_xaui_inst_transmitter_align_extra_a_glue_set : LUT5
    generic map(
      INIT => X"FF0F2202"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_align_extra_a_659,
      O => U0_xaui_inst_transmitter_align_extra_a_glue_set_1210
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT611 : LUT6
    generic map(
      INIT => X"0C0C3C0C04041404"
    )
    port map (
      I0 => configuration_vector(4),
      I1 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I3 => U0_xaui_inst_transmitter_G_FILTER_LOW_0_filter_txd_out_6_Q,
      I4 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I5 => configuration_vector(5),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_6_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT321 : LUT6
    generic map(
      INIT => X"0C0C3C0C04041404"
    )
    port map (
      I0 => configuration_vector(4),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_G_FILTER_HIGH_4_filter_txd_out_6_Q,
      I4 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I5 => configuration_vector(5),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_38_Q
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp43_SW3 : LUT6
    generic map(
      INIT => X"FFFFFFCFAAAAAA8A"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_is_idle(0),
      I1 => U0_xaui_inst_transmitter_state_machine_next_ifg_is_a_686,
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I4 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I5 => U0_xaui_inst_transmitter_tx_is_q(0),
      O => N439
    );
  U0_xaui_inst_transmitter_state_machine_Mmux_p_state_comb_state_temp43_SW2 : LUT5
    generic map(
      INIT => X"FCFFA8AA"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_tx_is_idle(0),
      I1 => U0_xaui_inst_transmitter_state_machine_state_1(2),
      I2 => U0_xaui_inst_transmitter_state_machine_state_1(1),
      I3 => U0_xaui_inst_transmitter_state_machine_state_1(0),
      I4 => U0_xaui_inst_transmitter_tx_is_q(0),
      O => N438
    );
  U0_xaui_inst_transmitter_is_terminate_1_4_1 : LUT6
    generic map(
      INIT => X"FF20FF0020200000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(56),
      I1 => U0_xaui_inst_transmitter_txd_pipe(57),
      I2 => U0_xaui_inst_transmitter_txd_pipe(58),
      I3 => U0_xaui_inst_transmitter_is_terminate_1_3_1084,
      I4 => U0_xaui_inst_transmitter_is_terminate_1_1_1082,
      I5 => U0_xaui_inst_transmitter_is_terminate_1_2_1083,
      O => U0_xaui_inst_transmitter_is_terminate_1_41
    );
  U0_xaui_inst_transmitter_is_terminate_1_6_1 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(34),
      I1 => U0_xaui_inst_transmitter_txd_pipe(33),
      I2 => U0_xaui_inst_transmitter_txd_pipe(32),
      I3 => U0_xaui_inst_transmitter_is_terminate_1_5_1086,
      O => U0_xaui_inst_transmitter_is_terminate_1_61
    );
  U0_xaui_inst_transmitter_is_terminate_0_4_1 : LUT6
    generic map(
      INIT => X"FF20FF0020200000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(24),
      I1 => U0_xaui_inst_transmitter_txd_pipe(25),
      I2 => U0_xaui_inst_transmitter_txd_pipe(26),
      I3 => U0_xaui_inst_transmitter_is_terminate_0_3_1091,
      I4 => U0_xaui_inst_transmitter_is_terminate_0_1_1089,
      I5 => U0_xaui_inst_transmitter_is_terminate_0_2_1090,
      O => U0_xaui_inst_transmitter_is_terminate_0_41
    );
  U0_xaui_inst_transmitter_is_terminate_0_6_1 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_txd_pipe(2),
      I1 => U0_xaui_inst_transmitter_txd_pipe(1),
      I2 => U0_xaui_inst_transmitter_txd_pipe(0),
      I3 => U0_xaui_inst_transmitter_is_terminate_0_5_1093,
      O => U0_xaui_inst_transmitter_is_terminate_0_61
    );
  U0_xaui_inst_align_status_int_inv1_INV_0 : INV
    port map (
      I => NlwRenamedSig_OI_U0_status_vector_int_6_Q,
      O => U0_xaui_inst_align_status_int_inv
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT64 : MUXF7
    port map (
      I0 => N475,
      I1 => N476,
      S => U0_xaui_inst_transmitter_tx_code_q(0),
      O => U0_xaui_inst_transmitter_recoder_code_sel_9_PWR_10_o_mux_78_OUT_9_Q
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT64_F : LUT6
    generic map(
      INIT => X"8080008088880088"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I1 => U0_xaui_inst_transmitter_G_FILTER_LOW_1_filter_txd_out_1_Q,
      I2 => configuration_vector(5),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I4 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I5 => configuration_vector(4),
      O => N475
    );
  U0_xaui_inst_transmitter_recoder_Mmux_code_sel_9_PWR_10_o_mux_78_OUT64_G : LUT6
    generic map(
      INIT => X"8080008088880088"
    )
    port map (
      I0 => U0_xaui_inst_transmitter_state_machine_state_0(0),
      I1 => U0_xaui_inst_transmitter_tqmsg_capture_1_last_qmsg(9),
      I2 => configuration_vector(5),
      I3 => U0_xaui_inst_transmitter_state_machine_state_0(2),
      I4 => U0_xaui_inst_transmitter_state_machine_state_0(1),
      I5 => configuration_vector(4),
      O => N476
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT42 : MUXF7
    port map (
      I0 => N477,
      I1 => N478,
      S => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_0_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_3_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT42_F : LUT6
    generic map(
      INIT => X"A8880220A8882020"
    )
    port map (
      I0 => mgt_rxlock(3),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_1_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N477
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT42_G : LUT6
    generic map(
      INIT => X"8AA80220A8A80220"
    )
    port map (
      I0 => mgt_rxlock(3),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_2_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_code_valid_pipe_1_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_3_pcs_sync_state_p_state_comb_state_temp_1_Q,
      O => N478
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT42 : MUXF7
    port map (
      I0 => N479,
      I1 => N480,
      S => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_0_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_3_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT42_F : LUT6
    generic map(
      INIT => X"A8880220A8882020"
    )
    port map (
      I0 => mgt_rxlock(2),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_1_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N479
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT42_G : LUT6
    generic map(
      INIT => X"8AA80220A8A80220"
    )
    port map (
      I0 => mgt_rxlock(2),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_2_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_code_valid_pipe_1_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_2_pcs_sync_state_p_state_comb_state_temp_1_Q,
      O => N480
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT42 : MUXF7
    port map (
      I0 => N481,
      I1 => N482,
      S => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_0_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_3_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT42_F : LUT6
    generic map(
      INIT => X"A8880220A8882020"
    )
    port map (
      I0 => mgt_rxlock(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_1_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N481
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT42_G : LUT6
    generic map(
      INIT => X"8AA80220A8A80220"
    )
    port map (
      I0 => mgt_rxlock(1),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_2_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_code_valid_pipe_1_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_1_pcs_sync_state_p_state_comb_state_temp_1_Q,
      O => N482
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT42 : MUXF7
    port map (
      I0 => N483,
      I1 => N484,
      S => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_0_Q,
      O => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_state_1_4_GND_17_o_mux_46_OUT_3_Q
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT42_F : LUT6
    generic map(
      INIT => X"A8880220A8882020"
    )
    port map (
      I0 => mgt_rxlock(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_1_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_1_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_2_Q,
      O => N483
    );
  U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_Mmux_state_1_4_GND_17_o_mux_46_OUT42_G : LUT6
    generic map(
      INIT => X"8AA80220A8A80220"
    )
    port map (
      I0 => mgt_rxlock(0),
      I1 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_4_Q,
      I2 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_3_Q,
      I3 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_2_Q,
      I4 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_code_valid_pipe_1_Q,
      I5 => U0_xaui_inst_receiver_G_SYNC_G_PCS_SYNC_STATE_0_pcs_sync_state_p_state_comb_state_temp_1_Q,
      O => N484
    );

end STRUCTURE;

-- synthesis translate_on
