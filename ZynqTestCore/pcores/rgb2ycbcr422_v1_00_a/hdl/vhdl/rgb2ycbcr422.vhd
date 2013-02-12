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

------------------------------------------------------------------------------
-- Filename            : dvi_24_to_16bit_ycbcr.vhd
-- $Revision:: 2433   $: Revision of last commit
-- $Date:: 2008-10-28#$: Date of last commit
-- Description         : DVI Output Hardware Interface
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity rgb2ycbcr422 is
    port ( 
           -- Input Interface
           clk        : in  std_logic;
           ce         : in  std_logic;
           de_i       : in  std_logic;
           vsync_i    : in  std_logic;
           hsync_i    : in  std_logic;
           data_in    : in  std_logic_vector (23 downto 0); -- {Cb,Cr,Y}
           
  
           -- Output Interface
           de         : out std_logic;
           vsync      : out std_logic;
           hsync      : out std_logic;
           hdmi_data  : out std_logic_vector (15 downto 0);
           hdmi_clk   : out std_logic);
end rgb2ycbcr422;

architecture imp of rgb2ycbcr422 is
   
  signal cbcr_sel                    : std_logic:= '0'; 
   
     -- RGB YCbCr converter signals
  signal rgb_ycbcr_video_in          : std_logic_vector(23 downto 0);  
  signal rgb_ycbcr_hsync             : std_logic;  
  signal rgb_ycbcr_vsync             : std_logic;  
  signal rgb_ycbcr_de                : std_logic;  
  signal rgb_ycbcr_video_out         : std_logic_vector(23 downto 0); 
  signal rgb_ycbcr_video_out_ff      : std_logic_vector(23 downto 0); 
 
  --------------------------------------------------------------------------------
  -- RGB to YCbCr declaration coregen core
  --------------------------------------------------------------------------------
  component rgb_ycbcr
    port (
          sclr                      : in std_logic ; 
          ce                        : in std_logic ; 
          clk                       : in std_logic ; 
          active_video_in           : in std_logic ; 
          video_data_in             : in std_logic_vector ( 23 downto 0 ); 
          hblank_in                 : in std_logic ; 
          vblank_in                 : in std_logic ; 
          vblank_out                : out std_logic; 
          active_video_out          : out std_logic; 
          hblank_out                : out std_logic; 
          video_data_out            : out std_logic_vector ( 23 downto 0 )); 
      end component;
    
   --------------------------------------------------------------------------------
   -- YCbCr 4:4:4 to 4:2:2 converter coregen core
  --------------------------------------------------------------------------------
 
 component chroma_444_422 
   port (
          clk                     : in STD_LOGIC := 'X'; 
          ce                      : in STD_LOGIC := 'X'; 
          sclr                    : in STD_LOGIC := 'X'; 
          vblank_in               : in STD_LOGIC := 'X'; 
          hblank_in               : in STD_LOGIC := 'X'; 
          active_video_in         : in STD_LOGIC := 'X'; 
          chroma_parity           : in STD_LOGIC := 'X'; 
          vblank_out              : out STD_LOGIC; 
          hblank_out              : out STD_LOGIC; 
          active_video_out        : out STD_LOGIC; 
          video_data_in           : in STD_LOGIC_VECTOR ( 23 downto 0 ); 
          num_active_cols         : in STD_LOGIC_VECTOR ( 10 downto 0 ); 
          num_active_rows         : in STD_LOGIC_VECTOR ( 10 downto 0 ); 
          video_data_out          : out STD_LOGIC_VECTOR ( 15 downto 0 ) 
   );
  end component;
 
 
 -- dummy constants
  constant one                       : std_logic:= '1';
  constant zero                      : std_logic:= '0';
  constant rows                      : std_logic_vector(10 downto 0):="10000111000";
  constant cols                      : std_logic_vector(10 downto 0):="11110000000";
  
begin

  --------------------------------------------------------------------------------
  -- RGB to YCbCr instantiation 
  --------------------------------------------------------------------------------
  -- Data realignment as per input data requirement of color space converter  
  rgb_ycbcr_video_in <= data_in(23 downto 16 ) & data_in(7 downto 0) & data_in(15 downto 8);

  conv_ycbcr: rgb_ycbcr
  port map (-- global signals
          sclr             => zero,
          ce               => one,
          clk              => clk,
          hblank_in        => hsync_i,
          vblank_in        => vsync_i,
          active_video_in  => de_i,
          video_data_in    => rgb_ycbcr_video_in,
          hblank_out       => rgb_ycbcr_hsync,
          vblank_out       => rgb_ycbcr_vsync,
          active_video_out => rgb_ycbcr_de,
          video_data_out   => rgb_ycbcr_video_out);


  --------------------------------------------------------------------------------
  -- Output control logic
  --   YCbCr 444 to 422 conversion
  --------------------------------------------------------------------------------
  
  conv_422:  chroma_444_422 
   port map (
          clk                     =>clk, 
          ce                      =>one, 
          sclr                    =>zero, 
          vblank_in               =>rgb_ycbcr_vsync,
          hblank_in               =>rgb_ycbcr_hsync,
          active_video_in         =>rgb_ycbcr_de,
          chroma_parity           =>one, 
          vblank_out              =>vsync, 
          hblank_out              =>hsync, 
          active_video_out        =>de, 
          video_data_in           =>rgb_ycbcr_video_out,
          num_active_cols         =>cols, 
          num_active_rows         =>rows, 
          video_data_out          =>hdmi_data
   );
 
  
 -- OUT_Reg : process (clk)
 -- begin
 --   if (clk'event and (clk = '1')) then
 --     de                     <= rgb_ycbcr_de;
 --     vsync                  <= rgb_ycbcr_vsync;
 --     hsync                  <= rgb_ycbcr_hsync;
 --     rgb_ycbcr_video_out_ff <= rgb_ycbcr_video_out;
      
                     
      -- toggle cbcr selection for every valid pixel
 --     if (rgb_ycbcr_de = '1') then
 --       cbcr_sel <= not cbcr_sel;
 --     else
 --       cbcr_sel <= '0';
 --     end if;      
      
 --   end if; -- clk
 -- end process;

  ODDR_hdmi_clk_p : ODDR
  generic map(
  DDR_CLK_EDGE => "OPPOSITE_EDGE")
  port map (
            Q  => hdmi_clk,
            C  => clk,
            CE => '1',
            D1 => '1',
            D2 => '0',
            R  => '0',
            S  => '0');
  
            
--  OUT_data : process (out_sel,rgb_ycbcr_video_out_ff,cbcr_sel)
--  begin 
--    case out_sel(2 downto 0) is 
--    when "000" => 
--      -- Style 1
--      --Outp--ut assignment
--      if (cbcr_sel = '1') then
--        -- hdmi_data = (Cb,Y)
--        hdmi_data <= rgb_ycbcr_video_out_ff(23 downto 16) & rgb_ycbcr_video_out_ff(7 downto 0);      
--      else
--        -- hdmi_data = (Cr,Y)
--        hdmi_data <= rgb_ycbcr_video_out_ff(15 downto 8) & rgb_ycbcr_video_out_ff(7 downto 0);      
--      end if;
--    
--    when "001" => 
--      -- Style 1, inverted
--      --Output assignment
--      if (cbcr_sel = '0') then
--        -- hdmi_data = (Cb,Y)
--        hdmi_data <= rgb_ycbcr_video_out_ff(23 downto 16) & rgb_ycbcr_video_out_ff(7 downto 0);      
--      else
--        -- hdmi_data = (Cr,Y)
--        hdmi_data <= rgb_ycbcr_video_out_ff(15 downto 8) & rgb_ycbcr_video_out_ff(7 downto 0);      
--      end if;
    
--    when "010" => 
      -- Style 3
      --Output assignment
--      if (cbcr_sel = '1') then
        -- hdmi_data = (Cb,Y)
--        hdmi_data <= rgb_ycbcr_video_out_ff(7 downto 0) & rgb_ycbcr_video_out_ff(23 downto 16);      
--      else
        -- hdmi_data = (Cr,Y)
--        hdmi_data <= rgb_ycbcr_video_out_ff(7 downto 0) & rgb_ycbcr_video_out_ff(15 downto 8);      
--      end if;
    
--    when "011" => 
      -- Style 3 inverted
      --Output assignment
--      if (cbcr_sel = '0') then
        -- hdmi_data = (Cb,Y)
--        hdmi_data <= rgb_ycbcr_video_out_ff(7 downto 0) & rgb_ycbcr_video_out_ff(23 downto 16);      
--      else
        -- hdmi_data = (Cr,Y)
--        hdmi_data <= rgb_ycbcr_video_out_ff(7 downto 0) & rgb_ycbcr_video_out_ff(15 downto 8);      
--      end if;
    
--    when "100" => 
      -- only Y
--        hdmi_data <=  X"00" & rgb_ycbcr_video_out_ff(7 downto 0);   
           
--    when "101" => 
      -- only YCb
--        hdmi_data <= rgb_ycbcr_video_out_ff(7 downto 0) & rgb_ycbcr_video_out_ff(23 downto 16);   
           
           
--    when "110" => 
      -- only YCr
--        hdmi_data <= rgb_ycbcr_video_out_ff(7 downto 0) & rgb_ycbcr_video_out_ff(15 downto 8);   
        
--    when others => 
      -- Style 1
      --Output assignment
--      if (cbcr_sel = '1') then
        -- hdmi_data = (Cb,Y)
--        hdmi_data <= rgb_ycbcr_video_out_ff(23 downto 16) & rgb_ycbcr_video_out_ff(7 downto 0);      
--      else
        -- hdmi_data = (Cr,Y)
--        hdmi_data <= rgb_ycbcr_video_out_ff(15 downto 8) & rgb_ycbcr_video_out_ff(7 downto 0);      
--      end if;
    
--    end case;  
--  end process;   
           
end IMP;

