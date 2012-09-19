
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

use work.Ppc440RceG2Pkg.all;

package EthMac1GPkg is

  ----------------------------------
  -- Components
  ----------------------------------

   component EthMac1G is 
      port (
         gtxClkRefP      : in  std_logic;
         gtxClkRefN      : in  std_logic;
         sysReset        : in  std_logic;
         apuClk          : in  std_logic;
         apuClkRst       : in  std_logic;
         apuReadFromPpc  : in  ApuReadFromPpcType;
         apuReadToPpc    : out ApuReadToPpcType;
         apuWriteFromPpc : in  ApuWriteFromPpcType;
         apuWriteToPpc   : out ApuWriteToPpcType;
         apuLoadFromPpc  : in  ApuLoadFromPpcType;
         apuLoadToPpc    : out ApuLoadToPpcType;
         apuStoreFromPpc : in  ApuStoreFromPpcType;
         apuStoreToPpc   : out ApuStoreToPpcType;
         gtxRxN          : in  std_logic;
         gtxRxP          : in  std_logic;
         gtxTxN          : out std_logic;
         gtxTxP          : out std_logic
      );
   end component;

   component EthMac1GCore is 
      port (
         gtxClk          : in  std_logic;
         gtxClkDiv       : in  std_logic;
         gtxClkOut       : out std_logic;
         gtxClkRef       : in  std_logic;
         gtxClkRst       : in  std_logic;
         emacRxData      : out std_logic_vector(7  downto 0);
         emacRxValid     : out std_logic;
         emacRxGoodFrame : out std_logic;
         emacRxBadFrame  : out std_logic;
         emacTxData      : in  std_logic_vector(7  downto 0);
         emacTxValid     : in  std_logic;
         emacTxAck       : out std_logic;
         emacTxFirst     : in  std_logic;
         gtxRxN          : in  std_logic;
         gtxRxP          : in  std_logic;
         gtxTxN          : out std_logic;
         gtxTxP          : out std_logic
      );
   end component;

   component EthMac1GCntrl is 
      port (
         gtxClk             : in  std_logic;
         gtxClkRst          : in  std_logic;
         sysClk             : in  std_logic;
         sysClkRst          : in  std_logic;
         emacRxData         : in  std_logic_vector(7  downto 0);
         emacRxValid        : in  std_logic;
         emacRxGoodFrame    : in  std_logic;
         emacRxBadFrame     : in  std_logic;
         emacTxData         : out std_logic_vector(7  downto 0);
         emacTxValid        : out std_logic;
         emacTxAck          : in  std_logic;
         emacTxFirst        : out std_logic;
         cmdFifoData        : in  std_logic_vector(31 downto 0);
         cmdFifoWr          : in  std_logic;
         cmdFifoFull        : out std_logic;
         cmdFifoAlmostFull  : out std_logic;
         resFifoData        : out std_logic_vector(31 downto 0);
         resFifoRd          : in  std_logic;
         resFifoEmpty       : out std_logic;
         resFifoAlmostEmpty : out std_logic;
         txFifoData         : in  std_logic_vector(63 downto 0);
         txFifoWr           : in  std_logic;
         txFifoFull         : out std_logic;
         txFifoAlmostFull   : out std_logic;
         rxFifoData         : out std_logic_vector(63 downto 0);
         rxFifoRd           : in  std_logic;
         rxFifoEmpty        : out std_logic;
         rxFifoAlmostEmpty  : out std_logic
      );
   end component;

end EthMac1GPkg;

