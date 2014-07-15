-------------------------------------------------------------------------------
-- Title         : PPI To PGP Block
-- File          : PpiPgpArray.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to receive and transmit PGP Frames.
-------------------------------------------------------------------------------
-- Copyright (c) 2014 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 03/21/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.Pgp2bPkg.all;

entity PpiPgpArray is
   generic (
      TPD_G                   : time                       := 1 ns;
      NUM_LANES_G             : integer range 1  to 12     := 12;
      AXI_CLK_FREQ_G          : real    := 125.0E+6;
      RX_AXIS_ADDR_WIDTH_G    : integer := 9;
      RX_AXIS_PAUSE_THRESH_G  : integer := 500;
      RX_AXIS_CASCADE_SIZE_G  : integer := 1;
      RX_DATA_ADDR_WIDTH_G    : integer := 9;
      RX_HEADER_ADDR_WIDTH_G  : integer := 9;
      RX_PPI_MAX_FRAME_SIZE_G : integer := 2048
      TX_PPI_ADDR_WIDTH_G     : integer := 9;
      TX_AXIS_ADDR_WIDTH_G    : integer := 9;
      TX_AXIS_CASCADE_SIZE_G  : integer := 1
   );
   port (

      -- PPI Interface
      ppiClk            : in  sl;
      ppiClkRst         : in  sl;
      ppiState          : in  RceDmaStateType;
      ppiIbMaster       : out AxiStreamMasterType;
      ppiIbSlave        : in  AxiStreamSlaveType;
      ppiObMaster       : in  AxiStreamMasterType;
      ppiObSlave        : out AxiStreamSlaveType;

      -- TX PGP Interfaces
      pgpTxClk          : in  slv(NUM_LANES_G-1 downto 0);
      pgpTxClkRst       : in  slv(NUM_LANES_G-1 downto 0);
      pgpTxIn           : out Pgp2bTxInArray(NUM_LANES_G-1 downto 0);
      pgpTxOut          : in  Pgp2bTxOutArray(NUM_LANES_G-1 downto 0);
      pgpTxMasters      : out AxiStreamMasterArray((NUM_LANES_G*4)-1 downto 0);
      pgpTxSlaves       : in  AxiStreamSlaveArray((NUM_LANES_G*4)-1 downto 0);

      -- RX PGP Interfaces
      pgpRxClk          : in  slv(NUM_LANES_G-1 downto 0);
      pgpRxClkRst       : in  slv(NUM_LANES_G-1 downto 0);
      pgpRxIn           : out Pgp2bRxInArray(NUM_LANES_G-1 downto 0);
      pgpRxOut          : in  Pgp2bRxOutArray(NUM_LANES_G-1 downto 0);
      pgpRxMasterMuxed  : in  AxiStreamMasterArray(NUM_LANES_G-1 downto 0);
      pgpRxCtrl         : out AxiStreamCtrlArray((NUM_LANES_G*4)-1 downto 0);

      -- AXI/Status Clocks Interface
      axilClk           : in  sl;
      axilClkRst        : in  sl
   );
end PpiPgpArray;

architecture structure of PpiPgpArray is

   signal intAxilWriteMaster   : AxiLiteWriteMasterArray(NUM_LANES_G-1 downto 0);
   signal intAxilWriteSlave    : AxiLiteWriteSlaveArray(NUM_LANES_G-1 downto 0);
   signal intAxilReadMaster    : AxiLiteReadMasterArray(NUM_LANES_G-1 downto 0);
   signal intAxilReadSlave     : AxiLiteReadSlaveArray(NUM_LANES_G-1 downto 0);
   signal locIbMaster          : AxiStreamMasterArray(NUM_LANES_G-1 downto 0);
   signal locIbSlave           : AxiStreamSlaveArray(NUM_LANES_G-1 downto 0);
   signal locObMaster          : AxiStreamMasterArray(NUM_LANES_G-1 downto 0);
   signal locObSlave           : AxiStreamSlaveArray(NUM_LANES_G-1 downto 0);
   signal statusWords          : Slv64Array(NUM_LANES_G-1 downto 0);
   signal statusSend           : slv(NUM_LANES_G-1 downto 0);

begin

   -- PPI Crossbar
   U_PpiInterconnect : entity work.PpiInterconnect
      generic map (
         TPD_G               => TPD_G,
         NUM_PPI_SLOTS_G     => NUM_LANES_G,
         NUM_AXI_SLOTS_G     => NUM_LANES_G,
         NUM_STATUS_WORDS_G  => 1,
         STATUS_SEND_WIDTH_G => 1
      ) port map (
         ppiClk              => ppiClk,
         ppiClkRst           => ppiClkRst,
         ppiState            => ppiState,
         ppiIbMaster         => ppiIbMaster,
         ppiIbSlave          => ppiIbSlave,
         ppiObMaster         => ppiObMaster,
         ppiObSlave          => ppiObSlave,
         locIbMaster         => locIbMaster,
         locIbSlave          => locIbSlave,
         locObMaster         => locObMaster,
         locObSlave          => locObSlave,
         axilClk             => axilClk,
         axilClkRst          => axilClkRst,
         axilWriteMasters    => intAxilWriteMasters,
         axilWriteSlaves     => intAxilWriteSlaves,
         axilReadMasters     => intAxilReadMasters,
         axilReadSlaves      => intAxilReadSlaves,
         statusClk           => axilClk,
         statusClkRst        => axilClkRst,
         statusWords         => statusWords,
         statusSend          => statusSend
      );

   -- PGP Lane Controllers
   U_LaneGen : for i in 0 to NUM_LANES_G-1 generate 
      U_PpiPgpLane: entity work.PpiPgpLane
         generic map (
            TPD_G                    => TPD_G,
            AXI_CLK_FREQ_G           => AXI_CLK_FREQ_G,
            RX_AXIS_ADDR_WIDTH_G     => RX_AXIS_ADDR_WIDTH_G,
            RX_AXIS_PAUSE_THRESH_G   => RX_AXIS_PAUSE_THRESH_G,
            RX_AXIS_CASCADE_SIZE_G   => RX_AXIS_CASCADE_SIZE_G,
            RX_DATA_ADDR_WIDTH_G     => RX_DATA_ADDR_WIDTH_G,
            RX_HEADER_ADDR_WIDTH_G   => RX_HEADER_ADDR_WIDTH_G,
            RX_PPI_MAX_FRAME_SIZE_G  => RX_PPI_MAX_FRAME_SIZE_G,
            TX_PPI_ADDR_WIDTH_G      => TX_PPI_ADDR_WIDTH_G,
            TX_AXIS_ADDR_WIDTH_G     => TX_AXIS_ADDR_WIDTH_G,
            TX_AXIS_CASCADE_SIZE_G   => TX_AXIS_CASCADE_SIZE_G
         ) port map (
            ppiClk             => ppiClk,
            ppiClkRst          => ppiClkRst,
            ppiState           => ppiState,
            ppiIbMaster        => locIbMaster,
            ppiIbSlave         => locIbSlave,
            ppiObMaster        => locObMaster,
            ppiObSlave         => locObSlave,
            pgpTxClk           => pgpTxClk(i),
            pgpTxClkRst        => pgpTxClkRst(i),
            pgpTxIn            => pgpTxIn(i),
            pgpTxOut           => pgpTxOut(i),
            pgpTxMasters       => pgpTxMasters((i*4)+3 downto i*4),
            pgpTxSlaves        => pgpTxSlaves((i*4)+3 downto i*4),
            pgpRxClk           => pgpRxClk(i),
            pgpRxClkRst        => pgpRxClkRst(i),
            pgpRxIn            => pgpRxIn(i),
            pgpRxOut           => pgpRxOut(i),
            pgpRxMasterMuxed   => pgpRxMasterMuxed(i),
            pgpRxCtrl          => pgpRxCtrl((i*4)+3 downto i*4),
            axilClk            => axilClk,
            axilClkRst         => axilClkRst,
            axilWriteMaster    => intAxilWriteMasters(i),
            axilWriteSlave     => intAxilWriteSlaves(i),
            axilReadMaster     => intAxilReadMasters(i),
            axilReadSlave      => intAxilReadSlaves(i),
            statusWord         => statusWords(i),
            statusSend         => statusSend(i)
         );
   end generate;

end architecture structure;

