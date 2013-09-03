-------------------------------------------------------------------------------
-- Title         : Zynq 1Gige Ethernet Core
-- File          : ZynqEthernet.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Wrapper file for Zynq ethernet core.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;

entity ZynqEthernet is
   port (

      -- Clocks
      sysClk125               : in  sl;
      sysClk200               : in  sl;
      sysClk200Rst            : in  sl;

      -- ARM Interface
      ethFromArm              : in  EthFromArmType;
      ethToArm                : out EthToArmType;

      -- Ethernet Lines
      ethRxP                  : in  sl;
      ethRxM                  : in  sl;
      ethTxP                  : out sl;
      ethTxM                  : out sl
   );
end ZynqEthernet;

architecture structure of ZynqEthernet is

   -- Local signals
   signal txoutclk              : sl;                    -- txoutclk from GT transceiver
   signal txoutclk_bufg         : sl;                    -- txoutclk from GT transceiver routed onto global routing.
   signal resetdone             : sl;                    -- To indicate that the GT transceiver has completed its reset cycle
   signal mmcm_locked           : sl;                    -- MMCM locked signal.
   signal mmcm_reset            : sl;                    -- MMCM reset signal.
   signal clkfbout              : sl;                    -- MMCM feedback clock
   signal clkout0               : sl;                    -- MMCM clock0 output (62.5MHz).
   signal clkout1               : sl;                    -- MMCM clock1 output (125MHz).
   signal userclk               : sl;                    -- 62.5MHz clock for GT transceiver Tx/Rx user clocks
   signal userclk2              : sl;                    -- 125MHz clock for core reference clock.
   signal pma_reset_pipe        : slv(3 downto 0); -- flip-flop pipeline for reset duration stretch
   signal pma_reset             : sl;                    -- Synchronous transcevier PMA reset
   signal confValid             : sl;

begin

   -- Outputs
   ethToArm.enetGmiiRxClk <= userclk2;
   ethToArm.enetGmiiTxClk <= userclk2;

   -- Unused inputs
   --ethFromArm.enetMdioT           : sl;
   --ethFromArm.enetPtpDelayReqRx   : sl;
   --ethFromArm.enetPtpDelayReqTx   : sl;
   --ethFromArm.enetPtpPDelayReqRx  : sl;
   --ethFromArm.enetPtpPDelayReqTx  : sl;
   --ethFromArm.enetPtpPDelayRespRx : sl;
   --ethFromArm.enetPtpPDelayRespTx : sl;
   --ethFromArm.enetPtpSyncFrameRx  : sl;
   --ethFromArm.enetPtpSyncFrameTx  : sl;
   --ethFromArm.enetSofRx           : sl;
   --ethFromArm.enetSofTx           : sl;

   -- Unused outputs
   ethToArm.enetGmiiCol  <= '0';
   ethToArm.enetGmiiCrs  <= '0';
   ethToArm.enetExtInitN <= '0';

   -----------------------------------------------------------------------------
   -- The following code is based on the zynq_gige_example_design.vhd
   -- file in the coregen/zynq_gige/example_design directory.
   -----------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- Transceiver Clock Management
   -----------------------------------------------------------------------------

   -- Route txoutclk input through a BUFG
   bufg_txoutclk : BUFG
      port map (
         I         => txoutclk,
         O         => txoutclk_bufg
      );

   -- The GT transceiver provides a 62.5MHz clock to the FPGA fabrix.  This is 
   -- routed to an MMCM module where it is used to create phase and frequency
   -- related 62.5MHz and 125MHz clock sources
   mmcm_adv_inst : MMCME2_ADV
      generic map (
         BANDWIDTH            => "OPTIMIZED",
         CLKOUT4_CASCADE      => FALSE,
         COMPENSATION         => "ZHOLD",
         STARTUP_WAIT         => FALSE,
         DIVCLK_DIVIDE        => 1,
         CLKFBOUT_MULT_F      => 16.000,
         CLKFBOUT_PHASE       => 0.000,
         CLKFBOUT_USE_FINE_PS => FALSE,
         CLKOUT0_DIVIDE_F     => 8.000,
         CLKOUT0_PHASE        => 0.000,
         CLKOUT0_DUTY_CYCLE   => 0.5,
         CLKOUT0_USE_FINE_PS  => FALSE,
         CLKOUT1_DIVIDE       => 16,
         CLKOUT1_PHASE        => 0.000,
         CLKOUT1_DUTY_CYCLE   => 0.5,
         CLKOUT1_USE_FINE_PS  => FALSE,
         CLKIN1_PERIOD        => 16.0,
         REF_JITTER1          => 0.010
      )
      port map (
         CLKFBOUT             => clkfbout,
         CLKFBOUTB            => open,
         CLKOUT0              => clkout0,
         CLKOUT0B             => open,
         CLKOUT1              => clkout1,
         CLKOUT1B             => open,
         CLKOUT2              => open,
         CLKOUT2B             => open,
         CLKOUT3              => open,
         CLKOUT3B             => open,
         CLKOUT4              => open,
         CLKOUT5              => open,
         CLKOUT6              => open,
         -- Input clock control
         CLKFBIN              => clkfbout,
         CLKIN1               => txoutclk_bufg,
         CLKIN2               => '0',
         -- Tied to always select the primary input clock
         CLKINSEL             => '1',
         -- Ports for dynamic reconfiguration
         DADDR                => (others => '0'),
         DCLK                 => '0',
         DEN                  => '0',
         DI                   => (others => '0'),
         DO                   => open,
         DRDY                 => open,
         DWE                  => '0',
         -- Ports for dynamic phase shift
         PSCLK                => '0',
         PSEN                 => '0',
         PSINCDEC             => '0',
         PSDONE               => open,
         -- Other control and status signals
         LOCKED               => mmcm_locked,
         CLKINSTOPPED         => open,
         CLKFBSTOPPED         => open,
         PWRDWN               => '0',
         RST                  => mmcm_reset
      );

   mmcm_reset <= sysClk200Rst or (not resetdone);

   -- This 62.5MHz clock is placed onto global clock routing and is then used
   -- for tranceiver TXUSRCLK/RXUSRCLK.
   bufg_userclk: BUFG
   port map (
      I     => clkout1,
      O     => userclk
   );    

   -- This 125MHz clock is placed onto global clock routing and is then used
   -- to clock all Ethernet core logic.
   bufg_userclk2: BUFG
   port map (
      I     => clkout0,
      O     => userclk2
   );    

   -----------------------------------------------------------------------------
   -- Transceiver PMA reset circuitry
   -----------------------------------------------------------------------------

   -- Create a reset pulse of a decent length
   process(sysClk200Rst, sysClk200)
   begin
     if (sysClk200Rst = '1') then
       pma_reset_pipe <= "1111";
     elsif sysClk200'event and sysClk200 = '1' then
       pma_reset_pipe <= pma_reset_pipe(2 downto 0) & sysClk200Rst;
     end if;
   end process;

   pma_reset <= pma_reset_pipe(3);

   ------------------------------------------------------------------------------
   -- Instantiate the Core Block (core wrapper).
   ------------------------------------------------------------------------------
   core_wrapper : entity work.zynq_gige_block
      generic map (
         EXAMPLE_SIMULATION   =>  0 
      )
      port map (
         drpaddr_in             => (others => '0') , 
         drpclk_in              => userclk2, 
         drpdi_in               => (others => '0') , 
         drpdo_out              => open , 
         drpen_in               => '0', 
         drprdy_out             => open, 
         drpwe_in               => '0', 
         gtrefclk               => sysClk125,
         txp                    => ethTxP,
         txn                    => ethTxM,
         rxp                    => ethRxP,
         rxn                    => ethRxM,
         txoutclk               => txoutclk,
         resetdone              => resetdone,
         mmcm_locked            => mmcm_locked,
         userclk                => userclk,
         userclk2               => userclk2,
         independent_clock_bufg => sysClk200,
         pma_reset              => pma_reset,
         gmii_txd               => ethFromArm.enetGmiiTxD,
         gmii_tx_en             => ethFromArm.enetGmiiTxEn,
         gmii_tx_er             => ethFromArm.enetGmiiTxEr,
         gmii_rxd               => ethToArm.enetGmiiRxd,
         gmii_rx_dv             => ethToArm.enetGmiiRxDv,
         gmii_rx_er             => ethToArm.enetGmiiRxEr,
         gmii_isolate           => open,
         mdc                    => ethFromArm.enetMdioMdc,
         mdio_i                 => ethFromArm.enetMdioO,
         mdio_o                 => ethToArm.enetMdioI,
         mdio_t                 => open,
         phyad                  => (others=>'0'),
         configuration_vector   => "00000",
         configuration_valid    => confValid, 
         status_vector          => open,
         reset                  => sysClk200Rst,
         signal_detect          => '1'
      );

   -- Force configuration set
   process(userclk2, sysClk200Rst)
   begin
     if (sysClk200Rst = '1') then
       confValid <= '0';
     elsif userclk2'event and userclk2 = '1' then
       confValid <= not confValid;
     end if;
   end process;

end architecture structure;

