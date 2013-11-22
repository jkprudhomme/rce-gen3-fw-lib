-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, AXI Read Controller
-- File          : AxiRceG3AxiReadCntrl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 10/02/2013
-------------------------------------------------------------------------------
-- Description:
-- This block bridges between the AXI read interface and a variable number 
-- of blocks which generate read traffic on the AXI bus. This block contains a
-- FIFO to decouple the AXI read interface from the individual state machines
-- in the reading blocks. 
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

entity AxiRceG3AxiReadCntrl is
   generic (
      TPD_G      : time     := 1 ns;
      CHAN_CNT_G : positive := 1    -- 1 or 4
   );
   port (

      -- Clock & reset
      axiClk                  : in  sl;
      axiClkRst               : in  sl;

      -- AXI Read Interface
      axiSlaveReadFromArm     : in  AxiReadSlaveType;
      axiSlaveReadToArm       : out AxiReadMasterType;

      -- Configuration
      readDmaCache            : in  slv(3 downto 0);

      -- Variable number of writing blocks
      axiReadToCntrl          : in  AxiReadToCntrlVector(CHAN_CNT_G-1 downto 0);
      axiReadFromCntrl        : out AxiReadFromCntrlVector(CHAN_CNT_G-1 downto 0)
   );
end AxiRceG3AxiReadCntrl;

architecture structure of AxiRceG3AxiReadCntrl is

   -- Local signals
   signal arbReq           : slv(3 downto 0);
   signal arbGnt           : slv(3 downto 0);
   signal arbSelect        : slv(1 downto 0);
   signal arbSelectFilt    : slv(1 downto 0);
   signal regReadToCntrl   : AxiReadToCntrlVector(CHAN_CNT_G-1 downto 0);
   signal aFifoWr          : sl;
   signal aFifoRd          : sl;
   signal aFifoDin         : slv(35 downto 0);
   signal aFifoDout        : slv(35 downto 0);
   signal aFifoValid       : sl;
   signal aFifoPFull       : sl;
   signal rdata            : slv(63 downto 0);
   signal rlast            : sl;
   signal rvalid           : slv(CHAN_CNT_G-1 downto 0);
   signal rresp            : slv(1 downto 0);

   -- Mark For Debug
   --attribute mark_debug                         : string;
   --attribute mark_debug of arbReq               : signal is "true";
   --attribute mark_debug of arbGnt               : signal is "true";
   --attribute mark_debug of arbSelect            : signal is "true";
   --attribute mark_debug of arbSelectFilt        : signal is "true";
   --attribute mark_debug of regReadToCntrl       : signal is "true";
   --attribute mark_debug of aFifoWr              : signal is "true";
   --attribute mark_debug of aFifoRd              : signal is "true";
   --attribute mark_debug of aFifoDin             : signal is "true";
   --attribute mark_debug of aFifoDout            : signal is "true";
   --attribute mark_debug of aFifoValid           : signal is "true";
   --attribute mark_debug of aFifoPFull           : signal is "true";
   --attribute mark_debug of rdata                : signal is "true";
   --attribute mark_debug of rlast                : signal is "true";
   --attribute mark_debug of rvalid               : signal is "true";
   --attribute mark_debug of rresp                : signal is "true";

begin

   -----------------------------------------
   -- Input Registration
   -----------------------------------------

   -- Input registration stage is only used if channel count is greater than 1
   U_RegEn: if CHAN_CNT_G > 1 generate
      process ( axiClk, axiClkRst ) begin
         if axiClkRst = '1' then
            regReadToCntrl <= (others=>AxiReadToCntrlInit) after TPD_G;
         elsif rising_edge(axiClk) then
            regReadToCntrl <= axiReadToCntrl after TPD_G;
         end if;
      end process;
   end generate;

   U_RegDis: if CHAN_CNT_G = 1 generate
      regReadToCntrl <= axiReadToCntrl;
   end generate;

   -----------------------------------------
   -- Arbitration 
   -----------------------------------------

   -- No arbiter for single channel mode
   U_ArbSingle: if CHAN_CNT_G = 1 generate
      arbGnt        <= (others=>'0');
      arbReq        <= (others=>'0');
      arbSelect     <= (others=>'0');
      arbSelectFilt <= (others=>'0');
   end generate;

   -- 4 Channel Version
   U_ArbMult: if CHAN_CNT_G = 4 generate

      -- Get request signals
      process (axiReadToCntrl) begin
         arbReq <= (others=>'0');
         for i in 0 to 3 loop
            arbReq(i) <= axiReadToCntrl(i).req;
         end loop;
      end process;

      U_Arbiter : entity work.Arbiter 
         generic map (
            TPD_G          => TPD_G,
            RST_POLARITY_G => '1',
            RST_ASYNC_G    => false,
            REQ_SIZE_G     => 4
         ) port map (
            clk      => axiClk,
            rst      => axiClkRst,
            req      => arbReq,
            selected => arbSelect,
            valid    => open,
            ack      => arbGnt
         );

      -- Delay one clock cycle
      process ( axiClk, axiClkRst ) begin
         if axiClkRst = '1' then
            arbSelectFilt <= (others=>'0') after TPD_G;
         elsif rising_edge(axiClk) then
            arbSelectFilt <= arbSelect after TPD_G;
         end if;
      end process;
   end generate;

   -----------------------------------------
   -- Address Buffer
   -----------------------------------------

   -- Mux address
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         aFifoWr  <= '0'           after TPD_G;
         aFifoDin <= (others=>'0') after TPD_G;
      elsif rising_edge(axiClk) then
         aFifoWr                <= regReadToCntrl(conv_integer(arbSelectFilt)).avalid  after TPD_G;
         aFifoDin(28 downto  0) <= regReadToCntrl(conv_integer(arbSelectFilt)).address after TPD_G;
         aFifoDin(31 downto 29) <= axiReadToCntrl(conv_integer(arbSelectFilt)).id      after TPD_G;
         aFifoDin(35 downto 32) <= regReadToCntrl(conv_integer(arbSelectFilt)).length  after TPD_G;
      end if;
   end process;

   -- FIFO
   U_AddrFifo : entity work.FifoSyncBuiltIn 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         XIL_DEVICE_G   => "7SERIES",
         DATA_WIDTH_G   => 36,
         ADDR_WIDTH_G   => 9,
         FULL_THRES_G   => 450,
         EMPTY_THRES_G  => 1
      ) port map (
         rst          => axiClkRst,
         clk          => axiClk,
         wr_en        => aFifoWr,
         rd_en        => aFifoRd,
         din          => aFifoDin,
         dout         => aFifoDout,
         data_count   => open,
         wr_ack       => open,
         valid        => aFifoValid,
         overflow     => open,
         underflow    => open,
         prog_full    => aFifoPFull,
         prog_empty   => open,
         almost_full  => open,
         almost_empty => open,
         not_full     => open,
         full         => open,
         empty        => open
      );

   -- AXI Address Channel
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         axiSlaveReadToArm.araddr  <= (others=>'0') after TPD_G;
         axiSlaveReadToArm.arid    <= (others=>'0') after TPD_G;
         axiSlaveReadToArm.arlen   <= (others=>'0') after TPD_G;
         axiSlaveReadToArm.arvalid <= '0'           after TPD_G;
      elsif rising_edge(axiClk) then
         if aFifoRd = '1' then
            axiSlaveReadToArm.araddr(31 downto 3) <= aFifoDout(28 downto 0)  after TPD_G;
            axiSlaveReadToArm.araddr(2  downto 0) <= "000"                   after TPD_G;
            axiSlaveReadToArm.arid(11 downto 3)   <= "000000000"             after TPD_G;
            axiSlaveReadToArm.arid(2 downto 0)    <= aFifoDout(31 downto 29) after TPD_G;
            axiSlaveReadToArm.arlen               <= aFifoDout(35 downto 32) after TPD_G;
            axiSlaveReadToArm.arvalid             <= aFifoValid              after TPD_G;
         end if;
      end if;
   end process;

   -- FIFO read control
   aFifoRd <= axiSlaveReadFromArm.arready;

   -- Constants
   axiSlaveReadToArm.arsize         <= "011";
   axiSlaveReadToArm.arburst        <= "01";
   axiSlaveReadToArm.arcache        <= readDmaCache;
   axiSlaveReadToArm.aruser         <= "00011";
   axiSlaveReadToArm.arlock         <= "00";
   axiSlaveReadToArm.arprot         <= "000";
   axiSlaveReadToArm.arqos          <= "0000";
   axiSlaveReadToArm.rdissuecap1_en <= '0';

   -----------------------------------------
   -- Read data  distribution
   -----------------------------------------

   -- Distribution
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         rdata  <= (others=>'0') after TPD_G;
         rlast  <= '0'           after TPD_G;
         rvalid <= (others=>'0') after TPD_G;
         rresp  <= (others=>'0') after TPD_G;
      elsif rising_edge(axiClk) then
         rdata  <= axiSlaveReadFromArm.rdata after TPD_G;
         rlast  <= axiSlaveReadFromArm.rlast after TPD_G;
         rresp  <= axiSlaveReadFromArm.rresp after TPD_G;
         rvalid <= (others=>'0')                after TPD_G;

         for i in 0 to CHAN_CNT_G-1 loop
            if CHAN_CNT_G = 1 then
               rvalid(i) <= axiSlaveReadFromArm.rvalid after TPD_G;
            elsif axiSlaveReadFromArm.rid(2 downto 0) = axiReadToCntrl(i).id then
               rvalid(i) <= axiSlaveReadFromArm.rvalid after TPD_G;
            end if;
         end loop;

      end if;
   end process;

   -- Generate ready
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         axiSlaveReadToArm.rready <= '0' after TPD_G;
      elsif rising_edge(axiClk) then
         axiSlaveReadToArm.rready <= 
            not regReadToCntrl(conv_integer(axiSlaveReadFromArm.rid(2 downto 0))).afull after TPD_G;
      end if;
   end process;

   -----------------------------------------
   -- Output
   -----------------------------------------
   U_OutGen: for i in 0 to CHAN_CNT_G-1 generate
      axiReadFromCntrl(i).afull  <= aFifoPFull;
      axiReadFromCntrl(i).gnt    <= arbGnt(i);
      axiReadFromCntrl(i).rdata  <= rdata;
      axiReadFromCntrl(i).rlast  <= rlast;
      axiReadFromCntrl(i).rvalid <= rvalid(i);
      axiReadFromCntrl(i).rresp  <= rresp;
   end generate;

end architecture structure;

