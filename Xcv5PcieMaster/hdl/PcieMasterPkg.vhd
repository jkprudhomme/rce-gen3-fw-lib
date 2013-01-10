
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

use work.Ppc440RceG2Pkg.all;

package PcieMasterPkg is

  ----------------------------------
  -- Constants
  ----------------------------------

  ----------------------------------
  -- Types
  ----------------------------------

  ----------------------------------
  -- Records
  ----------------------------------

  ----------------------------------
  -- Components
  ----------------------------------

  component pcie_debug is
    port ( rst             : in  std_logic;
           -- APU Interface
           apuClk          : in  std_logic;
           apuClkRst       : in  std_logic;
           apuReadFromPpc  : in  ApuReadFromPpcType;
           apuReadToPpc    : out ApuReadToPpcType;
           apuWriteFromPpc : in  ApuWriteFromPpcType;
           apuWriteToPpc   : out ApuWriteToPpcType;
           apuLoadToPpc    : in  ApuLoadToPpcType;
           apuLoadFromPpc  : in  ApuLoadFromPpcType;
           apuStoreFromPpc : in  ApuStoreFromPpcType;
           apuStoreToPpc   : out ApuStoreToPpcType;
           -- PCIE Interface
           pcie_clk    : in  std_logic;
           pcie_clkout : out std_logic;
           pcie_rst_n  : out std_logic;
           pcie_tx_p   : out std_logic;
           pcie_tx_n   : out std_logic;
           pcie_rx_p   : in  std_logic;
           pcie_rx_n   : in  std_logic;
           --
           debug       : out std_logic_vector(31 downto 0)
           );
  end component;

end PcieMasterPkg;
