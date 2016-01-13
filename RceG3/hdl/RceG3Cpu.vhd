-------------------------------------------------------------------------------
-- Title         : RCE Generation 3, CPU Wrapper
-- File          : RceG3Cpu.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- CPU wrapper for ARM based rce generation 3 processor core.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
      armInterrupt        : in  slv(15 downto 0);

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
      acpAxiClk           : in  sl;
      acpWriteSlave       : out AxiWriteSlaveType;
      acpWriteMaster      : in  AxiWriteMasterType;
      acpReadSlave        : out AxiReadSlaveType;
      acpReadMaster       : in  AxiReadMasterType;

      -- AXI HP Slave
      hpAxiClk            : in  slv(3 downto 0);
      hpWriteSlave        : out AxiWriteSlaveArray(3 downto 0);
      hpWriteMaster       : in  AxiWriteMasterArray(3 downto 0);
      hpReadSlave         : out AxiReadSlaveArray(3 downto 0);
      hpReadMaster        : in  AxiReadMasterArray(3 downto 0);

      -- Ethernet
      armEthTx            : out ArmEthTxArray(1 downto 0);
      armEthRx            : in  ArmEthRxArray(1 downto 0)
   );
end RceG3Cpu;

architecture Hw of RceG3Cpu is

   COMPONENT processing_system7_0
     PORT (
       ENET0_GMII_TX_EN : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
       ENET0_GMII_TX_ER : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
       ENET0_MDIO_MDC : OUT STD_LOGIC;
       ENET0_MDIO_O : OUT STD_LOGIC;
       ENET0_MDIO_T : OUT STD_LOGIC;
       ENET0_PTP_DELAY_REQ_RX : OUT STD_LOGIC;
       ENET0_PTP_DELAY_REQ_TX : OUT STD_LOGIC;
       ENET0_PTP_PDELAY_REQ_RX : OUT STD_LOGIC;
       ENET0_PTP_PDELAY_REQ_TX : OUT STD_LOGIC;
       ENET0_PTP_PDELAY_RESP_RX : OUT STD_LOGIC;
       ENET0_PTP_PDELAY_RESP_TX : OUT STD_LOGIC;
       ENET0_PTP_SYNC_FRAME_RX : OUT STD_LOGIC;
       ENET0_PTP_SYNC_FRAME_TX : OUT STD_LOGIC;
       ENET0_SOF_RX : OUT STD_LOGIC;
       ENET0_SOF_TX : OUT STD_LOGIC;
       ENET0_GMII_TXD : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       ENET0_GMII_COL : IN STD_LOGIC;
       ENET0_GMII_CRS : IN STD_LOGIC;
       ENET0_GMII_RX_CLK : IN STD_LOGIC;
       ENET0_GMII_RX_DV : IN STD_LOGIC;
       ENET0_GMII_RX_ER : IN STD_LOGIC;
       ENET0_GMII_TX_CLK : IN STD_LOGIC;
       ENET0_MDIO_I : IN STD_LOGIC;
       ENET0_EXT_INTIN : IN STD_LOGIC;
       ENET0_GMII_RXD : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
       ENET1_GMII_TX_EN : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
       ENET1_GMII_TX_ER : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
       ENET1_MDIO_MDC : OUT STD_LOGIC;
       ENET1_MDIO_O : OUT STD_LOGIC;
       ENET1_MDIO_T : OUT STD_LOGIC;
       --ENET1_PTP_DELAY_REQ_RX : OUT STD_LOGIC;
       --ENET1_PTP_DELAY_REQ_TX : OUT STD_LOGIC;
       --ENET1_PTP_PDELAY_REQ_RX : OUT STD_LOGIC;
       --ENET1_PTP_PDELAY_REQ_TX : OUT STD_LOGIC;
       --ENET1_PTP_PDELAY_RESP_RX : OUT STD_LOGIC;
       --ENET1_PTP_PDELAY_RESP_TX : OUT STD_LOGIC;
       --ENET1_PTP_SYNC_FRAME_RX : OUT STD_LOGIC;
       --ENET1_PTP_SYNC_FRAME_TX : OUT STD_LOGIC;
       --ENET1_SOF_RX : OUT STD_LOGIC;
       --ENET1_SOF_TX : OUT STD_LOGIC;
       ENET1_GMII_TXD : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       ENET1_GMII_COL : IN STD_LOGIC;
       ENET1_GMII_CRS : IN STD_LOGIC;
       ENET1_GMII_RX_CLK : IN STD_LOGIC;
       ENET1_GMII_RX_DV : IN STD_LOGIC;
       ENET1_GMII_RX_ER : IN STD_LOGIC;
       ENET1_GMII_TX_CLK : IN STD_LOGIC;
       ENET1_MDIO_I : IN STD_LOGIC;
       ENET1_EXT_INTIN : IN STD_LOGIC;
       ENET1_GMII_RXD : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
       GPIO_I : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
       GPIO_O : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
       GPIO_T : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
       TTC0_WAVE0_OUT : OUT STD_LOGIC;
       TTC0_WAVE1_OUT : OUT STD_LOGIC;
       TTC0_WAVE2_OUT : OUT STD_LOGIC;
       --TTC0_CLK0_IN : IN STD_LOGIC;
       --TTC0_CLK1_IN : IN STD_LOGIC;
       --TTC0_CLK2_IN : IN STD_LOGIC;
       WDT_RST_OUT : OUT STD_LOGIC;
       USB0_PORT_INDCTL : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       USB0_VBUS_PWRSELECT : OUT STD_LOGIC;
       USB0_VBUS_PWRFAULT : IN STD_LOGIC;
       M_AXI_GP0_ARVALID : OUT STD_LOGIC;
       M_AXI_GP0_AWVALID : OUT STD_LOGIC;
       M_AXI_GP0_BREADY : OUT STD_LOGIC;
       M_AXI_GP0_RREADY : OUT STD_LOGIC;
       M_AXI_GP0_WLAST : OUT STD_LOGIC;
       M_AXI_GP0_WVALID : OUT STD_LOGIC;
       M_AXI_GP0_ARID : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
       M_AXI_GP0_AWID : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
       M_AXI_GP0_WID : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
       M_AXI_GP0_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       M_AXI_GP0_ARLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       M_AXI_GP0_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       M_AXI_GP0_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       M_AXI_GP0_AWLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       M_AXI_GP0_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       M_AXI_GP0_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       M_AXI_GP0_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       M_AXI_GP0_ARADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       M_AXI_GP0_AWADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       M_AXI_GP0_WDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       M_AXI_GP0_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP0_ARLEN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP0_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP0_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP0_AWLEN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP0_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP0_WSTRB : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP0_ACLK : IN STD_LOGIC;
       M_AXI_GP0_ARREADY : IN STD_LOGIC;
       M_AXI_GP0_AWREADY : IN STD_LOGIC;
       M_AXI_GP0_BVALID : IN STD_LOGIC;
       M_AXI_GP0_RLAST : IN STD_LOGIC;
       M_AXI_GP0_RVALID : IN STD_LOGIC;
       M_AXI_GP0_WREADY : IN STD_LOGIC;
       M_AXI_GP0_BID : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
       M_AXI_GP0_RID : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
       M_AXI_GP0_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       M_AXI_GP0_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       M_AXI_GP0_RDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       M_AXI_GP1_ARVALID : OUT STD_LOGIC;
       M_AXI_GP1_AWVALID : OUT STD_LOGIC;
       M_AXI_GP1_BREADY : OUT STD_LOGIC;
       M_AXI_GP1_RREADY : OUT STD_LOGIC;
       M_AXI_GP1_WLAST : OUT STD_LOGIC;
       M_AXI_GP1_WVALID : OUT STD_LOGIC;
       M_AXI_GP1_ARID : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
       M_AXI_GP1_AWID : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
       M_AXI_GP1_WID : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
       M_AXI_GP1_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       M_AXI_GP1_ARLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       M_AXI_GP1_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       M_AXI_GP1_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       M_AXI_GP1_AWLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       M_AXI_GP1_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       M_AXI_GP1_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       M_AXI_GP1_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       M_AXI_GP1_ARADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       M_AXI_GP1_AWADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       M_AXI_GP1_WDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       M_AXI_GP1_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP1_ARLEN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP1_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP1_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP1_AWLEN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP1_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP1_WSTRB : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       M_AXI_GP1_ACLK : IN STD_LOGIC;
       M_AXI_GP1_ARREADY : IN STD_LOGIC;
       M_AXI_GP1_AWREADY : IN STD_LOGIC;
       M_AXI_GP1_BVALID : IN STD_LOGIC;
       M_AXI_GP1_RLAST : IN STD_LOGIC;
       M_AXI_GP1_RVALID : IN STD_LOGIC;
       M_AXI_GP1_WREADY : IN STD_LOGIC;
       M_AXI_GP1_BID : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
       M_AXI_GP1_RID : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
       M_AXI_GP1_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       M_AXI_GP1_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       M_AXI_GP1_RDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_GP0_ARREADY : OUT STD_LOGIC;
       S_AXI_GP0_AWREADY : OUT STD_LOGIC;
       S_AXI_GP0_BVALID : OUT STD_LOGIC;
       S_AXI_GP0_RLAST : OUT STD_LOGIC;
       S_AXI_GP0_RVALID : OUT STD_LOGIC;
       S_AXI_GP0_WREADY : OUT STD_LOGIC;
       S_AXI_GP0_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_GP0_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_GP0_RDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_GP0_BID : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_GP0_RID : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_GP0_ACLK : IN STD_LOGIC;
       S_AXI_GP0_ARVALID : IN STD_LOGIC;
       S_AXI_GP0_AWVALID : IN STD_LOGIC;
       S_AXI_GP0_BREADY : IN STD_LOGIC;
       S_AXI_GP0_RREADY : IN STD_LOGIC;
       S_AXI_GP0_WLAST : IN STD_LOGIC;
       S_AXI_GP0_WVALID : IN STD_LOGIC;
       S_AXI_GP0_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_GP0_ARLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_GP0_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_GP0_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_GP0_AWLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_GP0_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_GP0_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_GP0_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_GP0_ARADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_GP0_AWADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_GP0_WDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_GP0_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP0_ARLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP0_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP0_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP0_AWLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP0_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP0_WSTRB : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP0_ARID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_GP0_AWID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_GP0_WID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_GP1_ARREADY : OUT STD_LOGIC;
       S_AXI_GP1_AWREADY : OUT STD_LOGIC;
       S_AXI_GP1_BVALID : OUT STD_LOGIC;
       S_AXI_GP1_RLAST : OUT STD_LOGIC;
       S_AXI_GP1_RVALID : OUT STD_LOGIC;
       S_AXI_GP1_WREADY : OUT STD_LOGIC;
       S_AXI_GP1_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_GP1_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_GP1_RDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_GP1_BID : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_GP1_RID : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_GP1_ACLK : IN STD_LOGIC;
       S_AXI_GP1_ARVALID : IN STD_LOGIC;
       S_AXI_GP1_AWVALID : IN STD_LOGIC;
       S_AXI_GP1_BREADY : IN STD_LOGIC;
       S_AXI_GP1_RREADY : IN STD_LOGIC;
       S_AXI_GP1_WLAST : IN STD_LOGIC;
       S_AXI_GP1_WVALID : IN STD_LOGIC;
       S_AXI_GP1_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_GP1_ARLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_GP1_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_GP1_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_GP1_AWLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_GP1_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_GP1_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_GP1_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_GP1_ARADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_GP1_AWADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_GP1_WDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_GP1_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP1_ARLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP1_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP1_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP1_AWLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP1_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP1_WSTRB : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_GP1_ARID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_GP1_AWID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_GP1_WID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_ACP_ARREADY : OUT STD_LOGIC;
       S_AXI_ACP_AWREADY : OUT STD_LOGIC;
       S_AXI_ACP_BVALID : OUT STD_LOGIC;
       S_AXI_ACP_RLAST : OUT STD_LOGIC;
       S_AXI_ACP_RVALID : OUT STD_LOGIC;
       S_AXI_ACP_WREADY : OUT STD_LOGIC;
       S_AXI_ACP_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_ACP_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_ACP_BID : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_ACP_RID : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_ACP_RDATA : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
       S_AXI_ACP_ACLK : IN STD_LOGIC;
       S_AXI_ACP_ARVALID : IN STD_LOGIC;
       S_AXI_ACP_AWVALID : IN STD_LOGIC;
       S_AXI_ACP_BREADY : IN STD_LOGIC;
       S_AXI_ACP_RREADY : IN STD_LOGIC;
       S_AXI_ACP_WLAST : IN STD_LOGIC;
       S_AXI_ACP_WVALID : IN STD_LOGIC;
       S_AXI_ACP_ARID : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_ACP_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_ACP_AWID : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_ACP_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_ACP_WID : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_ACP_ARADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_ACP_AWADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_ACP_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_ACP_ARLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_ACP_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_ACP_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_ACP_AWLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_ACP_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_ACP_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_ACP_ARLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_ACP_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_ACP_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_ACP_AWLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_ACP_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_ACP_ARUSER : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
       S_AXI_ACP_AWUSER : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
       S_AXI_ACP_WDATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
       S_AXI_ACP_WSTRB : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
       S_AXI_HP0_ARREADY : OUT STD_LOGIC;
       S_AXI_HP0_AWREADY : OUT STD_LOGIC;
       S_AXI_HP0_BVALID : OUT STD_LOGIC;
       S_AXI_HP0_RLAST : OUT STD_LOGIC;
       S_AXI_HP0_RVALID : OUT STD_LOGIC;
       S_AXI_HP0_WREADY : OUT STD_LOGIC;
       S_AXI_HP0_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP0_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP0_BID : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP0_RID : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP0_RDATA : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
       S_AXI_HP0_RCOUNT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       S_AXI_HP0_WCOUNT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       S_AXI_HP0_RACOUNT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP0_WACOUNT : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP0_ACLK : IN STD_LOGIC;
       S_AXI_HP0_ARVALID : IN STD_LOGIC;
       S_AXI_HP0_AWVALID : IN STD_LOGIC;
       S_AXI_HP0_BREADY : IN STD_LOGIC;
       S_AXI_HP0_RDISSUECAP1_EN : IN STD_LOGIC;
       S_AXI_HP0_RREADY : IN STD_LOGIC;
       S_AXI_HP0_WLAST : IN STD_LOGIC;
       S_AXI_HP0_WRISSUECAP1_EN : IN STD_LOGIC;
       S_AXI_HP0_WVALID : IN STD_LOGIC;
       S_AXI_HP0_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP0_ARLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP0_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP0_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP0_AWLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP0_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP0_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP0_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP0_ARADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_HP0_AWADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_HP0_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP0_ARLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP0_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP0_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP0_AWLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP0_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP0_ARID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP0_AWID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP0_WID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP0_WDATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
       S_AXI_HP0_WSTRB : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
       S_AXI_HP1_ARREADY : OUT STD_LOGIC;
       S_AXI_HP1_AWREADY : OUT STD_LOGIC;
       S_AXI_HP1_BVALID : OUT STD_LOGIC;
       S_AXI_HP1_RLAST : OUT STD_LOGIC;
       S_AXI_HP1_RVALID : OUT STD_LOGIC;
       S_AXI_HP1_WREADY : OUT STD_LOGIC;
       S_AXI_HP1_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP1_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP1_BID : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP1_RID : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP1_RDATA : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
       S_AXI_HP1_RCOUNT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       S_AXI_HP1_WCOUNT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       S_AXI_HP1_RACOUNT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP1_WACOUNT : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP1_ACLK : IN STD_LOGIC;
       S_AXI_HP1_ARVALID : IN STD_LOGIC;
       S_AXI_HP1_AWVALID : IN STD_LOGIC;
       S_AXI_HP1_BREADY : IN STD_LOGIC;
       S_AXI_HP1_RDISSUECAP1_EN : IN STD_LOGIC;
       S_AXI_HP1_RREADY : IN STD_LOGIC;
       S_AXI_HP1_WLAST : IN STD_LOGIC;
       S_AXI_HP1_WRISSUECAP1_EN : IN STD_LOGIC;
       S_AXI_HP1_WVALID : IN STD_LOGIC;
       S_AXI_HP1_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP1_ARLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP1_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP1_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP1_AWLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP1_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP1_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP1_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP1_ARADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_HP1_AWADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_HP1_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP1_ARLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP1_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP1_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP1_AWLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP1_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP1_ARID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP1_AWID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP1_WID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP1_WDATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
       S_AXI_HP1_WSTRB : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
       S_AXI_HP2_ARREADY : OUT STD_LOGIC;
       S_AXI_HP2_AWREADY : OUT STD_LOGIC;
       S_AXI_HP2_BVALID : OUT STD_LOGIC;
       S_AXI_HP2_RLAST : OUT STD_LOGIC;
       S_AXI_HP2_RVALID : OUT STD_LOGIC;
       S_AXI_HP2_WREADY : OUT STD_LOGIC;
       S_AXI_HP2_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP2_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP2_BID : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP2_RID : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP2_RDATA : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
       S_AXI_HP2_RCOUNT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       S_AXI_HP2_WCOUNT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       S_AXI_HP2_RACOUNT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP2_WACOUNT : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP2_ACLK : IN STD_LOGIC;
       S_AXI_HP2_ARVALID : IN STD_LOGIC;
       S_AXI_HP2_AWVALID : IN STD_LOGIC;
       S_AXI_HP2_BREADY : IN STD_LOGIC;
       S_AXI_HP2_RDISSUECAP1_EN : IN STD_LOGIC;
       S_AXI_HP2_RREADY : IN STD_LOGIC;
       S_AXI_HP2_WLAST : IN STD_LOGIC;
       S_AXI_HP2_WRISSUECAP1_EN : IN STD_LOGIC;
       S_AXI_HP2_WVALID : IN STD_LOGIC;
       S_AXI_HP2_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP2_ARLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP2_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP2_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP2_AWLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP2_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP2_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP2_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP2_ARADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_HP2_AWADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_HP2_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP2_ARLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP2_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP2_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP2_AWLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP2_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP2_ARID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP2_AWID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP2_WID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP2_WDATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
       S_AXI_HP2_WSTRB : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
       S_AXI_HP3_ARREADY : OUT STD_LOGIC;
       S_AXI_HP3_AWREADY : OUT STD_LOGIC;
       S_AXI_HP3_BVALID : OUT STD_LOGIC;
       S_AXI_HP3_RLAST : OUT STD_LOGIC;
       S_AXI_HP3_RVALID : OUT STD_LOGIC;
       S_AXI_HP3_WREADY : OUT STD_LOGIC;
       S_AXI_HP3_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP3_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP3_BID : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP3_RID : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP3_RDATA : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
       S_AXI_HP3_RCOUNT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       S_AXI_HP3_WCOUNT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       S_AXI_HP3_RACOUNT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP3_WACOUNT : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP3_ACLK : IN STD_LOGIC;
       S_AXI_HP3_ARVALID : IN STD_LOGIC;
       S_AXI_HP3_AWVALID : IN STD_LOGIC;
       S_AXI_HP3_BREADY : IN STD_LOGIC;
       S_AXI_HP3_RDISSUECAP1_EN : IN STD_LOGIC;
       S_AXI_HP3_RREADY : IN STD_LOGIC;
       S_AXI_HP3_WLAST : IN STD_LOGIC;
       S_AXI_HP3_WRISSUECAP1_EN : IN STD_LOGIC;
       S_AXI_HP3_WVALID : IN STD_LOGIC;
       S_AXI_HP3_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP3_ARLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP3_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP3_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP3_AWLOCK : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       S_AXI_HP3_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP3_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP3_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       S_AXI_HP3_ARADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_HP3_AWADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       S_AXI_HP3_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP3_ARLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP3_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP3_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP3_AWLEN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP3_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       S_AXI_HP3_ARID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP3_AWID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP3_WID : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
       S_AXI_HP3_WDATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
       S_AXI_HP3_WSTRB : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
       IRQ_F2P : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
       Core0_nFIQ : IN STD_LOGIC;
       Core0_nIRQ : IN STD_LOGIC;
       Core1_nFIQ : IN STD_LOGIC;
       Core1_nIRQ : IN STD_LOGIC;
       FCLK_CLK0 : OUT STD_LOGIC;
       FCLK_CLK1 : OUT STD_LOGIC;
       FCLK_CLK2 : OUT STD_LOGIC;
       FCLK_CLK3 : OUT STD_LOGIC;
       FCLK_RESET0_N : OUT STD_LOGIC;
       FCLK_RESET1_N : OUT STD_LOGIC;
       FCLK_RESET2_N : OUT STD_LOGIC;
       FCLK_RESET3_N : OUT STD_LOGIC;
       MIO : INOUT STD_LOGIC_VECTOR(53 DOWNTO 0);
       DDR_CAS_n : INOUT STD_LOGIC;
       DDR_CKE : INOUT STD_LOGIC;
       DDR_Clk_n : INOUT STD_LOGIC;
       DDR_Clk : INOUT STD_LOGIC;
       DDR_CS_n : INOUT STD_LOGIC;
       DDR_DRSTB : INOUT STD_LOGIC;
       DDR_ODT : INOUT STD_LOGIC;
       DDR_RAS_n : INOUT STD_LOGIC;
       DDR_WEB : INOUT STD_LOGIC;
       DDR_BankAddr : INOUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       DDR_Addr : INOUT STD_LOGIC_VECTOR(14 DOWNTO 0);
       DDR_VRN : INOUT STD_LOGIC;
       DDR_VRP : INOUT STD_LOGIC;
       DDR_DM : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       DDR_DQ : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       DDR_DQS_n : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       DDR_DQS : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       PS_SRSTB : INOUT STD_LOGIC;
       PS_CLK : INOUT STD_LOGIC;
       PS_PORB : INOUT STD_LOGIC
     );
   END COMPONENT;

   -- Local signals
   signal fclkRst3N : sl;
   signal fclkRst2N : sl;
   signal fclkRst1N : sl;
   signal fclkRst0N : sl;
   
   attribute KEEP_HIERARCHY : string;
   attribute KEEP_HIERARCHY of
      U_PS7 : label is "TRUE";    

begin

   -- Reset outputs
   fclkRst3 <= not fclkRst3N;
   fclkRst2 <= not fclkRst2N;
   fclkRst1 <= not fclkRst1N;
   fclkRst0 <= not fclkRst0N;

   -----------------------------------------------------------------------------------
   -- Processor system module
   -----------------------------------------------------------------------------------
   U_PS7: processing_system7_0
      port map (
     
         -- FMIO ENET0
         ENET0_GMII_TX_EN(0)              => armEthTx(0).enetGmiiTxEn,
         ENET0_GMII_TX_ER(0)              => armEthTx(0).enetGmiiTxEr,
         ENET0_MDIO_MDC                   => armEthTx(0).enetMdioMdc,
         ENET0_MDIO_O                     => armEthTx(0).enetMdioO,
         ENET0_MDIO_T                     => armEthTx(0).enetMdioT,
         ENET0_PTP_DELAY_REQ_RX           => armEthTx(0).enetPtpDelayReqRx,
         ENET0_PTP_DELAY_REQ_TX           => armEthTx(0).enetPtpDelayReqTx,
         ENET0_PTP_PDELAY_REQ_RX          => armEthTx(0).enetPtpPDelayReqRx,
         ENET0_PTP_PDELAY_REQ_TX          => armEthTx(0).enetPtpPDelayReqTx,
         ENET0_PTP_PDELAY_RESP_RX         => armEthTx(0).enetPtpPDelayRespRx,
         ENET0_PTP_PDELAY_RESP_TX         => armEthTx(0).enetPtpPDelayRespTx,
         ENET0_PTP_SYNC_FRAME_RX          => armEthTx(0).enetPtpSyncFrameRx,
         ENET0_PTP_SYNC_FRAME_TX          => armEthTx(0).enetPtpSyncFrameTx,
         ENET0_SOF_RX                     => armEthTx(0).enetSofRx,
         ENET0_SOF_TX                     => armEthTx(0).enetSofTx,
         ENET0_GMII_TXD                   => armEthTx(0).enetGmiiTxD,
         ENET0_GMII_COL                   => armEthRx(0).enetGmiiCol,
         ENET0_GMII_CRS                   => armEthRx(0).enetGmiiCrs,
         ENET0_GMII_RX_CLK                => armEthRx(0).enetGmiiRxClk,
         ENET0_GMII_RX_DV                 => armEthRx(0).enetGmiiRxDv,
         ENET0_GMII_RX_ER                 => armEthRx(0).enetGmiiRxEr,
         ENET0_GMII_TX_CLK                => armEthRx(0).enetGmiiTxClk,
         ENET0_MDIO_I                     => armEthRx(0).enetMdioI,
         ENET0_EXT_INTIN                  => armEthRx(0).enetExtInitN,
         ENET0_GMII_RXD                   => armEthRx(0).enetGmiiRxd,

         -- FMI1 ENET1
         ENET1_GMII_TX_EN(0)              => armEthTx(1).enetGmiiTxEn,
         ENET1_GMII_TX_ER(0)              => armEthTx(1).enetGmiiTxEr,
         ENET1_MDIO_MDC                   => armEthTx(1).enetMdioMdc,
         ENET1_MDIO_O                     => armEthTx(1).enetMdioO,
         ENET1_MDIO_T                     => armEthTx(1).enetMdioT,
         --ENET1_PTP_DELAY_REQ_RX           => armEthTx(1).enetPtpDelayReqRx,
         --ENET1_PTP_DELAY_REQ_TX           => armEthTx(1).enetPtpDelayReqTx,
         --ENET1_PTP_PDELAY_REQ_RX          => armEthTx(1).enetPtpPDelayReqRx,
         --ENET1_PTP_PDELAY_REQ_TX          => armEthTx(1).enetPtpPDelayReqTx,
         --ENET1_PTP_PDELAY_RESP_RX         => armEthTx(1).enetPtpPDelayRespRx,
         --ENET1_PTP_PDELAY_RESP_TX         => armEthTx(1).enetPtpPDelayRespTx,
         --ENET1_PTP_SYNC_FRAME_RX          => armEthTx(1).enetPtpSyncFrameRx,
         --ENET1_PTP_SYNC_FRAME_TX          => armEthTx(1).enetPtpSyncFrameTx,
         --ENET1_SOF_RX                     => armEthTx(1).enetSofRx,
         --ENET1_SOF_TX                     => armEthTx(1).enetSofTx,
         ENET1_GMII_TXD                   => armEthTx(1).enetGmiiTxD,
         ENET1_GMII_COL                   => armEthRx(1).enetGmiiCol,
         ENET1_GMII_CRS                   => armEthRx(1).enetGmiiCrs,
         ENET1_GMII_RX_CLK                => armEthRx(1).enetGmiiRxClk,
         ENET1_GMII_RX_DV                 => armEthRx(1).enetGmiiRxDv,
         ENET1_GMII_RX_ER                 => armEthRx(1).enetGmiiRxEr,
         ENET1_GMII_TX_CLK                => armEthRx(1).enetGmiiTxClk,
         ENET1_MDIO_I                     => armEthRx(1).enetMdioI,
         ENET1_EXT_INTIN                  => armEthRx(1).enetExtInitN,
         ENET1_GMII_RXD                   => armEthRx(1).enetGmiiRxd,

         -- FMIO GPIO
         GPIO_I                           => x"0000000000000000",
         GPIO_O                           => open,
         GPIO_T                           => open,
     
         -- FMIO TTC0
         TTC0_WAVE0_OUT                   => open,
         TTC0_WAVE1_OUT                   => open,
         TTC0_WAVE2_OUT                   => open,
         --TTC0_CLK0_IN                     => '0',
         --TTC0_CLK1_IN                     => '0',
         --TTC0_CLK2_IN                     => '0',

         -- WDT
         WDT_RST_OUT                      => open,

         -- USB 0
         USB0_PORT_INDCTL                 => open,
         USB0_VBUS_PWRSELECT              => open,
         USB0_VBUS_PWRFAULT               => '0',

         --M_AXI_GP0
         M_AXI_GP0_ARVALID                => mGpReadMaster(0).arvalid,
         M_AXI_GP0_AWVALID                => mGpWriteMaster(0).awvalid,
         M_AXI_GP0_BREADY                 => mGpWriteMaster(0).bready,
         M_AXI_GP0_RREADY                 => mGpReadMaster(0).rready,
         M_AXI_GP0_WLAST                  => mGpWriteMaster(0).wlast,
         M_AXI_GP0_WVALID                 => mGpWriteMaster(0).wvalid,
         M_AXI_GP0_ARID                   => mGpReadMaster(0).arid(11 downto 0),
         M_AXI_GP0_AWID                   => mGpWriteMaster(0).awid(11 downto 0),
         M_AXI_GP0_WID                    => mGpWriteMaster(0).wid(11 downto 0),
         M_AXI_GP0_ARBURST                => mGpReadMaster(0).arburst,
         M_AXI_GP0_ARLOCK                 => mGpReadMaster(0).arlock,
         M_AXI_GP0_ARSIZE                 => mGpReadMaster(0).arsize,
         M_AXI_GP0_AWBURST                => mGpWriteMaster(0).awburst,
         M_AXI_GP0_AWLOCK                 => mGpWriteMaster(0).awlock,
         M_AXI_GP0_AWSIZE                 => mGpWriteMaster(0).awsize,
         M_AXI_GP0_ARPROT                 => mGpReadMaster(0).arprot,
         M_AXI_GP0_AWPROT                 => mGpWriteMaster(0).awprot,
         M_AXI_GP0_ARADDR                 => mGpReadMaster(0).araddr(31 downto 0),
         M_AXI_GP0_AWADDR                 => mGpWriteMaster(0).awaddr(31 downto 0),
         M_AXI_GP0_WDATA                  => mGpWriteMaster(0).wdata(31 downto 0),
         M_AXI_GP0_ARCACHE                => mGpReadMaster(0).arcache,
         M_AXI_GP0_ARLEN                  => mGpReadMaster(0).arlen(3 downto 0),
         M_AXI_GP0_ARQOS                  => open,
         M_AXI_GP0_AWCACHE                => mGpWriteMaster(0).awcache,
         M_AXI_GP0_AWLEN                  => mGpWriteMaster(0).awlen(3 downto 0),
         M_AXI_GP0_AWQOS                  => open,
         M_AXI_GP0_WSTRB                  => mGpWriteMaster(0).wstrb(3 downto 0),
         M_AXI_GP0_ACLK                   => mGpAxiClk(0),
         M_AXI_GP0_ARREADY                => mGpReadSlave(0).arready,
         M_AXI_GP0_AWREADY                => mGpWriteSlave(0).awready,
         M_AXI_GP0_BVALID                 => mGpWriteSlave(0).bvalid,
         M_AXI_GP0_RLAST                  => mGpReadSlave(0).rlast,
         M_AXI_GP0_RVALID                 => mGpReadSlave(0).rvalid,
         M_AXI_GP0_WREADY                 => mGpWriteSlave(0).wready,
         M_AXI_GP0_BID                    => mGpWriteSlave(0).bid(11 downto 0),
         M_AXI_GP0_RID                    => mGpReadSlave(0).rid(11 downto 0),
         M_AXI_GP0_BRESP                  => mGpWriteSlave(0).bresp,
         M_AXI_GP0_RRESP                  => mGpReadSlave(0).rresp,
         M_AXI_GP0_RDATA                  => mGpReadSlave(0).rdata(31 downto 0),
 
         -- M_AXI_GP1
         M_AXI_GP1_ARVALID                => mGpReadMaster(1).arvalid,
         M_AXI_GP1_AWVALID                => mGpWriteMaster(1).awvalid,
         M_AXI_GP1_BREADY                 => mGpWriteMaster(1).bready,
         M_AXI_GP1_RREADY                 => mGpReadMaster(1).rready,
         M_AXI_GP1_WLAST                  => mGpWriteMaster(1).wlast,
         M_AXI_GP1_WVALID                 => mGpWriteMaster(1).wvalid,
         M_AXI_GP1_ARID                   => mGpReadMaster(1).arid(11 downto 0),
         M_AXI_GP1_AWID                   => mGpWriteMaster(1).awid(11 downto 0),
         M_AXI_GP1_WID                    => mGpWriteMaster(1).wid(11 downto 0),
         M_AXI_GP1_ARBURST                => mGpReadMaster(1).arburst,
         M_AXI_GP1_ARLOCK                 => mGpReadMaster(1).arlock,
         M_AXI_GP1_ARSIZE                 => mGpReadMaster(1).arsize,
         M_AXI_GP1_AWBURST                => mGpWriteMaster(1).awburst,
         M_AXI_GP1_AWLOCK                 => mGpWriteMaster(1).awlock,
         M_AXI_GP1_AWSIZE                 => mGpWriteMaster(1).awsize,
         M_AXI_GP1_ARPROT                 => mGpReadMaster(1).arprot,
         M_AXI_GP1_AWPROT                 => mGpWriteMaster(1).awprot,
         M_AXI_GP1_ARADDR                 => mGpReadMaster(1).araddr(31 downto 0),
         M_AXI_GP1_AWADDR                 => mGpWriteMaster(1).awaddr(31 downto 0),
         M_AXI_GP1_WDATA                  => mGpWriteMaster(1).wdata(31 downto 0),
         M_AXI_GP1_ARCACHE                => mGpReadMaster(1).arcache,
         M_AXI_GP1_ARLEN                  => mGpReadMaster(1).arlen(3 downto 0),
         M_AXI_GP1_ARQOS                  => open,
         M_AXI_GP1_AWCACHE                => mGpWriteMaster(1).awcache,
         M_AXI_GP1_AWLEN                  => mGpWriteMaster(1).awlen(3 downto 0),
         M_AXI_GP1_AWQOS                  => open,
         M_AXI_GP1_WSTRB                  => mGpWriteMaster(1).wstrb(3 downto 0),
         M_AXI_GP1_ACLK                   => mGpAxiClk(1),
         M_AXI_GP1_ARREADY                => mGpReadSlave(1).arready,
         M_AXI_GP1_AWREADY                => mGpWriteSlave(1).awready,
         M_AXI_GP1_BVALID                 => mGpWriteSlave(1).bvalid,
         M_AXI_GP1_RLAST                  => mGpReadSlave(1).rlast,
         M_AXI_GP1_RVALID                 => mGpReadSlave(1).rvalid,
         M_AXI_GP1_WREADY                 => mGpWriteSlave(1).wready,
         M_AXI_GP1_BID                    => mGpWriteSlave(1).bid(11 downto 0),
         M_AXI_GP1_RID                    => mGpReadSlave(1).rid(11 downto 0),
         M_AXI_GP1_BRESP                  => mGpWriteSlave(1).bresp,
         M_AXI_GP1_RRESP                  => mGpReadSlave(1).rresp,
         M_AXI_GP1_RDATA                  => mGpReadSlave(1).rdata(31 downto 0),

         -- S_AXI_GP0
         S_AXI_GP0_ARREADY                => sGpReadSlave(0).arready,
         S_AXI_GP0_AWREADY                => sGpWriteSlave(0).awready,
         S_AXI_GP0_BVALID                 => sGpWriteSlave(0).bvalid,
         S_AXI_GP0_RLAST                  => sGpReadSlave(0).rlast,
         S_AXI_GP0_RVALID                 => sGpReadSlave(0).rvalid,
         S_AXI_GP0_WREADY                 => sGpWriteSlave(0).wready,
         S_AXI_GP0_BID                    => sGpWriteSlave(0).bid(5 downto 0),
         S_AXI_GP0_RID                    => sGpReadSlave(0).rid(5 downto 0),
         S_AXI_GP0_BRESP                  => sGpWriteSlave(0).bresp,
         S_AXI_GP0_RRESP                  => sGpReadSlave(0).rresp,
         S_AXI_GP0_RDATA                  => sGpReadSlave(0).rdata(31 downto 0),
         S_AXI_GP0_ACLK                   => sGpAxiClk(0),
         S_AXI_GP0_ARVALID                => sGpReadMaster(0).arvalid,
         S_AXI_GP0_AWVALID                => sGpWriteMaster(0).awvalid,
         S_AXI_GP0_BREADY                 => sGpWriteMaster(0).bready,
         S_AXI_GP0_RREADY                 => sGpReadMaster(0).rready,
         S_AXI_GP0_WLAST                  => sGpWriteMaster(0).wlast,
         S_AXI_GP0_WVALID                 => sGpWriteMaster(0).wvalid,
         S_AXI_GP0_ARID                   => sGpReadMaster(0).arid(5 downto 0),
         S_AXI_GP0_AWID                   => sGpWriteMaster(0).awid(5 downto 0),
         S_AXI_GP0_WID                    => sGpWriteMaster(0).wid(5 downto 0),
         S_AXI_GP0_ARBURST                => sGpReadMaster(0).arburst,
         S_AXI_GP0_ARLOCK                 => sGpReadMaster(0).arlock,
         S_AXI_GP0_ARSIZE                 => sGpReadMaster(0).arsize,
         S_AXI_GP0_AWBURST                => sGpWriteMaster(0).awburst,
         S_AXI_GP0_AWLOCK                 => sGpWriteMaster(0).awlock,
         S_AXI_GP0_AWSIZE                 => sGpWriteMaster(0).awsize,
         S_AXI_GP0_ARPROT                 => sGpReadMaster(0).arprot,
         S_AXI_GP0_AWPROT                 => sGpWriteMaster(0).awprot,
         S_AXI_GP0_ARADDR                 => sGpReadMaster(0).araddr(31 downto 0),
         S_AXI_GP0_AWADDR                 => sGpWriteMaster(0).awaddr(31 downto 0),
         S_AXI_GP0_WDATA                  => sGpWriteMaster(0).wdata(31 downto 0),
         S_AXI_GP0_ARCACHE                => sGpReadMaster(0).arcache,
         S_AXI_GP0_ARLEN                  => sGpReadMaster(0).arlen(3 downto 0),
         S_AXI_GP0_ARQOS                  => "1111",-- Highest priority
         S_AXI_GP0_AWCACHE                => sGpWriteMaster(0).awcache,
         S_AXI_GP0_AWLEN                  => sGpWriteMaster(0).awlen(3 downto 0),
         S_AXI_GP0_AWQOS                  => "1111",-- Highest priority
         S_AXI_GP0_WSTRB                  => sGpWriteMaster(0).wstrb(3 downto 0),

         -- S_AXI_GP1
         S_AXI_GP1_ARREADY                => sGpReadSlave(1).arready,
         S_AXI_GP1_AWREADY                => sGpWriteSlave(1).awready,
         S_AXI_GP1_BVALID                 => sGpWriteSlave(1).bvalid,
         S_AXI_GP1_RLAST                  => sGpReadSlave(1).rlast,
         S_AXI_GP1_RVALID                 => sGpReadSlave(1).rvalid,
         S_AXI_GP1_WREADY                 => sGpWriteSlave(1).wready,
         S_AXI_GP1_BID                    => sGpWriteSlave(1).bid(5 downto 0),
         S_AXI_GP1_RID                    => sGpReadSlave(1).rid(5 downto 0),
         S_AXI_GP1_BRESP                  => sGpWriteSlave(1).bresp,
         S_AXI_GP1_RRESP                  => sGpReadSlave(1).rresp,
         S_AXI_GP1_RDATA                  => sGpReadSlave(1).rdata(31 downto 0),
         S_AXI_GP1_ACLK                   => sGpAxiClk(1),
         S_AXI_GP1_ARVALID                => sGpReadMaster(1).arvalid,
         S_AXI_GP1_AWVALID                => sGpWriteMaster(1).awvalid,
         S_AXI_GP1_BREADY                 => sGpWriteMaster(1).bready,
         S_AXI_GP1_RREADY                 => sGpReadMaster(1).rready,
         S_AXI_GP1_WLAST                  => sGpWriteMaster(1).wlast,
         S_AXI_GP1_WVALID                 => sGpWriteMaster(1).wvalid,
         S_AXI_GP1_ARID                   => sGpReadMaster(1).arid(5 downto 0),
         S_AXI_GP1_AWID                   => sGpWriteMaster(1).awid(5 downto 0),
         S_AXI_GP1_WID                    => sGpWriteMaster(1).wid(5 downto 0),
         S_AXI_GP1_ARBURST                => sGpReadMaster(1).arburst,
         S_AXI_GP1_ARLOCK                 => sGpReadMaster(1).arlock,
         S_AXI_GP1_ARSIZE                 => sGpReadMaster(1).arsize,
         S_AXI_GP1_AWBURST                => sGpWriteMaster(1).awburst,
         S_AXI_GP1_AWLOCK                 => sGpWriteMaster(1).awlock,
         S_AXI_GP1_AWSIZE                 => sGpWriteMaster(1).awsize,
         S_AXI_GP1_ARPROT                 => sGpReadMaster(1).arprot,
         S_AXI_GP1_AWPROT                 => sGpWriteMaster(1).awprot,
         S_AXI_GP1_ARADDR                 => sGpReadMaster(1).araddr(31 downto 0),
         S_AXI_GP1_AWADDR                 => sGpWriteMaster(1).awaddr(31 downto 0),
         S_AXI_GP1_WDATA                  => sGpWriteMaster(1).wdata(31 downto 0),
         S_AXI_GP1_ARCACHE                => sGpReadMaster(1).arcache,
         S_AXI_GP1_ARLEN                  => sGpReadMaster(1).arlen(3 downto 0),
         S_AXI_GP1_ARQOS                  => "0000",
         S_AXI_GP1_AWCACHE                => sGpWriteMaster(1).awcache,
         S_AXI_GP1_AWLEN                  => sGpWriteMaster(1).awlen(3 downto 0),
         S_AXI_GP1_AWQOS                  => "0000",
         S_AXI_GP1_WSTRB                  => sGpWriteMaster(1).wstrb(3 downto 0),

         -- S_AXI_ACP
         S_AXI_ACP_ARREADY                => acpReadSlave.arready,
         S_AXI_ACP_AWREADY                => acpWriteSlave.awready,
         S_AXI_ACP_BVALID                 => acpWriteSlave.bvalid,
         S_AXI_ACP_RLAST                  => acpReadSlave.rlast,
         S_AXI_ACP_RVALID                 => acpReadSlave.rvalid,
         S_AXI_ACP_WREADY                 => acpWriteSlave.wready,
         S_AXI_ACP_BID                    => acpWriteSlave.bid(2 downto 0),
         S_AXI_ACP_RID                    => acpReadSlave.rid(2 downto 0),
         S_AXI_ACP_BRESP                  => acpWriteSlave.bresp,
         S_AXI_ACP_RRESP                  => acpReadSlave.rresp,
         S_AXI_ACP_RDATA                  => acpReadSlave.rdata(63 downto 0),
         S_AXI_ACP_ACLK                   => acpAxiClk,
         S_AXI_ACP_ARVALID                => acpReadMaster.arvalid,
         S_AXI_ACP_AWVALID                => acpWriteMaster.awvalid,
         S_AXI_ACP_BREADY                 => acpWriteMaster.bready,
         S_AXI_ACP_RREADY                 => acpReadMaster.rready,
         S_AXI_ACP_WLAST                  => acpWriteMaster.wlast,
         S_AXI_ACP_WVALID                 => acpWriteMaster.wvalid,
         S_AXI_ACP_ARID                   => acpReadMaster.arid(2 downto 0),
         S_AXI_ACP_AWID                   => acpWriteMaster.awid(2 downto 0),
         S_AXI_ACP_WID                    => acpWriteMaster.wid(2 downto 0),
         S_AXI_ACP_ARBURST                => acpReadMaster.arburst,
         S_AXI_ACP_ARLOCK                 => acpReadMaster.arlock,
         S_AXI_ACP_ARSIZE                 => acpReadMaster.arsize,
         S_AXI_ACP_AWBURST                => acpWriteMaster.awburst,
         S_AXI_ACP_AWLOCK                 => acpWriteMaster.awlock,
         S_AXI_ACP_AWSIZE                 => acpWriteMaster.awsize,
         S_AXI_ACP_ARPROT                 => acpReadMaster.arprot,
         S_AXI_ACP_AWPROT                 => acpWriteMaster.awprot,
         S_AXI_ACP_ARADDR                 => acpReadMaster.araddr(31 downto 0),
         S_AXI_ACP_AWADDR                 => acpWriteMaster.awaddr(31 downto 0),
         S_AXI_ACP_WDATA                  => acpWriteMaster.wdata(63 downto 0),
         S_AXI_ACP_ARCACHE                => acpReadMaster.arcache,
         S_AXI_ACP_ARLEN                  => acpReadMaster.arlen(3 downto 0),
         S_AXI_ACP_ARQOS                  => "0000",
         S_AXI_ACP_AWCACHE                => acpWriteMaster.awcache,
         S_AXI_ACP_AWLEN                  => acpWriteMaster.awlen(3 downto 0),
         S_AXI_ACP_AWQOS                  => "0000",
         S_AXI_ACP_WSTRB                  => acpWriteMaster.wstrb(7 downto 0),
         S_AXI_ACP_ARUSER                 => "00011",
         S_AXI_ACP_AWUSER                 => "00011",

         -- S_AXI_HP_0
         S_AXI_HP0_ARREADY                => hpReadSlave(0).arready,
         S_AXI_HP0_AWREADY                => hpWriteSlave(0).awready,
         S_AXI_HP0_BVALID                 => hpWriteSlave(0).bvalid,
         S_AXI_HP0_RLAST                  => hpReadSlave(0).rlast,
         S_AXI_HP0_RVALID                 => hpReadSlave(0).rvalid,
         S_AXI_HP0_WREADY                 => hpWriteSlave(0).wready,
         S_AXI_HP0_BID                    => hpWriteSlave(0).bid(5 downto 0),
         S_AXI_HP0_RID                    => hpReadSlave(0).rid(5 downto 0),
         S_AXI_HP0_BRESP                  => hpWriteSlave(0).bresp,
         S_AXI_HP0_RRESP                  => hpReadSlave(0).rresp,
         S_AXI_HP0_RDATA                  => hpReadSlave(0).rdata(63 downto 0),
         S_AXI_HP0_RCOUNT                 => open,
         S_AXI_HP0_WCOUNT                 => open,
         S_AXI_HP0_RACOUNT                => open,
         S_AXI_HP0_WACOUNT                => open,
         S_AXI_HP0_ACLK                   => hpAxiClk(0),
         S_AXI_HP0_ARVALID                => hpReadMaster(0).arvalid,
         S_AXI_HP0_AWVALID                => hpWriteMaster(0).awvalid,
         S_AXI_HP0_BREADY                 => hpWriteMaster(0).bready,
         S_AXI_HP0_RREADY                 => hpReadMaster(0).rready,
         S_AXI_HP0_WLAST                  => hpWriteMaster(0).wlast,
         S_AXI_HP0_WVALID                 => hpWriteMaster(0).wvalid,
         S_AXI_HP0_RDISSUECAP1_EN         => '0',
         S_AXI_HP0_WRISSUECAP1_EN         => '0',
         S_AXI_HP0_ARID                   => hpReadMaster(0).arid(5 downto 0),
         S_AXI_HP0_AWID                   => hpWriteMaster(0).awid(5 downto 0),
         S_AXI_HP0_WID                    => hpWriteMaster(0).wid(5 downto 0),
         S_AXI_HP0_ARBURST                => hpReadMaster(0).arburst,
         S_AXI_HP0_ARLOCK                 => hpReadMaster(0).arlock,
         S_AXI_HP0_ARSIZE                 => hpReadMaster(0).arsize,
         S_AXI_HP0_AWBURST                => hpWriteMaster(0).awburst,
         S_AXI_HP0_AWLOCK                 => hpWriteMaster(0).awlock,
         S_AXI_HP0_AWSIZE                 => hpWriteMaster(0).awsize,
         S_AXI_HP0_ARPROT                 => hpReadMaster(0).arprot,
         S_AXI_HP0_AWPROT                 => hpWriteMaster(0).awprot,
         S_AXI_HP0_ARADDR                 => hpReadMaster(0).araddr(31 downto 0),
         S_AXI_HP0_AWADDR                 => hpWriteMaster(0).awaddr(31 downto 0),
         S_AXI_HP0_WDATA                  => hpWriteMaster(0).wdata(63 downto 0),
         S_AXI_HP0_ARCACHE                => hpReadMaster(0).arcache,
         S_AXI_HP0_ARLEN                  => hpReadMaster(0).arlen(3 downto 0),
         S_AXI_HP0_ARQOS                  => "0000",
         S_AXI_HP0_AWCACHE                => hpWriteMaster(0).awcache,
         S_AXI_HP0_AWLEN                  => hpWriteMaster(0).awlen(3 downto 0),
         S_AXI_HP0_AWQOS                  => "0000",
         S_AXI_HP0_WSTRB                  => hpWriteMaster(0).wstrb(7 downto 0),

         -- S_AXI_HP_1
         S_AXI_HP1_ARREADY                => hpReadSlave(1).arready,
         S_AXI_HP1_AWREADY                => hpWriteSlave(1).awready,
         S_AXI_HP1_BVALID                 => hpWriteSlave(1).bvalid,
         S_AXI_HP1_RLAST                  => hpReadSlave(1).rlast,
         S_AXI_HP1_RVALID                 => hpReadSlave(1).rvalid,
         S_AXI_HP1_WREADY                 => hpWriteSlave(1).wready,
         S_AXI_HP1_BID                    => hpWriteSlave(1).bid(5 downto 0),
         S_AXI_HP1_RID                    => hpReadSlave(1).rid(5 downto 0),
         S_AXI_HP1_BRESP                  => hpWriteSlave(1).bresp,
         S_AXI_HP1_RRESP                  => hpReadSlave(1).rresp,
         S_AXI_HP1_RDATA                  => hpReadSlave(1).rdata(63 downto 0),
         S_AXI_HP1_RCOUNT                 => open,
         S_AXI_HP1_WCOUNT                 => open,
         S_AXI_HP1_RACOUNT                => open,
         S_AXI_HP1_WACOUNT                => open,
         S_AXI_HP1_ACLK                   => hpAxiClk(1),
         S_AXI_HP1_ARVALID                => hpReadMaster(1).arvalid,
         S_AXI_HP1_AWVALID                => hpWriteMaster(1).awvalid,
         S_AXI_HP1_BREADY                 => hpWriteMaster(1).bready,
         S_AXI_HP1_RREADY                 => hpReadMaster(1).rready,
         S_AXI_HP1_WLAST                  => hpWriteMaster(1).wlast,
         S_AXI_HP1_WVALID                 => hpWriteMaster(1).wvalid,
         S_AXI_HP1_RDISSUECAP1_EN         => '0',
         S_AXI_HP1_WRISSUECAP1_EN         => '0',
         S_AXI_HP1_ARID                   => hpReadMaster(1).arid(5 downto 0),
         S_AXI_HP1_AWID                   => hpWriteMaster(1).awid(5 downto 0),
         S_AXI_HP1_WID                    => hpWriteMaster(1).wid(5 downto 0),
         S_AXI_HP1_ARBURST                => hpReadMaster(1).arburst,
         S_AXI_HP1_ARLOCK                 => hpReadMaster(1).arlock,
         S_AXI_HP1_ARSIZE                 => hpReadMaster(1).arsize,
         S_AXI_HP1_AWBURST                => hpWriteMaster(1).awburst,
         S_AXI_HP1_AWLOCK                 => hpWriteMaster(1).awlock,
         S_AXI_HP1_AWSIZE                 => hpWriteMaster(1).awsize,
         S_AXI_HP1_ARPROT                 => hpReadMaster(1).arprot,
         S_AXI_HP1_AWPROT                 => hpWriteMaster(1).awprot,
         S_AXI_HP1_ARADDR                 => hpReadMaster(1).araddr(31 downto 0),
         S_AXI_HP1_AWADDR                 => hpWriteMaster(1).awaddr(31 downto 0),
         S_AXI_HP1_WDATA                  => hpWriteMaster(1).wdata(63 downto 0),
         S_AXI_HP1_ARCACHE                => hpReadMaster(1).arcache,
         S_AXI_HP1_ARLEN                  => hpReadMaster(1).arlen(3 downto 0),
         S_AXI_HP1_ARQOS                  => "0000",
         S_AXI_HP1_AWCACHE                => hpWriteMaster(1).awcache,
         S_AXI_HP1_AWLEN                  => hpWriteMaster(1).awlen(3 downto 0),
         S_AXI_HP1_AWQOS                  => "0000",
         S_AXI_HP1_WSTRB                  => hpWriteMaster(1).wstrb(7 downto 0),

         -- S_AXI_HP_2
         S_AXI_HP2_ARREADY                => hpReadSlave(2).arready,
         S_AXI_HP2_AWREADY                => hpWriteSlave(2).awready,
         S_AXI_HP2_BVALID                 => hpWriteSlave(2).bvalid,
         S_AXI_HP2_RLAST                  => hpReadSlave(2).rlast,
         S_AXI_HP2_RVALID                 => hpReadSlave(2).rvalid,
         S_AXI_HP2_WREADY                 => hpWriteSlave(2).wready,
         S_AXI_HP2_BID                    => hpWriteSlave(2).bid(5 downto 0),
         S_AXI_HP2_RID                    => hpReadSlave(2).rid(5 downto 0),
         S_AXI_HP2_BRESP                  => hpWriteSlave(2).bresp,
         S_AXI_HP2_RRESP                  => hpReadSlave(2).rresp,
         S_AXI_HP2_RDATA                  => hpReadSlave(2).rdata(63 downto 0),
         S_AXI_HP2_RCOUNT                 => open,
         S_AXI_HP2_WCOUNT                 => open,
         S_AXI_HP2_RACOUNT                => open,
         S_AXI_HP2_WACOUNT                => open,
         S_AXI_HP2_ACLK                   => hpAxiClk(2),
         S_AXI_HP2_ARVALID                => hpReadMaster(2).arvalid,
         S_AXI_HP2_AWVALID                => hpWriteMaster(2).awvalid,
         S_AXI_HP2_BREADY                 => hpWriteMaster(2).bready,
         S_AXI_HP2_RREADY                 => hpReadMaster(2).rready,
         S_AXI_HP2_WLAST                  => hpWriteMaster(2).wlast,
         S_AXI_HP2_WVALID                 => hpWriteMaster(2).wvalid,
         S_AXI_HP2_RDISSUECAP1_EN         => '0',
         S_AXI_HP2_WRISSUECAP1_EN         => '0',
         S_AXI_HP2_ARID                   => hpReadMaster(2).arid(5 downto 0),
         S_AXI_HP2_AWID                   => hpWriteMaster(2).awid(5 downto 0),
         S_AXI_HP2_WID                    => hpWriteMaster(2).wid(5 downto 0),
         S_AXI_HP2_ARBURST                => hpReadMaster(2).arburst,
         S_AXI_HP2_ARLOCK                 => hpReadMaster(2).arlock,
         S_AXI_HP2_ARSIZE                 => hpReadMaster(2).arsize,
         S_AXI_HP2_AWBURST                => hpWriteMaster(2).awburst,
         S_AXI_HP2_AWLOCK                 => hpWriteMaster(2).awlock,
         S_AXI_HP2_AWSIZE                 => hpWriteMaster(2).awsize,
         S_AXI_HP2_ARPROT                 => hpReadMaster(2).arprot,
         S_AXI_HP2_AWPROT                 => hpWriteMaster(2).awprot,
         S_AXI_HP2_ARADDR                 => hpReadMaster(2).araddr(31 downto 0),
         S_AXI_HP2_AWADDR                 => hpWriteMaster(2).awaddr(31 downto 0),
         S_AXI_HP2_WDATA                  => hpWriteMaster(2).wdata(63 downto 0),
         S_AXI_HP2_ARCACHE                => hpReadMaster(2).arcache,
         S_AXI_HP2_ARLEN                  => hpReadMaster(2).arlen(3 downto 0),
         S_AXI_HP2_ARQOS                  => "0000",
         S_AXI_HP2_AWCACHE                => hpWriteMaster(2).awcache,
         S_AXI_HP2_AWLEN                  => hpWriteMaster(2).awlen(3 downto 0),
         S_AXI_HP2_AWQOS                  => "0000",
         S_AXI_HP2_WSTRB                  => hpWriteMaster(2).wstrb(7 downto 0),

         -- S_AXI_HP_3
         S_AXI_HP3_ARREADY                => hpReadSlave(3).arready,
         S_AXI_HP3_AWREADY                => hpWriteSlave(3).awready,
         S_AXI_HP3_BVALID                 => hpWriteSlave(3).bvalid,
         S_AXI_HP3_RLAST                  => hpReadSlave(3).rlast,
         S_AXI_HP3_RVALID                 => hpReadSlave(3).rvalid,
         S_AXI_HP3_WREADY                 => hpWriteSlave(3).wready,
         S_AXI_HP3_BID                    => hpWriteSlave(3).bid(5 downto 0),
         S_AXI_HP3_RID                    => hpReadSlave(3).rid(5 downto 0),
         S_AXI_HP3_BRESP                  => hpWriteSlave(3).bresp,
         S_AXI_HP3_RRESP                  => hpReadSlave(3).rresp,
         S_AXI_HP3_RDATA                  => hpReadSlave(3).rdata(63 downto 0),
         S_AXI_HP3_RCOUNT                 => open,
         S_AXI_HP3_WCOUNT                 => open,
         S_AXI_HP3_RACOUNT                => open,
         S_AXI_HP3_WACOUNT                => open,
         S_AXI_HP3_ACLK                   => hpAxiClk(3),
         S_AXI_HP3_ARVALID                => hpReadMaster(3).arvalid,
         S_AXI_HP3_AWVALID                => hpWriteMaster(3).awvalid,
         S_AXI_HP3_BREADY                 => hpWriteMaster(3).bready,
         S_AXI_HP3_RREADY                 => hpReadMaster(3).rready,
         S_AXI_HP3_WLAST                  => hpWriteMaster(3).wlast,
         S_AXI_HP3_WVALID                 => hpWriteMaster(3).wvalid,
         S_AXI_HP3_RDISSUECAP1_EN         => '0',
         S_AXI_HP3_WRISSUECAP1_EN         => '0',
         S_AXI_HP3_ARID                   => hpReadMaster(3).arid(5 downto 0),
         S_AXI_HP3_AWID                   => hpWriteMaster(3).awid(5 downto 0),
         S_AXI_HP3_WID                    => hpWriteMaster(3).wid(5 downto 0),
         S_AXI_HP3_ARBURST                => hpReadMaster(3).arburst,
         S_AXI_HP3_ARLOCK                 => hpReadMaster(3).arlock,
         S_AXI_HP3_ARSIZE                 => hpReadMaster(3).arsize,
         S_AXI_HP3_AWBURST                => hpWriteMaster(3).awburst,
         S_AXI_HP3_AWLOCK                 => hpWriteMaster(3).awlock,
         S_AXI_HP3_AWSIZE                 => hpWriteMaster(3).awsize,
         S_AXI_HP3_ARPROT                 => hpReadMaster(3).arprot,
         S_AXI_HP3_AWPROT                 => hpWriteMaster(3).awprot,
         S_AXI_HP3_ARADDR                 => hpReadMaster(3).araddr(31 downto 0),
         S_AXI_HP3_AWADDR                 => hpWriteMaster(3).awaddr(31 downto 0),
         S_AXI_HP3_WDATA                  => hpWriteMaster(3).wdata(63 downto 0),
         S_AXI_HP3_ARCACHE                => hpReadMaster(3).arcache,
         S_AXI_HP3_ARLEN                  => hpReadMaster(3).arlen(3 downto 0),
         S_AXI_HP3_ARQOS                  => "0000",
         S_AXI_HP3_AWCACHE                => hpWriteMaster(3).awcache,
         S_AXI_HP3_AWLEN                  => hpWriteMaster(3).awlen(3 downto 0),
         S_AXI_HP3_AWQOS                  => "0000",
         S_AXI_HP3_WSTRB                  => hpWriteMaster(3).wstrb(7 downto 0),

         -- IRQ
         IRQ_F2P                          => armInterrupt,
         Core0_nFIQ                       => '0',
         Core0_nIRQ                       => '0',
         Core1_nFIQ                       => '0',
         Core1_nIRQ                       => '0',

         -- FCLK
         FCLK_CLK3                        => fclkClk3,
         FCLK_CLK2                        => fclkClk2,
         FCLK_CLK1                        => fclkClk1,
         FCLK_CLK0                        => fclkClk0,
         FCLK_RESET3_N                    => fclkRst3N,
         FCLK_RESET2_N                    => fclkRst2N,
         FCLK_RESET1_N                    => fclkRst1N,
         FCLK_RESET0_N                    => fclkRst0N,

         -- MIO
         MIO                              => open,

         -- DDR
         DDR_CAS_n                        => open,
         DDR_CKE                          => open,
         DDR_Clk_n                        => open,
         DDR_Clk                          => open,
         DDR_CS_n                         => open,
         DDR_DRSTB                        => open,
         DDR_ODT                          => open,
         DDR_RAS_n                        => open,
         DDR_WEB                          => open,
         DDR_BankAddr                     => open,
         DDR_Addr                         => open,
         DDR_VRN                          => open,
         DDR_VRP                          => open,
         DDR_DM                           => open,
         DDR_DQ                           => open,
         DDR_DQS_n                        => open,
         DDR_DQS                          => open,

         -- Clock and reset
         PS_SRSTB                         => open,
         PS_CLK                           => open,
         PS_PORB                          => open
      );

   -- Some ports have changed in Vivado 2015.3
   armEthTx(1).enetPtpDelayReqRx    <= '0';
   armEthTx(1).enetPtpDelayReqTx    <= '0';
   armEthTx(1).enetPtpPDelayReqRx   <= '0';
   armEthTx(1).enetPtpPDelayReqTx   <= '0';
   armEthTx(1).enetPtpPDelayRespRx  <= '0';
   armEthTx(1).enetPtpPDelayRespTx  <= '0';
   armEthTx(1).enetPtpSyncFrameRx   <= '0';
   armEthTx(1).enetPtpSyncFrameTx   <= '0';
   armEthTx(1).enetSofRx            <= '0';
   armEthTx(1).enetSofTx            <= '0';

   -- Unused AXI Master GP Signals
   U_UnusedMasterGP: for i in 0 to 1 generate
      mGpWriteMaster(i).wdata(63 downto 32) <= (others=>'0');
      mGpWriteMaster(i).wstrb(7 downto 4)   <= "0000";
   end generate;

   -- Unused AXI Slave GP Signals
   U_UnusedSlaveGP: for i in 0 to 1 generate
      sGpReadSlave(i).rdata(63 downto 32) <= (others=>'0');
      sGpWriteSlave(i).bid(11 downto 6)   <= (others=>'0');
      sGpReadSlave(i).rid(11 downto 6)    <= (others=>'0');
   end generate;

   -- Unused AXI ACP Signals
   acpWriteSlave.bid(11 downto 3) <= (others=>'0');
   acpReadSlave.rid(11 downto 3)  <= (others=>'0');

   -- Unused AXI Slave HP Signals
   U_UnusedSlaveHP: for i in 0 to 3 generate
      hpWriteSlave(i).bid(11 downto 6) <= (others=>'0');
      hpReadSlave(i).rid(11 downto 6)  <= (others=>'0');
   end generate;

end architecture Hw;

