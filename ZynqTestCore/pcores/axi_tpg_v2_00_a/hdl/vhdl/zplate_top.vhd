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

LIBRARY ieee;
use ieee.std_logic_1164.all;  
use IEEE.numeric_std.all;     
use IEEE.std_logic_arith.all; 
use IEEE.std_logic_unsigned.all;

Library work;
use work.ZplateLib.all;

entity zplate is
generic 
(
   OutWidth       :  integer  := 8;
   DeltaWidth     :  integer  := 17
   
);
port 
(
   clk   	      :  in    std_logic;
   HDeltaStart    :  in    std_logic_vector((DeltaWidth - 1) downto 0);
   HDelta2        :  in    std_logic_vector((DeltaWidth - 1) downto 0);
   VDeltaStart    :  in    std_logic_vector((DeltaWidth - 1) downto 0);
   VDelta2        :  in    std_logic_vector((DeltaWidth - 1) downto 0);
   ZPStart        :  in    std_logic_vector((DeltaWidth - 1) downto 0);
   de_in       :  in    std_logic;
   HSync       :  in    std_logic;
   VSync       :  in    std_logic;
   Dout        :  out   std_logic_vector((OutWidth - 1) downto 0);
   ZP_debug      : out     std_logic_vector(57 downto 0)
);
end zplate;

architecture rtl of zplate is


type     SinTableNBits                       is array (0 to 2047) of std_logic_vector((OutWidth - 1) downto 0);
signal   SinTableArray                       :  SinTableNBits;
signal   SinTableAddress                     :  integer;
signal   d_hsync, d2_hsync, re_hsync, fe_hsync         :  std_logic;
signal   d_vsync, d2_vsync, re_vsync         :  std_logic;
signal   d_de_in                             :  std_logic;
signal   d_HDelta2                           :  std_logic_vector((DeltaWidth - 1) downto 0);
signal   d_VDelta2                           :  std_logic_vector((DeltaWidth - 1) downto 0);
signal   NewHDelta                           :  std_logic_vector((DeltaWidth - 1) downto 0);
signal   NewVDelta                           :  std_logic_vector((DeltaWidth - 1) downto 0);
signal   d_NewHDelta                         :  std_logic_vector((DeltaWidth - 1) downto 0);
signal   d_NewVDelta                         :  std_logic_vector((DeltaWidth - 1) downto 0);
signal   CurrentHLUTAddr                     :  std_logic_vector((DeltaWidth - 1) downto 0);
signal   CurrentVLUTAddr                     :  std_logic_vector((DeltaWidth - 1) downto 0);
signal   d_CurrentHLUTAddr                   :  std_logic_vector((DeltaWidth - 1) downto 0);
signal   d_CurrentVLUTAddr                   :  std_logic_vector((DeltaWidth - 1) downto 0);
signal   AppliedRdAddr                       :  std_logic_vector(10 downto 0);
signal   VLUTOffset                          :  std_logic_vector((DeltaWidth - 1) downto 0);
signal   t_DOut                              :  std_logic_vector(7 downto 0);

begin


-- Create NBit Sin table - hope it creates BROMs!
SinTableGen :  for i in 0 to 2047 generate
--   SinTableArray(i)           <= conv_std_logic_vector((SinTable(i)*((2**OutWidth)-3))/(2**(19-OutWidth)), OutWidth);
   SinTableArray(i)           <= conv_std_logic_vector(144+(SinTable(i)*((2**OutWidth)-35)/(2**(19-OutWidth)*(2**OutWidth))), OutWidth);
end generate;


VProc: process(clk)
begin
if (clk'event and clk = '1') then
   d_de_in              <= de_in;
   d_vsync              <= VSync;
   d2_vsync             <= d_vSync;
   re_vsync             <= d_vSync and not(d2_vsync);
   
   if (re_vSync = '1') then
      d_VDelta2         <= (others => '0');
      NewVDelta         <= VDeltaStart;
      d_NewVDelta       <= (others => '0');
      CurrentVLUTAddr   <= ZPStart;
      
   elsif (re_hsync = '1') then
      d_VDelta2         <= VDelta2;
      NewVDelta         <= NewVDelta   + d_VDelta2; -- Every line, increase the amount by which we increase the Sine Table address
      d_NewVDelta       <= NewVDelta; -- Register it so it has a chance of getting across to another DSP48 if necessary.
      CurrentVLUTAddr   <= CurrentVLUTAddr + d_NewVDelta; -- Now add the increase to the Sine Table read address
--      VLUTOffset        <= SinTableArray(conv_integer(CurrentVLUTAddr((DeltaWidth-1) downto (DeltaWidth - 12)))); -- ... and address the table.
   end if;
end if;
end process;

HProc: process(clk)
begin
if (clk'event and clk = '1') then
   d_hsync              <= HSync;
   d2_hsync             <= d_hSync;
   re_hsync             <= d_hSync and not(d2_hsync);
   fe_hsync             <= d2_hSync and not(d_hsync);

   if (d_hsync = '1') then
      d_HDelta2         <= (others => '0');
      NewHDelta         <= HDeltaStart;
      CurrentHLUTAddr   <= CurrentVLUTAddr;
      d_NewHDelta       <= (others => '0');
   elsif (d_de_in = '1') then
      d_HDelta2         <= HDelta2;
      NewHDelta         <= NewHDelta   + d_HDelta2; -- Every pixel, increase the amount by which we increase the Sine Table address
      d_NewHDelta       <= NewHDelta; -- Register it so it has a chance of getting across to another DSP48 if necessary.
      CurrentHLUTAddr   <= CurrentHLUTAddr + d_NewHDelta; -- Now add the increase to the Sine Table read address
      d_CurrentHLUTAddr <= CurrentHLUTAddr; -- + CurrentVLUTAddr; -- Add Vertical offset.
      t_DOut            <= SinTableArray(conv_integer(AppliedRdAddr)); -- ... and address the table.
   end if;
end if;
end process;

DOut        <= t_DOut;

ZP_debug   <=  d_hSync & -- 1 bit
               d_vsync & -- 1 bit
               d_HDelta2 & -- 16 bits
               d_NewHDelta & -- 16 bits
               d_CurrentHLUTAddr & -- 16 bits
               t_DOut; -- 8 bits
               
AppliedRdAddr <= d_CurrentHLUTAddr((DeltaWidth-1) downto (DeltaWidth - 11));


end rtl;

