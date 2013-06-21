-------------------------------------------------------------------------------
-- Title         : Zynq PCIE Express Core
-- File          : ZynqPcieMaster.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Wrapper file for Zynq PCI Express core.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;

entity ZynqPcieMaster is
   port (

      -- Local Bus
      axiClk                  : in  std_logic;
      axiClkRst               : in  std_logic;
      localBusMaster          : in  LocalBusMasterType;
      localBusSlave           : out LocalBusSlaveType;

      -- Master clock and reset
      pciRefClk               : in  std_logic;
      ponReset                : in  std_logic;

      -- Reset output
      pcieResetL              : out std_logic;

      -- PCIE Lines
      pcieRxP                 : in  std_logic;
      pcieRxM                 : in  std_logic;
      pcieTxP                 : out std_logic;
      pcieTxM                 : out std_logic
   );
end ZynqPcieMaster;

architecture structure of ZynqPcieMaster is

   COMPONENT PcieFifo
      PORT (
         rst    : IN  STD_LOGIC;
         wr_clk : IN  STD_LOGIC;
         rd_clk : IN  STD_LOGIC;
         din    : IN  STD_LOGIC_VECTOR(94 DOWNTO 0);
         wr_en  : IN  STD_LOGIC;
         rd_en  : IN  STD_LOGIC;
         dout   : OUT STD_LOGIC_VECTOR(94 DOWNTO 0);
         full   : OUT STD_LOGIC;
         empty  : OUT STD_LOGIC;
         valid  : OUT STD_LOGIC
      );
   END COMPONENT;

   -- Local signals
   signal intLocalBusSlave       : LocalBusSlaveType;
   signal wrFifoDin              : std_logic_vector(94 downto 0);
   signal wrFifoDout             : std_logic_vector(94 downto 0);
   signal wrFifoWrEn             : std_logic;
   signal wrFifoRdEn             : std_logic;
   signal wrFifoValid            : std_logic;
   signal rdFifoDin              : std_logic_vector(94 downto 0);
   signal rdFifoDout             : std_logic_vector(94 downto 0);
   signal rdFifoWrEn             : std_logic;
   signal rdFifoRdEn             : std_logic;
   signal rdFifoFull             : std_logic;
   signal rdFifoValid            : std_logic;
   signal pciClk                 : std_logic;
   signal pciClkRst              : std_logic;
   signal txBufAv                : std_logic_vector(5 downto 0);
   signal txReady                : std_logic;
   signal txValid                : std_logic;
   signal rxReady                : std_logic;
   signal rxValid                : std_logic;
   signal linkUp                 : std_logic;
   signal cfgDout                : std_logic_vector(31 downto 0);
   signal cfgDin                 : std_logic_vector(31 downto 0);
   signal cfgAddr                : std_logic_vector(9  downto 0);
   signal cfgWrEn                : std_logic;
   signal cfgRdEn                : std_logic;
   signal cfgRdWrDone            : std_logic;
   signal cfgStatus              : std_logic_vector(15 downto 0);
   signal cfgCommand             : std_logic_vector(15 downto 0);
   signal cfgDStatus             : std_logic_vector(15 downto 0);
   signal cfgDCommand            : std_logic_vector(15 downto 0);
   signal cfgDCommand2           : std_logic_vector(15 downto 0);
   signal cfgLStatus             : std_logic_vector(15 downto 0);
   signal cfgLCommand            : std_logic_vector(15 downto 0);
   signal cfgPcieLinkState       : std_logic_vector(2  downto 0);
   signal cfgPmcsrPmeEn          : std_logic;
   signal cfgPmcsrPowerstate     : std_logic_vector(1  downto 0);
   signal cfgPmcsrPmeStatus      : std_logic;
   signal cfgReceivedFuncLvlRst  : std_logic;
   signal cfgBusNumber           : std_logic_vector(7  downto 0);
   signal cfgDeviceNumber        : std_logic_vector(4  downto 0);
   signal cfgFunctionNumber      : std_logic_vector(2  downto 0);
   signal phyLinkUp              : std_logic;
   signal pciExpTxP              : std_logic_vector(0  downto 0);
   signal pciExpTxN              : std_logic_vector(0  downto 0);
   signal pciExpRxP              : std_logic_vector(0  downto 0);
   signal pciExpRxN              : std_logic_vector(0  downto 0);
   signal intResetL              : std_logic;
   signal remResetL              : std_logic;
   signal pcieEnable             : std_logic;
   signal debugCount             : std_logic_vector(15 downto 0);

begin

   -- Outputs
   localBusSlave <= intLocalBusSlave;
   --pcieResetL    <= '0' when intResetL = '0' else 'Z';
   pcieResetL    <= intResetL and remResetL;
   intResetL     <= (not ponReset) and pcieEnable;

   --------------------------------------------
   -- Registers: 0xBC00_0000 - 0xBFFF_FFFF
   --------------------------------------------
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         intLocalBusSlave <= LocalBusSlaveInit       after TPD_G;
         wrFifoDin         <= (others=>'0')          after TPD_G;
         wrFifoWrEn        <= '0'                    after TPD_G;
         rdFifoRdEn        <= '0'                    after TPD_G;
         cfgDin            <= (others=>'0')          after TPD_G;
         cfgAddr           <= (others=>'0')          after TPD_G;
         cfgWrEn           <= '0'                    after TPD_G;
         cfgRdEn           <= '0'                    after TPD_G;
         cfgBusNumber      <= (others=>'0')          after TPD_G;
         cfgDeviceNumber   <= (others=>'0')          after TPD_G;
         cfgFunctionNumber <= (others=>'0')          after TPD_G;
         pcieEnable        <= '0'                    after TPD_G;
         remResetL         <= '0'                    after TPD_G;
      elsif rising_edge(axiClk) then
         intLocalBusSlave.readValid <= localBusMaster.readEnable after TPD_G;
         intLocalBusSlave.readData  <= x"deadbeef"               after TPD_G;
         wrFifoWrEn                 <= '0'                       after TPD_G;
         rdFifoRdEn                 <= '0'                       after TPD_G;

         -- Config read or write is done
         if cfgRdWrDone = '1' then
            cfgWrEn <= '0' after TPD_G;
            cfgRdEn <= '0' after TPD_G;
         end if;

         -- PCIE Configuration Port, 0xBC000000 - 0xBC000FFF
         if localBusMaster.addr(23 downto 12) = x"000" then

            -- Write cycle
            if localBusMaster.writeEnable = '1' then
               cfgAddr <= localBusMaster.addr(11 downto 2) after TPD_G;
               cfgDin  <= localBusMaster.writeData         after TPD_G;
               cfgWrEn <= '1'                              after TPD_G;
            end if;

            -- Read cycle
            if localBusMaster.readEnable = '1' then
               cfgAddr <= localBusMaster.addr(11 downto 2) after TPD_G;
               cfgRdEn <= '1'                              after TPD_G;
            end if;

            -- Wait for read to complete
            intLocalBusSlave.readValid <= cfgRdWrDone after TPD_G;
            intLocalBusSlave.readData  <= cfgDout     after TPD_G;

         -- Write FIFO QWord0, - 0xBC001000
         elsif localBusMaster.addr(23 downto 0) = x"001000" then
            if localBusMaster.writeEnable = '1' then
               wrFifoDin(31 downto  0)   <= localBusMaster.writeData after TPD_G;
            end if;

         -- Write FIFO QWord1, - 0xBC001004
         elsif localBusMaster.addr(23 downto 4) = x"001004" then
            if localBusMaster.writeEnable = '1' then
               wrFifoDin(63 downto 32)   <= localBusMaster.writeData after TPD_G;
            end if;

         -- Write FIFO QWord2, - 0xBC001008
         elsif localBusMaster.addr(23 downto 4) = x"001008" then
            if localBusMaster.writeEnable = '1' then
               wrFifoDin(94 downto 64)   <= localBusMaster.writeData(30 downto 0) after TPD_G;
               wrFifoWrEn                <= '1'                                   after TPD_G;
            end if;

         -- Read FIFO QWord0, - 0xBC00100C
         elsif localBusMaster.addr(23 downto 0) = x"00100C" then
            intLocalBusSlave.readData <= rdFifoDout(31 downto 0)   after TPD_G;
            rdFifoRdEn                <= localBusMaster.readEnable after TPD_G;

         -- Read FIFO QWord1, - 0xBC001010
         elsif localBusMaster.addr(23 downto 0) = x"001010" then
            intLocalBusSlave.readData <= rdFifoDout(63 downto 32) after TPD_G;

         -- Read FIFO QWord2, - 0xBC001014
         elsif localBusMaster.addr(23 downto 0) = x"001014" then
            intLocalBusSlave.readData(31)          <= rdFifoValid              after TPD_G;
            intLocalBusSlave.readData(30 downto 0) <= rdFifoDout(94 downto 64) after TPD_G;

         -- Config Bus Number, - 0xBC001018
         elsif localBusMaster.addr(23 downto 0) = x"001018" then
            if localBusMaster.writeEnable = '1' then
               cfgBusNumber <= localBusMaster.writeData(7 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"000000" & cfgBusNumber after TPD_G;

         -- Config Device Number, - 0xBC00101C
         elsif localBusMaster.addr(23 downto 0) = x"00101C" then
            if localBusMaster.writeEnable = '1' then
               cfgDeviceNumber <= localBusMaster.writeData(4 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"000000" & "000" & cfgDeviceNumber after TPD_G;

         -- Config Function Number, - 0xBC001020
         elsif localBusMaster.addr(23 downto 0) = x"001020" then
            if localBusMaster.writeEnable = '1' then
               cfgFunctionNumber <= localBusMaster.writeData(2 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"0000000" & "0" & cfgFunctionNumber after TPD_G;

         -- Config Status, - 0xBC001024
         elsif localBusMaster.addr(23 downto 0) = x"001024" then
            intLocalBusSlave.readData <= x"0000" & cfgStatus after TPD_G;

         -- Config Status, - 0xBC001028
         elsif localBusMaster.addr(23 downto 0) = x"001028" then
            intLocalBusSlave.readData <= x"0000" & cfgCommand after TPD_G;

         -- Config DStatus, - 0xBC00102C
         elsif localBusMaster.addr(23 downto 0) = x"00102C" then
            intLocalBusSlave.readData <= x"0000" & cfgDStatus after TPD_G;

         -- Config DStatus, - 0xBC001030
         elsif localBusMaster.addr(23 downto 0) = x"001030" then
            intLocalBusSlave.readData <= x"0000" & cfgDCommand after TPD_G;

         -- Config DStatus2, - 0xBC001034
         elsif localBusMaster.addr(23 downto 0) = x"001034" then
            intLocalBusSlave.readData <= x"0000" & cfgDCommand2 after TPD_G;

         -- Config LStatus, - 0xBC001038
         elsif localBusMaster.addr(23 downto 0) = x"001038" then
            intLocalBusSlave.readData <= x"0000" & cfgLStatus after TPD_G;

         -- Config LStatus, - 0xBC00103C
         elsif localBusMaster.addr(23 downto 0) = x"00103C" then
            intLocalBusSlave.readData <= x"0000" & cfgLCommand after TPD_G;

         -- Other Status, - 0xBC001040
         elsif localBusMaster.addr(23 downto 0) = x"001040" then
            intLocalBusSlave.readData(2 downto 0)   <= cfgPcieLinkState      after TPD_G;
            intLocalBusSlave.readData(3)            <= linkUp                after TPD_G;
            intLocalBusSlave.readData(4)            <= phyLinkUp             after TPD_G;
            intLocalBusSlave.readData(6 downto 5)   <= cfgPmcsrPowerstate    after TPD_G;
            intLocalBusSlave.readData(7)            <= cfgPmcsrPmeEn         after TPD_G;
            intLocalBusSlave.readData(8)            <= cfgPmcsrPmeStatus     after TPD_G;
            intLocalBusSlave.readData(9)            <= cfgReceivedFuncLvlRst after TPD_G;
            intLocalBusSlave.readData(11 downto 10) <= (others=>'0')         after TPD_G;
            intLocalBusSlave.readData(12)           <= pciClkRst             after TPD_G;
            intLocalBusSlave.readData(15 downto 13) <= (others=>'0')         after TPD_G;
            intLocalBusSlave.readData(31 downto 16) <= debugCount            after TPD_G;

         -- Enable Register - 0xBC001044
         elsif localBusMaster.addr(23 downto 0) = x"001044" then
            if localBusMaster.writeEnable = '1' then
               pcieEnable <= localBusMaster.writeData(0) after TPD_G;
               remResetL  <= localBusMaster.writeData(1) after TPD_G;
            end if;
            intLocalBusSlave.readData(0)            <= pcieEnable            after TPD_G;
            intLocalBusSlave.readData(1)            <= remResetL             after TPD_G;
            intLocalBusSlave.readData(3  downto  2) <= (others=>'0')         after TPD_G;
            intLocalBusSlave.readData(4)            <= intResetL             after TPD_G;
            intLocalBusSlave.readData(31 downto  5) <= (others=>'0')         after TPD_G;
         end if;
      end if;  
   end process;         

   -----------------------------------------
   -- FIFOs
   -----------------------------------------

   U_WriteFifo : PcieFifo
      PORT map (
         rst    => axiClkRst,
         wr_clk => axiClk,
         rd_clk => pciClk,
         din    => wrFifoDin,
         wr_en  => wrFifoWrEn,
         rd_en  => wrFifoRdEn,
         dout   => wrFifoDout,
         full   => open,
         empty  => open,
         valid  => wrFifoValid
      );

   wrFifoRdEn <= txReady and txValid;
   txValid    <= wrFifoValid when txBufAv > 1 else '0';

   U_ReadFifo : PcieFifo
      PORT map (
         rst    => axiClkRst,
         wr_clk => pciClk,
         rd_clk => axiClk,
         din    => rdFifoDin,
         wr_en  => rdFifoWrEn,
         rd_en  => rdFifoRdEn,
         dout   => rdFifoDout,
         full   => rdFifoFull,
         empty  => open,
         valid  => rdFifoValid
      );

   rxReady    <= not rdFifoFull;
   rdFifoWrEn <= rxReady and rxValid;

   -----------------------------------------
   -- PCI Express Core
   -----------------------------------------

   pcieTxP      <= pciExpTxP(0);
   pcieTxM      <= pciExpTxN(0);
   pciExpRxP(0) <= pcieRxP;
   pciExpRxN(0) <= pcieRxM;

   U_Pcie: entity work.pcie_7x_v1_9 
      generic map (
         PCIE_EXT_CLK                               => "FALSE"
      ) port map (
         pci_exp_txp                                => pciExpTxP,
         pci_exp_txn                                => pciExpTxN,
         pci_exp_rxp                                => pciExpRxP,
         pci_exp_rxn                                => pciExpRxN,
         PIPE_PCLK_IN                               => '0',
         PIPE_RXUSRCLK_IN                           => '0',
         PIPE_RXOUTCLK_IN                           => (others=>'0'),
         PIPE_DCLK_IN                               => '0',
         PIPE_USERCLK1_IN                           => '0',
         PIPE_USERCLK2_IN                           => '0',
         PIPE_OOBCLK_IN                             => '0',
         PIPE_MMCM_LOCK_IN                          => '0',
         PIPE_TXOUTCLK_OUT                          => open,
         PIPE_RXOUTCLK_OUT                          => open,
         PIPE_PCLK_SEL_OUT                          => open,
         PIPE_GEN3_OUT                              => open,
         user_clk_out                               => pciClk,
         user_reset_out                             => pciClkRst,
         user_lnk_up                                => linkUp,
         tx_buf_av                                  => txBufAv,
         tx_cfg_req                                 => open,
         tx_err_drop                                => open,
         s_axis_tx_tready                           => txReady,
         s_axis_tx_tdata                            => wrFifoDout(63 downto 0),
         s_axis_tx_tkeep                            => wrFifoDout(71 downto 64),
         s_axis_tx_tlast                            => wrFifoDout(94),
         s_axis_tx_tvalid                           => txValid,
         s_axis_tx_tuser                            => wrFifoDout(75 downto 72),
         tx_cfg_gnt                                 => '1',
         m_axis_rx_tdata                            => rdFifoDin(63 downto 0),
         m_axis_rx_tkeep                            => rdFifoDin(71 downto 64),
         m_axis_rx_tlast                            => rdFifoDin(94),
         m_axis_rx_tvalid                           => rxValid,
         m_axis_rx_tready                           => rxReady,
         m_axis_rx_tuser                            => rdFifoDin(93 downto 72),
         rx_np_ok                                   => '1',
         rx_np_req                                  => '1',
         fc_cpld                                    => open,
         fc_cplh                                    => open,
         fc_npd                                     => open,
         fc_nph                                     => open,
         fc_pd                                      => open,
         fc_ph                                      => open,
         fc_sel                                     => "000",
         cfg_mgmt_do                                => cfgDout,
         cfg_mgmt_rd_wr_done                        => cfgRdWrDone,
         cfg_status                                 => cfgStatus,
         cfg_command                                => cfgCommand,
         cfg_dstatus                                => cfgDstatus,
         cfg_dcommand                               => cfgDcommand,
         cfg_lstatus                                => cfgLstatus,
         cfg_lcommand                               => cfgLcommand,
         cfg_dcommand2                              => cfgDcommand2,
         cfg_pcie_link_state                        => cfgPcieLinkState,
         cfg_pmcsr_pme_en                           => cfgPmcsrPmeEn,
         cfg_pmcsr_powerstate                       => cfgPmcsrPowerstate,
         cfg_pmcsr_pme_status                       => cfgPmcsrPmeStatus,
         cfg_received_func_lvl_rst                  => cfgReceivedFuncLvlRst,
         cfg_mgmt_di                                => cfgDin,
         cfg_mgmt_byte_en                           => "1111",
         cfg_mgmt_dwaddr                            => cfgAddr,
         cfg_mgmt_wr_en                             => cfgWrEn,
         cfg_mgmt_rd_en                             => cfgRdEn,
         cfg_mgmt_wr_readonly                       => '0',
         cfg_err_ecrc                               => '0',
         cfg_err_ur                                 => '0',
         cfg_err_cpl_timeout                        => '0',
         cfg_err_cpl_unexpect                       => '0',
         cfg_err_cpl_abort                          => '0',
         cfg_err_posted                             => '0',
         cfg_err_cor                                => '0',
         cfg_err_atomic_egress_blocked              => '0',
         cfg_err_internal_cor                       => '0',
         cfg_err_malformed                          => '0',
         cfg_err_mc_blocked                         => '0',
         cfg_err_poisoned                           => '0',
         cfg_err_norecovery                         => '0',
         cfg_err_tlp_cpl_header                     => (others=>'0'),
         cfg_err_cpl_rdy                            => open,
         cfg_err_locked                             => '0',
         cfg_err_acs                                => '0',
         cfg_err_internal_uncor                     => '0',
         cfg_trn_pending                            => '0',
         cfg_pm_halt_aspm_l0s                       => '0',
         cfg_pm_halt_aspm_l1                        => '0',
         cfg_pm_force_state_en                      => '0',
         cfg_pm_force_state                         => (others=>'0'),
         cfg_dsn                                    => (others=>'0'),
         cfg_interrupt                              => '0',
         cfg_interrupt_rdy                          => open, 
         cfg_interrupt_assert                       => '0',
         cfg_interrupt_di                           => (others=>'0'),
         cfg_interrupt_do                           => open,
         cfg_interrupt_mmenable                     => open,
         cfg_interrupt_msienable                    => open,
         cfg_interrupt_msixenable                   => open,
         cfg_interrupt_msixfm                       => open,
         cfg_interrupt_stat                         => '0',
         cfg_pciecap_interrupt_msgnum               => (others=>'0'),
         cfg_to_turnoff                             => open,
         cfg_turnoff_ok                             => '0',
         cfg_bus_number                             => open,
         cfg_device_number                          => open,
         cfg_function_number                        => open,
         cfg_pm_wake                                => '0',
         cfg_pm_send_pme_to                         => '0',
         cfg_ds_bus_number                          => cfgBusNumber,
         cfg_ds_device_number                       => cfgDeviceNumber,
         cfg_ds_function_number                     => cfgFunctionNumber,
         cfg_mgmt_wr_rw1c_as_rw                     => '0',
         cfg_msg_received                           => open,
         cfg_msg_data                               => open,
         cfg_bridge_serr_en                         => open,
         cfg_slot_control_electromech_il_ctl_pulse  => open,
         cfg_root_control_syserr_corr_err_en        => open,
         cfg_root_control_syserr_non_fatal_err_en   => open,
         cfg_root_control_syserr_fatal_err_en       => open,
         cfg_root_control_pme_int_en                => open,
         cfg_aer_rooterr_corr_err_reporting_en      => open,
         cfg_aer_rooterr_non_fatal_err_reporting_en => open,
         cfg_aer_rooterr_fatal_err_reporting_en     => open,
         cfg_aer_rooterr_corr_err_received          => open,
         cfg_aer_rooterr_non_fatal_err_received     => open,
         cfg_aer_rooterr_fatal_err_received         => open,
         cfg_msg_received_err_cor                   => open,
         cfg_msg_received_err_non_fatal             => open,
         cfg_msg_received_err_fatal                 => open,
         cfg_msg_received_pm_as_nak                 => open,
         cfg_msg_received_pm_pme                    => open,
         cfg_msg_received_pme_to_ack                => open,
         cfg_msg_received_assert_int_a              => open,
         cfg_msg_received_assert_int_b              => open,
         cfg_msg_received_assert_int_c              => open,
         cfg_msg_received_assert_int_d              => open,
         cfg_msg_received_deassert_int_a            => open,
         cfg_msg_received_deassert_int_b            => open,
         cfg_msg_received_deassert_int_c            => open,
         cfg_msg_received_deassert_int_d            => open,
         cfg_msg_received_setslotpowerlimit         => open,
         pl_directed_link_change                    => "00",
         pl_directed_link_width                     => "00",
         pl_directed_link_speed                     => '0',
         pl_directed_link_auton                     => '0',
         pl_upstream_prefer_deemph                  => '0',
         pl_sel_lnk_rate                            => open,
         pl_sel_lnk_width                           => open,
         pl_ltssm_state                             => open,
         pl_lane_reversal_mode                      => open,
         pl_phy_lnk_up                              => phyLinkUp,
         pl_tx_pm_state                             => open,
         pl_rx_pm_state                             => open,
         pl_link_upcfg_cap                          => open,
         pl_link_gen2_cap                           => open,
         pl_link_partner_gen2_supported             => open,
         pl_initial_link_width                      => open,
         pl_directed_change_done                    => open,
         pl_received_hot_rst                        => open,
         pl_transmit_hot_rst                        => '0',
         pl_downstream_deemph_source                => '0',
         cfg_err_aer_headerlog                      => (others=>'0'),
         cfg_aer_interrupt_msgnum                   => (others=>'0'),
         cfg_err_aer_headerlog_set                  => open,
         cfg_aer_ecrc_check_en                      => open,
         cfg_aer_ecrc_gen_en                        => open,
         cfg_vc_tcvc_map                            => open,
         PIPE_MMCM_RST_N                            => '1',
         sys_clk                                    => pciRefClk,
         sys_rst_n                                  => intResetL
      );


   --------------------------------------------
   -- Debug Counter
   --------------------------------------------
   process ( pciClk, intResetL ) begin
      if intResetL = '0' then
         debugCount <= (others=>'0') after TPD_G;
      elsif rising_edge(pciClk) then
         debugCount <= debugCount + 1 after TPD_G;
      end if;
   end process;

end architecture structure;

