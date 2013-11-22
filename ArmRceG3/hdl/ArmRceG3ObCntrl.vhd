-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Outbound FIFOs
-- File          : ArmRceG3ObCntrl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- FIFO controller for outbound header FIFOs
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

entity ArmRceG3ObCntrl is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clock
      axiClk                  : in  sl;
      axiClkRst               : in  std_logic;

      -- AXI ACP Master
      axiAcpSlaveReadFromArm  : in  AxiReadSlaveType;
      axiAcpSlaveReadToArm    : out AxiReadMasterType;

      -- Transmit Descriptor write
      headerPtrWrite          : in  slv(3  downto 0);
      headerPtrData           : in  slv(35 downto 0);

      -- FIFO Read 
      freePtrSel              : in  slv(1  downto 0);
      freePtrData             : out slv(31 downto 0);
      freePtrRd               : in  sl;
      freePtrRdValid          : out sl;

      -- Configuration
      memBaseAddress          : in  slv(31 downto 18);      -- Lower bits from free list FIFO
      fifoEnable              : in  slv(3  downto  0);      -- 0-3 = header
      readDmaCache            : in  slv(3  downto 0);       -- Used in AXI transactions

      -- Header FIFO Interface
      obHeaderToFifo          : in  ObHeaderToFifoVector(3 downto 0);
      obHeaderFromFifo        : out ObHeaderFromFifoVector(3 downto 0)
   );
end ArmRceG3ObCntrl;

architecture structure of ArmRceG3ObCntrl is

   -- Local signals
   signal headerDmaId        : Slv3Array(3 downto 0);
   signal axiReadToCntrl     : AxiReadToCntrlVector(3 downto 0);
   signal axiReadFromCntrl   : AxiReadFromCntrlVector(3 downto 0);
   signal freePtrWrite       : slv(3 downto 0);
   signal freePtrDin         : Slv18Array(3 downto 0);
   signal freePtrDout        : Slv18Array(3 downto 0);
   signal freePtrRead        : slv(3 downto 0);
   signal freePtrReadDly     : sl;
   signal freePtrValid       : slv(3 downto 0);

   -- Mark For Debug
   attribute mark_debug                       : string;
   attribute mark_debug of axiReadToCntrl     : signal is "true";
   attribute mark_debug of axiReadFromCntrl   : signal is "true";
   --attribute mark_debug of freePtrWrite       : signal is "true";
   --attribute mark_debug of freePtrRead        : signal is "true";
   --attribute mark_debug of freePtrReadDly     : signal is "true";
   --attribute mark_debug of freePtrValid       : signal is "true";

begin

   -----------------------------------------
   -- Read Controller
   -----------------------------------------
   U_ReadCntrl : entity work.AxiRceG3AxiReadCntrl 
      generic map (
         TPD_G      => TPD_G,
         CHAN_CNT_G => 4
      ) port map (
         axiClk               => axiClk,
         axiClkRst            => axiClkRst,
         axiSlaveReadFromArm  => axiAcpSlaveReadFromArm,
         axiSlaveReadToArm    => axiAcpSlaveReadToArm,
         readDmaCache         => readDmaCache,
         axiReadToCntrl       => axiReadToCntrl,
         axiReadFromCntrl     => axiReadFromCntrl
      );

   ------------------------------------------------------
   -- Header FIFOs
   ------------------------------------------------------
   U_HeaderFifoGen: for i in 0 to 3 generate

      U_ObHeaderFifo: entity work.ArmRceG3ObHeaderFifo 
         generic map (
            TPD_G      => TPD_G
         ) port map (
            axiClk                  => axiClk,
            axiClkRst               => axiClkRst,
            axiReadToCntrl          => axiReadToCntrl(i),
            axiReadFromCntrl        => axiReadFromCntrl(i),
            headerPtrWrite          => headerPtrWrite(i),
            headerPtrData           => headerPtrData,
            freePtrWrite            => freePtrWrite(i),
            freePtrData             => freePtrDin(i),
            memBaseAddress          => memBaseAddress,
            fifoEnable              => fifoEnable(i),
            headerReadDmaId         => headerDmaId(i),
            obHeaderToFifo          => obHeaderToFifo(i),
            obHeaderFromFifo        => obHeaderFromFifo(i)
         );

         -- Generate DMA IDs
         headerDmaId(i) <= "0" & conv_std_logic_vector(i,2);

   end generate;

   ------------------------------------------------------
   -- Free List FIFOs
   ------------------------------------------------------
   U_FifoGen: for i in 0 to 3 generate
      U_CompFifo : entity work.FifoSyncBuiltIn 
         generic map (
            TPD_G          => TPD_G,
            RST_POLARITY_G => '1',
            FWFT_EN_G      => true,
            USE_DSP48_G    => "no",
            XIL_DEVICE_G   => "7SERIES",
            DATA_WIDTH_G   => 18,
            ADDR_WIDTH_G   => 11,
            FULL_THRES_G   => 479,
            EMPTY_THRES_G  => 1
         ) port map (
            rst               => axiClkRst,
            clk               => axiClk,
            wr_en             => freePtrWrite(i),
            din               => freePtrDin(i),
            data_count        => open,
            wr_ack            => open,
            overflow          => open,
            prog_full         => open,
            almost_full       => open,
            full              => open,
            not_full          => open,
            rd_en             => freePtrRead(i),
            dout              => freePtrDout(i),
            valid             => freePtrValid(i),
            underflow         => open,
            prog_empty        => open,
            almost_empty      => open,
            empty             => open
         );
   end generate;

   -----------------------------------------
   -- FIFO Read
   -----------------------------------------
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         freePtrRdValid <= '0'           after TPD_G;
         freePtrRead    <= (others=>'0') after TPD_G;
         freePtrReadDly <= '0'           after TPD_G;
         freePtrData    <= (others=>'0') after TPD_G;
      elsif rising_edge(axiClk) then
         freePtrReadDly <= freePtrRd      after TPD_G;
         freePtrRdValid <= freePtrReadDly after TPD_G;

         freePtrRead(conv_integer(freePtrSel)) <= freePtrRd after TPD_G;

         freePtrData(17 downto  0) <= freePtrDout(conv_integer(freePtrSel))  after TPD_G;
         freePtrData(30 downto 18) <= (others=>'0')                            after TPD_G;
         freePtrData(31)           <= freePtrValid(conv_integer(freePtrSel)) after TPD_G;

      end if;
   end process;

end architecture structure;

