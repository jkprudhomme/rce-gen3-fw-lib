-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, CPU Wrapper
-- File          : ArmRceG3Cpu.vhd
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;
use work.processing_system7_pkg.all;

entity ArmRceG3Cpu is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clocks
      fclkClk3                 : out    sl;
      fclkClk2                 : out    sl;
      fclkClk1                 : out    sl;
      fclkClk0                 : out    sl;
      fclkRst3                 : out    sl;
      fclkRst2                 : out    sl;
      fclkRst1                 : out    sl;
      fclkRst0                 : out    sl;

      -- Common AXI Clock
      axiClk                   : in     sl;

      -- Interrupts
      armInt                   : in     slv(15 downto 0);

      -- AXI GP Master
      axiGpMasterReset         : out    slv(1 downto 0);
      axiGpMasterWriteFromArm  : out    AxiWriteMasterVector(1 downto 0);
      axiGpMasterWriteToArm    : in     AxiWriteSlaveVector(1 downto 0);
      axiGpMasterReadFromArm   : out    AxiReadMasterVector(1 downto 0);
      axiGpMasterReadToArm     : in     AxiReadSlaveVector(1 downto 0);

      -- AXI GP Slave
      axiGpSlaveReset          : out    slv(1 downto 0);
      axiGpSlaveWriteFromArm   : out    AxiWriteSlaveVector(1 downto 0);
      axiGpSlaveWriteToArm     : in     AxiWriteMasterVector(1 downto 0);
      axiGpSlaveReadFromArm    : out    AxiReadSlaveVector(1 downto 0);
      axiGpSlaveReadToArm      : in     AxiReadMasterVector(1 downto 0);

      -- AXI ACP Slave
      axiAcpSlaveReset         : out    sl;
      axiAcpSlaveWriteFromArm  : out    AxiWriteSlaveType;
      axiAcpSlaveWriteToArm    : in     AxiWriteMasterType;
      axiAcpSlaveReadFromArm   : out    AxiReadSlaveType;
      axiAcpSlaveReadToArm     : in     AxiReadMasterType;

      -- AXI HP Slave
      axiHpSlaveReset          : out    slv(3 downto 0);
      axiHpSlaveWriteFromArm   : out    AxiWriteSlaveVector(3 downto 0);
      axiHpSlaveWriteToArm     : in     AxiWriteMasterVector(3 downto 0);
      axiHpSlaveReadFromArm    : out    AxiReadSlaveVector(3 downto 0);
      axiHpSlaveReadToArm      : in     AxiReadMasterVector(3 downto 0);

      -- Ethernet
      ethFromArm               : out    EthFromArmVector(1 downto 0);
      ethToArm                 : in     EthToArmVector(1 downto 0);

      -- External Inputs
      psSrstB                  : in     sl;
      psClk                    : in     sl;
      psPorB                   : in     sl

   );
end ArmRceG3Cpu;

architecture structure of ArmRceG3Cpu is

   -- Local signals
   signal axiGpMasterResetN : slv(1 downto 0);
   signal axiGpSlaveResetN  : slv(1 downto 0);
   signal axiAcpSlaveResetN : sl;
   signal axiHpSlaveResetN  : slv(3 downto 0);
   signal fclkRst3N         : sl;
   signal fclkRst2N         : sl;
   signal fclkRst1N         : sl;
   signal fclkRst0N         : sl;
   signal ipsSrstB          : sl;
   signal ipsClk            : sl;
   signal ipsPorB           : sl;

begin


   axiGpMasterReset <= not axiGpMasterResetN;
   axiGpSlaveReset  <= not axiGpSlaveResetN;
   axiAcpSlaveReset <= not axiAcpSlaveResetN;
   axiHpSlaveReset  <= not axiHpSlaveResetN;
   fclkRst3         <= not fclkRst3N;
   fclkRst2         <= not fclkRst2N;
   fclkRst1         <= not fclkRst1N;
   fclkRst0         <= not fclkRst0N;

   U_PsSrstB: IBUF port map (I => psSrstB, O => ipsSrstB );
   U_PsClk:   IBUF port map (I => psClk,   O => ipsClk   );
   U_PsPorB:  IBUF port map (I => psPorB,  O => ipsPorB  );

   -----------------------------------------------------------------------------------
   -- Processor system module
   -----------------------------------------------------------------------------------
   U_PS7: processing_system7
      generic map (
         C_USE_DEFAULT_ACP_USER_VAL      =>  1,
         C_S_AXI_ACP_ARUSER_VAL          =>  31,
         C_S_AXI_ACP_AWUSER_VAL          =>  31,
         C_M_AXI_GP0_THREAD_ID_WIDTH     =>  12,
         C_M_AXI_GP1_THREAD_ID_WIDTH     =>  12, 
         C_M_AXI_GP0_ENABLE_STATIC_REMAP =>  1,
         C_M_AXI_GP1_ENABLE_STATIC_REMAP =>  1, 
         C_M_AXI_GP0_ID_WIDTH            =>  12,
         C_M_AXI_GP1_ID_WIDTH            =>  12,
         C_S_AXI_GP0_ID_WIDTH            =>  6,
         C_S_AXI_GP1_ID_WIDTH            =>  6,
         C_S_AXI_HP0_ID_WIDTH            =>  6,
         C_S_AXI_HP1_ID_WIDTH            =>  6,
         C_S_AXI_HP2_ID_WIDTH            =>  6,
         C_S_AXI_HP3_ID_WIDTH            =>  6,
         C_S_AXI_ACP_ID_WIDTH            =>  3,
         C_S_AXI_HP0_DATA_WIDTH          =>  64,
         C_S_AXI_HP1_DATA_WIDTH          =>  64,
         C_S_AXI_HP2_DATA_WIDTH          =>  64,
         C_S_AXI_HP3_DATA_WIDTH          =>  64,
         C_INCLUDE_ACP_TRANS_CHECK       =>  0,
         C_NUM_F2P_INTR_INPUTS           =>  16,
         C_FCLK_CLK0_BUF                 =>  "TRUE",
         C_FCLK_CLK1_BUF                 =>  "TRUE",
         C_FCLK_CLK2_BUF                 =>  "TRUE",
         C_FCLK_CLK3_BUF                 =>  "TRUE",
         C_EMIO_GPIO_WIDTH               =>  64,
         C_INCLUDE_TRACE_BUFFER          =>  0,
         C_TRACE_BUFFER_FIFO_SIZE        =>  128,
         C_TRACE_BUFFER_CLOCK_DELAY      =>  12,
         USE_TRACE_DATA_EDGE_DETECTOR    =>  0,
         C_PS7_SI_REV                    =>  "PRODUCTION",
         C_EN_EMIO_ENET0                 =>  1,
         C_EN_EMIO_ENET1                 =>  1,
         C_EN_EMIO_TRACE                 =>  0,
         C_DQ_WIDTH                      =>  32,
         C_DQS_WIDTH                     =>  4,
         C_DM_WIDTH                      =>  4,
         C_MIO_PRIMITIVE                 =>  54,
         C_PACKAGE_NAME                  =>  "clg484"
      ) 
      port map (
  
         -- FMIO CAN0
         CAN0_PHY_TX                      => open,
         CAN0_PHY_RX                      => '0',

         -- FMIO CAN1
         CAN1_PHY_TX                      => open,
         CAN1_PHY_RX                      => '0',
     
         -- FMIO ENET0
         ENET0_GMII_TX_EN                 => ethFromArm(0).enetGmiiTxEn,
         ENET0_GMII_TX_ER                 => ethFromArm(0).enetGmiiTxEr,
         ENET0_MDIO_MDC                   => ethFromArm(0).enetMdioMdc,
         ENET0_MDIO_O                     => ethFromArm(0).enetMdioO,
         ENET0_MDIO_T                     => ethFromArm(0).enetMdioT,
         ENET0_PTP_DELAY_REQ_RX           => ethFromArm(0).enetPtpDelayReqRx,
         ENET0_PTP_DELAY_REQ_TX           => ethFromArm(0).enetPtpDelayReqTx,
         ENET0_PTP_PDELAY_REQ_RX          => ethFromArm(0).enetPtpPDelayReqRx,
         ENET0_PTP_PDELAY_REQ_TX          => ethFromArm(0).enetPtpPDelayReqTx,
         ENET0_PTP_PDELAY_RESP_RX         => ethFromArm(0).enetPtpPDelayRespRx,
         ENET0_PTP_PDELAY_RESP_TX         => ethFromArm(0).enetPtpPDelayRespTx,
         ENET0_PTP_SYNC_FRAME_RX          => ethFromArm(0).enetPtpSyncFrameRx,
         ENET0_PTP_SYNC_FRAME_TX          => ethFromArm(0).enetPtpSyncFrameTx,
         ENET0_SOF_RX                     => ethFromArm(0).enetSofRx,
         ENET0_SOF_TX                     => ethFromArm(0).enetSofTx,
         ENET0_GMII_TXD                   => ethFromArm(0).enetGmiiTxD,
         ENET0_GMII_COL                   => ethToArm(0).enetGmiiCol,
         ENET0_GMII_CRS                   => ethToArm(0).enetGmiiCrs,
         ENET0_GMII_RX_CLK                => ethToArm(0).enetGmiiRxClk,
         ENET0_GMII_RX_DV                 => ethToArm(0).enetGmiiRxDv,
         ENET0_GMII_RX_ER                 => ethToArm(0).enetGmiiRxEr,
         ENET0_GMII_TX_CLK                => ethToArm(0).enetGmiiTxClk,
         ENET0_MDIO_I                     => ethToArm(0).enetMdioI,
         ENET0_EXT_INTIN                  => ethToArm(0).enetExtInitN,
         ENET0_GMII_RXD                   => ethToArm(0).enetGmiiRxd,

         -- FMI1 ENET1
         ENET1_GMII_TX_EN                 => ethFromArm(1).enetGmiiTxEn,
         ENET1_GMII_TX_ER                 => ethFromArm(1).enetGmiiTxEr,
         ENET1_MDIO_MDC                   => ethFromArm(1).enetMdioMdc,
         ENET1_MDIO_O                     => ethFromArm(1).enetMdioO,
         ENET1_MDIO_T                     => ethFromArm(1).enetMdioT,
         ENET1_PTP_DELAY_REQ_RX           => ethFromArm(1).enetPtpDelayReqRx,
         ENET1_PTP_DELAY_REQ_TX           => ethFromArm(1).enetPtpDelayReqTx,
         ENET1_PTP_PDELAY_REQ_RX          => ethFromArm(1).enetPtpPDelayReqRx,
         ENET1_PTP_PDELAY_REQ_TX          => ethFromArm(1).enetPtpPDelayReqTx,
         ENET1_PTP_PDELAY_RESP_RX         => ethFromArm(1).enetPtpPDelayRespRx,
         ENET1_PTP_PDELAY_RESP_TX         => ethFromArm(1).enetPtpPDelayRespTx,
         ENET1_PTP_SYNC_FRAME_RX          => ethFromArm(1).enetPtpSyncFrameRx,
         ENET1_PTP_SYNC_FRAME_TX          => ethFromArm(1).enetPtpSyncFrameTx,
         ENET1_SOF_RX                     => ethFromArm(1).enetSofRx,
         ENET1_SOF_TX                     => ethFromArm(1).enetSofTx,
         ENET1_GMII_TXD                   => ethFromArm(1).enetGmiiTxD,
         ENET1_GMII_COL                   => ethToArm(1).enetGmiiCol,
         ENET1_GMII_CRS                   => ethToArm(1).enetGmiiCrs,
         ENET1_GMII_RX_CLK                => ethToArm(1).enetGmiiRxClk,
         ENET1_GMII_RX_DV                 => ethToArm(1).enetGmiiRxDv,
         ENET1_GMII_RX_ER                 => ethToArm(1).enetGmiiRxEr,
         ENET1_GMII_TX_CLK                => ethToArm(1).enetGmiiTxClk,
         ENET1_MDIO_I                     => ethToArm(1).enetMdioI,
         ENET1_EXT_INTIN                  => ethToArm(1).enetExtInitN,
         ENET1_GMII_RXD                   => ethToArm(1).enetGmiiRxd,

         -- FMIO GPIO
         GPIO_I                           => x"0000000000000000",
         GPIO_O                           => open,
         GPIO_T                           => open,
     
         -- FMIO I2C0
         I2C0_SDA_I                       => '0',
         I2C0_SDA_O                       => open,
         I2C0_SDA_T                       => open,
         I2C0_SCL_I                       => '0',
         I2C0_SCL_O                       => open,
         I2C0_SCL_T                       => open,

         -- FMIO I2C1
         I2C1_SDA_I                       => '0',
         I2C1_SDA_O                       => open,
         I2C1_SDA_T                       => open,
         I2C1_SCL_I                       => '0',
         I2C1_SCL_O                       => open,
         I2C1_SCL_T                       => open,
     
         -- FMIO PJTAG
         PJTAG_TCK                        => '0',
         PJTAG_TMS                        => '0',
         PJTAG_TD_I                       => '0',
         PJTAG_TD_T                       => open,
         PJTAG_TD_O                       => open,
     
         -- FMIO SDIO0
         SDIO0_CLK                        => open,
         SDIO0_CLK_FB                     => '0',
         SDIO0_CMD_O                      => open,
         SDIO0_CMD_I                      => '0',
         SDIO0_CMD_T                      => open,
         SDIO0_DATA_I                     => "0000",
         SDIO0_DATA_O                     => open,
         SDIO0_DATA_T                     => open,
         SDIO0_LED                        => open,
         SDIO0_CDN                        => '0',
         SDIO0_WP                         => '0',
         SDIO0_BUSPOW                     => open,
         SDIO0_BUSVOLT                    => open,

         -- FMIO SDIO1
         SDIO1_CLK                        => open,
         SDIO1_CLK_FB                     => '0',
         SDIO1_CMD_O                      => open,
         SDIO1_CMD_I                      => '0',
         SDIO1_CMD_T                      => open,
         SDIO1_DATA_I                     => "0000",
         SDIO1_DATA_O                     => open,
         SDIO1_DATA_T                     => open,
         SDIO1_LED                        => open,
         SDIO1_CDN                        => '0',
         SDIO1_WP                         => '0',
         SDIO1_BUSPOW                     => open,
         SDIO1_BUSVOLT                    => open,

         -- FMIO SPI0
         SPI0_SCLK_I                      => '0',
         SPI0_SCLK_O                      => open,
         SPI0_SCLK_T                      => open,
         SPI0_MOSI_I                      => '0',
         SPI0_MOSI_O                      => open,
         SPI0_MOSI_T                      => open,
         SPI0_MISO_I                      => '0',
         SPI0_MISO_O                      => open,
         SPI0_MISO_T                      => open,
         SPI0_SS_I                        => '0',
         SPI0_SS_O                        => open,
         SPI0_SS1_O                       => open,
         SPI0_SS2_O                       => open,
         SPI0_SS_T                        => open,

         -- FMIO SPI1
         SPI1_SCLK_I                      => '0',
         SPI1_SCLK_O                      => open,
         SPI1_SCLK_T                      => open,
         SPI1_MOSI_I                      => '0',
         SPI1_MOSI_O                      => open,
         SPI1_MOSI_T                      => open,
         SPI1_MISO_I                      => '0',
         SPI1_MISO_O                      => open,
         SPI1_MISO_T                      => open,
         SPI1_SS_I                        => '0',
         SPI1_SS_O                        => open,
         SPI1_SS1_O                       => open,
         SPI1_SS2_O                       => open,
         SPI1_SS_T                        => open,

         -- FMIO UART0
         UART0_DTRN                       => open,
         UART0_RTSN                       => open,
         UART0_TX                         => open,
         UART0_CTSN                       => '0',
         UART0_DCDN                       => '0',
         UART0_DSRN                       => '0',
         UART0_RIN                        => '0',
         UART0_RX                         => '0',

         -- FMIO UART1
         UART1_DTRN                       => open,
         UART1_RTSN                       => open,
         UART1_TX                         => open,
         UART1_CTSN                       => '0',
         UART1_DCDN                       => '0',
         UART1_DSRN                       => '0',
         UART1_RIN                        => '0',
         UART1_RX                         => '0',

         -- FMIO TTC0
         TTC0_WAVE0_OUT                   => open,
         TTC0_WAVE1_OUT                   => open,
         TTC0_WAVE2_OUT                   => open,
         TTC0_CLK0_IN                     => '0',
         TTC0_CLK1_IN                     => '0',
         TTC0_CLK2_IN                     => '0',

         -- FMIO TTC1
         TTC1_WAVE0_OUT                   => open,
         TTC1_WAVE1_OUT                   => open,
         TTC1_WAVE2_OUT                   => open,
         TTC1_CLK0_IN                     => '0',
         TTC1_CLK1_IN                     => '0',
         TTC1_CLK2_IN                     => '0',

         -- WDT
         WDT_CLK_IN                       => '0',
         WDT_RST_OUT                      => open,

         -- FTPORT
         TRACE_CLK                        => '0',
         TRACE_CTL                        => open,
         TRACE_DATA                       => open,
     
         -- USB 0
         USB0_PORT_INDCTL                 => open,
         USB0_VBUS_PWRSELECT              => open,
         USB0_VBUS_PWRFAULT               => '0',

         -- USB 1
         USB1_PORT_INDCTL                 => open,
         USB1_VBUS_PWRSELECT              => open,
         USB1_VBUS_PWRFAULT               => '0',
        
         SRAM_INTIN                       => '0',

         --M_AXI_GP0
         M_AXI_GP0_ARESETN                => axiGpMasterResetN(0),
         M_AXI_GP0_ARVALID                => axiGpMasterReadFromArm(0).arvalid,
         M_AXI_GP0_AWVALID                => axiGpMasterWriteFromArm(0).awvalid,
         M_AXI_GP0_BREADY                 => axiGpMasterWriteFromArm(0).bready,
         M_AXI_GP0_RREADY                 => axiGpMasterReadFromArm(0).rready,
         M_AXI_GP0_WLAST                  => axiGpMasterWriteFromArm(0).wlast,
         M_AXI_GP0_WVALID                 => axiGpMasterWriteFromArm(0).wvalid,
         M_AXI_GP0_ARID                   => axiGpMasterReadFromArm(0).arid,
         M_AXI_GP0_AWID                   => axiGpMasterWriteFromArm(0).awid,
         M_AXI_GP0_WID                    => axiGpMasterWriteFromArm(0).wid,
         M_AXI_GP0_ARBURST                => axiGpMasterReadFromArm(0).arburst,
         M_AXI_GP0_ARLOCK                 => axiGpMasterReadFromArm(0).arlock,
         M_AXI_GP0_ARSIZE                 => axiGpMasterReadFromArm(0).arsize,
         M_AXI_GP0_AWBURST                => axiGpMasterWriteFromArm(0).awburst,
         M_AXI_GP0_AWLOCK                 => axiGpMasterWriteFromArm(0).awlock,
         M_AXI_GP0_AWSIZE                 => axiGpMasterWriteFromArm(0).awsize,
         M_AXI_GP0_ARPROT                 => axiGpMasterReadFromArm(0).arprot,
         M_AXI_GP0_AWPROT                 => axiGpMasterWriteFromArm(0).awprot,
         M_AXI_GP0_ARADDR                 => axiGpMasterReadFromArm(0).araddr,
         M_AXI_GP0_AWADDR                 => axiGpMasterWriteFromArm(0).awaddr,
         M_AXI_GP0_WDATA                  => axiGpMasterWriteFromArm(0).wdata(31 downto 0),
         M_AXI_GP0_ARCACHE                => axiGpMasterReadFromArm(0).arcache,
         M_AXI_GP0_ARLEN                  => axiGpMasterReadFromArm(0).arlen,
         M_AXI_GP0_ARQOS                  => axiGpMasterReadFromArm(0).arqos,
         M_AXI_GP0_AWCACHE                => axiGpMasterWriteFromArm(0).awcache,
         M_AXI_GP0_AWLEN                  => axiGpMasterWriteFromArm(0).awlen,
         M_AXI_GP0_AWQOS                  => axiGpMasterWriteFromArm(0).awqos,
         M_AXI_GP0_WSTRB                  => axiGpMasterWriteFromArm(0).wstrb(3 downto 0),
         M_AXI_GP0_ACLK                   => axiClk,
         M_AXI_GP0_ARREADY                => axiGpMasterReadToArm(0).arready,
         M_AXI_GP0_AWREADY                => axiGpMasterWriteToArm(0).awready,
         M_AXI_GP0_BVALID                 => axiGpMasterWriteToArm(0).bvalid,
         M_AXI_GP0_RLAST                  => axiGpMasterReadToArm(0).rlast,
         M_AXI_GP0_RVALID                 => axiGpMasterReadToArm(0).rvalid,
         M_AXI_GP0_WREADY                 => axiGpMasterWriteToArm(0).wready,
         M_AXI_GP0_BID                    => axiGpMasterWriteToArm(0).bid,
         M_AXI_GP0_RID                    => axiGpMasterReadToArm(0).rid,
         M_AXI_GP0_BRESP                  => axiGpMasterWriteToArm(0).bresp,
         M_AXI_GP0_RRESP                  => axiGpMasterReadToArm(0).rresp,
         M_AXI_GP0_RDATA                  => axiGpMasterReadToArm(0).rdata(31 downto 0),
 
         -- M_AXI_GP1
         M_AXI_GP1_ARESETN                => axiGpMasterResetN(1),
         M_AXI_GP1_ARVALID                => axiGpMasterReadFromArm(1).arvalid,
         M_AXI_GP1_AWVALID                => axiGpMasterWriteFromArm(1).awvalid,
         M_AXI_GP1_BREADY                 => axiGpMasterWriteFromArm(1).bready,
         M_AXI_GP1_RREADY                 => axiGpMasterReadFromArm(1).rready,
         M_AXI_GP1_WLAST                  => axiGpMasterWriteFromArm(1).wlast,
         M_AXI_GP1_WVALID                 => axiGpMasterWriteFromArm(1).wvalid,
         M_AXI_GP1_ARID                   => axiGpMasterReadFromArm(1).arid,
         M_AXI_GP1_AWID                   => axiGpMasterWriteFromArm(1).awid,
         M_AXI_GP1_WID                    => axiGpMasterWriteFromArm(1).wid,
         M_AXI_GP1_ARBURST                => axiGpMasterReadFromArm(1).arburst,
         M_AXI_GP1_ARLOCK                 => axiGpMasterReadFromArm(1).arlock,
         M_AXI_GP1_ARSIZE                 => axiGpMasterReadFromArm(1).arsize,
         M_AXI_GP1_AWBURST                => axiGpMasterWriteFromArm(1).awburst,
         M_AXI_GP1_AWLOCK                 => axiGpMasterWriteFromArm(1).awlock,
         M_AXI_GP1_AWSIZE                 => axiGpMasterWriteFromArm(1).awsize,
         M_AXI_GP1_ARPROT                 => axiGpMasterReadFromArm(1).arprot,
         M_AXI_GP1_AWPROT                 => axiGpMasterWriteFromArm(1).awprot,
         M_AXI_GP1_ARADDR                 => axiGpMasterReadFromArm(1).araddr,
         M_AXI_GP1_AWADDR                 => axiGpMasterWriteFromArm(1).awaddr,
         M_AXI_GP1_WDATA                  => axiGpMasterWriteFromArm(1).wdata(31 downto 0),
         M_AXI_GP1_ARCACHE                => axiGpMasterReadFromArm(1).arcache,
         M_AXI_GP1_ARLEN                  => axiGpMasterReadFromArm(1).arlen,
         M_AXI_GP1_ARQOS                  => axiGpMasterReadFromArm(1).arqos,
         M_AXI_GP1_AWCACHE                => axiGpMasterWriteFromArm(1).awcache,
         M_AXI_GP1_AWLEN                  => axiGpMasterWriteFromArm(1).awlen,
         M_AXI_GP1_AWQOS                  => axiGpMasterWriteFromArm(1).awqos,
         M_AXI_GP1_WSTRB                  => axiGpMasterWriteFromArm(1).wstrb(3 downto 0),
         M_AXI_GP1_ACLK                   => axiClk,
         M_AXI_GP1_ARREADY                => axiGpMasterReadToArm(1).arready,
         M_AXI_GP1_AWREADY                => axiGpMasterWriteToArm(1).awready,
         M_AXI_GP1_BVALID                 => axiGpMasterWriteToArm(1).bvalid,
         M_AXI_GP1_RLAST                  => axiGpMasterReadToArm(1).rlast,
         M_AXI_GP1_RVALID                 => axiGpMasterReadToArm(1).rvalid,
         M_AXI_GP1_WREADY                 => axiGpMasterWriteToArm(1).wready,
         M_AXI_GP1_BID                    => axiGpMasterWriteToArm(1).bid,
         M_AXI_GP1_RID                    => axiGpMasterReadToArm(1).rid,
         M_AXI_GP1_BRESP                  => axiGpMasterWriteToArm(1).bresp,
         M_AXI_GP1_RRESP                  => axiGpMasterReadToArm(1).rresp,
         M_AXI_GP1_RDATA                  => axiGpMasterReadToArm(1).rdata(31 downto 0),

         -- S_AXI_GP0
         S_AXI_GP0_ARESETN                => axiGpSlaveResetN(0),
         S_AXI_GP0_ARREADY                => axiGpSlaveReadFromArm(0).arready,
         S_AXI_GP0_AWREADY                => axiGpSlaveWriteFromArm(0).awready,
         S_AXI_GP0_BVALID                 => axiGpSlaveWriteFromArm(0).bvalid,
         S_AXI_GP0_RLAST                  => axiGpSlaveReadFromArm(0).rlast,
         S_AXI_GP0_RVALID                 => axiGpSlaveReadFromArm(0).rvalid,
         S_AXI_GP0_WREADY                 => axiGpSlaveWriteFromArm(0).wready,
         S_AXI_GP0_BID                    => axiGpSlaveWriteFromArm(0).bid(5 downto 0),
         S_AXI_GP0_RID                    => axiGpSlaveReadFromArm(0).rid(5 downto 0),
         S_AXI_GP0_BRESP                  => axiGpSlaveWriteFromArm(0).bresp,
         S_AXI_GP0_RRESP                  => axiGpSlaveReadFromArm(0).rresp,
         S_AXI_GP0_RDATA                  => axiGpSlaveReadFromArm(0).rdata(31 downto 0),
         S_AXI_GP0_ACLK                   => axiClk,
         S_AXI_GP0_ARVALID                => axiGpSlaveReadToArm(0).arvalid,
         S_AXI_GP0_AWVALID                => axiGpSlaveWriteToArm(0).awvalid,
         S_AXI_GP0_BREADY                 => axiGpSlaveWriteToArm(0).bready,
         S_AXI_GP0_RREADY                 => axiGpSlaveReadToArm(0).rready,
         S_AXI_GP0_WLAST                  => axiGpSlaveWriteToArm(0).wlast,
         S_AXI_GP0_WVALID                 => axiGpSlaveWriteToArm(0).wvalid,
         S_AXI_GP0_ARID                   => axiGpSlaveReadToArm(0).arid(5 downto 0),
         S_AXI_GP0_AWID                   => axiGpSlaveWriteToArm(0).awid(5 downto 0),
         S_AXI_GP0_WID                    => axiGpSlaveWriteToArm(0).wid(5 downto 0),
         S_AXI_GP0_ARBURST                => axiGpSlaveReadToArm(0).arburst,
         S_AXI_GP0_ARLOCK                 => axiGpSlaveReadToArm(0).arlock,
         S_AXI_GP0_ARSIZE                 => axiGpSlaveReadToArm(0).arsize,
         S_AXI_GP0_AWBURST                => axiGpSlaveWriteToArm(0).awburst,
         S_AXI_GP0_AWLOCK                 => axiGpSlaveWriteToArm(0).awlock,
         S_AXI_GP0_AWSIZE                 => axiGpSlaveWriteToArm(0).awsize,
         S_AXI_GP0_ARPROT                 => axiGpSlaveReadToArm(0).arprot,
         S_AXI_GP0_AWPROT                 => axiGpSlaveWriteToArm(0).awprot,
         S_AXI_GP0_ARADDR                 => axiGpSlaveReadToArm(0).araddr,
         S_AXI_GP0_AWADDR                 => axiGpSlaveWriteToArm(0).awaddr,
         S_AXI_GP0_WDATA                  => axiGpSlaveWriteToArm(0).wdata(31 downto 0),
         S_AXI_GP0_ARCACHE                => axiGpSlaveReadToArm(0).arcache,
         S_AXI_GP0_ARLEN                  => axiGpSlaveReadToArm(0).arlen,
         S_AXI_GP0_ARQOS                  => axiGpSlaveReadToArm(0).arqos,
         S_AXI_GP0_AWCACHE                => axiGpSlaveWriteToArm(0).awcache,
         S_AXI_GP0_AWLEN                  => axiGpSlaveWriteToArm(0).awlen,
         S_AXI_GP0_AWQOS                  => axiGpSlaveWriteToArm(0).awqos,
         S_AXI_GP0_WSTRB                  => axiGpSlaveWriteToArm(0).wstrb(3 downto 0),

         -- S_AXI_GP1
         S_AXI_GP1_ARESETN                => axiGpSlaveResetN(1),
         S_AXI_GP1_ARREADY                => axiGpSlaveReadFromArm(1).arready,
         S_AXI_GP1_AWREADY                => axiGpSlaveWriteFromArm(1).awready,
         S_AXI_GP1_BVALID                 => axiGpSlaveWriteFromArm(1).bvalid,
         S_AXI_GP1_RLAST                  => axiGpSlaveReadFromArm(1).rlast,
         S_AXI_GP1_RVALID                 => axiGpSlaveReadFromArm(1).rvalid,
         S_AXI_GP1_WREADY                 => axiGpSlaveWriteFromArm(1).wready,
         S_AXI_GP1_BID                    => axiGpSlaveWriteFromArm(1).bid(5 downto 0),
         S_AXI_GP1_RID                    => axiGpSlaveReadFromArm(1).rid(5 downto 0),
         S_AXI_GP1_BRESP                  => axiGpSlaveWriteFromArm(1).bresp,
         S_AXI_GP1_RRESP                  => axiGpSlaveReadFromArm(1).rresp,
         S_AXI_GP1_RDATA                  => axiGpSlaveReadFromArm(1).rdata(31 downto 0),
         S_AXI_GP1_ACLK                   => axiClk,
         S_AXI_GP1_ARVALID                => axiGpSlaveReadToArm(1).arvalid,
         S_AXI_GP1_AWVALID                => axiGpSlaveWriteToArm(1).awvalid,
         S_AXI_GP1_BREADY                 => axiGpSlaveWriteToArm(1).bready,
         S_AXI_GP1_RREADY                 => axiGpSlaveReadToArm(1).rready,
         S_AXI_GP1_WLAST                  => axiGpSlaveWriteToArm(1).wlast,
         S_AXI_GP1_WVALID                 => axiGpSlaveWriteToArm(1).wvalid,
         S_AXI_GP1_ARID                   => axiGpSlaveReadToArm(1).arid(5 downto 0),
         S_AXI_GP1_AWID                   => axiGpSlaveWriteToArm(1).awid(5 downto 0),
         S_AXI_GP1_WID                    => axiGpSlaveWriteToArm(1).wid(5 downto 0),
         S_AXI_GP1_ARBURST                => axiGpSlaveReadToArm(1).arburst,
         S_AXI_GP1_ARLOCK                 => axiGpSlaveReadToArm(1).arlock,
         S_AXI_GP1_ARSIZE                 => axiGpSlaveReadToArm(1).arsize,
         S_AXI_GP1_AWBURST                => axiGpSlaveWriteToArm(1).awburst,
         S_AXI_GP1_AWLOCK                 => axiGpSlaveWriteToArm(1).awlock,
         S_AXI_GP1_AWSIZE                 => axiGpSlaveWriteToArm(1).awsize,
         S_AXI_GP1_ARPROT                 => axiGpSlaveReadToArm(1).arprot,
         S_AXI_GP1_AWPROT                 => axiGpSlaveWriteToArm(1).awprot,
         S_AXI_GP1_ARADDR                 => axiGpSlaveReadToArm(1).araddr,
         S_AXI_GP1_AWADDR                 => axiGpSlaveWriteToArm(1).awaddr,
         S_AXI_GP1_WDATA                  => axiGpSlaveWriteToArm(1).wdata(31 downto 0),
         S_AXI_GP1_ARCACHE                => axiGpSlaveReadToArm(1).arcache,
         S_AXI_GP1_ARLEN                  => axiGpSlaveReadToArm(1).arlen,
         S_AXI_GP1_ARQOS                  => axiGpSlaveReadToArm(1).arqos,
         S_AXI_GP1_AWCACHE                => axiGpSlaveWriteToArm(1).awcache,
         S_AXI_GP1_AWLEN                  => axiGpSlaveWriteToArm(1).awlen,
         S_AXI_GP1_AWQOS                  => axiGpSlaveWriteToArm(1).awqos,
         S_AXI_GP1_WSTRB                  => axiGpSlaveWriteToArm(1).wstrb(3 downto 0),

         -- S_AXI_ACP
         S_AXI_ACP_ARESETN                => axiAcpSlaveResetN,
         S_AXI_ACP_ARREADY                => axiAcpSlaveReadFromArm.arready,
         S_AXI_ACP_AWREADY                => axiAcpSlaveWriteFromArm.awready,
         S_AXI_ACP_BVALID                 => axiAcpSlaveWriteFromArm.bvalid,
         S_AXI_ACP_RLAST                  => axiAcpSlaveReadFromArm.rlast,
         S_AXI_ACP_RVALID                 => axiAcpSlaveReadFromArm.rvalid,
         S_AXI_ACP_WREADY                 => axiAcpSlaveWriteFromArm.wready,
         S_AXI_ACP_BID                    => axiAcpSlaveWriteFromArm.bid(2 downto 0),
         S_AXI_ACP_RID                    => axiAcpSlaveReadFromArm.rid(2 downto 0),
         S_AXI_ACP_BRESP                  => axiAcpSlaveWriteFromArm.bresp,
         S_AXI_ACP_RRESP                  => axiAcpSlaveReadFromArm.rresp,
         S_AXI_ACP_RDATA                  => axiAcpSlaveReadFromArm.rdata,
         S_AXI_ACP_ACLK                   => axiClk,
         S_AXI_ACP_ARVALID                => axiAcpSlaveReadToArm.arvalid,
         S_AXI_ACP_AWVALID                => axiAcpSlaveWriteToArm.awvalid,
         S_AXI_ACP_BREADY                 => axiAcpSlaveWriteToArm.bready,
         S_AXI_ACP_RREADY                 => axiAcpSlaveReadToArm.rready,
         S_AXI_ACP_WLAST                  => axiAcpSlaveWriteToArm.wlast,
         S_AXI_ACP_WVALID                 => axiAcpSlaveWriteToArm.wvalid,
         S_AXI_ACP_ARID                   => axiAcpSlaveReadToArm.arid(2 downto 0),
         S_AXI_ACP_AWID                   => axiAcpSlaveWriteToArm.awid(2 downto 0),
         S_AXI_ACP_WID                    => axiAcpSlaveWriteToArm.wid(2 downto 0),
         S_AXI_ACP_ARBURST                => axiAcpSlaveReadToArm.arburst,
         S_AXI_ACP_ARLOCK                 => axiAcpSlaveReadToArm.arlock,
         S_AXI_ACP_ARSIZE                 => axiAcpSlaveReadToArm.arsize,
         S_AXI_ACP_AWBURST                => axiAcpSlaveWriteToArm.awburst,
         S_AXI_ACP_AWLOCK                 => axiAcpSlaveWriteToArm.awlock,
         S_AXI_ACP_AWSIZE                 => axiAcpSlaveWriteToArm.awsize,
         S_AXI_ACP_ARPROT                 => axiAcpSlaveReadToArm.arprot,
         S_AXI_ACP_AWPROT                 => axiAcpSlaveWriteToArm.awprot,
         S_AXI_ACP_ARADDR                 => axiAcpSlaveReadToArm.araddr,
         S_AXI_ACP_AWADDR                 => axiAcpSlaveWriteToArm.awaddr,
         S_AXI_ACP_WDATA                  => axiAcpSlaveWriteToArm.wdata,
         S_AXI_ACP_ARCACHE                => axiAcpSlaveReadToArm.arcache,
         S_AXI_ACP_ARLEN                  => axiAcpSlaveReadToArm.arlen,
         S_AXI_ACP_ARQOS                  => axiAcpSlaveReadToArm.arqos,
         S_AXI_ACP_AWCACHE                => axiAcpSlaveWriteToArm.awcache,
         S_AXI_ACP_AWLEN                  => axiAcpSlaveWriteToArm.awlen,
         S_AXI_ACP_AWQOS                  => axiAcpSlaveWriteToArm.awqos,
         S_AXI_ACP_WSTRB                  => axiAcpSlaveWriteToArm.wstrb,
         S_AXI_ACP_ARUSER                 => axiAcpSlaveReadToArm.aruser,
         S_AXI_ACP_AWUSER                 => axiAcpSlaveWriteToArm.awuser,

         -- S_AXI_HP_0
         S_AXI_HP0_ARESETN                => axiHpSlaveResetN(0),
         S_AXI_HP0_ARREADY                => axiHpSlaveReadFromArm(0).arready,
         S_AXI_HP0_AWREADY                => axiHpSlaveWriteFromArm(0).awready,
         S_AXI_HP0_BVALID                 => axiHpSlaveWriteFromArm(0).bvalid,
         S_AXI_HP0_RLAST                  => axiHpSlaveReadFromArm(0).rlast,
         S_AXI_HP0_RVALID                 => axiHpSlaveReadFromArm(0).rvalid,
         S_AXI_HP0_WREADY                 => axiHpSlaveWriteFromArm(0).wready,
         S_AXI_HP0_BID                    => axiHpSlaveWriteFromArm(0).bid(5 downto 0),
         S_AXI_HP0_RID                    => axiHpSlaveReadFromArm(0).rid(5 downto 0),
         S_AXI_HP0_BRESP                  => axiHpSlaveWriteFromArm(0).bresp,
         S_AXI_HP0_RRESP                  => axiHpSlaveReadFromArm(0).rresp,
         S_AXI_HP0_RDATA                  => axiHpSlaveReadFromArm(0).rdata,
         S_AXI_HP0_RCOUNT                 => axiHpSlaveReadFromArm(0).rcount,
         S_AXI_HP0_WCOUNT                 => axiHpSlaveWriteFromArm(0).wcount,
         S_AXI_HP0_RACOUNT                => axiHpSlaveReadFromArm(0).racount,
         S_AXI_HP0_WACOUNT                => axiHpSlaveWriteFromArm(0).wacount,
         S_AXI_HP0_ACLK                   => axiClk,
         S_AXI_HP0_ARVALID                => axiHpSlaveReadToArm(0).arvalid,
         S_AXI_HP0_AWVALID                => axiHpSlaveWriteToArm(0).awvalid,
         S_AXI_HP0_BREADY                 => axiHpSlaveWriteToArm(0).bready,
         S_AXI_HP0_RREADY                 => axiHpSlaveReadToArm(0).rready,
         S_AXI_HP0_WLAST                  => axiHpSlaveWriteToArm(0).wlast,
         S_AXI_HP0_WVALID                 => axiHpSlaveWriteToArm(0).wvalid,
         S_AXI_HP0_RDISSUECAP1_EN         => axiHpSlaveReadToArm(0).rdissuecap1_en,
         S_AXI_HP0_WRISSUECAP1_EN         => axiHpSlaveWriteToArm(0).wrissuecap1_en,
         S_AXI_HP0_ARID                   => axiHpSlaveReadToArm(0).arid(5 downto 0),
         S_AXI_HP0_AWID                   => axiHpSlaveWriteToArm(0).awid(5 downto 0),
         S_AXI_HP0_WID                    => axiHpSlaveWriteToArm(0).wid(5 downto 0),
         S_AXI_HP0_ARBURST                => axiHpSlaveReadToArm(0).arburst,
         S_AXI_HP0_ARLOCK                 => axiHpSlaveReadToArm(0).arlock,
         S_AXI_HP0_ARSIZE                 => axiHpSlaveReadToArm(0).arsize,
         S_AXI_HP0_AWBURST                => axiHpSlaveWriteToArm(0).awburst,
         S_AXI_HP0_AWLOCK                 => axiHpSlaveWriteToArm(0).awlock,
         S_AXI_HP0_AWSIZE                 => axiHpSlaveWriteToArm(0).awsize,
         S_AXI_HP0_ARPROT                 => axiHpSlaveReadToArm(0).arprot,
         S_AXI_HP0_AWPROT                 => axiHpSlaveWriteToArm(0).awprot,
         S_AXI_HP0_ARADDR                 => axiHpSlaveReadToArm(0).araddr,
         S_AXI_HP0_AWADDR                 => axiHpSlaveWriteToArm(0).awaddr,
         S_AXI_HP0_WDATA                  => axiHpSlaveWriteToArm(0).wdata,
         S_AXI_HP0_ARCACHE                => axiHpSlaveReadToArm(0).arcache,
         S_AXI_HP0_ARLEN                  => axiHpSlaveReadToArm(0).arlen,
         S_AXI_HP0_ARQOS                  => axiHpSlaveReadToArm(0).arqos,
         S_AXI_HP0_AWCACHE                => axiHpSlaveWriteToArm(0).awcache,
         S_AXI_HP0_AWLEN                  => axiHpSlaveWriteToArm(0).awlen,
         S_AXI_HP0_AWQOS                  => axiHpSlaveWriteToArm(0).awqos,
         S_AXI_HP0_WSTRB                  => axiHpSlaveWriteToArm(0).wstrb,

         -- S_AXI_HP_1
         S_AXI_HP1_ARESETN                => axiHpSlaveResetN(1),
         S_AXI_HP1_ARREADY                => axiHpSlaveReadFromArm(1).arready,
         S_AXI_HP1_AWREADY                => axiHpSlaveWriteFromArm(1).awready,
         S_AXI_HP1_BVALID                 => axiHpSlaveWriteFromArm(1).bvalid,
         S_AXI_HP1_RLAST                  => axiHpSlaveReadFromArm(1).rlast,
         S_AXI_HP1_RVALID                 => axiHpSlaveReadFromArm(1).rvalid,
         S_AXI_HP1_WREADY                 => axiHpSlaveWriteFromArm(1).wready,
         S_AXI_HP1_BID                    => axiHpSlaveWriteFromArm(1).bid(5 downto 0),
         S_AXI_HP1_RID                    => axiHpSlaveReadFromArm(1).rid(5 downto 0),
         S_AXI_HP1_BRESP                  => axiHpSlaveWriteFromArm(1).bresp,
         S_AXI_HP1_RRESP                  => axiHpSlaveReadFromArm(1).rresp,
         S_AXI_HP1_RDATA                  => axiHpSlaveReadFromArm(1).rdata,
         S_AXI_HP1_RCOUNT                 => axiHpSlaveReadFromArm(1).rcount,
         S_AXI_HP1_WCOUNT                 => axiHpSlaveWriteFromArm(1).wcount,
         S_AXI_HP1_RACOUNT                => axiHpSlaveReadFromArm(1).racount,
         S_AXI_HP1_WACOUNT                => axiHpSlaveWriteFromArm(1).wacount,
         S_AXI_HP1_ACLK                   => axiClk,
         S_AXI_HP1_ARVALID                => axiHpSlaveReadToArm(1).arvalid,
         S_AXI_HP1_AWVALID                => axiHpSlaveWriteToArm(1).awvalid,
         S_AXI_HP1_BREADY                 => axiHpSlaveWriteToArm(1).bready,
         S_AXI_HP1_RREADY                 => axiHpSlaveReadToArm(1).rready,
         S_AXI_HP1_WLAST                  => axiHpSlaveWriteToArm(1).wlast,
         S_AXI_HP1_WVALID                 => axiHpSlaveWriteToArm(1).wvalid,
         S_AXI_HP1_RDISSUECAP1_EN         => axiHpSlaveReadToArm(1).rdissuecap1_en,
         S_AXI_HP1_WRISSUECAP1_EN         => axiHpSlaveWriteToArm(1).wrissuecap1_en,
         S_AXI_HP1_ARID                   => axiHpSlaveReadToArm(1).arid(5 downto 0),
         S_AXI_HP1_AWID                   => axiHpSlaveWriteToArm(1).awid(5 downto 0),
         S_AXI_HP1_WID                    => axiHpSlaveWriteToArm(1).wid(5 downto 0),
         S_AXI_HP1_ARBURST                => axiHpSlaveReadToArm(1).arburst,
         S_AXI_HP1_ARLOCK                 => axiHpSlaveReadToArm(1).arlock,
         S_AXI_HP1_ARSIZE                 => axiHpSlaveReadToArm(1).arsize,
         S_AXI_HP1_AWBURST                => axiHpSlaveWriteToArm(1).awburst,
         S_AXI_HP1_AWLOCK                 => axiHpSlaveWriteToArm(1).awlock,
         S_AXI_HP1_AWSIZE                 => axiHpSlaveWriteToArm(1).awsize,
         S_AXI_HP1_ARPROT                 => axiHpSlaveReadToArm(1).arprot,
         S_AXI_HP1_AWPROT                 => axiHpSlaveWriteToArm(1).awprot,
         S_AXI_HP1_ARADDR                 => axiHpSlaveReadToArm(1).araddr,
         S_AXI_HP1_AWADDR                 => axiHpSlaveWriteToArm(1).awaddr,
         S_AXI_HP1_WDATA                  => axiHpSlaveWriteToArm(1).wdata,
         S_AXI_HP1_ARCACHE                => axiHpSlaveReadToArm(1).arcache,
         S_AXI_HP1_ARLEN                  => axiHpSlaveReadToArm(1).arlen,
         S_AXI_HP1_ARQOS                  => axiHpSlaveReadToArm(1).arqos,
         S_AXI_HP1_AWCACHE                => axiHpSlaveWriteToArm(1).awcache,
         S_AXI_HP1_AWLEN                  => axiHpSlaveWriteToArm(1).awlen,
         S_AXI_HP1_AWQOS                  => axiHpSlaveWriteToArm(1).awqos,
         S_AXI_HP1_WSTRB                  => axiHpSlaveWriteToArm(1).wstrb,

         -- S_AXI_HP_2
         S_AXI_HP2_ARESETN                => axiHpSlaveResetN(2),
         S_AXI_HP2_ARREADY                => axiHpSlaveReadFromArm(2).arready,
         S_AXI_HP2_AWREADY                => axiHpSlaveWriteFromArm(2).awready,
         S_AXI_HP2_BVALID                 => axiHpSlaveWriteFromArm(2).bvalid,
         S_AXI_HP2_RLAST                  => axiHpSlaveReadFromArm(2).rlast,
         S_AXI_HP2_RVALID                 => axiHpSlaveReadFromArm(2).rvalid,
         S_AXI_HP2_WREADY                 => axiHpSlaveWriteFromArm(2).wready,
         S_AXI_HP2_BID                    => axiHpSlaveWriteFromArm(2).bid(5 downto 0),
         S_AXI_HP2_RID                    => axiHpSlaveReadFromArm(2).rid(5 downto 0),
         S_AXI_HP2_BRESP                  => axiHpSlaveWriteFromArm(2).bresp,
         S_AXI_HP2_RRESP                  => axiHpSlaveReadFromArm(2).rresp,
         S_AXI_HP2_RDATA                  => axiHpSlaveReadFromArm(2).rdata,
         S_AXI_HP2_RCOUNT                 => axiHpSlaveReadFromArm(2).rcount,
         S_AXI_HP2_WCOUNT                 => axiHpSlaveWriteFromArm(2).wcount,
         S_AXI_HP2_RACOUNT                => axiHpSlaveReadFromArm(2).racount,
         S_AXI_HP2_WACOUNT                => axiHpSlaveWriteFromArm(2).wacount,
         S_AXI_HP2_ACLK                   => axiClk,
         S_AXI_HP2_ARVALID                => axiHpSlaveReadToArm(2).arvalid,
         S_AXI_HP2_AWVALID                => axiHpSlaveWriteToArm(2).awvalid,
         S_AXI_HP2_BREADY                 => axiHpSlaveWriteToArm(2).bready,
         S_AXI_HP2_RREADY                 => axiHpSlaveReadToArm(2).rready,
         S_AXI_HP2_WLAST                  => axiHpSlaveWriteToArm(2).wlast,
         S_AXI_HP2_WVALID                 => axiHpSlaveWriteToArm(2).wvalid,
         S_AXI_HP2_RDISSUECAP1_EN         => axiHpSlaveReadToArm(2).rdissuecap1_en,
         S_AXI_HP2_WRISSUECAP1_EN         => axiHpSlaveWriteToArm(2).wrissuecap1_en,
         S_AXI_HP2_ARID                   => axiHpSlaveReadToArm(2).arid(5 downto 0),
         S_AXI_HP2_AWID                   => axiHpSlaveWriteToArm(2).awid(5 downto 0),
         S_AXI_HP2_WID                    => axiHpSlaveWriteToArm(2).wid(5 downto 0),
         S_AXI_HP2_ARBURST                => axiHpSlaveReadToArm(2).arburst,
         S_AXI_HP2_ARLOCK                 => axiHpSlaveReadToArm(2).arlock,
         S_AXI_HP2_ARSIZE                 => axiHpSlaveReadToArm(2).arsize,
         S_AXI_HP2_AWBURST                => axiHpSlaveWriteToArm(2).awburst,
         S_AXI_HP2_AWLOCK                 => axiHpSlaveWriteToArm(2).awlock,
         S_AXI_HP2_AWSIZE                 => axiHpSlaveWriteToArm(2).awsize,
         S_AXI_HP2_ARPROT                 => axiHpSlaveReadToArm(2).arprot,
         S_AXI_HP2_AWPROT                 => axiHpSlaveWriteToArm(2).awprot,
         S_AXI_HP2_ARADDR                 => axiHpSlaveReadToArm(2).araddr,
         S_AXI_HP2_AWADDR                 => axiHpSlaveWriteToArm(2).awaddr,
         S_AXI_HP2_WDATA                  => axiHpSlaveWriteToArm(2).wdata,
         S_AXI_HP2_ARCACHE                => axiHpSlaveReadToArm(2).arcache,
         S_AXI_HP2_ARLEN                  => axiHpSlaveReadToArm(2).arlen,
         S_AXI_HP2_ARQOS                  => axiHpSlaveReadToArm(2).arqos,
         S_AXI_HP2_AWCACHE                => axiHpSlaveWriteToArm(2).awcache,
         S_AXI_HP2_AWLEN                  => axiHpSlaveWriteToArm(2).awlen,
         S_AXI_HP2_AWQOS                  => axiHpSlaveWriteToArm(2).awqos,
         S_AXI_HP2_WSTRB                  => axiHpSlaveWriteToArm(2).wstrb,

         -- S_AXI_HP_3
         S_AXI_HP3_ARESETN                => axiHpSlaveResetN(3),
         S_AXI_HP3_ARREADY                => axiHpSlaveReadFromArm(3).arready,
         S_AXI_HP3_AWREADY                => axiHpSlaveWriteFromArm(3).awready,
         S_AXI_HP3_BVALID                 => axiHpSlaveWriteFromArm(3).bvalid,
         S_AXI_HP3_RLAST                  => axiHpSlaveReadFromArm(3).rlast,
         S_AXI_HP3_RVALID                 => axiHpSlaveReadFromArm(3).rvalid,
         S_AXI_HP3_WREADY                 => axiHpSlaveWriteFromArm(3).wready,
         S_AXI_HP3_BID                    => axiHpSlaveWriteFromArm(3).bid(5 downto 0),
         S_AXI_HP3_RID                    => axiHpSlaveReadFromArm(3).rid(5 downto 0),
         S_AXI_HP3_BRESP                  => axiHpSlaveWriteFromArm(3).bresp,
         S_AXI_HP3_RRESP                  => axiHpSlaveReadFromArm(3).rresp,
         S_AXI_HP3_RDATA                  => axiHpSlaveReadFromArm(3).rdata,
         S_AXI_HP3_RCOUNT                 => axiHpSlaveReadFromArm(3).rcount,
         S_AXI_HP3_WCOUNT                 => axiHpSlaveWriteFromArm(3).wcount,
         S_AXI_HP3_RACOUNT                => axiHpSlaveReadFromArm(3).racount,
         S_AXI_HP3_WACOUNT                => axiHpSlaveWriteFromArm(3).wacount,
         S_AXI_HP3_ACLK                   => axiClk,
         S_AXI_HP3_ARVALID                => axiHpSlaveReadToArm(3).arvalid,
         S_AXI_HP3_AWVALID                => axiHpSlaveWriteToArm(3).awvalid,
         S_AXI_HP3_BREADY                 => axiHpSlaveWriteToArm(3).bready,
         S_AXI_HP3_RREADY                 => axiHpSlaveReadToArm(3).rready,
         S_AXI_HP3_WLAST                  => axiHpSlaveWriteToArm(3).wlast,
         S_AXI_HP3_WVALID                 => axiHpSlaveWriteToArm(3).wvalid,
         S_AXI_HP3_RDISSUECAP1_EN         => axiHpSlaveReadToArm(3).rdissuecap1_en,
         S_AXI_HP3_WRISSUECAP1_EN         => axiHpSlaveWriteToArm(3).wrissuecap1_en,
         S_AXI_HP3_ARID                   => axiHpSlaveReadToArm(3).arid(5 downto 0),
         S_AXI_HP3_AWID                   => axiHpSlaveWriteToArm(3).awid(5 downto 0),
         S_AXI_HP3_WID                    => axiHpSlaveWriteToArm(3).wid(5 downto 0),
         S_AXI_HP3_ARBURST                => axiHpSlaveReadToArm(3).arburst,
         S_AXI_HP3_ARLOCK                 => axiHpSlaveReadToArm(3).arlock,
         S_AXI_HP3_ARSIZE                 => axiHpSlaveReadToArm(3).arsize,
         S_AXI_HP3_AWBURST                => axiHpSlaveWriteToArm(3).awburst,
         S_AXI_HP3_AWLOCK                 => axiHpSlaveWriteToArm(3).awlock,
         S_AXI_HP3_AWSIZE                 => axiHpSlaveWriteToArm(3).awsize,
         S_AXI_HP3_ARPROT                 => axiHpSlaveReadToArm(3).arprot,
         S_AXI_HP3_AWPROT                 => axiHpSlaveWriteToArm(3).awprot,
         S_AXI_HP3_ARADDR                 => axiHpSlaveReadToArm(3).araddr,
         S_AXI_HP3_AWADDR                 => axiHpSlaveWriteToArm(3).awaddr,
         S_AXI_HP3_WDATA                  => axiHpSlaveWriteToArm(3).wdata,
         S_AXI_HP3_ARCACHE                => axiHpSlaveReadToArm(3).arcache,
         S_AXI_HP3_ARLEN                  => axiHpSlaveReadToArm(3).arlen,
         S_AXI_HP3_ARQOS                  => axiHpSlaveReadToArm(3).arqos,
         S_AXI_HP3_AWCACHE                => axiHpSlaveWriteToArm(3).awcache,
         S_AXI_HP3_AWLEN                  => axiHpSlaveWriteToArm(3).awlen,
         S_AXI_HP3_AWQOS                  => axiHpSlaveWriteToArm(3).awqos,
         S_AXI_HP3_WSTRB                  => axiHpSlaveWriteToArm(3).wstrb,

         -- IRQ
         -- output [28:0] IRQ_P2F      => IRQ_P2F,
         IRQ_P2F_DMAC_ABORT               => open,
         IRQ_P2F_DMAC0                    => open,
         IRQ_P2F_DMAC1                    => open,
         IRQ_P2F_DMAC2                    => open,
         IRQ_P2F_DMAC3                    => open,
         IRQ_P2F_DMAC4                    => open,
         IRQ_P2F_DMAC5                    => open,
         IRQ_P2F_DMAC6                    => open,
         IRQ_P2F_DMAC7                    => open,
         IRQ_P2F_SMC                      => open,
         IRQ_P2F_QSPI                     => open,
         IRQ_P2F_CTI                      => open,
         IRQ_P2F_GPIO                     => open,
         IRQ_P2F_USB0                     => open,
         IRQ_P2F_ENET0                    => open,
         IRQ_P2F_ENET_WAKE0               => open,
         IRQ_P2F_SDIO0                    => open,
         IRQ_P2F_I2C0                     => open,
         IRQ_P2F_SPI0                     => open,
         IRQ_P2F_UART0                    => open,
         IRQ_P2F_CAN0                     => open,
         IRQ_P2F_USB1                     => open,
         IRQ_P2F_ENET1                    => open,
         IRQ_P2F_ENET_WAKE1               => open,
         IRQ_P2F_SDIO1                    => open,
         IRQ_P2F_I2C1                     => open,
         IRQ_P2F_SPI1                     => open,
         IRQ_P2F_UART1                    => open,
         IRQ_P2F_CAN1                     => open,
         IRQ_F2P                          => armInt,
         Core0_nFIQ                       => '0',
         Core0_nIRQ                       => '0',
         Core1_nFIQ                       => '0',
         Core1_nIRQ                       => '0',

         -- DMA 0
         DMA0_DATYPE                      => open,
         DMA0_DAVALID                     => open,
         DMA0_DRREADY                     => open,
         DMA0_RSTN                        => open,
         DMA0_ACLK                        => '0',
         DMA0_DAREADY                     => '0',
         DMA0_DRLAST                      => '0',
         DMA0_DRVALID                     => '0',
         DMA0_DRTYPE                      => "00",

         -- DMA 1
         DMA1_DATYPE                      => open,
         DMA1_DAVALID                     => open,
         DMA1_DRREADY                     => open,
         DMA1_RSTN                        => open,
         DMA1_ACLK                        => '0',
         DMA1_DAREADY                     => '0',
         DMA1_DRLAST                      => '0',
         DMA1_DRVALID                     => '0',
         DMA1_DRTYPE                      => "00",

         -- DMA 2
         DMA2_DATYPE                      => open,
         DMA2_DAVALID                     => open,
         DMA2_DRREADY                     => open,
         DMA2_RSTN                        => open,
         DMA2_ACLK                        => '0',
         DMA2_DAREADY                     => '0',
         DMA2_DRLAST                      => '0',
         DMA2_DRVALID                     => '0',
         DMA2_DRTYPE                      => "00",

         -- DMA 3
         DMA3_DATYPE                      => open,
         DMA3_DAVALID                     => open,
         DMA3_DRREADY                     => open,
         DMA3_RSTN                        => open,
         DMA3_ACLK                        => '0',
         DMA3_DAREADY                     => '0',
         DMA3_DRLAST                      => '0',
         DMA3_DRVALID                     => '0',
         DMA3_DRTYPE                      => "00",
     
         -- FCLK
         FCLK_CLK3                        => fclkClk3,
         FCLK_CLK2                        => fclkClk2,
         FCLK_CLK1                        => fclkClk1,
         FCLK_CLK0                        => fclkClk0,
         FCLK_CLKTRIG3_N                  => '1',
         FCLK_CLKTRIG2_N                  => '1',
         FCLK_CLKTRIG1_N                  => '1',
         FCLK_CLKTRIG0_N                  => '1',
         FCLK_RESET3_N                    => fclkRst3N,
         FCLK_RESET2_N                    => fclkRst2N,
         FCLK_RESET1_N                    => fclkRst1N,
         FCLK_RESET0_N                    => fclkRst0N,

         -- FTMD
         FTMD_TRACEIN_DATA                => x"00000000",
         FTMD_TRACEIN_VALID               => '0',
         FTMD_TRACEIN_CLK                 => '0',
         FTMD_TRACEIN_ATID                => "0000",
    
         -- FTMT
         FTMT_F2P_TRIG                    => "0000",
         FTMT_F2P_TRIGACK                 => open,
         FTMT_F2P_DEBUG                   => x"00000000",
         FTMT_P2F_TRIGACK                 => "0000",
         FTMT_P2F_TRIG                    => open,
         FTMT_P2F_DEBUG                   => open,

         -- FIDLE
         FPGA_IDLE_N                      => '0',
     
         -- EVENT
         EVENT_EVENTO                     => open,
         EVENT_STANDBYWFE                 => open,
         EVENT_STANDBYWFI                 => open,
         EVENT_EVENTI                     => '0',
     
         -- DARB
         DDR_ARB                          => "0000",
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
         PS_SRSTB                         => ipsSrstB,
         PS_CLK                           => ipsClk,
         PS_PORB                          => ipsPorB
      );

   -- Unused AXI Master GP Signals
   U_UnusedMasterGP: for i in 0 to 1 generate
      axiGpMasterReadFromArm(i).rdissuecap1_en       <= '0';
      axiGpMasterWriteFromArm(i).wrissuecap1_en      <= '0';
      axiGpMasterReadFromArm(i).aruser               <= "00000";
      axiGpMasterWriteFromArm(i).awuser              <= "00000";
      axiGpMasterWriteFromArm(i).wdata(63 downto 32) <= (others=>'0');
      axiGpMasterWriteFromArm(i).wstrb(7 downto 4)   <= "0000";
   end generate;

   -- Unused AXI Slave GP Signals
   U_UnusedSlaveGP: for i in 0 to 1 generate
      axiGpSlaveReadFromArm(i).rcount              <= (others=>'0');
      axiGpSlaveWriteFromArm(i).wcount             <= (others=>'0');
      axiGpSlaveReadFromArm(i).racount             <= (others=>'0');
      axiGpSlaveWriteFromArm(i).wacount            <= (others=>'0');
      axiGpSlaveReadFromArm(i).rdata(63 downto 32) <= (others=>'0');
      axiGpSlaveWriteFromArm(i).bid(11 downto 6)   <= (others=>'0');
      axiGpSlaveReadFromArm(i).rid(11 downto 6)    <= (others=>'0');
   end generate;

   -- Unused AXI ACP Signals
   axiAcpSlaveReadFromArm.rcount            <= (others=>'0');
   axiAcpSlaveWriteFromArm.wcount           <= (others=>'0');
   axiAcpSlaveReadFromArm.racount           <= (others=>'0');
   axiAcpSlaveWriteFromArm.wacount          <= (others=>'0');
   axiAcpSlaveWriteFromArm.bid(11 downto 3) <= (others=>'0');
   axiAcpSlaveReadFromArm.rid(11 downto 3)  <= (others=>'0');

   -- Unused AXI Slave HP Signals
   U_UnusedSlaveHP: for i in 0 to 3 generate
      axiHpSlaveWriteFromArm(i).bid(11 downto 6) <= (others=>'0');
      axiHpSlaveReadFromArm(i).rid(11 downto 6)  <= (others=>'0');
   end generate;

end architecture structure;
