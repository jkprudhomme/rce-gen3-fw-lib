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
-- File       : cgator_pkt_generator.vhd
-- Version    : 1.9
--
-- Description : Configurator Packet Generator module - transmits downstream
--               TLPs. Packet type and non-static header and data fields are
--               provided by the Configurator module
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

entity cgator_pkt_generator is
   generic (
      TCQ                         : integer := 1;
      REQUESTER_ID                : std_logic_vector(15 downto 0) := X"10EE";
      C_DATA_WIDTH                : integer := 64;
      KEEP_WIDTH                  : integer := 8  
   );
   port (
      -- globals
      user_clk                    : in std_logic;
      reset                       : in std_logic;

      -- Tx mux interface
      pg_s_axis_tx_tready         : in  std_logic;
      pg_s_axis_tx_tdata          : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
      pg_s_axis_tx_tkeep          : out std_logic_vector((C_DATA_WIDTH/8 - 1) downto 0);
      pg_s_axis_tx_tuser          : out std_logic_vector(3 downto 0);
      pg_s_axis_tx_tlast          : out std_logic;
      pg_s_axis_tx_tvalid         : out std_logic;

      -- Controller interface

      pkt_type                    : in std_logic_vector(1 downto 0);      -- See TYPE_* below for encodings
      pkt_func_num                : in std_logic_vector(1 downto 0);
      pkt_reg_num                 : in std_logic_vector(9 downto 0);
      pkt_1dw_be                  : in std_logic_vector(3 downto 0);
      pkt_msg_routing             : in std_logic_vector(2 downto 0);
      pkt_msg_code                : in std_logic_vector(7 downto 0);
      pkt_data                    : in std_logic_vector(31 downto 0);
      pkt_start                   : in std_logic;
      pkt_done                    : out std_logic
   );
end cgator_pkt_generator;

architecture rtl of cgator_pkt_generator is

      -- Encodings for pkt_type
   constant TYPE_CFGRD                  : std_logic_vector(1 downto 0) := "00";
   constant TYPE_CFGWR                  : std_logic_vector(1 downto 0) := "01";
   constant TYPE_MSG                    : std_logic_vector(1 downto 0) := "10";
   constant TYPE_MSGD                   : std_logic_vector(1 downto 0) := "11";

      -- State encodings
   constant ST_IDLE                     : std_logic_vector(2 downto 0) := "000";
   constant ST_CFG0                     : std_logic_vector(2 downto 0) := "001";
   constant ST_CFG1                     : std_logic_vector(2 downto 0) := "010";
   constant ST_MSG0                     : std_logic_vector(2 downto 0) := "011";
   constant ST_MSG1                     : std_logic_vector(2 downto 0) := "100";
   constant ST_MSG2                     : std_logic_vector(2 downto 0) := "101";

   -- State variable
   signal pkt_state                         : std_logic_vector(2 downto 0);

   -- X-HDL generated signals

   signal cfg_fmt : std_logic_vector(1 downto 0);
   signal tkeep   : std_logic_vector((C_DATA_WIDTH/8 - 1) downto 0);
   signal msg_fmt : std_logic_vector(1 downto 0);
   signal msg_len : std_logic_vector(9 downto 0);
   signal msg_eof : std_logic;

begin

  WIDTH_64 : if C_DATA_WIDTH = 64 generate
  begin
     -- State-machine and controller hand-shake
     process (user_clk)
     begin
        if (user_clk'event and user_clk = '1') then
           if (reset = '1') then
              pkt_state <= ST_IDLE after (TCQ)*1 ps;
              pkt_done <= '0' after (TCQ)*1 ps;
           else
              case pkt_state is
                 when ST_IDLE =>
                 -- Idle - wait for Controller to request TLP transmission

                    pkt_done <= '0' after (TCQ)*1 ps;
                    if (pkt_start = '1') then
                       if ((pkt_type = TYPE_CFGRD) or (pkt_type = TYPE_CFGWR)) then
                          pkt_state <= ST_CFG0 after (TCQ)*1 ps;
                       else
                          pkt_state <= ST_MSG0 after (TCQ)*1 ps;
                       end if;
                    end if;
                 -- ST_IDLE

                 when ST_CFG0 =>
                 -- First Quad-word (2 dwords) of a CfgRd0 or CfgWr0 TLP
                    if ((pg_s_axis_tx_tready) = '1') then
                       pkt_state <= ST_CFG1 after (TCQ)*1 ps;
                    end if;
                 -- ST_CFG0

                 when ST_CFG1 =>
                 -- Second and last QW of a CfgRd0 or CfgWr0 TLP
                    if ((pg_s_axis_tx_tready) = '1') then
                       pkt_state <= ST_IDLE after (TCQ)*1 ps;
                       pkt_done <= '1' after (TCQ)*1 ps;
                    end if;
                 -- ST_CFG1

                 when ST_MSG0 =>
                 -- First QW of a Msg or MsgD TLP
                    if ((pg_s_axis_tx_tready) = '1') then
                       pkt_state <= ST_MSG1 after (TCQ)*1 ps;
                    end if;
                 -- ST_MSG0

                 when ST_MSG1 =>
                 -- Second QW of a Msg or MsgD TLP
                    if ((pg_s_axis_tx_tready) = '1') then
                       if (pkt_type = TYPE_MSGD) then
                         -- MsgD TLPs have a third QW
                          pkt_state <= ST_MSG2 after (TCQ)*1 ps;
                       else
                         -- Msg TLPs end after two QWs
                          pkt_state <= ST_IDLE after (TCQ)*1 ps;
                          pkt_done <= '1' after (TCQ)*1 ps;
                       end if;
                    end if;
                 -- ST_MSG1

                 when ST_MSG2 =>
                 -- Third and last QW of a MsgD TLP
                    if ((pg_s_axis_tx_tready) = '1') then
                       pkt_state <= ST_IDLE after (TCQ)*1 ps;
                       pkt_done <= '1' after (TCQ)*1 ps;
                    end if;
                 -- ST_MSG2

                 when others =>
                    pkt_state <= ST_IDLE after (TCQ)*1 ps;
                 -- default case
              end case;
           end if;
        end if;
     end process;


     -- Packet generation output - combinatorially generate output to Tx Mux
     -- depending on the current state
     pg_s_axis_tx_tuser <= "0100";

     cfg_fmt    <= "10" when (pkt_type = TYPE_CFGWR) else
                   "00";
     tkeep      <= X"FF" when (pkt_type = TYPE_CFGWR) else
                   X"0F";
     msg_fmt    <= "11" when (pkt_type = TYPE_MSGD) else
                   "01";
     msg_len    <= "0000000001" when (pkt_type = TYPE_MSGD) else
                   "0000000000";
     msg_eof    <= '0' when (pkt_type = TYPE_MSGD) else
                   '1';
     process (pkt_state, pkt_1dw_be, cfg_fmt, pkt_data, pkt_func_num, pkt_reg_num, tkeep,
              pkt_msg_code, msg_fmt, pkt_msg_routing, msg_len, msg_eof)

     begin
       case pkt_state is
         when ST_CFG0 =>
           -- First QW of a CfgRd0 or CfgWr0 TLP
           pg_s_axis_tx_tlast <= '0';
           pg_s_axis_tx_tdata <= (REQUESTER_ID & -- Requester ID
                                         X"00" & -- Tag
                                          X"0" & -- Last DW BE
                                    pkt_1dw_be & -- First DW BE
                                           '0' & -- Reserved
                                       cfg_fmt & -- Fmt
                                       "00100" & -- Type
                                         X"00" & -- Reserved, TC, Reserved
                                          X"0" & -- TD, EP, Attr
                                          "00" & -- Reserved
                                   "0000000001");-- Length

           pg_s_axis_tx_tkeep <= X"FF";
           pg_s_axis_tx_tvalid <= '1';
           -- ST_CFG0

         when ST_CFG1 =>
           -- Second and last QW of a CfgRd0 or CfgWr0 TLP
           pg_s_axis_tx_tlast <= '1';
           pg_s_axis_tx_tdata <= (pkt_data & -- Data (Not used if CfgRd)
                                     X"01" & -- Bus #            \
                                   "00000" & -- Device #         |  Completer ID
                                       '0' & -- Function # (Hi)  |
                              pkt_func_num & -- Function # (Lo)  /
                                      X"0" & -- Reserved
                               pkt_reg_num & -- Ext Reg Number, Register Number
                                      "00" );-- Reserved
           pg_s_axis_tx_tkeep <= tkeep;
           pg_s_axis_tx_tvalid <= '1';
           -- ST_CFG1

         when ST_MSG0 =>
           -- First QW of a Msg or MsgD TLP
           pg_s_axis_tx_tlast <= '0';
           pg_s_axis_tx_tdata <= (REQUESTER_ID & -- Requester ID
                                         X"00" & -- Tag
                                  pkt_msg_code & -- Message Code
                                           '0' & -- Reserved
                                       msg_fmt & -- Fmt
                                          "10" & -- 2 MSb of Type
                               pkt_msg_routing & -- Msg Routing
                                         X"00" & -- Reserved, TC, Reserved
                                          X"0" & -- TD, EP, Attr
                                          "00" & -- Reserved
                                        msg_len);-- Length
           pg_s_axis_tx_tkeep <= X"FF";
           pg_s_axis_tx_tvalid <= '1';
           -- ST_MSG0

         when ST_MSG1 =>
           -- Second QW of a Msg or MsgD TLP (last for Msg)
           pg_s_axis_tx_tlast <= msg_eof;
           pg_s_axis_tx_tdata <= (others => '0'); -- Addr[63:32], Addr[31:2], Reserved
           pg_s_axis_tx_tkeep <= (others => '0');
           pg_s_axis_tx_tvalid <= '1';
           -- ST_MSG1

         when ST_MSG2 =>
           -- Third and last QW of a MsgD TLP
           pg_s_axis_tx_tlast <= '1';
           pg_s_axis_tx_tdata <= (X"00000000" & pkt_data); -- Data, don't-care
           pg_s_axis_tx_tkeep <= X"0F";
           pg_s_axis_tx_tvalid <= '1';
           -- ST_MSG2

         when others =>
           -- No TLP active
           pg_s_axis_tx_tlast <= '0';
           pg_s_axis_tx_tdata <= (others => '0');
           pg_s_axis_tx_tkeep <= (others => '0');
           pg_s_axis_tx_tvalid <= '0';
           -- default case
       end case;
     end process;
  end generate;

  WIDTH_128 : if C_DATA_WIDTH /= 64 generate
  begin
     -- State-machine and controller hand-shake
     process (user_clk)
     begin
        if (user_clk'event and user_clk = '1') then
           if (reset = '1') then
              pkt_state <= ST_IDLE after (TCQ)*1 ps;
              pkt_done <= '0' after (TCQ)*1 ps;
           else
              case pkt_state is
                 when ST_IDLE =>
                 -- Idle - wait for Controller to request TLP transmission

                    pkt_done <= '0' after (TCQ)*1 ps;

                    if (pkt_start = '1') then
                       if ((pkt_type = TYPE_CFGRD) or (pkt_type = TYPE_CFGWR)) then
                          pkt_state <= ST_CFG0 after (TCQ)*1 ps;
                       else
                          pkt_state <= ST_MSG0 after (TCQ)*1 ps;
                       end if;
                    end if;
                 -- ST_IDLE

                 when ST_CFG0 =>
                 -- First 2 QWs (4 dwords) of a CfgRd0 or CfgWr0 TLP
                    if (pg_s_axis_tx_tready = '1') then
                       pkt_state <= ST_IDLE after (TCQ)*1 ps;
                       pkt_done <= '1' after (TCQ)*1 ps;
                    end if;
                 -- ST_CFG0

                 when ST_MSG0 =>
                 -- First 2 QWs of a Msg or MsgD TLP
                    if (pg_s_axis_tx_tready = '1') then
                      if pkt_type = TYPE_MSGD then
                        pkt_state <= ST_MSG1 after (TCQ)*1 ps;
                      else
                        pkt_state    <= ST_IDLE after (TCQ)*1 ps;
                        pkt_done     <= '1' after (TCQ)*1 ps;
                      end if;
                    end if;
                 -- ST_MSG0

                 when ST_MSG1 =>
                 -- Third QW of a MsgD TLP
                    if ((pg_s_axis_tx_tready) = '1') then
                       if (pkt_type = TYPE_MSGD) then
                          pkt_state <= ST_IDLE after (TCQ)*1 ps;
                          pkt_done <= '1' after (TCQ)*1 ps;
                       end if;
                    end if;
                 -- ST_MSG1

                 when others =>
                    pkt_state <= ST_IDLE after (TCQ)*1 ps;
                 -- default case
              end case;
           end if;
        end if;
     end process;


     -- Packet generation output - combinatorially generate output to Tx Mux
     -- depending on the current state
     pg_s_axis_tx_tuser <= "0100";

     cfg_fmt    <= "10" when (pkt_type = TYPE_CFGWR) else
                   "00";
     tkeep      <= X"FFFF" when (pkt_type = TYPE_CFGWR) else
                   X"0FFF";
     msg_fmt    <= "11" when (pkt_type = TYPE_MSGD) else
                   "01";
     msg_len    <= "0000000001" when (pkt_type = TYPE_MSGD) else
                   "0000000000";
     msg_eof    <= '0' when (pkt_type = TYPE_MSGD) else
                   '1';
     process (pkt_state, pkt_data, msg_len, pkt_func_num, pkt_reg_num, pkt_1dw_be, cfg_fmt, tkeep,
              msg_fmt, msg_eof, pkt_msg_code, pkt_msg_routing)
     begin
       case pkt_state is
         when ST_CFG0 =>
           -- First QW of a CfgRd0 or CfgWr0 TLP
           pg_s_axis_tx_tdata  <= (pkt_data & -- Data (Not used if CfgRd)
                                      X"01" & -- Bus #            \
                                    "00000" & -- Device #         |  Completer ID
                                        '0' & -- Function # (Hi)  |
                               pkt_func_num & -- Function # (Lo)  /
                                       X"0" & -- Reserved
                                pkt_reg_num & -- Ext Reg Number, Register Number
                                       "00" & -- Reserved
                               REQUESTER_ID & -- Requester ID
                                      X"00" & -- Tag
                                       X"0" & -- Last DW BE
                                 pkt_1dw_be & -- First DW BE
                                        '0' & -- Reserved
                                    cfg_fmt & -- Fmt
                                    "00100" & -- Type
                                      X"00" & -- Reserved, TC, Reserved
                                       X"0" & -- TD, EP, Attr
                                       "00" & -- Reserved
                               "0000000001" );-- Length
           pg_s_axis_tx_tkeep  <= tkeep;
           pg_s_axis_tx_tvalid <= '1';
           pg_s_axis_tx_tlast  <= '1';
           -- ST_CFG0

         when ST_MSG0 =>
           -- First 2 QW of a Msg or MsgD TLP
           pg_s_axis_tx_tdata  <= (X"0000000000000000" & -- Addr[31:2], Reserved, Addr[63:32]
                                          REQUESTER_ID & -- Requester ID
                                                 X"00" & -- Tag
                                          pkt_msg_code & -- Message Code
                                                   '0' & -- Reserved
                                               msg_fmt & -- Fmt
                                                  "10" & -- 2 MSb of Type
                                       pkt_msg_routing & -- Msg Routing
                                                 X"00" & -- Reserved, TC, Reserved
                                                  X"0" & -- TD, EP, Attr
                                                  "00" & -- Reserved
                                               msg_len );-- Length
           pg_s_axis_tx_tlast  <= msg_eof;
           pg_s_axis_tx_tkeep  <= X"FFFF";
           pg_s_axis_tx_tvalid <= '1';

           -- ST_MSG0

         when ST_MSG1 =>
           -- Third and last QW of a MsgD TLP
           pg_s_axis_tx_tlast  <= '1';
           pg_s_axis_tx_tdata  <= (X"000000000000000000000000" & pkt_data); -- Data, don't-care
           pg_s_axis_tx_tkeep  <= X"000F";
           pg_s_axis_tx_tvalid <= '1';
           -- ST_MSG1

         when others =>
           -- No TLP active
           pg_s_axis_tx_tlast  <= '0';
           pg_s_axis_tx_tdata  <= (others => '0');
           pg_s_axis_tx_tkeep  <= (others => '0');
           pg_s_axis_tx_tvalid <= '0';
           -- default case
       end case;
     end process;
  end generate;



end rtl;


-- cgator_pkt_generator
