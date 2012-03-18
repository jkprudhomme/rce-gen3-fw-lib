-------------------------------------------------------------------------------
-- Title         : Ethernet Interface Module, 64-bit word receive / transmit
-- Project       : SID, KPIX ASIC
-------------------------------------------------------------------------------
-- File          : EthInterface.vhd
-- Author        : Raghuveer Ausoori, ausoori@slac.stanford.edu
-- Created       : 11/12/2010
-------------------------------------------------------------------------------
-- Description:
-- This module receives and transmits 64-bit data through the 10G ethernet line
-------------------------------------------------------------------------------
-- Copyright (c) 2011 by Raghuveer Ausoori. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 5/9/2011: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
Library Unisim;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.ALL;
use work.EthClientPackage.all;

entity EthInterface is port ( 

      -- Ethernet clock & reset
      sysClk        : in  std_logic;                        -- 125Mhz master clock
      sysRst        : in  std_logic;                        -- Synchronous reset input

      -- Ethernet clock & reset
      gtpClk        : in  std_logic;                        -- 125Mhz master clock
      gtpClkRst     : in  std_logic;                        -- Synchronous reset input
      
      ethTxEmpty    : in  std_logic;                        -- Ethernet TX Data Valid
      ethTxData     : in  std_logic_vector(63 downto 0);    -- Ethernet TX Data
      ethTxType     : in  std_logic_vector(1  downto 0);    -- Ethernet TX Data Type
      ethTxSOF      : in  std_logic;                        -- Ethernet TX Start of Frame
      ethTxEOF      : in  std_logic;                        -- Ethernet TX End of Frame
      ethTxWidth    : in  std_logic;                        -- Ethernet TX Width
      ethTxRd       : out std_logic;                        -- Ethernet TX Read
      
      -- UDP Transmit interface
      udpTxValid    : out std_logic;
      udpTxEOF      : out std_logic;
      udpTxReady    : in  std_logic;
      udpTxData     : out std_logic_vector(63 downto 0);
      udpTxLength   : out std_logic_vector(15 downto 0);

      -- Device ID
      deviceID      : in  std_logic_vector(1  downto 0);
      
      -- Debug
      csControl     : inout  std_logic_vector(35 downto 0)  -- Chip Scope Control
      
   );
end EthInterface;


-- Define architecture for Interface module
architecture EthInterface of EthInterface is

   component v5_fifo_66x8k port (
      rst           : IN  std_logic;
      din           : IN  std_logic_VECTOR(65 downto 0);
      wr_en         : IN  std_logic;
      wr_clk        : IN  std_logic;
      rd_en         : IN  std_logic;
      rd_clk        : IN  std_logic;
      dout          : OUT std_logic_VECTOR(65 downto 0);
      full          : OUT std_logic;
      empty         : OUT std_logic;
      rd_data_count : OUT std_logic_VECTOR(12 downto 0));
   end component;

   -- Counter FIFO
   component v5_fifo_17x1k port (
      rd_clk:IN  std_logic;
      wr_clk:IN  std_logic;
      din:   IN  std_logic_VECTOR(16 downto 0);
      rd_en: IN  std_logic;
      rst:   IN  std_logic;
      wr_en: IN  std_logic;
      dout:  OUT std_logic_VECTOR(16 downto 0);
      empty: OUT std_logic;
      full:  OUT std_logic
   ); end component;

   -- Local signals
   signal locTxFifoDout  : std_logic_vector(63 downto 0);
   signal locTxFifoDin   : std_logic_vector(63 downto 0);
   signal shiftData      : std_logic_vector(31 downto 0);
   signal locTxFifoWr    : std_logic;
   signal locTxFifoRd    : std_logic;
   signal locTxFifoFull  : std_logic;
   signal locTxFifoEmpty : std_logic;
   signal locTxFifoWidth : std_logic;
   signal locTxFifoEOFout: std_logic;
   signal intTxWidth     : std_logic;
   signal dataCount      : std_logic_vector(12 downto 0);
   signal pktCount       : std_logic_vector(12 downto 0);
   signal locTxFifoCnt   : std_logic_vector(12 downto 0);
   signal locTxCntDout   : std_logic_vector(12 downto 0);
   signal locTxCntDin    : std_logic_vector(12 downto 0);
   signal locTxCntSOF    : std_logic;
   signal locTxCntType   : std_logic_vector(1  downto 0);
   signal locTxCntWr     : std_logic;
   signal locTxCntRd     : std_logic;
   signal locTxCntFull   : std_logic;
   signal locTxCntEmpty  : std_logic;
   signal negTxCntWr     : std_logic;
   signal txCntWr        : std_logic;
   signal dlyEthTxRd     : std_logic;
   signal intTxRd        : std_logic;
   signal locTxEOF       : std_logic;
   signal intUdpTxValid  : std_logic;
   signal negUdpTxValid  : std_logic;
   signal dlyTxCntRd     : std_logic;
   signal intTxData      : std_logic_vector(63 downto 0);
   signal intTxSOF       : std_logic;
   signal intTxEOF       : std_logic;
   signal intTxType      : std_logic_vector(1  downto 0);
   signal dlyEthTxSOF    : std_logic;
   signal dlyEthTxType   : std_logic_vector(1  downto 0);
   
   -- Ethernet RX States
   constant ST_IDLE      : std_logic_vector(1 downto 0) := "00";
   constant ST_SOF       : std_logic_vector(1 downto 0) := "01";
   constant ST_DATA      : std_logic_vector(1 downto 0) := "10";
   constant ST_EOF       : std_logic_vector(1 downto 0) := "11";
   signal   curState     : std_logic_vector(1 downto 0);
   signal   nxtState     : std_logic_vector(1 downto 0);
   
   -- Chip Scope signals
   constant enChipScope  : integer := 0;
   signal   ethDebug     : std_logic_vector(63 downto 0);
   
begin

   ----------------------------------------------------------
   ------------------ Debug Block ---------------------------
   
--    ethDebug (63 downto 56)<= ;
--    ethDebug (52 downto 49)<= ;
--    ethDebug (48)          <= locTxEOF;
--    ethDebug (47)          <= intTxRd;
--    ethDebug (46)          <= locTxCntWr;
--    ethDebug (45)          <= locTxFifoWr;
--    ethDebug (44)          <= locTxFifoRd;
--    ethDebug (43 downto 42)<= curState;
--    ethDebug (41 downto 29)<= pktCount;
--    ethDebug (28 downto 21)<= locTxFifoDin(15 downto 8);
--    ethDebug (20 downto 13)<= locTxFifoDin(7  downto 0);
--    ethDebug (12 downto 0) <= dataCount;

   chipscope : if (enChipScope = 1) generate   
      U_EthInterface_EmacClk_ila : v5_ila port map (
         CONTROL => csControl,
         CLK     => gtpClk,
         TRIG0   => ethDebug
      );
   end generate chipscope;
   
   ---------------------- Debug Block ----------------------------
   ---------------------------------------------------------------
   
   udpTxData     <= intTxData;
--    udpTxEOF      <= locTxFifoEOFout;
   udpTxValid    <= not negUdpTxValid;
   udpTxLength(15 downto 0) <= locTxCntDout & "000"; -- Multiply by 8
   
   ethTxRd       <= intTxRd;
   intTxRd       <= (not ethTxEmpty) and (not locTxFifoFull);
--    intUdpTxValid <= (not locTxCntEmpty) and (not udpTxReady);
   locTxEOF      <= ethTxEOF when locTxFifoWr = '1' else '0';
   
   locTxFifoRd   <= '1' when (udpTxReady = '1' and locTxFifoEmpty = '0' and pktCount > 0) else '0';
   locTxFifoWr   <= dlyEthTxRd;
   locTxFifoDin  <= ethTxData;
         
   locTxCntWr    <= (txCntWr and negTxCntWr);
   locTxCntRd    <= intUdpTxValid and negUdpTxValid;
   
   -- Transmitter Data Fifo
   U_TxDataFifo : v5_fifo_66x8k port map (
      wr_clk            => gtpClk,
      rd_clk            => gtpClk,
      rst               => gtpClkRst,
      din(65)           => ethTxEOF,
      din(64)           => ethTxWidth,
      din(63 downto 0)  => locTxFifoDin,
      wr_en             => locTxFifoWr,
      rd_en             => locTxFifoRd,
      dout(65)          => locTxFifoEOFout,
      dout(64)          => locTxFifoWidth,
      dout(63 downto 0) => locTxFifoDout,
      full              => open,
      empty             => locTxFifoEmpty,
      rd_data_count     => locTxFifoCnt
   );
   
   -- Transmitter Data Count Fifo
   U_TxCntFifo : v5_fifo_17x1k port map (
      wr_clk             => gtpClk,
      rd_clk             => gtpClk,
      rst                => gtpClkRst,
      din(16)            => '0',
      din(15)            => intTxSOF,
      din(14 downto 13)  => intTxType,
      din(12 downto  0)  => locTxCntDin,
      wr_en              => locTxCntWr,
      rd_en              => locTxCntRd,
      dout(16)           => open,
      dout(15)           => locTxCntSOF,
      dout(14 downto 13) => locTxCntType,
      dout(12 downto  0) => locTxCntDout,
      full               => locTxCntFull,
      empty              => locTxCntEmpty
   );
   
   process (curState, locTxCntSOF, locTxCntType, locTxFifoDout,
            locTxFifoEOFout, udpTxReady, pktCount) begin
      case curState is
         when ST_IDLE =>
            intTxData  <= (others=>'0') after tpd;
            udpTxEOF   <= '0'           after tpd;
            intTxEOF   <= '0'           after tpd;
            intTxWidth <= '0'           after tpd;
            
            if udpTxReady = '1' and pktCount > 0 then
               nxtState <= ST_SOF after tpd;
            end if;
         when ST_SOF =>
            nxtState                <= ST_DATA       after tpd;
            intTxData(63)           <= locTxCntSOF   after tpd;
            intTxData(62 downto 61) <= locTxCntType  after tpd;
            intTxData(60 downto 59) <= deviceID      after tpd;
            intTxData(58 downto 32) <= (others=>'0') after tpd;
            intTxData(31 downto  0) <= locTxFifoDout(63 downto 32) after tpd;
            shiftData               <= locTxFifoDout(31 downto  0) after tpd;
         when ST_DATA =>
            intTxData(63 downto 32) <= shiftData     after tpd;
            intTxData(31 downto  0) <= locTxFifoDout(63 downto 32) after tpd;
            shiftData               <= locTxFifoDout(31 downto  0) after tpd;
            
            if pktCount = 0 then --This frame is the last one
               nxtState   <= ST_EOF          after tpd;
               intTxWidth <= locTxFifoWidth  after tpd;
               intTxEOF   <= locTxFifoEOFout after tpd;
            else
               nxtState   <= ST_DATA  after tpd;
               intTxWidth <= '0'      after tpd;
               intTxEOF   <= '0'      after tpd;
            end if;
         when ST_EOF =>
            nxtState <= ST_IDLE after tpd;
            udpTxEOF <= '1'     after tpd;
            
            if intTxWidth = '1' then
            -- Lower 32-bits are valid
               intTxData(63 downto 32) <= shiftData     after tpd;
               intTxData(31)           <= intTxEOF      after tpd;
               intTxData(30 downto  0) <= (others=>'0') after tpd;
               shiftData               <= (others=>'0') after tpd;
            else
            -- Lower 32-bits are invalid
               intTxData(63)           <= intTxEOF      after tpd;
               intTxData(62 downto  0) <= (others=>'0') after tpd;
               shiftData               <= (others=>'0') after tpd;
            end if;
         when others =>
            nxtState   <= ST_IDLE       after tpd;
            intTxData  <= (others=>'0') after tpd;
            udpTxEOF   <= '0'           after tpd;
            intTxEOF   <= '0'           after tpd;
            intTxWidth <= '0'           after tpd;

      end case;
   end process;
         
   process (gtpClk, gtpClkRst ) begin
      if gtpClkRst = '1' then
         pktCount       <= (OTHERS=>'0') after tpd;
         dlyTxCntRd     <= '0'           after tpd;
         negTxCntWr     <= '1'           after tpd;
         txCntWr        <= '0'           after tpd;
         negUdpTxValid  <= '1'           after tpd;
         intUdpTxValid  <= '0'           after tpd;
         dlyTxCntRd     <= '0'           after tpd;
         locTxCntDin    <= (OTHERS=>'0') after tpd;
         locTxFifoFull  <= '0'           after tpd;
         curState       <= (OTHERS=>'0') after tpd;
         dlyEthTxRd     <= '0'           after tpd;
         dataCount      <= (OTHERS=>'0') after tpd;
         intTxSOF       <= '0'           after tpd;
         intTxType      <= (OTHERS=>'0') after tpd;
         dlyEthTxSOF    <= '0'           after tpd;
         dlyEthTxType   <= (OTHERS=>'0') after tpd;
         
      elsif rising_edge(gtpClk) then
         curState       <= nxtState          after tpd;
         locTxCntDin    <= dataCount         after tpd;

         -- Delayed negative copy to produce single pulses
         negTxCntWr     <= not txCntWr       after tpd;
         negUdpTxValid  <= not intUdpTxValid after tpd;
         
         -- Delayed copy for matching the FIFO timing
         dlyTxCntRd     <= locTxCntRd        after tpd;
         dlyEthTxRd     <= intTxRd           after tpd;
         dlyEthTxSOF    <= ethTxSOF          after tpd;
         dlyEthTxType   <= ethTxType         after tpd;
         
         if dataCount = 1 then
            intTxSOF  <= dlyEthTxSOF  after tpd;
            intTxType <= dlyEthTxType after tpd;
         end if;
         
         if udpTxReady = '1' then
            intUdpTxValid <= '0' after tpd;
         elsif locTxCntEmpty = '0' then
            intUdpTxValid <= '1' after tpd;
         end if;
         
         -- Count # of data read out and sent to GTP
         if dlyTxCntRd = '1' then
            -- Latch the Data count value from counter FIFO
            pktCount    <= locTxCntDout  after tpd;
         elsif locTxFifoRd = '1' then --udpTxReady
            if pktCount = 0 then
               pktCount <= (OTHERS=>'0') after tpd;
            else
               pktCount <= pktCount - 1  after tpd;
            end if;
         end if;
         
         -- Raise FULL flag when 8100 packets are stored
         if locTxFifoCnt > 8099 then
            locTxFifoFull <= '1' after tpd;
         else
            locTxFifoFull <= '0' after tpd;
         end if;
         
         if dataCount > 7999 or locTxEOF = '1' then
            txCntWr <= '1' after tpd;
         else
            txCntWr <= '0' after tpd;
         end if;
         
         -- Count the number of packets being stored
         if dataCount > 7999 or (locTxEOF = '1' and intTxRd = '1') then
            dataCount  <= '0' & x"001"  after tpd;     -- Clear to update for new data 
         elsif locTxEOF = '1' and intTxRd = '0' then
            dataCount  <= (OTHERS=>'0') after tpd;     -- Clear to update for new data
         elsif intTxRd = '1' then
            dataCount  <= dataCount + 1 after tpd;
         end if;
         
      end if;
   end process;
   
end EthInterface;
