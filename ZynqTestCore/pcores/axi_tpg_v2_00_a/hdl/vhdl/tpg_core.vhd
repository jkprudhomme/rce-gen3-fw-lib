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

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity tpg_core is
generic 
(
   C_FAMILY          :  string   := "virtex5";
   C_Chroma_Format   :  integer  := 0 -- 0 = RGB444; 1 = YCbCr422
);
port 
(
   clk                  :  in    std_logic;
   rst                  :  in    std_logic;
   vsync_in             :  in    std_logic;
   hsync_in             :  in    std_logic;
   vblank_in            :  in    std_logic;
   hblank_in            :  in    std_logic;
   CbCrPolarity         :  in    std_logic;
   VSyncPolarity        :  in    std_logic;
   HSyncPolarity        :  in    std_logic;
   VBlankPolarity       :  in    std_logic;
   HBlankPolarity       :  in    std_logic;
   de_in                :  in    std_logic;
   red_in               :  in    std_logic_vector(7 downto 0);
   green_in             :  in    std_logic_vector(7 downto 0);
   blue_in              :  in    std_logic_vector(7 downto 0);
   Motion               :  in    std_logic;
   Motion_speed         :  in    std_logic_vector(7 downto 0);
   PatternSel           :  in    std_logic_vector(3 downto 0);
   EnableXHairs         :  in    std_logic;
   EnableBox            :  in    std_logic;
   ComponentMask        :  in    std_logic_vector(2 downto 0);
   XHairsV              :  in    std_logic_vector(11 downto 0);
   XHairsH              :  in    std_logic_vector(11 downto 0);
   BoxSize              :  in    std_logic_vector(11 downto 0);
   BoxColour            :  in    std_logic_vector(23 downto 0);
   active_line_length   :  in    std_logic_vector(11 downto 0);
   active_frame_height  :  in    std_logic_vector(11 downto 0);
   ZPlateHDeltaStart    :  in    std_logic_vector(15 downto 0);
   ZPlateHDelta2        :  in    std_logic_vector(15 downto 0);
   ZPlateVDeltaStart    :  in    std_logic_vector(15 downto 0);
   ZPlateVDelta2        :  in    std_logic_vector(15 downto 0);
   vsync_out            :  out   std_logic;
   hsync_out            :  out   std_logic;
   vblank_out           :  out   std_logic;
   hblank_out           :  out   std_logic;
   de_out               :  out   std_logic;
   red_out              :  out   std_logic_vector(7 downto 0);
   green_out            :  out   std_logic_vector(7 downto 0);
   blue_out             :  out   std_logic_vector(7 downto 0);
   ZP_debug             :  out   std_logic_vector(57 downto 0);
   TPG_debug            :  out   std_logic_vector(38 downto 0)
);
end tpg_core;

architecture Behavioral of tpg_core is
   

signal   d1                :  STD_LOGIC_VECTOR (11 downto 0);
signal   d2                :  STD_LOGIC_VECTOR (11 downto 0);
signal   hdata             :  STD_LOGIC_VECTOR (7 downto 0);
signal   vdata             :  STD_LOGIC_VECTOR (7 downto 0);
signal   HCount            :  STD_LOGIC_VECTOR (11 downto 0);
signal   VCount            :  STD_LOGIC_VECTOR (11 downto 0);
signal   d_vsync_in        :  std_logic;
signal   d_vblank_in       :  std_logic;
signal   d2_vsync_in       :  std_logic;
signal   re_vsync_in       :  std_logic;
signal   d_hsync_in        :  std_logic;
signal   d_hblank_in       :  std_logic;
signal   d2_hsync_in       :  std_logic;
signal   d2_de_in          :  std_logic;
signal   fe_de_in          :  std_logic;
signal   d_de_in           :  std_logic;
signal   re_hsync_in       :  std_logic;
signal   fe_hsync_in       :  std_logic;
signal   RampStart         :  STD_LOGIC_VECTOR (7 downto 0);

signal   red               :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   green             :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   blue              :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   Y                 :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   Cb                :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   Cr                :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   bar_red           :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   bar_green         :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   bar_blue          :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   bar_Y             :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   bar_Cb            :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   bar_Cr            :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   BarWidth          :  STD_LOGIC_VECTOR ( 8 downto 0);
signal   BarHCount         :  STD_LOGIC_VECTOR ( 8 downto 0);
signal   BarSel            :  STD_LOGIC_VECTOR ( 2 downto 0);
signal   XHairValue        :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   CSel              :  std_logic;
signal   ZPlateDOut        :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   ZPStart           :  STD_LOGIC_VECTOR ( 15 downto 0);
signal   d_red_in          :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   d_green_in        :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   d_blue_in         :  STD_LOGIC_VECTOR ( 7 downto 0);
signal   BoxHCoord         :  STD_LOGIC_VECTOR (11 downto 0);
signal   BoxVCoord         :  STD_LOGIC_VECTOR (11 downto 0);
signal   HMin              :  STD_LOGIC_VECTOR (11 downto 0);
signal   HMax              :  STD_LOGIC_VECTOR (11 downto 0);
signal   VMin              :  STD_LOGIC_VECTOR (11 downto 0);
signal   VMax              :  STD_LOGIC_VECTOR (11 downto 0);
signal   BoxTop            :  STD_LOGIC_VECTOR (11 downto 0);
signal   BoxBottom         :  STD_LOGIC_VECTOR (11 downto 0);
signal   BoxLeft           :  STD_LOGIC_VECTOR (11 downto 0);
signal   BoxRight          :  STD_LOGIC_VECTOR (11 downto 0);
signal   BoxEn             :  std_logic;
signal   HBoxEn            :  std_logic;
signal   VBoxEn            :  std_logic;
signal   HDir              :  std_logic;
signal   VDir              :  std_logic;
signal   t_red_out         :  std_logic_vector(7 downto 0);
signal   t_blue_out        :  std_logic_vector(7 downto 0);
signal   t_green_out       :  std_logic_vector(7 downto 0);
signal   t_de_out          :  std_logic;
signal   zp_vsync_in       :  std_logic;
signal   zp_hsync_in       :  std_logic;

begin
TPGCount : process (clk)   
begin
if (clk'event) and (clk = '1') then
   
   if (VSyncPolarity = '0') then
      d_vsync_in     <= vsync_in;
   else
      d_vsync_in     <= not(vsync_in);
   end if;
   if (HSyncPolarity = '0') then
      d_hsync_in     <= hsync_in;
   else
      d_hsync_in     <= not(hsync_in);
   end if;
   if (VBlankPolarity = '0') then
      d_vblank_in     <= vblank_in;
   else
      d_vblank_in     <= not(vblank_in);
   end if;
   if (HBlankPolarity = '0') then
      d_hblank_in     <= hblank_in;
   else
      d_hblank_in     <= not(hblank_in);
   end if;
      
   d2_hsync_in    <= d_hsync_in;
   d2_vsync_in    <= d_vsync_in;
   re_vsync_in    <= d_vsync_in and not(d2_vsync_in);
   re_hsync_in    <= d_hsync_in and not(d2_hsync_in);
   fe_hsync_in    <= d2_hsync_in and not(d_hsync_in);
   
   if (rst = '1') then
      RampStart   <= (others => '0');
      vdata       <= (others => '0');
      hdata       <= (others => '0');
      VCount      <= (others => '0');
      HCount      <= (others => '0');
   else
      if (re_vsync_in = '1') then
         if (Motion = '1') then
               RampStart   <= RampStart + Motion_speed;
         else
            RampStart   <= "00000000";
         end if;
         vdata <= RampStart;
      else
         if (fe_hsync_in = '1') then
            hdata    <= RampStart;
            vdata    <= vdata + 1;
         elsif (d_de_in = '1') then
            hdata    <= hdata + 1;
         end if;
      end if;
   
      if (re_vsync_in = '1') then
         VCount      <= (others => '0');
      else
         if (fe_de_in = '1') then
            VCount   <= VCount + 1;
            HCount   <= (others => '0');
         elsif (d_de_in = '1') then
            HCount   <= HCount + 1;
         end if;
      end if;
   end if;
end if;
end process;   

ZPStart  <= RampStart & "00000000";


ZPSyncSel:process(hsync_in, vsync_in, VSyncPolarity, HSyncPolarity)
begin
   if (VSyncPolarity = '0') then
      zp_vsync_in <= vsync_in;
   else
      zp_vsync_in <= not(vsync_in);
   end if;
   if (HSyncPolarity = '0') then
      zp_hsync_in <= hsync_in;
   else
      zp_hsync_in <= not(hsync_in);
   end if;
end process;


ZPlate1: entity work.zplate
generic map
(
   OutWidth       => 8,
   DeltaWidth     => 16
   
)
port  map
(
   clk   	      => clk,
   HDeltaStart    => ZPlateHDeltaStart,
   HDelta2        => ZPlateHDelta2,
   VDeltaStart    => ZPlateVDeltaStart,
   VDelta2        => ZPlateVDelta2,
   ZPStart        => ZPStart,
   de_in          => de_in,
   HSync          => zp_hsync_in,
   VSync          => zp_vsync_in,
   Dout           => ZPlateDOut,
   ZP_debug       => ZP_debug
);



BarsGen : process (clk)   
begin
if (clk'event) and (clk = '1') then
   BarWidth       <= active_line_length(11 downto 3); 
   if (fe_hsync_in = '1') then
      BarHCount   <= (others => '0');
      BarSel      <= (others => '0');
   elsif (BarHCount = BarWidth) then
      BarSel      <= BarSel + '1';
      BarHCount   <= (others => '0');
   elsif (d_de_in = '1') then
      BarHCount   <= BarHCount + '1';
   end if;
   
   case BarSel is
      when "000" => --  white
         bar_red      <= "11111111";
         bar_green    <= "11111111";
         bar_blue     <= "11111111";
         bar_Y        <= "11101011"; 
         bar_Cb       <= "10000000"; 
         bar_Cr       <= "10000000";
      when "001" => --  yellow
         bar_red      <= "11111111";
         bar_green    <= "11111111";
         bar_blue     <= "00000000";
         bar_Y        <= "11010010"; 
         bar_Cb       <= "00001000"; 
         bar_Cr       <= "10010010";
      when "010" => --  cyan
         bar_red      <= "00000000";
         bar_green    <= "11111111";
         bar_blue     <= "11111111";
         bar_Y        <= "10101010"; 
         bar_Cb       <= "10100110"; 
         bar_Cr       <= "00001000";
      when "011" => --  green
         bar_red      <= "00000000";
         bar_green    <= "11111111";
         bar_blue     <= "00000000";
         bar_Y        <= "10010001"; 
         bar_Cb       <= "00110110"; 
         bar_Cr       <= "00100010";
      when "100" => --  magenta
         bar_red      <= "11111111";
         bar_green    <= "00000000";
         bar_blue     <= "11111111";
         bar_Y        <= "01101010"; 
         bar_Cb       <= "11001010"; 
         bar_Cr       <= "11011110";
      when "101" => --  red
         bar_red      <= "11111111";
         bar_green    <= "00000000";
         bar_blue     <= "00000000";
         bar_Y        <= "01010001"; 
         bar_Cb       <= "01011010"; 
         bar_Cr       <= "11110000";
      when "110" => --  blue
         bar_red      <= "00000000";
         bar_green    <= "00000000";
         bar_blue     <= "11111111";
         bar_Y        <= "00101001"; 
         bar_Cb       <= "11110000"; 
         bar_Cr       <= "01101110";
      when "111" => --  black
         bar_red      <= "00000000";
         bar_green    <= "00000000";
         bar_blue     <= "00000000";
         bar_Y        <= "00001000"; 
         bar_Cb       <= "10000000"; 
         bar_Cr       <= "10000000";
      when others => null;
   end case;
end if;
end process;  

TPG_SM : process (clk)   
begin
if (clk'event) and (clk = '1') then
   d_de_in        <= de_in;
   d_red_in       <= red_in;
   d_green_in     <= green_in;
   d_blue_in      <= blue_in;
   
   vsync_out      <= d_vsync_in;
   hsync_out      <= d_hsync_in;
   vblank_out     <= d_vblank_in;
   hblank_out     <= d_hblank_in;
   
   t_de_out       <= d_de_in;
   fe_de_in       <= not(d_de_in) and t_de_out;

   case (PatternSel) is
      when "0000" => -- Input passthrough
         XHairValue <= "11110000"; -- max
         red   <= red_in;
         green <= green_in;
         blue  <= blue_in;
         Y     <= red_in;
         if (CbCrPolarity = '0') then
            Cb    <= green_in;
            Cr    <= green_in;
         else
            Cb    <= d_green_in;
            Cr    <= d_green_in;
         end if;
      when "0001" => -- horizontal ramp
         XHairValue <= "11110000"; -- max
         red   <= hdata;
         green <= hdata;
         blue  <= hdata;
         Y     <= hdata;
         Cb    <= hdata; 
         Cr    <= hdata; 
      when "0010" => -- vertical ramp
         XHairValue <= "11110000"; -- max
         red   <= vdata;
         green <= vdata;
         blue  <= vdata;
         Y     <= vdata;
         Cb    <= vdata;
         Cr    <= vdata;
      when "0011" => -- temporal ramp
         XHairValue <= "11110000"; -- max
         red   <= RampStart;
         green <= RampStart;
         blue  <= RampStart;
         Y     <= RampStart;
         Cb    <= RampStart;
         Cr    <= RampStart;
      when "0100" => -- red
         XHairValue <= "11110000"; -- max
         red   <= "10110100";
         green <= "00010000";
         blue  <= "00010000";
         Y     <= "01010001"; 
         Cb    <= "01011010"; 
         Cr    <= "11110000";
      when "0101" => -- green
         XHairValue <= "11110000"; -- max
         red   <= "00010000";
         green <= "10110100";
         blue  <= "00010000";
         Y     <= "10010001"; 
         Cb    <= "00110110"; 
         Cr    <= "00100010";
      when "0110" => -- blue
         XHairValue <= "11110000"; -- max
         red   <= "00010000";
         green <= "00010000";
         blue  <= "10110100";
         Y     <= "00101001"; 
         Cb    <= "11110000"; 
         Cr    <= "01101110";
      when "0111" => -- black
         XHairValue <= "11110000"; -- max
         red   <= "00010000";
         green <= "00010000";
         blue  <= "00010000";
         Y     <= "00001000"; 
         Cb    <= "10000000"; 
         Cr    <= "10000000";
      when "1000" => -- white
         XHairValue <= "00010000"; -- min
         red   <= "11110000";
         green <= "11110000";
         blue  <= "11110000";
         Y     <= "11101011"; 
         Cb    <= "10000000"; 
         Cr    <= "10000000";
      when "1001" => -- bars
         XHairValue <= "11110000"; -- max
         red   <= bar_red;
         green <= bar_green;
         blue  <= bar_blue;
         Y     <= bar_Y; 
         Cb    <= bar_Cb; 
         Cr    <= bar_Cr;
      when "1010" => -- ZonePlate/Sweep
         XHairValue <= "11110000"; -- max
         red   <= ZPlateDOut;
         green <= ZPlateDOut;
         blue  <= ZPlateDOut;
         Y     <= ZPlateDOut; 
         Cb    <= ZPlateDOut; 
         Cr    <= ZPlateDOut;
      when others => null;
   end case;
end if;
end process;



BoxGen : process (clk)             
begin                              
if (clk'event) and (clk = '1') then
   if (rst = '1') then
      BoxTop      <= conv_std_logic_vector(50, 12);
      BoxBottom   <= conv_std_logic_vector(81, 12);
      BoxLeft     <= conv_std_logic_vector(50, 12);
      BoxRight    <= conv_std_logic_vector(81, 12);
      HDir        <= '0'; -- Right
      VDir        <= '0'; -- Down
   else
      if (re_vsync_in = '1') then
   
         -- Define extreme locations for top left corner
         HMin  <= conv_std_logic_vector(1, 12);
         VMin  <= conv_std_logic_vector(1, 12);
         HMax  <= active_line_length - BoxSize;
         VMax  <= active_frame_height - BoxSize;
         
         -- Define Box Edge locations
         BoxRight    <= BoxHCoord + BoxSize;
         BoxLeft     <= BoxHCoord;
         BoxBottom   <= BoxVCoord + BoxSize;
         BoxTop      <= BoxVCoord;
         
         -- Change direction at image edges
         if (HDir = '0') then
            if (BoxHCoord > HMax) then
               HDir  <= '1';
            end if;
         else
            if (BoxHCoord < ("000" & Motion_speed & '0')) then
               HDir  <= '0';
            end if;
         end if;
         
         if (VDir = '0') then
            if (BoxVCoord > VMax) then
               VDir  <= '1';
            end if;
         else
            if (BoxVCoord < ("000" & Motion_speed & '0')) then
               VDir  <= '0';
            end if;
         end if;
   
         -- Increment or decrement box coordinates, to enable moving box.
         if (Motion = '1') then
            if (HDir = '0') then
               BoxHCoord   <= BoxHCoord + Motion_speed;
            else
               BoxHCoord   <= BoxHCoord - Motion_speed;
            end if;
            if (VDir = '0') then
               BoxVCoord   <= BoxVCoord + Motion_speed;
            else
               BoxVCoord   <= BoxVCoord - Motion_speed;
            end if;
         end if;
      end if;

      -- Generate Enable signal for switching box on.
      if (re_vsync_in = '1') then
         VBoxEn   <= '0';
      elsif (VCount = BoxTop) then
         VBoxEn   <= '1';
      elsif (VCount = BoxBottom) then
         VBoxEn   <= '0';
      end if;
   
      if (re_hsync_in = '1') then
         HBoxEn   <= '0';
      elsif (HCount = BoxLeft) then
         HBoxEn   <= '1';
      elsif (HCount = BoxRight) then
         HBoxEn   <= '0';
      end if;

      BoxEn <= VBoxEn and HBoxEn and EnableBox;
   
   end if;
end if;
end process;


RGB444OutGen : if (C_Chroma_Format = 0) generate -- RGB case
   OutGen : process (clk)             
   begin                              
   if (clk'event) and (clk = '1') then
      if (BoxEn = '1') then
         t_red_out               <= BoxColour(7 downto 0);
         t_blue_out              <= BoxColour(15 downto 8);
         t_green_out             <= BoxColour(23 downto 16);
      elsif (EnableXHairs = '1') and ((VCount = XHairsV) or (HCount = XHairsH)) then
         t_red_out    <= XHairValue;
         t_green_out  <= XHairValue;
         t_blue_out   <= XHairValue;
      else
         if (ComponentMask(0) = '0') then
            t_red_out      <= red;
         else
            t_red_out      <= "00000000";
         end if;

         if (ComponentMask(1) = '0') then
            t_green_out    <= green;
         else
            t_green_out    <= "00000000";
         end if;

         if (ComponentMask(2) = '0') then
            t_blue_out     <= blue;
         else
            t_blue_out     <= "00000000";
         end if;
      end if;
   end if;
   end process;
end generate;

YCbCr422OutGen : if (C_Chroma_Format = 1) generate -- YCbCr case

   OutGen : process (clk)             
   begin                              
   if (clk'event) and (clk = '1') then
      if (fe_hsync_in = '1') then
         CSel  <= CbCrPolarity;
      elsif (d_de_in = '1') then
         CSel  <= not(CSel);
      end if;

      if (BoxEn = '1') then
         t_red_out               <= BoxColour(7 downto 0);
         t_blue_out              <= BoxColour(7 downto 0); -- Both R and B become Luma
         if (CSel = '0') then
            t_green_out          <= BoxColour(23 downto 16);
         else
            t_green_out          <= BoxColour(15 downto 8);
         end if;
      elsif (EnableXHairs = '1') and ((VCount = XHairsV) or (HCount = XHairsH)) then
         t_red_out               <= XHairValue;
         t_blue_out              <= XHairValue;
         t_green_out             <= "10000000";
      else
      
         if (ComponentMask(0) = '0') then
            t_red_out            <= Y;
            t_blue_out           <= Y;
         else
            t_red_out            <= "00000000";
            t_blue_out           <= "00000000";
         end if;

         if (CSel = '0') then
            if (ComponentMask(1) = '0') then
               t_green_out       <= Cb;
            else
               t_green_out       <= "10000000";
            end if;
         else
            if (ComponentMask(2) = '0') then
               t_green_out       <= Cr;
            else
               t_green_out       <= "10000000";
            end if;
         end if;
      end if;
   end if;
   end process;
end generate;
red_out     <= t_red_out;
green_out   <= t_green_out;
blue_out    <= t_blue_out;
de_out      <= t_de_out;

--TPG_debug <=   d_vsync_in & -- 1 bit
--               d_hsync_in & -- 1 bit
--               VCount & -- 12 bits
--               d_red_in & -- 8 bits
--               d_green_in & -- 8 bits
--               d_blue_in & -- 8 bits
--               d_de_in; -- 1 bit
               
TPG_debug <=   d_vsync_in & -- 1 bit
               d_hsync_in & -- 1 bit
               VCount & -- 12 bits
               t_red_out & -- 8 bits
               t_green_out & -- 8 bits
               t_blue_out & -- 8 bits
               t_de_out; -- 1 bit
               

-- 39 bits

end Behavioral;
