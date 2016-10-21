-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : ZynqUserEthRouter.vhd
-- Author     : Larry Ruckman  <ruckman@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2016-10-18
-- Last update: 2016-10-21
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
use work.AxiStreamPkg.all;
use work.RceG3Pkg.all;

entity ZynqUserEthRouter is
   generic (
      -- Generic Configurations
      TPD_G              : time          := 1 ns;
      UDP_SERVER_EN_G    : boolean       := false;
      UDP_SERVER_SIZE_G  : positive      := 1;
      UDP_SERVER_PORTS_G : PositiveArray := (0 => 8192));      
   port (
      -- MAC Interface (ethClk domain)
      ethClk          : in  sl;
      ethRst          : in  sl;
      ibMacPrimMaster : out AxiStreamMasterType;
      ibMacPrimSlave  : in  AxiStreamSlaveType;
      obMacPrimMaster : in  AxiStreamMasterType;
      obMacPrimSlave  : out AxiStreamSlaveType;
      -- User ETH Interface (ethClk domain)
      ethUdpIbMaster  : in  AxiStreamMasterType;
      ethUdpIbSlave   : out AxiStreamSlaveType;
      ethUdpObMaster  : out AxiStreamMasterType;
      ethUdpObSlave   : in  AxiStreamSlaveType;
      -- CPU Interface (axisClk domain)
      axisClk         : in  sl;
      axisRst         : in  sl;
      ibPrimMaster    : in  AxiStreamMasterType;
      ibPrimSlave     : out AxiStreamSlaveType;
      obPrimMaster    : out AxiStreamMasterType;
      obPrimSlave     : in  AxiStreamSlaveType); 
end ZynqUserEthRouter;

architecture rtl of ZynqUserEthRouter is
   
   type StateType is (
      IDLE_S,
      PRIM_S,
      USER_S);      

   type RegType is record
      cnt            : natural range 0 to 3;
      tData          : Slv128Array(2 downto 0);
      txMaster       : AxiStreamMasterType;
      ethUdpObMaster : AxiStreamMasterType;
      obMacPrimSlave : AxiStreamSlaveType;
      state          : StateType;
   end record RegType;
   constant REG_INIT_C : RegType := (
      cnt            => 0,
      tData          => (others => (others => '0')),
      txMaster       => AXI_STREAM_MASTER_INIT_C,
      ethUdpObMaster => AXI_STREAM_MASTER_INIT_C,
      obMacPrimSlave => AXI_STREAM_SLAVE_INIT_C,
      state          => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal rxMaster : AxiStreamMasterType;
   signal rxSlave  : AxiStreamSlaveType;
   signal txMaster : AxiStreamMasterType;
   signal txSlave  : AxiStreamSlaveType;

--   attribute dont_touch      : string;
--   attribute dont_touch of r : signal is "TRUE";         
   
begin

   U_RxFifo : entity work.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 0,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => 1,
         -- FIFO configurations
         BRAM_EN_G           => false,
         GEN_SYNC_FIFO_G     => false,
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 4,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => RCEG3_AXIS_DMA_CONFIG_C,
         MASTER_AXI_CONFIG_G => EMAC_AXIS_CONFIG_C)        
      port map (
         sAxisClk    => axisClk,
         sAxisRst    => axisRst,
         sAxisMaster => ibPrimMaster,
         sAxisSlave  => ibPrimSlave,
         mAxisClk    => ethClk,
         mAxisRst    => ethRst,
         mAxisMaster => rxMaster,
         mAxisSlave  => rxSlave); 

   U_TxFifo : entity work.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 0,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => 1,
         -- FIFO configurations
         BRAM_EN_G           => false,
         GEN_SYNC_FIFO_G     => false,
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 4,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => EMAC_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => RCEG3_AXIS_DMA_CONFIG_C)        
      port map (
         sAxisClk    => ethClk,
         sAxisRst    => ethRst,
         sAxisMaster => txMaster,
         sAxisSlave  => txSlave,
         mAxisClk    => axisClk,
         mAxisRst    => axisRst,
         mAxisMaster => obPrimMaster,
         mAxisSlave  => obPrimSlave);          

   BYPASS_USER_MUX : if (UDP_SERVER_EN_G = false) generate
      ibMacPrimMaster <= rxMaster;
      rxSlave         <= ibMacPrimSlave;
      txMaster        <= obMacPrimMaster;
      obMacPrimSlave  <= txSlave;
      ethUdpObMaster  <= AXI_STREAM_MASTER_INIT_C;
      ethUdpIbSlave   <= AXI_STREAM_SLAVE_FORCE_C;
   end generate;

   GEN_USER_MUX : if (UDP_SERVER_EN_G = true) generate
      
      U_AxiStreamMux : entity work.AxiStreamMux
         generic map (
            TPD_G        => TPD_G,
            NUM_SLAVES_G => 2)
         port map (
            -- Clock and reset
            axisClk         => ethClk,
            axisRst         => ethRst,
            -- Slaves
            sAxisMasters(0) => rxMaster,
            sAxisMasters(1) => ethUdpIbMaster,
            sAxisSlaves(0)  => rxSlave,
            sAxisSlaves(1)  => ethUdpIbSlave,
            -- Master
            mAxisMaster     => ibMacPrimMaster,
            mAxisSlave      => ibMacPrimSlave);    

      comb : process (ethRst, ethUdpObSlave, obMacPrimMaster, r, txSlave) is
         variable v          : RegType;
         variable i          : natural;
         variable ipv4       : boolean;
         variable udpType    : boolean;
         variable udpPort    : boolean;
         variable userEthDet : boolean;
         variable udpNum     : slv(15 downto 0);
      begin
         -- Latch the current value
         v := r;

         -- Reset the flags
         v.obMacPrimSlave := AXI_STREAM_SLAVE_INIT_C;
         if (txSlave.tReady = '1') then
            v.txMaster.tValid := '0';
            v.txMaster.tLast  := '0';
            v.txMaster.tUser  := (others => '0');
            v.txMaster.tKeep  := (others => '1');
         end if;
         if (ethUdpObSlave.tReady = '1') then
            v.ethUdpObMaster.tValid := '0';
            v.ethUdpObMaster.tLast  := '0';
            v.ethUdpObMaster.tUser  := (others => '0');
            v.ethUdpObMaster.tKeep  := (others => '1');
         end if;

         -------------------------------------------------------------------------------------------------------
         -- IPv4/EtherType/UDP data fields:
         -- https://docs.google.com/spreadsheets/d/1_1M1keasfq8RLmRYHkO0IlRhMq5YZTgJ7OGrWvkib8I/edit?usp=sharing
         -------------------------------------------------------------------------------------------------------

         -- Check for IPv4 EtherType
         if (r.tData(0)(111 downto 96) = IPV4_TYPE_C) then
            ipv4 := true;
         else
            ipv4 := false;
         end if;

         -- Check for UDP Protocol
         if (r.tData(1)(63 downto 56) = UDP_C) then
            udpType := true;
         else
            udpType := false;
         end if;

         -- Convert to little endianness 
         udpNum(15 downto 8) := obMacPrimMaster.tData(39 downto 32);
         udpNum(7 downto 0)  := obMacPrimMaster.tData(47 downto 40);

         -- Check if matches one of the User's UDP ports
         udpPort := false;
         for i in (UDP_SERVER_SIZE_G-1) downto 0 loop
            if (udpNum = UDP_SERVER_PORTS_G(i)) then
               udpPort := true;
            end if;
         end loop;

         -- Check if outbound Ethernet frame is a user Ethernet frame
         if (ipv4 = true) and (udpType = true) and (udpPort = true) then
            userEthDet := true;
         else
            userEthDet := false;
         end if;

         -- State Machine
         case r.state is
            ----------------------------------------------------------------------
            when IDLE_S =>
               -- Check for data
               if (obMacPrimMaster.tValid = '1') then
                  -- Accept the data
                  v.obMacPrimSlave.tReady := '1';
                  -- Check for EOF
                  if (obMacPrimMaster.tLast = '1') then
                     -- Reset the counter
                     v.cnt := 0;
                  else
                     -- Save the data
                     v.tData(r.cnt) := obMacPrimMaster.tData;
                     -- Check the counter
                     if (r.cnt = 2) then
                        -- Reset the counter
                        v.cnt := 0;
                        -- Check for CPU ETH data
                        if (userEthDet = false) then
                           -- Next state
                           v.state := PRIM_S;
                        else
                           -- Next state
                           v.state := USER_S;
                        end if;
                     else
                        -- Increment the counter
                        v.cnt := r.cnt + 1;
                     end if;
                  end if;
               end if;
            ----------------------------------------------------------------------
            when PRIM_S =>
               -- Check if moving data
               if (obMacPrimMaster.tValid = '1') and (v.txMaster.tValid = '0') then
                  -- Check if moving cached data
                  if (r.cnt < 3) then
                     -- Move the data
                     v.txMaster.tValid := '1';
                     v.txMaster.tData  := r.tData(r.cnt);
                     -- Check for SOF
                     if (r.cnt = 0) then
                        axiStreamSetUserBit(EMAC_AXIS_CONFIG_C, v.txMaster, EMAC_SOF_BIT_C, '1', 0);
                     end if;
                     -- Increment the counter
                     v.cnt := r.cnt + 1;
                  else
                     -- Accept the data
                     v.obMacPrimSlave.tReady := '1';
                     -- Move the data
                     v.txMaster              := obMacPrimMaster;
                     -- Check for EOF
                     if (obMacPrimMaster.tLast = '1') then
                        -- Reset the counter
                        v.cnt   := 0;
                        -- Next state
                        v.state := IDLE_S;
                     end if;
                  end if;
               end if;
            ----------------------------------------------------------------------
            when USER_S =>
               -- Check if moving data
               if (obMacPrimMaster.tValid = '1') and (v.ethUdpObMaster.tValid = '0') then
                  -- Check if moving cached data
                  if (r.cnt < 3) then
                     -- Move the data
                     v.ethUdpObMaster.tValid := '1';
                     v.ethUdpObMaster.tData  := r.tData(r.cnt);
                     -- Check for SOF
                     if (r.cnt = 0) then
                        axiStreamSetUserBit(EMAC_AXIS_CONFIG_C, v.ethUdpObMaster, EMAC_SOF_BIT_C, '1', 0);
                     end if;
                     -- Increment the counter
                     v.cnt := r.cnt + 1;
                  else
                     -- Accept the data
                     v.obMacPrimSlave.tReady := '1';
                     -- Move the data
                     v.ethUdpObMaster        := obMacPrimMaster;
                     -- Check for EOF
                     if (obMacPrimMaster.tLast = '1') then
                        -- Reset the counter
                        v.cnt   := 0;
                        -- Next state
                        v.state := IDLE_S;
                     end if;
                  end if;
               end if;
         ----------------------------------------------------------------------
         end case;

         -- Reset
         if (ethRst = '1') then
            v := REG_INIT_C;
         end if;

         -- Register the variable for next clock cycle
         rin <= v;

         -- Outputs       
         obMacPrimSlave <= v.obMacPrimSlave;
         txMaster       <= r.txMaster;
         ethUdpObMaster <= r.ethUdpObMaster;
         
      end process comb;

      seq : process (ethClk) is
      begin
         if rising_edge(ethClk) then
            r <= rin after TPD_G;
         end if;
      end process seq;
      
   end generate;
   
end architecture rtl;
