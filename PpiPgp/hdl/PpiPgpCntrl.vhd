-------------------------------------------------------------------------------
-- Title         : PPI To PGP Block, Controller
-- File          : PpiPgpCntrl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to manage the PGP interface.
-- Address map (offset from base):
--    0x00 = Write Only, Count Reset On Write
--    0x04 = Read/Write
--       Bits 0 = Rx Clock Reset
--    0x08 = Read/Write
--       Bits 0 = Rx Reset
--    0x0C = Read/Write
--       Bits 0 = Tx Clock Reset
--    0x10 = Read/Write
--       Bits 0 = Tx/Rx Flush
--    0x14 = Read/Write
--       Bits 7:0 = Sideband data to transmit
--    0x18 = Read/Write
--       Bits   0 = Loopback Enable
--    0x1C = Read/Write
--       Bits   0 = Auto status send enable
--    0x20 = Read Only
--       Bits 0 = TX Link Ready
--       Bits 1 = RX Link Ready
--       Bits 2 = Remote Link Ready
--       Bits 3 = Receiver dropping frames
--       Bits 4 = Remove overflow flag
--    0x24 = Read Only
--       Bits 7:0 = Sideband data received
--    0x30 = Read Only
--       Bits 7:0 = Rx Cell Error Count
--    0x34 = Read Only
--       Bits 7:0 = Rx Link Down Count
--    0x38 = Read Only
--       Bits 7:0 = Rx Link Error Count
--    0x3C = Read Only
--       Bits 7:0 = Rx Drop Count
--    0x40 = Read Only
--       Bits 31:0 = TX Frame Count
--    0x44 = Read Only
--       Bits 31:0 = RX Frame Count
--    0x48 = Read Only
--       Bits 7:0 = RX Overflow Count
--
-- Status vector:
--       Bits 31:24 = Rx Link Down Count
--       Bits 23:16 = Rx Drop Count
--       Bits 15:8  = Rx Cell Error Count
--       Bits  7:4  = Zeros
--       Bits    3  = Remote Overflow
--       Bits    2  = RX Overflow
--       Bits    1  = Rx Remote Link ready
--       Bits    0  = Rx Link ready
-------------------------------------------------------------------------------
-- Copyright (c) 2014 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 03/21/2014: created.
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
use work.AxiLitePkg.all;
use work.Pgp2bPkg.all;

entity PpiPgpCntrl is
   generic (
      TPD_G   : time := 1 ns
   );
   port (

      -- PPI Online
      ppiOnline        : in  sl;

      -- TX PGP Interface
      pgpTxClk         : in  sl;
      pgpTxClkRst      : in  sl;
      pgpTxSwRst       : out sl;
      pgpTxIn          : out PgpTxInType;
      pgpTxOut         : in  PgpTxOutType;
      remOverflow      : in  sl;
      txFrameCntEn     : in  sl;

      -- RX PGP Interface
      pgpRxClk         : in  sl;
      pgpRxClkRst      : in  sl;
      pgpRxSwRst       : out sl;
      pgpRxIn          : out PgpRxInType;
      pgpRxOut         : in  PgpRxOutType;
      rxFrameCntEn     : in  sl;
      rxDropCountEn    : in  sl;
      rxOverflow       : in  sl;
      loopBackEn       : out sl;
     
      -- Status/Axi Clock
      axiStatClk       : in  sl;
      axiStatClkRst    : in  sl;

      -- AXI Interface
      axiWriteMaster   : in  AxiLiteWriteMasterType;
      axiWriteSlave    : out AxiLiteWriteSlaveType;
      axiReadMaster    : in  AxiLiteReadMasterType;
      axiReadSlave     : out AxiLiteReadSlaveType;

      -- Status Bus
      statusWord       : out slv(31 downto 0);
      statusSend       : out sl
   );
end PpiPgpCntrl;

architecture structure of PpiPgpCntrl is

   -- Local signals
   signal intOnline    : sl;
   signal rxStatusSend : sl;
   signal txStatusSend : sl;

   type RegType is record
      flush          : sl;
      resetRx        : sl;
      rxClkRst       : sl;
      txClkRst       : sl;
      countReset     : sl;
      loopBackEn     : sl;
      autoStatus     : sl;
      locData        : slv(7 downto 0);
      axiWriteSlave  : AxiLiteWriteSlaveType;
      axiReadSlave   : AxiLiteReadSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      flush          => '0',
      resetRx        => '1',
      rxClkRst       => '1',
      txClkRst       => '1',
      countReset     => '0',
      autoStatus     => '0',
      loopBackEn     => '0',
      locData        => (others=>'0'),
      axiWriteSlave  => AXI_LITE_WRITE_SLAVE_INIT_C,
      axiReadSlave   => AXI_LITE_READ_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   type RxStatusType is record
      linkReady      : sl;
      cellErrorCount : slv(7  downto 0);
      linkDownCount  : slv(7  downto 0);
      linkErrorCount : slv(7  downto 0);
      remLinkReady   : sl;
      remLinkData    : slv(7  downto 0);
      frameCount     : slv(31 downto 0);
      dropCount      : slv(7  downto 0);
      rxOverflow     : sl;
   end record RxStatusType;

   signal rxstatusSync : RxStatusType;

   type TxStatusType is record
      linkReady      : sl;
      remOverflow    : sl;
      remOverflowCnt : slv(7 downto 0);
      frameCount     : slv(31 downto 0);
   end record TxStatusType;

   signal txstatusSync : TxStatusType;

begin

   ---------------------------------------
   -- Online Sync
   ---------------------------------------
   U_OnlineSync : entity work.Synchronizer 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         OUT_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 2,
         INIT_G         => "0"
      ) port map (
         clk         => axiStatClk,
         rst         => axiStatClkRst,
         dataIn      => ppiOnline,
         dataOut     => intOnline
      );


   ---------------------------------------
   -- Receive Status
   ---------------------------------------

   -- Sync remote data
   U_RxDataSync : entity work.SyncStatusFifo 
      generic map (
         TPD_G         => TPD_G,
         BRAM_EN_G     => false,
         ALTERA_SYN_G  => false,
         ALTERA_RAM_G  => "M9K",
         SYNC_STAGES_G => 3,
         DATA_WIDTH_G  => 8,
         ADDR_WIDTH_G  => 2,
         INIT_G        => "0"
      ) port map (
         rst           => axiStatClkRst,
         wr_clk        => pgpRxClk,
         wr_en         => '1',
         din           => pgpRxOut.remLinkData,
         rd_clk        => axiStatClk,
         rd_en         => '1',
         valid         => open,
         dout          => rxStatusSync.remLinkData
      );

   -- 8 bit status counters and non counted values
   U_RxStatus8Bit : entity work.SyncStatusVector 
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         COMMON_CLK_G    => false,
         RELEASE_DELAY_G => 3,
         IN_POLARITY_G   => "1",
         OUT_POLARITY_G  => '1',
         USE_DSP48_G     => "no",
         SYNTH_CNT_G     => "1111000",
         CNT_RST_EDGE_G  => false,
         CNT_WIDTH_G     => 8,
         WIDTH_G         => 7
      ) port map (
         statusIn(0)           => pgpRxOut.linkReady,
         statusIn(1)           => pgpRxOut.remLinkReady,
         statusIn(2)           => rxOverflow,
         statusIn(3)           => pgpRxOut.cellError,
         statusIn(4)           => pgpRxOut.linkDown,
         statusIn(5)           => pgpRxOut.linkError,
         statusIn(6)           => rxDropCountEn,
         statusOut(0)          => rxStatusSync.linkReady,
         statusOut(1)          => rxStatusSync.remLinkReady,
         statusOut(2)          => rxStatusSync.rxOverflow,
         statusOut(6 downto 3) => open,
         cntRstIn              => r.countReset,
         rollOverEnIn          => (others=>'0'),
         cntOut(2 downto 0)    => open,
         cntOut(3)             => rxStatusSync.cellErrorCount,
         cntOut(4)             => rxStatusSync.linkDownCount,
         cntOut(5)             => rxStatusSync.linkErrorCount,
         cntOut(6)             => rxStatusSync.dropCount,
         irqEnIn               => (others=>r.autoStatus),
         irqOut                => rxStatusSend,
         wrClk                 => pgpRxClk,
         wrRst                 => pgpRxClkRst,
         rdClk                 => axiStatClk,
         rdRst                 => axiStatClkRst
      );

   signal cntOut(6 downto 0,7 downto 0);


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
         statusIn(0)     => rxFrameCntEn,
         statusOut       => open,
         cntRstIn        => r.countReset,
         rollOverEnIn    => (others=>'1'),
         cntOut(0)       => rxStatusSync.frameCount,
         irqEnIn         => (others=>'0'),
         irqOut          => open,
         wrClk           => pgpRxClk,
         wrRst           => pgpRxClkRst,
         rdClk           => axiStatClk,
         rdRst           => axiStatClkRst
      );


   ---------------------------------------
   -- Transmit Status
   ---------------------------------------

   -- 8 bit status counters and non counted values
   U_TxStatus8Bit : entity work.SyncStatusVector 
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         COMMON_CLK_G    => false,
         RELEASE_DELAY_G => 3,
         IN_POLARITY_G   => "1",
         OUT_POLARITY_G  => '1',
         USE_DSP48_G     => "no",
         SYNTH_CNT_G     => "10",
         CNT_RST_EDGE_G  => false,
         CNT_WIDTH_G     => 8,
         WIDTH_G         => 2
      ) port map (
         statusIn(0)           => pgpTxOut.linkReady,
         statusIn(1)           => remOverflow,
         statusOut(0)          => txStatusSync.linkReady,
         statusOut(1)          => txStatusSync.remOverflow,
         cntRstIn              => r.countReset,
         rollOverEnIn          => (others=>'0'),
         cntOut(0)             => open,
         cntOut(1)             => txStatusSync.remOverflowCnt,
         irqEnIn               => (others=>r.autoStatus),
         irqOut                => txStatusSend,
         wrClk                 => pgpTxClk,
         wrRst                 => pgpTxClkRst,
         rdClk                 => axiStatClk,
         rdRst                 => axiStatClkRst
      );

   -- 32 bit status counters
   U_TxStatus4Bit : entity work.SyncStatusVector 
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
         statusIn(0)     => txFrameCntEn,
         statusOut       => open,
         cntRstIn        => r.countReset,
         rollOverEnIn    => (others=>'1'),
         cntOut(0)       => txStatusSync.frameCount,
         irqEnIn         => (others=>'0'),
         irqOut          => open,
         wrClk           => pgpTxClk,
         wrRst           => pgpTxClkRst,
         rdClk           => axiStatClk,
         rdRst           => axiStatClkRst
      );


   ---------------------------------------
   -- Status Vector
   ---------------------------------------
   statusSend <= rxStatusSend or txStatusSend;

   statusWord(31 downto 24) <= rxStatusSync.linkDownCount;
   statusWord(23 downto 16) <= rxStatusSync.dropCount;
   statusWord(15 downto  8) <= rxStatusSync.cellErrorCount;
   statusWord(7  downto  4) <= (others=>'0');
   statusWord(3)            <= rxStatusSync.remOverflow;
   statusWord(2)            <= rxStatusSync.rxOverflow;
   statusWord(1)            <= rxStatusSync.remLinkReady;
   statusWord(0)            <= rxStatusSync.linkReady;


   -------------------------------------
   -- Tx Control Sync
   -------------------------------------

   -- Sync Tx Control
   U_TxCntrlStatus : entity work.SynchronizerFifo 
      generic map (
         TPD_G         => TPD_G,
         BRAM_EN_G     => false,
         ALTERA_SYN_G  => false,
         ALTERA_RAM_G  => "M9K",
         SYNC_STAGES_G => 3,
         DATA_WIDTH_G  => 10,
         ADDR_WIDTH_G  => 2,
         INIT_G        => "0"
      ) port map (
         rst     => axiStatClkRst,
         wr_clk  => axiStatClk,
         wr_en   => '1',
         din     => r.locData,
         rd_clk  => pgpTxClk,
         rd_en   => '1',
         valid   => open,
         dout    => pgptxIn.locData
      );

   -- Reset Sync
   U_TxRstSync: entity work.RstSync 
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '1',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 3
      ) port map (
         clk      => pgpTxClk,
         asyncRst => r.txClkRst,
         syncRst  => pgpTxSwRst
      );

   -- Flush Sync
   U_TxFlushSync: entity work.RstSync 
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '1',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 3
      ) port map (
         clk      => pgpTxClk,
         asyncRst => r.flush,
         syncRst  => pgpTxIn.flush
      );

   -- Unused, overridden externally
   pgpTxIn.opCodeEn     <= '0';
   pgpTxIn.opCode       <= (others=>'0');
   pgpTxIn.locLinkReady <= '0';


   -------------------------------------
   -- Rx Control Sync
   -------------------------------------

   -- Reset Sync
   U_RxRstSync: entity work.RstSync 
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '1',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 3
      ) port map (
         clk      => pgpRxClk,
         asyncRst => r.rxClkRst,
         syncRst  => pgpRxSwRst
      );

   -- Flush Sync
   U_RxFlushSync: entity work.RstSync 
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '1',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 3
      ) port map (
         clk      => pgpRxClk,
         asyncRst => r.flush,
         syncRst  => pgpRxIn.flush
      );

   -- Reset Rx Sync
   U_ResetRxSync: entity work.RstSync 
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '1',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 3
      ) port map (
         clk      => pgpRxClk,
         asyncRst => r.resetRx,
         syncRst  => pgpRxIn.resetRx
      );


   ------------------------------------
   -- AXI Registers
   ------------------------------------

   -- Sync
   process (axiStatClk) is
   begin
      if (rising_edge(axiStatClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (axiStatClkRst, axiReadMaster, axiWriteMaster, r, intOnline, rxStatusSync, txStatusSync) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      v.countReset := '0';

      axiSlaveWaitTxn(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Decode address and perform write
         case (axiWriteMaster.awaddr(7 downto 0)) is
            when X"00" =>
               v.countReset := '1';
            when X"04" =>
               v.rxClkRst   := axiWriteMaster.wdata(0);
            when X"08" =>
               v.resetRx    := axiWriteMaster.wdata(0);
            when X"0C" =>
               v.txClkRst   := axiWriteMaster.wdata(0);
            when X"10" =>
               v.flush      := axiWriteMaster.wdata(0);
            when X"14" =>
               v.locData    := axiWriteMaster.wdata(7 downto 0);
            when X"18" =>
               v.loopBackEn := axiWriteMaster.wdata(0);
            when X"1C" =>
               v.autoStatus := axiWriteMaster.wdata(0);
            when others => null;
         end case;

         -- Send Axi response
         axiSlaveWriteResponse(v.axiWriteSlave);
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axiReadSlave.rdata := (others => '0');

         -- Decode address and assign read data
         case axiReadMaster.araddr(7 downto 0) is
            when X"04" =>
               v.axiReadSlave.rdata(0) := r.rxClkRst;
            when X"08" =>
               v.axiReadSlave.rdata(0) := r.resetRx;
            when X"0C" =>
               v.axiReadSlave.rdata(0) := r.txClkRst;
            when X"10" =>
               v.axiReadSlave.rdata(0) := r.flush;
            when X"14" =>
               v.axiReadSlave.rdata(7 downto 0) := r.locData;
            when X"18" =>
               v.axiReadSlave.rdata(0) := r.loopBackEn;
            when X"1C" =>
               v.axiReadSlave.rdata(0) := r.autoStatus;
            when X"20" =>
               v.axiReadSlave.rdata(0) := txStatusSync.linkReady;
               v.axiReadSlave.rdata(1) := rxStatusSync.linkReady;
               v.axiReadSlave.rdata(2) := rxStatusSync.remLinkReady;
               v.axiReadSlave.rdata(3) := rxStatusSync.rxOverflow;
               v.axiReadSlave.rdata(4) := txStatusSync.remOverflow;
            when X"24" =>
               v.axiReadSlave.rdata(7 downto 0) := rxStatusSync.remLinkData;
            when X"30" =>
               v.axiReadSlave.rdata(7 downto 0) := rxStatusSync.cellErrorCount;
            when X"34" =>
               v.axiReadSlave.rdata(7 downto 0) := rxStatusSync.linkDownCount;
            when X"38" =>
               v.axiReadSlave.rdata(7 downto 0) := rxStatusSync.linkErrorCount;
            when X"3C" =>
               v.axiReadSlave.rdata(7 downto 0) := rxStatusSync.dropCount;
            when X"40" =>
               v.axiReadSlave.rdata := txStatusSync.frameCount;
            when X"44" =>
               v.axiReadSlave.rdata := rxStatusSync.frameCount;
            when X"48" =>
               v.axiReadSlave.rdata(7 downto 0) := txStatusSync.remOverflowCnt;
            when others => null;
         end case;

         -- Send Axi Response
         axiSlaveReadResponse(v.axiReadSlave);
      end if;

      -- Reset
      if (axiStatClkRst = '1' or intOnline = '0') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      axiReadSlave  <= r.axiReadSlave;
      axiWriteSlave <= r.axiWriteSlave;
      loopBackEn    <= r.loopBackEn;
      
   end process;

end architecture structure;

