-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Outbound PPI DMA
-- File          : ArmRceG3ObPpi.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 09/03/2013
-------------------------------------------------------------------------------
-- Description:
-- Outbound PPI DMA controller
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;

entity ArmRceG3ObPpi is
   generic (
      TPD_G             : time                   := 1 ns;
      PPI_READY_THOLD_G : integer range 0 to 511 := 0
   );
   port (

      -- Clock
      axiClk                  : in  sl;

      -- AXI HP Master
      axiClkRst               : in  sl;
      axiHpSlaveReadFromArm   : in  AxiReadSlaveType;
      axiHpSlaveReadToArm     : out AxiReadMasterType;

      -- Outbound Header FIFO
      obHeaderToFifo          : out ObHeaderToFifoType;
      obHeaderFromFifo        : in  ObHeaderFromFifoType;

      -- Configuration
      readDmaCache            : in  slv(3  downto 0);

      -- Completion FIFO
      compFromFifo            : out CompFromFifoType;
      compToFifo              : in  CompToFifoType;

      -- PPI FIFO Interface
      ppiClk                  : in  sl;
      ppiReadToFifo           : in  PpiReadToFifoType;
      ppiReadFromFifo         : out PpiReadFromFifoType
   );
end ArmRceG3ObPpi;

architecture structure of ArmRceG3ObPpi is

   -- Header dma info
   type HeaderDmaType is record 
      eoh      : sl;
      preEoh   : sl;
      empty    : sl;
      preEmpty : sl;
      compId   : slv(31 downto 0);
      compIdx  : slv(3  downto 0);
      compEn   : sl;
      length   : slv(31 downto 0);
      addr     : slv(31 downto 0);
      valid    : sl;
   end record;

   -- Outbound PPI data
   type ObPpiType is record
      data   : slv(63 downto 0);
      eof    : sl;
      eoh    : sl;
      ftype  : slv(3 downto 0);
      valid  : slv(7 downto 0);
   end record;

   -- States
   type States is ( ST_IDLE, ST_SHIFT, ST_PAUSE, ST_READ, ST_CHECK, ST_WAIT, ST_COMP  );

   -- Local signals
   signal obHeaderReg      : ObHeaderFromFifoArray(1 downto 0);
   signal headerDma        : HeaderDmaType;
   signal fifoShift        : sl;
   signal fifoClear        : sl;
   signal rxLengthRem      : slv(31 downto 0);
   signal rxLengthDec      : slv(3  downto 0);
   signal rxDone           : sl;
   signal rxLast           : sl;
   signal rxFirst          : sl;
   signal rxEnable         : sl;
   signal headerWrite      : sl;
   signal headerEOF        : sl;
   signal headerEOH        : sl;
   signal obPpiDin         : slv(71 downto 0);
   signal obPpiDout        : slv(71 downto 0);
   signal obPpi            : ObPpiType;
   signal obPpiHead        : sl;
   signal obPpiWriteEn     : sl;
   signal obPpiHold        : ObPpiType;
   signal obPpiFifo        : ObPpiType;
   signal obPpiFirst       : sl;
   signal obPpiFifoWr      : sl;
   signal currCompData     : CompFromFifoType;
   signal nxtCompWrite     : sl;
   signal addrValid        : sl;
   signal readAddr         : slv(31 downto 0);
   signal readPending      : slv(31 downto 0);
   signal ppiPFull         : sl;
   signal compFifoDin      : slv(35 downto 0);
   signal compFifoDout     : slv(35 downto 0);
   signal nextValid        : slv(7  downto 0);
   signal axiReadToCntrl   : AxiReadToCntrlType;
   signal axiReadFromCntrl : AxiReadFromCntrlType;
   signal firstSize        : slv(7   downto 0);
   signal currSize         : slv(7   downto 0);
   signal firstLength      : slv(3   downto 0);
   signal currLength       : slv(3   downto 0);
   signal curState         : States;
   signal nxtState         : States;
   signal dbgState         : slv(2 downto 0);
   signal ppiPFullReg      : sl;
   signal axiClkRstInt     : sl := '1';
   signal obPpiEofWr       : sl;
   signal obPpiEofRd       : sl;
   signal obPpiEofValid    : sl;
   signal ppiReadCount     : slv(8 downto 0);

   attribute mark_debug : string;
   attribute mark_debug of axiClkRstInt : signal is "true";

   attribute INIT : string;
   attribute INIT of axiClkRstInt : signal is "1";

begin

   -- Reset registration
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         axiClkRstInt <= axiClkRst after TPD_G;
      end if;
   end process;

   -- State Debug
   dbgState <= conv_std_logic_vector(States'POS(curState), 3);

   -----------------------------------------
   -- Outbound Header FIFO Interface
   -----------------------------------------

   -- Read to FIFO
   obHeaderToFifo.read <= fifoShift;

   -- Output pipeline, 2 extra registers after FIFO.
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            obHeaderReg  <= (others=>ObHeaderFromFifoInit) after TPD_G;
         elsif fifoClear = '1' then
            obHeaderReg  <= (others=>ObHeaderFromFifoInit) after TPD_G;
         elsif fifoShift = '1' then
            obHeaderReg(0) <= obHeaderFromFifo after TPD_G;
            obHeaderReg(1) <= obHeaderReg(0)   after TPD_G;
         end if;
      end if;
   end process;

   -- Extract Fields, assume eoh is at obHeaderRegA
   headerDma.preEmpty <= obHeaderFromFifo.data(37) and obHeaderFromFifo.eoh;
   headerDma.compIdx  <= obHeaderReg(0).data(35 downto 32);
   headerDma.compEn   <= obHeaderReg(0).data(36);
   headerDma.empty    <= obHeaderReg(0).data(37);
   headerDma.preEoh   <= obHeaderFromFifo.eoh;
   headerDma.eoh      <= obHeaderReg(0).eoh;
   headerDma.compId   <= obHeaderReg(0).data(31 downto  0);
   headerDma.length   <= obHeaderReg(1).data(63 downto 32);
   headerDma.addr     <= obHeaderReg(1).data(31 downto  0);
   headerDma.valid    <= obHeaderReg(1).valid;

   -----------------------------------------
   -- Master State Machine
   -----------------------------------------

   -- Determine transfer size to align all transfers to 128 byte boundaries
   -- This initial alignment will ensure that we never cross a 4k boundary
   firstSize(7 downto 3) <= "10000" - headerDma.addr(6 downto 3);
   firstSize(2 downto 0) <= "000";
   firstLength           <= x"F"  - headerDma.addr(6 downto 3);

   -- Sync states
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            curState           <= ST_IDLE       after TPD_G;
            readAddr           <= (others=>'0') after TPD_G;
            readPending        <= (others=>'0') after TPD_G;
            currCompData.valid <= '0'           after TPD_G;
            currCompData.id    <= (others=>'0') after TPD_G;
            currSize           <= (others=>'0') after TPD_G;
            currLength         <= (others=>'0') after TPD_G;
            ppiPFullReg        <= '0'           after TPD_G;
         else

            -- Almost full
            ppiPFullReg <= ppiPFull after TPD_G;

            -- State
            curState <= nxtState after TPD_G;

            -- Completion Data
            currCompData.id    <= headerDma.compId  after TPD_G;
            currCompData.index <= headerDma.compIdx after TPD_G;
            currCompData.valid <= nxtCompWrite      after TPD_G;

            -- Reset counters
            if rxEnable = '0' then
               readAddr(31 downto 3)  <= headerDma.addr(31 downto 3) after TPD_G;
               readAddr(2  downto 0)  <= "000"                       after TPD_G;
               currSize               <= firstSize                   after TPD_G;
               currLength             <= firstLength                 after TPD_G;
               readPending            <= (others=>'0')               after TPD_G;

            -- Increment pending and address, 128 bytes per read
            elsif addrValid = '1' then
               readAddr    <= readAddr + currSize after TPD_G;
               currSize    <= x"80"               after TPD_G; -- 128
               currLength  <= x"F"                after TPD_G; -- 15
               readPending <= readPending + 128   after TPD_G;
            end if;
         end if;
      end if;
   end process;

   -- ASync states
   process ( curState, obHeaderFromFifo, rxDone, rxLast, 
             headerDma, axiReadFromCntrl, ppiPFullReg, readPending ) begin

      -- Init signals
      nxtState        <= curState;
      nxtCompWrite    <= '0';
      rxEnable        <= '0';
      fifoShift       <= '0';
      fifoClear       <= '0';
      headerWrite     <= '0';
      headerEOF       <= '0';
      headerEOH       <= '0';
      addrValid       <= '0';

      -- State machine
      case curState is 

         -- IDLE
         when ST_IDLE =>
            fifoClear <= '1';

            -- Data is at FIFO
            if obHeaderFromFifo.valid = '1' then
               nxtState <= ST_SHIFT;
            end if;

         -- Shift Data
         when ST_SHIFT =>

            -- Only when FIFO is valid
            if obHeaderFromFifo.valid = '1' then
               fifoShift   <= '1';
               headerWrite <= headerDma.valid;

               -- EOH plus empty is coming
               if headerDma.preEmpty = '1' then
                  headerEOF <= '1';
                  headerEOH <= '1';
                  nxtState  <= ST_COMP;

               -- EOH is coming
               elsif headerDma.preEoh = '1' then
                  headerEOH <= '1';
                  nxtState  <= ST_PAUSE;
               end if;
            end if;

         -- Pause one clock for header data to shift in pipeline
         when ST_PAUSE =>
            nxtState <= ST_READ;

         -- Issue read request, wait for ready
         when ST_READ =>
            rxEnable <= '1';

            -- Pause on flow control
            if axiReadFromCntrl.afull = '0' then
               addrValid <= '1';
               nxtState  <= ST_CHECK;
            end if;
            
         -- Check if we are done with read requests
         when ST_CHECK =>
            rxEnable <= '1';
          
            -- Done 
            if readPending >= headerDma.length then
               nxtState <= ST_WAIT;

            -- Only continue if FIFO is not filling up
            elsif ppiPFullReg = '0' then
               nxtState <= ST_READ;
            end if;

         -- Wait for all of the data to return
         when ST_WAIT =>
            rxEnable <= '1';

            if rxDone = '1' and rxLast = '1' then
               nxtState <= ST_COMP;
            end if;

         -- Write Completion if enabled
         when ST_COMP =>
            nxtCompWrite <= headerDma.compEn and (not headerDma.empty);
            nxtState     <= ST_IDLE;

         when others =>
            nxtState <= ST_IDLE;
      end case;
   end process;

   -----------------------------------------
   -- AXI Read Controller
   -----------------------------------------
   U_ReadCntrl : entity work.AxiRceG3AxiReadCntrl 
      generic map (
         TPD_G      => TPD_G,
         CHAN_CNT_G => 1
      ) port map (
         axiClk               => axiClk,
         axiClkRst            => axiClkRstInt,
         axiSlaveReadFromArm  => axiHpSlaveReadFromArm,
         axiSlaveReadToArm    => axiHpSlaveReadToArm,
         readDmaCache         => readDmaCache,
         axiReadToCntrl(0)    => axiReadToCntrl,
         axiReadFromCntrl(0)  => axiReadFromCntrl
      );

   -- AXI read master
   axiReadToCntrl.req       <= '1';
   axiReadToCntrl.address   <= readAddr(31 downto 3);
   axiReadToCntrl.avalid    <= addrValid;
   axiReadToCntrl.id        <= "000";
   axiReadToCntrl.length    <= currLength;
   axiReadToCntrl.afull     <= ppiPFullReg;

   -----------------------------------------
   -- Read data processing
   -----------------------------------------

   -- Determine first read decrement based upon address alignment
   rxLengthDec <= "1000" when headerDma.addr(2 downto 0) = "000" and rxFirst = '1' else
                  "0111" when headerDma.addr(2 downto 0) = "001" and rxFirst = '1' else
                  "0110" when headerDma.addr(2 downto 0) = "010" and rxFirst = '1' else
                  "0101" when headerDma.addr(2 downto 0) = "011" and rxFirst = '1' else
                  "0100" when headerDma.addr(2 downto 0) = "100" and rxFirst = '1' else
                  "0011" when headerDma.addr(2 downto 0) = "101" and rxFirst = '1' else
                  "0010" when headerDma.addr(2 downto 0) = "110" and rxFirst = '1' else
                  "0001" when headerDma.addr(2 downto 0) = "111" and rxFirst = '1' else
                  "1000";

   -- Determine which read data bytes are valid
   nextValid <= "11111111" when rxLengthRem >= 8 and rxDone = '0' else
                "01111111" when rxLengthRem  = 7 and rxDone = '0' else
                "00111111" when rxLengthRem  = 6 and rxDone = '0' else
                "00011111" when rxLengthRem  = 5 and rxDone = '0' else
                "00001111" when rxLengthRem  = 4 and rxDone = '0' else
                "00000111" when rxLengthRem  = 3 and rxDone = '0' else
                "00000011" when rxLengthRem  = 2 and rxDone = '0' else
                "00000001" when rxLengthRem  = 1 and rxDone = '0' else
                "00000000";

   -- Sync states
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            obPpi.data      <= (others=>'0') after TPD_G;
            obPpi.eof       <= '0'           after TPD_G;
            obPpi.eoh       <= '0'           after TPD_G;
            obPpi.ftype     <= (others=>'0') after TPD_G;
            obPpi.valid     <= (others=>'0') after TPD_G;
            obPpiHead       <= '0'           after TPD_G;
            obPpiFirst      <= '0'           after TPD_G;
            rxLengthRem     <= (others=>'0') after TPD_G;
            rxDone          <= '0'           after TPD_G;
            rxLast          <= '0'           after TPD_G;
            rxFirst         <= '0'           after TPD_G;
         else

            -- Constant data
            obPpi.ftype <= obHeaderReg(1).htype after TPD_G;

            -- RX Engine disabled, writes sourced from main state machine (header data)
            if rxEnable = '0' then
               obPpi.valid    <= (others=>headerWrite) after TPD_G;
               obPpi.eof      <= headerEOF             after TPD_G;
               obPpi.eoh      <= headerEOH             after TPD_G;
               obPpi.data     <= obHeaderReg(1).data   after TPD_G;
               obPpiHead      <= '1'                   after TPD_G;
               rxDone         <= '0'                   after TPD_G;
               rxLast         <= '0'                   after TPD_G;
               rxFirst        <= '1'                   after TPD_G;
               obPpiFirst     <= '1'                   after TPD_G;
               rxLengthRem    <= headerDma.length      after TPD_G;

            -- Read data is valid and id matches
            elsif axiReadFromCntrl.rvalid = '1' then
               obPpiHead  <= '0'                    after TPD_G;
               obPpi.eoh  <= '0'                    after TPD_G;
               rxLast     <= axiReadFromCntrl.rlast after TPD_G;
               obPpiFirst <= rxFirst                after TPD_G;
               
               -- Output data
               obPpi.data <= axiReadFromCntrl.rdata after TPD_G;

               -- Write
               obPpi.valid <= nextValid after TPD_G;

               -- Last qword of the transfer
               if rxLengthRem <= 8 then
                  rxDone    <= '1' after TPD_G;
                  obPpi.eof <= '1' after TPD_G;

               -- Decrement remaining length
               else
                  rxLengthRem <= rxLengthRem - rxLengthDec after TPD_G;
                  obPpi.eof   <= '0'                       after TPD_G;
                  rxFirst     <= '0'                       after TPD_G;
               end if;
            else
               obPpi.valid <= (others=>'0') after TPD_G;
            end if;
         end if;
      end if;
   end process;

   -------------------------------------------------------------------------------
   -- Byte alignment adjustment
   -- Need to align outgoing data to 64-bits regardless of the base address
   -- alignment. A two stage register is used to shift the read data 
   -- accordingly as it is received from the AXI slave
   -------------------------------------------------------------------------------
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            obPpiHold.data    <= (others=>'0') after TPD_G;
            obPpiHold.eof     <= '0'           after TPD_G;
            obPpiHold.eoh     <= '0'           after TPD_G;
            obPpiHold.ftype   <= (others=>'0') after TPD_G;
            obPpiHold.valid   <= (others=>'0') after TPD_G;
            obPpiFifo.data    <= (others=>'0') after TPD_G;
            obPpiFifo.eof     <= '0'           after TPD_G;
            obPpiFifo.eoh     <= '0'           after TPD_G;
            obPpiFifo.ftype   <= (others=>'0') after TPD_G;
            obPpiFifo.valid   <= (others=>'0') after TPD_G;
            obPpiWriteEn      <= '0'           after TPD_G;
         else

            -- EOF is present in hold register, 
            -- shift to FIFO register, clear hold register, write to FIFO
            if obPpiHold.eof = '1' and obPpiHold.valid /= 0 then
               obPpiFifo       <= obPpiHold  after TPD_G;
               obPpiHold.eof   <= '0'        after TPD_G;
               obPpiHold.valid <= "00000000" after TPD_G;
               obPpiWriteEn    <= '1'        after TPD_G;

            -- EOF is present in fifo register, 
            -- clear FIFO register, clear write
            elsif obPpiFifo.eof = '1' and obPpiFifo.valid /= 0 then
               obPpiFifo.eof   <= '0'        after TPD_G;
               obPpiFifo.valid <= "00000000" after TPD_G;
               obPpiWriteEn    <= '0'        after TPD_G;

            -- Shifting in header mode, no alignment adjust
            elsif obPpi.valid /= 0 and obPpiHead = '1' then
               obPpiHold         <= obPpi         after TPD_G;
               obPpiHold.valid   <= "11111111"    after TPD_G;
               obPpiFifo         <= obPpiHold     after TPD_G;
               obPpiWriteEn      <= '1'           after TPD_G;

            -- Shifting in payload data
            elsif obPpi.valid(0) = '1' and obPpiHead = '0' then

               -- Init values
               obPpiHold       <= obPpi      after TPD_G;
               obPpiHold.valid <= "00000000" after TPD_G;
               obPpiFifo       <= obPpiHold  after TPD_G;
               obPpiWriteEn    <= '1'        after TPD_G;

               -- Determine which hold and FIFO bytes to update
               case headerDma.addr(2 downto 0) is 

                  -- Aligned address, no shift
                  when "000" =>
                     obPpiHold.data  <= obPpi.data  after TPD_G;
                     obPpiHold.valid <= obPPi.valid after TPD_G;

                  -- Shift by 1
                  when "001" =>
                     obPpiHold.data(55 downto  0) <= obPpi.data(63 downto 8) after TPD_G;
                     obPpiHold.valid(6 downto  0) <= obPpi.valid(7 downto 1) after TPD_G;

                     -- Don't write into FIFO register on first write
                     if obPpiFirst = '0' then
                        obPpiFifo.data(63 downto 56) <= obPpi.data(7 downto 0) after TPD_G;
                        obPpiFifo.valid(7)           <= obPpi.valid(0)         after TPD_G;
                     end if;

                     -- Force FIFO register EOF if hold register will be empty
                     if obPpi.valid(7 downto 1) = 0 then
                        obPpiHold.eof <= '0'       after TPD_G;
                        obPpiFifo.eof <= obPpi.eof after TPD_G;
                     end if;

                  -- Shift by 2
                  when "010" =>
                     obPpiHold.data(47 downto 0) <= obPpi.data(63 downto 16) after TPD_G;
                     obPpiHold.valid(5 downto 0) <= obPpi.valid(7 downto 2)  after TPD_G;

                     -- Don't write into FIFO register on first write
                     if obPpiFirst = '0' then
                        obPpiFifo.data(63 downto 48) <= obPpi.data(15 downto 0) after TPD_G;
                        obPpiFifo.valid(7 downto  6) <= obPpi.valid(1 downto 0) after TPD_G;
                     end if;

                     -- Force FIFO register EOF if hold register will be empty
                     if obPpi.valid(7 downto 2) = 0 then
                        obPpiHold.eof <= '0'       after TPD_G;
                        obPpiFifo.eof <= obPpi.eof after TPD_G;
                     end if;

                  -- Shift by 3
                  when "011" =>
                     obPpiHold.data(39 downto 0) <= obPpi.data(63 downto 24) after TPD_G;
                     obPpiHold.valid(4 downto 0) <= obPpi.valid(7 downto 3)  after TPD_G;

                     -- Don't write into FIFO register on first write
                     if obPpiFirst = '0' then
                        obPpiFifo.data(63 downto 40) <= obPpi.data(23 downto 0) after TPD_G;
                        obPpiFifo.valid(7 downto  5) <= obPpi.valid(2 downto 0) after TPD_G;
                     end if;

                     -- Force FIFO register EOF if hold register will be empty
                     if obPpi.valid(7 downto 3) = 0 then
                        obPpiHold.eof <= '0'       after TPD_G;
                        obPpiFifo.eof <= obPpi.eof after TPD_G;
                     end if;

                  -- Shift by 4
                  when "100" =>
                     obPpiHold.data(31 downto 0) <= obPpi.data(63 downto 32) after TPD_G;
                     obPpiHold.valid(3 downto 0) <= obPpi.valid(7 downto 4)  after TPD_G;

                     -- Don't write into FIFO register on first write
                     if obPpiFirst = '0' then
                        obPpiFifo.data(63 downto 32) <= obPpi.data(31 downto 0) after TPD_G;
                        obPpiFifo.valid(7 downto  4) <= obPpi.valid(3 downto 0) after TPD_G;
                     end if;

                     -- Force FIFO register EOF if hold register will be empty
                     if obPpi.valid(7 downto 4) = 0 then
                        obPpiHold.eof <= '0'       after TPD_G;
                        obPpiFifo.eof <= obPpi.eof after TPD_G;
                     end if;

                  -- Shift by 5
                  when "101" =>
                     obPpiHold.data(23 downto 0) <= obPpi.data(63 downto 40) after TPD_G;
                     obPpiHold.valid(2 downto 0) <= obPpi.valid(7 downto 5)  after TPD_G;

                     -- Don't write into FIFO register on first write
                     if obPpiFirst = '0' then
                        obPpiFifo.data(63 downto 24) <= obPpi.data(39 downto 0) after TPD_G;
                        obPpiFifo.valid(7 downto  3) <= obPpi.valid(4 downto 0) after TPD_G;
                     end if;

                     -- Force FIFO register EOF if hold register will be empty
                     if obPpi.valid(7 downto 5) = 0 then
                        obPpiHold.eof <= '0'       after TPD_G;
                        obPpiFifo.eof <= obPpi.eof after TPD_G;
                     end if;

                  -- Shift by 6
                  when "110" =>
                     obPpiHold.data(15 downto 0) <= obPpi.data(63 downto 48) after TPD_G;
                     obPpiHold.valid(1 downto 0) <= obPpi.valid(7 downto 6)  after TPD_G;

                     -- Don't write into FIFO register on first write
                     if obPpiFirst = '0' then
                        obPpiFifo.data(63 downto 16) <= obPpi.data(47 downto 0) after TPD_G;
                        obPpiFifo.valid(7 downto  2) <= obPpi.valid(5 downto 0) after TPD_G;
                     end if;

                     -- Force FIFO register EOF if hold register will be empty
                     if obPpi.valid(7 downto 6) = 0 then
                        obPpiHold.eof <= '0'       after TPD_G;
                        obPpiFifo.eof <= obPpi.eof after TPD_G;
                     end if;

                  -- Shift by 7
                  when "111" =>
                     obPpiHold.data(7  downto  0) <= obPpi.data(63 downto 56) after TPD_G;
                     obPpiHold.valid(0)           <= obPpi.valid(7)           after TPD_G;

                     -- Don't write into FIFO register on first write
                     if obPpiFirst = '0' then
                        obPpiFifo.data(63 downto  8) <= obPpi.data(55 downto 0) after TPD_G;
                        obPpiFifo.valid(7 downto  1) <= obPpi.valid(6 downto 0) after TPD_G;
                     end if;

                     -- Force FIFO register EOF if hold register will be empty
                     if obPpi.valid(7) = '0' then
                        obPpiHold.eof <= '0'       after TPD_G;
                        obPpiFifo.eof <= obPpi.eof after TPD_G;
                     end if;

                  when others =>
               end case;

            -- No write
            else
               obPpiWriteEn <= '0' after TPD_G;
            end if;
         end if;
      end if;
   end process;

   -- Control FIFO writes, write only when all bytes are valid or EOF is asserted
   obPpiFifoWr <= obPpiWriteEn when obPpiFifo.valid = "11111111" or obPpiFifo.eof = '1' else '0';
   obPpiEofWr  <= obPpiFifo.eof and obPpiFifoWr;

   -----------------------------------------
   -- Output FIFO
   -----------------------------------------
   -- Assert pfull when FIFO has less than 2
   -- bursts (16 locations per burst = 32)
   U_PpiFifo : entity work.FifoAsyncBuiltIn 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         XIL_DEVICE_G   => "7SERIES",
         SYNC_STAGES_G  => 3,
         DATA_WIDTH_G   => 72,
         ADDR_WIDTH_G   => 9,
         FULL_THRES_G   => (511-8),
         EMPTY_THRES_G  => 1
      ) port map (
         rst                => axiClkRstInt,
         wr_clk             => axiClk,
         wr_en              => obPpiFifoWr,
         din                => obPpiDin,
         wr_data_count      => open,
         wr_ack             => open,
         overflow           => open,
         prog_full          => ppiPFull,
         almost_full        => open,
         full               => open,
         not_full           => open,
         rd_clk             => ppiClk,
         rd_en              => ppiReadToFifo.read,
         dout               => obPpiDout,
         rd_data_count      => ppiReadCount,
         valid              => ppiReadFromFifo.valid,
         underflow          => open,
         prog_empty         => open,
         almost_empty       => open,
         empty              => open
      );

   -- Frame Counter
   U_EofFifo: entity work.FifoAsync 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         BRAM_EN_G      => true,
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         ALTERA_SYN_G   => false,
         ALTERA_RAM_G   => "M9K",
         SYNC_STAGES_G  => 3,
         DATA_WIDTH_G   => 1,
         ADDR_WIDTH_G   => 9,
         INIT_G         => "0",
         FULL_THRES_G   => (511-8),
         EMPTY_THRES_G  => 0
      ) port map (
         rst           => axiClkRstInt,
         wr_clk        => axiClk,
         wr_en         => obPpiEofWr,
         din           => "0",
         wr_data_count => open,
         wr_ack        => open,
         overflow      => open,
         prog_full     => open,
         almost_full   => open,
         full          => open,
         not_full      => open,
         rd_clk        => ppiClk,
         rd_en         => obPpiEofRd,
         dout          => open,
         rd_data_count => open,
         valid         => obPpiEofValid,
         underflow     => open,
         prog_empty    => open,
         almost_empty  => open,
         empty         => open
      );

   -- Read EOF
   obPpiEofRd <= ppiReadToFifo.read and obPpiDout(67);

   -- Input Data
   obPpiDin(71)           <= obPpiFifo.eoh; -- Temp, Ftype bit 3 in real system
   obPpiDin(70 downto 68) <= obPpiFifo.ftype(2 downto 0);
   obPpiDin(67)           <= obPpiFifo.eof;
   obPpiDin(66 downto 64) <= "111" when obPpiFifo.valid = "11111111" else
                             "110" when obPpiFifo.valid = "01111111" else
                             "101" when obPpiFifo.valid = "00111111" else
                             "100" when obPpiFifo.valid = "00011111" else
                             "011" when obPpiFifo.valid = "00001111" else
                             "010" when obPpiFifo.valid = "00000111" else
                             "001" when obPpiFifo.valid = "00000011" else
                             "000";
   obPpiDin(63 downto  0) <= obPpiFifo.data;

   -- Output Data
   ppiReadFromFifo.err    <= '0';
   ppiReadFromFifo.eoh    <= obPpiDout(71); -- Temp, Ftype bit 3 in real system
   ppiReadFromFifo.ftype  <= "0" & obPpiDout(70 downto 68);
   ppiReadFromFifo.eof    <= obPpiDout(67);
   ppiReadFromFifo.size   <= obPpiDout(66 downto  64);
   ppiReadFromFifo.data   <= obPpiDout(63 downto   0);

   -- Frame Ready
   process (ppiClk) begin
      if rising_edge(ppiClk) then
         if obPpiEofValid = '1' or (PPI_READY_THOLD_G > 0 and ppiReadCount > PPI_READY_THOLD_G) then
            ppiReadFromFifo.ready <= '1' after TPD_G;
         else
            ppiReadFromFifo.ready <= '0' after TPD_G;
         end if;
      end if;
   end process;


   -----------------------------------------
   -- Completion FIFO
   -----------------------------------------
   U_CompFifo : entity work.FifoSync
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         BRAM_EN_G      => false,  -- Use Dist Ram
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         ALTERA_RAM_G   => "M512",
         DATA_WIDTH_G   => 36,
         ADDR_WIDTH_G   => 4,
         FULL_THRES_G   => 15,
         EMPTY_THRES_G  => 1
      ) port map (
         rst                => axiClkRstInt,
         clk                => axiClk,
         wr_en              => currCompData.valid,
         din                => compFifoDin,
         data_count         => open,
         wr_ack             => open,
         overflow           => open,
         prog_full          => open,
         almost_full        => open,
         full               => open,
         not_full           => open,
         rd_en              => compToFifo.read,
         dout               => compFifoDout,
         valid              => compFromFifo.valid,
         underflow          => open,
         prog_empty         => open,
         almost_empty       => open,
         empty              => open
      );

   -- Completion FIFO input  
   compFifoDin(31 downto  0) <= currCompData.id;
   compFifoDin(35 downto 32) <= currCompData.index;

   -- Completion FIFO output  
   compFromFifo.id    <= compFifoDout(31 downto  0);
   compFromFifo.index <= compFifoDout(35 downto 32);

end architecture structure;

