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

architecture Ppi of RceG3DmaChannel is 

begin

   acpWriteMaster  <= AXI_WRITE_MASTER_INIT_C;
   acpReadMaster   <= AXI_READ_MASTER_INIT_C;
   hpWriteMaster   <= AXI_WRITE_MASTER_INIT_C;
   hpReadMaster    <= AXI_READ_MASTER_INIT_C;
   axilReadSlave   <= AXI_LITE_READ_SLAVE_INIT_C;
   axilWriteSlave  <= AXI_LITE_WRITE_SLAVE_INIT_C;
   interrupt       <= (others=>'0');
   dmaOnline       <= '0';
   dmaEnable       <= '0';
   dmaObMaster     <= AXI_STREAM_MASTER_INIT_C;
   dmaIbSlave      <= AXI_STREAM_SLAVE_INIT_C;

end Ppi;

