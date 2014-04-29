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

   signal xauiRxd           : slv(63 downto 0);
   signal xauiRxc           : slv(7  downto 0);
   signal xauiTxd           : slv(63 downto 0);
   signal xauiTxc           : slv(7  downto 0);
   signal phyStatus         : slv(7  downto 0);
   signal swStatus          : slv(7  downto 0);
   signal phyConfig         : slv(6  downto 0);
   signal phyDebug          : slv(5  downto 0);
   signal intReadToFifo     : PpiReadToFifoType;
   signal intReadFromFifo   : PpiReadFromFifoType;
   signal intWriteToFifo    : PpiWriteToFifoType;
   signal intWriteFromFifo  : PpiWriteFromFifoType;
   signal axiWriteMaster    : AxiLiteWriteMasterType;
   signal axiWriteSlave     : AxiLiteWriteSlaveType;
   signal axiReadMaster     : AxiLiteReadMasterType;
   signal axiReadSlave      : AxiLiteReadSlaveType;
   signal statusWords       : Slv64Array(1 downto 0);
   signal statusSend        : sl;
   signal ethClk            : sl;
   signal ethClkRst         : sl;
   signal ethClkLock        : sl;
   signal rstRxLink         : sl;
   signal rstRxLinkReg      : sl;
   signal rstFault          : sl;
   signal rstFaultReg       : sl;
   signal rstCounter        : slv(31 downto 0);
   signal coreReset         : sl;
   signal rxPauseReq        : sl;
   signal rxPauseSet        : sl;
   signal rxPauseValue      : slv(15 downto 0);
   signal txUnderRun        : sl;
   signal txLinkNotReady    : sl;
   signal rxOverFlow        : sl;
   signal rxCrcError        : sl;
   signal rxCountEn         : sl;
   signal rxCount           : slv(31 downto 0);
   signal txCountEn         : sl;
   signal txCount           : slv(31 downto 0);
   signal txFaultCnt        : slv(7  downto 0);
   signal rxFaultCnt        : slv(7  downto 0);
   signal sync0LossCnt      : slv(7  downto 0);
   signal sync1LossCnt      : slv(7  downto 0);
   signal sync2LossCnt      : slv(7  downto 0);
   signal sync3LossCnt      : slv(7  downto 0);
   signal alignLossCnt      : slv(7  downto 0);
   signal linkLossCnt       : slv(7  downto 0);
   signal rxOverflowCnt     : slv(7  downto 0);
   signal rxCrcErrorCnt     : slv(7  downto 0);
   signal txUnderRunCnt     : slv(7  downto 0);
   signal txLinkNotReadyCnt : slv(7  downto 0);
   signal cntOutA           : SlVectorArray(7 downto 0, 11 downto 0);
   signal cntOutB           : SlVectorArray(1 downto 0, 31 downto 0);

   type RegType is record
      countReset        : sl;
      config            : slv(6  downto 0);
      interFrameGap     : slv(3  downto 0);
      pauseTime         : slv(15 downto 0);
      macAddress        : slv(47 downto 0);
      autoStatus        : slv(11 downto 0);
      axiReadSlave      : AxiLiteReadSlaveType;
      axiWriteSlave     : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      countReset        => '0',
      config            => (others=>'0'),
      interFrameGap     => (others=>'0'),
      pauseTime         => (others=>'0'),
      macAddress        => (others=>'0'),
      autoStatus        => (others=>'0'),
      axiReadSlave      => AXI_LITE_READ_SLAVE_INIT_C,
      axiWriteSlave     => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   -- Outputs 
   ethStatus <= phyStatus;
   ethDebug  <= phyDebug;
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


   -------------------------------------------
   -- XAUI
   -------------------------------------------

   U_ZynqXaui: zynq_10g_xaui
      PORT map (
         dclk                  => sysClk125,
         reset                 => coreReset,
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
         debug                 => phyDebug,
         configuration_vector  => phyConfig,
         status_vector         => phyStatus
      );

   -- Status Vector
   -- 0   = Tx Local Fault
   -- 1   = Rx Local Fault
   -- 5:2 = Sync Status
   -- 6   = Alignment
   -- 7   = Rx Link Status

   -- Config Vector
   -- 0   = Loopback
   -- 1   = Power Down
   -- 2   = Reset Local Fault
   -- 3   = Reset Rx Link Status
   -- 4   = Test Enable
   -- 6:5 = Test Pattern

   -- Debug  Vector
   -- 5   = Align Status
   -- 4:1 = Sync Status
   -- 0   = TX Phase Complete

   -- Generate reset for eth clock
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

   -- Master phy reset
   process (sysClk125) begin
      if (rising_edge(sysClk125)) then
         if sysClk125Rst = '1' then
            rstCounter <= (others=>'1') after TPD_G;
            coreReset  <= '1'           after TPD_G;
         elsif phyStatus(7) = '1' then
            rstCounter <= (others=>'1') after TPD_G;
            coreReset  <= '0'           after TPD_G;
         else
            rstCounter <= rstCounter - 1 after TPD_G;

            if rstCounter < 10 then
               coreReset <= '1' after TPD_G;
            else
               coreReset <= '0' after TPD_G;
            end if;
         end if;
      end if;
   end process;

   -- Reset sticky bits
   process (ethClk) begin
      if (rising_edge(ethClk)) then
         rstRxLink    <= (not phyStatus(7)) and (not rstRxLinkReg) after TPD_G;
         rstRxLinkReg <= rstRxLink after TPD_G;
         rstFault     <= (phyStatus(0) or phyStatus(1)) and (not rstFaultReg) after TPD_G;
         rstFaultReg  <= rstFault after TPD_G;
      end if;
   end process;

   -- Combine config vectors
   process (ethConfig,r.config) begin
      phyConfig <= ethConfig or r.config;

      if rstRxLink = '1' then
         phyConfig(3) <= '1';
      end if;

      if rstFault = '1' then
         phyConfig(2) <= '1';
      end if;
   end process;


   -------------------------------------------
   -- RX MAC
   -------------------------------------------
   U_XMacImport : entity work.XMacImport
      generic map (
         TPD_G         => TPD_G,
         PAUSE_THOLD_G => 256, -- 2048 bytes
         ADDR_WIDTH_G  => 9,   -- 4096 bytes
         HEADER_SIZE_G => 16
      ) port map ( 
         ppiRdClk          => sysClk200,
         ppiRdClkRst       => sysClk200Rst,
         ppiOnline         => ppiOnline,
         ppiReadToFifo     => intReadToFifo,
         ppiReadFromFifo   => intReadFromFifo,
         phyClk            => ethClk,
         phyRst            => ethClkRst,
         phyRxd            => xauiRxd,
         phyRxc            => xauiRxc,
         phyReady          => phyStatus(7),
         rxPauseReq        => rxPauseReq,
         rxPauseSet        => rxPauseSet,
         rxPauseValue      => rxPauseValue,
         rxOverFlow        => rxOverFlow,
         rxCrcError        => rxCrcError,
         rxCountEn         => rxCountEn
      );

   -------------------------------------------
   -- TX MAC
   -------------------------------------------
   U_XMacExport : entity work.XMacExport
      generic map (
         TPD_G         => TPD_G,
         PAUSE_THOLD_G => 256, -- 2048 bytes
         ADDR_WIDTH_G  => 9,   -- 4096 bytes
         READY_THOLD_G => 32   -- 256  bytes
      ) port map ( 
         ppiWrClk          => sysClk200,
         ppiWrClkRst       => sysClk200Rst,
         ppiOnline         => ppiOnline,
         ppiWriteToFifo    => intWriteToFifo,
         ppiWriteFromFifo  => intWriteFromFifo,
         phyClk            => ethClk,
         phyRst            => ethClkRst,
         phyTxd            => xauiTxd,
         phyTxc            => xauiTxc,
         phyReady          => phyStatus(7),
         rxPauseReq        => rxPauseReq,
         rxPauseSet        => rxPauseSet,
         rxPauseValue      => rxPauseValue,
         interFrameGap     => r.interFrameGap,
         pauseTime         => r.pauseTime,
         macAddress        => r.macAddress,
         txUnderRun        => txUnderRun,
         txLinkNotReady    => txLinkNotReady,
         txCountEn         => txCountEn
      );


   -------------------------------------------
   -- Counters
   -------------------------------------------

   -- 8 bit status counters and non counted values
   U_RxStatus8Bit : entity work.SyncStatusVector 
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         COMMON_CLK_G    => false,
         RELEASE_DELAY_G => 3,
         IN_POLARITY_G   => "111100000011",
         OUT_POLARITY_G  => '1',
         USE_DSP48_G     => "no",
         SYNTH_CNT_G     => "1",
         CNT_RST_EDGE_G  => false,
         CNT_WIDTH_G     => 8,
         WIDTH_G         => 12
      ) port map (
         statusIn(7 downto 0)   => phyStatus,
         statusIn(8)            => rxOverflow,
         statusIn(9)            => rxCrcError,
         statusIn(10)           => txUnderRun,
         statusIn(11)           => txLinkNotReady,
         statusOut(7 downto 0)  => swStatus,
         --statusOut(11 downto 8) => open,
         cntRstIn               => r.countReset,
         rollOverEnIn           => (others=>'0'),
         cntOut                 => cntOutA,
         irqEnIn                => r.autoStatus,
         irqOut                 => statusSend,
         wrClk                  => ethClk,
         wrRst                  => ethClkRst,
         rdClk                  => sysClk125,
         rdRst                  => sysClk125Rst
      );

   txFaultCnt         <= muxSlVectorArray(cntOutA,0);
   rxFaultCnt         <= muxSlVectorArray(cntOutA,1);
   sync0LossCnt       <= muxSlVectorArray(cntOutA,2);
   sync1LossCnt       <= muxSlVectorArray(cntOutA,3);
   sync2LossCnt       <= muxSlVectorArray(cntOutA,4);
   sync3LossCnt       <= muxSlVectorArray(cntOutA,5);
   alignLossCnt       <= muxSlVectorArray(cntOutA,6);
   linkLossCnt        <= muxSlVectorArray(cntOutA,7);
   rxOverflowCnt      <= muxSlVectorArray(cntOutA,8);
   rxCrcErrorCnt      <= muxSlVectorArray(cntOutA,9);
   txUnderRunCnt      <= muxSlVectorArray(cntOutA,10);
   txLinkNotReadyCnt  <= muxSlVectorArray(cntOutA,11);

   -- 32 bit status counters
   U_RxStatus32Bit : entity work.SyncStatusVector 
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         COMMON_CLK_G    => false,
         RELEASE_DELAY_G => 3,
         IN_POLARITY_G   => "111",
         OUT_POLARITY_G  => '1',
         USE_DSP48_G     => "no",
         SYNTH_CNT_G     => "1",
         CNT_RST_EDGE_G  => false,
         CNT_WIDTH_G     => 32,
         WIDTH_G         => 1
      ) port map (
         statusIn(0)     => rxCountEn,
         statusIn(1)     => txCountEn,
         statusOut       => open,
         cntRstIn        => r.countReset,
         rollOverEnIn    => (others=>'1'),
         cntOut          => cntOutB,
         irqEnIn         => (others=>'0'),
         irqOut          => open,
         wrClk           => ethClk,
         wrRst           => ethClkRst,
         rdClk           => sysClk125,
         rdRst           => sysClk125Rst
      );

   rxCount <= muxSlVectorArray(cntOutB,0);
   rxCount <= muxSlVectorArray(cntOutB,1);


   -------------------------------------------
   -- Status
   -------------------------------------------

   statusWords(1)(63 downto 48) <= (others=>'0');
   statusWords(1)(47 downto 40) <= sync3LossCnt;
   statusWords(1)(39 downto 32) <= sync2LossCnt;
   statusWords(1)(31 downto 24) <= sync1LossCnt;
   statusWords(1)(23 downto 16) <= sync0LossCnt;
   statusWords(1)(15 downto  8) <= rxFaultCnt;
   statusWords(1)(7  downto  0) <= txFaultCnt;

   statusWords(0)(63 downto 56) <= (others=>'0');
   statusWords(0)(55 downto 48) <= alignLossCnt;
   statusWords(0)(47 downto 40) <= txLinkNotReadyCnt;
   statusWords(0)(39 downto 32) <= txUnderRunCnt;
   statusWords(0)(31 downto 24) <= rxCrcErrorCnt;
   statusWords(0)(23 downto 16) <= rxOverflowCnt;
   statusWords(0)(15 downto  8) <= linkLossCnt;
   statusWords(0)(7  downto  0) <= swStatus;


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
   process (sysClk125Rst, axiReadMaster, axiWriteMaster, r, swStatus,
            rxCount, txCount, txFaultCnt, rxFaultCnt, sync0LossCnt, sync1LossCnt,
            sync2LossCnt, sync3LossCnt, alignLossCnt, linkLossCnt, rxOverflowCnt,
            rxCrcErrorCnt, txUnderRunCnt, txLinkNotReadyCnt ) is

      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      axiSlaveWaitTxn(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         case (axiWriteMaster.awaddr(15 downto 0)) is

            when x"0000" => 
               v.countReset := axiWriteMaster.wdata(0);

            when x"0004" => 
               v.config := axiWriteMaster.wdata(6 downto 0);

            when x"0008" => 
               v.interFrameGap := axiWriteMaster.wdata(3 downto 0);

            when x"000C" => 
               v.pauseTime := axiWriteMaster.wdata(15 downto 0);

            when x"0010" => 
               v.macAddress(31 downto 0) := axiWriteMaster.wdata;

            when x"0014" => 
               v.macAddress(47 downto 32) := axiWriteMaster.wdata(15 downto 0);

            when x"0018" => 
               v.autoStatus(11 downto 0) := axiWriteMaster.wdata(11 downto 0);

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
               v.axiReadSlave.rdata(0) := r.countReset;

            when X"0004" =>
               v.axiReadSlave.rdata(6 downto 0) := r.config;

            when X"0008" =>
               v.axiReadSlave.rdata(3 downto 0) := r.interFrameGap;

            when X"000C" =>
               v.axiReadSlave.rdata(15 downto 0) := r.pauseTime;

            when X"0010" =>
               v.axiReadSlave.rdata := r.macAddress(31 downto 0);

            when X"0014" =>
               v.axiReadSlave.rdata(15 downto 0) := r.macAddress(47 downto 32);

            when X"0018" =>
               v.axiReadSlave.rdata(11 downto 0) := r.autoStatus;

            when X"1000" =>
               v.axiReadSlave.rdata(7 downto 0) := swStatus;

            when X"1004" =>
               v.axiReadSlave.rdata := rxCount;

            when X"1008" =>
               v.axiReadSlave.rdata := txCount;

            when X"100C" =>
               v.axiReadSlave.rdata(7 downto 0) := txFaultCnt;

            when X"1010" =>
               v.axiReadSlave.rdata(7 downto 0) := rxFaultCnt;

            when X"1014" =>
               v.axiReadSlave.rdata(7 downto 0) := sync0LossCnt;

            when X"1018" =>
               v.axiReadSlave.rdata(7 downto 0) := sync1LossCnt;

            when X"101C" =>
               v.axiReadSlave.rdata(7 downto 0) := sync2LossCnt;

            when X"101C" =>
               v.axiReadSlave.rdata(7 downto 0) := sync3LossCnt;

            when X"1020" =>
               v.axiReadSlave.rdata(7 downto 0) := alignLossCnt;

            when X"1024" =>
               v.axiReadSlave.rdata(7 downto 0) := linkLossCnt;

            when X"1028" =>
               v.axiReadSlave.rdata(7 downto 0) := rxOverflowCnt;

            when X"102C" =>
               v.axiReadSlave.rdata(7 downto 0) := rxCrcErrorCnt;

            when X"1030" =>
               v.axiReadSlave.rdata(7 downto 0) := txUnderRunCnt;

            when X"1034" =>
               v.axiReadSlave.rdata(7 downto 0) := txLinkNotReadyCnt;

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
      
   end process;

end architecture structure;

