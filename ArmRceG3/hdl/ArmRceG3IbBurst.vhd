-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Inbound Brust FIFOs
-- File          : ArmRceG3IbBurst.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Inbound Burst FIFO for PPI DMA Engines. This FIFO handles an inbound header
-- block, writing it to a defined destination address in cache line burst size
-- transactions. Bit 70 and 71 of the FIFO is used to mark the first and last 
-- entries which are to be written. After the entry is written the FIFO stalls 
-- and marks the entry as dirty. If enabled to the FIFO will then toggle to an 
-- alternate destination for the next incoming entry.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;

entity ArmRceG3IbBurst is
   port (

      -- Clock & reset
      axiClk                  : in  std_logic;

      -- AXI ACP Master
      axiAcpSlaveReset        : in  std_logic;
      axiAcpSlaveWriteFromArm : in  AxiWriteSlaveType;
      axiAcpSlaveWriteToArm   : out AxiWriteMasterType;

      -- Arbiter interface
      fifoReq                 : out std_logic;
      fifoGnt                 : in  std_logic;

      -- Memory Dirty Flags
      memDirty                : in  std_logic_vector(14 downto 0);
      memDirtySet             : out std_logic_vector(14 downto 0);

      -- Configuration
      fifoId                  : in  std_logic_vector(3 downto 0);
      fifoEnable              : in  std_logic;
      memToggleEn             : in  std_logic;
      memConfig               : in  Word32Array(1 downto 0);
      writeDmaCache           : in  std_logic_vector(3 downto 0);

      -- FIFO Interface
      writeFifoClk            : in  std_logic;
      writeFifoToFifo         : in  WriteFifoToFifoType;
      writeFifoFromFifo       : out WriteFifoFromFifoType;

      -- Debug
      debug                   : out std_logic_vector(127 downto 0)
   );
end ArmRceG3IbBurst;

architecture structure of ArmRceG3IbBurst is

   COMPONENT ArmAFifo72x512
      PORT (
         rst           : IN  STD_LOGIC;
         wr_clk        : IN  STD_LOGIC;
         rd_clk        : IN  STD_LOGIC;
         din           : IN  STD_LOGIC_VECTOR(71 DOWNTO 0);
         wr_en         : IN  STD_LOGIC;
         rd_en         : IN  STD_LOGIC;
         dout          : OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
         full          : OUT STD_LOGIC;
         empty         : OUT STD_LOGIC;
         valid         : OUT STD_LOGIC;
         wr_data_count : OUT STD_LOGIC_VECTOR(9 downto 0)
      );
   END COMPONENT;

   -- Local signals
   signal iAxiAcpSlaveWriteToArm   : AxiWriteMasterType;
   signal iWriteFifoFromFifo       : WriteFifoFromFifoType;
   signal iMemDirtySet             : std_logic_vector(14 downto 0);
   signal iFifoReq                 : std_logic;
   signal memSelect                : std_logic;
   signal burstDone                : std_logic;
   signal memAddress               : std_logic_vector(31 downto 0);
   signal memIndex                 : std_logic_vector(3  downto 0);
   signal memValid                 : std_logic;
   signal memReady                 : std_logic;
   signal fifoCount                : std_logic_vector(9 downto 0);
   signal fifoValid                : std_logic_vector(4 downto 0);
   signal fifoShift                : std_logic_vector(4 downto 0);
   signal pipeShift                : std_logic;
   signal fifoRd                   : std_logic;
   signal fifoRdFirst              : std_logic;
   signal fifoDout                 : Word72Array(4 downto 0);
   signal fifoReady                : std_logic;
   signal curInFrame               : std_logic;
   signal nxtInFrame               : std_logic;
   signal writeAddr                : std_logic_vector(31 downto 0);
   signal wvalid                   : std_logic;
   signal wlast                    : std_logic;
   signal awvalid                  : std_logic;
   signal curDone                  : std_logic;
   signal nxtDone                  : std_logic;
   signal ackCount                 : std_logic_vector(15 downto 0);
   signal writeCount               : std_logic_vector(15 downto 0);
   signal writeCountEn             : std_logic;

   -- States
   signal   curState   : std_logic_vector(2 downto 0);
   signal   nxtState   : std_logic_vector(2 downto 0);
   constant ST_IDLE    : std_logic_vector(2 downto 0) := "000";
   constant ST_WRITE0  : std_logic_vector(2 downto 0) := "001";
   constant ST_WRITE1  : std_logic_vector(2 downto 0) := "010";
   constant ST_WRITE2  : std_logic_vector(2 downto 0) := "011";
   constant ST_WRITE3  : std_logic_vector(2 downto 0) := "100";
   constant ST_CHECK   : std_logic_vector(2 downto 0) := "101";
   constant ST_WAIT    : std_logic_vector(2 downto 0) := "110";

begin

   -- Outputs
   axiAcpSlaveWriteToArm <= iAxiAcpSlaveWriteToArm;
   fifoReq               <= iFifoReq;
   writeFifoFromFifo     <= iWriteFifoFromFifo;
   memDirtySet           <= iMemDirtySet;

   -----------------------------------------
   -- Memory Toggle tracking
   -----------------------------------------
   
   process ( axiClk, axiAcpSlaveReset ) begin
      if axiAcpSlaveReset = '1' then
         memSelect  <= '0'           after TPD_G;
         memValid   <= '0'           after TPD_G;
         memAddress <= (others=>'0') after TPD_G;
         memIndex   <= (others=>'0') after TPD_G;
         memValid   <= '0'           after TPD_G;
         memReady   <= '1'           after TPD_G;
      elsif rising_edge(axiClk) then

         -- Toggle memory, clear valid and ready flags, force to mem 0 if toggle not enabled
         if burstDone = '1' then
            memValid  <= '0' after TPD_G;
            memReady  <= '0' after TPD_G;

            memSelect <= memToggleEn and (not memSelect) after TPD_G;

         else

            -- One clock delay for address and index to be valid
            memValid <= fifoEnable after TPD_G;

            -- Select memory and index location
            if memSelect = '0' then
               memAddress <= memConfig(0)(31 downto 4) & "0000" after TPD_G;
               memIndex   <= memConfig(0)(3  downto 0)          after TPD_G;
            else
               memAddress <= memConfig(1)(31 downto 4) & "0000" after TPD_G;
               memIndex   <= memConfig(1)(3  downto 0)          after TPD_G;
            end if;

            -- Memory ready is 2 clocks delayed
            memReady <= memValid and (not memDirty(conv_integer(memIndex))) after TPD_G;

         end if;
      end if;
   end process;

   -----------------------------------------
   -- FIFO
   -----------------------------------------

   U_Fifo: ArmAFifo72x512
      port map (
         rst           => axiAcpSlaveReset,
         wr_clk        => writeFifoClk,
         rd_clk        => axiClk,
         din           => writeFifoToFifo.data,
         wr_en         => writeFifoToFifo.write,
         rd_en         => fifoShift(4),
         dout          => fifoDout(4),
         full          => iWriteFifoFromFifo.full,
         empty         => open,
         valid         => fifoValid(4),
         wr_data_count => fifoCount
      );

   -- FIFO almost full
   process ( writeFifoClk, axiAcpSlaveReset ) begin
      if axiAcpSlaveReset = '1' then
         iWriteFifoFromFifo.almostFull <= '1' after TPD_G;
      elsif rising_edge(writeFifoClk) then
         if fifoCount > 500 or iWriteFifoFromFifo.full = '1' then
            iWriteFifoFromFifo.almostFull <= '1' after TPD_G;
         else
            iWriteFifoFromFifo.almostFull <= '0' after TPD_G;
         end if;
      end if;
   end process;

   -- Output pipeline, 4 extra registers after FIFO.
   -- Allows a cache line to be pulled from the FIFO and examined
   -- before the write access is started
   U_FifoPipeGen : for i in 0 to 3 generate
      process ( axiClk, axiAcpSlaveReset ) begin
         if axiAcpSlaveReset = '1' then
            fifoValid(i) <= '0' after TPD_G;
         elsif rising_edge(axiClk) then
            if fifoShift(i) = '1' then
               fifoValid(i) <= fifoValid(i+1) after TPD_G;
               fifoDout(i)  <= fifoDout(i+1)  after TPD_G;
            end if;
         end if;
      end process;

   end generate;

   -- Pipeline shift control
   fifoShift(4) <= fifoShift(3);
   fifoShift(3) <= fifoShift(2) or (fifoValid(4) and (not fifoValid(3)));
   fifoShift(2) <= fifoShift(1) or (fifoValid(3) and (not fifoValid(2)));
   fifoShift(1) <= fifoShift(0) or (fifoValid(2) and (not fifoValid(1)));
   fifoShift(0) <= pipeShift    or (fifoValid(1) and (not fifoValid(0)));
 
   -- Top level shift control. Don't shift if first flag is set and not the first read.
   pipeShift <= fifoRd and fifoValid(0) and (fifoRdFirst or (not fifoDout(0)(70)));

   -- FIFO is ready for read. Ready when 4 entries are valid or the last flag is set in one of the entries.
   fifoReady <= memReady when fifoValid(3 downto 0) = "1111" or
                              (fifoValid(2 downto 0) = "111" and fifoDout(2)(71) = '1') or
                              (fifoValid(1 downto 0) = "11"  and fifoDout(1)(71) = '1') or
                              (fifoValid(0)          = '1'   and fifoDout(0)(71) = '1') else '0';

   -----------------------------------------
   -- State machine
   -----------------------------------------

   -- AXI write channel outputs
   iAxiAcpSlaveWriteToArm.awaddr         <= writeAddr;
   iAxiAcpSlaveWriteToArm.awid           <= x"00" & fifoId;
   iAxiAcpSlaveWriteToArm.awlen          <= "0011";
   iAxiAcpSlaveWriteToArm.awsize         <= "011";
   iAxiAcpSlaveWriteToArm.awburst        <= "10";
   iAxiAcpSlaveWriteToArm.awcache        <= writeDmaCache;
   iAxiAcpSlaveWriteToArm.awuser         <= "00001";
   iAxiAcpSlaveWriteToArm.wdata          <= fifoDout(0)(63 downto 0);
   iAxiAcpSlaveWriteToArm.wid            <= x"00" & fifoId;
   iAxiAcpSlaveWriteToArm.wstrb          <= "11111111";
   iAxiAcpSlaveWriteToArm.bready         <= '1';
   iAxiAcpSlaveWriteToArm.awlock         <= "00";
   iAxiAcpSlaveWriteToArm.awprot         <= "000";
   iAxiAcpSlaveWriteToArm.awqos          <= "0000";
   iAxiAcpSlaveWriteToArm.wrissuecap1_en <= '0';

   -- Sync states
   process ( axiClk, axiAcpSlaveReset ) begin
      if axiAcpSlaveReset = '1' then
         iMemDirtySet                   <= (others=>'0') after TPD_G;
         curInFrame                     <= '0'           after TPD_G;
         curState                       <= ST_IDLE       after TPD_G;
         curDone                        <= '0'           after TPD_G;
         iAxiAcpSlaveWriteToArm.wvalid  <= '0'           after TPD_G;
         iAxiAcpSlaveWriteToArm.wlast   <= '0'           after TPD_G;
         iAxiAcpSlaveWriteToArm.awvalid <= '0'           after TPD_G;
         writeAddr                      <= (others=>'0') after TPD_G;
         writeCount                     <= (others=>'0') after TPD_G;
         ackCount                       <= (others=>'0') after TPD_G;
      elsif rising_edge(axiClk) then
         curInFrame                     <= nxtInFrame after TPD_G;
         curState                       <= nxtState   after TPD_G;
         curDone                        <= nxtDone    after TPD_G;
         iAxiAcpSlaveWriteToArm.wvalid  <= wvalid     after TPD_G;
         iAxiAcpSlaveWriteToArm.wlast   <= wlast      after TPD_G;
         iAxiAcpSlaveWriteToArm.awvalid <= awvalid    after TPD_G;

         -- Dirt flage set
         iMemDirtySet <= (others=>'0') after TPD_G;
         if burstDone = '1' then
            iMemDirtySet(conv_integer(memIndex)) <= '1' after TPD_G;
         end if;

         -- Write address tracking
         if curInFrame = '0' then
            writeAddr <= memAddress    after TPD_G;
         elsif writeCountEn = '1' then
            writeAddr <= writeAddr + 32 after TPD_G;
         end if;

         -- Write counter
         if curInFrame = '0' then
            writeCount <= (others=>'0') after TPD_G;
         elsif writeCountEn = '1' then
            writeCount <= writeCount + 1 after TPD_G;
         end if;

         -- Ack counter
         if curInFrame = '0' then
            ackCount <= (others=>'0') after TPD_G;
         elsif axiAcpSlaveWriteFromArm.bvalid = '1' and axiAcpSlaveWriteFromArm.bid = fifoId then
            ackCount <= ackCount + 1 after TPD_G;
         end if;

      end if;
   end process;

   -- ASync states
   process ( curState, curInFrame, fifoReady, fifoGnt, curDone, fifoDout, ackCount, writeCount,
             axiAcpSlaveWriteFromArm, iAxiAcpSlaveWriteToArm ) begin

      -- Init signals
      nxtState      <= curState;
      ififoReq      <= fifoReady;
      fifoRd        <= '0';
      fifoRdFirst   <= '0';
      nxtInFrame    <= curInFrame;
      nxtDone       <= curDone;
      burstDone     <= '0';
      wvalid        <= '0';
      wlast         <= '0';
      writeCountEn  <= '0';
      awvalid       <= iAxiAcpSlaveWriteToArm.awvalid;

      -- State machine
      case curState is 

         -- Idle
         when ST_IDLE =>

            -- Wait for ACK
            if fifoGnt = '1' then
               wvalid   <= '1';
               awvalid  <= '1';
               nxtState <= ST_WRITE0;
            end if;

         -- Write word 0
         when ST_WRITE0 =>
            ififoReq <= '1';
            wvalid   <= '1';

            -- EOF is set
            if fifoDout(0)(71) = '1' then
               nxtDone <= '1';
            end if;

            -- Clear address valid if not clear already
            if axiAcpSlaveWriteFromArm.awready = '1' then
               awvalid <= '0';
            end if;

            -- Data is acked, mark in frame, set first read if starting new frame
            if axiAcpSlaveWriteFromArm.wready = '1' then
               fifoRd      <= '1';
               fifoRdFirst <= not curInFrame;
               nxtInFrame  <= '1';
               nxtState    <= ST_WRITE1;
            end if;

         -- Write word 1
         when ST_WRITE1 =>
            ififoReq <= '1';
            wvalid   <= '1';

            -- EOF is set
            if fifoDout(0)(71) = '1' then
               nxtDone <= '1';
            end if;

            -- Clear address valid if not clear already
            if axiAcpSlaveWriteFromArm.awready = '1' then
               awvalid <= '0';
            end if;

            -- Data is acked
            if axiAcpSlaveWriteFromArm.wready = '1' then
               fifoRd   <= '1';
               nxtState <= ST_WRITE2;
            end if;

         -- Write word 2
         when ST_WRITE2 =>
            ififoReq <= '1';
            wvalid   <= '1';

            -- EOF is set
            if fifoDout(0)(71) = '1' then
               nxtDone <= '1';
            end if;

            -- Clear address valid if not clear already
            if axiAcpSlaveWriteFromArm.awready = '1' then
               awvalid <= '0';
            end if;

            -- Data is acked
            if axiAcpSlaveWriteFromArm.wready = '1' then
               wlast    <= '1';
               fifoRd   <= '1';
               nxtState <= ST_WRITE3;
            end if;

         -- Write word 3
         when ST_WRITE3 =>
            ififoReq <= '1';
            wlast    <= '1';

            -- EOF is set, catch SOF error
            if fifoDout(0)(71) = '1' or fifoDout(0)(70) = '1' then
               nxtDone <= '1';
            end if;

            -- Clear address valid if not clear already
            if axiAcpSlaveWriteFromArm.awready = '1' then
               awvalid <= '0';
            end if;

            -- Data is acked
            if axiAcpSlaveWriteFromArm.wready = '1' then
               wvalid   <= '0';
               fifoRd   <= '1';
               nxtState <= ST_CHECK;
            else
               wvalid  <= '1';
            end if;

         -- Check state, de-assert request
         when ST_CHECK =>
            ififoReq     <= '0';
            writeCountEn <= '1';
            nxtDone      <= '0';

            -- Transfer is done
            if curDone = '1' then
               nxtState <= ST_WAIT;
            else
               nxtState <= ST_IDLE;
            end if;

         -- Wait for writes to complete
         when ST_WAIT =>
            ififoReq <= '0';

            -- Writes have completed
            if ackCount = writeCount then
               nxtInFrame <= '0';
               burstDone  <= '1';
               nxtState   <= ST_IDLE;
            end if;

         when others =>
            nxtState <= ST_IDLE;
      end case;
   end process;

   ---------------------------
   -- Debug
   ---------------------------
   debug(127 downto 124) <= (others=>'0'); -- External
   debug(123 downto 121) <= (others=>'0');
   debug(120 downto 117) <= axiacpslavewritefromarm.bid(3 downto 0);
   debug(116 downto  85) <= writeAddr;
   debug(84)             <= iFifoReq;
   debug(83)             <= memSelect;
   debug(82)             <= burstDone;
   debug(81  downto  78) <= memIndex;
   debug(77)             <= memValid;
   debug(76)             <= memReady;
   debug(75  downto  71) <= fifoValid;
   debug(70  downto  66) <= fifoShift;
   debug(65)             <= fifoRd;
   debug(64)             <= fifoRdFirst;
   debug(63)             <= fifoReady;
   debug(62)             <= curInFrame;
   debug(61)             <= curDone;
   debug(60  downto  53) <= ackCount(7 downto 0);
   debug(52  downto  45) <= writeCount(7 downto 0);
   debug(44)             <= writeCountEn;
   debug(43)             <= iAxiAcpSlaveWriteToArm.wvalid;
   debug(42)             <= iAxiAcpSlaveWriteToArm.wlast;
   debug(41)             <= iAxiAcpSlaveWriteToArm.awvalid;
   debug(40)             <= axiAcpSlaveWriteFromArm.awready;
   debug(39)             <= axiAcpSlaveWriteFromArm.wready;
   debug(38)             <= axiacpslavewritefromarm.bvalid;
   debug(37)             <= fifoGnt;
   debug(36)             <= '0';
   debug(35  downto  21) <= memDirty;
   debug(20)             <= writeFifoToFifo.write;
   debug(19  downto   5) <= iMemDirtySet;
   debug(4)              <= fifoEnable;
   debug(3)              <= memToggleEn;
   debug(2   downto   0) <= curState;

end architecture structure;

