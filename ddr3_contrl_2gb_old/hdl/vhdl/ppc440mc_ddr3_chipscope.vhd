-------------------------------------------------------------------------------
-- system_tb.vhd
-------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_unsigned.conv_integer;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity ppc440mc_ddr3_chipscope is
  generic (
   BANK_WIDTH 		: integer         := 3;  -- # of memory bank addr bits
   CLK_WIDTH 		: integer         := 2;  -- # of clock outputs
   CKE_WIDTH 		: integer         := 2;  -- # of total memory chip selects
   CS_NUM 		: integer         := 2;  
   CS_BITS 		: integer         := 1;  -- #log2 of NUM_RANKS_MEM
   CS_WIDTH      	: integer 	  := 2;  -- # of total memory chip selects
   COL_WIDTH     	: integer 	  := 10; -- # of memory column bits
   ROW_WIDTH 		: integer         := 15; -- # of memory row & # of addr bits
   DM_WIDTH 		: integer         := 8;  --9,  --8 # of data mask bits
   DQ_BITS 		: integer         := 6;  --7,  --6  -- set to log2(DQS_WIDTH*DQ_PER_DQS)
   DQ_WIDTH 		: integer         := 64; --72,  --64 # data width 
   DQS_BITS 		: integer         := 3;  --4,  --3  -- set to log2(DQS_WIDTH)
   DQS_WIDTH 		: integer         := 8;  --9,  --8,  -- # of DQS strobes
   DQ_PER_DQS    	: integer 	  := 8;  -- # of DQ data bits per strobe
   ADDITIVE_LAT 	: integer         := 0;  -- additive write latency
   CAS_LAT 		: integer         := 5;  -- CAS latency
   ODT_TYPE 		: integer         := 1;      -- ODT (=0(none),=1(75),=2(150),=3(50))
   ODT_WIDTH 		: integer         := 2;      -- # of memory on-die term enables
   TREFI_NS 		: integer         := 3900;   -- auto refresh interval (uS)
   TRAS 		: integer         := 76800;  -- active->precharge delay
   TRCD 		: integer         := 13500;  -- active->read/write delay
   TRFC 		: integer         := 342400; -- ref->ref, ref->active delay
   TRP 			: integer         := 13500;  -- precharge->command delay
   TRTP 		: integer         := 12800;   -- read->precharge delayg
   TWR 			: integer         := 15000;  -- used to determine wr->prech
   TWTR  		: integer         := 12800;  -- write->read delay
   REDUCE_DRV		: integer         := 0;      -- reduced strength DDR3 I/O (=1 yes)
   IODELAY_GRP 		: string          := "IODELAY_MIG";
   CLK_PERIOD    	: integer 	  := 3200;    -- Core/Memory clock period (in ps) <-- use -15E, 1500 to 3300 ps
   BURST_LEN     	: integer 	  := 8;       -- burst length (in double words)
   BURST_TYPE    	: integer 	  := 0;       -- burst type (=0 seq; =1 interleaved)
   ECC_ENABLE    	: integer 	  := 0;       -- enable ECC (=1 enable), not supported
   MULTI_BANK_EN 	: integer 	  := 1;       -- Keeps multiple banks open. (= 1 en)
   TWO_T_TIME_EN 	: integer 	  := 1;       -- 2t timing for unbuffered dimms        ---- ????
   REG_ENABLE    	: integer 	  := 0;       -- registered addr/ctrl (=1 yes)
   READ_DATA_PIPELINE 	: integer         := 0;       -- Additional pipeline stage in read data path   
   APPDATA_WIDTH 	: integer 	  := 128;      -- # of usr read/write data bus bits
   HIGH_PERFORMANCE_MODE : boolean 	  := TRUE;
   MIB_CLK_RATIO 	: integer         := 0;
   C_MEM_BASEADDR 	: std_logic_vector  := x"00000000";
   C_MEM_HIGHADDR 	: std_logic_vector  := x"F7FFFFFF";
   SIM_ONLY 		: integer         := 0;         -- = 1 to skip power up delay
   DEBUG_EN      	: integer 	  := 0;       -- Enable debug signals/controls
   FPGA_SPEED_GRADE	: integer  	  := 2
  );
  port (
    mc_mibclk 		: in std_logic;
    mi_mcclk90 		: in std_logic;
    mi_mcreset 		: in std_logic;
    mi_mcclk_200 	: in std_logic;
    mi_mcclkdiv2 	: in std_logic;
    mi_mcaddressvalid 	: in std_logic;
    mi_mcaddress	: in std_logic_vector(0 to 35);
    mi_mcbankconflict 	: in std_logic;
    mi_mcrowconflict 	: in std_logic;
    mi_mcbyteenable	: in std_logic_vector(0 to 15);
    mi_mcwritedata	: in std_logic_vector(0 to 127);
    mi_mcreadnotwrite 	: in std_logic;
    mi_mcwritedatavalid : in std_logic;
 
    idelay_ctrl_rdy_i 	: in std_logic;
    idelay_ctrl_rdy 	: out std_logic;
 
    dcm_lock            : in  std_logic;
    phy_init_done       : out std_logic;

    DDR3_DQ		: inout std_logic_vector(DQ_WIDTH-1 downto 0);
    DDR3_DQS		: inout std_logic_vector(DQS_WIDTH-1 downto 0);
    DDR3_DQS_N		: inout std_logic_vector(DQS_WIDTH-1 downto 0);
 
    DDR3_A		: out std_logic_vector(ROW_WIDTH-1 downto 0);
    DDR3_BA		: out std_logic_vector(BANK_WIDTH-1 downto 0);
    DDR3_RAS_N		: out std_logic;
    DDR3_CAS_N		: out std_logic;
    DDR3_WE_N		: out std_logic;
    DDR3_CS_N		: out std_logic_vector(CS_WIDTH-1 downto 0);
    DDR3_ODT		: out std_logic_vector(ODT_WIDTH-1 downto 0);
    DDR3_CKE		: out std_logic_vector(CKE_WIDTH-1 downto 0);
    DDR3_DM		: out std_logic_vector(DM_WIDTH-1 downto 0);
    DDR3_CK		: out std_logic_vector(CLK_WIDTH-1 downto 0);
    DDR3_CK_N		: out std_logic_vector(CLK_WIDTH-1 downto 0);
    DDR3_RESET_N	: out std_logic;
    mc_miaddrreadytoaccept: out std_logic;
    mc_mireaddata	: out std_logic_vector(0 to 127);
    mc_mireaddataerr	: out std_logic;
    mc_mireaddatavalid	: out std_logic;
  
    mi_mcaddressvalid_chipscope		: out std_logic;
    mi_mcaddress_chipscope		: out std_logic_vector(0 to 35);
    mi_mcbankconflict_chipscope		: out std_logic;
    mi_mcrowconflict_chipscope		: out std_logic;
    mi_mcbyteenable_chipscope		: out std_logic_vector(0 to 15);
    mi_mcwritedata_chipscope		: out std_logic_vector(0 to 127);
    mi_mcreadnotwrite_chipscope		: out std_logic;
    mi_mcwritedatavalid_chipscope	: out std_logic;
    mc_miaddrreadytoaccept_chipscope 	: out std_logic;
    mc_mireaddata_chipscope		: out std_logic_vector(0 to 127);
    mc_mireaddataerr_chipscope		: out std_logic;
    mc_mireaddatavalid_chipscope 	: out std_logic
);        
end ppc440mc_ddr3_chipscope;

architecture RTL of ppc440mc_ddr3_chipscope is

  component ppc440mc_DDR3 is
  generic (
   BANK_WIDTH 		: integer         := 3;  -- # of memory bank addr bits
   CLK_WIDTH 		: integer         := 2;  -- # of clock outputs
   CKE_WIDTH 		: integer         := 2;  -- # of total memory chip selects
   CS_NUM 		: integer         := 2;  
   CS_BITS 		: integer         := 0;  -- #log2 of NUM_RANKS_MEM
   CS_WIDTH      	: integer 	  := 2;  -- # of total memory chip selects
   COL_WIDTH     	: integer 	  := 10; -- # of memory column bits
   ROW_WIDTH 		: integer         := 16; -- # of memory row & # of addr bits
   DM_WIDTH 		: integer         := 8;  --9,  --8 # of data mask bits
   DQ_BITS 		: integer         := 6;  --7,  --6  -- set to log2(DQS_WIDTH*DQ_PER_DQS)
   DQ_WIDTH 		: integer         := 64; --72,  --64 # data width 
   DQS_BITS 		: integer         := 3;  --4,  --3  -- set to log2(DQS_WIDTH)
   DQS_WIDTH 		: integer         := 8;  --9,  --8,  -- # of DQS strobes
   DQ_PER_DQS    	: integer 	  := 8;  -- # of DQ data bits per strobe
   ADDITIVE_LAT 	: integer         := 0;  -- additive write latency
   CAS_LAT 		: integer         := 5;  -- CAS latency
   ODT_TYPE 		: integer         := 1;      -- ODT (=0(none),=1(75),=2(150),=3(50))
   ODT_WIDTH 		: integer         := 2;      -- # of memory on-die term enables
   TREFI_NS 		: integer         := 7800;   -- auto refresh interval (uS)
   TRAS 		: integer         := 40000;  -- active->precharge delay
   TRCD 		: integer         := 15000;  -- active->read/write delay
   TRFC 		: integer         := 105000; -- ref->ref, ref->active delay
   TRP 			: integer         := 15000;  -- precharge->command delay
   TRTP 		: integer         := 7500;   -- read->precharge delayg
   TWR 			: integer         := 15000;  -- used to determine wr->prech
   TWTR  		: integer         := 10000;  -- write->read delay
   REDUCE_DRV		: integer         := 0;      -- reduced strength DDR3 I/O (=1 yes)
   IODELAY_GRP 		: string          := "IODELAY_MIG";
   CLK_PERIOD    	: integer 	  := 3200;    -- Core/Memory clock period (in ps) <-- use -15E, 1500 to 3300 ps
   BURST_LEN     	: integer 	  := 8;       -- burst length (in double words)
   BURST_TYPE    	: integer 	  := 0;       -- burst type (=0 seq; =1 interleaved)
   ECC_ENABLE    	: integer 	  := 0;       -- enable ECC (=1 enable), not supported
   MULTI_BANK_EN 	: integer 	  := 0;       -- Keeps multiple banks open. (= 1 en)
   TWO_T_TIME_EN 	: integer 	  := 0;       -- 2t timing for unbuffered dimms        ---- ????
   REG_ENABLE    	: integer 	  := 0;       -- registered addr/ctrl (=1 yes)
   READ_DATA_PIPELINE 	: integer         := 0;       -- Additional pipeline stage in read data path   
   APPDATA_WIDTH 	: integer 	  := 128;      -- # of usr read/write data bus bits
   HIGH_PERFORMANCE_MODE : boolean 	  := TRUE;
   MIB_CLK_RATIO 	: integer         := 0;
   C_MEM_BASEADDR 	: std_logic_vector  := x"FFFFFFFF";
   C_MEM_HIGHADDR 	: std_logic_vector  := x"00000000";
   SIM_ONLY 		: integer         := 1;         -- = 1 to skip power up delay
   DEBUG_EN      	: integer 	  := 0       -- Enable debug signals/controls   
   );                                         
  port (
    mc_mibclk 		: in std_logic;
    mi_mcclk90 		: in std_logic;
    mi_mcreset 		: in std_logic;
    mi_mcclk_200 	: in std_logic;
    mi_mcclkdiv2 	: in std_logic;
    mi_mcaddressvalid 	: in std_logic;
    mi_mcaddress	: in std_logic_vector(0 to 35);
    mi_mcbankconflict 	: in std_logic;
    mi_mcrowconflict 	: in std_logic;
    mi_mcbyteenable	: in std_logic_vector(0 to 15);
    mi_mcwritedata	: in std_logic_vector(0 to 127);
    mi_mcreadnotwrite 	: in std_logic;
    mi_mcwritedatavalid : in std_logic;
 
    idelay_ctrl_rdy_i 	: in std_logic;
    idelay_ctrl_rdy 	: out std_logic;
 
    dcm_lock            : in  std_logic;
    phy_init_done       : out std_logic;

    DDR3_DQ		: inout std_logic_vector(DQ_WIDTH-1 downto 0);
    DDR3_DQS		: inout std_logic_vector(DQS_WIDTH-1 downto 0);
    DDR3_DQS_N		: inout std_logic_vector(DQS_WIDTH-1 downto 0);
 
    DDR3_A		: out std_logic_vector(ROW_WIDTH-1 downto 0);
    DDR3_BA		: out std_logic_vector(BANK_WIDTH-1 downto 0);
    DDR3_RAS_N		: out std_logic;
    DDR3_CAS_N		: out std_logic;
    DDR3_WE_N		: out std_logic;
    DDR3_CS_N		: out std_logic_vector(CS_WIDTH-1 downto 0);
    DDR3_ODT		: out std_logic_vector(ODT_WIDTH-1 downto 0);
    DDR3_CKE		: out std_logic_vector(CKE_WIDTH-1 downto 0);
    DDR3_DM		: out std_logic_vector(DM_WIDTH-1 downto 0);
    DDR3_CK		: out std_logic_vector(CLK_WIDTH-1 downto 0);
    DDR3_CK_N		: out std_logic_vector(CLK_WIDTH-1 downto 0);
    DDR3_RESET_N	: out std_logic;
    mc_miaddrreadytoaccept: out std_logic;
    mc_mireaddata	: out std_logic_vector(0 to 127);
    mc_mireaddataerr	: out std_logic;
    mc_mireaddatavalid	: out std_logic
    );
  end component;

  -- Internal signals
   signal i_mc_miaddrreadytoaccept : std_logic;
   signal i_mc_mireaddata	: std_logic_vector(0 to 127);
   signal i_mc_mireaddataerr	: std_logic;
   signal i_mc_mireaddatavalid	: std_logic;
   
begin

    mi_mcaddressvalid_chipscope		<= mi_mcaddressvalid;
    mi_mcaddress_chipscope		<= mi_mcaddress;
    mi_mcbankconflict_chipscope		<= mi_mcbankconflict;		
    mi_mcrowconflict_chipscope		<= mi_mcrowconflict;		
    mi_mcbyteenable_chipscope		<= mi_mcbyteenable;		
    mi_mcwritedata_chipscope		<= mi_mcwritedata;		
    mi_mcreadnotwrite_chipscope		<= mi_mcreadnotwrite;		
    mi_mcwritedatavalid_chipscope	<= mi_mcwritedatavalid;	
    mc_miaddrreadytoaccept_chipscope 	<= i_mc_miaddrreadytoaccept; 	
    mc_mireaddata_chipscope		<= i_mc_mireaddata;		
    mc_mireaddataerr_chipscope		<= i_mc_mireaddataerr;		
    mc_mireaddatavalid_chipscope 	<= i_mc_mireaddatavalid;	

    mc_miaddrreadytoaccept 	<= i_mc_miaddrreadytoaccept; 	
    mc_mireaddata		<= i_mc_mireaddata;		
    mc_mireaddataerr		<= i_mc_mireaddataerr;		
    mc_mireaddatavalid 		<= i_mc_mireaddatavalid;
    
  u_ppc440mc_ddr3 : ppc440mc_ddr3
  generic map (
   BANK_WIDTH 		 => BANK_WIDTH, 		
   CLK_WIDTH 		 => CLK_WIDTH,		
   CKE_WIDTH 		 => CKE_WIDTH,
   CS_NUM 		 => CS_NUM,  
   CS_BITS 		 => CS_BITS, 		
   CS_WIDTH      	 => CS_WIDTH,      	
   COL_WIDTH     	 => COL_WIDTH,    	
   ROW_WIDTH 		 => ROW_WIDTH, 		
   DM_WIDTH 		 => DM_WIDTH, 		
   DQ_BITS 		 => DQ_BITS, 		
   DQ_WIDTH 		 => DQ_WIDTH, 		
   DQS_BITS 		 => DQS_BITS, 		
   DQS_WIDTH 		 => DQS_WIDTH, 		
   DQ_PER_DQS    	 => DQ_PER_DQS,
   ADDITIVE_LAT 	 => ADDITIVE_LAT,	
   CAS_LAT 		 => CAS_LAT, 		
   ODT_TYPE 		 => ODT_TYPE,		
   ODT_WIDTH 		 => ODT_WIDTH, 		
   TREFI_NS 		 => TREFI_NS, 		
   TRAS 		 => TRAS, 		
   TRCD 		 => TRCD, 		
   TRFC 		 => TRFC, 		
   TRP 			 => TRP, 			
   TRTP 		 => TRTP, 		
   TWR 			 => TWR, 			
   TWTR  		 => TWTR,  		
   REDUCE_DRV		 => REDUCE_DRV,		
   IODELAY_GRP 		 => IODELAY_GRP, 		
   CLK_PERIOD    	 => CLK_PERIOD,    	
   BURST_LEN     	 => BURST_LEN,     	
   BURST_TYPE    	 => BURST_TYPE,    	
   ECC_ENABLE    	 => ECC_ENABLE,   	
   MULTI_BANK_EN 	 => MULTI_BANK_EN, 	
   TWO_T_TIME_EN 	 => TWO_T_TIME_EN, 	
   REG_ENABLE    	 => REG_ENABLE,    	
   READ_DATA_PIPELINE 	 => READ_DATA_PIPELINE, 	
   APPDATA_WIDTH 	 => APPDATA_WIDTH, 	
   HIGH_PERFORMANCE_MODE => HIGH_PERFORMANCE_MODE,
   MIB_CLK_RATIO 	 => MIB_CLK_RATIO, 	
   C_MEM_BASEADDR 	 => C_MEM_BASEADDR,	
   C_MEM_HIGHADDR 	 => C_MEM_HIGHADDR,
   DEBUG_EN      	 => DEBUG_EN,     	 
   SIM_ONLY 		 => SIM_ONLY 		
  )                                        
  port map (
    mc_mibclk 			=> mc_mibclk, 			
    mi_mcclk90 			=> mi_mcclk90, 			
    mi_mcreset 			=> mi_mcreset, 			
    mi_mcclk_200 		=> mi_mcclk_200, 		
    mi_mcclkdiv2 		=> mi_mcclkdiv2, 		
    mi_mcaddressvalid 		=> mi_mcaddressvalid, 		
    mi_mcaddress		=> mi_mcaddress,		
    mi_mcbankconflict 		=> mi_mcbankconflict, 		
    mi_mcrowconflict 		=> mi_mcrowconflict, 		
    mi_mcbyteenable		=> mi_mcbyteenable,		
    mi_mcwritedata		=> mi_mcwritedata,		
    mi_mcreadnotwrite 		=> mi_mcreadnotwrite, 		
    mi_mcwritedatavalid 	=> mi_mcwritedatavalid, 	
 			 				 
    idelay_ctrl_rdy_i 		=> idelay_ctrl_rdy_i, 		
    idelay_ctrl_rdy 		=> idelay_ctrl_rdy, 		
 			 				 
    dcm_lock                    => dcm_lock,
    phy_init_done          	=> phy_init_done,

    DDR3_DQ			=> DDR3_DQ,			
    DDR3_DQS			=> DDR3_DQS,			
    DDR3_DQS_N			=> DDR3_DQS_N,			
    DDR3_A			=> DDR3_A,			
    DDR3_BA			=> DDR3_BA,			
    DDR3_RAS_N			=> DDR3_RAS_N,			
    DDR3_CAS_N			=> DDR3_CAS_N,			
    DDR3_WE_N			=> DDR3_WE_N,			
    DDR3_CS_N			=> DDR3_CS_N,			
    DDR3_ODT			=> DDR3_ODT,			
    DDR3_CKE			=> DDR3_CKE,			
    DDR3_DM			=> DDR3_DM,			
    DDR3_CK			=> DDR3_CK,			
    DDR3_CK_N			=> DDR3_CK_N,
    DDR3_RESET_N		=> DDR3_RESET_N,
    
    mc_miaddrreadytoaccept	=> i_mc_miaddrreadytoaccept,	
    mc_mireaddata		=> i_mc_mireaddata,		
    mc_mireaddataerr		=> i_mc_mireaddataerr,		
    mc_mireaddatavalid		=> i_mc_mireaddatavalid		
    );

end RTL;

