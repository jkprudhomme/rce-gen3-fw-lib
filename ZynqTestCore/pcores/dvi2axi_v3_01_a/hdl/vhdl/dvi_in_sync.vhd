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
-- Filename            : dvi_in_sync.vhd
-- $Revision:: 2433   $: Revision of last commit
-- $Date:: 2008-05-27#$: Date of last commit
-- Description         : DVI Hardware Interface
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dvi_in_sync is
    Port ( clk     : in  STD_LOGIC;
           ce      : in  STD_LOGIC;
           mode    : in  STD_LOGIC;
           de      : in  STD_LOGIC;
           vsync   : in  STD_LOGIC;
           hsync   : in  STD_LOGIC;
           red     : in  STD_LOGIC_VECTOR (7 downto 0);
           green   : in  STD_LOGIC_VECTOR (7 downto 0);
           blue    : in  STD_LOGIC_VECTOR (7 downto 0);
           de_o    : out  STD_LOGIC;
           vsync_o : out  STD_LOGIC;
           hsync_o : out  STD_LOGIC;
           red_o   : out  STD_LOGIC_VECTOR (7 downto 0);
           green_o : out  STD_LOGIC_VECTOR (7 downto 0);
           blue_o  : out  STD_LOGIC_VECTOR (7 downto 0)
    );
end dvi_in_sync;

architecture IMP of dvi_in_sync is

   signal vsync_r      : STD_LOGIC_VECTOR (5 downto 0);
   signal hsync_r      : STD_LOGIC_VECTOR (5 downto 0);

begin

   VGA_Delay : process (clk)
   begin
      if Rising_Edge(clk) then
         vsync_r(0)    <= vsync;
         hsync_r(0)    <= hsync;
         for I in 1 to 5 loop
            vsync_r(I) <= vsync_r(I-1);
            hsync_r(I) <= hsync_r(I-1);
         end loop;
      end if;
   end process;
   
   In_Reg : process (clk)
   begin
      if Rising_Edge(clk) then
         de_o    <= de;
         if( mode = '1') then -- Analog mode (6 cycle sync delay)
            vsync_o <= vsync_r(5);
            hsync_o <= hsync_r(5);
         else                 -- Digital mode
            vsync_o <= vsync;
            hsync_o <= hsync;
         end if;
         red_o   <= red;
         green_o <= green;
         blue_o  <= blue;
      end if;
   end process;
         
end IMP;
