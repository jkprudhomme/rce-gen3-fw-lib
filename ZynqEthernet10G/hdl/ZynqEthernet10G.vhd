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

   signal locIbMaster         : AxiStreamMasterType;
   signal locIbSlave          : AxiStreamSlaveType;
   signal locObMaster         : AxiStreamMasterType;
   signal locObSlave          : AxiStreamSlaveType;
   signal statusWord          : slv(63 downto 0);
   signal statusSend          : sl;
   signal xmacRst             : sl;

begin

   -- Select PPI clock
   ppiClk    <= sysClk200;
   ppiClkRst <= sysClk200Rst;
   xmacRst   <= not ppiState.online;

   -- PPI Crossbar
   U_PpiInterconnect : entity work.PpiInterconnect
      generic map (
         TPD_G               => TPD_G,
         NUM_PPI_SLOTS_G     => 1,
         NUM_STATUS_WORDS_G  => 1,
         STATUS_SEND_WIDTH_G => 1
      ) port map (
         ppiClk              => sysClk200,
         ppiClkRst           => sysClk200Rst,
         ppiState            => ppiState,
         ppiIbMaster         => ppiIbMaster,
         ppiIbSlave          => ppiIbSlave,
         ppiObMaster         => ppiObMaster,
         ppiObSlave          => ppiObSlave,
         locIbMaster(0)      => locIbMaster,
         locIbSlave(0)       => locIbSlave,
         locObMaster(0)      => locObMaster,
         locObSlave(0)       => locObSlave,
         statusClk           => axilClk,
         statusClkRst        => axilClkRst,
         statusWords(0)      => statusWord,
         statusSend(0)       => statusSend,
         offlineAck          => '0'
      );

   -- 10G Mac
   U_XMac : entity work.XMac 
      generic map (
         TPD_G            => TPD_G,
         IB_ADDR_WIDTH_G  => 9,
         OB_ADDR_WIDTH_G  => 9,
         PAUSE_THOLD_G    => 255,
         VALID_THOLD_G    => 255,
         EOH_BIT_G        => PPI_EOH_C,
         ERR_BIT_G        => PPI_ERR_C,
         HEADER_SIZE_G    => 16,
         AXIS_CONFIG_G    => PPI_AXIS_CONFIG_INIT_C
      ) port map (
         xmacRst          => xmacRst,
         dmaClk           => sysClk200,
         dmaClkRst        => sysClk200Rst,
         dmaIbMaster      => locIbMaster,
         dmaIbSlave       => locIbSlave,
         dmaObMaster      => locObMaster,
         dmaObSlave       => locObSlave,
         axilClk          => axilClk,
         axilClkRst       => axilClkRst,
         axilWriteMaster  => axilWriteMaster,
         axilWriteSlave   => axilWriteSlave,
         axilReadMaster   => axilReadMaster,
         axilReadSlave    => axilReadSlave,
         statusWord       => statusWord,
         statusSend       => statusSend,
         ethRefClkP       => ethRefClkP,
         ethRefClkM       => ethRefClkM,
         ethRxP           => ethRxP,
         ethRxM           => ethRxM,
         ethTxP           => ethTxP,
         ethTxM           => ethTxM
      );

end architecture structure;

