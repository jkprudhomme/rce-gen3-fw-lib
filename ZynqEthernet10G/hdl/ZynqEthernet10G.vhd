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
use ieee.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.AxiLitePkg.all;
use work.StdRtlPkg.all;

entity ZynqEthernet10G is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clocks
      sysClk200               : in  sl;
      sysClk200Rst            : in  sl;
      sysClk125               : in  sl;
      sysClk125Rst            : in  sl;

      -- PPI Interface
      ppiClk                  : out sl;
      ppiOnline               : in  sl;
      ppiReadToFifo           : out PpiReadToFifoType;
      ppiReadFromFifo         : in  PpiReadFromFifoType;
      ppiWriteToFifo          : out PpiWriteToFifoType;
      ppiWriteFromFifo        : in  PpiWriteFromFifoType;

      -- Temp status output
      ethStatus               : out slv(7  downto 0);
      ethConfig               : in  slv(6  downto 0);
      ethDebug                : out slv(5  downto 0);
      ethClkOut               : out sl;

      -- Ref Clock
      ethRefClkP              : in  sl;
      ethRefClkM              : in  sl;

      -- Ethernet Lines
      ethRxP                  : in  slv(3 downto 0);
      ethRxM                  : in  slv(3 downto 0);
      ethTxP                  : out slv(3 downto 0);
      ethTxM                  : out slv(3 downto 0)
   );
end ZynqEthernet10G;

architecture structure of ZynqEthernet10G is

   COMPONENT zynq_10g_xaui
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
   END COMPONENT;

   signal xauiRxd          : slv(63 downto 0);
   signal xauiRxc          : slv(7  downto 0);
   signal xauiTxd          : slv(63 downto 0);
   signal xauiTxc          : slv(7  downto 0);
   signal status           : slv(7  downto 0);
   signal swConfig         : slv(6  downto 0);
   signal intConfig        : slv(6  downto 0);
   signal intReadToFifo    : PpiReadToFifoType;
   signal intReadFromFifo  : PpiReadFromFifoType;
   signal intWriteToFifo   : PpiWriteToFifoType;
   signal intWriteFromFifo : PpiWriteFromFifoType;
   signal axiWriteMaster   : AxiLiteWriteMasterType;
   signal axiWriteSlave    : AxiLiteWriteSlaveType;
   signal axiReadMaster    : AxiLiteReadMasterType;
   signal axiReadSlave     : AxiLiteReadSlaveType;
   signal statusWords      : Slv64Array(1 downto 0);
   signal statusSend       : sl;
   signal ethReadToFifo    : PpiReadToFifoType;
   signal ethReadFromFifo  : PpiReadFromFifoType;
   signal ethWriteToFifo   : PpiWriteToFifoType;
   signal ethWriteFromFifo : PpiWriteFromFifoType;
   signal ethOnline        : sl;
   signal ethClk           : sl;
   signal ethClkRst        : sl;
   signal ethClkLock       : sl;
   signal rstRxLink        : sl;
   signal rstRxLinkReg     : sl;
   signal rstFault         : sl;
   signal rstFaultReg      : sl;

   type RegType is record
      config            : slv(6  downto 0);
      axiReadSlave      : AxiLiteReadSlaveType;
      axiWriteSlave     : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      config            => (others=>'0'),
      axiReadSlave      => AXI_LITE_READ_SLAVE_INIT_C,
      axiWriteSlave     => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin
 
   ethStatus <= status;
   ppiClk    <= sysClk200;
   ethClkOut <= ethClk;

   -- PPI Crossbar
   U_PpiCrossbar : entity work.PpiCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_PPI_SLOTS_G    => 1,
         NUM_AXI_SLOTS_G    => 1,
         NUM_STATUS_WORDS_G => 2
      ) port map (
         ppiClk             => sysClk200,
         ppiClkRst          => sysClk200Rst,
         ppiOnline          => ppiOnline,
         ibWriteToFifo      => ppiWriteToFifo,
         ibWriteFromFifo    => ppiWriteFromFifo,
         obReadToFifo       => ppiReadToFifo,
         obReadFromFifo     => ppiReadFromFifo,
         ibReadToFifo(0)    => intReadToFifo,
         ibReadFromFifo(0)  => intReadFromFifo,
         obWriteToFifo(0)   => intWriteToFifo,
         obWriteFromFifo(0) => intWriteFromFifo,
         axiClk             => sysClk125,
         axiClkRst          => sysClk125Rst,
         axiWriteMasters(0) => axiWriteMaster,
         axiWriteSlaves(0)  => axiWriteSlave,
         axiReadMasters(0)  => axiReadMaster,
         axiReadSlaves(0)   => axiReadSlave,
         statusClk          => sysClk125,
         statusClkRst       => sysClk125Rst,
         statusWords        => statusWords,
         statusSend         => statusSend
      );


   statusWords(0)(63 downto 8) <= (others=>'0');
   statusWords(0)(7  downto 0) <= status;
   statusWords(1)(63 downto 0) <= (others=>'0');
   statusSend                  <= '0';


   -------------------------------------------
   -- Local Registers
   -------------------------------------------

   -- Sync
   process (sysClk125) is
   begin
      if (rising_edge(sysClk125)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (sysClk125Rst, axiReadMaster, axiWriteMaster, r, status ) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      axiSlaveWaitTxn(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         case (axiWriteMaster.awaddr(15 downto 0)) is

            when x"0010" => 
               v.config := axiWriteMaster.wdata(6 downto 0);

            when others => null;
         end case;

         -- Send Axi response
         axiSlaveWriteResponse(v.axiWriteSlave);

      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axiReadSlave.rdata := (others => '0');

         case axiReadMaster.araddr(15 downto 0) is

            when X"0000" =>
               v.axiReadSlave.rdata(7 downto 0) := status;

            when X"0010" =>
               v.axiReadSlave.rdata(6 downto 0) := r.config;

            when others => null;
         end case;

         -- Send Axi Response
         axiSlaveReadResponse(v.axiReadSlave);
      end if;

      -- Reset
      if (sysClk125Rst = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      axiReadSlave  <= r.axiReadSlave;
      axiWriteSlave <= r.axiWriteSlave;
      swConfig      <= r.config;
      
   end process;


   -------------------------------------------
   -- XAUI
   -------------------------------------------

   U_ZynqXaui: zynq_10g_xaui
      PORT map (
         dclk                  => sysClk125,
         reset                 => sysClk125Rst,
         clk156_out            => ethClk,
         refclk_p              => ethRefClkP,
         refclk_n              => ethRefClkM,
         clk156_lock           => ethClkLock,
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
         signal_detect         => (others=>'1'),
         debug                 => ethDebug,
         --configuration_vector  => config,
         configuration_vector  => intConfig,
         status_vector         => status
      );

   process (ethConfig,swConfig) begin
      intConfig <= ethConfig or swConfig;

      if rstRxLink = '1' then
         intConfig(3) <= '1';
      end if;

      if rstFault = '1' then
         intConfig(2) <= '1';
      end if;
   end process;

   process (ethClk) begin
      if (rising_edge(ethClk)) then
         rstRxLink    <= (not status(7)) and (not rstRxLinkReg) after TPD_G;
         rstRxLinkReg <= rstRxLink after TPD_G;
         rstFault     <= (status(0) or status(1)) and (not rstFaultReg) after TPD_G;
         rstFaultReg  <= rstFault after TPD_G;
      end if;
   end process;

   U_EthClkRst : entity work.RstSync
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '0',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 3
      ) port map (
         clk      => ethClk,
         asyncRst => ethClkLock,
         syncRst  => ethClkRst
      );

   -------------------------------------------
   -- MAC
   -------------------------------------------



   -------------------------------------------
   -- PPI To MAC
   -------------------------------------------
   U_ObFifo : entity work.PpiFifoAsync
      port map (
         ppiWrClk          => sysClk200,
         ppiWrClkRst       => sysClk200Rst,
         ppiWrOnline       => ppiOnline,
         ppiWriteToFifo    => intWriteToFifo,
         ppiWriteFromFifo  => intWriteFromFifo,
         ppiRdClk          => ethClk,
         ppiRdClkRst       => ethClkRst,
         ppiRdOnline       => ethOnline,
         ppiReadToFifo     => ethReadToFifo,
         ppiReadFromFifo   => ethReadFromFifo
      );

   xauiTxd              <= ethReadFromFifo.data     when ethOnline = '1' else x"0707070707070707";
   xauiTxc(2 downto 0)  <= ethReadFromFifo.size     when ethOnline = '1' else (others=>'1');
   xauiTxc(3)           <= ethReadFromFifo.eof      when ethOnline = '1' else '1';
   xauiTxc(4)           <= ethReadFromFifo.eoh      when ethOnline = '1' else '1';
   xauiTxc(5)           <= ethReadFromFifo.ftype(0) when ethOnline = '1' else '1';
   xauiTxc(6)           <= ethReadFromFifo.valid    when ethOnline = '1' else '1';
   xauiTxc(7)           <= ethReadFromFifo.ready    when ethOnline = '1' else '1';

   ethReadToFifo.read   <= ethReadFromFifo.valid;

   ethWriteToFifo.data  <= xauiRxd;
   ethWriteToFifo.size  <= xauiRxc(2 downto 0);
   ethWriteToFifo.eof   <= xauiRxc(3);
   ethWriteToFifo.eoh   <= xauiRxc(4);
   ethWriteToFifo.err   <= '0';
   ethWriteToFifo.ftype <= xauiRxc(5) & "000";
   ethWriteToFifo.valid <= xauiRxc(6) when ethOnline = '1' else '0';

   U_IbFifo : entity work.PpiFifoAsync
      port map (
         ppiWrClk          => ethClk,
         ppiWrClkRst       => ethClkRst,
         ppiWrOnline       => '0',
         ppiWriteToFifo    => ethWriteToFifo,
         ppiWriteFromFifo  => ethWriteFromFifo,
         ppiRdClk          => sysClk200,
         ppiRdClkRst       => sysClk200Rst,
         ppiRdOnline       => open,
         ppiReadToFifo     => intReadToFifo,
         ppiReadFromFifo   => intReadFromFifo
      );

end architecture structure;

