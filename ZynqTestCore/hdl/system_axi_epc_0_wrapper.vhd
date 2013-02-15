-------------------------------------------------------------------------------
-- system_axi_epc_0_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library axi_epc_v1_00_a;
use axi_epc_v1_00_a.all;

entity system_axi_epc_0_wrapper is
  port (
    S_AXI_ACLK : in std_logic;
    S_AXI_ARESETN : in std_logic;
    S_AXI_AWADDR : in std_logic_vector(31 downto 0);
    S_AXI_AWVALID : in std_logic;
    S_AXI_AWREADY : out std_logic;
    S_AXI_WDATA : in std_logic_vector(31 downto 0);
    S_AXI_WSTRB : in std_logic_vector(3 downto 0);
    S_AXI_WVALID : in std_logic;
    S_AXI_WREADY : out std_logic;
    S_AXI_BRESP : out std_logic_vector(1 downto 0);
    S_AXI_BVALID : out std_logic;
    S_AXI_BREADY : in std_logic;
    S_AXI_ARADDR : in std_logic_vector(31 downto 0);
    S_AXI_ARVALID : in std_logic;
    S_AXI_ARREADY : out std_logic;
    S_AXI_RDATA : out std_logic_vector(31 downto 0);
    S_AXI_RRESP : out std_logic_vector(1 downto 0);
    S_AXI_RVALID : out std_logic;
    S_AXI_RREADY : in std_logic;
    PRH_Clk : in std_logic;
    PRH_Rst : in std_logic;
    PRH_CS_n : out std_logic_vector(0 to 0);
    PRH_Addr : out std_logic_vector(0 to 31);
    PRH_ADS : out std_logic;
    PRH_BE : out std_logic_vector(0 to 3);
    PRH_RNW : out std_logic;
    PRH_Rd_n : out std_logic;
    PRH_Wr_n : out std_logic;
    PRH_Burst : out std_logic;
    PRH_Rdy : in std_logic_vector(0 to 0);
    PRH_Data_I : in std_logic_vector(0 to 31);
    PRH_Data_O : out std_logic_vector(0 to 31);
    PRH_Data_T : out std_logic_vector(0 to 31)
  );

  attribute x_core_info : STRING;
  attribute x_core_info of system_axi_epc_0_wrapper : entity is "axi_epc_v1_00_a";

end system_axi_epc_0_wrapper;

architecture STRUCTURE of system_axi_epc_0_wrapper is

  component axi_epc is
    generic (
      C_S_AXI_CLK_PERIOD_PS : INTEGER;
      C_PRH_CLK_PERIOD_PS : INTEGER;
      C_FAMILY : STRING;
      C_INSTANCE : STRING;
      C_S_AXI_ADDR_WIDTH : INTEGER;
      C_S_AXI_DATA_WIDTH : INTEGER;
      C_NUM_PERIPHERALS : INTEGER;
      C_PRH_MAX_AWIDTH : INTEGER;
      C_PRH_MAX_DWIDTH : INTEGER;
      C_PRH_MAX_ADWIDTH : INTEGER;
      C_PRH_CLK_SUPPORT : INTEGER;
      C_PRH_BURST_SUPPORT : INTEGER;
      C_PRH0_BASEADDR : std_logic_vector;
      C_PRH0_HIGHADDR : std_logic_vector;
      C_PRH0_FIFO_ACCESS : INTEGER;
      C_PRH0_FIFO_OFFSET : INTEGER;
      C_PRH0_AWIDTH : INTEGER;
      C_PRH0_DWIDTH : INTEGER;
      C_PRH0_DWIDTH_MATCH : INTEGER;
      C_PRH0_SYNC : INTEGER;
      C_PRH0_BUS_MULTIPLEX : INTEGER;
      C_PRH0_ADDR_TSU : INTEGER;
      C_PRH0_ADDR_TH : INTEGER;
      C_PRH0_ADS_WIDTH : INTEGER;
      C_PRH0_CSN_TSU : INTEGER;
      C_PRH0_CSN_TH : INTEGER;
      C_PRH0_WRN_WIDTH : INTEGER;
      C_PRH0_WR_CYCLE : INTEGER;
      C_PRH0_DATA_TSU : INTEGER;
      C_PRH0_DATA_TH : INTEGER;
      C_PRH0_RDN_WIDTH : INTEGER;
      C_PRH0_RD_CYCLE : INTEGER;
      C_PRH0_DATA_TOUT : INTEGER;
      C_PRH0_DATA_TINV : INTEGER;
      C_PRH0_RDY_TOUT : INTEGER;
      C_PRH0_RDY_WIDTH : INTEGER;
      C_PRH1_BASEADDR : std_logic_vector;
      C_PRH1_HIGHADDR : std_logic_vector;
      C_PRH1_FIFO_ACCESS : INTEGER;
      C_PRH1_FIFO_OFFSET : INTEGER;
      C_PRH1_AWIDTH : INTEGER;
      C_PRH1_DWIDTH : INTEGER;
      C_PRH1_DWIDTH_MATCH : INTEGER;
      C_PRH1_SYNC : INTEGER;
      C_PRH1_BUS_MULTIPLEX : INTEGER;
      C_PRH1_ADDR_TSU : INTEGER;
      C_PRH1_ADDR_TH : INTEGER;
      C_PRH1_ADS_WIDTH : INTEGER;
      C_PRH1_CSN_TSU : INTEGER;
      C_PRH1_CSN_TH : INTEGER;
      C_PRH1_WRN_WIDTH : INTEGER;
      C_PRH1_WR_CYCLE : INTEGER;
      C_PRH1_DATA_TSU : INTEGER;
      C_PRH1_DATA_TH : INTEGER;
      C_PRH1_RDN_WIDTH : INTEGER;
      C_PRH1_RD_CYCLE : INTEGER;
      C_PRH1_DATA_TOUT : INTEGER;
      C_PRH1_DATA_TINV : INTEGER;
      C_PRH1_RDY_TOUT : INTEGER;
      C_PRH1_RDY_WIDTH : INTEGER;
      C_PRH2_BASEADDR : std_logic_vector;
      C_PRH2_HIGHADDR : std_logic_vector;
      C_PRH2_FIFO_ACCESS : INTEGER;
      C_PRH2_FIFO_OFFSET : INTEGER;
      C_PRH2_AWIDTH : INTEGER;
      C_PRH2_DWIDTH : INTEGER;
      C_PRH2_DWIDTH_MATCH : INTEGER;
      C_PRH2_SYNC : INTEGER;
      C_PRH2_BUS_MULTIPLEX : INTEGER;
      C_PRH2_ADDR_TSU : INTEGER;
      C_PRH2_ADDR_TH : INTEGER;
      C_PRH2_ADS_WIDTH : INTEGER;
      C_PRH2_CSN_TSU : INTEGER;
      C_PRH2_CSN_TH : INTEGER;
      C_PRH2_WRN_WIDTH : INTEGER;
      C_PRH2_WR_CYCLE : INTEGER;
      C_PRH2_DATA_TSU : INTEGER;
      C_PRH2_DATA_TH : INTEGER;
      C_PRH2_RDN_WIDTH : INTEGER;
      C_PRH2_RD_CYCLE : INTEGER;
      C_PRH2_DATA_TOUT : INTEGER;
      C_PRH2_DATA_TINV : INTEGER;
      C_PRH2_RDY_TOUT : INTEGER;
      C_PRH2_RDY_WIDTH : INTEGER;
      C_PRH3_BASEADDR : std_logic_vector;
      C_PRH3_HIGHADDR : std_logic_vector;
      C_PRH3_FIFO_ACCESS : INTEGER;
      C_PRH3_FIFO_OFFSET : INTEGER;
      C_PRH3_AWIDTH : INTEGER;
      C_PRH3_DWIDTH : INTEGER;
      C_PRH3_DWIDTH_MATCH : INTEGER;
      C_PRH3_SYNC : INTEGER;
      C_PRH3_BUS_MULTIPLEX : INTEGER;
      C_PRH3_ADDR_TSU : INTEGER;
      C_PRH3_ADDR_TH : INTEGER;
      C_PRH3_ADS_WIDTH : INTEGER;
      C_PRH3_CSN_TSU : INTEGER;
      C_PRH3_CSN_TH : INTEGER;
      C_PRH3_WRN_WIDTH : INTEGER;
      C_PRH3_WR_CYCLE : INTEGER;
      C_PRH3_DATA_TSU : INTEGER;
      C_PRH3_DATA_TH : INTEGER;
      C_PRH3_RDN_WIDTH : INTEGER;
      C_PRH3_RD_CYCLE : INTEGER;
      C_PRH3_DATA_TOUT : INTEGER;
      C_PRH3_DATA_TINV : INTEGER;
      C_PRH3_RDY_TOUT : INTEGER;
      C_PRH3_RDY_WIDTH : INTEGER
    );
    port (
      S_AXI_ACLK : in std_logic;
      S_AXI_ARESETN : in std_logic;
      S_AXI_AWADDR : in std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0);
      S_AXI_AWVALID : in std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA : in std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
      S_AXI_WSTRB : in std_logic_vector(((C_S_AXI_DATA_WIDTH/8)-1) downto 0);
      S_AXI_WVALID : in std_logic;
      S_AXI_WREADY : out std_logic;
      S_AXI_BRESP : out std_logic_vector(1 downto 0);
      S_AXI_BVALID : out std_logic;
      S_AXI_BREADY : in std_logic;
      S_AXI_ARADDR : in std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0);
      S_AXI_ARVALID : in std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA : out std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
      S_AXI_RRESP : out std_logic_vector(1 downto 0);
      S_AXI_RVALID : out std_logic;
      S_AXI_RREADY : in std_logic;
      PRH_Clk : in std_logic;
      PRH_Rst : in std_logic;
      PRH_CS_n : out std_logic_vector(0 to (C_NUM_PERIPHERALS-1));
      PRH_Addr : out std_logic_vector(0 to (C_PRH_MAX_AWIDTH-1));
      PRH_ADS : out std_logic;
      PRH_BE : out std_logic_vector(0 to ((C_PRH_MAX_DWIDTH/8)-1));
      PRH_RNW : out std_logic;
      PRH_Rd_n : out std_logic;
      PRH_Wr_n : out std_logic;
      PRH_Burst : out std_logic;
      PRH_Rdy : in std_logic_vector(0 to (C_NUM_PERIPHERALS-1));
      PRH_Data_I : in std_logic_vector(0 to (C_PRH_MAX_ADWIDTH-1));
      PRH_Data_O : out std_logic_vector(0 to (C_PRH_MAX_ADWIDTH-1));
      PRH_Data_T : out std_logic_vector(0 to (C_PRH_MAX_ADWIDTH-1))
    );
  end component;

begin

  axi_epc_0 : axi_epc
    generic map (
      C_S_AXI_CLK_PERIOD_PS => 10000,
      C_PRH_CLK_PERIOD_PS => 20000,
      C_FAMILY => "zynq",
      C_INSTANCE => "axi_epc_0",
      C_S_AXI_ADDR_WIDTH => 32,
      C_S_AXI_DATA_WIDTH => 32,
      C_NUM_PERIPHERALS => 1,
      C_PRH_MAX_AWIDTH => 32,
      C_PRH_MAX_DWIDTH => 32,
      C_PRH_MAX_ADWIDTH => 32,
      C_PRH_CLK_SUPPORT => 0,
      C_PRH_BURST_SUPPORT => 0,
      C_PRH0_BASEADDR => X"80070000",
      C_PRH0_HIGHADDR => X"8007ffff",
      C_PRH0_FIFO_ACCESS => 0,
      C_PRH0_FIFO_OFFSET => 0,
      C_PRH0_AWIDTH => 32,
      C_PRH0_DWIDTH => 32,
      C_PRH0_DWIDTH_MATCH => 0,
      C_PRH0_SYNC => 1,
      C_PRH0_BUS_MULTIPLEX => 0,
      C_PRH0_ADDR_TSU => 0,
      C_PRH0_ADDR_TH => 0,
      C_PRH0_ADS_WIDTH => 0,
      C_PRH0_CSN_TSU => 0,
      C_PRH0_CSN_TH => 0,
      C_PRH0_WRN_WIDTH => 0,
      C_PRH0_WR_CYCLE => 0,
      C_PRH0_DATA_TSU => 0,
      C_PRH0_DATA_TH => 0,
      C_PRH0_RDN_WIDTH => 0,
      C_PRH0_RD_CYCLE => 0,
      C_PRH0_DATA_TOUT => 0,
      C_PRH0_DATA_TINV => 0,
      C_PRH0_RDY_TOUT => 10000000,
      C_PRH0_RDY_WIDTH => 20000000,
      C_PRH1_BASEADDR => X"ffffffff",
      C_PRH1_HIGHADDR => X"00000000",
      C_PRH1_FIFO_ACCESS => 0,
      C_PRH1_FIFO_OFFSET => 0,
      C_PRH1_AWIDTH => 32,
      C_PRH1_DWIDTH => 32,
      C_PRH1_DWIDTH_MATCH => 0,
      C_PRH1_SYNC => 1,
      C_PRH1_BUS_MULTIPLEX => 0,
      C_PRH1_ADDR_TSU => 0,
      C_PRH1_ADDR_TH => 0,
      C_PRH1_ADS_WIDTH => 0,
      C_PRH1_CSN_TSU => 0,
      C_PRH1_CSN_TH => 0,
      C_PRH1_WRN_WIDTH => 0,
      C_PRH1_WR_CYCLE => 0,
      C_PRH1_DATA_TSU => 0,
      C_PRH1_DATA_TH => 0,
      C_PRH1_RDN_WIDTH => 0,
      C_PRH1_RD_CYCLE => 0,
      C_PRH1_DATA_TOUT => 0,
      C_PRH1_DATA_TINV => 0,
      C_PRH1_RDY_TOUT => 0,
      C_PRH1_RDY_WIDTH => 0,
      C_PRH2_BASEADDR => X"ffffffff",
      C_PRH2_HIGHADDR => X"00000000",
      C_PRH2_FIFO_ACCESS => 0,
      C_PRH2_FIFO_OFFSET => 0,
      C_PRH2_AWIDTH => 32,
      C_PRH2_DWIDTH => 32,
      C_PRH2_DWIDTH_MATCH => 0,
      C_PRH2_SYNC => 1,
      C_PRH2_BUS_MULTIPLEX => 0,
      C_PRH2_ADDR_TSU => 0,
      C_PRH2_ADDR_TH => 0,
      C_PRH2_ADS_WIDTH => 0,
      C_PRH2_CSN_TSU => 0,
      C_PRH2_CSN_TH => 0,
      C_PRH2_WRN_WIDTH => 0,
      C_PRH2_WR_CYCLE => 0,
      C_PRH2_DATA_TSU => 0,
      C_PRH2_DATA_TH => 0,
      C_PRH2_RDN_WIDTH => 0,
      C_PRH2_RD_CYCLE => 0,
      C_PRH2_DATA_TOUT => 0,
      C_PRH2_DATA_TINV => 0,
      C_PRH2_RDY_TOUT => 0,
      C_PRH2_RDY_WIDTH => 0,
      C_PRH3_BASEADDR => X"ffffffff",
      C_PRH3_HIGHADDR => X"00000000",
      C_PRH3_FIFO_ACCESS => 0,
      C_PRH3_FIFO_OFFSET => 0,
      C_PRH3_AWIDTH => 32,
      C_PRH3_DWIDTH => 32,
      C_PRH3_DWIDTH_MATCH => 0,
      C_PRH3_SYNC => 1,
      C_PRH3_BUS_MULTIPLEX => 0,
      C_PRH3_ADDR_TSU => 0,
      C_PRH3_ADDR_TH => 0,
      C_PRH3_ADS_WIDTH => 0,
      C_PRH3_CSN_TSU => 0,
      C_PRH3_CSN_TH => 0,
      C_PRH3_WRN_WIDTH => 0,
      C_PRH3_WR_CYCLE => 0,
      C_PRH3_DATA_TSU => 0,
      C_PRH3_DATA_TH => 0,
      C_PRH3_RDN_WIDTH => 0,
      C_PRH3_RD_CYCLE => 0,
      C_PRH3_DATA_TOUT => 0,
      C_PRH3_DATA_TINV => 0,
      C_PRH3_RDY_TOUT => 0,
      C_PRH3_RDY_WIDTH => 0
    )
    port map (
      S_AXI_ACLK => S_AXI_ACLK,
      S_AXI_ARESETN => S_AXI_ARESETN,
      S_AXI_AWADDR => S_AXI_AWADDR,
      S_AXI_AWVALID => S_AXI_AWVALID,
      S_AXI_AWREADY => S_AXI_AWREADY,
      S_AXI_WDATA => S_AXI_WDATA,
      S_AXI_WSTRB => S_AXI_WSTRB,
      S_AXI_WVALID => S_AXI_WVALID,
      S_AXI_WREADY => S_AXI_WREADY,
      S_AXI_BRESP => S_AXI_BRESP,
      S_AXI_BVALID => S_AXI_BVALID,
      S_AXI_BREADY => S_AXI_BREADY,
      S_AXI_ARADDR => S_AXI_ARADDR,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_RDATA => S_AXI_RDATA,
      S_AXI_RRESP => S_AXI_RRESP,
      S_AXI_RVALID => S_AXI_RVALID,
      S_AXI_RREADY => S_AXI_RREADY,
      PRH_Clk => PRH_Clk,
      PRH_Rst => PRH_Rst,
      PRH_CS_n => PRH_CS_n,
      PRH_Addr => PRH_Addr,
      PRH_ADS => PRH_ADS,
      PRH_BE => PRH_BE,
      PRH_RNW => PRH_RNW,
      PRH_Rd_n => PRH_Rd_n,
      PRH_Wr_n => PRH_Wr_n,
      PRH_Burst => PRH_Burst,
      PRH_Rdy => PRH_Rdy,
      PRH_Data_I => PRH_Data_I,
      PRH_Data_O => PRH_Data_O,
      PRH_Data_T => PRH_Data_T
    );

end architecture STRUCTURE;

