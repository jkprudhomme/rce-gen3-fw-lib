-------------------------------------------------------------------------------
-- Title         : Trigger Source Module For COB, 10-bit data version
-- File          : CobDataSource10b.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 08/29/2014
-------------------------------------------------------------------------------
-- Description:
-- Serial data source module for COB
-- Delivers encoded 10-bit (data + control) on DPM lines. 
-- Data is synchronous to the rising edge of clk. 
-- Recomended use of 10-bit data is:
-- Bits 7:0 = Data
-- Bits 9:8 = Type, 0 = OpCode, 1 = Echo, 2 = Data, 3 = Data EOF
--
-- Transmit Data Pattern:
-- Bit   : 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
-- Value :  1  1  0  0 B0 B1 B2 B3 B4 B5 B6 B7 B8 B9  P  P (parity sent twice)
--
-- Idle / Training Pattern:
-- Bit   : 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
-- Value :  0  1  0  1  0  1  0  1  0  1  0  1  0  1  0  1
--
-------------------------------------------------------------------------------
-- Copyright (c) 2014 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 08/29/2014: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.StdRtlPkg.all;

entity CobDataSource10b is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clock and reset
      distClk                  : in  sl;
      distClkRst               : in  sl;
      
      -- Opcode information
      txData                   : in  slv(9 downto 0);
      txDataEn                 : in  sl;
      txReady                  : out sl;

      -- Serial Bus 
      serialData               : out sl
   );
end CobDataSource10b;

architecture STRUCTURE of CobDataSource10b is

   -- Local Signals
   signal txCount  : slv(3 downto 0);
   signal txEnable : sl;
   signal outBit   : sl;
   signal codeVal  : slv(15 downto 0);

begin

   txReady <= not txEnable;

   ----------------------------------------
   -- Sync Data Generator
   ----------------------------------------
   process ( distClk ) begin
      if rising_edge(distClk) then
         if distClkRst = '1' then
            txCount <= (others=>'0')  after TPD_G;
            txEnable <= '0'           after TPD_G;
            outBit   <= '0'           after TPD_G;
            codeVal  <= (others=>'0') after TPD_G;
         else

            -- Sample incoming data when idle, start transmit
            if txEnable = '0' and txDataEn = '1' then
               codeVal(3  downto 0) <= "0011"            after TPD_G;
               codeVal(13 downto 4) <= txData            after TPD_G;
               codeVal(14)          <= oddParity(txData) after TPD_G;
               codeVal(15)          <= oddParity(txData) after TPD_G;
               txCount              <= "0001"            after TPD_G;
               outBit               <= '1'               after TPD_G;
               txEnable             <= '1'               after TPD_G;
            else

               txCount <= txCount + 1 after TPD_G;

               -- In transmission
               if txEnable = '1' then
                  outBit <= codeVal(conv_integer(txCount)) after TPD_G;

                  -- Done at 15
                  if txCount = 15 then
                     txEnable <= '0' after TPD_G;
                  end if;

               -- Idle 
               else 
                  outBit <= txCount(0) after TPD_G;
               end if;
            end if;
         end if;
      end if;
   end process;

   ----------------------------------------
   -- Output Register
   ----------------------------------------
   process ( distClk ) begin
      if rising_edge(distClk) then
         if distClkRst = '1' then
            serialData <= '0'    after TPD_G;
         else
            serialData <= outBit after TPD_G;
         end if;
      end if;
   end process;

end architecture STRUCTURE;

