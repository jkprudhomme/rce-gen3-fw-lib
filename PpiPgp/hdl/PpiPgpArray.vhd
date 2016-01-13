-------------------------------------------------------------------------------
-- Title         : PPI To PGP Block
-- File          : PpiPgpArray.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to receive and transmit PGP Frames.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE PGP Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE PGP Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 03/21/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.Pgp2bPkg.all;
use work.RceG3Pkg.all;
use work.Gtx7CfgPkg.all;

entity PpiPgpArray is
   generic (
      TPD_G                   : time                  := 1 ns;
      NUM_LANES_G             : integer range 1 to 12 := 12;
      AXIL_BASE_ADDRESS_G     : slv(31 downto 0)      := X"00000000";
      AXIL_CLK_FREQ_G         : real                  := 125.0E+6;
      RX_AXIS_ADDR_WIDTH_G    : integer               := 9;
      RX_AXIS_PAUSE_THRESH_G  : integer               := 500;
      RX_AXIS_CASCADE_SIZE_G  : integer               := 1;
      RX_DATA_ADDR_WIDTH_G    : integer               := 9;
      RX_HEADER_ADDR_WIDTH_G  : integer               := 9;
      RX_PPI_MAX_FRAME_SIZE_G : integer               := 2048;
      TX_PPI_ADDR_WIDTH_G     : integer               := 9;
      TX_AXIS_ADDR_WIDTH_G    : integer               := 9;
      TX_AXIS_CASCADE_SIZE_G  : integer               := 1
      );
   port (

      -- PPI Interface
      ppiClk      : in  sl;
      ppiClkRst   : in  sl;
      ppiState    : in  RceDmaStateType;
      ppiIbMaster : out AxiStreamMasterType;
      ppiIbSlave  : in  AxiStreamSlaveType;
      ppiObMaster : in  AxiStreamMasterType;
      ppiObSlave  : out AxiStreamSlaveType;

      -- TX PGP Interfaces
      pgpTxClk     : in  slv(NUM_LANES_G-1 downto 0);
      pgpTxClkRst  : in  slv(NUM_LANES_G-1 downto 0);
      pgpTxIn      : out Pgp2bTxInArray(NUM_LANES_G-1 downto 0);
      pgpTxOut     : in  Pgp2bTxOutArray(NUM_LANES_G-1 downto 0);
      pgpTxMasters : out AxiStreamQuadMasterArray(NUM_LANES_G-1 downto 0);
      pgpTxSlaves  : in  AxiStreamQuadSlaveArray(NUM_LANES_G-1 downto 0);

      -- RX PGP Interfaces
      pgpRxClk         : in  slv(NUM_LANES_G-1 downto 0);
      pgpRxClkRst      : in  slv(NUM_LANES_G-1 downto 0);
      pgpRxIn          : out Pgp2bRxInArray(NUM_LANES_G-1 downto 0);
      pgpRxOut         : in  Pgp2bRxOutArray(NUM_LANES_G-1 downto 0);
      pgpRxMasterMuxed : in  AxiStreamMasterArray(NUM_LANES_G-1 downto 0);
      pgpRxCtrl        : out AxiStreamQuadCtrlArray(NUM_LANES_G-1 downto 0);

      -- AXI/Status Clocks Interface
      axilClk         : in  sl;
      axilClkRst      : in  sl;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType
      );
end PpiPgpArray;

architecture structure of PpiPgpArray is

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray :=
      genAxiLiteConfig(NUM_LANES_G, AXIL_BASE_ADDRESS_G, 16, 12);

   signal intAxilWriteMasters : AxiLiteWriteMasterArray(NUM_LANES_G-1 downto 0);
   signal intAxilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_LANES_G-1 downto 0);
   signal intAxilReadMasters  : AxiLiteReadMasterArray(NUM_LANES_G-1 downto 0);
   signal intAxilReadSlaves   : AxiLiteReadSlaveArray(NUM_LANES_G-1 downto 0);

   signal locIbMaster : AxiStreamMasterArray(NUM_LANES_G-1 downto 0);
   signal locIbSlave  : AxiStreamSlaveArray(NUM_LANES_G-1 downto 0);
   signal locObMaster : AxiStreamMasterArray(NUM_LANES_G-1 downto 0);
   signal locObSlave  : AxiStreamSlaveArray(NUM_LANES_G-1 downto 0);

begin

   -------------------------------------------------------------------------------------------------
   -- Route AXI-Lite bus to each PpiPgpLane, which contains a Pgp2bAxi instance
   -------------------------------------------------------------------------------------------------
   AxiLiteCrossbar_1 : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_LANES_G,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilClkRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => intAxilWriteMasters,
         mAxiWriteSlaves     => intAxilWriteSlaves,
         mAxiReadMasters     => intAxilReadMasters,
         mAxiReadSlaves      => intAxilReadSlaves);

   -- Outbound DeMux
   U_ObDeMux : entity work.AxiStreamDeMux
      generic map (
         TPD_G         => TPD_G,
         NUM_MASTERS_G => NUM_LANES_G
         ) port map (
            axisClk      => ppiClk,
            axisRst      => ppiClkRst,
            sAxisMaster  => ppiObMaster,
            sAxisSlave   => ppiObSlave,
            mAxisMasters => locObMaster,
            mAxisSlaves  => locObSlave
            );

   -- Inbound Mux
   U_IbMux : entity work.AxiStreamMux
      generic map (
         TPD_G        => TPD_G,
         NUM_SLAVES_G => NUM_LANES_G
         ) port map (
            axisClk      => ppiClk,
            axisRst      => ppiClkRst,
            sAxisMasters => locIbMaster,
            sAxisSlaves  => locIbSlave,
            mAxisMaster  => ppiIbMaster,
            mAxisSlave   => ppiIbSlave

            );

   -- PGP Lane Controllers
   U_LaneGen : for i in 0 to NUM_LANES_G-1 generate
      U_PpiPgpLane : entity work.PpiPgpLane
         generic map (
            TPD_G                   => TPD_G,
            AXI_CLK_FREQ_G          => AXIL_CLK_FREQ_G,
            RX_AXIS_ADDR_WIDTH_G    => RX_AXIS_ADDR_WIDTH_G,
            RX_AXIS_PAUSE_THRESH_G  => RX_AXIS_PAUSE_THRESH_G,
            RX_AXIS_CASCADE_SIZE_G  => RX_AXIS_CASCADE_SIZE_G,
            RX_DATA_ADDR_WIDTH_G    => RX_DATA_ADDR_WIDTH_G,
            RX_HEADER_ADDR_WIDTH_G  => RX_HEADER_ADDR_WIDTH_G,
            RX_PPI_MAX_FRAME_SIZE_G => RX_PPI_MAX_FRAME_SIZE_G,
            TX_PPI_ADDR_WIDTH_G     => TX_PPI_ADDR_WIDTH_G,
            TX_AXIS_ADDR_WIDTH_G    => TX_AXIS_ADDR_WIDTH_G,
            TX_AXIS_CASCADE_SIZE_G  => TX_AXIS_CASCADE_SIZE_G
            ) port map (
               ppiClk           => ppiClk,
               ppiClkRst        => ppiClkRst,
               ppiState         => ppiState,
               ppiIbMaster      => locIbMaster(i),
               ppiIbSlave       => locIbSlave(i),
               ppiObMaster      => locObMaster(i),
               ppiObSlave       => locObSlave(i),
               pgpTxClk         => pgpTxClk(i),
               pgpTxClkRst      => pgpTxClkRst(i),
               pgpTxIn          => pgpTxIn(i),
               pgpTxOut         => pgpTxOut(i),
               pgpTxMasters     => pgpTxMasters(i),
               pgpTxSlaves      => pgpTxSlaves(i),
               pgpRxClk         => pgpRxClk(i),
               pgpRxClkRst      => pgpRxClkRst(i),
               pgpRxIn          => pgpRxIn(i),
               pgpRxOut         => pgpRxOut(i),
               pgpRxMasterMuxed => pgpRxMasterMuxed(i),
               pgpRxCtrl        => pgpRxCtrl(i),
               axilClk          => axilClk,
               axilClkRst       => axilClkRst,
               axilWriteMaster  => intAxilWriteMasters(i),
               axilWriteSlave   => intAxilWriteSlaves(i),
               axilReadMaster   => intAxilReadMasters(i),
               axilReadSlave    => intAxilReadSlaves(i));
   end generate;

end architecture structure;

