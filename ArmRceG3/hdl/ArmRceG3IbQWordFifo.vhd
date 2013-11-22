-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Inbound Quad Word FIFO
-- File          : ArmRceG3IbQWordFifo.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Inbound Quad Word FIFO for hardware/software handshaking.
-- After the entry is written the FIFO stalls and marks a memory channel as dirty. 
-- The quad word FIFOs will share AXI DMA IDs and us a busy bus to indicated 
-- when the associated ID is busy.
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
use IEEE.STD_LOGIC_ARITH.ALL;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;

entity ArmRceG3IbQWordFifo is
   generic (
      TPD_G      : time     := 1 ns;
      MEM_CHAN_G : integer  := 1
   );
   port (

      -- Clock & reset
      axiClk                  : in  sl;
      axiClkRst               : in  sl;

      -- AXI Write Interface, two channels, first for header data fifo, second for descriptor FIFO
      axiWriteToCntrl         : out AxiWriteToCntrlType;
      axiWriteFromCntrl       : in  AxiWriteFromCntrlType;

      -- Memory Dirty Flags
      memDirty                : in  sl;
      memDirtySet             : out sl;

      -- DMA ID Busy Bus
      writeDmaBusyOut         : out slv(7 downto 0);
      writeDmaBusyIn          : in  slv(7 downto 0);

      -- Configuration
      fifoEnable              : in  sl;
      writeDmaId              : in  slv(2 downto 0);
      memBaseAddress          : in  slv(31 downto 18); -- Lower bits derived from mem channel

      -- FIFO Interface
      qwordToFifo             : in  QWordToFifoType;
      qwordFromFifo           : out QWordFromFifoType
   );
end ArmRceG3IbQWordFifo;

architecture structure of ArmRceG3IbQWordFifo is

   -- State types
   type States is (ST_IDLE, ST_REQ, ST_WRITE, ST_WAIT, ST_PAUSE);

   -- Local signals
   signal burstDone                : sl;
   signal memAddress               : slv(31 downto 3);
   signal memReady                 : sl;
   signal fifoValid                : sl;
   signal fifoRd                   : sl;
   signal fifoDout                 : slv(71 downto 0);
   signal fifoReady                : sl;
   signal nextReq                  : sl;
   signal fifoReq                  : sl;
   signal nextBusy                 : sl;
   signal dbgState                 : slv(2 downto 0);
   signal curState                 : States;
   signal nxtState                 : States;

   -- Mark For Debug
   --attribute mark_debug                            : string;
   --attribute mark_debug of axiClk                  : signal is "true";
   --attribute mark_debug of axiClkRst               : signal is "true";
   --attribute mark_debug of axiWriteToCntrl         : signal is "true";
   --attribute mark_debug of axiWriteFromCntrl       : signal is "true";
   --attribute mark_debug of memDirty                : signal is "true";
   --attribute mark_debug of memDirtySet             : signal is "true";
   --attribute mark_debug of writeDmaBusyOut         : signal is "true";
   --attribute mark_debug of writeDmaBusyIn          : signal is "true";
   --attribute mark_debug of fifoEnable              : signal is "true";
   --attribute mark_debug of writeDmaId              : signal is "true";
   --attribute mark_debug of memBaseAddress          : signal is "true";
   --attribute mark_debug of qwordToFifo             : signal is "true";
   --attribute mark_debug of qwordFromFifo           : signal is "true";
   --attribute mark_debug of burstDone               : signal is "true";
   --attribute mark_debug of memAddress              : signal is "true";
   --attribute mark_debug of memReady                : signal is "true";
   --attribute mark_debug of fifoValid               : signal is "true";
   --attribute mark_debug of fifoRd                  : signal is "true";
   --attribute mark_debug of fifoDout                : signal is "true";
   --attribute mark_debug of fifoReady               : signal is "true";
   --attribute mark_debug of nextReq                 : signal is "true";
   --attribute mark_debug of fifoReq                 : signal is "true";
   --attribute mark_debug of nextBusy                : signal is "true";
   --attribute mark_debug of dbgState                : signal is "true";

begin

   -- State Debug
   dbgState <= conv_std_logic_vector(States'POS(curState), 3);

   -----------------------------------------
   -- Memory Address
   -----------------------------------------
   memAddress(31 downto 18) <= memBaseAddress;
   memAddress(17 downto  8) <= (others=>'0');
   memAddress(7  downto  3) <= conv_std_logic_vector(MEM_CHAN_G,5);
   memReady                 <= fifoEnable and (not memDirty);

   -----------------------------------------
   -- FIFO
   -----------------------------------------
   U_HdrFifo : entity work.FifoSyncBuiltIn 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         XIL_DEVICE_G   => "7SERIES",
         DATA_WIDTH_G   => 72,
         ADDR_WIDTH_G   => 9,
         FULL_THRES_G   => 479,
         EMPTY_THRES_G  => 1
      ) port map (
         rst               => axiClkRst,
         clk               => axiClk,
         wr_en             => qwordToFifo.valid,
         din(71 downto 64) => (others=>'0'),
         din(63 downto  0) => qwordToFifo.data,
         data_count        => open,
         wr_ack            => open,
         overflow          => open,
         prog_full         => qwordFromFifo.progFull,
         almost_full       => qwordFromFifo.almostFull,
         full              => qwordFromFifo.full,
         not_full          => open,
         rd_en             => fifoRd,
         dout              => fifoDout,
         valid             => fifoValid,
         underflow         => open,
         prog_empty        => open,
         almost_empty      => open,
         empty             => open
      );

   -- FIFO is ready for read, write channel is not busy
   fifoReady <= memReady and (not writeDmaBusyIn(conv_integer(writeDmaId))) and fifoValid;

   -----------------------------------------
   -- State machine
   -----------------------------------------

   -- AXI write channel outputs
   axiWriteToCntrl.req       <= fifoReq;
   axiWriteToCntrl.address   <= memAddress;
   axiWriteToCntrl.avalid    <= fifoRd;
   axiWriteToCntrl.id        <= writeDmaId;
   axiWriteToCntrl.length    <= "0000";
   axiWriteToCntrl.data      <= '0' & fifoDout(62 downto 0);
   axiWriteToCntrl.dvalid    <= fifoRd;
   axiWriteToCntrl.dstrobe   <= "11111111";
   axiWriteToCntrl.last      <= '1';

   -- Sync states
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         curState        <= ST_IDLE       after TPD_G;
         fifoReq         <= '0'           after TPD_G;
         memDirtySet     <= '0'           after TPD_G;
         writeDmaBusyOut <= (others=>'0') after TPD_G;
      elsif rising_edge(axiClk) then
         curState        <= nxtState       after TPD_G;
         fifoReq         <= nextReq        after TPD_G;

         -- Dirt flag set
         memDirtySet <= burstDone after TPD_G;

         -- Busy
         writeDmaBusyOut <= (others=>'0') after TPD_G;
         if nextBusy = '1' then
            writeDmaBusyOut(conv_integer(writeDmaId)) <= '1' after TPD_G;
         end if;

      end if;
   end process;

   -- ASync states
   process ( curState, fifoReady, axiWriteFromCntrl ) begin

      -- Init signals
      nxtState  <= curState;
      nextReq   <= '0';
      fifoRd    <= '0';
      burstDone <= '0';
      nextBusy  <= '0';

      -- State machine
      case curState is 

         -- Idle
         when ST_IDLE =>
            if fifoReady = '1' and axiWriteFromCntrl.afull = '0' then
               nextReq  <= '1';
               nxtState <= ST_REQ;
            end if;

         -- Request
         when ST_REQ =>
            nextReq <= '1';

            -- Wait for ACK
            if axiWriteFromCntrl.gnt = '1' then
               nxtState <= ST_WRITE;
            end if;

         -- Write word
         when ST_WRITE =>
            nextBusy  <= '1';
            fifoRd    <= '1';
            nxtState  <= ST_WAIT;

         -- Wait for write to complete
         when ST_WAIT =>

            -- Writes have completed
            if axiWriteFromCntrl.bvalid = '1' then 
               burstDone <= '1';
               nxtState  <= ST_PAUSE;
            else
               nextBusy <= '1';
            end if;

         -- Pause one clock to wait for dirty to be set
         when ST_PAUSE =>
            nxtState  <= ST_IDLE;

         when others =>
            nxtState <= ST_IDLE;
      end case;
   end process;

end architecture structure;

