-------------------------------------------------------------------------------
-- Title         : Trigger Source Module For COB
-- File          : CobOpCodeSource.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/10/2013
-------------------------------------------------------------------------------
-- Description:
-- OpCode source module for COB
-- Delivers encoded 8-bit opcode on DPM clk2 line. Opcode is synchronous to the
-- rising edge of clk. 
--
-- OpCode Pattern:
-- Bit   : 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23
-- Value :  0  0  0  0  1  1  1  1 B0 I0 B1 I1 B2 I2 B3 I3 B4 I4 B5 I5 B6 I6 B7 I7
--
-- Idle / Training Pattern:
-- Bit   : 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23
-- Value :  0  1  0  1  0  1  0  1  0  1  0  1  0  1  0  1  0  1  0  1  0  1  0  1
--
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/10/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.StdRtlPkg.all;

entity CobOpCodeSource is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clock and reset
      sysClk                   : in  sl;
      sysClkRst                : in  sl;
      
      -- Opcode information
      timingCode               : in  slv(7 downto 0);
      timingCodeEn             : in  sl;

      -- Timing bus
      dpmClk                   : out sl
   );
end CobOpCodeSource;

architecture STRUCTURE of CobOpCodeSource is

   -- Local Signals
   signal txCount  : slv(4 downto 0);
   signal txEnable : sl;
   signal outBit   : sl;
   signal codeEn   : sl;
   signal codeVal  : slv(7 downto 0);

begin

   ----------------------------------------
   -- Sync Data Generator
   ----------------------------------------
   process ( sysClk, sysClkRst ) begin
      if sysClkRst = '1' then
         txCount <= (others=>'0') after TPD_G;
         txEnable <= '0'           after TPD_G;
         outBit   <= '0'           after TPD_G;
         codeEn   <= '0'           after TPD_G;
         codeVal  <= (others=>'0') after TPD_G;
      elsif rising_edge(sysClk) then

         -- Sample incoming data when idle
         if txEnable = '0' and timingCodeEn = '1' then
            codeVal <= timingCode after TPD_G;
         end if;

         -- Pass enable when idle
         codeEn <= timingCodeEn and (not codeEn) after TPD_G;

         -- Setup counter
         if codeEn = '1' then
            txCount <= "00001" after TPD_G;
         else
            txCount <= txCount + 1 after TPD_G;
         end if;

         -- Start new transmission, bit = '0'
         if codeEn = '1' then
            outBit   <= '1'   after TPD_G;
            txEnable <= '1'   after TPD_G;

         -- In transmission
         elsif txEnable = '1' then

            -- Preamble 0-3
            if txCount < 4 then
               outBit <= '0' after TPD_G;

            -- Preamble 4-7
            elsif txCount < 8 then
               outBit <= '1' after TPD_G;

            -- Regular Bit
            elsif txCount(0) = '0' then
               outBit <= codeVal(conv_integer(txCount(4 downto 0))) after TPD_G;

            -- Inverted Bit
            else
               outBit <= not codeVal(conv_integer(txCount(4 downto 0))) after TPD_G;
            end if;

            -- Done at 23
            if txCount = 23 then
               txEnable <= '0' after TPD_G;
            end if;

         -- Idle 
         else 
            outBit <= txCount(0) after TPD_G;
         end if;

      end if;
   end process;

   ----------------------------------------
   -- Output Register
   ----------------------------------------
   process ( sysClk, sysClkRst ) begin
      if sysClkRst = '1' then
         dpmClk <= '0'    after TPD_G;
      elsif rising_edge(sysClk) then
         dpmClk <= outBit after TPD_G;
      end if;
   end process;

end architecture STRUCTURE;

