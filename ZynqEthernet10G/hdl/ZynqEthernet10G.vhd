-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : ZynqEthernet10G.vhd
-- Author     : Ryan Herbst <rherbst@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-09-03
-- Last update: 2016-10-20
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Wrapper file for Zynq Ethernet 10G core
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE 10G Ethernet Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE 10G Ethernet Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.EthMacPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.PpiPkg.all;
use work.RceG3Pkg.all;

entity ZynqEthernet10G is
   generic (
      -- Generic Configurations
      TPD_G              : time                  := 1 ns;
      RCE_DMA_MODE_G     : RceDmaModeType        := RCE_DMA_PPI_C;
      -- User ETH Configurations
      UDP_SERVER_EN_G    : boolean               := false;
      UDP_SERVER_SIZE_G  : positive              := 1;
      UDP_SERVER_PORTS_G : PositiveArray         := (0 => 8192);
      BYP_EN_G           : boolean               := false;
      BYP_ETH_TYPE_G     : slv(15 downto 0)      := x"AAAA";
      VLAN_EN_G          : boolean               := false;
      VLAN_SIZE_G        : positive range 1 to 8 := 1;
      VLAN_VID_G         : Slv12Array            := (0 => x"001"));   
   port (
      -- Clocks
      sysClk200            : in  sl;
      sysClk200Rst         : in  sl;
      -- PPI Interface
      dmaClk               : out sl;
      dmaClkRst            : out sl;
      dmaState             : in  RceDmaStateType;
      dmaIbMaster          : out AxiStreamMasterType;
      dmaIbSlave           : in  AxiStreamSlaveType;
      dmaObMaster          : in  AxiStreamMasterType;
      dmaObSlave           : out AxiStreamSlaveType;
      -- User ETH interface
      userEthClk           : out sl;
      userEthClkRst        : out sl;
      userEthIpAddr        : out slv(31 downto 0);
      userEthMacAddr       : out slv(47 downto 0);
      userEthUdpIbMaster   : in  AxiStreamMasterType;
      userEthUdpIbSlave    : out AxiStreamSlaveType;
      userEthUdpObMaster   : out AxiStreamMasterType;
      userEthUdpObSlave    : in  AxiStreamSlaveType;
      userEthBypIbMaster   : in  AxiStreamMasterType;
      userEthBypIbSlave    : out AxiStreamSlaveType;
      userEthBypObMaster   : out AxiStreamMasterType;
      userEthBypObSlave    : in  AxiStreamSlaveType;
      userEthVlanIbMasters : in  AxiStreamMasterArray(VLAN_SIZE_G-1 downto 0);
      userEthVlanIbSlaves  : out AxiStreamSlaveArray(VLAN_SIZE_G-1 downto 0);
      userEthVlanObMasters : out AxiStreamMasterArray(VLAN_SIZE_G-1 downto 0);
      userEthVlanObSlaves  : in  AxiStreamSlaveArray(VLAN_SIZE_G-1 downto 0);
      -- AXI-Lite Buses
      axilClk              : in  sl;
      axilClkRst           : in  sl;
      axilWriteMaster      : in  AxiLiteWriteMasterType;
      axilWriteSlave       : out AxiLiteWriteSlaveType;
      axilReadMaster       : in  AxiLiteReadMasterType;
      axilReadSlave        : out AxiLiteReadSlaveType;
      -- Ref Clock
      ethRefClkP           : in  sl;
      ethRefClkM           : in  sl;
      -- Ethernet Lines
      ethRxP               : in  slv(3 downto 0);
      ethRxM               : in  slv(3 downto 0);
      ethTxP               : out slv(3 downto 0);
      ethTxM               : out slv(3 downto 0));
end ZynqEthernet10G;

architecture mapping of ZynqEthernet10G is

   component zynq_10g_xaui
      port (
         dclk                 : in  sl;
         reset                : in  sl;
         clk156_out           : out sl;
         refclk_p             : in  sl;
         refclk_n             : in  sl;
         clk156_lock          : out sl;
         xgmii_txd            : in  slv(63 downto 0);
         xgmii_txc            : in  slv(7 downto 0);
         xgmii_rxd            : out slv(63 downto 0);
         xgmii_rxc            : out slv(7 downto 0);
         xaui_tx_l0_p         : out sl;
         xaui_tx_l0_n         : out sl;
         xaui_tx_l1_p         : out sl;
         xaui_tx_l1_n         : out sl;
         xaui_tx_l2_p         : out sl;
         xaui_tx_l2_n         : out sl;
         xaui_tx_l3_p         : out sl;
         xaui_tx_l3_n         : out sl;
         xaui_rx_l0_p         : in  sl;
         xaui_rx_l0_n         : in  sl;
         xaui_rx_l1_p         : in  sl;
         xaui_rx_l1_n         : in  sl;
         xaui_rx_l2_p         : in  sl;
         xaui_rx_l2_n         : in  sl;
         xaui_rx_l3_p         : in  sl;
         xaui_rx_l3_n         : in  sl;
         signal_detect        : in  slv(3 downto 0);
         debug                : out slv(5 downto 0);
         configuration_vector : in  slv(6 downto 0);
         status_vector        : out slv(7 downto 0));
   end component;

   type RegType is record
      sof          : sl;
      wrCnt        : slv(15 downto 0);
      rxSlave      : AxiStreamSlaveType;
      txSlave      : AxiStreamSlaveType;
      dmaIbMaster  : AxiStreamMasterType;
      ibPrimMaster : AxiStreamMasterType;
   end record RegType;
   constant REG_INIT_C : RegType := (
      sof          => '1',
      wrCnt        => (others => '0'),
      rxSlave      => AXI_STREAM_SLAVE_INIT_C,
      txSlave      => AXI_STREAM_SLAVE_INIT_C,
      dmaIbMaster  => AXI_STREAM_MASTER_INIT_C,
      ibPrimMaster => AXI_STREAM_MASTER_INIT_C);      

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal xauiRxd : slv(63 downto 0);
   signal xauiRxc : slv(7 downto 0);
   signal xauiTxd : slv(63 downto 0);
   signal xauiTxc : slv(7 downto 0);

   signal phyStatus : slv(7 downto 0);
   signal phyDebug  : slv(5 downto 0);
   signal phyConfig : slv(6 downto 0);

   signal ethClk     : sl;
   signal ethClkRst  : sl;
   signal ethClkLock : sl;
   signal phyReset   : sl;

   signal macConfig : EthMacConfigType;
   signal macStatus : EthMacStatusType;

   signal ibMacPrimMaster : AxiStreamMasterType;
   signal ibMacPrimSlave  : AxiStreamSlaveType;
   signal obMacPrimMaster : AxiStreamMasterType;
   signal obMacPrimSlave  : AxiStreamSlaveType;

   signal ibPrimMaster : AxiStreamMasterType;
   signal ibPrimSlave  : AxiStreamSlaveType;
   signal obPrimMaster : AxiStreamMasterType;
   signal obPrimSlave  : AxiStreamSlaveType;

   signal rxMaster  : AxiStreamMasterType;
   signal rxSlave   : AxiStreamSlaveType;
   signal txMaster  : AxiStreamMasterType;
   signal txSlave   : AxiStreamSlaveType;
   signal dmaMaster : AxiStreamMasterType;
   signal dmaSlave  : AxiStreamSlaveType;

   signal ethHeaderSize : slv(15 downto 0);
   signal txShift       : slv(3 downto 0);
   signal rxShift       : slv(3 downto 0);
   signal cfgPhyReset   : sl;
   signal onlineSync    : sl;

--   attribute dont_touch      : string;
--   attribute dont_touch of r : signal is "TRUE";         
   
begin

   -- Select DMA clock
   dmaClk         <= sysClk200;
   dmaClkRst      <= sysClk200Rst;
   userEthClk     <= ethClk;
   userEthClkRst  <= ethClkRst;
   userEthMacAddr <= macConfig.macAddress;

   -----------------
   -- Register Space
   -----------------
   U_Reg : entity work.ZynqEthernet10GReg
      generic map (
         TPD_G => TPD_G) 
      port map (
         axilClk         => axilClk,
         axilClkRst      => axilClkRst,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         dmaClk          => sysClk200,
         dmaClkRst       => sysClk200Rst,
         ethClk          => ethClk,
         ethClkRst       => ethClkRst,
         phyStatus       => phyStatus,
         phyDebug        => phyDebug,
         phyConfig       => phyConfig,
         phyReset        => cfgPhyReset,
         ethHeaderSize   => ethHeaderSize,
         txShift         => txShift,
         rxShift         => rxShift,
         macConfig       => macConfig,
         macStatus       => macStatus,
         ipAddr          => userEthIpAddr);

   -------
   -- XAUI
   -------
   U_ZynqXaui : zynq_10g_xaui
      port map (
         dclk                 => axilClk,
         reset                => phyReset,
         clk156_out           => ethClk,
         refclk_p             => ethRefClkP,
         refclk_n             => ethRefClkM,
         clk156_lock          => ethClkLock,
         xgmii_txd            => xauiTxd,
         xgmii_txc            => xauiTxc,
         xgmii_rxd            => xauiRxd,
         xgmii_rxc            => xauiRxc,
         xaui_tx_l0_p         => ethTxP(0),
         xaui_tx_l0_n         => ethTxM(0),
         xaui_tx_l1_p         => ethTxP(1),
         xaui_tx_l1_n         => ethTxM(1),
         xaui_tx_l2_p         => ethTxP(2),
         xaui_tx_l2_n         => ethTxM(2),
         xaui_tx_l3_p         => ethTxP(3),
         xaui_tx_l3_n         => ethTxM(3),
         xaui_rx_l0_p         => ethRxP(0),
         xaui_rx_l0_n         => ethRxM(0),
         xaui_rx_l1_p         => ethRxP(1),
         xaui_rx_l1_n         => ethRxM(1),
         xaui_rx_l2_p         => ethRxP(2),
         xaui_rx_l2_n         => ethRxM(2),
         xaui_rx_l3_p         => ethRxP(3),
         xaui_rx_l3_n         => ethRxM(3),
         signal_detect        => (others => '1'),
         debug                => phyDebug,
         configuration_vector => phyConfig,
         status_vector        => phyStatus);

   U_EthClkRst : entity work.RstSync
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '0',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 3) 
      port map (
         clk      => ethClk,
         asyncRst => ethClkLock,
         syncRst  => ethClkRst);

   onlineSync <= dmaState.online;
   phyReset   <= cfgPhyReset or not onlineSync;

   ---------------
   -- ETH MAC Core
   ---------------
   U_EthMacTop : entity work.EthMacTop
      generic map (
         -- Simulation Generics
         TPD_G               => TPD_G,
         -- MAC Configurations
         PAUSE_EN_G          => true,
         PAUSE_512BITS_G     => 8,
         PHY_TYPE_G          => "XGMII",
         DROP_ERR_PKT_G      => true,
         JUMBO_G             => true,
         -- RX FIFO Configurations
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         FIFO_ADDR_WIDTH_G   => 10,
         CASCADE_SIZE_G      => 4,
         FIFO_PAUSE_THRESH_G => 1000,
         CASCADE_PAUSE_SEL_G => 0,
         -- Non-VLAN Configurations
         FILT_EN_G           => true,
         PRIM_COMMON_CLK_G   => true,
         PRIM_CONFIG_G       => EMAC_AXIS_CONFIG_C,
         BYP_EN_G            => BYP_EN_G,
         BYP_ETH_TYPE_G      => BYP_ETH_TYPE_G,
         BYP_COMMON_CLK_G    => true,
         BYP_CONFIG_G        => EMAC_AXIS_CONFIG_C,
         -- VLAN Configurations
         VLAN_EN_G           => VLAN_EN_G,
         VLAN_SIZE_G         => VLAN_SIZE_G,
         VLAN_VID_G          => VLAN_VID_G,
         VLAN_COMMON_CLK_G   => true,
         VLAN_CONFIG_G       => EMAC_AXIS_CONFIG_C)           
      port map (
         -- Core Clock and Reset
         ethClk           => ethClk,
         ethRst           => ethClkRst,
         -- Primary Interface
         primClk          => ethClk,
         primRst          => ethClkRst,
         ibMacPrimMaster  => ibMacPrimMaster,
         ibMacPrimSlave   => ibMacPrimSlave,
         obMacPrimMaster  => obMacPrimMaster,
         obMacPrimSlave   => obMacPrimSlave,
         -- Bypass interface
         bypClk           => ethClk,
         bypRst           => ethClkRst,
         ibMacBypMaster   => userEthBypIbMaster,
         ibMacBypSlave    => userEthBypIbSlave,
         obMacBypMaster   => userEthBypObMaster,
         obMacBypSlave    => userEthBypObSlave,
         -- VLAN Interfaces
         vlanClk          => ethClk,
         vlanRst          => ethClkRst,
         ibMacVlanMasters => userEthVlanIbMasters,
         ibMacVlanSlaves  => userEthVlanIbSlaves,
         obMacVlanMasters => userEthVlanObMasters,
         obMacVlanSlaves  => userEthVlanObSlaves,
         -- XGMII PHY Interface
         xgmiiRxd         => xauiRxd,
         xgmiiRxc         => xauiRxc,
         xgmiiTxd         => xauiTxd,
         xgmiiTxc         => xauiTxc,
         -- Configuration and status
         phyReady         => phyStatus(7),
         ethConfig        => macConfig,
         ethStatus        => macStatus);     

   ------------------
   -- ETH USER Router
   ------------------
   U_ZynqUserEthRouter : entity work.ZynqUserEthRouter
      generic map (
         TPD_G              => TPD_G,
         UDP_SERVER_EN_G    => UDP_SERVER_EN_G,
         UDP_SERVER_SIZE_G  => UDP_SERVER_SIZE_G,
         UDP_SERVER_PORTS_G => UDP_SERVER_PORTS_G)
      port map (
         -- MAC Interface (ethClk domain)
         ethClk          => ethClk,
         ethRst          => ethClkRst,
         ibMacPrimMaster => ibMacPrimMaster,
         ibMacPrimSlave  => ibMacPrimSlave,
         obMacPrimMaster => obMacPrimMaster,
         obMacPrimSlave  => obMacPrimSlave,
         -- User ETH Interface (ethClk domain)
         ethUdpObMaster  => userEthUdpObMaster,
         ethUdpObSlave   => userEthUdpObSlave,
         ethUdpIbMaster  => userEthUdpIbMaster,
         ethUdpIbSlave   => userEthUdpIbSlave,
         -- CPU Interface (axisClk domain)
         axisClk         => sysClk200,
         axisRst         => sysClk200Rst,
         ibPrimMaster    => ibPrimMaster,
         ibPrimSlave     => ibPrimSlave,
         obPrimMaster    => obPrimMaster,
         obPrimSlave     => obPrimSlave);

   BYPASS_SHIFT : if (RCE_DMA_MODE_G /= RCE_DMA_PPI_C) generate
      dmaIbMaster  <= obPrimMaster;
      obPrimSlave  <= dmaIbSlave;
      ibPrimMaster <= dmaObMaster;
      dmaObSlave   <= ibPrimSlave;
   end generate;

   GEN_SHIFT : if (RCE_DMA_MODE_G = RCE_DMA_PPI_C) generate

      -------------------------------------------------
      -- Shift inbound data n bytes to the left.
      -- This adds bytes of data at start of the packet
      -------------------------------------------------
      U_RxShift : entity work.AxiStreamShift
         generic map (
            TPD_G          => TPD_G,
            PIPE_STAGES_G  => 1,
            AXIS_CONFIG_G  => RCEG3_AXIS_DMA_CONFIG_C,
            ADD_VALID_EN_G => true) 
         port map (
            axisClk     => sysClk200,
            axisRst     => sysClk200Rst,
            axiStart    => '1',
            axiShiftDir => '0',         -- 0 = left (lsb to msb)
            axiShiftCnt => rxShift,
            sAxisMaster => obPrimMaster,
            sAxisSlave  => obPrimSlave,
            mAxisMaster => rxMaster,
            mAxisSlave  => rxSlave);         

      ----------------------------------------------
      -- Shift outbound data n bytes to the right.
      -- This removes bytes of data at start 
      -- of the packet. These were added by software
      -- to create a software friendly alignment of 
      -- outbound data.
      ----------------------------------------------
      U_TxShift : entity work.AxiStreamShift
         generic map (
            TPD_G         => TPD_G,
            PIPE_STAGES_G => 1,
            AXIS_CONFIG_G => PPI_AXIS_CONFIG_INIT_C) 
         port map (
            axisClk     => sysClk200,
            axisRst     => sysClk200Rst,
            axiStart    => '1',
            axiShiftDir => '1',         -- 1 = right (msb to lsb)
            axiShiftCnt => txShift,
            sAxisMaster => dmaObMaster,
            sAxisSlave  => dmaObSlave,
            mAxisMaster => txMaster,
            mAxisSlave  => txSlave);   

      --------------
      -- PPI support
      --------------
      comb : process (dmaIbSlave, ethHeaderSize, ibPrimSlave, r, rxMaster, sysClk200Rst, txMaster) is
         variable v    : RegType;
         variable eofe : sl;
      begin
         -- Latch the current value
         v := r;

         -- Reset the flags
         v.txSlave := AXI_STREAM_SLAVE_INIT_C;
         v.rxSlave := AXI_STREAM_SLAVE_INIT_C;
         if dmaIbSlave.tReady = '1' then
            v.dmaIbMaster.tValid := '0';
         end if;
         if ibPrimSlave.tReady = '1' then
            v.ibPrimMaster.tValid := '0';
         end if;

         -- Check for RX data and ready to move
         if (rxMaster.tValid = '1') and (v.dmaIbMaster.tValid = '0') then
            -- Accept the data
            v.rxSlave.tReady := '1';
            -- Move the data
            v.dmaIbMaster    := rxMaster;
            -- Increment the counter
            v.wrCnt          := r.wrCnt + 1;
            -- Check for EOF
            if (rxMaster.tLast = '1') then
               -- Reset the counter
               v.wrCnt := (others => '0');
            end if;
            -- Get EOFE bit
            eofe                := axiStreamGetUserBit(RCEG3_AXIS_DMA_CONFIG_C, rxMaster, EMAC_EOFE_BIT_C);
            -- Reset tUser field
            v.dmaIbMaster.tUser := (others => '0');
            -- Set EOH if necessary
            if (r.wrCnt = ethHeaderSize) then
               axiStreamSetUserBit(PPI_AXIS_CONFIG_INIT_C, v.dmaIbMaster, PPI_EOH_C, '1');
            end if;
            -- Update ERR bit with EOFE
            if (rxMaster.tLast = '1') then
               axiStreamSetUserBit(PPI_AXIS_CONFIG_INIT_C, v.dmaIbMaster, PPI_ERR_C, eofe);
            end if;
         end if;

         -- Check for TX data and ready to move
         if (txMaster.tValid = '1') and (v.ibPrimMaster.tValid = '0') then
            -- Accept the data
            v.txSlave.tReady     := '1';
            -- Move the data
            v.ibPrimMaster       := txMaster;
            -- Get PPI_ERR bit
            eofe                 := axiStreamGetUserBit(PPI_AXIS_CONFIG_INIT_C, txMaster, PPI_ERR_C);
            -- Reset tUser field
            v.ibPrimMaster.tUser := (others => '0');
            -- Check for SOF
            if r.sof = '1' then
               -- Reset the flag
               v.sof := '0';
               -- Insert the EMAC_SOF_BIT_C bit after the AxiStreamShift
               axiStreamSetUserBit(RCEG3_AXIS_DMA_CONFIG_C, v.ibPrimMaster, EMAC_SOF_BIT_C, '1', 0);
            end if;
            -- Check for EOF
            if (txMaster.tLast = '1') then
               -- Set the flag
               v.sof := '1';
               -- Insert the EMAC_EOFE_BIT_C bit
               axiStreamSetUserBit(RCEG3_AXIS_DMA_CONFIG_C, v.ibPrimMaster, EMAC_EOFE_BIT_C, eofe);
            end if;
         end if;

         -- Reset
         if (sysClk200Rst = '1') then
            v := REG_INIT_C;
         end if;

         -- Register the variable for next clock cycle
         rin <= v;

         -- Outputs        
         rxSlave      <= v.rxSlave;
         txSlave      <= v.txSlave;
         dmaIbMaster  <= r.dmaIbMaster;
         ibPrimMaster <= r.ibPrimMaster;
         
      end process comb;

      seq : process (sysClk200) is
      begin
         if rising_edge(sysClk200) then
            r <= rin after TPD_G;
         end if;
      end process seq;
      
   end generate;
   
end architecture mapping;
