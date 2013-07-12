-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Outbound Header FIFOs
-- File          : ArmRceG3ObHeaderFifo.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 07/09/2013
-------------------------------------------------------------------------------
-- Description:
-- Outbound header FIFO for PPI DMA Engines.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 07/09/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;

entity ArmRceG3ObHeaderFifo is
   port (

      -- Clock & reset
      axiClk                  : in  std_logic;

      -- AXI ACP Master
      axiClkRst               : in  std_logic;
      axiAcpSlaveReadFromArm  : in  AxiReadSlaveType;
      axiAcpSlaveReadToArm    : out AxiReadMasterType;

      -- Arbiter interface
      fifoReq                 : out std_logic;
      fifoGnt                 : in  std_logic;

      -- Transmit Descriptor write
      descPtrWrite            : in  WriteFifoToFifoType;

      -- Free list FIFO (finished descriptors)
      freePtrWrite            : out WriteFifoToFifoType;

      -- Configuration
      dmaBaseAddress          : in  std_logic_vector(31 downto 18);
      fifoEnable              : in  std_logic;
      readDmaId               : in  std_logic_vector(2 downto 0);
      readDmaCache            : in  std_logic_vector(3 downto 0);

      -- FIFO Interface
      readFifoClk             : in  std_logic;
      readFifoToFifo          : in  ReadFifoToFifoType;
      readFifoFromFifo        : out ReadFifoFromFifoType;

      -- Debug
      debug                   : out std_logic_vector(127 downto 0)
   );
end ArmRceG3ObHeaderFifo;

architecture structure of ArmRceG3ObHeaderFifo is

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

   COMPONENT ArmFifo36x512
      PORT (
         srst          : IN  STD_LOGIC;
         clk           : IN  STD_LOGIC;
         din           : IN  STD_LOGIC_VECTOR(35 DOWNTO 0);
         wr_en         : IN  STD_LOGIC;
         rd_en         : IN  STD_LOGIC;
         dout          : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
         full          : OUT STD_LOGIC;
         empty         : OUT STD_LOGIC;
         valid         : OUT STD_LOGIC;
         wr_data_count : OUT STD_LOGIC_VECTOR(9 downto 0)
      );
   END COMPONENT;

   -- Local signals
   signal descPtrRdData            : std_logic_vector(35 downto 0);
   signal descPtrValid             : std_logic;
   signal iAxiAcpSlaveReadToArm    : AxiReadMasterType;
   signal iReadFifoFromFifo        : ReadFifoFromFifoType;
   signal iFifoReq                 : std_logic;
   signal burstDone                : std_logic;
   signal fifoCount                : std_logic_vector(9 downto 0);
   signal fifoFull                 : std_logic;
   signal fifoWrEn                 : std_logic;
   signal fifoDin                  : std_logic_vector(71 downto 0);
   --signal curInFrame               : std_logic;
   --signal nxtInFrame               : std_logic;
   signal readAddr                 : std_logic_vector(31 downto 0);
   --signal wvalid                   : std_logic;
   --signal wlast                    : std_logic;
   --signal awvalid                  : std_logic;
   --signal curDone                  : std_logic;
   --signal nxtDone                  : std_logic;
   --signal ackCount                 : std_logic_vector(15 downto 0);
   --signal writeCount               : std_logic_vector(15 downto 0);
   --signal writeCountEn             : std_logic;

   -- States
   --signal   curState   : std_logic_vector(2 downto 0);
   --signal   nxtState   : std_logic_vector(2 downto 0);
   --constant ST_IDLE    : std_logic_vector(2 downto 0) := "000";
   --constant ST_WRITE0  : std_logic_vector(2 downto 0) := "001";
   --constant ST_WRITE1  : std_logic_vector(2 downto 0) := "010";
   --constant ST_WRITE2  : std_logic_vector(2 downto 0) := "011";
   --constant ST_WRITE3  : std_logic_vector(2 downto 0) := "100";
   --constant ST_CHECK   : std_logic_vector(2 downto 0) := "101";
   --constant ST_WAIT    : std_logic_vector(2 downto 0) := "110";

begin

   -- Outputs
   axiAcpSlaveReadToArm <= iAxiAcpSlaveReadToArm;
   fifoReq              <= iFifoReq;
   readFifoFromFifo     <= iReadFifoFromFifo;

   -----------------------------------------
   -- Transmit descriptor FIFO
   -----------------------------------------

   U_PtrFifo: ArmFifo36x512
      port map (
         srst          => axiClkRst,
         clk           => axiClk,
         din           => descPtrWrite.data(35 downto 0),
         wr_en         => descPtrWrite.write,
         rd_en         => burstDone,
         dout          => descPtrRdData,
         full          => open,
         empty         => open,
         valid         => descPtrValid,
         wr_data_count => open
      );



   -----------------------------------------
   -- State machine
   -----------------------------------------

   -- AXI write channel outputs
   iAxiAcpSlaveWriteToArm.awaddr         <= writeAddr;
   iAxiAcpSlaveWriteToArm.awid           <= x"00" & '0' & writeDmaId;
   iAxiAcpSlaveWriteToArm.awlen          <= "0011";
   iAxiAcpSlaveWriteToArm.awsize         <= "011";
   iAxiAcpSlaveWriteToArm.awburst        <= "10";
   iAxiAcpSlaveWriteToArm.awcache        <= writeDmaCache;
   iAxiAcpSlaveWriteToArm.awuser         <= "00001";
   iAxiAcpSlaveWriteToArm.wdata          <= fifoDout(0)(63 downto 0);
   iAxiAcpSlaveWriteToArm.wid            <= x"00" & '0' & writeDmaId;
   iAxiAcpSlaveWriteToArm.wstrb          <= "11111111";
   iAxiAcpSlaveWriteToArm.bready         <= '1';
   iAxiAcpSlaveWriteToArm.awlock         <= "00";
   iAxiAcpSlaveWriteToArm.awprot         <= "000";
   iAxiAcpSlaveWriteToArm.awqos          <= "0000";
   iAxiAcpSlaveWriteToArm.wrissuecap1_en <= '0';

   -- Sync states
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         curInFrame                     <= '0'           after TPD_G;
         curState                       <= ST_IDLE       after TPD_G;
         curDone                        <= '0'           after TPD_G;
         iAxiAcpSlaveWriteToArm.wvalid  <= '0'           after TPD_G;
         iAxiAcpSlaveWriteToArm.wlast   <= '0'           after TPD_G;
         iAxiAcpSlaveWriteToArm.awvalid <= '0'           after TPD_G;
         writeAddr                      <= (others=>'0') after TPD_G;
         writeCount                     <= (others=>'0') after TPD_G;
         ackCount                       <= (others=>'0') after TPD_G;
         donePtrWrite.write             <= '0'           after TPD_G;
         donePtrWrite.data              <= (others=>'0') after TPD_G;
      elsif rising_edge(axiClk) then
         curInFrame                     <= nxtInFrame   after TPD_G;
         curState                       <= nxtState     after TPD_G;
         curDone                        <= nxtDone      after TPD_G;
         iAxiAcpSlaveWriteToArm.wvalid  <= wvalid       after TPD_G;
         iAxiAcpSlaveWriteToArm.wlast   <= wlast        after TPD_G;
         iAxiAcpSlaveWriteToArm.awvalid <= awvalid      after TPD_G;
         donePtrWrite.write             <= burstDone    after TPD_G;
         donePtrWrite.data(35 downto 0) <= memPtrRdData after TPD_G;

         -- Write address tracking
         if curInFrame = '0' then
            writeAddr <=  dmaBaseAddress(31 downto 18) & memPtrRdData(17 downto 0) after TPD_G;
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
         elsif axiAcpSlaveWriteFromArm.bvalid = '1' and axiAcpSlaveWriteFromArm.bid(2 downto 0) = writeDmaId then
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


   -----------------------------------------
   -- Header FIFO
   -----------------------------------------

   U_Fifo: ArmAFifo72x512
      port map (
         rst           => axiClkRst,
         wr_clk        => axiClk,
         rd_clk        => readFifoClk,
         din           => fifoDin,
         wr_en         => fifoWrEn,
         rd_en         => readFifoToFifo.read,
         dout          => readFifoFromFifo.data,
         full          => fifoFull,
         empty         => open,
         valid         => readFifoFromFifo.valid,
         wr_data_count => fifoCount
      );

   -- FIFO almost full
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         fifoAFull <= '1' after TPD_G;
      elsif rising_edge(axiClk) then
         if fifoCount > 500 or fifoFull = '1' then
            fifoAFull <= '1' after TPD_G;
         else
            fifoAFull <= '0' after TPD_G;
         end if;
      end if;
   end process;

   ---------------------------
   -- Debug
   ---------------------------
   debug(127 downto 124) <= (others=>'0'); -- External
   debug(123 downto 121) <= (others=>'0');
   debug(120 downto 117) <= axiacpslavewritefromarm.bid(3 downto 0);
   debug(116 downto  85) <= writeAddr;
   debug(84)             <= iFifoReq;
   debug(83)             <= memPtrValid;
   debug(82)             <= burstDone;
   debug(81  downto  77) <= (others=>'0');
   debug(76)             <= pipeShift;
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
   debug(36  downto   3) <= (others=>'0');
   debug(2   downto   0) <= curState;

end architecture structure;

