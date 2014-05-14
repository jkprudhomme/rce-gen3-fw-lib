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
-- Copyright (c) 2014 by Ryan Herbst. All rights reserved.
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

entity RceG3DmaPpi is
   generic (
      TPD_G            : time                := 1 ns;
      DMA_AXIL_COUNT_G : positive            := 4;
      DMA_INT_COUNT_G  : positive            := 4
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

      -- Local AXI Lite Bus
      axilReadMaster      : in  AxiLiteReadMasterArray(DMA_AXIL_COUNT_G-1 downto 0);
      axilReadSlave       : out AxiLiteReadSlaveArray(DMA_AXIL_COUNT_G-1 downto 0);
      axilWriteMaster     : in  AxiLiteWriteMasterArray(DMA_AXIL_COUNT_G-1 downto 0);
      axilWriteSlave      : out AxiLiteWriteSlaveArray(DMA_AXIL_COUNT_G-1 downto 0);

      -- Interrupts
      interrupt           : out slv(DMA_INT_COUNT_G-1 downto 0);

      -- External DMA Interfaces
      dmaClk              : in  slv(3 downto 0);
      dmaClkRst           : in  slv(3 downto 0);
      dmaOnline           : out slv(3 downto 0);
      dmaEnable           : out slv(3 downto 0);
      dmaObMaster         : out AxiStreamMasterArray(3 downto 0);
      dmaObSlave          : in  AxiStreamSlaveArray(3 downto 0);
      dmaIbMaster         : in  AxiStreamMasterArray(3 downto 0);
      dmaIbSlave          : out AxiStreamSlaveArray(3 downto 0)
   );
end RceG3DmaPpi;

architecture structure of RceG3DmaPpi is 

begin

   acpWriteMaster  <= AXI_WRITE_MASTER_INIT_C;
   acpReadMaster   <= AXI_READ_MASTER_INIT_C;
   hpWriteMaster   <= (others=>AXI_WRITE_MASTER_INIT_C);
   hpReadMaster    <= (others=>AXI_READ_MASTER_INIT_C);
   interrupt       <= (others=>'0');
   dmaOnline       <= (others=>'0');
   dmaEnable       <= (others=>'0');
   dmaObMaster     <= (others=>AXI_STREAM_MASTER_INIT_C);
   dmaIbSlave      <= (others=>AXI_STREAM_SLAVE_INIT_C);

   U_EmptyGen : for i in 0 to DMA_AXIL_COUNT_G-1 generate

      -- Terminate Unused AXI-Lite Interface
      U_AxiLiteEmpty : entity work.AxiLiteEmpty
         generic map (
            TPD_G  => TPD_G
         ) port map (
            axiClk          => axiDmaClk,
            axiClkRst       => axiDmaRst,
            axiReadMaster   => axilReadMaster(i),
            axiReadSlave    => axilReadSlave(i),
            axiWriteMaster  => axilWriteMaster(i),
            axiWriteSlave   => axilWriteSlave(i)
         );
   end generate;

end structure;

