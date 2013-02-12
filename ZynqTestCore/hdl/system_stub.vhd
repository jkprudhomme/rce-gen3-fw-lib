-------------------------------------------------------------------------------
-- system_stub.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity system_stub is
  port (
    ps7_0_PS_SRSTB_pin : in std_logic;
    ps7_0_PS_CLK_pin : in std_logic;
    ps7_0_PS_PORB_pin : in std_logic;
    fmc_imageon_iic_Sda_pin : inout std_logic;
    fmc_imageon_iic_Scl_pin : inout std_logic;
    axi_epc_0_PRH_CS_n_pin : out std_logic;
    axi_epc_0_PRH_Addr_pin : out std_logic_vector(0 to 31);
    axi_epc_0_PRH_ADS_pin : out std_logic;
    axi_epc_0_PRH_BE_pin : out std_logic_vector(0 to 3);
    axi_epc_0_PRH_RNW_pin : out std_logic;
    axi_epc_0_PRH_Rd_n_pin : out std_logic;
    axi_epc_0_PRH_Wr_n_pin : out std_logic;
    axi_epc_0_PRH_Burst_pin : out std_logic;
    axi_epc_0_PRH_Rdy_pin : in std_logic;
    axi_epc_0_PRH_Data_I_pin : in std_logic_vector(0 to 31);
    axi_epc_0_PRH_Data_O_pin : out std_logic_vector(0 to 31);
    axi_epc_0_PRH_Clk_pin : in std_logic;
    axi_epc_0_PRH_Rst_pin : in std_logic
  );
end system_stub;

architecture STRUCTURE of system_stub is

  component system is
    port (
      ps7_0_PS_SRSTB_pin : in std_logic;
      ps7_0_PS_CLK_pin : in std_logic;
      ps7_0_PS_PORB_pin : in std_logic;
      fmc_imageon_iic_Sda_pin : inout std_logic;
      fmc_imageon_iic_Scl_pin : inout std_logic;
      axi_epc_0_PRH_CS_n_pin : out std_logic;
      axi_epc_0_PRH_Addr_pin : out std_logic_vector(0 to 31);
      axi_epc_0_PRH_ADS_pin : out std_logic;
      axi_epc_0_PRH_BE_pin : out std_logic_vector(0 to 3);
      axi_epc_0_PRH_RNW_pin : out std_logic;
      axi_epc_0_PRH_Rd_n_pin : out std_logic;
      axi_epc_0_PRH_Wr_n_pin : out std_logic;
      axi_epc_0_PRH_Burst_pin : out std_logic;
      axi_epc_0_PRH_Rdy_pin : in std_logic;
      axi_epc_0_PRH_Data_I_pin : in std_logic_vector(0 to 31);
      axi_epc_0_PRH_Data_O_pin : out std_logic_vector(0 to 31);
      axi_epc_0_PRH_Clk_pin : in std_logic;
      axi_epc_0_PRH_Rst_pin : in std_logic
    );
  end component;

  attribute BOX_TYPE : STRING;
  attribute BOX_TYPE of system : component is "user_black_box";

begin

  system_i : system
    port map (
      ps7_0_PS_SRSTB_pin => ps7_0_PS_SRSTB_pin,
      ps7_0_PS_CLK_pin => ps7_0_PS_CLK_pin,
      ps7_0_PS_PORB_pin => ps7_0_PS_PORB_pin,
      fmc_imageon_iic_Sda_pin => fmc_imageon_iic_Sda_pin,
      fmc_imageon_iic_Scl_pin => fmc_imageon_iic_Scl_pin,
      axi_epc_0_PRH_CS_n_pin => axi_epc_0_PRH_CS_n_pin,
      axi_epc_0_PRH_Addr_pin => axi_epc_0_PRH_Addr_pin,
      axi_epc_0_PRH_ADS_pin => axi_epc_0_PRH_ADS_pin,
      axi_epc_0_PRH_BE_pin => axi_epc_0_PRH_BE_pin,
      axi_epc_0_PRH_RNW_pin => axi_epc_0_PRH_RNW_pin,
      axi_epc_0_PRH_Rd_n_pin => axi_epc_0_PRH_Rd_n_pin,
      axi_epc_0_PRH_Wr_n_pin => axi_epc_0_PRH_Wr_n_pin,
      axi_epc_0_PRH_Burst_pin => axi_epc_0_PRH_Burst_pin,
      axi_epc_0_PRH_Rdy_pin => axi_epc_0_PRH_Rdy_pin,
      axi_epc_0_PRH_Data_I_pin => axi_epc_0_PRH_Data_I_pin,
      axi_epc_0_PRH_Data_O_pin => axi_epc_0_PRH_Data_O_pin,
      axi_epc_0_PRH_Clk_pin => axi_epc_0_PRH_Clk_pin,
      axi_epc_0_PRH_Rst_pin => axi_epc_0_PRH_Rst_pin
    );

end architecture STRUCTURE;

