-------------------------------------------------------------------------------
-- Title         : 10 Gige Ethernet Core
-- File          : XMac.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 09/03/2013
-------------------------------------------------------------------------------
-- Description:
-- 10G Ethernet MAC
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

use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.StdRtlPkg.all;

entity XMac is
   generic (
      TPD_G            : time                := 1 ns;
      IB_ADDR_WIDTH_G  : integer             := 9;
      OB_ADDR_WIDTH_G  : integer             := 9;
      PAUSE_THOLD_G    : integer             := 255;
      VALID_THOLD_G    : integer             := 0;
      EOH_BIT_G        : integer             := 0;
      ERR_BIT_G        : integer             := 0;
      HEADER_SIZE_G    : integer             := 16;
      AXIS_CONFIG_G    : AxiStreamConfigType := AXI_STREAM_CONFIG_INIT_C
   );
   port (

      -- PPI Interface
      xmacRst                 : in  sl;
      dmaClk                  : in  sl;
      dmaClkRst               : in  sl;
      dmaIbMaster             : out AxiStreamMasterType;
      dmaIbSlave              : in  AxiStreamSlaveType;
      dmaObMaster             : in  AxiStreamMasterType;
      dmaObSlave              : out AxiStreamSlaveType;

      -- AXI Lite & Status Interface
      axilClk                 : in  sl;
      axilClkRst              : in  sl;
      axilWriteMaster         : in  AxiLiteWriteMasterType;
      axilWriteSlave          : out AxiLiteWriteSlaveType;
      axilReadMaster          : in  AxiLiteReadMasterType;
      axilReadSlave           : out AxiLiteReadSlaveType;
      statusWord              : out slv(63 downto 0);
      statusSend              : out sl;

      -- Ref Clock
      ethRefClkP              : in  sl;
      ethRefClkM              : in  sl;

      -- Ethernet Lines
      ethRxP                  : in  slv(3 downto 0);
      ethRxM                  : in  slv(3 downto 0);
      ethTxP                  : out slv(3 downto 0);
      ethTxM                  : out slv(3 downto 0)
   );
end XMac;

architecture structure of XMac is

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
   signal phyDebug          : slv(5  downto 0);
   signal ethClk            : sl;
   signal ethClkRst         : sl;
   signal ethClkLock        : sl;
   signal rxPauseReq        : sl;
   signal rxPauseSet        : sl;
   signal rxPauseValue      : slv(15 downto 0);
   signal txUnderRun        : sl;
   signal txLinkNotReady    : sl;
   signal rxOverFlow        : sl;
   signal rxCrcError        : sl;
   signal rxCountEn         : sl;
   signal txCountEn         : sl;
   signal cntOutA           : SlVectorArray(11 downto 0,  7 downto 0);
   signal cntOutB           : SlVectorArray(1  downto 0, 31 downto 0);
   signal phyReset          : sl;

   type RegType is record
      countReset        : sl;
      phyReset          : sl;
      config            : slv(6  downto 0);
      interFrameGap     : slv(3  downto 0);
      pauseTime         : slv(15 downto 0);
      macAddress        : slv(47 downto 0);
      autoStatus        : slv(11 downto 0);
      scratchA          : slv(31 downto 0);
      scratchB          : slv(31 downto 0);
      byteSwap          : sl;
      axilReadSlave     : AxiLiteReadSlaveType;
      axilWriteSlave    : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      countReset        => '0',
      phyReset          => '1',
      config            => (others=>'0'),
      interFrameGap     => (others=>'1'),
      pauseTime         => (others=>'1'),
      macAddress        => (others=>'0'),
      autoStatus        => (others=>'0'),
      scratchA          => (others=>'0'),
      scratchB          => (others=>'0'),
      byteSwap          => '0',
      axilReadSlave     => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave    => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   -------------------------------------------
   -- XAUI
   -------------------------------------------
   phyReset <= r.phyReset or xmacRst;

   U_ZynqXaui: zynq_10g_xaui
      PORT map (
         dclk                  => axilClk,
         reset                 => phyReset,
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
         configuration_vector  => r.config,
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


   -------------------------------------------
   -- RX MAC
   -------------------------------------------
   U_XMacImport : entity work.XMacImport
      generic map (
         TPD_G          => TPD_G,
         PAUSE_THOLD_G  => PAUSE_THOLD_G,
         ADDR_WIDTH_G   => IB_ADDR_WIDTH_G,
         EOH_BIT_G      => EOH_BIT_G,
         ERR_BIT_G      => ERR_BIT_G,
         HEADER_SIZE_G  => HEADER_SIZE_G,
         AXIS_CONFIG_G  => AXIS_CONFIG_G
      ) port map ( 
         dmaClk        => dmaClk,
         dmaClkRst     => dmaClkRst,
         dmaIbMaster   => dmaIbMaster,
         dmaIbSlave    => dmaIbSlave,
         phyClk        => ethClk,
         phyRst        => ethClkRst,
         phyRxd        => xauiRxd,
         phyRxc        => xauiRxc,
         phyReady      => phyStatus(7),
         macAddress    => r.macAddress,
         byteSwap      => r.byteSwap,
         rxPauseReq    => rxPauseReq,
         rxPauseSet    => rxPauseSet,
         rxPauseValue  => rxPauseValue,
         rxCountEn     => rxCountEn,
         rxOverFlow    => rxOverFlow,
         rxCrcError    => rxCrcError
      );

   -------------------------------------------
   -- TX MAC
   -------------------------------------------
   U_XMacExport : entity work.XMacExport
      generic map (
         TPD_G          => TPD_G,
         ADDR_WIDTH_G   => OB_ADDR_WIDTH_G,
         VALID_THOLD_G  => VALID_THOLD_G,
         AXIS_CONFIG_G  => AXIS_CONFIG_G
      ) port map ( 
         dmaClk            => dmaClk,
         dmaClkRst         => dmaClkRst,
         dmaObMaster       => dmaObMaster,
         dmaObSlave        => dmaObSlave,
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
         byteSwap          => r.byteSwap,
         txCountEn         => txCountEn,
         txUnderRun        => txUnderRun,
         txLinkNotReady    => txLinkNotReady
      );

   -------------------------------------------
   -- Counters
   -------------------------------------------

   -- 8 bit status counters
   U_RxStatus8Bit : entity work.SyncStatusVector 
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         COMMON_CLK_G    => false,
         RELEASE_DELAY_G => 3,
         IN_POLARITY_G   => "1",
         OUT_POLARITY_G  => '1',
         USE_DSP48_G     => "no",
         SYNTH_CNT_G     => "000000001111",
         CNT_RST_EDGE_G  => false,
         CNT_WIDTH_G     => 8,
         WIDTH_G         => 12 
      ) port map (
         statusIn(0)            => rxOverflow,
         statusIn(1)            => rxCrcError,
         statusIn(2)            => txUnderRun,
         statusIn(3)            => txLinkNotReady,
         statusIn(11 downto 4)  => phyStatus,
         statusOut              => open,
         cntRstIn               => r.countReset,
         rollOverEnIn           => (others=>'0'),
         cntOut                 => cntOutA,
         irqEnIn                => r.autoStatus,
         irqOut                 => statusSend,
         wrClk                  => ethClk,
         wrRst                  => ethClkRst,
         rdClk                  => axilClk,
         rdRst                  => axilClkRst
      );

   -- 32 bit status counters
   U_RxStatus32Bit : entity work.SyncStatusVector 
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         COMMON_CLK_G    => false,
         RELEASE_DELAY_G => 3,
         IN_POLARITY_G   => "1",
         OUT_POLARITY_G  => '1',
         USE_DSP48_G     => "no",
         SYNTH_CNT_G     => "1",
         CNT_RST_EDGE_G  => false,
         CNT_WIDTH_G     => 32,
         WIDTH_G         => 2
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
         rdClk           => axilClk,
         rdRst           => axilClkRst
      );

   -------------------------------------------
   -- Status
   -------------------------------------------
   statusWord(63 downto 40) <= (others=>'0');
   statusWord(39 downto 32) <= muxSlVectorArray(cntOutA,0);
   statusWord(31 downto 24) <= muxSlVectorArray(cntOutA,1);
   statusWord(23 downto 16) <= muxSlVectorArray(cntOutA,2);
   statusWord(15 downto  8) <= muxSlVectorArray(cntOutA,3);
   statusWord(7  downto  0) <= phyStatus;


   -------------------------------------------
   -- Local Registers
   -------------------------------------------

   -- Sync
   process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (axilClkRst, axilReadMaster, axilWriteMaster, r, phyStatus, phyDebug, cntOutA, cntOutB ) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      axiSlaveWaitTxn(axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         case (axilWriteMaster.awaddr(15 downto 0)) is

            when x"0000" => 
               v.countReset := axilWriteMaster.wdata(0);

            when x"0004" => 
               v.phyReset := axilWriteMaster.wdata(0);

            when x"0008" => 
               v.config := axilWriteMaster.wdata(6 downto 0);

            when x"000C" => 
               v.interFrameGap := axilWriteMaster.wdata(3 downto 0);

            when x"0010" => 
               v.pauseTime := axilWriteMaster.wdata(15 downto 0);

            when x"0014" => 
               v.macAddress(31 downto 0) := axilWriteMaster.wdata;

            when x"0018" => 
               v.macAddress(47 downto 32) := axilWriteMaster.wdata(15 downto 0);

            when x"001C" => 
               v.autoStatus := axilWriteMaster.wdata(11 downto 0);

            when x"0028" => 
               v.byteSwap := axilWriteMaster.wdata(0);

            when x"0030" => 
               v.scratchA := axilWriteMaster.wdata;

            when x"0034" => 
               v.scratchB := axilWriteMaster.wdata;

            when others => null;
         end case;

         -- Send Axi response
         axiSlaveWriteResponse(v.axilWriteSlave);

      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axilReadSlave.rdata := (others => '0');

         case axilReadMaster.araddr(15 downto 8) is
            when x"00" =>
               case axilReadMaster.araddr(7 downto 0) is

                  when X"00" =>
                     v.axilReadSlave.rdata(0) := r.countReset;

                  when X"04" =>
                     v.axilReadSlave.rdata(0) := r.phyReset;

                  when X"08" =>
                     v.axilReadSlave.rdata(6 downto 0) := r.config;

                  when X"0C" =>
                     v.axilReadSlave.rdata(3 downto 0) := r.interFrameGap;

                  when X"10" =>
                     v.axilReadSlave.rdata(15 downto 0) := r.pauseTime;

                  when X"14" =>
                     v.axilReadSlave.rdata := r.macAddress(31 downto 0);

                  when X"18" =>
                     v.axilReadSlave.rdata(15 downto 0) := r.macAddress(47 downto 32);

                  when X"1C" =>
                     v.axilReadSlave.rdata(11 downto 0) := r.autoStatus;

                  when X"20" =>
                     v.axilReadSlave.rdata(7 downto 0) := phyStatus;

                  when X"24" =>
                     v.axilReadSlave.rdata(5 downto 0) := phyDebug;

                  when X"28" =>
                     v.axilReadSlave.rdata(0) := r.byteSwap;

                  when X"30" =>
                     v.axilReadSlave.rdata := r.scratchA;

                  when X"34" =>
                     v.axilReadSlave.rdata := r.scratchB;

                  when others => null;
               end case;

            when X"01" =>
               v.axilReadSlave.rdata := muxSlVectorArray(cntOutB,conv_integer(axilReadMaster.araddr(2)));
               -- 0x0100 = rxCount
               -- 0x0104 = txCount

            when X"02" =>
               v.axilReadSlave.rdata(7 downto 0) := muxSlVectorArray(cntOutA,conv_integer(axilReadMaster.araddr(3 downto 2)));
               -- 0x0200 = rxOverflowCnt
               -- 0x0204 = rxCrcErrorCnt
               -- 0x0208 = txUnderRunCnt
               -- 0x020C = txLinkNotReadyCnt

            when others => null;
         end case;

         -- Send Axi Response
         axiSlaveReadResponse(v.axilReadSlave);
      end if;

      -- Reset
      if (axilClkRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      axilReadSlave  <= r.axilReadSlave;
      axilWriteSlave <= r.axilWriteSlave;
      
   end process;

end architecture structure;

