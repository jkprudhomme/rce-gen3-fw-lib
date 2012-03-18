-------------------------------------------------------------------------------
-- Title         : Pretty Good Protocol, V2, GTP RX Reset Control
-- Project       : General Purpose Core
-------------------------------------------------------------------------------
-- File          : EthClientGtxRxRst.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 08/18/2009
-------------------------------------------------------------------------------
-- Description:
-- This module contains the logic to control the reset of the RX GTP.
-------------------------------------------------------------------------------
-- Copyright (c) 2009 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 08/18/2009: created.
-- 01/13/2010: Added received init line to help linking.
-- 04/20/2010: Elec idle will no longer cause general reset.
-- 10/27/2010: Removed gtxRxInit as it was not needed.
-------------------------------------------------------------------------------

LIBRARY ieee;
use work.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.EthClientPackage.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;


entity EthClientGtxRxRst is 
   port (

      -- Clock and reset
      gtxRxClk          : in  std_logic;
      gtxRxRst          : in  std_logic;

      -- RX Side is ready
      gtxRxReady        : out std_logic;
      
      -- GTP Status
      gtxLockDetect     : in  std_logic;
      gtxRxBuffStatus   : in  std_logic_vector(1  downto 0);
      gtxRstDone        : in  std_logic;

      -- Reset Control
      gtxRxReset        : out std_logic;
      gtxRxCdrReset     : out std_logic
   );

end EthClientGtxRxRst;


-- Define architecture
architecture EthClientGtxRxRst of EthClientGtxRxRst is

   -- Local Signals
   signal intRxReset        : std_logic;
   signal intRxCdrReset     : std_logic;
   signal rxStateCnt        : std_logic_vector(1 downto 0);
   signal rxStateCntRst     : std_logic;
   signal rxClockReady      : std_logic;

   -- RX Reset State Machine
   constant RX_SYSTEM_RESET : std_logic_vector(2 downto 0) := "000";
   constant RX_WAIT_LOCK    : std_logic_vector(2 downto 0) := "001";
   constant RX_RESET        : std_logic_vector(2 downto 0) := "010";
   constant RX_WAIT_DONE    : std_logic_vector(2 downto 0) := "011";
   constant RX_READY        : std_logic_vector(2 downto 0) := "100";
   signal   curRxState      : std_logic_vector(2 downto 0);
   signal   nxtRxState      : std_logic_vector(2 downto 0);

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- RX State Machine Synchronous Logic
   process ( gtxRxClk, gtxRxRst ) begin
      if gtxRxRst = '1' then
         curRxState       <= RX_SYSTEM_RESET after tpd;
         rxStateCnt       <= (others=>'0')   after tpd;
         gtxRxReady       <= '0'             after tpd;
         gtxRxReset       <= '1'             after tpd;
         gtxRxCdrReset    <= '1'             after tpd;
      elsif rising_edge(gtxRxClk) then

         -- Drive PIB Lock 
         gtxRxReady <= rxClockReady after tpd;

         -- Pass on reset signals
         gtxRxReset       <= intRxReset       after tpd;
         gtxRxCdrReset    <= intRxCdrReset    after tpd;

         -- Rx State Counter
         if rxStateCntRst = '1' then
            rxStateCnt <= (others=>'0') after tpd;
         else
            rxStateCnt <= rxStateCnt + 1 after tpd;
         end if;

         -- Assign Next State
         curRxState    <= nxtRxState after tpd;
      end if;
   end process;


   -- Async RX State Logic
   process ( curRxState, rxStateCnt, gtxLockDetect, gtxRxBuffStatus, gtxRstDone ) begin
      case curRxState is 

         -- System Reset State
         when RX_SYSTEM_RESET =>
            rxStateCntRst    <= '1';
            intRxReset       <= '1';
            intRxCdrReset    <= '1';
            rxClockReady     <= '0';
            nxtRxState       <= RX_WAIT_LOCK;

         -- Wait for PLL lock
         when RX_WAIT_LOCK =>
            rxStateCntRst    <= '1';
            intRxReset       <= '1';
            intRxCdrReset    <= '0';
            rxClockReady     <= '0';

            -- Wait for lock
            if gtxLockDetect = '1' then
               nxtRxState    <= RX_RESET;
            else
               nxtRxState    <= curRxState;
            end if;

         -- RX Reset State
         when RX_RESET =>
            intRxReset       <= '1';
            intRxCdrReset    <= '0';
            rxClockReady     <= '0';
            rxStateCntRst    <= '0';

            -- Wait for three clocks
            if rxStateCnt = 3 then
               nxtRxState    <= RX_WAIT_DONE;
            else
               nxtRxState    <= curRxState;
            end if;

         -- RX Wait Reset Done
         when RX_WAIT_DONE =>
            intRxReset       <= '0';
            intRxCdrReset    <= '0';
            rxClockReady     <= '0';
            rxStateCntRst    <= '1';

            -- Wait for reset done
            if gtxRstDone = '1' then
               nxtRxState    <= RX_READY;
            else
               nxtRxState    <= curRxState;
            end if;

         -- RX Ready
         when RX_READY =>
            intRxReset       <= '0';
            intRxCdrReset    <= '0';
            rxClockReady     <= '1';
            rxStateCntRst    <= '1';

            -- Look for unlock error
            if gtxLockDetect = '0' then
               nxtRxState <= RX_WAIT_LOCK;

            -- Look For Buffer Error
            elsif gtxRxBuffStatus(1) = '1' then
               nxtRxState <= RX_RESET;

            else
               nxtRxState <= curRxState;
            end if;

         -- Default
         when others =>
            intRxReset       <= '0';
            intRxCdrReset    <= '0';
            rxClockReady     <= '0';
            rxStateCntRst    <= '1';
            nxtRxState       <= RX_SYSTEM_RESET;
      end case;
   end process;

end EthClientGtxRxRst;

