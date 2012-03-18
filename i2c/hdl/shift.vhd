-- File:     shift.vhd
-- 
-- Author:   Jennifer Jenkins
--	     Philips Semiconductor
-- Purpose:  Serial in/serial out 8-bit parallel load/out shift 
--           register component definition.  Must have shift_en
--           active to shift or load register.
--
-- Created:  5-3-99 JLJ
-- Revised:  5-5-99 JLJ
	


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity SHIFT8 is
	port(

	     clk          : in STD_LOGIC;    -- Clock
	     clr          : in STD_LOGIC;    -- Clear
	     data_ld      : in STD_LOGIC;    -- Data load enable
	     data_in      : in STD_LOGIC_VECTOR (7 downto 0); -- Data to load in
	     shift_in     : in STD_LOGIC;    -- Serial data in
	     shift_en     : in STD_LOGIC;    -- Shift enable
	     
	     shift_out    : out STD_LOGIC;   -- Shift serial data out
	     data_out     : out STD_LOGIC_VECTOR (7 downto 0)  -- Shifted data
		
	     );
		
end SHIFT8;




architecture DEFINITION of SHIFT8 is

constant RESET_ACTIVE : std_logic := '0';

signal data_int : STD_LOGIC_VECTOR (7 downto 0);

begin

     process(clk, clr)
     begin
          
          -- Clear output register
          if (clr = RESET_ACTIVE) then
	       data_int <= (others => '0');
	       
	  -- On rising edge of clock, shift in data
	  elsif clk'event and clk = '1' then

	       -- Load data
	       if (data_ld = '1') then
		    data_int <= data_in;

	       -- If shift enable is high
	       elsif shift_en = '1' then

		    -- Shift the data
		    data_int <= data_int(6 downto 0) & shift_in;

	       end if;

	  end if;

     end process;
	shift_out <= data_int(7);     
	data_out <= data_int;

end DEFINITION;
  
