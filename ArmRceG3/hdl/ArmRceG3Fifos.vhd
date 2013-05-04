
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;

entity ArmRceG3Fifos is
   port (

      -- Clocks & Reset
      axiClk                  : in  std_logic;
      axiClkRst               : in  std_logic;

      -- AXI ACP Master
      axiAcpSlaveWriteFromArm : in  AxiWriteSlaveType;
      axiAcpSlaveWriteToArm   : out AxiWriteMasterType;

      -- Local Bus
      localBusMaster          : in  LocalBusMasterType;
      localBusSlave           : out LocalBusSlaveType;

      -- Interrupt
      interrupt               : out std_logic;

      -- Debug
      debug                   : out std_logic_vector(127 downto 0)
   );
end ArmRceG3Fifos;

architecture structure of ArmRceG3Fifos is

   COMPONENT ArmFifo36x512
      PORT (
         clk   : IN  STD_LOGIC;
         srst  : IN  STD_LOGIC;
         din   : IN  STD_LOGIC_VECTOR(35 DOWNTO 0);
         wr_en : IN  STD_LOGIC;
         rd_en : IN  STD_LOGIC;
         dout  : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
         full  : OUT STD_LOGIC;
         empty : OUT STD_LOGIC;
         valid : OUT STD_LOGIC
      );
   END COMPONENT;

   -- Local signals
   signal writeDone             : std_logic;
   signal writeError            : std_logic;
   signal writeStart            : std_logic;
   signal writeAddr             : std_logic_vector(31 downto 0);
   signal writeData             : std_logic_vector(63 downto 0);
   signal intAcpSlaveWriteToArm : AxiWriteMasterType;
   signal intLocalBusSlave      : LocalBusSlaveType;
   signal dmaAddress            : Word32Array(7 downto 0);
   signal fifoDin               : std_logic_vector(35 downto 0);
   signal fifoWr                : std_logic_vector(7  downto 0);
   signal fifoWrEn              : std_logic;
   signal fifoWrSel             : std_logic_vector(2  downto 0);
   signal fifoRd                : std_logic_vector(7  downto 0);
   signal fifoRdEn              : std_logic;
   signal fifoDout              : Word36Array(7 downto 0);
   signal fifoValid             : std_logic_vector(7  downto 0);
   signal dirtyFlag             : std_logic_vector(7  downto 0);
   signal dirtyClearEn          : std_logic;
   signal dirtyClearSel         : std_logic_vector(2  downto 0);
   signal curChannel            : std_logic_vector(2  downto 0);
   signal nxtChannel            : std_logic_vector(2  downto 0);
   signal arbChannel            : std_logic_vector(2  downto 0);
   signal arbValid              : std_logic;
   signal writeDmaCache         : std_logic_vector(3  downto 0);
   signal fifoEnable            : std_logic_vector(7  downto 0);
   signal intEnable             : std_logic_vector(7  downto 0);
   signal iinterrupt            : std_logic;

   -- States
   signal   curState   : std_logic_vector(1 downto 0);
   signal   nxtState   : std_logic_vector(1 downto 0);
   constant ST_IDLE    : std_logic_vector(1 downto 0) := "00";
   constant ST_WRITE   : std_logic_vector(1 downto 0) := "01";
   constant ST_WAIT    : std_logic_vector(1 downto 0) := "10";
   constant ST_READ    : std_logic_vector(1 downto 0) := "11";

begin

   -- Outputs
   axiAcpSlaveWriteToArm   <= intAcpSlaveWriteToArm;
   localBusSlave           <= intLocalBusSlave;

   --------------------------------------------
   -- Registers: 0x8800_0000 - 0x8BFF_FFFF
   --------------------------------------------

   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         intLocalBusSlave <= LocalBusSlaveInit       after TPD_G;
         dmaAddress       <= (others=>(others=>'0')) after TPD_G;
         fifoWrEn         <= '0'                     after TPD_G;
         fifoWrSel        <= (others=>'0')           after TPD_G;
         fifoDin          <= (others=>'0')           after TPD_G;
         dirtyClearEn     <= '0'                     after TPD_G;
         dirtyClearSel    <= (others=>'0')           after TPD_G;
         writeDmaCache    <= (others=>'0')           after TPD_G;
         fifoEnable       <= (others=>'0')           after TPD_G;
         intEnable        <= (others=>'0')           after TPD_G;
      elsif rising_edge(axiClk) then
         intLocalBusSlave.readValid <= localBusMaster.readEnable after TPD_G;

         -- DMA Base Register Configuration - 0x88000000 - 0x8800FFFF
         if localBusMaster.addr(23 downto 16) = x"00" then
            if localBusMaster.writeEnable = '1' then
               dmaAddress(conv_integer(localBusMaster.addr(4 downto 2))) <= localBusMaster.writeData after TPD_G;
            end if;
            intLocalBusSlave.readData <= dmaAddress(conv_integer(localBusMaster.addr(4 downto 2))) after TPD_G;

         -- FIFO writes - 0x88010000 - 0x8801FFFF
         elsif localBusMaster.addr(23 downto 16) = x"01" then
            fifoWrEn                  <= localBusMaster.writeEnable      after TPD_G;
            fifoWrSel                 <= localBusMaster.addr(8 downto 6) after TPD_G;
            fifoDin(35 downto 32)     <= localBusMaster.addr(5 downto 2) after TPD_G;
            fifoDin(31 downto  0)     <= localBusMaster.writeData        after TPD_G;
            intLocalBusSlave.readData <= x"deadbeef"                     after TPD_G;

         -- FIFO dirty flags clear - 0x88020000 - 0x8802FFFF
         elsif localBusMaster.addr(23 downto 16) = x"02" then
            dirtyClearEn              <= localBusMaster.writeEnable      after TPD_G;
            dirtyClearSel             <= localBusMaster.addr(4 downto 2) after TPD_G;
            intLocalBusSlave.readData <= x"deadbeef"                     after TPD_G;

         -- Write DMA Config 0x88030000
         elsif localBusMaster.addr(23 downto 0) = x"030000" then
            if localBusMaster.writeEnable = '1' then
               writeDmaCache <= localBusMaster.writeData(3 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"0000000" & writeDmaCache after TPD_G;

         -- FIFO Enable 0x88030004
         elsif localBusMaster.addr(23 downto 0) = x"030004" then
            if localBusMaster.writeEnable = '1' then
               fifoEnable <= localBusMaster.writeData(7 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"000000" & fifoEnable after TPD_G;

         -- Dirty status 0x8803000C
         elsif localBusMaster.addr(23 downto 0) = x"03000C" then
            intLocalBusSlave.readData <= x"000000" & dirtyFlag after TPD_G;

         -- Int Enable 0x88030010
         elsif localBusMaster.addr(23 downto 0) = x"030010" then
            if localBusMaster.writeEnable = '1' then
               intEnable <= localBusMaster.writeData(7 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"000000" & intEnable after TPD_G;

         -- Unsupported
         else
            fifoWrEn                   <= '0'         after TPD_G;
            dirtyClearEn               <= '0'         after TPD_G;
            intLocalBusSlave.readData  <= x"deadbeef" after TPD_G;
         end if;

      end if;  
   end process;         

   -----------------------------------------
   -- FIFO State Tracking
   -----------------------------------------

   U_DirtyGen: for i in 0 to 7 generate
      process ( axiClk, axiClkRst ) begin
         if axiClkRst = '1' then
            dirtyFlag(i) <= '0' after TPD_G;
         elsif rising_edge(axiClk) then
            if dirtyClearEn = '1' and dirtyClearSel = i then
               dirtyFlag(i) <= '0' after TPD_G;
            elsif fifoRdEn = '1' and curChannel = i then
               dirtyFlag(i) <= '1' after TPD_G;
            end if;
         end if;
      end process;
   end generate;

   iinterrupt <= dirtyFlag(0) and intEnable(0);
   interrupt <= iinterrupt;

   -----------------------------------------
   -- State machine
   -----------------------------------------

   -- Sync states
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         curState   <= ST_IDLE       after TPD_G;
         curChannel <= (others=>'0') after TPD_G;
      elsif rising_edge(axiClk) then
         curState   <= nxtState    after TPD_G;
         curChannel <= nxtChannel after TPD_G;
      end if;
   end process;

   -- Write address & data
   writeAddr <= dmaAddress(conv_integer(curChannel));
   writeData <= x"8000000" & fifoDout(conv_integer(curChannel));

   -- ASync states
   process ( curState, writeDone, curChannel, arbValid, arbChannel ) begin

      -- Init signals
      nxtState    <= curState;
      writeStart  <= '0';
      fifoRdEn    <= '0';
      nxtChannel  <= curChannel;

      -- State machine
      case curState is 

         -- Idle wait for non dirty valid channel
         when ST_IDLE =>

            -- New arb channel
            if arbValid = '1' then
               nxtChannel <= arbChannel;
               nxtState   <= ST_WRITE;
            end if;

         -- Assert write read from FIFO
         when ST_WRITE =>
            writeStart <= '1';
            nxtState   <= ST_WAIT;

         -- Wait for write completion
         when ST_WAIT =>
            if writeDone = '1' then
               nxtState <= ST_READ;
            end if;

         -- Read FIFO, Set Dirty Flag
         when ST_READ =>
            fifoRdEn <= '1';
            nxtState <= ST_IDLE;

         when others =>
            nxtState <= ST_IDLE;
      end case;
   end process;

   -----------------------------------------
   -- Arbitration 
   -----------------------------------------
 
   -- One channel for now 
   arbValid   <= fifoValid(0) and (not dirtyFlag(0)) and fifoEnable(0);
   arbChannel <= "000";
   --signal fifoValid (7 downto 0)
   --signal curChannel            : std_logic_vector(2  downto 0);
  

   -----------------------------------------
   -- FIFOs
   -----------------------------------------
   U_GenFifo: for i in 0 to 7 generate
      U_Fifo: ArmFifo36x512
         port map (
            clk   => axiClk,
            srst  => axiClkRst,
            din   => fifoDin,
            wr_en => fifoWr(i),
            rd_en => fifoRd(i),
            dout  => fifoDout(i),
            full  => open,
            empty => open,
            valid => fifoValid(i)
         );

      fifoWr(i) <= fifoWrEn when fifoWrSel  = i else '0';
      fifoRd(i) <= fifoRdEn when curChannel = i else '0';
   end generate;

   -----------------------------------------
   -- Write Engine
   -----------------------------------------

   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         intAcpSlaveWriteToArm <= AxiWriteMasterInit after TPD_G;
         writeDone             <= '0'                after TPD_G;
         writeError            <= '0'                after TPD_G;
      elsif rising_edge(axiClk) then
         intAcpSlaveWriteToArm.bready <= '1' after TPD_G;

         -- Start request
         if writeStart = '1' then
            intAcpSlaveWriteToArm.awvalid  <= '1'           after TPD_G;
            intAcpSlaveWriteToArm.awaddr   <= writeAddr     after TPD_G;
            intAcpSlaveWriteToArm.awlen    <= "0000"        after TPD_G;
            intAcpSlaveWriteToArm.awsize   <= "011"         after TPD_G;
            intAcpSlaveWriteToArm.awburst  <= "00"          after TPD_G;
            intAcpSlaveWriteToArm.awlock   <= "00"          after TPD_G;
            intAcpSlaveWriteToArm.awcache  <= writeDmaCache after TPD_G;
            intAcpSlaveWriteToArm.awprot   <= "000"         after TPD_G;
            intAcpSlaveWriteToArm.awqos    <= "0000"        after TPD_G;
            intAcpSlaveWriteToArm.awuser   <= "00001"       after TPD_G;
            intAcpSlaveWriteToArm.wdata    <= writeData     after TPD_G;
            intAcpSlaveWriteToArm.wlast    <= '1'           after TPD_G;
            intAcpSlaveWriteToArm.wstrb    <= "11111111"    after TPD_G;

         -- Write address acked
         elsif axiAcpSlaveWriteFromArm.awready = '1' and intAcpSlaveWriteToArm.awvalid = '1' then
            intAcpSlaveWriteToArm.awvalid <= '0' after TPD_G;
            intAcpSlaveWriteToArm.wvalid  <= '1' after TPD_G;

         -- Write data acked
         elsif axiAcpSlaveWriteFromArm.wready = '1' then
            intAcpSlaveWriteToArm.wvalid  <= '0' after TPD_G;
         end if;

         -- Write status
         if axiAcpSlaveWriteFromArm.bvalid = '1' then
            writeDone <= '1' after TPD_G;
            if axiAcpSlaveWriteFromArm.bresp = "00" then
               writeError <= '0' after TPD_G;
            else
               writeError <= '1' after TPD_G;
            end if;
         else
            writeDone  <= '0' after TPD_G;
            writeError <= '0' after TPD_G;
         end if;
      end if;  
   end process;

   ---------------------------
   -- Debug
   ---------------------------
   debug(127 downto 113) <= (others=>'0'); -- External
   debug(112 downto 106) <= (others=>'0');
   debug(105)            <= iinterrupt;
   debug(104 downto 103) <= curState;
   debug(102)            <= writeDone;
   debug(101)            <= writeError;
   debug(100)            <= writeStart;
   debug(99 downto 36)   <= writeData;
   debug(35)             <= fifoWrEn;
   debug(34 downto 32)   <= fifoWrSel;
   debug(31)             <= fifoRdEn;
   debug(30 downto 23)   <= fifoValid;
   debug(22 downto 15)   <= dirtyFlag;
   debug(14)             <= dirtyClearEn;
   debug(13 downto 11)   <= dirtyClearSel;
   debug(10 downto  8)   <= curChannel;
   debug(7)              <= arbValid;
   debug(6)              <= intAcpSlaveWriteToArm.awvalid;
   debug(5)              <= intAcpSlaveWriteToArm.wlast;
   debug(4)              <= intAcpSlaveWriteToArm.wvalid;
   debug(3)              <= intAcpSlaveWriteToArm.bready;
   debug(2)              <= axiAcpSlaveWriteFromArm.awready;
   debug(1)              <= axiAcpSlaveWriteFromArm.wready;
   debug(0)              <= axiAcpSlaveWriteFromArm.bvalid;

end architecture structure;

