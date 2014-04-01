-------------------------------------------------------------------------------
-- Title         : PPI To PGP Block, Controller
-- File          : PpiPgpCntrl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to manage the PGP interface.
-- Address map:
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
--    0x20 = Read Only
--       Bits 0 = TX Link Ready
--       Bits 1 = RX Link Ready
--       Bits 2 = Remote Link Ready
--    0x24 = Read Only
--       Bits 7:0 = Sideband data received
--    0x30 = Read Only
--       Bits 7:0 = Rx Cell Error Count
--    0x34 = Read Only
--       Bits 7:0 = Rx Link Down Count
--    0x38 = Read Only
--       Bits 7:0 = Rx Link Error Count
--    0x40 = Read Only
--       Bits 7:0 = TX Frame Count
--    0x44 = Read Only
--       Bits 7:0 = RX Frame Count
--
-- Status vector:
--    Word 1:
--       bits 63:32 = Tx Frame Counter
--       bits 31:00 = Rx Frame Counter
--    Word 0:
--       Bits 63:35 = Zeros
--       Bits 34    = Tx Link ready
--       Bits 33    = Rx Link ready
--       Bits 32    = Rx Remote Link ready
--       Bits 31:24 = Rx Link Data
--       Bits 23:16 = Rx Link Error Count
--       Bits 15:8  = Rx Link Down Count
--       Bits  7:0  = Rx Cell Error Count
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
use work.VcPkg.all;
use work.Pgp2CoreTypesPkg.all;

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
      txFrameCntEn     : in  sl;

      -- RX PGP Interface
      pgpRxClk         : in  sl;
      pgpRxClkRst      : in  sl;
      pgpRxSwRst       : out sl;
      pgpRxIn          : out PgpRxInType;
      pgpRxOut         : in  PgpRxOutType;
      rxFrameCntEn     : in  sl;
     
      -- Status/Axi Clock
      axiStatClk       : in  sl;
      axiStatClkRst    : in  sl;

      -- AXI Interface
      axiWriteMaster   : in  AxiLiteWriteMasterType;
      axiWriteSlave    : out AxiLiteWriteSlaveType;
      axiReadMaster    : in  AxiLiteReadMasterType;
      axiReadSlave     : out AxiLiteReadSlaveType;

      -- Status Bus
      statusWords      : out Slv64Array(1 downto 0);
      statusSend       : out sl
   );
end PpiPgpCntrl;

architecture structure of PpiPgpCntrl is

   -- Local signals
   signal rxCountReset : sl;
   signal txCountReset : sl;
   signal intOnline    : sl;

   type RegType is record
      flush          : sl;
      resetRx        : sl;
      rxClkRst       : sl;
      txClkRst       : sl;
      countReset     : sl;
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
      locData        => (others=>'0'),
      axiWriteSlave  => AXI_WRITE_SLAVE_INIT_C,
      axiReadSlave   => AXI_READ_SLAVE_INIT_C
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
      statusSend     : sl;
   end record RxStatusType;

   constant RX_STATUS_INIT_C : RxStatusType := (
      linkReady      => '0',
      cellErrorCount => (others=>'0'),
      linkDownCount  => (others=>'0'),
      linkErrorCount => (others=>'0'),
      remLinkReady   => '0',
      remLinkData    => (others=>'0'),
      frameCount     => (others=>'0'),
      statusSend     => '0'
   );

   signal rxstatus     : RxStatusType := RX_STATUS_INIT_C;
   signal rxStatusIn   : RxStatusType;
   signal rxStatusSync : RxStatusType;

   type TxStatusType is record
      linkReady      : sl;
      frameCount     : slv(31 downto 0);
   end record TxStatusType;

   constant TX_STATUS_INIT_C : TxStatusType := (
      linkReady      => '0',
      frameCount     => (others=>'0')
   );

   signal txstatus     : TxStatusType := TX_STATUS_INIT_C;
   signal txStatusIn   : TxStatusType;
   signal txStatusSync : TxStatusType;

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

   -- Sync counter reset
   U_RxCountReset : entity work.SynchronizerOneShot 
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1'
      ) port map (
         clk     => pgpRxClk,
         dataIn  => r.countReset,
         dataOut => rxCountReset
      );

   -- Sync
   process (pgpRxClk) is
   begin
      if (rising_edge(pgpRxClk)) then
         rxStatus <= rxStatusIn after TPD_G;
      end if;
   end process;

   -- Async
   process (pgpRxClkRst, rxStatus, pgpRxOut, rxCountReset, rxFrameCntEn ) is
      variable v  : RxStatusType;
   begin
      v := rxStatus;

      v.linkReady    := pgpRxOut.linkReady;
      v.remLinkReady := pgpRxOut.remLinkReady;
      v.remLinkData  := pgpRxOut.remLinkData;
      v.statusSend   := '0';

      if pgpRxOut.cellError = '1' and rxStatus.cellErrorCount /= x"FF" then
         v.cellErrorCount := rxStatus.cellErrorCount + 1;
         v.statusSend     := '1';
      end if;

      if pgpRxOut.linkDown = '1' and rxStatus.linkDownCount /= x"FF" then
         v.linkDownCount := rxStatus.linkDownCount + 1;
         v.statusSend    := '1';
      end if;

      if pgpRxOut.linkError = '1' and rxStatus.linkErrorCount /= x"FF" then
         v.linkErrorCount := rxStatus.linkErrorCount + 1;
         v.statusSend     := '1';
      end if;

      if v.linkReady = '1' and rxStatus.linkReady = '0' then
         v.statusSend := '1';
      end if;

      if rxFrameCntEn = '1' then
         v.frameCount := rxstatus.frameCount + 1;
      end if;

      -- Reset
      if pgpRxClkRst = '1' or rxCountReset = '1' then
         v := RX_STATUS_INIT_C;
      end if;

      -- Next register assignment
      rxStatusIn <= v;

   end process;

   -- Sync status Send
   U_RxSyncStatusSend : entity work.SynchronizerOneShot 
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1'
      ) port map (
         clk     => axiStatClk,
         dataIn  => rxStatus.statusSend,
         dataOut => rxStatusSync.statusSend
      );

   -- Sync Status
   U_RxSyncStatus : entity work.SynchronizerFifo 
      generic map (
         TPD_G         => TPD_G,
         BRAM_EN_G     => false,
         ALTERA_SYN_G  => false,
         ALTERA_RAM_G  => "M9K",
         SYNC_STAGES_G => 3,
         DATA_WIDTH_G  => 66,
         ADDR_WIDTH_G  => 2,
         INIT_G        => "0"
      ) port map (
         rst                => axiStatClkRst,
         wr_clk             => pgpRxClk,
         wr_en              => '1',
         din(7  downto  0)  => rxStatus.cellErrorCount,
         din(15 downto  8)  => rxStatus.linkDownCount,
         din(23 downto 16)  => rxStatus.linkErrorCount,
         din(31 downto 24)  => rxStatus.remLinkData,
         din(63 downto 32)  => rxStatus.frameCount,
         din(64)            => rxStatus.linkReady,
         din(65)            => rxStatus.remLinkReady,
         rd_clk             => axiStatClk,
         rd_en              => '1',
         valid              => open,
         dout(7  downto  0) => rxStatusSync.cellErrorCount,
         dout(15 downto  8) => rxStatusSync.linkDownCount,
         dout(23 downto 16) => rxStatusSync.linkErrorCount,
         dout(31 downto 24) => rxStatusSync.remLinkData,
         dout(63 downto 32) => rxStatusSync.frameCount,
         dout(64)           => rxStatusSync.linkReady,
         dout(65)           => rxStatusSync.remLinkReady
      );


   ---------------------------------------
   -- Transmit Status
   ---------------------------------------

   -- Sync counter reset
   U_TxCountReset : entity work.SynchronizerOneShot 
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1'
      ) port map (
         clk     => pgpTxClk,
         dataIn  => r.countReset,
         dataOut => txCountReset
      );

   -- Sync
   process (pgpTxClk) is
   begin
      if (rising_edge(pgpTxClk)) then
         txStatus <= txStatusIn after TPD_G;
      end if;
   end process;

   -- Async
   process (pgpTxClkRst, txStatus, pgpTxOut, txCountReset, txFrameCntEn ) is
      variable v  : TxStatusType;
   begin
      v := txStatus;

      v.linkReady := pgpTxOut.linkReady;

      if txFrameCntEn = '1' then
         v.frameCount := txstatus.frameCount + 1;
      end if;

      -- Reset
      if pgpTxClkRst = '1' or txCountReset = '1' then
         v := TX_STATUS_INIT_C;
      end if;

      -- Next register assignment
      txStatusIn <= v;

   end process;

   -- Sync Status
   U_TxSyncStatus : entity work.SynchronizerFifo
      generic map (
         TPD_G         => TPD_G,
         BRAM_EN_G     => false,
         ALTERA_SYN_G  => false,
         ALTERA_RAM_G  => "M9K",
         SYNC_STAGES_G => 3,
         DATA_WIDTH_G  => 33,
         ADDR_WIDTH_G  => 2,
         INIT_G        => "0"
      ) port map (
         rst                => axiStatClkRst,
         wr_clk             => pgpTxClk,
         wr_en              => '1',
         din(31 downto  0)  => txStatus.frameCount,
         din(32)            => txStatus.linkReady,
         rd_clk             => axiStatClk,
         rd_en              => '1',
         valid              => open,
         dout(31 downto  0) => txStatusSync.frameCount,
         dout(32)           => txStatusSync.linkReady
      );


   ---------------------------------------
   -- Status Vector
   ---------------------------------------
   statusSend <= rxStatusSync.statusSend;

   statusWords(0)(7  downto  0) <= rxStatusSync.cellErrorCount;
   statusWords(0)(15 downto  8) <= rxStatusSync.linkDownCount;
   statusWords(0)(23 downto 16) <= rxStatusSync.linkErrorCount;
   statusWords(0)(31 downto 24) <= rxStatusSync.remLinkData;
   statusWords(0)(32)           <= rxStatusSync.remLinkReady;
   statusWords(0)(33)           <= rxStatusSync.linkReady;
   statusWords(0)(34)           <= txStatusSync.linkReady;
   statusWords(0)(63 downto 35) <= (others=>'0');
   statusWords(1)(31 downto  0) <= txStatusSync.frameCount;
   statusWords(1)(63 downto 32) <= txStatusSync.frameCount;


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
               v.axireadSlave.rdata(0) := r.resetRx;
            when X"0C" =>
               v.axireadSlave.rdata(0) := r.txClkRst;
            when X"10" =>
               v.axireadSlave.rdata(0) := r.flush;
            when X"14" =>
               v.axireadSlave.rdata(7 downto 0) := r.locData;
            when X"20" =>
               v.axireadSlave.rdata(0) := txStatusSync.linkReady;
               v.axireadSlave.rdata(1) := rxStatusSync.linkReady;
               v.axireadSlave.rdata(2) := rxStatusSync.remLinkReady;
            when X"24" =>
               v.axireadSlave.rdata(7 downto 0) := rxStatusSync.remLinkData;
            when X"30" =>
               v.axireadSlave.rdata(7 downto 0) := rxStatusSync.cellErrorCount;
            when X"34" =>
               v.axireadSlave.rdata(7 downto 0) := rxStatusSync.linkDownCount;
            when X"38" =>
               v.axireadSlave.rdata(7 downto 0) := rxStatusSync.linkErrorCount;
            when X"40" =>
               v.axireadSlave.rdata := txStatusSync.frameCount;
            when X"44" =>
               v.axireadSlave.rdata := rxStatusSync.frameCount;
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
      
   end process;

end architecture structure;

