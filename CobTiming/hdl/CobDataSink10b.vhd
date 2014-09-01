-------------------------------------------------------------------------------
-- Title         : Trigger Sink Module For COB, 10-bit data version
-- File          : CobDataSink10b.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 08/28/2014
-------------------------------------------------------------------------------
-- Description:
-- Serial data sink module for COB
-- Receives encoded 10-bit (data + control) on DPM lines. 
-- Data is synchronous to the rising edge of clk. 
-- Recomended use of 10-bit data is:
-- Bits 7:0 = Data
-- Bits 9:8 = Type, 0 = OpCode, 1 = Echo, 2 = Data, 3 = Data EOF
--
-- Receive Data Pattern:
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

entity CobDataSink10b is
   generic (
      TPD_G           : time   := 1 ns;
      IODELAY_GROUP_G : string := "DtmTimingGrp"
   );
   port (

      -- Serial Input
      serialData               : in  sl;

      -- Timing Clock
      distClk                  : in  sl;
      distClkRst               : in  sl;
      
      -- Opcode information, synchronous to distClk
      rxData                   : out slv(9 downto 0);
      rxDataEn                 : out sl;

      -- Configuration & status information
      configClk                : in  sl;
      configClkRst             : in  sl;
      configSet                : in  sl;
      configDelay              : in  slv(4  downto 0);
      statusIdleCnt            : out slv(15 downto 0);
      statusErrorCnt           : out slv(15 downto 0)
   );
end CobDataSink10b;

architecture STRUCTURE of CobDataSink10b is

   -- Local Signals
   signal delayLd      : sl;
   signal delayValue   : slv(4 downto 0);
   signal inBit        : sl;
   signal shiftReg     : slv(15 downto 0);
   signal intIdleCnt   : slv(15 downto 0);
   signal intErrorCnt  : slv(15 downto 0);
   signal intData      : slv(9 downto 0);
   signal intDataEn    : sl;
   signal intDataErr   : sl;
   signal dataBlockCnt : slv(15 downto 0);
   
   attribute IODELAY_GROUP                    : string;
   attribute IODELAY_GROUP of IDELAYE2_inst : label is IODELAY_GROUP_G;   

begin

   -- Outputs
   rxData         <= intData;
   rxDataEn       <= intDataEn;
   statusErrorCnt <= intErrorCnt;
   statusIdleCnt  <= intIdleCnt;

   ----------------------------------------
   -- Incoming Sync Stream
   ----------------------------------------

   -- Pipeline config values
   process ( configClk, configClkRst ) begin
      if configClkRst = '1' then
         delayLd    <= '0'           after TPD_G;
         delayValue <= (others=>'0') after TPD_G;
      elsif rising_edge(configClk) then
         delayLd    <= configSet     after TPD_G;
         delayValue <= configDelay   after TPD_G;
      end if;
   end process;

   -- Delay line
   IDELAYE2_inst : IDELAYE2
      generic map (
         CINVCTRL_SEL          => "FALSE",    -- Enable dynamic clock inversion (FALSE, TRUE)
         DELAY_SRC             => "IDATAIN",  -- Delay input (IDATAIN, DATAIN)
         HIGH_PERFORMANCE_MODE => "FALSE",    -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
         IDELAY_TYPE           => "VAR_LOAD", -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
         IDELAY_VALUE          => 0,          -- Input delay tap setting (0-31)
         PIPE_SEL              => "FALSE",    -- Select pipelined mode, FALSE, TRUE
         REFCLK_FREQUENCY      => 200.0,      -- IDELAYCTRL clock input frequency in MHz (190.0-210.0).
         SIGNAL_PATTERN        => "DATA"      -- DATA, CLOCK input signal
      )
      port map (
         CNTVALUEOUT => open,        -- 5-bit output: Counter value output
         DATAOUT     => inBit,       -- 1-bit output: Delayed data output
         C           => configClk,   -- 1-bit input: Clock input
         CE          => '0',         -- 1-bit input: Active high enable increment/decrement input
         CINVCTRL    => '0',         -- 1-bit input: Dynamic clock inversion input
         CNTVALUEIN  => delayValue,  -- 5-bit input: Counter value input
         DATAIN      => '0',         -- 1-bit input: Internal delay data input
         IDATAIN     => serialData,  -- 1-bit input: Data input from the I/O
         INC         => '0',         -- 1-bit input: Increment / Decrement tap delay input
         LD          => delayLd,     -- 1-bit input: Load IDELAY_VALUE input
         LDPIPEEN    => '0',         -- 1-bit input: Enable PIPELINE register to load data input
         REGRST      => configClkRst -- 1-bit input: Active-high reset tap-delay input
      );

   ----------------------------------------
   -- Shift Register 
   ----------------------------------------
   process ( distClk ) begin
      if rising_edge(distClk) then
         if distClkRst = '1' then
            shiftReg <= (others=>'0') after TPD_G;
         else

            -- First bit recieved is LSB of pattern
            shiftReg <= inBit & shiftReg(15 downto 1) after TPD_G;
         end if;
      end if;
   end process;


   ----------------------------------------
   -- Idle Detect
   ----------------------------------------
   process ( distClk ) begin
      if rising_edge(distClk) then
         if distClkRst = '1' or delayLd = '1' then
            intIdleCnt    <= (others=>'0') after TPD_G;
         else
            if shiftReg = x"AAAA" or shiftReg = x"5555" then
               if intIdleCnt /= x"FFFF" then
                  intIdleCnt <= intIdleCnt + 1 after TPD_G;
               end if;
            else
               intIdleCnt <= (others=>'0') after TPD_G;
            end if;
         end if;
      end if;
   end process;


   ----------------------------------------
   -- Pattern Detect
   ----------------------------------------
   process ( distClk ) begin
      if rising_edge(distClk) then
         if distClkRst = '1' or delayLd = '1' then
            intData        <= (others=>'0') after TPD_G;
            intDataEn      <= '0'           after TPD_G;
            intDataErr     <= '0'           after TPD_G;
            dataBlockCnt   <= (others=>'0') after TPD_G;
            intErrorCnt    <= (others=>'0') after TPD_G;
         else

            -- Preamble detected
            if shiftReg(3 downto 0) = "0011" and dataBlockCnt = 0 then
               intDataEn    <= '1'           after TPD_G;
               intDataErr   <= '0'           after TPD_G;
               dataBlockCnt <= (others=>'1') after TPD_G;

               -- Extract Data
               intData <= shiftReg(13 downto 4) after TPD_G;

               -- Check parity
               if oddParity(shiftReg(13 downto 4)) /= shiftReg(14) or
                  oddParity(shiftReg(13 downto 4)) /= shiftReg(15) then

                  intDataEn  <= '0' after TPD_G;
                  intDataErr <= '1' after TPD_G;
               end if;
            else
   
               if dataBlockCnt /= 0 then
                  dataBlockCnt <= dataBlockCnt - 1 after TPD_G;
               end if;

               intDataEn  <= '0' after TPD_G;
               intDataErr <= '0' after TPD_G;
            end if;

            -- Error counter
            if intDataErr = '1' and intErrorCnt /= x"FFFF" then
               intErrorCnt <= intErrorCnt + 1 after TPD_G;
            end if;

         end if;
      end if;
   end process;

end architecture STRUCTURE;

