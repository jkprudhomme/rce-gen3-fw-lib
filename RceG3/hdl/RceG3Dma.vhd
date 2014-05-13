-------------------------------------------------------------------------------
-- Title         : RCE Generation 3, DMA Controllers
-- File          : RceG3Dma.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Top level Wrapper for DMA controllers
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

use work.StdRtlPkg.all;
use work.RceG3Pkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;

entity RceG3Dma is
   generic (
      TPD_G                 : time                  := 1 ns;
      AXIL_BASE_ADDR_G      : slv(31 downto 0)      := x"00000000";
      RCE_DMA_COUNT_G       : integer range 1 to 16 := 1;
      RCE_DMA_AXIS_CONFIG_G : AxiStreamConfigArray;
      RCE_DMA_MODE_G        : RceDmaModeArray
   );
   port (

      -- AXI BUS Clock
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
      dmaClk              : in  slv(RCE_DMA_COUNT_G-1 downto 0);
      dmaClkRst           : in  slv(RCE_DMA_COUNT_G-1 downto 0);
      dmaOnline           : out slv(RCE_DMA_COUNT_G-1 downto 0);
      dmaEnable           : out slv(RCE_DMA_COUNT_G-1 downto 0);
      dmaObMaster         : out AxiStreamMasterArray(RCE_DMA_COUNT_G-1 downto 0);
      dmaObSlave          : in  AxiStreamSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
      dmaIbMaster         : in  AxiStreamMasterArray(RCE_DMA_COUNT_G-1 downto 0);
      dmaIbSlave          : out AxiStreamSlaveArray(RCE_DMA_COUNT_G-1 downto 0)
   );
end RceG3Dma;

architecture structure of RceG3Dma is

   constant HP_BRANCHES_C : integerArray(3 downto 0) := (
      0 => (RCE_DMA_COUNT_G+3)/4,
      1 => (RCE_DMA_COUNT_G+2)/4,
      2 => (RCE_DMA_COUNT_G+1)/4,
      3 => (RCE_DMA_COUNT_G)/4);

   constant HP_BASE_C : integerArray(3 downto 0) := (
      0 => 0,
      1 => (RCE_DMA_COUNT_G+3)/4,
      2 => (RCE_DMA_COUNT_G+2)/4,
      3 => (RCE_DMA_COUNT_G+1)/4);

   constant MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray(RCE_DMA_COUNT_G-1 downto 0) := 
      genAxiLiteConfig ( RCE_DMA_COUNT_G, AXIL_BASE_ADDR_G, 16, 12);

   signal iacpWriteSlaves  : AxiWriteSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal iacpWriteMasters : AxiWriteMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal iacpReadSlaves   : AxiReadSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal iacpReadMasters  : AxiReadMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal ihpWriteSlaves   : AxiWriteSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal ihpWriteMasters  : AxiWriteMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal ihpReadSlaves    : AxiReadSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal ihpReadMasters   : AxiReadMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal iaxilReadMaster  : AxiLiteReadMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal iaxilReadSlave   : AxiLiteReadSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal iaxilWriteMaster : AxiLiteWriteMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal iaxilWriteSlave  : AxiLiteWriteSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal iinterrupt       : Slv16Array(RCE_DMA_COUNT_G-1 downto 0);

begin


   ------------------------------------
   -- ACP Branching
   ------------------------------------
   U_AxiReadPathMux : entity work.AxiReadPathMux 
      generic map (
         TPD_G        => TPD_G,
         NUM_SLAVES_G => RCE_DMA_COUNT_G
      ) port map (
         axiClk          => axiDmaClk,
         axiRst          => axiDmaRst,
         sAxiReadMasters => iacpReadMasters,
         sAxiReadSlaves  => iacpReadSlaves,
         mAxiReadMaster  => acpReadMaster,
         mAxiReadSlave   => acpReadSlave
      );

   U_AxiWritePathMux : entity work.AxiWritePathMux
      generic map (
         TPD_G        => TPD_G,
         NUM_SLAVES_G => RCE_DMA_COUNT_G
      ) port map (
         axiClk           => axiDmaClk,
         axiRst           => axiDmaRst,
         sAxiWriteMasters => iacpWriteMasters,
         sAxiWriteSlaves  => iacpWriteSlaves,
         mAxiWriteMaster  => acpWriteMaster,
         mAxiWriteSlave   => acpWriteSlave
      );


   ------------------------------------
   -- HP Branching
   ------------------------------------
   U_HpGen : for i in 0 to 3 generate

      U_HpEn : if HP_BRANCHES_C(i) > 0 generate

         U_HpReadPathMux : entity work.AxiReadPathMux 
            generic map (
               TPD_G        => TPD_G,
               NUM_SLAVES_G => HP_BRANCHES_C(i)
            ) port map (
               axiClk          => axiDmaClk,
               axiRst          => axiDmaRst,
               sAxiReadMasters => ihpReadMasters((HP_BASE_C(i)+HP_BRANCHES_C(i))-1 downto HP_BASE_C(i)),
               sAxiReadSlaves  => ihpReadSlaves((HP_BASE_C(i)+HP_BRANCHES_C(i))-1 downto HP_BASE_C(i)),
               mAxiReadMaster  => hpReadMaster(i),
               mAxiReadSlave   => hpReadSlave(i)
            );

         U_HpWritePathMux : entity work.AxiWritePathMux
            generic map (
               TPD_G        => TPD_G,
               NUM_SLAVES_G => HP_BRANCHES_C(i)
            ) port map (
               axiClk           => axiDmaClk,
               axiRst           => axiDmaRst,
               sAxiWriteMasters => ihpWriteMasters((HP_BASE_C(i)+HP_BRANCHES_C(i))-1 downto HP_BASE_C(i)),
               sAxiWriteSlaves  => ihpWriteSlaves((HP_BASE_C(i)+HP_BRANCHES_C(i))-1 downto HP_BASE_C(i)),
               mAxiWriteMaster  => hpWriteMaster(i),
               mAxiWriteSlave   => hpWriteSlave(i)
            );
      end generate;

      U_HpDis : if HP_BRANCHES_C(i) = 0 generate
         ihpReadSlaves(i)  <= AXI_READ_SLAVE_INIT_C;
         ihpWriteSlaves(i) <= AXI_WRITE_SLAVE_INIT_C;
      end generate;

   end generate;


   ------------------------------------
   -- AXI-Lite Crossbar
   ------------------------------------
   U_AxiLiteCrossbar : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => RCE_DMA_COUNT_G,
         DEC_ERROR_RESP_G   => AXI_RESP_DECERR_C,
         MASTERS_CONFIG_G   => MASTERS_CONFIG_C
      ) port map (
         axiClk              => axiDmaClk,
         axiClkRst           => axiDmaRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiReadMasters     => iaxilReadMaster,
         mAxiReadSlaves      => iaxilReadSlave,
         mAxiWriteMasters    => iaxilWriteMaster,
         mAxiWriteSlaves     => iaxilWriteSlave
      );


   ------------------------------------
   -- DMA Controllers
   ------------------------------------
   U_DmaGen : for i in 0 to RCE_DMA_COUNT_G-1 generate

      U_DmaChannel : entity work.RceG3DmaChannel
         generic map (
            TPD_G            => TPD_G,
            AXIL_BASE_ADDR_G => MASTERS_CONFIG_C(i).baseAddr,
            AXIS_CONFIG_G    => RCE_DMA_AXIS_CONFIG_G(i),
            CHANNEL_NUM_G    => i
         ) port map (
            axiDmaClk        => axiDmaClk,
            axiDmaRst        => axiDmaRst,
            acpWriteSlave    => iacpWriteSlaves(i),
            acpWriteMaster   => iacpWriteMasters(i),
            acpReadSlave     => iacpReadSlaves(i),
            acpReadMaster    => iacpReadMasters(i),
            hpWriteSlave     => ihpWriteSlaves(i),
            hpWriteMaster    => ihpWriteMasters(i),
            hpReadSlave      => ihpReadSlaves(i),
            hpReadMaster     => ihpReadMasters(i),
            axilReadMaster   => iaxilReadMaster(i),
            axilReadSlave    => iaxilReadSlave(i),
            axilWriteMaster  => iaxilWriteMaster(i),
            axilWriteSlave   => iaxilWriteSlave(i),
            interrupt        => iinterrupt(i),
            dmaClk           => dmaClk(i),
            dmaClkRst        => dmaClkRst(i),
            dmaOnline        => dmaOnline(i),
            dmaEnable        => dmaEnable(i),
            dmaObMaster      => dmaObMaster(i),
            dmaObSlave       => dmaObSlave(i),
            dmaIbMaster      => dmaIbMaster(i),
            dmaIbSlave       => dmaIbSlave(i)
         );
   end generate;

   ------------------------------------
   -- Interrupts
   ------------------------------------
   U_IntComb: process ( iinterrupt ) is
      variable intOut : slv(15 downto 0);
   begin
      intOut := (others=>'0');

      for i in 0 to RCE_DMA_COUNT_G-1 loop
         intOut := intOut or iinterrupt(i);
      end loop;

      interrupt <= intOut;
   end process;

end architecture structure;

