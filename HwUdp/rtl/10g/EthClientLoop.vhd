-------------------------------------------------------------------------------
-- Title         : Ethernet Client, Loopback Block
-- Project       : General Purpose Core
-------------------------------------------------------------------------------
-- File          : EthClientLoop.vhd
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

entity EthClientLoop is 
   port (

      -- Ethernet clock & reset
      emacClk         : in  std_logic;
      emacClkRst      : in  std_logic;
      cScopeCtrl      : inout std_logic_vector(35 downto 0);
      
      -- MAC Interface Signals, Receiver
      -- UDP Transmit interface
      udpTxValid      : out std_logic;
      udpTxReady      : in  std_logic;
      udpTxData       : out std_logic_vector(7  downto 0);
      udpTxLength     : out std_logic_vector(15 downto 0);

      -- UDP Receive interface
      udpRxValid      : in  std_logic;
      udpRxData       : in  std_logic_vector(7 downto 0);
      udpRxGood       : in  std_logic;
      udpRxError      : in  std_logic
   );

end EthClientLoop;


-- Define architecture
architecture EthClientLoop of EthClientLoop is

   -- Local Signals
   signal rxCount    : std_logic_vector(12 downto 0);
   signal dFifoDin   : std_logic_vector(17 downto 0);
   signal dFifoWr    : std_logic;
   signal dFifoDout  : std_logic_vector(17 downto 0);
   signal dFifoRd    : std_logic;
   signal dFifoEn    : std_logic;
   signal dFifoValid : std_logic;
   signal dFifoEmpty : std_logic;
   signal cFifoDin   : std_logic_vector(12 downto 0);
   signal cFifoWr    : std_logic;
   signal cFifoDout  : std_logic_vector(12 downto 0);
   signal cFifoRd    : std_logic;
   signal cFifoEn    : std_logic;
   signal cFifoValid : std_logic;
   signal cFifoEmpty : std_logic;
   signal regRxValid : std_logic;
   signal regRxData  : std_logic_vector(7 downto 0);

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
   ethDebug (63 downto 51)<= (OTHERS => '0');
   ethDebug (50)          <= dFifoRd;
   ethDebug (49)          <= cFifoRd;
   ethDebug (48)          <= dFifoWr;
   ethDebug (47)          <= cFifoWr;
   ethDebug (46 downto 34)<= rxCount;
   ethDebug (33)          <= udpTxReady;
   ethDebug (32)          <= cFifoValid;
   ethDebug (31)          <= udpRxError;
   ethDebug (30)          <= udpRxGood;
   ethDebug (29)          <= udpRxValid;
   ethDebug (28 downto 16)<= cFifoDout;
   ethDebug (15 downto 8) <= dFifoDout(7 downto 0);
   ethDebug (7  downto 0) <= udpRxData;
   
   -- Chipscope logic analyzer
   chipscope : if (enChipScope = 1) generate
   U_EthClientLoop_ila : v5_ila port map ( control => cScopeCtrl,
                                           clk     => emacClk,
                                           trig0   => ethDebug);
   end generate chipscope;

   -- Data input
   process ( emacClk, emacClkRst ) begin
      if emacClkRst = '1' then
         dFifoDin   <= (others=>'0') after tpd;
         cFifoDin   <= (others=>'0') after tpd;
         dFifoWr    <= '0'           after tpd;
         cFifoWr    <= '0'           after tpd;
         rxCount    <= (others=>'0') after tpd;
         regRxValid <= '0'           after tpd;
         regRxData  <= (others=>'0') after tpd;
      elsif rising_edge(emacClk) then

         -- registered copy of data
         regRxValid <= udpRxValid after tpd;
         regRxData  <= udpRxData  after tpd;

         -- Counter
         if regRxValid = '0' then
            rxCount <= (others=>'0') after tpd;
         else
            rxCount <= rxCount + 1 after tpd;
         end if;
 
         -- Data Input
         dFifoDin(7 downto 0) <= regRxData      after tpd;
         dFifoDin(8)          <= not udpRxValid after tpd;
         dFifoWr              <= regRxValid     after tpd;
         
         -- Count input
         cFifoDin              <= rxCount                    after tpd;
         cFifoWr               <= dFifoWr and not regRxValid after tpd;

      end if;
   end process;

   -- Data FIFO
   U_DataFifo : v5_fifo_18x8k port map (
      wr_clk        => emacClk,
      rd_clk        => emacClk,
      rst           => emacClkRst,
      din           => dFifoDin,
      wr_en         => dFifoWr,
      rd_en         => dFifoRd,
      dout          => dFifoDout,
      full          => open,
      empty         => dFifoEmpty,
      wr_data_count => open,
      rd_data_count => open
   );

   -- Count FIFO
   U_CountFifo : v5_fifo_13x1k port map (
      wr_clk        => emacClk,
      rd_clk        => emacClk,
      rst           => emacClkRst,
      din           => cFifoDin,
      wr_en         => cFifoWr,
      rd_en         => cFifoRd,
      dout          => cFifoDout,
      full          => open,
      empty         => cFifoEmpty
   );

   -- FIFO preread
   process ( emacClk, emacClkRst ) begin
      if emacClkRst = '1' then
         dFifoValid <= '0' after tpd;
         cFifoValid <= '0' after tpd;
      elsif rising_edge(emacClk) then

         if dFifoRd = '1' then
            dFifoValid <= '1' after tpd;
         elsif dFifoEn = '1' then
            dFifoValid <= '0' after tpd;
         end if;

         if cFifoRd = '1' then
            cFifoValid <= '1' after tpd;
         elsif cFifoEn = '1' then
            cFifoValid <= '0' after tpd;
         end if;
      end if;
   end process;

   -- Data FIFO reads
   dFifoRd <= (not dFifoEmpty) and (dFifoEn or (not dFifoValid));
   cFifoRd <= (not cFifoEmpty) and (cFifoEn or (not cFifoValid));

   -- Shift enable
   dFifoEn <= udpTxReady;
   cFifoEn <= udpTxReady and dFifoDout(8); -- last flag

   -- Output data
   udpTxValid               <= cFifoValid;
   udpTxLength(12 downto 0) <= cFifoDout;
   udpTxData                <= dFifoDout(7 downto 0);

end EthClientLoop;

