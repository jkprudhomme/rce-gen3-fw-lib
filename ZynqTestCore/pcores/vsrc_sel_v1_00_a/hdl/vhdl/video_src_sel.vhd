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
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

Library UNISIM;
use UNISIM.vcomponents.all;
-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_NUM_REG                    -- Number of software accessible registers
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Resetn                -- Bus to IP reset
--   Bus2IP_Data                  -- Bus to IP data bus
--   Bus2IP_BE                    -- Bus to IP byte enables
--   Bus2IP_RdCE                  -- Bus to IP read chip enable
--   Bus2IP_WrCE                  -- Bus to IP write chip enable
--   IP2Bus_Data                  -- IP to Bus data bus
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   IP2Bus_Error                 -- IP to Bus error response
------------------------------------------------------------------------------

entity vsrc_sel is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    --USER generics added here
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_NUM_CHANNELS                 : integer              := 1
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    -- User logic ports 
    video_clk_1                    : in  std_logic_vector(C_NUM_CHANNELS-1 downto 0);
    video_clk_2                    : in  std_logic_vector(C_NUM_CHANNELS-1 downto 0);
    hsync_1                        : in  std_logic_vector(C_NUM_CHANNELS-1 downto 0);
    hsync_2                        : in  std_logic_vector(C_NUM_CHANNELS-1 downto 0);

    vsync_1                        : in  std_logic_vector(C_NUM_CHANNELS-1 downto 0);
    vsync_2                        : in  std_logic_vector(C_NUM_CHANNELS-1 downto 0);

    de_1                           : in  std_logic_vector(C_NUM_CHANNELS-1 downto 0);
    de_2                           : in  std_logic_vector(C_NUM_CHANNELS-1 downto 0);


    video_clk                     : out  std_logic_vector(C_NUM_CHANNELS-1 downto 0);
    hsync                         : out  std_logic_vector(C_NUM_CHANNELS-1 downto 0);
    vsync                         : out  std_logic_vector(C_NUM_CHANNELS-1 downto 0);
    de                            : out  std_logic_vector(C_NUM_CHANNELS-1 downto 0);
    
    video_sel                     : in std_logic

 );

  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

--  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
--  attribute SIGIS of Bus2IP_Resetn : signal is "RST";

end entity vsrc_sel;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of vsrc_sel is


begin


   
  de    <= de_1 when video_sel = '0' else
           de_2;
    
  hsync <= hsync_1 when video_sel = '0' else
           hsync_2;

  vsync <= vsync_1 when video_sel = '0' else
           vsync_2;
        
VIDEO_SEL_GEN:for i in 0 to C_NUM_CHANNELS-1 generate
begin      
      BUFGMUX_INST : BUFGMUX
      generic map (
      CLK_SEL_TYPE => "SYNC" -- Not supported. Must be "SYNC".
      )
      port map (
      O => video_clk(i), -- 1-bit output: Clock buffer output
      I0 => video_clk_1(i), -- 1-bit input: Clock buffer input (S=0)
      I1 => video_clk_2(i), -- 1-bit input: Clock buffer input (S=1)
      S => video_sel-- 1-bit input: Clock buffer select
     );
      
end generate VIDEO_SEL_GEN;

end IMP;
