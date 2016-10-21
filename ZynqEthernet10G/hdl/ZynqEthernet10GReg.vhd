-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : ZynqEthernet10GReg.vhd
-- Author     : Ryan Herbst <rherbst@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-09-03
-- Last update: 2016-10-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Zynq Ethernet 10G Registers
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE 10G Ethernet Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE 10G Ethernet Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.PpiPkg.all;
use work.RceG3Pkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.StdRtlPkg.all;
use work.EthMacPkg.all;

entity ZynqEthernet10GReg is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- AXI Lite Buses
      axilClk         : in  sl;
      axilClkRst      : in  sl;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      -- Config/Status signals
      dmaClk          : in  sl;
      dmaClkRst       : in  sl;
      ethClk          : in  sl;
      ethClkRst       : in  sl;
      phyStatus       : in  slv(7 downto 0);
      phyDebug        : in  slv(5 downto 0);
      phyConfig       : out slv(6 downto 0);
      phyReset        : out sl;
      ethHeaderSize   : out slv(15 downto 0);
      txShift         : out slv(3 downto 0);
      rxShift         : out slv(3 downto 0);
      macConfig       : out EthMacConfigType;
      macStatus       : in  EthMacStatusType;
      ipAddr          : out slv(31 downto 0));
end ZynqEthernet10GReg;

architecture structure of ZynqEthernet10GReg is

   constant STATUS_SIZE_C : positive                      := 17;
   constant ROLL_OVER_C   : slv(STATUS_SIZE_C-1 downto 0) := toSlv(3, STATUS_SIZE_C);

   type RegType is record
      countReset     : sl;
      phyReset       : sl;
      config         : slv(6 downto 0);
      pauseTime      : slv(15 downto 0);
      macAddress     : slv(47 downto 0);
      ipAddr         : slv(31 downto 0);
      rxShift        : slv(3 downto 0);
      txShift        : slv(3 downto 0);
      filtEnable     : sl;
      ipCsumEn       : sl;
      tcpCsumEn      : sl;
      udpCsumEn      : sl;
      dropOnPause    : sl;
      ethHeaderSize  : slv(15 downto 0);
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      countReset     => '0',
      phyReset       => '1',
      config         => (others => '0'),
      pauseTime      => (others => '1'),
      macAddress     => (others => '0'),
      ipAddr         => (others => '0'),
      rxShift        => (others => '0'),
      txShift        => (others => '0'),
      filtEnable     => '0',
      ipCsumEn       => '1',
      tcpCsumEn      => '1',
      udpCsumEn      => '1',
      dropOnPause    => '0',
      ethHeaderSize  => x"000F",
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal statusCnt : SlVectorArray(STATUS_SIZE_C-1 downto 0, 31 downto 0);

begin

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
         WIDTH_G         => STATUS_SIZE_C) 
      port map (
         statusIn(0)           => macStatus.rxCountEn,
         statusIn(1)           => macStatus.txCountEn,
         statusIn(2)           => macStatus.rxpauseCnt,
         statusIn(3)           => macStatus.txPauseCnt,
         statusIn(4)           => macStatus.rxOverflow,
         statusIn(5)           => macStatus.rxCrcErrorCnt,
         statusIn(6)           => macStatus.txUnderRunCnt,
         statusIn(7)           => macStatus.txNotReadyCnt,
         statusIn(15 downto 8) => phyStatus,
         statusIn(16)          => macStatus.rxFifoDropCnt,
         statusOut             => open,
         cntRstIn              => r.countReset,
         rollOverEnIn          => ROLL_OVER_C,
         cntOut                => statusCnt,
         irqEnIn               => (others => '0'),
         irqOut                => open,
         wrClk                 => ethClk,
         wrRst                 => ethClkRst,
         rdClk                 => axilClk,
         rdRst                 => axilClkRst);

   comb : process (axilClkRst, axilReadMaster, axilWriteMaster, phyDebug, phyStatus, r, statusCnt) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndpointType;
   begin
      -- Latch the current value
      v := r;

      ------------------------      
      -- AXI-Lite Transactions
      ------------------------      

      -- Determine the transaction type
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);
      
      -- Reset data bus on AXI-Lite ACK (Makes easier to read from CPU memDump)
      if (axilReadMaster.rready = '1') then
         v.axilReadSlave.rdata := (others => '0');
      end if;      

      axiSlaveRegister(axilEp, x"000", 0, v.countReset);
      axiSlaveRegister(axilEp, x"004", 0, v.phyReset);
      axiSlaveRegister(axilEp, x"008", 0, v.config);
      -- 0x00C is unmapped
      axiSlaveRegister(axilEp, x"010", 0, v.pauseTime);
      axiSlaveRegister(axilEp, x"014", 0, v.macAddress);                     --48-bit
      axiSlaveRegister(axilEp, x"01C", 0, v.ipAddr);
      axiSlaveRegisterR(axilEp, x"020", 0, phyStatus);
      axiSlaveRegisterR(axilEp, x"024", 0, phyDebug);
      -- 0x0034:0x028 are unmapped
      axiSlaveRegister(axilEp, x"038", 0, v.txShift);
      axiSlaveRegister(axilEp, x"038", 4, v.rxShift);
      axiSlaveRegister(axilEp, x"038", 16, v.filtEnable);
      axiSlaveRegister(axilEp, x"038", 17, v.ipCsumEn);
      axiSlaveRegister(axilEp, x"038", 18, v.tcpCsumEn);
      axiSlaveRegister(axilEp, x"038", 19, v.udpCsumEn);
      axiSlaveRegister(axilEp, x"038", 20, v.dropOnPause);
      axiSlaveRegister(axilEp, x"03C", 0, v.ethHeaderSize);
      -- 0x00FC:0x040 are unmapped
      axiSlaveRegisterR(axilEp, x"100", 0, muxSlVectorArray(statusCnt, 0));  -- rxCountEn
      axiSlaveRegisterR(axilEp, x"104", 0, muxSlVectorArray(statusCnt, 1));  -- txCountEn
      axiSlaveRegisterR(axilEp, x"108", 0, muxSlVectorArray(statusCnt, 2));  -- rxpauseCnt
      axiSlaveRegisterR(axilEp, x"10C", 0, muxSlVectorArray(statusCnt, 3));  -- txPauseCnt
      axiSlaveRegisterR(axilEp, x"110", 0, muxSlVectorArray(statusCnt, 4));  -- rxOverflow
      axiSlaveRegisterR(axilEp, x"114", 0, muxSlVectorArray(statusCnt, 5));  -- rxCrcErrorCnt
      axiSlaveRegisterR(axilEp, x"118", 0, muxSlVectorArray(statusCnt, 6));  -- txUnderRunCnt
      axiSlaveRegisterR(axilEp, x"11C", 0, muxSlVectorArray(statusCnt, 7));  -- txNotReadyCnt
      axiSlaveRegisterR(axilEp, x"120", 0, muxSlVectorArray(statusCnt, 8));  -- phyStatus(0) = TX Local Fault
      axiSlaveRegisterR(axilEp, x"124", 0, muxSlVectorArray(statusCnt, 9));  -- phyStatus(1) = RX Local Fault
      axiSlaveRegisterR(axilEp, x"128", 0, muxSlVectorArray(statusCnt, 10));  -- phyStatus(2) = Sync Status(0)
      axiSlaveRegisterR(axilEp, x"12C", 0, muxSlVectorArray(statusCnt, 11));  -- phyStatus(3) = Sync Status(1)
      axiSlaveRegisterR(axilEp, x"130", 0, muxSlVectorArray(statusCnt, 12));  -- phyStatus(4) = Sync Status(2)
      axiSlaveRegisterR(axilEp, x"134", 0, muxSlVectorArray(statusCnt, 13));  -- phyStatus(5) = Sync Status(3)
      axiSlaveRegisterR(axilEp, x"138", 0, muxSlVectorArray(statusCnt, 14));  -- phyStatus(6) = Alignment
      axiSlaveRegisterR(axilEp, x"13C", 0, muxSlVectorArray(statusCnt, 15));  -- phyStatus(7) = RX Link Status
      axiSlaveRegisterR(axilEp, x"140", 0, muxSlVectorArray(statusCnt, 16));  -- rxFifoDropCnt

      -- Close out the transaction
      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_OK_C);  -- Always return "OK" response for ZYNQ CPU 

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

   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   macConfig.pauseEnable <= '1';

   U_SyncMAC : entity work.SynchronizerVector
      generic map (
         TPD_G    => TPD_G,
         STAGES_G => 2,
         WIDTH_G  => 48) 
      port map (
         clk     => ethClk,
         rst     => ethClkRst,
         -- Input Data
         dataIn  => r.macAddress,
         -- Output Data
         dataOut => macConfig.macAddress);

   U_SyncIP : entity work.SynchronizerVector
      generic map (
         TPD_G    => TPD_G,
         STAGES_G => 2,
         WIDTH_G  => 32) 
      port map (
         clk     => ethClk,
         rst     => ethClkRst,
         -- Input Data
         dataIn  => r.ipAddr,
         -- Output Data
         dataOut => ipAddr);    

   U_SyncPause : entity work.SynchronizerVector
      generic map (
         TPD_G    => TPD_G,
         STAGES_G => 2,
         WIDTH_G  => 16) 
      port map (
         clk     => ethClk,
         rst     => ethClkRst,
         -- Input Data
         dataIn  => r.pauseTime,
         -- Output Data
         dataOut => macConfig.pauseTime); 

   U_SyncConfig : entity work.SynchronizerVector
      generic map (
         TPD_G    => TPD_G,
         STAGES_G => 2,
         WIDTH_G  => 7) 
      port map (
         clk     => ethClk,
         rst     => ethClkRst,
         -- Input Data
         dataIn  => r.config,
         -- Output Data
         dataOut => phyConfig);          

   U_SyncETH : entity work.SynchronizerVector
      generic map (
         TPD_G    => TPD_G,
         STAGES_G => 2,
         WIDTH_G  => 6) 
      port map (
         clk        => ethClk,
         rst        => ethClkRst,
         -- Input Data
         dataIn(0)  => r.phyReset,
         dataIn(1)  => r.filtEnable,
         dataIn(2)  => r.dropOnPause,
         dataIn(3)  => r.ipCsumEn,
         dataIn(4)  => r.tcpCsumEn,
         dataIn(5)  => r.udpCsumEn,
         -- Output Data
         dataOut(0) => phyReset,
         dataOut(1) => macConfig.filtEnable,
         dataOut(2) => macConfig.dropOnPause,
         dataOut(3) => macConfig.ipCsumEn,
         dataOut(4) => macConfig.tcpCsumEn,
         dataOut(5) => macConfig.udpCsumEn);         

   U_SyncPPI : entity work.SynchronizerVector
      generic map (
         TPD_G    => TPD_G,
         STAGES_G => 2,
         WIDTH_G  => 24) 
      port map (
         clk                   => dmaClk,
         rst                   => dmaClkRst,
         -- Input Data
         dataIn(15 downto 0)   => r.ethHeaderSize,
         dataIn(19 downto 16)  => r.txShift,
         dataIn(23 downto 20)  => r.rxShift,
         -- Output Data
         dataOut(15 downto 0)  => ethHeaderSize,
         dataOut(19 downto 16) => txShift,
         dataOut(23 downto 20) => rxShift);         

end architecture structure;
