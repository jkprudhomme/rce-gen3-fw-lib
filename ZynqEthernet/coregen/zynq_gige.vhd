--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.58f
--  \   \         Application: netgen
--  /   /         Filename: zynq_gige.vhd
-- /___/   /\     Timestamp: Mon Jul  8 14:11:00 2013
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -w -sim -ofmt vhdl /afs/slac.stanford.edu/u/ey/rherbst/projects/rce/dpm_stable/modules/ZynqEthernet/coregen/tmp/_cg/zynq_gige.ngc /afs/slac.stanford.edu/u/ey/rherbst/projects/rce/dpm_stable/modules/ZynqEthernet/coregen/tmp/_cg/zynq_gige.vhd 
-- Device	: 7z030fbg484-2
-- Input file	: /afs/slac.stanford.edu/u/ey/rherbst/projects/rce/dpm_stable/modules/ZynqEthernet/coregen/tmp/_cg/zynq_gige.ngc
-- Output file	: /afs/slac.stanford.edu/u/ey/rherbst/projects/rce/dpm_stable/modules/ZynqEthernet/coregen/tmp/_cg/zynq_gige.vhd
-- # of Entities	: 1
-- Design Name	: zynq_gige
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

entity zynq_gige is
  port (
    reset : in STD_LOGIC := 'X'; 
    signal_detect : in STD_LOGIC := 'X'; 
    userclk : in STD_LOGIC := 'X'; 
    userclk2 : in STD_LOGIC := 'X'; 
    dcm_locked : in STD_LOGIC := 'X'; 
    txbuferr : in STD_LOGIC := 'X'; 
    gmii_tx_en : in STD_LOGIC := 'X'; 
    gmii_tx_er : in STD_LOGIC := 'X'; 
    mdc : in STD_LOGIC := 'X'; 
    mdio_in : in STD_LOGIC := 'X'; 
    configuration_valid : in STD_LOGIC := 'X'; 
    mgt_rx_reset : out STD_LOGIC; 
    mgt_tx_reset : out STD_LOGIC; 
    powerdown : out STD_LOGIC; 
    txchardispmode : out STD_LOGIC; 
    txchardispval : out STD_LOGIC; 
    txcharisk : out STD_LOGIC; 
    enablealign : out STD_LOGIC; 
    gmii_rx_dv : out STD_LOGIC; 
    gmii_rx_er : out STD_LOGIC; 
    gmii_isolate : out STD_LOGIC; 
    mdio_out : out STD_LOGIC; 
    mdio_tri : out STD_LOGIC; 
    rxbufstatus : in STD_LOGIC_VECTOR ( 1 downto 0 ); 
    rxchariscomma : in STD_LOGIC_VECTOR ( 0 downto 0 ); 
    rxcharisk : in STD_LOGIC_VECTOR ( 0 downto 0 ); 
    rxclkcorcnt : in STD_LOGIC_VECTOR ( 2 downto 0 ); 
    rxdata : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    rxdisperr : in STD_LOGIC_VECTOR ( 0 downto 0 ); 
    rxnotintable : in STD_LOGIC_VECTOR ( 0 downto 0 ); 
    rxrundisp : in STD_LOGIC_VECTOR ( 0 downto 0 ); 
    gmii_txd : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    phyad : in STD_LOGIC_VECTOR ( 4 downto 0 ); 
    configuration_vector : in STD_LOGIC_VECTOR ( 4 downto 0 ); 
    txdata : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    gmii_rxd : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    status_vector : out STD_LOGIC_VECTOR ( 15 downto 0 ) 
  );
end zynq_gige;

architecture STRUCTURE of zynq_gige is
  signal U0_gpcs_pma_inst_RXNOTINTABLE_REG_60 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXDISPERR_REG_61 : STD_LOGIC; 
  signal NlwRenamedSig_OI_U0_gpcs_pma_inst_RECEIVER_RX_INVALID : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RUDI_I_63 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RUDI_C_64 : STD_LOGIC; 
  signal NlwRenamedSignal_U0_gpcs_pma_inst_STATUS_VECTOR_0 : STD_LOGIC; 
  signal NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT : STD_LOGIC; 
  signal NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT : STD_LOGIC; 
  signal NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_POWERDOWN_REG : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXCHARDISPMODE_69 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXCHARDISPVAL_70 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXCHARISK_71 : STD_LOGIC; 
  signal NlwRenamedSig_OI_U0_gpcs_pma_inst_SYNCHRONISATION_ENCOMMAALIGN : STD_LOGIC; 
  signal NlwRenamedSig_OI_U0_gpcs_pma_inst_RECEIVER_RX_DV : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RX_ER_74 : STD_LOGIC; 
  signal NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_OUT_76 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_TRI_77 : STD_LOGIC; 
  signal N0 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd1_79 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd2_80 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd3_81 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd4_82 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd1_In : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd2_In : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd3_In : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd1_86 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd2_87 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd3_88 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd4_89 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd1_In : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd2_In : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd3_In : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNC_SIGNAL_DETECT_data_sync1 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SRESET_PIPE_PWR_15_o_MUX_1_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RESET_INT_RXBUFSTATUS_INT_1_OR_126_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RESET_INT_TXBUFERR_INT_OR_125_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXCHARDISPVAL_INT_GND_15_o_MUX_288_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXCHARDISPMODE_INT_TXEVEN_MUX_287_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXCHARISK_INT_TXEVEN_MUX_286_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_0_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_1_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_2_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_3_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_4_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_5_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_6_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_7_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RX_RST_SM_3_GND_15_o_Mux_13_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TX_RST_SM_3_GND_15_o_Mux_9_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXBUFERR_INT_110 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXNOTINTABLE_INT_115 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXDISPERR_INT_116 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXCHARISK_INT_125 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXCHARISCOMMA_INT_126 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SRESET_127 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SRESET_PIPE_128 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_130 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXNOTINTABLE_SRL : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXDISPERR_SRL : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RESET_INT_PIPE_133 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RESET_INT_134 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SIGNAL_DETECT_REG : STD_LOGIC; 
  signal U0_gpcs_pma_inst_DCM_LOCKED_SOFT_RESET_OR_2_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_RESET_REG_138 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TXCHARDISPVAL_139 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TXCHARDISPMODE_140 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TXCHARISK_141 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXNOTINTABLE_0_GND_15_o_MUX_276_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXDISPERR_0_GND_15_o_MUX_277_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_0_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_1_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_2_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_3_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_4_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_5_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_6_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_7_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXCLKCORCNT_2_GND_15_o_mux_18_OUT_0_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXCLKCORCNT_2_GND_15_o_mux_18_OUT_1_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXCLKCORCNT_2_GND_15_o_mux_18_OUT_2_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXCHARISK_0_TXCHARISK_INT_MUX_279_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXCHARISCOMMA_0_TXCHARISK_INT_MUX_280_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RXBUFSTATUS_1_GND_15_o_mux_17_OUT_1_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT511 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_Mram_CODE_GRP_CNT_1_GND_26_o_Mux_5_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TX_EN_TRIGGER_S_OR_25_o_0 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT_1_TX_CONFIG_15_wide_mux_4_OUT_7_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_DISP5 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TX_EN_TRIGGER_T_OR_27_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TX_EN_EVEN_AND_25_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_CODE_GRP_CNT_1_MUX_186_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRPISK_GND_26_o_MUX_192_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_0_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_1_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_2_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_3_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_4_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_5_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_6_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_7_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_EVEN_AND_59_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_0_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_1_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_2_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_3_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_4_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_5_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_6_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_7_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_DISPARITY_196 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_V_197 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_R_198 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT_200 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_XMIT_DATA_INT_201 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_C1_OR_C2_202 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRPISK_204 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TRIGGER_T_206 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_T_207 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TRIGGER_S_208 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_S_209 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TX_ER_REG1_222 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_223 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_SYNC_MDC_data_sync1 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_SYNC_MDIO_IN_data_sync1 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_n0162_inv : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_UNIDIRECTIONAL_ENABLE_REG_DATA_WR_5_MUX_126_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG_DATA_WR_10_MUX_124_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_DATA_WR_14_MUX_120_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_GND_22_o_MDIO_WE_AND_14_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_IN_REG2 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_REG2 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_UNIDIRECTIONAL_ENABLE_REG_242 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_IN_REG4_243 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_IN_REG3_244 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_REG3_245 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_CONFIGURATION_VALID_EN_REG_246 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_CONFIGURATION_VALID_EN_247 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_WE_249 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG3_250 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT_xor_3_14 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In1 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mmux_STATE_3_PWR_20_o_Mux_36_o11_270 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB2_271 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In1 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1011 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT3 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT2 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT1 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0141_inv : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_In : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_In : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In_281 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0147_inv_283 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0155_inv : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_3_PWR_20_o_Mux_37_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_3_PWR_20_o_Mux_36_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_GND_24_o_GND_24_o_MUX_62_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG1_PWR_20_o_AND_3_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_LAST_DATA_SHIFT_302 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_307 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG2_308 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG1_309 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_0_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_1_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_2_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_3_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_4_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_5_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_6_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_7_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_8_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_9_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_10_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_11_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_12_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_13_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_14_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_15_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_In1_0 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_327 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_In2_331 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_In2 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_In2 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_In3 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_n0103_inv : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_1_PWR_23_o_equal_19_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_1_GND_27_o_mux_30_OUT_0_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_1_GND_27_o_mux_30_OUT_1_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD_GND_27_o_AND_69_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_SIGNAL_DETECT_REG_343 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_K27p7_RXFIFO_ERR_AND_128_o1_344 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_K28p51_345 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_C_REG2_346 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_D21p5_AND_133_o_norst : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_IDLE_REG_1_IDLE_REG_2_OR_124_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG_0_RX_CONFIG_VALID_REG_3_OR_123_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_C_REG1_C_REG3_OR_69_o_350 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_I_REG_T_REG2_OR_74_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_D0p0_352 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EXTEND_REG3_EXT_ILLEGAL_K_REG2_OR_93_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EOP_REG1_SYNC_STATUS_OR_97_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EOP_EXTEND_OR_75_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_0_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_1_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_2_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_3_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_4_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_5_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_6_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_7_Q : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RXCHARISK_REG1_K28p5_REG1_AND_184_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_S_WAIT_FOR_K_AND_161_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_ISOLATE_AND_199_o_367 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_SYNC_STATUS_C_REG1_AND_142_o_368 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EVEN_RXCHARISK_AND_132_o_369 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_EVEN_AND_144_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_K28p5 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RXDATA_7_RXNOTINTABLE_AND_228_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_K23p7 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_K27p7_RXFIFO_ERR_AND_128_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_K29p7 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RXFIFO_ERR_RXDISPERR_OR_46_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EXTEND_378 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RECEIVE_379 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_380 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_WAIT_FOR_K_381 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_389 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_K_390 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_391 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_REG2_392 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_REG1_393 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_394 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EXTEND_ERR_395 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_ILLEGAL_K_REG2_396 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_ILLEGAL_K_REG1_397 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_ILLEGAL_K_398 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RX_DATA_ERROR_399 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EOP_REG1_400 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EOP_401 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_SOP_402 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FROM_RX_CX_403 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG3_405 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_SYNC_STATUS_REG_406 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_INT_407 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_CGBAD_REG3_408 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_CGBAD_409 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_R_410 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EXTEND_REG3_419 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_SOP_REG3_421 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_SOP_REG2_422 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG2 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_C_HDR_REMOVED_REG_424 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_CGBAD_REG2 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RXCHARISK_REG1_426 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_C_REG3_427 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_C_REG1_428 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_I_REG_429 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_R_REG1_430 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_T_REG2_431 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_T_REG1_432 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_D0p0_REG_433 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_C_435 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_I_436 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_T_437 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_S_438 : STD_LOGIC; 
  signal N2 : STD_LOGIC; 
  signal N6 : STD_LOGIC; 
  signal N8 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_XMIT_DATA_INT_AND_37_o1_442 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_XMIT_DATA_INT_AND_37_o2_443 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT2 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT1 : STD_LOGIC; 
  signal N10 : STD_LOGIC; 
  signal N12 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB1_448 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB3_449 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB4_450 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB5_451 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB6_452 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB7_453 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB8_454 : STD_LOGIC; 
  signal N14 : STD_LOGIC; 
  signal N16 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In3_457 : STD_LOGIC; 
  signal N18 : STD_LOGIC; 
  signal N20 : STD_LOGIC; 
  signal N22 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_In31_461 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_In21_462 : STD_LOGIC; 
  signal N28 : STD_LOGIC; 
  signal N32 : STD_LOGIC; 
  signal N34 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_D21p5_D2p2_OR_48_o : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_D21p5_D2p2_OR_48_o1_467 : STD_LOGIC; 
  signal N36 : STD_LOGIC; 
  signal N38 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o1_470 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o2_471 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o3_472 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o4_473 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_POS_FALSE_NIT_NEG_OR_118_o1 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_POS_FALSE_NIT_NEG_OR_118_o12_475 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_POS_FALSE_NIT_NEG_OR_118_o13_476 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_I_REG_T_REG2_OR_74_o1_477 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_T_REG2_R_REG1_OR_89_o2_478 : STD_LOGIC; 
  signal N40 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_V_glue_set_480 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_glue_set_481 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_R_glue_set_482 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_DISPARITY_glue_rst_483 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_POWERDOWN_REG_glue_set_484 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_ENCOMMAALIGN_glue_set_485 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_glue_rst_486 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_glue_set_487 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RECEIVE_glue_set_488 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RX_INVALID_glue_set_489 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RX_DV_glue_set_490 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EXTEND_glue_set_491 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_glue_set_492 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_WAIT_FOR_K_glue_set_493 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_C1_OR_C2_rstpot_494 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_WE_rstpot_495 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_rstpot_496 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_RESET_REG_rstpot_497 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd4_rstpot_498 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd4_rstpot_499 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRPISK_rstpot_500 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TXCHARDISPVAL_rstpot_501 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_TRIGGER_T_rstpot_502 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_S_rstpot_503 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA_0_rstpot_504 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_CONFIGURATION_VALID_EN_rstpot_505 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_rstpot_506 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_C_HDR_REMOVED_REG_rstpot_507 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_C_rstpot_508 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_rstpot_509 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_RX_DATA_ERROR_rstpot_510 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_rstpot_511 : STD_LOGIC; 
  signal N47 : STD_LOGIC; 
  signal N49 : STD_LOGIC; 
  signal N55 : STD_LOGIC; 
  signal N57 : STD_LOGIC; 
  signal N59 : STD_LOGIC; 
  signal N61 : STD_LOGIC; 
  signal N63 : STD_LOGIC; 
  signal N64 : STD_LOGIC; 
  signal N65 : STD_LOGIC; 
  signal N66 : STD_LOGIC; 
  signal N67 : STD_LOGIC; 
  signal N68 : STD_LOGIC; 
  signal N69 : STD_LOGIC; 
  signal N70 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_Mshreg_STATUS_VECTOR_0_526 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_7_527 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_6_528 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_5_529 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_2_530 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_4_531 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_3_532 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_Mshreg_EXTEND_REG3_533 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_1_534 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_0_535 : STD_LOGIC; 
  signal U0_gpcs_pma_inst_RECEIVER_Mshreg_SOP_REG2_536 : STD_LOGIC; 
  signal NLW_U0_gpcs_pma_inst_Mshreg_STATUS_VECTOR_0_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_7_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_6_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_5_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_2_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_4_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_3_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_EXTEND_REG3_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_1_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_0_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_CGBAD_REG2_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_SOP_REG2_Q15_UNCONNECTED : STD_LOGIC; 
  signal NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_FALSE_CARRIER_REG2_Q15_UNCONNECTED : STD_LOGIC; 
  signal U0_gpcs_pma_inst_TXDATA : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal U0_gpcs_pma_inst_RECEIVER_RXD : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal U0_gpcs_pma_inst_RXCLKCORCNT_INT : STD_LOGIC_VECTOR ( 2 downto 0 ); 
  signal U0_gpcs_pma_inst_RXBUFSTATUS_INT : STD_LOGIC_VECTOR ( 1 downto 1 ); 
  signal U0_gpcs_pma_inst_RXDATA_INT : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal U0_gpcs_pma_inst_TRANSMITTER_TXDATA : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal U0_gpcs_pma_inst_TRANSMITTER_Result : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal U0_gpcs_pma_inst_TRANSMITTER_n0235 : STD_LOGIC_VECTOR ( 1 downto 1 ); 
  signal U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_DATA_RD : STD_LOGIC_VECTOR ( 6 downto 6 ); 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG : STD_LOGIC_VECTOR ( 15 downto 0 ); 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_OPCODE : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal U0_gpcs_pma_inst_RECEIVER_IDLE_REG : STD_LOGIC_VECTOR ( 2 downto 0 ); 
  signal U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal NlwRenamedSig_OI_status_vector : STD_LOGIC_VECTOR ( 7 downto 7 ); 
  signal U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
begin
  txdata(7) <= U0_gpcs_pma_inst_TXDATA(7);
  txdata(6) <= U0_gpcs_pma_inst_TXDATA(6);
  txdata(5) <= U0_gpcs_pma_inst_TXDATA(5);
  txdata(4) <= U0_gpcs_pma_inst_TXDATA(4);
  txdata(3) <= U0_gpcs_pma_inst_TXDATA(3);
  txdata(2) <= U0_gpcs_pma_inst_TXDATA(2);
  txdata(1) <= U0_gpcs_pma_inst_TXDATA(1);
  txdata(0) <= U0_gpcs_pma_inst_TXDATA(0);
  gmii_rxd(7) <= U0_gpcs_pma_inst_RECEIVER_RXD(7);
  gmii_rxd(6) <= U0_gpcs_pma_inst_RECEIVER_RXD(6);
  gmii_rxd(5) <= U0_gpcs_pma_inst_RECEIVER_RXD(5);
  gmii_rxd(4) <= U0_gpcs_pma_inst_RECEIVER_RXD(4);
  gmii_rxd(3) <= U0_gpcs_pma_inst_RECEIVER_RXD(3);
  gmii_rxd(2) <= U0_gpcs_pma_inst_RECEIVER_RXD(2);
  gmii_rxd(1) <= U0_gpcs_pma_inst_RECEIVER_RXD(1);
  gmii_rxd(0) <= U0_gpcs_pma_inst_RECEIVER_RXD(0);
  status_vector(15) <= NlwRenamedSig_OI_status_vector(7);
  status_vector(14) <= NlwRenamedSig_OI_status_vector(7);
  status_vector(13) <= NlwRenamedSig_OI_status_vector(7);
  status_vector(12) <= NlwRenamedSig_OI_status_vector(7);
  status_vector(11) <= NlwRenamedSig_OI_status_vector(7);
  status_vector(10) <= NlwRenamedSig_OI_status_vector(7);
  status_vector(9) <= NlwRenamedSig_OI_status_vector(7);
  status_vector(8) <= NlwRenamedSig_OI_status_vector(7);
  status_vector(7) <= NlwRenamedSig_OI_status_vector(7);
  status_vector(6) <= U0_gpcs_pma_inst_RXNOTINTABLE_REG_60;
  status_vector(5) <= U0_gpcs_pma_inst_RXDISPERR_REG_61;
  status_vector(4) <= NlwRenamedSig_OI_U0_gpcs_pma_inst_RECEIVER_RX_INVALID;
  status_vector(3) <= U0_gpcs_pma_inst_RECEIVER_RUDI_I_63;
  status_vector(2) <= U0_gpcs_pma_inst_RECEIVER_RUDI_C_64;
  status_vector(1) <= NlwRenamedSignal_U0_gpcs_pma_inst_STATUS_VECTOR_0;
  status_vector(0) <= NlwRenamedSignal_U0_gpcs_pma_inst_STATUS_VECTOR_0;
  mgt_rx_reset <= NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT;
  mgt_tx_reset <= NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT;
  powerdown <= NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_POWERDOWN_REG;
  txchardispmode <= U0_gpcs_pma_inst_TXCHARDISPMODE_69;
  txchardispval <= U0_gpcs_pma_inst_TXCHARDISPVAL_70;
  txcharisk <= U0_gpcs_pma_inst_TXCHARISK_71;
  enablealign <= NlwRenamedSig_OI_U0_gpcs_pma_inst_SYNCHRONISATION_ENCOMMAALIGN;
  gmii_rx_dv <= NlwRenamedSig_OI_U0_gpcs_pma_inst_RECEIVER_RX_DV;
  gmii_rx_er <= U0_gpcs_pma_inst_RECEIVER_RX_ER_74;
  gmii_isolate <= NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG;
  mdio_out <= U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_OUT_76;
  mdio_tri <= U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_TRI_77;
  XST_VCC : VCC
    port map (
      P => N0
    );
  XST_GND : GND
    port map (
      G => NlwRenamedSig_OI_status_vector(7)
    );
  U0_gpcs_pma_inst_DELAY_RXNOTINTABLE : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => NlwRenamedSig_OI_status_vector(7),
      A1 => NlwRenamedSig_OI_status_vector(7),
      A2 => N0,
      A3 => NlwRenamedSig_OI_status_vector(7),
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RXNOTINTABLE_INT_115,
      Q => U0_gpcs_pma_inst_RXNOTINTABLE_SRL
    );
  U0_gpcs_pma_inst_DELAY_RXDISPERR : SRL16
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => NlwRenamedSig_OI_status_vector(7),
      A1 => NlwRenamedSig_OI_status_vector(7),
      A2 => N0,
      A3 => NlwRenamedSig_OI_status_vector(7),
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RXDISPERR_INT_116,
      Q => U0_gpcs_pma_inst_RXDISPERR_SRL
    );
  U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd2 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd2_In,
      R => U0_gpcs_pma_inst_RESET_INT_RXBUFSTATUS_INT_1_OR_126_o,
      Q => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd2_80
    );
  U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd3 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd3_In,
      R => U0_gpcs_pma_inst_RESET_INT_RXBUFSTATUS_INT_1_OR_126_o,
      Q => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd3_81
    );
  U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd1_In,
      R => U0_gpcs_pma_inst_RESET_INT_RXBUFSTATUS_INT_1_OR_126_o,
      Q => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd1_79
    );
  U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd1_In,
      R => U0_gpcs_pma_inst_RESET_INT_TXBUFERR_INT_OR_125_o,
      Q => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd1_86
    );
  U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd2 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd2_In,
      R => U0_gpcs_pma_inst_RESET_INT_TXBUFERR_INT_OR_125_o,
      Q => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd2_87
    );
  U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd3 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd3_In,
      R => U0_gpcs_pma_inst_RESET_INT_TXBUFERR_INT_OR_125_o,
      Q => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd3_88
    );
  U0_gpcs_pma_inst_SYNC_SIGNAL_DETECT_data_sync : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => signal_detect,
      Q => U0_gpcs_pma_inst_SYNC_SIGNAL_DETECT_data_sync1
    );
  U0_gpcs_pma_inst_SYNC_SIGNAL_DETECT_data_sync_reg : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_SYNC_SIGNAL_DETECT_data_sync1,
      Q => U0_gpcs_pma_inst_SIGNAL_DETECT_REG
    );
  U0_gpcs_pma_inst_TXCHARDISPVAL : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TXCHARDISPVAL_INT_GND_15_o_MUX_288_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TXCHARDISPVAL_70
    );
  U0_gpcs_pma_inst_TXCHARDISPMODE : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TXCHARDISPMODE_INT_TXEVEN_MUX_287_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TXCHARDISPMODE_69
    );
  U0_gpcs_pma_inst_TXCHARISK : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TXCHARISK_INT_TXEVEN_MUX_286_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TXCHARISK_71
    );
  U0_gpcs_pma_inst_RXCLKCORCNT_INT_2 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXCLKCORCNT_2_GND_15_o_mux_18_OUT_2_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXCLKCORCNT_INT(2)
    );
  U0_gpcs_pma_inst_RXCLKCORCNT_INT_1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXCLKCORCNT_2_GND_15_o_mux_18_OUT_1_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXCLKCORCNT_INT(1)
    );
  U0_gpcs_pma_inst_RXCLKCORCNT_INT_0 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXCLKCORCNT_2_GND_15_o_mux_18_OUT_0_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXCLKCORCNT_INT(0)
    );
  U0_gpcs_pma_inst_TXDATA_7 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_7_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TXDATA(7)
    );
  U0_gpcs_pma_inst_TXDATA_6 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_6_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TXDATA(6)
    );
  U0_gpcs_pma_inst_TXDATA_5 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_5_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TXDATA(5)
    );
  U0_gpcs_pma_inst_TXDATA_4 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_4_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TXDATA(4)
    );
  U0_gpcs_pma_inst_TXDATA_3 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_3_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TXDATA(3)
    );
  U0_gpcs_pma_inst_TXDATA_2 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_2_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TXDATA(2)
    );
  U0_gpcs_pma_inst_TXDATA_1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_1_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TXDATA(1)
    );
  U0_gpcs_pma_inst_TXDATA_0 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_0_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TXDATA(0)
    );
  U0_gpcs_pma_inst_RXDATA_INT_7 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_7_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXDATA_INT(7)
    );
  U0_gpcs_pma_inst_RXDATA_INT_6 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_6_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXDATA_INT(6)
    );
  U0_gpcs_pma_inst_RXDATA_INT_5 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_5_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXDATA_INT(5)
    );
  U0_gpcs_pma_inst_RXDATA_INT_4 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_4_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXDATA_INT(4)
    );
  U0_gpcs_pma_inst_RXDATA_INT_3 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_3_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXDATA_INT(3)
    );
  U0_gpcs_pma_inst_RXDATA_INT_2 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_2_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXDATA_INT(2)
    );
  U0_gpcs_pma_inst_RXDATA_INT_1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_1_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXDATA_INT(1)
    );
  U0_gpcs_pma_inst_RXDATA_INT_0 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_0_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXDATA_INT(0)
    );
  U0_gpcs_pma_inst_RXCHARISK_INT : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXCHARISK_0_TXCHARISK_INT_MUX_279_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXCHARISK_INT_125
    );
  U0_gpcs_pma_inst_RXCHARISCOMMA_INT : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXCHARISCOMMA_0_TXCHARISK_INT_MUX_280_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXCHARISCOMMA_INT_126
    );
  U0_gpcs_pma_inst_RXNOTINTABLE_REG : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXNOTINTABLE_SRL,
      Q => U0_gpcs_pma_inst_RXNOTINTABLE_REG_60
    );
  U0_gpcs_pma_inst_RXDISPERR_REG : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXDISPERR_SRL,
      Q => U0_gpcs_pma_inst_RXDISPERR_REG_61
    );
  U0_gpcs_pma_inst_SRESET : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_SRESET_PIPE_PWR_15_o_MUX_1_o,
      Q => U0_gpcs_pma_inst_SRESET_127
    );
  U0_gpcs_pma_inst_TXBUFERR_INT : FDR
    port map (
      C => userclk2,
      D => txbuferr,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TXBUFERR_INT_110
    );
  U0_gpcs_pma_inst_RXBUFSTATUS_INT_1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXBUFSTATUS_1_GND_15_o_mux_17_OUT_1_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXBUFSTATUS_INT(1)
    );
  U0_gpcs_pma_inst_RXNOTINTABLE_INT : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXNOTINTABLE_0_GND_15_o_MUX_276_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXNOTINTABLE_INT_115
    );
  U0_gpcs_pma_inst_RXDISPERR_INT : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXDISPERR_0_GND_15_o_MUX_277_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RXDISPERR_INT_116
    );
  U0_gpcs_pma_inst_SRESET_PIPE : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RESET_INT_134,
      Q => U0_gpcs_pma_inst_SRESET_PIPE_128
    );
  U0_gpcs_pma_inst_MGT_RX_RESET_INT : FDS
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RX_RST_SM_3_GND_15_o_Mux_13_o,
      S => U0_gpcs_pma_inst_RESET_INT_RXBUFSTATUS_INT_1_OR_126_o,
      Q => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT
    );
  U0_gpcs_pma_inst_MGT_TX_RESET_INT : FDS
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TX_RST_SM_3_GND_15_o_Mux_9_o,
      S => U0_gpcs_pma_inst_RESET_INT_TXBUFERR_INT_OR_125_o,
      Q => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT
    );
  U0_gpcs_pma_inst_RESET_INT : FDP
    port map (
      C => userclk,
      D => U0_gpcs_pma_inst_RESET_INT_PIPE_133,
      PRE => U0_gpcs_pma_inst_DCM_LOCKED_SOFT_RESET_OR_2_o,
      Q => U0_gpcs_pma_inst_RESET_INT_134
    );
  U0_gpcs_pma_inst_RESET_INT_PIPE : FDP
    port map (
      C => userclk,
      D => NlwRenamedSig_OI_status_vector(7),
      PRE => U0_gpcs_pma_inst_DCM_LOCKED_SOFT_RESET_OR_2_o,
      Q => U0_gpcs_pma_inst_RESET_INT_PIPE_133
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT_1 : FDS
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_Result(1),
      S => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(1)
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT_0 : FDS
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_Result(0),
      S => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXDATA_7 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_7_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(7)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXDATA_6 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_6_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(6)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXDATA_5 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_5_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(5)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXDATA_4 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_4_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(4)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXDATA_3 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_3_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(3)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXDATA_2 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_2_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(2)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXDATA_1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_1_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(1)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXDATA_0 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_0_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(0)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXCHARISK : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRPISK_GND_26_o_MUX_192_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXCHARISK_141
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_7_Q,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(7)
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_6 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_6_Q,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(6)
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_5 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_5_Q,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(5)
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_4 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_4_Q,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(4)
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_3 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_3_Q,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(3)
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_2 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_2_Q,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(2)
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_1 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_1_Q,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(1)
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_0 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_0_Q,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(0)
    );
  U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_CODE_GRP_CNT_1_MUX_186_o,
      Q => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205
    );
  U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT : FDSE
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_TRANSMITTER_Mram_CODE_GRP_CNT_1_GND_26_o_Mux_5_o,
      D => NlwRenamedSig_OI_status_vector(7),
      S => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT_200
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXCHARDISPMODE : FDS
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_EVEN_AND_59_o,
      S => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXCHARDISPMODE_140
    );
  U0_gpcs_pma_inst_TRANSMITTER_XMIT_DATA_INT : FDRE
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_TRANSMITTER_Mram_CODE_GRP_CNT_1_GND_26_o_Mux_5_o,
      D => N0,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_XMIT_DATA_INT_201
    );
  U0_gpcs_pma_inst_TRANSMITTER_TRIGGER_S : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_EVEN_AND_25_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TRIGGER_S_208
    );
  U0_gpcs_pma_inst_TRANSMITTER_T : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_TRIGGER_T_OR_27_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_T_207
    );
  U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA_3 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_Mram_CODE_GRP_CNT_1_GND_26_o_Mux_5_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA(3)
    );
  U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA_2 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT_1_TX_CONFIG_15_wide_mux_4_OUT_7_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA(2)
    );
  U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA_1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_n0235(1),
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA(1)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TX_ER_REG1 : FD
    port map (
      C => userclk2,
      D => gmii_tx_er,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TX_ER_REG1_222
    );
  U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1 : FD
    port map (
      C => userclk2,
      D => gmii_tx_en,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_223
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1_7 : FD
    port map (
      C => userclk2,
      D => gmii_txd(7),
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(7)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1_6 : FD
    port map (
      C => userclk2,
      D => gmii_txd(6),
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(6)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1_5 : FD
    port map (
      C => userclk2,
      D => gmii_txd(5),
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(5)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1_4 : FD
    port map (
      C => userclk2,
      D => gmii_txd(4),
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(4)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1_3 : FD
    port map (
      C => userclk2,
      D => gmii_txd(3),
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(3)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1_2 : FD
    port map (
      C => userclk2,
      D => gmii_txd(2),
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(2)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1_1 : FD
    port map (
      C => userclk2,
      D => gmii_txd(1),
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(1)
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1_0 : FD
    port map (
      C => userclk2,
      D => gmii_txd(0),
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(0)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_SYNC_MDC_data_sync : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => mdc,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_SYNC_MDC_data_sync1
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_SYNC_MDC_data_sync_reg : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_SYNC_MDC_data_sync1,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_REG2
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_SYNC_MDIO_IN_data_sync : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => mdio_in,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_SYNC_MDIO_IN_data_sync1
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_SYNC_MDIO_IN_data_sync_reg : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_SYNC_MDIO_IN_data_sync1,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_IN_REG2
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_IN_REG4 : FDS
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_IN_REG3_244,
      S => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_IN_REG4_243
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG : FDSE
    generic map(
      INIT => '1'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_n0162_inv,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG_DATA_WR_10_MUX_124_o,
      S => U0_gpcs_pma_inst_SRESET_127,
      Q => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_UNIDIRECTIONAL_ENABLE_REG : FDRE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_n0162_inv,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_UNIDIRECTIONAL_ENABLE_REG_DATA_WR_5_MUX_126_o,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_UNIDIRECTIONAL_ENABLE_REG_242
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG : FDRE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_n0162_inv,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_DATA_WR_14_MUX_120_o,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_IN_REG3 : FDS
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_IN_REG2,
      S => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_IN_REG3_244
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_REG3 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_REG2,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_REG3_245
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_CONFIGURATION_VALID_EN_REG : FDR
    port map (
      C => userclk2,
      D => configuration_valid,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_CONFIGURATION_VALID_EN_REG_246
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT_3 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0141_inv,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT3,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(3)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT_2 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0141_inv,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT2,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(2)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT_1 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0141_inv,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT1,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(1)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT_0 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0141_inv,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(0)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_In,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_In,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In_281,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_TRI : FDSE
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_3_PWR_20_o_Mux_37_o,
      S => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_TRI_77
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_OUT : FDSE
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_3_PWR_20_o_Mux_36_o,
      S => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_OUT_76
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG3 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG2_308,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG3_250
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_OPCODE_1 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0147_inv_283,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(1),
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_OPCODE(1)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_OPCODE_0 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0147_inv_283,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(0),
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_OPCODE(0)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR_4 : FDRE
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0155_inv,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(3),
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR(4)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR_3 : FDRE
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0155_inv,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(2),
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR(3)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR_2 : FDRE
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0155_inv,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(1),
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR(2)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR_1 : FDRE
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0155_inv,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(0),
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR(1)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR_0 : FDRE
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0155_inv,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR(0)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG1_309,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG2_308
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_LAST_DATA_SHIFT : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG1_PWR_20_o_AND_3_o,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_LAST_DATA_SHIFT_302
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_15 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_15_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(15)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_14_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(14)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_13 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_13_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(13)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_12 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_12_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(12)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_11 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_11_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(11)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_10 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_10_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(10)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_9 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_9_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(9)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_8 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_8_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(8)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_7 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_7_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(7)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_6 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_6_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(6)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_5 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_5_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(5)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_4 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_4_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(4)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_3 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_3_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(3)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_2 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_2_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(2)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_1 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_1_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(1)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_0 : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_0_Q,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(0)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG : FDSE
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_IN_REG4_243,
      S => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG1_309
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_In2,
      R => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_In1_0,
      Q => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_327
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_In2,
      R => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_In1_0,
      Q => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_In2_331,
      R => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_In1_0,
      Q => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_In3,
      R => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_In1_0,
      Q => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_1 : FDRE
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_SYNCHRONISATION_n0103_inv,
      D => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_1_GND_27_o_mux_30_OUT_1_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS(1)
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_0 : FDRE
    port map (
      C => userclk2,
      CE => U0_gpcs_pma_inst_SYNCHRONISATION_n0103_inv,
      D => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_1_GND_27_o_mux_30_OUT_0_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS(0)
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_SIGNAL_DETECT_REG : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_SIGNAL_DETECT_REG,
      Q => U0_gpcs_pma_inst_SYNCHRONISATION_SIGNAL_DETECT_REG_343
    );
  U0_gpcs_pma_inst_RECEIVER_RXD_7 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_7_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      Q => U0_gpcs_pma_inst_RECEIVER_RXD(7)
    );
  U0_gpcs_pma_inst_RECEIVER_RXD_6 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_6_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      Q => U0_gpcs_pma_inst_RECEIVER_RXD(6)
    );
  U0_gpcs_pma_inst_RECEIVER_RXD_5 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_5_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      Q => U0_gpcs_pma_inst_RECEIVER_RXD(5)
    );
  U0_gpcs_pma_inst_RECEIVER_RXD_4 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_4_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      Q => U0_gpcs_pma_inst_RECEIVER_RXD(4)
    );
  U0_gpcs_pma_inst_RECEIVER_RXD_3 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_3_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      Q => U0_gpcs_pma_inst_RECEIVER_RXD(3)
    );
  U0_gpcs_pma_inst_RECEIVER_RXD_2 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_2_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      Q => U0_gpcs_pma_inst_RECEIVER_RXD(2)
    );
  U0_gpcs_pma_inst_RECEIVER_RXD_1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_1_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      Q => U0_gpcs_pma_inst_RECEIVER_RXD(1)
    );
  U0_gpcs_pma_inst_RECEIVER_RXD_0 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_0_Q,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      Q => U0_gpcs_pma_inst_RECEIVER_RXD(0)
    );
  U0_gpcs_pma_inst_RECEIVER_C_REG3 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_C_REG2_346,
      Q => U0_gpcs_pma_inst_RECEIVER_C_REG3_427
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG3 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG2,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG3_405
    );
  U0_gpcs_pma_inst_RECEIVER_CGBAD_REG3 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_CGBAD_REG2,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_CGBAD_REG3_408
    );
  U0_gpcs_pma_inst_RECEIVER_SOP_REG3 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_SOP_REG2_422,
      Q => U0_gpcs_pma_inst_RECEIVER_SOP_REG3_421
    );
  U0_gpcs_pma_inst_RECEIVER_C_REG2 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_C_REG1_428,
      Q => U0_gpcs_pma_inst_RECEIVER_C_REG2_346
    );
  U0_gpcs_pma_inst_RECEIVER_IDLE_REG_2 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_IDLE_REG(1),
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_IDLE_REG(2)
    );
  U0_gpcs_pma_inst_RECEIVER_IDLE_REG_1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_IDLE_REG(0),
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_IDLE_REG(1)
    );
  U0_gpcs_pma_inst_RECEIVER_IDLE_REG_0 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_I_REG_429,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_IDLE_REG(0)
    );
  U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_REG2 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_REG1_393,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_REG2_392
    );
  U0_gpcs_pma_inst_RECEIVER_ILLEGAL_K_REG2 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_ILLEGAL_K_REG1_397,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => U0_gpcs_pma_inst_RECEIVER_ILLEGAL_K_REG2_396
    );
  U0_gpcs_pma_inst_RECEIVER_C_REG1 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_C_435,
      Q => U0_gpcs_pma_inst_RECEIVER_C_REG1_428
    );
  U0_gpcs_pma_inst_RECEIVER_T_REG2 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_T_REG1_432,
      Q => U0_gpcs_pma_inst_RECEIVER_T_REG2_431
    );
  U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG_3 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG(2),
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG(3)
    );
  U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG_2 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG(1),
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG(2)
    );
  U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG_1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG(0),
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG(1)
    );
  U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG_0 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_INT_407,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG(0)
    );
  U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_REG1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_394,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_REG1_393
    );
  U0_gpcs_pma_inst_RECEIVER_ILLEGAL_K_REG1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_ILLEGAL_K_398,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => U0_gpcs_pma_inst_RECEIVER_ILLEGAL_K_REG1_397
    );
  U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_EXTEND_378,
      Q => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420
    );
  U0_gpcs_pma_inst_RECEIVER_I_REG : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_I_436,
      Q => U0_gpcs_pma_inst_RECEIVER_I_REG_429
    );
  U0_gpcs_pma_inst_RECEIVER_R_REG1 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_R_410,
      Q => U0_gpcs_pma_inst_RECEIVER_R_REG1_430
    );
  U0_gpcs_pma_inst_RECEIVER_T_REG1 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_T_437,
      Q => U0_gpcs_pma_inst_RECEIVER_T_REG1_432
    );
  U0_gpcs_pma_inst_RECEIVER_RUDI_I : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_IDLE_REG_1_IDLE_REG_2_OR_124_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_RUDI_I_63
    );
  U0_gpcs_pma_inst_RECEIVER_RUDI_C : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG_0_RX_CONFIG_VALID_REG_3_OR_123_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_RUDI_C_64
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_K : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RXDATA_7_RXNOTINTABLE_AND_228_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_FALSE_K_390
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_DATA : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_391
    );
  U0_gpcs_pma_inst_RECEIVER_RX_ER : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_ISOLATE_AND_199_o_367,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_RX_ER_74
    );
  U0_gpcs_pma_inst_RECEIVER_EXTEND_ERR : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG3_EXT_ILLEGAL_K_REG2_OR_93_o,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => U0_gpcs_pma_inst_RECEIVER_EXTEND_ERR_395
    );
  U0_gpcs_pma_inst_RECEIVER_ILLEGAL_K : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RXCHARISK_REG1_K28p5_REG1_AND_184_o,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => U0_gpcs_pma_inst_RECEIVER_ILLEGAL_K_398
    );
  U0_gpcs_pma_inst_RECEIVER_EOP : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_I_REG_T_REG2_OR_74_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_EOP_401
    );
  U0_gpcs_pma_inst_RECEIVER_SOP : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_S_WAIT_FOR_K_AND_161_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_SOP_402
    );
  U0_gpcs_pma_inst_RECEIVER_EOP_REG1 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_EOP_EXTEND_OR_75_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_EOP_REG1_400
    );
  U0_gpcs_pma_inst_RECEIVER_FROM_RX_CX : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_C_REG1_C_REG3_OR_69_o_350,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => U0_gpcs_pma_inst_RECEIVER_FROM_RX_CX_403
    );
  U0_gpcs_pma_inst_RECEIVER_SYNC_STATUS_REG : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => U0_gpcs_pma_inst_RECEIVER_SYNC_STATUS_REG_406
    );
  U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_INT : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_SYNC_STATUS_C_REG1_AND_142_o_368,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_INT_407
    );
  U0_gpcs_pma_inst_RECEIVER_R : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_K23p7,
      Q => U0_gpcs_pma_inst_RECEIVER_R_410
    );
  U0_gpcs_pma_inst_RECEIVER_CGBAD : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RXFIFO_ERR_RXDISPERR_OR_46_o,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_RECEIVER_CGBAD_409
    );
  U0_gpcs_pma_inst_RECEIVER_RXCHARISK_REG1 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RXCHARISK_INT_125,
      Q => U0_gpcs_pma_inst_RECEIVER_RXCHARISK_REG1_426
    );
  U0_gpcs_pma_inst_RECEIVER_D0p0_REG : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_D0p0_352,
      Q => U0_gpcs_pma_inst_RECEIVER_D0p0_REG_433
    );
  U0_gpcs_pma_inst_RECEIVER_K28p5_REG1 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_K28p5,
      Q => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434
    );
  U0_gpcs_pma_inst_RECEIVER_I : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_EVEN_RXCHARISK_AND_132_o_369,
      Q => U0_gpcs_pma_inst_RECEIVER_I_436
    );
  U0_gpcs_pma_inst_RECEIVER_S : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_K27p7_RXFIFO_ERR_AND_128_o,
      Q => U0_gpcs_pma_inst_RECEIVER_S_438
    );
  U0_gpcs_pma_inst_RECEIVER_T : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_K29p7,
      Q => U0_gpcs_pma_inst_RECEIVER_T_437
    );
  U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd2_In1 : LUT4
    generic map(
      INIT => X"EA6A"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd2_87,
      I1 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd4_89,
      I2 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd3_88,
      I3 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd1_86,
      O => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd2_In
    );
  U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd2_In1 : LUT4
    generic map(
      INIT => X"EA6A"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd2_80,
      I1 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd4_82,
      I2 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd3_81,
      I3 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd1_79,
      O => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd2_In
    );
  U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd3_In1 : LUT4
    generic map(
      INIT => X"E666"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd3_81,
      I1 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd4_82,
      I2 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd1_79,
      I3 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd2_80,
      O => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd3_In
    );
  U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd3_In1 : LUT4
    generic map(
      INIT => X"E666"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd3_88,
      I1 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd4_89,
      I2 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd1_86,
      I3 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd2_87,
      O => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd3_In
    );
  U0_gpcs_pma_inst_Mmux_TXCHARDISPVAL_INT_GND_15_o_MUX_288_o11 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXCHARDISPVAL_139,
      O => U0_gpcs_pma_inst_TXCHARDISPVAL_INT_GND_15_o_MUX_288_o
    );
  U0_gpcs_pma_inst_Mmux_TXCHARDISPMODE_INT_TXEVEN_MUX_287_o11 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXCHARDISPMODE_140,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TXCHARDISPMODE_INT_TXEVEN_MUX_287_o
    );
  U0_gpcs_pma_inst_Mmux_TXCHARISK_INT_TXEVEN_MUX_286_o11 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXCHARISK_141,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TXCHARISK_INT_TXEVEN_MUX_286_o
    );
  U0_gpcs_pma_inst_Mmux_TXDATA_INT_7_GND_15_o_mux_26_OUT11 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(0),
      O => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_0_Q
    );
  U0_gpcs_pma_inst_Mmux_TXDATA_INT_7_GND_15_o_mux_26_OUT21 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(1),
      O => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_1_Q
    );
  U0_gpcs_pma_inst_Mmux_TXDATA_INT_7_GND_15_o_mux_26_OUT31 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(2),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_2_Q
    );
  U0_gpcs_pma_inst_Mmux_TXDATA_INT_7_GND_15_o_mux_26_OUT41 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(3),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_3_Q
    );
  U0_gpcs_pma_inst_Mmux_TXDATA_INT_7_GND_15_o_mux_26_OUT51 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(4),
      O => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_4_Q
    );
  U0_gpcs_pma_inst_Mmux_TXDATA_INT_7_GND_15_o_mux_26_OUT61 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(5),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_5_Q
    );
  U0_gpcs_pma_inst_Mmux_TXDATA_INT_7_GND_15_o_mux_26_OUT71 : LUT3
    generic map(
      INIT => X"4E"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(6),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_6_Q
    );
  U0_gpcs_pma_inst_Mmux_TXDATA_INT_7_GND_15_o_mux_26_OUT81 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(7),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TXDATA_INT_7_GND_15_o_mux_26_OUT_7_Q
    );
  U0_gpcs_pma_inst_Mmux_RXDATA_7_TXDATA_INT_7_mux_16_OUT11 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxdata(0),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(0),
      O => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_0_Q
    );
  U0_gpcs_pma_inst_Mmux_RXDATA_7_TXDATA_INT_7_mux_16_OUT21 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxdata(1),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(1),
      O => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_1_Q
    );
  U0_gpcs_pma_inst_Mmux_RXDATA_7_TXDATA_INT_7_mux_16_OUT31 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxdata(2),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(2),
      O => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_2_Q
    );
  U0_gpcs_pma_inst_Mmux_RXDATA_7_TXDATA_INT_7_mux_16_OUT41 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxdata(3),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(3),
      O => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_3_Q
    );
  U0_gpcs_pma_inst_Mmux_RXDATA_7_TXDATA_INT_7_mux_16_OUT51 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxdata(4),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(4),
      O => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_4_Q
    );
  U0_gpcs_pma_inst_Mmux_RXDATA_7_TXDATA_INT_7_mux_16_OUT61 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxdata(5),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(5),
      O => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_5_Q
    );
  U0_gpcs_pma_inst_Mmux_RXDATA_7_TXDATA_INT_7_mux_16_OUT71 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxdata(6),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(6),
      O => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_6_Q
    );
  U0_gpcs_pma_inst_Mmux_RXDATA_7_TXDATA_INT_7_mux_16_OUT81 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxdata(7),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TXDATA(7),
      O => U0_gpcs_pma_inst_RXDATA_7_TXDATA_INT_7_mux_16_OUT_7_Q
    );
  U0_gpcs_pma_inst_Mmux_RXCHARISCOMMA_0_TXCHARISK_INT_MUX_280_o11 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxchariscomma(0),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TXCHARISK_141,
      O => U0_gpcs_pma_inst_RXCHARISCOMMA_0_TXCHARISK_INT_MUX_280_o
    );
  U0_gpcs_pma_inst_Mmux_RXCHARISK_0_TXCHARISK_INT_MUX_279_o11 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxcharisk(0),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TXCHARISK_141,
      O => U0_gpcs_pma_inst_RXCHARISK_0_TXCHARISK_INT_MUX_279_o
    );
  U0_gpcs_pma_inst_Mmux_RXNOTINTABLE_0_GND_15_o_MUX_276_o11 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxnotintable(0),
      O => U0_gpcs_pma_inst_RXNOTINTABLE_0_GND_15_o_MUX_276_o
    );
  U0_gpcs_pma_inst_Mmux_RXDISPERR_0_GND_15_o_MUX_277_o11 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxdisperr(0),
      O => U0_gpcs_pma_inst_RXDISPERR_0_GND_15_o_MUX_277_o
    );
  U0_gpcs_pma_inst_Mmux_RXCLKCORCNT_2_GND_15_o_mux_18_OUT11 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxclkcorcnt(0),
      O => U0_gpcs_pma_inst_RXCLKCORCNT_2_GND_15_o_mux_18_OUT_0_Q
    );
  U0_gpcs_pma_inst_Mmux_RXCLKCORCNT_2_GND_15_o_mux_18_OUT21 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxclkcorcnt(1),
      O => U0_gpcs_pma_inst_RXCLKCORCNT_2_GND_15_o_mux_18_OUT_1_Q
    );
  U0_gpcs_pma_inst_Mmux_RXCLKCORCNT_2_GND_15_o_mux_18_OUT31 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxclkcorcnt(2),
      O => U0_gpcs_pma_inst_RXCLKCORCNT_2_GND_15_o_mux_18_OUT_2_Q
    );
  U0_gpcs_pma_inst_Mmux_RXBUFSTATUS_1_GND_15_o_mux_17_OUT21 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I1 => rxbufstatus(1),
      O => U0_gpcs_pma_inst_RXBUFSTATUS_1_GND_15_o_mux_17_OUT_1_Q
    );
  U0_gpcs_pma_inst_Mmux_SRESET_PIPE_PWR_15_o_MUX_1_o11 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RESET_INT_134,
      I1 => U0_gpcs_pma_inst_SRESET_PIPE_128,
      O => U0_gpcs_pma_inst_SRESET_PIPE_PWR_15_o_MUX_1_o
    );
  U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd1_In1 : LUT4
    generic map(
      INIT => X"FF80"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd4_82,
      I1 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd3_81,
      I2 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd2_80,
      I3 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd1_79,
      O => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd1_In
    );
  U0_gpcs_pma_inst_RX_RST_SM_RX_RST_SM_3_GND_15_o_Mux_13_o1 : LUT4
    generic map(
      INIT => X"DFFF"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd3_81,
      I1 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd4_82,
      I2 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd1_79,
      I3 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd2_80,
      O => U0_gpcs_pma_inst_RX_RST_SM_3_GND_15_o_Mux_13_o
    );
  U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd1_In1 : LUT4
    generic map(
      INIT => X"FF80"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd4_89,
      I1 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd3_88,
      I2 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd2_87,
      I3 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd1_86,
      O => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd1_In
    );
  U0_gpcs_pma_inst_TX_RST_SM_TX_RST_SM_3_GND_15_o_Mux_9_o1 : LUT4
    generic map(
      INIT => X"DFFF"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd3_88,
      I1 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd4_89,
      I2 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd1_86,
      I3 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd2_87,
      O => U0_gpcs_pma_inst_TX_RST_SM_3_GND_15_o_Mux_9_o
    );
  U0_gpcs_pma_inst_RESET_INT_RXBUFSTATUS_INT_1_OR_126_o1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RESET_INT_134,
      I1 => U0_gpcs_pma_inst_RXBUFSTATUS_INT(1),
      O => U0_gpcs_pma_inst_RESET_INT_RXBUFSTATUS_INT_1_OR_126_o
    );
  U0_gpcs_pma_inst_RESET_INT_TXBUFERR_INT_OR_125_o1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RESET_INT_134,
      I1 => U0_gpcs_pma_inst_TXBUFERR_INT_110,
      O => U0_gpcs_pma_inst_RESET_INT_TXBUFERR_INT_OR_125_o
    );
  U0_gpcs_pma_inst_DCM_LOCKED_SOFT_RESET_OR_2_o1 : LUT3
    generic map(
      INIT => X"FB"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_RESET_REG_138,
      I1 => dcm_locked,
      I2 => reset,
      O => U0_gpcs_pma_inst_DCM_LOCKED_SOFT_RESET_OR_2_o
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT51 : LUT4
    generic map(
      INIT => X"FE54"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT_200,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT511,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(4),
      I3 => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA(2),
      O => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_4_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT61 : LUT4
    generic map(
      INIT => X"FE54"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT_200,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT511,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(5),
      I3 => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA(2),
      O => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_5_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT81 : LUT4
    generic map(
      INIT => X"FE54"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT_200,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT511,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(7),
      I3 => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA(2),
      O => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_7_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT5111 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFEFFFF"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_T_207,
      I1 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_V_197,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_S_209,
      I4 => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199,
      I5 => U0_gpcs_pma_inst_TRANSMITTER_R_198,
      O => U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT511
    );
  U0_gpcs_pma_inst_TRANSMITTER_DISP51 : LUT5
    generic map(
      INIT => X"E881811F"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(3),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(4),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(1),
      I3 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(2),
      I4 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(0),
      O => U0_gpcs_pma_inst_TRANSMITTER_DISP5
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT_1_TX_CONFIG_15_wide_mux_4_OUT_7_1 : LUT3
    generic map(
      INIT => X"15"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(1),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_C1_OR_C2_202,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT_1_TX_CONFIG_15_wide_mux_4_OUT_7_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_TX_EN_TRIGGER_T_OR_27_o1 : LUT6
    generic map(
      INIT => X"FFFF444044404440"
    )
    port map (
      I0 => gmii_tx_en,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_223,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_S_209,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199,
      I4 => U0_gpcs_pma_inst_TRANSMITTER_TRIGGER_T_206,
      I5 => U0_gpcs_pma_inst_TRANSMITTER_V_197,
      O => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_TRIGGER_T_OR_27_o
    );
  U0_gpcs_pma_inst_TRANSMITTER_TX_EN_TRIGGER_S_OR_25_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFF45455545"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_TRIGGER_S_208,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_223,
      I2 => gmii_tx_en,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      I4 => U0_gpcs_pma_inst_TRANSMITTER_TX_ER_REG1_222,
      I5 => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      O => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_TRIGGER_S_OR_25_o_0
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mcount_CODE_GRP_CNT_xor_1_11 : LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(1),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TRANSMITTER_Result(1)
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mram_CODE_GRP_CNT_1_GND_26_o_Mux_5_o1 : LUT2
    generic map(
      INIT => X"1"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(1),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TRANSMITTER_Mram_CODE_GRP_CNT_1_GND_26_o_Mux_5_o
    );
  U0_gpcs_pma_inst_TRANSMITTER_TX_EN_EVEN_AND_25_o1 : LUT4
    generic map(
      INIT => X"0040"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_TX_ER_REG1_222,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      I2 => gmii_tx_en,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_223,
      O => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_EVEN_AND_25_o
    );
  U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_EVEN_AND_59_o1 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205,
      O => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_EVEN_AND_59_o
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_Mmux_DATA_RD511 : LUT4
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(3),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(2),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(1),
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(0),
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_DATA_RD(6)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_n0162_inv1 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_CONFIGURATION_VALID_EN_247,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG3_250,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_GND_22_o_MDIO_WE_AND_14_o,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_n0162_inv
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_Mmux_UNIDIRECTIONAL_ENABLE_REG_DATA_WR_5_MUX_126_o11 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_GND_22_o_MDIO_WE_AND_14_o,
      I1 => configuration_vector(0),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(5),
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_UNIDIRECTIONAL_ENABLE_REG_DATA_WR_5_MUX_126_o
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_Mmux_LOOPBACK_REG_DATA_WR_14_MUX_120_o11 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_GND_22_o_MDIO_WE_AND_14_o,
      I1 => configuration_vector(1),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(14),
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_DATA_WR_14_MUX_120_o
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_Mmux_ISOLATE_REG_DATA_WR_10_MUX_124_o11 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_GND_22_o_MDIO_WE_AND_14_o,
      I1 => configuration_vector(3),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(10),
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG_DATA_WR_10_MUX_124_o
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_GND_22_o_MDIO_WE_AND_14_o1 : LUT6
    generic map(
      INIT => X"0000000000000002"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_WE_249,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR(4),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR(3),
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR(2),
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR(1),
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDR_WR(0),
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_GND_22_o_MDIO_WE_AND_14_o
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT_xor_2_11 : LUT6
    generic map(
      INIT => X"A9A9A9A9FFA9A9A9"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(2),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(1),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(0),
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT2
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT_xor_3_11 : LUT6
    generic map(
      INIT => X"99999999F9980999"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(3),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT_xor_3_14,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT3
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0141_inv1 : LUT6
    generic map(
      INIT => X"AAAAAAAA20022000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In1,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0141_inv
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_In1 : LUT4
    generic map(
      INIT => X"6AAA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_In
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mmux_GND_24_o_GND_24_o_MUX_62_o11 : LUT5
    generic map(
      INIT => X"20000000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_OPCODE(0),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_OPCODE(1),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_307,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_GND_24_o_GND_24_o_MUX_62_o
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB21 : LUT6
    generic map(
      INIT => X"8040201008040200"
    )
    port map (
      I0 => phyad(3),
      I1 => phyad(4),
      I2 => phyad(2),
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(2),
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(3),
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(1),
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB2_271
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mmux_STATE_3_PWR_20_o_Mux_36_o12 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFB4051"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In1,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(15),
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mmux_STATE_3_PWR_20_o_Mux_36_o11_270,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_3_PWR_20_o_Mux_36_o
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mmux_STATE_3_PWR_20_o_Mux_37_o11 : LUT5
    generic map(
      INIT => X"FFFF1011"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In1,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mmux_STATE_3_PWR_20_o_Mux_36_o11_270,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_3_PWR_20_o_Mux_37_o
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_In1 : LUT5
    generic map(
      INIT => X"CAAA8AAA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_In
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In11 : LUT5
    generic map(
      INIT => X"00000400"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(3),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT_xor_3_14,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In1
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT_xor_3_141 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(2),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(0),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(1),
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT_xor_3_14
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1311 : LUT5
    generic map(
      INIT => X"EAAAC000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(6),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_DATA_RD(6),
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In1,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1011,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_7_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1411 : LUT4
    generic map(
      INIT => X"EAC0"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(7),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_DATA_RD(6),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In1,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1011,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_8_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1211 : LUT4
    generic map(
      INIT => X"EAC0"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(5),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_DATA_RD(6),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In1,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1011,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_6_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux11111 : LUT6
    generic map(
      INIT => X"AEAAAAAA0C000000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(4),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_UNIDIRECTIONAL_ENABLE_REG_242,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_DATA_RD(6),
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In1,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1011,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_5_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux811 : LUT6
    generic map(
      INIT => X"EAAAAAAAC0000000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(1),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_DATA_RD(6),
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In1,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1011,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_2_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux511 : LUT6
    generic map(
      INIT => X"BAAAAAAA30000000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(13),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_DATA_RD(6),
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In1,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1011,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_14_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux211 : LUT6
    generic map(
      INIT => X"AEAAAAAA0C000000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(10),
      I1 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_POWERDOWN_REG,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_DATA_RD(6),
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In1,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1011,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_11_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1111 : LUT6
    generic map(
      INIT => X"BAAAAAAA30000000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(9),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      I2 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_DATA_RD(6),
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In1,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1011,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_10_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux10111 : LUT4
    generic map(
      INIT => X"FFF7"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In1,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1011
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG1_PWR_20_o_AND_3_o1 : LUT3
    generic map(
      INIT => X"80"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG1_309,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG1_PWR_20_o_AND_3_o
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_LAST_DATA_SHIFT_302,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_IN_LAST_DATA_SHIFT_OR_9_o
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_Mmux_GOOD_CGS_1_GND_27_o_mux_30_OUT21 : LUT6
    generic map(
      INIT => X"0000577757770000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_327,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328,
      I3 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS(0),
      I5 => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS(1),
      O => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_1_GND_27_o_mux_30_OUT_1_Q
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_n0103_inv1 : LUT5
    generic map(
      INIT => X"A888FFFF"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_327,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329,
      I3 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_n0103_inv
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_Mmux_GOOD_CGS_1_GND_27_o_mux_30_OUT11 : LUT5
    generic map(
      INIT => X"01115555"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS(0),
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_327,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329,
      I3 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_1_GND_27_o_mux_30_OUT_0_Q
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_In21 : LUT6
    generic map(
      INIT => X"F2A8F2AAAA28AA2A"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_327,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328,
      I3 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_1_PWR_23_o_equal_19_o,
      I5 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_In2
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_In1_01 : LUT3
    generic map(
      INIT => X"AB"
    )
    port map (
      I0 => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_LOOPBACK_REG_137,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_SIGNAL_DETECT_REG_343,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_In1_0
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_1_PWR_23_o_equal_19_o_1_1 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS(0),
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS(1),
      O => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_1_PWR_23_o_equal_19_o
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD_GND_27_o_AND_69_o1 : LUT5
    generic map(
      INIT => X"00000008"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329,
      I3 => U0_gpcs_pma_inst_RXCHARISK_INT_125,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD_GND_27_o_AND_69_o
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD1 : LUT5
    generic map(
      INIT => X"FFFEFEFE"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXBUFSTATUS_INT(1),
      I1 => U0_gpcs_pma_inst_RXNOTINTABLE_INT_115,
      I2 => U0_gpcs_pma_inst_RXDISPERR_INT_116,
      I3 => U0_gpcs_pma_inst_RXCHARISCOMMA_INT_126,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_130,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD
    );
  U0_gpcs_pma_inst_RECEIVER_Mmux_RXDATA_REG5_7_GND_28_o_mux_9_OUT21 : LUT4
    generic map(
      INIT => X"5554"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_SOP_REG3_421,
      I1 => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420,
      I2 => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG3_405,
      I3 => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(1),
      O => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_1_Q
    );
  U0_gpcs_pma_inst_RECEIVER_Mmux_RXDATA_REG5_7_GND_28_o_mux_9_OUT41 : LUT4
    generic map(
      INIT => X"5554"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_SOP_REG3_421,
      I1 => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420,
      I2 => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG3_405,
      I3 => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(3),
      O => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_3_Q
    );
  U0_gpcs_pma_inst_RECEIVER_Mmux_RXDATA_REG5_7_GND_28_o_mux_9_OUT31 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(2),
      I1 => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420,
      I2 => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG3_405,
      I3 => U0_gpcs_pma_inst_RECEIVER_SOP_REG3_421,
      O => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_2_Q
    );
  U0_gpcs_pma_inst_RECEIVER_Mmux_RXDATA_REG5_7_GND_28_o_mux_9_OUT61 : LUT4
    generic map(
      INIT => X"0002"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(5),
      I1 => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420,
      I2 => U0_gpcs_pma_inst_RECEIVER_SOP_REG3_421,
      I3 => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG3_405,
      O => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_5_Q
    );
  U0_gpcs_pma_inst_RECEIVER_Mmux_RXDATA_REG5_7_GND_28_o_mux_9_OUT81 : LUT4
    generic map(
      INIT => X"0002"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(7),
      I1 => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420,
      I2 => U0_gpcs_pma_inst_RECEIVER_SOP_REG3_421,
      I3 => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG3_405,
      O => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_7_Q
    );
  U0_gpcs_pma_inst_RECEIVER_K29p71 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_K27p7_RXFIFO_ERR_AND_128_o1_344,
      I1 => U0_gpcs_pma_inst_RXDATA_INT(1),
      I2 => U0_gpcs_pma_inst_RXDATA_INT(3),
      I3 => U0_gpcs_pma_inst_RXDATA_INT(2),
      O => U0_gpcs_pma_inst_RECEIVER_K29p7
    );
  U0_gpcs_pma_inst_RECEIVER_K27p7_RXFIFO_ERR_AND_128_o11 : LUT6
    generic map(
      INIT => X"8000000000000000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXCHARISK_INT_125,
      I1 => U0_gpcs_pma_inst_RXDATA_INT(6),
      I2 => U0_gpcs_pma_inst_RXDATA_INT(0),
      I3 => U0_gpcs_pma_inst_RXDATA_INT(4),
      I4 => U0_gpcs_pma_inst_RXDATA_INT(5),
      I5 => U0_gpcs_pma_inst_RXDATA_INT(7),
      O => U0_gpcs_pma_inst_RECEIVER_K27p7_RXFIFO_ERR_AND_128_o1_344
    );
  U0_gpcs_pma_inst_RECEIVER_Mmux_RXDATA_REG5_7_GND_28_o_mux_9_OUT11 : LUT4
    generic map(
      INIT => X"FF54"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG3_405,
      I1 => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420,
      I2 => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(0),
      I3 => U0_gpcs_pma_inst_RECEIVER_SOP_REG3_421,
      O => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_0_Q
    );
  U0_gpcs_pma_inst_RECEIVER_Mmux_RXDATA_REG5_7_GND_28_o_mux_9_OUT51 : LUT5
    generic map(
      INIT => X"FFFF4540"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG3_405,
      I1 => U0_gpcs_pma_inst_RECEIVER_EXTEND_ERR_395,
      I2 => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420,
      I3 => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(4),
      I4 => U0_gpcs_pma_inst_RECEIVER_SOP_REG3_421,
      O => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_4_Q
    );
  U0_gpcs_pma_inst_RECEIVER_RXDATA_7_RXNOTINTABLE_AND_228_o1 : LUT4
    generic map(
      INIT => X"2002"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_K28p51_345,
      I1 => U0_gpcs_pma_inst_RXNOTINTABLE_INT_115,
      I2 => U0_gpcs_pma_inst_RXDATA_INT(5),
      I3 => U0_gpcs_pma_inst_RXDATA_INT(6),
      O => U0_gpcs_pma_inst_RECEIVER_RXDATA_7_RXNOTINTABLE_AND_228_o
    );
  U0_gpcs_pma_inst_RECEIVER_S_WAIT_FOR_K_AND_161_o1 : LUT5
    generic map(
      INIT => X"08080800"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      I1 => U0_gpcs_pma_inst_RECEIVER_S_438,
      I2 => U0_gpcs_pma_inst_RECEIVER_WAIT_FOR_K_381,
      I3 => U0_gpcs_pma_inst_RECEIVER_EXTEND_378,
      I4 => U0_gpcs_pma_inst_RECEIVER_I_REG_429,
      O => U0_gpcs_pma_inst_RECEIVER_S_WAIT_FOR_K_AND_161_o
    );
  U0_gpcs_pma_inst_RECEIVER_K23p71 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(2),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(3),
      I2 => U0_gpcs_pma_inst_RXDATA_INT(1),
      I3 => U0_gpcs_pma_inst_RECEIVER_K27p7_RXFIFO_ERR_AND_128_o1_344,
      O => U0_gpcs_pma_inst_RECEIVER_K23p7
    );
  U0_gpcs_pma_inst_RECEIVER_K27p7_RXFIFO_ERR_AND_128_o1 : LUT5
    generic map(
      INIT => X"00200000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(1),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(2),
      I2 => U0_gpcs_pma_inst_RXDATA_INT(3),
      I3 => U0_gpcs_pma_inst_RECEIVER_RXFIFO_ERR_RXDISPERR_OR_46_o,
      I4 => U0_gpcs_pma_inst_RECEIVER_K27p7_RXFIFO_ERR_AND_128_o1_344,
      O => U0_gpcs_pma_inst_RECEIVER_K27p7_RXFIFO_ERR_AND_128_o
    );
  U0_gpcs_pma_inst_RECEIVER_K28p52 : LUT3
    generic map(
      INIT => X"20"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(5),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(6),
      I2 => U0_gpcs_pma_inst_RECEIVER_K28p51_345,
      O => U0_gpcs_pma_inst_RECEIVER_K28p5
    );
  U0_gpcs_pma_inst_RECEIVER_Mmux_RXDATA_REG5_7_GND_28_o_mux_9_OUT71 : LUT4
    generic map(
      INIT => X"FF10"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG3_405,
      I1 => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420,
      I2 => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(6),
      I3 => U0_gpcs_pma_inst_RECEIVER_SOP_REG3_421,
      O => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7_GND_28_o_mux_9_OUT_6_Q
    );
  U0_gpcs_pma_inst_RECEIVER_IDLE_REG_1_IDLE_REG_2_OR_124_o1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_IDLE_REG(1),
      I1 => U0_gpcs_pma_inst_RECEIVER_IDLE_REG(2),
      O => U0_gpcs_pma_inst_RECEIVER_IDLE_REG_1_IDLE_REG_2_OR_124_o
    );
  U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG_0_RX_CONFIG_VALID_REG_3_OR_123_o_0_1 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG(0),
      I1 => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG(1),
      I2 => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG(2),
      I3 => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG(3),
      O => U0_gpcs_pma_inst_RECEIVER_RX_CONFIG_VALID_REG_0_RX_CONFIG_VALID_REG_3_OR_123_o
    );
  U0_gpcs_pma_inst_RECEIVER_EXTEND_REG3_EXT_ILLEGAL_K_REG2_OR_93_o1 : LUT3
    generic map(
      INIT => X"F8"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG3_419,
      I1 => U0_gpcs_pma_inst_RECEIVER_CGBAD_REG3_408,
      I2 => U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_REG2_392,
      O => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG3_EXT_ILLEGAL_K_REG2_OR_93_o
    );
  U0_gpcs_pma_inst_RECEIVER_EOP_REG1_SYNC_STATUS_OR_97_o1 : LUT3
    generic map(
      INIT => X"AB"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_EOP_REG1_400,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      I2 => U0_gpcs_pma_inst_RECEIVER_RECEIVE_379,
      O => U0_gpcs_pma_inst_RECEIVER_EOP_REG1_SYNC_STATUS_OR_97_o
    );
  U0_gpcs_pma_inst_RECEIVER_EOP_EXTEND_OR_75_o1 : LUT3
    generic map(
      INIT => X"F8"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_EXTEND_378,
      I1 => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420,
      I2 => U0_gpcs_pma_inst_RECEIVER_EOP_401,
      O => U0_gpcs_pma_inst_RECEIVER_EOP_EXTEND_OR_75_o
    );
  U0_gpcs_pma_inst_RECEIVER_RXCHARISK_REG1_K28p5_REG1_AND_184_o1 : LUT4
    generic map(
      INIT => X"0002"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_RXCHARISK_REG1_426,
      I1 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434,
      I2 => U0_gpcs_pma_inst_RECEIVER_R_410,
      I3 => U0_gpcs_pma_inst_RECEIVER_T_437,
      O => U0_gpcs_pma_inst_RECEIVER_RXCHARISK_REG1_K28p5_REG1_AND_184_o
    );
  U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_EVEN_AND_144_o1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_130,
      O => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_EVEN_AND_144_o
    );
  U0_gpcs_pma_inst_RECEIVER_RXFIFO_ERR_RXDISPERR_OR_46_o1 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXBUFSTATUS_INT(1),
      I1 => U0_gpcs_pma_inst_RXNOTINTABLE_INT_115,
      I2 => U0_gpcs_pma_inst_RXDISPERR_INT_116,
      O => U0_gpcs_pma_inst_RECEIVER_RXFIFO_ERR_RXDISPERR_OR_46_o
    );
  U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o1 : LUT2
    generic map(
      INIT => X"B"
    )
    port map (
      I0 => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      O => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT3_SW0 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_V_197,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(2),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_T_207,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_R_198,
      O => N2
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT3 : LUT6
    generic map(
      INIT => X"FFFFBBAB55551101"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT_200,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_S_209,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199,
      I3 => N2,
      I4 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      I5 => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA(2),
      O => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_2_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT4_SW0 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_V_197,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_T_207,
      I2 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_S_209,
      O => N6
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT4 : LUT6
    generic map(
      INIT => X"FFFFBBAB55551101"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT_200,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_R_198,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(3),
      I4 => N6,
      I5 => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA(3),
      O => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_3_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT7_SW0 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_V_197,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_T_207,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_R_198,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_S_209,
      O => N8
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT7 : LUT6
    generic map(
      INIT => X"DDDDDCCC11111000"
    )
    port map (
      I0 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT_200,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(6),
      I4 => N8,
      I5 => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA(1),
      O => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_6_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_XMIT_DATA_INT_AND_37_o1 : LUT6
    generic map(
      INIT => X"FFFFFFFDFFFFFFFF"
    )
    port map (
      I0 => gmii_txd(3),
      I1 => gmii_txd(7),
      I2 => gmii_txd(4),
      I3 => gmii_txd(5),
      I4 => gmii_txd(6),
      I5 => gmii_txd(2),
      O => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_XMIT_DATA_INT_AND_37_o1_442
    );
  U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_XMIT_DATA_INT_AND_37_o2 : LUT6
    generic map(
      INIT => X"A8AAAAAA20222222"
    )
    port map (
      I0 => gmii_tx_er,
      I1 => gmii_tx_en,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_XMIT_DATA_INT_AND_37_o1_442,
      I3 => gmii_txd(0),
      I4 => gmii_txd(1),
      I5 => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199,
      O => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_XMIT_DATA_INT_AND_37_o2_443
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT21 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFF5540"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_T_207,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(1),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_R_198,
      I4 => U0_gpcs_pma_inst_TRANSMITTER_S_209,
      I5 => U0_gpcs_pma_inst_TRANSMITTER_V_197,
      O => U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT2
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT22 : LUT4
    generic map(
      INIT => X"AE04"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT_200,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT2,
      I2 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA(1),
      O => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_1_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT11 : LUT6
    generic map(
      INIT => X"FFFFFFFF55555540"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_V_197,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TXD_REG1(0),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_T_207,
      I4 => U0_gpcs_pma_inst_TRANSMITTER_R_198,
      I5 => U0_gpcs_pma_inst_TRANSMITTER_S_209,
      O => U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT1
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT12 : LUT4
    generic map(
      INIT => X"AE04"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT_200,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_Mmux_PWR_22_o_CONFIG_DATA_7_mux_21_OUT1,
      I2 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA(0),
      O => U0_gpcs_pma_inst_TRANSMITTER_PWR_22_o_CONFIG_DATA_7_mux_21_OUT_0_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT_xor_1_1_SW0 : LUT3
    generic map(
      INIT => X"04"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(3),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(2),
      O => N10
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT_xor_1_1 : LUT6
    generic map(
      INIT => X"9999999909099899"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(1),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(0),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I3 => N10,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT1
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0147_inv_SW0 : LUT3
    generic map(
      INIT => X"FB"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(1),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(2),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(0),
      O => N12
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0147_inv : LUT6
    generic map(
      INIT => X"0000000001000000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(3),
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      I5 => N12,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0147_inv_283
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB1 : LUT3
    generic map(
      INIT => X"01"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(2),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(3),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(1),
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB1_448
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB2 : LUT3
    generic map(
      INIT => X"01"
    )
    port map (
      I0 => phyad(3),
      I1 => phyad(4),
      I2 => phyad(2),
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB3_449
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB3 : LUT6
    generic map(
      INIT => X"002008FF00000000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB3_449,
      I1 => phyad(1),
      I2 => phyad(0),
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(0),
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB1_448,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB4_450
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB4 : LUT6
    generic map(
      INIT => X"8040201008040216"
    )
    port map (
      I0 => phyad(3),
      I1 => phyad(4),
      I2 => phyad(2),
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(2),
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(3),
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(1),
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB5_451
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB5 : LUT4
    generic map(
      INIT => X"9810"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(0),
      I1 => phyad(1),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB5_451,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB2_271,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB6_452
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB6 : LUT6
    generic map(
      INIT => X"8008000020020000"
    )
    port map (
      I0 => phyad(1),
      I1 => phyad(2),
      I2 => phyad(3),
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(2),
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(0),
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(1),
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB7_453
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB7 : LUT6
    generic map(
      INIT => X"C3D70055C3C30000"
    )
    port map (
      I0 => phyad(1),
      I1 => phyad(4),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(3),
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(0),
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB7_453,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB2_271,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB8_454
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB8 : LUT5
    generic map(
      INIT => X"F9F8F1F0"
    )
    port map (
      I0 => phyad(0),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB4_450,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB6_452,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB8_454,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT_xor_0_1_SW0 : LUT3
    generic map(
      INIT => X"01"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(3),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(2),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(1),
      O => N14
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT_xor_0_1 : LUT6
    generic map(
      INIT => X"55555555D145D155"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(0),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I4 => N14,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In_SW0 : LUT5
    generic map(
      INIT => X"ABC4AAC4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      O => N16
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In : LUT4
    generic map(
      INIT => X"EEE4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I2 => N16,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In1,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In_281
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In2 : LUT5
    generic map(
      INIT => X"A2A2A2F6"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(3),
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT_xor_3_14,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In3_457
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mmux_STATE_3_PWR_20_o_Mux_36_o11_SW0 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_OPCODE(1),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_307,
      O => N18
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mmux_STATE_3_PWR_20_o_Mux_36_o11 : LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFAFAD"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_OPCODE(0),
      I5 => N18,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mmux_STATE_3_PWR_20_o_Mux_36_o11_270
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux61_SW0 : LUT5
    generic map(
      INIT => X"7F7FFEFF"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(1),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(0),
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_RESET_REG_138,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(2),
      O => N20
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux61 : LUT5
    generic map(
      INIT => X"ABAA0300"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(14),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(3),
      I2 => N20,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In1,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1011,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_15_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux16_SW0 : LUT2
    generic map(
      INIT => X"B"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(1),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(0),
      O => N22
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux16 : LUT6
    generic map(
      INIT => X"F0F4F0F000040000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(2),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(3),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      I3 => N22,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_In1,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1011,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_0_Q
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_In32 : LUT6
    generic map(
      INIT => X"7777555722220002"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD,
      I3 => U0_gpcs_pma_inst_RXCHARISK_INT_125,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_327,
      I5 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_In31_461,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_In3
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_In21 : LUT6
    generic map(
      INIT => X"91C49BE4DD80DFA0"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_327,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329,
      I3 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328,
      I4 => U0_gpcs_pma_inst_RXCHARISK_INT_125,
      I5 => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_1_PWR_23_o_equal_19_o,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_In21_462
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_In22 : LUT5
    generic map(
      INIT => X"4040FF40"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329,
      I3 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_In21_462,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_In2
    );
  U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_ISOLATE_AND_199_o_SW0 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      I1 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_POWERDOWN_REG,
      O => N28
    );
  U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_ISOLATE_AND_199_o : LUT6
    generic map(
      INIT => X"5555555144444440"
    )
    port map (
      I0 => N28,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      I2 => U0_gpcs_pma_inst_RECEIVER_RX_DATA_ERROR_399,
      I3 => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG3_405,
      I4 => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420,
      I5 => U0_gpcs_pma_inst_RECEIVER_RECEIVE_379,
      O => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_ISOLATE_AND_199_o_367
    );
  U0_gpcs_pma_inst_RECEIVER_EVEN_RXCHARISK_AND_132_o_SW0 : LUT4
    generic map(
      INIT => X"AAA8"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_I_REG_429,
      I1 => U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_389,
      I2 => U0_gpcs_pma_inst_RECEIVER_FALSE_K_390,
      I3 => U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_391,
      O => N32
    );
  U0_gpcs_pma_inst_RECEIVER_EVEN_RXCHARISK_AND_132_o : LUT6
    generic map(
      INIT => X"00000000AA088808"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_130,
      I1 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434,
      I2 => U0_gpcs_pma_inst_RXCHARISK_INT_125,
      I3 => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      I4 => N32,
      I5 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_D21p5_AND_133_o_norst,
      O => U0_gpcs_pma_inst_RECEIVER_EVEN_RXCHARISK_AND_132_o_369
    );
  U0_gpcs_pma_inst_RECEIVER_K28p51_SW0 : LUT2
    generic map(
      INIT => X"B"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(0),
      I1 => U0_gpcs_pma_inst_RXCHARISK_INT_125,
      O => N34
    );
  U0_gpcs_pma_inst_RECEIVER_K28p51 : LUT6
    generic map(
      INIT => X"0000000000800000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(7),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(3),
      I2 => U0_gpcs_pma_inst_RXDATA_INT(2),
      I3 => U0_gpcs_pma_inst_RXDATA_INT(1),
      I4 => U0_gpcs_pma_inst_RXDATA_INT(4),
      I5 => N34,
      O => U0_gpcs_pma_inst_RECEIVER_K28p51_345
    );
  U0_gpcs_pma_inst_RECEIVER_D21p5_D2p2_OR_48_o1 : LUT6
    generic map(
      INIT => X"4000000000000000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(6),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(7),
      I2 => U0_gpcs_pma_inst_RXDATA_INT(0),
      I3 => U0_gpcs_pma_inst_RXDATA_INT(2),
      I4 => U0_gpcs_pma_inst_RXDATA_INT(4),
      I5 => U0_gpcs_pma_inst_RXDATA_INT(5),
      O => U0_gpcs_pma_inst_RECEIVER_D21p5_D2p2_OR_48_o
    );
  U0_gpcs_pma_inst_RECEIVER_D21p5_D2p2_OR_48_o2 : LUT6
    generic map(
      INIT => X"0000000001000000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(7),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(5),
      I2 => U0_gpcs_pma_inst_RXDATA_INT(4),
      I3 => U0_gpcs_pma_inst_RXDATA_INT(6),
      I4 => U0_gpcs_pma_inst_RXDATA_INT(1),
      I5 => U0_gpcs_pma_inst_RXDATA_INT(2),
      O => U0_gpcs_pma_inst_RECEIVER_D21p5_D2p2_OR_48_o1_467
    );
  U0_gpcs_pma_inst_RECEIVER_D21p5_D2p2_OR_48_o3 : LUT6
    generic map(
      INIT => X"0013000300110000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(0),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(3),
      I2 => U0_gpcs_pma_inst_RXDATA_INT(1),
      I3 => U0_gpcs_pma_inst_RXCHARISK_INT_125,
      I4 => U0_gpcs_pma_inst_RECEIVER_D21p5_D2p2_OR_48_o1_467,
      I5 => U0_gpcs_pma_inst_RECEIVER_D21p5_D2p2_OR_48_o,
      O => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_D21p5_AND_133_o_norst
    );
  U0_gpcs_pma_inst_RECEIVER_D0p0_SW0 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(5),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(4),
      I2 => U0_gpcs_pma_inst_RXCHARISK_INT_125,
      I3 => U0_gpcs_pma_inst_RXDATA_INT(0),
      O => N36
    );
  U0_gpcs_pma_inst_RECEIVER_D0p0 : LUT6
    generic map(
      INIT => X"0000000000000001"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(7),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(3),
      I2 => U0_gpcs_pma_inst_RXDATA_INT(2),
      I3 => U0_gpcs_pma_inst_RXDATA_INT(1),
      I4 => U0_gpcs_pma_inst_RXDATA_INT(6),
      I5 => N36,
      O => U0_gpcs_pma_inst_RECEIVER_D0p0_352
    );
  U0_gpcs_pma_inst_RECEIVER_C_REG1_C_REG3_OR_69_o_SW0 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_C_REG1_428,
      I1 => U0_gpcs_pma_inst_RECEIVER_C_REG2_346,
      O => N38
    );
  U0_gpcs_pma_inst_RECEIVER_C_REG1_C_REG3_OR_69_o : LUT6
    generic map(
      INIT => X"FFFF8AAACEEE8AAA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_C_REG3_427,
      I1 => U0_gpcs_pma_inst_RECEIVER_CGBAD_409,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_130,
      I3 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434,
      I4 => N38,
      I5 => U0_gpcs_pma_inst_RECEIVER_RXCHARISK_REG1_426,
      O => U0_gpcs_pma_inst_RECEIVER_C_REG1_C_REG3_OR_69_o_350
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o1 : LUT5
    generic map(
      INIT => X"00200000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(0),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(7),
      I2 => U0_gpcs_pma_inst_RXDATA_INT(6),
      I3 => U0_gpcs_pma_inst_RXDATA_INT(5),
      I4 => U0_gpcs_pma_inst_RXDATA_INT(1),
      O => U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o1_470
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o2 : LUT4
    generic map(
      INIT => X"1118"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(1),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(0),
      I2 => U0_gpcs_pma_inst_RXDATA_INT(3),
      I3 => U0_gpcs_pma_inst_RXDATA_INT(4),
      O => U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o2_471
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o3 : LUT4
    generic map(
      INIT => X"2000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(5),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(6),
      I2 => U0_gpcs_pma_inst_RXDATA_INT(7),
      I3 => U0_gpcs_pma_inst_RXDATA_INT(2),
      O => U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o3_472
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o4 : LUT6
    generic map(
      INIT => X"FF171717FF000000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(4),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(3),
      I2 => U0_gpcs_pma_inst_RXDATA_INT(2),
      I3 => U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o3_472,
      I4 => U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o2_471,
      I5 => U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o1_470,
      O => U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o4_473
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o5 : LUT3
    generic map(
      INIT => X"10"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXNOTINTABLE_INT_115,
      I1 => U0_gpcs_pma_inst_RXCHARISK_INT_125,
      I2 => U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o4_473,
      O => U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_POS_RXNOTINTABLE_AND_220_o
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_POS_FALSE_NIT_NEG_OR_118_o11 : LUT6
    generic map(
      INIT => X"E8FFFFFFFFFFFFFF"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(7),
      I1 => U0_gpcs_pma_inst_RXDISPERR_INT_116,
      I2 => U0_gpcs_pma_inst_RXDATA_INT(1),
      I3 => U0_gpcs_pma_inst_RXDATA_INT(6),
      I4 => U0_gpcs_pma_inst_RXDATA_INT(4),
      I5 => U0_gpcs_pma_inst_RXDATA_INT(3),
      O => U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_POS_FALSE_NIT_NEG_OR_118_o1
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_POS_FALSE_NIT_NEG_OR_118_o13 : LUT5
    generic map(
      INIT => X"FFFFFFFE"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(4),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(6),
      I2 => U0_gpcs_pma_inst_RXCHARISK_INT_125,
      I3 => U0_gpcs_pma_inst_RXDATA_INT(2),
      I4 => U0_gpcs_pma_inst_RXDATA_INT(3),
      O => U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_POS_FALSE_NIT_NEG_OR_118_o13_476
    );
  U0_gpcs_pma_inst_RECEIVER_I_REG_T_REG2_OR_74_o1 : LUT5
    generic map(
      INIT => X"88888000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_T_REG2_431,
      I1 => U0_gpcs_pma_inst_RECEIVER_R_REG1_430,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_130,
      I3 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434,
      I4 => U0_gpcs_pma_inst_RECEIVER_R_410,
      O => U0_gpcs_pma_inst_RECEIVER_I_REG_T_REG2_OR_74_o1_477
    );
  U0_gpcs_pma_inst_RECEIVER_I_REG_T_REG2_OR_74_o2 : LUT6
    generic map(
      INIT => X"FFFFFF80FF80FF80"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_C_REG1_428,
      I1 => U0_gpcs_pma_inst_RECEIVER_D0p0_REG_433,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_130,
      I3 => U0_gpcs_pma_inst_RECEIVER_I_REG_T_REG2_OR_74_o1_477,
      I4 => U0_gpcs_pma_inst_RECEIVER_I_REG_429,
      I5 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434,
      O => U0_gpcs_pma_inst_RECEIVER_I_REG_T_REG2_OR_74_o
    );
  U0_gpcs_pma_inst_RECEIVER_T_REG2_R_REG1_OR_89_o2 : LUT5
    generic map(
      INIT => X"54545554"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_R_REG1_430,
      I1 => U0_gpcs_pma_inst_RECEIVER_T_REG2_431,
      I2 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434,
      I3 => U0_gpcs_pma_inst_RECEIVER_R_410,
      I4 => U0_gpcs_pma_inst_RECEIVER_T_REG1_432,
      O => U0_gpcs_pma_inst_RECEIVER_T_REG2_R_REG1_OR_89_o2_478
    );
  U0_gpcs_pma_inst_RECEIVER_SYNC_STATUS_C_REG1_AND_142_o_SW0 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_RXCHARISK_REG1_426,
      I1 => U0_gpcs_pma_inst_RECEIVER_CGBAD_409,
      O => N40
    );
  U0_gpcs_pma_inst_RECEIVER_SYNC_STATUS_C_REG1_AND_142_o : LUT6
    generic map(
      INIT => X"0010001000100000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_RXFIFO_ERR_RXDISPERR_OR_46_o,
      I1 => U0_gpcs_pma_inst_RXCHARISK_INT_125,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      I3 => N40,
      I4 => U0_gpcs_pma_inst_RECEIVER_C_REG1_428,
      I5 => U0_gpcs_pma_inst_RECEIVER_C_HDR_REMOVED_REG_424,
      O => U0_gpcs_pma_inst_RECEIVER_SYNC_STATUS_C_REG1_AND_142_o_368
    );
  U0_gpcs_pma_inst_TRANSMITTER_V : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_V_glue_set_480,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_V_197
    );
  U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_glue_set_481,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199
    );
  U0_gpcs_pma_inst_TRANSMITTER_R : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_R_glue_set_482,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_R_198
    );
  U0_gpcs_pma_inst_TRANSMITTER_DISPARITY : FDS
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_DISPARITY_glue_rst_483,
      S => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_DISPARITY_196
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_POWERDOWN_REG : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_POWERDOWN_REG_glue_set_484,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_POWERDOWN_REG
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_ENCOMMAALIGN : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_SYNCHRONISATION_ENCOMMAALIGN_glue_set_485,
      R => U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD_GND_27_o_AND_69_o,
      Q => NlwRenamedSig_OI_U0_gpcs_pma_inst_SYNCHRONISATION_ENCOMMAALIGN
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS : FDS
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_glue_rst_486,
      S => U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD_GND_27_o_AND_69_o,
      Q => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_EVEN : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_glue_set_487,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_130
    );
  U0_gpcs_pma_inst_RECEIVER_RECEIVE : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RECEIVE_glue_set_488,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => U0_gpcs_pma_inst_RECEIVER_RECEIVE_379
    );
  U0_gpcs_pma_inst_RECEIVER_RX_INVALID : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RX_INVALID_glue_set_489,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => NlwRenamedSig_OI_U0_gpcs_pma_inst_RECEIVER_RX_INVALID
    );
  U0_gpcs_pma_inst_RECEIVER_RX_DV : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RX_DV_glue_set_490,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      Q => NlwRenamedSig_OI_U0_gpcs_pma_inst_RECEIVER_RX_DV
    );
  U0_gpcs_pma_inst_RECEIVER_EXTEND : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_EXTEND_glue_set_491,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => U0_gpcs_pma_inst_RECEIVER_EXTEND_378
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_glue_set_492,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_380
    );
  U0_gpcs_pma_inst_RECEIVER_WAIT_FOR_K : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_WAIT_FOR_K_glue_set_493,
      R => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      Q => U0_gpcs_pma_inst_RECEIVER_WAIT_FOR_K_381
    );
  U0_gpcs_pma_inst_TRANSMITTER_C1_OR_C2 : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_C1_OR_C2_rstpot_494,
      R => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      Q => U0_gpcs_pma_inst_TRANSMITTER_C1_OR_C2_202
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_WE_rstpot : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG2_308,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_WE_249,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_GND_24_o_GND_24_o_MUX_62_o,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_WE_rstpot_495
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_WE : FDR
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_WE_rstpot_495,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_WE_249
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_rstpot_496,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_307
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_RESET_REG : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_RESET_REG_rstpot_497,
      R => U0_gpcs_pma_inst_SRESET_127,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_RESET_REG_138
    );
  U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd4 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd4_rstpot_498,
      Q => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd4_82
    );
  U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd4 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd4_rstpot_499,
      Q => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd4_89
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRPISK : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRPISK_rstpot_500,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRPISK_204
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXCHARDISPVAL : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_TXCHARDISPVAL_rstpot_501,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TXCHARDISPVAL_139
    );
  U0_gpcs_pma_inst_TRANSMITTER_TRIGGER_T : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_TRIGGER_T_rstpot_502,
      Q => U0_gpcs_pma_inst_TRANSMITTER_TRIGGER_T_206
    );
  U0_gpcs_pma_inst_TRANSMITTER_S_rstpot : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_TRIGGER_S_OR_25_o_0,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_XMIT_DATA_INT_201,
      O => U0_gpcs_pma_inst_TRANSMITTER_S_rstpot_503
    );
  U0_gpcs_pma_inst_TRANSMITTER_S : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_S_rstpot_503,
      Q => U0_gpcs_pma_inst_TRANSMITTER_S_209
    );
  U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA_0 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA_0_rstpot_504,
      Q => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA(0)
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_CONFIGURATION_VALID_EN : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_CONFIGURATION_VALID_EN_rstpot_505,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_CONFIGURATION_VALID_EN_247
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1 : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_rstpot_506,
      Q => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248
    );
  U0_gpcs_pma_inst_RECEIVER_C_HDR_REMOVED_REG : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_C_HDR_REMOVED_REG_rstpot_507,
      Q => U0_gpcs_pma_inst_RECEIVER_C_HDR_REMOVED_REG_424
    );
  U0_gpcs_pma_inst_RECEIVER_C : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_C_rstpot_508,
      Q => U0_gpcs_pma_inst_RECEIVER_C_435
    );
  U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_rstpot_509,
      Q => U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_394
    );
  U0_gpcs_pma_inst_RECEIVER_RX_DATA_ERROR : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_RX_DATA_ERROR_rstpot_510,
      Q => U0_gpcs_pma_inst_RECEIVER_RX_DATA_ERROR_399
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_POS_FALSE_NIT_NEG_OR_118_o12 : LUT6
    generic map(
      INIT => X"FFFFFFFFA9999995"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(0),
      I1 => U0_gpcs_pma_inst_RXDATA_INT(5),
      I2 => U0_gpcs_pma_inst_RXDISPERR_INT_116,
      I3 => U0_gpcs_pma_inst_RXDATA_INT(7),
      I4 => U0_gpcs_pma_inst_RXDATA_INT(1),
      I5 => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      O => U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_POS_FALSE_NIT_NEG_OR_118_o12_475
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1511 : LUT5
    generic map(
      INIT => X"A8AAAAAA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(8),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In1,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_9_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux1012 : LUT5
    generic map(
      INIT => X"A8AAAAAA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(3),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In1,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_4_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux911 : LUT5
    generic map(
      INIT => X"A8AAAAAA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(2),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In1,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_3_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux711 : LUT5
    generic map(
      INIT => X"A8AAAAAA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(0),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In1,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_1_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux411 : LUT5
    generic map(
      INIT => X"A8AAAAAA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(12),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In1,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_13_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_mux311 : LUT5
    generic map(
      INIT => X"A8AAAAAA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(11),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In1,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG_14_DATA_IN_15_mux_25_OUT_12_Q
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In11 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(3),
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(2),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(0),
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(1),
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In1
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_NIT : FD
    port map (
      C => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_rstpot_511,
      Q => U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_389
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_rstpot : LUT6
    generic map(
      INIT => X"AAAAAAEAAAAAAA2A"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_307,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_COMB,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_ADDRESS_MATCH_rstpot_496
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0155_inv1 : LUT6
    generic map(
      INIT => X"0000000000200000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_BIT_COUNT(3),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_Mcount_BIT_COUNT_xor_3_14,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_n0155_inv
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_POWERDOWN_REG_glue_set : LUT6
    generic map(
      INIT => X"FFFFDD80AAFF8880"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_GND_22_o_MDIO_WE_AND_14_o,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(11),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG3_250,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_CONFIGURATION_VALID_EN_247,
      I4 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_POWERDOWN_REG,
      I5 => configuration_vector(2),
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_POWERDOWN_REG_glue_set_484
    );
  U0_gpcs_pma_inst_RECEIVER_RX_DV_glue_set : LUT6
    generic map(
      INIT => X"1000FFFF10001000"
    )
    port map (
      I0 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_POWERDOWN_REG,
      I1 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      I3 => U0_gpcs_pma_inst_RECEIVER_SOP_REG3_421,
      I4 => U0_gpcs_pma_inst_RECEIVER_EOP_REG1_SYNC_STATUS_OR_97_o,
      I5 => NlwRenamedSig_OI_U0_gpcs_pma_inst_RECEIVER_RX_DV,
      O => U0_gpcs_pma_inst_RECEIVER_RX_DV_glue_set_490
    );
  U0_gpcs_pma_inst_TRANSMITTER_C1_OR_C2_rstpot : LUT4
    generic map(
      INIT => X"6A2A"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_C1_OR_C2_202,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(1),
      I3 => U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT_200,
      O => U0_gpcs_pma_inst_TRANSMITTER_C1_OR_C2_rstpot_494
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_glue_set : LUT3
    generic map(
      INIT => X"2F"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXCHARISCOMMA_INT_126,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_130,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_glue_set_487
    );
  U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd4_rstpot : LUT6
    generic map(
      INIT => X"0001010101010101"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RESET_INT_134,
      I1 => U0_gpcs_pma_inst_RXBUFSTATUS_INT(1),
      I2 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd4_82,
      I3 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd2_80,
      I4 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd3_81,
      I5 => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd1_79,
      O => U0_gpcs_pma_inst_RX_RST_SM_FSM_FFd4_rstpot_498
    );
  U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd4_rstpot : LUT6
    generic map(
      INIT => X"0001010101010101"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RESET_INT_134,
      I1 => U0_gpcs_pma_inst_TXBUFERR_INT_110,
      I2 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd4_89,
      I3 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd2_87,
      I4 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd3_88,
      I5 => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd1_86,
      O => U0_gpcs_pma_inst_TX_RST_SM_FSM_FFd4_rstpot_499
    );
  U0_gpcs_pma_inst_TRANSMITTER_DISPARITY_glue_rst : LUT6
    generic map(
      INIT => X"4114055014411441"
    )
    port map (
      I0 => N47,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(6),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_DISP5,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_DISPARITY_196,
      I4 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(7),
      I5 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(5),
      O => U0_gpcs_pma_inst_TRANSMITTER_DISPARITY_glue_rst_483
    );
  U0_gpcs_pma_inst_TRANSMITTER_V_glue_set_SW0 : LUT2
    generic map(
      INIT => X"B"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TX_ER_REG1_222,
      O => N49
    );
  U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA_0_rstpot : LUT4
    generic map(
      INIT => X"0002"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      I1 => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_C1_OR_C2_202,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(1),
      O => U0_gpcs_pma_inst_TRANSMITTER_CONFIG_DATA_0_rstpot_504
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_RESET_REG_rstpot : LUT4
    generic map(
      INIT => X"FF80"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDC_RISING_REG3_250,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_SHIFT_REG(15),
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_GND_22_o_MDIO_WE_AND_14_o,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_RESET_REG_138,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_RESET_REG_rstpot_497
    );
  U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_glue_set : LUT3
    generic map(
      INIT => X"BA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_S_209,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_T_207,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199,
      O => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_glue_set_481
    );
  U0_gpcs_pma_inst_RECEIVER_RECEIVE_glue_set : LUT3
    generic map(
      INIT => X"BA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_SOP_REG2_422,
      I1 => U0_gpcs_pma_inst_RECEIVER_EOP_401,
      I2 => U0_gpcs_pma_inst_RECEIVER_RECEIVE_379,
      O => U0_gpcs_pma_inst_RECEIVER_RECEIVE_glue_set_488
    );
  U0_gpcs_pma_inst_RECEIVER_RX_INVALID_glue_set : LUT3
    generic map(
      INIT => X"BA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_FROM_RX_CX_403,
      I1 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434,
      I2 => NlwRenamedSig_OI_U0_gpcs_pma_inst_RECEIVER_RX_INVALID,
      O => U0_gpcs_pma_inst_RECEIVER_RX_INVALID_glue_set_489
    );
  U0_gpcs_pma_inst_TRANSMITTER_TRIGGER_T_rstpot : LUT3
    generic map(
      INIT => X"04"
    )
    port map (
      I0 => gmii_tx_en,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_223,
      I2 => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      O => U0_gpcs_pma_inst_TRANSMITTER_TRIGGER_T_rstpot_502
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_CONFIGURATION_VALID_EN_rstpot : LUT3
    generic map(
      INIT => X"04"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_CONFIGURATION_VALID_EN_REG_246,
      I1 => configuration_valid,
      I2 => U0_gpcs_pma_inst_SRESET_127,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_CONFIGURATION_VALID_EN_rstpot_505
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_rstpot : LUT3
    generic map(
      INIT => X"04"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_REG3_245,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_REG2,
      I2 => U0_gpcs_pma_inst_SRESET_127,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_rstpot_506
    );
  U0_gpcs_pma_inst_RECEIVER_C_HDR_REMOVED_REG_rstpot : LUT4
    generic map(
      INIT => X"0040"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXCLKCORCNT_INT(1),
      I1 => U0_gpcs_pma_inst_RECEIVER_C_REG2_346,
      I2 => U0_gpcs_pma_inst_RXCLKCORCNT_INT(0),
      I3 => U0_gpcs_pma_inst_RXCLKCORCNT_INT(2),
      O => U0_gpcs_pma_inst_RECEIVER_C_HDR_REMOVED_REG_rstpot_507
    );
  U0_gpcs_pma_inst_RECEIVER_RX_DATA_ERROR_rstpot : LUT6
    generic map(
      INIT => X"2222222200020000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_RECEIVE_379,
      I1 => U0_gpcs_pma_inst_RECEIVER_RESET_SYNC_STATUS_OR_61_o,
      I2 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_EVEN_AND_144_o,
      I3 => U0_gpcs_pma_inst_RECEIVER_R_410,
      I4 => U0_gpcs_pma_inst_RECEIVER_T_REG2_431,
      I5 => N55,
      O => U0_gpcs_pma_inst_RECEIVER_RX_DATA_ERROR_rstpot_510
    );
  U0_gpcs_pma_inst_RECEIVER_EXTEND_glue_set_SW0 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_RECEIVE_379,
      I1 => U0_gpcs_pma_inst_RECEIVER_R_REG1_430,
      O => N57
    );
  U0_gpcs_pma_inst_RECEIVER_EXTEND_glue_set : LUT6
    generic map(
      INIT => X"FFFF022202220222"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_EXTEND_378,
      I1 => U0_gpcs_pma_inst_RECEIVER_S_438,
      I2 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434,
      I3 => U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_130,
      I4 => N57,
      I5 => U0_gpcs_pma_inst_RECEIVER_R_410,
      O => U0_gpcs_pma_inst_RECEIVER_EXTEND_glue_set_491
    );
  U0_gpcs_pma_inst_RECEIVER_C_rstpot : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434,
      I1 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_D21p5_AND_133_o_norst,
      O => U0_gpcs_pma_inst_RECEIVER_C_rstpot_508
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_ENCOMMAALIGN_glue_set : LUT6
    generic map(
      INIT => X"FFFFFFFF88808085"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_327,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328,
      I3 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330,
      I5 => NlwRenamedSig_OI_U0_gpcs_pma_inst_SYNCHRONISATION_ENCOMMAALIGN,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_ENCOMMAALIGN_glue_set_485
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_CODE_GRPISK_GND_26_o_MUX_192_o11 : LUT3
    generic map(
      INIT => X"2A"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRPISK_204,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRPISK_GND_26_o_MUX_192_o
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_CODE_GRP_7_GND_26_o_mux_24_OUT11 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(0),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      I3 => U0_gpcs_pma_inst_TRANSMITTER_DISPARITY_196,
      O => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_0_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_CODE_GRP_7_GND_26_o_mux_24_OUT21 : LUT3
    generic map(
      INIT => X"2A"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(1),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_1_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_CODE_GRP_7_GND_26_o_mux_24_OUT31 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(2),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      I3 => U0_gpcs_pma_inst_TRANSMITTER_DISPARITY_196,
      O => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_2_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_CODE_GRP_7_GND_26_o_mux_24_OUT41 : LUT3
    generic map(
      INIT => X"2A"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(3),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_3_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_CODE_GRP_7_GND_26_o_mux_24_OUT51 : LUT4
    generic map(
      INIT => X"2AEA"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(4),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      I3 => U0_gpcs_pma_inst_TRANSMITTER_DISPARITY_196,
      O => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_4_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_CODE_GRP_7_GND_26_o_mux_24_OUT61 : LUT3
    generic map(
      INIT => X"2A"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(5),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_5_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_CODE_GRP_7_GND_26_o_mux_24_OUT71 : LUT3
    generic map(
      INIT => X"F8"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(6),
      O => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_6_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_CODE_GRP_7_GND_26_o_mux_24_OUT81 : LUT4
    generic map(
      INIT => X"EA2A"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP(7),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      I3 => U0_gpcs_pma_inst_TRANSMITTER_DISPARITY_196,
      O => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_7_GND_26_o_mux_24_OUT_7_Q
    );
  U0_gpcs_pma_inst_TRANSMITTER_n0235_1_1 : LUT3
    generic map(
      INIT => X"20"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_C1_OR_C2_202,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(1),
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TRANSMITTER_n0235(1)
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_In31 : LUT6
    generic map(
      INIT => X"FFF00000FFFF0020"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS(1),
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS(0),
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_327,
      I3 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329,
      I5 => U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_In31_461
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRPISK_rstpot_SW1 : LUT4
    generic map(
      INIT => X"FFFB"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_T_207,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_S_209,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_V_197,
      O => N59
    );
  U0_gpcs_pma_inst_TRANSMITTER_CODE_GRPISK_rstpot : LUT6
    generic map(
      INIT => X"55545554FFFE5554"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT_200,
      I1 => N59,
      I2 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_R_198,
      I4 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      I5 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(1),
      O => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRPISK_rstpot_500
    );
  U0_gpcs_pma_inst_TRANSMITTER_R_glue_set : LUT5
    generic map(
      INIT => X"FFFF4440"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_S_209,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_R_198,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      I3 => U0_gpcs_pma_inst_TRANSMITTER_TX_ER_REG1_222,
      I4 => U0_gpcs_pma_inst_TRANSMITTER_T_207,
      O => U0_gpcs_pma_inst_TRANSMITTER_R_glue_set_482
    );
  U0_gpcs_pma_inst_TRANSMITTER_DISPARITY_glue_rst_SW0 : LUT3
    generic map(
      INIT => X"20"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205,
      I1 => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => N47
    );
  U0_gpcs_pma_inst_TRANSMITTER_V_glue_set : LUT6
    generic map(
      INIT => X"FFFF88A888A888A8"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_XMIT_DATA_INT_201,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_XMIT_DATA_INT_AND_37_o2_443,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_TX_EN_REG1_223,
      I3 => N49,
      I4 => U0_gpcs_pma_inst_TRANSMITTER_S_209,
      I5 => U0_gpcs_pma_inst_TRANSMITTER_V_197,
      O => U0_gpcs_pma_inst_TRANSMITTER_V_glue_set_480
    );
  U0_gpcs_pma_inst_RECEIVER_RX_DATA_ERROR_rstpot_SW0 : LUT5
    generic map(
      INIT => X"FFFFFFFE"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_I_REG_429,
      I1 => U0_gpcs_pma_inst_RECEIVER_ILLEGAL_K_REG2_396,
      I2 => U0_gpcs_pma_inst_RECEIVER_C_REG1_428,
      I3 => U0_gpcs_pma_inst_RECEIVER_CGBAD_REG3_408,
      I4 => U0_gpcs_pma_inst_RECEIVER_T_REG2_R_REG1_OR_89_o2_478,
      O => N55
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_glue_set_SW1 : LUT4
    generic map(
      INIT => X"FDFF"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_I_REG_429,
      I1 => U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_389,
      I2 => U0_gpcs_pma_inst_RECEIVER_S_438,
      I3 => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      O => N61
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_glue_set : LUT6
    generic map(
      INIT => X"44444445CCCCCCCD"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434,
      I1 => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_380,
      I2 => N61,
      I3 => U0_gpcs_pma_inst_RECEIVER_FALSE_DATA_391,
      I4 => U0_gpcs_pma_inst_RECEIVER_FALSE_K_390,
      I5 => U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_130,
      O => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_glue_set_492
    );
  U0_gpcs_pma_inst_RECEIVER_WAIT_FOR_K_glue_set : LUT5
    generic map(
      INIT => X"2AFF2A2A"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_WAIT_FOR_K_381,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_EVEN_130,
      I2 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_434,
      I3 => U0_gpcs_pma_inst_RECEIVER_SYNC_STATUS_REG_406,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      O => U0_gpcs_pma_inst_RECEIVER_WAIT_FOR_K_glue_set_493
    );
  U0_gpcs_pma_inst_TRANSMITTER_TXCHARDISPVAL_rstpot : LUT4
    generic map(
      INIT => X"0040"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_DISPARITY_196,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_SYNC_DISPARITY_205,
      I3 => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_TX_RESET_INT,
      O => U0_gpcs_pma_inst_TRANSMITTER_TXCHARDISPVAL_rstpot_501
    );
  U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_rstpot : LUT6
    generic map(
      INIT => X"0000000001000000"
    )
    port map (
      I0 => NlwRenamedSig_OI_U0_gpcs_pma_inst_MGT_RX_RESET_INT,
      I1 => U0_gpcs_pma_inst_RECEIVER_K28p5_REG1_EVEN_AND_144_o,
      I2 => U0_gpcs_pma_inst_RECEIVER_R_410,
      I3 => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      I5 => U0_gpcs_pma_inst_RECEIVER_S_438,
      O => U0_gpcs_pma_inst_RECEIVER_EXT_ILLEGAL_K_rstpot_509
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_glue_rst : LUT6
    generic map(
      INIT => X"2A2A2AAA2AAA2A88"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_327,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD,
      I3 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329,
      I5 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_glue_rst_486
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_In2 : MUXF7
    port map (
      I0 => N63,
      I1 => N64,
      S => U0_gpcs_pma_inst_SYNCHRONISATION_CGBAD,
      O => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_In2_331
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_In2_F : LUT6
    generic map(
      INIT => X"F0F4540400040404"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330,
      I1 => U0_gpcs_pma_inst_RXCHARISCOMMA_INT_126,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_327,
      I3 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328,
      I5 => U0_gpcs_pma_inst_SYNCHRONISATION_GOOD_CGS_1_PWR_23_o_equal_19_o,
      O => N63
    );
  U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_In2_G : LUT5
    generic map(
      INIT => X"DBDB8988"
    )
    port map (
      I0 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd3_329,
      I1 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd2_328,
      I2 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd4_330,
      I3 => U0_gpcs_pma_inst_RXCHARISCOMMA_INT_126,
      I4 => U0_gpcs_pma_inst_SYNCHRONISATION_STATE_FSM_FFd1_327,
      O => N64
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_rstpot : MUXF7
    port map (
      I0 => N65,
      I1 => N66,
      S => U0_gpcs_pma_inst_RXDATA_INT(5),
      O => U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_rstpot_511
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_rstpot_F : LUT6
    generic map(
      INIT => X"0404040004000000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_POS_FALSE_NIT_NEG_OR_118_o12_475,
      I1 => U0_gpcs_pma_inst_RXNOTINTABLE_INT_115,
      I2 => U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_POS_FALSE_NIT_NEG_OR_118_o13_476,
      I3 => U0_gpcs_pma_inst_RXDISPERR_INT_116,
      I4 => U0_gpcs_pma_inst_RXDATA_INT(1),
      I5 => U0_gpcs_pma_inst_RXDATA_INT(7),
      O => N65
    );
  U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_rstpot_G : LUT5
    generic map(
      INIT => X"00200000"
    )
    port map (
      I0 => U0_gpcs_pma_inst_RXDATA_INT(2),
      I1 => U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_POS_FALSE_NIT_NEG_OR_118_o12_475,
      I2 => U0_gpcs_pma_inst_RXNOTINTABLE_INT_115,
      I3 => U0_gpcs_pma_inst_RECEIVER_FALSE_NIT_POS_FALSE_NIT_NEG_OR_118_o1,
      I4 => U0_gpcs_pma_inst_RXCHARISK_INT_125,
      O => N66
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In3 : MUXF7
    port map (
      I0 => N67,
      I1 => N68,
      S => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_303,
      O => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In3_F : LUT6
    generic map(
      INIT => X"AAAAAAAA00000002"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In3_457,
      O => N67
    );
  U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In3_G : LUT6
    generic map(
      INIT => X"44450001FFFFFFFF"
    )
    port map (
      I0 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd3_304,
      I1 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd2_305,
      I2 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_MDIO_IN_REG_258,
      I3 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd1_306,
      I4 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDIO_INTERFACE_1_STATE_FSM_FFd4_In1,
      I5 => U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_MDC_RISING_REG1_248,
      O => N68
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_TX_PACKET_CODE_GRP_CNT_1_MUX_186_o11 : MUXF7
    port map (
      I0 => N69,
      I1 => N70,
      S => U0_gpcs_pma_inst_TRANSMITTER_XMIT_CONFIG_INT_200,
      O => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_CODE_GRP_CNT_1_MUX_186_o
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_TX_PACKET_CODE_GRP_CNT_1_MUX_186_o11_F : LUT6
    generic map(
      INIT => X"FFFFFFFF00000001"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_S_209,
      I1 => U0_gpcs_pma_inst_TRANSMITTER_V_197,
      I2 => U0_gpcs_pma_inst_TRANSMITTER_T_207,
      I3 => U0_gpcs_pma_inst_TRANSMITTER_R_198,
      I4 => U0_gpcs_pma_inst_TRANSMITTER_TX_PACKET_199,
      I5 => NlwRenamedSig_OI_U0_gpcs_pma_inst_HAS_MANAGEMENT_MDIO_ISOLATE_REG,
      O => N69
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mmux_TX_PACKET_CODE_GRP_CNT_1_MUX_186_o11_G : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(1),
      I1 => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => N70
    );
  U0_gpcs_pma_inst_TRANSMITTER_Mcount_CODE_GRP_CNT_xor_0_11_INV_0 : INV
    port map (
      I => U0_gpcs_pma_inst_TRANSMITTER_CODE_GRP_CNT(0),
      O => U0_gpcs_pma_inst_TRANSMITTER_Result(0)
    );
  U0_gpcs_pma_inst_Mshreg_STATUS_VECTOR_0 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => NlwRenamedSig_OI_status_vector(7),
      A1 => NlwRenamedSig_OI_status_vector(7),
      A2 => NlwRenamedSig_OI_status_vector(7),
      A3 => NlwRenamedSig_OI_status_vector(7),
      CE => N0,
      CLK => userclk2,
      D => U0_gpcs_pma_inst_SYNCHRONISATION_SYNC_STATUS_129,
      Q => U0_gpcs_pma_inst_Mshreg_STATUS_VECTOR_0_526,
      Q15 => NLW_U0_gpcs_pma_inst_Mshreg_STATUS_VECTOR_0_Q15_UNCONNECTED
    );
  U0_gpcs_pma_inst_STATUS_VECTOR_0 : FDE
    port map (
      C => userclk2,
      CE => N0,
      D => U0_gpcs_pma_inst_Mshreg_STATUS_VECTOR_0_526,
      Q => NlwRenamedSignal_U0_gpcs_pma_inst_STATUS_VECTOR_0
    );
  U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_7 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => N0,
      A1 => N0,
      A2 => NlwRenamedSig_OI_status_vector(7),
      A3 => NlwRenamedSig_OI_status_vector(7),
      CE => N0,
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_INT(7),
      Q => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_7_527,
      Q15 => NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_7_Q15_UNCONNECTED
    );
  U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_7 : FDE
    port map (
      C => userclk2,
      CE => N0,
      D => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_7_527,
      Q => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(7)
    );
  U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_6 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => N0,
      A1 => N0,
      A2 => NlwRenamedSig_OI_status_vector(7),
      A3 => NlwRenamedSig_OI_status_vector(7),
      CE => N0,
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_INT(6),
      Q => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_6_528,
      Q15 => NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_6_Q15_UNCONNECTED
    );
  U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_6 : FDE
    port map (
      C => userclk2,
      CE => N0,
      D => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_6_528,
      Q => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(6)
    );
  U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_5 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => N0,
      A1 => N0,
      A2 => NlwRenamedSig_OI_status_vector(7),
      A3 => NlwRenamedSig_OI_status_vector(7),
      CE => N0,
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_INT(5),
      Q => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_5_529,
      Q15 => NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_5_Q15_UNCONNECTED
    );
  U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_5 : FDE
    port map (
      C => userclk2,
      CE => N0,
      D => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_5_529,
      Q => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(5)
    );
  U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_2 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => N0,
      A1 => N0,
      A2 => NlwRenamedSig_OI_status_vector(7),
      A3 => NlwRenamedSig_OI_status_vector(7),
      CE => N0,
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_INT(2),
      Q => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_2_530,
      Q15 => NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_2_Q15_UNCONNECTED
    );
  U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_2 : FDE
    port map (
      C => userclk2,
      CE => N0,
      D => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_2_530,
      Q => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(2)
    );
  U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_4 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => N0,
      A1 => N0,
      A2 => NlwRenamedSig_OI_status_vector(7),
      A3 => NlwRenamedSig_OI_status_vector(7),
      CE => N0,
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_INT(4),
      Q => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_4_531,
      Q15 => NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_4_Q15_UNCONNECTED
    );
  U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_4 : FDE
    port map (
      C => userclk2,
      CE => N0,
      D => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_4_531,
      Q => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(4)
    );
  U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_3 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => N0,
      A1 => N0,
      A2 => NlwRenamedSig_OI_status_vector(7),
      A3 => NlwRenamedSig_OI_status_vector(7),
      CE => N0,
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_INT(3),
      Q => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_3_532,
      Q15 => NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_3_Q15_UNCONNECTED
    );
  U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_3 : FDE
    port map (
      C => userclk2,
      CE => N0,
      D => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_3_532,
      Q => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(3)
    );
  U0_gpcs_pma_inst_RECEIVER_Mshreg_EXTEND_REG3 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => NlwRenamedSig_OI_status_vector(7),
      A1 => NlwRenamedSig_OI_status_vector(7),
      A2 => NlwRenamedSig_OI_status_vector(7),
      A3 => NlwRenamedSig_OI_status_vector(7),
      CE => N0,
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG1_420,
      Q => U0_gpcs_pma_inst_RECEIVER_Mshreg_EXTEND_REG3_533,
      Q15 => NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_EXTEND_REG3_Q15_UNCONNECTED
    );
  U0_gpcs_pma_inst_RECEIVER_EXTEND_REG3 : FDE
    port map (
      C => userclk2,
      CE => N0,
      D => U0_gpcs_pma_inst_RECEIVER_Mshreg_EXTEND_REG3_533,
      Q => U0_gpcs_pma_inst_RECEIVER_EXTEND_REG3_419
    );
  U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_1 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => N0,
      A1 => N0,
      A2 => NlwRenamedSig_OI_status_vector(7),
      A3 => NlwRenamedSig_OI_status_vector(7),
      CE => N0,
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_INT(1),
      Q => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_1_534,
      Q15 => NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_1_Q15_UNCONNECTED
    );
  U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_1 : FDE
    port map (
      C => userclk2,
      CE => N0,
      D => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_1_534,
      Q => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(1)
    );
  U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_0 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => N0,
      A1 => N0,
      A2 => NlwRenamedSig_OI_status_vector(7),
      A3 => NlwRenamedSig_OI_status_vector(7),
      CE => N0,
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RXDATA_INT(0),
      Q => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_0_535,
      Q15 => NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_0_Q15_UNCONNECTED
    );
  U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5_0 : FDE
    port map (
      C => userclk2,
      CE => N0,
      D => U0_gpcs_pma_inst_RECEIVER_Mshreg_RXDATA_REG5_0_535,
      Q => U0_gpcs_pma_inst_RECEIVER_RXDATA_REG5(0)
    );
  U0_gpcs_pma_inst_RECEIVER_Mshreg_CGBAD_REG2 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => N0,
      A1 => NlwRenamedSig_OI_status_vector(7),
      A2 => NlwRenamedSig_OI_status_vector(7),
      A3 => NlwRenamedSig_OI_status_vector(7),
      CE => N0,
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_CGBAD_409,
      Q => U0_gpcs_pma_inst_RECEIVER_CGBAD_REG2,
      Q15 => NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_CGBAD_REG2_Q15_UNCONNECTED
    );
  U0_gpcs_pma_inst_RECEIVER_Mshreg_SOP_REG2 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => NlwRenamedSig_OI_status_vector(7),
      A1 => NlwRenamedSig_OI_status_vector(7),
      A2 => NlwRenamedSig_OI_status_vector(7),
      A3 => NlwRenamedSig_OI_status_vector(7),
      CE => N0,
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_SOP_402,
      Q => U0_gpcs_pma_inst_RECEIVER_Mshreg_SOP_REG2_536,
      Q15 => NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_SOP_REG2_Q15_UNCONNECTED
    );
  U0_gpcs_pma_inst_RECEIVER_SOP_REG2 : FDE
    port map (
      C => userclk2,
      CE => N0,
      D => U0_gpcs_pma_inst_RECEIVER_Mshreg_SOP_REG2_536,
      Q => U0_gpcs_pma_inst_RECEIVER_SOP_REG2_422
    );
  U0_gpcs_pma_inst_RECEIVER_Mshreg_FALSE_CARRIER_REG2 : SRLC16E
    generic map(
      INIT => X"0000"
    )
    port map (
      A0 => N0,
      A1 => NlwRenamedSig_OI_status_vector(7),
      A2 => NlwRenamedSig_OI_status_vector(7),
      A3 => NlwRenamedSig_OI_status_vector(7),
      CE => N0,
      CLK => userclk2,
      D => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_380,
      Q => U0_gpcs_pma_inst_RECEIVER_FALSE_CARRIER_REG2,
      Q15 => NLW_U0_gpcs_pma_inst_RECEIVER_Mshreg_FALSE_CARRIER_REG2_Q15_UNCONNECTED
    );

end STRUCTURE;

-- synthesis translate_on
