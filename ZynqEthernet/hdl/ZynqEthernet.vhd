-------------------------------------------------------------------------------
-- Title         : Zynq 1Gige Ethernet Core
-- File          : ZynqEthernet.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Wrapper file for Zynq ethernet core.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE 1G Ethernet Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE 1G Ethernet Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

library unisim;
use unisim.vcomponents.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;

entity ZynqEthernet is
   port (

      -- Clocks
      sysClk125    : in sl;
      sysClk200    : in sl;
      sysClk200Rst : in sl;

      -- ARM Interface
      armEthTx : in  ArmEthTxType;
      armEthRx : out ArmEthRxType;

      -- Ethernet Lines
      ethRxP : in  sl;
      ethRxM : in  sl;
      ethTxP : out sl;
      ethTxM : out sl
      );
end ZynqEthernet;

architecture structure of ZynqEthernet is

   component zynq_gige_block
      port (
         gtrefclk               : in  std_logic;
         txp                    : out std_logic;
         txn                    : out std_logic;
         rxp                    : in  std_logic;
         rxn                    : in  std_logic;
         txoutclk               : out std_logic;
         rxoutclk               : out std_logic;
         resetdone              : out std_logic;
         cplllock               : out std_logic;
         mmcm_locked            : in  std_logic;
         userclk                : in  std_logic;
         userclk2               : in  std_logic;
         rxuserclk              : in  std_logic;
         rxuserclk2             : in  std_logic;
         independent_clock_bufg : in  std_logic;
         pma_reset              : in  std_logic;
         gmii_txclk             : out std_logic;
         gmii_rxclk             : out std_logic;
         gmii_txd               : in  std_logic_vector (7 downto 0);
         gmii_tx_en             : in  std_logic;
         gmii_tx_er             : in  std_logic;
         gmii_rxd               : out std_logic_vector (7 downto 0);
         gmii_rx_dv             : out std_logic;
         gmii_rx_er             : out std_logic;
         gmii_isolate           : out std_logic;
         mdc                    : in  std_logic;
         mdio_i                 : in  std_logic;
         mdio_o                 : out std_logic;
         mdio_t                 : out std_logic;
         configuration_vector   : in  std_logic_vector (4 downto 0);
         configuration_valid    : in  std_logic;
         status_vector          : out std_logic_vector (15 downto 0);
         reset                  : in  std_logic;
         signal_detect          : in  std_logic;
         gt0_qplloutclk_in      : in  std_logic;
         gt0_qplloutrefclk_in   : in  std_logic);
   end component;

   type RegType is record
      load  : sl;
   end record;
   
   constant REG_INIT_C : RegType := (
      load  => '0');

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal txoutclk       : sl;          -- txoutclk from GT transceiver
   signal txoutclk_bufg  : sl;          -- txoutclk from GT transceiver routed onto global routing.
   signal mmcm_locked    : sl;          -- MMCM locked signal.
   signal clkfbout       : sl;          -- MMCM feedback clock
   signal clkout0        : sl;          -- MMCM clock0 output (62.5MHz).
   signal clkout1        : sl;          -- MMCM clock1 output (125MHz).
   signal userclk        : sl;          -- 62.5MHz clock for GT transceiver Tx/Rx user clocks
   signal userclk2       : sl;          -- 125MHz clock for core reference clock.
   signal pma_reset_pipe : slv(3 downto 0);  -- flip-flop pipeline for reset duration stretch
   signal pma_reset      : sl;          -- Synchronous transcevier PMA reset
   signal reset          : sl;
   signal status_vector  : slv(15 downto 0);
   signal cplllock       : sl;
   signal resetdone       : sl;
   
   -- attribute dont_touch                  : string;
   -- attribute dont_touch of r             : signal is "true";
   -- attribute dont_touch of status_vector : signal is "true";
   -- attribute dont_touch of cplllock      : signal is "true";
   -- attribute dont_touch of resetdone     : signal is "true";

begin

   -- Outputs
   armEthRx.enetGmiiRxClk <= userclk2;
   armEthRx.enetGmiiTxClk <= userclk2;

   -- Unused inputs
   --armEthTx.enetMdioT           : sl;
   --armEthTx.enetPtpDelayReqRx   : sl;
   --armEthTx.enetPtpDelayReqTx   : sl;
   --armEthTx.enetPtpPDelayReqRx  : sl;
   --armEthTx.enetPtpPDelayReqTx  : sl;
   --armEthTx.enetPtpPDelayRespRx : sl;
   --armEthTx.enetPtpPDelayRespTx : sl;
   --armEthTx.enetPtpSyncFrameRx  : sl;
   --armEthTx.enetPtpSyncFrameTx  : sl;
   --armEthTx.enetSofRx           : sl;
   --armEthTx.enetSofTx           : sl;

   -- Unused outputs
   armEthRx.enetGmiiCol  <= '0';
   armEthRx.enetGmiiCrs  <= '1';
   armEthRx.enetExtInitN <= '0';

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
         I => txoutclk,
         O => txoutclk_bufg
         );

   -- The GT transceiver provides a 62.5MHz clock to the FPGA fabrix.  This is 
   -- routed to an MMCM module where it is used to create phase and frequency
   -- related 62.5MHz and 125MHz clock sources
   mmcm_adv_inst : MMCME2_ADV
      generic map (
         BANDWIDTH            => "OPTIMIZED",
         CLKOUT4_CASCADE      => false,
         COMPENSATION         => "ZHOLD",
         STARTUP_WAIT         => false,
         DIVCLK_DIVIDE        => 1,
         CLKFBOUT_MULT_F      => 16.000,
         CLKFBOUT_PHASE       => 0.000,
         CLKFBOUT_USE_FINE_PS => false,
         CLKOUT0_DIVIDE_F     => 8.000,
         CLKOUT0_PHASE        => 0.000,
         CLKOUT0_DUTY_CYCLE   => 0.5,
         CLKOUT0_USE_FINE_PS  => false,
         CLKOUT1_DIVIDE       => 16,
         CLKOUT1_PHASE        => 0.000,
         CLKOUT1_DUTY_CYCLE   => 0.5,
         CLKOUT1_USE_FINE_PS  => false,
         CLKIN1_PERIOD        => 16.0,
         REF_JITTER1          => 0.010
         )
      port map (
         CLKFBOUT     => clkfbout,
         CLKFBOUTB    => open,
         CLKOUT0      => clkout0,
         CLKOUT0B     => open,
         CLKOUT1      => clkout1,
         CLKOUT1B     => open,
         CLKOUT2      => open,
         CLKOUT2B     => open,
         CLKOUT3      => open,
         CLKOUT3B     => open,
         CLKOUT4      => open,
         CLKOUT5      => open,
         CLKOUT6      => open,
         -- Input clock control
         CLKFBIN      => clkfbout,
         CLKIN1       => txoutclk_bufg,
         CLKIN2       => '0',
         -- Tied to always select the primary input clock
         CLKINSEL     => '1',
         -- Ports for dynamic reconfiguration
         DADDR        => (others => '0'),
         DCLK         => '0',
         DEN          => '0',
         DI           => (others => '0'),
         DO           => open,
         DRDY         => open,
         DWE          => '0',
         -- Ports for dynamic phase shift
         PSCLK        => '0',
         PSEN         => '0',
         PSINCDEC     => '0',
         PSDONE       => open,
         -- Other control and status signals
         LOCKED       => mmcm_locked,
         CLKINSTOPPED => open,
         CLKFBSTOPPED => open,
         PWRDWN       => '0',
         RST          => sysClk200Rst
         );

   -- This 62.5MHz clock is placed onto global clock routing and is then used
   -- for tranceiver TXUSRCLK/RXUSRCLK.
   bufg_userclk : BUFG
      port map (
         I => clkout1,
         O => userclk
         );    

   -- This 125MHz clock is placed onto global clock routing and is then used
   -- to clock all Ethernet core logic.
   bufg_userclk2 : BUFG
      port map (
         I => clkout0,
         O => userclk2
         );    

   -----------------------------------------------------------------------------
   -- Transceiver PMA reset circuitry
   -----------------------------------------------------------------------------

   -- Create a reset pulse of a decent length
   process(sysClk200, sysClk200Rst)
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
   core_wrapper : zynq_gige_block
      port map (
         gtrefclk               => sysClk125,
         txn                    => ethTxM,
         txp                    => ethTxP,
         rxn                    => ethRxM,
         rxp                    => ethRxP,
         independent_clock_bufg => sysClk200,
         txoutclk               => txoutclk,
         rxoutclk               => open,
         resetdone              => resetdone,
         cplllock               => cplllock,
         userclk                => userclk,
         userclk2               => userclk2,
         pma_reset              => pma_reset,
         mmcm_locked            => mmcm_locked,
         rxuserclk              => userclk,
         rxuserclk2             => userclk,
         gmii_txclk             => open,
         gmii_rxclk             => open,
         gmii_txd               => armEthTx.enetGmiiTxD,
         gmii_tx_en             => armEthTx.enetGmiiTxEn,
         gmii_tx_er             => armEthTx.enetGmiiTxEr,
         gmii_rxd               => armEthRx.enetGmiiRxd,
         gmii_rx_dv             => armEthRx.enetGmiiRxDv,
         gmii_rx_er             => armEthRx.enetGmiiRxEr,
         gmii_isolate           => open,
         mdc                    => armEthTx.enetMdioMdc,
         mdio_i                 => armEthTx.enetMdioO,
         mdio_o                 => armEthRx.enetMdioI,
         mdio_t                 => open,
         configuration_vector   => "00000",
         configuration_valid    => r.load,
         status_vector          => status_vector,
         reset                  => reset,
         signal_detect          => '1',
         gt0_qplloutclk_in      => '0',   -- QPLL not used
         gt0_qplloutrefclk_in   => '0');  -- QPLL not used

   RstSync_Inst : entity work.RstSync
      port map (
         clk      => userclk2,
         asyncRst => sysClk200Rst,
         syncRst  => reset);       

   comb : process (r, reset) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;    
      
      -- Toggle
      v.load := not(r.load);

      -- Reset
      if (reset = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;
      
   end process comb;

   seq : process (userclk2) is
   begin
      if rising_edge(userclk2) then
         r <= rin;
      end if;
   end process seq;

end architecture structure;
