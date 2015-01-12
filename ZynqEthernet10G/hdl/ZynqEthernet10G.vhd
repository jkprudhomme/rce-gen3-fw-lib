-------------------------------------------------------------------------------
-- Title         : Zynq 10 Gige Ethernet Core
-- File          : ZynqEthernet10G.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 09/03/2013
-------------------------------------------------------------------------------
-- Description:
-- Wrapper file for Zynq ethernet 10G core.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 09/03/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.PpiPkg.all;
use work.RceG3Pkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.StdRtlPkg.all;

entity ZynqEthernet10G is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clocks
      sysClk200               : in  sl;
      sysClk200Rst            : in  sl;

      -- PPI Interface
      ppiClk                  : out sl;
      ppiClkRst               : out sl;
      ppiState                : in  RceDmaStateType;
      ppiIbMaster             : out AxiStreamMasterType;
      ppiIbSlave              : in  AxiStreamSlaveType;
      ppiObMaster             : in  AxiStreamMasterType;
      ppiObSlave              : out AxiStreamSlaveType;

      -- AXI Lite Busses
      axilClk                 : in  sl;
      axilClkRst              : in  sl;
      axilWriteMaster         : in  AxiLiteWriteMasterType;
      axilWriteSlave          : out AxiLiteWriteSlaveType;
      axilReadMaster          : in  AxiLiteReadMasterType;
      axilReadSlave           : out AxiLiteReadSlaveType;

      -- Ref Clock
      ethRefClkP              : in  sl;
      ethRefClkM              : in  sl;

      -- Ethernet Lines
      ethRxP                  : in  slv(3 downto 0);
      ethRxM                  : in  slv(3 downto 0);
      ethTxP                  : out slv(3 downto 0);
      ethTxM                  : out slv(3 downto 0)
   );
end ZynqEthernet10G;

architecture structure of ZynqEthernet10G is

   signal xmacRst             : sl;

begin

   -- Select PPI clock
   ppiClk    <= sysClk200;
   ppiClkRst <= sysClk200Rst;
   xmacRst   <= not ppiState.online;

   --
   -- 9 bits = 4kbytes
   -- 255 x 8 = 2kbytes (not enough for pause)
   -- 11 bits = 16kbytes

   -- 10G Mac
   U_XMac : entity work.XMac 
      generic map (
         TPD_G            => TPD_G,
         IB_ADDR_WIDTH_G  => 11,
         OB_ADDR_WIDTH_G  => 9,
         PAUSE_THOLD_G    => 512,
         VALID_THOLD_G    => 255,
         EOH_BIT_G        => PPI_EOH_C,
         ERR_BIT_G        => PPI_ERR_C,
         HEADER_SIZE_G    => 16,
         AXIS_CONFIG_G    => PPI_AXIS_CONFIG_INIT_C
      ) port map (
         xmacRst          => xmacRst,
         dmaClk           => sysClk200,
         dmaClkRst        => sysClk200Rst,
         dmaIbMaster      => ppiIbMaster,
         dmaIbSlave       => ppiIbSlave,
         dmaObMaster      => ppiObMaster,
         dmaObSlave       => ppiObSlave,
         axilClk          => axilClk,
         axilClkRst       => axilClkRst,
         axilWriteMaster  => axilWriteMaster,
         axilWriteSlave   => axilWriteSlave,
         axilReadMaster   => axilReadMaster,
         axilReadSlave    => axilReadSlave,
         ethRefClkP       => ethRefClkP,
         ethRefClkM       => ethRefClkM,
         ethRxP           => ethRxP,
         ethRxM           => ethRxM,
         ethTxP           => ethTxP,
         ethTxM           => ethTxM
      );

end architecture structure;

