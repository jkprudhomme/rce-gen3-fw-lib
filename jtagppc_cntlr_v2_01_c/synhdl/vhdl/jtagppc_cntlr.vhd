--------------------------------------------------------------------------
-- $Id: jtagppc_cntlr.vhd,v 1.2 2008/07/08 04:23:48 jeffs Exp $
--------------------------------------------------------------------------
-- jtagppc_cntlr.vhd - entity/architecture
--------------------------------------------------------------------------
-- ** Copyright(C) 2008 by Xilinx, Inc. All rights reserved.
-- **
-- ** This text contains proprietary, confidential information of
-- ** Xilinx, Inc. , is distributed by under license from Xilinx, Inc.,
-- ** and may be used, copied and/or disclosed only pursuant to the
-- ** terms of a valid license agreement with Xilinx, Inc.
-- **
-- ** Unmodified source code is guaranteed to place and route,
-- ** function and run at speed according to the datasheet
-- ** specification. Source code is provided "as-is", with no
-- ** obligation on the part of Xilinx to provide support.
-- **
-- ** Xilinx Hotline support of source code IP shall only include
-- ** standard level Xilinx Hotline support, and will only address
-- ** issues and questions related to the standard released Netlist
-- ** version of the core (and thus indirectly, the original core source
-- **
-- ** The Xilinx Support Hotline does not have access to source
-- ** code and therefore cannot answer specific questions related
-- ** to source HDL. The Xilinx Support Hotline will only be able
-- ** to confirm the problem in the Netlist version of the core.
-- **
-- ** This copyright and support notice must be retained as part
-- ** of this text at all times.
-- -------------------------------------------------------------------------
-- Filename: jtagppc_cntlr.vhd
-- Description:
--   SYNTHESIS-ONLY MODULE
--   Connecting this module to the JTAG port of the 
--   PowerPC pcore causes all PowerPC BDM ports to be 
--   included in the JTAG chain of the FPGA device,
--   normally used for configuration download.
-------------------------------------------------------------------------------
-- Structure:
--                 jtagppc_cntlr
-------------------------------------------------------------------------------
-- @BEGIN_CHANGELOG EDK_K_SP3
-- *** jtagppc_cntlr_v2_01_c EDK10.1.03 ***
-- New Features
-- Supports qvirtex4 and qrvirtex4 families
--
-- Resolved Issues
-- Bus interface JTAGPPC1 visible only when dual-PPC device targeted (CR472523).
--
-- @END_CHANGELOG
--
-- @BEGIN_CHANGELOG EDK_K
-- *** jtagppc_cntlr_v2_01_b EDK10.1.02 ***
-- New Features
-- None
--
-- Resolved Issues
-- Fixed CR470148: Simulation flow broken for dual-PowerPC devices
-- Problem only occurs when only one ppc is instantiated in the mhs
-- (2nd ppc is automatically instatiated by the jtagppc_cntlr_v2_01_a),
-- the simulation flow breaks due to an illegal binding of the 2nd ppc instance
-- to the swift model. Solution is to create a separate simulation model (simhdl)
-- and implementation model (synhdl) in pcore.
--
-- Known Issues
-- None
--
-- Other Information (optional)
--
-- *** jtagppc_cntlr_v2_01_a EDK10.1 ***
-- New Features
-- Added support for Virtex5FX, which uses new JTAGPPC440 primitive.
-- Implemented CR435050: JTAGPPC enhancement for devices with 2 PPCs in it.
-- Enhanced to automatically instantiate and connect second PPC in any dual-PPC device
-- Drop-in compatible to jtagppc_cntlr_v2_00_a.
-- 
-- Resolved Issues
-- None
--
-- Known Issues
-- None
--
-- Other Information (optional)
--
-- @END_CHANGELOG
--------------------------------------------------------------------------
-- Naming Conventions:
-- active low signals: "*_n"
-- clock signals: "clk", "div#_clk", "#x_clk"
-- reset signals: "rst", "rst_n"
-- generics: "C_*"
-- user defined types: "*_TYPE"
-- state machine next state: "*_ns"
-- state machine current state: "*_cs"
-- combinational signals: "*_cmb"
-- pipelined or register delay signals: "*_d#"
-- counter signals: "*cnt*"
-- clock enable signals: "*_ce"
-- internal version of output port: "*_i"
-- ports: - Names begin with Uppercase
-- processes: "*_PROCESS"
-- component instantiations: "<ENTITY_><#|FUNC>_I
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity jtagppc_cntlr is
  generic (
    C_DEVICE          :     string := "2vp4";
    C_NUM_PPC_USED    :     integer := 0
  );
  port (
    TRSTNEG           : in  std_logic;
    -- Halt control PPC 0
    HALTNEG0          : in  std_logic;
    DBGC405DEBUGHALT0 : out std_logic;
    -- Halt control PPC 1
    HALTNEG1          : in  std_logic;
    DBGC405DEBUGHALT1 : out std_logic;
    -- JTAG Port 0
    C405JTGTDO0       : in  std_logic;
    C405JTGTDOEN0     : in  std_logic;
    JTGC405TCK0       : out std_logic;
    JTGC405TDI0       : out std_logic;
    JTGC405TMS0       : out std_logic;
    JTGC405TRSTNEG0   : out std_logic;
    -- JTAG Port 1
    C405JTGTDO1       : in  std_logic;
    C405JTGTDOEN1     : in  std_logic;
    JTGC405TCK1       : out std_logic;
    JTGC405TDI1       : out std_logic;
    JTGC405TMS1       : out std_logic;
    JTGC405TRSTNEG1   : out std_logic
    );
    
    -- NOTE: All ports that connect to the processor, such as JTGC405TCK0,
    --       JTGC405TRSTNEG0 and DBGC405DEBUGHALT0, are compatible with both 
    --       PPC405 and PPC440 type processors.
    
end jtagppc_cntlr;

--------------------------------------------------------------------------------
-- Architecture Implementation
--------------------------------------------------------------------------------
architecture implementation of jtagppc_cntlr is

  component JTAGPPC
    port
    (
      TCK : out std_ulogic;
      TDIPPC : out std_ulogic;
      TMS : out std_ulogic;
      TDOPPC : in std_ulogic;
      TDOTSPPC : in std_ulogic
    );
  end component;

  component JTAGPPC440
    port
    (
      TCK : out std_ulogic;
      TDIPPC : out std_ulogic;
      TMS : out std_ulogic;
      TDOPPC : in std_ulogic
    );
  end component;

  component PPC405
    port (
      JTGC405TCK 		: in std_logic ;
      JTGC405TDI 		: in std_logic ;
      JTGC405TMS 		: in std_logic ;
      JTGC405TRSTNEG 		: in std_logic ;
      C405JTGTDO 		: out std_logic ;
      C405JTGTDOEN 		: out std_logic
    );
  end component;

  component PPC405_ADV
    port (
      JTGC405TCK 		: in std_logic ;
      JTGC405TDI 		: in std_logic ;
      JTGC405TMS 		: in std_logic ;
      JTGC405TRSTNEG 		: in std_logic ;
      C405JTGTDO 		: out std_logic ;
      C405JTGTDOEN 		: out std_logic
    );
  end component;

  component PPC440
    port (
      JTGC440TCK 		: in std_logic ;
      JTGC440TDI 		: in std_logic ;
      JTGC440TMS 		: in std_logic ;
      JTGC440TRSTNEG 		: in std_logic ;
      C440JTGTDO 		: out std_logic ;
      C440JTGTDOEN 		: out std_logic
    );
  end component;
  
  function LowerCase_Char(char : character) return character is
  begin
    -- If char is not an upper case letter then return char
    if char < 'A' or char > 'Z' then
      return char;
    end if;
    -- Otherwise map char to its corresponding lower case character and
    -- return that
    case char is
      when 'A'    => return 'a'; when 'B' => return 'b'; when 'C' => return 'c'; when 'D' => return 'd';
      when 'E'    => return 'e'; when 'F' => return 'f'; when 'G' => return 'g'; when 'H' => return 'h';
      when 'I'    => return 'i'; when 'J' => return 'j'; when 'K' => return 'k'; when 'L' => return 'l';
      when 'M'    => return 'm'; when 'N' => return 'n'; when 'O' => return 'o'; when 'P' => return 'p';
      when 'Q'    => return 'q'; when 'R' => return 'r'; when 'S' => return 's'; when 'T' => return 't';
      when 'U'    => return 'u'; when 'V' => return 'v'; when 'W' => return 'w'; when 'X' => return 'x';
      when 'Y'    => return 'y'; when 'Z' => return 'z';
      when others => return char;
    end case;
  end LowerCase_Char;

  function LowerCase_String (s : string) return string is
    variable res : string(s'range);
  begin  -- function LoweerCase_String
    for I in s'range loop
      res(I) := LowerCase_Char(s(I));
    end loop;  -- I
    return res;
  end function LowerCase_String;
  
  -- purpose: look up how many ppc's are in the targeted device
  function ppc_cnt (
    constant DEVICE : string)
    return natural is
    variable lowercase_device : string(DEVICE'range);
  begin  -- ppc_cnt
    lowercase_device := LowerCase_String(DEVICE);
    if 
      (lowercase_device = "2vp4") or 
      (lowercase_device = "2vp7") or 
      (lowercase_device = "2vpx20") or 
      (lowercase_device = "4vfx12") or 
      (lowercase_device = "4vfx20") or
      (lowercase_device = "5vfx30t") or
      (lowercase_device = "5vfx70t") then
      return 1;
      -- Note: qvirtex4 and qrvirtex4 families contain no single-ppc devices
    else
      return 2;
    end if;
  end ppc_cnt;
  
  function fpga_family (
    constant DEVICE : string)
    return character is
    variable res : character := '5';
  begin 
    FirstDigit: for I in DEVICE'left to (DEVICE'right - 2) loop
      if (DEVICE(I) >= '2') and (DEVICE(I) <= '9') then
        res := DEVICE(I);
        exit FirstDigit;
      end if;
    end loop FirstDigit;
    return res;
  end fpga_family;
  
  signal C405JTGTDOEN_All : std_logic;
  signal C405JTGTDOEN     : std_logic;
  signal JTGC405TCK       : std_logic;
  signal JTGC405TMS       : std_logic;
  signal C405JTGTDO       : std_logic;
  constant device_ppc_cnt : natural := ppc_cnt(C_DEVICE);
  constant device_family  : character := fpga_family(C_DEVICE);
  constant net_vcc       : std_logic := '1';

begin
  -----------------------------------------------------------------------------
  -- Connect to Internal JTAG Debug Controller  -- 
  -----------------------------------------------------------------------------

  DBGC405DEBUGHALT0 <= not HALTNEG0;
  DBGC405DEBUGHALT1 <= not HALTNEG1;

  JTGC405TRSTNEG0 <= TRSTNEG;
  JTGC405TRSTNEG1 <= TRSTNEG;
  
  -----------------------------------------------------------------------------
  -- Chains single PPC to jtagppc primitive. Only to be used in devices with a
  -- single PPC (2VP4, 2VP7, 2VPX20, 4VFX12, 4VXFX20)
  -----------------------------------------------------------------------------
  single_ppc_connectivity: if device_ppc_cnt = 1 generate
    single_PPC405: if device_family = '2' or device_family = '4' generate
      JTAGPPC_i0 : JTAGPPC port map (
        TCK      => JTGC405TCK0,            -- O
        TDIPPC   => JTGC405TDI0,            -- O
        TMS      => JTGC405TMS0,            -- O
        TDOPPC   => C405JTGTDO0,            -- I
        TDOTSPPC => C405JTGTDOEN0           -- I
        );
    end generate single_PPC405;
    single_PPC440: if not(device_family = '2' or device_family = '4') generate
      JTAGPPC_i1 : JTAGPPC440 port map (
        TCK      => JTGC405TCK0,            -- O
        TDIPPC   => JTGC405TDI0,            -- O
        TMS      => JTGC405TMS0,            -- O
        TDOPPC   => C405JTGTDO0            -- I
        -- TDOTSPPC not present on JTAGPPC440
        );
    end generate single_PPC440;
  end generate single_ppc_connectivity;

  -----------------------------------------------------------------------------
  -- Chains both PPC devices as required in 2 PPC parts
  -- Both PPCs are instantiated in the design
  -----------------------------------------------------------------------------
  dual_ppc_connectivity: if device_ppc_cnt = 2 and C_NUM_PPC_USED = 2 generate
    JTGC405TDI1 <= C405JTGTDO0;
    JTGC405TMS0 <= JTGC405TMS;
    JTGC405TMS1 <= JTGC405TMS;
    JTGC405TCK0 <= JTGC405TCK;
    JTGC405TCK1 <= JTGC405TCK;
    C405JTGTDOEN_All <= C405JTGTDOEN0 or C405JTGTDOEN1;

    dual_PPC405: if device_family = '2' or device_family = '4' generate
      JTAGPPC_i2 : JTAGPPC port map (
        TCK      => JTGC405TCK,            -- O
        TDIPPC   => JTGC405TDI0,            -- O
        TMS      => JTGC405TMS,            -- O
        TDOPPC   => C405JTGTDO1,            -- I
        TDOTSPPC => C405JTGTDOEN_All        -- I
        );    
    end generate dual_PPC405;
    dual_PPC440: if not(device_family = '2' or device_family = '4') generate
      JTAGPPC_i3 : JTAGPPC440 port map (
        TCK      => JTGC405TCK,            -- O
        TDIPPC   => JTGC405TDI0,            -- O
        TMS      => JTGC405TMS,            -- O
        TDOPPC   => C405JTGTDO1            -- I
        -- TDOTSPPC not present on JTAGPPC440
        );    
    end generate dual_PPC440;
  end generate dual_ppc_connectivity;

  -----------------------------------------------------------------------------
  -- Chains both PPC devices as required in 2 PPC parts
  -- Only one PPC is instantiated in the design
  -----------------------------------------------------------------------------
  auto_ppc_connectivity: if device_ppc_cnt = 2 and C_NUM_PPC_USED = 1 generate
    JTGC405TMS0 <= JTGC405TMS;
    JTGC405TCK0 <= JTGC405TCK;

    auto_PPC405: if device_family = '2' generate
      C405JTGTDOEN_All <= C405JTGTDOEN0 or C405JTGTDOEN;
      JTAGPPC_i4 : JTAGPPC port map (
        TCK      => JTGC405TCK,            -- O
        TDIPPC   => JTGC405TDI0,            -- O
        TMS      => JTGC405TMS,            -- O
        TDOPPC   => C405JTGTDO,            -- I
        TDOTSPPC => C405JTGTDOEN_All        -- I
        );    
      PPC_auto_i0: PPC405 port map (
        C405JTGTDO                 => C405JTGTDO,
        C405JTGTDOEN               => C405JTGTDOEN,
        JTGC405TCK                 => JTGC405TCK,
        JTGC405TDI                 => C405JTGTDO0,
        JTGC405TMS                 => JTGC405TMS,
        JTGC405TRSTNEG             => TRSTNEG
        );
    end generate auto_PPC405;
    auto_PPC405_ADV: if device_family = '4' generate
      C405JTGTDOEN_All <= C405JTGTDOEN0 or C405JTGTDOEN;
      JTAGPPC_i5 : JTAGPPC port map (
        TCK      => JTGC405TCK,            -- O
        TDIPPC   => JTGC405TDI0,            -- O
        TMS      => JTGC405TMS,            -- O
        TDOPPC   => C405JTGTDO,            -- I
        TDOTSPPC => C405JTGTDOEN_All        -- I
        );    
      PPC_auto_i1: PPC405_ADV port map (
        C405JTGTDO                 => C405JTGTDO,
        C405JTGTDOEN               => C405JTGTDOEN,
        JTGC405TCK                 => JTGC405TCK,
        JTGC405TDI                 => C405JTGTDO0,
        JTGC405TMS                 => JTGC405TMS,
        JTGC405TRSTNEG             => TRSTNEG
        );
   end generate auto_PPC405_ADV;
    auto_PPC440: if not(device_family = '2' or device_family = '4') generate
      JTAGPPC_i6 : JTAGPPC440 port map (
        TCK      => JTGC405TCK,            -- O
        TDIPPC   => JTGC405TDI0,            -- O
        TMS      => JTGC405TMS,            -- O
        TDOPPC   => C405JTGTDO            -- I
        -- TDOTSPPC not present on JTAGPPC440
        );    
      PPC_auto_i2: PPC440 port map (
        C440JTGTDO                 => C405JTGTDO,
        JTGC440TCK                 => JTGC405TCK,
        JTGC440TDI                 => C405JTGTDO0,
        JTGC440TMS                 => JTGC405TMS,
        JTGC440TRSTNEG             => TRSTNEG
        );
    end generate auto_PPC440;
  end generate auto_ppc_connectivity;

end implementation ;

