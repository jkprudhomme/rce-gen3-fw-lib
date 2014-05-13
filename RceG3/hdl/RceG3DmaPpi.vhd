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
      AXIL_BASE_ADDR_G : slv(31 downto 0)    := x"00000000"
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
      axilReadMaster      : in  AxiLiteReadMasterType;
      axilReadSlave       : out AxiLiteReadSlaveType;
      axilWriteMaster     : in  AxiLiteWriteMasterType;
      axilWriteSlave      : out AxiLiteWriteSlaveType;

      -- Interrupts
      interrupt           : out slv(15 downto 0);

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
   axilReadSlave   <= AXI_LITE_READ_SLAVE_INIT_C;
   axilWriteSlave  <= AXI_LITE_WRITE_SLAVE_INIT_C;
   interrupt       <= (others=>'0');
   dmaOnline       <= (others=>'0');
   dmaEnable       <= (others=>'0');
   dmaObMaster     <= (others=>AXI_STREAM_MASTER_INIT_C);
   dmaIbSlave      <= (others=>AXI_STREAM_SLAVE_INIT_C);

end structure;

