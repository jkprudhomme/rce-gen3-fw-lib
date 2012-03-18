-------------------------------------------------------------------------------
-- Title         : Ethernet Client, Core Top Level
-- Project       : General Purpose Core
-------------------------------------------------------------------------------
-- File          : EthClient.vhd
-- Author        : Raghuveer Ausoori, ausoori@slac.stanford.edu
-- Created       : 10/18/2010
-------------------------------------------------------------------------------
-- Description:
-- Top level source code for general purpose firmware ethernet client.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2011 by Raghuveer Ausoori. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 10/18/2010: created.
-- 05/24/2011: Modified for 10g XMAC
-------------------------------------------------------------------------------

LIBRARY ieee;
USE work.ALL;
USE work.EthClientPackage.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity EthClient is 
   generic ( 
      UdpPort : integer := 8192
   );
   port (

      -- Ethernet clock & reset
      emacClk         : in  std_logic;
      emacClkRst      : in  std_logic;

      -- MAC Interface Signals, Receiver
      emacRxData      : in  std_logic_vector(63 downto 0);
      emacRxValid     : in  std_logic;
      emacRxLast      : in  std_logic;

      -- MAC Interface Signals, Transmitter
      emacTxData      : out std_logic_vector(63 downto 0);
      emacTxValid     : out std_logic;
      emacTxReady     : in  std_logic;
      emacTxSOF       : out std_logic;
      emacTxWidth     : out std_logic;
      emacTxEOF       : out std_logic;

      -- Ethernet Constants
      ipAddr          : in  IPAddrType;
      macAddr         : in  MacAddrType;

      -- UDP Transmit interface
      udpTxValid      : in  std_logic;
      udpTxEOF        : in  std_logic;
      udpTxReady      : out std_logic;
      udpTxData       : in  std_logic_vector(63 downto 0);
      udpTxLength     : in  std_logic_vector(15 downto 0);

      -- UDP Receive interface
      udpRxValid      : out std_logic;
      udpRxSOF        : out std_logic;
      udpRxEOF        : out std_logic;
      udpRxWidth      : out std_logic;
      udpRxError      : out std_logic;
      udpRxData       : out std_logic_vector(63 downto 0);

      -- Debug
      cScopeCtrl1     : inout std_logic_vector(35 downto 0);
      cScopeCtrl2     : inout std_logic_vector(35 downto 0)
   );
end EthClient;

-- Define architecture
architecture EthClient of EthClient is

   -- ARP Processor
   component EthClientArp port (
      emacClk    : in  std_logic;
      emacClkRst : in  std_logic;
      ipAddr     : in  IPAddrType;
      macAddr    : in  MacAddrType;
      rxData     : in  std_logic_vector(63 downto 0);
      rxLast     : in  std_logic;
      rxValid    : in  std_logic;
      rxSrc      : in  MacAddrType;
      txValid    : out std_logic;
      txReady    : in  std_logic;
      txSOF      : out std_logic;
      txEOF      : out std_logic;
      txData     : out std_logic_vector(63 downto 0);
      txWidth    : out std_logic;
      txDst      : out MacAddrType;
      cScopeCtrl : inout std_logic_vector(35 downto 0)
   );
   end component;

   -- UDP interface
   component EthClientUdp 
      generic ( 
         UdpPort : integer := 8192
      );
      port (
         emacClk     : in  std_logic;
         emacClkRst  : in  std_logic;
         ipAddr      : in  IPAddrType;
         rxData      : in  std_logic_vector(63 downto 0);
         rxLast      : in  std_logic;
         rxValid     : in  std_logic;
         rxSrc       : in  MacAddrType;
         txValid     : out std_logic;
         txReady     : in  std_logic;
         txSOF       : out std_logic;
         txEOF       : out std_logic;
         txData      : out std_logic_vector(63 downto 0);
         txWidth     : out std_logic;
         txDst       : out MacAddrType;
         udpTxValid  : in  std_logic;
         udpTxEOF    : in  std_logic;
         udpTxReady  : out std_logic;
         udpTxData   : in  std_logic_vector(63  downto 0);
         udpTxLength : in  std_logic_vector(15 downto 0);
         udpRxValid  : out std_logic;
         udpRxSOF    : out std_logic;
         udpRxEOF    : out std_logic;
         udpRxWidth  : out std_logic;
         udpRxError  : out std_logic;
         udpRxData   : out std_logic_vector(63 downto 0);
         cScopeCtrl  : inout std_logic_vector(35 downto 0)
      );
   end component;

   -- Local Signals
   signal intRxData      : std_logic_vector(63 downto 0);
   signal intRxValid     : std_logic;
   signal intRxLast      : std_logic;
   signal selRxData      : std_logic_vector(63 downto 0);
   signal selRxError     : std_logic;
   signal selRxGood      : std_logic;
   signal selRxLast      : std_logic;
   signal selRxArpValid  : std_logic;
   signal selRxUdpValid  : std_logic;
   signal rxCount        : std_logic_vector(2  downto 0);
   signal rxEthType      : std_logic_vector(15 downto 0);
   signal rxSrcAddr      : MacAddrType;
   signal rxDstAddr      : MacAddrType;
   signal txCount        : std_logic_vector(2  downto 0);
   signal selTxArpValid  : std_logic;
   signal selTxArpReady  : std_logic;
   signal selTxArpSOF    : std_logic;
   signal selTxArpEOF    : std_logic;
   signal selTxArpWidth  : std_logic;
   signal selTxArpData   : std_logic_vector(63 downto 0);
   signal selTxArpDst    : MacAddrType;
   signal selTxArp       : std_logic;
   signal selTxUdpValid  : std_logic;
   signal selTxUdpReady  : std_logic;
   signal selTxUdpSOF    : std_logic;
   signal selTxUdpEOF    : std_logic;
   signal selTxUdpWidth  : std_logic;
   signal selTxUdpData   : std_logic_vector(63 downto 0);
   signal intTxData      : std_logic_vector(63 downto 0);
   signal selTxUdpDst    : MacAddrType;

   -- Ethernet RX States
   constant ST_RX_IDLE   : std_logic_vector(2 downto 0) := "001";
   constant ST_RX_SRC    : std_logic_vector(2 downto 0) := "010";
   constant ST_RX_SEL    : std_logic_vector(2 downto 0) := "011";
   constant ST_RX_DATA   : std_logic_vector(2 downto 0) := "100";
   constant ST_RX_DONE   : std_logic_vector(2 downto 0) := "101";
   signal   curRXState   : std_logic_vector(2 downto 0);

   -- Ethernet TX States
   constant ST_TX_IDLE   : std_logic_vector(2 downto 0) := "001";
   constant ST_TX_ACK    : std_logic_vector(2 downto 0) := "010";
   constant ST_TX_DST    : std_logic_vector(2 downto 0) := "011";
   constant ST_TX_SRC    : std_logic_vector(2 downto 0) := "100";
   constant ST_TX_TYPE   : std_logic_vector(2 downto 0) := "101";
   constant ST_TX_DATA   : std_logic_vector(2 downto 0) := "110";
   signal   curTXState   : std_logic_vector(2 downto 0);

   -- Debug
   signal   cScopeTrig   : std_logic_vector(63 downto 0);
   constant enChipScope  : std_logic := '0';

begin

   -----------------------------
   -- Chipscope for debug
   -----------------------------

   -- Debug Signals
--    cScopeTrig (63)           <= udpTxValid;--intRxGoodFrame;selTxUdpValid
--    cScopeTrig (62)           <= selTxUdpValid;
--    cScopeTrig (61)           <= selTxArpValid;
--    cScopeTrig (60)           <= selTxArpReady;
--    --cScopeTrig (62 downto 60) <= rxCount;
--    cScopeTrig (59)           <= intRxValid;
--    cScopeTrig (58 downto 56) <= curRXState;
--    cScopeTrig (55 downto 48) <= selTxUdpData;--rxDstAddr(5);
--    cScopeTrig (47 downto 40) <= selTxArpData;--rxDstAddr(4);
--    cScopeTrig (39 downto 32) <= rxDstAddr(3);
--    cScopeTrig (31 downto 24) <= rxDstAddr(2);
--    cScopeTrig (23 downto 16) <= rxDstAddr(1);
--    cScopeTrig (15 downto 8)  <= rxDstAddr(0);
--    cScopeTrig (7  downto 0)  <= intRxData;
   
   -- Chipscope logic analyzer
   chipscope : if (enChipScope = '1') generate
   U_EthClient_ila : v5_Ila port map ( control => cScopeCtrl1,
                                       clk     => emacClk,
                                       trig0   => cscopeTrig);
   end generate chipscope;

   --------------------------------
   -- Ethernet Receive Logic
   --------------------------------

   -- Register EMAC Data
   process ( emacClk, emacClkRst ) begin
      if emacClkRst = '1' then
         intRxData  <= (others=>'0') after tpd;
         intRxValid <= '0'           after tpd;
         intRxLast  <= '0'           after tpd;
      elsif rising_edge(emacClk) then
         intRxData  <= emacRxData    after tpd;
         intRxValid <= emacRxValid   after tpd;
         intRxLast  <= emacRxLast    after tpd;
      end if;
   end process;

   -- Sync state logic
   process ( emacClk, emacClkRst ) begin
      if emacClkRst = '1' then
         selRxData      <= (others=>'0')   after tpd;
         selRxError     <= '0'             after tpd;
         selRxGood      <= '0'             after tpd;
         selRxLast      <= '0'             after tpd;
         selRxArpValid  <= '0'             after tpd;
         selRxUdpValid  <= '0'             after tpd;
         rxSrcAddr      <= (others=>x"00") after tpd;
         rxDstAddr      <= (others=>x"00") after tpd;
         rxEthType      <= (others=>'0')   after tpd;
         curRxState     <= ST_RX_IDLE      after tpd;
      elsif rising_edge(emacClk) then

         -- Outgoing data
         selRxData <= intRxData after tpd;
         selRxLast <= intRxLast after tpd;

         -- State machine
         case curRxState is

            -- IDLE
            when ST_RX_IDLE =>
               selRxError    <= '0' after tpd;
               selRxGood     <= '0' after tpd;
               selRxArpValid <= '0' after tpd;
               selRxUdpValid <= '0' after tpd;
                  
               -- New frame
               if intRxValid = '1' then
                  rxDstAddr(0) <= intRxData(63 downto 56) after tpd;
                  rxDstAddr(1) <= intRxData(55 downto 48) after tpd;
                  rxDstAddr(2) <= intRxData(47 downto 40) after tpd;
                  rxDstAddr(3) <= intRxData(39 downto 32) after tpd;
                  rxDstAddr(4) <= intRxData(31 downto 24) after tpd;
                  rxDstAddr(5) <= intRxData(23 downto 16) after tpd;
                  rxSrcAddr(0) <= intRxData(15 downto  8) after tpd;
                  rxSrcAddr(1) <= intRxData(7  downto  0) after tpd;
                  curRxState   <= ST_RX_SRC after tpd;
               end if;

            -- Source address
            when ST_RX_SRC =>
               selRxError             <= '0'                     after tpd;
               selRxGood              <= '0'                     after tpd;
               selRxArpValid          <= '0'                     after tpd;
               selRxUdpValid          <= '0'                     after tpd;
               rxSrcAddr(2)           <= intRxData(63 downto 56) after tpd;
               rxSrcAddr(3)           <= intRxData(55 downto 48) after tpd;
               rxSrcAddr(4)           <= intRxData(47 downto 40) after tpd;
               rxSrcAddr(5)           <= intRxData(39 downto 32) after tpd;
               rxEthType(15 downto 8) <= intRxData(31 downto 24) after tpd;
               rxEthType(7  downto 0) <= intRxData(23 downto 16) after tpd;

               if intRxValid = '0' then
                  curRxState <= ST_RX_IDLE after tpd;
               else
                  curRxState <= ST_RX_SEL  after tpd;
               end if;

            -- Select destination
            when ST_RX_SEL =>
               selRxError <= '0' after tpd;
               selRxGood  <= '0' after tpd;

               if intRxValid = '0' then
                  curRxState <= ST_RX_IDLE after tpd;

               -- ARP Request, dest mac is broadcast
               elsif rxEthType = EthTypeARP and 
                     rxDstAddr(0) = x"FF" and rxDstAddr(1) = x"FF" and
                     rxDstAddr(2) = x"FF" and rxDstAddr(3) = x"FF" and
                     rxDstAddr(4) = x"FF" and rxDstAddr(5) = x"FF" then
                  selRxArpValid <= '1'        after tpd;
                  selRxUdpValid <= '0'        after tpd;
                  curRxState    <= ST_RX_DATA after tpd;

               -- IPV4 Packet
               elsif rxEthType = EthTypeIPV4 and rxDstAddr = MacAddr then
                  selRxArpValid <= '0'        after tpd;
                  selRxUdpValid <= '1'        after tpd;
                  curRxState    <= ST_RX_DATA after tpd;
               else
                  selRxArpValid <= '0'        after tpd;
                  selRxUdpValid <= '0'        after tpd;
                  curRxState    <= ST_RX_DATA after tpd;
               end if;

            -- Move Data
            when ST_RX_DATA =>
               selRxError    <= '0' after tpd;
               selRxGood     <= '0' after tpd;

               if intRxLast = '1' then
                  curRxState <= ST_RX_IDLE after tpd;
               end if;

            -- Done
--             when ST_RX_DONE =>
--                selRxError    <= '0' after tpd;
--                selRxGood     <= '0' after tpd;
--                selRxArpValid <= '0' after tpd;
--                selRxUdpValid <= '0' after tpd;
-- 
--                if intRxGoodFrame = '1' or intRxBadFrame  = '1' then
--                   curRxState <= ST_RX_IDLE     after tpd;
--                   selRxError <= intRxBadFrame  after tpd;
--                   selRxGood  <= intRxGoodFrame after tpd;
--                end if;

            when others => curRxState <= ST_RX_IDLE after tpd;
         end case;
      end if;
   end process;


   --------------------------------
   -- Ethernet Transmit Logic
   --------------------------------

   -- Transmit
   
   emacTxData <= intTxData;
   
   process ( emacClk, emacClkRst ) begin
      if emacClkRst = '1' then
         intTxData  <= (others=>'0') after tpd;
         emacTxValid    <= '0'           after tpd;
         emacTxSOF      <= '0'           after tpd;
         selTxArpReady  <= '0'           after tpd;
         selTxUdpReady  <= '0'           after tpd;
         selTxArp       <= '0'           after tpd;
         txCount        <= (others=>'0') after tpd;
         curTxState     <= ST_TX_IDLE    after tpd;
      elsif rising_edge(emacClk) then

         -- TX Counter
         if curTxState = ST_TX_IDLE or txCount = 5 then
            txCount <= "000" after tpd;
         elsif curTxState = ST_TX_ACK then
            txCount <= "010" after tpd;
         else
            txCount <= txCount + 1 after tpd;
         end if;

         -- State machine
         case curTxState is

            -- IDLE
            when ST_TX_IDLE =>
               emacTxEOF   <= '0' after tpd;
               emacTxWidth <= '0' after tpd;
               emacTxValid <= selTxArpValid or selTxUdpValid after tpd;

               if emacTxReady = '1' then
                  if selTxArpValid = '1' then
                     selTxArpReady           <= '1'            after tpd;
                     selTxUdpReady           <= '0'            after tpd;
                     emacTxSOF               <= '1'            after tpd;
                     selTxArp                <= '1'            after tpd;
                     curTxState              <= ST_TX_SRC      after tpd;
                     intTxData(63 downto 56) <= selTxArpDst(0) after tpd;
                     intTxData(55 downto 48) <= selTxArpDst(1) after tpd;
                     intTxData(47 downto 40) <= selTxArpDst(2) after tpd;
                     intTxData(39 downto 32) <= selTxArpDst(3) after tpd;
                     intTxData(31 downto 24) <= selTxArpDst(4) after tpd;
                     intTxData(23 downto 16) <= selTxArpDst(5) after tpd;
                     intTxData(15 downto  8) <= MacAddr(0)     after tpd;
                     intTxData(7  downto  0) <= MacAddr(1)     after tpd;

                  elsif selTxUdpValid = '1' then
                     selTxArpReady           <= '0'            after tpd;
                     selTxUdpReady           <= '1'            after tpd;
                     emacTxSOF               <= '1'            after tpd;
                     selTxArp                <= '0'            after tpd;
                     curTxState              <= ST_TX_SRC      after tpd;
                     intTxData(63 downto 56) <= selTxUdpDst(0) after tpd;
                     intTxData(55 downto 48) <= selTxUdpDst(1) after tpd;
                     intTxData(47 downto 40) <= selTxUdpDst(2) after tpd;
                     intTxData(39 downto 32) <= selTxUdpDst(3) after tpd;
                     intTxData(31 downto 24) <= selTxUdpDst(4) after tpd;
                     intTxData(23 downto 16) <= selTxUdpDst(5) after tpd;
                     intTxData(15 downto  8) <= MacAddr(0)     after tpd;
                     intTxData(7  downto  0) <= MacAddr(1)     after tpd;
                  end if;
               else
                  intTxData     <= (others=>'0') after tpd;
                  selTxArpReady <= '0'           after tpd;
                  selTxUdpReady <= '0'           after tpd;
                  emacTxSOF     <= '0'           after tpd;
                  selTxArp      <= '0'           after tpd;
               end if;

            -- Source address
            when ST_TX_SRC =>
               emacTxValid   <= '1'          after tpd;
               emacTxSOF     <= '0'          after tpd;
               selTxArpReady <= selTxArp     after tpd;
               selTxUdpReady <= not selTxArp after tpd;
               curTxState    <= ST_TX_DATA   after tpd;

               intTxData(63 downto 56) <= MacAddr(2) after tpd;
               intTxData(55 downto 48) <= MacAddr(3) after tpd;
               intTxData(47 downto 40) <= MacAddr(4) after tpd;
               intTxData(39 downto 32) <= MacAddr(5) after tpd;

               if selTxArp = '1' then
                  intTxData(31 downto 16) <= EthTypeARP   after tpd;
                  intTxData(15 downto  0) <= selTxArpData(15 downto 0) after tpd;
               else
                  intTxData(31 downto 16) <= EthTypeIPV4  after tpd;
                  intTxData(15 downto  0) <= selTxUdpData(15 downto 0) after tpd;
               end if;

            -- Payload Data
            when ST_TX_DATA =>
               emacTxSOF     <= '0'          after tpd;
               selTxArpReady <= selTxArp     after tpd;
               selTxUdpReady <= not selTxArp after tpd;

               if selTxArp = '1' then
                  emacTxValid <= selTxArpValid after tpd;
                  emacTxEOF   <= selTxArpEOF   after tpd;
                  emacTxWidth <= selTxArpWidth after tpd;
                  intTxData   <= selTxArpData  after tpd;
                  if selTxArpValid = '0' then
                     curTxState <= ST_TX_IDLE;
                  end if;
               else
                  emacTxValid <= selTxUdpValid after tpd;
                  emacTxEOF   <= selTxUdpEOF   after tpd;
                  emacTxWidth <= selTxUdpWidth after tpd;
                  intTxData   <= selTxUdpData  after tpd;
                  if selTxUdpValid = '0' then
                     curTxState <= ST_TX_IDLE;
                  end if;
               end if;

            when others => curTxState <= ST_TX_IDLE after tpd;
         end case;
      end if;
   end process;


   --------------------------------
   -- ARP Engine
   --------------------------------
   U_EthClientArp : EthClientArp port map (
      emacClk    => emacClk,
      emacClkRst => emacClkRst,
      ipAddr     => ipAddr,
      macAddr    => macAddr,
      rxData     => selRxData,
      rxLast     => selRxLast,
      rxValid    => selRxArpValid,
      rxSrc      => rxSrcAddr,
      txValid    => selTxArpValid,
      txReady    => selTxArpReady,
      txData     => selTxArpData,
      txSOF      => selTxArpSOF,
      txEOF      => selTxArpEOF,
      txWidth    => selTxArpWidth,
      txDst      => selTxArpDst,
      cScopeCtrl => cScopeCtrl2
   );


   --------------------------------
   -- UDP Engine
   --------------------------------
   U_EthClientUdp: EthClientUdp generic map ( UdpPort => UdpPort ) port map (
      emacClk     => emacClk,
      emacClkRst  => emacClkRst,
      ipAddr      => ipAddr,
      rxData      => selRxData,
      rxLast      => selRxLast,
      rxValid     => selRxUdpValid,
      rxSrc       => rxSrcAddr,
      txValid     => selTxUdpValid,
      txReady     => selTxUdpReady,
      txData      => selTxUdpData,
      txSOF       => selTxUdpSOF,
      txEOF       => selTxUdpEOF,
      txWidth     => selTxUdpWidth,
      txDst       => selTxUdpDst,
      udpTxValid  => udpTxValid,
      udpTxEOF    => udpTxEOF,
      udpTxReady  => udpTxReady,
      udpTxData   => udpTxData,
      udpTxLength => udpTxLength,
      udpRxValid  => udpRxValid,
      udpRxWidth  => udpRxWidth,
      udpRxError  => udpRxError,
      udpRxSOF    => udpRxSOF,
      udpRxEOF    => udpRxEOF,
      udpRxData   => udpRxData,
      cScopeCtrl  => cScopeCtrl2
   );

end EthClient;

