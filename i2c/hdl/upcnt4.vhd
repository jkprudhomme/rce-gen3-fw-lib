-- File:     upcnt4.vhd
-- 
-- Author:   Jennifer Jenkins
--	     Philips Semiconductor
-- Purpose:  Up 4-bit counter
--
-- Created:  5-3-99 JLJ
-- Revised:  6-15-99 ALS
	


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity upcnt4 is
	port(
	      
	     data         : in STD_LOGIC_VECTOR (3 downto 0);    -- Serial data in
	     cnt_en       : in STD_LOGIC;                        -- Count enable
	     load         : in STD_LOGIC;                        -- Load line enable
 	     clr          : in STD_LOGIC;                        -- Active low clear
	     clk          : in STD_LOGIC;                        -- Clock
	     qout         : inout STD_LOGIC_VECTOR (3 downto 0)
		
	     );
		
end upcnt4;



architecture DEFINITION of upcnt4 is

constant RESET_ACTIVE : std_logic := '0';

signal q_int : UNSIGNED (3 downto 0);

begin

     process(clk, clr)
     begin
          
          -- Clear output register
          if (clr = RESET_ACTIVE) then
	       q_int <= (others => '0');
	       
	  -- On falling edge of clock count
	  elsif (clk'event) and clk = '1' then

	       -- Load in start value
	       if (load = '1') then
		    q_int <= UNSIGNED(data);
	       -- If count enable is high
	       elsif cnt_en = '1' then
		    q_int <= q_int + 1;
	       end if;
	  end if;

     end process;

     qout <= STD_LOGIC_VECTOR(q_int);

end DEFINITION;
  

