-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Inbound PPI DMA
-- File          : ArmRceG3IbPpi.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 09/03/2013
-------------------------------------------------------------------------------
-- Description:
-- Inbound PPI DMA controller
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
use work.AxiPkg.all;

entity ArmRceG3IbPpi is
   generic (
      TPD_G        : time          := 1 ns;
      PPI_CONFIG_G : PpiConfigType := PPI_CONFIG_INIT_C
   );
   port (

      -- Clock
      axiClk                  : in  sl;
      axiClkRst               : in  sl;

      -- AXI HP Master
      axiHpSlaveWriteFromArm  : in  AxiWriteSlaveType;
      axiHpSlaveWriteToArm    : out AxiWriteMasterType;

      -- Inbound Header FIFO
      ibHeaderToFifo          : out IbHeaderToFifoType;
      ibHeaderFromFifo        : in  IbHeaderFromFifoType;

      -- Memory pointer free list write
      ppiPtrWrite             : in  sl;
      ppiPtrData              : in  slv(35 downto 0);

      -- Configuration
      writeDmaCache           : in  slv(3  downto 0);

      -- Completion FIFO
      compFromFifo            : out CompFromFifoType;
      compToFifo              : in  CompToFifoType;

      -- PPI FIFO Interface
      ppiClk                  : in  sl;
      ppiWriteToFifo          : in  PpiWriteToFifoType;
      ppiWriteFromFifo        : out PpiWriteFromFifoType
   );
end ArmRceG3IbPpi;

architecture structure of ArmRceG3IbPpi is

   -- Inbound Descriptor Data
   type IbDescType is record
      addr      : slv(31 downto 0);
      drop      : sl;
      length    : slv(31 downto 0);
      compId    : slv(31 downto 0);
      compEn    : sl;
      compIdx   : slv(3  downto 0);
      ready     : sl;
      compReady : sl;
   end record;

   -- Inbound PPI data
   type IbPpiType is record
      data   : slv(63 downto 0);
      eof    : sl;
      err    : sl;
      ftype  : slv(3 downto 0);
      valid  : slv(7 downto 0);
   end record;

   -- States
   type States is ( ST_IDLE, ST_ADDR, ST_WRITE, ST_CHECK, ST_WAIT, ST_DROP, ST_CLEAR );

   -- Local signals
   signal currCompData      : CompFromFifoType;
   signal nextCompWrite     : sl;
   signal ppiPtrRead        : sl;
   signal ppiPtrDout        : slv(35 downto 0);
   signal ppiPtrValid       : sl;
   signal ibPpiFifo         : IbPpiType;
   signal ibPpiHold         : IbPpiType;
   signal ibPpi             : IbPpiType;
   signal ibPpiFifoRead     : sl;
   signal ibPpiRead         : sl;
   signal ibPpiStart        : sl;
   signal ibPpiValid        : sl;
   signal ibPpiShift        : sl;
   signal ibPpiShiftEn      : sl;
   signal ibPpiWrite        : sl;
   signal ibPpiDout         : slv(72 downto 0);
   signal ibPpiDin          : slv(72 downto 0);
   signal ibPpiProgFull     : sl;
   signal addrValid         : sl;
   signal dataValid         : sl;
   signal dataLast          : sl;
   signal writeAddr         : slv(31 downto 0);
   signal currDone          : sl;
   signal nextDone          : sl;
   signal ackCount          : slv(31 downto 0);
   signal burstCount        : slv(31 downto 0);
   signal wordCount         : slv(3  downto 0);
   signal frameLength       : slv(31 downto 0);
   signal nextLength        : slv(31 downto 0);
   signal compFifoDin       : slv(35 downto 0);
   signal compFifoDout      : slv(35 downto 0);
   signal payloadEn         : sl;
   signal burstCountEn      : sl;
   signal wordCountEn       : sl;
   signal ibDesc            : IbDescType;
   signal ibDescCount       : slv(1 downto 0);
   signal ibDescClear       : sl;
   signal countReset        : sl;
   signal axiWriteToCntrl   : AxiWriteToCntrlType;
   signal axiWriteFromCntrl : AxiWriteFromCntrlType;
   signal firstSize         : slv(7   downto 0);
   signal currSize          : slv(7   downto 0);
   signal firstLength       : slv(3   downto 0);
   signal currLength        : slv(3   downto 0);
   signal currState         : States;
   signal nextState         : States;
   signal dbgState          : slv(2 downto 0);
   signal ppiClkRst         : sl;
   signal axiClkRstInt      : sl := '1';
   signal nextError         : slv(3 downto 1);
   signal currError         : slv(3 downto 1);

   attribute INIT : string;
   attribute INIT of axiClkRstInt : signal is "1";

   attribute mark_debug : string;
   attribute mark_debug of axiClkRstInt : signal is "true";

   attribute mark_debug of axiWriteToCntrl  : signal is "true";
   attribute mark_debug of ibPpiFifo        : signal is "true";
   attribute mark_debug of ibPpiFifoRead    : signal is "true";

begin

   -- Reset registration
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         axiClkRstInt <= axiClkRst after TPD_G;
      end if;
   end process;

   -- State Debug
   dbgState <= conv_std_logic_vector(States'POS(currState), 3);

   -----------------------------------------
   -- Receive Control FIFO
   -----------------------------------------
   U_PtrFifo : entity work.Fifo
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         RST_ASYNC_G     => false,
         GEN_SYNC_FIFO_G => true,
         BRAM_EN_G       => true,
         FWFT_EN_G       => true,
         USE_DSP48_G     => "no",
         USE_BUILT_IN_G  => true,
         XIL_DEVICE_G    => "7SERIES",
         SYNC_STAGES_G   => 3,
         DATA_WIDTH_G    => 36,
         ADDR_WIDTH_G    => 9,
         INIT_G          => "0",
         FULL_THRES_G    => 1,
         EMPTY_THRES_G   => 1
      ) port map (
         rst           => axiClkRstInt,
         wr_clk        => axiClk,
         wr_en         => ppiPtrWrite,
         din           => ppiPtrData,
         wr_data_count => open,
         wr_ack        => open,
         overflow      => open,
         prog_full     => open,
         almost_full   => open,
         full          => open,
         not_full      => open,
         rd_clk        => axiClk,
         rd_en         => ppiPtrRead,
         dout          => ppiPtrDout,
         rd_data_count => open,
         valid         => ppiPtrValid,
         underflow     => open,
         prog_empty    => open,
         almost_empty  => open,
         empty         => open
      );

   -- Read control
   ppiPtrRead <= ppiPtrValid when ibDescCount /= 3 and ibDescClear = '0' else '0';

   -- Extract descriptor data
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' or ibDescClear = '1' then
            ibDesc.addr      <= (others=>'0') after TPD_G;
            ibDesc.drop      <= '0'           after TPD_G;
            ibDesc.length    <= (others=>'0') after TPD_G;
            ibDesc.compId    <= (others=>'0') after TPD_G;
            ibDesc.compEn    <= '0'           after TPD_G;
            ibDesc.compIdx   <= (others=>'0') after TPD_G;
            ibDesc.ready     <= '0'           after TPD_G;
            ibDesc.compReady <= '0'           after TPD_G;
            ibDescCount      <= (others=>'0') after TPD_G;

         -- Count up to 3
         elsif ppiPtrRead = '1' and ibDescCount /= 3 then
            ibDescCount <= ibDescCount + 1 after TPD_G;
         
            -- Latch read data
            case ibDescCount is

               -- Word 0, Address
               when "00" => 
                  ibDesc.drop <= ppiPtrDout(32)          after TPD_G;
                  ibDesc.addr <= ppiPtrDout(31 downto 0) after TPD_G;

               -- Word 1, Length
               when "01" => 
                  ibDesc.compEn    <= ppiPtrDout(32)          after TPD_G;
                  ibDesc.length    <= ppiPtrDout(31 downto 0) after TPD_G;
                  ibDesc.ready     <= '1'                     after TPD_G;

               -- Word 2, comp id and enable
               when "10" => 
                  ibDesc.compIdx   <= ppiPtrDout(35 downto 32) after TPD_G;
                  ibDesc.compId    <= ppiPtrDout(31 downto  0) after TPD_G;
                  ibDesc.compReady <= '1'                      after TPD_G;

               when others =>
            end case;
         end if;
      end if;
   end process;


   -----------------------------------------
   -- Input FIFO
   -----------------------------------------
   U_PpiFifo : entity work.Fifo
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         RST_ASYNC_G     => false,
         GEN_SYNC_FIFO_G => false, -- Async
         BRAM_EN_G       => true,
         FWFT_EN_G       => true,
         USE_DSP48_G     => "no",
         USE_BUILT_IN_G  => false,
         XIL_DEVICE_G    => "7SERIES",
         SYNC_STAGES_G   => 3,
         DATA_WIDTH_G    => 73,
         ADDR_WIDTH_G    => PPI_CONFIG_G.ibDataAddrWidth,
         INIT_G          => "0",
         FULL_THRES_G    => PPI_CONFIG_G.ibDataPauseThold,
         EMPTY_THRES_G   => 1
      ) port map (
         rst                => axiClkRstInt,
         wr_clk             => ppiClk,
         wr_en              => ibPpiWrite,
         din                => ibPpiDin,
         wr_data_count      => open,
         wr_ack             => open,
         overflow           => open,
         prog_full          => ibPpiProgFull,
         almost_full        => open,
         full               => open,
         not_full           => open,
         rd_clk             => axiClk,
         rd_en              => ibPpiFifoRead,
         dout               => ibPpiDout,
         rd_data_count      => open,
         valid              => ibPpiValid,
         underflow          => open,
         prog_empty         => open,
         almost_empty       => open,
         empty              => open
      );

   -- Sync reset
   U_ppiClkRstGen : entity work.RstSync
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '1',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 16
      )
      port map (
        clk      => ppiClk,
        asyncRst => axiClkRstInt,
        syncRst  => ppiClkRst
      );

   -- Toggle write destination
   process ( ppiClk ) begin
      if rising_edge(ppiClk) then
         if ppiClkRst = '1' then
            payloadEn <= '0' after TPD_G;
         elsif ppiWriteToFifo.valid = '1' then

            -- Go to header mode on EOF
            if ppiWriteToFifo.eof = '1' then
               payloadEn <= '0' after TPD_G;

            -- Go to payload mode on EOH (and not EOF)
            elsif ppiWriteToFifo.eoh = '1' then
               payloadEn <= '1' after TPD_G;
            end if;
         end if;
      end if;
   end process;

   -- Local write
   ibPpiWrite <= ppiWriteToFifo.valid and payloadEn;

   -- Header write
   ibHeaderToFifo.valid <= ppiWriteToFifo.valid and (not payloadEn);
   ibHeaderToFifo.htype <= ppiWriteToFifo.ftype;
   ibHeaderToFifo.data  <= ppiWriteToFifo.data;
   ibHeaderToFifo.err   <= ppiWriteToFifo.err and ppiWriteToFifo.eof;
   ibHeaderToFifo.eoh   <= ppiWriteToFifo.eoh or ppiWriteToFifo.eof;

   -- Outbound flow control
   ppiWriteFromFifo.pause <= ibPpiProgFull or ibHeaderFromFifo.progFull;

   -- Input Data
   ibPpiDin(72)           <= ppiWriteToFifo.err;
   ibPpiDin(71)           <= ppiWriteToFifo.eof;
   ibPpiDin(70 downto 67) <= ppiWriteToFifo.ftype;
   ibPpiDin(66 downto 64) <= ppiWriteToFifo.size;
   ibPpiDin(63 downto  0) <= ppiWriteToFifo.data;

   -- Output Data
   ibPpiFifo.err   <= ibPpiDout(72);
   ibPpiFifo.eof   <= ibPpiDout(71);
   ibPpiFifo.ftype <= ibPpiDout(70 downto 67);
   ibPpiFifo.valid <= "11111111" when ibPpiDout(66 downto 64) = "111" and ibPpiValid = '1' else 
                      "01111111" when ibPpiDout(66 downto 64) = "110" and ibPpiValid = '1' else 
                      "00111111" when ibPpiDout(66 downto 64) = "101" and ibPpiValid = '1' else 
                      "00011111" when ibPpiDout(66 downto 64) = "100" and ibPpiValid = '1' else 
                      "00001111" when ibPpiDout(66 downto 64) = "011" and ibPpiValid = '1' else 
                      "00000111" when ibPpiDout(66 downto 64) = "010" and ibPpiValid = '1' else 
                      "00000011" when ibPpiDout(66 downto 64) = "001" and ibPpiValid = '1' else 
                      "00000001" when ibPpiDout(66 downto 64) = "000" and ibPpiValid = '1' else 
                      "00000000";
   ibPpiFifo.data  <= ibPpiDout(63 downto  0);


   -----------------------------------------
   -- FIFO Output Byte Reordering
   -----------------------------------------

   -- FIFO register stages
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            ibPpiShiftEn    <= '0'           after TPD_G;
            ibPpiHold.data  <= (others=>'0') after TPD_G; 
            ibPpiHold.eof   <= '0'           after TPD_G;
            ibPpiHold.ftype <= (others=>'0') after TPD_G;
            ibPpiHold.valid <= (others=>'0') after TPD_G;
            ibPpi.data      <= (others=>'0') after TPD_G;
            ibPpi.eof       <= '0'           after TPD_G;
            ibPpi.err       <= '0'           after TPD_G;
            ibPpi.ftype     <= (others=>'0') after TPD_G;
            ibPpi.valid     <= (others=>'0') after TPD_G;
         else

            -- Shift enable
            if ibPpiShift = '1' and ibPpiFifo.eof = '1' then
               ibPpiShiftEn <= '0' after TPD_G;
            elsif ibPpiStart = '1' then
               ibPpiShiftEn <= '1' after TPD_G;
            end if;

            -- Shift
            if ibPpiShift = '1' then

               -- Init
               ibPpiHold       <= ibPpiFifo     after TPD_G;
               ibPpiHold.eof   <= '0'           after TPD_G;
               ibPpiHold.valid <= (others=>'0') after TPD_G;
               ibPpi           <= ibPpiFifo     after TPD_G;
               ibPpi.eof       <= '0'           after TPD_G;
               ibPpi.valid     <= (others=>'0') after TPD_G;

               -- EOF is sitting on hold register
               if ibPpiHold.eof = '1' then
                  ibPpi <= ibPpiHold after TPD_G;

               -- EOF is not sitting on output register or hold register
               elsif ibPpi.eof = '0' then

                  -- Determine shift
                  case ibDesc.addr(2 downto 0) is

                     -- No shift
                     when "000" =>
                        ibPpi <= ibPpiFifo after TPD_G;

                     -- Shift by 1
                     when "001" =>

                        -- Output register
                        ibPpi.data(63 downto 8)    <= ibPpiFifo.data(55 downto 0)  after TPD_G;
                        ibPpi.valid(7 downto 1)    <= ibPpiFifo.valid(6 downto 0)  after TPD_G;
                        ibPpi.data(7  downto 0)    <= ibPpiHold.data(7  downto 0)  after TPD_G;
                        ibPpi.valid(0)             <= ibPpiHold.valid(0)           after TPD_G;

                        -- Holding register
                        ibPpiHold.data(7 downto 0) <= ibPpiFifo.data(63 downto 56) after TPD_G;
                        ibPpiHold.valid(0)         <= ibPpiFifo.valid(7)           after TPD_G;

                        -- EOF
                        if ibPpiFifo.eof = '1' then
                           if ibPpiFifo.valid(7) /= '0' then
                              ibPpiHold.eof  <= '1';
                           else
                              ibPpi.eof <= '1';
                           end if;
                        end if;

                     -- Shift by 2
                     when "010" =>

                        -- Output register
                        ibPpi.data(63 downto 16)    <= ibPpiFifo.data(47 downto 0)  after TPD_G;
                        ibPpi.valid(7 downto 2)     <= ibPpiFifo.valid(5 downto 0)  after TPD_G;
                        ibPpi.data(15 downto 0)     <= ibPpiHold.data(15 downto 0)  after TPD_G;
                        ibPpi.valid(1 downto 0)     <= ibPpiHold.valid(1 downto 0)  after TPD_G;

                        -- Holding register
                        ibPpiHold.data(15 downto 0) <= ibPpiFifo.data(63 downto 48) after TPD_G;
                        ibPpiHold.valid(1 downto 0) <= ibPpiFifo.valid(7 downto 6)  after TPD_G;

                        -- EOF
                        if ibPpiFifo.eof = '1' then
                           if ibPpiFifo.valid(7 downto 6) /= 0 then
                              ibPpiHold.eof <= '1';
                           else
                              ibPpi.eof <= '1';
                           end if;
                        end if;

                     -- Shift by 3
                     when "011" =>

                        -- Output register
                        ibPpi.data(63 downto 24)    <= ibPpiFifo.data(39 downto 0)  after TPD_G;
                        ibPpi.valid(7 downto 3)     <= ibPpiFifo.valid(4 downto 0)  after TPD_G;
                        ibPpi.data(23 downto 0)     <= ibPpiHold.data(23 downto 0)  after TPD_G;
                        ibPpi.valid(2 downto 0)     <= ibPpiHold.valid(2 downto 0)  after TPD_G;

                        -- Holding register
                        ibPpiHold.data(23 downto 0) <= ibPpiFifo.data(63 downto 40) after TPD_G;
                        ibPpiHold.valid(2 downto 0) <= ibPpiFifo.valid(7 downto 5)  after TPD_G;

                        -- EOF
                        if ibPpiFifo.eof = '1' then
                           if ibPpiFifo.valid(7 downto 5) /= 0 then
                              ibPpiHold.eof <= '1';
                           else
                              ibPpi.eof <= '1';
                           end if;
                        end if;

                     -- Shift by 4
                     when "100" =>

                        -- Output register
                        ibPpi.data(63 downto 32)    <= ibPpiFifo.data(31 downto 0)  after TPD_G;
                        ibPpi.valid(7 downto 4)     <= ibPpiFifo.valid(3 downto 0)  after TPD_G;
                        ibPpi.data(31 downto 0)     <= ibPpiHold.data(31 downto 0)  after TPD_G;
                        ibPpi.valid(3 downto 0)     <= ibPpiHold.valid(3 downto 0)  after TPD_G;

                        -- Holding register
                        ibPpiHold.data(31 downto 0) <= ibPpiFifo.data(63 downto 32) after TPD_G;
                        ibPpiHold.valid(3 downto 0) <= ibPpiFifo.valid(7 downto 4)  after TPD_G;

                        -- EOF
                        if ibPpiFifo.eof = '1' then
                           if ibPpiFifo.valid(7 downto 4) /= 0 then
                              ibPpiHold.eof <= '1';
                           else
                              ibPpi.eof <= '1';
                           end if;
                        end if;

                     -- Shift by 5
                     when "101" =>

                        -- Output register
                        ibPpi.data(63 downto 40)    <= ibPpiFifo.data(23 downto 0)  after TPD_G;
                        ibPpi.valid(7 downto 5)     <= ibPpiFifo.valid(2 downto 0)  after TPD_G;
                        ibPpi.data(39 downto 0)     <= ibPpiHold.data(39 downto 0)  after TPD_G;
                        ibPpi.valid(4 downto 0)     <= ibPpiHold.valid(4 downto 0)  after TPD_G;

                        -- Holding register
                        ibPpiHold.data(39 downto 0) <= ibPpiFifo.data(63 downto 24) after TPD_G;
                        ibPpiHold.valid(4 downto 0) <= ibPpiFifo.valid(7 downto 3)  after TPD_G;

                        -- EOF
                        if ibPpiFifo.eof = '1' then
                           if ibPpiFifo.valid(7 downto 3) /= 0 then
                              ibPpiHold.eof <= '1';
                           else
                              ibPpi.eof <= '1';
                           end if;
                        end if;

                     -- Shift by 6
                     when "110" =>

                        -- Output register
                        ibPpi.data(63 downto 48)    <= ibPpiFifo.data(15 downto 0)  after TPD_G;
                        ibPpi.valid(7 downto 6)     <= ibPpiFifo.valid(1 downto 0)  after TPD_G;
                        ibPpi.data(47 downto 0)     <= ibPpiHold.data(47 downto 0)  after TPD_G;
                        ibPpi.valid(5 downto 0)     <= ibPpiHold.valid(5 downto 0)  after TPD_G;

                        -- Holding register
                        ibPpiHold.data(47 downto 0) <= ibPpiFifo.data(63 downto 16) after TPD_G;
                        ibPpiHold.valid(5 downto 0) <= ibPpiFifo.valid(7 downto 2)  after TPD_G;

                        -- EOF
                        if ibPpiFifo.eof = '1' then
                           if ibPpiFifo.valid(7 downto 2) /= 0 then
                              ibPpiHold.eof <= '1';
                           else
                              ibPpi.eof <= '1';
                           end if;
                        end if;

                     -- Shift by 7
                     when "111" =>

                        -- Output register
                        ibPpi.data(63 downto 56)    <= ibPpiFifo.data(7  downto 0)  after TPD_G;
                        ibPpi.valid(7)              <= ibPpiFifo.valid(0)           after TPD_G;
                        ibPpi.data(55 downto 0)     <= ibPpiHold.data(55 downto 0)  after TPD_G;
                        ibPpi.valid(6 downto 0)     <= ibPpiHold.valid(6 downto 0)  after TPD_G;

                        -- Holding register
                        ibPpiHold.data(55 downto 0) <= ibPpiFifo.data(63 downto 8)  after TPD_G;
                        ibPpiHold.valid(6 downto 0) <= ibPpiFifo.valid(7 downto 1)  after TPD_G;

                        -- EOF
                        if ibPpiFifo.eof = '1' then
                           if ibPpiFifo.valid(7 downto 1) /= 0 then
                              ibPpiHold.eof <= '1';
                           else
                              ibPpi.eof <= '1';
                           end if;
                        end if;

                     when others =>
                  end case;

               -- Clear EOF
               else 
                  ibPpi.eof <= '0' after TPD_G;
               end if;
            end if;
         end if;
      end if;
   end process;

   -- Determine next length value
   nextLength <= frameLength + onesCount(ibPpi.valid);

   -- Control pipeline shift
   ibPpiShift <= '1' when ibPpiRead = '1' or 
                          ( ibPpiShiftEn = '1' and ibPpiValid = '1' and ibPpi.valid = 0 ) else '0';

   -- Control FIFO reads
   ibPpiFifoRead <= ibPpiShift and ibPpiShiftEn;

   -----------------------------------------
   -- AXI Write Controller
   -----------------------------------------
   U_WriteCntrl : entity work.AxiRceG3AxiWriteCntrl 
      generic map (
         TPD_G      => TPD_G,
         CHAN_CNT_G => 1
      ) port map (
         axiClk               => axiClk,
         axiClkRst            => axiClkRstInt,
         axiSlaveWriteFromArm => axiHpSlaveWriteFromArm,
         axiSlaveWriteToArm   => axiHpSlaveWriteToArm,
         writeDmaCache        => writeDmaCache,
         axiWriteToCntrl(0)   => axiWriteToCntrl,
         axiWriteFromCntrl(0) => axiWriteFromCntrl
      );

   -- AXI write master
   axiWriteToCntrl.req       <= '1';
   axiWriteToCntrl.address   <= writeAddr(31 downto 3);
   axiWriteToCntrl.avalid    <= addrValid;
   axiWriteToCntrl.id        <= "000";
   axiWriteToCntrl.length    <= currLength;
   axiWriteToCntrl.data      <= ibPpi.data;
   axiWriteToCntrl.dvalid    <= dataValid;
   axiWriteToCntrl.dstrobe   <= ibPpi.valid when currDone = '0' and nextLength <= ibDesc.length else (others=>'0');
   axiWriteToCntrl.last      <= dataLast;


   -----------------------------------------
   -- State Machine
   -----------------------------------------

   -- Determine transfer size to align all transfers to 128 byte boundaries
   -- This initial alignment will ensure that we never cross a 4k boundary
   firstSize(7 downto 3) <= "10000" - ibDesc.addr(6 downto 3);
   firstSize(2 downto 0) <= "000";
   firstLength           <= x"F"  - ibDesc.addr(6 downto 3);
             
   -- Sync states
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            currState              <= ST_IDLE       after TPD_G;
            currDone               <= '0'           after TPD_G;
            writeAddr              <= (others=>'0') after TPD_G;
            burstCount             <= (others=>'0') after TPD_G;
            ackCount               <= (others=>'0') after TPD_G;
            wordCount              <= (others=>'0') after TPD_G;
            frameLength            <= (others=>'0') after TPD_G;
            currCompData.valid     <= '0'           after TPD_G;
            currCompData.index     <= (others=>'0') after TPD_G;
            currCompData.id        <= (others=>'0') after TPD_G;
            currSize               <= (others=>'0') after TPD_G;
            currLength             <= (others=>'0') after TPD_G;
            currError              <= (others=>'0') after TPD_G;
         else
            currState  <= nextState     after TPD_G;
            currDone   <= nextDone      after TPD_G;
            currError  <= nextError     after TPD_G;

            -- Write address tracking
            if countReset = '1' then
               writeAddr(31 downto 3)  <= ibDesc.addr(31 downto 3) after TPD_G;
               writeAddr(2  downto 0)  <= "000"                    after TPD_G;
               currSize                <= firstSize                after TPD_G;
               currLength              <= firstLength              after TPD_G;

            -- Increment address, adjust next size
            elsif burstCountEn = '1' then
               writeAddr  <= writeAddr + currSize after TPD_G;
               currSize   <= x"80"                after TPD_G; -- 128
               currLength <= x"F"                 after TPD_G; -- 15
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
            if countReset = '1' or dataLast = '1' then
               wordCount <= "0000" after TPD_G;
            elsif wordCountEn = '1' then
               wordCount <= wordCount + 1 after TPD_G;
            end if;

            -- Frame length tracking
            if countReset = '1' then
               frameLength <= (others=>'0') after TPD_G;
            elsif ibPpiRead = '1' then
               frameLength <= nextLength after TPD_G;
            end if;

            -- Completion 
            currCompData.id(31 downto 4) <= ibDesc.compId(31 downto 4) after TPD_G;
            currCompData.id(3  downto 1) <= currError                  after TPD_G;
            currCompData.id(1)           <= '0'                        after TPD_G;
            currCompData.index           <= ibDesc.compIdx             after TPD_G;
            currCompData.valid           <= nextCompWrite              after TPD_G;

         end if;
      end if;
   end process;

   -- ASync states
   process ( currState, ibDesc, currDone, burstCount, ackCount, currError, frameLength,
             ibPpi, wordCount, axiWriteFromCntrl, currLength ) begin

      -- Init signals
      nextState     <= currState;
      nextDone      <= currDone;
      burstCountEn  <= '0';
      wordCountEn   <= '0';
      dataValid     <= '0';
      dataLast      <= '0';
      countReset    <= '0';
      ibDescClear   <= '0';
      ibPpiStart    <= '0';
      ibPpiRead     <= '0';
      nextCompWrite <= '0';
      addrValid     <= '0';

      -- Detect error
      if axiWriteFromCntrl.bvalid = '1' and axiWriteFromCntrl.bresp /= 0 then
         nextError(1) <= '1'; -- Write error
      else
         nextError <= currError;
      end if;

      -- State machine
      case currState is 

         -- Idle
         when ST_IDLE =>
            countReset <= '1';
            nextError  <= (others=>'0');

            -- Wait for ib desc to be valid
            if ibDesc.ready = '1' then
               ibPpiStart <= '1';

               -- Drop is set
               if ibDesc.drop = '1' then
                  nextState  <= ST_DROP;
               else
                  nextState  <= ST_ADDR;
               end if;
            end if;

         -- Address
         when ST_ADDR =>

            -- Wait for controller to be ready
            if axiWriteFromCntrl.afull = '0' then
               addrValid  <= '1';
               nextState  <= ST_WRITE;
            end if;

         -- Write data
         when ST_WRITE =>

            -- Assert data valid
            dataValid <= uOr(ibPpi.valid) or currDone;

            -- Data is moving
            if (ibPpi.valid /= 0 or currDone = '1') then

               -- Assert read
               ibPpiRead   <= not currDone;
               wordCountEn <= '1';
               
               -- EOF is set
               if ibPpi.eof = '1' then
                  nextDone     <= '1';
                  nextError(3) <= ibPpi.err;
               end if;

               -- Last word
               if wordCount = currLength then
                  dataLast  <= '1';
                  nextState <= ST_CHECK;
               end if;
            end if;

         -- Check state, de-assert request
         when ST_CHECK =>
            burstCountEn <= '1';
            nextDone     <= '0';

            -- Transfer is done
            if currDone = '1' then

               if frameLength /= ibDesc.length then
                  nextError(2) <= '1'; -- Length error
               end if;

               nextState <= ST_WAIT;
            else
               nextState <= ST_ADDR;
            end if;

         -- Wait for writes to complete
         when ST_WAIT =>

            -- Writes have completed
            if burstCount = ackCount and ibDesc.compReady = '1' then
               nextCompWrite <= ibDesc.compEn;
               nextState     <= ST_CLEAR;
            end if;

         -- Drop data
         when ST_DROP =>

            -- Flush FIFO
            ibPpiRead <= uOr(ibPpi.valid);

            -- EOF
            if ibPpi.eof = '1' then
               nextState    <= ST_CLEAR;
               nextError(3) <= ibPpi.err;
            end if;

         -- Clear Descriptor
         when ST_CLEAR =>
            ibDescClear <= '1';
            nextState   <= ST_IDLE;

         when others =>
            nextState <= ST_IDLE;
      end case;
   end process;


   -----------------------------------------
   -- Completion FIFO
   -----------------------------------------
   U_CompFifo : entity work.Fifo
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         RST_ASYNC_G     => false,
         GEN_SYNC_FIFO_G => true,
         BRAM_EN_G       => false, -- Use dist ram
         FWFT_EN_G       => true,
         USE_DSP48_G     => "no",
         USE_BUILT_IN_G  => false,
         XIL_DEVICE_G    => "7SERIES",
         SYNC_STAGES_G   => 3,
         DATA_WIDTH_G    => 36,
         ADDR_WIDTH_G    => 4,
         INIT_G          => "0",
         FULL_THRES_G    => 15,
         EMPTY_THRES_G   => 1
      ) port map (
         rst                => axiClkRstInt,
         wr_clk             => axiClk,
         wr_en              => currCompData.valid,
         din                => compFifoDin,
         wr_data_count      => open,
         wr_ack             => open,
         overflow           => open,
         prog_full          => open,
         almost_full        => open,
         full               => open,
         not_full           => open,
         rd_clk             => axiClk,
         rd_en              => compToFifo.read,
         dout               => compFifoDout,
         rd_data_count      => open,
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

