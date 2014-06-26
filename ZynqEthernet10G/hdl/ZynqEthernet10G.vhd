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

   signal intAxilWriteMaster  : AxiLiteWriteMasterType;
   signal intAxilWriteSlave   : AxiLiteWriteSlaveType;
   signal intAxilReadMaster   : AxiLiteReadMasterType;
   signal intAxilReadSlave    : AxiLiteReadSlaveType;
   signal muxAxilWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal muxAxilWriteSlaves  : AxiLiteWriteSlaveArray(1 downto 0);
   signal muxAxilReadMasters  : AxiLiteReadMasterArray(1 downto 0);
   signal muxAxilReadSlaves   : AxiLiteReadSlaveArray(1 downto 0);
   signal locIbMaster         : AxiStreamMasterType;
   signal locIbSlave          : AxiStreamSlaveType;
   signal locObMaster         : AxiStreamMasterType;
   signal locObSlave          : AxiStreamSlaveType;
   signal statusWord          : slv(63 downto 0);
   signal statusSend          : sl;

begin

   -- Select PPI clock
   ppiClk    <= sysClk200;
   ppiClkRst <= sysClk200Rst;

   -- PPI Crossbar
   U_PpiInterconnect : entity work.PpiInterconnect
      generic map (
         TPD_G               => TPD_G,
         NUM_PPI_SLOTS_G     => 1,
         NUM_AXI_SLOTS_G     => 1,
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
         axilClk             => axilClk,
         axilClkRst          => axilClkRst,
         axilWriteMasters(0) => muxAxilWriteMasters(0),
         axilWriteSlaves(0)  => muxAxilWriteSlaves(0),
         axilReadMasters(0)  => muxAxilReadMasters(0),
         axilReadSlaves(0)   => muxAxilReadSlaves(0),
         statusClk           => axilClk,
         statusClkRst        => axilClkRst,
         statusWords(0)      => statusWord,
         statusSend(0)       => statusSend
      );

   -- Connect external axi-lite to MUX, mask out upper address bits
   process (axilWriteMaster,axilReadMaster) begin
      muxAxilWriteMasters(1) <= axilWriteMaster;
      muxAxilReadMasters(1)  <= axilReadMaster;

      muxAxilWriteMasters(1).awaddr(31 downto 16) <= (others=>'0');
      muxAxilReadMasters(1).araddr(31 downto 16)  <= (others=>'0');
   end process;
   axilWriteSlave <= muxAxilWriteSlaves(1);
   axilReadSlave  <= muxAxilReadSlaves(1);

   -- AXI Crossbar
   U_AxiCrossbar : entity work.AxiLiteCrossbar 
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 2,
         NUM_MASTER_SLOTS_G => 1,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => (
            0 => ( baseAddr     => x"00000000",
                   addrBits     => 16,
                   connectivity => x"FFFF")
         )
      ) port map (
         axiClk              => axilClk,
         axiClkRst           => axilClkRst,
         sAxiWriteMasters    => muxAxilWriteMasters,
         sAxiWriteSlaves     => muxAxilWriteSlaves,
         sAxiReadMasters     => muxAxilReadMasters,
         sAxiReadSlaves      => muxAxilReadSlaves,
         mAxiWriteMasters(0) => intAxilWriteMaster,
         mAxiWriteSlaves(0)  => intAxilWriteSlave,
         mAxiReadMasters(0)  => intAxilReadMaster,
         mAxiReadSlaves(0)   => intAxilReadSlave
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
         dmaClk           => sysClk200,
         dmaClkRst        => sysClk200Rst,
         dmaIbMaster      => ppiIbMaster,
         dmaIbSlave       => ppiIbSlave,
         dmaObMaster      => ppiObMaster,
         dmaObSlave       => ppiObSlave,
         axilClk          => axilClk,
         axilClkRst       => axilClkRst,
         axilWriteMaster  => intAxilWriteMaster,
         axilWriteSlave   => intAxilWriteSlave,
         axilReadMaster   => intAxilReadMaster,
         axilReadSlave    => intAxilReadSlave,
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

