-------------------------------------------------------------------------------
-- Title         : Ethernet Client, Loopback Block
-- Project       : General Purpose Core
-------------------------------------------------------------------------------
-- File          : EthClientTest.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 10/18/2010
-------------------------------------------------------------------------------
-- Description:
-- Loopback module for testing.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 10/18/2010: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.EthClientPackage.all;

entity EthClientTest is 
   port (

      -- Ethernet clock & reset
      sysClk          : in  std_logic;
      sysRst          : in  std_logic;

      -- Ethernet clock & reset
      emacClk         : in  std_logic;
      emacClkRst      : in  std_logic;
      cScopeCtrl      : inout std_logic_vector(35 downto 0);
      
      -- MAC Interface Signals, Receiver
      -- UDP Transmit interface
      ethTxEmpty      : out    std_logic;
      ethTxSOF        : out    std_logic;
      ethTxEOF        : out    std_logic;
      ethTxData       : out    std_logic_vector(15 downto 0);
      ethTxType       : out    std_logic_vector(1  downto 0);
      ethTxRd         : in     std_logic;                     -- TX FIFO Read
      
      -- UDP Receive interface
      ethRxValid      : in  std_logic;
      ethRxData       : in  std_logic_vector(7 downto 0);
      ethRxGood       : in  std_logic;
      ethRxError      : in  std_logic
   );

end EthClientTest;


-- Define architecture
architecture EthClientTest of EthClientTest is

   -- Local Signals
   signal dataCount      : std_logic_vector(31 downto 0);
   signal counter        : std_logic_vector(31 downto 0);
   signal txState        : std_logic_vector(1 downto 0);
   signal dataValid      : std_logic;
   signal rstValid       : std_logic;
   signal msbCount       : std_logic;
   signal locTxFifoDin   : std_logic_vector(15 downto 0);
   signal locTxFifoDout  : std_logic_vector(15 downto 0);
   signal locTxFifoRd    : std_logic;
   signal locTxFifoWr    : std_logic;
   signal locTxFifoEmpty : std_logic;
   signal locTxFifoFull  : std_logic;
   signal locTxSOFin     : std_logic;
   signal locTxSOFout    : std_logic;
   signal locTxEOFin     : std_logic;
   signal locTxEOFout    : std_logic;
   signal locTxValid     : std_logic;
   

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

   -- Chip Scope signals
   constant enChipScope  : integer := 1;
   signal   ethDebug     : std_logic_vector(63 downto 0);
   
begin

   -----------------------------
   -- Chipscope for debug
   -----------------------------

   -- Debug Signals
   ethDebug (57)           <= locTxValid;
   ethDebug (56)           <= locTxFifoFull;
   ethDebug (55)           <= dataValid;
   ethDebug (54)           <= locTxEOFout;
   ethDebug (53)           <= locTxEOFin;
   ethDebug (52)           <= locTxFifoEmpty;
   ethDebug (51)           <= locTxFifoWr;
   ethDebug (50)           <= locTxFifoRd;
   ethDebug (49 downto 48) <= txState;
   ethDebug (47 downto 32) <= counter(15 downto 0);
   ethDebug (31 downto 16) <= locTxFifoDout;
   ethDebug (15 downto 0)  <= locTxFifoDin;
   
   -- Chipscope logic analyzer
   chipscope : if (enChipScope = 1) generate
   U_EthClientTest_ila : v5_ila port map ( control => cScopeCtrl,
                                           clk     => emacClk,
                                           trig0   => ethDebug);
   end generate chipscope;

   ------------------ Rx Block ---------------------
   
   ------ Enable to convert 8-bit data into 16-bit words
   process (emacClk, emacClkRst ) begin
      if emacClkRst = '1' then
         dataCount <= (others=>'0') after tpd;
         dataValid <= '0'           after tpd;
         msbCount  <= '0'           after tpd;
      elsif rising_edge(emacClk) then

         if ethRxValid = '1' then
            if msbCount = '0' then
               -- Byte 0
               if ethRxData(7) = '1' then
                     dataCount(3  downto 0)  <= ethRxData(3 downto 0) after tpd;
               else
                  -- Byte 1 
                  if ethRxData(6) = '0' then
                     dataCount(9  downto 4)  <= ethRxData(5 downto 0) after tpd;
                 -- Byte 2
                  else 
                     dataCount(15 downto 10) <= ethRxData(5 downto 0) after tpd;
                     msbCount                <= '1'                   after tpd;
                  end if;
               end if;
            else
               -- Byte 0
               if ethRxData(7) = '1' then
                     dataCount(19 downto 16) <= ethRxData(3 downto 0) after tpd;
               else
                  -- Byte 1 
                  if ethRxData(6) = '0' then
                     dataCount(25 downto 20) <= ethRxData(5 downto 0) after tpd;
                 -- Byte 2
                  else 
                     dataCount(31 downto 26) <= ethRxData(5 downto 0) after tpd;
                     dataValid               <= '1'                   after tpd;
                     msbCount                <= '0'                   after tpd;
                  end if;
               end if;
            end if;
         elsif txState > 0 then
--             dataCount <= (others=>'0') after tpd;
            dataValid <= '0'           after tpd;
            msbCount  <= '0'           after tpd;
         end if;
      end if;
   end process;
   
   ------------------ Tx Block ---------------------
   
   -- Transmitter Data Fifo
   U_TxDataFifo : v5_fifo_18x8k port map (
      wr_clk            => emacClk,
      rd_clk            => emacClk,
      rst               => emacClkRst,
      din(17)           => locTxEOFin,
      din(16)           => locTxSOFin,
      din(15 downto 0)  => locTxFifoDin,
      wr_en             => locTxFifoWr,
      rd_en             => locTxFifoRd,
      dout(17)          => locTxEOFout,
      dout(16)          => locTxSOFout,
      dout(15 downto 0) => locTxFifoDout,
      full              => locTxFifoFull,
      empty             => locTxFifoEmpty,
      rd_data_count     => open
   );
   
   ethTxData   <= locTxFifoDout;
   ethTxType   <= "11";
   ethTxSOF    <= locTxSOFout;
   ethTxEOF    <= locTxEOFout;
   ethTxEmpty  <= locTxFifoEmpty;
   locTxFifoRd <= ethTxRd;
   locTxValid  <= not locTxFifoEmpty;
--    locTxEOFin  <= txState(2) and txState(0);
   process ( emacClk, emacClkRst ) begin
      if emacClkRst = '1' then
         locTxFifoDin <= (OTHERS=>'0') after tpd;
         txState      <= (OTHERS=>'0') after tpd;
         counter      <= x"00000001"   after tpd;
         rstValid     <= '0'           after tpd;
         locTxFifoWr  <= '0'           after tpd;
         locTxSOFin   <= '0'           after tpd;
         locTxEOFin   <= '0'           after tpd;
      elsif rising_edge(emacClk) then

         case txState is
            when "00" =>
               rstValid     <= '0'                    after tpd;
               locTxFifoWr  <= '0'                    after tpd;
               locTxFifoDin <= (OTHERS => '0')        after tpd;
               locTxEOFin   <= '0'                    after tpd;

               if dataValid = '1' and dataCount > 0 then
                  txState    <= "01"                  after tpd;
                  locTxSOFin <= '1'                   after tpd;
               else
                  txState    <= "00"                  after tpd;
                  locTxSOFin <= '0'                   after tpd;
               end if;
            when "01" =>
               if locTxFifoFull = '0' then
                  locTxFifoDin <= counter (31 downto 16) after tpd;
                  locTxFifoWr  <= '1'                    after tpd;
                  txState      <= "10"                   after tpd;
               
                  if dataCount = counter then
                     txState   <= "11"                   after tpd;
                  else
                     txState   <= "10"                   after tpd;
                  end if;
               end if;
            when "10" =>
               if locTxFifoFull = '0' then
                  locTxFifoDin <= counter (15 downto  0) after tpd;
                  locTxSOFin   <= '0'                    after tpd;
                  locTxFifoWr  <= '1'                    after tpd;
                  counter      <= counter + '1'          after tpd;
                  txState      <= "01"                   after tpd;
               end if;
            when "11" =>
               if locTxFifoFull = '0' then
                  locTxFifoDin <= counter (15 downto  0) after tpd;
                  locTxFifoWr  <= '1'                    after tpd;
                  locTxEOFin   <= '1'                    after tpd;
                  rstValid     <= '1'                    after tpd;
                  txState      <= "00"                   after tpd;
                  counter      <= x"00000001"            after tpd;
               end if;
            when others =>
               locTxFifoDin <= (OTHERS=>'0') after tpd;
               locTxSOFin   <= '0'           after tpd;
               locTxEOFin   <= '0'           after tpd;
               locTxFifoWr  <= '0'           after tpd;
               rstValid     <= '0'           after tpd;
               txState      <= "00"          after tpd;
               counter      <= x"00000001"   after tpd;
         end case;
      end if;
   end process;

end EthClientTest;

