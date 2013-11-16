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

entity EvalCore is
   port (
      i2cSda     : inout sl;
      i2cScl     : inout sl;

      -- Clocks
      axiClk                   : out   sl;
      axiClkRst                : out   sl;
      sysClk125                : out   sl;
      sysClk125Rst             : out   sl;
      sysClk200                : out   sl;
      sysClk200Rst             : out   sl;

      -- External Local Bus
      localBusMaster           : out   LocalBusMasterVector(15 downto 8);
      localBusSlave            : in    LocalBusSlaveVector(15 downto 8);

      -- PPI Outbound FIFO Interface
      obPpiClk                : in     slv(3 downto 0);
      obPpiToFifo             : in     ObPpiToFifoVector(3 downto 0);
      obPpiFromFifo           : out    ObPpiFromFifoVector(3 downto 0);

      -- PPI Inbound FIFO Interface
      ibPpiClk                : in     slv(3 downto 0);
      ibPpiToFifo             : in     IbPpiToFifoVector(3 downto 0);
      ibPpiFromFifo           : out    IbPpiFromFifoVector(3 downto 0);

      -- External Inputs
      psSrstB                 : in     sl;
      psClk                   : in     sl;
      psPorB                  : in     sl
   );
end EvalCore;

architecture STRUCTURE of EvalCore is

   -- Local Signals

begin

   -- Core
   U_ArmRceG3Top: entity work.ArmRceG3Top
      generic map (
         AXI_CLKDIV_G => 10.0
      ) port map (
         i2cSda             => i2cSda,
         i2cScl             => i2cScl,
         axiClk             => axiClk,
         axiClkRst          => axiClkRst,
         sysClk125          => sysClk125,
         sysClk125Rst       => sysClk125Rst,
         sysClk200          => sysClk200,
         sysClk200Rst       => sysClk200Rst,
         localBusMaster     => localBusMaster,
         localBusSlave      => localBusSlave,
         obPpiClk           => obPpiClk,
         obPpiToFifo        => obPpiToFifo,
         obPpiFromFifo      => obPpiFromFifo,
         ibPpiClk           => ibPpiClk,
         ibPpiToFifo        => ibPpiToFifo,
         ibPpiFromFifo      => ibPpiFromFifo,
         ethFromArm         => open,
         ethToArm           => (others=>EthToArmInit),
         clkSelA            => open,
         clkSelB            => open,
         psSrstB            => psSrstB,
         psClk              => psClk,
         psPorB             => psPorB
      );

end architecture STRUCTURE;

