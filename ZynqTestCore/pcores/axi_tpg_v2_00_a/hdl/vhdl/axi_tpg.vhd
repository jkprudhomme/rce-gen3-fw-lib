------------------------------------------------------------------------------
-- axi_tpg.vhd - entity/architecture pair
------------------------------------------------------------------------------
-- IMPORTANT:
-- DO NOT MODIFY THIS FILE EXCEPT IN THE DESIGNATED SECTIONS.
--
-- SEARCH FOR --USER TO DETERMINE WHERE CHANGES ARE ALLOWED.
--
-- TYPICALLY, THE ONLY ACCEPTABLE CHANGES INVOLVE ADDING NEW
-- PORTS AND GENERICS THAT GET PASSED THROUGH TO THE INSTANTIATION
-- OF THE USER_LOGIC ENTITY.
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2007 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          axi_tpg.vhd
-- Version:           1.00.a
-- Description:       Top level design, instantiates library components and user logic.
-- Date:              Mon Oct 22 10:34:41 2007 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;
use proc_common_v3_00_a.ipif_pkg.all;

library axi_lite_ipif_v1_00_a;
use axi_lite_ipif_v1_00_a.axi_lite_ipif;

library axi_tpg_v2_00_a;
use axi_tpg_v2_00_a.user_logic;

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
-- C_BASEADDR             -- AXI slave: base address
-- C_HIGHADDR             -- AXI slave: high address
-- C_S_AXI_ADDR_WIDTH     -- AXI address bus width - allowed value - 32 only
-- C_S_AXI_DATA_WIDTH     -- AXI data bus width - allowed value - 32 or 64 only
-- C_S_AXI_ID_WIDTH       -- AXI Identification TAG width - 1 to 16
-- C_S_AXI_CLK_FREQ_HZ    -- AXI Clock Frequency in Hz
-- Not used:
-- C_S_AXI_SUPPORTS_NARROW = 1, DT = INTEGER, RANGE = (0:1), BUS = S_AXI
-- C_S_AXI_WRITE_ACCEPTANCE
-- C_S_AXI_READ_ACCEPTANCE
-- C_S_AXI_READ_ACCEPTANCE
-- C_S_AXI_SUPPORTS_NARROW_BURST  
--   C_FAMILY                     -- Xilinx FPGA family
--
-- Definition of Ports:
-- S_AXI_ACLK            -- AXI Clock
-- S_AXI_ARESETN         -- AXI Reset - active low
--==================================
-- AXI Write Address Channel Signals
--==================================
-- S_AXI_AWID            -- AXI Write Address ID
-- S_AXI_AWADDR          -- AXI Write address - 32 bit
-- S_AXI_AWLEN           -- AXI Write Data Length
-- S_AXI_AWSIZE          -- AXI Burst Size - allowed values
--                       -- 000 - byte burst
--                       -- 001 - half word
--                       -- 010 - word
--                       -- 011 - double word
--                       -- NA for all remaining values
-- S_AXI_AWBURST         -- AXI Burst Type
--                       -- 00  - Fixed
--                       -- 01  - Incr
--                       -- 10  - Wrap
--                       -- 11  - Reserved
-- S_AXI_AWLOCK          -- AXI Lock type
-- S_AXI_AWCACHE         -- AXI Cache Type
-- S_AXI_AWPROT          -- AXI Protection Type
-- S_AXI_AWVALID         -- Write address valid
-- S_AXI_AWREADY         -- Write address ready
--===============================
-- AXI Write Data Channel Signals
--===============================
-- S_AXI_WDATA           -- AXI Write data width
-- S_AXI_WSTRB           -- AXI Write strobes
-- S_AXI_WLAST           -- AXI Last write indicator signal
-- S_AXI_WVALID          -- AXI Write valid
-- S_AXI_WREADY          -- AXI Write ready
--================================
-- AXI Write Data Response Signals
--================================
-- S_AXI_BID             -- AXI Write Response channel number
-- S_AXI_BRESP           -- AXI Write response
--                       -- 00  - Okay
--                       -- 01  - ExOkay
--                       -- 10  - Slave Error
--                       -- 11  - Decode Error
-- S_AXI_BVALID          -- AXI Write response valid
-- S_AXI_BREADY          -- AXI Response ready
--=================================
-- AXI Read Address Channel Signals
--=================================
-- S_AXI_ARID            -- AXI Read ID
-- S_AXI_ARADDR          -- AXI Read address
-- S_AXI_ARLEN           -- AXI Read Data length
-- S_AXI_ARSIZE          -- AXI Read Size
-- S_AXI_ARBURST         -- AXI Read Burst length
-- S_AXI_ARLOCK          -- AXI Read Lock
-- S_AXI_ARCACHE         -- AXI Read Cache
-- S_AXI_ARPROT          -- AXI Read Protection
-- S_AXI_RVALID          -- AXI Read valid
-- S_AXI_RREADY          -- AXI Read ready
--==============================
-- AXI Read Data Channel Signals
--==============================
-- S_AXI_RID             -- AXI Read Channel ID
-- S_AXI_RDATA           -- AXI Read data
-- S_AXI_RRESP           -- AXI Read response
-- S_AXI_RLAST           -- AXI Read Data Last signal
-- S_AXI_RVALID          -- AXI Read address valid
-- S_AXI_RREADY          -- AXI Read address ready
------------------------------------------------------------------------------

entity axi_tpg is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    C_CHROMA_FORMAT                 :  integer           := 0;
    C_DATA_WIDTH                    :  integer           := 8;
    C_NUM_CHANNELS                  :  integer           := 2;
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_BASEADDR                     : std_logic_vector     := X"FFFFFFFF";
    C_HIGHADDR                     : std_logic_vector     := X"00000000";
     C_S_AXI_ADDR_WIDTH     : integer range 32 to 32 := 32;
     C_S_AXI_DATA_WIDTH     : integer range 32 to 64 := 32;
     C_S_AXI_CLK_FREQ_HZ    : integer := 100000000;
    C_FAMILY                       : string               := "virtex5"
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    -- USER ports added here
   clk               :  in    STD_LOGIC;
   
   -- XSVI input bus.
   vsync_in                :  in    std_logic;
   hsync_in                :  in    std_logic;
   vblank_in               :  in    std_logic;
   hblank_in               :  in    std_logic;
   active_video_in         :  in    std_logic;
   video_data_in           :  in    std_logic_vector((C_NUM_CHANNELS*C_DATA_WIDTH)-1 downto 0);

   -- XSVI output bus.
   vsync_out               :  out   std_logic;
   hsync_out               :  out   std_logic;
   vblank_out              :  out   std_logic;
   hblank_out              :  out   std_logic;
   active_video_out        :  out   std_logic;
   video_data_out          :  out   std_logic_vector((C_NUM_CHANNELS*C_DATA_WIDTH)-1 downto 0);
   
   -- Video out to VDMA to VFBC to MPMC to external memory
   VDMA_wd_clk             :  out   std_logic;
   VDMA_wd_reset           :  out   std_logic;
   VDMA_video_out_we       :  out   std_logic;
   VDMA_video_out_full     :  in    std_logic;
   VDMA_video_data_out     :  out   std_logic_vector((C_DATA_WIDTH*C_NUM_CHANNELS)-1 downto 0);

   ZP_debug          :  out   std_logic_vector(57 downto 0);
   TPG_debug         :  out   std_logic_vector(38 downto 0);

    -- ADD USER PORTS ABOVE THIS LINE ------------------
    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
--  -- AXI Slave signals ------------------------------------------------------
--   -- AXI Global System Signals
       S_AXI_ACLK    : in  std_logic := '0';
       S_AXI_ARESETN : in  std_logic := '1';
--   -- AXI Write Address Channel Signals
       S_AXI_AWADDR  : in  std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0) := (others => '0');
       S_AXI_AWVALID : in  std_logic := '0';
       S_AXI_AWREADY : out std_logic;
--   -- AXI Write Channel Signals
       S_AXI_WDATA   : in  std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0) := (others => '0');
       S_AXI_WSTRB   : in  std_logic_vector
                               (((C_S_AXI_DATA_WIDTH/8)-1) downto 0) := (others => '0');
       S_AXI_WVALID  : in  std_logic := '0';
       S_AXI_WREADY  : out std_logic;
--   -- AXI Write Response Channel Signals
       S_AXI_BRESP   : out std_logic_vector(1 downto 0);
       S_AXI_BVALID  : out std_logic;
       S_AXI_BREADY  : in  std_logic := '0';
--   -- AXI Read Address Channel Signals
       S_AXI_ARADDR  : in  std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0) := (others => '0');
       S_AXI_ARVALID : in  std_logic := '0';
       S_AXI_ARREADY : out std_logic := '0';
--   -- AXI Read Data Channel Signals
       S_AXI_RDATA   : out std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
       S_AXI_RRESP   : out std_logic_vector(1 downto 0);
       S_AXI_RVALID  : out std_logic;
       S_AXI_RREADY  : in  std_logic := '0'
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute SIGIS : string;
  attribute SIGIS of S_AXI_ACLK      : signal is "CLK";
  attribute SIGIS of S_AXI_ARESETN      : signal is "RST";

end entity axi_tpg;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of axi_tpg is

  ------------------------------------------
  -- Array of base/high address pairs for each address range
  ------------------------------------------
  constant ZERO_ADDR_PAD                  : std_logic_vector(0 to 31) := (others => '0');
  constant USER_SLV_BASEADDR              : std_logic_vector     := C_BASEADDR;
  constant USER_SLV_HIGHADDR              : std_logic_vector     := C_HIGHADDR;

  constant IPIF_ARD_ADDR_RANGE_ARRAY      : SLV64_ARRAY_TYPE     := 
    (
      ZERO_ADDR_PAD & USER_SLV_BASEADDR,  -- user logic slave space base address
      ZERO_ADDR_PAD & USER_SLV_HIGHADDR   -- user logic slave space high address
    );

  ------------------------------------------
  -- Array of desired number of chip enables for each address range
  ------------------------------------------
  constant USER_SLV_NUM_REG               : integer              := 8;
  constant USER_NUM_REG                   : integer              := USER_SLV_NUM_REG;

  constant IPIF_ARD_NUM_CE_ARRAY          : INTEGER_ARRAY_TYPE   := 
    (
      0  => pad_power2(USER_SLV_NUM_REG)  -- number of ce for user logic slave space
    );

  ------------------------------------------
  -- Ratio of bus clock to core clock (for use in dual clock systems)
  -- 1 = ratio is 1:1
  -- 2 = ratio is 2:1
  ------------------------------------------
  constant IPIF_BUS2CORE_CLK_RATIO        : integer              := 1;

  ------------------------------------------
  -- Width of the slave data bus (32 only)
  ------------------------------------------
  constant USER_SLV_DWIDTH                : integer              := C_S_AXI_DATA_WIDTH;

  constant IPIF_SLV_DWIDTH                : integer              := C_S_AXI_DATA_WIDTH;

  ------------------------------------------
  -- Index for CS/CE
  ------------------------------------------
  constant USER_SLV_CS_INDEX              : integer              := 0;
  constant USER_SLV_CE_INDEX              : integer              := calc_start_ce_index(IPIF_ARD_NUM_CE_ARRAY, USER_SLV_CS_INDEX);

  constant USER_CE_INDEX                  : integer              := USER_SLV_CE_INDEX;

  ------------------------------------------
  -- IP Interconnect (IPIC) signal declarations
  ------------------------------------------
	--function swap_endian (a : std_logic_vector) return std_logic_vector is
	--	variable result : std_logic_vector(a'length-1 downto 0);
	--begin
	--	for i in result'RANGE loop
	--		result(i) := a(a'length-1-i);
	--	end loop;
	--	return result;
	--end;

  signal le_ipif_Bus2IP_Addr            : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal le_ipif_Bus2IP_Data            : std_logic_vector(IPIF_SLV_DWIDTH-1 downto 0);
  signal le_ipif_Bus2IP_BE              : std_logic_vector(IPIF_SLV_DWIDTH/8-1 downto 0);
  signal le_ipif_Bus2IP_CS              : std_logic_vector(((IPIF_ARD_ADDR_RANGE_ARRAY'length)/2)-1 downto 0);
  signal le_ipif_Bus2IP_RdCE            : std_logic_vector(calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1 downto 0);
  signal le_ipif_Bus2IP_WrCE            : std_logic_vector(calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1 downto 0);
  signal le_ipif_IP2Bus_Data            : std_logic_vector(IPIF_SLV_DWIDTH-1 downto 0);
  signal ipif_Bus2IP_Resetn             : std_logic;

   signal   ipif_Bus2IP_Clk               :  std_logic;
   signal   ipif_Bus2IP_Reset             :  std_logic;
   signal   ipif_IP2Bus_Data              :  std_logic_vector(0 to IPIF_SLV_DWIDTH-1);
   signal   ipif_IP2Bus_WrAck             :  std_logic;
   signal   ipif_IP2Bus_RdAck             :  std_logic;
   signal   ipif_IP2Bus_Error             :  std_logic;
   signal   ipif_Bus2IP_Addr              :  std_logic_vector(0 to C_S_AXI_ADDR_WIDTH-1);
   signal   ipif_Bus2IP_Data              :  std_logic_vector(0 to IPIF_SLV_DWIDTH-1);
   signal   ipif_Bus2IP_RNW               :  std_logic;
   signal   ipif_Bus2IP_BE                :  std_logic_vector(0 to IPIF_SLV_DWIDTH/8-1);
   signal   ipif_Bus2IP_CS                :  std_logic_vector(0 to ((IPIF_ARD_ADDR_RANGE_ARRAY'length)/2)-1);
   signal   ipif_Bus2IP_RdCE              :  std_logic_vector(0 to calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1);
   signal   ipif_Bus2IP_WrCE              :  std_logic_vector(0 to calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1);
   signal   user_Bus2IP_RdCE              :  std_logic_vector(0 to USER_NUM_REG-1);
   signal   user_Bus2IP_WrCE              :  std_logic_vector(0 to USER_NUM_REG-1);
   signal   user_IP2Bus_Data              :  std_logic_vector(0 to USER_SLV_DWIDTH-1);
   signal   user_IP2Bus_RdAck             :  std_logic;
   signal   user_IP2Bus_WrAck             :  std_logic;
   signal   user_IP2Bus_Error             :  std_logic;
   signal   t_vsync_out                   :  std_logic;
   signal   t_video_data_out              :  std_logic_vector((C_NUM_CHANNELS*C_DATA_WIDTH)-1 downto 0);
   signal   t_active_video_out            :  std_logic;
   signal   red_out                       :  std_logic_vector((C_DATA_WIDTH -1) downto 0);
   signal   green_out                     :  std_logic_vector((C_DATA_WIDTH -1) downto 0);
   signal   blue_out                      :  std_logic_vector((C_DATA_WIDTH -1) downto 0);
   signal   red_in                        :  std_logic_vector((C_DATA_WIDTH -1) downto 0);
   signal   green_in                      :  std_logic_vector((C_DATA_WIDTH -1) downto 0);
   signal   blue_in                       :  std_logic_vector((C_DATA_WIDTH -1) downto 0);
begin

  ------------------------------------------
  -- instantiate axi_lite_ipif
  ------------------------------------------
  -------------------------------------------------------------------------
  --REG_RESET_FROM_IPIF: convert active low to active high reset to rest of
  --                     the core.
  -------------------------------------------------------------------------
  REG_RESET_FROM_IPIF: process (S_AXI_ACLK) is
  begin
       if(S_AXI_ACLK'event and S_AXI_ACLK = '1') then
           ipif_Bus2IP_Reset <= not(ipif_Bus2IP_Resetn);
       end if;
  end process REG_RESET_FROM_IPIF;

--  ipif_Bus2IP_Addr <= swap_endian(le_ipif_Bus2IP_Addr);
--  ipif_Bus2IP_Data <= swap_endian(le_ipif_Bus2IP_Data);
--  ipif_Bus2IP_BE   <= swap_endian(le_ipif_Bus2IP_BE);
--  ipif_Bus2IP_CS   <= swap_endian(le_ipif_Bus2IP_CS);
--  ipif_Bus2IP_RdCE <= swap_endian(le_ipif_Bus2IP_RdCE);
--  ipif_Bus2IP_WrCE <= swap_endian(le_ipif_Bus2IP_WrCE);
--  le_ipif_IP2Bus_Data <= swap_endian(ipif_IP2Bus_Data);

  ipif_Bus2IP_Addr <= le_ipif_Bus2IP_Addr;
  ipif_Bus2IP_Data <= le_ipif_Bus2IP_Data;
  ipif_Bus2IP_BE   <= le_ipif_Bus2IP_BE;
  ipif_Bus2IP_CS   <= le_ipif_Bus2IP_CS;
  ipif_Bus2IP_RdCE <= le_ipif_Bus2IP_RdCE;
  ipif_Bus2IP_WrCE <= le_ipif_Bus2IP_WrCE;
  le_ipif_IP2Bus_Data <= ipif_IP2Bus_Data;


    AXI_LITE_IPIF_I : entity axi_lite_ipif_v1_00_a.axi_lite_ipif
      generic map
       (
        C_S_AXI_ADDR_WIDTH        => C_S_AXI_ADDR_WIDTH,
        C_S_AXI_DATA_WIDTH        => C_S_AXI_DATA_WIDTH,
        C_S_AXI_MIN_SIZE          => X"000003FF",
        C_USE_WSTRB               => 0,
        C_DPHASE_TIMEOUT          => 8,
        C_ARD_ADDR_RANGE_ARRAY    => IPIF_ARD_ADDR_RANGE_ARRAY,
        C_ARD_NUM_CE_ARRAY        => IPIF_ARD_NUM_CE_ARRAY,
        C_FAMILY                  => C_FAMILY
       )
     port map
       (
        S_AXI_ACLK          =>  S_AXI_ACLK,
        S_AXI_ARESETN       =>  S_AXI_ARESETN,
        S_AXI_AWADDR        =>  S_AXI_AWADDR,
        S_AXI_AWVALID       =>  S_AXI_AWVALID,
        S_AXI_AWREADY       =>  S_AXI_AWREADY,
        S_AXI_WDATA         =>  S_AXI_WDATA,
        S_AXI_WSTRB         =>  S_AXI_WSTRB,
        S_AXI_WVALID        =>  S_AXI_WVALID,
        S_AXI_WREADY        =>  S_AXI_WREADY,
        S_AXI_BRESP         =>  S_AXI_BRESP,
        S_AXI_BVALID        =>  S_AXI_BVALID,
        S_AXI_BREADY        =>  S_AXI_BREADY,
        S_AXI_ARADDR        =>  S_AXI_ARADDR,
        S_AXI_ARVALID       =>  S_AXI_ARVALID,
        S_AXI_ARREADY       =>  S_AXI_ARREADY,
        S_AXI_RDATA         =>  S_AXI_RDATA,
        S_AXI_RRESP         =>  S_AXI_RRESP,
        S_AXI_RVALID        =>  S_AXI_RVALID,
        S_AXI_RREADY        =>  S_AXI_RREADY,
     
     -- IP Interconnect (IPIC) port signals 
        Bus2IP_Clk     => ipif_Bus2IP_Clk,
        Bus2IP_Resetn  => ipif_Bus2IP_Resetn,
        IP2Bus_Data    => le_ipif_IP2Bus_Data, --swap_endian(ipif_IP2Bus_Data),
        IP2Bus_WrAck   => ipif_IP2Bus_WrAck,
        IP2Bus_RdAck   => ipif_IP2Bus_RdAck,
        IP2Bus_Error   => ipif_IP2Bus_Error,
        Bus2IP_Addr    => le_ipif_Bus2IP_Addr,
        Bus2IP_Data    => le_ipif_Bus2IP_Data,
        Bus2IP_RNW     => ipif_Bus2IP_RNW,
        Bus2IP_BE      => le_ipif_Bus2IP_BE,
        Bus2IP_CS      => le_ipif_Bus2IP_CS,
        Bus2IP_RdCE    => le_ipif_Bus2IP_RdCE,
        Bus2IP_WrCE    => le_ipif_Bus2IP_WrCE 
       );


  ------------------------------------------
  -- instantiate User Logic
  ------------------------------------------
  USER_LOGIC_I : entity axi_tpg_v2_00_a.user_logic
    generic map
    (
      -- MAP USER GENERICS BELOW THIS LINE ---------------
      C_FAMILY          => C_FAMILY,  
      C_Chroma_Format   => C_CHROMA_FORMAT,
      -- MAP USER GENERICS ABOVE THIS LINE ---------------

      C_SLV_DWIDTH                   => USER_SLV_DWIDTH,
      C_NUM_REG                      => USER_NUM_REG
    )
    port map
    (
      -- MAP USER PORTS BELOW THIS LINE ------------------
      clk               => clk,
      rst               => ipif_Bus2IP_Reset,
      vsync_in          => vsync_in,
      hsync_in          => hsync_in,
      vblank_in         => vblank_in,
      hblank_in         => hblank_in,
      de_in             => active_video_in,
      blue_in           => blue_in,    
      green_in          => green_in,   
      red_in            => red_in,     

      vsync_out         => t_vsync_out,
      hsync_out         => hsync_out,
      vblank_out        => vblank_out,
      hblank_out        => hblank_out,
      de_out            => t_active_video_out,
      blue_out          => blue_out,
      green_out         => green_out,
      red_out           => red_out,
      ZP_debug          => ZP_debug,
      TPG_debug         => TPG_debug,
      -- MAP USER PORTS ABOVE THIS LINE ------------------

      Bus2IP_Clk                     => ipif_Bus2IP_Clk,
      Bus2IP_Reset                   => ipif_Bus2IP_Reset,
      Bus2IP_Data                    => ipif_Bus2IP_Data,
      Bus2IP_BE                      => ipif_Bus2IP_BE,
      Bus2IP_RdCE                    => user_Bus2IP_RdCE,
      Bus2IP_WrCE                    => user_Bus2IP_WrCE,
      IP2Bus_Data                    => user_IP2Bus_Data,
      IP2Bus_RdAck                   => user_IP2Bus_RdAck,
      IP2Bus_WrAck                   => user_IP2Bus_WrAck,
      IP2Bus_Error                   => user_IP2Bus_Error
    );

Select_2_Channels : if (C_NUM_CHANNELS = 2) generate
      t_video_data_out((2*C_DATA_WIDTH)-1 downto C_DATA_WIDTH)       <= green_out;
      t_video_data_out(C_DATA_WIDTH-1 downto 0)                      <= red_out;

      blue_in        <= (others=> '0');
      green_in       <= video_data_in((2*C_DATA_WIDTH)-1 downto C_DATA_WIDTH);
      red_in         <= video_data_in(C_DATA_WIDTH-1 downto 0);

end generate;

Select_3_Channels : if (C_NUM_CHANNELS = 3) generate
      t_video_data_out((3*C_DATA_WIDTH)-1 downto (2*C_DATA_WIDTH))   <= red_out;
      t_video_data_out((2*C_DATA_WIDTH)-1 downto C_DATA_WIDTH)       <= blue_out;
      t_video_data_out(C_DATA_WIDTH-1 downto 0)                      <= green_out;

      red_in         <= video_data_in((3*C_DATA_WIDTH)-1 downto (2*C_DATA_WIDTH));
      blue_in        <= video_data_in((2*C_DATA_WIDTH)-1 downto C_DATA_WIDTH);
      green_in       <= video_data_in(C_DATA_WIDTH-1 downto 0);
end generate;

vsync_out            <= t_vsync_out;
active_video_out     <= t_active_video_out;
video_data_out       <= t_video_data_out;
VDMA_wd_clk          <= clk;
VDMA_wd_reset        <= t_vsync_out;
VDMA_video_out_we    <= t_active_video_out;
VDMA_video_data_out  <= t_video_data_out;

------------------------------------------
-- connect internal signals
------------------------------------------
ipif_IP2Bus_Data   <= user_IP2Bus_Data;
ipif_IP2Bus_WrAck  <= user_IP2Bus_WrAck;
ipif_IP2Bus_RdAck  <= user_IP2Bus_RdAck;
ipif_IP2Bus_Error  <= user_IP2Bus_Error;

user_Bus2IP_RdCE <= ipif_Bus2IP_RdCE(USER_CE_INDEX to USER_CE_INDEX+USER_NUM_REG-1);
user_Bus2IP_WrCE <= ipif_Bus2IP_WrCE(USER_CE_INDEX to USER_CE_INDEX+USER_NUM_REG-1);

end IMP;
