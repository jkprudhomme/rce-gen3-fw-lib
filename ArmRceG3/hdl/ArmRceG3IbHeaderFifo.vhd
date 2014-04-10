-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Inbound Header FIFOs
-- File          : ArmRceG3IbHeaderFifo.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Inbound header FIFO for PPI DMA Engines. This FIFO handles an inbound header
-- block, writing it to a defined destination address in cache line burst size
-- transactions.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-- 06/14/2013: Modified to use free list and completion list. No longer set dirty
--             flag or asserts interrupt.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;

entity ArmRceG3IbHeaderFifo is
   generic (
      TPD_G        : time          := 1 ns;
      PPI_CONFIG_G : PpiConfigType := PPI_CONFIG_INIT_C
   );
   port (

      -- Clock & reset
      axiClk                  : in  sl;
      axiClkRst               : in  sl;

      -- AXI Write Interface, two channels, first for header data fifo, second for descriptor FIFO
      axiWriteToCntrl         : out AxiWriteToCntrlType;
      axiWriteFromCntrl       : in  AxiWriteFromCntrlType;

      -- Memory pointer free list write
      headerPtrWrite          : in  sl;
      headerPtrData           : in  slv(35 downto 0);

      -- Configuration
      fifoEnable              : in  sl;
      memBaseAddress          : in  slv(31 downto 18);     -- Lower bits from free list FIFO
      writeDmaId              : in  slv(2  downto  0);

      -- Completion FIFO Interface
      qwordToFifo             : out QWordToFifoType;
      qwordFromFifo           : in  QWordFromFifoType;

      -- Header FIFO Interface
      ibHeaderClk             : in  sl;
      ibHeaderToFifo          : in  IbheaderToFifoType;
      ibHeaderFromFifo        : out IbHeaderFromFifoType
   );
end ArmRceG3IbHeaderFifo;

architecture structure of ArmRceG3IbHeaderFifo is

   -- Max header size
   constant MAX_HEADER_C : integer := 32;

   -- Inbound Descriptor Data
   type IbDescType is record
      offset : slv(17 downto 0);
      length : slv(7  downto 0);
      err    : sl;
      htype  : slv(3 downto 0);
      valid  : sl;
   end record;

   -- Inbound FIFO Data
   type IbFifoType is record
      data   : slv(63 downto 0);
      err    : sl;
      eoh    : sl;
      htype  : slv(3  downto 0);
   end record;

   -- Inbound FIFO Init
   constant IB_FIFO_INIT_C : IbFifoType := ( 
      data   => x"0000000000000000",
      err    => '0',
      eoh    => '0',
      htype  => "0000"
   );

   -- Inbound FIFO Array
   type IbFifoArray is array (natural range<>) of IbFifoType;

   -- State Types
   type States is ( ST_IDLE, ST_NEXT, ST_REQ, ST_WRITE, ST_CHECK, ST_WAIT );
   
   -- Local signals
   signal headerPtrDout            : slv(35 downto 0);
   signal headerPtrValid           : sl;
   signal headerPtrOffset          : slv(17 downto 0);
   signal ibHeaderDin              : slv(71 downto 0);
   signal ibHeaderDout             : slv(71 downto 0);
   signal ibValid                  : slv(4  downto 0);
   signal ibHeader                 : IbFifoArray(4 downto 0);
   signal fifoShift                : slv(4 downto 0);
   signal headerDone               : sl;
   signal pipeReady                : sl;
   signal pipeShift                : sl;
   signal fifoRd                   : sl;
   signal fifoReady                : sl;
   signal writeAddr                : slv(31 downto 0);
   signal countReset               : sl;
   signal addrValid                : sl;
   signal dataValid                : sl;
   signal dataLast                 : sl;
   signal curDone                  : sl;
   signal nxtDone                  : sl;
   signal ackCount                 : slv(7 downto 0);
   signal burstCount               : slv(7 downto 0);
   signal burstCountEn             : sl;
   signal wordCount                : slv(1 downto 0);
   signal headerLength             : slv(7 downto 0);
   signal curError                 : sl;
   signal nxtError                 : sl;
   signal ibDesc                   : IbDescType;
   signal fifoReq                  : sl;
   signal nextReq                  : sl;
   signal curState                 : States;
   signal nxtState                 : States;
   signal dbgState                 : slv(2 downto 0);
   signal axiClkRstInt             : sl := '1';

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
   -- Free list FIFO
   -----------------------------------------
   U_PtrFifo : entity work.FifoSyncBuiltIn 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         XIL_DEVICE_G   => "7SERIES",
         DATA_WIDTH_G   => 36,
         ADDR_WIDTH_G   => 9,
         FULL_THRES_G   => 1,
         EMPTY_THRES_G  => 1
      ) port map (
         rst          => axiClkRstInt,
         clk          => axiClk,
         wr_en        => headerPtrWrite,
         rd_en        => headerDone,
         din          => headerPtrData,
         dout         => headerPtrDout,
         data_count   => open,
         wr_ack       => open,
         valid        => headerPtrValid,
         overflow     => open,
         underflow    => open,
         prog_full    => open,
         prog_empty   => open,
         almost_full  => open,
         almost_empty => open,
         not_full     => open,
         full         => open,
         empty        => open
      );

   -- Extract data
   headerPtrOffset <= headerPtrDout(17 downto 0);

   -----------------------------------------
   -- Header FIFO
   -----------------------------------------
   U_HdrFifo : entity work.FifoASyncBuiltIn 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         XIL_DEVICE_G   => "7SERIES",
         SYNC_STAGES_G  => 3,
         DATA_WIDTH_G   => 72,
         ADDR_WIDTH_G   => PPI_CONFIG_G.ibHeaderAddrWidth,
         FULL_THRES_G   => PPI_CONFIG_G.ibHeaderPauseThold,
         EMPTY_THRES_G  => 1
      ) port map (
         rst               => axiClkRstInt,
         wr_clk            => ibHeaderClk,
         wr_en             => ibHeaderToFifo.valid,
         din               => ibHeaderDin,
         wr_data_count     => open,
         wr_ack            => open,
         overflow          => open,
         prog_full         => ibHeaderFromFifo.progFull,
         almost_full       => ibHeaderFromFifo.almostFull,
         full              => ibHeaderFromFifo.full,
         not_full          => open,
         rd_clk            => axiClk,
         rd_en             => fifoShift(4),
         dout              => ibHeaderDout,
         rd_data_count     => open,
         valid             => ibValid(4),
         underflow         => open,
         prog_empty        => open,
         almost_empty      => open,
         empty             => open
      );

   -- Inputs
   ibHeaderDin(71 downto 70) <= "00";
   ibHeaderDin(69)           <= ibHeaderToFifo.eoh;
   ibHeaderDin(68)           <= ibHeaderToFifo.err;
   ibHeaderDin(67 downto 64) <= ibHeaderToFifo.htype;
   ibHeaderDin(63 downto  0) <= ibHeaderToFifo.data;

   -- Outputs
   ibHeader(4).eoh    <= ibHeaderDout(69);
   ibHeader(4).err    <= ibHeaderDout(68);
   ibHeader(4).htype  <= ibHeaderDout(67 downto 64);
   ibHeader(4).data   <= ibHeaderDout(63 downto  0);

   -- Output pipeline, 4 extra registers after FIFO.
   -- Allows a cache line to be pulled from the FIFO and examined
   -- before the write access is started
   U_FifoPipeGen : for i in 0 to 3 generate
      process ( axiClk ) begin
         if rising_edge(axiClk) then
            if axiClkRstInt = '1' then
               ibHeader(i) <= IB_FIFO_INIT_C after TPD_G;
               ibValid(i)  <= '0'            after TPD_G;
            elsif fifoShift(i) = '1' then
               ibHeader(i) <= ibHeader(i+1) after TPD_G;
               ibValid(i)  <= ibValid(i+1)  after TPD_G;
            end if;
         end if;
      end process;
   end generate;

   -- Pipeline shift control
   fifoShift(4) <= fifoShift(3);
   fifoShift(3) <= fifoShift(2) or (ibValid(4) and (not ibValid(3)));
   fifoShift(2) <= fifoShift(1) or (ibValid(3) and (not ibValid(2)));
   fifoShift(1) <= fifoShift(0) or (ibValid(2) and (not ibValid(1)));
   fifoShift(0) <= pipeShift    or (ibValid(1) and (not ibValid(0)));

   -- Top level shift control. 
   pipeShift <= fifoRd and ibValid(0);

   -- Pipeline is full
   pipeReady <= '1' when ibValid(3 downto 0) = "1111" 
                     or (ibValid(2 downto 0) = "111" and ibHeader(2).eoh = '1') 
                     or (ibValid(1 downto 0) = "11"  and ibHeader(1).eoh = '1')
                     or (ibValid(0)          = '1'   and ibHeader(0).eoh = '1') else '0';

   -- FIFO is ready for read. Ready when 4 entries are valid or the last flag is set in one of the entries.
   -- Do not assert ready if associated quad word FIFO is full
   fifoReady <= fifoEnable and headerPtrValid and pipeReady and (not qwordFromFifo.full);

   -----------------------------------------
   -- State machine
   -----------------------------------------

   -- AXI write channel outputs
   axiWriteToCntrl.req       <= fifoReq;
   axiWriteToCntrl.address   <= writeAddr(31 downto 3);
   axiWriteToCntrl.avalid    <= addrValid;
   axiWriteToCntrl.id        <= writeDmaId;
   axiWriteToCntrl.length    <= "0011";
   axiWriteToCntrl.data      <= ibHeader(0).data;
   axiWriteToCntrl.dvalid    <= dataValid;
   axiWriteToCntrl.dstrobe   <= "11111111";
   axiWriteToCntrl.last      <= dataLast;

   -- Sync states
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            curState       <= ST_IDLE       after TPD_G;
            curDone        <= '0'           after TPD_G;
            curError       <= '0'           after TPD_G;
            writeAddr      <= (others=>'0') after TPD_G;
            burstCount     <= (others=>'0') after TPD_G;
            wordCount      <= (others=>'0') after TPD_G;
            ackCount       <= (others=>'0') after TPD_G;
            fifoReq        <= '0'           after TPD_G;
            headerLength   <= (others=>'0') after TPD_G;
            ibDesc.htype   <= (others=>'0') after TPD_G;
            ibDesc.offset  <= (others=>'0') after TPD_G;
            ibDesc.err     <= '0'           after TPD_G;
            ibDesc.length  <= (others=>'0') after TPD_G;
            ibDesc.valid   <= '0'           after TPD_G;
         else
            curState       <= nxtState        after TPD_G;
            curDone        <= nxtDone         after TPD_G;
            curError       <= nxtError        after TPD_G;
            fifoReq        <= nextReq         after TPD_G;

            -- Write address tracking
            if countReset = '1' then
               writeAddr <=  memBaseAddress & headerPtrOffset after TPD_G;

            -- Stop incrementing address after hitting max length
            elsif burstCountEn = '1' and headerLength /= MAX_HEADER_C then
               writeAddr <= writeAddr + 32 after TPD_G;
            end if;

            -- Counter to track outstanding writes
            if countReset = '1' then
               burstCount <= (others=>'0') after TPD_G;
            elsif burstCountEn = '1' then
               burstCount <= burstCount + 1 after TPD_G;
            end if;

            -- Counter to track acks
            if countReset = '1' then
               ackCount <= (others=>'0') after TPD_G;
            elsif axiWriteFromCntrl.bvalid = '1' then 
               ackCount <= ackCount + 1 after TPD_G;
            end if;

            -- Word count tracking
            if countReset = '1' then
               wordCount <= "00" after TPD_G;
            elsif dataValid = '1' then
               wordCount <= wordCount + 1 after TPD_G;
            end if;

            -- Header length tracking
            if countReset = '1' then
               headerLength <= (others=>'0') after TPD_G;
            elsif fifoRd = '1' then

               -- Mark frame in error if exceeding max length
               if headerLength = MAX_HEADER_C then
                  curError <= '1' after TPD_G;
               else
                  headerLength <= headerLength + 1 after TPD_G;
               end if;
            end if;

            -- Generate descriptor information
            -- type field
            if fifoRd = '1' and headerLength = 0 then
               ibDesc.htype <= ibHeader(0).htype after TPD_G;
            end if;

            -- Rest of incoming descriptor
            ibDesc.offset <= headerPtrOffset;
            ibDesc.err    <= curError;
            ibDesc.length <= headerLength;
            ibDesc.valid  <= headerDone;

         end if;
      end if;
   end process;


   -- ASync states
   process ( curState, fifoReady, axiWriteFromCntrl, curDone, fifoReq,
             ibHeader, ackCount, wordCount, burstCount, curError ) begin

      -- Init signals
      nxtState      <= curState;
      nextReq       <= '0';
      fifoRd        <= '0';
      nxtDone       <= curDone;
      nxtError      <= curError;
      headerDone    <= '0';
      burstCountEn  <= '0';
      countReset    <= '0';
      addrValid     <= '0';
      dataValid     <= '0';
      dataLast      <= '0';

      -- State machine
      case curState is 

         -- Idle
         when ST_IDLE =>
            countReset <= '1';

            if fifoReady = '1' and axiWriteFromCntrl.afull = '0' then
               nextReq  <= '1';
               nxtState <= ST_REQ;
            end if;

         -- Next
         when ST_NEXT =>

            if fifoReady = '1' and axiWriteFromCntrl.afull = '0' then
               nextReq  <= '1';
               nxtState <= ST_REQ;
            end if;

         -- Request
         when ST_REQ =>
            nextReq <= '1';

            -- Wait for ACK
            if axiWriteFromCntrl.gnt = '1' and fifoReq = '1' then
               addrValid <= '1';
               nxtState  <= ST_WRITE;
            end if;

         -- Write data
         when ST_WRITE =>
            nextReq   <= '1';
            dataValid <= '1';
            fifoRd    <= not curDone;

            -- Word 3, last
            if wordCount = 3 then
               nextReq  <= '0';
               nextReq  <= '0';
               dataLast <= '1';
               nxtState <= ST_CHECK;
            end if;

            -- ERR is set
            if ibHeader(0).err = '1' then
               nxtError <= '1';
            end if;

            -- EOH is set
            if ibHeader(0).eoh = '1' then
               nxtDone <= '1';
            end if;

         -- Check state, de-assert request
         when ST_CHECK =>
            burstCountEn <= '1';
            nxtDone      <= '0';

            -- Transfer is done
            if curDone = '1' then
               nxtState <= ST_WAIT;
            else
               nextReq  <= fifoReady and (not axiWriteFromCntrl.afull);
               nxtState <= ST_NEXT;
            end if;

         -- Wait for writes to complete
         when ST_WAIT =>

            -- Writes have completed
            if burstCount = ackCount then
               nxtError   <= '0';
               headerDone <= '1';
               nxtState   <= ST_IDLE;
            end if;

         when others =>
            nxtState <= ST_IDLE;
      end case;
   end process;

   ---------------------------
   -- Descriptor FIFO Output
   ---------------------------
   qwordToFifo.data(63 downto 61) <= (others=>'0');
   qwordToFifo.data(60)           <= ibDesc.err;
   qwordToFifo.data(59 downto 52) <= (others=>'0');
   qwordToFifo.data(51 downto 48) <= ibDesc.htype;
   qwordToFifo.data(47 downto 40) <= (others=>'0');
   qwordToFifo.data(39 downto 32) <= ibDesc.length;
   qwordToFifo.data(31 downto 18) <= (others=>'0');
   qwordToFifo.data(17 downto  0) <= ibDesc.offset;
   qwordToFifo.valid              <= ibDesc.valid;

end architecture structure;
