
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
      emacTxFirst        : out std_logic;

      -- Command FIFO
      cmdFifoData        : in  std_logic_vector(31 downto 0);
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
      rxFifoData         : out std_logic_vector(63 downto 0);
      rxFifoRd           : in  std_logic;
      rxFifoEmpty        : out std_logic;
      rxFifoAlmostEmpty  : out std_logic
   );

end EthMac1GCntrl;

-- Define architecture
architecture EthMac1GCntrl of EthMac1GCntrl is

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

  COMPONENT EthMac1G_afifo_64x8192_fwft
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

   -- Local signals
   signal txFifoRd       : std_logic;
   signal txFifoDout     : std_logic_vector(63 downto 0);
   signal cmdFifoRd      : std_logic;
   signal cmdFifoEmpty   : std_logic;
   signal cmdFifoDout    : std_logic_vector(31 downto 0);
   signal rxFifoWr       : std_logic;
   signal rxFifoDin      : std_logic_vector(63 downto 0);
   signal resFifoWr      : std_logic;
   signal resFifoDin     : std_logic_vector(31 downto 0);
   signal txLength       : std_logic_vector(15 downto 0);
   signal txCount        : std_logic_vector(15 downto 0);
   signal txCountEn      : std_logic;
   signal txCountRst     : std_logic;
   signal txSequence     : std_logic_vector(11 downto 0);
   signal txOpCode       : std_logic_vector(3  downto 0);
   signal txRespReq      : std_logic;
   signal txRespAck      : std_logic;
   signal rxCount        : std_logic_vector(15 downto 0);
   signal rxCountRst     : std_logic;
   signal emacRxValidReg : std_logic;
   signal rxFrameCnt     : std_logic_vector(11 downto 0);
  
   -- State machines
   constant ST_TX_IDLE   : std_logic_vector(2 downto 0) := "000";
   constant ST_TX_RD     : std_logic_vector(2 downto 0) := "001";
   constant ST_TX_CMD    : std_logic_vector(2 downto 0) := "010";
   constant ST_TX_REQ    : std_logic_vector(2 downto 0) := "011";
   constant ST_TX_DATA   : std_logic_vector(2 downto 0) := "100";
   constant ST_TX_RESP   : std_logic_vector(2 downto 0) := "101";
   signal   curTxState   : std_logic_vector(2 downto 0);
   signal   nxtTxState   : std_logic_vector(2 downto 0);
 
   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin     

   -----------------------------------------
   ---- Transmit Control
   -----------------------------------------
   -- 64-bit command
   --   15:0  = Transmit length 
   --   27:16 = Sequence Number
   --   31:28 = OpCode 5 = Transmit

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
         empty        => open,
         almost_empty => open
      );

   -- Cmd FIFO
   U_CmdFifo : EthMac1G_afifo_32x1024_fwft
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
         almost_empty => open
      );

   -- Sync state logic
   process (gtxClk, gtxClkRst ) begin
      if gtxClkRst = '1' then
         txLength     <= (others=>'0') after tpd;
         txCount      <= (others=>'0') after tpd;
         txSequence   <= (others=>'0') after tpd;
         txOpCode     <= (others=>'0') after tpd;
         curTxState   <= ST_TX_IDLE    after tpd;
      elsif rising_edge(gtxClk) then

         -- Transmit counter
         if txCountRst = '1' then
            txCount <= (others=>'0') after tpd;
         elsif txCountEn = '1' then
            txCount <= txCount + 1 after tpd;
         end if;

         -- Store command
         if cmdFifoRd = '1' then
            txLength     <= cmdFifoDout(15 downto  0) after tpd;
            txSequence   <= cmdFifoDout(27 downto 16) after tpd;
            txOpCode     <= cmdFifoDout(31 downto 28) after tpd;
         end if;

         -- State
         curTxState <= nxtTxState after tpd;

      end if;
   end process;

   -- Data mux
   emacTxData <= txFifoData(63 downto 56) when txCount(2 downto 0) = "000" else
                 txFifoData(55 downto 48) when txCount(2 downto 0) = "001" else
                 txFifoData(47 downto 40) when txCount(2 downto 0) = "010" else
                 txFifoData(39 downto 32) when txCount(2 downto 0) = "011" else
                 txFifoData(31 downto 24) when txCount(2 downto 0) = "100" else
                 txFifoData(23 downto 16) when txCount(2 downto 0) = "101" else
                 txFifoData(15 downto  8) when txCount(2 downto 0) = "110" else
                 txFifoData(7  downto  0);

   -- ASync state logic
   process ( curTxState, emacTxAck, cmdFifoEmpty, txOpCode, txCount, txRespAck, txLength ) begin
      case ( curTxState ) is
     
         -- Idle 
         when ST_TX_IDLE =>
            txCountRst  <= '1';
            txCountEn   <= '0';
            emacTxValid <= '0';
            emacTxFirst <= '0';
            cmdFifoRd   <= '0';
            txFifoRd    <= '0';
            txRespReq   <= '0';

            -- Fifo has data
            if cmdFifoEmpty = '0' then
               nxtTxState <= ST_TX_RD;
            else
               nxtTxState <= curTxState;
            end if;

         -- Read Command
         when ST_TX_RD =>
            txCountRst  <= '1';
            txCountEn   <= '0';
            emacTxValid <= '0';
            emacTxFirst <= '0';
            cmdFifoRd   <= '1';
            txFifoRd    <= '0';
            txRespReq   <= '0';
            nxtTxState  <= ST_TX_CMD;

         -- Process command
         when ST_TX_CMD =>
            txCountRst  <= '1';
            txCountEn   <= '0';
            emacTxValid <= '0';
            emacTxFirst <= '0';
            cmdFifoRd   <= '0';
            txFifoRd    <= '0';
            txRespReq   <= '0';

            if txOpCode = 5 then
               nxtTxState <= ST_TX_REQ;
            else
               nxtTxState <= ST_TX_RESP;
            end if;

         -- Send first byte
         when ST_TX_REQ =>
            txCountRst  <= '0';
            emacTxValid <= '1';
            emacTxFirst <= '1';
            cmdFifoRd   <= '0';
            txFifoRd    <= '0';
            txRespReq   <= '0';

            if emacTxAck = '1' then
               nxtTxState <= ST_TX_DATA;
               txCountEn  <= '1';
            else
               nxtTxState <= curTxState;
               txCountEn  <= '0';
            end if;

         -- Send data
         when ST_TX_DATA =>
            txCountRst  <= '0';
            txCountEn   <= '1';
            emacTxFirst <= '0';
            cmdFifoRd   <= '0';
            txRespReq   <= '0';

            -- We just sent the last byte
            if txCount = txLength then
               emacTxValid <= '0';
               nxtTxState  <= ST_TX_RESP;

               -- Don't read if we just read from FIFO
               if txCount(2 downto 0) = "000" then
                  txFifoRd    <= '0';
               else
                  txFifoRd    <= '1';
               end if;

            -- All bytes of fifo have been sent
            elsif txCount(2 downto 0) = "111" then
               emacTxValid <= '1';
               txFifoRd    <= '1';
               nxtTxState  <= curTxState;
           else
               emacTxValid <= '1';
               txFifoRd    <= '0';
               nxtTxState  <= curTxState;
           end if;

         -- Send response
         when ST_TX_RESP =>
            txCountRst  <= '0';
            txCountEn   <= '0';
            emacTxValid <= '0';
            emacTxFirst <= '0';
            cmdFifoRd   <= '0';
            txFifoRd    <= '0';
            txRespReq   <= '1';

            if txRespAck = '1' then
               nxtTxState <= ST_TX_IDLE;
            else
               nxtTxState <= curTxState;
            end if;

         when others =>
            txCountRst  <= '0';
            txCountEn   <= '0';
            emacTxValid <= '0';
            emacTxFirst <= '0';
            cmdFifoRd   <= '0';
            txFifoRd    <= '0';
            txRespReq   <= '0';
            nxtTxState  <= ST_TX_IDLE;
      end case;
   end process;


   -----------------------------------------
   ---- Receive Control
   -----------------------------------------
   -- 32-bit result
   --   15:0  = Length 
   --   27:16 = Sequence Number
   --   31:28 = OpCode 7 = Receive Ok, 6 = Receive Bad, 5 = Tx Ack

   -- Rx FIFO
   U_RxFifo : EthMac1G_afifo_64x8192_fwft
      PORT MAP (
         rst          => sysClkRst,
         wr_clk       => gtxClk,
         rd_clk       => sysClk,
         din          => rxFifoDin,
         wr_en        => rxFifoWr,
         rd_en        => rxFifoRd,
         dout         => rxFifoData,
         full         => open,
         almost_full  => open,
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
         full         => open,
         almost_full  => open,
         empty        => resFifoEmpty,
         almost_empty => resFifoAlmostEmpty
      );


   -- Rx FIFO write control
   process (gtxClk, gtxClkRst ) begin
      if gtxClkRst = '1' then
         rxCount        <= (others=>'0') after tpd;
         rxFifoWr       <= '0'           after tpd;
         rxFifoDin      <= (others=>'0') after tpd;
         emacRxValidReg <= '0'           after tpd;
      elsif rising_edge(gtxClk) then

         -- Delayed copy of valid
         emacRxValidReg <= emacRxValid   after tpd;

         -- rxCounter
         if rxCountRst = '1' then
            rxCount <= (others=>'0') after tpd;
         elsif emacRxValid = '1' then
            rxCount <= rxCount + 1 after tpd;
         end if;

         -- Mux data
         case rxCount(2 downto 0) is
            when "000"   => rxFifoDin(63 downto 56) <= emacRxData    after tpd;
            when "001"   => rxFifoDin(55 downto 48) <= emacRxData    after tpd;
            when "010"   => rxFifoDin(47 downto 40) <= emacRxData    after tpd;
            when "011"   => rxFifoDin(39 downto 32) <= emacRxData    after tpd;
            when "100"   => rxFifoDin(31 downto 24) <= emacRxData    after tpd;
            when "101"   => rxFifoDin(23 downto 16) <= emacRxData    after tpd;
            when "110"   => rxFifoDin(15 downto  8) <= emacRxData    after tpd;
            when "111"   => rxFifoDin(7  downto  0) <= emacRxData    after tpd;
            when others  => rxFifoDin               <= (others=>'0') after tpd;
         end case;

         -- Control writes
         if emacRxValid = '1' and rxCount(2 downto 0) = "111" then
            rxFifoWr <= '1';
         elsif emacRxValid = '0' and emacRxValidReg = '1' and rxCount(2 downto 0) /= "000" then
            rxFifoWr <= '1';
         else
            rxFifoWr <= '0';
         end if;

      end if;
   end process;

   -- Res FIFO write control
   process (gtxClk, gtxClkRst ) begin
      if gtxClkRst = '1' then
         resFifoWr      <= '0'           after tpd;
         resFifoDin     <= (others=>'0') after tpd;
         rxCountRst     <= '0'           after tpd;
         rxFrameCnt     <= (others=>'0') after tpd;
         txRespAck      <= '0'           after tpd;
      elsif rising_edge(gtxClk) then

         -- Counter
         if emacRxGoodFrame = '1' or emacRxBadFrame = '1' then
            rxFrameCnt <= rxFrameCnt + 1 after tpd;
            rxCountRst <= '1'            after tpd;
         else
            rxCountRst <= '0'            after tpd;
         end if;

         -- Good frame received
         if emacRxGoodFrame = '1' then
            resFifoDin(31 downto 28) <= "0111"     after tpd;
            resFifoDin(27 downto 16) <= rxFrameCnt after tpd;
            resFifoDin(15 downto  0) <= rxCount    after tpd;
            resFifoWr                <= '1'        after tpd;
            txRespAck                <= '0'        after tpd;

         -- Bad frame received
         elsif emacRxBadFrame = '1' then
            resFifoDin(31 downto 28) <= "0110"     after tpd;
            resFifoDin(27 downto 16) <= rxFrameCnt after tpd;
            resFifoDin(15 downto  0) <= rxCount    after tpd;
            resFifoWr                <= '1'        after tpd;
            txRespAck                <= '0'        after tpd;

         -- Tx resp
         elsif txRespReq = '1' and txRespAck = '0' then
            resFifoDin(31 downto 28) <= txOpCode   after tpd;
            resFifoDin(27 downto 16) <= txSequence after tpd;
            resFifoDin(15 downto  0) <= txLength   after tpd;
            resFifoWr                <= '1'        after tpd;
            txRespAck                <= '1'        after tpd;
         
         -- Idle
         else
            resFifoDin <= (others=>'0') after tpd;
            resFifoWr  <= '0'           after tpd;
            txRespAck  <= '0'           after tpd;
         end if;

      end if;
   end process;

end EthMac1GCntrl;

