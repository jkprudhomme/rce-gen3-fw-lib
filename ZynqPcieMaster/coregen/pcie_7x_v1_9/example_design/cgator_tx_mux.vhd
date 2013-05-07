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
-- File       : cgator_tx_mux.vhd
-- Version    : 1.9
--
-- Description : Configurator Tx Mux module - multiplexes between data from
--               Packet Generator and user logic
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

entity cgator_tx_mux is
   generic (
      TCQ                         : integer := 1;
      C_DATA_WIDTH                : integer := 64;
      KEEP_WIDTH                  : integer := 8     );
   port (
      -- globals
      user_clk                    : in std_logic;
      reset                       : in std_logic;

      -- User Tx TRN interface
      usr_s_axis_tx_tready        : out std_logic;
      usr_s_axis_tx_tdata         : in std_logic_vector(C_DATA_WIDTH - 1 downto 0);
      usr_s_axis_tx_tkeep         : in std_logic_vector((C_DATA_WIDTH/8) - 1 downto 0);
      usr_s_axis_tx_tuser         : in std_logic_vector(3 downto 0);
      usr_s_axis_tx_tlast         : in std_logic;
      usr_s_axis_tx_tvalid        : in std_logic;

      -- Packet Generator Tx interface
      pg_s_axis_tx_tready         : out std_logic;
      pg_s_axis_tx_tdata          : in std_logic_vector(C_DATA_WIDTH - 1  downto 0);
      pg_s_axis_tx_tkeep          : in std_logic_vector((C_DATA_WIDTH/8) - 1 downto 0);
      pg_s_axis_tx_tuser          : in std_logic_vector(3 downto 0);
      pg_s_axis_tx_tlast          : in std_logic;
      pg_s_axis_tx_tvalid         : in std_logic;

      -- Root Port Wrapper Tx interface
      rport_tx_cfg_req            : in std_logic;
      rport_tx_cfg_gnt            : in std_logic;
      rport_s_axis_tx_tready      : in std_logic;
      rport_s_axis_tx_tdata       : out std_logic_vector(C_DATA_WIDTH - 1  downto 0);
      rport_s_axis_tx_tkeep       : out std_logic_vector((C_DATA_WIDTH/8) - 1 downto 0);
      rport_s_axis_tx_tuser       : out std_logic_vector(3 downto 0);
      rport_s_axis_tx_tlast       : out std_logic;
      rport_s_axis_tx_tvalid      : out std_logic;

      -- Root port status interface
      rport_tx_buf_av               : in std_logic_vector(5 downto 0);

      -- Controller interface
      config_mode                 : in std_logic;
      config_mode_active          : out std_logic
   );
end cgator_tx_mux;

architecture rtl of cgator_tx_mux is

   -- Local variables
   signal usr_active_start                  : std_logic;
   signal usr_active_end                    : std_logic;
   signal usr_active                        : std_logic;
   signal usr_holdoff                       : std_logic;

   -- Declare intermediate signals for referenced outputs
   signal usr_s_axis_tx_tready_7xpcie       : std_logic;
   signal config_mode_active_7xpcie         : std_logic;

   signal in_packet_q                       : std_logic;
   signal sop                               : std_logic;
   signal pg_s_axis_tx_tready_7xpcie        : std_logic;

begin

  -- Generate a signal that can be used to signal start of packet.

  sop <= not(in_packet_q) and usr_s_axis_tx_tvalid;

  process (user_clk) begin
    if (user_clk'event and user_clk = '1') then
      if (reset = '1') then
        in_packet_q    <= '0' after (TCQ)*1 ps;
      elsif (usr_s_axis_tx_tvalid = '1' and usr_s_axis_tx_tready_7xpcie = '1' and usr_s_axis_tx_tlast = '1') then
        in_packet_q    <= '0' after (TCQ)*1 ps;
      elsif (sop = '1' and usr_s_axis_tx_tready_7xpcie = '1') then
        in_packet_q    <= '1' after (TCQ)*1 ps;
      end if;
    end if;
  end process;


   -- Drive referenced outputs
   usr_s_axis_tx_tready <= usr_s_axis_tx_tready_7xpcie;
   config_mode_active <= config_mode_active_7xpcie;

   -- Determine when user is in the middle of a Tx TLP
   usr_active_start <= sop and usr_s_axis_tx_tvalid and usr_s_axis_tx_tready_7xpcie;
   usr_active_end <= usr_s_axis_tx_tlast and usr_s_axis_tx_tvalid and usr_s_axis_tx_tready_7xpcie;
   process (user_clk)
   begin
      if (user_clk'event and user_clk = '1') then
         if (reset = '1') then
            usr_active <= '0' after (TCQ)*1 ps;
         else
            if (usr_active_start = '1') then
               usr_active <= '1' after (TCQ)*1 ps;
            elsif (usr_active_end = '1') then
               usr_active <= '0' after (TCQ)*1 ps;
            end if;
         end if;
      end if;
   end process;


   --  User dst rdy is the same as rport_tdst_rdy unless
   --  usr_holdoff is asserted. This can happen when:
   --    - config mode is asserted
   --    - trn_tcfg_req_n is asserted and trn_tcfg_gnt_n is asserted
   --    - trn_tbuf_av = 1
   --    AND user is between packets
   process (user_clk)
   begin
      if (user_clk'event and user_clk = '1') then
         if (reset = '1') then
            usr_holdoff <= '1' after (TCQ)*1 ps;
         else
            if (((usr_active = '0') and (usr_active_start= '0')) or (usr_active = '1' and usr_active_end = '1')) then
               -- User logic is between packets

               if ((config_mode = '1' or (rport_tx_cfg_req = '1' and rport_tx_cfg_gnt = '1')) or (rport_tx_buf_av = "000001" and usr_active_end = '1')) then
                  -- If
                  --   configuration mode is requested, or
                  --   an packet is being generated inside the Root Port, or
                  --   the last TX buffer is being consumed
                  -- Then
                  --   prevent user logic from transmitting a new TLP - this
                  --   compensates for the 1-cycle delay between usr_tsrc_rdy and
                  --   rport_tsrc_rdy_n

                  usr_holdoff <= '1' after (TCQ)*1 ps;
               else
                  -- None of the above conditions is true - allow user packets
                  usr_holdoff <= '0' after (TCQ)*1 ps;
               end if;
            else

               -- If user logic is starting or is in the middle of a packet, don't
               -- deassert usr_s_axis_tx_tready
               usr_holdoff <= '0' after (TCQ)*1 ps;
            end if;
         end if;
      end if;
   end process;


   -- Deassert usr_s_axis_tx_tready when above logic determines user cannot transmit,
   -- or when Root Port is not accepting data
   usr_s_axis_tx_tready_7xpcie <= rport_s_axis_tx_tready and (not(usr_holdoff));

   -- Accept entry to config mode when config_mode is asserted and user
   -- has finished any outstanding Tx TLP
   process (user_clk)
   begin
      if (user_clk'event and user_clk = '1') then
         if (reset = '1') then
            config_mode_active_7xpcie <= '0' after (TCQ)*1 ps;
         else
            config_mode_active_7xpcie <= config_mode and usr_holdoff after (TCQ)*1 ps;
         end if;
      end if;
   end process;


   -- dst rdy to Packet Generator is the same as rport_tdst_rdy_n when
   -- config_mode_active is asserted
   pg_s_axis_tx_tready_7xpcie <= rport_s_axis_tx_tready and config_mode_active_7xpcie;
   pg_s_axis_tx_tready <= pg_s_axis_tx_tready_7xpcie;

   -- Data-path mux with one pipeline stage
   process (user_clk)
   begin
      if (user_clk'event and user_clk = '1') then
         if (reset = '1') then
            rport_s_axis_tx_tdata <= (others => '0') after (TCQ)*1 ps;
            rport_s_axis_tx_tkeep <= (others => '0') after (TCQ)*1 ps;
            rport_s_axis_tx_tuser <= (others => '0') after (TCQ)*1 ps;
            rport_s_axis_tx_tlast <= '0' after (TCQ)*1 ps;
            rport_s_axis_tx_tvalid <= '0' after (TCQ)*1 ps;
         else
            if (config_mode_active_7xpcie = '1') then
               rport_s_axis_tx_tdata  <= pg_s_axis_tx_tdata  after (TCQ)*1 ps;
               rport_s_axis_tx_tkeep  <= pg_s_axis_tx_tkeep  after (TCQ)*1 ps;
               rport_s_axis_tx_tuser  <= pg_s_axis_tx_tuser  after (TCQ)*1 ps;
               rport_s_axis_tx_tlast  <= pg_s_axis_tx_tlast  after (TCQ)*1 ps;
               rport_s_axis_tx_tvalid <= (pg_s_axis_tx_tvalid and pg_s_axis_tx_tready_7xpcie) after (TCQ)*1 ps;
            else
               rport_s_axis_tx_tdata  <= usr_s_axis_tx_tdata after (TCQ)*1 ps;
               rport_s_axis_tx_tkeep  <= usr_s_axis_tx_tkeep after (TCQ)*1 ps;
               rport_s_axis_tx_tuser  <= usr_s_axis_tx_tuser after (TCQ)*1 ps;
               rport_s_axis_tx_tlast  <= usr_s_axis_tx_tlast after (TCQ)*1 ps;
               rport_s_axis_tx_tvalid <= (usr_s_axis_tx_tvalid and usr_s_axis_tx_tready_7xpcie) after (TCQ)*1 ps;
            end if;
         end if;
      end if;
   end process;


end rtl;



-- cgator_tx_mux
