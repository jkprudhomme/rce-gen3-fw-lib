--*****************************************************************************
-- Copyright (c) 2006-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, Inc. 
-- All Rights Reserved 
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: $Id: phy_io.vhd,v 1.2 2007/08/28 06:46:24 richc Exp $
--  \   \         Filename: phy_io.v
--  /   /         Date Last Modified:
-- /___/   /\     Date Created: 8/16/06
-- \   \  /  \
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR/DDR2
--Purpose:
--   This module instantiates calibration logic, data, data strobe and the 
--   data mask iobs.
--Reference:
--Revision History:
--   Rev 1.1 - Translated from Verilog to VHDL. 8/1/07  
--   Rev 1.2 - Changed copyright, added calib_ref_done & calib_ref_req ports
--             added keep on en_dqs MD 8/24/07
--*****************************************************************************

--*****************************************************************************
--$Id: phy_io.vhd,v 1.2 2007/08/28 06:46:24 richc Exp $
--$Date: 2007/08/28 06:46:24 $
--$Author: richc $
--$Revision: 1.2 $
--$Source: /devl/xcs/repo/groups/apd_mem/Virtex5/designs/2_0/ddr2/rtl/vhdl/phy_io.vhd,v $
--*****************************************************************************
  
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity phy_io is
  generic (
    CLK_WIDTH    : integer    := 1;
    DM_WIDTH     : integer    := 2;
    DQ_WIDTH     : integer    := 16;
    DQ_BITS      : integer    := 4;
    DQ_PER_DQS   : integer    := 8;
    DQS_BITS     : integer    := 1;
    DQS_WIDTH    : integer    := 2;
    ODT_WIDTH    : integer    := 1;
    ADDITIVE_LAT : integer    := 0;
    CAS_LAT      : integer    := 5;
    REG_ENABLE   : integer    := 0;
    CLK_PERIOD   : integer    := 3000;
    DDR_TYPE     : integer    := 1;
    SIM_ONLY     : integer    := 0;
    DEBUG_EN     : integer    := 0;
    HIGH_PERFORMANCE_MODE : boolean := TRUE;
    IODELAY_GRP           : string  := "IODELAY_MIG";
    FPGA_SPEED_GRADE      : integer := 2
    );
  port (
    clk0                   : in    std_logic;
    clk90                  : in    std_logic;
    clkdiv0                : in    std_logic;
    rst0                   : in    std_logic;
    rst90                  : in    std_logic;
    rst270                 : in    std_logic;
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
    rd_data_rise           : out   std_logic_vector(DQ_WIDTH-1 downto 0);
    rd_data_fall           : out   std_logic_vector(DQ_WIDTH-1 downto 0);
    ddr_ck                 : out   std_logic_vector(CLK_WIDTH-1 downto 0);
    ddr_ck_n               : out   std_logic_vector(CLK_WIDTH-1 downto 0);
    ddr_dm                 : out   std_logic_vector(DM_WIDTH-1 downto 0);
    ddr_dqs                : inout std_logic_vector(DQS_WIDTH-1 downto 0);
    ddr_dqs_n              : inout std_logic_vector(DQS_WIDTH-1 downto 0);
    ddr_dq                 : inout std_logic_vector(DQ_WIDTH-1 downto 0)
    -- Debug signals (optional use)
--    dbg_idel_up_all        : in    std_logic;
--    dbg_idel_down_all      : in    std_logic;
--    dbg_idel_up_dq         : in    std_logic;
--    dbg_idel_down_dq       : in    std_logic;
--    dbg_idel_up_dqs        : in    std_logic;
--    dbg_idel_down_dqs      : in    std_logic;
--    dbg_idel_up_gate       : in    std_logic;
--    dbg_idel_down_gate     : in    std_logic;
--    dbg_sel_idel_dq        : in    std_logic_vector(DQ_BITS-1 downto 0);
--    dbg_sel_all_idel_dq    : in    std_logic;
--    dbg_sel_idel_dqs       : in    std_logic_vector(DQS_BITS downto 0);
--    dbg_sel_all_idel_dqs   : in    std_logic;
--    dbg_sel_idel_gate      : in    std_logic_vector(DQS_BITS downto 0);
--    dbg_sel_all_idel_gate  : in    std_logic;
--    dbg_calib_done         : out   std_logic_vector(3 downto 0);
--    dbg_calib_err          : out   std_logic_vector(3 downto 0);
--    dbg_calib_dq_tap_cnt   : out   std_logic_vector((6*DQ_WIDTH)-1 downto 0);
--    dbg_calib_dqs_tap_cnt  : out   std_logic_vector((6*DQS_WIDTH)-1 downto 0);
--    dbg_calib_gate_tap_cnt : out   std_logic_vector((6*DQS_WIDTH)-1 downto 0);
--    dbg_calib_rd_data_sel  : out   std_logic_vector(DQS_WIDTH-1 downto 0);
--    dbg_calib_rden_dly     : out   std_logic_vector((5*DQS_WIDTH)-1 downto 0);
--    dbg_calib_gate_dly     : out   std_logic_vector((5*DQS_WIDTH)-1 downto 0)
    );
end entity phy_io;

architecture syn of phy_io is

  component phy_calib
    generic (
      DQ_WIDTH     : integer;
      DQ_BITS      : integer;
      DQ_PER_DQS   : integer;
      DQS_BITS     : integer;
      DQS_WIDTH    : integer;
      ADDITIVE_LAT : integer;
      CAS_LAT      : integer;
      REG_ENABLE   : integer;
      CLK_PERIOD   : integer;
      SIM_ONLY     : integer;
      DEBUG_EN     : integer);
    port (
      clk                    : in  std_logic;
      clkdiv                 : in  std_logic;
      rstdiv                 : in  std_logic;
      calib_start            : in  std_logic_vector(3 downto 0);
      ctrl_rden              : in  std_logic;
      phy_init_rden          : in  std_logic;
      rd_data_rise           : in  std_logic_vector(DQ_WIDTH-1 downto 0);
      rd_data_fall           : in  std_logic_vector(DQ_WIDTH-1 downto 0);
      calib_ref_done         : in  std_logic;
      calib_done             : out std_logic_vector(3 downto 0);
      calib_ref_req          : out std_logic;
      calib_rden             : out std_logic_vector(DQS_WIDTH-1 downto 0);
      calib_rden_sel         : out std_logic_vector(DQS_WIDTH-1 downto 0);
      dlyrst_dq              : out std_logic;
      dlyce_dq               : out std_logic_vector(DQ_WIDTH-1 downto 0);
      dlyinc_dq              : out std_logic_vector(DQ_WIDTH-1 downto 0);
      dlyrst_dqs             : out std_logic;
      dlyce_dqs              : out std_logic_vector(DQS_WIDTH-1 downto 0);
      dlyinc_dqs             : out std_logic_vector(DQS_WIDTH-1 downto 0);
      dlyrst_gate            : out std_logic_vector(DQS_WIDTH-1 downto 0);
      dlyce_gate             : out std_logic_vector(DQS_WIDTH-1 downto 0);
      dlyinc_gate            : out std_logic_vector(DQS_WIDTH-1 downto 0);
      en_dqs                 : out std_logic_vector(DQS_WIDTH-1 downto 0);
      rd_data_sel            : out std_logic_vector(DQS_WIDTH-1 downto 0)
--      dbg_idel_up_all        : in  std_logic;
--      dbg_idel_down_all      : in  std_logic;
--      dbg_idel_up_dq         : in  std_logic;
--      dbg_idel_down_dq       : in  std_logic;
--      dbg_idel_up_dqs        : in  std_logic;
--      dbg_idel_down_dqs      : in  std_logic;
--      dbg_idel_up_gate       : in  std_logic;
--      dbg_idel_down_gate     : in  std_logic;
--      dbg_sel_idel_dq        : in  std_logic_vector(DQ_BITS-1 downto 0);
--      dbg_sel_all_idel_dq    : in  std_logic;
--      dbg_sel_idel_dqs       : in  std_logic_vector(DQS_BITS downto 0);
--      dbg_sel_all_idel_dqs   : in  std_logic;
--      dbg_sel_idel_gate      : in  std_logic_vector(DQS_BITS downto 0);
--      dbg_sel_all_idel_gate  : in  std_logic;
--      dbg_calib_done         : out std_logic_vector(3 downto 0);
--      dbg_calib_err          : out std_logic_vector(3 downto 0);
--      dbg_calib_dq_tap_cnt   : out std_logic_vector((6*DQ_WIDTH)-1 downto 0);
--      dbg_calib_dqs_tap_cnt  : out std_logic_vector((6*DQS_WIDTH)-1 downto 0);
--      dbg_calib_gate_tap_cnt : out std_logic_vector((6*DQS_WIDTH)-1 downto 0);
--      dbg_calib_rd_data_sel  : out std_logic_vector(DQS_WIDTH-1 downto 0);
--      dbg_calib_rden_dly     : out std_logic_vector((5*DQS_WIDTH)-1 downto 0);
--      dbg_calib_gate_dly     : out std_logic_vector((5*DQS_WIDTH)-1 downto 0)
);
  end component;

  component phy_dm_iob
    port (
      clk90          : in  std_logic;
      dm_ce          : in  std_logic;
      mask_data_rise : in  std_logic;
      mask_data_fall : in  std_logic;
      ddr_dm         : out std_logic);
  end component;
  
  component phy_dq_iob
    generic (
    HIGH_PERFORMANCE_MODE : boolean;
    IODELAY_GRP           : string;
    FPGA_SPEED_GRADE      : integer);
    port (
      clk0         : in    std_logic;
      clk90        : in    std_logic;
      clkdiv0      : in    std_logic;
      rst90        : in    std_logic;
      dlyinc       : in    std_logic;
      dlyce        : in    std_logic;
      dlyrst       : in    std_logic;
      dq_oe_n      : in    std_logic_vector(1 downto 0);
      dqs          : in    std_logic;
      ce           : in    std_logic;
      rd_data_sel  : in    std_logic;
      wr_data_rise : in    std_logic;
      wr_data_fall : in    std_logic;
      rd_data_rise : out   std_logic;
      rd_data_fall : out   std_logic;
      ddr_dq       : inout std_logic);
  end component;
  
  component phy_dqs_iob
    generic (
      HIGH_PERFORMANCE_MODE : boolean;
      IODELAY_GRP           : string;
      DDR_TYPE : integer);
    port (
      clk0        : in    std_logic;
      clkdiv0     : in    std_logic;
      rst0        : in    std_logic;
      dlyinc_dqs  : in    std_logic;
      dlyce_dqs   : in    std_logic;
      dlyrst_dqs  : in    std_logic;
      dlyinc_gate : in    std_logic;
      dlyce_gate  : in    std_logic;
      dlyrst_gate : in    std_logic;
      dqs_oe_n    : in    std_logic;
      dqs_rst_n   : in    std_logic;
      en_dqs      : in    std_logic;
      ddr_dqs     : inout std_logic;
      ddr_dqs_n   : inout std_logic;
      dq_ce       : out   std_logic;
      delayed_dqs : out   std_logic);
  end component;
  
  -- ratio of # of physical DM outputs to bytes in data bus
  -- may be different - e.g. if using x4 components
  constant DM_TO_BYTE_RATIO : integer := DM_WIDTH / (DQ_WIDTH/8);
  
  signal ddr_ck_q    : std_logic_vector(CLK_WIDTH-1 downto 0);
  signal delayed_dqs : std_logic_vector(DQS_WIDTH-1 downto 0);
  signal dlyce_dq    : std_logic_vector(DQ_WIDTH-1 downto 0);
  signal dlyce_dqs   : std_logic_vector(DQS_WIDTH-1 downto 0);
  signal dlyce_gate  : std_logic_vector(DQS_WIDTH-1 downto 0);
  signal dlyinc_dq   : std_logic_vector(DQ_WIDTH-1 downto 0);
  signal dlyinc_dqs  : std_logic_vector(DQS_WIDTH-1 downto 0);
  signal dlyinc_gate : std_logic_vector(DQS_WIDTH-1 downto 0);
  signal dlyrst_dq   : std_logic;
  signal dlyrst_dqs  : std_logic;
  signal dlyrst_gate : std_logic_vector(DQS_WIDTH-1 downto 0);
  signal dq_ce       : std_logic_vector(DQS_WIDTH-1 downto 0);
  signal en_dqs      : std_logic_vector(DQS_WIDTH-1 downto 0);
  signal rd_data_sel : std_logic_vector(DQS_WIDTH-1 downto 0);

  signal i_rd_data_fall : std_logic_vector(DQ_WIDTH-1 downto 0);
  signal i_rd_data_rise : std_logic_vector(DQ_WIDTH-1 downto 0);

  attribute keep : string; 
  attribute syn_keep : boolean;
  attribute keep of en_dqs : signal is "true";
  attribute syn_keep of en_dqs : signal is true;

  
begin

  rd_data_rise <= i_rd_data_rise;
  rd_data_fall <= i_rd_data_fall;
    
  --***************************************************************************
  
  u_phy_calib : phy_calib
    generic map (
      DQ_WIDTH               => DQ_WIDTH,
      DQ_BITS                => DQ_BITS,
      DQ_PER_DQS             => DQ_PER_DQS,
      DQS_BITS               => DQS_BITS,
      DQS_WIDTH              => DQS_WIDTH,
      ADDITIVE_LAT           => ADDITIVE_LAT,
      CAS_LAT                => CAS_LAT,
      REG_ENABLE             => REG_ENABLE,
      CLK_PERIOD             => CLK_PERIOD,
      SIM_ONLY               => SIM_ONLY,
      DEBUG_EN               => DEBUG_EN
      )
    port map (
      clk                    => clk0,
      clkdiv                 => clkdiv0,
      rstdiv                 => rstdiv0,
      calib_start            => calib_start,
      ctrl_rden              => ctrl_rden,
      phy_init_rden          => phy_init_rden,
      rd_data_rise           => i_rd_data_rise,
      rd_data_fall           => i_rd_data_fall,
      calib_ref_done         => calib_ref_done,
      calib_done             => calib_done,
      calib_ref_req          => calib_ref_req,
      calib_rden             => calib_rden,
      calib_rden_sel         => calib_rden_sel,
      dlyrst_dq              => dlyrst_dq,
      dlyce_dq               => dlyce_dq,
      dlyinc_dq              => dlyinc_dq,
      dlyrst_dqs             => dlyrst_dqs,
      dlyce_dqs              => dlyce_dqs,
      dlyinc_dqs             => dlyinc_dqs,
      dlyrst_gate            => dlyrst_gate,
      dlyce_gate             => dlyce_gate,
      dlyinc_gate            => dlyinc_gate,
      en_dqs                 => en_dqs,
      rd_data_sel            => rd_data_sel
--      dbg_idel_up_all        => dbg_idel_up_all,
--      dbg_idel_down_all      => dbg_idel_down_all,
--      dbg_idel_up_dq         => dbg_idel_up_dq,
--      dbg_idel_down_dq       => dbg_idel_down_dq,
--      dbg_idel_up_dqs        => dbg_idel_up_dqs,
--      dbg_idel_down_dqs      => dbg_idel_down_dqs,
--      dbg_idel_up_gate       => dbg_idel_up_gate,
--      dbg_idel_down_gate     => dbg_idel_down_gate,
--      dbg_sel_idel_dq        => dbg_sel_idel_dq,
--      dbg_sel_all_idel_dq    => dbg_sel_all_idel_dq,
--      dbg_sel_idel_dqs       => dbg_sel_idel_dqs,
--      dbg_sel_all_idel_dqs   => dbg_sel_all_idel_dqs,
--      dbg_sel_idel_gate      => dbg_sel_idel_gate,
--      dbg_sel_all_idel_gate  => dbg_sel_all_idel_gate,
--      dbg_calib_done         => dbg_calib_done,
--      dbg_calib_err          => dbg_calib_err,
--      dbg_calib_dq_tap_cnt   => dbg_calib_dq_tap_cnt,
--      dbg_calib_dqs_tap_cnt  => dbg_calib_dqs_tap_cnt,
--      dbg_calib_gate_tap_cnt => dbg_calib_gate_tap_cnt,
--      dbg_calib_rd_data_sel  => dbg_calib_rd_data_sel,
--      dbg_calib_rden_dly     => dbg_calib_rden_dly,
--      dbg_calib_gate_dly     => dbg_calib_gate_dly
      );
  
  --***************************************************************************
  -- Memory clock generation
  --***************************************************************************
  
  gen_ck: for ck_i in 0 to CLK_WIDTH-1 generate    
    u_oddr_ck_i : ODDR
      generic map (
        SRTYPE       => "SYNC",
        DDR_CLK_EDGE => "OPPOSITE_EDGE"
        )
      port map (
        Q            => ddr_ck_q(ck_i),
        C            => clk0,
        CE           => '1',
        D1           => '0',
        D2           => '1',
        R            => '0',
        S            => '0'
        );
    -- Can insert ODELAY here if required    
    u_obuf_ck_i : OBUFDS
      port map (
        I   => ddr_ck_q(ck_i),
        O   => ddr_ck(ck_i),
        OB  => ddr_ck_n(ck_i)
      );
  end generate;
  
  --***************************************************************************
  -- DQS instances
  --***************************************************************************
  
  gen_dqs: for dqs_i in 0 to DQS_WIDTH-1 generate    
    u_iob_dqs : phy_dqs_iob
      generic map (
        HIGH_PERFORMANCE_MODE => HIGH_PERFORMANCE_MODE,
        IODELAY_GRP           => IODELAY_GRP,
        DDR_TYPE    => DDR_TYPE
        )
      port map (
        clk0        => clk0,
        clkdiv0     => clkdiv0,
        rst0        => rst0,
        dlyinc_dqs  => dlyinc_dqs(dqs_i),
        dlyce_dqs   => dlyce_dqs(dqs_i),
        dlyrst_dqs  => dlyrst_dqs,
        dlyinc_gate => dlyinc_gate(dqs_i),
        dlyce_gate  => dlyce_gate(dqs_i),
        dlyrst_gate => dlyrst_gate(dqs_i),
        dqs_oe_n    => dqs_oe_n,
        dqs_rst_n   => dqs_rst_n,
        en_dqs      => en_dqs(dqs_i),
        ddr_dqs     => ddr_dqs(dqs_i),
        ddr_dqs_n   => ddr_dqs_n(dqs_i),
        dq_ce       => dq_ce(dqs_i),
        delayed_dqs => delayed_dqs(dqs_i)
        );
  end generate;
  
  --***************************************************************************
  -- DM instances
  --***************************************************************************
  
  gen_dm: for dm_i in 0 to DM_WIDTH-1 generate    
    u_iob_dm : phy_dm_iob
      port map (
        clk90           => clk90,
        dm_ce           => dm_ce,
        mask_data_rise  => mask_data_rise(dm_i/DM_TO_BYTE_RATIO),
        mask_data_fall  => mask_data_fall(dm_i/DM_TO_BYTE_RATIO),
        ddr_dm          => ddr_dm(dm_i)
      );
  end generate;
  
  --***************************************************************************
  -- DQ IOB instances
  --***************************************************************************
  
  gen_dq: for dq_i in 0 to DQ_WIDTH-1 generate    
    u_iob_dq : phy_dq_iob
      generic map (
          HIGH_PERFORMANCE_MODE => HIGH_PERFORMANCE_MODE,
          IODELAY_GRP           => IODELAY_GRP,
          FPGA_SPEED_GRADE      => FPGA_SPEED_GRADE
        )
      port map (
        clk0          => clk0,
        clk90         => clk90,
        clkdiv0       => clkdiv0,
        rst90         => rst90,
        dlyinc        => dlyinc_dq(dq_i),
        dlyce         => dlyce_dq(dq_i),
        dlyrst        => dlyrst_dq,
        dq_oe_n       => dq_oe_n,
        dqs           => delayed_dqs(dq_i/DQ_PER_DQS),
        ce            => dq_ce(dq_i/DQ_PER_DQS),
        rd_data_sel   => rd_data_sel(dq_i/DQ_PER_DQS),
        wr_data_rise  => wr_data_rise(dq_i),
        wr_data_fall  => wr_data_fall(dq_i),
        rd_data_rise  => i_rd_data_rise(dq_i),
        rd_data_fall  => i_rd_data_fall(dq_i),
        ddr_dq        => ddr_dq(dq_i)
      );
  end generate;
    
end architecture syn;


