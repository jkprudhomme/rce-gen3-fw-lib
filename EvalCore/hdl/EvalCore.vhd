-------------------------------------------------------------------------------
-- Title         : Eval Core Module
-- File          : EvalCore.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 11/14/2013
-------------------------------------------------------------------------------
-- Description:
-- Common top level module for Eval
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

entity EvalCore is
   port (
      i2cSda                  : inout sl;
      i2cScl                  : inout sl;

      -- Clocks
      sysClk125               : out   sl;
      sysClk125Rst            : out   sl;
      sysClk200               : out   sl;
      sysClk200Rst            : out   sl;

      -- External Axi Bus, 0xA0000000 - 0xBFFFFFFF
      axiClk                  : out   sl;
      axiClkRst               : out   sl;
      localAxiReadMaster      : out   AxiLiteReadMasterType;
      localAxiReadSlave       : in    AxiLiteReadSlaveType;
      localAxiWriteMaster     : out   AxiLiteWriteMasterType;
      localAxiWriteSlave      : in    AxiLiteWriteSlaveType;

      -- PPI Outbound FIFO Interface
      obPpiClk                : in    slv(3 downto 0);
      obPpiToFifo             : in    ObPpiToFifoVector(3 downto 0);
      obPpiFromFifo           : out   ObPpiFromFifoVector(3 downto 0);

      -- PPI Inbound FIFO Interface
      ibPpiClk                : in    slv(3 downto 0);
      ibPpiToFifo             : in    IbPpiToFifoVector(3 downto 0);
      ibPpiFromFifo           : out   IbPpiFromFifoVector(3 downto 0)
   );
end EvalCore;

architecture STRUCTURE of EvalCore is

   -- Local Signals
   signal intAxiReadMaster  : AxiLiteReadMasterArray(0 downto 0);
   signal intAxiReadSlave   : AxiLiteReadSlaveArray(0 downto 0);
   signal intAxiWriteMaster : AxiLiteWriteMasterArray(0 downto 0);
   signal intAxiWriteSlave  : AxiLiteWriteSlaveArray(0 downto 0);
   signal topAxiReadMaster  : AxiLiteReadMasterType;
   signal topAxiReadSlave   : AxiLiteReadSlaveType;
   signal topAxiWriteMaster : AxiLiteWriteMasterType;
   signal topAxiWriteSlave  : AxiLiteWriteSlaveType;
   signal intAxiClk         : std_logic;
   signal intAxiClkRst      : std_logic;

begin

   -- Core
   U_ArmRceG3Top: entity work.ArmRceG3Top
      generic map (
         AXI_CLKDIV_G => 10.0
      ) port map (
         i2cSda              => i2cSda,
         i2cScl              => i2cScl,
         sysClk125           => sysClk125,
         sysClk125Rst        => sysClk125Rst,
         sysClk200           => sysClk200,
         sysClk200Rst        => sysClk200Rst,
         axiClk              => intAxiClk,
         axiClkRst           => intAxiClkRst,
         localAxiReadMaster  => topAxiReadMaster,
         localAxiReadSlave   => topAxiReadSlave ,
         localAxiWriteMaster => topAxiWriteMaster,
         localAxiWriteSlave  => topAxiWriteSlave ,
         obPpiClk            => obPpiClk,
         obPpiToFifo         => obPpiToFifo,
         obPpiFromFifo       => obPpiFromFifo,
         ibPpiClk            => ibPpiClk,
         ibPpiToFifo         => ibPpiToFifo,
         ibPpiFromFifo       => ibPpiFromFifo,
         ethFromArm          => open,
         ethToArm            => (others=>EthToArmInit),
         clkSelA             => open,
         clkSelB             => open
      );

   -- Output
   axiClk    <= intAxiClk;
   axiClkRst <= intAxiClkRst;

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
         axiClk              => intAxiClk,
         axiClkRst           => intAxiClkRst,
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

