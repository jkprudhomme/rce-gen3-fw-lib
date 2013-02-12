------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2007 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          user_logic.vhd
-- Version:           1.00.a
-- Description:       User logic.
-- Date:              Mon Oct 22 10:34:41 2007 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
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

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--   C_NUM_REG                    -- Number of software accessible registers
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Reset                 -- Bus to IP reset
--   Bus2IP_Data                  -- Bus to IP data bus
--   Bus2IP_BE                    -- Bus to IP byte enables
--   Bus2IP_RdCE                  -- Bus to IP read chip enable
--   Bus2IP_WrCE                  -- Bus to IP write chip enable
--   IP2Bus_Data                  -- IP to Bus data bus
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   IP2Bus_Error                 -- IP to Bus error response
------------------------------------------------------------------------------


entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    --USER generics added here
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_SLV_DWIDTH                    :  integer              := 32;
    C_NUM_REG                       :  integer              := 8;
    C_FAMILY                        :  string               := "virtex5";
    C_Chroma_Format                 :  integer              := 0 -- 0 = RGB444; 1 = YCbCr422

    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
   clk               :  in    STD_LOGIC;
   rst               :  in    STD_LOGIC;
   
   vsync_in          :  in    std_logic;
   hsync_in          :  in    std_logic;
   vblank_in         :  in    std_logic;
   hblank_in         :  in    std_logic;

   de_in             :  in    std_logic;
   red_in            :  in    std_logic_vector(7 downto 0);
   green_in          :  in    std_logic_vector(7 downto 0);
   blue_in           :  in    std_logic_vector(7 downto 0);
   
   vsync_out         :  out   std_logic;
   hsync_out         :  out   std_logic;
   vblank_out        :  out   std_logic;
   hblank_out        :  out   std_logic;
   de_out            :  out   std_logic;
   red_out           :  out   std_logic_vector(7 downto 0);
   green_out         :  out   std_logic_vector(7 downto 0);
   blue_out          :  out   std_logic_vector(7 downto 0);
   ZP_debug          :  out   std_logic_vector(57 downto 0);
   TPG_debug         :  out   std_logic_vector(38 downto 0);
   
   -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Reset                   : in  std_logic;
    Bus2IP_Data                    : in  std_logic_vector(C_SLV_DWIDTH-1 downto 0);
    Bus2IP_BE                      : in  std_logic_vector(C_SLV_DWIDTH/8-1 downto 0);
    Bus2IP_RdCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    Bus2IP_WrCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    IP2Bus_Data                    : out std_logic_vector(C_SLV_DWIDTH-1 downto 0);
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    IP2Bus_Error                   : out std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute SIGIS : string;
  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
  attribute SIGIS of Bus2IP_Reset  : signal is "RST";

end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is

------------------------------------------
-- Signals for user logic slave model s/w accessible register example

signal   Control_reg                      : std_logic_vector(31 downto 0);
signal   Motion_reg                       : std_logic_vector(31 downto 0);
signal   XHairs_reg                       : std_logic_vector(31 downto 0);
signal   FrameSize_reg                    : std_logic_vector(31 downto 0);
signal   ZPlateHDelta_reg                 : std_logic_vector(31 downto 0);
signal   ZPlateVDelta_reg                 : std_logic_vector(31 downto 0);
signal   BoxSize_reg                      : std_logic_vector(31 downto 0);
signal   BoxColour_reg                    : std_logic_vector(31 downto 0);
signal   not_tpg_hsync_out                : std_logic;
signal   not_tpg_vsync_out                : std_logic;

------------------------------------------
signal   slv_reg_write_sel                :  std_logic_vector(0 to (C_NUM_REG-1));
signal   slv_reg_read_sel                 :  std_logic_vector(0 to (C_NUM_REG-1));
signal   slv_ip2bus_data                  : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
signal   slv_read_ack                     : std_logic;
signal   slv_write_ack                    : std_logic;
type     slv_array1     is array (natural range <>) of std_logic_vector(C_SLV_DWIDTH-1 downto 0);
type     slv_array2     is array (natural range <>) of std_logic_vector(C_SLV_DWIDTH-1 downto 0);
type     slv_array_ce   is array (natural range <>) of std_logic_vector(0 to C_NUM_REG-1);
type     slv_array_be   is array (natural range <>) of std_logic_vector(C_SLV_DWIDTH/8-1 downto 0);

constant slv_mask                         : slv_array2(0 to C_NUM_REG-1) := (
    x"00000fff", --00  0
    x"000001ff", --04  1
    x"0fff0fff", --08  2
    x"0fff0fff", --0c  3
    x"ffffffff", --10  4
    x"ffffffff", --14  5
    x"00000fff", --18  6
    x"00ffffff"  --1c  7
);

signal   slv_reg                    : slv_array2((C_NUM_REG-1) downto 0);
signal   le_slv_reg                 : slv_array1(C_NUM_REG-1 downto 0);
signal   slv_reg_stat               : slv_array2(C_NUM_REG-1 downto 0);
signal   le_slv_reg_stat            : slv_array1(C_NUM_REG-1 downto 0);

signal   Bus2IP_Data_sync           :  slv_array2(1 downto 0);
signal   slv_ip2bus_data_sync       :  slv_array2(1 downto 0);
signal   Bus2IP_WrCE_sync           :  slv_array_ce(1 downto 0);
signal   Bus2IP_RdCE_sync           :  slv_array_ce(1 downto 0);
signal   Bus2IP_BE_sync             :  slv_array_be(1 downto 0);
signal   Bus2IP_Reset_sync          :  std_logic_vector(1 downto 0);
signal   reset_core                 :  std_logic;
signal   slv_write_ack_sync         :  std_logic_vector(1 downto 0);
signal   slv_read_ack_sync          :  std_logic_vector(1 downto 0);

constant   read_only_reg               :  std_logic_vector((C_NUM_REG-1) downto 0) := "00000000";


-- JLH: Signals used to created single beat acknowledge
signal   rdack_d : std_logic := '0';
signal   slv_read_ack_end : std_logic;
signal   wrack_d : std_logic := '0';
signal   slv_write_ack_end : std_logic;
signal   RdCE_or : std_logic_vector(C_NUM_REG downto 0);
signal   WrCE_or : std_logic_vector(C_NUM_REG downto 0);

attribute SYN_PRESERVE        : boolean;
attribute KEEP                : boolean;
attribute SYN_KEEP            : boolean; 

-- CW
attribute SYN_PRESERVE of Bus2IP_Data_sync : signal is TRUE;
attribute KEEP         of Bus2IP_Data_sync : signal is TRUE;
attribute SYN_KEEP     of Bus2IP_Data_sync : signal is TRUE;

attribute SYN_PRESERVE of slv_ip2bus_data_sync : signal is TRUE;
attribute KEEP         of slv_ip2bus_data_sync : signal is TRUE;
attribute SYN_KEEP     of slv_ip2bus_data_sync : signal is TRUE;

attribute SYN_PRESERVE of Bus2IP_WrCE_sync: signal is TRUE;
attribute KEEP         of Bus2IP_WrCE_sync: signal is TRUE;
attribute SYN_KEEP     of Bus2IP_WrCE_sync: signal is TRUE;

attribute SYN_PRESERVE of Bus2IP_RdCE_sync : signal is TRUE;
attribute KEEP         of Bus2IP_RdCE_sync : signal is TRUE;
attribute SYN_KEEP     of Bus2IP_RdCE_sync : signal is TRUE;

attribute SYN_PRESERVE of Bus2IP_BE_sync : signal is TRUE;
attribute KEEP         of Bus2IP_BE_sync : signal is TRUE;
attribute SYN_KEEP     of Bus2IP_BE_sync : signal is TRUE;

attribute SYN_PRESERVE of slv_write_ack_sync : signal is TRUE;
attribute KEEP         of slv_write_ack_sync : signal is TRUE;
attribute SYN_KEEP     of slv_write_ack_sync : signal is TRUE;

attribute SYN_PRESERVE of slv_read_ack_sync : signal is TRUE;
attribute KEEP         of slv_read_ack_sync : signal is TRUE;
attribute SYN_KEEP     of slv_read_ack_sync : signal is TRUE;

attribute SYN_PRESERVE of Bus2IP_Reset_sync : signal is TRUE;
attribute KEEP         of Bus2IP_Reset_sync : signal is TRUE;
attribute SYN_KEEP     of Bus2IP_Reset_sync : signal is TRUE;

attribute KEEP         of slv_reg_read_sel : signal is TRUE;
attribute KEEP         of slv_reg_write_sel : signal is TRUE;
attribute KEEP         of Bus2IP_RdCE : signal is TRUE;
attribute KEEP         of Bus2IP_WrCE : signal is TRUE;
-- end CW


begin   

  ------------------------------------------
  -- Example code to read/write user logic slave model s/w accessible registers
  -- 
  -- Note:
  -- The example code presented here is to show you one way of reading/writing
  -- software accessible registers implemented in the user logic slave model.
  -- Each bit of the Bus2IP_WrCE/Bus2IP_RdCE signals is configured to correspond
  -- to one software accessible register by the top level template. For example,
  -- if you have four 32 bit software accessible registers in the user logic,
  -- you are basically operating on the following memory mapped registers:
  -- 
  --    Bus2IP_WrCE/Bus2IP_RdCE   Memory Mapped Register
  --                     "1000"   C_BASEADDR + 0x0
  --                     "0100"   C_BASEADDR + 0x4
  --                     "0010"   C_BASEADDR + 0x8
  --                     "0001"   C_BASEADDR + 0xC
  -- 
  ------------------------------------------
---  slv_reg_write_sel <= Bus2IP_WrCE(0 to 7);
---  slv_reg_read_sel  <= Bus2IP_RdCE(0 to 7);
---  slv_write_ack     <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1) or Bus2IP_WrCE(2) or Bus2IP_WrCE(3) or Bus2IP_WrCE(4) or Bus2IP_WrCE(5) or Bus2IP_WrCE(6) or Bus2IP_WrCE(7);
---  slv_read_ack      <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1) or Bus2IP_RdCE(2) or Bus2IP_RdCE(3) or Bus2IP_RdCE(4) or Bus2IP_RdCE(5) or Bus2IP_RdCE(6) or Bus2IP_RdCE(7);
-- JLH: Variable input OR gates for ack end generation

RdCE_or(0)<='0';
WrCE_or(0)<='0';

GEN_OR: for i in 0 to C_NUM_REG-1 generate
   RdCE_or(i+1)<=Bus2IP_RdCE(i) or RdCE_or(i);
   WrCE_or(i+1)<=Bus2IP_WrCE(i) or WrCE_or(i);
end generate;

slv_read_ack_end <= RdCE_or(C_NUM_REG);
slv_write_ack_end <= WrCE_or(C_NUM_REG); 

---- Including sync registers
slv_reg_write_sel     <= Bus2IP_WrCE_sync(Bus2IP_WrCE_sync'high);
slv_write_ack     <= '0' when(Bus2IP_WrCE_sync(Bus2IP_WrCE_sync'high) = 0) else '1';
slv_reg_read_sel      <= Bus2IP_RdCE_sync(Bus2IP_RdCE_sync'high);
slv_read_ack      <= '0' when(Bus2IP_RdCE_sync(Bus2IP_RdCE_sync'high) = 0) else '1';

reset_core            <= Bus2IP_Reset_sync(Bus2IP_Reset_sync'high);

-- signal synchronization to clk domain
process(clk) is
begin
   if (clk'event) and (clk = '1') then
      Bus2IP_Data_sync  <= Bus2IP_Data_sync(Bus2IP_Data_sync'high-1 downto 0) & Bus2IP_Data;
      Bus2IP_WrCE_sync  <= Bus2IP_WrCE_sync(Bus2IP_WrCE_sync'high-1 downto 0) & Bus2IP_WrCE;
      Bus2IP_RdCE_sync  <= Bus2IP_RdCE_sync(Bus2IP_RdCE_sync'high-1 downto 0) & Bus2IP_RdCE;
      Bus2IP_BE_sync    <= Bus2IP_BE_sync(Bus2IP_BE_sync'high-1 downto 0) & Bus2IP_BE;
      Bus2IP_Reset_sync <= Bus2IP_Reset_sync(Bus2IP_Reset_sync'high-1 downto 0) & Bus2IP_Reset; 
   end if;
end process;

-- signal synchronization to Bus2IP_Clk domain
process(Bus2IP_Clk) is
begin
if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
   slv_ip2bus_data_sync      <= slv_ip2bus_data_sync(slv_ip2bus_data_sync'high-1 downto 0) & slv_ip2bus_data;
   slv_write_ack_sync        <= slv_write_ack_sync(slv_write_ack_sync'high-1 downto 0) & slv_write_ack;
   slv_read_ack_sync         <= slv_read_ack_sync(slv_read_ack_sync'high-1 downto 0) & slv_read_ack;

   if Bus2IP_Reset = '1' then -- remove and set attribute to not use SRL16
      rdack_d <= '0';
      wrack_d <= '0';
   else

      -- JLH: Create single beat read acknowledge.
      if (rdack_d = '1') then
        rdack_d <= '0';
      elsif (slv_read_ack_end = '1') then
        rdack_d <= slv_read_ack_sync(slv_read_ack_sync'high);
      end if;

      -- JLH: Create single beat write acknowledge.
      if (wrack_d = '1') then
        wrack_d <= '0';
      elsif (slv_write_ack_end = '1') then
        wrack_d <= slv_write_ack_sync(slv_write_ack_sync'high);
      end if;
   end if;
end if;
end process;

SLAVE_REG_WRITE_PROC2 : process(clk) is
begin
if clk'event and clk = '1' then
   if reset_core = '1' then
      for i in 0 to C_NUM_REG-1 loop
         if (read_only_reg(i) = '0') then
            slv_reg(i) <= (others => '0');
         end if;
      end loop;
   else
      for i in 0 to C_NUM_REG-1 loop
         if(slv_reg_write_sel(i) = '1') then
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if (Bus2IP_BE_sync(Bus2IP_BE_sync'high)(byte_index) = '1' ) then
                  if (read_only_reg(i) = '0') then
--                     slv_reg(i)(byte_index*8 to byte_index*8+7) <= Bus2IP_Data_sync(Bus2IP_Data_sync'high)(byte_index*8 to byte_index*8+7);
                     slv_reg(i)(byte_index*8+7 downto byte_index*8) <= Bus2IP_Data_sync(Bus2IP_Data_sync'high)(byte_index*8+7 downto byte_index*8);
                  end if;
               end if;
            end loop;
         end if;
      end loop;
   end if;
end if;
end process SLAVE_REG_WRITE_PROC2;

SLAVE_REG_READ_PROC : process( slv_reg_read_sel, slv_reg) is
begin
slv_ip2bus_data <= (others => '0'); 
for i in 0 to C_NUM_REG-1 loop
   if(slv_reg_read_sel(i) = '1') then
      for j in 0 to C_SLV_DWIDTH-1 loop
         if (slv_mask(i)(j) = '1') then
            slv_ip2bus_data(j) <= slv_reg(i)(j);
         else
            slv_ip2bus_data(j) <= slv_reg_stat(i)(j);
         end if;
      end loop;
   end if;
end loop;
end process SLAVE_REG_READ_PROC;


GEN_REGS: for i in 0 to C_NUM_REG-1 generate
   le_slv_reg(i)     <= slv_reg(i);
   slv_reg_stat(i)   <= le_slv_reg_stat(i);
end generate GEN_REGS;


   tpg_u1 : entity work.tpg_core
   generic map 
   (
      C_FAMILY          => C_FAMILY,
      C_Chroma_Format   => C_Chroma_Format
   )
   port map
   (
      clk                  => clk,
      rst                  => rst,
      
      vsync_in             => vsync_in,
      hsync_in             => hsync_in,
      vblank_in            => vblank_in,
      hblank_in            => hblank_in,
      CbCrPolarity         => le_slv_reg(0)(5),
      VSyncPolarity        => le_slv_reg(0)(10),
      HSyncPolarity        => le_slv_reg(0)(11),
      VBlankPolarity       => le_slv_reg(0)(12),
      HBlankPolarity       => le_slv_reg(0)(13),
      de_in                => de_in,
      red_in               => red_in,
      green_in             => green_in,
      blue_in              => blue_in,
      
      PatternSel           => le_slv_reg(0)(3 downto 0),
      Motion               => le_slv_reg(1)(0),
      Motion_speed         => le_slv_reg(1)(8 downto 1),
      EnableXHairs         => le_slv_reg(0)(4),
      ComponentMask        => le_slv_reg(0)(8 downto 6),
      EnableBox            => le_slv_reg(0)(9),
      XHairsV              => le_slv_reg(2)(11 downto 0),
      XHairsH              => le_slv_reg(2)(27 downto 16),
      active_line_length   => le_slv_reg(3)(11 downto 0),
      active_frame_height  => le_slv_reg(3)(27 downto 16),
      ZPlateHDeltaStart    => le_slv_reg(4)(31 downto 16),
      ZPlateHDelta2        => le_slv_reg(4)(15 downto 0),
      ZPlateVDeltaStart    => le_slv_reg(5)(31 downto 16),
      ZPlateVDelta2        => le_slv_reg(5)(15 downto 0),
      BoxSize              => le_slv_reg(6)(11 downto 0),
      BoxColour            => le_slv_reg(7)(23 downto 0),
      vsync_out            => vsync_out,
      hsync_out            => hsync_out,
      vblank_out           => vblank_out,
      hblank_out           => hblank_out,
      de_out               => de_out,
      red_out              => red_out,
      green_out            => green_out,
      blue_out             => blue_out,
      ZP_debug             => ZP_debug,
      TPG_debug            => TPG_debug
      
   );
  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
--  IP2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else (others => '0');
--  IP2Bus_WrAck <= slv_write_ack;
--  IP2Bus_RdAck <= slv_read_ack;
--  IP2Bus_Error <= '0';

---- Including sync registers
-- JLH: Modified to use single beat ack signals wrack_d, rdack_d
IP2Bus_Data    <= slv_ip2bus_data_sync(slv_ip2bus_data_sync'high);
IP2Bus_WrAck   <= wrack_d;--slv_write_ack_sync(slv_write_ack_sync'high);
IP2Bus_RdAck   <= rdack_d; -- slv_read_ack_sync(slv_read_ack_sync'high);
IP2Bus_Error   <= '0';


end IMP;
