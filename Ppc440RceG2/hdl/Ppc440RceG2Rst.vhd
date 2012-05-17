

library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library Unisim;
use Unisim.vcomponents.all;

entity Ppc440RceG2Rst is
   port (

      -- Inputs
      syncClk                    : in std_logic;
      asyncReset                 : in std_logic;
      pllLocked                  : in std_logic;

      -- Output
      syncReset                  : out std_logic
   );
end Ppc440RceG2Rst;

architecture STRUCTURE of Ppc440RceG2Rst is

   -- Local signals
   signal syncRstIn  : std_logic_vector(2 downto 0);
   signal rstCnt     : std_logic_vector(4 downto 0);

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   process ( syncClk, asyncReset ) begin
      if asyncReset = '1' then
         syncRstIn <= (others=>'0') after tpd;
         rstCnt    <= (others=>'1') after tpd;
         syncReset <= '1'           after tpd;
      elsif rising_edge(syncClk) then

         syncRstIn(0) <= pllLocked    after tpd;
         syncRstIn(1) <= syncRstIn(0) after tpd;
         syncRstIn(2) <= syncRstIn(1) after tpd;

         if syncRstIn(2) = '0' then
            rstCnt    <= (others=>'1') after tpd;
            syncReset <= '1' after tpd;

         elsif rstCnt = 0 then
            syncReset <= '0' after tpd;

         else
            syncReset <= '1'        after tpd;
            rstCnt    <= rstCnt - 1 after tpd;
         end if;
      end if;
   end process;

end architecture STRUCTURE;

