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
-- File       : pio_master_controller.vhd
-- Version    : 1.9
--
-- Description : PIO Master Controller module - performs write/read test on
--               a PIO design instantiated in a connected Endpoint. This
--               module controls the read/write/verify cycle. It waits for
--               user_lnk_up to be asserted, directs the Configurator to
--               configure the attached Endpoint, directs the PIO Master
--               Packet Generator to transmit TLPs writing data to each
--               configured BAR, directs the PIO Master Packet Generator to
--               transmit TLPs reading back data from each BAR, and specifies
--               the data to be matched to the PIO Master Checker. If the
--               entire process succeeds, it asserts the pio_test_finished
--               output. If not, it asserts the pio_test_failed output.
--
-- Note        : pio_test_long is unused at this time, but is intended to
--               allow user to select between short (one write/read for each
--               aperture) and long (full memory test) tests in the future
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

entity pio_master_controller is
   generic (
      TCQ                                          : integer := 1;

      -- BAR A settings
      BAR_A_ENABLED                                : integer := 1;
      BAR_A_64BIT                                  : integer := 1;
      BAR_A_IO                                     : integer := 0;
      BAR_A_BASE                                   : std_logic_vector(63 downto 0) := X"1000000000000000";
      BAR_A_SIZE                                   : integer := 1024;  -- Size in DW

      -- BAR B settings
      BAR_B_ENABLED                                : integer := 0;
      BAR_B_64BIT                                  : integer := 0;
      BAR_B_IO                                     : integer := 0;
      BAR_B_BASE                                   : std_logic_vector(63 downto 0) := X"0000000020000000";
      BAR_B_SIZE                                   : integer := 1024;  -- Size in DW

      -- BAR C settings
      BAR_C_ENABLED                                : integer := 0;
      BAR_C_64BIT                                  : integer := 0;
      BAR_C_IO                                     : integer := 0;
      BAR_C_BASE                                   : std_logic_vector(63 downto 0) := X"0000000040000000";
      BAR_C_SIZE                                   : integer := 1024;  -- Size in DW

      -- BAR D settings
      BAR_D_ENABLED                                : integer := 0;
      BAR_D_64BIT                                  : integer := 0;
      BAR_D_IO                                     : integer := 0;
      BAR_D_BASE                                   : std_logic_vector(63 downto 0) := X"0000000080000000";
      BAR_D_SIZE                                   : integer := 1024  -- Size in DW
   );
   port (
      -- globals
      user_clk                                     : in std_logic;
      reset                                        : in std_logic;

      -- System information
      user_lnk_up                                  : in std_logic;
      pio_test_restart                             : in std_logic;
      pio_test_long                                : in std_logic;      -- Unused for now
      pio_test_finished                            : out std_logic;
      pio_test_failed                              : out std_logic;

      -- Control configuration process
      start_config                                 : out std_logic;
      finished_config                              : in std_logic;
      failed_config                                : in std_logic;

      link_gen2_capable                            : in  std_logic;
      link_gen2                                    : in  std_logic;

      -- Packet generator interface
      tx_type                                      : out std_logic_vector(2 downto 0);      -- see TX_TYPE_* below for encoding
      tx_tag                                       : out std_logic_vector(7 downto 0);
      tx_addr                                      : out std_logic_vector(63 downto 0);
      tx_data                                      : out std_logic_vector(31 downto 0);
      tx_start                                     : out std_logic;
      tx_done                                      : in std_logic;

      -- Checker interface
      rx_type                                      : out std_logic;      -- see RX_TYPE_* below for encoding
      rx_tag                                       : out std_logic_vector(7 downto 0);
      rx_data                                      : out std_logic_vector(31 downto 0);
      rx_good                                      : in std_logic;
      rx_bad                                       : in std_logic
   );
end pio_master_controller;

architecture rtl of pio_master_controller is

  function state_check (
    curr_state  : std_logic_vector(3 downto 0);
    check_state : std_logic_vector(3 downto 0))
    return std_logic is
  begin  -- state_check
    if (curr_state = check_state) then
      return '1';
    else
      return '0';
    end if;
  end state_check;

      -- TLP type encoding for tx_type
   constant TX_TYPE_MEMRD32                        : std_logic_vector(2 downto 0) := "000";
   constant TX_TYPE_MEMWR32                        : std_logic_vector(2 downto 0) := "001";
   constant TX_TYPE_MEMRD64                        : std_logic_vector(2 downto 0) := "010";
   constant TX_TYPE_MEMWR64                        : std_logic_vector(2 downto 0) := "011";
   constant TX_TYPE_IORD                           : std_logic_vector(2 downto 0) := "100";
   constant TX_TYPE_IOWR                           : std_logic_vector(2 downto 0) := "101";

      -- TLP type encoding for rx_type
   constant RX_TYPE_CPL                            : std_logic := '0';
   constant RX_TYPE_CPLD                           : std_logic := '1';

      -- State encodings
   constant ST_WAIT_CFG                            : std_logic_vector(3 downto 0) := "0000";
   constant ST_WRITE                               : std_logic_vector(3 downto 0) := "0001";
   constant ST_WRITE_WAIT                          : std_logic_vector(3 downto 0) := "0010";
   constant ST_IOWR_CPL_WAIT                       : std_logic_vector(3 downto 0) := "0011";
   constant ST_READ                                : std_logic_vector(3 downto 0) := "0100";
   constant ST_READ_WAIT                           : std_logic_vector(3 downto 0) := "0101";
   constant ST_READ_CPL_WAIT                       : std_logic_vector(3 downto 0) := "0110";
   constant ST_DONE                                : std_logic_vector(3 downto 0) := "0111";
   constant ST_ERROR                               : std_logic_vector(3 downto 0) := "1000";

      -- Data used for checking each memory aperture
   constant BAR_A_DATA                             : std_logic_vector(31 downto 0) := X"12345678";
   constant BAR_B_DATA                             : std_logic_vector(31 downto 0) := X"FEEDFACE";
   constant BAR_C_DATA                             : std_logic_vector(31 downto 0) := X"DECAFBAD";
   constant BAR_D_DATA                             : std_logic_vector(31 downto 0) := X"31415927";

      -- Determine the highest-numbered enabled memory aperture
   constant LAST_BAR                               : integer := BAR_A_ENABLED + BAR_B_ENABLED + BAR_C_ENABLED + BAR_D_ENABLED - 1;

   -- State control
   signal ctl_state                                : std_logic_vector(3 downto 0);
--   signal cur_bar                                : std_logic_vector(1 downto 0);
--   signal cur_last_bar                           : std_logic;
   signal cur_bar                                  : integer;
   signal cur_last_bar                             : boolean;

   -- Sampling registers
   signal user_lnk_up_q                           : std_logic;
   signal user_lnk_up_q2                          : std_logic;

   -- X-HDL generated signals

   signal sevenxpcie2 : std_logic_vector(2 downto 0);
   signal sevenxpcie3 : std_logic_vector(2 downto 0);
   signal sevenxpcie4 : std_logic_vector(2 downto 0);
   signal sevenxpcie5 : std_logic_vector(2 downto 0);
   signal sevenxpcie6 : std_logic_vector(2 downto 0);
   signal sevenxpcie7 : std_logic;
   signal sevenxpcie8 : std_logic_vector(2 downto 0);
   signal sevenxpcie9 : std_logic_vector(2 downto 0);
   signal sevenxpcie10 : std_logic_vector(2 downto 0);
   signal sevenxpcie11 : std_logic_vector(2 downto 0);
   signal sevenxpcie12 : std_logic_vector(2 downto 0);
   signal sevenxpcie13 : std_logic;
   signal sevenxpcie14 : std_logic_vector(2 downto 0);
   signal sevenxpcie15 : std_logic_vector(2 downto 0);
   signal sevenxpcie16 : std_logic_vector(2 downto 0);
   signal sevenxpcie17 : std_logic_vector(2 downto 0);
   signal sevenxpcie18 : std_logic_vector(2 downto 0);
   signal sevenxpcie19 : std_logic;
   signal sevenxpcie20 : std_logic_vector(2 downto 0);
   signal sevenxpcie21 : std_logic_vector(2 downto 0);
   signal sevenxpcie22 : std_logic_vector(2 downto 0);
   signal sevenxpcie23 : std_logic_vector(2 downto 0);
   signal sevenxpcie24 : std_logic_vector(2 downto 0);
   signal sevenxpcie25 : std_logic;

   -- Declare intermediate signals for referenced outputs
   signal tx_type_7xpcie1                              : std_logic_vector(2 downto 0);
   signal tx_tag_7xpcie0                               : std_logic_vector(7 downto 0);

   signal link_gen2_q                                  : std_logic;
   signal link_gen2_q2                                 : std_logic;

begin
   -- Drive referenced outputs
   tx_type <= tx_type_7xpcie1;
   tx_tag <= tx_tag_7xpcie0;

   -- Sanity check on BAR settings
--   process
--   begin
--      if (((BAR_B_ENABLED or BAR_C_ENABLED or BAR_D_ENABLED) and not(BAR_A_ENABLED)) or ((BAR_C_ENABLED or BAR_D_ENABLED) and not(BAR_B_ENABLED)) or (BAR_D_ENABLED and not(BAR_B_ENABLED)) /= 0) then
--         -- $display("ERROR in %m : BARs must be enabled contiguously starting with BAR_A");
--         -- $finish();
--      end if;
--      wait;
--   end process;


   -- Start Configurator after link comes up
   process (user_clk)
   begin
      if (user_clk'event and user_clk = '1') then
         if (reset = '1') then
            user_lnk_up_q  <= '0' after (TCQ)*1 ps;
            user_lnk_up_q2 <= '0' after (TCQ)*1 ps;
            link_gen2_q    <= '0' after (TCQ)*1 ps;
            link_gen2_q2   <= '0' after (TCQ)*1 ps;
            start_config   <= '0' after (TCQ)*1 ps;
         else
            user_lnk_up_q  <= user_lnk_up after (TCQ)*1 ps;
            user_lnk_up_q2 <= user_lnk_up_q after (TCQ)*1 ps;
            link_gen2_q    <= link_gen2 after (TCQ)*1 ps;
            link_gen2_q2   <= link_gen2_q after (TCQ)*1 ps;
            if (link_gen2_capable = '1') then
              start_config <= ((not link_gen2_q2) and link_gen2_q and user_lnk_up) after (TCQ)*1 ps;
            else
              start_config <= ((not user_lnk_up_q2) and user_lnk_up_q) after (TCQ)*1 ps;
            end if;
         end if;
      end if;
   end process;


   -- Controller state-machine
   process (user_clk)
   begin
     if (user_clk'event and user_clk = '1') then
       if (reset = '1' or user_lnk_up = '0') then
         -- Link going down causes PIO master state machine to restart
         ctl_state <= ST_WAIT_CFG after (TCQ)*1 ps;
         cur_bar <= 0 after (TCQ)*1 ps;
       else
         case ctl_state is
           when ST_WAIT_CFG =>
             -- Wait for Configurator to finish configuring the Endpoint
             -- If this state is entered due to assertion of pio_test_restart,
             -- state machine will immediately fall through to ST_WRITE. In that
             -- case, this state is used to reset the cur_bar counter

             if (failed_config = '1') then
               ctl_state <= ST_ERROR after (TCQ)*1 ps;
             elsif (finished_config = '1') then
               ctl_state <= ST_WRITE after (TCQ)*1 ps;
             end if;
             cur_bar <= 0 after (TCQ)*1 ps;
             -- ST_WAIT_CFG

           when ST_WRITE =>
             -- Transmit write TLP to Endpoint PIO design

             ctl_state <= ST_WRITE_WAIT after (TCQ)*1 ps;
             -- ST_WRITE

           when ST_WRITE_WAIT =>
             -- Wait for write TLP to be transmitted

             if (tx_done = '1') then
               if (tx_type_7xpcie1 = TX_TYPE_IOWR) then
                 -- If targeted aperture was an IO BAR, wait for a completion TLP
                 ctl_state <= ST_IOWR_CPL_WAIT after (TCQ)*1 ps;
               elsif (cur_last_bar) then
                 -- If targeted aperture was the last one enabled, start sending
                 -- reads
                 ctl_state <= ST_READ after (TCQ)*1 ps;
                 cur_bar <= 0 after (TCQ)*1 ps;
               else
                 -- Otherwise, send more writes
                 ctl_state <= ST_WRITE after (TCQ)*1 ps;
                 cur_bar <= cur_bar + 1 after (TCQ)*1 ps;
               end if;
             end if;
             -- ST_WRITE_WAIT

           when ST_IOWR_CPL_WAIT =>
             -- Wait for completion for an IO write to be returned

             if (rx_bad = '1') then
               -- If there was something wrong with the completion, finish with
               -- an error condition
               ctl_state <= ST_ERROR after (TCQ)*1 ps;

             elsif (rx_good = '1') then
               if (cur_last_bar) then
                 -- If completion was good and targeted aperture was the last one
                 -- enabled, start sending reads
                 ctl_state <= ST_READ after (TCQ)*1 ps;
                 cur_bar <= 0 after (TCQ)*1 ps;

               else
                 -- Otherwise, send more writes
                 ctl_state <= ST_WRITE after (TCQ)*1 ps;
                 cur_bar <= cur_bar + 1 after (TCQ)*1 ps;
               end if;
             end if;
             -- ST_IOWR_CPL_WAIT

           when ST_READ =>
             -- Send a read TLP to Endpoint PIO design

             ctl_state <= ST_READ_WAIT after (TCQ)*1 ps;
             -- ST_READ

           when ST_READ_WAIT =>
             -- Wait for read TLP to be transmitted

             if (tx_done = '1') then
               ctl_state <= ST_READ_CPL_WAIT after (TCQ)*1 ps;
             end if;
             -- ST_READ_WAIT

           when ST_READ_CPL_WAIT =>
             -- Wait for completion to be returned

             if (rx_bad = '1') then
               -- If there was something wrong with the completion, finish with
               -- an error condition
               ctl_state <= ST_ERROR after (TCQ)*1 ps;
             elsif (rx_good = '1') then
               if (cur_last_bar) then
                 -- If completion was good and targeted aperture was the last one
                 -- enabled, finish with a success condition
                 ctl_state <= ST_DONE after (TCQ)*1 ps;

               else
                 -- Otherwise, send more reads
                 ctl_state <= ST_READ after (TCQ)*1 ps;
                 cur_bar <= cur_bar + 1 after (TCQ)*1 ps;
               end if;
             end if;
             -- ST_READ_CPL_WAIT

           when ST_DONE =>
             -- Test passed successfully. Wait for restart to be requested

             if (pio_test_restart = '1') then
               ctl_state <= ST_WAIT_CFG after (TCQ)*1 ps;
             end if;
             -- ST_DONE

           when ST_ERROR =>
             -- Test failed. Wait for restart to be requested

             if (pio_test_restart = '1') then
               ctl_state <= ST_WAIT_CFG after (TCQ)*1 ps;
             end if;
             -- ST_ERROR

           when others =>
             -- Test failed. Wait for restart to be requested

             if (pio_test_restart = '1') then
               ctl_state <= ST_WAIT_CFG after (TCQ)*1 ps;
             end if;
             -- others
         end case;
       end if;
     end if;
   end process;


   -- Generate status outputs based on state
   process (user_clk)
   begin
      if (user_clk'event and user_clk = '1') then
         if (reset = '1') then
            pio_test_finished <= '0' after (TCQ)*1 ps;
            pio_test_failed <= '0' after (TCQ)*1 ps;
         else
            pio_test_finished <= state_check(ctl_state, ST_DONE) after (TCQ)*1 ps;
            pio_test_failed <= state_check(ctl_state, ST_ERROR) after (TCQ)*1 ps;
         end if;
      end if;
   end process;


   -- Track whether current BAR is last in the list. cur_bar gets incremented in
   -- ST_WRITE and ST_READ, and tx_done and rx_done take at least two
   -- clock cycles to be asserted, so cur_last_bar will always be valid before
   -- it's needed
   process (user_clk)
   begin
      if (user_clk'event and user_clk = '1') then
         if (reset = '1') then
            cur_last_bar <= false after (TCQ)*1 ps;
         else
            cur_last_bar <= (cur_bar = LAST_BAR) after (TCQ)*1 ps;
         end if;
      end if;
   end process;


   -- BAR A
   sevenxpcie2 <= TX_TYPE_MEMWR64 when (BAR_A_64BIT /= 0) else
                   TX_TYPE_MEMWR32;
   sevenxpcie3 <= TX_TYPE_IOWR when (BAR_A_IO /= 0) else
                   sevenxpcie2;
   sevenxpcie4 <= TX_TYPE_MEMRD64 when (BAR_A_64BIT /= 0) else
                   TX_TYPE_MEMRD32;
   sevenxpcie5 <= TX_TYPE_IORD when (BAR_A_IO /= 0) else
                   sevenxpcie4;
   sevenxpcie6 <= sevenxpcie3 when (ctl_state = ST_WRITE) else
                   sevenxpcie5;
   sevenxpcie7 <= RX_TYPE_CPLD when (ctl_state = ST_READ) else
                   RX_TYPE_CPL;

   -- BAR B
   sevenxpcie8 <= TX_TYPE_MEMWR64 when (BAR_B_64BIT /= 0) else
                   TX_TYPE_MEMWR32;
   sevenxpcie9 <= TX_TYPE_IOWR when (BAR_B_IO /= 0) else
                   sevenxpcie8;
   sevenxpcie10 <= TX_TYPE_MEMRD64 when (BAR_B_64BIT /= 0) else
                   TX_TYPE_MEMRD32;
   sevenxpcie11 <= TX_TYPE_IORD when (BAR_B_IO /= 0) else
                   sevenxpcie10;
   sevenxpcie12 <= sevenxpcie9 when (ctl_state = ST_WRITE) else
                   sevenxpcie11;
   sevenxpcie13 <= RX_TYPE_CPLD when (ctl_state = ST_READ) else
                   RX_TYPE_CPL;

   -- BAR C
   sevenxpcie14 <= TX_TYPE_MEMWR64 when (BAR_C_64BIT /= 0) else
                   TX_TYPE_MEMWR32;
   sevenxpcie15 <= TX_TYPE_IOWR when (BAR_C_IO /= 0) else
                   sevenxpcie14;
   sevenxpcie16 <= TX_TYPE_MEMRD64 when (BAR_C_64BIT /= 0) else
                   TX_TYPE_MEMRD32;
   sevenxpcie17 <= TX_TYPE_IORD when (BAR_C_IO /= 0) else
                   sevenxpcie16;
   sevenxpcie18 <= sevenxpcie15 when (ctl_state = ST_WRITE) else
                   sevenxpcie17;
   sevenxpcie19 <= RX_TYPE_CPLD when (ctl_state = ST_READ) else
                   RX_TYPE_CPL;

   -- BAR D
   sevenxpcie20 <= TX_TYPE_MEMWR64 when (BAR_D_64BIT /= 0) else
                   TX_TYPE_MEMWR32;
   sevenxpcie21 <= TX_TYPE_IOWR when (BAR_D_IO /= 0) else
                   sevenxpcie20;
   sevenxpcie22 <= TX_TYPE_MEMRD64 when (BAR_D_64BIT /= 0) else
                   TX_TYPE_MEMRD32;
   sevenxpcie23 <= TX_TYPE_IORD when (BAR_D_IO /= 0) else
                   sevenxpcie22;
   sevenxpcie24 <= sevenxpcie21 when (ctl_state = ST_WRITE) else
                   sevenxpcie23;
   sevenxpcie25 <= RX_TYPE_CPLD when (ctl_state = ST_READ) else
                   RX_TYPE_CPL;

   -- Generate outputs to packet generator and checker


   process (user_clk)
   begin
      if (user_clk'event and user_clk = '1') then
         if (reset = '1') then
            tx_type_7xpcie1 <= "000" after (TCQ)*1 ps;
            tx_addr <= (others => '0') after (TCQ)*1 ps;
            tx_data <= (others => '0') after (TCQ)*1 ps;
            rx_type <= '0' after (TCQ)*1 ps;
            rx_data <= (others => '0') after (TCQ)*1 ps;
            tx_tag_7xpcie0 <= X"00" after (TCQ)*1 ps;
            tx_start <= '0' after (TCQ)*1 ps;
         else
            if (ctl_state = ST_WRITE or ctl_state = ST_READ) then
              -- New control information is latched out only in these two states

               case cur_bar is    -- Select settings for current aperture
                  when 0 =>
                     tx_type_7xpcie1 <= sevenxpcie6 after (TCQ)*1 ps;
                     tx_data <= BAR_A_DATA after (TCQ)*1 ps;
                     tx_addr <= BAR_A_BASE after (TCQ)*1 ps;
                     rx_type <= sevenxpcie7 after (TCQ)*1 ps;
                     rx_data <= BAR_A_DATA after (TCQ)*1 ps;
                  when 1 =>
                     tx_type_7xpcie1 <= sevenxpcie12 after (TCQ)*1 ps;
                     tx_data <= BAR_B_DATA after (TCQ)*1 ps;
                     tx_addr <= BAR_B_BASE after (TCQ)*1 ps;
                     rx_type <= sevenxpcie13 after (TCQ)*1 ps;
                     rx_data <= BAR_B_DATA after (TCQ)*1 ps;
                  when 2 =>
                     tx_type_7xpcie1 <= sevenxpcie18 after (TCQ)*1 ps;
                     tx_data <= BAR_C_DATA after (TCQ)*1 ps;
                     tx_addr <= BAR_C_BASE after (TCQ)*1 ps;
                     rx_type <= sevenxpcie19 after (TCQ)*1 ps;
                     rx_data <= BAR_C_DATA after (TCQ)*1 ps;
                  when others =>
                     tx_type_7xpcie1 <= sevenxpcie24 after (TCQ)*1 ps;
                     tx_data <= BAR_D_DATA after (TCQ)*1 ps;
                     tx_addr <= BAR_D_BASE after (TCQ)*1 ps;
                     rx_type <= sevenxpcie25 after (TCQ)*1 ps;
                     rx_data <= BAR_D_DATA after (TCQ)*1 ps;
               end case;
            end if;

            if (ctl_state = ST_WRITE or ctl_state = ST_READ) then
               -- Tag is incremented for each TLP sent
               tx_tag_7xpcie0 <= tx_tag_7xpcie0 + X"01" after (TCQ)*1 ps;
            end if;

            if (ctl_state = ST_WRITE or ctl_state = ST_READ) then
               -- Pulse tx_start for one cycle as state machine passes through
               -- ST_WRITE or ST_READ
               tx_start <= '1' after (TCQ)*1 ps;
            else
               tx_start <= '0' after (TCQ)*1 ps;
            end if;
         end if;
      end if;
   end process;


   -- tx_tag and rx_tag are always the same
   rx_tag <= tx_tag_7xpcie0;

end rtl;



-- pio_master_controller
