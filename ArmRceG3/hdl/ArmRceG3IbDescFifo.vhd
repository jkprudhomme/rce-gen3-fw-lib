-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Inbound Single Entry FIFO
-- File          : ArmRceG3IbDescFifo.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Inbound descriptor FIFO for PPI DMA Engines. 
-- After the entry is written the FIFO stalls and marks the entry as dirty. 
-- If enabled to the FIFO will then toggle to an alternate destination for 
-- the next incoming entry.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-- 06/14/2013: 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;

entity ArmRceG3IbDescFifo is
   generic
      UseAsyncFifo : boolean := true
   port (

      -- Clock & reset
      axiClk                  : in  std_logic;

      -- AXI ACP Master
      axiClkRst               : in  std_logic;
      axiAcpSlaveWriteFromArm : in  AxiWriteSlaveType;
      axiAcpSlaveWriteToArm   : out AxiWriteMasterType;

      -- Arbiter interface
      fifoReq                 : out std_logic;
      fifoGnt                 : in  std_logic;

      -- Memory Dirty Flags
      memDirty                : in  std_logic_vector(16 downto 0);
      memDirtySet             : out std_logic_vector(16 downto 0);

      -- DMA ID Busy Bus
      writeDmaBusyOut         : out std_logic_vector(7 downto 0);
      writeDmaBusyIn          : in  std_logic_vector(7 downto 0);

      -- Configuration
      fifoEnable              : in  std_logic;
      writeDmaId              : in  std_logic_vector(2 downto 0);
      writeDmaCache           : in  std_logic_vector(3 downto 0);
      memToggleEn             : in  std_logic;
      memConfig               : in  Word5Array(1 downto 0);
      memBaseAddress          : in  std_logic_vector(31 downto 8);

      -- FIFO Interface
      writeFifoClk            : in  std_logic;
      writeFifoToFifo         : in  WriteFifoToFifoType;
      writeFifoFromFifo       : out WriteFifoFromFifoType;

      -- Debug
      debug                   : out std_logic_vector(127 downto 0)
   );
end ArmRceG3IbDescFifo;

architecture structure of ArmRceG3IbDescFifo is

   COMPONENT ArmAFifo36x512
      PORT (
         rst           : IN  STD_LOGIC;
         wr_clk        : IN  STD_LOGIC;
         rd_clk        : IN  STD_LOGIC;
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
   signal iAxiAcpSlaveWriteToArm   : AxiWriteMasterType;
   signal iWriteFifoFromFifo       : WriteFifoFromFifoType;
   signal iMemDirtySet             : std_logic_vector(16 downto 0);
   signal iFifoReq                 : std_logic;
   signal memSelect                : std_logic;
   signal burstDone                : std_logic;
   signal memAddress               : std_logic_vector(31 downto 0);
   signal memIndex                 : std_logic_vector(4  downto 0);
   signal memValid                 : std_logic;
   signal memReady                 : std_logic;
   signal fifoCount                : std_logic_vector(9 downto 0);
   signal fifoValid                : std_logic_vector(1 downto 0);
   signal fifoShift                : std_logic_vector(1 downto 0);
   signal pipeShift                : std_logic;
   signal fifoRd                   : std_logic;
   signal fifoRdFirst              : std_logic;
   signal fifoDout                 : Word36Array(1 downto 0);
   signal fifoReady                : std_logic;
   signal wvalid                   : std_logic;
   signal awvalid                  : std_logic;
   signal curDone                  : std_logic;
   signal nxtDone                  : std_logic;
   signal iwriteDmaBusyOut         : std_logic_vector(7 downto 0);
   signal nwriteDmaBusyOut         : std_logic_vector(7 downto 0);

   -- States
   signal   curState   : std_logic_vector(1 downto 0);
   signal   nxtState   : std_logic_vector(1 downto 0);
   constant ST_IDLE    : std_logic_vector(1 downto 0) := "00";
   constant ST_WRITE   : std_logic_vector(1 downto 0) := "01";
   constant ST_WAIT    : std_logic_vector(1 downto 0) := "10";

begin

   -- Outputs
   axiAcpSlaveWriteToArm <= iAxiAcpSlaveWriteToArm;
   fifoReq               <= iFifoReq;
   writeFifoFromFifo     <= iWriteFifoFromFifo;
   memDirtySet           <= iMemDirtySet;
   writeDmaBusyOut       <= iwriteDmaBusyOut;

   -----------------------------------------
   -- Memory Toggle tracking
   -----------------------------------------
   
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
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
               memAddress <= memBaseAddress & memConfig(0) & "000" after TPD_G;
               memIndex   <= memConfig(0)                          after TPD_G;
            else
               memAddress <= memBaseAddress & memConfig(1) & "000" after TPD_G;
               memIndex   <= memConfig(0)                          after TPD_G;
            end if;

            -- Memory ready is 2 clocks delayed
            memReady <= memValid and (not memDirty(conv_integer(memIndex))) after TPD_G;

         end if;
      end if;
   end process;

   -----------------------------------------
   -- FIFO
   -----------------------------------------
   U_FifoGen: if UseAsyncFifo = true generate

      U_AsyncFifo: ArmAFifo36x512
         port map (
            rst           => axiClkRst,
            wr_clk        => writeFifoClk,
            rd_clk        => axiClk,
            din           => writeFifoToFifo.data(35 downto 0),
            wr_en         => writeFifoToFifo.write,
            rd_en         => fifoShift(1),
            dout          => fifoDout(1),
            full          => iWriteFifoFromFifo.full,
            empty         => open,
            valid         => fifoValid(1),
            wr_data_count => fifoCount
         );

   else generate

      U_SyncFifo: ArmFifo36x512
         port map (
            srst          => axiClkRst,
            clk           => axiClk,
            din           => writeFifoToFifo.data(35 downto 0),
            wr_en         => writeFifoToFifo.write,
            rd_en         => fifoShift(1),
            dout          => fifoDout(1),
            full          => iWriteFifoFromFifo.full,
            empty         => open,
            valid         => fifoValid(1),
            wr_data_count => fifoCount
         );

   end generate;


   -- FIFO almost full
   process ( writeFifoClk, axiClkRst ) begin
      if axiClkRst = '1' then
         iWriteFifoFromFifo.almostFull <= '1' after TPD_G;
      elsif rising_edge(writeFifoClk) then
         if fifoCount > 500 or iWriteFifoFromFifo.full = '1' then
            iWriteFifoFromFifo.almostFull <= '1' after TPD_G;
         else
            iWriteFifoFromFifo.almostFull <= '0' after TPD_G;
         end if;
      end if;
   end process;

   -- Output pipeline, 1 extra register after FIFO.
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         fifoValid(0) <= '0' after TPD_G;
      elsif rising_edge(axiClk) then
         if fifoShift(0) = '1' then
            fifoValid(0) <= fifoValid(1) after TPD_G;
            fifoDout(0)  <= fifoDout(1)  after TPD_G;
         end if;
      end if;
   end process;

   -- Pipeline shift control
   fifoShift(1) <= fifoShift(0);
   fifoShift(0) <= pipeShift    or (fifoValid(1) and (not fifoValid(0)));
    
   -- Top level shift control.
   pipeShift <= fifoRd and fifoValid(0);
 
   -- FIFO is ready for read, write channel is not busy
   fifoReady <= memReady and (not writeDmaBusyIn(conv_integer(writeDmaId))) and fifoValid(0);

   -----------------------------------------
   -- State machine
   -----------------------------------------

   -- AXI write channel outputs
   iAxiAcpSlaveWriteToArm.awaddr         <= memAddress;
   iAxiAcpSlaveWriteToArm.awid           <= x"00" & '0' & writeDmaId;
   iAxiAcpSlaveWriteToArm.awlen          <= "0000";
   iAxiAcpSlaveWriteToArm.awsize         <= "011";
   iAxiAcpSlaveWriteToArm.wlast          <= '1';
   iAxiAcpSlaveWriteToArm.awburst        <= "10";
   iAxiAcpSlaveWriteToArm.awcache        <= writeDmaCache;
   iAxiAcpSlaveWriteToArm.awuser         <= "00001";
   iAxiAcpSlaveWriteToArm.wdata          <= x"0000000" & fifoDout(0);
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
         iMemDirtySet                   <= (others=>'0') after TPD_G;
         curState                       <= ST_IDLE       after TPD_G;
         iAxiAcpSlaveWriteToArm.wvalid  <= '0'           after TPD_G;
         iAxiAcpSlaveWriteToArm.awvalid <= '0'           after TPD_G;
         iwriteDmaBusyOut               <= (others=>'0') after TPD_G;
      elsif rising_edge(axiClk) then
         curState                       <= nxtState         after TPD_G;
         iAxiAcpSlaveWriteToArm.wvalid  <= wvalid           after TPD_G;
         iAxiAcpSlaveWriteToArm.awvalid <= awvalid          after TPD_G;
         iwriteDmaBusyOut               <= nwriteDmaBusyOut after TPD_G;

         -- Dirt flage set
         iMemDirtySet <= (others=>'0') after TPD_G;
         if burstDone = '1' then
            iMemDirtySet(conv_integer(memIndex)) <= '1' after TPD_G;
         end if;

      end if;
   end process;

   -- ASync states
   process ( curState, fifoReady, fifoGnt, fifoReady, writeDmaId, nwriteDmaBusyOut,
             axiAcpSlaveWriteFromArm, iAxiAcpSlaveWriteToArm ) begin

      -- Init signals
      nxtState         <= curState;
      ififoReq         <= fifoReady;
      fifoRd           <= '0';
      burstDone        <= '0';
      wvalid           <= '0';
      awvalid          <= iAxiAcpSlaveWriteToArm.awvalid;
      nwriteDmaBusyOut <= (others=>'0');

      -- State machine
      case curState is 

         -- Idle
         when ST_IDLE =>

            -- Wait for ACK
            if fifoGnt = '1' then
               wvalid   <= '1';
               awvalid  <= '1';
               nxtState <= ST_WRITE;
            end if;

         -- Write word 0
         when ST_WRITE =>
            ififoReq                                   <= '1';
            wvalid                                     <= '1';
            nwriteDmaBusyOut(conv_integer(writeDmaId)) <= '1';

            -- Clear address valid if not clear already
            if axiAcpSlaveWriteFromArm.awready = '1' then
               awvalid <= '0';
            end if;

            -- Data is acked, mark in frame, set first read if starting new frame
            if axiAcpSlaveWriteFromArm.wready = '1' then
               wvalid      <= '0';
               fifoRd      <= '1';
               nxtState    <= ST_WAIT;
            end if;

         -- Wait for write to complete
         when ST_WAIT =>
            ififoReq <= '0';

            -- Writes have completed
            if axiAcpSlaveWriteFromArm.bvalid = '1' and axiAcpSlaveWriteFromArm.bid(2 downto 0) = writeDmaId then
               burstDone <= '1';
               nxtState  <= ST_IDLE;
            else
               nwriteDmaBusyOut(conv_integer(writeDmaId)) <= '1';
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
   debug(120 downto 117) <= axiAcpSlaveWriteFromArm.bid(3 downto 0);
   debug(116 downto  85) <= memAddress;
   debug(84)             <= iFifoReq;
   debug(83)             <= memSelect;
   debug(82)             <= burstDone;
   debug(81  downto  78) <= memIndex(3 downto 0);
   debug(77)             <= memValid;
   debug(76)             <= memReady;
   debug(75  downto  73) <= (others=>'0');
   debug(72  downto  71) <= fifoValid;
   debug(70  downto  68) <= (others=>'0');
   debug(67  downto  66) <= fifoShift;
   debug(65)             <= fifoRd;
   debug(64)             <= '0';
   debug(63)             <= fifoReady;
   debug(62  downto  55) <= (others=>'0');
   debug(54  downto  52) <= writeDmaId;
   debug(51  downto  44) <= writeDmaBusyIn;
   debug(43)             <= iAxiAcpSlaveWriteToArm.wvalid;
   debug(42)             <= iAxiAcpSlaveWriteToArm.wlast;
   debug(41)             <= iAxiAcpSlaveWriteToArm.awvalid;
   debug(40)             <= axiAcpSlaveWriteFromArm.awready;
   debug(39)             <= axiAcpSlaveWriteFromArm.wready;
   debug(38)             <= axiAcpSlaveWriteFromArm.bvalid;
   debug(37)             <= fifoGnt;
   debug(36  downto  20) <= memDirty;
   debug(19  downto   3) <= iMemDirtySet;
   debug(2)              <= '0';
   debug(1   downto   0) <= curState;

end architecture structure;

