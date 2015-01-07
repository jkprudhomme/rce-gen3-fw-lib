library ieee;
use ieee.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;

entity zynq_10g_xaui is
   PORT (
      dclk                 : in sl;
      reset                : in sl;
      clk156_out           : out sl;
      refclk_p             : in sl;
      refclk_n             : in sl;
      clk156_lock          : out sl;
      xgmii_txd            : in slv(63 downto 0);
      xgmii_txc            : in slv(7 downto 0);
      xgmii_rxd            : out slv(63 downto 0);
      xgmii_rxc            : out slv(7 downto 0);
      xaui_tx_l0_p         : out sl;
      xaui_tx_l0_n         : out sl;
      xaui_tx_l1_p         : out sl;
      xaui_tx_l1_n         : out sl;
      xaui_tx_l2_p         : out sl;
      xaui_tx_l2_n         : out sl;
      xaui_tx_l3_p         : out sl;
      xaui_tx_l3_n         : out sl;
      xaui_rx_l0_p         : in sl;
      xaui_rx_l0_n         : in sl;
      xaui_rx_l1_p         : in sl;
      xaui_rx_l1_n         : in sl;
      xaui_rx_l2_p         : in sl;
      xaui_rx_l2_n         : in sl;
      xaui_rx_l3_p         : in sl;
      xaui_rx_l3_n         : in sl;
      signal_detect        : in slv(3 downto 0);
      debug                : out slv(5 downto 0);
      configuration_vector : in slv(6 downto 0);
      status_vector        : out slv(7 downto 0)
   );
end zynq_10g_xaui;

architecture structure of zynq_10g_xaui is


begin

   clk156_out     <= refclk_p;
   clk156_lock    <= '1';
   xgmii_rxd      <= xgmii_txd;
   xgmii_rxc      <= xgmii_txc;
   xaui_tx_l0_p   <= '0';
   xaui_tx_l0_n   <= '0';
   xaui_tx_l1_p   <= '0';
   xaui_tx_l1_n   <= '0';
   xaui_tx_l2_p   <= '0';
   xaui_tx_l2_n   <= '0';
   xaui_tx_l3_p   <= '0';
   xaui_tx_l3_n   <= '0';
   debug          <= (others=>'0');
   status_vector  <= (others=>'0');

end architecture structure;

