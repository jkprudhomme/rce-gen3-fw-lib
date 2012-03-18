-------------------------------------------------------------------------------
-- Title         : 10G MAC / Export PIC Interface
-- Project       : RCE 10G-bit MAC
-------------------------------------------------------------------------------
-- File          : XMacExport.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 02/11/2008
-------------------------------------------------------------------------------
-- Description:
-- PIC Export block for 10G MAC core for the RCE.
-------------------------------------------------------------------------------
-- Copyright (c) 2008 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 02/11/2008: created.
-- 02/23/2008: Fixed error which incorrectly detected short frame if the 
--             data available signal was de-asserted with the last line signal.
-- 02/29/2008: Outgoing data is now dumped when phy is not ready. Byte order
--             is swapped at PIC interface. 
-- 03/31/2008: Fixed errror where status was not generated properly in error
--             situation. 
-- 05/09/2008: Removed header/payload re-alignment. Added automated pause frame
--             reception and transmission.
-- 08/05/2008: Added two clock delay following tx of pause frames.
-- 11/12/2008: Added padding for frames under 64 bytes.
-------------------------------------------------------------------------------

LIBRARY ieee;
use work.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity XMacExport is port ( 
    
      -- Clock & Reset
      macClk                          : in  std_logic;
      macClk2X                        : in  std_logic;
      macRst                          : in  std_logic;

      -- PIC Export Interface
      Export_Clock                    : out std_logic;
      Export_Core_Reset               : in  std_logic;
      Export_Data_Valid               : in  std_logic;
      Export_Data_Ready               : out std_logic;
      Export_Data_SOP                 : in  std_logic;
      Export_Data_EOP                 : in  std_logic;
      Export_Data_Width               : in  std_logic;
      Export_Data                     : in  std_logic_vector(63 downto 0);
      Export_Advance_Status_Pipeline  : out std_logic;
      Export_Status                   : out std_logic_vector(31 downto 0);
      Export_Status_Full              : in  std_logic;

      -- Pic Import Flow Control
      Import_Pause                    : in  std_logic;

      -- XAUI Interface
      phyTxd                          : out std_logic_vector(63 downto 0);
      phyTxc                          : out std_logic_vector(7  downto 0);
      phyReady                        : in  std_logic;
      phyIdle                         : out std_logic;

      -- CRC Interface
      txCrcIn                         : out std_logic_vector(63 downto 0);
      txCrcDataWidth                  : out std_logic_vector(2  downto 0);
      txCrcDataValid                  : out std_logic;
      txCrcInit                       : out std_logic;
      txCrcReset                      : out std_logic;
      txCrcOut                        : in  std_logic_vector(31 downto 0);

      -- Pause Interface
      rxPauseSet                      : in  std_logic;
      rxPauseValue                    : in  std_logic_vector(15 downto 0);

      -- Configuration
      interFrameGap                   : in  std_logic_vector(3  downto 0);
      pauseTime                       : in  std_logic_vector(15 downto 0);
      macAddress                      : in  std_logic_vector(47 downto 0)
   );
end XMacExport;


-- Define architecture
architecture XMacExport of XMacExport is

   -- CRC delay FIFO
   component xmac_fifo_72x16 port (
      clk:   IN  std_logic;
      din:   IN  std_logic_VECTOR(71 downto 0);
      rd_en: IN  std_logic;
      rst:   IN  std_logic;
      wr_en: IN  std_logic;
      dout:  OUT std_logic_VECTOR(71 downto 0);
      empty: OUT std_logic;
      full:  OUT std_logic);
   end component;

   -- Local Signals
   signal intAdvance      : std_logic;
   signal intDump         : std_logic;
   signal intRunt         : std_logic;
   signal intPad          : std_logic;
   signal intLastLine     : std_logic;
   signal intLastValidByte: std_logic_vector(2  downto 0);
   signal locRst          : std_logic;
   signal frameShift0     : std_logic;
   signal frameShift1     : std_logic;
   signal txEnable0       : std_logic;
   signal txEnable1       : std_logic;
   signal txEnable2       : std_logic;
   signal txEnable3       : std_logic;
   signal txEnable4       : std_logic;
   signal crcIn           : std_logic_vector(63 downto 0);
   signal crcMaskIn       : std_logic_vector(7  downto 0);
   signal nxtMaskIn       : std_logic_vector(7  downto 0);
   signal crcFifoIn       : std_logic_vector(71 downto 0);
   signal crcFifoOut      : std_logic_vector(71 downto 0);
   signal txCrcInv        : std_logic_vector(31 downto 0);
   signal nxtEOF          : std_logic;
   signal intData         : std_logic_vector(63 downto 0);
   signal stateCount      : std_logic_vector(3  downto 0);
   signal stateCountRst   : std_logic;
   signal tmpImportPause  : std_logic;
   signal intImportPause  : std_logic;
   signal pausePreCnt     : std_logic_vector(2  downto 0);
   signal importPauseCnt  : std_logic_vector(15 downto 0);
   signal exportPauseCnt  : std_logic_vector(15 downto 0);
   signal exportWordCnt   : std_logic_vector(3  downto 0);
   signal pauseTx         : std_logic;
   signal pausePrst       : std_logic;
   signal pauseLast       : std_logic;
   signal pauseData       : std_logic_vector(63 downto 0);
   signal tmpPauseSet     : std_logic;
   signal intPauseSet     : std_logic;

   -- MAC States
   signal   curState    : std_logic_vector(3 downto 0);
   signal   nxtState    : std_logic_vector(3 downto 0);
   constant ST_IDLE     : std_logic_vector(3 downto 0) := "0000";
   constant ST_DUMP     : std_logic_vector(3 downto 0) := "0001";
   constant ST_READ     : std_logic_vector(3 downto 0) := "0010";
   constant ST_STAT     : std_logic_vector(3 downto 0) := "0011";
   constant ST_STAT_ERR : std_logic_vector(3 downto 0) := "0100";
   constant ST_WAIT     : std_logic_vector(3 downto 0) := "0101";
   constant ST_PWAIT    : std_logic_vector(3 downto 0) := "0110";
   constant ST_PAUSE    : std_logic_vector(3 downto 0) := "0111";
   constant ST_PAD      : std_logic_vector(3 downto 0) := "1000";

   -- Export errors
   type ErrorType is ( NO_ERROR, UNDERRUN, LINK_NOT_READY );
   signal intError : ErrorType;
   signal nxtError : ErrorType;

   -- Register delay for simulation
   constant tpd:time := 0.1 ns;

begin
   -- Re-Order Bytes
--    intData(63 downto 56) <= Export_Data(39 downto 32) when Export_Data_Valid = '1' else (others=>'0');
--    intData(55 downto 48) <= Export_Data(47 downto 40) when Export_Data_Valid = '1' else (others=>'0');
--    intData(47 downto 40) <= Export_Data(55 downto 48) when Export_Data_Valid = '1' else (others=>'0');
--    intData(39 downto 32) <= Export_Data(63 downto 56) when Export_Data_Valid = '1' else (others=>'0');
--    intData(31 downto 24) <= Export_Data(7  downto  0) when Export_Data_Valid = '1' else (others=>'0');
--    intData(23 downto 16) <= Export_Data(15 downto  8) when Export_Data_Valid = '1' else (others=>'0');
--    intData(15 downto  8) <= Export_Data(23 downto 16) when Export_Data_Valid = '1' else (others=>'0');
--    intData(7  downto  0) <= Export_Data(31 downto 24) when Export_Data_Valid = '1' else (others=>'0');

   -- Converting from Big Endian to little
   intData(63 downto 56) <= Export_Data(7  downto  0) when Export_Data_Valid = '1' else (others=>'0');
   intData(55 downto 48) <= Export_Data(15 downto  8) when Export_Data_Valid = '1' else (others=>'0');
   intData(47 downto 40) <= Export_Data(23 downto 16) when Export_Data_Valid = '1' else (others=>'0');
   intData(39 downto 32) <= Export_Data(31 downto 24) when Export_Data_Valid = '1' else (others=>'0');
   intData(31 downto 24) <= Export_Data(39 downto 32) when Export_Data_Valid = '1' else (others=>'0');
   intData(23 downto 16) <= Export_Data(47 downto 40) when Export_Data_Valid = '1' else (others=>'0');
   intData(15 downto  8) <= Export_Data(55 downto 48) when Export_Data_Valid = '1' else (others=>'0');
   intData(7  downto  0) <= Export_Data(63 downto 56) when Export_Data_Valid = '1' else (others=>'0');


   -- Advance data pipeline
   Export_Data_Ready <= (intAdvance and not intPad) or intDump;

   -- Output export clock
   Export_Clock <= macClk;

   -- Generate local reset
   locRst <= Export_Core_Reset or macRst;

   -- Status
   with nxtError select
     Export_Status <= (others=>'0')                   when NO_ERROR,
                      (txCrcInv(31 downto 8) & X"5F") when LINK_NOT_READY,
                      (txCrcInv(31 downto 8) & X"7F") when UNDERRUN;

   -- CRC Input
   txCrcReset            <= locRst or not phyReady;
   txCrcIn(63 downto 56) <= crcIn(7  downto  0);
   txCrcIn(55 downto 48) <= crcIn(15 downto  8);
   txCrcIn(47 downto 40) <= crcIn(23 downto 16);
   txCrcIn(39 downto 32) <= crcIn(31 downto 24);
   txCrcIn(31 downto 24) <= crcIn(39 downto 32);
   txCrcIn(23 downto 16) <= crcIn(47 downto 40);
   txCrcIn(15 downto  8) <= crcIn(55 downto 48);
   txCrcIn(7  downto  0) <= crcIn(63 downto 56);

   -- State machine logic
   process ( macClk, locRst ) begin
      if locRst = '1' then
         curState        <= ST_IDLE       after tpd;
         intError        <= NO_ERROR      after tpd;
         tmpImportPause  <= '0'           after tpd;
         intImportPause  <= '0'           after tpd;
         stateCount      <= (others=>'0') after tpd;
         exportWordCnt   <= (others=>'0') after tpd;
      elsif rising_edge(macClk) then

         -- State transition
         curState <= nxtState after tpd;

         -- Fail flag
         intError <= nxtError after tpd;

         -- Inter frame gap
         if stateCountRst = '1' then
           stateCount <= (others=>'0');
         else
           stateCount <= stateCount + 1;
         end if;

         if stateCountRst = '1' then
           exportWordCnt <= (others=>'0');
         elsif intAdvance = '1' and intRunt = '1' then
           exportWordCnt <= exportWordCnt + 1;
         end if;
         
         -- Double sample PIC pause signal, crossing clock domain
         tmpImportPause <= Import_Pause   after tpd;
         intImportPause <= tmpImportPause after tpd;
         
      end if;
   end process;

   -- Pad runt frames
   intRunt          <= not exportWordCnt(3);
   intLastValidByte <= "111" when (curState=ST_PAD or Export_Data_Width='1') else "011";
   
   -- State machine
   process (curState, Export_Data_Valid, intError, Export_Data_EOP, phyReady,
            Export_Status_Full, locRst, stateCount, intImportPause, importPauseCnt, exportPauseCnt,
            interFrameGap, intRunt ) begin

      case curState is 

         -- IDLE, wait for data to be available
         when ST_IDLE =>
            Export_Advance_Status_Pipeline <= '0';
            pauseTx                        <= '0';
            pauseLast                      <= '0';
            stateCountRst                  <= '1';
            intPad                         <= '0';
            intLastLine                    <= '0';
            
            -- Pause frame is required
            if intImportPause = '1' and importPauseCnt = 0 then
               intAdvance <= '0';
               intDump    <= '0';
               nxtError   <= NO_ERROR;
               pausePrst  <= '1';
               nxtState   <= ST_PAUSE;

            -- Wait for start flag, export pause count must be zero
            elsif Export_Data_Valid = '1' and locRst = '0' and exportPauseCnt = 0 then

               pausePrst  <= '0';

               -- Phy is ready
               if phyReady = '1' then
                  intAdvance <= '1';
                  intDump    <= '0';
                  nxtState   <= ST_READ;
                  nxtError   <= NO_ERROR;

               -- Phy is not ready dump data
               else
                  intAdvance <= '0';
                  intDump    <= '1';
                  nxtState   <= ST_DUMP;
                  nxtError   <= LINK_NOT_READY;
               end if;
            else
               nxtError   <= NO_ERROR;
               intAdvance <= '0';
               intDump    <= '0';
               pausePrst  <= '0';
               nxtState   <= curState;
            end if;

         -- Transmit Pause Frame
         when ST_PAUSE =>
            Export_Advance_Status_Pipeline <= '0';
            pauseTx                        <= '1';
            intAdvance                     <= '0';   
            intDump                        <= '0';   
            nxtError                       <= NO_ERROR;
            pausePrst                      <= '0';
            intPad                         <= '0';
            intLastLine                    <= '0';
            
            -- Pause Frame Is Finished
            if stateCount = 8 then
               stateCountRst <= '1';
               pauseLast     <= '1';
               nxtState      <= ST_PWAIT;
            else
               stateCountRst <= '0';
               pauseLast     <= '0';
               nxtState      <= curState;
            end if;

         -- Wait following pause frame TX
         when ST_PWAIT =>
            Export_Advance_Status_Pipeline <= '0';
            intDump                        <= '0';
            nxtError                       <= intError;
            intAdvance                     <= '0';
            pauseTx                        <= '0';
            pauseLast                      <= '0';
            stateCountRst                  <= '0';
            pausePrst                      <= '0';
            intPad                         <= '0';
            intLastLine                    <= '0';
            
            -- Wait for gap
            if stateCount = 2 then
               nxtState <= ST_IDLE;
            else
               nxtState <= curState;
            end if;

         -- Reading from PIC
         when ST_READ =>
            Export_Advance_Status_Pipeline <= '0';
            intDump                        <= '0';
            pauseTx                        <= '0';
            pauseLast                      <= '0';
            stateCountRst                  <= '0';
            pausePrst                      <= '0';
            intLastLine                    <= '0';
            intPad                         <= '0';
            nxtError                       <= intError;
            nxtState                       <= curState;

            -- Read until we get last
            if Export_Data_EOP = '1' and intRunt = '1' then
               intAdvance <= '1';
               intPad     <= '1';
               nxtState   <= ST_PAD;

            elsif Export_Data_EOP='1' and intRunt = '0' then
               intAdvance <= '0';
               intLastLine<= '1';
               nxtState   <= ST_STAT;

            -- Detect underflow
--             elsif Export_Data_Available = '0' then
--                nxtError   <= UNDERRUN;
--                intAdvance <= '0';

            -- Keep reading
            else
               intAdvance <= '1';
            end if;

         -- Reading from PIC, Dumping data
         when ST_DUMP =>
            Export_Advance_Status_Pipeline <= '0';
            intAdvance                     <= '0';
            nxtError                       <= intError;
            pauseTx                        <= '0';
            pauseLast                      <= '0';
            stateCountRst                  <= '0';
            pausePrst                      <= '0';
            intPad                         <= '0';
            
            -- Read until we get last
            if Export_Data_EOP = '1' then
               intDump    <= '0';
               intLastLine<= '1';
               nxtState   <= ST_STAT;

            -- Keep reading
            else
               intDump    <= Export_Data_Valid;
               intLastLine<= '0';
               nxtState   <= curState;
            end if;

         -- Write Status
         when ST_STAT =>
            intAdvance    <= '0';
            intDump       <= '0';
            nxtError      <= intError;
            pauseTx       <= '0';
            pauseLast     <= '0';
            stateCountRst <= '0';
            pausePrst     <= '0';
            intPad        <= '0';
            intLastLine   <= '0';
            
            -- Wait for status to be ready
            if Export_Status_Full = '0' then
               if intError = NO_ERROR then
                  nxtState <= ST_WAIT;
               else
                  nxtState <= ST_STAT_ERR;
               end if;
               Export_Advance_Status_Pipeline <= '1';
            else
               nxtState                       <= curState;
               Export_Advance_Status_Pipeline <= '0';
            end if;

         -- Write status with error
         when ST_STAT_ERR =>
            nxtError      <= NO_ERROR;
            intAdvance    <= '0';
            intDump       <= '0';
            pauseTx       <= '0';
            pauseLast     <= '0';
            stateCountRst <= '0';
            pausePrst     <= '0';
            intPad        <= '0';
            intLastLine   <= '0';
            
            -- Wait for status to be ready
            if Export_Status_Full = '0' then
               nxtState                       <= ST_WAIT;
               Export_Advance_Status_Pipeline <= '1';
            else
               nxtState                       <= curState;
               Export_Advance_Status_Pipeline <= '0';
            end if;

         -- Wait for inter-frame gap
         when ST_WAIT =>
            Export_Advance_Status_Pipeline <= '0';
            intDump                        <= '0';
            nxtError                       <= intError;
            intAdvance                     <= '0';
            pauseTx                        <= '0';
            pauseLast                      <= '0';
            stateCountRst                  <= '0';
            pausePrst                      <= '0';
            intPad                         <= '0';
            intLastLine                    <= '0';
            
            -- Wait for gap
            if stateCount = interFrameGap then
               nxtState <= ST_IDLE;
            else
               nxtState <= curState;
            end if;

         -- Padding frame
         when ST_PAD =>
            Export_Advance_Status_Pipeline <= '0';
            intDump                        <= '0';
            pauseTx                        <= '0';
            pauseLast                      <= '0';
            stateCountRst                  <= '0';
            pausePrst                      <= '0';
            nxtError                       <= intError;
            if intRunt = '1' then
              intAdvance <= '1';
              intPad     <= '1';
              intLastLine<= '0';
              nxtState   <= curState;
            else
              intAdvance <= '0';
              intPad     <= '0';
              intLastLine<= '1';
              nxtState   <= ST_STAT;
            end if;

        when others =>
            nxtState                       <= ST_IDLE;
            intAdvance                     <= '0';
            Export_Advance_Status_Pipeline <= '0';
            intDump                        <= '0';
            nxtError                       <= NO_ERROR;
            pauseTx                        <= '0';
            pauseLast                      <= '0';
            stateCountRst                  <= '0';
            pausePrst                      <= '0';
            intPad                         <= '0';
            intLastLine                    <= '0';
      end case;
   end process;


   -- Format data for input into CRC delay FIFO.
   process ( macClk, locRst ) begin
      if locRst = '1' then
         frameShift0    <= '0'           after tpd;
         frameShift1    <= '0'           after tpd;
         txEnable0      <= '0'           after tpd;
         txEnable1      <= '0'           after tpd;
         txEnable2      <= '0'           after tpd;
         txEnable3      <= '0'           after tpd;
         txEnable4      <= '0'           after tpd;
         txCrcInit      <= '0'           after tpd;
         txCrcDataValid <= '0'           after tpd;
         txCrcDataWidth <= (others=>'0') after tpd;
         crcMaskIn      <= (others=>'0') after tpd;
         nxtMaskIn      <= (others=>'0') after tpd;
         crcIn          <= (others=>'0') after tpd;
      elsif rising_edge(macClk) then

         -- Shift register to track frame state
         frameShift0 <= intAdvance  or pauseTx after tpd;
         frameShift1 <= frameShift0            after tpd;

         -- Input to transmit enable shift register. 
         -- Asserted with frameShift0
         if (intAdvance = '1' or pauseTx = '1') and frameShift0 = '0' then
            txEnable0 <= '1' after tpd;

         -- De-assert following frame shift0, 
         -- keep one extra clock if nxtMask contains a non-zero value.
         elsif frameShift0 = '0' and nxtMaskIn = x"00" then
            txEnable0 <= '0' after tpd;
         end if;

         -- Transmit enable shift register
         txEnable1 <= txEnable0 after tpd;
         txEnable2 <= txEnable1 after tpd;
         txEnable3 <= txEnable2 after tpd;
         txEnable4 <= txEnable3 after tpd;

         -- CRC Input
         if pauseTx = '1' then
            crcIn <= pauseData after tpd;
         else
            crcIn <= intData after tpd;
         end if;

         -- CRC Input Control. 
         -- Assert init after shift 1, before shift 2
         if frameShift0 = '1' and frameShift1 = '0' then
            txCrcInit      <= '1'   after tpd;
            txCrcDataValid <= '1'   after tpd;
            txCrcDataWidth <= "111" after tpd;
         else

            -- Init asserted for one pulse
            txCrcInit      <= '0'         after tpd;
            txCrcDataValid <= frameShift0 after tpd;

            -- Last line
            if intLastLine = '1' and pauseTx = '0' then
               txCrcDataWidth <= intLastValidByte after tpd;
            else
               txCrcDataWidth <= "111" after tpd;
            end if;
         end if;

         -- Generate CRC Mask Value for CRC append after delay buffer.
         -- depends on number of bytes in last transfer
         if pauseLast = '1' then
            crcMaskIn <= x"00" after tpd;
            nxtMaskIn <= x"0F" after tpd;
         elsif intLastLine = '1' and frameShift0 = '1' and pauseTx = '0' then
            if intError /= NO_ERROR then
               crcMaskIn <= x"FF" after tpd;
               nxtMaskIn <= x"00" after tpd;
            else
               case intLastValidByte is
                  when "000"  => crcMaskIn <= x"1E" after tpd; nxtMaskIn <= x"00" after tpd;
                  when "001"  => crcMaskIn <= x"3C" after tpd; nxtMaskIn <= x"00" after tpd;
                  when "010"  => crcMaskIn <= x"78" after tpd; nxtMaskIn <= x"00" after tpd;
                  when "011"  => crcMaskIn <= x"F0" after tpd; nxtMaskIn <= x"00" after tpd;
                  when "100"  => crcMaskIn <= x"E0" after tpd; nxtMaskIn <= x"01" after tpd;
                  when "101"  => crcMaskIn <= x"C0" after tpd; nxtMaskIn <= x"03" after tpd;
                  when "110"  => crcMaskIn <= x"80" after tpd; nxtMaskIn <= x"07" after tpd;
                  when "111"  => crcMaskIn <= x"00" after tpd; nxtMaskIn <= x"0F" after tpd;
                  when others => crcMaskIn <= x"00" after tpd; nxtMaskIn <= x"00" after tpd;
               end case;
            end if;
         else
            crcMaskIn <= nxtMaskIn     after tpd;
            nxtMaskIn <= (others=>'0') after tpd;
         end if;
      end if;
   end process;

   -- Select CRC FIFO Data
   crcFifoIn(71 downto 64) <= crcMaskIn;
   crcFifoIn(63 downto  0) <= crcIn;

   -- CRC Delay FIFO
   U_CrcFifo: xmac_fifo_72x16 port map (
      clk    => macClk,
      din    => crcFifoIn,
      rd_en  => txEnable2,
--      rst    => macRst,
      rst    => locRst,
      wr_en  => txEnable0,
      dout   => crcFifoOut,
      empty  => open,
      full   => open
   );


   -- Invert CRC for transmission
   txCrcInv(31 downto 24) <= not txCrcOut(7  downto  0);
   txCrcInv(23 downto 16) <= not txCrcOut(15 downto  8);
   txCrcInv(15 downto  8) <= not txCrcOut(23 downto 16);
   txCrcInv(7  downto  0) <= not txCrcOut(31 downto 24);


   -- Output Stage to PHY
   process ( macClk, locRst ) begin
      if locRst = '1' then
         phyTxd  <= (others=>'0') after tpd;
         phyTxc  <= (others=>'0') after tpd;
         phyIdle <= '0'           after tpd;
         nxtEOF  <= '0'           after tpd;
      elsif rising_edge(macClk) then

         -- EOF Charactor Required If CRC was in last word and there was
         -- not enough space for EOF
         if nxtEOF = '1' then
            phyTxd <= X"BCBCBCBCBCBCBCFD" after tpd;
            phyTxc <= x"FF"               after tpd;
            nxtEOF <= '0'                 after tpd;

         -- Not transmitting
         elsif txEnable3 = '0' then 
            phyTxd  <= X"BCBCBCBCBCBCBCBC" after tpd;
            phyTxc  <= x"FF"               after tpd;
            phyIdle <= '1'                 after tpd;

         -- Pre-amble word
         elsif txEnable4 = '0' then
            phyTxd  <= X"D5555555555555FB" after tpd;
            phyTxc  <= x"01"               after tpd;
            phyIdle <= '0'                 after tpd;

         -- Normal data or CRC data. Select CRC / data combination
         else
            case crcFifoOut(71 downto 64) is -- CRC MASK
               when x"00" => 
                  phyTxd <= crcFifoOut(63 downto 0)               after tpd;
                  phyTxc <= x"00"                                 after tpd;
               when x"80" => 
                  phyTxd(63 downto 56) <= txCrcInv(7  downto 0)   after tpd;
                  phyTxd(55 downto  0) <= crcFifoOut(55 downto 0) after tpd;
                  phyTxc               <= x"00"                   after tpd;
               when x"07" => 
                  phyTxd(63 downto 24) <= x"BCBCBCBCFD"           after tpd;
                  phyTxd(23 downto  0) <= txCrcInv(31 downto 8)   after tpd;
                  phyTxc               <= x"F8"                   after tpd;
               when x"0F" => 
                  phyTxd(63 downto 32) <= x"BCBCBCFD"             after tpd;
                  phyTxd(31 downto  0) <= txCrcInv                after tpd;
                  phyTxc               <= x"F0"                   after tpd;
               when x"1E" => 
                  phyTxd(63 downto 40) <= x"BCBCFD"               after tpd;
                  phyTxd(39 downto  8) <= txCrcInv                after tpd;
                  phyTxd(7  downto  0) <= crcFifoOut(7 downto 0)  after tpd;
                  phyTxc               <= x"E0"                   after tpd;
               when x"3C" => 
                  phyTxd(63 downto 48) <= x"BCFD"                 after tpd;
                  phyTxd(47 downto 16) <= txCrcInv                after tpd;
                  phyTxd(15 downto  0) <= crcFifoOut(15 downto 0) after tpd;
                  phyTxc               <= x"C0"                   after tpd;
               when x"78" => 
                  phyTxd(63 downto 56) <= x"FD"                   after tpd;
                  phyTxd(55 downto 24) <= txCrcInv                after tpd;
                  phyTxd(23 downto  0) <= crcFifoOut(23 downto 0) after tpd;
                  phyTxc               <= x"80"                   after tpd;
               when x"F0" => 
                  phyTxd(63 downto 32) <= txCrcInv                after tpd;
                  phyTxd(31 downto  0) <= crcFifoOut(31 downto 0) after tpd;
                  phyTxc               <= x"00"                   after tpd;
                  nxtEOF               <= '1'                     after tpd;
               when x"E0" => 
                  phyTxd(63 downto 40) <= txCrcInv(23 downto 0)   after tpd;
                  phyTxd(39 downto  0) <= crcFifoOut(39 downto 0) after tpd;
                  phyTxc               <= x"00"                   after tpd;
               when x"01" => 
                  phyTxd(63 downto  8) <= x"BCBCBCBCBCBCFD"       after tpd;
                  phyTxd(7  downto  0) <= txCrcInv(31 downto 24)  after tpd;
                  phyTxc               <= x"FE"                   after tpd;
               when x"C0" => 
                  phyTxd(63 downto 48) <= txCrcInv(15 downto 0)   after tpd;
                  phyTxd(47 downto  0) <= crcFifoOut(47 downto 0) after tpd;
                  phyTxc               <= x"00"                   after tpd;
               when x"03" => 
                  phyTxd(63 downto 16) <= x"BCBCBCBCBCFD"         after tpd;
                  phyTxd(15 downto  0) <= txCrcInv(31 downto 16)  after tpd;
                  phyTxc               <= x"FC"                   after tpd;
               when x"FF" => 
                  phyTxd(63 downto 32) <= x"BCBCBCFD"             after tpd;
                  phyTxd(31 downto  0) <= not txCrcInv            after tpd;
                  phyTxc               <= x"F0"                   after tpd;
               when others => 
                  phyTxd <= x"BCBCBCBCBCBCBCBC"                   after tpd;
                  phyTxc <= x"FF"                                 after tpd;
            end case;
            phyIdle <= '0' after tpd;
         end if;
      end if;
   end process;


   -- Pause Counters & Frame Generation

   with stateCount select
     pauseData <=
       -- Preamble
       (others => '0') when "0000", 
       -- Src Id, Upper 2 Bytes + Dest Id, All 6 bytes
       (macAddress(39 downto 32) & macAddress(47 downto 40) & x"010000C28001") when "0001",
       -- Pause Opcode + Length/Type Field + Src Id, Lower 4 bytes
       (x"0100" & x"0888" & macAddress( 7 downto 0) &
                            macAddress(15 downto  8) &
                            macAddress(23 downto 16) &
                            macAddress(31 downto 24)) when "0010",
       -- Pause length
       (x"000000000000" & pauseTime( 7 downto 0) & pauseTime(15 downto 8)) when "0011",
       (others=>'0') when others;

   -- Counters for pause tracking
   process ( macClk, locRst ) begin
      if locRst = '1' then
         pausePreCnt    <= (others=>'0') after tpd;
         importPauseCnt <= (others=>'0') after tpd;
         exportPauseCnt <= (others=>'0') after tpd;
         tmpPauseSet    <= '0'           after tpd;
         intPauseSet    <= '0'           after tpd;
      elsif rising_edge(macClk) then

         -- Pre-counter, 8 125Mhz clocks ~= 512 bit times of 10G
         pausePreCnt <= pausePreCnt + 1 after tpd;

         -- Import Pause Counter, preset with transmitted pause value
         -- Decrement at end of pause tx. This ensures local count will
         -- expire in time to send a new pause frame to remote end before it expires
         if pausePrst = '1' then
            importPauseCnt <= pauseTime after tpd;
         elsif (pausePreCnt = 0 or pauseLast = '1') and importPauseCnt /= 0 then
            importPauseCnt <= importPauseCnt - 1 after tpd;
         end if;

         -- Double sample pause set indication, crossing clock boundary
         tmpPauseSet <= rxPauseSet  after tpd;
         intPauseSet <= tmpPauseSet after tpd;

         -- Export Pause Counter, preset with received pause value
         if intPauseSet = '1' then
            exportPauseCnt <= rxPauseValue after tpd;
         elsif pausePreCnt = 0 and exportPauseCnt /= 0 then
            exportPauseCnt <= exportPauseCnt - 1 after tpd;
         end if;
      end if;
   end process;

end XMacExport;

