--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.7xd
--  \   \         Application: netgen
--  /   /         Filename: v_ycrcb2rgb_v4_0.vhd
-- /___/   /\     Timestamp: Mon Mar  5 17:59:15 2012
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -w -sim -ofmt vhdl /proj/emb_apps/kravi/zynq_trd/new_avnet_card/coregen_cores/tmp/_cg/v_ycrcb2rgb_v4_0.ngc /proj/emb_apps/kravi/zynq_trd/new_avnet_card/coregen_cores/tmp/_cg/v_ycrcb2rgb_v4_0.vhd 
-- Device	: 7z020clg484-1
-- Input file	: /proj/emb_apps/kravi/zynq_trd/new_avnet_card/coregen_cores/tmp/_cg/v_ycrcb2rgb_v4_0.ngc
-- Output file	: /proj/emb_apps/kravi/zynq_trd/new_avnet_card/coregen_cores/tmp/_cg/v_ycrcb2rgb_v4_0.vhd
-- # of Entities	: 1
-- Design Name	: v_ycrcb2rgb_v4_0
-- Xilinx	: /proj/xbuilds/ids_14.1_P.7xd.0.0/lin64/14.1/ISE_DS/ISE/
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity v_ycrcb2rgb_v4_0 is
  port (
    vblank_in : in STD_LOGIC := 'X'; 
    hblank_in : in STD_LOGIC := 'X'; 
    active_video_in : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    ce : in STD_LOGIC := 'X'; 
    sclr : in STD_LOGIC := 'X'; 
    vblank_out : out STD_LOGIC; 
    hblank_out : out STD_LOGIC; 
    active_video_out : out STD_LOGIC; 
    video_data_in : in STD_LOGIC_VECTOR ( 23 downto 0 ); 
    video_data_out : out STD_LOGIC_VECTOR ( 23 downto 0 ) 
  );
end v_ycrcb2rgb_v4_0;

architecture STRUCTURE of v_ycrcb2rgb_v4_0 is
begin
end STRUCTURE;

