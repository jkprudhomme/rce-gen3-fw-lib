-------------------------------------------------------------------------------
-- Title         : RCE Generation 3, CPU Wrapper
-- File          : RceG3Cpu.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- CPU wrapper for ARM based rce generation 3 processor core.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiPkg.all;

entity RceG3Cpu is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clocks
      fclkClk3            : out sl;
      fclkClk2            : out sl;
      fclkClk1            : out sl;
      fclkClk0            : out sl;
      fclkRst3            : out sl;
      fclkRst2            : out sl;
      fclkRst1            : out sl;
      fclkRst0            : out sl;

      -- Interrupts
      armInt              : in  slv(15 downto 0);

      -- AXI GP Master
      mGpAxiClk           : in  slv(1 downto 0);
      mGpWriteMaster      : out AxiWriteMasterArray(1 downto 0);
      mGpWriteSlave       : in  AxiWriteSlaveArray(1 downto 0);
      mGpReadMaster       : out AxiReadMasterArray(1 downto 0);
      mGpReadSlave        : in  AxiReadSlaveArray(1 downto 0);

      -- AXI GP Slave
      sGpAxiClk           : in  slv(1 downto 0);
      sGpWriteSlave       : out AxiWriteSlaveArray(1 downto 0);
      sGpWriteMaster      : in  AxiWriteMasterArray(1 downto 0);
      sGpReadSlave        : out AxiReadSlaveArray(1 downto 0);
      sGpReadMaster       : in  AxiReadMasterArray(1 downto 0);

      -- AXI ACP Slave
      acpAxiClk           : in  slv(1 downto 0);
      acpWriteSlave       : out AxiWriteSlaveType;
      acpWriteMaster      : in  AxiWriteMasterType;
      acpReadSlave        : out AxiReadSlaveType;
      acpReadMaster       : in  AxiReadMasterType;

      -- AXI HP Slave
      hpAxiClk            : in  slv(1 downto 0);
      hpWriteSlave        : out AxiWriteSlaveArray(3 downto 0);
      hpWriteMaster       : in  AxiWriteMasterArray(3 downto 0);
      hpReadSlave         : out AxiReadSlaveArray(3 downto 0);
      hpReadMaster        : in  AxiReadMasterArray(3 downto 0);

      -- Ethernet
      armEthTx            : out ArmEthTxArray(1 downto 0);
      armEthRx            : in  ArmEthRxArray(1 downto 0)
   );
end RceG3Cpu;

