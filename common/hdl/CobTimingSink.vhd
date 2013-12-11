-------------------------------------------------------------------------------
-- Title         : Clock/Trigger Sink Module For COB
-- File          : CobTimingSink.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/10/2013
-------------------------------------------------------------------------------
-- Description:
-- Clock & Trigger sink module for COB
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

entity CobTimingSink is
   generic (
      TPD_G        : time    := 1 ns
   );
   port (

      -- Timing bus
      dpmClk                   : in  slv(2 downto 1)

      -- Clock output   
      sysClk                   : out sl;
      sysClkRst                : out sl;
      
      -- Opcode information, synchronous to sysClk
      timingCode               : out slv(7 downto 0);
      timingCodeEn             : out sl;

      -- Configuration & status information
      configClk                : in  sl;
      configClkRst             : in  sl;
      configReset              : in  sl;
      configSet                : in  sl;
      configDelay              : in  slv(4  downto 0);
      statusIdleCnt            : out slv(15 downto 0);
      statusErrorCnt           : out slv(15 downto 0);
   );
end CobTimingSink;

architecture STRUCTURE of CobTimingSink is

   -- Local Signals
   signal intClk      : sl;
   signal intClkRst   : sl;
   signal delayLd     : sl;
   signal delayValue  : slv(4 downto 0)
   signal inBit       : sl;
   signal shiftReg    : slv(23 downto 0);
   signal intIdleCnt  : slv(15 downto 0);
   signal intErrorCnt : slv(15 downto 0);
   signal intCode     : slv(7 downto 0);
   signal intCodeEn   : sl;
   signal intCodeErr  : sl;
   signal intReset    : sl;

begin

   -- Clock and reset out
   sysClk    <= intClk;
   sysClkRst <= intClkRst;

   ----------------------------------------
   -- Incoming global clock
   ----------------------------------------
   U_Bufg : BUFG
      port map (
         I => dpmClk(1),
         O => intClk
      );

   intReset <= configClkRst or configReset;

   -- Reset gen
   U_RstGen : entity work.RstSync
      generic map (
         TPD_G            => TPD_G,
         IN_POLARITY_G    => '1',
         OUT_POLARITY_G   => '1',
         RELEASE_DELAY_G  => 16
      )
      port map (
        clk      => intClk,
        asyncRst => intReset,
        syncRst  => intClkRst
      );
  
   ----------------------------------------
   -- Incoming Sync Stream
   ----------------------------------------

   -- Pipeline config values
   process ( configClk, configClkRst ) begin
      if configClkRst = '1' then
         delayLd    <= '0'           after TPD_G;
         delayValue <= (others=>'0') after TPD_G;
      elsif rising_edge(configClk) begin
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
         IDATAIN     => dpmClk(2),   -- 1-bit input: Data input from the I/O
         INC         => '0',         -- 1-bit input: Increment / Decrement tap delay input
         LD          => delayLd,     -- 1-bit input: Load IDELAY_VALUE input
         LDPIPEEN    => '0',         -- 1-bit input: Enable PIPELINE register to load data input
         REGRST      => configClkRst -- 1-bit input: Active-high reset tap-delay input
      );

   ----------------------------------------
   -- Shift Register 
   ----------------------------------------
   process ( intClk, intClkRst ) begin
      if sysClkRst = '1' then
         shiftReg <= (others=>'0') after TPD_G;
      elsif rising_edge(intClk) begin

         -- First bit recieved is LSB of pattern
         shiftReg <= inBit & shiftReg(23 downto 1) after TPD_G;
      end if;
   end process;


   ----------------------------------------
   -- Idle Detect
   ----------------------------------------
   process ( intClk, intClkRst ) begin
      if sysClkRst = '1' then
         intIdleCnt    <= (others=>'0') after TPD_G;
         statusIdleCnt <= (others=>'0') after TPD_G;
      elsif rising_edge(intClk) begin
         if shiftReg = x"AAAAAA" or shiftReg = x"555555" then
            shiftReg <= inBit & shiftReg(23 downto 1) after TPD_G;
            if intIdleCnt /= x"FFFF" then
               intIdleCnt <= intIdleCnt + 1 after TPD_G;
            end if;
         else
            intIdleCnt <= (others=>'0') after TPD_G;
         end if;

         statusIdleCnt <= intIdleCnt after TPD_G;

      end if;
   end process;


   ----------------------------------------
   -- Pattern Detect
   ----------------------------------------
   process ( intClk, intClkRst ) begin
      if sysClkRst = '1' then
         intCode        <= (others=>'0') after TPD_G;
         intCodeEn      <= '0'           after TPD_G;
         intCodeErr     <= '0'           after TPD_G;
         intErrorCnt    <= (others=>'0') after TPD_G;
         statusErrorCnt <= (others=>'0') after TPD_G;
         timingCodeEn   <= '0'           after TPD_G;
         timingCodeErr  <= '0'           after TPD_G;
      elsif rising_edge(intClk) begin

         -- Preamble detected
         if shiftReg(7 downto 0) = x"F0" then
            intCodeEn  <= '1' after TPD_G;
            intCodeErr <= '0' after TPD_G;

            -- Process bits
            for i in 0 to 7 loop

               -- Check inverting pattern
               if shiftReg(i*2+8) = shiftReg(i*2+9) then
                  intCodeEn  <= '0' after TPD_G;
                  intCodeErr <= '1' after TPD_G;
               end if;

               -- Extract bit
               intCode(i) <= shiftReg(i*2+8) after TPD_G;
            end loop;
         else
            intCodeEn  <= '0' after TPD_G;
            intCodeErr <= '0' after TPD_G;
         end if;

         -- Error counter
         if intCodeErr = '1' and intErrorCnt /= x"FFFF" then
            itnErrorCnt <= intErrorCnt + 1 after TPD_G;
         end if;

         -- Outputs
         timingCode     <= intCode     after TPD_G;
         timingCodeEn   <= intCodeEn   after TPD_G;
         statusErrorCnt <= intErrorCnt after TPD_G;

      end if;
   end process;

end architecture STRUCTURE;

