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
-- File       : cgator_cpl_decoder.vhd
-- Version    : 1.9
--
-- Description : Configurator Completion Decoder module - receives incoming
--               TLPs and checks completion status. When in config mode, all
--               received TLPs are consumed by this module. When not in config
--               mode, all TLPs are passed to user logic
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
   use ieee.std_logic_unsigned.all;

entity cgator_cpl_decoder is
   generic (
      TCQ                         : integer := 1;
      EXTRA_PIPELINE              : integer := 1;
      REQUESTER_ID                : std_logic_vector(15 downto 0) := X"10EE";
      C_DATA_WIDTH                : integer := 64;
      KEEP_WIDTH                  : integer := 8

   );
   port (
      -- globals
      user_clk                    : in std_logic;
      reset                       : in std_logic;

      -- Root Port Wrapper Rx interface
      rport_m_axis_rx_tdata       : in std_logic_vector(C_DATA_WIDTH-1 downto 0);
      rport_m_axis_rx_tkeep       : in std_logic_vector((C_DATA_WIDTH / 8) - 1 downto 0);
      rport_m_axis_rx_tuser       : in std_logic_vector(21 downto 0);
      rport_m_axis_rx_tlast       : in std_logic;
      rport_m_axis_rx_tvalid      : in std_logic;
      rport_m_axis_rx_tready      : out std_logic;
      rport_rx_np_ok              : out std_logic;

      -- User Rx TRN interface
      usr_m_axis_rx_tdata         : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
      usr_m_axis_rx_tkeep         : out std_logic_vector((C_DATA_WIDTH / 8) - 1 downto 0);
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
      cpl_mismatch                : out std_logic
   );
end cgator_cpl_decoder;

architecture rtl of cgator_cpl_decoder is

   FUNCTION to_stdlogic (
      in_val      : IN boolean) RETURN std_logic IS
   BEGIN
      IF (in_val) THEN
         RETURN('1');
      ELSE
         RETURN('0');
      END IF;
   END to_stdlogic;

      -- Bit-slicing positions for decoding header fields
   constant FMT_TYPE_HI                 : integer := 30;
   constant FMT_TYPE_LO                 : integer := 24;
   constant CPL_STAT_HI                 : integer := 47;
   constant CPL_STAT_LO                 : integer := 45;
   constant CPL_DATA_HI                 : integer := 63;
   constant CPL_DATA_LO                 : integer := 32;
   constant REQ_ID_HI                   : integer := 31;
   constant REQ_ID_LO                   : integer := 16;

   constant CPL_DATA_HI_128             : integer := 127;
   constant CPL_DATA_LO_128             : integer := 96;
   constant REQ_ID_HI_128               : integer := 95;
   constant REQ_ID_LO_128               : integer := 80;


      -- Static field values for comparison
   constant FMT_TYPE_CPLX               : std_logic_vector(5 downto 0) := "001010";
   constant SC_STATUS                   : std_logic_vector(2 downto 0) := "000";
   constant UR_STATUS                   : std_logic_vector(2 downto 0) := "001";
   constant CRS_STATUS                  : std_logic_vector(2 downto 0) := "010";
   constant CA_STATUS                   : std_logic_vector(2 downto 0) := "100";

   -- Local variables
   signal pipe_m_axis_rx_tdata          : std_logic_vector(C_DATA_WIDTH-1 downto 0);
   signal pipe_m_axis_rx_tkeep          : std_logic_vector((C_DATA_WIDTH / 8) - 1 downto 0);
   signal pipe_m_axis_rx_tuser          : std_logic_vector(21 downto 0);
   signal pipe_m_axis_rx_tlast          : std_logic;
   signal pipe_m_axis_rx_tvalid         : std_logic;
   signal pipe_rx_np_ok                 : std_logic;
   signal pipe_rsop                     : std_logic;

   signal check_rd                      : std_logic_vector(C_DATA_WIDTH-1 downto 0);
   signal check_rsop                    : std_logic;
   signal check_rsrc_rdy                : std_logic;
   signal cpl_status                    : std_logic_vector(2 downto 0);
   signal cpl_detect                    : std_logic;

   signal in_packet_q                   : std_logic;
   signal sop                           : std_logic;

   signal rport_m_axis_rx_tready_int    : std_logic;

   -- X-HDL generated signals

   signal rx_tlast                      : std_logic;
   signal rx_tdata                      : std_logic_vector(C_DATA_WIDTH-1 downto 0);
   signal rx_tkeep                      : std_logic_vector((C_DATA_WIDTH / 8) - 1 downto 0);
   signal rx_tvalid                     : std_logic;
   signal rx_tuser                      : std_logic_vector(21 downto 0);

begin

   -- Dst rdy and rNP OK are always asserted to Root Port wrapper
   rport_m_axis_rx_tready_int <= '1';
   rport_m_axis_rx_tready     <= rport_m_axis_rx_tready_int;
   rport_rx_np_ok             <= '1';



  -- Generate a signal that indicates if we are currently receiving a packet.
  -- This value is one clock cycle delayed from what is actually on the AXIS
  -- data bus.

  in_pkt_width_64 : if C_DATA_WIDTH = 64 generate
  begin

    process (user_clk) begin
      if (user_clk'event and user_clk = '1') then
        if (reset = '1') then
          in_packet_q    <= '0' after (TCQ)*1 ps;
        elsif (rport_m_axis_rx_tvalid = '1' and rport_m_axis_rx_tready_int = '1' and rport_m_axis_rx_tlast = '1') then
          in_packet_q    <= '0' after (TCQ)*1 ps;
        elsif (sop = '1' and rport_m_axis_rx_tready_int = '1') then
          in_packet_q    <= '1' after (TCQ)*1 ps;
        end if;
      end if;
    end process;

    sop <= not(in_packet_q) and rport_m_axis_rx_tvalid;

  end generate;

  in_pkt_width_128 : if C_DATA_WIDTH /= 64 generate
  begin

    process (user_clk) begin
      if (user_clk'event and user_clk = '1') then
        if (reset = '1') then
          in_packet_q    <= '0' after (TCQ)*1 ps;
        elsif (rport_m_axis_rx_tvalid = '1' and rport_m_axis_rx_tready_int = '1' and rport_m_axis_rx_tuser(21) = '1') then
          in_packet_q    <= '0' after (TCQ)*1 ps;
        elsif (sop = '1' and rport_m_axis_rx_tready_int = '1') then
          in_packet_q    <= '1' after (TCQ)*1 ps;
        end if;
      end if;
    end process;

    sop <= (not(in_packet_q) and rport_m_axis_rx_tuser(14) and rport_m_axis_rx_tvalid);

  end generate;


   -- Output to user

   rx_tdata <= pipe_m_axis_rx_tdata when (EXTRA_PIPELINE = 1) else
              rport_m_axis_rx_tdata;

   rx_tkeep <= pipe_m_axis_rx_tkeep when (EXTRA_PIPELINE = 1) else
              rport_m_axis_rx_tkeep;

   rx_tlast <= pipe_m_axis_rx_tlast when (EXTRA_PIPELINE = 1) else
              rport_m_axis_rx_tlast;

   rx_tvalid <= (pipe_m_axis_rx_tvalid and not(config_mode)) when (EXTRA_PIPELINE = 1) else
              (rport_m_axis_rx_tvalid and not(config_mode));

   rx_tuser <= pipe_m_axis_rx_tuser when (EXTRA_PIPELINE = 1) else
              rport_m_axis_rx_tuser;

   -- Data-path with one or two pipeline stages
   process (user_clk)
   begin
     if (user_clk'event and user_clk = '1') then
       if (reset = '1') then
         pipe_m_axis_rx_tdata   <= (others => '0') after (TCQ)*1 ps;
         pipe_m_axis_rx_tkeep   <= (others => '0') after (TCQ)*1 ps;
         pipe_m_axis_rx_tlast   <= '0' after (TCQ)*1 ps;
         pipe_m_axis_rx_tvalid  <= '0' after (TCQ)*1 ps;
         pipe_m_axis_rx_tuser   <= (others => '0') after (TCQ)*1 ps;
         pipe_rx_np_ok          <= '0' after (TCQ)*1 ps;
         pipe_rsop              <= '0' after (TCQ)*1 ps;

         usr_m_axis_rx_tdata    <= (others => '0') after (TCQ)*1 ps;
         usr_m_axis_rx_tkeep    <= (others => '0') after (TCQ)*1 ps;
         usr_m_axis_rx_tlast    <= '0' after (TCQ)*1 ps;
         usr_m_axis_rx_tvalid   <= '0' after (TCQ)*1 ps;
         usr_m_axis_rx_tuser    <= (others => '0') after (TCQ)*1 ps;
       else
         -- Optional pipeline stage (for timing)
         pipe_m_axis_rx_tdata   <=  rport_m_axis_rx_tdata after (TCQ)*1 ps;
         pipe_m_axis_rx_tkeep   <=  rport_m_axis_rx_tkeep after (TCQ)*1 ps;
         pipe_m_axis_rx_tlast   <=  rport_m_axis_rx_tlast after (TCQ)*1 ps;
         pipe_m_axis_rx_tvalid  <=  rport_m_axis_rx_tvalid after (TCQ)*1 ps;
         pipe_m_axis_rx_tuser   <=  rport_m_axis_rx_tuser after (TCQ)*1 ps;
         pipe_rsop              <=  sop after (TCQ)*1 ps;

         usr_m_axis_rx_tdata    <= rx_tdata after (TCQ)*1 ps;
         usr_m_axis_rx_tkeep    <= rx_tkeep after (TCQ)*1 ps;
         usr_m_axis_rx_tlast    <= rx_tlast after (TCQ)*1 ps;
         usr_m_axis_rx_tvalid   <= rx_tvalid after (TCQ)*1 ps;
         usr_m_axis_rx_tuser    <= rx_tuser after (TCQ)*1 ps;
       end if;
     end if;
   end process;


   --
   -- Completion processing
   --

   -- Select input to completion decoder depending on whether extra pipeline
   -- stage is selected
   check_rd             <= pipe_m_axis_rx_tdata when (EXTRA_PIPELINE /= 0) else
                           rport_m_axis_rx_tdata;
   check_rsop           <= pipe_rsop when (EXTRA_PIPELINE /= 0) else
                           sop;
   check_rsrc_rdy       <= pipe_m_axis_rx_tvalid when (EXTRA_PIPELINE /= 0) else
                           rport_m_axis_rx_tvalid;


  width_64 : if C_DATA_WIDTH = 64 generate
  begin

    -- Process first QW of received TLP - Check for Cpl or CplD type and capture
    -- completion status
    process (user_clk)
    begin
      if (user_clk'event and user_clk = '1') then
        if (reset = '1') then
          cpl_status <= "000" after (TCQ)*1 ps;
          cpl_detect <= '0' after (TCQ)*1 ps;
        else
          if (check_rsop = '1' and check_rsrc_rdy = '1') then
            -- Check for Start of Frame

            if (check_rd(FMT_TYPE_HI - 1 downto FMT_TYPE_LO) = FMT_TYPE_CPLX) then
              -- Check Format and Type fields to see whether this is a Cpl or
              -- CplD. If so, set the cpl_detect bit for the next pipeline stage.

              cpl_detect <= '1' after (TCQ)*1 ps;

              -- Capture Completion Status header field
              cpl_status <= check_rd(CPL_STAT_HI downto CPL_STAT_LO) after (TCQ)*1 ps;
            else
              -- Not a Cpl or CplD TLP
              cpl_detect <= '0' after (TCQ)*1 ps;
            end if;
          else

            -- Not start-of-frame
            cpl_detect <= '0' after (TCQ)*1 ps;
          end if;
        end if;
      end if;
    end process;


    -- Process second QW of received TLP - check Requester ID and output
    -- status bits and data Dword
    process (user_clk)
    begin
      if (user_clk'event and user_clk = '1') then
        if (reset = '1') then
          cpl_sc <= '0' after (TCQ)*1 ps;
          cpl_ur <= '0' after (TCQ)*1 ps;
          cpl_crs <= '0' after (TCQ)*1 ps;
          cpl_ca <= '0' after (TCQ)*1 ps;
          cpl_data <= "00000000000000000000000000000000" after (TCQ)*1 ps;
          cpl_mismatch <= '0' after (TCQ)*1 ps;
        else
          if (cpl_detect = '1') then
            -- Only process TLP if previous pipeline stage has determined this is
            -- a Cpl or CplD TLP

            -- Capture data

            cpl_data <= check_rd(CPL_DATA_HI downto CPL_DATA_LO) after (TCQ)*1 ps;

            if (check_rd(REQ_ID_HI downto REQ_ID_LO) = REQUESTER_ID) then
              -- If requester ID matches, check Completion Status field
              cpl_sc <= to_stdlogic(cpl_status = SC_STATUS) after (TCQ)*1 ps;
              cpl_ur <= to_stdlogic(cpl_status = UR_STATUS) after (TCQ)*1 ps;
              cpl_crs <= to_stdlogic(cpl_status = CRS_STATUS) after (TCQ)*1 ps;
              cpl_ca <= to_stdlogic(cpl_status = CA_STATUS) after (TCQ)*1 ps;
              cpl_mismatch <= '0' after (TCQ)*1 ps;
            else
              -- If Requester ID doesn't match, set mismatch indicator
              cpl_sc <= '0' after (TCQ)*1 ps;
              cpl_ur <= '0' after (TCQ)*1 ps;
              cpl_crs <= '0' after (TCQ)*1 ps;
              cpl_ca <= '0' after (TCQ)*1 ps;
              cpl_mismatch <= '1' after (TCQ)*1 ps;
            end if;
          else

            -- If this isn't the 2nd QW of a Cpl or CplD, do nothing
            cpl_sc <= '0' after (TCQ)*1 ps;
            cpl_ur <= '0' after (TCQ)*1 ps;
            cpl_crs <= '0' after (TCQ)*1 ps;
            cpl_ca <= '0' after (TCQ)*1 ps;
            cpl_mismatch <= '0' after (TCQ)*1 ps;
          end if;
        end if;
      end if;
    end process;
  end generate;


  width_128 : if C_DATA_WIDTH /= 64 generate
  begin

    -- Process first 2 QW's of received TLP - Check for Cpl or CplD type and capture
    -- completion status
    process (user_clk)
    begin
      if (user_clk'event and user_clk = '1') then
        if (reset = '1') then
          cpl_status     <= "000" after (TCQ)*1 ps;
          cpl_detect     <= '0' after (TCQ)*1 ps;
          cpl_sc         <= '0' after (TCQ)*1 ps;
          cpl_ur         <= '0' after (TCQ)*1 ps;
          cpl_crs        <= '0' after (TCQ)*1 ps;
          cpl_ca         <= '0' after (TCQ)*1 ps;
          cpl_data       <= (others => '0') after (TCQ)*1 ps;
          cpl_mismatch   <= '0' after (TCQ)*1 ps;
        else
          cpl_detect     <= '0' after (TCQ)*1 ps; -- Unused in 128-bit mode
          if (check_rsop = '1' and check_rsrc_rdy = '1') then
            -- Check for Start of Frame

            if (check_rd(FMT_TYPE_HI-1 downto FMT_TYPE_LO) = FMT_TYPE_CPLX) then

              if (check_rd(REQ_ID_HI_128 downto REQ_ID_LO_128) = REQUESTER_ID) then
                --  If requester ID matches, check Completion Status field
                cpl_sc       <= to_stdlogic((check_rd(CPL_STAT_HI downto CPL_STAT_LO) = SC_STATUS)) after (TCQ)*1 ps;
                cpl_ur       <= to_stdlogic((check_rd(CPL_STAT_HI downto CPL_STAT_LO) = UR_STATUS)) after (TCQ)*1 ps;
                cpl_crs      <= to_stdlogic((check_rd(CPL_STAT_HI downto CPL_STAT_LO) = CRS_STATUS)) after (TCQ)*1 ps;
                cpl_ca       <= to_stdlogic((check_rd(CPL_STAT_HI downto CPL_STAT_LO) = CA_STATUS)) after (TCQ)*1 ps;
                cpl_mismatch <= '0' after (TCQ)*1 ps;
              else
                cpl_sc       <= '0' after (TCQ)*1 ps;
                cpl_ur       <= '0' after (TCQ)*1 ps;
                cpl_crs      <= '0' after (TCQ)*1 ps;
                cpl_ca       <= '0' after (TCQ)*1 ps;
                cpl_mismatch <= '1' after (TCQ)*1 ps;
              end if;

              -- Capture data
              cpl_data       <= check_rd(CPL_DATA_HI_128 downto CPL_DATA_LO_128);

            else
                -- Not a Cpl or CplD TLP
                cpl_data     <= (others => '0') after (TCQ)*1 ps;
                cpl_sc       <= '0' after (TCQ)*1 ps;
                cpl_ur       <= '0' after (TCQ)*1 ps;
                cpl_crs      <= '0' after (TCQ)*1 ps;
                cpl_ca       <= '0' after (TCQ)*1 ps;
                cpl_mismatch <= '0' after (TCQ)*1 ps;
            end if;
          else
            -- Not start-of-frame
            cpl_data     <= (others => '0') after (TCQ)*1 ps;
            cpl_sc       <= '0' after (TCQ)*1 ps;
            cpl_ur       <= '0' after (TCQ)*1 ps;
            cpl_crs      <= '0' after (TCQ)*1 ps;
            cpl_ca       <= '0' after (TCQ)*1 ps;
            cpl_mismatch <= '0' after (TCQ)*1 ps;
          end if;
        end if;
      end if;
    end process;
  end generate;

end rtl;

-- cgator_cpl_decoder
