-------------------------------------------------------------------------------
-- Title         : Ethernet Client, ARP Processor
-- Project       : General Purpose Core
-------------------------------------------------------------------------------
-- File          : EthClientArp.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 10/18/2010
-------------------------------------------------------------------------------
-- Description:
-- ARP processor source code for general purpose firmware ethenet client.
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

entity EthClientArp is 
   port (

      -- Ethernet clock & reset
      emacClk    : in  std_logic;
      emacClkRst : in  std_logic;

      -- Local IP Address
      ipAddr     : in  IPAddrType;
      macAddr    : in  MacAddrType;

      -- Receive interface
      rxData     : in  std_logic_vector(63 downto 0);
      rxLast     : in  std_logic;
      rxValid    : in  std_logic;
      rxSrc      : in  MacAddrType;

      -- Transmit interface
      txValid    : out std_logic;
      txReady    : in  std_logic;
      txSOF      : out std_logic;
      txEOF      : out std_logic;
      txData     : out std_logic_vector(63 downto 0);
      txWidth    : out std_logic;
      txDst      : out MacAddrType;

      -- Debug
      cScopeCtrl : inout std_logic_vector(35 downto 0)
   );

end EthClientArp;


-- Define architecture
architecture EthClientArp of EthClientArp is

   -- Local Signals
   signal rxCount  : std_logic_vector(5 downto 0);
   signal txCount  : std_logic_vector(2 downto 0);
   signal rxArpMsg : ArpMsgType;
   signal txArpMsg : ArpMsgType;
   signal txStart  : std_logic;
   signal txBusy   : std_logic;

   -- Ethernet RX States
   constant ST_RX_IDLE   : std_logic_vector(1 downto 0) := "00";
   constant ST_RX_ARP    : std_logic_vector(1 downto 0) := "01";
   constant ST_RX_WAIT   : std_logic_vector(1 downto 0) := "10";
   constant ST_RX_SEND   : std_logic_vector(1 downto 0) := "11";
   signal   curRXState   : std_logic_vector(1 downto 0);

   -- Debug
   signal   cScopeTrig   : std_logic_vector(63 downto 0);
   signal   locTxData    : std_logic_vector(63 downto 0);
   signal   locTxSOF     : std_logic;
   signal   locTxEOF     : std_logic;
   constant enChipScope  : std_logic := '0';

begin


   -----------------------------
   -- Chipscope for debug
   -----------------------------

   -- Debug Signals
--    cScopeTrig (63)           <= txBusy;
--    cScopeTrig (62)           <= txStart;
--    cScopeTrig (61 downto 56) <= rxCount;
--    cScopeTrig (55 downto 54) <= curRXState;
--    cScopeTrig (53 downto 51) <= (OTHERS => '0');
--    cScopeTrig (50)           <= rxError;
--    cScopeTrig (49)           <= rxGood;
--    cScopeTrig (48)           <= rxValid;
--    cScopeTrig (47 downto 40) <= rxArpMsg(4);
--    cScopeTrig (39 downto 32) <= rxArpMsg(3);
--    cScopeTrig (31 downto 24) <= rxArpMsg(2);
--    cScopeTrig (23 downto 16) <= rxArpMsg(1);
--    cScopeTrig (15 downto 8)  <= rxArpMsg(0);
--    cScopeTrig (7  downto 0)  <= rxdata;
   
   -- Chipscope logic analyzer
   chipscope : if (enChipScope = '1') generate
   U_EthClientArp_ila : v5_Ila port map ( control => cScopeCtrl,
                                          clk     => emacClk,
                                          trig0   => cscopeTrig);
   end generate chipscope;
   
   --------------------------------
   -- ARP Receive Logic
   --------------------------------

   -- Sync state logic
   process ( emacClk, emacClkRst ) begin
      if emacClkRst = '1' then
         rxCount    <= (others=>'0')   after tpd;
         rxArpMsg   <= (others=>(others=>'0')) after tpd;
         txDst      <= (others=>(others=>'0')) after tpd;
         txStart    <= '0'             after tpd;
         curRxState <= ST_RX_IDLE      after tpd;
      elsif rising_edge(emacClk) then

         -- RX Data
         if rxValid = '1' and rxCount < 4 then
           rxArpMsg(conv_integer(rxCount)) <= rxData after tpd; 
         end if;

         -- RX Counter
         if rxValid = '0' then
            rxCount <= (others=>'0') after tpd;
         elsif rxCount /= 7 then
            rxCount <= rxCount + 1 after tpd;
         end if;

         -- State machine
         case curRxState is

            -- IDLE
            when ST_RX_IDLE =>
               if rxValid = '1' then
                  curRxState <= ST_RX_ARP after tpd;
               end if;
               txStart <= '0' after tpd;

            -- ARP message
            when ST_RX_ARP =>
               if rxValid = '0' then
                  curRxState <= ST_RX_IDLE after tpd;
               elsif rxCount = 2 then
                  curRxState <= ST_RX_WAIT after tpd;
               end if;

            -- Wait for message status
            when ST_RX_WAIT =>
               if rxLast = '1' then
                  if txBusy = '0' then
                     curRxState <= ST_RX_SEND after tpd;
                     txDst      <= rxSrc      after tpd;
                  else
                     curRxState <= ST_RX_IDLE after tpd;
                  end if;
               end if;

            -- Check message and send response
            when ST_RX_SEND =>
               if rxArpMsg(0) = x"0001" & EthTypeIPV4 & x"06040001" then
--                   rxArpMsg(0) = x"00"                    and  -- Hardware type
--                   rxArpMsg(1) = x"01"                    and  -- Hardware type
--                   rxArpMsg(2) = EthTypeIPV4(15 downto 8) and  -- Protocol type
--                   rxArpMsg(3) = EthTypeIPV4(7  downto 0) and  -- Protocol type
--                   rxArpMsg(4) = x"06"                    and  -- Hardware Addr length
--                   rxArpMsg(5) = x"04"                    and  -- Protocol Addr length
--                   rxArpMsg(6) = x"00"                    and  -- Opcode, Arp Request
--                   rxArpMsg(7) = x"01"                    then -- Opcode, Arp Request
                  txStart <= '1' after tpd;
               end if;
               curRxState <= ST_RX_IDLE after tpd;

            when others => curRxState <= ST_RX_IDLE after tpd;
         end case;
      end if;
   end process;


   --------------------------------
   -- Ethernet Transmit Logic
   --------------------------------

   -- Transmit
   
   txData  <= locTxData;
   txSOF   <= locTxSOF;
   txEOF   <= locTxEOF;
   txWidth <= '0';
   txValid <= txBusy;

   process ( emacClk, emacClkRst ) begin
      if emacClkRst = '1' then
         txBusy         <= '0'             after tpd;
         locTxData      <= (others=>'0')   after tpd;
         txCount        <= (others=>'0')   after tpd;
         txArpMsg       <= (others=>(others=>'0')) after tpd;
      elsif rising_edge(emacClk) then

         -- RX Data
         if txReady = '0' then
            locTxData <= txArpMsg(0) after tpd;
            locTxSOF  <= '1'         after tpd;
            locTxEOF  <= '0'         after tpd;
         elsif txCount < 5 then
            locTxData <= txArpMsg(conv_integer(txCount)) after tpd;
            locTxSOF  <= '0'         after tpd;

            if txCount = 4 then
               locTxEOF  <= '1' after tpd;
            else
               locTxEOF  <= '0' after tpd;
            end if;
         else
            locTxData <= (others=>'0')  after tpd;
            locTxSOF  <= '0'         after tpd;
            locTxEOF  <= '0'         after tpd;
         end if;

         -- TX Counter
         if txReady = '0' or txBusy = '0' then
            txCount <= "001" after tpd;
         elsif txCount /= 7 then
            txCount <= txCount + 1 after tpd;
         end if;

         -- Create arp response
         if txStart = '1' then
            txArpMsg(0) <= x"000000000000" & x"0001" after tpd; --Shifting for easy interfacing with ethClient
            txArpMsg(1) <= EthTypeIPV4 & x"06040002" & MacAddr(0) & MacAddr(1) after tpd;
--             txArpMsg(0)  <= x"00"                    after tpd; -- Hardware type
--             txArpMsg(1)  <= x"01"                    after tpd; -- Hardware type
--             txArpMsg(2)  <= EthTypeIPV4(15 downto 8) after tpd; -- Protocol Type
--             txArpMsg(3)  <= EthTypeIPV4(7  downto 0) after tpd; -- Protocol Type
--             txArpMsg(4)  <= x"06"                    after tpd; -- Hardware Length
--             txArpMsg(5)  <= x"04"                    after tpd; -- Protocol Length
--             txArpMsg(6)  <= x"00"                    after tpd; -- OpCode, Arp Reply
--             txArpMsg(7)  <= x"02"                    after tpd; -- OpCode, Arp Reply
            txArpMsg(2) <= MacAddr(2) & MacAddr(3) & MacAddr(4) & MacAddr(5) & 
                           IpAddr(3)  & IpAddr(2)  & IpAddr(1)  & IpAddr(0) after tpd; -- My Mac Addr
            txArpMsg(3) <= rxArpMsg(1) after tpd;
            txArpMsg(4) <= rxArpMsg(2)(63 downto 48) & x"000000000000" after tpd;
         end if;

         -- State control
         if txStart = '1' then
            txBusy  <= '1' after tpd;
         elsif txCount = 5 then
            txBusy <= '0' after tpd;
         end if;
      end if;
   end process;

end EthClientArp;

