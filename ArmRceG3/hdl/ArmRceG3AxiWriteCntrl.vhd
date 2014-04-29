-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, AXI Write Controller
-- File          : AxiRceG3AxiWriteCntrl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 10/02/2013
-------------------------------------------------------------------------------
-- Description:
-- This block bridges between the AXI write interface and a variable number 
-- of blocks which generate write traffic on the AXI bus. This block contains a
-- FIFO to decouple the AXI write interface from the individual state machines
-- in the writing blocks. 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 10/02/2013: created.
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
use work.AxiPkg.all;

entity AxiRceG3AxiWriteCntrl is
   generic (
      TPD_G      : time     := 1 ns;
      CHAN_CNT_G : positive := 1    -- 1 or 9
   );
   port (

      -- Clock & reset
      axiClk                  : in  sl;
      axiClkRst               : in  sl;

      -- AXI Write Interface
      axiSlaveWriteFromArm    : in  AxiWriteSlaveType;
      axiSlaveWriteToArm      : out AxiWriteMasterType;

      -- Configuration
      writeDmaCache           : in  slv(3 downto 0);

      -- Variable number of writing blocks
      axiWriteToCntrl         : in  AxiWriteToCntrlArray(CHAN_CNT_G-1 downto 0);
      axiWriteFromCntrl       : out AxiWriteFromCntrlArray(CHAN_CNT_G-1 downto 0)
   );
end AxiRceG3AxiWriteCntrl;

architecture structure of AxiRceG3AxiWriteCntrl is

   -- Local signals
   signal arbReq                   : slv(11 downto 0);
   signal arbGnt                   : slv(11 downto 0);
   signal preGnt                   : slv(11 downto 0);
   signal preSelect                : slv(5  downto 0);
   signal arbValid                 : slv(3  downto 0);
   signal arbSelect                : slv(3  downto 0);
   signal arbSelectFilt            : slv(3  downto 0);
   signal regWriteToCntrl          : AxiWriteToCntrlArray(CHAN_CNT_G-1 downto 0);
   signal aFifoWr                  : sl;
   signal aFifoRd                  : sl;
   signal aFifoDin                 : slv(35 downto 0);
   signal aFifoDout                : slv(35 downto 0);
   signal aFifoValid               : sl;
   signal aFifoPFull               : sl;
   signal dFifoWr                  : sl;
   signal dFifoRd                  : sl;
   signal dFifoDin                 : slv(71 downto 0);
   signal dFifoDout                : slv(71 downto 0);
   signal dFifoValid               : sl;
   signal dFifoPFull               : sl;
   signal dSize                    : slv(3 downto 0);
   signal dValid                   : slv(7 downto 0);
   signal bresp                    : slv(1 downto 0);
   signal bvalid                   : slv(CHAN_CNT_G-1 downto 0);
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

   -----------------------------------------
   -- Input Registration
   -----------------------------------------

   -- Input registration stage is only used if channel count is greater than 1
   U_RegEn: if CHAN_CNT_G > 1 generate
      process ( axiClk ) begin
         if rising_edge(axiClk) then
            if axiClkRstInt = '1' then
               regWriteToCntrl <= (others=>AXI_WRITE_TO_CNTRL_INIT_C) after TPD_G;
            else
               regWriteToCntrl <= axiWriteToCntrl after TPD_G;
            end if;
         end if;
      end process;
   end generate;

   U_RegDis: if CHAN_CNT_G = 1 generate
      regWriteToCntrl <= axiWriteToCntrl;
   end generate;

   -----------------------------------------
   -- Arbitration 
   -----------------------------------------

   -- No arbiter for single channel mode
   U_ArbSingle: if CHAN_CNT_G = 1 generate
      arbGnt        <= (others=>'0');
      arbReq        <= (others=>'0');
      preGnt        <= (others=>'0');
      preSelect     <= (others=>'0');
      arbValid      <= (others=>'0');
      arbSelect     <= (others=>'0');
      arbSelectFilt <= (others=>'0');
   end generate;

   -- 9 Channel version
   U_ArbMult: if CHAN_CNT_G = 9 generate

      -- Get request signals
      process (axiWriteToCntrl) begin
         arbReq <= (others=>'0');
         for i in 0 to 8 loop
            arbReq(i) <= axiWriteToCntrl(i).req;
         end loop;
      end process;

      -- Pre-arbiters
      U_PreArb: for i in 0 to 2 generate
         U_Arbiter : entity work.Arbiter 
            generic map (
               TPD_G          => TPD_G,
               RST_POLARITY_G => '1',
               RST_ASYNC_G    => false,
               REQ_SIZE_G     => 4
            ) port map (
               clk      => axiClk,
               rst      => axiClkRstInt,
               req      => arbReq(i*4+3 downto i*4),
               selected => preSelect(i*2+1 downto i*2),
               valid    => open,
               ack      => preGnt(i*4+3 downto i*4)
            );

         -- Gate valid
         arbValid(i) <= arbReq(i*4 + conv_integer(preSelect(i*2+1 downto i*2)));

      end generate;

      -- Unused channel
      arbValid(3) <= '0';

      -- Main Arbiter
      U_Arbiter : entity work.Arbiter 
         generic map (
            TPD_G          => TPD_G,
            RST_POLARITY_G => '1',
            RST_ASYNC_G    => false,
            REQ_SIZE_G     => 4
         ) port map (
            clk      => axiClk,
            rst      => axiClkRstInt,
            req      => arbValid,
            selected => arbSelect(3 downto 2),
            valid    => open,
            ack      => open
         );

      -- Form select lines
      arbSelect(1 downto 0) <= preSelect(1 downto 0) when arbSelect(3 downto 2) = "00" else
                               preSelect(3 downto 2) when arbSelect(3 downto 2) = "01" else
                               preSelect(5 downto 4) when arbSelect(3 downto 2) = "10" else "00";

      -- Enable GNT lines
      arbGnt(3  downto  0) <= preGnt(3  downto  0) when arbSelect(3 downto 2) = "00" else x"0";
      arbGnt(7  downto  4) <= preGnt(7  downto  4) when arbSelect(3 downto 2) = "01" else x"0";
      arbGnt(11 downto  8) <= preGnt(11 downto  8) when arbSelect(3 downto 2) = "10" else x"0";

      -- Filter out of bounds and delay one clock cycle
      process ( axiClk ) begin
         if rising_edge(axiClk) then
            if axiClkRstInt = '1' then
               arbSelectFilt <= (others=>'0') after TPD_G;
            elsif arbSelect < 9 then
               arbSelectFilt <= arbSelect after TPD_G;
            else
               arbSelectFilt <= (others=>'0') after TPD_G;
            end if;
         end if;
      end process;
   end generate;


   -----------------------------------------
   -- Address Buffer
   -----------------------------------------

   -- Mux address
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            aFifoWr  <= '0'           after TPD_G;
            aFifoDin <= (others=>'0') after TPD_G;
         else
            aFifoWr                <= regWriteToCntrl(conv_integer(arbSelectFilt)).avalid  after TPD_G;
            aFifoDin(28 downto  0) <= regWriteToCntrl(conv_integer(arbSelectFilt)).address after TPD_G;
            aFifoDin(31 downto 29) <= regWriteToCntrl(conv_integer(arbSelectFilt)).id      after TPD_G;
            aFifoDin(35 downto 32) <= regWriteToCntrl(conv_integer(arbSelectFilt)).length  after TPD_G;
         end if;
      end if;
   end process;

   -- FIFO
   U_AddrFifo : entity work.Fifo
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
         FULL_THRES_G    => 450,
         EMPTY_THRES_G   => 1
      ) port map (
         rst           => axiClkRstInt,
         wr_clk        => axiClk,
         wr_en         => aFifoWr,
         din           => aFifoDin,
         wr_data_count => open,
         wr_ack        => open,
         overflow      => open,
         prog_full     => aFifoPFull,
         almost_full   => open,
         full          => open,
         not_full      => open,
         rd_clk        => axiClk,
         rd_en         => aFifoRd,
         dout          => aFifoDout,
         rd_data_count => open,
         valid         => aFifoValid,
         underflow     => open,
         prog_empty    => open,
         almost_empty  => open,
         empty         => open
      );

   -- AXI Address Channel
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            axiSlaveWriteToArm.awaddr  <= (others=>'0') after TPD_G;
            axiSlaveWriteToArm.awid    <= (others=>'0') after TPD_G;
            axiSlaveWriteToArm.awlen   <= (others=>'0') after TPD_G;
            axiSlaveWriteToArm.awvalid <= '0'           after TPD_G;
         elsif aFifoRd = '1' then
            axiSlaveWriteToArm.awaddr(31 downto 3) <= aFifoDout(28 downto 0)  after TPD_G;
            axiSlaveWriteToArm.awaddr(2  downto 0) <= "000"                   after TPD_G;
            axiSlaveWriteToArm.awid(11 downto 3)   <= "000000000"             after TPD_G;
            axiSlaveWriteToArm.awid(2  downto 0)   <= aFifoDout(31 downto 29) after TPD_G;
            axiSlaveWriteToArm.awlen               <= aFifoDout(35 downto 32) after TPD_G;
            axiSlaveWriteToArm.awvalid             <= aFifoValid              after TPD_G;
         end if;
      end if;
   end process;

   -- FIFO read control
   aFifoRd <= axiSlaveWriteFromArm.awready;

   -- Constants
   axiSlaveWriteToArm.awsize         <= "011";
   axiSlaveWriteToArm.awburst        <= "01";
   axiSlaveWriteToArm.awcache        <= writeDmaCache;
   axiSlaveWriteToArm.awlock         <= "00";
   axiSlaveWriteToArm.awprot         <= "000";

   -----------------------------------------
   -- Data Buffer
   -----------------------------------------

   -- Convert valid signals to size vector
   dsize <= "0000" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "00000000"  else
            "0001" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "00000001"  else
            "0010" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "00000011"  else
            "0011" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "00000111"  else
            "0100" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "00001111"  else
            "0101" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "00011111"  else
            "0110" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "00111111"  else
            "0111" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "01111111"  else
            "1000" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "11111111"  else
            "1001" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "11111110"  else
            "1010" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "11111100"  else
            "1011" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "11111000"  else
            "1100" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "11110000"  else
            "1101" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "11100000"  else
            "1110" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "11000000"  else
            "1111" when regWriteToCntrl(conv_integer(arbSelectFilt)).dstrobe = "10000000"  else
            "0000";

   -- Mux data
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            dFifoWr  <= '0'           after TPD_G;
            dFifoDin <= (others=>'0') after TPD_G;
         else
            dFifoWr                <= regWriteToCntrl(conv_integer(arbSelectFilt)).dvalid  after TPD_G;
            dFifoDin(63 downto  0) <= regWriteToCntrl(conv_integer(arbSelectFilt)).data    after TPD_G;
            dFifoDin(66 downto 64) <= regWriteToCntrl(conv_integer(arbSelectFilt)).id      after TPD_G;
            dFifoDin(67)           <= regWriteToCntrl(conv_integer(arbSelectFilt)).last    after TPD_G;
            dFifoDin(71 downto 68) <= dsize                                                after TPD_G;
         end if;
      end if;
   end process;

   -- FIFO
   U_DataFifo : entity work.Fifo
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
         DATA_WIDTH_G    => 72,
         ADDR_WIDTH_G    => 9,
         INIT_G          => "0",
         FULL_THRES_G    => 450,
         EMPTY_THRES_G   => 1
      ) port map (
         rst           => axiClkRstInt,
         wr_clk        => axiClk,
         wr_en         => dFifoWr,
         din           => dFifoDin,
         wr_data_count => open,
         wr_ack        => open,
         overflow      => open,
         prog_full     => dFifoPFull,
         almost_full   => open,
         full          => open,
         not_full      => open,
         rd_clk        => axiClk,
         rd_en         => dFifoRd,
         dout          => dFifoDout,
         rd_data_count => open,
         valid         => dFifoValid,
         underflow     => open,
         prog_empty    => open,
         almost_empty  => open,
         empty         => open
      );

   -- Convert size back into valid
   dValid <= "00000000" when dFifoDout(71 downto 68) = "0000" else
             "00000001" when dFifoDout(71 downto 68) = "0001" else
             "00000011" when dFifoDout(71 downto 68) = "0010" else
             "00000111" when dFifoDout(71 downto 68) = "0011" else
             "00001111" when dFifoDout(71 downto 68) = "0100" else
             "00011111" when dFifoDout(71 downto 68) = "0101" else
             "00111111" when dFifoDout(71 downto 68) = "0110" else
             "01111111" when dFifoDout(71 downto 68) = "0111" else
             "11111111" when dFifoDout(71 downto 68) = "1000" else
             "11111110" when dFifoDout(71 downto 68) = "1001" else
             "11111100" when dFifoDout(71 downto 68) = "1010" else
             "11111000" when dFifoDout(71 downto 68) = "1011" else
             "11110000" when dFifoDout(71 downto 68) = "1100" else
             "11100000" when dFifoDout(71 downto 68) = "1101" else
             "11000000" when dFifoDout(71 downto 68) = "1110" else
             "10000000" when dFifoDout(71 downto 68) = "1111" else
             "00000000";

   -- AXI Data Channel
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            axiSlaveWriteToArm.wdata   <= (others=>'0') after TPD_G;
            axiSlaveWriteToArm.wid     <= (others=>'0') after TPD_G;
            axiSlaveWriteToArm.wstrb   <= (others=>'0') after TPD_G;
            axiSlaveWriteToArm.wvalid  <= '0'           after TPD_G;
            axiSlaveWriteToArm.wlast   <= '0'           after TPD_G;
         elsif dFifoRd = '1' then
            axiSlaveWriteToArm.wdata            <= dFifoDout(63 downto  0) after TPD_G;
            axiSlaveWriteToArm.wid(11 downto 3) <= "000000000"             after TPD_G;
            axiSlaveWriteToArm.wid(2 downto 0)  <= dFifoDout(66 downto 64) after TPD_G;
            axiSlaveWriteToArm.wstrb            <= dValid                  after TPD_G;
            axiSlaveWriteToArm.wvalid           <= dFifoValid              after TPD_G;
            axiSlaveWriteToArm.wlast            <= dFifoDout(67)           after TPD_G;
         end if;
      end if;
   end process;

   -- FIFO read control
   dFifoRd <= axiSlaveWriteFromArm.wready;

   -----------------------------------------
   -- Write status distribution
   -----------------------------------------

   -- Always ready
   axiSlaveWriteToArm.bready <= '1';

   -- Distribution
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            bresp  <= (others=>'0') after TPD_G;
            bvalid <= (others=>'0') after TPD_G;
         else
            bresp  <= axiSlaveWriteFromArm.bresp after TPD_G;
            bvalid <= (others=>'0')              after TPD_G;

            for i in 0 to CHAN_CNT_G-1 loop
               if CHAN_CNT_G = 1 then
                  bvalid(i) <= axiSlaveWriteFromArm.bvalid after TPD_G;
               elsif axiSlaveWriteFromArm.bid(2 downto 0) = axiWriteToCntrl(i).id or CHAN_CNT_G = 1 then
                  bvalid(i) <= axiSlaveWriteFromArm.bvalid after TPD_G;
               end if;
            end loop;
         end if;
      end if;
   end process;

   -----------------------------------------
   -- Output
   -----------------------------------------
   U_OutGen: for i in 0 to CHAN_CNT_G-1 generate
      axiWriteFromCntrl(i).afull  <= aFifoPFull or dFifoPFull;
      axiWriteFromCntrl(i).gnt    <= arbGnt(i);
      axiWriteFromCntrl(i).bresp  <= bresp;
      axiWriteFromCntrl(i).bvalid <= bvalid(i);
   end generate;

end architecture structure;

