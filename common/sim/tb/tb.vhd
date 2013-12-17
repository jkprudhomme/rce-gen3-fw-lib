LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
Library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;

entity tb is end tb;

-- Define architecture
architecture tb of tb is

   signal dpmClk                   : sl;
   signal sysClk                   : sl;
   signal sysClkRst                : sl;
   signal sinkCode                 : slv(7 downto 0);
   signal sinkCodeEn               : sl;
   signal statusIdleCnt            : slv(15 downto 0);
   signal statusErrorCnt           : slv(15 downto 0);
   signal sourceCode               : slv(7 downto 0);
   signal sourceCodeEn             : sl;
   signal sourceCount              : slv(11 downto 0);

begin

   process begin
      sysClk <= '1';
      wait for 2.5 ns;
      sysClk <= '0';
      wait for 2.5 ns;
   end process;

   process begin
      sysClkRst <= '1';
      wait for (50 ns);
      sysClkRst <= '0';
      wait;
   end process;

   process (sysClk, sysClkRst ) begin
      if sysClkRst = '1' then
         sourceCount  <= (others=>'0') after 1 ns;
         sourceCode   <= (others=>'0') after 1 ns;
         sourceCodeEn <= '0'           after 1 ns;
      elsif rising_edge(sysClk) then
         sourceCount <= sourceCount + 1 after 1 ns;

         if sourceCount = x"FFF" then
            sourceCode   <= sourceCode + 1 after 1 ns;
            sourceCodeEn <= '1'            after 1 ns;
         else
            sourceCodeEn <= '0'            after 1 ns;
         end if;

      end if;
   end process;


   U_Source : entity work.CobOpCodeSource
      generic map (
         TPD_G => 1 ns
      ) port map (
         sysClk                    => sysClk,
         sysClkRst                 => sysClkRst,
         timingCode                => sourceCode,
         timingCodeEn              => sourceCodeEn,
         dpmClk                    => dpmClk
      );

   U_Sink : entity work.CobOpCodeSink 
      generic map (
         TPD_G => 1 ns
      ) port map (
         dpmClk                    => dpmClk,
         sysClk                    => sysClk,
         sysClkRst                 => sysClkRst,
         timingCode                => sinkCode,
         timingCodeEn              => sinkCodeEn,
         configClk                 => sysClk,
         configClkRst              => sysClkRst,
         configSet                 => '0',
         configDelay               => (others=>'0'),
         statusIdleCnt             => statusIdleCnt,
         statusErrorCnt            => statusErrorCnt
      );

end tb;

