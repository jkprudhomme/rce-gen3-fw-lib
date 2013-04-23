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
   constant tpd : time := 0.1 ns;

   ----------------------------------
   -- Types
   ----------------------------------
   subtype word32Type is std_logic_vector(31 downto 0);
   type word32Array   is array (integer range<>) of word32Type;

   subtype word36Type is std_logic_vector(35 downto 0);
   type word36Array   is array (integer range<>) of word36Type;

   --------------------------------------------------------
   -- AXI bus, read master signal record
   --------------------------------------------------------

   -- Base Record
   type AxiReadMasterType is record

      -- Read Address channel
      arvalid               : std_logic;
      araddr                : std_logic_vector(31 downto 0);
      arid                  : std_logic_vector(11 downto 0); -- 12 for master GP, 6 for slave GP, 4 for ACP, 6 for HP
      arlen                 : std_logic_vector(3  downto 0);
      arsize                : std_logic_vector(2  downto 0);
      arburst               : std_logic_vector(1  downto 0);
      arlock                : std_logic_vector(1  downto 0);
      arprot                : std_logic_vector(2  downto 0);
      arcache               : std_logic_vector(3  downto 0);
      arqos                 : std_logic_vector(3  downto 0);
      aruser                : std_logic_vector(4  downto 0); -- ACP

      -- Read data channel
      rready                : std_logic;

      -- Control 
      rdissuecap1_en        : std_logic;                     -- HP0-3

   end record;

   -- Initialization constants
   constant AxiReadMasterInit : AxiReadMasterType := ( 
      arvalid               => '0',
      araddr                => x"00000000",
      arid                  => x"000",
      arlen                 => "0000",
      arsize                => "000",
      arburst               => "00",
      arlock                => "00",
      arprot                => "000",
      arcache               => "0000",
      arqos                 => "0000",
      aruser                => "00000",
      rready                => '0',
      rdissuecap1_en        => '0'
   );

   -- Vector
   type AxiReadMasterVector is array (integer range<>) of AxiReadMasterType;


   --------------------------------------------------------
   -- AXI bus, read slave signal record
   --------------------------------------------------------

   -- Base Record
   type AxiReadSlaveType is record

      -- Read Address channel
      arready               : std_logic;

      -- Read data channel
      rdata                 : std_logic_vector(63 downto 0); -- 32 bits for GP0/GP1 
      rlast                 : std_logic;
      rvalid                : std_logic;
      rid                   : std_logic_vector(11 downto 0); -- 12 for master GP, 6 for slave GP, 4 for ACP, 6 for HP
      rresp                 : std_logic_vector(1  downto 0);

      -- Status
      racount               : std_logic_vector(2  downto 0); -- HP0-3
      rcount                : std_logic_vector(7  downto 0); -- HP0-3

   end record;

   -- Initialization constants
   constant AxiReadSlaveInit : AxiReadSlaveType := ( 
      arready               => '0',
      rdata                 => x"0000000000000000",
      rlast                 => '0',
      rvalid                => '0',
      rid                   => x"000",
      rresp                 => "00",
      racount               => "000",
      rcount                => x"00"
   );

   -- Vector
   type AxiReadSlaveVector is array (integer range<>) of AxiReadSlaveType;


   --------------------------------------------------------
   -- AXI bus, write master signal record
   --------------------------------------------------------

   -- Base Record
   type AxiWriteMasterType is record

      -- Write address channel
      awvalid               : std_logic;
      awaddr                : std_logic_vector(31 downto 0);
      awid                  : std_logic_vector(11 downto 0); -- 12 for master GP, 6 for slave GP, 4 for ACP, 6 for HP
      awlen                 : std_logic_vector(3  downto 0);
      awsize                : std_logic_vector(2  downto 0);
      awburst               : std_logic_vector(1  downto 0);
      awlock                : std_logic_vector(1  downto 0);
      awcache               : std_logic_vector(3  downto 0);
      awprot                : std_logic_vector(2  downto 0);
      awqos                 : std_logic_vector(3  downto 0);
      awuser                : std_logic_vector(4  downto 0); -- ACP

      -- Write data channel
      wdata                 : std_logic_vector(63 downto 0); -- 32 bits for GP0/GP1
      wlast                 : std_logic;
      wvalid                : std_logic;
      wid                   : std_logic_vector(11 downto 0); -- 12 for master GP, 6 for slave GP, 4 for ACP, 6 for HP
      wstrb                 : std_logic_vector(7  downto 0); -- 4 for GPs

      -- Write ack channel
      bready                : std_logic;

      -- Control
      wrissuecap1_en        : std_logic;                     -- HP0-3

   end record;

   -- Initialization constants
   constant AxiWriteMasterInit : AxiWriteMasterType := ( 
      awvalid               => '0',
      awaddr                => x"00000000",
      awid                  => x"000",
      awlen                 => "0000",
      awsize                => "000",
      awburst               => "00",
      awlock                => "00",
      awcache               => "0000",
      awprot                => "000",
      awqos                 => "0000",
      awuser                => "00000",
      wdata                 => x"0000000000000000",
      wlast                 => '0',
      wvalid                => '0',
      wid                   => x"000",
      wstrb                 => "00000000",
      bready                => '0',
      wrissuecap1_en        => '0'
   );

   -- Vector
   type AxiWriteMasterVector is array (integer range<>) of AxiWriteMasterType;


   --------------------------------------------------------
   -- AXI bus, write slave signal record
   --------------------------------------------------------

   -- Base Record
   type AxiWriteSlaveType is record

      -- Write address channel
      awready               : std_logic;

      -- Write data channel
      wready                : std_logic;

      -- Write ack channel
      bresp                 : std_logic_vector(1  downto 0);
      bvalid                : std_logic;
      bid                   : std_logic_vector(11 downto 0); -- 12 for master GP, 6 for slave GP, 4 for ACP, 6 for HP

      -- Status
      wacount               : std_logic_vector(5  downto 0); -- HP0-3
      wcount                : std_logic_vector(7  downto 0); -- HP0-3

   end record;

   -- Initialization constants
   constant AxiWriteSlaveInit : AxiWriteSlaveType := ( 
      awready               => '0',
      wready                => '0',
      bresp                 => "00",
      bvalid                => '0',
      bid                   => x"000",
      wacount               => "000000",
      wcount                => x"00"
   );

   -- Vector
   type AxiWriteSlaveVector is array (integer range<>) of AxiWriteSlaveType;

end ArmRceG3Pkg;

