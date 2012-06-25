
LIBRARY ieee;
use work.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.EthMac1GPkg.all;
use work.Ppc440RceG2Pkg.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity EthMac1G is 
   port (

      -- GTX Reference Clock
      gtxClkRefP      : in  std_logic;
      gtxClkRefN      : in  std_logic;
      sysReset        : in  std_logic;

      -- APU Interface
      apuClk          : in  std_logic;
      apuClkRst       : in  std_logic;
      apuReadFromPpc  : in  ApuReadFromPpcType;
      apuReadToPpc    : out ApuReadToPpcType;
      apuWriteFromPpc : in  ApuWriteFromPpcType;
      apuWriteToPpc   : out ApuWriteToPpcType;
      apuLoadFromPpc  : in  ApuLoadFromPpcType;
      apuStoreFromPpc : in  ApuStoreFromPpcType;
      apuStoreToPpc   : out ApuStoreToPpcType;

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
   signal emacRxData         : std_logic_vector(7  downto 0);
   signal emacRxValid        : std_logic;
   signal emacRxGoodFrame    : std_logic;
   signal emacRxBadFrame     : std_logic;
   signal emacTxData         : std_logic_vector(7  downto 0);
   signal emacTxValid        : std_logic;
   signal emacTxAck          : std_logic;
   signal emacTxFirst        : std_logic;
   signal gtxClkRef          : std_logic;
   signal gtxClk             : std_logic;
   signal gtxClkOut          : std_logic;
   signal gtxClkDiv          : std_logic;
   signal intGtxClk          : std_logic;
   signal intGtxClkDiv       : std_logic;
   signal gtxLock            : std_logic;
   signal syncRstIn          : std_logic_vector(2 downto 0);
   signal rstCnt             : std_logic_vector(3 downto 0);
   signal gtxClkRst          : std_logic;
   signal cmdFifoData        : std_logic_vector(31 downto 0);
   signal cmdFifoWr          : std_logic;
   signal cmdFifoFull        : std_logic;
   signal cmdFifoAlmostFull  : std_logic;
   signal resFifoData        : std_logic_vector(31 downto 0);
   signal resFifoRd          : std_logic;
   signal resFifoEmpty       : std_logic;
   signal resFifoAlmostEmpty : std_logic;
   signal txFifoData         : std_logic_vector(63 downto 0);
   signal txFifoWr           : std_logic;
   signal txFifoFull         : std_logic;
   signal txFifoAlmostFull   : std_logic;
   signal rxFifoData         : std_logic_vector(63 downto 0);
   signal rxFifoRd           : std_logic;
   signal rxFifoEmpty        : std_logic;
   signal rxFifoAlmostEmpty  : std_logic;

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin     

   -- Input Buffer
   U_RefClk : IBUFDS  port map ( I => gtxClkRefP,    IB => gtxClkRefN,   O => gtxClkRef );

   -- DCM For IODELAY reference
   U_RefDcm: DCM_ADV
      generic map (
         DFS_FREQUENCY_MODE    => "LOW",
         DLL_FREQUENCY_MODE    => "HIGH",
         CLKIN_DIVIDE_BY_2     => FALSE,
         CLK_FEEDBACK          => "1X",
         CLKOUT_PHASE_SHIFT    => "NONE",
         STARTUP_WAIT          => false,
         PHASE_SHIFT           => 0,
         CLKFX_MULTIPLY        => 8,
         CLKFX_DIVIDE          => 5,
         CLKDV_DIVIDE          => 2.0,
         CLKIN_PERIOD          => 8.0,
         DCM_PERFORMANCE_MODE  => "MAX_SPEED",
         FACTORY_JF            => X"F0F0",
         DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS"
      )
      port map (
         CLKIN    => gtxClkOut,     CLKFB    => gtxClk,
         CLK0     => intGtxClk,     CLK90    => open,
         CLK180   => open,          CLK270   => open, 
         CLK2X    => open,          CLK2X180 => open,
         CLKDV    => intGtxClkDiv,  CLKFX    => open,
         CLKFX180 => open,          LOCKED   => gtxLock,
         PSDONE   => open,          PSCLK    => '0',
         PSINCDEC => '0',           PSEN     => '0',
         DCLK     => '0',           DADDR    => (others=>'0'),
         DI       => (others=>'0'), DO       => open,
         DRDY     => open,          DWE      => '0',
         DEN      => '0',           RST      => sysReset
      );

   U_GtpClkBuff    : BUFG port map ( I => intGtxClk,    O => gtxClk    );
   U_GtpClkDivBuff : BUFG port map ( I => intGtxClkDiv, O => gtxClkDiv );

   process ( gtxClk, sysReset ) begin
      if sysReset = '1' then
         syncRstIn <= (others=>'0') after tpd;
         rstCnt    <= (others=>'0') after tpd;
         gtxClkRst <= '1'           after tpd;
      elsif rising_edge(gtxClk) then

         syncRstIn(0) <= gtxLock      after tpd;
         syncRstIn(1) <= syncRstIn(0) after tpd;
         syncRstIn(2) <= syncRstIn(1) after tpd;

         if syncRstIn(2) = '0' then
            rstCnt    <= (others=>'0') after tpd;
            gtxClkRst <= '1' after tpd;

         elsif rstCnt = "1111" then
            gtxClkRst <= '0' after tpd;

         else
            gtxClkRst <= '1'        after tpd;
            rstCnt    <= rstCnt + 1 after tpd;
         end if;
      end if;
   end process;

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

   U_Ethmac1GCntrl : EthMac1GCntrl
      port map (
         gtxClk             => gtxClk,
         gtxClkRst          => gtxClkRst,
         sysClk             => apuClk,
         sysClkRst          => apuClkRst,
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

   -- Command FIFO
   cmdFifoData          <= apuWriteFromPpc.regB;
   cmdFifoWr            <= apuWriteFromPpc.enable;

   apuWriteToPpc.status <= "00" & cmdFifoAlmostFull & cmdFifoFull;

   -- Result FIFO
   resFifoRd            <= apuReadFromPpc.enable;

   apuReadToPpc.result  <= resFifoData;
   apuReadToPpc.status  <= "00" & resFifoAlmostEmpty & resFifoEmpty;

   -- Transmit FIFO
   txFifoData           <= apuLoadFromPpc.data(0 to 63);
   txFifoWr             <= apuLoadFromPpc.enable;

   -- Receive FIFO
   rxFifoRd             <= apuStoreFromPpc.enable;
  
   apuStoreToPpc.data   <= rxFifoData & x"0000000000000000";

end EthMac1G;

