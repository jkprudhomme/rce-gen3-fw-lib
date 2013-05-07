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
-- File       : pio_master_checker.vhd
-- Version    : 1.9
--
-- Description : PIO Master Checker module - consumes incoming TLPs and
--               verifies that all completion fields match what is expected.
--               Header and data fields to check against are provided by
--               Controller module
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

entity pio_master_checker is
   generic (
      TCQ                                          : integer := 1;
      REQUESTER_ID                                 : std_logic_vector(15 downto 0) := X"10EE";
      C_DATA_WIDTH                                 : integer := 64;
      KEEP_WIDTH                                   : integer := 8
   );
   port (
      -- globals
      user_clk                                     : in std_logic;
      reset                                        : in std_logic;

      -- Rx AXI interface
      m_axis_rx_tlast                              : in std_logic;
      m_axis_rx_tdata                              : in std_logic_vector((C_DATA_WIDTH-1) downto 0);
      m_axis_rx_tkeep                              : in std_logic_vector((KEEP_WIDTH-1) downto 0);
      m_axis_rx_tuser                              : in std_logic_vector (21 downto 0);
      m_axis_rx_tvalid                             : in std_logic;

      -- Controller interface
      rx_type                                      : in std_logic;      -- see RX_TYPE_* below for encoding
      rx_tag                                       : in std_logic_vector(7 downto 0);
      rx_data                                      : in std_logic_vector(31 downto 0);
      rx_good                                      : out std_logic;
      rx_bad                                       : out std_logic
   );
end pio_master_checker;

architecture rtl of pio_master_checker is

   FUNCTION to_stdlogic (
      in_val      : IN boolean) RETURN std_logic IS
   BEGIN
      IF (in_val) THEN
         RETURN('1');
      ELSE
         RETURN('0');
      END IF;
   END to_stdlogic;

      -- Bit-slicing positions
   constant FMT_TYPE_HI                                  : integer := 30;
   constant FMT_TYPE_LO                                  : integer := 24;
   constant CPL_STAT_HI                                  : integer := 47;
   constant CPL_STAT_LO                                  : integer := 45;
   constant CPL_DATA_HI                                  : integer := 63;
   constant CPL_DATA_LO                                  : integer := 32;
   constant REQ_ID_HI                                    : integer := 31;
   constant REQ_ID_LO                                    : integer := 16;
   constant TAG_HI                                       : integer := 15;
   constant TAG_LO                                       : integer :=  8;

   constant CPL_DATA_HI_128                              : integer := 127;
   constant CPL_DATA_LO_128                              : integer := 96;
   constant REQ_ID_HI_128                                : integer := 95;
   constant REQ_ID_LO_128                                : integer := 80;
   constant TAG_HI_128                                   : integer := 79;
   constant TAG_LO_128                                   : integer := 72;

   -- Static field values for comparison
   constant FMT_TYPE_CPLX                                : std_logic_vector(5 downto 0) := "001010";
   constant SC_STATUS                                    : std_logic_vector(2 downto 0) := "000";
   constant UR_STATUS                                    : std_logic_vector(2 downto 0) := "001";
   constant CRS_STATUS                                   : std_logic_vector(2 downto 0) := "010";
   constant CA_STATUS                                    : std_logic_vector(2 downto 0) := "100";

      -- TLP type encoding for rx_type - same as high bit of Format field
   constant RX_TYPE_CPL                                  : std_logic := '0';
   constant RX_TYPE_CPLD                                 : std_logic := '1';

      -- Local registers for processing incoming completions
   signal cpl_status_good                              : std_logic;
   signal cpl_type_match                               : std_logic;
   signal cpl_detect                                   : std_logic;
   signal cpl_detect_q                                 : std_logic;
   signal cpl_data_match                               : std_logic;
   signal cpl_reqid_match                              : std_logic;
   signal cpl_tag_match                                : std_logic;

   signal sop                                          : std_logic;
   signal in_packet_q                                  : std_logic;

begin

  in_pkt_width_64 : if C_DATA_WIDTH = 64 generate
  begin

    process (user_clk)
    begin
      if (user_clk'event and user_clk = '1') then
        if (reset = '1') then
          in_packet_q <= '0' after (TCQ)*1 ps;
        elsif ((m_axis_rx_tvalid = '1') and (m_axis_rx_tlast = '1')) then
            in_packet_q <= '0' after (TCQ)*1 ps;
        elsif (sop = '1') then
            in_packet_q <= '1' after (TCQ)*1 ps;
        end if;
      end if;
    end process;

    -- Create a start of packet indicator
    sop <= ((not(in_packet_q)) and (m_axis_rx_tvalid));
  end generate;

  in_pkt_width_128 : if C_DATA_WIDTH /= 64 generate
  begin

    process (user_clk)
    begin
      if (user_clk'event and user_clk = '1') then
        if (reset = '1') then
          in_packet_q <= '0' after (TCQ)*1 ps;
        elsif ((m_axis_rx_tvalid = '1') and (m_axis_rx_tuser(21) = '1')) then
          in_packet_q <= '0' after (TCQ)*1 ps;
        elsif (sop = '1') then
          in_packet_q <= '1' after (TCQ)*1 ps;
        end if;
      end if;
    end process;

    -- Create a start of packet indicator
    sop <= ((not in_packet_q) and m_axis_rx_tuser(14) and m_axis_rx_tvalid);
  end generate;

  width_64 : if C_DATA_WIDTH = 64 generate
  begin

    -- Process first Quad-word (two dwords) of received TLPs: Determine whether
    --   - TLP is a Completion
    --   - Type of completion matches expected
    --   - Completion status is "Successful Completion"
    process (user_clk)
    begin
       if (user_clk'event and user_clk = '1') then
          if (reset = '1') then
             cpl_status_good <= '0' after (TCQ)*1 ps;
             cpl_type_match  <= '0' after (TCQ)*1 ps;
             cpl_detect      <= '0' after (TCQ)*1 ps;
          else
             if (sop = '1') then
                -- Check for beginning of Completion TLP - cpl_detect is asserted for
                -- Completion to indicate to later pipeline stages whether to continue
                -- processing data
                if (m_axis_rx_tdata(FMT_TYPE_HI - 1 downto FMT_TYPE_LO) = FMT_TYPE_CPLX) then
                   cpl_detect <= '1' after (TCQ)*1 ps;
                else
                   cpl_detect <= '0' after (TCQ)*1 ps;
                end if;

                -- Compare type and completion status with expected
                cpl_type_match  <= to_stdlogic((m_axis_rx_tdata(FMT_TYPE_HI) = rx_type)) after (TCQ)*1 ps;

                cpl_status_good <= to_stdlogic((m_axis_rx_tdata(CPL_STAT_HI downto CPL_STAT_LO) = SC_STATUS)) after (TCQ)*1 ps;
             else
                cpl_detect <= '0' after (TCQ)*1 ps;
             end if;
          end if;
       end if;
    end process;


    -- Process second Quad-word of received TLPs: Determine whether
    --   - Data matches expected value
    --   - Requester ID matches expected value
    --   - Tag matches expected value
    process (user_clk)
    begin
       if (user_clk'event and user_clk = '1') then
          if (reset = '1') then
             cpl_detect_q    <= '0' after (TCQ)*1 ps;
             cpl_data_match  <= '0' after (TCQ)*1 ps;
             cpl_reqid_match <= '0' after (TCQ)*1 ps;
             cpl_tag_match   <= '0' after (TCQ)*1 ps;
          else
             -- Pipeline cpl_detect signal
             cpl_detect_q    <= cpl_detect after (TCQ)*1 ps;

             -- Check fields for match
             cpl_data_match  <= to_stdlogic((m_axis_rx_tdata(CPL_DATA_HI downto CPL_DATA_LO) = rx_data)) after (TCQ)*1 ps;
             cpl_reqid_match <= to_stdlogic((m_axis_rx_tdata(REQ_ID_HI downto REQ_ID_LO) = REQUESTER_ID)) after (TCQ)*1 ps;
             cpl_tag_match   <= to_stdlogic((m_axis_rx_tdata(TAG_HI downto TAG_LO) = rx_tag)) after (TCQ)*1 ps;
          end if;
       end if;
    end process;


    -- After second QW is processed, check whether all fields matched expected
    -- and output results
    process (user_clk)
    begin
       if (user_clk'event and user_clk = '1') then
          if (reset = '1') then
             rx_good <= '0' after (TCQ)*1 ps;
             rx_bad <= '0' after (TCQ)*1 ps;
          else
             if (cpl_detect_q = '1') then
                if ((cpl_type_match and cpl_status_good and cpl_reqid_match and cpl_tag_match) = '1') then
                   if (cpl_data_match = '1' or (rx_type = RX_TYPE_CPL)) then
                      -- Header and data match, or header match and no data expected

                      rx_good <= '1' after (TCQ)*1 ps;
                   else
                      -- Data mismatch
                      rx_bad <= '1' after (TCQ)*1 ps;
                   end if;
                else

                   -- Header mismatch
                   rx_bad <= '1' after (TCQ)*1 ps;
                end if;
             else

                -- Not checking this cycle
                rx_good <= '0' after (TCQ)*1 ps;
                rx_bad <= '0' after (TCQ)*1 ps;
             end if;
          end if;
       end if;
    end process;
  end generate;

  width_128 : if C_DATA_WIDTH = 128 generate
  begin

    -- Process first 2 QW's (4 DW's) of received TLPs: Determine whether
    --   - TLP is a Completion
    --   - Type of completion matches expected
    --   - Completion status is "Successful Completion"
    process (user_clk) 
    begin
       
      if (user_clk'event and user_clk = '1') then
        if (reset = '1') then
          cpl_status_good   <= '0' after (TCQ)*1 ps;
          cpl_type_match    <= '0' after (TCQ)*1 ps;
          cpl_detect        <= '0' after (TCQ)*1 ps;
          cpl_data_match    <= '0' after (TCQ)*1 ps;
          cpl_reqid_match   <= '0' after (TCQ)*1 ps;
          cpl_tag_match     <= '0' after (TCQ)*1 ps;
          cpl_detect_q      <= '0' after (TCQ)*1 ps;
        else
          if (sop = '1') then
            -- Check for beginning of Completion TLP and process entire packet in 1 clock
            if (m_axis_rx_tdata(FMT_TYPE_HI-1 downto FMT_TYPE_LO) = FMT_TYPE_CPLX) then
              cpl_detect      <= '1' after (TCQ)*1 ps;
            else
              cpl_detect      <= '0' after (TCQ)*1 ps;
            end if;
  
            -- Compare type and completion status with expected
            cpl_data_match  <= to_stdlogic(
                                 (m_axis_rx_tdata(CPL_DATA_HI_128 downto CPL_DATA_LO_128) = rx_data)) after (TCQ)*1 ps;
            cpl_reqid_match <= to_stdlogic(
                                 (m_axis_rx_tdata(REQ_ID_HI_128 downto REQ_ID_LO_128) = REQUESTER_ID)) after (TCQ)*1 ps;
            cpl_tag_match   <= to_stdlogic((m_axis_rx_tdata(TAG_HI_128 downto TAG_LO_128) = rx_tag)) after (TCQ)*1 ps;
            cpl_type_match  <= to_stdlogic((m_axis_rx_tdata(FMT_TYPE_HI) = rx_type)) after (TCQ)*1 ps;
            cpl_status_good <= to_stdlogic(
                                 (m_axis_rx_tdata(CPL_STAT_HI downto CPL_STAT_LO) = SC_STATUS)) after (TCQ)*1 ps;
          else
            cpl_status_good   <= '0' after (TCQ)*1 ps;
            cpl_type_match    <= '0' after (TCQ)*1 ps;
            cpl_detect        <= '0' after (TCQ)*1 ps;
            cpl_data_match    <= '0' after (TCQ)*1 ps;
            cpl_reqid_match   <= '0' after (TCQ)*1 ps;
            cpl_tag_match     <= '0' after (TCQ)*1 ps;
          end if;
        end if;
      end if;
    end process;

    -- After TLP is processed, check whether all fields matched expected and output results
    process (user_clk) 
    begin
             
      if (user_clk'event and user_clk = '1') then
        if (reset = '1') then
          rx_good           <= '0' after (TCQ)*1 ps;
          rx_bad            <= '0' after (TCQ)*1 ps;
        else
          if (cpl_detect = '1') then
            if (cpl_type_match = '1' and cpl_status_good = '1' and cpl_reqid_match = '1' and cpl_tag_match = '1') then
              if (cpl_data_match = '1' or (rx_type = RX_TYPE_CPL)) then
                -- Header and data match, or header match and no data expected
                rx_good      <= '1' after (TCQ)*1 ps;
              else
                -- Data mismatch
                rx_bad       <= '1' after (TCQ)*1 ps;
              end if;
            else
              -- Header mismatch
              rx_bad         <= '1' after (TCQ)*1 ps;
            end if;
          else
            -- Not checking this cycle
            rx_good          <= '0' after (TCQ)*1 ps;
            rx_bad           <= '0' after (TCQ)*1 ps;
          end if;
        end if;
      end if;
    end process;  
  end generate;


end rtl;



-- pio_master_checker
