-------------------------------------------------------------------------------
-- Title         : Clock/Trigger Source Module For COB
-- File          : CobTimingSource.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/10/2013
-------------------------------------------------------------------------------
-- Description:
-- Clock & Trigger source module for COB
-- Delivers clock on both DPM clk0 and clk1 lines (GPIO and GTP reference).
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.StdRtlPkg.all;

entity CobTimingSource is
   generic (
      TPD_G        : time    := 1 ns
   );
   port (

      -- Clock and reset
      sysClk                   : in  sl;
      sysClkRst                : in  sl;
      
      -- Opcode information
      timingCode               : in  slv(7 downto 0);
      timingCodeEn             : in  sl;

      -- Timing bus
      dpmClk                   : out slv(2 downto 0)
   );
end CobTimingSource;

architecture STRUCTURE of CobTimingSource is

   -- Local Signals
   signal bitCount : slv(4 downto 0);
   signal txEnable : sl;
   signal outBit   : sl;
   signal codeEn   : sl;
   signal codeVal  : slv(7 downto 0);

begin

   ----------------------------------------
   -- Clock Outputs
   ----------------------------------------

   -- Clock output
   U_Clk0: ODDR
      generic map(
         DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
         INIT         => '0',             -- Initial value for Q port ('1' or '0')
         SRTYPE       => "SYNC"           -- Reset Type ("ASYNC" or "SYNC")
      ) port map (
         Q  => dpmClk(0),  -- 1-bit DDR output
         C  => sysClk,     -- 1-bit clock input
         CE => '1',        -- 1-bit clock enable input
         D1 => '1',        -- 1-bit data input (positive edge)
         D2 => '0',        -- 1-bit data input (negative edge)
         R  => sysClkRst,  -- 1-bit reset input
         S  => '0'         -- 1-bit set input
      );

   -- Clock output
   U_Clk1: ODDR
      generic map(
         DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
         INIT         => '0',             -- Initial value for Q port ('1' or '0')
         SRTYPE       => "SYNC"           -- Reset Type ("ASYNC" or "SYNC")
      ) port map (
         Q  => dpmClk(1),  -- 1-bit DDR output
         C  => sysClk,     -- 1-bit clock input
         CE => '1',        -- 1-bit clock enable input
         D1 => '1',        -- 1-bit data input (positive edge)
         D2 => '0',        -- 1-bit data input (negative edge)
         R  => sysClkRst,  -- 1-bit reset input
         S  => '0'         -- 1-bit set input
      );


   ----------------------------------------
   -- Sync Data Generator
   ----------------------------------------
   process ( sysClk, sysClkRst ) begin
      if sysClkRst = '1' then
         bitCount <= (others=>'0') after TPD_G;
         txEnable <= '0'           after TPD_G;
         outBit   <= '0'           after TPD_G;
         codeEn   <= '0'           after TPD_G;
         codeVal  <= (others=>'0') after TPD_G;
      elsif rising_edge(sysClk) begin

         -- Sample incoming data when idle
         if txEnable = '0' then
            codeVal <= timingCode after TPD_G;
         end if;

         -- Pass enable when idle
         codeEn <= timingCodeEn and (not codeEn) after TPD_G;

         -- Start new transmission, bit = '0'
         if codeEn = '1' then
            bitCount <= x"01" after TPD_G;
            outBit   <= '1'   after TPD_G;
            txMode   <= '1'   after TPD_G;

         -- In transmission
         elsif txMode = '1' then
            bitCount <= bitCount + 1 after TPD_G;

            -- Preamble 0-3
            if bitCount < 4 then
               outBit <= '0' after TPD_G;

            -- Preamble 4-7
            elsif bitCount < 8 then
               outBit <= '1' after TPD_G;

            -- Regular Bit
            elsif bitCount(0) = '0' then
               outBit <= codeVal(conv_integer(bitCount(4 downto 0))) after TPD_G;

            -- Inverted Bit
            else
               outBit <= not codeVal(conv_integer(bitCount(4 downto 0))) after TPD_G;
            end if;

            -- Done at 23
            if bitCount = 23 then
               txMode <= '0' after TPD_G;
            end if;

         -- Idle 
         else 
            outBit <= bitCount(0) after TPD_G;
         end if;

      end if;
   end process;

   ----------------------------------------
   -- Output Register
   ----------------------------------------
   process ( sysClk, sysClkRst ) begin
      if sysClkRst = '1' then
         dpmClk(2) <= '0'    after TPD_G;
      elsif rising_edge(sysClk) begin
         dpmClk(2) <= outBit after TPD_G;
      end if;
   end process;

end architecture STRUCTURE;

