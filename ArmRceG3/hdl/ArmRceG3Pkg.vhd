-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Package File
-- File          : ArmRceG3Pkg.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Package file for ARM based rce generation 3 processor core.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

package ArmRceG3Pkg is

   ----------------------------------
   -- Constants
   ----------------------------------
   constant tpd                             : time    := 0.1 ns;

   ----------------------------------
   -- Types
   ----------------------------------
   --subtype i2c_reg_type is bit_vector(0 to 31);
   --type i2c_reg_vector is array (integer range<>) of i2c_reg_type;

   ----------------------------------
   -- Records
   ----------------------------------

   -- AXI bus, master output
   type AxiMasterType is record
      arvalid               : std_logic;
      awvalid               : std_logic;
      bready                : std_logic;
      rready                : std_logic;
      wlast                 : std_logic;
      wvalid                : std_logic;
      rdissuecap1_en        : std_logic; -- HP0-3
      wrissuecap1_en        : std_logic; -- HP0-3
      arid                  : std_logic_vector(11 downto 0); -- 12 for master GP, 6 for slave GP, 4 for ACP, 6 for HP
      awid                  : std_logic_vector(11 downto 0); -- 12 for master GP, 6 for slave GP, 4 for ACP, 6 for HP
      wid                   : std_logic_vector(11 downto 0); -- 12 for master GP, 6 for slave GP, 4 for ACP, 6 for HP
      arburst               : std_logic_vector(1  downto 0);
      arlock                : std_logic_vector(1  downto 0);
      arsize                : std_logic_vector(2  downto 0);
      awburst               : std_logic_vector(1  downto 0);
      awlock                : std_logic_vector(1  downto 0);
      awsize                : std_logic_vector(2  downto 0);
      arprot                : std_logic_vector(2  downto 0);
      awprot                : std_logic_vector(2  downto 0);
      araddr                : std_logic_vector(31 downto 0);
      awaddr                : std_logic_vector(31 downto 0);
      wdata                 : std_logic_vector(63 downto 0); -- 32 bits for GP0/GP1
      arcache               : std_logic_vector(3  downto 0);
      arlen                 : std_logic_vector(3  downto 0);
      arqos                 : std_logic_vector(3  downto 0);
      awcache               : std_logic_vector(3  downto 0);
      awlen                 : std_logic_vector(3  downto 0);
      awqos                 : std_logic_vector(3  downto 0);
      wstrb                 : std_logic_vector(3  downto 0);
      aruser                : std_logic_vector(4  downto 0); -- ACP
      awuser                : std_logic_vector(4  downto 0); -- ACP
   end record;

   constant AxiMasterInit : AxiMasterType := ( 
      arvalid               => '0',
      awvalid               => '0',
      bready                => '0',
      rready                => '0',
      wlast                 => '0',
      wvalid                => '0',
      rdissuecap1_en        => '0',
      wrissuecap1_en        => '0',
      arid                  => x"000",
      awid                  => x"000",
      wid                   => x"000",
      arburst               => "00",
      arlock                => "00",
      arsize                => "000",
      awburst               => "00",
      awlock                => "00",
      awsize                => "000",
      arprot                => "000",
      awprot                => "000",
      araddr                => x"00000000",
      awaddr                => x"00000000",
      wdata                 => x"0000000000000000",
      arcache               => "0000",
      arlen                 => "0000",
      arqos                 => "0000",
      awcache               => "0000",
      awlen                 => "0000",
      awqos                 => "0000",
      wstrb                 => "0000",
      aruser                => "00000",
      awuser                => "00000"
   );

   type AxiMasterVector is array (integer range<>) of AxiMasterType;

   -- AXI bus, slave output
   type AxiSlaveType is record
      arready               : std_logic;
      awready               : std_logic;
      bvalid                : std_logic;
      rlast                 : std_logic;
      rvalid                : std_logic;
      wready                : std_logic;
      bid                   : std_logic_vector(11 downto 0); -- 12 for master GP, 6 for slave GP, 4 for ACP, 6 for HP
      rid                   : std_logic_vector(11 downto 0); -- 12 for master GP, 6 for slave GP, 4 for ACP, 6 for HP
      bresp                 : std_logic_vector(1  downto 0);
      rresp                 : std_logic_vector(1  downto 0);
      rdata                 : std_logic_vector(63 downto 0); -- 32 bits for GP0/GP1 
      rcount                : std_logic_vector(7  downto 0); -- HP0-3
      wcount                : std_logic_vector(7  downto 0); -- HP0-3
      racount               : std_logic_vector(2  downto 0); -- HP0-3
      wacount               : std_logic_vector(5  downto 0); -- HP0-3
   end record;

   constant AxiSlaveInit : AxiSlaveType := ( 
      arready               => '0',
      awready               => '0',
      bvalid                => '0',
      rlast                 => '0',
      rvalid                => '0',
      wready                => '0',
      bid                   => x"000",
      rid                   => x"000",
      bresp                 => "00",
      rresp                 => "00",
      rdata                 => x"0000000000000000",
      rcount                => x"00",
      wcount                => x"00",
      racount               => "000",
      wacount               => "000000"
   );

   type AxiSlaveVector is array (integer range<>) of AxiSlaveType;










end ArmRceG3Pkg;

