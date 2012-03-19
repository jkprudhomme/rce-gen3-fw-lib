--------------------------------------------------------------------------------
-- xuart.vhd - entity/architecture pair
--------------------------------------------------------------------------------
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
--  **  Copyright 2007, 2008, 2009 Xilinx, Inc.                              **
--  **  All rights reserved.                                                 **
--  **                                                                       **
--  **  This disclaimer and copyright notice must be retained as part        **
--  **  of this file at all times.                                           **
--  ***************************************************************************
-------------------------------------------------------------------------------
-- Filename:        xuart.vhd
-- Version:         v3.00a
-- Description:     This module instantiates the uart 16550 core , 
--                  plbv46_slave_single.vhd and ipic_if.vhd modules
--                                        
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
-- Structure:   
--                  xps_uart16550.vhd
--                      -- xuart.vhd
--                          -- plbv46_slave_single.vhd
--                          -- ipic_if.vhd
--                          -- uart16550.vhd
--                              -- rx16550.vhd
--                              -- tx16550.vhd
--                              -- xuart_tx_load_sm.vhd
--                              -- tx_fifo_block.vhd
--                              -- rx_fifo_block.vhd
--                                  -- rx_fifo_control.vhd
-------------------------------------------------------------------------------
-- ~~~~~~~
--   BSB                9/22/06
-- ^^^^^^^
--  First version of xuart
--  PLBV46 single slave ipif added and code cleanup
-- ~~~~~~~
--  USM                02/26/08
-- ^^^^^^^
--  Modified for CR:446943.
-- ~~~~~~~
--  PVK                08/28/08     v2.01.a
-- ^^^^^^^
--     Updated helper libraries proc_common_v2_00_a to proc_common_v3_00_a and
--     plbv46_slave_single_v1_00_a to plbv46_slave_single_v1_01_a.
-- ~~~~~~~
--  PVK                05/25/09     
-- ^^^^^^^
--  Updated to new version v3.00.a 
-- ~~~~~~~
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x" 
--      reset signals:                          "rst", "rst_n" 
--      generics:                               "C_*" 
--      user defined types:                     "*_TYPE" 
--      state machine next state:               "*_ns" 
--      state machine current state:            "*_cs" 
--      combinatorial signals:                  "*_cmb" 
--      pipelined or register delay signals:    "*_d#" 
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce" 
--      internal version of output port         "*_i"
--      device pins:                            "*_pin" 
--      ports:                                  - Names begin with Uppercase 
--      processes:                              "*_PROCESS" 
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
-- proc common package of the proc common library is used for different 
-- function declarations
-------------------------------------------------------------------------------
library proc_common_v3_00_a;
use proc_common_v3_00_a.ipif_pkg.SLV64_ARRAY_TYPE;
use proc_common_v3_00_a.ipif_pkg.INTEGER_ARRAY_TYPE;

-------------------------------------------------------------------------------
-- xps_uart16550_v3_00_a library is used for xps_uart16550_v3_00_a 
-- component declarations
-------------------------------------------------------------------------------
library xps_uart16550_v3_00_a;
use xps_uart16550_v3_00_a.uart16550;
use xps_uart16550_v3_00_a.ipic_if;

-------------------------------------------------------------------------------
-- plbv46_slave_single_v1_01_a library is used for plbv46_slave_single 
-- component declarations
-------------------------------------------------------------------------------
library plbv46_slave_single_v1_01_a; 
use plbv46_slave_single_v1_01_a.plbv46_slave_single;

-------------------------------------------------------------------------------
-- Definition of Generics:
--  C_BASEADDR              -- XPS UART Base Address
--  C_HIGHADDR              -- XPS UART High Address
--  C_IS_A_16550            -- Selection of UART for 16450 or 16550 mode
--  C_HAS_EXTERNAL_XIN      -- External XIN
--  C_HAS_EXTERNAL_RCLK     -- External RCLK
--  C_SPLB_AWIDTH           -- Width of the PLB Least significant address bus
--  C_SPLB_DWIDTH           -- width of the PLB data bus
--  C_SPLB_P2P              -- Selects point to point or shared topology
--  C_SPLB_MID_WIDTH        -- PLB Master ID bus width
--  C_SPLB_NUM_MASTERS      -- Number of PLB masters 
--  C_SPLB_NATIVE_DWIDTH    -- Slave bus data width
--  C_SPLB_SUPPORTS_BURST   -- Burst/no burst support
--  C_FAMILY                -- XILINX FPGA family
-------------------------------------------------------------------------------

-- Definition of ports:
--   PLB Slave Signals 
--  PLB_ABus                -- PLB address bus
--  PLB_UABus               -- PLB upper address bus
--  PLB_PAValid             -- PLB primary address valid
--  PLB_SAValid             -- PLB secondary address valid
--  PLB_rdPrim              -- PLB secondary to primary read request
--  PLB_wrPrim              -- PLB secondary to primary write request
--  PLB_masterID            -- PLB current master identifier
--  PLB_abort               -- PLB abort request
--  PLB_busLock             -- PLB bus lock
--  PLB_RNW                 -- PLB read not write
--  PLB_BE                  -- PLB byte enable
--  PLB_MSize               -- PLB data bus width indicator
--  PLB_size                -- PLB transfer size
--  PLB_type                -- PLB transfer type
--  PLB_lockErr             -- PLB lock error
--  PLB_wrDBus              -- PLB write data bus
--  PLB_wrBurst             -- PLB burst write transfer
--  PLB_rdBurst             -- PLB burst read transfer
--  PLB_wrPendReq           -- PLB pending bus write request
--  PLB_rdPendReq           -- PLB pending bus read request
--  PLB_wrPendPri           -- PLB pending bus write request priority
--  PLB_rdPendPri           -- PLB pending bus read request priority
--  PLB_reqPri              -- PLB current request 
--  PLB_TAttribute          -- PLB transfer attribute
--   Slave Responce Signal
--  Sl_addrAck              --  Salve address ack
--  Sl_SSize                --  Slave data bus size
--  Sl_wait                 --  Salve wait indicator
--  Sl_rearbitrate          --  Salve rearbitrate
--  Sl_wrDAck               --  Slave write data ack
--  Sl_wrComp               --  Salve write complete
--  Sl_wrBTerm              --  Salve terminate write burst transfer
--  Sl_rdDBus               --  Slave read data bus
--  Sl_rdWdAddr             --  Slave read word address
--  Sl_rdDAck               --  Salve read data ack
--  Sl_rdComp               --  Slave read complete
--  Sl_rdBTerm              --  Salve terminate read burst transfer
--  Sl_MBusy                --  Slave busy
--  Sl_MWrErr               --  Slave write error
--  Sl_MRdErr               --  Slave read error
--  Sl_MIRQ                 --  Master interrput 
--   UART Signals
--  BaudoutN                -- Transmitter Clock
--  Rclk                    -- Receiver 16x Clock
--  Sin                     -- Serial Data Input
--  Sout                    -- Serial Data Output
--  Xin                     -- Baud Rate Generator reference clock
--  Xout                    -- Inverted XIN
--  CtsN                    -- Clear To Send (active low)
--  DcdN                    -- Data Carrier Detect (active low)
--  DsrN                    -- Data Set Ready (active low)
--  DtrN                    -- Data Terminal Ready (active low)
--  RiN                     -- Ring Indicator (active low)
--  RtsN                    -- Request To Send (active low)
--  Ddis                    -- Driver Disable
--  Out1N                   -- User controlled output1
--  Out2N                   -- User controlled output2
--  RxrdyN                  -- DMA control signal
--  TxrdyN                  -- DMA control signal
--
--   System Signals
--  PLB_Clk                 -- System clock
--  PLB_Rst                 -- System Reset (active high)
--  Freeze                  -- Freezes UART for software debug (active high)
--  IP2INTC_Irpt            -- Device interrupt output to microprocessor 
                            -- interrupt input or system interrupt controller.
-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------

entity xuart is
  
  generic (
    C_BASEADDR              : std_logic_vector;
    C_HIGHADDR              : std_logic_vector;
    C_IS_A_16550            : boolean;
    C_HAS_EXTERNAL_XIN      : boolean;
    C_HAS_EXTERNAL_RCLK     : boolean;
    C_SPLB_AWIDTH           : integer;
    C_SPLB_DWIDTH           : integer;
    C_SPLB_P2P              : integer;
    C_SPLB_MID_WIDTH        : integer;
    C_SPLB_NUM_MASTERS      : integer;
    C_SPLB_NATIVE_DWIDTH    : integer;    
    C_FAMILY                : string);
   port (
    SPLB_Clk                : in std_logic;
    SPLB_Rst                : in std_logic;
    PLB_ABus                : in  std_logic_vector(0 to 31);
    PLB_UABus               : in  std_logic_vector(0 to 31);
    PLB_PAValid             : in  std_logic;
    PLB_SAValid             : in  std_logic;
    PLB_rdPrim              : in  std_logic;
    PLB_wrPrim              : in  std_logic;
    PLB_masterID            : in  std_logic_vector(0 to C_SPLB_MID_WIDTH-1);
    PLB_abort               : in  std_logic;
    PLB_busLock             : in  std_logic;
    PLB_RNW                 : in  std_logic;
    PLB_BE                  : in  std_logic_vector(0 to(C_SPLB_DWIDTH/8) - 1);
    PLB_MSize               : in  std_logic_vector(0 to 1);
    PLB_size                : in  std_logic_vector(0 to 3);
    PLB_type                : in  std_logic_vector(0 to 2);
    PLB_lockErr             : in  std_logic;
    PLB_wrDBus              : in  std_logic_vector(0 to C_SPLB_DWIDTH-1);
    PLB_wrBurst             : in  std_logic;
    PLB_rdBurst             : in  std_logic;   
    PLB_wrPendReq           : in  std_logic; 
    PLB_rdPendReq           : in  std_logic; 
    PLB_wrPendPri           : in  std_logic_vector(0 to 1); 
    PLB_rdPendPri           : in  std_logic_vector(0 to 1); 
    PLB_reqPri              : in  std_logic_vector(0 to 1);
    PLB_TAttribute          : in  std_logic_vector(0 to 15); 
         
    -- Slave Responce Signals
    Sl_addrAck              : out std_logic;
    Sl_SSize                : out std_logic_vector(0 to 1);
    Sl_wait                 : out std_logic;
    Sl_rearbitrate          : out std_logic;
    Sl_wrDAck               : out std_logic;
    Sl_wrComp               : out std_logic;
    Sl_wrBTerm              : out std_logic;
    Sl_rdDBus               : out std_logic_vector(0 to C_SPLB_DWIDTH-1);
    Sl_rdWdAddr             : out std_logic_vector(0 to 3);
    Sl_rdDAck               : out std_logic;
    Sl_rdComp               : out std_logic;
    Sl_rdBTerm              : out std_logic;
    Sl_MBusy                : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
    Sl_MWrErr               : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);                   
    Sl_MRdErr               : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);                   
    Sl_MIRQ                 : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
    BaudoutN                : out std_logic;
    CtsN                    : in  std_logic;
    DcdN                    : in  std_logic;
    Ddis                    : out std_logic;
    DsrN                    : in  std_logic;
    DtrN                    : out std_logic;
    Out1N                   : out std_logic;
    Out2N                   : out std_logic;
    Rclk                    : in  std_logic;
    RiN                     : in  std_logic;
    RtsN                    : out std_logic;
    RxrdyN                  : out std_logic;
    Sin                     : in  std_logic;
    Sout                    : out std_logic;
    IP2INTC_Irpt            : out std_logic;
    TxrdyN                  : out std_logic;
    Xin                     : in  std_logic;
    Xout                    : out std_logic;
    Freeze                  : in  std_logic;
    Intr                    : out std_logic
    );

end xuart;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------
architecture imp of xuart is

  -----------------------------------------------------------------------------
    -- Constant Declarations
  -----------------------------------------------------------------------------
  constant  ZEROES                : std_logic_vector := X"00000000";
  constant  INCLUDE_DPHASE_TIMER  : integer := 1;
  constant  BUS2CORE_CLK_RATIO    : integer := 1;

  
  constant UART_REG_BASEADDR  : std_logic_vector  := C_BASEADDR or X"00001000";
  constant UART_REG_HIGHADDR  : std_logic_vector  := C_BASEADDR or X"0000101F";
 
  constant ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE  :=
        (
         ZEROES & UART_REG_BASEADDR,              -- Uart Reg Base Address
         ZEROES & UART_REG_HIGHADDR               -- Uart Reg High Address
        );

  constant ARD_NUM_CE_ARRAY     : INTEGER_ARRAY_TYPE :=
          (
           0 => 1   
          );

  -----------------------------------------------------------------------------
    -- Signal and Type Declarations
  -----------------------------------------------------------------------------
  -- signal ip2Bus_IntrEvent : std_logic_vector(0 to 0);
  signal rd               : std_logic;
  signal wr               : std_logic;
  signal baudoutN_int     : std_logic;
  signal rclk_int         : std_logic;
  signal uart_intr        : std_logic;
  signal xin_int          : std_logic;
  signal bus2ip_clk_i     : std_logic;
  signal bus2ip_cs_i      : std_logic;
  signal bus2ip_data_i    : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH-1);
  signal bus2ip_addr_i    : std_logic_vector(0 to C_SPLB_AWIDTH-1);
  signal bus2ip_reset_i   : std_logic;
  signal ip2bus_data_i    : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH-1);
  signal bus2ip_rdce_i    : std_logic_vector(0 to 0);
  signal bus2ip_wrce_i    : std_logic_vector(0 to 0);
  signal bus2ip_rdreq_i   : std_logic;
  signal bus2ip_wrreq_i   : std_logic;
  signal ip2bus_wrack_i   : std_logic;
  signal ip2bus_rdack_i   : std_logic;
  signal ip2bus_error_i   : std_logic;
 
  -----------------------------------------------------------------------------
    -- Begin Architecture
  -----------------------------------------------------------------------------
    
  begin
  
  -----------------------------------------------------------------------------
  -- Component Instantiations
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
    -- Entity UART instantiation
  -----------------------------------------------------------------------------
       
   UART16550_I_1 : entity xps_uart16550_v3_00_a.uart16550
    generic map (
      C_FAMILY           => C_FAMILY, 
      C_IS_A_16550       => C_IS_A_16550,
      C_HAS_EXTERNAL_XIN => C_HAS_EXTERNAL_XIN)
    port map (
      Din          => bus2ip_data_i(C_SPLB_NATIVE_DWIDTH-8 to 
                                                       C_SPLB_NATIVE_DWIDTH-1),
      Dout         => ip2bus_data_i(C_SPLB_NATIVE_DWIDTH-8 to 
                                                       C_SPLB_NATIVE_DWIDTH-1),
      Sout         => Sout,
      BaudoutN     => BaudoutN,
      BaudoutN_int => baudoutN_int, 
      Intr         => uart_intr,
      Ddis         => Ddis,
      TxrdyN       => TxrdyN,
      RxrdyN       => RxrdyN,
      Xout         => Xout,
      RtsN         => RtsN,
      DtrN         => DtrN,
      Out1N        => Out1N,
      Out2N        => Out2N,
      Addr         => bus2ip_addr_i(27 to 29),
      Cs0          => bus2ip_cs_i,
      Cs1          => '1',
      Cs2N         => '0',
      AdsN         => '0',
      Sin          => Sin,
      Rclk         => rclk_int,
      Xin          => xin_int,
      Rd           => rd,
      RdN          => '1',
      Wr           => wr,
      WrN          => '1',
      Rst          => bus2ip_reset_i,
      CtsN         => CtsN,
      DcdN         => DcdN,
      DsrN         => DsrN,
      RiN          => RiN,
      Freeze       => Freeze,
      Sys_clk      => SPLB_Clk);

  ip2bus_data_i(0 to C_SPLB_NATIVE_DWIDTH-9) <= (others => '0');
  IP2INTC_Irpt  <= uart_intr;  
  Intr          <= uart_intr;



  -----------------------------------------------------------------------------
    -- Entity IPIC_IC instantiation
  -----------------------------------------------------------------------------
  
  IPIC_IF_I_1 : entity xps_uart16550_v3_00_a.ipic_if 
    port map
       (
       Bus2IP_Clk                => bus2ip_clk_i,
       Bus2IP_Reset              => bus2ip_reset_i,
       Bus2IP_RdCE               => bus2ip_rdce_i(0),
       Bus2IP_WrCE               => bus2ip_wrce_i(0),
       Bus2IP_RdReq              => bus2ip_rdreq_i,
       Bus2IP_WrReq              => bus2ip_wrreq_i,
       Wr                        => wr,
       Rd                        => rd,
                                 
       -- IPIF signals           
       IP2Bus_WrAcknowledge      => ip2bus_wrack_i,
       IP2Bus_RdAcknowledge      => ip2bus_rdack_i,
       IP2Bus_Error              => ip2bus_error_i,
       IP2Bus_Retry              => open,
       IP2Bus_ToutSup            => open
       );
  
 PLBV46_I : entity plbv46_slave_single_v1_01_a.plbv46_slave_single
    generic map
    (
      C_ARD_ADDR_RANGE_ARRAY     => ARD_ADDR_RANGE_ARRAY,
      C_ARD_NUM_CE_ARRAY         => ARD_NUM_CE_ARRAY,
      C_SPLB_P2P                 => C_SPLB_P2P,
      C_SPLB_MID_WIDTH           => C_SPLB_MID_WIDTH,
      C_SPLB_NUM_MASTERS         => C_SPLB_NUM_MASTERS,
      C_SPLB_AWIDTH              => C_SPLB_AWIDTH,
      C_SPLB_DWIDTH              => C_SPLB_DWIDTH,
      C_SIPIF_DWIDTH             => C_SPLB_NATIVE_DWIDTH,
      C_INCLUDE_DPHASE_TIMER     => INCLUDE_DPHASE_TIMER,
      C_BUS2CORE_CLK_RATIO       => BUS2CORE_CLK_RATIO,
      C_FAMILY                   => C_FAMILY
    )
    port map
    (
    -- System signals
      
      SPLB_Clk                   => SPLB_Clk,
      SPLB_Rst                   => SPLB_Rst,

    -- Bus Slave signals
      PLB_ABus                   => PLB_ABus,
      PLB_UABus                  => PLB_UABus,
      PLB_PAValid                => PLB_PAValid,
      PLB_SAValid                => PLB_SAValid,
      PLB_rdPrim                 => PLB_rdPrim, 
      PLB_wrPrim                 => PLB_wrPrim,
      PLB_masterID               => PLB_masterID,
      PLB_abort                  => PLB_abort,
      PLB_busLock                => PLB_busLock, 
      PLB_RNW                    => PLB_RNW,
      PLB_BE                     => PLB_BE, 
      PLB_MSize                  => PLB_MSize,
      PLB_size                   => PLB_size, 
      PLB_type                   => PLB_type,
      PLB_lockErr                => PLB_lockErr, 
      PLB_wrDBus                 => PLB_wrDBus,
      PLB_wrBurst                => PLB_wrBurst, 
      PLB_rdBurst                => PLB_rdBurst,
      PLB_wrPendReq              => PLB_wrPendReq, 
      PLB_rdPendReq              => PLB_rdPendReq,
      PLB_wrPendPri              => PLB_wrPendPri, 
      PLB_rdPendPri              => PLB_rdPendPri,
      PLB_reqPri                 => PLB_reqPri, 
      PLB_TAttribute             => PLB_TAttribute,
    -- Slave Response Signals
      Sl_addrAck                 => Sl_addrAck,   
      Sl_SSize                   => Sl_SSize,  
      Sl_wait                    => Sl_wait,
      Sl_rearbitrate             => Sl_rearbitrate,
      Sl_wrDAck                  => Sl_wrDAck, 
      Sl_wrComp                  => Sl_wrComp,
      Sl_wrBTerm                 => Sl_wrBTerm,
      Sl_rdDBus                  => Sl_rdDBus,
      Sl_rdWdAddr                => Sl_rdWdAddr,
      Sl_rdDAck                  => Sl_rdDAck,
      Sl_rdComp                  => Sl_rdComp, 
      Sl_rdBTerm                 => Sl_rdBTerm,
      Sl_MBusy                   => Sl_MBusy,
      Sl_MWrErr                  => Sl_MWrErr,
      Sl_MRdErr                  => Sl_MRdErr, 
      Sl_MIRQ                    => Sl_MIRQ,
    -- IP Interconnect (IPIC) port signals
      Bus2IP_Clk                 => bus2ip_clk_i,   
      Bus2IP_Reset               => bus2ip_reset_i, 
      Bus2IP_Addr                => bus2ip_addr_i,   
      Bus2IP_Data                => bus2ip_data_i,
      Bus2IP_RNW                 => open,   
      Bus2IP_BE                  => open,    
      Bus2IP_CS                  => open,
      Bus2IP_RdCE                => bus2ip_rdce_i, 
      Bus2IP_WrCE                => bus2ip_wrce_i,
      IP2Bus_Data                => ip2bus_data_i,
      IP2Bus_WrAck               => ip2bus_wrack_i,
      IP2Bus_RdAck               => ip2bus_rdack_i,
      IP2Bus_Error               => ip2bus_error_i
    );

  -----------------------------------------------------------------------------
  -- GENERATING_EXTERNAL_RCLK : Synchronize Rclk clock with system clock if 
  -- external receive clock is selected.
  -----------------------------------------------------------------------------
  GENERATING_EXTERNAL_RCLK : if C_HAS_EXTERNAL_RCLK = TRUE generate

    signal rclk_d1 : std_logic;
    signal rclk_d2 : std_logic;

  begin
  
    ---------------------------------------------------------------------------
     -- purpose: detects rising edge of Rclk
     -- type   : sequential
     -- inputs : SPLB_Clk, Rclk
    ---------------------------------------------------------------------------
    RCLK_RISING_EDGE : process (SPLB_Clk) is
      begin  -- process RCLK_RISING_EDGE
        if SPLB_Clk'event and SPLB_Clk = '1' then  -- rising clock edge
          rclk_d1 <= Rclk;
          rclk_d2 <= rclk_d1;
      end if;
    end process RCLK_RISING_EDGE;
    
    rclk_int <= rclk_d1 and (not rclk_d2) and (not SPLB_Rst);
  end generate GENERATING_EXTERNAL_RCLK;

  -----------------------------------------------------------------------------
  -- NOT_GENERATING_EXTERNAL_RCLK : If external receive clock is not available,
  -- use baudoutN_int as a receive clock
  -----------------------------------------------------------------------------
  NOT_GENERATING_EXTERNAL_RCLK : if C_HAS_EXTERNAL_RCLK /= TRUE generate
  begin
    rclk_int <= not baudoutN_int;
  end generate NOT_GENERATING_EXTERNAL_RCLK;

  -----------------------------------------------------------------------------
  -- GENERATING_EXTERNAL_XIN : Synchronize Xin clock with system clock if 
  -- external Xin clock is selected.
  -----------------------------------------------------------------------------
  GENERATING_EXTERNAL_XIN : if C_HAS_EXTERNAL_XIN = TRUE generate

    signal xin_d1 : std_logic;
    signal xin_d2 : std_logic;

  begin
  
    ---------------------------------------------------------------------------
    -- purpose: detects rising edge of xin
    -- Type   : sequential
    -- inputs : SPLB_Clk, xin
    -- outputs: xin_rising
    ---------------------------------------------------------------------------
    XIN_RISING_EDGE : process (SPLB_Clk) is
    begin  -- process XIN_RISING_EDGE
      if SPLB_Clk'event and SPLB_Clk = '1' then  -- rising clock edge
        if SPLB_Rst = '1' then           -- asynchronous reset (active high)
          xin_d1 <= '0';
          xin_d2 <= '0';
        else
          xin_d1 <= Xin;
          xin_d2 <= xin_d1;
        end if;
      end if;
    end process XIN_RISING_EDGE;
    xin_int <= xin_d1 and (not xin_d2);  -- inverted to make baudoutN
  end generate GENERATING_EXTERNAL_XIN;

  -----------------------------------------------------------------------------
  -- NOT_GENERATING_EXTERNAL_XIN : If external xin clock is not available,
  -- drive xin_int with '1'. 
  -----------------------------------------------------------------------------
  NOT_GENERATING_EXTERNAL_XIN : if C_HAS_EXTERNAL_XIN /= TRUE generate
  begin
    xin_int <= '1';                      -- xin in always active
  end generate NOT_GENERATING_EXTERNAL_XIN;
  
  bus2ip_cs_i <= bus2ip_rdreq_i or bus2ip_wrreq_i;  

end imp;
