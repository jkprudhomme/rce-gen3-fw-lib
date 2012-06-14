
LIBRARY ieee;
use work.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.EthMac2GPkg.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity EthMac1G is 
   port (

      -- System clock, reset & control
      gtxClk          : in  std_logic;
      gtxClkDiv       : in  std_logic;
      gtxClkOut       : out std_logic;
      gtxClkRef       : in  std_logic;
      gtxClkRst       : in  std_logic;

      -- System clock & reset
      sysClk             : in  std_logic;
      sysClkRst          : in  std_logic;

      -- Command FIFO
      cmdFifoData        : in  std_logic_vector(63 downto 0);
      cmdFifoWr          : in  std_logic;
      cmdFifoFull        : out std_logic;
      cmdFifoAlmostFull  : out std_logic;

      -- Result FIFO
      resFifoData        : out std_logic_vector(31 downto 0);
      resFifoRd          : in  std_logic;
      resFifoEmpty       : out std_logic;
      resFifoAlmostEmpty : out std_logic;

      -- Transmit data FIFO
      txFifoData         : in  std_logic_vector(63 downto 0);
      txFifoWr           : in  std_logic;
      txFifoFull         : out std_logic;
      txFifoAlmostFull   : out std_logic;

      -- Receive data FIFO
      rxFifoData         : out std_logic_vector(31 downto 0);
      rxFifoRd           : in  std_logic;
      rxFifoEmpty        : out std_logic;
      rxFifoAlmostEmpty  : out std_logic;

      -- GTX Signals
      gtxRxN          : in  std_logic;
      gtxRxP          : in  std_logic;
      gtxTxN          : out std_logic;
      gtxTxP          : out std_logic
   );

end EthMac1G;

-- Define architecture
architecture EthMac1G of EthMac1G is

   -- Local signals
   signal emacRxData      : std_logic_vector(7  downto 0);
   signal emacRxValid     : std_logic;
   signal emacRxGoodFrame : std_logic;
   signal emacRxBadFrame  : std_logic;
   signal emacTxData      : std_logic_vector(7  downto 0);
   signal emacTxValid     : std_logic;
   signal emacTxAck       : std_logic;
   signal emacTxFirst     : std_logic;
   
   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin     

   U_EthMac1GCore : EthMac1GCore 
      port map (
         gtxClk          => gtxClk,
         gtxClkDiv       => gtxClkDiv,
         gtxClkOut       => gtxClkOut,
         gtxClkRef       => gtxClkRef,
         gtxClkRst       => gtxClkRst,
         emacRxData      => emacRxData,
         emacRxValid     => emacRxValid,
         emacRxGoodFrame => emacRxGoodFrame,
         emacRxBadFrame  => emacRxBadFrame,
         emacTxData      => emacTxData,
         emacTxValid     => emacTxValid,
         emacTxAck       => emacTxAck,
         emacTxFirst     => emacTxFirst,
         gtxRxN          => gtxRxN,
         gtxRxP          => gtxRxP,
         gtxTxN          => gtxTxN,
         gtxTxP          => gtxTxP
      );

   U_Ethmac1GCore : EthMac1GCore
      port map (
         gtxClk             => gtxClk,
         gtxClkRst          => gtxClkRst,
         sysClk             => sysClk,
         sysClkRst          => sysClkRst,
         emacRxData         => emacRxData,
         emacRxValid        => emacRxValid,
         emacRxGoodFrame    => emacRxGoodFrame,
         emacRxBadFrame     => emacRxBadFrame,
         emacTxData         => emacTxData,
         emacTxValid        => emacTxValid,
         emacTxAck          => emacTxAck,
         emacTxFirst        => emacTxFirst,
         cmdFifoData        => cmdFifoData,
         cmdFifoWr          => cmdFifoWr,
         cmdFifoFull        => cmdFifoFull,
         cmdFifoAlmostFull  => cmdFifoAlmostFull,
         resFifoData        => resFifoData,
         resFifoRd          => resFifoRd,
         resFifoEmpty       => resFifoEmpty,
         resFifoAlmostEmpty => resFifoAlmostEmpty,
         txFifoData         => txFifoData,
         txFifoWr           => txFifoWr,
         txFifoFull         => txFifoFull,
         txFifoAlmostFull   => txFifoAlmostFull,
         rxFifoData         => rxFifoData,
         rxFifoRd           => rxFifoRd,
         rxFifoEmpty        => rxFifoEmpty,
         rxFifoAlmostEmpty  => rxFifoAlmostEmpty
      );

end EthMac1G;

