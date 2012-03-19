-------------------------------------------------------------------------------
-- xps_uart16550.vhd - entity/architecture pair
-------------------------------------------------------------------------------
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
-- Filename:        xps_uart16550.vhd
-- Version:         v3.00.a
-- Description:     This is the top level module for xps 16550 uart core.
--                  This module has interfaces to plbv46 single slave plb,
--                  Serial port and Modem and incorporates the logic for 
--                  UART 16550 core functionality and interfacing logic 
--                  for PLB.
--
-- VHDL-Standard:   VHDL'93
--
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
--
--*****************************************************************************
-------------------------------------------------------------------------------
---- Revisions  :
-- ~~~~~~~
--   BSB                9/22/06
-- ^^^^^^^
--  PLBV46 single slave ipif added and code cleanup
-- ~~~~~~~
--  PVK                 06/21/07
-- ^^^^^^^
--  Modified Error Flag generation logic in uart16550.vhd file to update LSR 
--  register as soon as error is detected and FIFO is enabled.
--  Modified for CR:440029
-- ~~~~~~~
--  PVK                 07/06/07     
-- ^^^^^^^
--  Modified clkdiv re-synchronization logic in rx1650.vhd to adjust the 
--  sampling clock to detect the sin input data. Problem found when data send at 
--  high speed from the terminal and uart was missing to sample the data because
--  of error lies in the calculation of the intiger baud rate.
--  Modified for CR:441089
-- ~~~~~~~
--   USM                12/14/07
-- ^^^^^^^
--  Modified the version to v2.00.a to make the core license free.
-- ~~~~~~~
--  USM                02/26/08
-- ^^^^^^^
--  Modified the version to v2.00.b for CR:446943 fix.
-- ~~~~~~~
--  PVK                08/28/08     v2.01.a
-- ^^^^^^^
--  1) Updated helper libraries proc_common_v2_00_a to proc_common_v3_00_a and
--     plbv46_slave_single_v1_00_a to plbv46_slave_single_v1_01_a.
--  2) Modified clkdiv re-synchronization logic to supports +/- 3% baud jitter.
--  3) Updated state machine to detect the break error if sin input keeps low
--     for full character and if the framing error occurs before the break 
--     condition. (CR:415474)
-- ~~~~~~~
--  PVK                09/25/08     
-- ^^^^^^^
--  1) Modifed LSR(7)-"Error in Receiver FIFO" bit behavior to show error until 
--     the character containing error gets read out of the FIFO. (CR:490328)
--  2) Removed latch generation on lsr2_rst singnal.(CR:481176)
-- ~~~~~~~
--  PVK                05/25/09     v3.00.a
-- ^^^^^^^
--     Updated design to support Baud divisor value '1'. 
--     If Baud divisor is set to '1', BaudoutN will be same as SPLB clock when
--     C_HAS_EXTERNAL_XIN is set to '0' else it will be same as XIN clock.
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
-- xps_uart16550_v3_00_a library is used for xps_uart16550_v3_00_a 
-- component declarations
-------------------------------------------------------------------------------
library xps_uart16550_v3_00_a;
use xps_uart16550_v3_00_a.xuart;


-------------------------------------------------------------------------------
-- Definition of Generics:
--   C_BASEADDR             -- XPS UART Base Address
--   C_HIGHADDR             -- XPS UART High Address
--   C_IS_A_16550           -- Selection of UART for 16450 or 16550 mode
--   C_HAS_EXTERNAL_XIN     -- External XIN
--   C_HAS_EXTERNAL_RCLK    -- External RCLK
--   C_SPLB_AWIDTH          -- Width of the PLB Least significant address bus
--   C_SPLB_DWIDTH          -- width of the PLB data bus
--   C_SPLB_P2P             -- Selects point to point or shared topology
--   C_SPLB_MID_WIDTH       -- PLB Master ID bus width
--   C_SPLB_NUM_MASTERS     -- Number of PLB masters 
--   C_SPLB_NATIVE_DWIDTH   -- Slave bus data width
--   C_SPLB_SUPPORT_BURSTS  -- Burst/no burst support
--   C_FAMILY               -- XILINX FPGA family
-------------------------------------------------------------------------------

-- Definition of ports:
--   PLB Slave Signals 
--      PLB_ABus            -- PLB address bus          
--      PLB_UABus           -- PLB upper address bus
--      PLB_PAValid         -- PLB primary address valid
--      PLB_SAValid         -- PLB secondary address valid
--      PLB_rdPrim          -- PLB secondary to primary read request
--      PLB_wrPrim          -- PLB secondary to primary write request
--      PLB_masterID        -- PLB current master identifier
--      PLB_abort           -- PLB abort request
--      PLB_busLock         -- PLB bus lock
--      PLB_RNW             -- PLB read not write
--      PLB_BE              -- PLB byte enable
--      PLB_MSize           -- PLB data bus width indicator
--      PLB_size            -- PLB transfer size
--      PLB_type            -- PLB transfer type
--      PLB_lockErr         -- PLB lock error
--      PLB_wrDBus          -- PLB write data bus
--      PLB_wrBurst         -- PLB burst write transfer
--      PLB_rdBurst         -- PLB burst read transfer
--      PLB_wrPendReq       -- PLB pending bus write request
--      PLB_rdPendReq       -- PLB pending bus read request
--      PLB_wrPendPri       -- PLB pending bus write request priority
--      PLB_rdPendPri       -- PLB pending bus read request priority
--      PLB_reqPri          -- PLB current request 
--      PLB_TAttribute      -- PLB transfer attribute
--   Slave Responce Signal
--      Sl_addrAck          -- Salve address ack
--      Sl_SSize            -- Slave data bus size
--      Sl_wait             -- Salve wait indicator
--      Sl_rearbitrate      -- Salve rearbitrate
--      Sl_wrDAck           -- Slave write data ack
--      Sl_wrComp           -- Salve write complete
--      Sl_wrBTerm          -- Salve terminate write burst transfer
--      Sl_rdDBus           -- Slave read data bus
--      Sl_rdWdAddr         -- Slave read word address
--      Sl_rdDAck           -- Salve read data ack
--      Sl_rdComp           -- Slave read complete
--      Sl_rdBTerm          -- Salve terminate read burst transfer
--      Sl_MBusy            -- Slave busy
--      Sl_MWrErr           -- Slave write error
--      Sl_MRdErr           -- Slave read error
--      Sl_MIRQ             -- Master interrput 
--   UART Signals
--      baudoutN            -- Transmitter Clock
--      rclk                -- Receiver 16x Clock
--      sin                 -- Serial Data Input
--      sout                -- Serial Data Output
--      xin                 -- Baud Rate Generator reference clock
--      xout                -- Inverted XIN
--      ctsN                -- Clear To Send (active low)
--      dcdN                -- Data Carrier Detect (active low)
--      dsrN                -- Data Set Ready (active low)
--      dtrN                -- Data Terminal Ready (active low)
--      riN                 -- Ring Indicator (active low)
--      rtsN                -- Request To Send (active low)
--      ddis                -- Driver Disable
--      out1N               -- User controlled output1
--      out2N               -- User controlled output2
--      rxrdyN              -- DMA control signal
--      txrdyN              -- DMA control signal

--   System Signals
--      PLB_Clk             -- System clock
--      PLB_Rst             -- System Reset (active high)
--      Freeze              -- Freezes UART for software debug (active high)
--      IP2INTC_Irpt        -- Device interrupt output to microprocessor 
                            -- interrupt input or system interrupt controller.        

-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------

entity xps_uart16550 is

  generic (
    C_BASEADDR            : std_logic_vector         := X"FFFFFFFF";
    C_HIGHADDR            : std_logic_vector         := X"00000000";
    C_IS_A_16550          : integer range 0 to 1     := 1;
    C_HAS_EXTERNAL_XIN    : integer range 0 to 1     := 0;
    C_HAS_EXTERNAL_RCLK   : integer range 0 to 1     := 0;
    C_SPLB_AWIDTH         : integer range 32 to 32   := 32;
    C_SPLB_DWIDTH         : integer range 32 to 128  := 32;
    C_SPLB_P2P            : integer range 0 to 1     := 0;
    C_SPLB_MID_WIDTH      : integer range 0 to 4     := 1;
    C_SPLB_NUM_MASTERS    : integer range 1 to 16    := 1;
    C_SPLB_NATIVE_DWIDTH  : integer range 32 to 32   := 32;    
    C_SPLB_SUPPORT_BURSTS : integer range 0 to 0     := 0;    
    C_FAMILY              : string                   := "virtex5");
 
  port (
    -- System signals --------------------
    SPLB_Clk              : in std_logic;
    SPLB_Rst              : in std_logic;
    -- Bus Slave signals -----------------  
    PLB_ABus              : in  std_logic_vector(0 to C_SPLB_AWIDTH-1);
    PLB_UABus             : in  std_logic_vector(0 to C_SPLB_AWIDTH-1);
    PLB_PAValid           : in  std_logic;
    PLB_SAValid           : in  std_logic;
    PLB_rdPrim            : in  std_logic;
    PLB_wrPrim            : in  std_logic;
    PLB_masterID          : in  std_logic_vector(0 to C_SPLB_MID_WIDTH-1);
    PLB_abort             : in  std_logic;
    PLB_busLock           : in  std_logic;
    PLB_RNW               : in  std_logic;
    PLB_BE                : in  std_logic_vector(0 to(C_SPLB_DWIDTH/8) - 1);
    PLB_MSize             : in  std_logic_vector(0 to 1);
    PLB_size              : in  std_logic_vector(0 to 3);
    PLB_type              : in  std_logic_vector(0 to 2);
    PLB_lockErr           : in  std_logic;
    PLB_wrDBus            : in  std_logic_vector(0 to C_SPLB_DWIDTH-1);
    PLB_wrBurst           : in  std_logic;
    PLB_rdBurst           : in  std_logic;   
    PLB_wrPendReq         : in  std_logic; 
    PLB_rdPendReq         : in  std_logic; 
    PLB_wrPendPri         : in  std_logic_vector(0 to 1); 
    PLB_rdPendPri         : in  std_logic_vector(0 to 1); 
    PLB_reqPri            : in  std_logic_vector(0 to 1);
    PLB_TAttribute        : in  std_logic_vector(0 to 15); 
         
    -- Slave Responce Signals
    Sl_addrAck            : out std_logic;
    Sl_SSize              : out std_logic_vector(0 to 1);
    Sl_wait               : out std_logic;
    Sl_rearbitrate        : out std_logic;
    Sl_wrDAck             : out std_logic;
    Sl_wrComp             : out std_logic;
    Sl_wrBTerm            : out std_logic;
    Sl_rdDBus             : out std_logic_vector(0 to C_SPLB_DWIDTH-1);
    Sl_rdWdAddr           : out std_logic_vector(0 to 3);
    Sl_rdDAck             : out std_logic;
    Sl_rdComp             : out std_logic;
    Sl_rdBTerm            : out std_logic;
    Sl_MBusy              : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
    Sl_MWrErr             : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);                     
    Sl_MRdErr             : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);                     
    Sl_MIRQ               : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);                     

    -- UART signals  
    baudoutN              : out std_logic;
    ctsN                  : in  std_logic;
    dcdN                  : in  std_logic;
    ddis                  : out std_logic;
    dsrN                  : in  std_logic;
    dtrN                  : out std_logic;
    out1N                 : out std_logic;
    out2N                 : out std_logic;
    rclk                  : in  std_logic := '0';
    riN                   : in  std_logic;
    rtsN                  : out std_logic;
    rxrdyN                : out std_logic;
    sin                   : in  std_logic;
    sout                  : out std_logic;
    IP2INTC_Irpt          : out std_logic;
    txrdyN                : out std_logic;
    xin                   : in  std_logic := '0';
    xout                  : out std_logic;
    Freeze                : in  std_logic);

  -- fan-out attributes for Synplicity
  attribute syn_maxfan                         : integer;            
  attribute syn_maxfan of SPLB_Clk             : signal   is 10000;  
  attribute syn_maxfan of SPLB_Rst             : signal   is 10000;  
  
  --fan-out attributes for XST
  
  attribute MAX_FANOUT                         : string;             
  attribute MAX_FANOUT of SPLB_Clk             : signal   is "10000";  
  attribute MAX_FANOUT of SPLB_Rst             : signal   is "10000";
  
  -----------------------------------------------------------------
  -- Start of PSFUtil MPD attributes              
  -----------------------------------------------------------------
  attribute  HDL                              : string; 
  attribute  HDL      of  xps_uart16550       : entity   is  "VHDL"; 
  
  attribute  IMP_NETLIST                      : string; 
  attribute  IMP_NETLIST of  xps_uart16550    : entity   is  "TRUE"; 
      
  attribute  IP_GROUP                         : string; 
  attribute  IP_GROUP of  xps_uart16550       : entity   is  "LOGICORE"; 
  
  attribute  IPTYPE                           : string; 
  attribute  IPTYPE   of  xps_uart16550       : entity   is  "PERIPHERAL"; 
    
  attribute  STYLE                            : string; 
  attribute  STYLE    of  xps_uart16550       : entity   is  "HDL"; 
    
  attribute  CORE_STATE                       : string; 
  attribute  CORE_STATE of  xps_uart16550     : entity   is  "ACTIVE"; 
  
  --sigis attribute for specifying clocks,interrrupts,resets for EDK
  attribute SIGIS                             : string;    
  attribute SIGIS     of SPLB_Clk             : signal   is "Clk" ;
  attribute SIGIS     of SPLB_Rst             : signal   is "Rst" ;
  attribute SIGIS     of IP2INTC_Irpt         : signal   is "INTR_LEVEL_HIGH"; 
  attribute SIGIS     of rclk                 : signal   is "Clk" ;
  attribute SIGIS     of xin                  : signal   is "Clk" ;
  
  --assignment attribute for EDK
  attribute ASSIGNMENT                        : string;
  attribute ASSIGNMENT of C_BASEADDR          : constant is "REQUIRE"; 
  attribute ASSIGNMENT of C_HIGHADDR          : constant is "REQUIRE"; 
  attribute ASSIGNMENT of C_SPLB_AWIDTH       : constant is "CONSTANT";
  
  -----------------------------------------------------------------
  -- End of PSFUtil MPD attributes              
  ----------------------------------------------------------------- 

end entity xps_uart16550;

  -----------------------------------------------------------------------------
  -- Architecture section
  -----------------------------------------------------------------------------
architecture imp of xps_uart16550 is

begin  -- architecture imp

  -----------------------------------------------------------------------------
  -- Component Instantiations
  -----------------------------------------------------------------------------

  XUART_I_1 : entity xps_uart16550_v3_00_a.xuart
    generic map (
      C_BASEADDR              =>  C_BASEADDR,
      C_HIGHADDR              =>  C_HIGHADDR,
      C_IS_A_16550            =>  C_IS_A_16550 /= 0,         -- default TRUE
      C_HAS_EXTERNAL_XIN      =>  C_HAS_EXTERNAL_XIN /= 0,   -- default TRUE
      C_HAS_EXTERNAL_RCLK     =>  C_HAS_EXTERNAL_RCLK /= 0,  -- default TRUE
      C_SPLB_AWIDTH           =>  C_SPLB_AWIDTH,        
      C_SPLB_DWIDTH           =>  C_SPLB_DWIDTH,        
      C_SPLB_P2P              =>  C_SPLB_P2P,           
      C_SPLB_MID_WIDTH        =>  C_SPLB_MID_WIDTH,     
      C_SPLB_NUM_MASTERS      =>  C_SPLB_NUM_MASTERS,   
      C_SPLB_NATIVE_DWIDTH    =>  C_SPLB_NATIVE_DWIDTH, 
      C_FAMILY                =>  C_FAMILY )
    port map (
      SPLB_Clk                =>  SPLB_Clk,
      SPLB_Rst                =>  SPLB_Rst,
      PLB_ABus                =>  PLB_ABus,      
      PLB_UABus               =>  PLB_UABus,     
      PLB_PAValid             =>  PLB_PAValid,   
      PLB_SAValid             =>  PLB_SAValid,   
      PLB_rdPrim              =>  PLB_rdPrim,    
      PLB_wrPrim              =>  PLB_wrPrim,    
      PLB_masterID            =>  PLB_masterID,  
      PLB_abort               =>  PLB_abort,     
      PLB_busLock             =>  PLB_busLock,   
      PLB_RNW                 =>  PLB_RNW,       
      PLB_BE                  =>  PLB_BE,        
      PLB_MSize               =>  PLB_MSize,     
      PLB_size                =>  PLB_size,      
      PLB_type                =>  PLB_type,      
      PLB_lockErr             =>  PLB_lockErr,   
      PLB_wrDBus              =>  PLB_wrDBus,    
      PLB_wrBurst             =>  PLB_wrBurst,   
      PLB_rdBurst             =>  PLB_rdBurst,   
      PLB_wrPendReq           =>  PLB_wrPendReq, 
      PLB_rdPendReq           =>  PLB_rdPendReq, 
      PLB_wrPendPri           =>  PLB_wrPendPri, 
      PLB_rdPendPri           =>  PLB_rdPendPri, 
      PLB_reqPri              =>  PLB_reqPri,    
      PLB_TAttribute          =>  PLB_TAttribute,
      Sl_addrAck              =>  Sl_addrAck,    
      Sl_SSize                =>  Sl_SSize,      
      Sl_wait                 =>  Sl_wait,       
      Sl_rearbitrate          =>  Sl_rearbitrate,
      Sl_wrDAck               =>  Sl_wrDAck,     
      Sl_wrComp               =>  Sl_wrComp,     
      Sl_wrBTerm              =>  Sl_wrBTerm,    
      Sl_rdDBus               =>  Sl_rdDBus,     
      Sl_rdWdAddr             =>  Sl_rdWdAddr,   
      Sl_rdDAck               =>  Sl_rdDAck,     
      Sl_rdComp               =>  Sl_rdComp,     
      Sl_rdBTerm              =>  Sl_rdBTerm,    
      Sl_MBusy                =>  Sl_MBusy,      
      Sl_MWrErr               =>  Sl_MWrErr,     
      Sl_MRdErr               =>  Sl_MRdErr,     
      Sl_MIRQ                 =>  Sl_MIRQ,       
      baudoutN                =>  baudoutN,
      CtsN                    =>  ctsN,
      DcdN                    =>  dcdN,
      Ddis                    =>  ddis,
      DsrN                    =>  dsrN,
      DtrN                    =>  dtrN,
      Out1N                   =>  out1N,
      Out2N                   =>  out2N,
      Rclk                    =>  rclk,
      RiN                     =>  riN,
      RtsN                    =>  rtsN,
      RxrdyN                  =>  rxrdyN,
      Sin                     =>  sin,
      Sout                    =>  sout,
      IP2INTC_Irpt            =>  IP2INTC_Irpt,
      TxrdyN                  =>  txrdyN,
      Xin                     =>  xin,
      Xout                    =>  xout,
      Intr                    =>  open,
      Freeze                  =>  Freeze);
end architecture imp;