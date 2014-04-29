-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Inbound FIFOs
-- File          : ArmRceG3IbCntrl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- FIFO controller for inbound headers & generic quad word FIFOs
-- FIFOs 0 -3 are header burst FIFO blocks including a header engine and a
-- generic quad word FIFO for the incoming dma descriptor. 
-- FIFO 4 is for the BSI
-- FIFOs 5 - 8 are transmit header free list FIFOs (synchronous)
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

entity ArmRceG3IbCntrl is
   generic (
      TPD_G        : time                       := 1 ns;
      PPI_CONFIG_G : PpiConfigArray(3 downto 0) := (others=>PPI_CONFIG_INIT_C)
   );
   port (

      -- Clock
      axiClk                  : in  sl;
      axiClkRst               : in  sl;

      -- AXI ACP Master
      axiAcpSlaveWriteFromArm : in  AxiWriteSlaveType;
      axiAcpSlaveWriteToArm   : out AxiWriteMasterType;

      -- Memory channel dirty flags
      dirtyFlag               : out slv(4 downto 0);
      dirtyFlagClrEn          : in  sl;
      dirtyFlagClrSel         : in  slv(2 downto 0);

      -- Header pointer free list write
      headerPtrWrite          : in  slv(3 downto 0);
      headerPtrData           : in  slv(35 downto 0);

      -- Configuration
      fifoEnable              : in  slv(4  downto  0); -- 0-3 = header, 4 = BSI
      memBaseAddress          : in  slv(31 downto 18); -- Lower bits from free list FIFO
      writeDmaCache           : in  slv(3  downto  0); -- Used in AXI transactions

      -- Header FIFO Interface
      ibHeaderClk             : in  slv(3 downto 0);
      ibHeaderToFifo          : in  IbHeaderToFifoArray(3 downto 0);
      ibHeaderFromFifo        : out IbHeaderFromFifoArray(3 downto 0);

      -- Quad Word FIFO Interface
      qwordToFifo             : in  QWordToFifoType;
      qwordFromFifo           : out QWordFromFifoType
   );
end ArmRceG3IbCntrl;

architecture structure of ArmRceG3IbCntrl is

   -- Local signals
   signal idirtyFlag                : slv(4 downto 0);
   signal dirtyFlagSet              : slv(4 downto 0);
   signal headerDmaId               : Slv3Array(3 downto 0);
   signal qwordDmaId                : Slv3Array(4 downto 0);
   signal writeDmaBusyOut           : Slv8Array(4 downto 0);
   signal writeDmaBusyIn            : slv(7 downto 0);
   signal axiWriteToCntrl           : AxiWriteToCntrlArray(8 downto 0);
   signal axiWriteFromCntrl         : AxiWriteFromCntrlArray(8 downto 0);
   signal iqwordToFifo              : QWordToFifoArray(4 downto 0);
   signal iqwordFromFifo            : QWordFromFifoArray(4 downto 0);
   signal axiClkRstInt              : sl := '1';

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
   -- Dirty flags
   -----------------------------------------

   -- Set and clear flags
   U_DirtyGen: for i in 0 to 4 generate
      process ( axiClk ) begin
         if rising_edge(axiClk) then
            if axiClkRstInt = '1' then
               idirtyFlag(i) <= '0' after TPD_G;
            elsif dirtyFlagClrEn = '1' and dirtyFlagClrSel = i then
               idirtyFlag(i) <= '0' after TPD_G;
            elsif dirtyFlagSet(i) = '1' then
               idirtyFlag(i) <= '1' after TPD_G;
            end if;
         end if;
      end process;
   end generate;

   -- Output
   dirtyFlag <= idirtyFlag;

   -----------------------------------------
   -- Write Controller
   -----------------------------------------
   U_WriteCntrl : entity work.AxiRceG3AxiWriteCntrl 
      generic map (
         TPD_G      => TPD_G,
         CHAN_CNT_G => 9
      ) port map (
         axiClk               => axiClk,
         axiClkRst            => axiClkRstInt,
         axiSlaveWriteFromArm => axiAcpSlaveWriteFromArm,
         axiSlaveWriteToArm   => axiAcpSlaveWriteToArm,
         writeDmaCache        => writeDmaCache,
         axiWriteToCntrl      => axiWriteToCntrl,
         axiWriteFromCntrl    => axiWriteFromCntrl
      );


   -----------------------------------------
   -- DMA ID BUSY
   -----------------------------------------

   -- Combine dma ID busy Signals
   U_Busy: process ( writeDmaBusyOut ) begin
      writeDmaBusyIn <= (others=>'0');
      for i in 0 to 7 loop
         for j in 0 to 4 loop
            if writeDmaBusyOut(j)(i) = '1' then
               writeDmaBusyIn(i) <= '1';
            end if;
         end loop;
      end loop;
   end process;

   ------------------------------------------------------
   -- Header FIFOs
   ------------------------------------------------------
   U_HeaderFifoGen: for i in 0 to 3 generate

      U_IbHeaderFifo: entity work.ArmRceG3IbHeaderFifo 
         generic map (
            TPD_G        => TPD_G,
            PPI_CONFIG_G => PPI_CONFIG_G(i)
         ) port map (
            axiClk                  => axiClk,
            axiClkRst               => axiClkRstInt,
            axiWriteToCntrl         => axiWriteToCntrl(i),
            axiWriteFromCntrl       => axiWriteFromCntrl(i),
            headerPtrWrite          => headerPtrWrite(i),
            headerPtrData           => headerPtrData,
            fifoEnable              => fifoEnable(i),
            memBaseAddress          => memBaseAddress,
            writeDmaId              => headerDmaId(i),
            qwordToFifo             => iqwordToFifo(i),
            qwordFromFifo           => iqwordFromFifo(i),
            ibHeaderClk             => ibHeaderClk(i),
            ibHeaderToFifo          => ibHeaderToFifo(i),
            ibHeaderFromFifo        => ibHeaderFromFifo(i)
         );

         -- Generate DMA IDs
         headerDmaId(i) <= "0" & conv_std_logic_vector(i,2);

   end generate;

   -----------------------------------------
   -- Generic quad word FIFOs
   -----------------------------------------
   U_GenFifoGen: for i in 0 to 4 generate

      U_GenFifo : entity work.ArmRceG3IbQWordFifo
         generic map (
            TPD_G       => TPD_G,
            MEM_CHAN_G  => i
         ) port map (
            axiClk                  => axiClk,
            axiClkRst               => axiClkRstInt,
            axiWriteToCntrl         => axiWriteToCntrl(i+4),
            axiWriteFromCntrl       => axiWriteFromCntrl(i+4),
            memDirty                => idirtyFlag(i),
            memDirtySet             => dirtyFlagSet(i),
            writeDmaBusyOut         => writeDmaBusyOut(i),
            writeDmaBusyIn          => writeDmaBusyIn,
            fifoEnable              => fifoEnable(i),
            writeDmaId              => qwordDmaId(i),
            memBaseAddress          => memBaseAddress,
            qwordToFifo             => iqwordToFifo(i),
            qwordFromFifo           => iqwordFromFifo(i)
         );

         -- Generate DMA IDs
         qwordDmaId(i) <= "1" & conv_std_logic_vector(i,2);

   end generate;

   -- Connect quad word ports
   iqwordToFifo(4) <= qwordToFifo;
   qwordFromFifo   <= iqwordFromFifo(4);   

end architecture structure;

