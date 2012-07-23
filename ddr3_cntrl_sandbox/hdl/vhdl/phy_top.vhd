--*****************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2006, 2007, 2008 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: 3.6.1
--  \   \         Application: MIG
--  /   /         Filename: ddr2_phy_top.vhd
-- /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:03 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR/DDR2
--Purpose:
--   Top-level for memory physical layer (PHY) interface
--Reference:
--Revision History:
--   Rev 1.1 - Parameter USE_DM_PORT added. PK. 6/25/08
--   Rev 1.2 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
--   Rev 1.3 - Parameter CS_BITS added. PK. 10/8/08
--   Rev 1.4 - Parameter IODELAY_GRP added. PK. 11/27/08
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity phy_top is
  generic (
    -- Following parameters are for 72-bit RDIMM design (for ML561 Reference
    -- board design). Actual values may be different. Actual parameters values
    -- are passed from design top module mig_36_1 module. Please refer to
    -- the mig_36_1 module for actual values.
    BANK_WIDTH             :       integer := 2;
    CLK_WIDTH              :       integer := 1;
    CKE_WIDTH              :       integer := 1;
    COL_WIDTH              :       integer := 10;
    CS_BITS                :       integer := 0;
    CS_NUM                 :       integer := 1;
    CS_WIDTH               :       integer := 1;
    USE_DM_PORT            :       integer := 1;
    DM_WIDTH               :       integer := 9;
    DQ_WIDTH               :       integer := 72;
    DQ_BITS                :       integer := 7;
    DQ_PER_DQS             :       integer := 8;
    DQS_WIDTH              :       integer := 9;
    DQS_BITS               :       integer := 4;
    HIGH_PERFORMANCE_MODE  :       boolean := TRUE;
    IODELAY_GRP            :       string  := "IODELAY_MIG";
    ODT_WIDTH              :       integer := 1;
    ROW_WIDTH              :       integer := 14;
    ADDITIVE_LAT           :       integer := 0;
    TWO_T_TIME_EN          :       integer := 0;
    BURST_LEN              :       integer := 4;
    BURST_TYPE             :       integer := 0;
    CAS_LAT                :       integer := 5;
    ECC_ENABLE             :       integer := 0;
    ODT_TYPE               :       integer := 1;
    DDR_TYPE               :       integer := 1;
    REDUCE_DRV             :       integer := 0;
    REG_ENABLE             :       integer := 1;
    TWR                    :       integer := 15000;
    CLK_PERIOD             :       integer := 3000;
    SIM_ONLY               :       integer := 0;
    DEBUG_EN               :       integer := 0;
    FPGA_SPEED_GRADE       :       integer    := 2
    );
  port (
    clk0                   : in    std_logic;
    clk90                  : in    std_logic;
    clkdiv0                : in    std_logic;
    rst0                   : in    std_logic;
    rst90                  : in    std_logic;
    rstdiv0                : in    std_logic;
    ctrl_wren              : in    std_logic;
    ctrl_addr              : in    std_logic_vector(ROW_WIDTH-1 downto 0);
    ctrl_ba                : in    std_logic_vector(BANK_WIDTH-1 downto 0);
    ctrl_ras_n             : in    std_logic;
    ctrl_cas_n             : in    std_logic;
    ctrl_we_n              : in    std_logic;
    ctrl_cs_n              : in    std_logic_vector(CS_NUM-1 downto 0);
    ctrl_rden              : in    std_logic;
    ctrl_ref_flag          : in    std_logic;
    wdf_data               : in    std_logic_vector((2*DQ_WIDTH)-1 downto 0);
    wdf_mask_data          : in    std_logic_vector((2*DQ_WIDTH/8)-1 downto 0);
    wdf_rden               : out   std_logic;
    phy_init_done          : out   std_logic;
    phy_calib_rden         : out   std_logic_vector(DQS_WIDTH-1 downto 0);
    phy_calib_rden_sel     : out   std_logic_vector(DQS_WIDTH-1 downto 0);
    rd_data_rise           : out   std_logic_vector(DQ_WIDTH-1 downto 0);
    rd_data_fall           : out   std_logic_vector(DQ_WIDTH-1 downto 0);
    ddr_ck                 : out   std_logic_vector(CLK_WIDTH-1 downto 0);
    ddr_ck_n               : out   std_logic_vector(CLK_WIDTH-1 downto 0);
    ddr_addr               : out   std_logic_vector(ROW_WIDTH-1 downto 0);
    ddr_ba                 : out   std_logic_vector(BANK_WIDTH-1 downto 0);
    ddr_ras_n              : out   std_logic;
    ddr_cas_n              : out   std_logic;
    ddr_we_n               : out   std_logic;
    ddr_cs_n               : out   std_logic_vector(CS_WIDTH-1 downto 0);
    ddr_cke                : out   std_logic_vector(CKE_WIDTH-1 downto 0);
    ddr_odt                : out   std_logic_vector(ODT_WIDTH-1 downto 0);
    ddr_dm                 : out   std_logic_vector(DM_WIDTH-1 downto 0);
    ddr_dqs                : inout std_logic_vector(DQS_WIDTH-1 downto 0);
    ddr_dqs_n              : inout std_logic_vector(DQS_WIDTH-1 downto 0);
    ddr_dq                 : inout std_logic_vector(DQ_WIDTH-1 downto 0);
    -- Debug signals (optional use)
    dbg_idel_up_all        : in    std_logic;
    dbg_idel_down_all      : in    std_logic;
    dbg_idel_up_dq         : in    std_logic;
    dbg_idel_down_dq       : in    std_logic;
    dbg_idel_up_dqs        : in    std_logic;
    dbg_idel_down_dqs      : in    std_logic;
    dbg_idel_up_gate       : in    std_logic;
    dbg_idel_down_gate     : in    std_logic;
    dbg_sel_idel_dq        : in    std_logic_vector(DQ_BITS-1 downto 0);
    dbg_sel_all_idel_dq    : in    std_logic;
    dbg_sel_idel_dqs       : in    std_logic_vector(DQS_BITS downto 0);
    dbg_sel_all_idel_dqs   : in    std_logic;
    dbg_sel_idel_gate      : in    std_logic_vector(DQS_BITS downto 0);
    dbg_sel_all_idel_gate  : in    std_logic;
    dbg_calib_done         : out   std_logic_vector(3 downto 0);
    dbg_calib_err          : out   std_logic_vector(3 downto 0);
    dbg_calib_dq_tap_cnt   : out   std_logic_vector((6*DQ_WIDTH)-1 downto 0);
    dbg_calib_dqs_tap_cnt  : out   std_logic_vector((6*DQS_WIDTH)-1 downto 0);
    dbg_calib_gate_tap_cnt : out   std_logic_vector((6*DQS_WIDTH)-1 downto 0);
    dbg_calib_rd_data_sel  : out   std_logic_vector(DQS_WIDTH-1 downto 0);
    dbg_calib_rden_dly     : out   std_logic_vector((5*DQS_WIDTH)-1 downto 0);
    dbg_calib_gate_dly     : out   std_logic_vector((5*DQS_WIDTH)-1 downto 0)
    );
end entity phy_top;

architecture syn of phy_top is

  component phy_ctl_io

    generic (
      BANK_WIDTH    : integer;
      CKE_WIDTH     : integer;
      COL_WIDTH     : integer;
      CS_NUM        : integer;
      TWO_T_TIME_EN : integer;
      CS_WIDTH      : integer;
      ODT_WIDTH     : integer;
      ROW_WIDTH     : integer;
      DDR_TYPE      : integer);
    port (
      clk0              : in  std_logic;
      clk90             : in  std_logic;
      rst0              : in  std_logic;
      rst90             : in  std_logic;
      ctrl_addr         : in  std_logic_vector(ROW_WIDTH-1 downto 0);
      ctrl_ba           : in  std_logic_vector(BANK_WIDTH-1 downto 0);
      ctrl_ras_n        : in  std_logic;
      ctrl_cas_n        : in  std_logic;
      ctrl_we_n         : in  std_logic;
      ctrl_cs_n         : in  std_logic_vector(CS_NUM-1 downto 0);
      phy_init_addr     : in  std_logic_vector(ROW_WIDTH-1 downto 0);
      phy_init_ba       : in  std_logic_vector(BANK_WIDTH-1 downto 0);
      phy_init_ras_n    : in  std_logic;
      phy_init_cas_n    : in  std_logic;
      phy_init_we_n     : in  std_logic;
      phy_init_cs_n     : in  std_logic_vector(CS_NUM-1 downto 0);
      phy_init_cke      : in  std_logic_vector(CKE_WIDTH-1 downto 0);
      phy_init_data_sel : in  std_logic;
      odt               : in  std_logic_vector(CS_NUM-1 downto 0);
      ddr_addr          : out std_logic_vector(ROW_WIDTH-1 downto 0);
      ddr_ba            : out std_logic_vector(BANK_WIDTH-1 downto 0);
      ddr_ras_n         : out std_logic;
      ddr_cas_n         : out std_logic;
      ddr_we_n          : out std_logic;
      ddr_cke           : out std_logic_vector(CKE_WIDTH-1 downto 0);
      ddr_cs_n          : out std_logic_vector(CS_WIDTH-1 downto 0);
      ddr_odt           : out std_logic_vector(ODT_WIDTH-1 downto 0));
  end component;

  component phy_init
    generic (
      BANK_WIDTH    : integer;
      CKE_WIDTH     : integer;
      COL_WIDTH     : integer;
      CS_BITS       : integer;
      CS_NUM        : integer;
      DQ_WIDTH      : integer;
      ODT_WIDTH     : integer;
      ROW_WIDTH     : integer;
      ADDITIVE_LAT  : integer;
      BURST_LEN     : integer;
      TWO_T_TIME_EN : integer;
      BURST_TYPE    : integer;
      CAS_LAT       : integer;
      ODT_TYPE      : integer;
      REDUCE_DRV    : integer;
      REG_ENABLE    : integer;
      TWR           : integer;
      CLK_PERIOD    : integer;
      DDR_TYPE      : integer;
      SIM_ONLY      : integer);
    port (
      clk0              : in  std_logic;
      clkdiv0           : in  std_logic;
      rst0              : in  std_logic;
      rstdiv0           : in  std_logic;
      calib_done        : in  std_logic_vector(3 downto 0);
      ctrl_ref_flag     : in  std_logic;
      calib_ref_req     : in  std_logic;
      calib_start       : out std_logic_vector(3 downto 0);
      calib_ref_done    : out std_logic;
      phy_init_wren     : out std_logic;
      phy_init_rden     : out std_logic;
      phy_init_addr     : out std_logic_vector(ROW_WIDTH-1 downto 0);
      phy_init_ba       : out std_logic_vector(BANK_WIDTH-1 downto 0);
      phy_init_ras_n    : out std_logic;
      phy_init_cas_n    : out std_logic;
      phy_init_we_n     : out std_logic;
      phy_init_cs_n     : out std_logic_vector(CS_NUM-1 downto 0);
      phy_init_cke      : out std_logic_vector(CKE_WIDTH-1 downto 0);
      phy_init_done     : out std_logic;
      phy_init_data_sel : out std_logic);
  end component;

  component phy_io
    generic (
      CLK_WIDTH             : integer;
      USE_DM_PORT           : integer;
      DM_WIDTH              : integer;
      DQ_WIDTH              : integer;
      DQ_BITS               : integer;
      DQ_PER_DQS            : integer;
      DQS_BITS              : integer;
      DQS_WIDTH             : integer;
      HIGH_PERFORMANCE_MODE : boolean;
      IODELAY_GRP           : string;
      ODT_WIDTH             : integer;
      ADDITIVE_LAT          : integer;
      CAS_LAT               : integer;
      REG_ENABLE            : integer;
      CLK_PERIOD            : integer;
      DDR_TYPE              : integer;
      SIM_ONLY              : integer;
      DEBUG_EN              : integer;
      FPGA_SPEED_GRADE      : integer);
    port (
      clk0                   : in    std_logic;
      clk90                  : in    std_logic;
      clkdiv0                : in    std_logic;
      rst0                   : in    std_logic;
      rst90                  : in    std_logic;
      rstdiv0                : in    std_logic;
      dm_ce                  : in    std_logic;
      dq_oe_n                : in    std_logic_vector(1 downto 0);
      dqs_oe_n               : in    std_logic;
      dqs_rst_n              : in    std_logic;
      calib_start            : in    std_logic_vector(3 downto 0);
      ctrl_rden              : in    std_logic;
      phy_init_rden          : in    std_logic;
      calib_ref_done         : in    std_logic;
      calib_done             : out   std_logic_vector(3 downto 0);
      calib_ref_req          : out   std_logic;
      calib_rden             : out   std_logic_vector(DQS_WIDTH-1 downto 0);
      calib_rden_sel         : out   std_logic_vector(DQS_WIDTH-1 downto 0);
      wr_data_rise           : in    std_logic_vector(DQ_WIDTH-1 downto 0);
      wr_data_fall           : in    std_logic_vector(DQ_WIDTH-1 downto 0);
      mask_data_rise         : in    std_logic_vector((DQ_WIDTH/8)-1 downto 0);
      mask_data_fall         : in    std_logic_vector((DQ_WIDTH/8)-1 downto 0);
      rd_data_rise           : out   std_logic_vector((DQ_WIDTH)-1 downto 0);
      rd_data_fall           : out   std_logic_vector((DQ_WIDTH)-1 downto 0);
      ddr_ck                 : out   std_logic_vector(CLK_WIDTH-1 downto 0);
      ddr_ck_n               : out   std_logic_vector(CLK_WIDTH-1 downto 0);
      ddr_dm                 : out   std_logic_vector(DM_WIDTH-1 downto 0);
      ddr_dqs                : inout std_logic_vector(DQS_WIDTH-1 downto 0);
      ddr_dqs_n              : inout std_logic_vector(DQS_WIDTH-1 downto 0);
      ddr_dq                 : inout std_logic_vector(DQ_WIDTH-1 downto 0);
      dbg_idel_up_all        : in    std_logic;
      dbg_idel_down_all      : in    std_logic;
      dbg_idel_up_dq         : in    std_logic;
      dbg_idel_down_dq       : in    std_logic;
      dbg_idel_up_dqs        : in    std_logic;
      dbg_idel_down_dqs      : in    std_logic;
      dbg_idel_up_gate       : in    std_logic;
      dbg_idel_down_gate     : in    std_logic;
      dbg_sel_idel_dq        : in    std_logic_vector(DQ_BITS-1 downto 0);
      dbg_sel_all_idel_dq    : in    std_logic;
      dbg_sel_idel_dqs       : in    std_logic_vector(DQS_BITS downto 0);
      dbg_sel_all_idel_dqs   : in    std_logic;
      dbg_sel_idel_gate      : in    std_logic_vector(DQS_BITS downto 0);
      dbg_sel_all_idel_gate  : in    std_logic;
      dbg_calib_done         : out   std_logic_vector(3 downto 0);
      dbg_calib_err          : out   std_logic_vector(3 downto 0);
      dbg_calib_dq_tap_cnt   : out   std_logic_vector((6*DQ_WIDTH)-1 downto 0);
      dbg_calib_dqs_tap_cnt  : out   std_logic_vector((6*DQS_WIDTH)-1
                                                      downto 0);
      dbg_calib_gate_tap_cnt : out   std_logic_vector((6*DQS_WIDTH)-1
                                                      downto 0);
      dbg_calib_rd_data_sel  : out   std_logic_vector(DQS_WIDTH - 1 downto 0);
      dbg_calib_rden_dly     : out   std_logic_vector((5*DQS_WIDTH)-1
                                                      downto 0);
      dbg_calib_gate_dly     : out   std_logic_vector((5*DQS_WIDTH)-1
                                                      downto 0));
  end component;

  component phy_write
    generic (
      DQ_WIDTH     : integer;
      CS_NUM       : integer;
      ADDITIVE_LAT : integer;
      CAS_LAT      : integer;
      ECC_ENABLE   : integer;
      ODT_TYPE     : integer;
      REG_ENABLE   : integer;
      DDR_TYPE     : integer);
    port (
      clk0              : in  std_logic;
      clk90             : in  std_logic;
      rst90             : in  std_logic;
      wdf_data          : in  std_logic_vector((2*DQ_WIDTH)-1 downto 0);
      wdf_mask_data     : in  std_logic_vector((2*DQ_WIDTH/8)-1 downto 0);
      ctrl_wren         : in  std_logic;
      phy_init_wren     : in  std_logic;
      phy_init_data_sel : in  std_logic;
      dm_ce             : out std_logic;
      dq_oe_n           : out std_logic_vector(1 downto 0);
      dqs_oe_n          : out std_logic;
      dqs_rst_n         : out std_logic;
      wdf_rden          : out std_logic;
      odt               : out std_logic_vector(CS_NUM-1 downto 0);
      wr_data_rise      : out std_logic_vector(DQ_WIDTH-1 downto 0);
      wr_data_fall      : out std_logic_vector(DQ_WIDTH-1 downto 0);
      mask_data_rise    : out std_logic_vector((DQ_WIDTH/8)-1 downto 0);
      mask_data_fall    : out std_logic_vector((DQ_WIDTH/8)-1 downto 0));
  end component;

  signal calib_done        : std_logic_vector(3 downto 0);
  signal calib_ref_done    : std_logic;
  signal calib_ref_req     : std_logic;
  signal calib_start       : std_logic_vector(3 downto 0);
  signal dm_ce             : std_logic;
  signal dq_oe_n           : std_logic_vector(1 downto 0);
  signal dqs_oe_n          : std_logic;
  signal dqs_rst_n         : std_logic;
  signal mask_data_fall    : std_logic_vector((DQ_WIDTH/8)-1 downto 0);
  signal mask_data_rise    : std_logic_vector((DQ_WIDTH/8)-1 downto 0);
  signal odt               : std_logic_vector(CS_NUM-1 downto 0);
  signal phy_init_addr     : std_logic_vector(ROW_WIDTH-1 downto 0);
  signal phy_init_ba       : std_logic_vector(BANK_WIDTH-1 downto 0);
  signal phy_init_cas_n    : std_logic;
  signal phy_init_cke      : std_logic_vector(CKE_WIDTH-1 downto 0);
  signal phy_init_cs_n     : std_logic_vector(CS_NUM-1 downto 0);
  signal phy_init_data_sel : std_logic;
  signal phy_init_ras_n    : std_logic;
  signal phy_init_rden     : std_logic;
  signal phy_init_we_n     : std_logic;
  signal phy_init_wren     : std_logic;
  signal wr_data_fall      : std_logic_vector(DQ_WIDTH-1 downto 0);
  signal wr_data_rise      : std_logic_vector(DQ_WIDTH-1 downto 0);

  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of syn : architecture IS
    "mig_v3_61_ddr2_sdram_v5, Coregen 12.4";

  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of syn : architecture IS "ddr2_sdram_v5,mig_v3_61,{component_name=ddr2_phy_top, BANK_WIDTH=2, CKE_WIDTH=1, CLK_WIDTH=2, COL_WIDTH=10, CS_NUM=1, CS_WIDTH=1, DM_WIDTH=8, DQ_WIDTH=64, DQ_PER_DQS=8, DQS_WIDTH=8, ODT_WIDTH=1, ROW_WIDTH=13, ADDITIVE_LAT=0, BURST_LEN=4, BURST_TYPE=0, CAS_LAT=4, ECC_ENABLE=0, MULTI_BANK_EN=1, TWO_T_TIME_EN=1, ODT_TYPE=1, REDUCE_DRV=0, REG_ENABLE=0, TREFI_NS=7800, TRAS=40000, TRCD=15000, TRFC=105000, TRP=15000, TRTP=7500, TWR=15000, TWTR=7500, CLK_PERIOD=5000, RST_ACT_LOW=1, INTERFACE_TYPE=DDR2_SDRAM, LANGUAGE=VHDL, SYNTHESIS_TOOL=ISE, NO_OF_CONTROLLERS=1}";

begin

  u_phy_write : phy_write
    generic map (
      DQ_WIDTH       => DQ_WIDTH,
      CS_NUM         => CS_NUM,
      ADDITIVE_LAT   => ADDITIVE_LAT,
      CAS_LAT        => CAS_LAT,
      ECC_ENABLE     => ECC_ENABLE,
      ODT_TYPE       => ODT_TYPE,
      REG_ENABLE     => REG_ENABLE,
      DDR_TYPE       => DDR_TYPE
      )
    port map (
      clk0              => clk0,
      clk90             => clk90,
      rst90             => rst90,
      wdf_data          => wdf_data,
      wdf_mask_data     => wdf_mask_data,
      ctrl_wren         => ctrl_wren,
      phy_init_wren     => phy_init_wren,
      phy_init_data_sel => phy_init_data_sel,
      dm_ce             => dm_ce,
      dq_oe_n           => dq_oe_n,
      dqs_oe_n          => dqs_oe_n,
      dqs_rst_n         => dqs_rst_n,
      wdf_rden          => wdf_rden,
      odt               => odt,
      wr_data_rise      => wr_data_rise,
      wr_data_fall      => wr_data_fall,
      mask_data_rise    => mask_data_rise,
      mask_data_fall    => mask_data_fall
      );

  u_phy_io : phy_io
    generic map (
      CLK_WIDTH              => CLK_WIDTH,
      USE_DM_PORT            => USE_DM_PORT,
      DM_WIDTH               => DM_WIDTH,
      DQ_WIDTH               => DQ_WIDTH,
      DQ_BITS                => DQ_BITS,
      DQ_PER_DQS             => DQ_PER_DQS,
      DQS_BITS               => DQS_BITS,
      DQS_WIDTH              => DQS_WIDTH,
      HIGH_PERFORMANCE_MODE  => HIGH_PERFORMANCE_MODE,
      IODELAY_GRP            => IODELAY_GRP,
      ODT_WIDTH              => ODT_WIDTH,
      ADDITIVE_LAT           => ADDITIVE_LAT,
      CAS_LAT                => CAS_LAT,
      REG_ENABLE             => REG_ENABLE,
      CLK_PERIOD             => CLK_PERIOD,
      DDR_TYPE               => DDR_TYPE,
      SIM_ONLY               => SIM_ONLY,
      DEBUG_EN               => DEBUG_EN,
      FPGA_SPEED_GRADE       => FPGA_SPEED_GRADE
      )
    port map (
      clk0                   => clk0,
      clk90                  => clk90,
      clkdiv0                => clkdiv0,
      rst0                   => rst0,
      rst90                  => rst90,
      rstdiv0                => rstdiv0,
      dm_ce                  => dm_ce,
      dq_oe_n                => dq_oe_n,
      dqs_oe_n               => dqs_oe_n,
      dqs_rst_n              => dqs_rst_n,
      calib_start            => calib_start,
      ctrl_rden              => ctrl_rden,
      phy_init_rden          => phy_init_rden,
      calib_ref_done         => calib_ref_done,
      calib_done             => calib_done,
      calib_ref_req          => calib_ref_req,
      calib_rden             => phy_calib_rden,
      calib_rden_sel         => phy_calib_rden_sel,
      wr_data_rise           => wr_data_rise,
      wr_data_fall           => wr_data_fall,
      mask_data_rise         => mask_data_rise,
      mask_data_fall         => mask_data_fall,
      rd_data_rise           => rd_data_rise,
      rd_data_fall           => rd_data_fall,
      ddr_ck                 => ddr_ck,
      ddr_ck_n               => ddr_ck_n,
      ddr_dm                 => ddr_dm,
      ddr_dqs                => ddr_dqs,
      ddr_dqs_n              => ddr_dqs_n,
      ddr_dq                 => ddr_dq,
      dbg_idel_up_all        => dbg_idel_up_all,
      dbg_idel_down_all      => dbg_idel_down_all,
      dbg_idel_up_dq         => dbg_idel_up_dq,
      dbg_idel_down_dq       => dbg_idel_down_dq,
      dbg_idel_up_dqs        => dbg_idel_up_dqs,
      dbg_idel_down_dqs      => dbg_idel_down_dqs,
      dbg_idel_up_gate       => dbg_idel_up_gate,
      dbg_idel_down_gate     => dbg_idel_down_gate,
      dbg_sel_idel_dq        => dbg_sel_idel_dq,
      dbg_sel_all_idel_dq    => dbg_sel_all_idel_dq,
      dbg_sel_idel_dqs       => dbg_sel_idel_dqs,
      dbg_sel_all_idel_dqs   => dbg_sel_all_idel_dqs,
      dbg_sel_idel_gate      => dbg_sel_idel_gate,
      dbg_sel_all_idel_gate  => dbg_sel_all_idel_gate,
      dbg_calib_done         => dbg_calib_done,
      dbg_calib_err          => dbg_calib_err,
      dbg_calib_dq_tap_cnt   => dbg_calib_dq_tap_cnt,
      dbg_calib_dqs_tap_cnt  => dbg_calib_dqs_tap_cnt,
      dbg_calib_gate_tap_cnt => dbg_calib_gate_tap_cnt,
      dbg_calib_rd_data_sel  => dbg_calib_rd_data_sel,
      dbg_calib_rden_dly     => dbg_calib_rden_dly,
      dbg_calib_gate_dly     => dbg_calib_gate_dly
      );

  u_phy_ctl_io : phy_ctl_io
    generic map (
      BANK_WIDTH     => BANK_WIDTH,
      CKE_WIDTH      => CKE_WIDTH,
      COL_WIDTH      => COL_WIDTH,
      CS_NUM         => CS_NUM,
      CS_WIDTH       => CS_WIDTH,
      TWO_T_TIME_EN  => TWO_T_TIME_EN,
      ODT_WIDTH      => ODT_WIDTH,
      ROW_WIDTH      => ROW_WIDTH,
      DDR_TYPE       => DDR_TYPE
      )
    port map (
      clk0              => clk0,
      clk90             => clk90,
      rst0              => rst0,
      rst90             => rst90,
      ctrl_addr         => ctrl_addr,
      ctrl_ba           => ctrl_ba,
      ctrl_ras_n        => ctrl_ras_n,
      ctrl_cas_n        => ctrl_cas_n,
      ctrl_we_n         => ctrl_we_n,
      ctrl_cs_n         => ctrl_cs_n,
      phy_init_addr     => phy_init_addr,
      phy_init_ba       => phy_init_ba,
      phy_init_ras_n    => phy_init_ras_n,
      phy_init_cas_n    => phy_init_cas_n,
      phy_init_we_n     => phy_init_we_n,
      phy_init_cs_n     => phy_init_cs_n,
      phy_init_cke      => phy_init_cke,
      phy_init_data_sel => phy_init_data_sel,
      odt               => odt,
      ddr_addr          => ddr_addr,
      ddr_ba            => ddr_ba,
      ddr_ras_n         => ddr_ras_n,
      ddr_cas_n         => ddr_cas_n,
      ddr_we_n          => ddr_we_n,
      ddr_cke           => ddr_cke,
      ddr_cs_n          => ddr_cs_n,
      ddr_odt           => ddr_odt
      );

  u_phy_init : phy_init
    generic map (
      BANK_WIDTH     => BANK_WIDTH,
      CKE_WIDTH      => CKE_WIDTH,
      COL_WIDTH      => COL_WIDTH,
      CS_BITS        => CS_BITS,
      CS_NUM         => CS_NUM,
      DQ_WIDTH       => DQ_WIDTH,
      ODT_WIDTH      => ODT_WIDTH,
      ROW_WIDTH      => ROW_WIDTH,
      ADDITIVE_LAT   => ADDITIVE_LAT,
      BURST_LEN      => BURST_LEN,
      BURST_TYPE     => BURST_TYPE,
      TWO_T_TIME_EN  => TWO_T_TIME_EN,
      CAS_LAT        => CAS_LAT,
      ODT_TYPE       => ODT_TYPE,
      REDUCE_DRV     => REDUCE_DRV,
      REG_ENABLE     => REG_ENABLE,
      TWR            => TWR,
      CLK_PERIOD     => CLK_PERIOD,
      DDR_TYPE       => DDR_TYPE,
      SIM_ONLY       => SIM_ONLY
      )
    port map (
      clk0              => clk0,
      clkdiv0           => clkdiv0,
      rst0              => rst0,
      rstdiv0           => rstdiv0,
      calib_done        => calib_done,
      ctrl_ref_flag     => ctrl_ref_flag,
      calib_ref_req     => calib_ref_req,
      calib_start       => calib_start,
      calib_ref_done    => calib_ref_done,
      phy_init_wren     => phy_init_wren,
      phy_init_rden     => phy_init_rden,
      phy_init_addr     => phy_init_addr,
      phy_init_ba       => phy_init_ba,
      phy_init_ras_n    => phy_init_ras_n,
      phy_init_cas_n    => phy_init_cas_n,
      phy_init_we_n     => phy_init_we_n,
      phy_init_cs_n     => phy_init_cs_n,
      phy_init_cke      => phy_init_cke,
      phy_init_done     => phy_init_done,
      phy_init_data_sel => phy_init_data_sel
      );

end architecture syn;


