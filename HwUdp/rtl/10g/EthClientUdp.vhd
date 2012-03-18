-------------------------------------------------------------------------------
-- Title         : Ethernet Client, UDP Processor
-- Project       : General Purpose Core
-------------------------------------------------------------------------------
-- File          : EthClientUdp.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 10/18/2010
-------------------------------------------------------------------------------
-- Description:
-- UDP processor source code for general purpose firmware ethenet client.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 10/18/2010: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
USE work.ALL;
use work.EthClientPackage.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity EthClientUdp is 
   generic ( 
      UdpPort : integer := 8192
   );
   port (

      -- Ethernet clock & reset
      emacClk     : in  std_logic;
      emacClkRst  : in  std_logic;

      -- Local IP Address
      ipAddr      : in  IPAddrType;

      -- Receive interface
      rxData      : in  std_logic_vector(63 downto 0);
      rxLast      : in  std_logic;
      rxValid     : in  std_logic;
      rxSrc       : in  MacAddrType;

      -- Transmit interface
      txValid     : out std_logic;
      txReady     : in  std_logic;
      txSOF       : out std_logic;
      txEOF       : out std_logic;
      txData      : out std_logic_vector(63 downto 0);
      txWidth     : out std_logic;
      txDst       : out MacAddrType;

      -- UDP Transmit interface
      udpTxValid  : in  std_logic;
      udpTxEOF    : in  std_logic;
      udpTxReady  : out std_logic;
      udpTxData   : in  std_logic_vector(63 downto 0);
      udpTxLength : in  std_logic_vector(15 downto 0);

      -- UDP Receive interface
      udpRxValid  : out std_logic;
      udpRxSOF    : out std_logic;
      udpRxEOF    : out std_logic;
      udpRxWidth  : out std_logic;
      udpRxError  : out std_logic;
      udpRxData   : out std_logic_vector(63 downto 0);

      -- Debug
      cScopeCtrl  : inout std_logic_vector(35 downto 0)
   );

end EthClientUdp;


-- Define architecture
architecture EthClientUdp of EthClientUdp is

   -- Local Signals
   signal rxUdpHead    : UDPMsgType;
   signal txUdpHead    : ARPMsgType;
   signal rxCount      : std_logic_vector(15 downto 0);
   signal txCount      : std_logic_vector(15 downto 0);
   signal myPortAddr   : std_logic_vector(15 downto 0);
   signal lastIpAddr   : IPAddrType;
   signal lastMacAddr  : MacAddrType;
   signal lastPort     : std_logic_vector(15 downto 0);
   signal intTxLength  : std_logic_vector(15 downto 0);
   signal IPV4Length   : std_logic_vector(15 downto 0);
   signal UDPLength    : std_logic_vector(15 downto 0);
   signal rxUdpLength  : std_logic_vector(15 downto 0);
   signal compCSumAA   : std_logic_vector(16 downto 0);
   signal compCSumAB   : std_logic_vector(16 downto 0);
   signal compCSumAC   : std_logic_vector(16 downto 0);
   signal compCSumAD   : std_logic_vector(16 downto 0);
   signal compCSumBA   : std_logic_vector(17 downto 0);
   signal compCSumBB   : std_logic_vector(17 downto 0);
   signal compCSumC    : std_logic_vector(18 downto 0);
   signal compCSumD    : std_logic_vector(19 downto 0);
   signal CompCheckSum : std_logic_vector(20 downto 0);
   signal shiftRxData  : std_logic_vector(47 downto 0);
   signal shiftTxData  : std_logic_vector(15 downto 0);
   
   -- RX States
   constant ST_RX_IDLE   : std_logic_vector(3 downto 0) := "0000";
   constant ST_RX_HEAD   : std_logic_vector(3 downto 0) := "0001";
   constant ST_RX_CHECK  : std_logic_vector(3 downto 0) := "0010";
   constant ST_RX_LENGTH : std_logic_vector(3 downto 0) := "0011";
   constant ST_RX_DATA   : std_logic_vector(3 downto 0) := "0100";
   constant ST_RX_DUMP   : std_logic_vector(3 downto 0) := "0101";
   constant ST_RX_SOF    : std_logic_vector(3 downto 0) := "0110";
   constant ST_RX_EOF    : std_logic_vector(3 downto 0) := "0111";
   constant ST_RX_SEOF   : std_logic_vector(3 downto 0) := "1000";
   signal   curRXState   : std_logic_vector(3 downto 0);

   -- TX States
   constant ST_TX_IDLE   : std_logic_vector(2 downto 0) := "000";
   constant ST_TX_HEAD1  : std_logic_vector(2 downto 0) := "001";
   constant ST_TX_HEAD2  : std_logic_vector(2 downto 0) := "010";
   constant ST_TX_HEAD3  : std_logic_vector(2 downto 0) := "011";
   constant ST_TX_DATA   : std_logic_vector(2 downto 0) := "100";
   constant ST_TX_PAD    : std_logic_vector(2 downto 0) := "101";
   constant ST_TX_EOF    : std_logic_vector(2 downto 0) := "110";
   signal   curTXState   : std_logic_vector(2 downto 0);

   -- Debug
   signal   cScopeTrig   : std_logic_vector(63 downto 0);
   signal   locTxData    : std_logic_vector(63 downto 0);
   constant enChipScope  : integer := 0;
   signal   intRxValid   : std_logic;
   signal   intTxReady   : std_logic;
   signal   locTxValid   : std_logic;
   signal   locTxSOF     : std_logic;
   signal   locTxEOF     : std_logic;
   signal   locTxWidth   : std_logic;

begin

   -----------------------------
   -- Chipscope for debug
   -----------------------------

   -- Debug Signals
--    cScopeTrig (63 downto 56) <= ;
--    cScopeTrig (50)           <= udpTxEOF;
--    cScopeTrig (49)           <= locTxValid;
--    cScopeTrig (48)           <= intTxReady;
--    cScopeTrig (47)           <= udpTxValid;
--    cScopeTrig (46 downto 45) <= curTXState;
--    cScopeTrig (44 downto 29) <= txCount;
--    cScopeTrig (28 downto 16) <= udpTxLength(12 downto 0);
--    cScopeTrig (15 downto 8)  <= udpTxData;
--    cScopeTrig (7  downto 0)  <= locTxData;
   
   -- Chipscope logic analyzer
   chipscope : if (enChipScope = 1) generate
   U_EthClientUdp_ila : v5_ila port map ( control => cScopeCtrl,
                                          clk     => emacClk,
                                          trig0   => cscopeTrig);
   end generate chipscope;
   
   -- Convert port address
   myPortAddr <= conv_std_logic_vector(UdpPort,16);

   --------------------------------
   -- Receive Logic
   --------------------------------
   udpRxValid <= intRxValid;
   
   -- Sync state logic
   process ( emacClk, emacClkRst ) begin
      if emacClkRst = '1' then
         rxCount     <= (others=>'0')   after tpd;
         rxUdpHead   <= (others=>x"00") after tpd;
         rxUdpLength <= (others=>'0')   after tpd;
         udpRxSOF    <= '0'             after tpd;
         udpRxEOF    <= '0'             after tpd;
         intRxValid  <= '0'             after tpd;
         udpRxData   <= (others=>'0')   after tpd;
         udpRxWidth  <= '0'             after tpd;
         udpRxError  <= '0'             after tpd;
         lastIpAddr  <= (others=>x"00") after tpd;
         lastMacAddr <= (others=>x"00") after tpd;
         lastPort    <= (others=>'0')   after tpd;
         curRxState  <= ST_RX_IDLE      after tpd;
      elsif rising_edge(emacClk) then

         -- RX Counter
         if rxValid = '0' then
            rxCount <= x"0000" after tpd;
         elsif curRxState = ST_RX_CHECK then
            rxCount <= x"0008" after tpd;
         elsif curRxState = ST_RX_LENGTH or curRxState = ST_RX_SOF or curRxState = ST_RX_DATA then
            rxCount <= rxCount + 8 after tpd;
         end if;

         -- State machine
         case curRxState is

            -- IDLE
            when ST_RX_IDLE =>
               if rxValid = '1' then
                  curRxState   <= ST_RX_HEAD           after tpd;
                  rxUdpHead(0) <= rxData(63 downto 56) after tpd;
                  rxUdpHead(1) <= rxData(55 downto 48) after tpd;
                  rxUdpHead(2) <= rxData(47 downto 40) after tpd;
                  rxUdpHead(3) <= rxData(39 downto 32) after tpd;
                  rxUdpHead(4) <= rxData(31 downto 24) after tpd;
                  rxUdpHead(5) <= rxData(23 downto 16) after tpd;
                  rxUdpHead(6) <= rxData(15 downto  8) after tpd;
                  rxUdpHead(7) <= rxData(7  downto  0) after tpd;
               else
                  curRxState   <= ST_RX_IDLE      after tpd;
                  rxUdpHead    <= (others=>x"00") after tpd;
               end if;
               rxUdpLength <= (others=>'0') after tpd;
               shiftRxData <= (others=>'0') after tpd;
               udpRxData   <= (others=>'0') after tpd;
               intRxValid  <= '0' after tpd;
               udpRxSOF    <= '0' after tpd;
               udpRxEOF    <= '0' after tpd;
               udpRxWidth  <= '0' after tpd;
               udpRxError  <= '0' after tpd;

            -- IPV4 Header
            when ST_RX_HEAD =>
               if rxValid = '0' then
                  curRxState    <= ST_RX_IDLE  after tpd;
               else
                  curRxState    <= ST_RX_CHECK after tpd;
                  rxUdpHead(8)  <= rxData(63 downto 56) after tpd;
                  rxUdpHead(9)  <= rxData(55 downto 48) after tpd;
                  rxUdpHead(10) <= rxData(47 downto 40) after tpd;
                  rxUdpHead(11) <= rxData(39 downto 32) after tpd;
                  rxUdpHead(12) <= rxData(31 downto 24) after tpd;
                  rxUdpHead(13) <= rxData(23 downto 16) after tpd;
                  rxUdpHead(14) <= rxData(15 downto  8) after tpd;
                  rxUdpHead(15) <= rxData(7  downto  0) after tpd;
               end if;
               udpRxData  <= (others=>'0') after tpd;
               intRxValid <= '0' after tpd;
               udpRxSOF   <= '0' after tpd;
               udpRxEOF   <= '0' after tpd;
               udpRxWidth <= '0' after tpd;
               udpRxError <= '0' after tpd;

            -- Check header
            when ST_RX_CHECK =>
               if rxValid = '0' then
                  curRxState <= ST_RX_IDLE after tpd;
               elsif rxUdpHead(9)         = UDPProtocol and  -- Protocol
                     rxData(63 downto 56) = ipAddr(3)   and  -- My IP Address
                     rxData(55 downto 48) = ipAddr(2)   and  -- My IP Address
                     rxData(47 downto 40) = ipAddr(1)   and  -- My IP Address
                     rxData(39 downto 32) = ipAddr(0)   and  -- My IP Address
                     rxData(15 downto  0) = myPortAddr  then -- My UDP Port

                  -- Store some fields for transmittion
                  lastIpAddr(3) <= rxUdpHead(12)        after tpd;
                  lastIpAddr(2) <= rxUdpHead(13)        after tpd;
                  lastIpAddr(1) <= rxUdpHead(14)        after tpd;
                  lastIpAddr(0) <= rxUdpHead(15)        after tpd;
                  lastMacAddr   <= rxSrc                after tpd;
                  lastPort      <= rxData(31 downto 16) after tpd;
                  curRxState    <= ST_RX_LENGTH         after tpd;
               else
                  curRxState <= ST_RX_DUMP after tpd;
               end if;
               udpRxData  <= (others=>'0') after tpd;
               intRxValid <= '0' after tpd;
               udpRxSOF   <= '0' after tpd;
               udpRxEOF   <= '0' after tpd;
               udpRxWidth <= '0' after tpd;
               udpRxError <= '0' after tpd;

            -- Data Length
            when ST_RX_LENGTH =>
               if rxCount >= rxData(63 downto 48) then --rxValid = '0' or rxLast = '1' then
                  curRxState  <= ST_RX_SEOF after tpd;
              else
                  curRxState  <= ST_RX_SOF  after tpd;
               end if;
               rxUdpLength <= rxData(63 downto 48) after tpd;
               shiftRxData <= rxData(47 downto  0) after tpd;
               udpRxData   <= (others=>'0')        after tpd;
               udpRxSOF    <= '0' after tpd;
               intRxValid  <= '0' after tpd;
               udpRxEOF    <= '0' after tpd;
               udpRxWidth  <= '0' after tpd;
               udpRxError  <= '0' after tpd;

            -- Asserting SOF
            when ST_RX_SOF =>
               if rxCount >= rxUdpLength then --rxValid = '0' or rxLast = '1' then
                  curRxState  <= ST_RX_EOF  after tpd;
               else
                  curRxState  <= ST_RX_DATA after tpd;
               end if;
               udpRxData   <= shiftRxData & rxData(63 downto 48) after tpd;
               shiftRxData <= rxData(47 downto 0)                after tpd;
               udpRxSOF    <= '1' after tpd;
               intRxValid  <= '1' after tpd;
               udpRxEOF    <= '0' after tpd;
               udpRxWidth  <= '0' after tpd;
               udpRxError  <= '0' after tpd;

            -- Output Data
            when ST_RX_DATA =>
               if rxCount >= rxUdpLength then --rxValid = '0' or rxLast = '1' then 
                  curRxState <= ST_RX_EOF after tpd;
               end if;
               udpRxData   <= shiftRxData & rxData(63 downto 48) after tpd;
               shiftRxData <= rxData(47 downto 0)                after tpd;
               udpRxSOF    <= '0' after tpd;
               intRxValid  <= '1' after tpd;
               udpRxEOF    <= '0' after tpd;
               udpRxWidth  <= '0' after tpd;
               udpRxError  <= '0' after tpd;

            -- Dump Data
            when ST_RX_DUMP =>
               if rxValid = '0' then
                  curRxState <= ST_RX_IDLE after tpd;
               end if;
               intRxValid <= '0' after tpd;
               udpRxData  <= (others=>'0') after tpd;
               udpRxSOF   <= '0' after tpd;
               udpRxEOF   <= '0' after tpd;
               udpRxWidth <= '0' after tpd;
               udpRxError <= '0' after tpd;

            -- EOF
            when ST_RX_EOF =>
               udpRxData  <= shiftRxData & x"0000" after tpd;
               intRxValid <= '1'        after tpd;
               udpRxSOF   <= '0'        after tpd;
               udpRxEOF   <= '1'        after tpd;
               curRxState <= ST_RX_IDLE after tpd;
               udpRxWidth <= not rxUdpLength(2) and not rxUdpLength(1) and not rxUdpLength(0) after tpd; -- Multiples of 8
               udpRxError <= rxUdpLength(1) or rxUdpLength(0) after tpd; -- Not multiples of 4

            -- Only one frame
            when ST_RX_SEOF =>
               udpRxData  <= shiftRxData & rxData(63 downto 48) after tpd;
               intRxValid <= '1'        after tpd;
               udpRxSOF   <= '1'        after tpd;
               udpRxEOF   <= '1'        after tpd;
               curRxState <= ST_RX_IDLE after tpd;
               udpRxWidth <= not rxUdpLength(2) and not rxUdpLength(1) and not rxUdpLength(0) after tpd; -- Multiples of 8
               udpRxError <= rxUdpLength(1) or rxUdpLength(0) after tpd; -- Not multiples of 4

            when others => curRxState <= ST_RX_IDLE after tpd;
         end case;
      end if;
   end process;


   --------------------------------
   -- Transmit Logic
   --------------------------------

   -- Checksum and length adder
   process ( emacClk, emacClkRst ) begin
      if emacClkRst = '1' then
         compCSumAA   <= (others=>'0') after tpd;
         compCSumAB   <= (others=>'0') after tpd;
         compCSumAC   <= (others=>'0') after tpd;
         compCSumAD   <= (others=>'0') after tpd;
         compCSumBA   <= (others=>'0') after tpd;
         compCSumBB   <= (others=>'0') after tpd;
         compCSumC    <= (others=>'0') after tpd;
         compCSumD    <= (others=>'0') after tpd;
         compCheckSum <= (others=>'0') after tpd;
      elsif rising_edge(emacClk) then

         -- Level 0
         compCSumAA   <= ('0' & txUdpHead(0)(63 downto 56) & txUdpHead(0)(55 downto 48)) +
                         ('0' & txUdpHead(1)(63 downto 56) & txUdpHead(1)(55 downto 48))  after tpd;
         compCSumAB   <= ('0' & txUdpHead(1)(47 downto 40) & txUdpHead(1)(39 downto 32)) +
                         ('0' & txUdpHead(1)(31 downto 24) & txUdpHead(1)(23 downto 16))  after tpd;
         compCSumAC   <= ('0' & txUdpHead(1)(15 downto  8) & txUdpHead(1)(7  downto  0)) +
                         ('0' & txUdpHead(2)(47 downto 40) & txUdpHead(2)(39 downto 32)) after tpd;
         compCSumAD   <= ('0' & txUdpHead(2)(31 downto 24) & txUdpHead(2)(23 downto 16)) +
                         ('0' & txUdpHead(2)(15 downto  8) & txUdpHead(2)(7  downto  0)) after tpd;

         -- Level 1
         compCSumBA   <= ('0' & compCSumAA) + ('0' & compCSumAB) after tpd;
         compCSumBB   <= ('0' & compCSumAC) + ('0' & compCSumAD) after tpd;

         -- Level 2
         compCSumC    <= ('0' & compCSumBA) + ('0' & compCSumBB) after tpd;

         -- Level 3
         compCSumD    <= ('0' & compCSumC) + ("000" & txUdpHead(3)(63 downto 56) & txUdpHead(3)(55 downto 48)) after tpd;

         -- Level 4
         compCheckSum <= ('0' & x"0000" & compCSumD(19 downto 16)) + ("00000" & compCSumD(15 downto 0));
                        
      end if;
   end process;

   -- Define IPV4/UDP Header
   txUdpHead(0)  <= x"000000000000" & x"4500"; --Shifting for easy interfacing with ethClient
   txUdpHead(1)  <= IPV4Length & x"0000000006" & UDPProtocol;
   txUdpHead(2)  <= not compCheckSum & ipAddr(3) & ipAddr(2) & ipAddr(1) & ipAddr(0) & lastIpAddr(3) & lastIpAddr(2);
   txUdpHead(3)  <= lastIpAddr(1) & lastIpAddr(0) & myPortAddr & lastPort & UDPLength;
--    txUdpHead(0)  <= x"45";                         -- Header length 5, IPVersion 4
--    txUdpHead(1)  <= x"00";                         -- Type of service
--    txUdpHead(2)  <= IPV4Length(15 downto 8);       -- Length
--    txUdpHead(3)  <= IPV4Length(7  downto 0);       -- Length
--    txUdpHead(4)  <= x"00";                         -- Id
--    txUdpHead(5)  <= x"00";                         -- Id
--    txUdpHead(6)  <= x"00";                         -- flags, frag
--    txUdpHead(7)  <= x"00";                         -- flags, frag
--    txUdpHead(8)  <= x"06";                         -- Time to live
--    txUdpHead(9)  <= UDPProtocol;                   -- Protocol
--    txUdpHead(10) <= not compCheckSum(15 downto 8); -- Checksum
--    txUdpHead(11) <= not compCheckSum(7  downto 0); -- Checksum
--    txUdpHead(12) <= ipAddr(3);                     
--    txUdpHead(13) <= ipAddr(2);                     
--    txUdpHead(14) <= ipAddr(1);                     
--    txUdpHead(15) <= ipAddr(0);                     
--    txUdpHead(16) <= lastIpAddr(3);                 
--    txUdpHead(17) <= lastIpAddr(2);                 
--    txUdpHead(18) <= lastIpAddr(1);                 
--    txUdpHead(19) <= lastIpAddr(0);
--    txUdpHead(20) <= myPortAddr(15 downto 8);       
--    txUdpHead(21) <= myPortAddr(7  downto 0);                 
--    txUdpHead(22) <= lastPort(15 downto 8);
--    txUdpHead(23) <= lastPort(7  downto 0);
--    txUdpHead(24) <= UDPLength(15 downto 8);        
--    txUdpHead(25) <= UDPLength(7  downto 0);        
--    txUdpHead(26) <= x"00";                         -- UDP Checksum unused
--    txUdpHead(27) <= x"00";                         -- UDP Checksum unused

   -- Transmit
   txSOF      <= locTxSOF;
   txEOF      <= locTxEOF;
   txData     <= locTxData;
   txWidth    <= locTxWidth;
   txValid    <= locTxValid;
   udpTxReady <= intTxReady;
   process ( emacClk, emacClkRst ) begin
      if emacClkRst = '1' then
         IPV4Length        <= (others=>'0')   after tpd;
         UDPLength         <= (others=>'0')   after tpd;
         locTxValid        <= '0'             after tpd;
         locTxSOF          <= '0'             after tpd;
         locTxEOF          <= '0'             after tpd;
         locTxData         <= (others=>'0')   after tpd;
         locTxWidth        <= '0'             after tpd;
         shiftTxData       <= (others=>'0')   after tpd;
         txCount           <= x"0008"         after tpd;
         txDst             <= (others=>x"00") after tpd;
         intTxReady        <= '0'             after tpd;
         intTxLength       <= (others=>'0')   after tpd;
         curTxState        <= ST_TX_IDLE      after tpd;
      elsif rising_edge(emacClk) then

         -- UDP Length, 8 Byte + length + SOF/EOF frames
         UDPLength  <= 8  + udpTxLength + 8 after tpd;
         -- IPV4 Length, 20 Byte IPV4 + UDP Length + SOF/EOF frames
         IPV4Length <= 20 + udpTxLength + 8 after tpd;
         
         -- TX Counter
--          if curTxState = ST_TX_IDLE then
--             txCount <= (others=>'0') after tpd;
--          elsif txReady = '1' and txCount /= x"FFFF" then
--             txCount <= txCount + 8 after tpd;
--          end if;

         -- State machine
         case curTxState is

            -- IDLE
            when ST_TX_IDLE =>
               if udpTxValid = '1' and txReady = '0' then
                  locTxData        <= txUdpHead(0) after tpd;
                  locTxSOF         <= '1'          after tpd;
                  curTxState       <= ST_TX_HEAD1  after tpd;
                  locTxValid       <= '1'          after tpd;
                  txDst            <= lastMacAddr  after tpd; 
                  intTxLength      <= udpTxLength + 8 after tpd; -- Adding 8 for SOF/EOF frames
               end if;
               intTxReady          <= '0'           after tpd;
               shiftTxData         <= (others=>'0') after tpd;
               locTxEOF            <= '0'           after tpd;
               locTxWidth          <= '0'           after tpd;
               txCount             <= x"0008"       after tpd;

            -- Header1
            when ST_TX_HEAD1 =>
               locTxSOF   <= '0'          after tpd;
               if txReady = '1' then
                  --locTxValid <= '1'          after tpd;
                  locTxData  <= txUdpHead(1) after tpd;
                  curTxState <= ST_TX_HEAD2  after tpd;
--                else
--                   locTxValid <= '0'         after tpd;
--                   curTxState <= ST_TX_HEAD1 after tpd;
               end if;

            -- Header2
            when ST_TX_HEAD2 =>
               if txReady = '1' then
                  locTxValid <= '1'          after tpd;
                  locTxData  <= txUdpHead(2) after tpd;
                  intTxReady <= '1'          after tpd; -- Asserting one clock cycle ahead for udpTxData to be ready
                  curTxState <= ST_TX_HEAD3  after tpd;
               else
                  locTxValid <= '0'          after tpd;
                  intTxReady <= '0'          after tpd;
                  curTxState <= ST_TX_HEAD2  after tpd;
               end if;

            -- Header3
            when ST_TX_HEAD3 =>
               if txReady = '1' then
                  locTxValid <= '1'          after tpd;
                  locTxData  <= txUdpHead(3) after tpd;
                  intTxReady <= '1'          after tpd;
                  curTxState <= ST_TX_DATA   after tpd;
               else
                  locTxValid <= '0'          after tpd;
                  intTxReady <= '0'          after tpd;
                  curTxState <= ST_TX_HEAD3  after tpd;
               end if;

            -- Data  
            when ST_TX_DATA =>
               if txReady = '1' then
                  locTxData(63 downto 48) <= shiftTxData             after tpd;
                  locTxData(47 downto  0) <= udpTxData(63 downto 16) after tpd;
                  shiftTxData             <= udpTxData(15 downto  0) after tpd;
                  txCount                 <= txCount + 8             after tpd;

                  if udpTxEOF = '1' then
                     if txCount < 46 then
                        curTxState <= ST_TX_PAD  after tpd;
                     else
                        curTxState <= ST_TX_EOF  after tpd;
                     end if;
                  
                     intTxReady    <= '0'        after tpd;
                  end if;
               else
                  locTxValid <= '0'         after tpd;
                  intTxReady <= '0'         after tpd;
                  curTxState <= ST_TX_DATA  after tpd;
               end if;

            when ST_TX_EOF =>
               locTxData(63 downto 48) <= shiftTxData   after tpd;
               locTxData(47 downto  0) <= (others=>'0') after tpd;
               curTxState              <= ST_TX_IDLE    after tpd;
               locTxValid              <= '0'           after tpd;
               locTxEOF                <= '1'           after tpd;
               locTxWidth              <= '0'           after tpd;

            -- PAD to 46 bytes
            when ST_TX_PAD =>
               locTxData  <= (others=>'0') after tpd;
               txCount    <= txCount + 8   after tpd;
               
               if txCount >= 46 then
                  curTxState <= ST_TX_IDLE after tpd;
                  locTxValid <= '0'        after tpd;
                  locTxEOF   <= '1'        after tpd;
                  locTxWidth <= '1'        after tpd;
               end if;

            when others => curTxState <= ST_TX_IDLE after tpd;
         end case;
      end if;
   end process;

end EthClientUdp;

