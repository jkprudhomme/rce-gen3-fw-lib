library ieee;
use ieee.std_logic_1164.all;
  
entity ddr3_top is
  generic (
    BANK_WIDTH    : integer := 2;       -- # of memory bank addr bits
    CKE_WIDTH     : integer := 1;       -- # of memory clock enable outputs
    CLK_WIDTH     : integer := 1;       -- # of clock outputs
    COL_WIDTH     : integer := 10;      -- # of memory column bits
    CS_NUM        : integer := 1;       -- # of separate memory chip selects
    CS_BITS       : integer := 0;       -- set to log2(CS_NUM) (rounded up)
    CS_WIDTH      : integer := 1;       -- # of total memory chip selects
    DM_WIDTH      : integer := 8;       -- # of data mask bits
    DQ_WIDTH      : integer := 64;      -- # of data width
    DQ_BITS       : integer := 6;       -- set to log2(DQS_WIDTH*DQ_PER_DQS)
    DQ_PER_DQS    : integer := 8;       -- # of DQ data bits per strobe
    DQS_WIDTH     : integer := 8;       -- # of DQS strobes
    DQS_BITS      : integer := 3;       -- set to log2(DQS_WIDTH)
    ODT_TYPE      : integer := 2;       -- ODT (=0(none),=1(75),=2(150),=3(50))
    ODT_WIDTH     : integer := 1;       -- # of memory on-die term enables
    ROW_WIDTH     : integer := 14;      -- # of memory row & # of addr bits
    APPDATA_WIDTH : integer := 128;     -- # of read/write data bus bits
    EN_WIDTH      : integer := 16;      -- # of MC Byte enable bits
    ADDITIVE_LAT  : integer := 4;       -- additive write latency
    BURST_LEN     : integer := 8;       -- burst length (in double words)
    BURST_TYPE    : integer := 0;       -- burst type (=0 seq; =1 interlved)
    CAS_LAT       : integer := 5;       -- CAS latency
    ECC_ENABLE    : integer := 0;       -- enable ECC (=1 enable), not supported
    MULTI_BANK_EN : integer := 0;       -- enable bank management
    TWO_T_TIME_EN : integer := 0;       -- 2t timing for unbuffered dimms 
    REDUCE_DRV    : integer := 0;       -- reduced strength mem I/O (=1 yes)
    REG_ENABLE    : integer := 1;       -- registered addr/ctrl (=1 yes)
    READ_DATA_PIPELINE 	: integer         := 0;       -- Additional pipeline stage in read data path   
    TREFI_NS      : integer := 7800;    -- auto refresh interval (uS)
    TRAS          : integer := 40000;   -- active->precharge delay
    TRCD          : integer := 15000;   -- active->read/write delay
    TRFC          : integer := 105000;  -- ref->ref, ref->active delay
    TRP           : integer := 15000;   -- precharge->command delay
    TRTP          : integer := 7500;    -- read->precharge delay
    TWR           : integer := 15000;   -- used to determine wr->prech
    TWTR          : integer := 10000;   -- write->read delay
    CLK_PERIOD    : integer := 3745;    -- Core/Mem clk period (in ps)
    MIB_CLK_RATIO : integer := 0;
    SIM_ONLY      : integer := 0;       -- = 1 to skip power up delay
    C_MEM_BASEADDR 	: std_logic_vector  := x"FFFFFFFF";
    C_MEM_HIGHADDR 	: std_logic_vector  := x"00000000";
    DEBUG_EN      : integer := 0;       -- Enable debug signals/controls
    HIGH_PERFORMANCE_MODE : boolean 	  := TRUE;
    IODELAY_GRP            :       string  := "IODELAY_MIG";
    FPGA_SPEED_GRADE       :       integer := 2
    );
  port (
    mc_mibclk              : in    std_logic;
    mi_mcclk90             : in    std_logic;
    mi_mcreset             : in    std_logic;
    mi_mcclk_200            : in    std_logic;
    mi_mcclkdiv2           : in    std_logic;
 
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

--    clk0                   : in    std_logic;
--    clk90                  : in    std_logic;
--    clkdiv0                : in    std_logic;
--    rst0                   : in    std_logic;
--    rst90                  : in    std_logic;
--    rstdiv0                : in    std_logic;

--    app_af_cmd             : in    std_logic_vector(2 downto 0);
--    app_af_addr            : in    std_logic_vector(30 downto 0);
--    app_af_wren            : in    std_logic;
--    app_wdf_wren           : in    std_logic;
--    app_wdf_data           : in    std_logic_vector(APPDATA_WIDTH-1 downto 0);
--    app_wdf_mask_data      : in    std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
--    app_af_afull           : out   std_logic;
--    app_wdf_afull          : out   std_logic;
--    rd_data_valid          : out   std_logic;
--    rd_data_fifo_out       : out   std_logic_vector(APPDATA_WIDTH-1 downto 0);
--    rd_ecc_error           : out   std_logic_vector(1 downto 0);
    idelay_ctrl_rdy_i	   : in  std_logic; -- not used
    idelay_ctrl_rdy        : out   std_logic;
    
    dcm_lock        	   : in  std_logic;

    phy_init_done          : out   std_logic;
    ddr3_ck                : out   std_logic_vector(CLK_WIDTH-1 downto 0);
    ddr3_ck_n              : out   std_logic_vector(CLK_WIDTH-1 downto 0);
    ddr3_a                 : out   std_logic_vector(ROW_WIDTH-1 downto 0);
    ddr3_ba                : out   std_logic_vector(BANK_WIDTH-1 downto 0);
    ddr3_ras_n             : out   std_logic;
    ddr3_cas_n             : out   std_logic;
    ddr3_we_n              : out   std_logic;
    ddr3_cs_n              : out   std_logic_vector(CS_WIDTH-1 downto 0);
    ddr3_cke               : out   std_logic_vector(CKE_WIDTH-1 downto 0);
    ddr3_odt               : out   std_logic_vector(ODT_WIDTH-1 downto 0);
    ddr3_dm                : out   std_logic_vector(DM_WIDTH-1 downto 0);
    ddr3_dqs               : inout std_logic_vector(DQS_WIDTH-1 downto 0);
    ddr3_dqs_n             : inout std_logic_vector(DQS_WIDTH-1 downto 0);
    ddr3_dq                : inout std_logic_vector(DQ_WIDTH-1 downto 0);
    ddr3_reset_n	   : out std_logic

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
end entity ddr3_top;

architecture syn of ddr3_top is

component clk_reset
  port (
    clk0_in         : in  std_logic;
    clk90_in	    : in  std_logic;
    clk200_in       : in  std_logic;
    clkdiv0_in      : in  std_logic;
    sys_rst_n       : in  std_logic;
    idelay_ctrl_rdy : in  std_logic;
    dcm_lock        : in  std_logic;
    clk0            : out std_logic;
    clk90           : out std_logic;
    clk200          : out std_logic;
    clkdiv0         : out std_logic;
    rst0            : out std_logic;
    rst90           : out std_logic;
    rst270          : out std_logic;
    rst200          : out std_logic;
    rstdiv0         : out std_logic
    );
  end component;

component idelay_ctrl
  generic (
    IODELAY_GRP    : string  := "IODELAY_MIG"
    );
  port (
    clk200           : in std_logic;
    rst200           : in std_logic;
    idelay_ctrl_rdy  : out std_logic
  );
end component;

  component mem_if_top
    generic (
      BANK_WIDTH    : integer;
      CKE_WIDTH     : integer;
      CLK_WIDTH     : integer;
      COL_WIDTH     : integer;
      CS_BITS       : integer;
      CS_NUM        : integer;
      CS_WIDTH      : integer;
      DM_WIDTH      : integer;
      DQ_WIDTH      : integer;
      DQ_BITS       : integer;
      DQ_PER_DQS    : integer;
      DQS_BITS      : integer;
      DQS_WIDTH     : integer;
      ODT_WIDTH     : integer;
      ROW_WIDTH     : integer;
      APPDATA_WIDTH : integer;
      EN_WIDTH      : integer;
      ADDITIVE_LAT  : integer;
      BURST_LEN     : integer;
      BURST_TYPE    : integer;
      CAS_LAT       : integer;
      ECC_ENABLE    : integer;
      MULTI_BANK_EN : integer;
      TWO_T_TIME_EN : integer;
      ODT_TYPE      : integer;
      DDR_TYPE      : integer;
      REDUCE_DRV    : integer;
      REG_ENABLE    : integer;
      READ_DATA_PIPELINE : integer;          
      TREFI_NS      : integer;
      TRAS          : integer;
      TRCD          : integer;
      TRFC          : integer;
      TRP           : integer;
      TRTP          : integer;
      TWR           : integer;
      TWTR          : integer;
      CLK_PERIOD    : integer;
      MIB_CLK_RATIO : integer;
      SIM_ONLY      : integer;
      DEBUG_EN      : integer;
      C_MEM_BASEADDR 	: std_logic_vector  := x"FFFFFFFF";
      C_MEM_HIGHADDR 	: std_logic_vector  := x"00000000";
      HIGH_PERFORMANCE_MODE : boolean 	  := TRUE;
      IODELAY_GRP            :       string  := "IODELAY_MIG";
      FPGA_SPEED_GRADE      : integer);
    port (
      clk0                   : in    std_logic;
      clk90                  : in    std_logic;
      clkdiv0                : in    std_logic;
      rst0                   : in    std_logic;
      rst90                  : in    std_logic;
      rst270                 : in    std_logic;
      rstdiv0                : in    std_logic;
 
      mi_mcaddressvalid      : in    std_logic;
      mi_mcaddress	     : in    std_logic_vector(35 downto 0);
      mi_mcbankconflict      : in    std_logic;
      mi_mcrowconflict       : in    std_logic;
      mi_mcbyteenable	     : in    std_logic_vector(EN_WIDTH-1 downto 0);
      mi_mcwritedata	     : in    std_logic_vector(APPDATA_WIDTH-1 downto 0);
      mi_mcreadnotwrite      : in    std_logic;
      mi_mcwritedatavalid    : in    std_logic;

      mc_mireaddata	     : out   std_logic_vector(APPDATA_WIDTH-1 downto 0);
      mc_mireaddataerr	     : out   std_logic;
      mc_mireaddatavalid     : out   std_logic;
      mc_miaddrreadytoaccept : out   std_logic;
--      app_af_cmd             : in    std_logic_vector(2 downto 0);
--      app_af_addr            : in    std_logic_vector(30 downto 0);
--      app_af_wren            : in    std_logic;
--      app_wdf_wren           : in    std_logic;
--      app_wdf_data           : in    std_logic_vector(APPDATA_WIDTH-1 downto 0);
--      app_wdf_mask_data      : in    std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
--      rd_ecc_error           : out   std_logic_vector(1 downto 0);
--      app_af_afull           : out   std_logic;
--      app_wdf_afull          : out   std_logic;
--      rd_data_valid          : out   std_logic;
--      rd_data_fifo_out       : out   std_logic_vector(APPDATA_WIDTH-1 downto 0);
      phy_init_done          : out   std_logic;

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
  
  signal clk0              : std_logic;
  signal clkdiv0           : std_logic;
  signal clk90             : std_logic;
  signal clk200            : std_logic;
--  signal idelay_ctrl_rdy   : std_logic;
  signal rst0              : std_logic;
  signal rst90             : std_logic;
  signal rst270             : std_logic;
  signal rst200            : std_logic;
  signal rstdiv0           : std_logic;
  
  signal i_idelay_ctrl_rdy : std_logic;
  
  signal sys_rst_n         : std_logic;
  
  signal ddr_reset_n       : std_logic;
  
--  signal mi_mcaddressvalid_r      	:  std_logic;
--  signal mi_mcaddress_r	     		:  std_logic_vector(35 downto 0);
--  signal mi_mcbankconflict_r      	:  std_logic;
--  signal mi_mcrowconflict_r       	:  std_logic;
--  signal mi_mcbyteenable_r	     	:  std_logic_vector(EN_WIDTH-1 downto 0);
--  signal mi_mcwritedata_r	    	:  std_logic_vector(APPDATA_WIDTH-1 downto 0);
--  signal mi_mcreadnotwrite_r      	:  std_logic;
--  signal mi_mcwritedatavalid_r    	:  std_logic;

--  signal mc_mireaddata_r	     	:  std_logic_vector(APPDATA_WIDTH-1 downto 0);
--  signal mc_mireaddataerr_r	     	:  std_logic;
--  signal mc_mireaddatavalid_r     	:  std_logic;
--  signal mc_miaddrreadytoaccept_r 	:  std_logic;

  
begin

  ddr3_reset_n <= ddr_reset_n;
  
  sys_rst_n <= not mi_mcreset;
  
  idelay_ctrl_rdy <= i_idelay_ctrl_rdy;

  u_idelay_ctrl : idelay_ctrl
    generic map (
                 IODELAY_GRP => IODELAY_GRP
                )
    port map (
      rst200          => rst200,
      clk200          => clk200,
      idelay_ctrl_rdy => i_idelay_ctrl_rdy
      );
  
  u_clk_reset : clk_reset
    port map (
      clk0_in         => mc_mibclk,
      clk90_in	      => mi_mcclk90,
      clk200_in       => mi_mcclk_200,
      clkdiv0_in      => mi_mcclkdiv2,
      sys_rst_n       => sys_rst_n,
      dcm_lock	      => dcm_lock,
      rst0            => rst0,
      rst90           => rst90,
      rst270          => rst270,
      rst200          => rst200,
      rstdiv0         => rstdiv0,
      clk0            => clk0,
      clk90           => clk90,
      clk200          => clk200,
      clkdiv0         => clkdiv0,
      idelay_ctrl_rdy => i_idelay_ctrl_rdy
      );
      
  
--  process (mc_mibclk, rst0)
--  begin
--    if (mi_mcreset = '1') then
--	  mi_mcaddressvalid_r      	<= '0';
--	  mi_mcaddress_r	     	<= (others => '0');
--	  mi_mcbankconflict_r      	<= '0';
--	  mi_mcrowconflict_r       	<= '0';
--	  mi_mcbyteenable_r	     	<= (others => '0');
--	  mi_mcwritedata_r	    	<= (others => '0');
--	  mi_mcreadnotwrite_r      	<= '0';
--	  mi_mcwritedatavalid_r    	<= '0';
--    elsif (rising_edge(mc_mibclk)) then
--	  mi_mcaddressvalid_r      	<= mi_mcaddressvalid; 
--	  mi_mcaddress_r	     	<= mi_mcaddress;	
--	  mi_mcbankconflict_r      	<= mi_mcbankconflict;  
--	  mi_mcrowconflict_r       	<= mi_mcrowconflict;   
--	  mi_mcbyteenable_r	     	<= mi_mcbyteenable;	
--	  mi_mcwritedata_r	    	<= mi_mcwritedata;	
--	  mi_mcreadnotwrite_r      	<= mi_mcreadnotwrite;  
--	  mi_mcwritedatavalid_r    	<= mi_mcwritedatavalid;
--    end if;
--  end process;
  
--  process (mc_mibclk, rst0)
--  begin
--    if (mi_mcreset = '1') then
--	  mc_mireaddata	     		<= (others => '0');
--	  mc_mireaddataerr	     	<= '0';
--	  mc_mireaddatavalid     	<= '0';
--	  mc_miaddrreadytoaccept 	<= '0';
--    elsif (rising_edge(mc_mibclk)) then
--	  mc_mireaddata	     		<= mc_mireaddata_r;	  
--	  mc_mireaddataerr	     	<= mc_mireaddataerr_r;	  
--	  mc_mireaddatavalid     	<= mc_mireaddatavalid_r;    
--	  mc_miaddrreadytoaccept 	<= mc_miaddrreadytoaccept_r;
--    end if;
--  end process;

  -- memory initialization/control logic
  u_mem_if_top : mem_if_top
    generic map (
      BANK_WIDTH     => BANK_WIDTH,
      CKE_WIDTH      => CKE_WIDTH,
      CLK_WIDTH      => CLK_WIDTH,
      COL_WIDTH      => COL_WIDTH,
      CS_BITS        => CS_BITS,
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
      APPDATA_WIDTH  => APPDATA_WIDTH,
      EN_WIDTH       => EN_WIDTH,
      ADDITIVE_LAT   => ADDITIVE_LAT,
      BURST_LEN      => BURST_LEN,
      BURST_TYPE     => BURST_TYPE,
      CAS_LAT        => CAS_LAT,
      ECC_ENABLE     => ECC_ENABLE,
      MULTI_BANK_EN  => MULTI_BANK_EN,
      TWO_T_TIME_EN  => TWO_T_TIME_EN,
      ODT_TYPE       => ODT_TYPE,
      DDR_TYPE       => 2,  -- 2 = DDR3
      REDUCE_DRV     => REDUCE_DRV,
      REG_ENABLE     => REG_ENABLE,
      READ_DATA_PIPELINE => READ_DATA_PIPELINE,
      TREFI_NS       => TREFI_NS,
      TRAS           => TRAS,
      TRCD           => TRCD,
      TRFC           => TRFC,
      TRP            => TRP,
      TRTP           => TRTP,
      TWR            => TWR,
      TWTR           => TWTR,
      CLK_PERIOD     => CLK_PERIOD,
      MIB_CLK_RATIO  => MIB_CLK_RATIO,
      SIM_ONLY       => SIM_ONLY,
      DEBUG_EN       => DEBUG_EN,
      C_MEM_BASEADDR  => C_MEM_BASEADDR, 
      C_MEM_HIGHADDR  => C_MEM_HIGHADDR, 
      HIGH_PERFORMANCE_MODE  => HIGH_PERFORMANCE_MODE,
      IODELAY_GRP            => IODELAY_GRP,
      FPGA_SPEED_GRADE       => FPGA_SPEED_GRADE
      )
    port map (
      clk0                    => mc_mibclk,
      clk90                   => mi_mcclk90,
      clkdiv0                 => mi_mcclkdiv2,
      rst0                    => rst0,
      rst90                   => rst90,
      rst270                  => rst270,
      rstdiv0                 => rstdiv0,

--      mi_mcaddressvalid       => mi_mcaddressvalid_r,
--      mi_mcaddress            => mi_mcaddress_r,
--      mi_mcbankconflict       => mi_mcbankconflict_r,
--      mi_mcrowconflict        => mi_mcrowconflict_r,
--      mi_mcbyteenable         => mi_mcbyteenable_r,
--      mi_mcwritedata          => mi_mcwritedata_r,
--      mi_mcreadnotwrite       => mi_mcreadnotwrite_r,
--      mi_mcwritedatavalid     => mi_mcwritedatavalid_r,

--      mc_mireaddata           => mc_mireaddata_r,
--      mc_mireaddataerr        => mc_mireaddataerr_r,
--      mc_mireaddatavalid      => mc_mireaddatavalid_r,
--      mc_miaddrreadytoaccept  => mc_miaddrreadytoaccept_r,

      mi_mcaddressvalid       => mi_mcaddressvalid,
      mi_mcaddress            => mi_mcaddress,
      mi_mcbankconflict       => mi_mcbankconflict,
      mi_mcrowconflict        => mi_mcrowconflict,
      mi_mcbyteenable         => mi_mcbyteenable,
      mi_mcwritedata          => mi_mcwritedata,
      mi_mcreadnotwrite       => mi_mcreadnotwrite,
      mi_mcwritedatavalid     => mi_mcwritedatavalid,

      mc_mireaddata           => mc_mireaddata,
      mc_mireaddataerr        => mc_mireaddataerr,
      mc_mireaddatavalid      => mc_mireaddatavalid,
      mc_miaddrreadytoaccept  => mc_miaddrreadytoaccept,

--      app_af_cmd              => app_af_cmd,
--      app_af_addr             => app_af_addr,
--      app_af_wren             => app_af_wren,
--      app_wdf_wren            => app_wdf_wren,
--      app_wdf_data            => app_wdf_data,
--      app_wdf_mask_data       => app_wdf_mask_data,
--      app_af_afull            => app_af_afull,
--      app_wdf_afull           => app_wdf_afull,
--      rd_data_valid           => rd_data_valid,
--      rd_data_fifo_out        => rd_data_fifo_out,
--      rd_ecc_error            => rd_ecc_error,

      phy_init_done           => phy_init_done,
      ddr_reset_n             => ddr_reset_n,
      ddr_ck                  => ddr3_ck,
      ddr_ck_n                => ddr3_ck_n,
      ddr_addr                => ddr3_a,
      ddr_ba                  => ddr3_ba,
      ddr_ras_n               => ddr3_ras_n,
      ddr_cas_n               => ddr3_cas_n,
      ddr_we_n                => ddr3_we_n,
      ddr_cs_n                => ddr3_cs_n,
      ddr_cke                 => ddr3_cke,
      ddr_odt                 => ddr3_odt,
      ddr_dm                  => ddr3_dm,
      ddr_dqs                 => ddr3_dqs,
      ddr_dqs_n               => ddr3_dqs_n,
      ddr_dq                  => ddr3_dq,
      dbg_idel_up_all         => '0',
      dbg_idel_down_all       => '0',
      dbg_idel_up_dq          => '0',
      dbg_idel_down_dq        => '0',
      dbg_idel_up_dqs         => '0',
      dbg_idel_down_dqs       => '0',
      dbg_idel_up_gate        => '0',
      dbg_idel_down_gate      => '0',
      dbg_sel_idel_dq         => (others=>'0'),
      dbg_sel_all_idel_dq     => '0',
      dbg_sel_idel_dqs        => (others=>'0'),
      dbg_sel_all_idel_dqs    => '0',
      dbg_sel_idel_gate       => (others=>'0'),
      dbg_sel_all_idel_gate   => '0',
      dbg_calib_done          => open,
      dbg_calib_err           => open,
      dbg_calib_dq_tap_cnt    => open,
      dbg_calib_dqs_tap_cnt   => open,
      dbg_calib_gate_tap_cnt  => open,
      dbg_calib_rd_data_sel   => open,
      dbg_calib_rden_dly      => open,
      dbg_calib_gate_dly      => open
      );
  
end architecture syn;



