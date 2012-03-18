-------------------------------------------------------------------------------
-- Title         : 10G MAC Data Arbiter
-- Project       : RCE 10G-bit MAC
-------------------------------------------------------------------------------
-- File          : XMacArbiter.vhd
-- Author        : Raghuveer Ausoori, ausoori@slac.stanford.edu
-- Created       : 05/31/2011
-------------------------------------------------------------------------------
-- Description:
-- Data Arbiter for 10G MAC core for the RCE.
-------------------------------------------------------------------------------
-- Copyright (c) 2011 by Raghuveer Ausoori. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 05/31/2011: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
use work.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.EthClientPackage.all;

entity XMacArbiter is
   port (

      -- Ethernet clock & reset
      macClk        : in  std_logic;                        -- 125Mhz master clock
      macRst        : in  std_logic;                        -- Synchronous reset input

      -- Data from Device 1
      part1Valid    : in  std_logic;
      part1EOF      : in  std_logic;
      part1Ready    : out std_logic;
      part1Data     : in  std_logic_vector(63 downto 0);
      part1Length   : in  std_logic_vector(15 downto 0);

      -- Data from Device 2
      part2Valid    : in  std_logic;
      part2EOF      : in  std_logic;
      part2Ready    : out std_logic;
      part2Data     : in  std_logic_vector(63 downto 0);
      part2Length   : in  std_logic_vector(15 downto 0);
      
      -- UDP Transmit interface
      udpTxValid    : out std_logic;
      udpTxEOF      : out std_logic;
      udpTxReady    : in  std_logic;
      udpTxData     : out std_logic_vector(63 downto 0);
      udpTxLength   : out std_logic_vector(15 downto 0);
      
      -- Debug
      csControl     : inout  std_logic_vector(35 downto 0)  -- Chip Scope Control
      
   );
end XMacArbiter;


-- Define architecture for Interface module
architecture XMacArbiter of XMacArbiter is

   signal loc1Valid   : std_logic;
   signal loc2Valid   : std_logic;
   signal udpDone     : std_logic;
   signal negTxReady  : std_logic;
   signal muxSel      : std_logic_vector(1 downto 0);
   
begin

   process ( macClk, macRst ) begin
      if macRst = '1' then
         loc1Valid   <= '0' after tpd;
         loc2Valid   <= '0' after tpd;
         udpDone     <= '0' after tpd;
         part1Ready  <= '0' after tpd;
         part2Ready  <= '0' after tpd;
         negTxReady  <= '1' after tpd;
         udpTxValid  <= '0' after tpd;
         udpTxEOF    <= '0' after tpd;
         udpTxData   <= (others=>'0') after tpd;
         udpTxLength <= (others=>'0') after tpd;
         muxSel      <= (others=>'0') after tpd;
      elsif rising_edge (macClk) then
      
--    process ( muxSel, part1Valid, part1EOF, part1Data, part1Length,
--              part2Valid, part2EOF, part2Data, part2Length, udpTxReady )
--    begin
         
         negTxReady <= not udpTxReady after tpd;
         udpDone    <= not (negTxReady or udpTxReady) after tpd;
         
         if udpDone = '1' and muxSel = "00" then
            loc1Valid <= '0' after tpd;
         elsif part1Valid = '1' then
            loc1Valid <= '1' after tpd;
         end if;
         
         if udpDone = '1' and muxSel = "01" then
            loc2Valid <= '0' after tpd;
         elsif part2Valid = '1' then
            loc2Valid <= '1' after tpd;
         end if;
         
         case muxSel is
            when "00" =>
               udpTxValid  <= loc1Valid   after tpd;
               udpTxEOF    <= part1EOF    after tpd;
               part1Ready  <= udpTxReady  after tpd;
               udpTxData   <= part1Data   after tpd;
               udpTxLength <= part1Length after tpd;
               
               if loc2Valid = '1' and udpDone = '1' then
                  muxSel     <= "01" after tpd;
               end if;
            when "01" =>
               udpTxValid  <= loc2Valid   after tpd;
               udpTxEOF    <= part2EOF    after tpd;
               part2Ready  <= udpTxReady  after tpd;
               udpTxData   <= part2Data   after tpd;
               udpTxLength <= part2Length after tpd;
               
               if loc1Valid = '1' and udpDone = '1' then
                  muxSel     <= "00" after tpd;
               end if;
             when OTHERS =>
                part1Ready  <= '0' after tpd;
                part2Ready  <= '0' after tpd;
                udpTxValid  <= '0' after tpd;
                udpTxEOF    <= '0' after tpd;
                udpTxData   <= (others=>'0') after tpd;
                udpTxLength <= (others=>'0') after tpd;
                muxSel      <= (others=>'0') after tpd;
         end case;
      end if;
   end process;

end XMacArbiter;