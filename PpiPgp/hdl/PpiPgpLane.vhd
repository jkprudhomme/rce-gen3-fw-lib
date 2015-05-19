-------------------------------------------------------------------------------
-- Title         : PPI To PGP Block
-- File          : PpiPgpLane.vhd
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

library unisim;
use unisim.vcomponents.all;

use work.PpiPkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.Pgp2bPkg.all;
use work.SsiPkg.all;
use work.RceG3Pkg.all;

entity PpiPgpLane is
   generic (
      TPD_G                   : time    := 1 ns;
      AXI_CLK_FREQ_G          : real    := 125.0E+6;
      RX_AXIS_ADDR_WIDTH_G    : integer := 9;
      RX_AXIS_PAUSE_THRESH_G  : integer := 500;
      RX_AXIS_CASCADE_SIZE_G  : integer := 1;
      RX_DATA_ADDR_WIDTH_G    : integer := 9;
      RX_HEADER_ADDR_WIDTH_G  : integer := 9;
      RX_PPI_MAX_FRAME_SIZE_G : integer := 2048;
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

      -- TX PGP Interface
      pgpTxClk          : in  sl;
      pgpTxClkRst       : in  sl;
      pgpTxIn           : out Pgp2bTxInType;
      pgpTxOut          : in  Pgp2bTxOutType;
      pgpTxMasters      : out AxiStreamMasterArray(3 downto 0);
      pgpTxSlaves       : in  AxiStreamSlaveArray(3 downto 0);

      -- RX PGP Interface
      pgpRxClk          : in  sl;
      pgpRxClkRst       : in  sl;
      pgpRxIn           : out Pgp2bRxInType;
      pgpRxOut          : in  Pgp2bRxOutType;
      pgpRxMasterMuxed  : in  AxiStreamMasterType;
      pgpRxCtrl         : out AxiStreamCtrlArray(3 downto 0);

      -- AXI/Status Clocks Interface
      axilClk           : in  sl;
      axilClkRst        : in  sl;

      -- AXI Interface
      axilWriteMaster   : in  AxiLiteWriteMasterType;
      axilWriteSlave    : out AxiLiteWriteSlaveType;
      axilReadMaster    : in  AxiLiteReadMasterType;
      axilReadSlave     : out AxiLiteReadSlaveType
   );
end PpiPgpLane;

architecture structure of PpiPgpLane is

   -- Local Signals
   signal ipgpRxCtrl     : AxiStreamCtrlType;
   signal ipgpTxMaster   : AxiStreamMasterType;
   signal ipgpTxSlave    : AxiStreamSlaveType;

begin

   -- PGP Axil Controller
   U_Pgp2bAxi : entity work.Pgp2bAxi 
      generic map (
         TPD_G              => TPD_G,
         COMMON_TX_CLK_G    => false,
         COMMON_RX_CLK_G    => false,
         WRITE_EN_G         => true,
         AXI_CLK_FREQ_G     => AXI_CLK_FREQ_G,
         STATUS_CNT_WIDTH_G => 32,
         ERROR_CNT_WIDTH_G  => 4
      ) port map (
         pgpTxClk          => pgpTxClk,
         pgpTxClkRst       => pgpTxClkRst,
         pgpTxIn           => pgpTxIn,
         pgpTxOut          => pgpTxOut,
         pgpRxClk          => pgpRxClk,
         pgpRxClkRst       => pgpRxClkRst,
         pgpRxIn           => pgpRxIn,
         pgpRxOut          => pgpRxOut,
         statusWord        => open,
         statusSend        => open,
         axilClk           => axilClk,
         axilRst           => axilClkRst,
         axilReadMaster    => axilReadMaster,
         axilReadSlave     => axilReadSlave,
         axilWriteMaster   => axilWriteMaster,
         axilWriteSlave    => axilWriteSlave
      );

   -- Inbound
   U_AxisToPpi: entity work.AxisToPpi
      generic map (
         TPD_G                => TPD_G,
         AXIS_CONFIG_G        => SSI_PGP2B_CONFIG_C,
         AXIS_READY_EN_G      => false,
         AXIS_ERROR_EN_G      => true,
         AXIS_ERROR_BIT_G     => SSI_EOFE_C,
         AXIS_ADDR_WIDTH_G    => RX_AXIS_ADDR_WIDTH_G,
         AXIS_PAUSE_THRESH_G  => RX_AXIS_PAUSE_THRESH_G,
         AXIS_CASCADE_SIZE_G  => RX_AXIS_CASCADE_SIZE_G,
         DATA_ADDR_WIDTH_G    => RX_DATA_ADDR_WIDTH_G,
         HEADER_ADDR_WIDTH_G  => RX_HEADER_ADDR_WIDTH_G,
         PPI_MAX_FRAME_SIZE_G => RX_PPI_MAX_FRAME_SIZE_G
      ) port map (
         ppiClk           => ppiClk,
         ppiClkRst        => ppiClkRst,
         ppiState         => ppiState,
         ppiIbMaster      => ppiIbMaster,
         ppiIbSlave       => ppiIbSlave,
         axisIbClk        => pgpRxClk,
         axisIbClkRst     => pgpRxClkRst,
         axisIbMaster     => pgpRxMasterMuxed,
         axisIbSlave      => open,
         axisIbCtrl       => ipgpRxCtrl,
         rxFrameCntEn     => open,
         rxOverflow       => open
      );

   pgpRxCtrl <= (others=>ipgpRxCtrl);

   -- Outbound 
   U_PpiToAxis : entity work.PpiToAxis
      generic map (
         AXIS_CONFIG_G        => SSI_PGP2B_CONFIG_C,
         PPI_ADDR_WIDTH_G     => TX_PPI_ADDR_WIDTH_G,
         AXIS_ADDR_WIDTH_G    => TX_AXIS_ADDR_WIDTH_G,
         AXIS_CASCADE_SIZE_G  => TX_AXIS_CASCADE_SIZE_G
      ) port map (
         ppiClk           => ppiClk,
         ppiClkRst        => ppiClkRst,
         ppiState         => ppiState,
         ppiObMaster      => ppiObMaster,
         ppiObSlave       => ppiObSlave,
         axisObClk        => pgpTxClk,
         axisObClkRst     => pgpTxClkRst,
         axisObMaster     => ipgpTxMaster,
         axisObSlave      => ipgpTxSlave,
         txFrameCntEn     => open
      );

   -- Outbound de-mux
   U_AxisStreamDeMux: entity work.AxiStreamDeMux 
      generic map (
         TPD_G         => TPD_G,
         NUM_MASTERS_G => 4
      ) port map (
         axisClk      => pgpTxClk,
         axisRst      => pgpTxClkRst,
         sAxisMaster  => ipgpTxMaster,
         sAxisSlave   => ipgpTxSlave,
         mAxisMasters => pgpTxMasters,
         mAxisSlaves  => pgpTxSlaves
      );

end architecture structure;

