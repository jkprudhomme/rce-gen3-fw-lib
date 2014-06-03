-------------------------------------------------------------------------------
-- Title         : RCE Generation 3, Interrupt Controller
-- File          : RceG3IntCntl.vhd
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

entity RceG3IntCntl is
   generic (
      TPD_G                 : time                  := 1 ns;
      RCE_DMA_MODE_G        : RceDmaModeType        := RCE_DMA_PPI_C
   );
   port (

      -- AXI BUS Clock
      axiDmaClk           : in  sl;
      axiDmaRst           : in  sl;

      -- Local AXI Lite Bus
      icAxilReadMaster    : in  AxiLiteReadMasterType;
      icAxilReadSlave     : out AxiLiteReadSlaveType;
      icAxilWriteMaster   : in  AxiLiteWriteMasterType;
      icAxilWriteSlave    : out AxiLiteWriteSlaveType;

      -- Interrupt Inputs
      dmaInterrupt        : in  slv(DMA_INT_COUNT_C-1 downto 0);
      bsiInterrupt        : in  sl;

      -- Interrupt Outputs
      armInterrupt        : out slv(15 downto 0)
   );
end RceG3IntCntl;

architecture structure of RceG3IntCntl is

begin

   -- Terminate Unused AXI-Lite Interface
   U_AxiLiteEmpty : entity work.AxiLiteEmpty
      generic map (
         TPD_G  => TPD_G
      ) port map (
         axiClk          => axiDmaClk,
         axiClkRst       => axiDmaRst,
         axiReadMaster   => icAxilReadMaster,
         axiReadSlave    => icAxilReadSlave,
         axiWriteMaster  => icAxilWriteMaster,
         axiWriteSlave   => icAxilWriteSlave
      );

   armInterrupt(3  downto 0) <= dmaInterrupt(3 downto 0);
   armInterrupt(4)           <= bsiInterrupt;
   armInterrupt(15 downto 5) <= (others=>'0');

end architecture structure;

