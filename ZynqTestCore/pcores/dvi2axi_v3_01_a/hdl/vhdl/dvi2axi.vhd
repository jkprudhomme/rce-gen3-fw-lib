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

---------------------------------------------------------------------------
-- top level module for transferring dvi video to video-dma ip 
--   through axi streaming interface. 
---------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity dvi2axi is
  generic (C_S_AXIS_S2MM_TDATA_WIDTH : integer := 32); 
  port (-- dvi input interface                                                                                                                                               
        dvii_clk       : in  std_logic;                                                -- dvi video input pixel reference clock                                
        dvii_de        : in  std_logic;                                                -- data enable for vaild pixel data                                     
        dvii_vsync     : in  std_logic;                                                -- vertical sync of video data                                          
        dvii_hsync     : in  std_logic;                                                -- horizontal sync of video data                                        
        dvii_red       : in  std_logic_vector(7 downto 0);                             -- pixel data - red                                                     
        dvii_green     : in  std_logic_vector(7 downto 0);                             -- pixel data - green                                                   
        dvii_blue      : in  std_logic_vector(7 downto 0);                             -- pixel data - blue                                                    
                                                                                                                                                                             
        -- axi stream interface towards video dma ip                                                                                                                         
        s_axis_s2mm_aresetn          : in  std_logic;                                                -- asynchronous reset from video dma ip                                 
        m_axi_s2mm_aclk              : in  std_logic;                                                -- axi streaming clock                                                                                                                          
        s_axis_s2mm_tdata            : out std_logic_vector(C_S_AXIS_S2MM_TDATA_WIDTH-1   downto 0); -- axi streaming data                                                   
        s_axis_s2mm_tkeep            : out std_logic_vector(C_S_AXIS_S2MM_TDATA_WIDTH/8-1 downto 0); -- axi keep signals representing byte valid                             
        s_axis_s2mm_tvalid           : out std_logic;                                                -- data valid signal                                                    
        s_axis_s2mm_tready           : in  std_logic;                                                -- ready signal from video dma indicates video dma is ready recieve data
        s_axis_s2mm_tlast            : out std_logic;                                                -- indicates last data beat of stream data, end of packet               
                                                                                                                                                                             
        -- dvi video output interface to fmc dvi daughter card                                                                                                               
        dvio_clk       : out std_logic;                                                -- dvi video output pixel reference clock                               
        dvio_de        : out std_logic;                                                -- data enable for vaild pixel data                                     
        dvio_vsync     : out std_logic;                                                -- vertical sync of video data                                          
        dvio_hsync     : out std_logic;                                                -- horizontal sync of video data                                        
        dvio_red       : out std_logic_vector(7 downto 0);                             -- pixel data - red                                                     
        dvio_green     : out std_logic_vector(7 downto 0);                             -- pixel data - green                                                   
        dvio_blue      : out std_logic_vector(7 downto 0);                             -- pixel data - blue    
        fsync_o                      : out std_logic;
  

        -- DDR Init Done
        phy_done                     : in  std_logic                                                 -- DDR Init done signal                                
                                                        
);                                                                                                   
end dvi2axi;

architecture vhdl_rtl of dvi2axi is


  --------------------------------------------------------------------------------
  -- component declaration
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  -- dvi sync declaration
  --------------------------------------------------------------------------------
  component dvi_in_sync
    port (
           clk                      : in  std_logic;
           ce                       : in  std_logic;
           mode                     : in  std_logic;
           de                       : in  std_logic;
           vsync                    : in  std_logic;
           hsync                    : in  std_logic;
           red                      : in  std_logic_vector (7 downto 0);
           green                    : in  std_logic_vector (7 downto 0);
           blue                     : in  std_logic_vector (7 downto 0);
           de_o                     : out std_logic;
           vsync_o                  : out std_logic;
           hsync_o                  : out std_logic;
           red_o                    : out std_logic_vector (7 downto 0);
           green_o                  : out std_logic_vector (7 downto 0);
           blue_o                   : out std_logic_vector (7 downto 0));
      end component;
    
  --------------------------------------------------------------------------------
  -- axi fifo declaration
  --------------------------------------------------------------------------------
  component fifo_generator_v8_4
    port (
          m_aclk                    : in  std_logic;
          s_aclk                    : in  std_logic;
          s_aresetn                 : in  std_logic;
          s_axis_tvalid             : in  std_logic;
          s_axis_tready             : out std_logic;
          s_axis_tdata              : in  std_logic_vector(31 downto 0);
          s_axis_tkeep              : in  std_logic_vector(3 downto 0);
          s_axis_tlast              : in  std_logic;
          m_axis_tvalid             : out std_logic;
          m_axis_tready             : in  std_logic;
          m_axis_tdata              : out std_logic_vector(31 downto 0);
          m_axis_tkeep              : out std_logic_vector(3 downto 0);
          m_axis_tlast              : out std_logic );
      end component;
      
    
  --------------------------------------------------------------------------------
  -- signal declaration
  --------------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  -- wire and register declaration
  ----------------------------------------------------------------------------
  -- dvi video input synchronization signals
  signal dvi_de_ff                   : std_logic;
  signal dvi_de_ff2                  : std_logic;
  signal dvi_vsync_ff                : std_logic;
  signal dvi_vsync_ff2               : std_logic;
  signal dvi_vsync_ff3               : std_logic;
  signal dvi_hsync_ff                : std_logic;
  signal dvi_hsync_ff2               : std_logic;
  signal dvi_red_ff                  : std_logic_vector(7 downto 0);
  signal dvi_red_ff2                 : std_logic_vector(7 downto 0);
  signal dvi_green_ff                : std_logic_vector(7 downto 0);
  signal dvi_green_ff2               : std_logic_vector(7 downto 0);
  signal dvi_blue_ff                 : std_logic_vector(7 downto 0);
  signal dvi_blue_ff2                : std_logic_vector(7 downto 0);
  signal wait_for_vsync              : std_logic;
                                     
  -- fifo interface signals          
  signal fifo_reset_n                : std_logic;
  signal link_fail_n                 : std_logic;
  signal fifo_wr_data                : std_logic_vector(31 downto 0);
  signal fifo_wr_tvalid              : std_logic;
  signal fifo_wr_ready               : std_logic;
  signal fifo_wr_keep                : std_logic_vector(3 downto 0);
  signal fifo_wr_tlast               : std_logic;
                                
  -- internal signals
  signal trdy_wait_count             : unsigned(11 downto 0);
  signal s_axis_s2mm_tvalid_int      : std_logic;
  signal s_axis_s2mm_tvalid_int_ff   : std_logic;
  signal s_axis_s2mm_tvalid_int_ff2  : std_logic;
  signal s_axis_s2mm_tready_ff       : std_logic;
  signal s_axis_s2mm_tready_ff2      : std_logic;
  signal s_axis_s2mm_tlast_int       : std_logic;
  
  signal reset_n                     : std_logic;
  signal reset_ff1                   : std_logic;
  signal reset_ff2                   : std_logic;
  signal reset_ff3                   : std_logic;
  
  
  signal s_axis_s2mm_tdata_temp            : std_logic_vector(31 downto 0);
  signal s_axis_s2mm_tkeep_temp            : std_logic_vector(3 downto 0);
  -- dummy constants
  constant one                       : std_logic:= '1';
  constant zero                      : std_logic:= '0';
  
begin

  -- output assignment                               
  s_axis_s2mm_tvalid        <= s_axis_s2mm_tvalid_int;
  

  -- dvi output assignment                                    
  dvio_clk    <= dvii_clk;  
  dvio_de     <= dvi_de_ff;   --- changed by VPK
  dvio_vsync  <= dvi_vsync_ff;--- changed by VPK
  dvio_hsync  <= dvi_hsync_ff;--- changed by VPK
  dvio_red    <= dvii_red;  
  dvio_green  <= dvii_green;
  dvio_blue   <= dvii_blue; 
  
  
  --------------------------------------------------------------------------------
  -- dvi sync instantiation 
  --------------------------------------------------------------------------------
  inst_dvi_in: dvi_in_sync
  port map (-- global signals
            clk            => dvii_clk,         
            ce             => one,                              
            mode           => zero,                              
            de             => dvii_de,         
            vsync          => dvii_vsync,      
            hsync          => dvii_hsync,      
            red            => dvii_red,        
            green          => dvii_green,      
            blue           => dvii_blue,       
            de_o           => dvi_de_ff,                     
            vsync_o        => dvi_vsync_ff,                  
            hsync_o        => dvi_hsync_ff,                  
            red_o          => dvi_red_ff,                    
            green_o        => dvi_green_ff,                  
            blue_o         => dvi_blue_ff);       
            
  ---------------------------------------------------
  ---------------Frame Synch generation -------------
  ---------------------------------------------------
  fsync_gen:process(dvii_clk)
  begin
   if rising_edge(dvii_clk) then
    fsync_o <= (not dvi_vsync_ff) and  dvi_vsync_ff2;
   end if;
  end process fsync_gen;
  
  --------------------------------------------------------------------------------
  -- synchronize s_axis_s2mm_aresetn signal w.r.t dvi clock
  --------------------------------------------------------------------------------
  sync_s_axis_s2mm_aresetn: process(dvii_clk)
  begin
    if rising_edge(dvii_clk) then 
      reset_ff1 <= s_axis_s2mm_aresetn;
      reset_ff2 <= reset_ff1;
      reset_ff3 <= reset_ff2;
    end if; -- clk
  end process sync_s_axis_s2mm_aresetn;
  
  reset_n <= reset_ff3;  
  
  --------------------------------------------------------------------------------
  -- adding flop for video interface
  --------------------------------------------------------------------------------
  -- Assert Tlast with falling edge of DE
  fifo_wr_tlast <= ((not dvi_de_ff) and dvi_de_ff2);  
  
  vsync_delay: process(dvii_clk)
  begin
    if rising_edge(dvii_clk) then 
      if (reset_n = '0') then   
        dvi_vsync_ff2    <= '0';
        dvi_vsync_ff3    <= '0';
        dvi_de_ff2       <= '0'; 
        dvi_hsync_ff2    <= '0'; 
        dvi_red_ff2      <= (others => '0');  
        dvi_green_ff2    <= (others => '0');
        dvi_blue_ff2     <= (others => '0');
      else  
        dvi_vsync_ff2    <= dvi_vsync_ff;  
        dvi_vsync_ff3    <= dvi_vsync_ff2;  
        dvi_de_ff2       <= dvi_de_ff;  
        dvi_hsync_ff2    <= dvi_hsync_ff;  
        dvi_red_ff2      <= dvi_red_ff;  
        dvi_green_ff2    <= dvi_green_ff;  
        dvi_blue_ff2     <= dvi_blue_ff;  
      end if;  
    end if; -- clk
  end process vsync_delay;
  
  --------------------------------------------------------------------------------
  -- active frame identification - vsync detection
  --------------------------------------------------------------------------------
  wait_for_vsync_gen: process(dvii_clk)
  begin
    if rising_edge(dvii_clk) then 
      if (reset_n = '0') then   
        wait_for_vsync <= '1';
      -- assert with link failure and without ddr init done - wait for new frame
      elsif ((link_fail_n = '0') or (phy_done = '0')) then
        wait_for_vsync <= '1';
      -- de assert with falling edge of vsync - avtive frame
      elsif ((dvi_vsync_ff3 = '1') and (dvi_vsync_ff2 = '0')) then
        wait_for_vsync <= '0';
      -- assert with rising edge of vsync - wait for new frame
      elsif ((dvi_vsync_ff3 = '0') and (dvi_vsync_ff2 = '1')) then
        wait_for_vsync <= '1';
      end if; 
    end if; -- clk
  end process wait_for_vsync_gen;
    
  
  --------------------------------------------------------------------------------
  -- synchronize s_axis_s2mm_tvalid and s_axis_s2mm_tready signals w.r.t dvi clock
  --------------------------------------------------------------------------------
  tvld_trdy_dvi_clk_sync: process(dvii_clk)
  begin
    if rising_edge(dvii_clk) then 
      if (reset_n = '0') then   
        s_axis_s2mm_tvalid_int_ff  <= '0';
        s_axis_s2mm_tvalid_int_ff2 <= '0';  
        s_axis_s2mm_tready_ff      <= '0';
        s_axis_s2mm_tready_ff2     <= '0';
      else
        s_axis_s2mm_tvalid_int_ff  <= s_axis_s2mm_tvalid_int;  
        s_axis_s2mm_tvalid_int_ff2 <= s_axis_s2mm_tvalid_int_ff;  
        s_axis_s2mm_tready_ff      <= s_axis_s2mm_tready;   
        s_axis_s2mm_tready_ff2     <= s_axis_s2mm_tready_ff;   
      end if;  
    end if; -- clk
  end process tvld_trdy_dvi_clk_sync;
  
  
  --------------------------------------------------------------------------------
  -- counter for link failure detection
  --------------------------------------------------------------------------------
  trdy_wait_count_gen: process(dvii_clk)
  begin
    if rising_edge(dvii_clk) then 
      if (reset_n = '0') then   
        trdy_wait_count  <= (others => '0');
      elsif (s_axis_s2mm_tready_ff2 = '1') then
        trdy_wait_count  <= (others => '0');
      -- increment counter with tvalid
      elsif (s_axis_s2mm_tvalid_int_ff2 = '1') then
        trdy_wait_count  <= trdy_wait_count + 1;
      end if;
    end if; -- clk
  end process trdy_wait_count_gen;
    
  
  --------------------------------------------------------------------------------
  -- process for link failure detection
  --------------------------------------------------------------------------------
  link_fail_detect: process(dvii_clk)
  begin
    if rising_edge(dvii_clk) then 
      if (reset_n = '0') then   
        link_fail_n <= '1';
      -- assert link failure if ready is not asserted for 250 tvalid(beats) by vdma ip
      elsif (trdy_wait_count = 2000) then
        link_fail_n <= '0';
      else
        link_fail_n <= '1';
      end if;  
    end if; -- clk
  end process link_fail_detect;
      
            
  --------------------------------------------------------------------------------
  -- fifo input signal management
  --------------------------------------------------------------------------------
  -- fifo reset is a combination of global reset input and the link failure
  fifo_reset_n  <= reset_n and link_fail_n and phy_done;
  
  -- fifo write data vaild signals assertion
  fifo_wr_tvalid <= (dvi_de_ff2 and (not dvi_hsync_ff2) and (not wait_for_vsync));
  
  -- concatination of synchronized dvi to write into axi fifo 
  fifo_wr_data  <= (x"FF" & dvi_red_ff2 & dvi_green_ff2 & dvi_blue_ff2) when  (fifo_wr_tvalid = '1') else x"00000000";
  
  -- fifo write keep - 3 bytes are valid 
  fifo_wr_keep <= ( fifo_wr_tvalid & fifo_wr_tvalid & fifo_wr_tvalid & fifo_wr_tvalid);
           
   
  --------------------------------------------------------------------------------
  -- axi fifo instantiation 
  --------------------------------------------------------------------------------
  inst_fifo_generator_v8_4: fifo_generator_v8_4
  port map (-- global signals
            m_aclk         => m_axi_s2mm_aclk,                 
            s_aclk         => dvii_clk,          
            s_aresetn      => fifo_reset_n,                    
            s_axis_tvalid  => fifo_wr_tvalid,                  
            s_axis_tready  => fifo_wr_ready,                   
            s_axis_tdata   => fifo_wr_data,                    
            s_axis_tkeep   => fifo_wr_keep,                    
            s_axis_tlast   => fifo_wr_tlast,                   
            m_axis_tvalid  => s_axis_s2mm_tvalid_int,          
            m_axis_tready  => s_axis_s2mm_tready,              
            m_axis_tdata   => s_axis_s2mm_tdata_temp,               
            m_axis_tkeep   => s_axis_s2mm_tkeep_temp,                
            m_axis_tlast   => s_axis_s2mm_tlast_int);              

-- Tlast is asserted w.r.t Tvalid
  s_axis_s2mm_tlast <= s_axis_s2mm_tlast_int and s_axis_s2mm_tvalid_int;
            
  s_axis_s2mm_tdata <= s_axis_s2mm_tdata_temp(C_S_AXIS_S2MM_TDATA_WIDTH-1 downto 0);
  s_axis_s2mm_tkeep <= s_axis_s2mm_tkeep_temp(C_S_AXIS_S2MM_TDATA_WIDTH/8-1 downto 0);
  
  
  
  
end vhdl_rtl;
