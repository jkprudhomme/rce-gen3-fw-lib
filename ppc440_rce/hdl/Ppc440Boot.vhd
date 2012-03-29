


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


entity Ppc440Boot is
   port (

      -- Clock inputs
      bramClk                   : in  std_logic;
      bramClkRst                : in  std_logic;

      -- MPLB Bus
      plbPpcmMBusy              : out std_logic;
      plbPpcmAddrAck            : out std_logic;
      plbPpcmRdDack             : out std_logic;
      plbPpcmRdDbus             : out std_logic(0 to 127);
      plbPpcmRdWdAddr           : out std_logic(0 to 3);
      plbPpcmTimeout            : out std_logic;
      plbPpcmWrDack             : out std_logic;
      ppcMplbAbus               : in  std_logic(0 to 31);
      ppcMplbBe                 : in  std_logic;
      ppcMplbRequest            : in  std_logic;
      ppcMplbRnW                : in  std_logic;
      ppcMplbSize               : in  std_logic(0 to 1);
      ppcMplbWrDBus             : in  std_logic(0 to 127)
   );
end Ppc440Boot;

architecture behavioral of Ppc440Boot is

   -- Boot Ram
   component Ppc440BootBram 
      port (
         bramRstA  : in  std_logic;
         bramClkA  : in  std_logic;
         bramEnA   : in  std_logic;
         bramWenA  : in  std_logic_vector(0 to 7);
         bramAddrA : in  std_logic_vector(0 to 31);
         bramDinA  : out std_logic_vector(0 to 63);
         bramDoutA : in  std_logic_vector(0 to 63);
         bramRstB  : in  std_logic;
         bramClkB  : in  std_logic;
         bramEnB   : in  std_logic;
         bramWenB  : in  std_logic_vector(0 to 7);
         bramAddrB : in  std_logic_vector(0 to 31);
         bramDinB  : out std_logic_vector(0 to 63);
         bramDoutB : in  std_logic_vector(0 to 63)
      );

   -- Signals
   signal bramEnA   : std_logic;
   signal bramWenA  : std_logic_vector(0 to 7);
   signal bramAddrA : std_logic_vector(0 to 31);
   signal bramDinA  : std_logic_vector(0 to 63);
   signal bramDoutA : std_logic_vector(0 to 63);

   -- States
   constant ST_IDLE      : std_logic_vector(1 downto 0) := "01";
   constant ST_ADDR      : std_logic_vector(1 downto 0) := "10";
   constant ST_TAIL      : std_logic_vector(1 downto 0) := "11";
   signal   curState     : std_logic_vector(1 downto 0);
   signal   nxtState     : std_logic_vector(1 downto 0);

begin


   -- Sync state logic
   process (bramClk, bramClkRst ) begin
      if bramClkRst = '1' then

         curState <= ST_IDLE after tpd;
      elsif rising_edge(bramClk) then


         curState <= nxtState after tpd;

      end if;
   end process;

   -- ASync state logic
   process (curState ) begin
      case curState is 

         -- Idle. Wait for data
         when ST_IDLE =>



         when others =>


      end case;
   end process;
















   -- Boot RAM
   U_Ppc440BootBram : Ppc440BootBram 
      port map (
         bramRstA  => bramClkRst,
         bramClkA  => bramClk,
         bramEnA   => bramEnA,
         bramWenA  => bramWenA,
         bramAddrA => bramAddrA,
         bramDinA  => bramDinA,
         bramDoutA => bramDoutA,
         bramRstB  => '0',
         bramClkB  => '0',
         bramEnB   => '0',
         bramWenB  => '0',
         bramAddrB => (others=>'0'),
         bramDinB  => (others=>'0'),
         bramDoutB => open
      );

end Ppc440Boot;

