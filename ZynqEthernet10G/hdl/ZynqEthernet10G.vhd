-------------------------------------------------------------------------------
-- Title         : Zynq 10 Gige Ethernet Core
-- File          : ZynqEthernet10G.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 09/03/2013
-------------------------------------------------------------------------------
-- Description:
-- Wrapper file for Zynq ethernet 10G core.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 09/03/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.sl_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;

entity ZynqEthernet10G is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clocks
      ponReset                : in  sl;
      ethRefClk               : in  sl;

      -- Local Bus
      axiClk                  : in  sl;
      axiClkRst               : in  sl;
      localBusMaster          : in  LocalBusMasterType;
      localBusSlave           : out LocalBusSlaveType;

      -- Ethernet Lines
      ethRxP                  : in  slv(3 downto 0);
      ethRxM                  : in  slv(3 downto 0);
      ethTxP                  : out slv(3 downto 0);
      ethTxM                  : out slv(3 downto 0)
   );
end ZynqEthernet10G;

architecture structure of ZynqEthernet10G is

   -- Local signals
   signal ethEnable              : sl;
   signal ethReset               : sl;
   signal clk156RstR1            : sl;
   signal clk156RstR2            : sl;
   signal clk156Rst              : sl;
   signal clk156                 : sl;
   signal txoutclk               : sl;
   signal xauiTxd                : slv(63 downto 0);
   signal xauiTxc                : slv(7  downto 0);
   signal xauiRxd                : slv(63 downto 0);
   signal xauiRxc                : slv(7  downto 0);
   signal txlock                 : sl;
   signal signal_detect          : slv(3  downto 0);
   signal align_status           : sl;
   signal sync_status            : slv(3  downto 0);
   signal mgt_tx_ready           : sl;
   signal configuration_vector   : slv(6  downto 0);
   signal status_vector          : slv(7  downto 0);

begin

   --------------------------------------------
   -- Registers: 0xB800_0000 - 0xBBFF_FFFF
   --------------------------------------------
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         localBusSlave        <= LocalBusSlaveInit      after TPD_G;
         ethEnable            <= '0'                    after TPD_G;
         xauiTxd              <= (others=>'0')          after TPD_G;
         xauiTxc              <= (others=>'0')          after TPD_G;
         configuration_vector <= (others=>'0')          after TPD_G;
      elsif rising_edge(axiClk) then
         localBusSlave.readValid <= localBusMaster.readEnable after TPD_G;
         localBusSlave.readData  <= (others=>'0')             after TPD_G;
         wrFifoWrEn              <= '0'                       after TPD_G;
         rdFifoRdEn              <= '0'                       after TPD_G;

         -- Write Low Data - 0xB800_1000
         if localBusMaster.addr(23 downto 0) = x"001000" then
            if localBusMaster.writeEnable = '1' then
               xauiTxd(31 downto 0) <= localBusMaster.writeData after TPD_G;
            end if;
            localBusSlave.readData  <= xauiTxd(31 downto 0)     after TPD_G;

         -- Write High Data - 0xB800_1004
         elsif localBusMaster.addr(23 downto 0) = x"001004" then
            if localBusMaster.writeEnable = '1' then
               xauiTxd(63 downto 32) <= localBusMaster.writeData after TPD_G;
            end if;
            localBusSlave.readData  <= xauiTxd(63 downto 32)     after TPD_G;

         -- Write Control - 0xB800_1008
         elsif localBusMaster.addr(23 downto 0) = x"001008" then
            if localBusMaster.writeEnable = '1' then
               xauiTxc <= localBusMaster.writeData(7 downto 0) after TPD_G;
            end if;
            localBusSlave.readData(7 downto 0) <= xauiTxc after TPD_G;

         -- Read Low Data - 0xB800_100C
         elsif localBusMaster.addr(23 downto 0) = x"00100C" then
            localBusSlave.readData  <= xauiRxd(31 downto 0)     after TPD_G;

         -- Read High Data - 0xB800_1010
         elsif localBusMaster.addr(23 downto 0) = x"001010" then
            localBusSlave.readData  <= xauiRxd(63 downto 32)     after TPD_G;

         -- Read Control - 0xB800_1014
         elsif localBusMaster.addr(23 downto 0) = x"001014" then
            localBusSlave.readData(7 downto 0) <= xauiRxc after TPD_G;

         -- Config Vector - 0xB800_1018
         elsif localBusMaster.addr(23 downto 0) = x"001018" then
            if localBusMaster.writeEnable = '1' then
               configuration_vector <= localBusMaster.writeData(6 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData(6 downto 0) <= configuration_vector after TPD_G;

         -- Status Vector - 0xB800_101C
         elsif localBusMaster.addr(23 downto 0) = x"00101C" then
            intLocalBusSlave.readData(7 downto 0) <= status_vector after TPD_G;

         -- Others status - 0xB800_1020
         elsif localBusMaster.addr(23 downto 0) = x"001020" then
            intLocalBusSlave.readData(3 downto 0) <= signal_detect after TPD_G;
            intLocalBusSlave.readData(7 downto 4) <= sync_status   after TPD_G;
            intLocalBusSlave.readData(8)          <= align_status  after TPD_G;
            intLocalBusSlave.readData(9)          <= mgt_tx_ready  after TPD_G;
            intLocalBusSlave.readData(10)         <= txlock        after TPD_G;

         -- Enable Register - 0xB800_1024
         elsif localBusMaster.addr(23 downto 0) = x"001024" then
            if localBusMaster.writeEnable = '1' then
               ethEnable <= localBusMaster.writeData(0) after TPD_G;
            end if;
            intLocalBusSlave.readData(0) <= ethEnable after TPD_G;

         end if;
      end if;  
   end process;         


   -----------------------------------------
   -- XAUI Interface
   -----------------------------------------

   -- Reset
   ethReset = ponReset or not ethEnable;

   -- Core, copied from example design
   -- Modified reset timing for 200mhz dclk
   U_ZynqXaui : entity work.zynq_xaui_block
      generic map (
         WRAPPER_SIM_GTRESET_SPEEDUP => "TRUE" --Does not affect hardware
      ) port map (
         reset156              => clk156Rst,
         reset                 => ethReset,
         dclk                  => axiClk,
         clk156                => clk156,
         refclk                => ethRefClk,
         txoutclk              => txoutclk,
         xgmii_txd             => xauiTxd,
         xgmii_txc             => xauiTxc,
         xgmii_rxd             => xauiRxd,
         xgmii_rxc             => xauiRxc,
         xaui_tx_l0_p          => ethTxP(0),
         xaui_tx_l0_n          => ethTxM(0),
         xaui_tx_l1_p          => ethTxP(1),
         xaui_tx_l1_n          => ethTxM(1),
         xaui_tx_l2_p          => ethTxP(2),
         xaui_tx_l2_n          => ethTxM(2),
         xaui_tx_l3_p          => ethTxP(3),
         xaui_tx_l3_n          => ethTxM(3),
         xaui_rx_l0_p          => ethRxP(0),
         xaui_rx_l0_n          => ethRxM(0),
         xaui_rx_l1_p          => ethRxP(1),
         xaui_rx_l1_n          => ethRxM(1),
         xaui_rx_l2_p          => ethRxP(2),
         xaui_rx_l2_n          => ethRxM(2),
         xaui_rx_l3_p          => ethRxP(3),
         xaui_rx_l3_n          => ethRxM(3),
         txlock                => txlock,
         mmcm_lock             => txlock,
         signal_detect         => signal_detect,
         align_status          => align_status,
         sync_status           => sync_status,
         drp_addr              => (others=>'0'),
         drp_en                => (others=>'0'),
         drp_i                 => (others=>'0'),
         drp_o                 => open,
         drp_rdy               => open,
         drp_we                => (others=>'0'),
         mgt_tx_ready          => mgt_tx_ready,
         configuration_vector  => configuration_vector,
         status_vector         => status_vector
      );

   -- Clock buffer
   clk156_bufg : BUFG
      port map ( 
         O => clk156,
         I => txoutclk
      );

   -- Generate reset
   p_reset : process (clk156, txlock) begin
      if txlock = '0' then
         clk156RstR1  <= '1' after TPD_G;
         clk156RstR2  <= '1' after TPD_G;
         clk156Rst    <= '1' after TPD_G;
      elsif rising_edge(clk156) then
         clk156RstR1  <= '0'         after TPD_G;
         clk156RstR2  <= clk156RstR1 after TPD_G;
         clk156Rst    <= clk156RstR2 after TPD_G;
      end if;
   end process;

end architecture structure;

