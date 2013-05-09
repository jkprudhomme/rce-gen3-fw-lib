-------------------------------------------------------------------------------
-- Title         : Clock generation block
-- File          : ArmRceG3Clocks.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Clock generation block for generation 3 RCE core.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;

entity ArmRceG3Clocks is
   port (

      -- Core clock and reset inputs
      fclkClk3                : in     std_logic;
      fclkClk2                : in     std_logic;
      fclkClk1                : in     std_logic;
      fclkClk0                : in     std_logic; -- 100Mhz
      fclkRst3                : in     std_logic;
      fclkRst2                : in     std_logic;
      fclkRst1                : in     std_logic;
      fclkRst0                : in     std_logic;

      -- AXI bus clock inputs
      axiGpMasterReset        : in     std_logic_vector(1 downto 0);
      axiGpSlaveReset         : in     std_logic_vector(1 downto 0);
      axiAcpSlaveReset        : in     std_logic;
      axiHpSlaveReset         : in     std_logic_vector(3 downto 0);

      -- AXI clock and reset
      axiClk                  : out    std_logic;
      axiClkRst               : out    std_logic;

      -- Other system clocks
      sysClk125               : out    std_logic;
      sysClk125Rst            : out    std_logic;
      sysClk200               : out    std_logic;
      sysClk200Rst            : out    std_logic
   );
end ArmRceG3Clocks;

architecture structure of ArmRceG3Clocks is

   -- Local signals
   signal axiCombinedRst     : std_logic;
   signal daxiClk            : std_logic;
   signal iaxiClk            : std_logic;
   signal iaxiClkRst         : std_logic;
   signal dsysClk125         : std_logic;
   signal isysClk125         : std_logic;
   signal isysClk125Rst      : std_logic;
   signal dsysClk200         : std_logic;
   signal isysClk200         : std_logic;
   signal isysClk200Rst      : std_logic;
   signal clkFbOut           : std_logic;
   signal mmcmLocked         : std_logic;
   signal ponCount           : std_logic_vector(7 downto 0);
   signal ponResetL          : std_logic;
   signal ponReset           : std_logic;
   signal lockedReset        : std_logic;

begin

   -- Outputs
   axiClk    <= iaxiClk;
   sysClk125 <= isysClk125;
   sysClk200 <= isysClk200;

   ---------------------------------------------------------------
   -- Power on reset generation
   ---------------------------------------------------------------
   process (fclkClk0, fclkRst0) begin
      if (fclkRst0 = '1') then
         ponCount  <= (others=>'0') after TPD_G;
         ponResetL <= '0'           after TPD_G;
      elsif (rising_edge(fclkClk0)) then
         if ponCount = x"FF" then
            ponResetL <= '1' after TPD_G;
         else
            ponResetL <= '0'          after TPD_G;
            ponCount  <= ponCount + 1 after TPD_G;
         end if;
      end if;
   end process;

   ponReset <= not ponResetL;

   ---------------------------------------------------------------
   -- Clock generation
   ---------------------------------------------------------------

   U_ClockGen : MMCME2_ADV
      generic map (
         BANDWIDTH            => "OPTIMIZED",
         CLKOUT4_CASCADE      => FALSE,
         COMPENSATION         => "ZHOLD",
         STARTUP_WAIT         => FALSE,
         DIVCLK_DIVIDE        => 1,
         CLKFBOUT_MULT_F      => 10.000,
         CLKFBOUT_PHASE       => 0.000,
         CLKFBOUT_USE_FINE_PS => FALSE,
         CLKOUT0_DIVIDE_F     => 10.000,
         CLKOUT0_PHASE        => 0.000,
         CLKOUT0_DUTY_CYCLE   => 0.5,
         CLKOUT0_USE_FINE_PS  => FALSE,
         CLKOUT1_DIVIDE       => 5,
         CLKOUT1_PHASE        => 0.000,
         CLKOUT1_DUTY_CYCLE   => 0.5,
         CLKOUT1_USE_FINE_PS  => FALSE,
         CLKOUT2_DIVIDE       => 8,
         CLKOUT2_PHASE        => 0.000,
         CLKOUT2_DUTY_CYCLE   => 0.5,
         CLKOUT2_USE_FINE_PS  => FALSE,
         CLKIN1_PERIOD        => 10.0,
         REF_JITTER1          => 0.010
      )
      port map (
         CLKFBOUT             => clkFbOut,
         CLKFBOUTB            => open,
         CLKOUT0              => daxiClk, -- 100Mhz
         CLKOUT0B             => open,
         CLKOUT1              => dsysClk200, -- 200Mhz
         CLKOUT1B             => open,
         CLKOUT2              => dsysClk125, -- 125Mhz
         CLKOUT2B             => open,
         CLKOUT3              => open,
         CLKOUT3B             => open,
         CLKOUT4              => open,
         CLKOUT5              => open,
         CLKOUT6              => open,
         CLKFBIN              => clkFbOut,
         CLKIN1               => fclkClk0,
         CLKIN2               => '0',
         CLKINSEL             => '1',
         DADDR                => (others => '0'),
         DCLK                 => '0',
         DEN                  => '0',
         DI                   => (others => '0'),
         DO                   => open,
         DRDY                 => open,
         DWE                  => '0',
         PSCLK                => '0',
         PSEN                 => '0',
         PSINCDEC             => '0',
         PSDONE               => open,
         LOCKED               => mmcmLocked,
         CLKINSTOPPED         => open,
         CLKFBSTOPPED         => open,
         PWRDWN               => '0',
         RST                  => ponReset
      );

   U_axiClkBuf : BUFG
      port map (
         I     => daxiClk,
         O     => iaxiClk
      );

   U_sysClk200Buf : BUFG
      port map (
         I     => dsysClk200,
         O     => isysClk200
      );

   U_sysClk125Buf : BUFG
      port map (
         I     => dsysClk125,
         O     => isysClk125
      );

   ---------------------------------------------------------------
   -- Reset generation
   ---------------------------------------------------------------

   -- Locked reset
   lockedReset <= ponReset or (not mmcmLocked);

   -- Combine AXI bus resets
   axiCombinedRst <= lockedReset when axiGpMasterReset /= "00" or axiGpSlaveReset /= "00" or 
                                      axiAcpSlaveReset /= '0'  or axiHpSlaveReset /= "0000" else '1';

   U_axiClkRstGen : entity work.RstSync
      generic map (
         DELAY_G        => 1 ns,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1',
         HOLD_CYCLES_G  => 16
      )
      port map (
        clk      => iaxiClk,
        asyncRst => axiCombinedRst,
        syncRst  => axiClkRst
      );

   U_sysClk200RstGen : entity work.RstSync
      generic map (
         DELAY_G        => 1 ns,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1',
         HOLD_CYCLES_G  => 16
      )
      port map (
        clk      => isysClk200,
        asyncRst => lockedReset,
        syncRst  => sysClk200Rst
      );

   U_sysClk125RstGen : entity work.RstSync
      generic map (
         DELAY_G        => 1 ns,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1',
         HOLD_CYCLES_G  => 16
      )
      port map (
        clk      => isysClk125,
        asyncRst => lockedReset,
        syncRst  => sysClk125Rst
      );

end architecture structure;

