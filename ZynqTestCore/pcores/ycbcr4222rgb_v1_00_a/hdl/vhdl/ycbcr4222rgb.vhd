--  ***************************************************************************
--  ** DISCLAIMER OF LIABILITY                                               **
--  **                                                                       **
--  **  This file contains proprietary and confidential information of       **
--  **  Xilinx, Inc. ("Xilinx"), that is distributed under a license         **
--  **  from Xilinx, and may be used, copied and/or disclosed only           **
--  **  pursuant to the terms of a valid license agreement with Xilinx.      **
--  **                                                                       **
--  **  XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION                **
--  **  ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER           **
--  **  EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT                  **
--  **  LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,            **
--  **  MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx        **
--  **  does not warrant that functions included in the Materials will       **
--  **  meet the requirements of Licensee, or that the operation of the      **
--  **  Materials will be uninterrupted or error-free, or that defects       **
--  **  in the Materials will be corrected. Furthermore, Xilinx does         **
--  **  not warrant or make any representations regarding use, or the        **
--  **  results of the use, of the Materials in terms of correctness,        **
--  **  accuracy, reliability or otherwise.                                  **
--  **                                                                       **
--  **  Xilinx products are not designed or intended to be fail-safe,        **
--  **  or for use in any application requiring fail-safe performance,       **
--  **  such as life-support or safety devices or systems, Class III         **
--  **  medical devices, nuclear facilities, applications related to         **
--  **  the deployment of airbags, or any other applications that could      **
--  **  lead to death, personal injury or severe property or                 **
--  **  environmental damage (individually and collectively, "critical       **
--  **  applications"). Customer assumes the sole risk and liability         **
--  **  of any use of Xilinx products in critical applications,              **
--  **  subject only to applicable laws and regulations governing            **
--  **  limitations on product liability.                                    **
--  **                                                                       **
--  **  Copyright 2010 Xilinx, Inc.                                          **
--  **  All rights reserved.                                                 **
--  **                                                                       **
--  **  This disclaimer and copyright notice must be retained as part        **
--  **  of this file at all times.                                           **
--  ***************************************************************************
--  This is the wrapper that instantiates ycbcr4222_444 and croma_resampler
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ycbcr4222rgb is
  port (
    vblank_in : in STD_LOGIC := 'X'; 
    hblank_in : in STD_LOGIC := 'X'; 
    de_in : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    vblank_out : out STD_LOGIC; 
    hblank_out : out STD_LOGIC; 
    de_out : out STD_LOGIC; 
    video_in : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
    video_out : out STD_LOGIC_VECTOR ( 23 downto 0 ) 
  );
end ycbcr4222rgb;

architecture STRUCTURE of ycbcr4222rgb is
  constant rows                      : std_logic_vector(10 downto 0):="10000111000";
  constant cols                      : std_logic_vector(10 downto 0):="11110000000";
  constant one                       : std_logic:= '1';
  constant zero                      : std_logic:= '0';
  signal   vblank_out_int            : std_logic;
  signal   hblank_out_int            : std_logic;
  signal   active_video_out_int      : std_logic;
  signal   video_data_out_int        : std_logic_vector(23 downto 0);


component chroma_resampler is
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
    video_data_in : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
    num_active_cols : in STD_LOGIC_VECTOR ( 10 downto 0 ); 
    num_active_rows : in STD_LOGIC_VECTOR ( 10 downto 0 ); 
    video_data_out : out STD_LOGIC_VECTOR ( 23 downto 0 ) 
  );
end component;

component v_ycrcb2rgb_v4_0 is
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
end component;

begin
U_chroma_resampler: chroma_resampler
  port map (
    clk                => clk,
    ce                 => one,
    sclr               => zero,
    vblank_in          => vblank_in,
    hblank_in          => hblank_in,
    active_video_in    => de_in,
    chroma_parity      => one,
    vblank_out         => vblank_out_int,
    hblank_out         => hblank_out_int,
    active_video_out   => active_video_out_int,
    video_data_in      => video_in,
    num_active_cols    => cols,
    num_active_rows    => rows,
    video_data_out     => video_data_out_int
  );

U_v_ycrcb2rgb_v4_0: v_ycrcb2rgb_v4_0
  port map (
    vblank_in          => vblank_out_int,
    hblank_in          => hblank_out_int,
    active_video_in    => active_video_out_int,
    clk                => clk,
    ce                 => one,
    sclr               => zero,
    vblank_out         => vblank_out,
    hblank_out         => hblank_out,
    active_video_out   => de_out,
    video_data_in      => video_data_out_int,
    video_data_out     => video_out
  );

end STRUCTURE;
