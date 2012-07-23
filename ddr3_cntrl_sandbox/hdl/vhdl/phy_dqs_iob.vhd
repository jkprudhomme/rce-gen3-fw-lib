--*****************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2006, 2007, 2008 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: 3.6.1
--  \   \         Application: MIG
--  /   /         Filename: ddr2_phy_dqs_iob.vhd
-- /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:03 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR/DDR2
--Purpose:
--   This module places the data strobes in the IOBs.
--Reference:
--Revision History:
--   Rev 1.1 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
--   Rev 1.2 - Parameter IODELAY_GRP added and constraint IODELAY_GROUP added
--             on IODELAY primitives. PK. 11/27/08
--   Rev 1.3 - IDDR primitve (u_iddr_dq_ce) is replaced with a negative-edge
--             triggered flip-flop. PK. 03/20/09
--   Rev 1.4 - To fix CR 540201, S and syn_preserve attributes are added
--             for dqs_oe_n_r. PK. 01/08/10
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity phy_dqs_iob is
  generic (
    -- Following parameters are for 72-bit RDIMM design (for ML561 Reference
    -- board design). Actual values may be different. Actual parameters values
    -- are passed from design top module mig_36_1 module. Please refer to
    -- the mig_36_1 module for actual values.
    DDR_TYPE              : integer := 1;
    HIGH_PERFORMANCE_MODE : boolean := TRUE;
    IODELAY_GRP           : string  := "IODELAY_MIG"
  );
  port (
    clk0           : in std_logic;
    clkdiv0        : in std_logic;
    rst0           : in std_logic;
    dlyinc_dqs     : in std_logic;
    dlyce_dqs      : in std_logic;
    dlyrst_dqs     : in std_logic;
    dlyinc_gate    : in std_logic;
    dlyce_gate     : in std_logic;
    dlyrst_gate    : in std_logic;
    dqs_oe_n       : in std_logic;
    dqs_rst_n      : in std_logic;
    en_dqs         : in std_logic;
    ddr_dqs        : inout std_logic;
    ddr_dqs_n      : inout std_logic;
    dq_ce          : out std_logic;
    delayed_dqs    : out std_logic
  );
end entity phy_dqs_iob;

architecture syn of phy_dqs_iob is

  -- only need explicit component declarations for IODELAY
  -- for pre-Synplify Pro 8.8 (Synplify Pro 8.8+ and XST understands this
  -- primitive)
  component IODELAY
    generic (
      DELAY_SRC             : string;
      HIGH_PERFORMANCE_MODE : boolean;
      IDELAY_TYPE           : string;
      IDELAY_VALUE          : integer;
      ODELAY_VALUE          : integer);
    port (
      DATAOUT : out std_ulogic;
      C       : in  std_ulogic;
      CE      : in  std_ulogic;
      DATAIN  : in  std_ulogic;
      IDATAIN : in  std_ulogic;
      INC     : in  std_ulogic;
      ODATAIN : in  std_ulogic;
      RST     : in  std_ulogic;
      T       : in  std_ulogic);
  end component;

  -- for simulation only. Synthesis should ignore this delay
  constant DQS_NET_DELAY : time := 0.8 ns;

  signal clk180          : std_logic;
  signal dqs_bufio       : std_logic;
  signal dqs_ibuf        : std_logic;
  signal dqs_idelay      : std_logic;
  signal dqs_oe_n_delay  : std_logic;
  signal dqs_oe_n_r      : std_logic;
  signal dqs_rst_n_delay : std_logic;
  signal dqs_rst_n_r     : std_logic;
  signal dqs_out         : std_logic;
  signal en_dqs_sync     : std_logic;

  attribute syn_black_box : boolean;
  attribute syn_black_box of IODELAY : component is true;
  attribute IOB : string;
  attribute syn_useioff : boolean;
  attribute IOB of u_tri_state_dqs : label is "force";
  attribute syn_useioff of u_tri_state_dqs : label is true;
  attribute IOB of u_iddr_dq_ce : label is "force";
  attribute syn_useioff of u_iddr_dq_ce : label is true;
  attribute syn_replicate : boolean;
  attribute syn_replicate of u_iddr_dq_ce : label is false;
  attribute S : string;
  attribute S of dqs_oe_n_r : signal is "TRUE";

  attribute equivalent_register_removal : string;
  attribute max_fanout : string;
  attribute syn_keep : boolean;
  attribute syn_maxfan : integer;
  attribute syn_preserve : boolean;
  attribute max_fanout of dqs_rst_n_r : signal is "1";
  attribute syn_maxfan of dqs_rst_n_r : signal is 1;
  attribute equivalent_register_removal of dqs_rst_n_r : signal is "no";
  attribute syn_preserve of dqs_rst_n_r : signal is true;
  attribute syn_keep of dqs_rst_n_r : signal is true;
  attribute syn_keep of dqs_oe_n_r : signal is true;

  signal i_delayed_dqs : std_logic;

  attribute IODELAY_GROUP : string;
  attribute IODELAY_GROUP of u_idelay_dqs : label is IODELAY_GRP;
  attribute IODELAY_GROUP of u_iodelay_dq_ce : label is IODELAY_GRP;

begin

  clk180 <= not(clk0);

  -- add delta delay to inputs clocked by clk180 to avoid delta-delay
  -- simulation issues
  dqs_rst_n_delay <= dqs_rst_n;
  dqs_oe_n_delay  <= dqs_oe_n;

  --***************************************************************************
  -- DQS input-side resources:
  --  - IODELAY (pad -> IDELAY)
  --  - BUFIO (IDELAY -> BUFIO)
  --***************************************************************************

  -- Route DQS from PAD to IDELAY
  u_idelay_dqs : IODELAY
    generic map (
      DELAY_SRC             => "I",
      IDELAY_TYPE           => "VARIABLE",
      HIGH_PERFORMANCE_MODE => HIGH_PERFORMANCE_MODE,
      IDELAY_VALUE          => 0,
      ODELAY_VALUE          => 0
      )
    port map (
      DATAOUT => dqs_idelay,
      C       => clkdiv0,
      CE      => dlyce_dqs,
      DATAIN  => '0',
      IDATAIN => dqs_ibuf,
      INC     => dlyinc_dqs,
      ODATAIN => '0',
      RST     => dlyrst_dqs,
      T       => '0'
      );

  -- From IDELAY to BUFIO
  u_bufio_dqs : BUFIO
    port map (
      I  => dqs_idelay,
      O  => dqs_bufio
    );

  -- To model additional delay of DQS BUFIO + gating network
  -- for behavioral simulation. Make sure to select a delay number smaller
  -- than half clock cycle (otherwise output will not track input changes
  -- because of inertial delay). Duplicate to avoid delta delay issues.
  i_delayed_dqs <= dqs_bufio after DQS_NET_DELAY;
  delayed_dqs <= dqs_bufio after DQS_NET_DELAY;

  --***************************************************************************
  -- DQS gate circuit (not supported for all controllers)
  --***************************************************************************

  -- Gate routing:
  --   en_dqs -> IDELAY -> en_dqs_sync -> IDDR.S -> dq_ce ->
  --   capture IDDR.CE

  -- Delay CE control so that it's in phase with delayed DQS
  u_iodelay_dq_ce : IODELAY
    generic map (
      DELAY_SRC             => "DATAIN",
      IDELAY_TYPE           => "VARIABLE",
      HIGH_PERFORMANCE_MODE => HIGH_PERFORMANCE_MODE,
      IDELAY_VALUE          => 0,
      ODELAY_VALUE          => 0
      )
    port map (
      DATAOUT => en_dqs_sync,
      C       => clkdiv0,
      CE      => dlyce_gate,
      DATAIN  => en_dqs,
      IDATAIN => '0',
      INC     => dlyinc_gate,
      ODATAIN => '0',
      RST     => dlyrst_gate,
      T       => '0'
      );

  -- Generate sync'ed CE to DQ IDDR's using a negative-edge triggered flip-flop
  -- clocked by DQS. This flop should be locked to the IOB flip-flop at the same
  -- site as IODELAY u_idelay_dqs in order to use the dedicated route from
  -- the IODELAY to flip-flop (to keep this route as short as possible)
  u_iddr_dq_ce : FDCPE_1
    generic map (
      INIT => '0'
      )
    port map (
      Q   => dq_ce,
      C   => i_delayed_dqs,
      CE  => '1',
      CLR => '0',
      D   => en_dqs_sync,
      PRE => en_dqs_sync
      );

  --***************************************************************************
  -- DQS output-side resources
  --***************************************************************************

  process (clk180)
  begin
    if (rising_edge(clk180)) then
      dqs_rst_n_r <= dqs_rst_n_delay;
    end if;
  end process;

  u_oddr_dqs : ODDR
    generic map (
      SRTYPE        => "SYNC",
      DDR_CLK_EDGE  => "OPPOSITE_EDGE"
    )
    port map (
      Q  => dqs_out,
      C  => clk180,
      CE => '1',
      D1 => dqs_rst_n_r, -- keep output deasserted for write preamble
      D2 => '0',
      R  => '0',
      S  => '0'
      );

  u_tri_state_dqs : FDP
    port map (
      D   => dqs_oe_n_delay,
      Q   => dqs_oe_n_r,
      C   => clk180,
      PRE => rst0
      );

  --***************************************************************************

  -- use either single-ended (for DDR1) or differential (for DDR2) DQS input

  gen_dqs_iob_ddr2_ddr3: if (DDR_TYPE > 0) generate
    u_iobuf_dqs : IOBUFDS
      port map (
        O   => dqs_ibuf,
        IO  => ddr_dqs,
        IOB => ddr_dqs_n,
        I   => dqs_out,
        T   => dqs_oe_n_r
        );
  end generate;

  gen_dqs_iob_ddr1: if (DDR_TYPE = 0) generate
    u_iobuf_dqs : IOBUF
      port map (
        O  => dqs_ibuf,
        IO => ddr_dqs,
        I  => dqs_out,
        T  => dqs_oe_n_r
        );
  end generate;

end architecture syn;


