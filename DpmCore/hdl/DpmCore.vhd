-------------------------------------------------------------------------------
-- Title         : Common DPM Core Module
-- File          : DpmCore.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 11/14/2013
-------------------------------------------------------------------------------
-- Description:
-- Common top level module for DPM
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 11/14/2013: created.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity DpmCore is
   generic (
      TPD_G        : time                       := 1 ns;
      ETH_10G_EN_G : boolean                    := false;
      PPI_CONFIG_G : PpiConfigArray(2 downto 0) := (others=>PPI_CONFIG_INIT_C)
   );
   port (

      -- I2C
      i2cSda                   : inout sl;
      i2cScl                   : inout sl;

      -- Ethernet
      ethRxP                   : in    slv(3 downto 0);
      ethRxM                   : in    slv(3 downto 0);
      ethTxP                   : out   slv(3 downto 0);
      ethTxM                   : out   slv(3 downto 0);
      ethRefClkP               : in    sl;
      ethRefClkM               : in    sl;

      -- Clocks
      axiClk                   : out   sl;
      axiClkRst                : out   sl;
      sysClk125                : out   sl;
      sysClk125Rst             : out   sl;
      sysClk200                : out   sl;
      sysClk200Rst             : out   sl;

      -- External Axi Bus, 0xA0000000 - 0xAFFFFFFF
      localAxiReadMaster      : out    AxiLiteReadMasterType;
      localAxiReadSlave       : in     AxiLiteReadSlaveType;
      localAxiWriteMaster     : out    AxiLiteWriteMasterType;
      localAxiWriteSlave      : in     AxiLiteWriteSlaveType;

      -- PPI Clock and Reset
      ppiClk                  : in     slv(2 downto 0);
      ppiOnline               : out    slv(2 downto 0);

      -- PPI Outbound FIFO Interface
      ppiReadToFifo           : in     PpiReadToFifoArray(2 downto 0);
      ppiReadFromFifo         : out    PpiReadFromFifoArray(2 downto 0);

      -- PPI Inbound FIFO Interface
      ppiWriteToFifo          : in     PpiWriteToFifoArray(2 downto 0);
      ppiWriteFromFifo        : out    PpiWriteFromFifoArray(2 downto 0);

      dbgStatus               : out    slv(7  downto 0);

      -- Clock Select
      clkSelA                 : out    slv(1 downto 0);
      clkSelB                 : out    slv(1 downto 0)
   );
end DpmCore;

architecture STRUCTURE of DpmCore is

   -- Local Ethernet Config
   constant ETH_PPI_CONFIG_C : PpiConfigType := ( 
      obHeaderAddrWidth  => 9,
      obDataAddrWidth    => 9,
      obReadyThold       => 1,
      ibHeaderAddrWidth  => 9,
      ibHeaderPauseThold => 255,
      ibDataAddrWidth    => 9,
      ibDataPauseThold   => 255
   );

   -- PPI Configuration
   constant INT_PPI_CONFIG_C : PpiConfigArray(3 downto 0) := (
      0 =>  PPI_CONFIG_G(0),
      1 =>  PPI_CONFIG_G(1),
      2 =>  PPI_CONFIG_G(2),
      3 =>  ETH_PPI_CONFIG_C
   );

   -- Local Signals
   signal iaxiClk            : sl;
   signal iaxiClkRst         : sl;
   signal isysClk125         : sl;
   signal isysClk125Rst      : sl;
   signal isysClk200         : sl;
   signal isysClk200Rst      : sl;
   signal iethFromArm        : EthFromArmArray(1 downto 0);
   signal iethToArm          : EthToArmArray(1 downto 0);
   signal intAxiReadMaster   : AxiLiteReadMasterArray(0 downto 0);
   signal intAxiReadSlave    : AxiLiteReadSlaveArray(0 downto 0);
   signal intAxiWriteMaster  : AxiLiteWriteMasterArray(0 downto 0);
   signal intAxiWriteSlave   : AxiLiteWriteSlaveArray(0 downto 0);
   signal topAxiReadMaster   : AxiLiteReadMasterType;
   signal topAxiReadSlave    : AxiLiteReadSlaveType;
   signal topAxiWriteMaster  : AxiLiteWriteMasterType;
   signal topAxiWriteSlave   : AxiLiteWriteSlaveType;
   signal intReadToFifo      : PpiReadToFifoArray(3 downto 0);
   signal intReadFromFifo    : PpiReadFromFifoArray(3 downto 0);
   signal intWriteToFifo     : PpiWriteToFifoArray(3 downto 0);
   signal intWriteFromFifo   : PpiWriteFromFifoArray(3 downto 0);
   signal ippiClk            : slv(3 downto 0);
   signal ippiOnline         : slv(3 downto 0);

begin

   --------------------------------------------------
   -- Inputs/Outputs
   --------------------------------------------------
   axiClk          <= iaxiClk;
   axiClkRst       <= iaxiClkRst;
   sysClk125       <= isysClk125;
   sysClk125Rst    <= isysClk125Rst;
   sysClk200       <= isysClk200;
   sysClk200Rst    <= isysClk200Rst;

   intReadToFifo(2 downto 0)  <= ppiReadToFifo;
   ppiReadFromFifo            <= intReadFromFifo(2 downto 0);
   intWriteToFifo(2 downto 0) <= ppiWriteToFifo;
   ppiWriteFromFifo           <= intWriteFromFifo(2 downto 0);
   ippiClk(2 downto 0)        <= ppiClk;
   ppiOnline                  <= ippiOnline(2 downto 0);


   --------------------------------------------------
   -- RCE Core
   --------------------------------------------------
   U_ArmRceG3Top: entity work.ArmRceG3Top
      generic map (
         AXI_CLKDIV_G => 5.0,
         PPI_CONFIG_G => INT_PPI_CONFIG_C
      ) port map (
         i2cSda              => i2cSda,
         i2cScl              => i2cScl,
         axiClk              => iaxiClk,
         axiClkRst           => iaxiClkRst,
         sysClk125           => isysClk125,
         sysClk125Rst        => isysClk125Rst,
         sysClk200           => isysClk200,
         sysClk200Rst        => isysClk200Rst,
         localAxiReadMaster  => topAxiReadMaster,
         localAxiReadSlave   => topAxiReadSlave ,
         localAxiWriteMaster => topAxiWriteMaster,
         localAxiWriteSlave  => topAxiWriteSlave ,
         ppiClk              => ippiClk,
         ppiOnline           => ippiOnline,
         ppiReadToFifo       => intReadToFifo,
         ppiReadFromFifo     => intReadFromFifo,
         ppiWriteToFifo      => intWriteToFifo,
         ppiWriteFromFifo    => intWriteFromFifo,
         ethFromArm          => iethFromArm,
         ethToArm            => iethToArm,
         clkSelA             => clkSelA,
         clkSelB             => clkSelB
      );

   --------------------------------------------------
   -- Ethernet
   --------------------------------------------------
   U_Eth1gGen: if ETH_10G_EN_G = false generate 
      U_ZynqEthernet : entity work.ZynqEthernet 
         port map (
            sysClk125          => isysClk125,
            sysClk200          => isysClk200,
            sysClk200Rst       => isysClk200Rst,
            ethFromArm         => iethFromArm(0),
            ethToArm           => iethToArm(0),
            ethRxP             => ethRxP(0),
            ethRxM             => ethRxM(0),
            ethTxP             => ethTxP(0),
            ethTxM             => ethTxM(0)
         );

      ippiClk(3)         <= isysClk125;
      intReadToFifo(3)   <= PPI_READ_TO_FIFO_INIT_C;
      intWriteToFifo(3)  <= PPI_WRITE_TO_FIFO_INIT_C;
      ethTxP(3 downto 1) <= (others=>'0');
      ethTxM(3 downto 1) <= (others=>'0');

   end generate;

   U_Eth10gGen: if ETH_10G_EN_G = true generate 
      U_ZynqEthernet10G : entity work.ZynqEthernet10G
         port map (
            sysClk200                => isysClk200,
            sysClk200Rst             => isysClk200Rst,
            sysClk125                => isysClk125,
            sysClk125Rst             => isysClk125Rst,
            ppiClk                   => ippiClk(3),
            ppiOnline                => ippiOnline(3),
            ppiReadToFifo            => intReadToFifo(3),
            ppiReadFromFifo          => intReadFromFifo(3),
            ppiWriteToFifo           => intWriteToFifo(3),
            ppiWriteFromFifo         => intWriteFromFifo(3),
            dbgStatus                => dbgStatus,
            ethRefClkP               => ethRefClkP,
            ethRefClkM               => ethRefClkM,
            ethRxP                   => ethRxP,
            ethRxM                   => ethRxM,
            ethTxP                   => ethTxP,
            ethTxM                   => ethTxM
         );

      iethToArm(0) <= ETH_TO_ARM_INIT_C;

   end generate;

   iethToArm(1) <= ETH_TO_ARM_INIT_C;

   -------------------------------------
   -- AXI Lite Crossbar
   -- Base: 0xA0000000 - 0xBFFFFFFF
   -------------------------------------
   U_AxiCrossbar : entity work.AxiLiteCrossbar 
      generic map (
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 1,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => (

            -- Channel 0 = 0xA0000000 - 0xAFFFFFFF : External Top Level
            0 => ( baseAddr     => x"A0000000",
                   addrBits     => 28,
                   connectivity => x"FFFF")
         )
      ) port map (
         axiClk              => iaxiClk,
         axiClkRst           => iaxiClkRst,
         sAxiWriteMasters(0) => topAxiWriteMaster,
         sAxiWriteSlaves(0)  => topAxiWriteSlave,
         sAxiReadMasters(0)  => topAxiReadMaster,
         sAxiReadSlaves(0)   => topAxiReadSlave,
         mAxiWriteMasters    => intAxiWriteMaster,
         mAxiWriteSlaves     => intAxiWriteSlave,
         mAxiReadMasters     => intAxiReadMaster,
         mAxiReadSlaves      => intAxiReadSlave
      );

   -- External Connections
   localAxiReadMaster  <= intAxiReadMaster(0);
   intAxiReadSlave(0)  <= localAxiReadSlave;
   localAxiWriteMaster <= intAxiWriteMaster(0);
   intAxiWriteSlave(0) <= localAxiWriteSlave;

end architecture STRUCTURE;

