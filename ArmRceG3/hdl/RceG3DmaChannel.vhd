-------------------------------------------------------------------------------
-- Title      : RCE Generation 3 DMA channel
-- Project    : General Purpose Core
-------------------------------------------------------------------------------
-- File       : RceG3DmaChannel.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2014-04-25
-- Last update: 2014-05-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- AXI Stream DMA based channel for RCE core DMA.
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

entity RceG3DmaChannel is
   generic (
      TPD_G            : time                := 1 ns;
      AXIL_BASE_ADDR_G : slv(31 downto 0)    := x"00000000";
      AXIS_CONFIG_G    : AxiStreamConfigType := AXI_STREAM_CONFIG_INIT_C;
      CHANNEL_NUM_G    : integer := 0
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
      hpWriteSlave        : in  AxiWriteSlaveType;
      hpWriteMaster       : out AxiWriteMasterType;
      hpReadSlave         : in  AxiReadSlaveType;
      hpReadMaster        : out AxiReadMasterType;

      -- Local AXI Lite Bus
      axilReadMaster      : in  AxiLiteReadMasterType;
      axilReadSlave       : out AxiLiteReadSlaveType;
      axilWriteMaster     : in  AxiLiteWriteMasterType;
      axilWriteSlave      : out AxiLiteWriteSlaveType;

      -- Interrupts
      interrupt           : out slv(15 downto 0);

      -- External DMA Interfaces
      dmaClk              : in  sl;
      dmaClkRst           : in  sl;
      dmaOnline           : out sl;
      dmaEnable           : out sl;
      dmaObMaster         : out AxiStreamMasterType;
      dmaObSlave          : in  AxiStreamSlaveType;
      dmaIbMaster         : in  AxiStreamMasterType;
      dmaIbSlave          : out AxiStreamSlaveType
   );
end RceG3DmaChannel;

