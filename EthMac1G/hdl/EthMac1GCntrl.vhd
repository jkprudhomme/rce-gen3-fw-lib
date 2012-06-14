
LIBRARY ieee;
use work.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity EthMac1GCntrl is 
   port (

      -- Gtx clock & reset
      gtxClk             : in  std_logic;
      gtxClkRst          : in  std_logic;

      -- System clock & reset
      sysClk             : in  std_logic;
      sysClkRst          : in  std_logic;

      -- Frame Receive 
      emacRxData         : in  std_logic_vector(7  downto 0);
      emacRxValid        : in  std_logic;
      emacRxGoodFrame    : in  std_logic;
      emacRxBadFrame     : in  std_logic;

      -- Frame Transmit
      emacTxData         : out std_logic_vector(7  downto 0);
      emacTxValid        : out std_logic;
      emacTxAck          : in  std_logic;
      emacTxFirst        : out std_logic

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
      rxFifoAlmostEmpty  : out std_logic
   );

end EthMac1GCntrl;

-- Define architecture
architecture EthMac1GCntrl of EthMac1GCntrl is

  COMPONENT EthMac1G_afifo_64x2048_fwft
    PORT (
      rst : IN STD_LOGIC;
      wr_clk : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      full : OUT STD_LOGIC;
      almost_full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      almost_empty : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT EthMac1G_afifo_64x512_fwft
    PORT (
      rst : IN STD_LOGIC;
      wr_clk : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      full : OUT STD_LOGIC;
      almost_full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      almost_empty : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT EthMac1G_afifo_32x16384_fwft
    PORT (
      rst : IN STD_LOGIC;
      wr_clk : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      full : OUT STD_LOGIC;
      almost_full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      almost_empty : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT EthMac1G_afifo_32x1024_fwft
    PORT (
      rst : IN STD_LOGIC;
      wr_clk : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      full : OUT STD_LOGIC;
      almost_full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      almost_empty : OUT STD_LOGIC
    );
  END COMPONENT;

   -- Local signals
   signal txFifoRd     : std_logic;
   signal txFifoEmpty  : std_logic;
   signal txFifoDout   : std_logic_vector(63 downto 0);
   signal cmdFifoRd    : std_logic;
   signal cmdFifoEmpty : std_logic;
   signal cmdFifoDout  : std_logic_vector(63 downto 0);
   signal rxFifoWr     : std_logic;
   signal rxFifoFull   : std_logic;
   signal rxFifoAFull  : std_logic;
   signal rxFifoDin    : std_logic_vector(31 downto 0);
   signal resFifoWr    : std_logic;
   signal resFifoFull  : std_logic;
   signal resFifoAFull : std_logic;
   signal resFifoDin   : std_logic_vector(31 downto 0);
   
   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin     

   -- Transmit FIFO
   U_TxFifo : EthMac1G_afifo_64x2048_fwft
      PORT MAP (
         rst          => sysClkRst,
         wr_clk       => sysClk,
         rd_clk       => gtxClk,
         din          => txFifoData,
         wr_en        => txFifoWr,
         rd_en        => txFifoRd,
         dout         => txFifoDout,
         full         => txFifoFull,
         almost_full  => txFifoAlmostFull,
         empty        => txFifoEmpty,
         almost_empty => open
      );

   -- Cmd FIFO
   U_CmdFifo : EthMac1G_afifo_64x512_fwft
      PORT MAP (
         rst          => sysClkRst,
         wr_clk       => sysClk,
         rd_clk       => gtxClk,
         din          => cmdFifoData,
         wr_en        => cmdFifoWr,
         rd_en        => cmdFifoRd,
         dout         => cmdFifoDout,
         full         => cmdFifoFull,
         almost_full  => cmdFifoAlmostFull,
         empty        => cmdFifoEmpty,
         almost_empty => open,
      );

   -- Rx FIFO
   U_RxFifo : EthMac1G_afifo_32x16384_fwft
      PORT MAP (
         rst          => sysClkRst,
         wr_clk       => gtxClk,
         rd_clk       => sysClk,
         din          => rxFifoDin,
         wr_en        => rxFifoWr,
         rd_en        => rxFifoRd,
         dout         => rxFifoData,
         full         => rxFifoFull,
         almost_full  => rxFifoAFull,
         empty        => rxFifoEmpty,
         almost_empty => rxFifoAlmostEmpty
      );

   -- Res FIFO
   U_ResFifo : EthMac1G_afifo_32x1024_fwft
      PORT MAP (
         rst          => sysClkRst,
         wr_clk       => gtxClk,
         rd_clk       => sysClk,
         din          => resFifoDin,
         wr_en        => resFifoWr,
         rd_en        => resFifoRd,
         dout         => resFifoData,
         full         => resFifoFull,
         almost_full  => resFifoAFull,
         empty        => resFifoEmpty,
         almost_empty => resFifoAlmostEmpty
      );
























end EthMac1GCntrl;

