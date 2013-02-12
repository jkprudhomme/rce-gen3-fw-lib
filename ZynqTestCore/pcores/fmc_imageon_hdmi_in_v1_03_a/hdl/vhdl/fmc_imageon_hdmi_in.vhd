------------------------------------------------------------------
--      _____
--     /     \
--    /____   \____
--   / \===\   \==/
--  /___\===\___\/  AVNET
--       \======/
--        \====/    
-----------------------------------------------------------------
--
-- This design is the property of Avnet.  Publication of this
-- design is not authorized without written consent from Avnet.
-- 
-- Please direct any questions to:  technical.support@avnet.com
--
-- Disclaimer:
--    Avnet, Inc. makes no warranty for the use of this code or design.
--    This code is provided  "As Is". Avnet, Inc assumes no responsibility for
--    any errors, which may appear in this code, nor does it make a commitment
--    to update the information contained herein. Avnet, Inc specifically
--    disclaims any implied warranties of fitness for a particular purpose.
--                     Copyright(c) 2011 Avnet, Inc.
--                             All rights reserved.
--
------------------------------------------------------------------
--
-- Create Date:         Aug 31, 2011
-- Design Name:         FMC-IMAGEON
-- Module Name:         fmc_imageon_hdmi_in.vhd
-- Project Name:        FMC-IMAGEON
-- Target Devices:      Spartan-6, Virtex-6, Kintex-7
-- Avnet Boards:        FMC-IMAGEON
--
-- Tool versions:       ISE 13.4
--
-- Description:         FMC-IMAGEON HDMI input interface.
--
-- Dependencies:        
--
-- Revision:            Aug 31, 2011: 1.01 Initial version
--                      Nov 11, 2011: 1.02 Add CCIR656 decode logic
--                                         Remove VSYNC/HSYNC ports
--                      Feb 06, 2012: 1.03 Fix sync de-embed logic
--                                         Change IOB attribute from "TRUE" to "FORCE"
--
------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fmc_imageon_hdmi_in is
   Generic
   (
      C_DATA_WIDTH         : integer := 16;
      C_FAMILY             : string := "virtex6"
   );
   Port
   (
      clk                  : in  std_logic;
      -- IO Pins    
      io_hdmii_spdif       : in  std_logic;
      io_hdmii_video       : in  std_logic_vector(15 downto 0);
      -- Audio Input Port
      audio_spdif          : out std_logic;
      -- XSVI Port
--      xsvi_vsync_o         : out  std_logic;
--      xsvi_hsync_o         : out  std_logic;
      xsvi_vblank_o        : out  std_logic;
      xsvi_hblank_o        : out  std_logic;
      xsvi_active_video_o  : out  std_logic;
      xsvi_video_data_o    : out  std_logic_vector((C_DATA_WIDTH-1) downto 0);
      -- Debug Port
      debug_o              : out std_logic_vector(23 downto 0)
    );
end fmc_imageon_hdmi_in;

architecture rtl of fmc_imageon_hdmi_in is

   --
   -- IOB registers
   --

   signal spdif_r  : std_logic;
   signal video_r  : std_logic_vector (15 downto 0);

   attribute IOB : string;
   attribute IOB of spdif_r: signal is "FORCE";
   attribute IOB of video_r: signal is "FORCE";

   --
   -- Input Delay
   -- 
   
   signal video_d1       : std_logic_vector(15 downto 0);
   signal video_d2       : std_logic_vector(15 downto 0);
   signal video_d3       : std_logic_vector(15 downto 0);
   signal video_d4       : std_logic_vector(15 downto 0);

   --
   -- CCIR656 Decode Logic
   -- 
   
   signal sc             : std_logic;
   signal sav_va         : std_logic; 
   signal eav_va         : std_logic; 
   signal sav_vb         : std_logic; 
   signal eav_vb         : std_logic; 
   signal sav_va_d1      : std_logic;
   signal sav_va_d2      : std_logic;
   signal sav_va_d3      : std_logic;
   signal sav_va_d4      : std_logic;
   signal sav_vb_d1      : std_logic;
   signal sav_vb_d2      : std_logic;
   signal sav_vb_d3      : std_logic;
   signal sav_vb_d4      : std_logic;

   signal sync_code      : std_logic;
   
   signal vblank         : std_logic;
   signal hblank         : std_logic;
   signal active_video   : std_logic;

begin

   --
   -- IOB registers
   --

   io_iregs_l : process (clk)
   begin
      if Rising_Edge(clk) then
         spdif_r         <= io_hdmii_spdif;
         video_r         <= io_hdmii_video;
      end if;
   end process;

   --
   -- Input Delay
   -- 
   
   input_delay_l : process (clk)
   begin
      if Rising_Edge(clk) then
         -- Delay DATA by 4 cycles to have a 4 cycle view of data
         video_d1        <= video_r;
         video_d2        <= video_d1;
         video_d3        <= video_d2;
         video_d4        <= video_d3;
      end if;
   end process;

   --
   -- CCIR656 Decode Logic
   -- 
   
   ccir656_decode_l : process ( video_r, video_d1, video_d2, video_d3, video_d4 )
   begin
      -- Sync Code
      sc                <= '0';
      if ( (video_d3 = X"FFFF") and (video_d2 = X"0000") and (video_d1 = X"0000") ) then
         sc             <= '1';
      end if;
	
      -- Start of Active Video (active line)
      sav_va            <= '0';
      if ( (video_d3 = X"FFFF") and (video_d2 = X"0000") and (video_d1 = X"0000") and (video_r = X"8080") ) then
         sav_va         <= '1';
      end if;
      
      -- End of Active Video (active line)
      eav_va            <= '0';
      if ( (video_d3 = X"FFFF") and (video_d2 = X"0000") and (video_d1 = X"0000") and (video_r = X"9D9D") ) then
         eav_va         <= '1';
      end if;

      -- Start of Inactive Video (blank line)
      sav_vb            <= '0';
      if ( (video_d3 = X"FFFF") and (video_d2 = X"0000") and (video_d1 = X"0000") and (video_r = X"ABAB") ) then
         sav_vb         <= '1';
      end if;
      
      -- End of Inactive Video (blank line)
      eav_vb            <= '0';
      if ( (video_d3 = X"FFFF") and (video_d2 = X"0000") and (video_d2 = X"0000") and (video_r = X"B6B6") ) then
         eav_vb         <= '1';
      end if;
      
   end process;

   ccir656_syncgen_l : process (clk)
   begin
      if Rising_Edge(clk) then
		
         -- Delay SAV by 4 cycles
         sav_va_d1      <= sav_va;
         sav_va_d2      <= sav_va_d1;
         sav_va_d3      <= sav_va_d2;
         sav_va_d4      <= sav_va_d3;
         --
         sav_vb_d1      <= sav_vb;
         sav_vb_d2      <= sav_vb_d1;
         sav_vb_d3      <= sav_vb_d2;
         sav_vb_d4      <= sav_vb_d3;

         -- Create generic Sync Code event indicator (for use with ChipScope)
         sync_code      <= sc;

         -- Create Active Video strobe based on SAV/EAV events         
         if ( sav_va_d4 = '1' ) then
            active_video <= '1';
         end if;
         if ( eav_va = '1' or eav_vb = '1' ) then
            active_video <= '0';
         end if;

         -- Create VBLANK strobes based on SAV events
         --if ( sav_vb = '1' ) then
         if ( sav_vb = '1' or eav_vb = '1' ) then
            vblank      <= '1';
         end if;
         if ( sav_va = '1' ) then
            vblank      <= '0';
         end if;
         
         -- Create HBLANK strobes based on SAV/EAV events
         if ( sav_va_d4 = '1' or sav_vb_d4 = '1' ) then
            hblank      <= '0';
         end if;
         if ( eav_va = '1' or eav_vb = '1' ) then
            hblank      <= '1';
         end if;
         
      end if;
   end process;


   --
   -- XSVI Port
   -- 

   XSVI_16BIT_GEN : if (C_DATA_WIDTH = 16) generate
      xsvi_16bit_oregs_l : process (clk)
         begin
          if rising_edge( clk ) then
--            xsvi_vsync_o        <= '0';
--            xsvi_hsync_o        <= '0';
            xsvi_vblank_o       <= vblank;
            xsvi_hblank_o       <= hblank;
            xsvi_active_video_o <= active_video;
            xsvi_video_data_o   <= video_d4;
         end if;
      end process;
   end generate XSVI_16BIT_GEN;

   --
   -- Audio Port
   --

   audio_spdif <= spdif_r;

   --
   -- Debug Port
   --    Can be used to connect to ChipScope for debugging.
   --    Having a port makes these signals accessible for debug via EDK.
   -- 

   debug_l : process (clk)
   begin
      if Rising_Edge(clk) then
         debug_o(15 downto  0) <= video_r;
         debug_o(          16) <= spdif_r;
         debug_o(          17) <= active_video;
         debug_o(          18) <= hblank;
         debug_o(          19) <= vblank;
         debug_o(          20) <= sav_va;
         debug_o(          21) <= sav_vb;
         debug_o(          22) <= eav_va or eav_vb;
         debug_o(          23) <= sync_code;
      end if;
   end process;

         
end rtl;
