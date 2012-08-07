--*****************************************************************************
-- Copyright (c) 2006-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, Inc.
-- All Rights Reserved
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: $Name:  $
--  \   \         Application: MIG
--  /   /         Filename: phy_dm_iob.v
-- /___/   /\     Date Last Modified: $Date: 2007/08/14 02:59:41 $
-- \   \  /  \    Date Created: Wed Aug 16 2006
--  \___\/\___\
--
--Device: Virtex-5
--Purpose:
--   This module places the data mask signals into the IOBs.
--Reference:
--Revision History:
--   Rev 1.1 - Translated from Verilog to VHDL. 7/31/07
--   Rev 1.2 - Use falling edge primitive for CE flop. RC. 8/12/07
--*****************************************************************************

--*****************************************************************************
--$Id: phy_dm_iob.vhd,v 1.2 2007/08/14 02:59:41 richc Exp $
--$Date: 2007/08/14 02:59:41 $
--$Author: richc $
--$Revision: 1.2 $
--$Source: /devl/xcs/repo/groups/apd_mem/Virtex5/designs/2_0/ddr2/rtl/vhdl/phy_dm_iob.vhd,v $
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;
  
entity phy_dm_iob is
  port (
    clk90           : in std_logic;
    dm_ce           : in std_logic;
    mask_data_rise  : in std_logic;
    mask_data_fall  : in std_logic;
    ddr_dm          : out std_logic
  );
end entity phy_dm_iob;

architecture syn of phy_dm_iob is
  
  signal dm_out        : std_logic;
  signal dm_ce_r       : std_logic;


begin

  u_dm_ce : FDPE_1
    port map (
      D    => dm_ce,
      PRE  => '0',
      C    => clk90,
      Q    => dm_ce_r,
      CE   => '1'
      );
    
  u_oddr_dm : ODDR
    generic map (
      SRTYPE        => "SYNC",
      DDR_CLK_EDGE  => "SAME_EDGE"
      )
    port map (
      Q  => dm_out,
      C  => clk90,
      CE => dm_ce_r,
      D1 => mask_data_rise,
      D2 => mask_data_fall,
      R  => '0',
      S  => '0'
      );
   
  u_obuf_dm : OBUF
    port map (
      I  => dm_out,
      O  => ddr_dm
    );
  
end architecture syn;


