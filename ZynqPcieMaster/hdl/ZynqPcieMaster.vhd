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
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity ZynqPcieMaster is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Local Bus
      axiClk                  : in  sl;
      axiClkRst               : in  sl;
      axiReadMaster           : in  AxiLiteReadMasterType;
      axiReadSlave            : out AxiLiteReadSlaveType;
      axiWriteMaster          : in  AxiLiteWriteMasterType;
      axiWriteSlave           : out AxiLiteWriteSlaveType;

      -- Master clock and reset
      pciRefClkP              : in  sl;
      pciRefClkM              : in  sl;

      -- Reset output
      pcieResetL              : out sl;

      -- PCIE Lines
      pcieRxP                 : in  sl;
      pcieRxM                 : in  sl;
      pcieTxP                 : out sl;
      pcieTxM                 : out sl
   );
end ZynqPcieMaster;

architecture structure of ZynqPcieMaster is

   -- Local signals
   signal pciRefClk              : sl;
   signal wrFifoDout             : slv(94 downto 0);
   signal wrFifoRdEn             : sl;
   signal wrFifoValid            : sl;
   signal rdFifoDin              : slv(94 downto 0);
   signal rdFifoDout             : slv(94 downto 0);
   signal rdFifoWrEn             : sl;
   signal rdFifoFull             : sl;
   signal rdFifoValid            : sl;
   signal pciClk                 : sl;
   signal pciClkRst              : sl;
   signal txBufAv                : slv(5 downto 0);
   signal txReady                : sl;
   signal txValid                : sl;
   signal rxReady                : sl;
   signal rxValid                : sl;
   signal linkUp                 : sl;
   signal cfgStatus              : slv(15 downto 0);
   signal cfgCommand             : slv(15 downto 0);
   signal cfgDStatus             : slv(15 downto 0);
   signal cfgDCommand            : slv(15 downto 0);
   signal cfgDCommand2           : slv(15 downto 0);
   signal cfgLStatus             : slv(15 downto 0);
   signal cfgLCommand            : slv(15 downto 0);
   signal cfgPcieLinkState       : slv(2  downto 0);
   signal cfgPmcsrPmeEn          : sl;
   signal cfgPmcsrPowerstate     : slv(1  downto 0);
   signal cfgPmcsrPmeStatus      : sl;
   signal cfgReceivedFuncLvlRst  : sl;
   signal phyLinkUp              : sl;
   signal pciExpTxP              : slv(0  downto 0);
   signal pciExpTxN              : slv(0  downto 0);
   signal pciExpRxP              : slv(0  downto 0);
   signal pciExpRxN              : slv(0  downto 0);
   signal intResetL              : sl;
   signal axiClkRstInt           : sl := '1';

   type RegType is record
      wrFifoDin         : slv(94 downto 0);
      wrFifoWrEn        : sl;
      rdFifoRdEn        : sl;
      cfgBusNumber      : slv(7  downto 0);
      cfgDeviceNumber   : slv(4  downto 0);
      cfgFunctionNumber : slv(2  downto 0);
      remResetL         : sl;
      pcieEnable        : sl;
      axiReadSlave      : AxiLiteReadSlaveType;
      axiWriteSlave     : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      wrFifoDin         => (others=>'0'),
      wrFifoWrEn        => '0',
      rdFifoRdEn        => '0',
      cfgBusNumber      => (others=>'0'),
      cfgDeviceNumber   => (others=>'0'),
      cfgFunctionNumber => (others=>'0'),
      remResetL         => '0',
      pcieEnable        => '0',
      axiReadSlave      => AXI_READ_SLAVE_INIT_C,
      axiWriteSlave     => AXI_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   attribute mark_debug : string;
   attribute mark_debug of axiClkRstInt : signal is "true";

   attribute INIT : string;
   attribute INIT of axiClkRstInt : signal is "1";

begin

   -- Reset registration
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         axiClkRstInt <= axiClkRst after TPD_G;
      end if;
   end process;

   -- Outputs
   pcieResetL    <= r.remResetL;
   intResetL     <= r.pcieEnable;

   -- PCI Ref Clk 
   U_PciRefClk : IBUFDS_GTE2
      port map(
         O       => pciRefClk,
         ODIV2   => open,
         I       => pciRefClkP,
         IB      => pciRefClkM,
         CEB     => '0'
      );


   --------------------------------------------
   -- Registers: 0x0000 - 0xFFFF
   --------------------------------------------

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (axiClkRstInt, axiReadMaster, axiWriteMaster, r, rdFifoValid, rdFifoDout, cfgStatus, 
            cfgCommand, cfgDStatus, cfgDCommand, cfgDCommand2, cfgLStatus, cfgLCommand,
            cfgPcieLinkState, linkUp, phyLinkUp, cfgPmcsrPowerstate, cfgPmcsrPmeEn, 
            cfgPmcsrPmeStatus, cfgReceivedFuncLvlRst, pciClkRst, intResetL ) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      v.wrFifoWrEn := '0';
      v.rdFifoRdEn := '0';

      axiSlaveWaitTxn(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Decode address and perform write
         case (axiWriteMaster.awaddr(15 downto 0)) is

            -- Write FIFO QWord0, - 0x1000
            when x"1000" => 
               v.wrFifoDin(31 downto  0) := axiWriteMaster.wdata;

            -- Write FIFO QWord1, - 0x1004
            when x"1004" => 
               v.wrFifoDin(63 downto 32) := axiWriteMaster.wdata;

            -- Write FIFO QWord2, - 0x1008
            when x"1008" => 
               v.wrFifoDin(94 downto 64) := axiWriteMaster.wdata(30 downto 0);
               v.wrFifoWrEn              := '1';

            -- Config Bus Number, - 0x1018
            when x"1018" => 
               v.cfgBusNumber := axiWriteMaster.wdata(7 downto 0);

            -- Config Device Number, - 0x101C
            when x"101C" => 
               v.cfgDeviceNumber := axiWriteMaster.wdata(4 downto 0);

            -- Config Function Number, - 0x1020
            when x"1020" => 
               v.cfgFunctionNumber := axiWriteMaster.wdata(2 downto 0);

            -- Enable Register - 0x1044
            when x"1044" => 
               v.pcieEnable := axiWriteMaster.wdata(0);
               v.remResetL  := axiWriteMaster.wdata(1);

            when others => null;
         end case;

         -- Send Axi response
         axiSlaveWriteResponse(v.axiWriteSlave);

      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axiReadSlave.rdata := (others => '0');

         -- Decode address and assign read data
         case axiReadMaster.araddr(15 downto 0) is

            -- Read FIFO QWord0, - 0x100C
            when X"100C" =>
               v.axiReadSlave.rdata := rdFifoDout(31 downto 0);
               v.rdFifoRdEn         := '1';

            -- Read FIFO QWord1, - 0x1010
            when X"1010" =>
               v.axiReadSlave.rdata := rdFifoDout(63 downto 32);

            -- Read FIFO QWord2, - 0x1014
            when X"1014" =>
               v.axiReadSlave.rdata(31)          := rdFifoValid;
               v.axiReadSlave.rdata(30 downto 0) := rdFifoDout(94 downto 64);

            -- Config Bus Number, - 0x1018
            when X"1018" =>
               v.axiReadSlave.rdata(7 downto 0) := r.cfgBusNumber;

            -- Config Device Number, - 0x101C
            when X"101C" =>
               v.axiReadSlave.rdata(4 downto 0) := r.cfgDeviceNumber;

            -- Config Function Number, - 0x1020
            when X"1020" =>
               v.axiReadSlave.rdata(2 downto 0) := r.cfgFunctionNumber;

            -- Config Status, - 0x1024
            when X"1024" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgStatus;

            -- Config Status, - 0x1028
            when X"1028" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgCommand;

            -- Config DStatus, - 0x102C
            when X"102C" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgDStatus;

            -- Config DStatus, - 0x1030
            when X"1030" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgDCommand;

            -- Config DStatus, - 0x1034
            when X"1034" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgDCommand2;

            -- Config LStatus, - 0x1038
            when X"1038" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgLStatus;

            -- Config LStatus, - 0x103C
            when X"103C" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgLCommand;

            -- Other Status, - 0x1040
            when X"1040" =>
               v.axiReadSlave.rdata(2 downto 0)   := cfgPcieLinkState;
               v.axiReadSlave.rdata(3)            := linkUp;
               v.axiReadSlave.rdata(4)            := phyLinkUp;
               v.axiReadSlave.rdata(6 downto 5)   := cfgPmcsrPowerstate;
               v.axiReadSlave.rdata(7)            := cfgPmcsrPmeEn;
               v.axiReadSlave.rdata(8)            := cfgPmcsrPmeStatus;
               v.axiReadSlave.rdata(9)            := cfgReceivedFuncLvlRst;
               v.axiReadSlave.rdata(12)           := pciClkRst;

            -- Enable Register - 0x1044
            when X"1044" =>
               v.axiReadSlave.rdata(0)            := v.pcieEnable;
               v.axiReadSlave.rdata(1)            := v.remResetL;
               v.axiReadSlave.rdata(4)            := intResetL;

            when others => null;
         end case;

         -- Send Axi Response
         axiSlaveReadResponse(v.axiReadSlave);
      end if;

      -- Reset
      if (axiClkRstInt = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      axiReadSlave  <= r.axiReadSlave;
      axiWriteSlave <= r.axiWriteSlave;
      
   end process;


   -----------------------------------------
   -- FIFOs, Dist Ram
   -----------------------------------------
   U_WriteFifo : entity work.FifoASync
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         BRAM_EN_G      => false,  -- Use Dist Ram
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         ALTERA_SYN_G   => false,
         ALTERA_RAM_G   => "M512",
         SYNC_STAGES_G  => 3,
         DATA_WIDTH_G   => 95,
         ADDR_WIDTH_G   => 4,
         INIT_G         => "0",
         FULL_THRES_G   => 15,
         EMPTY_THRES_G  => 1
      ) port map (
         rst                => axiClkRstInt,
         wr_clk             => axiClk,
         wr_en              => r.wrFifoWrEn,
         din                => r.wrFifoDin,
         wr_data_count      => open,
         wr_ack             => open,
         overflow           => open,
         prog_full          => open,
         almost_full        => open,
         full               => open,
         not_full           => open,
         rd_clk             => pciClk,
         rd_en              => wrFifoRdEn,
         rd_data_count      => open,
         dout               => wrFifoDout,
         valid              => wrFifoValid,
         underflow          => open,
         prog_empty         => open,
         almost_empty       => open,
         empty              => open
      );

   wrFifoRdEn <= txReady and txValid;
   txValid    <= wrFifoValid when txBufAv > 1 else '0';

   U_ReadFifo : entity work.FifoASync
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         BRAM_EN_G      => false,  -- Use Dist Ram
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         ALTERA_SYN_G   => false,
         ALTERA_RAM_G   => "M512",
         SYNC_STAGES_G  => 3,
         DATA_WIDTH_G   => 95,
         ADDR_WIDTH_G   => 4,
         INIT_G         => "0",
         FULL_THRES_G   => 15,
         EMPTY_THRES_G  => 1
      ) port map (
         rst                => axiClkRstInt,
         wr_clk             => pciClk,
         wr_en              => rdFifoWrEn,
         din                => rdFifoDin,
         wr_data_count      => open,
         wr_ack             => open,
         overflow           => open,
         prog_full          => open,
         almost_full        => open,
         full               => rdFifoFull,
         not_full           => open,
         rd_clk             => axiClk,
         rd_en              => r.rdFifoRdEn,
         rd_data_count      => open,
         dout               => rdFifoDout,
         valid              => rdFifoValid,
         underflow          => open,
         prog_empty         => open,
         almost_empty       => open,
         empty              => open
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
         cfg_mgmt_do                                => open,
         cfg_mgmt_rd_wr_done                        => open,
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
         cfg_mgmt_di                                => (others=>'0'),
         cfg_mgmt_byte_en                           => "1111",
         cfg_mgmt_dwaddr                            => (others=>'0'),
         cfg_mgmt_wr_en                             => '0',
         cfg_mgmt_rd_en                             => '0',
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
         cfg_ds_bus_number                          => r.cfgBusNumber,
         cfg_ds_device_number                       => r.cfgDeviceNumber,
         cfg_ds_function_number                     => r.cfgFunctionNumber,
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

end architecture structure;

