-------------------------------------------------------------------------------
-- Title      : RCE Generation 3 DMA channel, PPI Architecture
-- Project    : General Purpose Core
-------------------------------------------------------------------------------
-- File       : RceG3DmaChannelAxis.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2014-04-25
-- Last update: 2014-05-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- AXI Stream DMA based channel for RCE core DMA. PPI architecture.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/25/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.AxiDmaPkg.all;
use work.RceG3Pkg.all;
use work.PpiPkg.all;

entity RceG3DmaPpi is
   generic (
      TPD_G            : time                := 1 ns
   );
   port (

      -- Clock/Reset
      axiDmaClk           : in  sl;
      axiDmaRst           : in  sl;

      -- AXI ACP Slave
      acpWriteSlave       : in  AxiWriteSlaveType;
      acpWriteMaster      : out AxiWriteMasterType;
      acpReadSlave        : in  AxiReadSlaveType;
      acpReadMaster       : out AxiReadMasterType;

      -- AXI HP Slave
      hpWriteSlave        : in  AxiWriteSlaveArray(3 downto 0);
      hpWriteMaster       : out AxiWriteMasterArray(3 downto 0);
      hpReadSlave         : in  AxiReadSlaveArray(3 downto 0);
      hpReadMaster        : out AxiReadMasterArray(3 downto 0);

      -- Local AXI Lite Bus, 0x500n0000
      axilReadMaster      : in  AxiLiteReadMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilReadSlave       : out AxiLiteReadSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilWriteMaster     : in  AxiLiteWriteMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilWriteSlave      : out AxiLiteWriteSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);

      -- Interrupts
      interrupt           : out slv(DMA_INT_COUNT_C-1 downto 0);

      -- External DMA Interfaces
      dmaClk              : in  slv(3 downto 0);
      dmaClkRst           : in  slv(3 downto 0);
      dmaState            : out RceDmaStateArray(3 downto 0);
      dmaObMaster         : out AxiStreamMasterArray(3 downto 0);
      dmaObSlave          : in  AxiStreamSlaveArray(3 downto 0);
      dmaIbMaster         : in  AxiStreamMasterArray(3 downto 0);
      dmaIbSlave          : out AxiStreamSlaveArray(3 downto 0)
   );
end RceG3DmaPpi;

architecture structure of RceG3DmaPpi is 

   constant LOOP_FIFO_COUNT_C : integer := 4;

   signal iacpReadMaster  : AxiReadMasterArray(7 downto 0);
   signal iacpReadSlave   : AxiReadSlaveArray(7 downto 0);
   signal muxReadMaster   : AxiReadMasterType;
   signal muxReadSlave    : AxiReadSlaveType;
   signal iacpWriteMaster : AxiWriteMasterArray(3 downto 0);
   signal iacpWriteSlave  : AxiWriteSlaveArray(3 downto 0);
   signal muxWriteMaster  : AxiWriteMasterType;
   signal muxWriteSlave   : AxiWriteSlaveType;
   signal compValid       : slv(7 downto 0);
   signal compSel         : SlV32Array(7 downto 0);
   signal compDin         : Slv31Array(7 downto 0);
   signal compRead        : slv(7 downto 0);
   signal icompRead       : Slv8Array(PPI_COMP_CNT_C-1 downto 0);
   signal compFifoWrite   : slv(PPI_COMP_CNT_C-1 downto 0);
   signal compFifoDin     : Slv32Array(PPI_COMP_CNT_C-1 downto 0);
   signal compFifoAFull   : slv(PPI_COMP_CNT_C-1 downto 0);
   signal compFifoValid   : slv(PPI_COMP_CNT_C-1 downto 0);
   signal ibPendValid     : slv(3 downto 0);
   signal ibWorkAFull     : slv(3 downto 0);
   signal obFreeAEmpty    : slv(3 downto 0);
   signal obWorkAFull     : slv(3 downto 0);
   signal compFifoClk     : slv(PPI_COMP_CNT_C-1 downto 0);
   signal compFifoRst     : slv(PPI_COMP_CNT_C-1 downto 0);
   signal loopFifoValid   : slv(LOOP_FIFO_COUNT_C-1 downto 0);
   signal loopFifoAEmpty  : slv(LOOP_FIFO_COUNT_C-1 downto 0);

begin

   interrupt(3  downto  0) <= ibPendValid;
   interrupt(7  downto  4) <= ibWorkAFull;
   interrupt(11 downto  8) <= obFreeAEmpty;
   interrupt(15 downto 12) <= obWorkAFull;
   interrupt(19 downto 16) <= loopFifoValid;
   interrupt(23 downto 20) <= loopFifoAEmpty;

   interrupt(PPI_COMP_CNT_C+23 downto 24) <= compFifoValid;

   U_UnusedInt : if DMA_INT_COUNT_C > (PPI_COMP_CNT_C+24) generate
      interrupt(DMA_INT_COUNT_C-1 downto PPI_COMP_CNT_C+24) <= (others=>'0');
   end generate;


   -- Sockets
   U_PpiGen : for i in 0 to 3 generate
      U_PpiSocket : entity work.PpiSocket
         generic map (
            TPD_G     => TPD_G,
            CHAN_ID_G => i
         ) port map (
            axiClk           => axiDmaClk,
            axiRst           => axiDmaRst,
            axilReadMaster   => axilReadMaster((i*2)+1 downto i*2),
            axilReadSlave    => axilReadSlave((i*2)+1 downto i*2),
            axilWriteMaster  => axilWriteMaster((i*2)+1 downto i*2),
            axilWriteSlave   => axilWriteSlave((i*2)+1 downto i*2),
            acpReadMaster    => iacpReadMaster((i*2)+1 downto i*2),
            acpReadSlave     => iacpReadSlave((i*2)+1 downto i*2),
            acpWriteMaster   => iacpWriteMaster(i),
            acpWriteSlave    => iacpWriteSlave(i),
            hpReadMaster     => hpReadMaster(i),
            hpReadSlave      => hpReadSlave(i),
            hpWriteMaster    => hpWriteMaster(i),
            hpWriteSlave     => hpWriteSlave(i),
            compValid        => compValid((i*2)+1 downto i*2),
            compSel          => compSel((i*2)+1 downto i*2),
            compDin          => compDin((i*2)+1 downto i*2),
            compRead         => compRead((i*2)+1 downto i*2),
            ibPendValid      => ibPendValid(i),
            ibWorkAFull      => ibWorkAFull(i),
            obFreeAEmpty     => obFreeAEmpty(i),
            obWorkAFull      => obWorkAFull(i),
            dmaClk           => dmaClk(i),
            dmaClkRst        => dmaClkRst(i),
            dmaState         => dmaState(i),
            dmaIbMaster      => dmaIbMaster(i),
            dmaIbSlave       => dmaIbSlave(i),
            dmaObMaster      => dmaObMaster(i),
            dmaObSlave       => dmaObSlave(i)
         );
   end generate;


   -- Completion Routers
   U_CompGen: for i in 0 to PPI_COMP_CNT_C-1 generate
      U_PpiCompCtrl : entity work.PpiCompCtrl
         generic map (
            TPD_G      => TPD_G,
            CHAN_ID_G  => i
         ) port map (
            axiClk           => axiDmaClk,
            axiRst           => axiDmaRst,
            compValid        => compValid,
            compSel          => compSel,
            compDin          => compDin,
            compRead         => icompRead(i),
            compFifoWrite    => compFifoWrite(i),
            compFifoDin      => compFifoDin(i),
            compFifoAFull    => compFifoAFull(i)
         );
   end generate;


   -- Combine reads
   process (icompRead) begin
      compRead <= (others=>'0');
      for d in 0 to 7 loop
         for s in 0 to PPI_COMP_CNT_C-1 loop
            if icompRead(s)(d) = '1' then
               compRead(d) <= '1';
            end if;
         end loop;
      end loop;
   end process;


   -- Completion FIFOs & Utility FIFOs
   U_AxiLiteFifoPop : entity work.AxiLiteFifoPop 
      generic map (
         TPD_G              => TPD_G,
         POP_FIFO_COUNT_G   => PPI_COMP_CNT_C,
         POP_SYNC_FIFO_G    => true,
         POP_BRAM_EN_G      => true,
         POP_ADDR_WIDTH_G   => 9,
         LOOP_FIFO_EN_G     => true,
         LOOP_FIFO_COUNT_G  => 4,
         LOOP_BRAM_EN_G     => true,
         LOOP_ADDR_WIDTH_G  => 9,
         RANGE_LSB_G        => 8,
         VALID_POSITION_G   => 0,
         VALID_POLARITY_G   => '0',
         USE_BUILT_IN_G     => false,
         XIL_DEVICE_G       => "7SERIES"
      ) port map (

         -- AXI Interface
         axiClk             => axiDmaClk,
         axiClkRst          => axiDmaRst,
         axiReadMaster      => axilReadMaster(8),
         axiReadSlave       => axilReadSlave(8),
         axiWriteMaster     => axilWriteMaster(8),
         axiWriteSlave      => axilWriteSlave(8),
         popFifoValid       => compFifoValid,
         popFifoAEmpty      => open,
         loopFifoValid      => loopFifoValid,
         loopFifoAEmpty     => loopFifoAEmpty,
         popFifoClk         => compFifoClk,
         popFifoRst         => compFifoRst,
         popFifoWrite       => compFifoWrite,
         popFifoDin         => compFifoDin,
         popFifoFull        => open,
         popFifoAFull       => compFifoAFull
      );

   compFifoClk <= (others=>axiDmaClk);
   compFifoRst <= (others=>axiDmaRst);


   -- ACP Write Mux
   U_AxiWritePathMux : entity work.AxiWritePathMux
      generic map (
         TPD_G        => TPD_G,
         NUM_SLAVES_G => 4
      ) port map (
         axiClk           => axiDmaClk,
         axiRst           => axiDmaRst,
         sAxiWriteMasters => iacpWriteMaster,
         sAxiWriteSlaves  => iacpWriteSlave,
         mAxiWriteMaster  => muxWriteMaster,
         mAxiWriteSlave   => muxWriteSlave
      );


   -- ACP Write FIFO
   U_AxiWritePathFifo : entity work.AxiWritePathFifo
      generic map (
         TPD_G                    => TPD_G,
         XIL_DEVICE_G             => "7SERIES",
         USE_BUILT_IN_G           => false,
         GEN_SYNC_FIFO_G          => true,
         ALTERA_SYN_G             => false,
         ALTERA_RAM_G             => "M9K",
         ADDR_LSB_G               => 3,
         ID_FIXED_EN_G            => false,
         SIZE_FIXED_EN_G          => true,
         BURST_FIXED_EN_G         => true,
         LEN_FIXED_EN_G           => false,
         LOCK_FIXED_EN_G          => true,
         PROT_FIXED_EN_G          => true,
         CACHE_FIXED_EN_G         => true,
         ADDR_BRAM_EN_G           => true, 
         ADDR_CASCADE_SIZE_G      => 1,
         ADDR_FIFO_ADDR_WIDTH_G   => 9,
         DATA_BRAM_EN_G           => true,
         DATA_CASCADE_SIZE_G      => 1,
         DATA_FIFO_ADDR_WIDTH_G   => 9,
         DATA_FIFO_PAUSE_THRESH_G => 456,
         RESP_BRAM_EN_G           => false,
         RESP_CASCADE_SIZE_G      => 1,
         RESP_FIFO_ADDR_WIDTH_G   => 4,
         AXI_CONFIG_G             => AXI_ACP_INIT_C
      ) port map (
         sAxiClk         => axiDmaClk,
         sAxiRst         => axiDmaRst,
         sAxiWriteMaster => muxWriteMaster,
         sAxiWriteSlave  => muxWriteSlave,
         sAxiCtrl        => open,
         mAxiClk         => axiDmaClk,
         mAxiRst         => axiDmaRst,
         mAxiWriteMaster => acpWriteMaster,
         mAxiWriteSlave  => acpWriteSlave
      );


   -- ACP Read Mux
   U_AxiReadPathMux : entity work.AxiReadPathMux
      generic map (
         TPD_G        => TPD_G,
         NUM_SLAVES_G => 8
      ) port map (
         axiClk          => axiDmaClk,
         axiRst          => axiDmaRst,
         sAxiReadMasters => iacpReadMaster,
         sAxiReadSlaves  => iacpReadSlave,
         mAxiReadMaster  => muxReadMaster,
         mAxiReadSlave   => muxReadSlave
      );


   -- ACP Read FIFO
   U_AxiReadPathFifo : entity work.AxiReadPathFifo 
      generic map (
         TPD_G                    => TPD_G,
         XIL_DEVICE_G             => "7SERIES",
         USE_BUILT_IN_G           => false,
         GEN_SYNC_FIFO_G          => true,
         ALTERA_SYN_G             => false,
         ALTERA_RAM_G             => "M9K",
         ADDR_LSB_G               => 3,
         ID_FIXED_EN_G            => false,
         SIZE_FIXED_EN_G          => true,
         BURST_FIXED_EN_G         => true,
         LEN_FIXED_EN_G           => false,
         LOCK_FIXED_EN_G          => true,
         PROT_FIXED_EN_G          => true,
         CACHE_FIXED_EN_G         => true,
         ADDR_BRAM_EN_G           => false, 
         ADDR_CASCADE_SIZE_G      => 1,
         ADDR_FIFO_ADDR_WIDTH_G   => 4,
         DATA_BRAM_EN_G           => false,
         DATA_CASCADE_SIZE_G      => 1,
         DATA_FIFO_ADDR_WIDTH_G   => 4,
         AXI_CONFIG_G             => AXI_ACP_INIT_C
      ) port map (
         sAxiClk        => axiDmaClk,
         sAxiRst        => axiDmaRst,
         sAxiReadMaster => muxReadMaster,
         sAxiReadSlave  => muxReadSlave,
         mAxiClk        => axiDmaClk,
         mAxiRst        => axiDmaRst,
         mAxiReadMaster => acpReadMaster,
         mAxiReadSlave  => acpReadSlave
      );

end structure;

