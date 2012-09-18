library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mem_if_top is
  generic (
    BANK_WIDTH             :       integer := 2;
    CKE_WIDTH              :       integer := 1;
    CLK_WIDTH              :       integer := 1;
    COL_WIDTH              :       integer := 10;
    CS_BITS                :       integer := 0;
    CS_NUM                 :       integer := 1;
    CS_WIDTH               :       integer := 1;
    DM_WIDTH               :       integer := 8;
    DQ_WIDTH               :       integer := 64;
    DQ_BITS                :       integer := 6;
    DQ_PER_DQS             :       integer := 8;
    DQS_BITS               :       integer := 3;
    DQS_WIDTH              :       integer := 8;
    ODT_WIDTH              :       integer := 1;
    ROW_WIDTH              :       integer := 14;
    ADDITIVE_LAT           :       integer := 4;
    BURST_LEN              :       integer := 8;
    BURST_TYPE             :       integer := 0;
    CAS_LAT                :       integer := 5;
    ECC_ENABLE             :       integer := 0;
    APPDATA_WIDTH          :       integer := 128;
    EN_WIDTH               :       integer := 16;      
    MULTI_BANK_EN          :       integer := 0;
    TWO_T_TIME_EN          :       integer := 1;
    ODT_TYPE               :       integer := 2;
    DDR_TYPE               :       integer := 3;
    REDUCE_DRV             :       integer := 0;
    REG_ENABLE             :       integer := 1;
    READ_DATA_PIPELINE     :       integer := 0;          
    TREFI_NS               :       integer := 7800;
    TRAS                   :       integer := 40000;
    TRCD                   :       integer := 15000;
    TRFC                   :       integer := 105000;
    TRP                    :       integer := 15000;
    TRTP                   :       integer := 7500;
    TWR                    :       integer := 15000;
    TWTR                   :       integer := 10000;
    CLK_PERIOD             :       integer := 3745;
    MIB_CLK_RATIO          :       integer := 2;
    SIM_ONLY               :       integer := 0;
    DEBUG_EN               :       integer := 0;
    C_MEM_BASEADDR 	   : std_logic_vector  := x"FFFFFFFF";
    C_MEM_HIGHADDR 	   : std_logic_vector  := x"00000000";
    HIGH_PERFORMANCE_MODE  : boolean 	  := TRUE;
    IODELAY_GRP            :       string  := "IODELAY_MIG";
    FPGA_SPEED_GRADE       : integer := 2
    );
  port (
    clk0                   : in    std_logic;
    clk90                  : in    std_logic;
    clkdiv0                : in    std_logic;
    rst0                   : in    std_logic;
    rst90                  : in    std_logic;
    rst270                 : in    std_logic;
    rstdiv0                : in    std_logic;

    mi_mcaddressvalid      : in    std_logic;
    mi_mcaddress	   : in    std_logic_vector(35 downto 0);
    mi_mcbankconflict      : in    std_logic;
    mi_mcrowconflict       : in    std_logic;
    mi_mcbyteenable	   : in    std_logic_vector(EN_WIDTH-1 downto 0);
    mi_mcwritedata	   : in    std_logic_vector(APPDATA_WIDTH-1 downto 0);
    mi_mcreadnotwrite      : in    std_logic;
    mi_mcwritedatavalid    : in    std_logic;

    mc_mireaddata	   : out   std_logic_vector(APPDATA_WIDTH-1 downto 0);
    mc_mireaddataerr	   : out   std_logic;
    mc_mireaddatavalid	   : out   std_logic;
    mc_miaddrreadytoaccept : out   std_logic;

--    app_af_cmd             : in    std_logic_vector(2 downto 0);
--    app_af_addr            : in    std_logic_vector(30 downto 0);
--    app_af_wren            : in    std_logic;
--    app_wdf_wren           : in    std_logic;
--    app_wdf_data           : in    std_logic_vector(APPDATA_WIDTH-1 downto 0);
--    app_wdf_mask_data      : in    std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
--    rd_ecc_error           : out   std_logic_vector(1 downto 0);
--    app_af_afull           : out   std_logic;
--    app_wdf_afull          : out   std_logic;
--    rd_data_valid          : out   std_logic;
--    rd_data_fifo_out       : out   std_logic_vector(APPDATA_WIDTH-1 downto 0);

    phy_init_done          : out   std_logic;
    ddr_reset_n 	   : out   std_logic;
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
    dbg_idel_up_all        : in    std_logic := '0'; 
    dbg_idel_down_all      : in    std_logic := '0';
    dbg_idel_up_dq         : in    std_logic := '0';
    dbg_idel_down_dq       : in    std_logic := '0';
    dbg_idel_up_dqs        : in    std_logic := '0';
    dbg_idel_down_dqs      : in    std_logic := '0';
    dbg_idel_up_gate       : in    std_logic := '0';
    dbg_idel_down_gate     : in    std_logic := '0';
    dbg_sel_idel_dq        : in    std_logic_vector(DQ_BITS-1 downto 0) := (others=>'0');
    dbg_sel_all_idel_dq    : in    std_logic := '0';
    dbg_sel_idel_dqs       : in    std_logic_vector(DQS_BITS downto 0) := (others=>'0');
    dbg_sel_all_idel_dqs   : in    std_logic := '0';
    dbg_sel_idel_gate      : in    std_logic_vector(DQS_BITS downto 0) := (others=>'0');
    dbg_sel_all_idel_gate  : in    std_logic := '0';
    dbg_calib_done         : out   std_logic_vector(3 downto 0);
    dbg_calib_err          : out   std_logic_vector(3 downto 0);
    dbg_calib_dq_tap_cnt   : out   std_logic_vector((6*DQ_WIDTH)-1 downto 0);
    dbg_calib_dqs_tap_cnt  : out   std_logic_vector((6*DQS_WIDTH)-1 downto 0);
    dbg_calib_gate_tap_cnt : out   std_logic_vector((6*DQS_WIDTH)-1 downto 0);
    dbg_calib_rd_data_sel  : out   std_logic_vector(DQS_WIDTH-1 downto 0);
    dbg_calib_rden_dly     : out   std_logic_vector((5*DQS_WIDTH)-1 downto 0);
    dbg_calib_gate_dly     : out   std_logic_vector((5*DQS_WIDTH)-1 downto 0)
    );
end entity mem_if_top;

architecture syn of mem_if_top is

  component phy_top
    generic (
      BANK_WIDTH    : integer;
      CLK_WIDTH     : integer;
      CKE_WIDTH     : integer;
      COL_WIDTH     : integer;
      CS_NUM        : integer;
      CS_WIDTH      : integer;
      DM_WIDTH      : integer;
      DQ_WIDTH      : integer;
      DQ_BITS       : integer;
      DQ_PER_DQS    : integer;
      DQS_WIDTH     : integer;
      DQS_BITS      : integer;
      ODT_WIDTH     : integer;
      ROW_WIDTH     : integer;
      ADDITIVE_LAT  : integer;
      TWO_T_TIME_EN : integer;
      BURST_LEN     : integer;
      BURST_TYPE    : integer;
      CAS_LAT       : integer;
      ECC_ENABLE    : integer;
      ODT_TYPE      : integer;
      DDR_TYPE      : integer;
      REDUCE_DRV    : integer;
      REG_ENABLE    : integer;
      CLK_PERIOD    : integer;
      SIM_ONLY      : integer;
      DEBUG_EN      : integer;
      HIGH_PERFORMANCE_MODE : boolean;
      IODELAY_GRP           : string;
      FPGA_SPEED_GRADE      : integer);
    port (
      clk0                   : in    std_logic;
      clk90                  : in    std_logic;
      clkdiv0                : in    std_logic;
      rst0                   : in    std_logic;
      rst90                  : in    std_logic;
--      rst270                 : in    std_logic;
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
--      rmw_data_out           : in    std_logic_vector((2*DQ_WIDTH)-1 downto 0); -- from usr_top, not used in this ddr3 phy
--      ctrl_rmw_data_sel      : in    std_logic;                                 -- from ctrl, not used in this ddr3 phy

      wdf_rden               : out   std_logic;
      phy_init_done          : out   std_logic;
      phy_calib_rden         : out   std_logic_vector(DQS_WIDTH-1 downto 0);
      phy_calib_rden_sel     : out   std_logic_vector(DQS_WIDTH-1 downto 0);
      rd_data_rise           : out   std_logic_vector(DQ_WIDTH-1 downto 0);
      rd_data_fall           : out   std_logic_vector(DQ_WIDTH-1 downto 0);
      ddr_reset_n 	     : out   std_logic;
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
  end component;

  component usr_top
    generic (
      BANK_WIDTH    : integer;
      CS_BITS       : integer;
      COL_WIDTH     : integer;
      DQ_WIDTH      : integer;
      DQ_PER_DQS    : integer;
      ECC_ENABLE    : integer;
      APPDATA_WIDTH : integer;
      DQS_WIDTH     : integer;
      ROW_WIDTH     : integer;
      READ_DATA_PIPELINE  : integer;
      EN_WIDTH            : integer;
      SIM_ONLY            : integer
      
      );
    port (
      clk0               : in  std_logic;
      clk90              : in  std_logic;
      rst0               : in  std_logic;
      rst90              : in  std_logic;
--      rst270             : in  std_logic;
      rd_data_in_rise    : in  std_logic_vector(DQ_WIDTH-1 downto 0);
      rd_data_in_fall    : in  std_logic_vector(DQ_WIDTH-1 downto 0);
      phy_calib_rden     : in  std_logic_vector(DQS_WIDTH-1 downto 0);
      phy_calib_rden_sel : in  std_logic_vector(DQS_WIDTH-1 downto 0);

      ctrl_rmw_data_sel  : in  std_logic;
      ctrl_rmw_disable   : in  std_logic;
      rmw_flag_r         : in  std_logic;
      rmw_state_flag     : in  std_logic;
      rmw_state2_flag    : in  std_logic;
      rd_mod_wr          : in  std_logic;
      rmw_wr_flag        : in  std_logic;
      rmw_wr_data_rdy    : out  std_logic;
      rmw_data_out       : out  std_logic_vector((2*DQ_WIDTH)-1 downto 0);

      rd_ecc_error       : out std_logic_vector(1 downto 0);
      rd_data_valid      : out std_logic;
      rd_data_fifo_out   : out std_logic_vector(APPDATA_WIDTH-1 downto 0);
      app_wdf_wren       : in  std_logic;
      app_wdf_data       : in  std_logic_vector(APPDATA_WIDTH-1 downto 0);
      app_wdf_mask_data  : in  std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
      wdf_rden           : in  std_logic;
      wdf_data           : out std_logic_vector((2*DQ_WIDTH)-1 downto 0);
      wdf_mask_data      : out std_logic_vector(((2*DQ_WIDTH)/8)-1 downto 0));


--      app_af_cmd         : in  std_logic_vector(2 downto 0);
--      app_af_addr        : in  std_logic_vector(30 downto 0);
--      app_af_wren        : in  std_logic;
--      ctrl_af_rden       : in  std_logic;
--      af_cmd             : out std_logic_vector(2 downto 0);
--      af_addr            : out std_logic_vector(30 downto 0);
--      af_empty           : out std_logic;
--      app_af_afull       : out std_logic;
--      app_wdf_afull      : out std_logic;
  end component;

  component u_ctrl
    generic (
      BANK_WIDTH    : integer;
      COL_WIDTH     : integer;
      CS_BITS       : integer;
      CS_NUM        : integer;
      DQS_BITS      : integer;
      DQ_WIDTH      : integer;
      ROW_WIDTH     : integer;
      ADDITIVE_LAT  : integer;
      BURST_LEN     : integer;
      CAS_LAT       : integer;
      ECC_ENABLE    : integer;
      SIM_ONLY      : integer;
      MIB_CLK_RATIO : integer;
--      REG_ENABLE    : integer;
      TREFI_NS      : integer;
      TRAS          : integer;
      TRCD          : integer;
      TRFC          : integer;
      TRP           : integer;
      TRTP          : integer;
      TWR           : integer;
      TWTR          : integer;
      CLK_PERIOD    : integer);
--      MULTI_BANK_EN : integer;
--      TWO_T_TIME_EN : integer;
--      DDR_TYPE      : integer);
    port (
      clk           : in  std_logic;
      clk90         : in  std_logic;
      rst           : in  std_logic;
      rst270        : in  std_logic;
      phy_init_done : in  std_logic;

      mi_mcwritedatavalid : in  std_logic;
      mi_mc_add_val : in  std_logic;
      mi_mc_add: in  std_logic_vector(35 downto 0);
      mi_mc_bank_conf : in  std_logic;
      mi_mc_row_conf : in  std_logic;
      mi_mc_rd : in  std_logic;
      rmw_flag : in  std_logic;
      rmw_wr_data_rdy : in  std_logic;
      wdf_rden : in  std_logic;
      rmw_wr_flag : out std_logic;
      rd_mod_wr : out std_logic;
      rmw_state_flag : out std_logic;
      rmw_state2_flag : out std_logic;
      mc_mi_addr_rdy_accpt : out std_logic;
--      af_cmd        : in  std_logic_vector(2 downto 0);
--      af_addr       : in  std_logic_vector(30 downto 0);
--      af_empty      : in  std_logic;
      ctrl_ref_flag : out std_logic;
--      ctrl_af_rden  : out std_logic;
      ctrl_wren     : out std_logic;
      ctrl_rden     : out std_logic;
      ctrl_rmw_data_sel    : out std_logic;
      ctrl_rmw_done        : out std_logic;
      ctrl_rmw_disable     : out std_logic;
      ctrl_addr     : out std_logic_vector(ROW_WIDTH-1 downto 0);
      ctrl_ba       : out std_logic_vector(BANK_WIDTH-1 downto 0);
      ctrl_ras_n    : out std_logic;
      ctrl_cas_n    : out std_logic;
      ctrl_we_n     : out std_logic;
      ctrl_cs_n     : out std_logic_vector(CS_NUM-1 downto 0));
  end component;
  
--  signal af_addr            : std_logic_vector(30 downto 0);
--  signal af_cmd             : std_logic_vector(2 downto 0);
--  signal af_empty           : std_logic;
  signal ctrl_addr          : std_logic_vector(ROW_WIDTH-1 downto 0);
  signal ctrl_af_rden       : std_logic;
  signal ctrl_ba            : std_logic_vector(BANK_WIDTH-1 downto 0);
  signal ctrl_cas_n         : std_logic;
  signal ctrl_cs_n          : std_logic_vector(CS_NUM-1 downto 0);
  signal ctrl_ras_n         : std_logic;
  signal ctrl_rden          : std_logic;
  signal ctrl_ref_flag      : std_logic;
  signal ctrl_we_n          : std_logic;
  signal ctrl_wren          : std_logic;
  signal phy_calib_rden     : std_logic_vector(DQS_WIDTH-1 downto 0);
  signal phy_calib_rden_sel : std_logic_vector(DQS_WIDTH-1 downto 0);
  signal rd_data_fall       : std_logic_vector(DQ_WIDTH-1 downto 0);
  signal rd_data_rise       : std_logic_vector(DQ_WIDTH-1 downto 0);
  signal wdf_data           : std_logic_vector((2*DQ_WIDTH)-1 downto 0);
  signal wdf_mask_data      : std_logic_vector(((2*DQ_WIDTH)/8)-1 downto 0);
  signal wdf_mask_data_inv  : std_logic_vector(((2*DQ_WIDTH)/8)-1 downto 0);
  signal wdf_rden           : std_logic;

  signal rmw_data_out       : std_logic_vector((2*DQ_WIDTH)-1 downto 0); -- from usr_top, not used in this ddr3 phy
  signal rmw_data_sel       : std_logic;                                 -- from ctrl, not used in this ddr3 phy

  signal i_phy_init_done   : std_logic;
  
  signal rmw_flag_w  : std_logic;
  signal rmw_flag_r  : std_logic;
  signal wr_dataval_r  : std_logic;
  signal wr_dataval_r1  : std_logic;
  signal ctrl_rmw_done_r  : std_logic;
  signal rmw_flag_reg  : std_logic;
  signal rmw_flag  : std_logic;
  signal rd_mod_wr  : std_logic;
  signal rmw_wr_flag  : std_logic;
  signal rmw_state_flag  : std_logic;
  signal rmw_state2_flag  : std_logic;
  signal rmw_data_rdy : std_logic;
  signal ctrl_rmw_done : std_logic; -- only used for ECC, not supported
  signal ctrl_rmw_disable : std_logic;
  
  signal mi_mc_add_val : std_logic;
  
begin
  
  --***************************************************************************
    
-- for phy_top, the mask high means data is blocked during write. the ppc mc interface means opposite, inverts at this level
wdf_mask_data_inv <= not wdf_mask_data;

u_phy_top : phy_top
    generic map (
      BANK_WIDTH     => BANK_WIDTH,
      CKE_WIDTH      => CKE_WIDTH,
      CLK_WIDTH      => CLK_WIDTH,
      COL_WIDTH      => COL_WIDTH,
      CS_NUM         => CS_NUM,
      CS_WIDTH       => CS_WIDTH,
      DM_WIDTH       => DM_WIDTH,
      DQ_WIDTH       => DQ_WIDTH,
      DQ_BITS        => DQ_BITS,
      DQ_PER_DQS     => DQ_PER_DQS,
      DQS_BITS       => DQS_BITS,
      DQS_WIDTH      => DQS_WIDTH,
      ODT_WIDTH      => ODT_WIDTH,
      ROW_WIDTH      => ROW_WIDTH,
      TWO_T_TIME_EN  => TWO_T_TIME_EN,
      ADDITIVE_LAT   => ADDITIVE_LAT,
      BURST_LEN      => BURST_LEN,
      BURST_TYPE     => BURST_TYPE,
      CAS_LAT        => CAS_LAT,
      ECC_ENABLE     => ECC_ENABLE,
      ODT_TYPE       => ODT_TYPE,
      DDR_TYPE       => DDR_TYPE,
      REDUCE_DRV     => REDUCE_DRV,
      REG_ENABLE     => REG_ENABLE,
      CLK_PERIOD     => CLK_PERIOD,
      SIM_ONLY       => SIM_ONLY,
      DEBUG_EN       => DEBUG_EN,
      HIGH_PERFORMANCE_MODE  => HIGH_PERFORMANCE_MODE,
      IODELAY_GRP            => IODELAY_GRP,
      FPGA_SPEED_GRADE       => FPGA_SPEED_GRADE
    )
    port map (
      clk0                   => clk0,
      clk90                  => clk90,
      clkdiv0                => clkdiv0,
      rst0                   => rst0,
      rst90                  => rst90,
--      rst270                 => rst270,
      rstdiv0                => rstdiv0,
      ctrl_wren              => ctrl_wren,
      ctrl_addr              => ctrl_addr,
      ctrl_ba                => ctrl_ba,
      ctrl_ras_n             => ctrl_ras_n,
      ctrl_cas_n             => ctrl_cas_n,
      ctrl_we_n              => ctrl_we_n,
      ctrl_cs_n              => ctrl_cs_n,
      ctrl_rden              => ctrl_rden,
      ctrl_ref_flag          => ctrl_ref_flag,
      wdf_data               => wdf_data,
      wdf_mask_data          => wdf_mask_data_inv,
--      rmw_data_out           => rmw_data_out, -- from usr_top, not used in this ddr3 phy
--      ctrl_rmw_data_sel      => rmw_data_sel, -- from ctrl, not used in this ddr3 phy
      wdf_rden               => wdf_rden,
      phy_init_done          => i_phy_init_done,
      phy_calib_rden         => phy_calib_rden,
      phy_calib_rden_sel     => phy_calib_rden_sel,
      rd_data_rise           => rd_data_rise,
      rd_data_fall           => rd_data_fall,
      ddr_reset_n 	     => ddr_reset_n,
      ddr_ck                 => ddr_ck,
      ddr_ck_n               => ddr_ck_n,
      ddr_addr               => ddr_addr,
      ddr_ba                 => ddr_ba,
      ddr_ras_n              => ddr_ras_n,
      ddr_cas_n              => ddr_cas_n,
      ddr_we_n               => ddr_we_n,
      ddr_cs_n               => ddr_cs_n,
      ddr_cke                => ddr_cke,
      ddr_odt                => ddr_odt,
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
   
 u_usr_top : usr_top
   generic map (
      BANK_WIDTH    => BANK_WIDTH,
      COL_WIDTH     => COL_WIDTH,
      CS_BITS       => CS_BITS,
      DQ_WIDTH      => DQ_WIDTH,
      DQ_PER_DQS    => DQ_PER_DQS,
      DQS_WIDTH     => DQS_WIDTH,
      ECC_ENABLE    => ECC_ENABLE,
      EN_WIDTH      => EN_WIDTH,
      APPDATA_WIDTH => APPDATA_WIDTH,
      READ_DATA_PIPELINE => READ_DATA_PIPELINE,
      SIM_ONLY      => SIM_ONLY,
      ROW_WIDTH     => ROW_WIDTH
    )
    port map (

      clk0                => clk0,
      clk90               => clk90,
      rst0                => rst0,
      rst90               => rst90,
--      rst270             => rst270,
      rd_data_in_rise     => rd_data_rise,
      rd_data_in_fall     => rd_data_fall,
      phy_calib_rden      => phy_calib_rden,
      phy_calib_rden_sel  => phy_calib_rden_sel,
  
      ctrl_rmw_data_sel   => rmw_data_sel,
      ctrl_rmw_disable    => ctrl_rmw_disable,
      rmw_flag_r          => rmw_flag,
      rmw_state_flag      => rmw_state_flag,
      rmw_state2_flag     => rmw_state2_flag,
      rd_mod_wr           => rd_mod_wr,
      rmw_wr_flag         => rmw_wr_flag,  
      rmw_wr_data_rdy     => rmw_data_rdy,
      rmw_data_out        => rmw_data_out,
 
--      rd_ecc_error        => rd_ecc_error,
      rd_data_valid       => mc_mireaddatavalid,
      rd_data_fifo_out    => mc_mireaddata,
      app_wdf_wren        => mi_mcwritedatavalid,
      app_wdf_data        => mi_mcwritedata,
      app_wdf_mask_data   => mi_mcbyteenable,

      wdf_rden            => wdf_rden,
      wdf_data            => wdf_data,
      wdf_mask_data       => wdf_mask_data
      );
  
rmw_flag_w <= '0'; -- no ECC support 

-- mi_mc_add_val <= '1' when mi_mcaddressvalid = '1' and (mi_mcaddress(31 downto 0) >= C_MEM_BASEADDR) and (mi_mcaddress(31 downto 0) <= C_MEM_HIGHADDR) else '0';
mi_mc_add_val <= '1' when mi_mcaddressvalid = '1' else '0';


-- ***************************************************************************
-- mc_mireaddataerr signal only valid when ECC_ENABLE is set to '1'  
-- rd_ecc_err[0] asserted when 2 bit error detected.
-- rd_ecc_err[1] asserted when single bit error detected and corrected 
mc_mireaddataerr <= '0'; -- no ECC support

u_u_ctrl : u_ctrl
    generic map (
      BANK_WIDTH     => BANK_WIDTH,
      COL_WIDTH      => COL_WIDTH,
      CS_BITS        => CS_BITS,
      CS_NUM         => CS_NUM,
      ROW_WIDTH      => ROW_WIDTH,
      ADDITIVE_LAT   => ADDITIVE_LAT,
      BURST_LEN      => BURST_LEN,
      CAS_LAT        => CAS_LAT,
      ECC_ENABLE     => ECC_ENABLE,
      SIM_ONLY     => SIM_ONLY,
      DQS_BITS       => DQS_BITS,     
      DQ_WIDTH       =>	DQ_WIDTH,     
--      REG_ENABLE     => REG_ENABLE,
--      MULTI_BANK_EN  => MULTI_BANK_EN,
--      TWO_T_TIME_EN  => TWO_T_TIME_EN,
      TREFI_NS       => TREFI_NS,
      TRAS           => TRAS,
      TRCD           => TRCD,
      TRFC           => TRFC,
      TRP            => TRP,
      TRTP           => TRTP,
      TWR            => TWR,
      TWTR           => TWTR,
      CLK_PERIOD     => CLK_PERIOD,
--      DDR_TYPE       => DDR_TYPE

      MIB_CLK_RATIO  =>	MIB_CLK_RATIO

      )
    port map (
      clk            		=> clk0,
      clk90  => clk90,
      rst            		=> rst0,
      rst270 => rst270,
--      af_cmd         		=> af_cmd,
--      af_addr        		=> af_addr,
--      af_empty       		=> af_empty,

      mi_mcwritedatavalid 	=> mi_mcwritedatavalid,
      mi_mc_add_val 		=> mi_mc_add_val,
      mi_mc_add			=> mi_mcaddress,
      mi_mc_bank_conf 		=> mi_mcbankconflict,
      mi_mc_row_conf 		=> mi_mcrowconflict,
      mc_mi_addr_rdy_accpt 	=> mc_miaddrreadytoaccept,
      mi_mc_rd 			=> mi_mcreadnotwrite,
      rmw_flag 			=> rmw_flag_w,
      rmw_wr_data_rdy 		=> rmw_data_rdy,
      wdf_rden 			=> wdf_rden,
      rmw_wr_flag 		=> rmw_wr_flag,
      rd_mod_wr 		=> rd_mod_wr,
      rmw_state_flag 		=> rmw_state_flag,
      rmw_state2_flag 		=> rmw_state2_flag,

      phy_init_done  		=> i_phy_init_done,
      ctrl_ref_flag  		=> ctrl_ref_flag,
--      ctrl_af_rden   		=> ctrl_af_rden,
      ctrl_wren      		=> ctrl_wren,
      ctrl_rden      		=> ctrl_rden,
      ctrl_rmw_data_sel    	=> rmw_data_sel,
      ctrl_rmw_done        	=> ctrl_rmw_done,
      ctrl_rmw_disable     	=> ctrl_rmw_disable,
      ctrl_addr      		=> ctrl_addr,
      ctrl_ba        		=> ctrl_ba,
      ctrl_ras_n     		=> ctrl_ras_n,
      ctrl_cas_n     		=> ctrl_cas_n,
      ctrl_we_n      		=> ctrl_we_n,
      ctrl_cs_n      		=> ctrl_cs_n

    );

  phy_init_done <= i_phy_init_done;
  
end architecture syn;


