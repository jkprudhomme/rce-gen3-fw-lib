-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : ZynqEthernet10GReg.vhd
-- Author     : Ryan Herbst <rherbst@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-09-03
-- Last update: 2016-10-20
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
         statusIn(31 downto 17)=> (others => '0'),
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

            -- Config Vector 0x8
            -- 0   = Loopback
            -- 1   = Power Down
            -- 2   = Reset Local Fault
            -- 3   = Reset Rx Link Status
            -- 4   = Test Enable
            -- 6:5 = Test Pattern               
            when x"0008" =>
               v.config := axilWriteMaster.wdata(6 downto 0);

            when x"0010" =>
               v.pauseTime := axilWriteMaster.wdata(15 downto 0);

            when x"0014" =>
               v.macAddress(31 downto 0) := axilWriteMaster.wdata;

            when x"0018" =>
               v.macAddress(47 downto 32) := axilWriteMaster.wdata(15 downto 0);

            when x"001C" =>
               v.ipAddr := axilWriteMaster.wdata;

            when x"0038" =>
               v.txShift     := axilWriteMaster.wdata(3 downto 0);
               v.rxShift     := axilWriteMaster.wdata(7 downto 4);
               v.filtEnable  := axilWriteMaster.wdata(16);
               v.ipCsumEn    := axilWriteMaster.wdata(17);
               v.tcpCsumEn   := axilWriteMaster.wdata(18);
               v.udpCsumEn   := axilWriteMaster.wdata(19);
               v.dropOnPause := axilWriteMaster.wdata(20);

            when x"003C" =>
               v.ethHeaderSize := axilWriteMaster.wdata(15 downto 0);

            when others => null;
         end case;

         -- Send Axi response
         axiSlaveWriteResponse(v.axilWriteSlave);

      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axilReadSlave.rdata := (others => '0');
         if (axilReadMaster.araddr(15 downto 8) = x"00") then

            case axilReadMaster.araddr(7 downto 0) is

               when X"00" =>
                  v.axilReadSlave.rdata(0) := r.countReset;

               when X"04" =>
                  v.axilReadSlave.rdata(0) := r.phyReset;

               when X"08" =>
                  v.axilReadSlave.rdata(6 downto 0) := r.config;

               when X"10" =>
                  v.axilReadSlave.rdata(15 downto 0) := r.pauseTime;

               when X"14" =>
                  v.axilReadSlave.rdata := r.macAddress(31 downto 0);

               when X"18" =>
                  v.axilReadSlave.rdata(15 downto 0) := r.macAddress(47 downto 32);
                  
               when X"1C" =>
                  v.axilReadSlave.rdata := r.ipAddr;

               -- Status Vector 0x20
               -- 0   = Tx Local Fault
               -- 1   = Rx Local Fault
               -- 5:2 = Sync Status
               -- 6   = Alignment
               -- 7   = Rx Link Status
               when X"20" =>
                  v.axilReadSlave.rdata(7 downto 0) := phyStatus;

               -- Debug  Vector 0x24
               -- 5   = Align Status
               -- 4:1 = Sync Status
               -- 0   = TX Phase Complete                     
               when X"24" =>
                  v.axilReadSlave.rdata(5 downto 0) := phyDebug;
                  
               when x"38" =>
                  v.axilReadSlave.rdata(3 downto 0) := r.txShift;
                  v.axilReadSlave.rdata(7 downto 4) := r.rxShift;
                  v.axilReadSlave.rdata(16)         := r.filtEnable;
                  v.axilReadSlave.rdata(17)         := r.ipCsumEn;
                  v.axilReadSlave.rdata(18)         := r.tcpCsumEn;
                  v.axilReadSlave.rdata(19)         := r.udpCsumEn;
                  v.axilReadSlave.rdata(20)         := r.dropOnPause;

               when X"3C" =>
                  v.axilReadSlave.rdata(15 downto 0) := r.ethHeaderSize;

               when others => null;
            end case;
            
         else
            v.axilReadSlave.rdata := muxSlVectorArray(statusCnt, conv_integer(axilReadMaster.araddr(6 downto 2)));
         end if;

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
