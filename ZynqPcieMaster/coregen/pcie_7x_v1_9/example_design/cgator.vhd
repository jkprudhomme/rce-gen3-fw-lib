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
-- File       : cgator.vhd
-- Version    : 1.9
--
-- Description : Configurator example design - configures a PCI Express
--               Endpoint via the Root Port Block for PCI Express. Endpoint is
--               configured using a pre-determined set of configuration
--               and message transactions. Transactions are specified in the
--               file indicated by the ROM_FILE parameter
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

entity cgator is
   generic (
      TCQ                         : integer := 1;
      EXTRA_PIPELINE              : integer := 1;
      ROM_FILE                    : string := "cgator_cfg_rom.data";
      ROM_SIZE                    : integer := 32;
      REQUESTER_ID                : std_logic_vector(15 downto 0) := X"10EE";
      C_DATA_WIDTH                : integer := 64;
      KEEP_WIDTH                  : integer := 8
   );
   port (
      -- globals
      user_clk                    : in std_logic;
      reset                       : in std_logic;

      -- User interface for configuration
      start_config                : in std_logic;
      finished_config             : out std_logic;
      failed_config               : out std_logic;

      -- Rport AXIS interfaces

      rport_s_axis_tx_tlast       : out std_logic;
      rport_s_axis_tx_tdata       : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
      rport_s_axis_tx_tkeep       : out std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
      rport_s_axis_tx_tuser       : out std_logic_vector(3 downto 0);
      rport_s_axis_tx_tvalid      : out std_logic;
      rport_s_axis_tx_tready      : in std_logic;
      rport_tx_cfg_req            : in std_logic;
      rport_tx_cfg_gnt            : out std_logic;
      rport_tx_buf_av             : in std_logic_vector(5 downto 0);
      rport_tx_err_drop           : in std_logic;

      rport_m_axis_rx_tlast       : in std_logic;
      rport_m_axis_rx_tdata       : in std_logic_vector(C_DATA_WIDTH-1 downto 0);
      rport_m_axis_rx_tkeep       : in std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
      rport_m_axis_rx_tuser       : in std_logic_vector(21 downto 0);
      rport_m_axis_rx_tvalid      : in std_logic;
      rport_m_axis_rx_tready      : out std_logic;
      rport_rx_np_ok              : out std_logic;

      usr_s_axis_tx_tlast         : in std_logic;
      usr_s_axis_tx_tdata         : in std_logic_vector(C_DATA_WIDTH-1 downto 0);
      usr_s_axis_tx_tkeep         : in std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
      usr_s_axis_tx_tuser         : in std_logic_vector(3 downto 0);
      usr_s_axis_tx_tvalid        : in std_logic;
      usr_s_axis_tx_tready        : out std_logic;
      usr_tx_cfg_req              : out std_logic;
      usr_tx_cfg_gnt              : in std_logic;
      usr_tx_buf_av               : out std_logic_vector(5 downto 0);
      usr_tx_err_drop             : out std_logic;

      usr_m_axis_rx_tlast         : out std_logic;
      usr_m_axis_rx_tdata         : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
      usr_m_axis_rx_tkeep         : out std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
      usr_m_axis_rx_tuser         : out std_logic_vector(21 downto 0);
      usr_m_axis_rx_tvalid        : out std_logic;

      -- Rport CFG interface
      rport_cfg_do                : in std_logic_vector(31 downto 0);
      rport_cfg_rd_wr_done        : in std_logic;
      rport_cfg_di                : out std_logic_vector(31 downto 0);
      rport_cfg_byte_en           : out std_logic_vector(3 downto 0);
      rport_cfg_dwaddr            : out std_logic_vector(9 downto 0);
      rport_cfg_wr_en             : out std_logic;
      rport_cfg_wr_rw1c_as_rw     : out std_logic;
      rport_cfg_rd_en             : out std_logic;

      -- User CFG interface
      usr_cfg_do                  : out std_logic_vector(31 downto 0);
      usr_cfg_rd_wr_done          : out std_logic;
      usr_cfg_di                  : in std_logic_vector(31 downto 0);
      usr_cfg_byte_en             : in std_logic_vector(3 downto 0);
      usr_cfg_dwaddr              : in std_logic_vector(9 downto 0);
      usr_cfg_wr_en               : in std_logic;
      usr_cfg_wr_rw1c_as_rw       : in std_logic;
      usr_cfg_rd_en               : in std_logic;

      -- Rport PL interface
      rport_pl_link_gen2_capable  : in std_logic
   );
end cgator;

architecture rtl of cgator is

  component cgator_controller
    generic (
      TCQ                  : integer;
      ROM_FILE             : string;
      ROM_SIZE             : integer);
    port (
        user_clk           : in  std_logic;
        reset              : in  std_logic;
        start_config       : in  std_logic;
        finished_config    : out std_logic;
        failed_config      : out std_logic;
        pkt_type           : out std_logic_vector(1 downto 0);
        pkt_func_num       : out std_logic_vector(1 downto 0);
        pkt_reg_num        : out std_logic_vector(9 downto 0);
        pkt_1dw_be         : out std_logic_vector(3 downto 0);
        pkt_msg_routing    : out std_logic_vector(2 downto 0);
        pkt_msg_code       : out std_logic_vector(7 downto 0);
        pkt_data           : out std_logic_vector(31 downto 0);
        pkt_start          : out std_logic;
        pkt_done           : in  std_logic;
        config_mode        : out std_logic;
        config_mode_active : in  std_logic;
        cpl_sc             : in  std_logic;
        cpl_ur             : in  std_logic;
        cpl_crs            : in  std_logic;
        cpl_ca             : in  std_logic;
        cpl_data           : in  std_logic_vector(31 downto 0);
        cpl_mismatch       : in  std_logic);
  end component;

  component cgator_pkt_generator
    generic (
      TCQ                         : integer := 1;
      REQUESTER_ID                : std_logic_vector(15 downto 0) := X"10EE";
      C_DATA_WIDTH                : integer := 64;
      KEEP_WIDTH                  : integer := 8  
      );
    port (
      user_clk                    : in std_logic;
      reset                       : in std_logic;

      -- Tx mux interface
      pg_s_axis_tx_tready         : in std_logic;
      pg_s_axis_tx_tdata          : out std_logic_vector(C_DATA_WIDTH-1  downto 0);
      pg_s_axis_tx_tkeep          : out std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
      pg_s_axis_tx_tuser          : out std_logic_vector(3 downto 0);
      pg_s_axis_tx_tlast          : out std_logic;
      pg_s_axis_tx_tvalid         : out std_logic;

      -- Controller interface

      pkt_type                    : in std_logic_vector(1 downto 0);
      pkt_func_num                : in std_logic_vector(1 downto 0);
      pkt_reg_num                 : in std_logic_vector(9 downto 0);
      pkt_1dw_be                  : in std_logic_vector(3 downto 0);
      pkt_msg_routing             : in std_logic_vector(2 downto 0);
      pkt_msg_code                : in std_logic_vector(7 downto 0);
      pkt_data                    : in std_logic_vector(31 downto 0);
      pkt_start                   : in std_logic;
      pkt_done                    : out std_logic);
  end component;

  component cgator_tx_mux
    generic (
      TCQ                         : integer;
      C_DATA_WIDTH                : integer := 64;
      KEEP_WIDTH                  : integer := 8      
      );
    port (
      user_clk                    : in std_logic;
      reset                       : in std_logic;

      -- User Tx AXIS interface
      usr_s_axis_tx_tready        : out std_logic;
      usr_s_axis_tx_tdata         : in std_logic_vector(C_DATA_WIDTH-1  downto 0);
      usr_s_axis_tx_tkeep         : in std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
      usr_s_axis_tx_tuser         : in std_logic_vector(3 downto 0);
      usr_s_axis_tx_tlast         : in std_logic;
      usr_s_axis_tx_tvalid        : in std_logic;

      -- Packet Generator Tx interface
      pg_s_axis_tx_tready         : out std_logic;
      pg_s_axis_tx_tdata          : in std_logic_vector(C_DATA_WIDTH-1  downto 0);
      pg_s_axis_tx_tkeep          : in std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
      pg_s_axis_tx_tuser          : in std_logic_vector(3 downto 0);
      pg_s_axis_tx_tlast          : in std_logic;
      pg_s_axis_tx_tvalid         : in std_logic;

      -- Root Port Wrapper Tx interface
      rport_tx_cfg_req            : in std_logic;
      rport_tx_cfg_gnt            : in std_logic;
      rport_s_axis_tx_tready      : in std_logic;
      rport_s_axis_tx_tdata       : out std_logic_vector(C_DATA_WIDTH-1  downto 0);
      rport_s_axis_tx_tkeep       : out std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
      rport_s_axis_tx_tuser       : out std_logic_vector(3 downto 0);
      rport_s_axis_tx_tlast       : out std_logic;
      rport_s_axis_tx_tvalid      : out std_logic;

      -- Root port status interface
      rport_tx_buf_av               : in std_logic_vector(5 downto 0);

      -- Controller interface
      config_mode                 : in std_logic;
      config_mode_active          : out std_logic);
  end component;

  component cgator_cpl_decoder
    generic (
      TCQ            : integer;
      EXTRA_PIPELINE : integer;
      REQUESTER_ID   : std_logic_vector(15 downto 0);
      C_DATA_WIDTH   : integer := 64;
      KEEP_WIDTH     : integer := 8 
      );
    port (
      user_clk                    : in std_logic;
      reset                       : in std_logic;

      -- Root Port Wrapper Rx interface
      rport_m_axis_rx_tdata       : in std_logic_vector(C_DATA_WIDTH-1  downto 0);
      rport_m_axis_rx_tkeep       : in std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
      rport_m_axis_rx_tuser       : in std_logic_vector(21 downto 0);
      rport_m_axis_rx_tlast       : in std_logic;
      rport_m_axis_rx_tvalid      : in std_logic;
      rport_m_axis_rx_tready      : out std_logic;
      rport_rx_np_ok              : out std_logic;

      -- User Rx AXIS interface
      usr_m_axis_rx_tdata         : out std_logic_vector(C_DATA_WIDTH-1  downto 0);
      usr_m_axis_rx_tkeep         : out std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
      usr_m_axis_rx_tuser         : out std_logic_vector(21 downto 0);
      usr_m_axis_rx_tlast         : out std_logic;
      usr_m_axis_rx_tvalid        : out std_logic;

      -- Controller interface
      config_mode                 : in std_logic;
      cpl_sc                      : out std_logic;
      cpl_ur                      : out std_logic;
      cpl_crs                     : out std_logic;
      cpl_ca                      : out std_logic;
      cpl_data                    : out std_logic_vector(31 downto 0);
      cpl_mismatch                : out std_logic);
  end component;

  -- Controller <-> All modules
   signal config_mode                       : std_logic;
   signal config_mode_active                : std_logic;

   -- Packet Generator <-> Tx Mux
   signal pg_s_axis_tx_tready               : std_logic;
   signal pg_s_axis_tx_tdata                : std_logic_vector(C_DATA_WIDTH-1  downto 0);
   signal pg_s_axis_tx_tkeep                : std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
   signal pg_s_axis_tx_tuser                : std_logic_vector(3 downto 0);
   signal pg_s_axis_tx_tlast                : std_logic;
   signal pg_s_axis_tx_tvalid               : std_logic;

   -- Controller <-> Packet Generator
   signal pkt_type                          : std_logic_vector(1 downto 0);
   signal pkt_func_num                      : std_logic_vector(1 downto 0);
   signal pkt_reg_num                       : std_logic_vector(9 downto 0);
   signal pkt_1dw_be                        : std_logic_vector(3 downto 0);
   signal pkt_msg_routing                   : std_logic_vector(2 downto 0);
   signal pkt_msg_code                      : std_logic_vector(7 downto 0);
   signal pkt_data                          : std_logic_vector(31 downto 0);
   signal pkt_start                         : std_logic;
   signal pkt_done                          : std_logic;

   -- Completion Decoder -> Controller
   signal cpl_sc                            : std_logic;
   signal cpl_ur                            : std_logic;
   signal cpl_crs                           : std_logic;
   signal cpl_ca                            : std_logic;
   signal cpl_data                          : std_logic_vector(31 downto 0);
   signal cpl_mismatch                      : std_logic;

   -- Controller <-> Gen2 Enabler
   signal gen2_train_start                  : std_logic;
   signal gen2_train_done                   : std_logic;

   signal rport_tx_cfg_gnt_int              : std_logic;

begin

   -- These signals are not modified internally, so are just passed through
   -- this module to user logic
   rport_tx_cfg_gnt_int   <= usr_tx_cfg_gnt;
   rport_tx_cfg_gnt       <= rport_tx_cfg_gnt_int;
   usr_tx_cfg_req         <= rport_tx_cfg_req;
   usr_tx_buf_av          <= rport_tx_buf_av;
   usr_tx_err_drop        <= rport_tx_err_drop;


   --
   -- Configurator Controller module - controls the Endpoint configuration
   -- process
   --
   cgator_controller_i : cgator_controller
      generic map (
         TCQ                   => TCQ,
         ROM_FILE              => ROM_FILE,
         ROM_SIZE              => ROM_SIZE
      )
      port map (
         -- globals
         user_clk            => user_clk,
         reset               => reset,

         -- User interface
         start_config        => start_config,
         finished_config     => finished_config,
         failed_config       => failed_config,

         -- Packet generator interface
         pkt_type            => pkt_type,
         pkt_func_num        => pkt_func_num,
         pkt_reg_num         => pkt_reg_num,
         pkt_1dw_be          => pkt_1dw_be,
         pkt_msg_routing     => pkt_msg_routing,
         pkt_msg_code        => pkt_msg_code,
         pkt_data            => pkt_data,
         pkt_start           => pkt_start,
         pkt_done            => pkt_done,

         -- Tx mux and completion decoder interface
         config_mode         => config_mode,
         config_mode_active  => config_mode_active,
         cpl_sc              => cpl_sc,
         cpl_ur              => cpl_ur,
         cpl_crs             => cpl_crs,
         cpl_ca              => cpl_ca,
         cpl_data            => cpl_data,
         cpl_mismatch        => cpl_mismatch
      );

   --
   -- Configurator Packet Generator module - generates downstream TLPs as
   -- directed by the Controller module
   --
   cgator_pkt_generator_i : cgator_pkt_generator
      generic map (
         TCQ           => TCQ,
         REQUESTER_ID  => REQUESTER_ID,
         C_DATA_WIDTH  => C_DATA_WIDTH,
         KEEP_WIDTH    => KEEP_WIDTH   
      )
      port map (
         -- globals
         user_clk               => user_clk,
         reset                  => reset,

         -- Tx mux interface
         pg_s_axis_tx_tready    => pg_s_axis_tx_tready,
         pg_s_axis_tx_tdata     => pg_s_axis_tx_tdata,
         pg_s_axis_tx_tkeep     => pg_s_axis_tx_tkeep,
         pg_s_axis_tx_tuser     => pg_s_axis_tx_tuser,
         pg_s_axis_tx_tlast     => pg_s_axis_tx_tlast,
         pg_s_axis_tx_tvalid    => pg_s_axis_tx_tvalid,

         -- Controller interface
         pkt_type               => pkt_type,
         pkt_func_num           => pkt_func_num,
         pkt_reg_num            => pkt_reg_num,
         pkt_1dw_be             => pkt_1dw_be,
         pkt_msg_routing        => pkt_msg_routing,
         pkt_msg_code           => pkt_msg_code,
         pkt_data               => pkt_data,
         pkt_start              => pkt_start,
         pkt_done               => pkt_done
      );

   --
   -- Configurator Tx Mux module - multiplexes between internally-generated
   -- TLP data and user data
   --
   cgator_tx_mux_i : cgator_tx_mux
      generic map (
         TCQ          => TCQ,
         C_DATA_WIDTH => C_DATA_WIDTH,
         KEEP_WIDTH   => KEEP_WIDTH   
      )
      port map (
         -- globals
         user_clk               => user_clk,
         reset                  => reset,

         -- User Tx interface
         usr_s_axis_tx_tready   => usr_s_axis_tx_tready,
         usr_s_axis_tx_tdata    => usr_s_axis_tx_tdata,
         usr_s_axis_tx_tkeep    => usr_s_axis_tx_tkeep,
         usr_s_axis_tx_tuser    => usr_s_axis_tx_tuser,
         usr_s_axis_tx_tlast    => usr_s_axis_tx_tlast,
         usr_s_axis_tx_tvalid   => usr_s_axis_tx_tvalid,

         -- Packet Generator Tx interface
         pg_s_axis_tx_tready    => pg_s_axis_tx_tready,
         pg_s_axis_tx_tdata     => pg_s_axis_tx_tdata,
         pg_s_axis_tx_tkeep     => pg_s_axis_tx_tkeep,
         pg_s_axis_tx_tuser     => pg_s_axis_tx_tuser,
         pg_s_axis_tx_tlast     => pg_s_axis_tx_tlast,
         pg_s_axis_tx_tvalid    => pg_s_axis_tx_tvalid,

         -- Root Port Wrapper Tx interface
         rport_tx_cfg_req          => rport_tx_cfg_req,
         rport_tx_cfg_gnt          => rport_tx_cfg_gnt_int,
         rport_s_axis_tx_tready    => rport_s_axis_tx_tready,
         rport_s_axis_tx_tdata     => rport_s_axis_tx_tdata,
         rport_s_axis_tx_tkeep     => rport_s_axis_tx_tkeep,
         rport_s_axis_tx_tuser     => rport_s_axis_tx_tuser,
         rport_s_axis_tx_tlast     => rport_s_axis_tx_tlast,
         rport_s_axis_tx_tvalid    => rport_s_axis_tx_tvalid,

         -- Root port status interface
         rport_tx_buf_av     => rport_tx_buf_av,

         -- Controller interface
         config_mode         => config_mode,
         config_mode_active  => config_mode_active
      );

   --
   -- Configurator Completion Decoder module - receives upstream TLPs and
   -- decodes completion status
   --
   cgator_cpl_decoder_i : cgator_cpl_decoder
      generic map (
         TCQ             => TCQ,
         EXTRA_PIPELINE  => EXTRA_PIPELINE,
         REQUESTER_ID    => REQUESTER_ID,
         C_DATA_WIDTH    => C_DATA_WIDTH,
         KEEP_WIDTH      => KEEP_WIDTH   
      )
      port map (
         -- globals
         user_clk           => user_clk,
         reset              => reset,

         -- Root Port Wrapper Rx interface
         rport_m_axis_rx_tdata   => rport_m_axis_rx_tdata,
         rport_m_axis_rx_tkeep   => rport_m_axis_rx_tkeep,
         rport_m_axis_rx_tlast   => rport_m_axis_rx_tlast,
         rport_m_axis_rx_tvalid  => rport_m_axis_rx_tvalid,
         rport_m_axis_rx_tready  => rport_m_axis_rx_tready,
         rport_m_axis_rx_tuser   => rport_m_axis_rx_tuser,
         rport_rx_np_ok          => rport_rx_np_ok,

         -- User Rx AXIS interface
         usr_m_axis_rx_tdata     => usr_m_axis_rx_tdata,
         usr_m_axis_rx_tkeep     => usr_m_axis_rx_tkeep,
         usr_m_axis_rx_tlast     => usr_m_axis_rx_tlast,
         usr_m_axis_rx_tvalid    => usr_m_axis_rx_tvalid,
         usr_m_axis_rx_tuser     => usr_m_axis_rx_tuser,

         -- Controller interface
         config_mode        => config_mode,
         cpl_sc             => cpl_sc,
         cpl_ur             => cpl_ur,
         cpl_crs            => cpl_crs,
         cpl_ca             => cpl_ca,
         cpl_data           => cpl_data,
         cpl_mismatch       => cpl_mismatch
      );

   --
   -- Configurator Gen2 Enabler module - interfaces with the Root Port's CFG
   -- interface to initiate up-training to PCIe Gen2 speed
   --

end rtl;


-- cgator
