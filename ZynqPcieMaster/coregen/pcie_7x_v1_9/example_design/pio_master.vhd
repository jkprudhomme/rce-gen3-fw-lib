-------------------------------------------------------------------------------
--
-- (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------
-- Project    : Series-7 Integrated Block for PCI Express
-- File       : pio_master.vhd
-- Version    : 1.9
--
-- Description : PIO Master Example Design - performs write/read test on
--               a PIO design instantiated in a connected Endpoint. This
--               block can address up to four separate memory apertures,
--               designated as BAR A, B, C, and D to differentiate them from
--               the BAR0-5 registers defined in the PCI Specification. The
--               block performs a write to each aperture, followed by a read
--               from each space. The results of the read are compared with the
--               data written to each aperture, and if all data matches the
--               block declares success. The write/read/verify process can be
--               restarted by pulsing the pio_test_restart input. The block is
--               designed to interface with the Configurator block - when the
--               user_lnk_up input is asserted (signifying that the link has
--               reached L0 and DL_UP) then this block instructs the
--               Configurator to configure the attached endpoint. When the
--               Configurator finished successfully, this block begins its
--               write/read/verify cycle.
--
-- Hierarchy   : xilinx_pcie_2_1_rport_7x
--               |
--               |--cgator_wrapper
--               |  |
--               |  |--pcie_2_1_rport_7x (in source directory)
--               |  |  |
--               |  |  |--<various>
--               |  |
--               |  |--cgator
--               |     |
--               |     |--cgator_cpl_decoder
--               |     |--cgator_pkt_generator
--               |     |--cgator_tx_mux
--               |     |--cgator_gen2_enabler
--               |     |--cgator_controller
--               |        |--<cgator_cfg_rom.data> (specified by ROM_FILE)
--               |
--               |--pio_master
--                  |
--                  |--pio_master_controller
--                  |--pio_master_checker
--                  |--pio_master_pkt_generator
-------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;

entity pio_master is
   generic (
      TCQ                                          : integer := 1;
      REQUESTER_ID                                 : std_logic_vector(15 downto 0) := X"FACE";

      -- BAR A settings
      BAR_A_ENABLED                                : integer := 1;
      BAR_A_64BIT                                  : integer := 1;
      BAR_A_IO                                     : integer := 0;
      BAR_A_BASE                                   : std_logic_vector(63 downto 0) := X"1000000000000000";
      BAR_A_SIZE                                   : integer := 1024;   -- Size in DW

      -- BAR B settings
      BAR_B_ENABLED                                : integer := 0;
      BAR_B_64BIT                                  : integer := 0;
      BAR_B_IO                                     : integer := 0;
      BAR_B_BASE                                   : std_logic_vector(63 downto 0) := X"0000000020000000";
      BAR_B_SIZE                                   : integer := 1024;   -- Size in DW

      -- BAR C settings
      BAR_C_ENABLED                                : integer := 0;
      BAR_C_64BIT                                  : integer := 0;
      BAR_C_IO                                     : integer := 0;
      BAR_C_BASE                                   : std_logic_vector(63 downto 0) := X"0000000040000000";
      BAR_C_SIZE                                   : integer := 1024;   -- Size in DW

      -- BAR D settings
      BAR_D_ENABLED                                : integer := 0;
      BAR_D_64BIT                                  : integer := 0;
      BAR_D_IO                                     : integer := 0;
      BAR_D_BASE                                   : std_logic_vector(63 downto 0) := X"0000000080000000";
      BAR_D_SIZE                                   : integer := 1024;   -- Size in DW

      C_DATA_WIDTH                                 : integer := 64;
      KEEP_WIDTH                                   : integer := 8


   );
   port (
      -- globals
      user_clk                                     : in  std_logic;
      reset                                        : in  std_logic;
      user_lnk_up                                  : in  std_logic;

      -- System information
      pio_test_restart                             : in  std_logic;
      pio_test_long                                : in  std_logic;   -- Unused for now
      pio_test_finished                            : out std_logic;
      pio_test_failed                              : out std_logic;

      -- Control configuration process
      start_config                                 : out std_logic;
      finished_config                              : in  std_logic;
      failed_config                                : in  std_logic;

      link_gen2_capable                            : in  std_logic;
      link_gen2                                    : in  std_logic;

      -- TRN interfaces
      s_axis_tx_tlast                              : out std_logic;
      s_axis_tx_tdata                              : out std_logic_vector((C_DATA_WIDTH-1) downto 0);
      s_axis_tx_tkeep                              : out std_logic_vector((KEEP_WIDTH-1) downto 0);
      s_axis_tx_tvalid                             : out std_logic;
      s_axis_tx_tready                             : in  std_logic;
      s_axis_tx_tuser                              : out std_logic_vector(3 downto 0);

      tx_cfg_req                                   : in  std_logic;
      tx_cfg_gnt                                   : out std_logic;
      tx_buf_av                                    : in  std_logic_vector(5 downto 0);

      m_axis_rx_tlast                              : in  std_logic;
      m_axis_rx_tdata                              : in  std_logic_vector((C_DATA_WIDTH-1) downto 0);
      m_axis_rx_tkeep                              : in  std_logic_vector((KEEP_WIDTH-1) downto 0);
      m_axis_rx_tvalid                             : in  std_logic;
      m_axis_rx_tuser                              : in  std_logic_vector (21 downto 0)

   );
end pio_master;

architecture rtl of pio_master is

  component pio_master_controller
    generic (
      TCQ           : integer;
      BAR_A_ENABLED : integer;
      BAR_A_64BIT   : integer;
      BAR_A_IO      : integer;
      BAR_A_BASE    : std_logic_vector(63 downto 0);
      BAR_A_SIZE    : integer;
      BAR_B_ENABLED : integer;
      BAR_B_64BIT   : integer;
      BAR_B_IO      : integer;
      BAR_B_BASE    : std_logic_vector(63 downto 0);
      BAR_B_SIZE    : integer;
      BAR_C_ENABLED : integer;
      BAR_C_64BIT   : integer;
      BAR_C_IO      : integer;
      BAR_C_BASE    : std_logic_vector(63 downto 0);
      BAR_C_SIZE    : integer;
      BAR_D_ENABLED : integer;
      BAR_D_64BIT   : integer;
      BAR_D_IO      : integer;
      BAR_D_BASE    : std_logic_vector(63 downto 0);
      BAR_D_SIZE    : integer);
    port (
      user_clk          : in  std_logic;
      reset             : in  std_logic;
      user_lnk_up       : in  std_logic;
      pio_test_restart  : in  std_logic;
      pio_test_long     : in  std_logic;
      pio_test_finished : out std_logic;
      pio_test_failed   : out std_logic;
      start_config      : out std_logic;
      finished_config   : in  std_logic;
      failed_config     : in  std_logic;
      link_gen2_capable : in  std_logic;
      link_gen2         : in  std_logic;
      tx_type           : out std_logic_vector(2 downto 0);
      tx_tag            : out std_logic_vector(7 downto 0);
      tx_addr           : out std_logic_vector(63 downto 0);
      tx_data           : out std_logic_vector(31 downto 0);
      tx_start          : out std_logic;
      tx_done           : in  std_logic;
      rx_type           : out std_logic;
      rx_tag            : out std_logic_vector(7 downto 0);
      rx_data           : out std_logic_vector(31 downto 0);
      rx_good           : in  std_logic;
      rx_bad            : in  std_logic);
  end component;

  component pio_master_pkt_generator
    generic (
      TCQ              : integer;
      REQUESTER_ID     : std_logic_vector(15 downto 0);
      C_DATA_WIDTH     : integer;
      KEEP_WIDTH       : integer);
    port (
      user_clk         : in  std_logic;
      reset            : in  std_logic;
      s_axis_tx_tlast  : out std_logic;
      s_axis_tx_tdata  : out std_logic_vector((C_DATA_WIDTH-1) downto 0);
      s_axis_tx_tkeep  : out std_logic_vector((KEEP_WIDTH-1) downto 0);
      s_axis_tx_tvalid : out std_logic;
      s_axis_tx_tready : in  std_logic;
      s_axis_tx_tuser  : out std_logic_vector(3 downto 0);
      tx_type          : in  std_logic_vector(2 downto 0);
      tx_tag           : in  std_logic_vector(7 downto 0);
      tx_addr          : in  std_logic_vector(63 downto 0);
      tx_data          : in  std_logic_vector(31 downto 0);
      tx_start         : in  std_logic;
      tx_done          : out std_logic);
  end component;

  component pio_master_checker
    generic (
      TCQ              : integer;
      REQUESTER_ID     : std_logic_vector(15 downto 0);
      C_DATA_WIDTH     : integer;
      KEEP_WIDTH       : integer);
    port (
      user_clk         : in  std_logic;
      reset            : in  std_logic;
      m_axis_rx_tlast  : in  std_logic;
      m_axis_rx_tdata  : in  std_logic_vector((C_DATA_WIDTH-1) downto 0);
      m_axis_rx_tkeep  : in  std_logic_vector((KEEP_WIDTH-1) downto 0);
      m_axis_rx_tuser  : in std_logic_vector(21 downto 0);
      m_axis_rx_tvalid : in  std_logic;
      rx_type          : in  std_logic;
      rx_tag           : in  std_logic_vector(7 downto 0);
      rx_data          : in  std_logic_vector(31 downto 0);
      rx_good          : out std_logic;
      rx_bad           : out std_logic);
  end component;

  -- Controller <-> Packet Generator
   signal tx_type                                      : std_logic_vector(2 downto 0);
   signal tx_tag                                       : std_logic_vector(7 downto 0);
   signal tx_addr                                      : std_logic_vector(63 downto 0);
   signal tx_data                                      : std_logic_vector(31 downto 0);
   signal tx_start                                     : std_logic;
   signal tx_done                                      : std_logic;

   -- Controller <-> Checker
   signal rx_type                                      : std_logic;
   signal rx_tag                                       : std_logic_vector(7 downto 0);
   signal rx_data                                      : std_logic_vector(31 downto 0);
   signal rx_good                                      : std_logic;
   signal rx_bad                                       : std_logic;

   -- Declare intermediate signals for referenced outputs
   signal start_config_7xpcie2                         : std_logic;
   signal s_axis_tx_tlast_7xpcie4                      : std_logic;
   signal s_axis_tx_tdata_7xpcie3                      : std_logic_vector((C_DATA_WIDTH-1) downto 0);
   signal s_axis_tx_tkeep_7xpcie6                      : std_logic_vector((KEEP_WIDTH-1) downto 0);
   signal s_axis_tx_tvalid_7xpcie9                     : std_logic;
begin
   -- Drive referenced outputs
   start_config <= start_config_7xpcie2;
   s_axis_tx_tlast <= s_axis_tx_tlast_7xpcie4;
   s_axis_tx_tdata <= s_axis_tx_tdata_7xpcie3;
   s_axis_tx_tkeep <= s_axis_tx_tkeep_7xpcie6;
   s_axis_tx_tvalid <= s_axis_tx_tvalid_7xpcie9;

   -- Static output
   tx_cfg_gnt <= '0';

   --
   -- PIO Master Controller - controls the read/write/verify process
   --


   pio_master_controller_i : pio_master_controller
      generic map (
         TCQ            => TCQ,
         BAR_A_ENABLED  => BAR_A_ENABLED,
         BAR_A_64BIT    => BAR_A_64BIT,
         BAR_A_IO       => BAR_A_IO,
         BAR_A_BASE     => BAR_A_BASE,
         BAR_A_SIZE     => BAR_A_SIZE,
         BAR_B_ENABLED  => BAR_B_ENABLED,
         BAR_B_64BIT    => BAR_B_64BIT,
         BAR_B_IO       => BAR_B_IO,
         BAR_B_BASE     => BAR_B_BASE,
         BAR_B_SIZE     => BAR_B_SIZE,
         BAR_C_ENABLED  => BAR_C_ENABLED,
         BAR_C_64BIT    => BAR_C_64BIT,
         BAR_C_IO       => BAR_C_IO,
         BAR_C_BASE     => BAR_C_BASE,
         BAR_C_SIZE     => BAR_C_SIZE,
         BAR_D_ENABLED  => BAR_D_ENABLED,
         BAR_D_64BIT    => BAR_D_64BIT,
         BAR_D_IO       => BAR_D_IO,
         BAR_D_BASE     => BAR_D_BASE,
         BAR_D_SIZE     => BAR_D_SIZE
      )
      port map (
         -- System inputs
         user_clk           => user_clk,
         reset              => reset,
         user_lnk_up        => user_lnk_up,

         -- Board-level control/status
         pio_test_restart   => pio_test_restart,
         pio_test_long      => pio_test_long,
         pio_test_finished  => pio_test_finished,
         pio_test_failed    => pio_test_failed,

         -- Control of Configurator
         start_config       => start_config_7xpcie2,
         finished_config    => finished_config,
         failed_config      => failed_config,

         link_gen2_capable  => link_gen2_capable,
         link_gen2          => link_gen2,

         -- Packet generator interface
         tx_type            => tx_type,
         tx_tag             => tx_tag,
         tx_addr            => tx_addr,
         tx_data            => tx_data,
         tx_start           => tx_start,
         tx_done            => tx_done,

         -- Checker interface
         rx_type            => rx_type,
         rx_tag             => rx_tag,
         rx_data            => rx_data,
         rx_good            => rx_good,
         rx_bad             => rx_bad
      );

   --
   -- PIO Master Packet Generator - Generates downstream packets as directed by
   -- the PIO Master Controller module
   --


   pio_master_pkt_generator_i : pio_master_pkt_generator
      generic map (
         TCQ               => TCQ,
         REQUESTER_ID      => REQUESTER_ID,
         C_DATA_WIDTH      => C_DATA_WIDTH,
         KEEP_WIDTH        => KEEP_WIDTH
      )
      port map (
         -- globals
         user_clk          => user_clk,
         reset             => reset,

         -- Tx TRN interface
         s_axis_tx_tlast   => s_axis_tx_tlast_7xpcie4,
         s_axis_tx_tdata   => s_axis_tx_tdata_7xpcie3,
         s_axis_tx_tkeep   => s_axis_tx_tkeep_7xpcie6,
         s_axis_tx_tuser   => s_axis_tx_tuser,
         s_axis_tx_tvalid  => s_axis_tx_tvalid_7xpcie9,
         s_axis_tx_tready  => s_axis_tx_tready,

         -- Controller interface
         tx_type           => tx_type,
         tx_tag            => tx_tag,
         tx_addr           => tx_addr,
         tx_data           => tx_data,
         tx_start          => tx_start,
         tx_done           => tx_done
      );

   --
   -- PIO Master Checker - Checks that incoming Completion TLPs match the
   -- parameters imposed by the Controller
   --


   pio_master_checker_i : pio_master_checker
      generic map (
         TCQ               => TCQ,
         REQUESTER_ID      => REQUESTER_ID,
         C_DATA_WIDTH      => C_DATA_WIDTH,
         KEEP_WIDTH        => KEEP_WIDTH
      )
      port map (
         -- globals
         user_clk          => user_clk,
         reset             => reset,

         -- Rx TRN interface
         m_axis_rx_tlast   => m_axis_rx_tlast,
         m_axis_rx_tdata   => m_axis_rx_tdata,
         m_axis_rx_tkeep   => m_axis_rx_tkeep,
         m_axis_rx_tuser   => m_axis_rx_tuser,
         m_axis_rx_tvalid  => m_axis_rx_tvalid,

         -- Controller interface
         rx_type           => rx_type,
         rx_tag            => rx_tag,
         rx_data           => rx_data,
         rx_good           => rx_good,
         rx_bad            => rx_bad
      );

end rtl;



-- pio_master
