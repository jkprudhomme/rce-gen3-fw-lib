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
-- File       : cgator_controller.vhd
-- Version    : 1.9
--
-- Description : Configurator Controller module - directs configuration of
--               Endpoint connected to the local Root Port. Configuration
--               steps are read from the file specified by the ROM_FILE
--               parameter. This module directs the Packet Generator module to
--               create downstream TLPs and receives decoded Completion TLP
--               information from the Completion Decoder module. Additionally,
--               in a Gen2-speec-capable system, the Gen2 Enabler module
--               directs the Root Port block to up-configure the link after
--               Link Training completes.
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
   use ieee.std_logic_textio.all;
   use ieee.std_logic_arith.all;

library std;
use std.textio.all;

entity cgator_controller is
   generic (
      TCQ                         : integer := 1;
      ROM_FILE                    : string := "cgator_cfg_rom.data";		-- Location of configuration rom data file
      ROM_SIZE                    : integer := 26  	                	-- Number of entries in configuration rom
   );
   port (
      -- globals
      user_clk                    : in std_logic;
      reset                       : in std_logic;

      -- User interface
      start_config                : in std_logic;
      finished_config             : out std_logic;
      failed_config               : out std_logic;

      -- Packet Generator interface
      pkt_type                    : out std_logic_vector(1 downto 0);      -- See TYPE_* below for encoding
      pkt_func_num                : out std_logic_vector(1 downto 0);
      pkt_reg_num                 : out std_logic_vector(9 downto 0);
      pkt_1dw_be                  : out std_logic_vector(3 downto 0);
      pkt_msg_routing             : out std_logic_vector(2 downto 0);
      pkt_msg_code                : out std_logic_vector(7 downto 0);
      pkt_data                    : out std_logic_vector(31 downto 0);
      pkt_start                   : out std_logic;
      pkt_done                    : in std_logic;

      -- Tx Mux and Completion Decoder interface
      config_mode                 : out std_logic;
      config_mode_active          : in std_logic;
      cpl_sc                      : in std_logic;
      cpl_ur                      : in std_logic;
      cpl_crs                     : in std_logic;
      cpl_ca                      : in std_logic;
      cpl_data                    : in std_logic_vector(31 downto 0);
      cpl_mismatch                : in std_logic
   );
end cgator_controller;

architecture rtl of cgator_controller is

      -- Encodings for pkt_type output
   constant TYPE_CFGRD                  : std_logic_vector(1 downto 0) := "00";
   constant TYPE_CFGWR                  : std_logic_vector(1 downto 0) := "01";
   constant TYPE_MSG                    : std_logic_vector(1 downto 0) := "10";
   constant TYPE_MSGD                   : std_logic_vector(1 downto 0) := "11";

      -- State encodings
   constant ST_IDLE                     : std_logic_vector(2 downto 0) := "000";
   constant ST_WAIT_CFG                 : std_logic_vector(2 downto 0) := "001";
   constant ST_WAIT_SPD                 : std_logic_vector(2 downto 0) := "010";
   constant ST_READ1                    : std_logic_vector(2 downto 0) := "011";
   constant ST_READ2                    : std_logic_vector(2 downto 0) := "100";
   constant ST_WAIT_PKT                 : std_logic_vector(2 downto 0) := "101";
   constant ST_WAIT_CPL                 : std_logic_vector(2 downto 0) := "110";
   constant ST_DONE                     : std_logic_vector(2 downto 0) := "111";

      -- Width of ROM address, calculated from depth
  function width (
    constant ROM_SIZE   : integer)
    return integer is
     variable ROM_ADDR_WIDTH : integer := 1;
  begin  -- width

    if ((ROM_SIZE - 1) < 2) then
      ROM_ADDR_WIDTH := 1;
    elsif ((ROM_SIZE - 1) < 4) then
      ROM_ADDR_WIDTH := 2;
    elsif ((ROM_SIZE - 1) < 8) then
      ROM_ADDR_WIDTH := 3;
    elsif ((ROM_SIZE - 1) < 16) then
      ROM_ADDR_WIDTH := 4;
    elsif ((ROM_SIZE - 1) < 32) then
      ROM_ADDR_WIDTH := 5;
    elsif ((ROM_SIZE - 1) < 64) then
      ROM_ADDR_WIDTH := 6;
    elsif ((ROM_SIZE - 1) < 128) then
      ROM_ADDR_WIDTH := 7;
    elsif ((ROM_SIZE - 1) < 256) then
      ROM_ADDR_WIDTH := 8;
    elsif ((ROM_SIZE - 1) < 512) then
      ROM_ADDR_WIDTH := 9;
    elsif ((ROM_SIZE - 1) < 1024) then
      ROM_ADDR_WIDTH := 10;
    else
      ROM_ADDR_WIDTH := 11;
    end if;
    return ROM_ADDR_WIDTH;
  end width;

   constant ROM_ADDR_WIDTH              : integer := width(ROM_SIZE);

      -- Bit-slicing constants for ROM output data
   constant PKT_TYPE_HI                 : integer := 17;
   constant PKT_TYPE_LO                 : integer := 16;
   constant PKT_FUNC_NUM_HI             : integer := 15;
   constant PKT_FUNC_NUM_LO             : integer := 14;
   constant PKT_REG_NUM_HI              : integer := 13;
   constant PKT_REG_NUM_LO              : integer := 4;
   constant PKT_1DW_BE_HI               : integer := 3;
   constant PKT_1DW_BE_LO               : integer := 0;
   constant PKT_MSG_ROUTING_HI          : integer := 10;		-- Overlaps with REG_NUM/1DW_BE
   constant PKT_MSG_ROUTING_LO          : integer := 8;		-- Overlaps with REG_NUM/1DW_BE
   constant PKT_MSG_CODE_HI             : integer := 7;		-- Overlaps with REG_NUM/1DW_BE
   constant PKT_MSG_CODE_LO             : integer := 0;		-- Overlaps with REG_NUM/1DW_BE
   constant PKT_DATA_HI                 : integer := 31;
   constant PKT_DATA_LO                 : integer := 0;

  FUNCTION to_integer (
      val_in      : std_logic_vector) RETURN integer IS

      CONSTANT vec_val      : std_logic_vector(val_in'high-val_in'low DOWNTO 0) := val_in;
      VARIABLE ret          : integer := 0;
   BEGIN
      FOR i IN vec_val'RANGE LOOP
         IF (vec_val(i) = '1') THEN
            ret := ret + (2**i);
         END IF;
      END LOOP;
      RETURN(ret);
   END to_integer;

   type rom_type is array (0 to ROM_SIZE - 1) of std_logic_vector(31 downto 0);

   -- Initialize ROM from file
   -- Load user-supplied configuration data into configuration ROM.
   impure function InitRomFromFile (
     RomFileName : string;
     RomSize : integer)              -- rom file initialization data file
     return rom_type is
     file RomFile : text open read_mode is RomFileName;
     variable RomFileLine : line;
     variable ROM : rom_type;
     variable i : integer := 0;
   begin  -- InitRomFromFile
     while ((not endfile(RomFile)) and (i < RomSize)) loop
       readline (RomFile, RomFileLine);
   --    if RomFileLine(1) = '/' then
   --      next;
   --    end if;
       read (RomFileLine, ROM(i));
       i := i + 1;
     end loop;
     return ROM;
   end InitRomFromFile;

   -- ROM instantiation
   signal ctl_rom                           : rom_type := InitRomFromFile(ROM_FILE, ROM_SIZE);

   -- Local variables
   signal ctl_state                         : std_logic_vector(2 downto 0);
   signal ctl_addr                          : std_logic_vector(ROM_ADDR_WIDTH - 1 downto 0);
   signal ctl_data                          : std_logic_vector(31 downto 0);
   signal ctl_last_cfg                      : std_logic;
   signal ctl_skip_cpl                      : std_logic;
   signal ctl_last_addr                     : std_logic_vector(ROM_ADDR_WIDTH-1 downto 0);

   -- Declare intermediate signals for referenced outputs
   signal pkt_type_7xpcie1                  : std_logic_vector(1 downto 0);
   signal pkt_start_7xpcie0                 : std_logic;
begin
   -- Drive referenced outputs
   pkt_type <= pkt_type_7xpcie1;
   pkt_start <= pkt_start_7xpcie0;

   -- Sanity check on ROM_SIZE
--   process
--   begin
--      if (ROM_SIZE > 2048) then
--         -- $display("ERROR in cgator_controller: ROM_SIZE is too big (max 2048)");
--         -- $finish();
--      end if;
--      wait;
--   end process;

   ctl_last_addr <= CONV_STD_LOGIC_VECTOR(ROM_SIZE - 1, ROM_ADDR_WIDTH);

   -- Determine when the last ROM address is being read
   process (user_clk)
   begin
      if (user_clk'event and user_clk = '1') then
         if (reset = '1') then
            ctl_last_cfg <= '0' after (TCQ)*1 ps;
         else
            if (ctl_addr = ctl_last_addr) then
               ctl_last_cfg <= '1' after (TCQ)*1 ps;
            elsif (start_config = '1') then
               ctl_last_cfg <= '0' after (TCQ)*1 ps;
            end if;
         end if;
      end if;
   end process;


   -- Determine whether or not to expect a completion from the current
   -- downstream TLP
   process (user_clk)
   begin
      if (user_clk'event and user_clk = '1') then
         if (reset = '1') then
            ctl_skip_cpl <= '0' after (TCQ)*1 ps;
         else
            if (pkt_start_7xpcie0 = '1') then
               if (pkt_type_7xpcie1 = TYPE_MSG or pkt_type_7xpcie1 = TYPE_MSGD) then
                  -- Don't wait for a completion for a message TLP

                  ctl_skip_cpl <= '1' after (TCQ)*1 ps;
               else
                  -- All other TLP types get completions
                  ctl_skip_cpl <= '0' after (TCQ)*1 ps;
               end if;
            end if;
         end if;
      end if;
   end process;


   -- Controller state-machine
   process (user_clk)
   begin
     if (user_clk'event and user_clk = '1') then
       if (reset = '1') then
         ctl_state <= ST_IDLE after (TCQ)*1 ps;
         config_mode <= '1' after (TCQ)*1 ps;
         finished_config <= '0' after (TCQ)*1 ps;
         failed_config <= '0' after (TCQ)*1 ps;
         pkt_start_7xpcie0 <= '0' after (TCQ)*1 ps;
         pkt_type_7xpcie1 <= "00" after (TCQ)*1 ps;
         pkt_func_num <= "00" after (TCQ)*1 ps;
         pkt_reg_num <= (others => '0') after (TCQ)*1 ps;
         pkt_1dw_be <= X"0" after (TCQ)*1 ps;
         pkt_msg_routing <= "000" after (TCQ)*1 ps;
         pkt_msg_code <= X"00" after (TCQ)*1 ps;

         pkt_data <= (others => '0') after (TCQ)*1 ps;
         ctl_addr <= (others => '0') after (TCQ)*1 ps;
       else
         case ctl_state is
           when ST_IDLE =>
             -- Waiting for user to request configuration to begin

             -- Don't allow user packets until config completes
             config_mode <= '1' after (TCQ)*1 ps;
             finished_config <= '0' after (TCQ)*1 ps;
             failed_config <= '0' after (TCQ)*1 ps;
             pkt_start_7xpcie0 <= '0' after (TCQ)*1 ps;

             if (start_config = '1') then
               -- Stay in this state until user logic requests configuration to
               -- begin
               ctl_state <= ST_WAIT_CFG after (TCQ)*1 ps;
             end if;
             -- ST_IDLE

           when ST_WAIT_CFG =>
             -- Waiting for Tx Mux to indicate no active user packets

             if (config_mode_active = '1') then
                 -- No Gen2 speed - start reading from ROM
                 ctl_state <= ST_READ1 after (TCQ)*1 ps;
                 ctl_addr <= ctl_addr + "01" after (TCQ)*1 ps;
             end if;
             -- ST_WAIT_CFG


           when ST_READ1 =>
             -- Capture TLP header information from ROM
             pkt_type_7xpcie1 <= ctl_data(PKT_TYPE_HI downto PKT_TYPE_LO) after (TCQ)*1 ps;
             pkt_func_num <= ctl_data(PKT_FUNC_NUM_HI downto PKT_FUNC_NUM_LO) after (TCQ)*1 ps;
             pkt_reg_num <= ctl_data(PKT_REG_NUM_HI downto PKT_REG_NUM_LO) after (TCQ)*1 ps;
             pkt_1dw_be <= ctl_data(PKT_1DW_BE_HI downto PKT_1DW_BE_LO) after (TCQ)*1 ps;
             pkt_msg_routing <= ctl_data(PKT_MSG_ROUTING_HI downto PKT_MSG_ROUTING_LO) after (TCQ)*1 ps;
             pkt_msg_code <= ctl_data(PKT_MSG_CODE_HI downto PKT_MSG_CODE_LO) after (TCQ)*1 ps;

             ctl_addr <= ctl_addr + "01" after (TCQ)*1 ps;
             ctl_state <= ST_READ2 after (TCQ)*1 ps;
             -- ST_READ1

           when ST_READ2 =>
             -- Capture TLP data from ROM
             pkt_data <= ctl_data(PKT_DATA_HI downto PKT_DATA_LO) after (TCQ)*1 ps;

             -- start TLP transmission
             pkt_start_7xpcie0 <= '1' after (TCQ)*1 ps;

             ctl_state <= ST_WAIT_PKT after (TCQ)*1 ps;
             -- ST_READ2

           when ST_WAIT_PKT =>
             -- Wait for TLP to be transmitted
             pkt_start_7xpcie0 <= '0' after (TCQ)*1 ps;

             if (pkt_done = '1') then
               -- Once TLP has been transmitted, wait for a completion (if
               -- necessary)
               ctl_state <= ST_WAIT_CPL after (TCQ)*1 ps;
             end if;
             -- ST_WAIT_PKT

           when ST_WAIT_CPL =>
             -- Wait for completion to be received (if necessary)

             if ((cpl_sc or ctl_skip_cpl) = '1') then
               -- If a Completion with Successful Completion status is received,
               -- or if a completion isn't expected

               if (ctl_last_cfg = '1') then
                 -- If this is the last step of configuration, configuration was
                 -- completed successfully - go to DONE state with good status
                 finished_config <= '1' after (TCQ)*1 ps;
                 ctl_state <= ST_DONE after (TCQ)*1 ps;

               else
                 -- Otherwise, begin the next TLP
                 ctl_addr <= ctl_addr + "01" after (TCQ)*1 ps;
                 ctl_state <= ST_READ1 after (TCQ)*1 ps;
               end if;

             elsif (cpl_crs = '1') then
               -- If a Completion with Configuration Retry status is received,
               -- retransmit the current TLP
               pkt_start_7xpcie0 <= '1' after (TCQ)*1 ps;
               ctl_state <= ST_WAIT_PKT after (TCQ)*1 ps;

             elsif ((cpl_ur or cpl_ca or cpl_mismatch) = '1') then
               -- If a Completion with Unsupported Request or Completer Abort
               -- status is received, or the Requester ID doesn't match,
               -- configuration failed - go to DONE state with bad status
               finished_config <= '1' after (TCQ)*1 ps;
               failed_config <= '1' after (TCQ)*1 ps;
               ctl_state <= ST_DONE after (TCQ)*1 ps;
             end if;
             -- ST_WAIT_CPL

           when ST_DONE =>
             -- Configuration has commpleted - remain in this state unless user
             -- logic requests configuration to begin again
             ctl_addr <= (others => '0') after (TCQ)*1 ps;

             if (start_config = '1') then
               config_mode <= '1' after (TCQ)*1 ps;
               finished_config <= '0' after (TCQ)*1 ps;
               failed_config <= '0' after (TCQ)*1 ps;
               ctl_state <= ST_WAIT_CFG after (TCQ)*1 ps;
             else
               config_mode <= '0' after (TCQ)*1 ps;
             end if;
             -- ST_DONE

           when others =>
             null;
         end case;
       end if;
     end if;
   end process;


   -- ROM instantiation - this structure is known to be supported by Synplify
   -- and XST for ROM inference
   process (user_clk)		-- No reset for a ROM
   begin
      if (user_clk'event and user_clk = '1') then
         ctl_data <= ctl_rom(to_integer(ctl_addr)) after (TCQ)*1 ps;
      end if;
   end process;

end rtl;



-- cgator_controller
