-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Top Level
-- File          : ArmRceG3Top.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Top level file for ARM based rce generation 3 processor core.
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

entity ArmRceG3 is
   port (

      -- Clocks
      fclkClk3            : out    std_logic;
      fclkClk2            : out    std_logic;
      fclkClk1            : out    std_logic;
      fclkClk0            : out    std_logic;
      fclkRst3N           : out    std_logic;
      fclkRst2N           : out    std_logic;
      fclkRst1N           : out    std_logic;
      fclkRst0N           : out    std_logic;

      -- AXI GP Master
      axiGpMasterClk1     : in     std_logic;
      axiGpMasterClk0     : in     std_logic;
      axiGpMasterResetN   : out    std_logic_vector(1 downto 0);
      axiGpMasterFromArm  : out    AxiMasterVector(1 downto 0);
      axiGpMasterToArm    : in     AxiSlaveVector(1 downto 0);

      -- AXI GP Slave
      axiGpSlaveClk1      : in     std_logic;
      axiGpSlaveClk0      : in     std_logic;
      axiGpSlaveResetN    : out    std_logic_vector(1 downto 0);
      axiGpSlaveFromArm   : out    AxiSlaveVector(1 downto 0);
      axiGpSlaveToArm     : in     AxiMasterVector(1 downto 0);

      -- AXI ACP Slave
      axiAcpSlaveClk      : in     std_logic;
      axiAcpSlaveResetN   : out    std_logic;
      axiAcpSlaveFromArm  : out    AxiSlaveType;
      axiAcpSlaveToArm    : in     AxiMasterType;

      -- AXI HP Slave
      axiHpSlaveClk3      : in     std_logic;
      axiHpSlaveClk2      : in     std_logic;
      axiHpSlaveClk1      : in     std_logic;
      axiHpSlaveClk0      : in     std_logic;
      axiHpSlaveResetN    : out    std_logic_vector(3 downto 0);
      axiHpSlaveFromArm   : out    AxiSlaveVector(3 downto 0);
      axiHpSlaveToArm     : in     AxiMasterVector(3 downto 0);

   );
end ArmRceG3;

architecture structure of ArmRceG3 is

   -- Local signals



begin



   -----------------------------------------------------------------------------------
   -- Processor system module
   -----------------------------------------------------------------------------------
   U_PS7: processing_system_7 
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
         C_NUM_F2P_INTR_INPUTS           =>  2,
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
         C_EN_EMIO_ENET0                 =>  0,
         C_EN_EMIO_ENET1                 =>  0,
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
         ENET0_GMII_TX_EN                 => open,
         ENET0_GMII_TX_ER                 => open,
         ENET0_MDIO_MDC                   => open,
         ENET0_MDIO_O                     => open,
         ENET0_MDIO_T                     => open,
         ENET0_PTP_DELAY_REQ_RX           => open,
         ENET0_PTP_DELAY_REQ_TX           => open,
         ENET0_PTP_PDELAY_REQ_RX          => open,
         ENET0_PTP_PDELAY_REQ_TX          => open,
         ENET0_PTP_PDELAY_RESP_RX         => open,
         ENET0_PTP_PDELAY_RESP_TX         => open,
         ENET0_PTP_SYNC_FRAME_RX          => open,
         ENET0_PTP_SYNC_FRAME_TX          => open,
         ENET0_SOF_RX                     => open,
         ENET0_SOF_TX                     => open,
         ENET0_GMII_TXD                   => open,
         ENET0_GMII_COL                   => '0',
         ENET0_GMII_CRS                   => '0',
         ENET0_GMII_RX_CLK                => '0',
         ENET0_GMII_RX_DV                 => '0',
         ENET0_GMII_RX_ER                 => '0',
         ENET0_GMII_TX_CLK                => '0',
         ENET0_MDIO_I                     => '0',
         ENET0_EXT_INTIN                  => '0',
         ENET0_GMII_RXD                   => "00000000",

         -- FMIO ENET1
         ENET1_GMII_TX_EN                 => open,
         ENET1_GMII_TX_ER                 => open,
         ENET1_MDIO_MDC                   => open,
         ENET1_MDIO_O                     => open,
         ENET1_MDIO_T                     => open,
         ENET1_PTP_DELAY_REQ_RX           => open,
         ENET1_PTP_DELAY_REQ_TX           => open,
         ENET1_PTP_PDELAY_REQ_RX          => open,
         ENET1_PTP_PDELAY_REQ_TX          => open,
         ENET1_PTP_PDELAY_RESP_RX         => open,
         ENET1_PTP_PDELAY_RESP_TX         => open,
         ENET1_PTP_SYNC_FRAME_RX          => open,
         ENET1_PTP_SYNC_FRAME_TX          => open,
         ENET1_SOF_RX                     => open,
         ENET1_SOF_TX                     => open,
         ENET1_GMII_TXD                   => open,
         ENET1_GMII_COL                   => '0',
         ENET1_GMII_CRS                   => '0',
         ENET1_GMII_RX_CLK                => '0',
         ENET1_GMII_RX_DV                 => '0',
         ENET1_GMII_RX_ER                 => '0',
         ENET1_GMII_TX_CLK                => '0',
         ENET0_MDIO_I                     => '0',
         ENET1_EXT_INTIN                  => '0',
         ENET1_GMII_RXD                   => "00000000",

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
         M_AXI_GP0_ARVALID                => axiGpMasterFromArm(0).arvalid,
         M_AXI_GP0_AWVALID                => axiGpMasterFromArm(0).awvalid,
         M_AXI_GP0_BREADY                 => axiGpMasterFromArm(0).bready,
         M_AXI_GP0_RREADY                 => axiGpMasterFromArm(0).rready,
         M_AXI_GP0_WLAST                  => axiGpMasterFromArm(0).wlast,
         M_AXI_GP0_WVALID                 => axiGpMasterFromArm(0).wvalid,
         M_AXI_GP0_ARID                   => axiGpMasterFromArm(0).arid,
         M_AXI_GP0_AWID                   => axiGpMasterFromArm(0).awid,
         M_AXI_GP0_WID                    => axiGpMasterFromArm(0).wid,
         M_AXI_GP0_ARBURST                => axiGpMasterFromArm(0).arburst,
         M_AXI_GP0_ARLOCK                 => axiGpMasterFromArm(0).arlock,
         M_AXI_GP0_ARSIZE                 => axiGpMasterFromArm(0).arsize,
         M_AXI_GP0_AWBURST                => axiGpMasterFromArm(0).awburst,
         M_AXI_GP0_AWLOCK                 => axiGpMasterFromArm(0).awlock,
         M_AXI_GP0_AWSIZE                 => axiGpMasterFromArm(0).awsize,
         M_AXI_GP0_ARPROT                 => axiGpMasterFromArm(0).arprot,
         M_AXI_GP0_AWPROT                 => axiGpMasterFromArm(0).awprot,
         M_AXI_GP0_ARADDR                 => axiGpMasterFromArm(0).araddr,
         M_AXI_GP0_AWADDR                 => axiGpMasterFromArm(0).awaddr,
         M_AXI_GP0_WDATA                  => axiGpMasterFromArm(0).wdata(31 downto 0),
         M_AXI_GP0_ARCACHE                => axiGpMasterFromArm(0).arcache,
         M_AXI_GP0_ARLEN                  => axiGpMasterFromArm(0).arlen,
         M_AXI_GP0_ARQOS                  => axiGpMasterFromArm(0).arqos,
         M_AXI_GP0_AWCACHE                => axiGpMasterFromArm(0).awcache,
         M_AXI_GP0_AWLEN                  => axiGpMasterFromArm(0).awlen,
         M_AXI_GP0_AWQOS                  => axiGpMasterFromArm(0).awqos,
         M_AXI_GP0_WSTRB                  => axiGpMasterFromArm(0).wstrb,
         M_AXI_GP0_ACLK                   => axiGpMasterClk0,
         M_AXI_GP0_ARREADY                => axiGpMasterToArm(0).arready,
         M_AXI_GP0_AWREADY                => axiGpMasterToArm(0).awready,
         M_AXI_GP0_BVALID                 => axiGpMasterToArm(0).bvalid,
         M_AXI_GP0_RLAST                  => axiGpMasterToArm(0).rlast,
         M_AXI_GP0_RVALID                 => axiGpMasterToArm(0).rvalid,
         M_AXI_GP0_WREADY                 => axiGpMasterToArm(0).wready,
         M_AXI_GP0_BID                    => axiGpMasterToArm(0).bid,
         M_AXI_GP0_RID                    => axiGpMasterToArm(0).rid,
         M_AXI_GP0_BRESP                  => axiGpMasterToArm(0).bresp,
         M_AXI_GP0_RRESP                  => axiGpMasterToArm(0).rresp,
         M_AXI_GP0_RDATA                  => axiGpMasterToArm(0).rdata(31 downto 0),
 
         -- M_AXI_GP1
         M_AXI_GP1_ARESETN                => axiGpMasterResetN(1),
         M_AXI_GP1_ARVALID                => axiGpMasterFromArm(1).arvalid,
         M_AXI_GP1_AWVALID                => axiGpMasterFromArm(1).awvalid,
         M_AXI_GP1_BREADY                 => axiGpMasterFromArm(1).bready,
         M_AXI_GP1_RREADY                 => axiGpMasterFromArm(1).rready,
         M_AXI_GP1_WLAST                  => axiGpMasterFromArm(1).wlast,
         M_AXI_GP1_WVALID                 => axiGpMasterFromArm(1).wvalid,
         M_AXI_GP1_ARID                   => axiGpMasterFromArm(1).arid,
         M_AXI_GP1_AWID                   => axiGpMasterFromArm(1).awid,
         M_AXI_GP1_WID                    => axiGpMasterFromArm(1).wid,
         M_AXI_GP1_ARBURST                => axiGpMasterFromArm(1).arburst,
         M_AXI_GP1_ARLOCK                 => axiGpMasterFromArm(1).arlock,
         M_AXI_GP1_ARSIZE                 => axiGpMasterFromArm(1).arsize,
         M_AXI_GP1_AWBURST                => axiGpMasterFromArm(1).awburst,
         M_AXI_GP1_AWLOCK                 => axiGpMasterFromArm(1).awlock,
         M_AXI_GP1_AWSIZE                 => axiGpMasterFromArm(1).awsize,
         M_AXI_GP1_ARPROT                 => axiGpMasterFromArm(1).arprot,
         M_AXI_GP1_AWPROT                 => axiGpMasterFromArm(1).awprot,
         M_AXI_GP1_ARADDR                 => axiGpMasterFromArm(1).araddr,
         M_AXI_GP1_AWADDR                 => axiGpMasterFromArm(1).awaddr,
         M_AXI_GP1_WDATA                  => axiGpMasterFromArm(1).wdata(31 downto 0),
         M_AXI_GP1_ARCACHE                => axiGpMasterFromArm(1).arcache,
         M_AXI_GP1_ARLEN                  => axiGpMasterFromArm(1).arlen,
         M_AXI_GP1_ARQOS                  => axiGpMasterFromArm(1).arqos,
         M_AXI_GP1_AWCACHE                => axiGpMasterFromArm(1).awcache,
         M_AXI_GP1_AWLEN                  => axiGpMasterFromArm(1).awlen,
         M_AXI_GP1_AWQOS                  => axiGpMasterFromArm(1).awqos,
         M_AXI_GP1_WSTRB                  => axiGpMasterFromArm(1).wstrb,
         M_AXI_GP1_ACLK                   => axiGpMasterClk1,
         M_AXI_GP1_ARREADY                => axiGpMasterToArm(1).arready,
         M_AXI_GP1_AWREADY                => axiGpMasterToArm(1).awready,
         M_AXI_GP1_BVALID                 => axiGpMasterToArm(1).bvalid,
         M_AXI_GP1_RLAST                  => axiGpMasterToArm(1).rlast,
         M_AXI_GP1_RVALID                 => axiGpMasterToArm(1).rvalid,
         M_AXI_GP1_WREADY                 => axiGpMasterToArm(1).wready,
         M_AXI_GP1_BID                    => axiGpMasterToArm(1).bid,
         M_AXI_GP1_RID                    => axiGpMasterToArm(1).rid,
         M_AXI_GP1_BRESP                  => axiGpMasterToArm(1).bresp,
         M_AXI_GP1_RRESP                  => axiGpMasterToArm(1).rresp,
         M_AXI_GP1_RDATA                  => axiGpMasterToArm(1).rdata(31 downto 0),

         -- S_AXI_GP0
         S_AXI_GP0_ARESETN                => axiGpSlaveResetN(0),
         S_AXI_GP0_ARREADY                => axiGpSlaveFromArm(0).arready,
         S_AXI_GP0_AWREADY                => axiGpSlaveFromArm(0).awready,
         S_AXI_GP0_BVALID                 => axiGpSlaveFromArm(0).bvalid,
         S_AXI_GP0_RLAST                  => axiGpSlaveFromArm(0).rlast,
         S_AXI_GP0_RVALID                 => axiGpSlaveFromArm(0).rvalid,
         S_AXI_GP0_WREADY                 => axiGpSlaveFromArm(0).wready,
         S_AXI_GP0_BID                    => axiGpSlaveFromArm(0).bid(5 downto 0),
         S_AXI_GP0_RID                    => axiGpSlaveFromArm(0).rid(5 downto 0),
         S_AXI_GP0_BRESP                  => axiGpSlaveFromArm(0).bresp,
         S_AXI_GP0_RRESP                  => axiGpSlaveFromArm(0).rresp,
         S_AXI_GP0_RDATA                  => axiGpSlaveFromArm(0).rdata(31 downto 0),
         S_AXI_GP0_ACLK                   => axiGpSlaveClk0,
         S_AXI_GP0_ARVALID                => axiGpSlaveToArm(0).arvalid,
         S_AXI_GP0_AWVALID                => axiGpSlaveToArm(0).awvalid,
         S_AXI_GP0_BREADY                 => axiGpSlaveToArm(0).bready,
         S_AXI_GP0_RREADY                 => axiGpSlaveToArm(0).rready,
         S_AXI_GP0_WLAST                  => axiGpSlaveToArm(0).wlast,
         S_AXI_GP0_WVALID                 => axiGpSlaveToArm(0).wvalid,
         S_AXI_GP0_ARID                   => axiGpSlaveToArm(0).arid,
         S_AXI_GP0_AWID                   => axiGpSlaveToArm(0).awid,
         S_AXI_GP0_WID                    => axiGpSlaveToArm(0).wid,
         S_AXI_GP0_ARBURST                => axiGpSlaveToArm(0).arburst,
         S_AXI_GP0_ARLOCK                 => axiGpSlaveToArm(0).arlock,
         S_AXI_GP0_ARSIZE                 => axiGpSlaveToArm(0).arsize,
         S_AXI_GP0_AWBURST                => axiGpSlaveToArm(0).awburst,
         S_AXI_GP0_AWLOCK                 => axiGpSlaveToArm(0).awlock,
         S_AXI_GP0_AWSIZE                 => axiGpSlaveToArm(0).awsize,
         S_AXI_GP0_ARPROT                 => axiGpSlaveToArm(0).arprot,
         S_AXI_GP0_AWPROT                 => axiGpSlaveToArm(0).awprot,
         S_AXI_GP0_ARADDR                 => axiGpSlaveToArm(0).araddr,
         S_AXI_GP0_AWADDR                 => axiGpSlaveToArm(0).awaddr,
         S_AXI_GP0_WDATA                  => axiGpSlaveToArm(0).wdata(31 downto 0),
         S_AXI_GP0_ARCACHE                => axiGpSlaveToArm(0).arcache,
         S_AXI_GP0_ARLEN                  => axiGpSlaveToArm(0).arlen,
         S_AXI_GP0_ARQOS                  => axiGpSlaveToArm(0).arqos,
         S_AXI_GP0_AWCACHE                => axiGpSlaveToArm(0).awcache,
         S_AXI_GP0_AWLEN                  => axiGpSlaveToArm(0).awlen,
         S_AXI_GP0_AWQOS                  => axiGpSlaveToArm(0).awqos,
         S_AXI_GP0_WSTRB                  => axiGpSlaveToArm(0).wstrb,

         -- S_AXI_GP1
         S_AXI_GP1_ARESETN                => axiGpSlaveResetN(1),
         S_AXI_GP1_ARREADY                => axiGpSlaveFromArm(1).arready,
         S_AXI_GP1_AWREADY                => axiGpSlaveFromArm(1).awready,
         S_AXI_GP1_BVALID                 => axiGpSlaveFromArm(1).bvalid,
         S_AXI_GP1_RLAST                  => axiGpSlaveFromArm(1).rlast,
         S_AXI_GP1_RVALID                 => axiGpSlaveFromArm(1).rvalid,
         S_AXI_GP1_WREADY                 => axiGpSlaveFromArm(1).wready,
         S_AXI_GP1_BID                    => axiGpSlaveFromArm(1).bid(5 downto 0),
         S_AXI_GP1_RID                    => axiGpSlaveFromArm(1).rid(5 downto 0),
         S_AXI_GP1_BRESP                  => axiGpSlaveFromArm(1).bresp,
         S_AXI_GP1_RRESP                  => axiGpSlaveFromArm(1).rresp,
         S_AXI_GP1_RDATA                  => axiGpSlaveFromArm(1).rdata(31 downto 0),
         S_AXI_GP1_ACLK                   => axiGpSlaveClk1,
         S_AXI_GP1_ARVALID                => axiGpSlaveToArm(1).arvalid,
         S_AXI_GP1_AWVALID                => axiGpSlaveToArm(1).awvalid,
         S_AXI_GP1_BREADY                 => axiGpSlaveToArm(1).bready,
         S_AXI_GP1_RREADY                 => axiGpSlaveToArm(1).rready,
         S_AXI_GP1_WLAST                  => axiGpSlaveToArm(1).wlast,
         S_AXI_GP1_WVALID                 => axiGpSlaveToArm(1).wvalid,
         S_AXI_GP1_ARID                   => axiGpSlaveToArm(1).arid,
         S_AXI_GP1_AWID                   => axiGpSlaveToArm(1).awid,
         S_AXI_GP1_WID                    => axiGpSlaveToArm(1).wid,
         S_AXI_GP1_ARBURST                => axiGpSlaveToArm(1).arburst,
         S_AXI_GP1_ARLOCK                 => axiGpSlaveToArm(1).arlock,
         S_AXI_GP1_ARSIZE                 => axiGpSlaveToArm(1).arsize,
         S_AXI_GP1_AWBURST                => axiGpSlaveToArm(1).awburst,
         S_AXI_GP1_AWLOCK                 => axiGpSlaveToArm(1).awlock,
         S_AXI_GP1_AWSIZE                 => axiGpSlaveToArm(1).awsize,
         S_AXI_GP1_ARPROT                 => axiGpSlaveToArm(1).arprot,
         S_AXI_GP1_AWPROT                 => axiGpSlaveToArm(1).awprot,
         S_AXI_GP1_ARADDR                 => axiGpSlaveToArm(1).araddr,
         S_AXI_GP1_AWADDR                 => axiGpSlaveToArm(1).awaddr,
         S_AXI_GP1_WDATA                  => axiGpSlaveToArm(1).wdata(31 downto 0),
         S_AXI_GP1_ARCACHE                => axiGpSlaveToArm(1).arcache,
         S_AXI_GP1_ARLEN                  => axiGpSlaveToArm(1).arlen,
         S_AXI_GP1_ARQOS                  => axiGpSlaveToArm(1).arqos,
         S_AXI_GP1_AWCACHE                => axiGpSlaveToArm(1).awcache,
         S_AXI_GP1_AWLEN                  => axiGpSlaveToArm(1).awlen,
         S_AXI_GP1_AWQOS                  => axiGpSlaveToArm(1).awqos,
         S_AXI_GP1_WSTRB                  => axiGpSlaveToArm(1).wstrb,

         -- S_AXI_ACP
         S_AXI_ACP_ARESETN                => axiAcpSlaveResetN,
         S_AXI_ACP_ARREADY                => axiAcpSlaveFromArm.arready,
         S_AXI_ACP_AWREADY                => axiAcpSlaveFromArm.awready,
         S_AXI_ACP_BVALID                 => axiAcpSlaveFromArm.bvalid,
         S_AXI_ACP_RLAST                  => axiAcpSlaveFromArm.rlast,
         S_AXI_ACP_RVALID                 => axiAcpSlaveFromArm.rvalid,
         S_AXI_ACP_WREADY                 => axiAcpSlaveFromArm.wready,
         S_AXI_ACP_BID                    => axiAcpSlaveFromArm.bid(3 downto 0),
         S_AXI_ACP_RID                    => axiAcpSlaveFromArm.rid(3 downto 0),
         S_AXI_ACP_BRESP                  => axiAcpSlaveFromArm.bresp,
         S_AXI_ACP_RRESP                  => axiAcpSlaveFromArm.rresp,
         S_AXI_ACP_RDATA                  => axiAcpSlaveFromArm.rdata,
         S_AXI_ACP_ACLK                   => axiAcpSlaveClk,
         S_AXI_ACP_ARVALID                => axiAcpSlaveToArm.arvalid,
         S_AXI_ACP_AWVALID                => axiAcpSlaveToArm.awvalid,
         S_AXI_ACP_BREADY                 => axiAcpSlaveToArm.bready,
         S_AXI_ACP_RREADY                 => axiAcpSlaveToArm.rready,
         S_AXI_ACP_WLAST                  => axiAcpSlaveToArm.wlast,
         S_AXI_ACP_WVALID                 => axiAcpSlaveToArm.wvalid,
         S_AXI_ACP_ARID                   => axiAcpSlaveToArm.arid,
         S_AXI_ACP_AWID                   => axiAcpSlaveToArm.awid,
         S_AXI_ACP_WID                    => axiAcpSlaveToArm.wid,
         S_AXI_ACP_ARBURST                => axiAcpSlaveToArm.arburst,
         S_AXI_ACP_ARLOCK                 => axiAcpSlaveToArm.arlock,
         S_AXI_ACP_ARSIZE                 => axiAcpSlaveToArm.arsize,
         S_AXI_ACP_AWBURST                => axiAcpSlaveToArm.awburst,
         S_AXI_ACP_AWLOCK                 => axiAcpSlaveToArm.awlock,
         S_AXI_ACP_AWSIZE                 => axiAcpSlaveToArm.awsize,
         S_AXI_ACP_ARPROT                 => axiAcpSlaveToArm.arprot,
         S_AXI_ACP_AWPROT                 => axiAcpSlaveToArm.awprot,
         S_AXI_ACP_ARADDR                 => axiAcpSlaveToArm.araddr,
         S_AXI_ACP_AWADDR                 => axiAcpSlaveToArm.awaddr,
         S_AXI_ACP_WDATA                  => axiAcpSlaveToArm.wdata,
         S_AXI_ACP_ARCACHE                => axiAcpSlaveToArm.arcache,
         S_AXI_ACP_ARLEN                  => axiAcpSlaveToArm.arlen,
         S_AXI_ACP_ARQOS                  => axiAcpSlaveToArm.arqos,
         S_AXI_ACP_AWCACHE                => axiAcpSlaveToArm.awcache,
         S_AXI_ACP_AWLEN                  => axiAcpSlaveToArm.awlen,
         S_AXI_ACP_AWQOS                  => axiAcpSlaveToArm.awqos,
         S_AXI_ACP_WSTRB                  => axiAcpSlaveToArm.wstrb,
         S_AXI_ACP_ARUSER                 => axiAcpSlaveToArm.racount,
         S_AXI_ACP_AWUSER                 => axiAcpSlaveToArm.wacount,

         -- S_AXI_HP_0
         S_AXI_HP0_ARESETN                => axiHpSlaveResetN(0),
         S_AXI_HP0_ARREADY                => axiHpSlaveFromArm(0).arready,
         S_AXI_HP0_AWREADY                => axiHpSlaveFromArm(0).awready,
         S_AXI_HP0_BVALID                 => axiHpSlaveFromArm(0).bvalid,
         S_AXI_HP0_RLAST                  => axiHpSlaveFromArm(0).rlast,
         S_AXI_HP0_RVALID                 => axiHpSlaveFromArm(0).rvalid,
         S_AXI_HP0_WREADY                 => axiHpSlaveFromArm(0).wready,
         S_AXI_HP0_BID                    => axiHpSlaveFromArm(0).bid(5 downto 0),
         S_AXI_HP0_RID                    => axiHpSlaveFromArm(0).rid(5 downto 0),
         S_AXI_HP0_BRESP                  => axiHpSlaveFromArm(0).bresp,
         S_AXI_HP0_RRESP                  => axiHpSlaveFromArm(0).rresp,
         S_AXI_HP0_RDATA                  => axiHpSlaveFromArm(0).rdata,
         S_AXI_HP0_RCOUNT                 => axiHpSlaveFromArm(0).rcount,
         S_AXI_HP0_WCOUNT                 => axiHpSlaveFromArm(0).wcount,
         S_AXI_HP0_RACOUNT                => axiHpSlaveFromArm(0).racount,
         S_AXI_HP0_WACOUNT                => axiHpSlaveFromArm(0).wacount,
         S_AXI_HP0_ACLK                   => axiHpSlaveClk0,
         S_AXI_HP0_ARVALID                => axiHpSlaveToArm(0).arvalid,
         S_AXI_HP0_AWVALID                => axiHpSlaveToArm(0).awvalid,
         S_AXI_HP0_BREADY                 => axiHpSlaveToArm(0).bready,
         S_AXI_HP0_RREADY                 => axiHpSlaveToArm(0).rready,
         S_AXI_HP0_WLAST                  => axiHpSlaveToArm(0).wlast,
         S_AXI_HP0_WVALID                 => axiHpSlaveToArm(0).wvalid,
         S_AXI_HP0_RDISSUECAP1_EN         => axiHpSlaveToArm(0).rdissuecap1_en,
         S_AXI_HP0_WRISSUECAP1_EN         => axiHpSlaveToArm(0).wrissuecap1_en,
         S_AXI_HP0_ARID                   => axiHpSlaveToArm(0).arid,
         S_AXI_HP0_AWID                   => axiHpSlaveToArm(0).awid,
         S_AXI_HP0_WID                    => axiHpSlaveToArm(0).wid,
         S_AXI_HP0_ARBURST                => axiHpSlaveToArm(0).arburst,
         S_AXI_HP0_ARLOCK                 => axiHpSlaveToArm(0).arlock,
         S_AXI_HP0_ARSIZE                 => axiHpSlaveToArm(0).arsize,
         S_AXI_HP0_AWBURST                => axiHpSlaveToArm(0).awburst,
         S_AXI_HP0_AWLOCK                 => axiHpSlaveToArm(0).awlock,
         S_AXI_HP0_AWSIZE                 => axiHpSlaveToArm(0).awsize,
         S_AXI_HP0_ARPROT                 => axiHpSlaveToArm(0).arprot,
         S_AXI_HP0_AWPROT                 => axiHpSlaveToArm(0).awprot,
         S_AXI_HP0_ARADDR                 => axiHpSlaveToArm(0).araddr,
         S_AXI_HP0_AWADDR                 => axiHpSlaveToArm(0).awaddr,
         S_AXI_HP0_WDATA                  => axiHpSlaveToArm(0).wdata,
         S_AXI_HP0_ARCACHE                => axiHpSlaveToArm(0).arcache,
         S_AXI_HP0_ARLEN                  => axiHpSlaveToArm(0).arlen,
         S_AXI_HP0_ARQOS                  => axiHpSlaveToArm(0).arqos,
         S_AXI_HP0_AWCACHE                => axiHpSlaveToArm(0).awcache,
         S_AXI_HP0_AWLEN                  => axiHpSlaveToArm(0).awlen,
         S_AXI_HP0_AWQOS                  => axiHpSlaveToArm(0).awqos,
         S_AXI_HP0_WSTRB                  => axiHpSlaveToArm(0).wstrb,

         -- S_AXI_HP1
         S_AXI_HP1_ARESETN                => axiHpSlaveResetN(1),
         S_AXI_HP1_ARREADY                => axiHpSlaveFromArm(1).arready,
         S_AXI_HP1_AWREADY                => axiHpSlaveFromArm(1).awready,
         S_AXI_HP1_BVALID                 => axiHpSlaveFromArm(1).bvalid,
         S_AXI_HP1_RLAST                  => axiHpSlaveFromArm(1).rlast,
         S_AXI_HP1_RVALID                 => axiHpSlaveFromArm(1).rvalid,
         S_AXI_HP1_WREADY                 => axiHpSlaveFromArm(1).wready,
         S_AXI_HP1_BID                    => axiHpSlaveFromArm(1).bid(5 downto 1),
         S_AXI_HP1_RID                    => axiHpSlaveFromArm(1).rid(5 downto 1),
         S_AXI_HP1_BRESP                  => axiHpSlaveFromArm(1).bresp,
         S_AXI_HP1_RRESP                  => axiHpSlaveFromArm(1).rresp,
         S_AXI_HP1_RDATA                  => axiHpSlaveFromArm(1).rdata,
         S_AXI_HP1_RCOUNT                 => axiHpSlaveFromArm(1).rcount,
         S_AXI_HP1_WCOUNT                 => axiHpSlaveFromArm(1).wcount,
         S_AXI_HP1_RACOUNT                => axiHpSlaveFromArm(1).racount,
         S_AXI_HP1_WACOUNT                => axiHpSlaveFromArm(1).wacount,
         S_AXI_HP1_ACLK                   => axiHpSlaveClk1,
         S_AXI_HP1_ARVALID                => axiHpSlaveToArm(1).arvalid,
         S_AXI_HP1_AWVALID                => axiHpSlaveToArm(1).awvalid,
         S_AXI_HP1_BREADY                 => axiHpSlaveToArm(1).bready,
         S_AXI_HP1_RREADY                 => axiHpSlaveToArm(1).rready,
         S_AXI_HP1_WLAST                  => axiHpSlaveToArm(1).wlast,
         S_AXI_HP1_WVALID                 => axiHpSlaveToArm(1).wvalid,
         S_AXI_HP1_RDISSUECAP1_EN         => axiHpSlaveToArm(1).rdissuecap1_en,
         S_AXI_HP1_WRISSUECAP1_EN         => axiHpSlaveToArm(1).wrissuecap1_en,
         S_AXI_HP1_ARID                   => axiHpSlaveToArm(1).arid,
         S_AXI_HP1_AWID                   => axiHpSlaveToArm(1).awid,
         S_AXI_HP1_WID                    => axiHpSlaveToArm(1).wid,
         S_AXI_HP1_ARBURST                => axiHpSlaveToArm(1).arburst,
         S_AXI_HP1_ARLOCK                 => axiHpSlaveToArm(1).arlock,
         S_AXI_HP1_ARSIZE                 => axiHpSlaveToArm(1).arsize,
         S_AXI_HP1_AWBURST                => axiHpSlaveToArm(1).awburst,
         S_AXI_HP1_AWLOCK                 => axiHpSlaveToArm(1).awlock,
         S_AXI_HP1_AWSIZE                 => axiHpSlaveToArm(1).awsize,
         S_AXI_HP1_ARPROT                 => axiHpSlaveToArm(1).arprot,
         S_AXI_HP1_AWPROT                 => axiHpSlaveToArm(1).awprot,
         S_AXI_HP1_ARADDR                 => axiHpSlaveToArm(1).araddr,
         S_AXI_HP1_AWADDR                 => axiHpSlaveToArm(1).awaddr,
         S_AXI_HP1_WDATA                  => axiHpSlaveToArm(1).wdata,
         S_AXI_HP1_ARCACHE                => axiHpSlaveToArm(1).arcache,
         S_AXI_HP1_ARLEN                  => axiHpSlaveToArm(1).arlen,
         S_AXI_HP1_ARQOS                  => axiHpSlaveToArm(1).arqos,
         S_AXI_HP1_AWCACHE                => axiHpSlaveToArm(1).awcache,
         S_AXI_HP1_AWLEN                  => axiHpSlaveToArm(1).awlen,
         S_AXI_HP1_AWQOS                  => axiHpSlaveToArm(1).awqos,
         S_AXI_HP1_WSTRB                  => axiHpSlaveToArm(1).wstrb,

         -- S_AXI_HP2
         S_AXI_HP2_ARESETN                => axiHpSlaveResetN(2),
         S_AXI_HP2_ARREADY                => axiHpSlaveFromArm(2).arready,
         S_AXI_HP2_AWREADY                => axiHpSlaveFromArm(2).awready,
         S_AXI_HP2_BVALID                 => axiHpSlaveFromArm(2).bvalid,
         S_AXI_HP2_RLAST                  => axiHpSlaveFromArm(2).rlast,
         S_AXI_HP2_RVALID                 => axiHpSlaveFromArm(2).rvalid,
         S_AXI_HP2_WREADY                 => axiHpSlaveFromArm(2).wready,
         S_AXI_HP2_BID                    => axiHpSlaveFromArm(2).bid(5 downto 2),
         S_AXI_HP2_RID                    => axiHpSlaveFromArm(2).rid(5 downto 2),
         S_AXI_HP2_BRESP                  => axiHpSlaveFromArm(2).bresp,
         S_AXI_HP2_RRESP                  => axiHpSlaveFromArm(2).rresp,
         S_AXI_HP2_RDATA                  => axiHpSlaveFromArm(2).rdata,
         S_AXI_HP2_RCOUNT                 => axiHpSlaveFromArm(2).rcount,
         S_AXI_HP2_WCOUNT                 => axiHpSlaveFromArm(2).wcount,
         S_AXI_HP2_RACOUNT                => axiHpSlaveFromArm(2).racount,
         S_AXI_HP2_WACOUNT                => axiHpSlaveFromArm(2).wacount,
         S_AXI_HP2_ACLK                   => axiHpSlaveClk2,
         S_AXI_HP2_ARVALID                => axiHpSlaveToArm(2).arvalid,
         S_AXI_HP2_AWVALID                => axiHpSlaveToArm(2).awvalid,
         S_AXI_HP2_BREADY                 => axiHpSlaveToArm(2).bready,
         S_AXI_HP2_RREADY                 => axiHpSlaveToArm(2).rready,
         S_AXI_HP2_WLAST                  => axiHpSlaveToArm(2).wlast,
         S_AXI_HP2_WVALID                 => axiHpSlaveToArm(2).wvalid,
         S_AXI_HP2_RDISSUECAP2_EN         => axiHpSlaveToArm(2).rdissuecap2_en,
         S_AXI_HP2_WRISSUECAP2_EN         => axiHpSlaveToArm(2).wrissuecap2_en,
         S_AXI_HP2_ARID                   => axiHpSlaveToArm(2).arid,
         S_AXI_HP2_AWID                   => axiHpSlaveToArm(2).awid,
         S_AXI_HP2_WID                    => axiHpSlaveToArm(2).wid,
         S_AXI_HP2_ARBURST                => axiHpSlaveToArm(2).arburst,
         S_AXI_HP2_ARLOCK                 => axiHpSlaveToArm(2).arlock,
         S_AXI_HP2_ARSIZE                 => axiHpSlaveToArm(2).arsize,
         S_AXI_HP2_AWBURST                => axiHpSlaveToArm(2).awburst,
         S_AXI_HP2_AWLOCK                 => axiHpSlaveToArm(2).awlock,
         S_AXI_HP2_AWSIZE                 => axiHpSlaveToArm(2).awsize,
         S_AXI_HP2_ARPROT                 => axiHpSlaveToArm(2).arprot,
         S_AXI_HP2_AWPROT                 => axiHpSlaveToArm(2).awprot,
         S_AXI_HP2_ARADDR                 => axiHpSlaveToArm(2).araddr,
         S_AXI_HP2_AWADDR                 => axiHpSlaveToArm(2).awaddr,
         S_AXI_HP2_WDATA                  => axiHpSlaveToArm(2).wdata,
         S_AXI_HP2_ARCACHE                => axiHpSlaveToArm(2).arcache,
         S_AXI_HP2_ARLEN                  => axiHpSlaveToArm(2).arlen,
         S_AXI_HP2_ARQOS                  => axiHpSlaveToArm(2).arqos,
         S_AXI_HP2_AWCACHE                => axiHpSlaveToArm(2).awcache,
         S_AXI_HP2_AWLEN                  => axiHpSlaveToArm(2).awlen,
         S_AXI_HP2_AWQOS                  => axiHpSlaveToArm(2).awqos,
         S_AXI_HP2_WSTRB                  => axiHpSlaveToArm(2).wstrb,

         -- S_AXI_HP3
         S_AXI_HP3_ARESETN                => axiHpSlaveResetN(3),
         S_AXI_HP3_ARREADY                => axiHpSlaveFromArm(3).arready,
         S_AXI_HP3_AWREADY                => axiHpSlaveFromArm(3).awready,
         S_AXI_HP3_BVALID                 => axiHpSlaveFromArm(3).bvalid,
         S_AXI_HP3_RLAST                  => axiHpSlaveFromArm(3).rlast,
         S_AXI_HP3_RVALID                 => axiHpSlaveFromArm(3).rvalid,
         S_AXI_HP3_WREADY                 => axiHpSlaveFromArm(3).wready,
         S_AXI_HP3_BID                    => axiHpSlaveFromArm(3).bid(5 downto 3),
         S_AXI_HP3_RID                    => axiHpSlaveFromArm(3).rid(5 downto 3),
         S_AXI_HP3_BRESP                  => axiHpSlaveFromArm(3).bresp,
         S_AXI_HP3_RRESP                  => axiHpSlaveFromArm(3).rresp,
         S_AXI_HP3_RDATA                  => axiHpSlaveFromArm(3).rdata,
         S_AXI_HP3_RCOUNT                 => axiHpSlaveFromArm(3).rcount,
         S_AXI_HP3_WCOUNT                 => axiHpSlaveFromArm(3).wcount,
         S_AXI_HP3_RACOUNT                => axiHpSlaveFromArm(3).racount,
         S_AXI_HP3_WACOUNT                => axiHpSlaveFromArm(3).wacount,
         S_AXI_HP3_ACLK                   => axiHpSlaveClk3,
         S_AXI_HP3_ARVALID                => axiHpSlaveToArm(3).arvalid,
         S_AXI_HP3_AWVALID                => axiHpSlaveToArm(3).awvalid,
         S_AXI_HP3_BREADY                 => axiHpSlaveToArm(3).bready,
         S_AXI_HP3_RREADY                 => axiHpSlaveToArm(3).rready,
         S_AXI_HP3_WLAST                  => axiHpSlaveToArm(3).wlast,
         S_AXI_HP3_WVALID                 => axiHpSlaveToArm(3).wvalid,
         S_AXI_HP3_RDISSUECAP3_EN         => axiHpSlaveToArm(3).rdissuecap3_en,
         S_AXI_HP3_WRISSUECAP3_EN         => axiHpSlaveToArm(3).wrissuecap3_en,
         S_AXI_HP3_ARID                   => axiHpSlaveToArm(3).arid,
         S_AXI_HP3_AWID                   => axiHpSlaveToArm(3).awid,
         S_AXI_HP3_WID                    => axiHpSlaveToArm(3).wid,
         S_AXI_HP3_ARBURST                => axiHpSlaveToArm(3).arburst,
         S_AXI_HP3_ARLOCK                 => axiHpSlaveToArm(3).arlock,
         S_AXI_HP3_ARSIZE                 => axiHpSlaveToArm(3).arsize,
         S_AXI_HP3_AWBURST                => axiHpSlaveToArm(3).awburst,
         S_AXI_HP3_AWLOCK                 => axiHpSlaveToArm(3).awlock,
         S_AXI_HP3_AWSIZE                 => axiHpSlaveToArm(3).awsize,
         S_AXI_HP3_ARPROT                 => axiHpSlaveToArm(3).arprot,
         S_AXI_HP3_AWPROT                 => axiHpSlaveToArm(3).awprot,
         S_AXI_HP3_ARADDR                 => axiHpSlaveToArm(3).araddr,
         S_AXI_HP3_AWADDR                 => axiHpSlaveToArm(3).awaddr,
         S_AXI_HP3_WDATA                  => axiHpSlaveToArm(3).wdata,
         S_AXI_HP3_ARCACHE                => axiHpSlaveToArm(3).arcache,
         S_AXI_HP3_ARLEN                  => axiHpSlaveToArm(3).arlen,
         S_AXI_HP3_ARQOS                  => axiHpSlaveToArm(3).arqos,
         S_AXI_HP3_AWCACHE                => axiHpSlaveToArm(3).awcache,
         S_AXI_HP3_AWLEN                  => axiHpSlaveToArm(3).awlen,
         S_AXI_HP3_AWQOS                  => axiHpSlaveToArm(3).awqos,
         S_AXI_HP3_WSTRB                  => axiHpSlaveToArm(3).wstrb,

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
         IRQ_F2P                          => x"0000",
         Core0_nFIQ                       => '0',
         Core0_nIRQ                       => '0',
         Core1_nFIQ                       => '0',
         Core1_nIRQ                       => '0',

         -- DMA
         DMA0_DATYPE                      => open,
         DMA0_DAVALID                     => open,
         DMA0_DRREADY                     => open,
         DMA0_RSTN                        => open,
         DMA1_DATYPE                      => open,
         DMA1_DAVALID                     => open,
         DMA1_DRREADY                     => open,
         DMA1_RSTN                        => open,
         DMA2_DATYPE                      => open,
         DMA2_DAVALID                     => open,
         DMA2_DRREADY                     => open,
         DMA2_RSTN                        => open,
         DMA3_DATYPE                      => open,
         DMA3_DAVALID                     => open,
         DMA3_DRREADY                     => open,
         DMA3_RSTN                        => open,
         DMA0_ACLK                        => '0',
         DMA0_DAREADY                     => '0',
         DMA0_DRLAST                      => '0',
         DMA0_DRVALID                     => '0',
         DMA1_ACLK                        => '0',
         DMA1_DAREADY                     => '0',
         DMA1_DRLAST                      => '0',
         DMA1_DRVALID                     => '0',
         DMA2_ACLK                        => '0',
         DMA2_DAREADY                     => '0',
         DMA2_DRLAST                      => '0',
         DMA2_DRVALID                     => '0',
         DMA3_ACLK                        => '0',
         DMA3_DAREADY                     => '0',
         DMA3_DRLAST                      => '0',
         DMA3_DRVALID,                    => '0',
         DMA0_DRTYPE                      => "00",
         DMA1_DRTYPE                      => "00",
         DMA2_DRTYPE                      => "00",
         DMA3_DRTYPE                      => "00",
     
         -- FCLK
         FCLK_CLK3                        => fclkClk3,
         FCLK_CLK2                        => fclkClk2,
         FCLK_CLK1                        => fclkClk1,
         FCLK_CLK0                        => fclkClk0,
         FCLK_CLKTRIG3_N                  => '0',
         FCLK_CLKTRIG2_N                  => '0',
         FCLK_CLKTRIG1_N                  => '0',
         FCLK_CLKTRIG0_N                  => '0',
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
         FTMT_F2P_TRIGACK                 => "0000",
         FTMT_F2P_DEBUG,                  => x"00000000",
         FTMT_P2F_TRIGACK                 => "0000",
         FTMT_P2F_TRIG                    => "0000",
         FTMT_P2F_DEBUG                   => x"00000000",

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
         PS_SRSTB                         => '0',
         PS_CLK                           => '0',
         PS_PORB                          => '0'
      );

   -- Unused AXI Master GP Signals
   --axiGpMasterToArm(1 downto 0).rcount
   --axiGpMasterToArm(1 downto 0).wcount
   --axiGpMasterToArm(1 downto 0).racount
   --axiGpMasterToArm(1 downto 0).wacount
   --axiGpMasterToArm(1 downto 0).rdata(63 downto 32)
   axiGpMasterFromArm(1 downto 0).rdissuecap1_en       <= (others=>'0');
   axiGpMasterFromArm(1 downto 0).wrissuecap1_en       <= (others=>'0');
   axiGpMasterFromArm(1 downto 0).aruser               <= (others=>"00000");
   axiGpMasterFromArm(1 downto 0).awuser               <= (others=>"00000");
   axiGpMasterFromArm(1 downto 0).wdata(63 downto 32)  <= (others=>(others=>'0'));

   -- Unused AXI Slave GP Signals
   axiGpSlaveFromArm(1 downto 0).rcount                <= (others=>(others=>'0'));
   axiGpSlaveFromArm(1 downto 0).wcount                <= (others=>(others=>'0'));
   axiGpSlaveFromArm(1 downto 0).racount               <= (others=>(others=>'0'));
   axiGpSlaveFromArm(1 downto 0).wacount               <= (others=>(others=>'0'));
   axiGpSlaveFromArm(1 downto 0).rdata(63 downto 32)   <= (others=>(others=>'0'));
   axiGpSlaveFromArm(1 downto 0).bid(11 downto 6)      <= (others=>(others=>'0'));
   axiGpSlaveFromArm(1 downto 0).rid(11 downto 6)      <= (others=>(others=>'0'));
   --axiGpSlaveToArm(1 downto 0).rdissuecap1_en
   --axiGpSlaveToArm(1 downto 0).wrissuecap1_en
   --axiGpSlaveToArm(1 downto 0).aruser
   --axiGpSlaveToArm(1 downto 0).awuser
   --axiGpSlaveToArm(1 downto 0).wdata(63 downto 32)
   --axiGpSlaveToArm(1 downto 0).arid(11 downto 6)
   --axiGpSlaveToArm(1 downto 0).awid(11 downto 6)
   --axiGpSlaveToArm(1 downto 0).wid(11 downto 6)

   -- Unused AXI ACP Signals
   axiAcpSlaveFromArm.rcount                <= (others=>(others=>'0'));
   axiAcpSlaveFromArm.wcount                <= (others=>(others=>'0'));
   axiAcpSlaveFromArm.racount               <= (others=>(others=>'0'));
   axiAcpSlaveFromArm.wacount               <= (others=>(others=>'0'));
   axiAcpSlaveFromArm.bid(11 downto 4)      <= (others=>(others=>'0'));
   axiAcpSlaveFromArm.rid(11 downto 4)      <= (others=>(others=>'0'));
   --axiAcpSlaveToArm.rdissuecap1_en
   --axiAcpSlaveToArm.wrissuecap1_en
   --axiAcpSlaveToArm.arid(11 downto 4)
   --axiAcpSlaveToArm.awid(11 downto 4)
   --axiAcpSlaveToArm.wid(11 downto 4)

   -- Unused AXI Slave HP Signals
   axiGpSlaveFromArm(3 downto 0).bid(11 downto 6)      <= (others=>(others=>'0'));
   axiGpSlaveFromArm(1 downto 0).rid(11 downto 6)      <= (others=>(others=>'0'));
   --axiGpSlaveToArm(3 downto 0).aruser
   --axiGpSlaveToArm(3 downto 0).awuser
   --axiGpSlaveToArm(3 downto 0).arid(11 downto 6)
   --axiGpSlaveToArm(3 downto 0).awid(11 downto 6)
   --axiGpSlaveToArm(3 downto 0).wid(11 downto 6)

end architecture structure;

