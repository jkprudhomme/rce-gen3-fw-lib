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
-- File       : pio_master_pkt_generator.vhd
-- Version    : 1.9
--
-- Description : PIO Master Packet Generator module - generates downstream TLPs
--               as directed by the Controller module. Type and contents for
--               variable fields are specified via the tx_* inputs.
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

entity pio_master_pkt_generator is
   generic (
      TCQ                                          : integer := 1;
      REQUESTER_ID                                 : std_logic_vector(15 downto 0) := X"10EE";
      C_DATA_WIDTH                                 : integer := 64;
      KEEP_WIDTH                                   : integer := 8
   );
   port (
      -- Globals
      user_clk                                     : in std_logic;
      reset                                        : in std_logic;

      -- Tx TRN interface
      s_axis_tx_tlast                              : out std_logic;
      s_axis_tx_tdata                              : out std_logic_vector((C_DATA_WIDTH-1) downto 0);
      s_axis_tx_tkeep                              : out std_logic_vector((KEEP_WIDTH-1) downto 0);
      s_axis_tx_tuser                              : out std_logic_vector(3 downto 0);
      s_axis_tx_tvalid                             : out std_logic;
      s_axis_tx_tready                             : in std_logic;

      -- Controller interface
      tx_type                                      : in std_logic_vector(2 downto 0);      -- see TX_TYPE_* below for encoding
      tx_tag                                       : in std_logic_vector(7 downto 0);
      tx_addr                                      : in std_logic_vector(63 downto 0);
      tx_data                                      : in std_logic_vector(31 downto 0);
      tx_start                                     : in std_logic;
      tx_done                                      : out std_logic
   );
end pio_master_pkt_generator;

architecture rtl of pio_master_pkt_generator is

      -- TLP type encoding for tx_type
   constant TYPE_MEMRD32                           : std_logic_vector(2 downto 0) := "000";
   constant TYPE_MEMWR32                           : std_logic_vector(2 downto 0) := "001";
   constant TYPE_MEMRD64                           : std_logic_vector(2 downto 0) := "010";
   constant TYPE_MEMWR64                           : std_logic_vector(2 downto 0) := "011";
   constant TYPE_IORD                              : std_logic_vector(2 downto 0) := "100";
   constant TYPE_IOWR                              : std_logic_vector(2 downto 0) := "101";

      -- State encoding
   constant ST_IDLE                                : std_logic_vector(1 downto 0) := "00";
   constant ST_CYC1                                : std_logic_vector(1 downto 0) := "01";
   constant ST_CYC2                                : std_logic_vector(1 downto 0) := "10";
   constant ST_CYC3                                : std_logic_vector(1 downto 0) := "11";
   -- State variable
   signal pkt_state                                : std_logic_vector(1 downto 0);

   -- Registers to store format and type bits of the TLP header
   signal pkt_fmt                                  : std_logic_vector(1 downto 0);
   signal pkt_type                                 : std_logic_vector(4 downto 0);
   -- X-HDL generated signals

   signal tx_tlast   : std_logic;
   signal addr_64bit : std_logic_vector(63 downto 0);
   signal tx_tkeep   : std_logic_vector((KEEP_WIDTH-1) downto 0);
   
begin

  width_64 : if C_DATA_WIDTH = 64 generate 
  begin
  
    -- Packet Generator State-machine - responsible for hand-shake
    -- with Controller module and selecting which QW of the packet is
    -- transmitted
    process (user_clk)
    begin
      if (user_clk'event and user_clk = '1') then
        if (reset = '1') then
          pkt_state <= ST_IDLE after (TCQ)*1 ps;
          tx_done <= '0' after (TCQ)*1 ps;
        else
          case pkt_state is
            when ST_IDLE =>
              -- Waiting for input from Controller module
    
              tx_done <= '0' after (TCQ)*1 ps;
              if (tx_start = '1') then
                pkt_state <= ST_CYC1 after (TCQ)*1 ps;
              end if;
              -- ST_IDLE
    
            when ST_CYC1 =>
              -- First Quad-word - wait for data to be accepted by core
    
              if (s_axis_tx_tready = '1') then
                pkt_state <= ST_CYC2 after (TCQ)*1 ps;
              end if;
              -- ST_CYC1
    
            when ST_CYC2 =>
              -- Second Quad-word - wait for data to be accepted by core
    
              if (s_axis_tx_tready = '1') then
                if (tx_type = TYPE_MEMWR64) then
                  -- A MemWr64 TLP uses half of the third Quad-word
    
                  pkt_state <= ST_CYC3 after (TCQ)*1 ps;
                else
                  -- All non-MemWr64 TLPs end here
    
                  pkt_state <= ST_IDLE after (TCQ)*1 ps;
                  tx_done <= '1' after (TCQ)*1 ps;
                end if;
              end if;
              -- ST_CYC2
    
            when ST_CYC3 =>
              -- Third Quad-word - wait for data to be accepted by core
    
              if (s_axis_tx_tready = '1') then
                pkt_state <= ST_IDLE after (TCQ)*1 ps;
                tx_done <= '1' after (TCQ)*1 ps;
              end if;
              -- ST_CYC3
    
            when others =>
              pkt_state <= ST_IDLE after (TCQ)*1 ps;
              -- default case
          end case;
        end if;
      end if;
    end process;
    
    
     -- Compute Format and Type fields from type of TLP requested
    process (user_clk)
    begin
      if (user_clk'event and user_clk = '1') then
        if (reset = '1') then
          pkt_fmt <= "00" after (TCQ)*1 ps;
          pkt_type <= "00000" after (TCQ)*1 ps;
        else
          case tx_type is
            when TYPE_MEMRD32 =>
              pkt_fmt <= "00" after (TCQ)*1 ps;
              pkt_type <= "00000" after (TCQ)*1 ps;
            when TYPE_MEMWR32 =>
              pkt_fmt <= "10" after (TCQ)*1 ps;
              pkt_type <= "00000" after (TCQ)*1 ps;
            when TYPE_MEMRD64 =>
              pkt_fmt <= "01" after (TCQ)*1 ps;
              pkt_type <= "00000" after (TCQ)*1 ps;
            when TYPE_MEMWR64 =>
              pkt_fmt <= "11" after (TCQ)*1 ps;
              pkt_type <= "00000" after (TCQ)*1 ps;
            when TYPE_IORD =>
              pkt_fmt <= "00" after (TCQ)*1 ps;
              pkt_type <= "00010" after (TCQ)*1 ps;
            when TYPE_IOWR =>
              pkt_fmt <= "10" after (TCQ)*1 ps;
              pkt_type <= "00010" after (TCQ)*1 ps;
            when others =>
              pkt_fmt <= "00" after (TCQ)*1 ps;
              pkt_type <= "00000" after (TCQ)*1 ps;
          end case;
        end if;
      end if;
    end process;
    
    
     -- Static Transaction Interface outputs
     s_axis_tx_tuser(2) <= '1'; -- Enable Streaming
     s_axis_tx_tuser(1) <= '0';
     s_axis_tx_tuser(3) <= '0';
     s_axis_tx_tuser(0) <= '0';
    
    
     tx_tlast <= '0' when (tx_type = TYPE_MEMWR64) else
                       '1';
     addr_64bit <= (tx_addr(31 downto 2) & "00" & tx_addr(63 downto 32)) when (tx_type = TYPE_MEMRD64 or tx_type = TYPE_MEMWR64) else    -- 64-bit address
                       (tx_data & tx_addr(31 downto 2) & "00");   -- 32-bit address
    
     tx_tkeep <= "00001111" when (tx_type = TYPE_MEMRD32 or tx_type = TYPE_IORD) else
                       "11111111";
    
    -- Packet generation output - combinatorial output using current state to
     -- select which fields to output
    process (pkt_state, pkt_fmt, pkt_type, tx_tag, tx_type, tx_addr, tx_data, tx_tlast, addr_64bit, tx_tkeep)
    begin
      case pkt_state is
        when ST_IDLE =>
    
          s_axis_tx_tlast <= '0';
          s_axis_tx_tdata <= (others => '0');
          s_axis_tx_tkeep <= (others => '0');
          s_axis_tx_tvalid <= '0';
          -- ST_IDLE
    
        when ST_CYC1 =>
          -- First QW (two dwords) of TLP
    
          s_axis_tx_tlast <= '0';
          s_axis_tx_tdata <= (REQUESTER_ID & tx_tag & "0000" & "1111" & '0' & pkt_fmt & pkt_type & "00000000" & "0000" & "00" & "0000000001");
          -- Reserved, Format, Type, Reserved, TC, Reserved, TD, EP, Attr, Reserved,
          -- Length, Requester ID, Tag, Last DW BE, First DW BE
          s_axis_tx_tkeep <= (others => '1');
          s_axis_tx_tvalid <= '1';
          -- ST_CYC1
    
        when ST_CYC2 =>
          -- Second QW of TLP - either address (for 64-bit transactions) or
          -- address + data (for 32-bit transactions). For MemRd32 or IORd
          -- TLPs, the tx_data field is ignored by the core because s_axis_tx_tkeep
          -- is deasserted.
    
          s_axis_tx_tlast <= tx_tlast;  -- RP currently supports 64-bit width
          s_axis_tx_tdata <= addr_64bit;  -- RP currently supports 64-bit width
          s_axis_tx_tkeep <= tx_tkeep;  -- RP Currently supports 64-bit width
          s_axis_tx_tvalid <= '1';
          -- ST_CYC2
    
        when ST_CYC3 =>
          -- Third QW of TLP - only used for MemWr64; only upper 32-bits are
          -- used
    
          s_axis_tx_tlast <= '1';
          s_axis_tx_tdata <= (X"00000000" & tx_data);         -- Data, don't-care
          s_axis_tx_tkeep <= "00001111";
          s_axis_tx_tvalid <= '1';
          -- ST_CYC3
    
        when others =>
    
          s_axis_tx_tlast <= '0';
          s_axis_tx_tdata <= (others => '0');
          s_axis_tx_tkeep <= (others => '0');
          s_axis_tx_tvalid <= '0';
          -- default case
      end case;
    end process;
  end generate;
  
  width_128 : if C_DATA_WIDTH /= 64 generate 
  begin
  
    -- 128-bit Packet Generator State-machine - responsible for hand-shake
    -- with Controller module and selecting which QW of the packet is
    -- transmitted
    process(user_clk)
    begin   
        
      if rising_edge(user_clk) then
        if (reset = '1') then
          pkt_state     <= ST_IDLE after (TCQ)*1 ps;
          tx_done       <= '0' after (TCQ)*1 ps;
        else
          case (pkt_state) is
            when ST_IDLE => 
              -- Waiting for input from Controller module
              tx_done        <= '0' after (TCQ)*1 ps;
              if (tx_start = '1') then
                pkt_state    <= ST_CYC1 after (TCQ)*1 ps;
              end if;
            -- ST_IDLE
  
            when ST_CYC1 => 
              -- First Double-Quad-word - wait for data to be accepted by core
              if (s_axis_tx_tready = '1') then
                if (tx_type = TYPE_MEMWR64) then
                  pkt_state    <= ST_CYC2 after (TCQ)*1 ps;
                else
                  pkt_state  <= ST_IDLE after (TCQ)*1 ps;
                  tx_done    <= '1' after (TCQ)*1 ps;
                end if;
              end if;
            --ST_CYC1
  
            when ST_CYC2 => 
              -- Second Quad-word - wait for data to be accepted by core
              if (s_axis_tx_tready = '1') then
                pkt_state  <= ST_IDLE after (TCQ)*1 ps; 
                tx_done    <= '1' after (TCQ)*1 ps;
              end if;
            -- ST_CYC2
  
            when others => 
              pkt_state      <= ST_IDLE after (TCQ)*1 ps;
            -- others case
          end case;
        end if;
      end if;
    end process;

    -- Compute Format and Type fields from type of TLP requested
    process(user_clk)
    begin   
        
      if rising_edge(user_clk) then
        if (reset = '1') then
          pkt_fmt      <= "00"    after (TCQ)*1 ps;
          pkt_type     <= "00000" after (TCQ)*1 ps;
        else
          case (tx_type) is
            when TYPE_MEMRD32 => 
              pkt_fmt  <= "00"    after (TCQ)*1 ps;
              pkt_type <= "00000" after (TCQ)*1 ps;
            when TYPE_MEMWR32 =>
              pkt_fmt  <= "10"    after (TCQ)*1 ps;
              pkt_type <= "00000" after (TCQ)*1 ps;
            when TYPE_MEMRD64 =>
              pkt_fmt  <= "01"    after (TCQ)*1 ps;
              pkt_type <= "00000" after (TCQ)*1 ps;
            when TYPE_MEMWR64 =>
              pkt_fmt  <= "11"    after (TCQ)*1 ps;
              pkt_type <= "00000" after (TCQ)*1 ps;
            when TYPE_IORD =>
              pkt_fmt  <= "00"    after (TCQ)*1 ps;
              pkt_type <= "00010" after (TCQ)*1 ps;
            when TYPE_IOWR =>
              pkt_fmt  <= "10"    after (TCQ)*1 ps;
              pkt_type <= "00010" after (TCQ)*1 ps;
            when others => 
              pkt_fmt  <= "00"    after (TCQ)*1 ps;
              pkt_type <= "00000" after (TCQ)*1 ps;
          end case;
        end if;
      end if;
    end process;

    -- Static Transaction Interface outputs
    s_axis_tx_tuser <= "0100"; -- Enable streaming
    

    
    tx_tlast   <= '0' when (tx_type = TYPE_MEMWR64) else '1';      
    
    addr_64bit <= (tx_addr(31 downto 2) & "00" & tx_addr(63 downto 32)) when 
                    ((tx_type = TYPE_MEMRD64) or (tx_type = TYPE_MEMWR64)) else
                  (tx_data & tx_addr(31 downto 2) & "00");
                  
    tx_tkeep   <= X"0FFF" when (tx_type = TYPE_MEMRD32 or tx_type = TYPE_IORD) else X"FFFF";
    
    
    

    -- Packet generation output - combinatorial output using current state to
    -- select which fields to output
    process(pkt_state, tx_type, tx_tlast, addr_64bit, tx_tag, pkt_fmt, pkt_type, tx_tkeep)
    begin 
    
      case (pkt_state) is
        when ST_IDLE => 
          s_axis_tx_tlast  <= '0';
          s_axis_tx_tdata  <= (others => '0');
          s_axis_tx_tkeep  <= (others => '0');
          s_axis_tx_tvalid <= '0';
        -- ST_IDLE

        when ST_CYC1 => 
          -- First 2 QW's (4 DW's) of TLP

          s_axis_tx_tlast  <= tx_tlast; 
          s_axis_tx_tdata  <= (addr_64bit &                               -- 64-bit address
                            REQUESTER_ID &                               -- Requester ID
                                  tx_tag &                               -- Tag
                                   X"0F" &                               -- Last DW BE, First DW BE
                                     '0' &                               -- Reserved
                                 pkt_fmt &                               -- Format
                                pkt_type &                               -- Type
                                   X"00" &                               -- Reserved, TC, Reserved
                                    X"0" &                               -- TD, EP, Attr
                                    "00" &                               -- Reserved
                               "0000000001");                            -- Length
                             
          s_axis_tx_tkeep  <= tx_tkeep;
          s_axis_tx_tvalid <= '1';
        -- ST_CYC1

        when ST_CYC2 => 
          -- Second 2 QW's of TLP (64-bit MWR only)
          s_axis_tx_tdata  <= X"000000000000000000000000" & tx_data; -- 96-bit zeros & 32-bit data
          s_axis_tx_tkeep  <= X"000F"; 
          s_axis_tx_tvalid <= '1';
          s_axis_tx_tlast  <= '1';
        -- ST_CYC2

        when others => 
          s_axis_tx_tlast  <= '0';
          s_axis_tx_tdata  <= (others => '0');
          s_axis_tx_tkeep  <= (others => '0');
          s_axis_tx_tvalid <= '0';
        -- others case
      end case;
    end process;
  end generate;
  
  

end rtl;


-- pio_master_pkt_generator
