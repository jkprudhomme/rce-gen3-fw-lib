-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : RceG3AppRegCrossbar.vhd
-- Author     : Larry Ruckman  <ruckman@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2016-08-03
-- Last update: 2016-08-03
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.RceG3Pkg.all;

entity RceG3AppRegCrossbar is
   generic (
      TPD_G        : time    := 1 ns;
      COMMON_CLK_G : boolean := false);       
   port (
      -- DMA Bus: SRPv0 Protocol
      dmaClk             : out sl;
      dmaRst             : out sl;
      dmaObMaster        : in  AxiStreamMasterType;
      dmaObSlave         : out AxiStreamSlaveType;
      dmaIbMaster        : out AxiStreamMasterType;
      dmaIbSlave         : in  AxiStreamSlaveType;
      -- CPU AXI-Lite Bus [0xA0000000:0xAFFFFFFF]
      axilClk            : in  sl;
      axilRst            : in  sl;
      extAxilReadMaster  : in  AxiLiteReadMasterType;
      extAxilReadSlave   : out AxiLiteReadSlaveType;
      extAxilWriteMaster : in  AxiLiteWriteMasterType;
      extAxilWriteSlave  : out AxiLiteWriteSlaveType;
      -- Application AXI-Lite Bus [0xA0000000:0xAFFFFFFF]   
      appClk             : in  sl;
      appRst             : in  sl;
      axilReadMaster     : out AxiLiteReadMasterType;
      axilReadSlave      : in  AxiLiteReadSlaveType;
      axilWriteMaster    : out AxiLiteWriteMasterType;
      axilWriteSlave     : in  AxiLiteWriteSlaveType);        
end RceG3AppRegCrossbar;

architecture mapping of RceG3AppRegCrossbar is

   constant AXI_CROSSBAR_MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray(0 downto 0) := (
      0               => (
         baseAddr     => x"A0000000",
         addrBits     => 28,
         connectivity => x"FFFF"));  

   signal readMasters  : AxiLiteReadMasterArray(1 downto 0);
   signal readSlaves   : AxiLiteReadSlaveArray(1 downto 0);
   signal writeMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal writeSlaves  : AxiLiteWriteSlaveArray(1 downto 0);

begin

   dmaClk <= appClk;
   dmaRst <= appRst;

   U_AXIL_M : entity work.SrpV0AxiLite
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => true,
         EN_32BIT_ADDR_G     => true,
         BRAM_EN_G           => true,
         XIL_DEVICE_G        => "7SERIES",
         USE_BUILT_IN_G      => false,
         ALTERA_SYN_G        => false,
         ALTERA_RAM_G        => "M9K",
         GEN_SYNC_FIFO_G     => true,
         FIFO_ADDR_WIDTH_G   => 9,
         FIFO_PAUSE_THRESH_G => 2**8,
         AXI_STREAM_CONFIG_G => RCEG3_AXIS_DMA_CONFIG_C)
      port map (
         -- Streaming Slave (Rx) Interface (sAxisClk domain) 
         sAxisClk            => appClk,
         sAxisRst            => appRst,
         sAxisMaster         => dmaObMaster,
         sAxisSlave          => dmaObSlave,
         -- Streaming Master (Tx) Data Interface (mAxisClk domain)
         mAxisClk            => appClk,
         mAxisRst            => appRst,
         mAxisMaster         => dmaIbMaster,
         mAxisSlave          => dmaIbSlave,
         -- AXI Lite Bus (axiLiteClk domain)
         axiLiteClk          => appClk,
         axiLiteRst          => appRst,
         mAxiLiteReadMaster  => readMasters(0),
         mAxiLiteReadSlave   => readSlaves(0),
         mAxiLiteWriteMaster => writeMasters(0),
         mAxiLiteWriteSlave  => writeSlaves(0));

   U_AxiLiteAsync : entity work.AxiLiteAsync
      generic map (
         TPD_G        => TPD_G,
         COMMON_CLK_G => COMMON_CLK_G)
      port map (
         -- Slave Port
         sAxiClk         => axilClk,
         sAxiClkRst      => axilRst,
         sAxiReadMaster  => extAxilReadMaster,
         sAxiReadSlave   => extAxilReadSlave,
         sAxiWriteMaster => extAxilWriteMaster,
         sAxiWriteSlave  => extAxilWriteSlave,
         -- Master Port
         mAxiClk         => appClk,
         mAxiClkRst      => appRst,
         mAxiReadMaster  => readMasters(1),
         mAxiReadSlave   => readSlaves(1),
         mAxiWriteMaster => writeMasters(1),
         mAxiWriteSlave  => writeSlaves(1));           

   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         NUM_SLAVE_SLOTS_G  => 2,
         NUM_MASTER_SLOTS_G => 1,
         MASTERS_CONFIG_G   => AXI_CROSSBAR_MASTERS_CONFIG_C)
      port map (
         axiClk              => appClk,
         axiClkRst           => appRst,
         sAxiWriteMasters    => writeMasters,
         sAxiWriteSlaves     => writeSlaves,
         sAxiReadMasters     => readMasters,
         sAxiReadSlaves      => readSlaves,
         mAxiWriteMasters(0) => axilWriteMaster,
         mAxiWriteSlaves(0)  => axilWriteSlave,
         mAxiReadMasters(0)  => axilReadMaster,
         mAxiReadSlaves(0)   => axilReadSlave);   

end architecture mapping;
