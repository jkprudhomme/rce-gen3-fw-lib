-------------------------------------------------------------------------------
-- Title         : Clock/Trigger Sink Module For DPM, Version 2
-- File          : DpmTimingSinkV2.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/10/2013
-------------------------------------------------------------------------------
-- Description:
-- Clock & Trigger sink module for COB
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/10/2013: created.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity DpmTimingSinkV2 is
   generic (
      TPD_G           : time   := 1 ns;
      IODELAY_GROUP_G : string := "DtmTimingGrp"
   );
   port (

      -- Local Bus
      axiClk                   : in  sl;
      axiClkRst                : in  sl;
      axiReadMaster            : in  AxiLiteReadMasterType;
      axiReadSlave             : out AxiLiteReadSlaveType;
      axiWriteMaster           : in  AxiLiteWriteMasterType;
      axiWriteSlave            : out AxiLiteWriteSlaveType;

      -- Reference Clock
      sysClk200                : in  sl;
      sysClk200Rst             : in  sl;

      -- Timing bus, Ref Clock Receiver Is External
      dtmClkP                  : in  slv(1 downto 0);
      dtmClkM                  : in  slv(1 downto 0);
      dtmFbP                   : out sl;
      dtmFbM                   : out sl;

      -- Clock and reset
      distClk                  : in  sl;
      distClkRst               : out sl;
      
      -- Received Data, synchronous to distClk
      rxData                   : out Slv10Array(1 downto 0);
      rxDataEn                 : out slv(1 downto 0);

      -- Transmit data, synchronous to distClk
      txData                   : in  slv(9 downto 0);
      txDataEn                 : in  sl;
      txReady                  : out sl
   );
end DpmTimingSinkV2;

architecture STRUCTURE of DpmTimingSinkV2 is

   -- Local Signals
   signal intRxData           : Slv10Array(1 downto 0);
   signal intRxDataEn         : slv(1 downto 0);
   signal statusIdleCnt       : Slv16Array(1 downto 0);
   signal statusErrorCnt      : Slv16Array(1 downto 0);
   signal rxDataCnt           : Slv32Array(1 downto 0);
   signal intTxData           : slv(9 downto 0);
   signal intTxDataEn         : sl;
   signal txDataCnt           : slv(31 downto 0);
   signal dtmFb               : sl;
   signal dtmClk              : slv(1 downto 0);
   signal intClkRst           : sl;
   signal intReset            : sl;
   signal intRxEcho           : slv(1 downto 0);

   type RegType is record
      cfgReset          : sl;
      countReset        : sl;
      cfgSet            : slv(1 downto 0);
      cfgDelay          : Slv5Array(4 downto 0);
      axiReadSlave      : AxiLiteReadSlaveType;
      axiWriteSlave     : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      cfgReset         => '0',
      countReset       => '0',
      cfgSet           => (others=>'0'),
      cfgDelay         => (others=>(others=>'0')),
      axiReadSlave     => AXI_LITE_READ_SLAVE_INIT_C,
      axiWriteSlave    => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   attribute IODELAY_GROUP                        : string;
   attribute IODELAY_GROUP of U_DpmTimingDlyCntrl : label is IODELAY_GROUP_G;   

begin

   -- Clock and reset out
   distClkRst   <= intClkRst;
   rxData       <= intRxData;
   rxDataEn     <= intRxDataEn;

   ----------------------------------------
   -- Delay Control
   ----------------------------------------
   U_DpmTimingDlyCntrl : IDELAYCTRL
      port map (
         RDY    => open,        -- 1-bit output: Ready output
         REFCLK => sysClk200,   -- 1-bit input: Reference clock input
         RST    => sysClk200Rst -- 1-bit input: Active high reset input
      );


   ----------------------------------------
   -- Incoming global clock
   ----------------------------------------

   intReset <= axiClkRst or r.cfgReset;

   -- Reset gen
   U_RstGen : entity work.RstSync
      generic map (
         TPD_G            => TPD_G,
         IN_POLARITY_G    => '1',
         OUT_POLARITY_G   => '1',
         RELEASE_DELAY_G  => 16
      )
      port map (
        clk      => distClk,
        asyncRst => intReset,
        syncRst  => intClkRst
      );


   ----------------------------------------
   -- Incoming Data Stream
   ----------------------------------------

   U_Gen: for i in 0 to 1 generate

      -- DTM Clock
      U_DtmClk : IBUFDS 
         generic map ( DIFF_TERM => true ) 
         port map ( 
            I  => dtmClkP(i),
            IB => dtmClkM(i),
            O  => dtmClk(i)
         );

      -- Input processor
      U_CobDataSink : entity work.CobDataSink10b 
         generic map (
            TPD_G           => TPD_G,
            IODELAY_GROUP_G => IODELAY_GROUP_G
         ) port map (
            serialData      => dtmClk(i),
            distClk         => distClk,
            distClkRst      => intClkRst,
            rxData          => intRxData(i),
            rxDataEn        => intRxDataEn(i),
            configClk       => axiClk,
            configClkRst    => axiClkRst,
            configSet       => r.cfgSet(i),
            configDelay     => r.cfgDelay(i),
            statusIdleCnt   => statusIdleCnt(i),
            statusErrorCnt  => statusErrorCnt(i)
         );

      process ( distClk ) begin
         if rising_edge(distClk) then
            if intClkRst = '1' or r.countReset = '1' then
               rxDataCnt(i) <= (others=>'0') after TPD_G;
            elsif intRxDataEn(i) = '1' then
               rxDataCnt(i) <= rxDataCnt(i) + 1 after TPD_G;
            end if;
         end if;
      end process;

   end generate;


   ----------------------------------------
   -- Feedback Output
   ----------------------------------------

   -- Determine Echo 
   intRxEcho(0) <= '1' when intRxDataEn(0) = '1' and intRxData(0)(9 downto 8) = "01" else '0';
   intRxEcho(1) <= '1' when intRxDataEn(1) = '1' and intRxData(1)(9 downto 8) = "01" else '0';

   -- Mux TX Data
   intTxDataEn <= txDataEn or intRxEcho(0) or intRxEcho(1);
   intTxData   <= txData       when txDataEn = '1' else
                  intRxData(0) when intRxEcho(0) = '1' else
                  intRxData(1) when intRxEcho(1) = '1' else
                  (others=>'0');

   -- Module
   U_CobDataSource : entity work.CobDataSource10b
      generic map (
         TPD_G => TPD_G
      ) port map (
         distClk         => distClk,
         distClkRst      => intClkRst,
         txData          => intTxData,
         txDataEn        => intTxDataEn,
         txReady         => txReady,
         serialData      => dtmFb
      );

   -- DTM Feedback
   U_DtmFb : OBUFDS 
      port map ( 
         O  => dtmFbP,     
         OB => dtmFbM,     
         I  => dtmFb
      );

   process ( distClk ) begin
      if rising_edge(distClk) then
         if intClkRst = '1' or r.countReset = '1' then
            txDataCnt <= (others=>'0') after TPD_G;
         elsif intTxDataEn = '1' then
            txDataCnt <= txDataCnt + 1 after TPD_G;
         end if;
      end if;
   end process;


   ----------------------------------------
   -- Local Registers
   ----------------------------------------

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (axiClkRst, axiReadMaster, axiWriteMaster, r, statusErrorCnt, statusIdleCnt, rxDataCnt, txDataCnt ) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      v.cfgReset   := '0';
      v.cfgSet     := "00";
      v.countReset := '0';

      axiSlaveWaitTxn(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Master Reset, 0x000
         if axiWriteMaster.awaddr(11 downto 0) = x"000" then
            v.cfgReset := axiWriteMaster.wdata(0);

         -- OC Fifo Write Enable, 0x004 (legacy)

         -- OC 0 Delay configuration, 0x008
         elsif axiWriteMaster.awaddr(11 downto 0) = x"008" then
            v.cfgSet(0)   := '1';
            v.cfgDelay(0) := axiWriteMaster.wdata(4 downto 0);

         -- Receive status, 0x00C

         -- OC FIFO read, one per FIFO, 0x010 (legacy)

         -- Clock Count, 0x014 (legacy)

         -- OC 1 Delay configuration, 0x018
         elsif axiWriteMaster.awaddr(11 downto 0) = x"018" then
            v.cfgSet(1)   := '1';
            v.cfgDelay(1) := axiWriteMaster.wdata(4 downto 0);

         -- Receive status, 0x01C

         -- Counter Reset 0x020
         elsif axiWriteMaster.awaddr(11 downto 0) = x"020" then
            v.countReset := axiWriteMaster.wdata(0);

         -- Rx Count A, 0x024

         -- Rx Count B, 0x028

         end if;

         -- Send Axi response
         axiSlaveWriteResponse(v.axiWriteSlave);

      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axiReadSlave.rdata := (others => '0');

         -- Master Reset, 0x000

         -- OC Fifo Write Enable, 0x004 (legacy)

         -- OC 0 Delay configuration, 0x008
         if axiReadMaster.araddr(11 downto 0) = x"008" then
            v.axiReadSlave.rdata(4 downto 0) := r.cfgDelay(0);

         -- Receive status, 0x00C
         elsif axiReadMaster.araddr(11 downto 0) = x"00C" then
            v.axiReadSlave.rdata(31 downto 16) := statusErrorCnt(0);
            v.axiReadSlave.rdata(15 downto 0)  := statusIdleCnt(0);

         -- OC FIFO read, one per FIFO, 0x010 (legacy)

         -- Clock Count, 0x014 (legacy)

         -- OC 1 Delay configuration, 0x018
         elsif axiReadMaster.araddr(11 downto 0) = x"018" then
            v.axiReadSlave.rdata(4 downto 0) := r.cfgDelay(1);

         -- Receive status, 0x01C
         elsif axiReadMaster.araddr(11 downto 0) = x"01C" then
            v.axiReadSlave.rdata(31 downto 16) := statusErrorCnt(1);
            v.axiReadSlave.rdata(15 downto 0)  := statusIdleCnt(1);

         -- Clock Reset, 0x020

         -- Rx Count A, 0x024
         elsif axiReadMaster.araddr(11 downto 0) = x"024" then
            v.axiReadSlave.rdata := rxDataCnt(0);

         -- Rx Count B, 0x028
         elsif axiReadMaster.araddr(11 downto 0) = x"028" then
            v.axiReadSlave.rdata := rxDataCnt(1);

         -- Tx Count, 0x02C
         elsif axiReadMaster.araddr(11 downto 0) = x"02C" then
            v.axiReadSlave.rdata := txDataCnt;

         end if;

         -- Send Axi Response
         axiSlaveReadResponse(v.axiReadSlave);

      end if;

      -- Reset
      if (axiClkRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      axiReadSlave  <= r.axiReadSlave;
      axiWriteSlave <= r.axiWriteSlave;
      
   end process;

end architecture STRUCTURE;

