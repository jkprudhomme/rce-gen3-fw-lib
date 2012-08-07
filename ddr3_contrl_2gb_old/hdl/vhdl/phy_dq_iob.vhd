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
-- \   \   \/     Version: 3.1
--  \   \         Application: MIG
--  /   /         Filename: phy_dq_iob.vhd
-- /___/   /\     Date Last Modified: $Date: 2009/03/23 16:10:57 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR2
--Purpose:
--   This module places the data in the IOBs.
--Reference:
--Revision History:
--   Rev 1.1 - DIRT strings removed and modified the code. PK. 11/13/08
--   Rev 1.2 - Parameter IODELAY_GRP added and constraint IODELAY_GROUP added
--             on IODELAY primitive. PK. 11/27/08
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity phy_dq_iob is
  generic (
    -- Following parameters are for 72-bit RDIMM design (for ML561 Reference
    -- board design). Actual values may be different. Actual parameters values
    -- are passed from design top module mig_31 module. Please refer to
    -- the mig_31 module for actual values.
    HIGH_PERFORMANCE_MODE : boolean := TRUE;
    IODELAY_GRP           : string  := "IODELAY_MIG";
    FPGA_SPEED_GRADE      : integer := 2
    );
  port (
    clk0          : in std_logic;
    clk90         : in std_logic;
    clkdiv0       : in std_logic;
    rst90         : in std_logic;
    dlyinc        : in std_logic;
    dlyce         : in std_logic;
    dlyrst        : in std_logic;
    dq_oe_n       : in std_logic_vector(1 downto 0);
    dqs           : in std_logic;
    ce            : in std_logic;
    rd_data_sel   : in std_logic;
    wr_data_rise  : in std_logic;
    wr_data_fall  : in std_logic;
    rd_data_rise  : out std_logic;
    rd_data_fall  : out std_logic;
    ddr_dq        : inout std_logic
  );
end entity phy_dq_iob;

architecture syn of phy_dq_iob is

  -- only need explicit component declarations for IODELAY and LUT6_2
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

  signal dq_iddr_clk       : std_logic;
  signal dq_idelay         : std_logic;
  signal dq_in             : std_logic;
  signal dq_oe_n_r         : std_logic;
  signal dq_out            : std_logic;
  signal stg2a_out_fall    : std_logic;
  signal stg2a_out_rise    : std_logic;
  signal stg2b_out_fall    : std_logic;
  signal stg2b_out_rise    : std_logic;
  signal stg3a_out_fall    : std_logic;
  signal stg3a_out_rise    : std_logic;
  signal stg3b_out_fall    : std_logic;
  signal stg3b_out_rise    : std_logic;

  attribute IOB           : string;
  attribute KEEP          : string;
  attribute syn_black_box : boolean;
  attribute syn_keep      : boolean;
  attribute syn_useioff   : boolean;
  attribute syn_preserve  : boolean;
  attribute syn_replicate : boolean;

  attribute syn_black_box of IODELAY : component is true;
  attribute IOB of u_tri_state_dq : label is "force";
  attribute syn_useioff of u_tri_state_dq : label is true;

  --***************************************************************************
  -- Directed routing constraints for route between IDDR and stage 2 capture
  -- in fabric.
  -- Only 2 out of the 12 wire declarations will be used for any given
  -- instantiation of this module.
  -- Varies according:
  --  (1) I/O column (left, center, right) used
  --  (2) Which I/O in I/O pair (master, slave) used
  -- Nomenclature: _Xy, X = column (0 = left, 1 = center, 2 = right),
  --  y = master or slave
  --***************************************************************************

  -- MODIFIED, RC, 06/19/08: Remove all references to DIRT, master/slave
  signal stg1_out_rise_sg3 : std_logic;
  signal stg1_out_fall_sg3 : std_logic;
  signal stg1_out_rise_sg2 : std_logic;
  signal stg1_out_fall_sg2 : std_logic;
  signal stg1_out_rise_sg1 : std_logic;
  signal stg1_out_fall_sg1 : std_logic;

  attribute XIL_PAR_DELAY   : string;
  attribute XIL_PAR_SKEW    : string;
  attribute XIL_PAR_IP_NAME : string;

  attribute XIL_PAR_DELAY   of stg1_out_rise_sg3 : signal is "500 ps";
  attribute XIL_PAR_SKEW    of stg1_out_rise_sg3 : signal is "55 ps";
  attribute XIL_PAR_IP_NAME of stg1_out_rise_sg3 : signal is "MIG";
  attribute syn_keep        of stg1_out_rise_sg3 : signal is true;
  attribute KEEP            of stg1_out_rise_sg3 : signal is "TRUE";
  attribute XIL_PAR_DELAY   of stg1_out_rise_sg2 : signal is "575 ps";
  attribute XIL_PAR_SKEW    of stg1_out_rise_sg2 : signal is "65 ps";
  attribute XIL_PAR_IP_NAME of stg1_out_rise_sg2 : signal is "MIG";
  attribute syn_keep        of stg1_out_rise_sg2 : signal is true;
  attribute KEEP            of stg1_out_rise_sg2 : signal is "TRUE";
  attribute XIL_PAR_DELAY   of stg1_out_rise_sg1 : signal is "650 ps";
  attribute XIL_PAR_SKEW    of stg1_out_rise_sg1 : signal is "70 ps";
  attribute XIL_PAR_IP_NAME of stg1_out_rise_sg1 : signal is "MIG";
  attribute syn_keep        of stg1_out_rise_sg1 : signal is true;
  attribute KEEP            of stg1_out_rise_sg1 : signal is "TRUE";

  attribute XIL_PAR_DELAY   of stg1_out_fall_sg3 : signal is "500 ps";
  attribute XIL_PAR_SKEW    of stg1_out_fall_sg3 : signal is "55 ps";
  attribute XIL_PAR_IP_NAME of stg1_out_fall_sg3 : signal is "MIG";
  attribute syn_keep        of stg1_out_fall_sg3 : signal is true;
  attribute KEEP            of stg1_out_fall_sg3 : signal is "TRUE";
  attribute XIL_PAR_DELAY   of stg1_out_fall_sg2 : signal is "575 ps";
  attribute XIL_PAR_SKEW    of stg1_out_fall_sg2 : signal is "65 ps";
  attribute XIL_PAR_IP_NAME of stg1_out_fall_sg2 : signal is "MIG";
  attribute syn_keep        of stg1_out_fall_sg2 : signal is true;
  attribute KEEP            of stg1_out_fall_sg2 : signal is "TRUE";
  attribute XIL_PAR_DELAY   of stg1_out_fall_sg1 : signal is "650 ps";
  attribute XIL_PAR_SKEW    of stg1_out_fall_sg1 : signal is "70 ps";
  attribute XIL_PAR_IP_NAME of stg1_out_fall_sg1 : signal is "MIG";
  attribute syn_keep        of stg1_out_fall_sg1 : signal is true;
  attribute KEEP            of stg1_out_fall_sg1 : signal is "TRUE";

  attribute XIL_PAR_DELAY   of stg2b_out_fall : signal is "0 ps";
  attribute XIL_PAR_IP_NAME of stg2b_out_fall : signal is "MIG";
  attribute syn_keep        of stg2b_out_fall : signal is true;
  attribute KEEP            of stg2b_out_fall : signal is "TRUE";
  attribute XIL_PAR_DELAY   of stg2b_out_rise : signal is "0 ps";
  attribute XIL_PAR_IP_NAME of stg2b_out_rise : signal is "MIG";
  attribute syn_keep        of stg2b_out_rise : signal is true;
  attribute KEEP            of stg2b_out_rise : signal is "TRUE";

  attribute IODELAY_GROUP : string;
  attribute IODELAY_GROUP of u_idelay_dq : label is IODELAY_GRP;

begin

  --***************************************************************************
  -- Bidirectional I/O
  --***************************************************************************

  u_iobuf_dq : IOBUF
    port map (
      I   => dq_out,
      T   => dq_oe_n_r,
      IO  => ddr_dq,
      O   => dq_in
    );

  --***************************************************************************
  -- Write (output) path
  --***************************************************************************

  -- on a write, rising edge of DQS corresponds to rising edge of CLK180
  -- (aka falling edge of CLK0 -> rising edge DQS). We also know:
  --  1. data must be driven 1/4 clk cycle before corresponding DQS edge
  --  2. first rising DQS edge driven on falling edge of CLK0
  --  3. rising data must be driven 1/4 cycle before falling edge of CLK0
  --  4. therefore, rising data driven on rising edge of CLK
  u_oddr_dq : ODDR
    generic map (
      SRTYPE        => "SYNC",
      DDR_CLK_EDGE  => "SAME_EDGE"
      )
    port map (
      Q  => dq_out,
      C  => clk90,
      CE => '1',
      D1 => wr_data_rise,
      D2 => wr_data_fall,
      R  => '0',
      S  => '0'
      );

  -- make sure output is tri-state during reset (DQ_OE_N_R = 1)
  u_tri_state_dq : ODDR
    generic map (
      SRTYPE        => "ASYNC",
      DDR_CLK_EDGE  => "SAME_EDGE"
      )
    port map (
      Q  => dq_oe_n_r,
      C  => clk90,
      CE => '1',
      D1 => dq_oe_n(0),
      D2 => dq_oe_n(1),
      R  => '0',
      S  => rst90
      );

  --***************************************************************************
  -- Read data capture scheme description:
  -- Data capture consists of 3 ranks of flops, and a MUX
  --  1. Rank 1 ("Stage 1"): IDDR captures delayed DDR DQ from memory using
  --     delayed DQS.
  --     - Data is split into 2 SDR streams, one each for rise and fall data.
  --     - BUFIO (DQS) input inverted to IDDR. IDDR configured in SAME_EDGE
  --       mode. This means that: (1) Q1 = fall data, Q2 = rise data,
  --       (2) Both rise and fall data are output on falling edge of DQS -
  --       rather than rise output being output on one edge of DQS, and fall
  --       data on the other edge if the IDDR were configured in OPPOSITE_EDGE
  --       mode. This simplifies Stage 2 capture (only one core clock edge
  --       used, removing effects of duty-cycle-distortion), and saves one
  --       fabric flop in Rank 3.
  --  2. Rank 2 ("Stage 2"): Fabric flops are used to capture output of first
  --     rank into FPGA clock (CLK) domain. Each rising/falling SDR stream
  --     from IDDR is feed into two flops, one clocked off rising and one off
  --     falling edge of CLK. One of these flops is chosen, with the choice
  --     being the one that reduces # of DQ/DQS taps necessary to align Stage
  --     1 and Stage 2. Same edge is used to capture both rise and fall SDR
  --     streams.
  --  3. Rank 3 ("Stage 3"): Removes half-cycle paths in CLK domain from
  --     output of Rank 2. This stage, like Stage 2, is clocked by CLK. Note
  --     that Stage 3 can be expanded to also support SERDES functionality
  --  4. Output MUX: Selects whether Stage 1 output is aligned to rising or
  --     falling edge of CLK (i.e. specifically this selects whether IDDR
  --     rise/fall output is transfered to rising or falling edge of CLK).
  -- Implementation:
  --  1. Rank 1 is implemented using an IDDR primitive
  --  2. Rank 2 is implemented using:
  --     - An RPM to fix the location of the capture flops near the DQ I/O.
  --       The exact RPM used depends on which I/O column (left, center,
  --       right) the DQ I/O is placed at - this affects the optimal location
  --       of the slice flops (or does it - can we always choose the two
  --       columns to slices to the immediate right of the I/O to use, no
  --       matter what the column?). The origin of the RPM must be set in the
  --       UCF file using the RLOC_ORIGIN constraint (where the original is
  --       based on the DQ I/O location).
  --     - Directed Routing Constraints ("DIRT strings") to fix the routing
  --       to the rank 2 fabric flops. This is done to minimize: (1) total
  --       route delay (and therefore minimize voltage/temperature-related
  --       variations), and (2) minimize skew both within each rising and
  --       falling data net, as well as between the rising and falling nets.
  --       The exact DIRT string used depends on: (1) which I/O column the
  --       DQ I/O is placed, and (2) whether the DQ I/O is placed on the
  --       "Master" or "Slave" I/O of a diff pair (DQ is not differential, but
  --       the routing will be affected by which of each I/O pair is used)
  -- 3. Rank 3 is implemented using fabric flops. No LOC or DIRT contraints
  --    are used, tools are expected to place these and meet PERIOD timing
  --    without constraints (constraints may be necessary for "full" designs,
  --    in this case, user may need to add LOC constraints - if this is the
  --    case, there are no constraints - other than meeting PERIOD timing -
  --    for rank 3 flops.
  --***************************************************************************

  --***************************************************************************
  -- MIG 2.2: Define AREA_GROUP = "DDR_CAPTURE_FFS" contain all RPM flops in
  --          design. In UCF file, add constraint:
  --             AREA_GROUP "DDR_CAPTURE_FFS" GROUP = CLOSED;
  --          This is done to prevent MAP from packing unrelated logic into
  --          the slices used by the RPMs. Doing so may cause the DIRT strings
  --          that define the IDDR -> fabric flop routing to later become
  --          unroutable during PAR because the unrelated logic placed by MAP
  --          may use routing resources required by the DIRT strings. MAP
  --          does not currently take into account DIRT strings when placing
  --          logic
  --***************************************************************************

  -- IDELAY to delay incoming data for synchronization purposes
  u_idelay_dq : IODELAY
    generic map (
      DELAY_SRC             => "I",
      IDELAY_TYPE           => "VARIABLE",
      HIGH_PERFORMANCE_MODE => HIGH_PERFORMANCE_MODE,
      IDELAY_VALUE          => 0,
      ODELAY_VALUE          => 0
      )
    port map (
      DATAOUT => dq_idelay,
      C       => clkdiv0,
      CE      => dlyce,
      DATAIN  => '0',
      IDATAIN => dq_in,
      INC     => dlyinc,
      ODATAIN => '0',
      RST     => dlyrst,
      T       => '0'
      );

  --***************************************************************************
  -- Rank 1 capture: Use IDDR to generate two SDR outputs
  --***************************************************************************

  -- invert clock to IDDR in order to use SAME_EDGE mode (otherwise, we "run
  -- out of clocks" because DQS is not continuous
  dq_iddr_clk <= not(dqs);

  --***************************************************************************
  -- Rank 2 capture: Use fabric flops to capture Rank 1 output. Use RPM and
  -- DIRT strings here.
  -- BEL ("Basic Element of Logic") and relative location constraints for
  -- second stage capture. C
  -- Varies according:
  --  (1) I/O column (left, center, right) used
  --  (2) Which I/O in I/O pair (master, slave) used
  --***************************************************************************

  -- MODIFIED, RC, 06/13/08: Remove all references to DIRT, master/slave
  --  Take out generate statements - collapses to a single case

  gen_stg2_sg3: if (FPGA_SPEED_GRADE = 3) generate

    attribute syn_preserve  of u_ff_stg2a_fall : label is true;
    attribute syn_replicate of u_ff_stg2a_fall : label is false;
    attribute syn_preserve  of u_ff_stg2a_rise : label is true;
    attribute syn_replicate of u_ff_stg2a_rise : label is false;
    attribute syn_preserve  of u_ff_stg3b_fall : label is true;
    attribute syn_replicate of u_ff_stg3b_fall : label is false;
    attribute syn_preserve  of u_ff_stg3b_rise : label is true;
    attribute syn_replicate of u_ff_stg3b_rise : label is false;
    attribute syn_preserve  of u_ff_stg2b_fall : label is true;
    attribute syn_replicate of u_ff_stg2b_fall : label is false;
    attribute syn_preserve  of u_ff_stg2b_rise : label is true;
    attribute syn_replicate of u_ff_stg2b_rise : label is false;

  begin
    u_iddr_dq : IDDR
      generic map (
        DDR_CLK_EDGE  => "SAME_EDGE"
        )
      port map (
        Q1 => stg1_out_fall_sg3,
        Q2 => stg1_out_rise_sg3,
        C  => dq_iddr_clk,
        CE => ce,
        D  => dq_idelay,
        R  => '0',
        S  => '0'
        );

    --*********************************************************
    -- Slice #1 (posedge CLK): Used for:
    --  1. IDDR transfer to CLK0 rising edge domain ("stg2a")
    --  2. stg2 falling edge -> stg3 rising edge transfer
    --*********************************************************

    -- Stage 2 capture
    u_ff_stg2a_fall : FDRSE
      port map (
        Q    => stg2a_out_fall,
        C    => clk0,
        CE   => '1',
        D    => stg1_out_fall_sg3,
        R    => '0',
        S    => '0'
        );
    u_ff_stg2a_rise : FDRSE
      port map (
        Q    => stg2a_out_rise,
        C    => clk0,
        CE   => '1',
        D    => stg1_out_rise_sg3,
        R    => '0',
        S    => '0'
        );
    -- Stage 3 falling -> rising edge translation
    u_ff_stg3b_fall : FDRSE
      port map (
        Q    => stg3b_out_fall,
        C    => clk0,
        CE   => '1',
        D    => stg2b_out_fall,
        R    => '0',
        S    => '0'
        );
    u_ff_stg3b_rise : FDRSE
      port map (
        Q    => stg3b_out_rise,
        C    => clk0,
        CE   => '1',
        D    => stg2b_out_rise,
        R    => '0',
        S    => '0'
        );

    --*********************************************************
    -- Slice #2 (posedge CLK): Used for:
    --  1. IDDR transfer to CLK0 falling edge domain ("stg2b")
    --*********************************************************

    u_ff_stg2b_fall : FDRSE_1
      port map (
        Q    => stg2b_out_fall,
        C    => clk0,
        CE   => '1',
        D    => stg1_out_fall_sg3,
        R    => '0',
        S    => '0'
        );

    u_ff_stg2b_rise : FDRSE_1
      port map (
        Q    => stg2b_out_rise,
        C    => clk0,
        CE   => '1',
        D    => stg1_out_rise_sg3,
        R    => '0',
        S    => '0'
        );

  end generate;

  gen_stg2_sg2: if (FPGA_SPEED_GRADE = 2) generate

    attribute syn_preserve  of u_ff_stg2a_fall : label is true;
    attribute syn_replicate of u_ff_stg2a_fall : label is false;
    attribute syn_preserve  of u_ff_stg2a_rise : label is true;
    attribute syn_replicate of u_ff_stg2a_rise : label is false;
    attribute syn_preserve  of u_ff_stg3b_fall : label is true;
    attribute syn_replicate of u_ff_stg3b_fall : label is false;
    attribute syn_preserve  of u_ff_stg3b_rise : label is true;
    attribute syn_replicate of u_ff_stg3b_rise : label is false;
    attribute syn_preserve  of u_ff_stg2b_fall : label is true;
    attribute syn_replicate of u_ff_stg2b_fall : label is false;
    attribute syn_preserve  of u_ff_stg2b_rise : label is true;
    attribute syn_replicate of u_ff_stg2b_rise : label is false;

  begin
    u_iddr_dq : IDDR
      generic map (
        DDR_CLK_EDGE  => "SAME_EDGE"
        )
      port map (
        Q1 => stg1_out_fall_sg2,
        Q2 => stg1_out_rise_sg2,
        C  => dq_iddr_clk,
        CE => ce,
        D  => dq_idelay,
        R  => '0',
        S  => '0'
        );

    --*********************************************************
    -- Slice #1 (posedge CLK): Used for:
    --  1. IDDR transfer to CLK0 rising edge domain ("stg2a")
    --  2. stg2 falling edge -> stg3 rising edge transfer
    --*********************************************************

    -- Stage 2 capture
    u_ff_stg2a_fall : FDRSE
      port map (
        Q    => stg2a_out_fall,
        C    => clk0,
        CE   => '1',
        D    => stg1_out_fall_sg2,
        R    => '0',
        S    => '0'
        );
    u_ff_stg2a_rise : FDRSE
      port map (
        Q    => stg2a_out_rise,
        C    => clk0,
        CE   => '1',
        D    => stg1_out_rise_sg2,
        R    => '0',
        S    => '0'
        );
    -- Stage 3 falling -> rising edge translation
    u_ff_stg3b_fall : FDRSE
      port map (
        Q    => stg3b_out_fall,
        C    => clk0,
        CE   => '1',
        D    => stg2b_out_fall,
        R    => '0',
        S    => '0'
        );
    u_ff_stg3b_rise : FDRSE
      port map (
        Q    => stg3b_out_rise,
        C    => clk0,
        CE   => '1',
        D    => stg2b_out_rise,
        R    => '0',
        S    => '0'
        );

    --*********************************************************
    -- Slice #2 (posedge CLK): Used for:
    --  1. IDDR transfer to CLK0 falling edge domain ("stg2b")
    --*********************************************************

    u_ff_stg2b_fall : FDRSE_1
      port map (
        Q    => stg2b_out_fall,
        C    => clk0,
        CE   => '1',
        D    => stg1_out_fall_sg2,
        R    => '0',
        S    => '0'
        );

    u_ff_stg2b_rise : FDRSE_1
      port map (
        Q    => stg2b_out_rise,
        C    => clk0,
        CE   => '1',
        D    => stg1_out_rise_sg2,
        R    => '0',
        S    => '0'
        );

  end generate;

  gen_stg2_sg1: if (FPGA_SPEED_GRADE = 1) generate

    attribute syn_preserve  of u_ff_stg2a_fall : label is true;
    attribute syn_replicate of u_ff_stg2a_fall : label is false;
    attribute syn_preserve  of u_ff_stg2a_rise : label is true;
    attribute syn_replicate of u_ff_stg2a_rise : label is false;
    attribute syn_preserve  of u_ff_stg3b_fall : label is true;
    attribute syn_replicate of u_ff_stg3b_fall : label is false;
    attribute syn_preserve  of u_ff_stg3b_rise : label is true;
    attribute syn_replicate of u_ff_stg3b_rise : label is false;
    attribute syn_preserve  of u_ff_stg2b_fall : label is true;
    attribute syn_replicate of u_ff_stg2b_fall : label is false;
    attribute syn_preserve  of u_ff_stg2b_rise : label is true;
    attribute syn_replicate of u_ff_stg2b_rise : label is false;

  begin
    u_iddr_dq : IDDR
      generic map (
        DDR_CLK_EDGE  => "SAME_EDGE"
        )
      port map (
        Q1 => stg1_out_fall_sg1,
        Q2 => stg1_out_rise_sg1,
        C  => dq_iddr_clk,
        CE => ce,
        D  => dq_idelay,
        R  => '0',
        S  => '0'
        );

    --*********************************************************
    -- Slice #1 (posedge CLK): Used for:
    --  1. IDDR transfer to CLK0 rising edge domain ("stg2a")
    --  2. stg2 falling edge -> stg3 rising edge transfer
    --*********************************************************

    -- Stage 2 capture
    u_ff_stg2a_fall : FDRSE
      port map (
        Q    => stg2a_out_fall,
        C    => clk0,
        CE   => '1',
        D    => stg1_out_fall_sg1,
        R    => '0',
        S    => '0'
        );
    u_ff_stg2a_rise : FDRSE
      port map (
        Q    => stg2a_out_rise,
        C    => clk0,
        CE   => '1',
        D    => stg1_out_rise_sg1,
        R    => '0',
        S    => '0'
        );
    -- Stage 3 falling -> rising edge translation
    u_ff_stg3b_fall : FDRSE
      port map (
        Q    => stg3b_out_fall,
        C    => clk0,
        CE   => '1',
        D    => stg2b_out_fall,
        R    => '0',
        S    => '0'
        );
    u_ff_stg3b_rise : FDRSE
      port map (
        Q    => stg3b_out_rise,
        C    => clk0,
        CE   => '1',
        D    => stg2b_out_rise,
        R    => '0',
        S    => '0'
        );

    --*********************************************************
    -- Slice #2 (posedge CLK): Used for:
    --  1. IDDR transfer to CLK0 falling edge domain ("stg2b")
    --*********************************************************

    u_ff_stg2b_fall : FDRSE_1
      port map (
        Q    => stg2b_out_fall,
        C    => clk0,
        CE   => '1',
        D    => stg1_out_fall_sg1,
        R    => '0',
        S    => '0'
        );

    u_ff_stg2b_rise : FDRSE_1
      port map (
        Q    => stg2b_out_rise,
        C    => clk0,
        CE   => '1',
        D    => stg1_out_rise_sg1,
        R    => '0',
        S    => '0'
        );

  end generate;

  --***************************************************************************
  -- Second stage flops clocked by posedge CLK0 don't need another layer of
  -- registering
  --***************************************************************************

  stg3a_out_rise <= stg2a_out_rise;
  stg3a_out_fall <= stg2a_out_fall;

  --*******************************************************************

  rd_data_rise <= stg3a_out_rise when (rd_data_sel = '1') else
                  stg3b_out_rise;
  rd_data_fall <= stg3a_out_fall when (rd_data_sel = '1') else
                  stg3b_out_fall;

end architecture syn;


