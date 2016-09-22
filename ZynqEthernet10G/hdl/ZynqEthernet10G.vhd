-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : ZynqEthernet10G.vhd
-- Author     : Ryan Herbst <rherbst@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-09-03
-- Last update: 2016-09-22
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
      TPD_G           : time             := 1 ns;
      RCE_DMA_MODE_G  : RceDmaModeType   := RCE_DMA_PPI_C;
      USER_ETH_EN_G   : boolean          := false;
      USER_ETH_TYPE_G : slv(15 downto 0) := x"0000");
   port (
      -- Clocks
      sysClk200       : in  sl;
      sysClk200Rst    : in  sl;
      -- PPI Interface
      dmaClk          : out sl;
      dmaClkRst       : out sl;
      dmaState        : in  RceDmaStateType;
      dmaIbMaster     : out AxiStreamMasterType;
      dmaIbSlave      : in  AxiStreamSlaveType;
      dmaObMaster     : in  AxiStreamMasterType;
      dmaObSlave      : out AxiStreamSlaveType;
      -- User interface
      userEthClk      : in  sl;
      userEthClkRst   : in  sl;
      userEthObMaster : in  AxiStreamMasterType;
      userEthObSlave  : out AxiStreamSlaveType;
      userEthIbMaster : out AxiStreamMasterType;
      userEthIbSlave  : in  AxiStreamSlaveType;
      -- AXI-Lite Buses
      axilClk         : in  sl;
      axilClkRst      : in  sl;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      -- Ref Clock
      ethRefClkP      : in  sl;
      ethRefClkM      : in  sl;
      -- Ethernet Lines
      ethRxP          : in  slv(3 downto 0);
      ethRxM          : in  slv(3 downto 0);
      ethTxP          : out slv(3 downto 0);
      ethTxM          : out slv(3 downto 0));
end ZynqEthernet10G;

architecture structure of ZynqEthernet10G is

   constant HEADER_SIZE_C : positive := 16;
   constant AXIS_CONFIG_C : AxiStreamConfigType := ite((RCE_DMA_MODE_G = RCE_DMA_PPI_C),
                                                       PPI_AXIS_CONFIG_INIT_C,
                                                       RCEG3_AXIS_DMA_CONFIG_C);
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
      wrCnt    : natural range 0 to HEADER_SIZE_C;
      rxSlave  : AxiStreamSlaveType;
      ibMaster : AxiStreamMasterType;
   end record RegType;
   constant REG_INIT_C : RegType := (
      wrCnt    => 0,
      rxSlave  => AXI_STREAM_SLAVE_INIT_C,
      ibMaster => AXI_STREAM_MASTER_INIT_C);      

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

   signal rxMaster : AxiStreamMasterType;
   signal rxSlave  : AxiStreamSlaveType;
   signal ibSlave  : AxiStreamSlaveType;

   signal writeCount    : slv(15 downto 0);
   signal ethHeaderSize : slv(15 downto 0);
   signal cfgPhyReset   : sl;
   signal onlineSync    : sl;

--   attribute dont_touch      : string;
--   attribute dont_touch of r : signal is "TRUE";         
   
begin

   -- Select DMA clock
   dmaClk    <= sysClk200;
   dmaClkRst <= sysClk200Rst;

   -------------------------------------------
   -- Register Space
   -------------------------------------------
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
         ethClk          => ethClk,
         ethClkRst       => ethClkRst,
         phyStatus       => phyStatus,
         phyDebug        => phyDebug,
         phyReset        => cfgPhyReset,
         phyConfig       => phyConfig,
         ethHeaderSize   => ethHeaderSize,
         macConfig       => macConfig,
         macStatus       => macStatus);


   -------------------------------------------
   -- XAUI
   -------------------------------------------
   --U_OnlineSync: entity work.Synchronizer 
   --   generic map (
   --      TPD_G  => TPD_G
   --   ) port map (
   --      clk     => ethClk,
   --      rst     => ethClkRst,
   --      dataIn  => dmaState.online,
   --      dataOut => onlineSync
   --   );
   onlineSync <= dmaState.online;

   phyReset <= cfgPhyReset or not onlineSync;

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

   -- Status Vector 0x20
   -- 0   = Tx Local Fault
   -- 1   = Rx Local Fault
   -- 5:2 = Sync Status
   -- 6   = Alignment
   -- 7   = Rx Link Status

   -- Config Vector 0x8
   -- 0   = Loopback
   -- 1   = Power Down
   -- 2   = Reset Local Fault
   -- 3   = Reset Rx Link Status
   -- 4   = Test Enable
   -- 6:5 = Test Pattern

   -- Debug  Vector 0x24
   -- 5   = Align Status
   -- 4:1 = Sync Status
   -- 0   = TX Phase Complete

   -- Generate reset for eth clock
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

   -------------------------------------------
   -- Eth MAC
   -------------------------------------------
   U_EthMacTop : entity work.EthMacTop
      generic map (
         -- Simulation Generics
         TPD_G             => TPD_G,
         -- MAC Configurations
         PAUSE_EN_G        => true,
         PAUSE_512BITS_G   => 8,
         PHY_TYPE_G        => "XGMII",
         DROP_ERR_PKT_G    => true,
         JUMBO_G           => true,
         -- Non-VLAN Configurations
         SHIFT_EN_G        => true,
         FILT_EN_G         => true,
         PRIM_COMMON_CLK_G => false,
         PRIM_CONFIG_G     => AXIS_CONFIG_C,
         BYP_EN_G          => USER_ETH_EN_G,
         BYP_ETH_TYPE_G    => USER_ETH_TYPE_G,
         BYP_COMMON_CLK_G  => false,
         BYP_CONFIG_G      => AXIS_CONFIG_C,
         -- VLAN Configurations
         VLAN_EN_G         => false,
         VLAN_CNT_G        => 1,
         VLAN_COMMON_CLK_G => false,
         VLAN_CONFIG_G     => AXIS_CONFIG_C)           
      port map (
         -- Core Clock and Reset
         ethClk          => ethClk,
         ethRst          => ethClkRst,
         -- Primary Interface
         primClk         => sysClk200,
         primRst         => sysClk200Rst,
         ibMacPrimMaster => dmaObMaster,
         ibMacPrimSlave  => dmaObSlave,
         obMacPrimMaster => rxMaster,
         obMacPrimSlave  => rxSlave,
         -- Bypass interface
         bypClk          => userEthClk,
         bypRst          => userEthClkRst,
         ibMacBypMaster  => userEthObMaster,
         ibMacBypSlave   => userEthObSlave,
         obMacBypMaster  => userEthIbMaster,
         obMacBypSlave   => userEthIbSlave,
         -- XGMII PHY Interface
         xgmiiRxd        => xauiRxd,
         xgmiiRxc        => xauiRxc,
         xgmiiTxd        => xauiTxd,
         xgmiiTxc        => xauiTxc,
         -- Configuration and status
         phyReady        => phyStatus(7),
         ethConfig       => macConfig,
         ethStatus       => macStatus);

   --------------
   -- PPI support
   --------------
   comb : process (ibSlave, r, rxMaster, sysClk200Rst) is
      variable v    : RegType;
      variable eofe : sl;
   begin
      -- Latch the current value
      v := r;

      -- Reset the flags
      v.rxSlave := AXI_STREAM_SLAVE_INIT_C;
      if ibSlave.tReady = '1' then
         v.ibMaster.tValid := '0';
      end if;

      -- Check for data and ready to move
      if (rxMaster.tValid = '1') and (v.ibMaster.tValid = '0') then
         -- Accept the data
         v.rxSlave.tReady := '1';
         -- Move the data
         v.ibMaster       := rxMaster;
         -- Increment the counter
         if (r.wrCnt /= HEADER_SIZE_C) then
            v.wrCnt := r.wrCnt + 1;
         end if;
         -- Check for EOF
         if (rxMaster.tLast = '1') then
            -- Reset the counter
            v.wrCnt := 0;
         end if;
         -- Get EOFE bit
         eofe := axiStreamGetUserBit(AXIS_CONFIG_C, rxMaster, EMAC_EOFE_BIT_C);
         -- Check for PPI interface
         if (RCE_DMA_MODE_G = RCE_DMA_PPI_C) then
            -- Reset tUser field
            v.ibMaster.tUser := (others => '0');
            -- Set EOH if necessary
            if (r.wrCnt = (HEADER_SIZE_C-1)) then
               axiStreamSetUserBit(AXIS_CONFIG_C, v.ibMaster, PPI_EOH_C, '1');
            end if;
            -- Update ERR bit with EOFE
            if (rxMaster.tLast = '1') then
               axiStreamSetUserBit(AXIS_CONFIG_C, v.ibMaster, PPI_ERR_C, eofe);
            end if;
         end if;
      end if;

      -- Reset
      if (sysClk200Rst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs        
      rxSlave <= v.rxSlave;
      
   end process comb;

   seq : process (sysClk200) is
   begin
      if rising_edge(sysClk200) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   U_Pipeline : entity work.AxiStreamPipeline
      generic map (
         TPD_G         => TPD_G,
         PIPE_STAGES_G => 1)
      port map (
         axisClk     => sysClk200,
         axisRst     => sysClk200Rst,
         sAxisMaster => r.ibMaster,
         sAxisSlave  => ibSlave,
         mAxisMaster => dmaIbMaster,
         mAxisSlave  => dmaIbSlave);        

end architecture structure;
