-------------------------------------------------------------------------------
-- Title      : RCE Generation 3 DMA, AXI Streaming
-- Project    : General Purpose Core
-------------------------------------------------------------------------------
-- File       : RceG3DmaAxis.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2014-04-25
-- Last update: 2016-10-27
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- AXI Stream DMA based channel for RCE core DMA. AXI streaming.
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
use work.RceG3Pkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.AxiDmaPkg.all;

entity RceG3DmaAxis is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clock/Reset
      axiDmaClk       : in  sl;
      axiDmaRst       : in  sl;
      -- AXI ACP Slave
      acpWriteSlave   : in  AxiWriteSlaveType;
      acpWriteMaster  : out AxiWriteMasterType;
      acpReadSlave    : in  AxiReadSlaveType;
      acpReadMaster   : out AxiReadMasterType;
      -- AXI HP Slave
      hpWriteSlave    : in  AxiWriteSlaveArray(3 downto 0);
      hpWriteMaster   : out AxiWriteMasterArray(3 downto 0);
      hpReadSlave     : in  AxiReadSlaveArray(3 downto 0);
      hpReadMaster    : out AxiReadMasterArray(3 downto 0);
      -- User memory access
      userWriteSlave  : out AxiWriteSlaveType;
      userWriteMaster : in  AxiWriteMasterType;
      userReadSlave   : out AxiReadSlaveType;
      userReadMaster  : in  AxiReadMasterType;
      -- Local AXI Lite Bus, 0x600n0000
      axilReadMaster  : in  AxiLiteReadMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilReadSlave   : out AxiLiteReadSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilWriteMaster : in  AxiLiteWriteMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilWriteSlave  : out AxiLiteWriteSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);
      -- Interrupts
      interrupt       : out slv(DMA_INT_COUNT_C-1 downto 0);
      -- External DMA Interfaces
      dmaClk          : in  slv(3 downto 0);
      dmaClkRst       : in  slv(3 downto 0);
      dmaState        : out RceDmaStateArray(3 downto 0);
      dmaObMaster     : out AxiStreamMasterArray(3 downto 0);
      dmaObSlave      : in  AxiStreamSlaveArray(3 downto 0);
      dmaIbMaster     : in  AxiStreamMasterArray(3 downto 0);
      dmaIbSlave      : out AxiStreamSlaveArray(3 downto 0));
end RceG3DmaAxis;

architecture mapping of RceG3DmaAxis is

   signal intWriteSlave  : AxiWriteSlaveArray(3 downto 0);
   signal intWriteMaster : AxiWriteMasterArray(3 downto 0);
   signal intReadSlave   : AxiReadSlaveArray(3 downto 0);
   signal intReadMaster  : AxiReadMasterArray(3 downto 0);

   -- Caching enabled for ACP port
   constant AXI_CACHE_C : Slv4Array(3 downto 0) := ("0000", "0010", "0000", "0000");

begin

   -- HP for channel 0 & 1
   intWriteSlave(1 downto 0) <= hpWriteSlave(1 downto 0);
   hpWriteMaster(1 downto 0) <= intWriteMaster(1 downto 0);
   intReadSlave(1 downto 0)  <= hpReadSlave(1 downto 0);
   hpReadMaster(1 downto 0)  <= intReadMaster(1 downto 0);

   -- ACP for channel 2
   intWriteSlave(2) <= acpWriteSlave;
   acpWriteMaster   <= intWriteMaster(2);
   intReadSlave(2)  <= acpReadSlave;
   acpReadMaster    <= intReadMaster(2);

   -- HP 2 goes to user space
   userWriteSlave   <= hpWriteSlave(2);
   hpWriteMaster(2) <= userWriteMaster;
   userReadSlave    <= hpReadSlave(2);
   hpReadMaster(2)  <= userReadMaster;

   -- HP for channel 3
   intWriteSlave(3) <= hpWriteSlave(3);
   hpWriteMaster(3) <= intWriteMaster(3);
   intReadSlave(3)  <= hpReadSlave(3);
   hpReadMaster(3)  <= intReadMaster(3);

   -- Unused Interrupts
   interrupt(DMA_INT_COUNT_C-1 downto 4) <= (others => '0');

   -- Terminate Unused AXI-Lite Interfaces
   U_AxiLiteEmpty : entity work.AxiLiteEmpty
      generic map (
         TPD_G => TPD_G)
      port map (
         axiClk         => axiDmaClk,
         axiClkRst      => axiDmaRst,
         axiReadMaster  => axilReadMaster(8),
         axiReadSlave   => axilReadSlave(8),
         axiWriteMaster => axilWriteMaster(8),
         axiWriteSlave  => axilWriteSlave(8));

   ------------------------------------------
   -- DMA Channels
   ------------------------------------------
   U_DmaChanGen : for i in 0 to 3 generate
      U_RxG3DmaAxiChan: entity work.RceG3DmaAxisChan
         generic map (
            TPD_G        => TPD_G,
            AXI_CACHE_G  => AXI_CACHE_C(i),
            BYP_SHIFT_G  => ite((i=3),false,true),  -- APP DMA driver enforces alignment, which means shift not required
            AXI_CONFIG_G => ite((i=2),AXI_ACP_INIT_C,AXI_HP_INIT_C))
         port map (
            axiDmaClk        => axiDmaClk,
            axiDmaRst        => axiDmaRst,
            axiReadMaster    => intReadMaster(i),
            axiReadSlave     => intReadSlave(i),
            axiWriteMaster   => intWriteMaster(i),
            axiWriteSlave    => intWriteSlave(i),
            axilReadMaster   => axilReadMaster((i*2)+1 downto i*2),
            axilReadSlave    => axilReadSlave((i*2)+1 downto i*2),
            axilWriteMaster  => axilWriteMaster((i*2)+1 downto i*2),
            axilWriteSlave   => axilWriteSlave((i*2)+1 downto i*2),
            interrupt        => interrupt(i),
            dmaClk           => dmaClk(i),
            dmaClkRst        => dmaClkRst(i),
            dmaState         => dmaState(i),
            dmaObMaster      => dmaObMaster(i),
            dmaObSlave       => dmaObSlave(i),
            dmaIbMaster      => dmaIbMaster(i),
            dmaIbSlave       => dmaIbSlave(i));
   end generate;

end mapping;
