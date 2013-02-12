--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.7xd
--  \   \         Application: netgen
--  /   /         Filename: chroma_444_422.vhd
-- /___/   /\     Timestamp: Wed Feb 29 22:34:10 2012
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -w -sim -ofmt vhdl /proj/emb_apps/vaibhavk/ZynQ/Final_Systems/702/zynq_hdmi_designs/14_1/video_cores/coregen_cores/444_422/tmp/_cg/chroma_444_422.ngc /proj/emb_apps/vaibhavk/ZynQ/Final_Systems/702/zynq_hdmi_designs/14_1/video_cores/coregen_cores/444_422/tmp/_cg/chroma_444_422.vhd 
-- Device	: xc7z020-clg484-1
-- Input file	: /proj/emb_apps/vaibhavk/ZynQ/Final_Systems/702/zynq_hdmi_designs/14_1/video_cores/coregen_cores/444_422/tmp/_cg/chroma_444_422.ngc
-- Output file	: /proj/emb_apps/vaibhavk/ZynQ/Final_Systems/702/zynq_hdmi_designs/14_1/video_cores/coregen_cores/444_422/tmp/_cg/chroma_444_422.vhd
-- # of Entities	: 1
-- Design Name	: chroma_444_422
-- Xilinx	: /proj/xbuilds/ids_14.1_P.7xd.0.1/lin64/14.1/ISE_DS/ISE/
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Command Line Tools User Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------


-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity chroma_444_422 is
  port (
    clk : in STD_LOGIC := 'X'; 
    ce : in STD_LOGIC := 'X'; 
    sclr : in STD_LOGIC := 'X'; 
    vblank_in : in STD_LOGIC := 'X'; 
    hblank_in : in STD_LOGIC := 'X'; 
    active_video_in : in STD_LOGIC := 'X'; 
    chroma_parity : in STD_LOGIC := 'X'; 
    vblank_out : out STD_LOGIC; 
    hblank_out : out STD_LOGIC; 
    active_video_out : out STD_LOGIC; 
    video_data_in : in STD_LOGIC_VECTOR ( 23 downto 0 ); 
    num_active_cols : in STD_LOGIC_VECTOR ( 10 downto 0 ); 
    num_active_rows : in STD_LOGIC_VECTOR ( 10 downto 0 ); 
    video_data_out : out STD_LOGIC_VECTOR ( 15 downto 0 ) 
  );
end chroma_444_422;

architecture STRUCTURE of chroma_444_422 is
  signal U0_coretop_intcore_from_444_to_422_convert_vblank_out : STD_LOGIC; 
  signal U0_coretop_intcore_from_444_to_422_convert_hblank_out : STD_LOGIC; 
  signal U0_coretop_intcore_from_444_to_422_convert_active_video_out : STD_LOGIC; 
  signal sig00000001 : STD_LOGIC; 
  signal sig00000002 : STD_LOGIC; 
  signal sig00000003 : STD_LOGIC; 
  signal sig00000004 : STD_LOGIC; 
  signal sig00000005 : STD_LOGIC; 
  signal sig00000006 : STD_LOGIC; 
  signal sig00000007 : STD_LOGIC; 
  signal sig00000008 : STD_LOGIC; 
  signal sig00000009 : STD_LOGIC; 
  signal sig0000000a : STD_LOGIC; 
  signal sig0000000b : STD_LOGIC; 
  signal sig0000000c : STD_LOGIC; 
  signal sig0000000d : STD_LOGIC; 
  signal sig0000000e : STD_LOGIC; 
  signal sig0000000f : STD_LOGIC; 
  signal sig00000010 : STD_LOGIC; 
  signal sig00000011 : STD_LOGIC; 
  signal sig00000012 : STD_LOGIC; 
  signal sig00000013 : STD_LOGIC; 
  signal sig00000014 : STD_LOGIC; 
  signal sig00000015 : STD_LOGIC; 
  signal sig00000016 : STD_LOGIC; 
  signal sig00000017 : STD_LOGIC; 
  signal sig00000018 : STD_LOGIC; 
  signal sig00000019 : STD_LOGIC; 
  signal sig0000001a : STD_LOGIC; 
  signal sig0000001b : STD_LOGIC; 
  signal sig0000001c : STD_LOGIC; 
  signal sig0000001d : STD_LOGIC; 
  signal sig0000001e : STD_LOGIC; 
  signal sig0000001f : STD_LOGIC; 
  signal sig00000020 : STD_LOGIC; 
  signal sig00000021 : STD_LOGIC; 
  signal sig00000022 : STD_LOGIC; 
  signal sig00000023 : STD_LOGIC; 
  signal sig00000024 : STD_LOGIC; 
  signal sig00000025 : STD_LOGIC; 
  signal sig00000026 : STD_LOGIC; 
  signal sig00000027 : STD_LOGIC; 
  signal sig00000028 : STD_LOGIC; 
  signal sig00000029 : STD_LOGIC; 
  signal sig0000002a : STD_LOGIC; 
  signal sig0000002b : STD_LOGIC; 
  signal sig0000002c : STD_LOGIC; 
  signal sig0000002d : STD_LOGIC; 
  signal sig0000002e : STD_LOGIC; 
  signal sig0000002f : STD_LOGIC; 
  signal sig00000030 : STD_LOGIC; 
  signal sig00000031 : STD_LOGIC; 
  signal sig00000032 : STD_LOGIC; 
  signal sig00000033 : STD_LOGIC; 
  signal sig00000034 : STD_LOGIC; 
  signal sig00000035 : STD_LOGIC; 
  signal sig00000036 : STD_LOGIC; 
  signal sig00000037 : STD_LOGIC; 
  signal sig00000038 : STD_LOGIC; 
  signal sig00000039 : STD_LOGIC; 
  signal sig0000003a : STD_LOGIC; 
  signal sig0000003b : STD_LOGIC; 
  signal sig0000003c : STD_LOGIC; 
  signal sig0000003d : STD_LOGIC; 
  signal sig0000003e : STD_LOGIC; 
  signal sig0000003f : STD_LOGIC; 
  signal NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out : STD_LOGIC_VECTOR ( 7 downto 0 ); 
begin
  video_data_out(15) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(7);
  video_data_out(14) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(6);
  video_data_out(13) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(5);
  video_data_out(12) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(4);
  video_data_out(11) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(3);
  video_data_out(10) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(2);
  video_data_out(9) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(1);
  video_data_out(8) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(0);
  video_data_out(7) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(7);
  video_data_out(6) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(6);
  video_data_out(5) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(5);
  video_data_out(4) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(4);
  video_data_out(3) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(3);
  video_data_out(2) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(2);
  video_data_out(1) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(1);
  video_data_out(0) <= NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(0);
  vblank_out <= U0_coretop_intcore_from_444_to_422_convert_vblank_out;
  hblank_out <= U0_coretop_intcore_from_444_to_422_convert_hblank_out;
  active_video_out <= U0_coretop_intcore_from_444_to_422_convert_active_video_out;
  blk00000001 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => sig00000016,
      Q => sig0000000b
    );
  blk00000002 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => sig00000015,
      Q => sig0000000a
    );
  blk00000003 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => sig00000014,
      Q => sig00000009
    );
  blk00000004 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => sig00000013,
      Q => sig00000008
    );
  blk00000005 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => sig00000012,
      Q => sig00000007
    );
  blk00000006 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => sig00000011,
      Q => sig00000006
    );
  blk00000007 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => sig00000010,
      Q => sig00000005
    );
  blk00000008 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => sig0000000f,
      Q => sig00000004
    );
  blk00000009 : FDRE
    port map (
      C => clk,
      CE => ce,
      D => sig0000000c,
      R => sclr,
      Q => U0_coretop_intcore_from_444_to_422_convert_vblank_out
    );
  blk0000000a : FDRE
    port map (
      C => clk,
      CE => ce,
      D => sig0000000d,
      R => sclr,
      Q => U0_coretop_intcore_from_444_to_422_convert_hblank_out
    );
  blk0000000b : FDRE
    port map (
      C => clk,
      CE => ce,
      D => sig0000000e,
      R => sclr,
      Q => U0_coretop_intcore_from_444_to_422_convert_active_video_out
    );
  blk0000000c : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => sig00000002,
      D => vblank_in,
      Q => sig0000000c
    );
  blk0000000d : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => sig00000002,
      D => hblank_in,
      Q => sig0000000d
    );
  blk0000000e : FDE
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      CE => sig00000002,
      D => active_video_in,
      Q => sig0000000e
    );
  blk0000000f : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(23),
      Q => sig00000026
    );
  blk00000010 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(22),
      Q => sig00000025
    );
  blk00000011 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(21),
      Q => sig00000024
    );
  blk00000012 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(20),
      Q => sig00000023
    );
  blk00000013 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(19),
      Q => sig00000022
    );
  blk00000014 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(18),
      Q => sig00000021
    );
  blk00000015 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(17),
      Q => sig00000020
    );
  blk00000016 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(16),
      Q => sig0000001f
    );
  blk00000017 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(7),
      Q => sig0000002e
    );
  blk00000018 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(6),
      Q => sig0000002d
    );
  blk00000019 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(5),
      Q => sig0000002c
    );
  blk0000001a : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(4),
      Q => sig0000002b
    );
  blk0000001b : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(3),
      Q => sig0000002a
    );
  blk0000001c : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(2),
      Q => sig00000029
    );
  blk0000001d : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(1),
      Q => sig00000028
    );
  blk0000001e : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(0),
      Q => sig00000027
    );
  blk0000001f : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(15),
      Q => sig0000001e
    );
  blk00000020 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(14),
      Q => sig0000001d
    );
  blk00000021 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(13),
      Q => sig0000001c
    );
  blk00000022 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(12),
      Q => sig0000001b
    );
  blk00000023 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(11),
      Q => sig0000001a
    );
  blk00000024 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(10),
      Q => sig00000019
    );
  blk00000025 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(9),
      Q => sig00000018
    );
  blk00000026 : FDE
    port map (
      C => clk,
      CE => sig00000002,
      D => video_data_in(8),
      Q => sig00000017
    );
  blk00000027 : LUT4
    generic map(
      INIT => X"BA8A"
    )
    port map (
      I0 => sig00000017,
      I1 => sig0000000e,
      I2 => active_video_in,
      I3 => video_data_in(8),
      O => sig0000000f
    );
  blk00000028 : LUT4
    generic map(
      INIT => X"BA8A"
    )
    port map (
      I0 => sig00000018,
      I1 => sig0000000e,
      I2 => active_video_in,
      I3 => video_data_in(9),
      O => sig00000010
    );
  blk00000029 : LUT4
    generic map(
      INIT => X"BA8A"
    )
    port map (
      I0 => sig00000019,
      I1 => sig0000000e,
      I2 => active_video_in,
      I3 => video_data_in(10),
      O => sig00000011
    );
  blk0000002a : LUT4
    generic map(
      INIT => X"BA8A"
    )
    port map (
      I0 => sig0000001a,
      I1 => sig0000000e,
      I2 => active_video_in,
      I3 => video_data_in(11),
      O => sig00000012
    );
  blk0000002b : LUT4
    generic map(
      INIT => X"BA8A"
    )
    port map (
      I0 => sig0000001b,
      I1 => sig0000000e,
      I2 => active_video_in,
      I3 => video_data_in(12),
      O => sig00000013
    );
  blk0000002c : LUT4
    generic map(
      INIT => X"BA8A"
    )
    port map (
      I0 => sig0000001c,
      I1 => sig0000000e,
      I2 => active_video_in,
      I3 => video_data_in(13),
      O => sig00000014
    );
  blk0000002d : LUT4
    generic map(
      INIT => X"BA8A"
    )
    port map (
      I0 => sig0000001d,
      I1 => sig0000000e,
      I2 => active_video_in,
      I3 => video_data_in(14),
      O => sig00000015
    );
  blk0000002e : LUT4
    generic map(
      INIT => X"BA8A"
    )
    port map (
      I0 => sig0000001e,
      I1 => sig0000000e,
      I2 => active_video_in,
      I3 => video_data_in(15),
      O => sig00000016
    );
  blk0000002f : LUT3
    generic map(
      INIT => X"02"
    )
    port map (
      I0 => ce,
      I1 => sclr,
      I2 => sig0000000e,
      O => sig00000001
    );
  blk00000030 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => sclr,
      I1 => ce,
      O => sig00000002
    );
  blk00000031 : FD
    port map (
      C => clk,
      D => sig0000002f,
      Q => sig00000003
    );
  blk00000032 : FD
    port map (
      C => clk,
      D => sig00000030,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(7)
    );
  blk00000033 : FD
    port map (
      C => clk,
      D => sig00000031,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(6)
    );
  blk00000034 : FD
    port map (
      C => clk,
      D => sig00000032,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(5)
    );
  blk00000035 : FD
    port map (
      C => clk,
      D => sig00000033,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(4)
    );
  blk00000036 : FD
    port map (
      C => clk,
      D => sig00000034,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(3)
    );
  blk00000037 : FD
    port map (
      C => clk,
      D => sig00000035,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(2)
    );
  blk00000038 : FD
    port map (
      C => clk,
      D => sig00000036,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(1)
    );
  blk00000039 : FD
    port map (
      C => clk,
      D => sig00000037,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(0)
    );
  blk0000003a : FD
    port map (
      C => clk,
      D => sig00000038,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(7)
    );
  blk0000003b : FD
    port map (
      C => clk,
      D => sig00000039,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(6)
    );
  blk0000003c : FD
    port map (
      C => clk,
      D => sig0000003a,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(5)
    );
  blk0000003d : FD
    port map (
      C => clk,
      D => sig0000003b,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(4)
    );
  blk0000003e : FD
    port map (
      C => clk,
      D => sig0000003c,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(3)
    );
  blk0000003f : FD
    port map (
      C => clk,
      D => sig0000003d,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(2)
    );
  blk00000040 : FD
    port map (
      C => clk,
      D => sig0000003e,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(1)
    );
  blk00000041 : FD
    port map (
      C => clk,
      D => sig0000003f,
      Q => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(0)
    );
  blk00000042 : LUT6
    generic map(
      INIT => X"00000000EE44E4E4"
    )
    port map (
      I0 => sig00000002,
      I1 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(7),
      I2 => sig00000026,
      I3 => sig0000000b,
      I4 => sig00000003,
      I5 => sig00000001,
      O => sig00000030
    );
  blk00000043 : LUT6
    generic map(
      INIT => X"00000000EE44E4E4"
    )
    port map (
      I0 => sig00000002,
      I1 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(6),
      I2 => sig00000025,
      I3 => sig0000000a,
      I4 => sig00000003,
      I5 => sig00000001,
      O => sig00000031
    );
  blk00000044 : LUT6
    generic map(
      INIT => X"00000000EE44E4E4"
    )
    port map (
      I0 => sig00000002,
      I1 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(5),
      I2 => sig00000024,
      I3 => sig00000009,
      I4 => sig00000003,
      I5 => sig00000001,
      O => sig00000032
    );
  blk00000045 : LUT6
    generic map(
      INIT => X"00000000EE44E4E4"
    )
    port map (
      I0 => sig00000002,
      I1 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(4),
      I2 => sig00000023,
      I3 => sig00000008,
      I4 => sig00000003,
      I5 => sig00000001,
      O => sig00000033
    );
  blk00000046 : LUT6
    generic map(
      INIT => X"00000000EE44E4E4"
    )
    port map (
      I0 => sig00000002,
      I1 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(3),
      I2 => sig00000022,
      I3 => sig00000007,
      I4 => sig00000003,
      I5 => sig00000001,
      O => sig00000034
    );
  blk00000047 : LUT6
    generic map(
      INIT => X"00000000EE44E4E4"
    )
    port map (
      I0 => sig00000002,
      I1 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(2),
      I2 => sig00000021,
      I3 => sig00000006,
      I4 => sig00000003,
      I5 => sig00000001,
      O => sig00000035
    );
  blk00000048 : LUT6
    generic map(
      INIT => X"00000000EE44E4E4"
    )
    port map (
      I0 => sig00000002,
      I1 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(1),
      I2 => sig00000020,
      I3 => sig00000005,
      I4 => sig00000003,
      I5 => sig00000001,
      O => sig00000036
    );
  blk00000049 : LUT6
    generic map(
      INIT => X"00000000EE44E4E4"
    )
    port map (
      I0 => sig00000002,
      I1 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_CbCrRep(0),
      I2 => sig0000001f,
      I3 => sig00000004,
      I4 => sig00000003,
      I5 => sig00000001,
      O => sig00000037
    );
  blk0000004a : LUT5
    generic map(
      INIT => X"51114000"
    )
    port map (
      I0 => sclr,
      I1 => ce,
      I2 => sig0000000e,
      I3 => sig0000002e,
      I4 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(7),
      O => sig00000038
    );
  blk0000004b : LUT5
    generic map(
      INIT => X"51114000"
    )
    port map (
      I0 => sclr,
      I1 => ce,
      I2 => sig0000000e,
      I3 => sig0000002d,
      I4 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(6),
      O => sig00000039
    );
  blk0000004c : LUT5
    generic map(
      INIT => X"51114000"
    )
    port map (
      I0 => sclr,
      I1 => ce,
      I2 => sig0000000e,
      I3 => sig0000002c,
      I4 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(5),
      O => sig0000003a
    );
  blk0000004d : LUT5
    generic map(
      INIT => X"51114000"
    )
    port map (
      I0 => sclr,
      I1 => ce,
      I2 => sig0000000e,
      I3 => sig0000002b,
      I4 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(4),
      O => sig0000003b
    );
  blk0000004e : LUT5
    generic map(
      INIT => X"51114000"
    )
    port map (
      I0 => sclr,
      I1 => ce,
      I2 => sig0000000e,
      I3 => sig0000002a,
      I4 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(3),
      O => sig0000003c
    );
  blk0000004f : LUT5
    generic map(
      INIT => X"51114000"
    )
    port map (
      I0 => sclr,
      I1 => ce,
      I2 => sig0000000e,
      I3 => sig00000029,
      I4 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(2),
      O => sig0000003d
    );
  blk00000050 : LUT5
    generic map(
      INIT => X"51114000"
    )
    port map (
      I0 => sclr,
      I1 => ce,
      I2 => sig0000000e,
      I3 => sig00000028,
      I4 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(1),
      O => sig0000003e
    );
  blk00000051 : LUT5
    generic map(
      INIT => X"51114000"
    )
    port map (
      I0 => sclr,
      I1 => ce,
      I2 => sig0000000e,
      I3 => sig00000027,
      I4 => NlwRenamedSig_OI_U0_coretop_intcore_from_444_to_422_convert_luma_out(0),
      O => sig0000003f
    );
  blk00000052 : LUT5
    generic map(
      INIT => X"F30CF304"
    )
    port map (
      I0 => active_video_in,
      I1 => ce,
      I2 => sclr,
      I3 => sig00000003,
      I4 => sig0000000e,
      O => sig0000002f
    );

end STRUCTURE;

-- synthesis translate_on
