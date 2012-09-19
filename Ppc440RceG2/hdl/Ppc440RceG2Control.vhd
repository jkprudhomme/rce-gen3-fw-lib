
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.Ppc440RceG2Pkg.all;

entity Ppc440RceG2Control is
  port (

    -- Clock & Reset Inputs
    apuClk                     : in  std_logic;
    apuClkRst                  : in  std_logic;

    -- APU Interface
    apuReadFromPpc             : in  ApuReadFromPpcType;
    apuReadToPpc               : out ApuReadToPpcType;

    -- Write instructions
    apuWriteFromPpc            : in  ApuWriteFromPpcType;
    apuWriteToPpc              : out ApuWriteToPpcType;

    -- Reset
    apuReset                   : out std_logic_vector(0 to 31);

    -- Full/Empty Bits
    apuWriteFull               : in  std_logic_vector(0 to 7);
    apuReadEmpty               : in  std_logic_vector(0 to 7);
    apuLoadFull                : in  std_logic_vector(0 to 31);
    apuStoreEmpty              : in  std_logic_vector(0 to 31)
  );
end Ppc440RceG2Control;

architecture structure of Ppc440RceG2Control is

  -- Local signals

  -- Register delay for simulation
  constant tpd:time := 0.5 ns;

begin

   apuReadToPpc  <= ApuReadToPpcInit;
   apuWriteToPpc <= ApuWriteToPpcInit;
   apuReset      <= (others=>'0');
   --apuWriteFull                : std_logic_vector(0 to 7);
   --apuReadEmpty                : std_logic_vector(0 to 7);
   --apuLoadFull                 : std_logic_vector(0 to 31);
   --apuStoreEmpty               : std_logic_vector(0 to 31)

end architecture;

