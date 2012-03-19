-------------------------------------------------------------------------------
-- $Id: ppc440_virtex5.vhd,v 1.3 2008/04/09 04:29:34 jeffs Exp $
-------------------------------------------------------------------------------
-- ppc440_virtex5.vhd - entity/architecture
-------------------------------------------------------------------------------
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
------------------------------------------------------------------------------
-- Filename:       ppc440_virtex5.vhd
-- Version:        v1.00a
-- Description:    PowerPC440 wrapper for EDK (only for Virtex5FX)
-------------------------------------------------------------------------------
-- Structure:
--                 ppc440_virtex5
-------------------------------------------------------------------------------
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics/parameters:                    "C_*"
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
-- @BEGIN_CHANGELOG EDK_K 
-- *** ppc440_virtex5_v1_01_a EDK10.1.02 ***
-- New Features
-- None
--
-- Resolved Issues
--
-- Fixed CR469412: The MPLB watchdog timer feature of the ppc440 hardblock intermittently produces 
-- spurious timout exceptions, and support is being permanently retracted. The WDT (originally 
-- enabled by default in ppc440_virtex5_v1_00_a) has been permanently disabled in the 
-- ppc440_virtex5_v1_01_a wrapper. Specifically, PPCM_CONTROL bit 23 is set to constant '0' on 
-- the ppc440 instance in the HDL. Associated parameters C_MPLB_WDOG_ENABLE and C_MPLB_COUNTER 
-- remain on the ppc440_virtex5_v1_01_a pcore for backwards-compatibility, but are ignored. 
-- A fatal error is issued if C_MPLB_COUNTER is set to "1" in the MHS design.
--
-- Fixed CR471051: LLDMA bus interfaces only appear in the XPS System Assembly View after parameter
--   C_NUM_DMA is set to a non-zero value in the Configure IP dialog.
--
-- Known Issues
--
-- CR470022: If parameter C_MPLB_ARB_MODE is set to 1 (round-robin), parameter C_MPLB_READ_PIPE_ENABLE 
--   should not be set to 0. Otherwise, one crossbar master may monopolize the MPLB bus under certain conditions.
--   A DRC warning is added to report this condition.
--
-- Other Information (optional)
--
-- @END_CHANGELOG
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------

entity ppc440_virtex5 is
  generic (

-- Control
  
    C_PIR 		: std_logic_vector (28 to 31) 	:= "1111" ;
    C_ENDIAN_RESET 		: std_logic	:= '0' ;
    C_USER_RESET 		: std_logic_vector (0 to 3) 	:= "0000" ;

-- Crossbar

    C_INTERCONNECT_IMASK 		: bit_vector (0 to 31) 	:= x"FFFFFFFF" ;
    C_ICU_RD_FETCH_PLB_PRIO 		: std_logic_vector (0 to 1) 	:= "00" ;
    C_ICU_RD_SPEC_PLB_PRIO 		: std_logic_vector (0 to 1) 	:= "00" ;
    C_ICU_RD_TOUCH_PLB_PRIO 		: std_logic_vector (0 to 1) 	:= "00" ;
    C_DCU_RD_LD_CACHE_PLB_PRIO 		: std_logic_vector (0 to 1) 	:= "00" ;
    C_DCU_RD_NONCACHE_PLB_PRIO 		: std_logic_vector (0 to 1) 	:= "00" ;
    C_DCU_RD_TOUCH_PLB_PRIO 		: std_logic_vector (0 to 1) 	:= "00" ;
    C_DCU_RD_URGENT_PLB_PRIO 		: std_logic_vector (0 to 1) 	:= "00" ;
    C_DCU_WR_FLUSH_PLB_PRIO 		: std_logic_vector (0 to 1) 	:= "00" ;
    C_DCU_WR_STORE_PLB_PRIO 		: std_logic_vector (0 to 1) 	:= "00" ;
    C_DCU_WR_URGENT_PLB_PRIO 		: std_logic_vector (0 to 1) 	:= "00" ;
    C_DMA0_PLB_PRIO 		: bit_vector (0 to 1) 	:= "00" ;
    C_DMA1_PLB_PRIO 		: bit_vector (0 to 1) 	:= "00" ;
    C_DMA2_PLB_PRIO 		: bit_vector (0 to 1) 	:= "00" ;
    C_DMA3_PLB_PRIO 		: bit_vector (0 to 1) 	:= "00" ;

-- DCR Bus Master

    C_IDCR_BASEADDR 		: std_logic_vector(0 to 9) 	:= "1111111111";
    C_IDCR_HIGHADDR 		: std_logic_vector(0 to 9) 	:= "0000000000";

-- APU Interface (FCB Bus)

    C_APU_CONTROL 		: bit_vector (0 to 16) 	:= "00010000000000000" ;
    C_APU_UDI_0 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_1 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_2 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_3 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_4 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_5 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_6 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_7 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_8 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_9 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_10 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_11 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_12 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_13 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_14 		: bit_vector (0 to 23) 	:= x"000000" ;
    C_APU_UDI_15 		: bit_vector (0 to 23) 	:= x"000000" ;

-- PPC440 Memory Controller

    C_PPC440MC_ADDR_BASE 		: std_logic_vector (0 to 31) 	:= x"FFFFFFFF" ;
    C_PPC440MC_ADDR_HIGH 		: std_logic_vector (0 to 31) 	:= x"00000000" ;
    C_PPC440MC_ROW_CONFLICT_MASK 		: bit_vector (0 to 31) 	:= x"00000000" ;
    C_PPC440MC_BANK_CONFLICT_MASK 		: bit_vector (0 to 31) 	:= x"00000000" ;
    C_PPC440MC_CONTROL 		: bit_vector (0 to 31) 	:= x"0000001F" ;
    C_PPC440MC_PRIO_ICU : integer := 4 ;
    C_PPC440MC_PRIO_DCUW : integer := 3 ;
    C_PPC440MC_PRIO_DCUR : integer := 2 ;
    C_PPC440MC_PRIO_SPLB1 : integer := 0 ;
    C_PPC440MC_PRIO_SPLB0 : integer := 1 ;
    C_PPC440MC_ARB_MODE : integer := 0 ;
    C_PPC440MC_MAX_BURST : integer := 8 ;

-- Master PLB Bus

    C_MPLB_AWIDTH 		: integer := 32 ;
    C_MPLB_DWIDTH 		: integer := 128 ;
    C_MPLB_NATIVE_DWIDTH 		: integer := 128 ;
    C_MPLB_COUNTER 		: bit_vector (0 to 31) 	:= x"00000500" ; -- 1280 count
    C_MPLB_PRIO_ICU : integer := 4 ;
    C_MPLB_PRIO_DCUW : integer := 3 ;
    C_MPLB_PRIO_DCUR : integer := 2 ;
    C_MPLB_PRIO_SPLB1 : integer := 0 ;
    C_MPLB_PRIO_SPLB0 : integer := 1 ;
    C_MPLB_ARB_MODE : integer := 0 ;
    C_MPLB_SYNC_TATTRIBUTE : integer := 0 ;
    C_MPLB_MAX_BURST : integer := 8 ;
    C_MPLB_ALLOW_LOCK_XFER : integer := 1 ;
    C_MPLB_READ_PIPE_ENABLE : integer := 1 ;
    C_MPLB_WRITE_PIPE_ENABLE : integer := 1 ;
    C_MPLB_WRITE_POST_ENABLE : integer := 1 ;
    C_MPLB_P2P : integer := 0 ;
    C_MPLB_WDOG_ENABLE : integer := 1 ;

-- Slave PLB Bus #0

    C_SPLB0_AWIDTH 		: integer := 32 ;
    C_SPLB0_DWIDTH 		: integer := 128 ;
    C_SPLB0_NATIVE_DWIDTH 		: integer := 128 ;
    C_SPLB0_SUPPORT_BURSTS 		: integer := 1 ;
    C_SPLB0_USE_MPLB_ADDR 		: integer 	:= 0 ;
    C_SPLB0_NUM_MPLB_ADDR_RNG 		: integer 	:= 0 ;
    C_SPLB0_RNG_MC_BASEADDR 		: std_logic_vector (0 to 31) 	:= x"FFFFFFFF" ;
    C_SPLB0_RNG_MC_HIGHADDR 		: std_logic_vector (0 to 31) 	:= x"00000000" ;
    C_SPLB0_RNG0_MPLB_BASEADDR 		: std_logic_vector (0 to 31) 	:= x"FFFFFFFF" ;
    C_SPLB0_RNG0_MPLB_HIGHADDR 		: std_logic_vector (0 to 31) 	:= x"00000000" ;
    C_SPLB0_RNG1_MPLB_BASEADDR 		: std_logic_vector (0 to 31) 	:= x"FFFFFFFF" ;
    C_SPLB0_RNG1_MPLB_HIGHADDR 		: std_logic_vector (0 to 31) 	:= x"00000000" ;
    C_SPLB0_RNG2_MPLB_BASEADDR 		: std_logic_vector (0 to 31) 	:= x"FFFFFFFF" ;
    C_SPLB0_RNG2_MPLB_HIGHADDR 		: std_logic_vector (0 to 31) 	:= x"00000000" ;
    C_SPLB0_RNG3_MPLB_BASEADDR 		: std_logic_vector (0 to 31) 	:= x"FFFFFFFF" ;
    C_SPLB0_RNG3_MPLB_HIGHADDR 		: std_logic_vector (0 to 31) 	:= x"00000000" ;
    C_SPLB0_NUM_MASTERS 		: integer  := 1 ;
    C_SPLB0_MID_WIDTH 		: integer  := 1 ;
    C_SPLB0_ALLOW_LOCK_XFER : integer := 1 ;
    C_SPLB0_READ_PIPE_ENABLE : integer := 0 ;
    C_SPLB0_PROPAGATE_MIRQ : integer := 0 ;
    C_SPLB0_P2P : integer := -1 ;

-- Slave PLB Bus #1

    C_SPLB1_AWIDTH 		: integer := 32 ;
    C_SPLB1_DWIDTH 		: integer := 128 ;
    C_SPLB1_NATIVE_DWIDTH 		: integer := 128 ;
    C_SPLB1_SUPPORT_BURSTS 		: integer := 1 ;
    C_SPLB1_USE_MPLB_ADDR 		: integer 	:= 0 ;
    C_SPLB1_NUM_MPLB_ADDR_RNG 		: integer 	:= 0 ;
    C_SPLB1_RNG_MC_BASEADDR 		: std_logic_vector (0 to 31) 	:= x"FFFFFFFF" ;
    C_SPLB1_RNG_MC_HIGHADDR 		: std_logic_vector (0 to 31) 	:= x"00000000" ;
    C_SPLB1_RNG0_MPLB_BASEADDR 		: std_logic_vector (0 to 31) 	:= x"FFFFFFFF" ;
    C_SPLB1_RNG0_MPLB_HIGHADDR 		: std_logic_vector (0 to 31) 	:= x"00000000" ;
    C_SPLB1_RNG1_MPLB_BASEADDR 		: std_logic_vector (0 to 31) 	:= x"FFFFFFFF" ;
    C_SPLB1_RNG1_MPLB_HIGHADDR 		: std_logic_vector (0 to 31) 	:= x"00000000" ;
    C_SPLB1_RNG2_MPLB_BASEADDR 		: std_logic_vector (0 to 31) 	:= x"FFFFFFFF" ;
    C_SPLB1_RNG2_MPLB_HIGHADDR 		: std_logic_vector (0 to 31) 	:= x"00000000" ;
    C_SPLB1_RNG3_MPLB_BASEADDR 		: std_logic_vector (0 to 31) 	:= x"FFFFFFFF" ;
    C_SPLB1_RNG3_MPLB_HIGHADDR 		: std_logic_vector (0 to 31) 	:= x"00000000" ;
    C_SPLB1_NUM_MASTERS 		: integer  := 1 ;
    C_SPLB1_MID_WIDTH 		: integer  := 1 ;
    C_SPLB1_ALLOW_LOCK_XFER : integer := 1 ;
    C_SPLB1_READ_PIPE_ENABLE : integer := 0 ;
    C_SPLB1_PROPAGATE_MIRQ : integer := 0 ;
    C_SPLB1_P2P : integer := -1 ;

-- DMA LocalLink

    C_NUM_DMA : integer := 0 ;

    C_DMA0_TXCHANNELCTRL 		: bit_vector (0 to 31) 	:= x"01010000" ;
    C_DMA0_RXCHANNELCTRL 		: bit_vector (0 to 31) 	:= x"01010000" ;
    C_DMA0_CONTROL 		: bit_vector (0 to 7) 	:= "00000000" ;
    C_DMA0_TXIRQTIMER 		: bit_vector (0 to 9) 	:= "1111111111" ;
    C_DMA0_RXIRQTIMER 		: bit_vector (0 to 9) 	:= "1111111111" ;

    C_DMA1_TXCHANNELCTRL 		: bit_vector (0 to 31) 	:= x"01010000" ;
    C_DMA1_RXCHANNELCTRL 		: bit_vector (0 to 31) 	:= x"01010000" ;
    C_DMA1_CONTROL 		: bit_vector (0 to 7) 	:= "00000000" ;
    C_DMA1_TXIRQTIMER 		: bit_vector (0 to 9) 	:= "1111111111" ;
    C_DMA1_RXIRQTIMER 		: bit_vector (0 to 9) 	:= "1111111111" ;

    C_DMA2_TXCHANNELCTRL 		: bit_vector (0 to 31) 	:= x"01010000" ;
    C_DMA2_RXCHANNELCTRL 		: bit_vector (0 to 31) 	:= x"01010000" ;
    C_DMA2_CONTROL 		: bit_vector (0 to 7) 	:= "00000000" ;
    C_DMA2_TXIRQTIMER 		: bit_vector (0 to 9) 	:= "1111111111" ;
    C_DMA2_RXIRQTIMER 		: bit_vector (0 to 9) 	:= "1111111111" ;

    C_DMA3_TXCHANNELCTRL 		: bit_vector (0 to 31) 	:= x"01010000" ;
    C_DMA3_RXCHANNELCTRL 		: bit_vector (0 to 31) 	:= x"01010000" ;
    C_DMA3_CONTROL 		: bit_vector (0 to 7) 	:= "00000000" ;
    C_DMA3_TXIRQTIMER 		: bit_vector (0 to 9) 	:= "1111111111" ;
    C_DMA3_RXIRQTIMER 		: bit_vector (0 to 9) 	:= "1111111111" ;

-- DCR Interface

    C_DCR_AUTOLOCK_ENABLE 		: integer 	:= 1 ;
    C_PPCDM_ASYNCMODE 		: integer 	:= 0 ;
    C_PPCDS_ASYNCMODE 		: integer 	:= 0 
  );

  port (
  
-- Control

    C440MACHINECHECK 		: out std_logic ;

-- Clock and Power Management

    CPMC440CLK 		: in std_logic ;
    CPMC440CLKEN 		: in std_logic ;
    CPMINTERCONNECTCLK 		: in std_logic ;
    CPMINTERCONNECTCLKEN 		: in std_logic ;
    CPMINTERCONNECTCLKNTO1 		: in std_logic ;
    CPMC440CORECLOCKINACTIVE 		: in std_logic ;
    CPMC440TIMERCLOCK 		: in std_logic ;
    C440CPMCORESLEEPREQ 		: out std_logic ;
    C440CPMDECIRPTREQ 		: out std_logic ;
    C440CPMFITIRPTREQ 		: out std_logic ;
    C440CPMMSRCE 		: out std_logic ;
    C440CPMMSREE 		: out std_logic ;
    C440CPMTIMERRESETREQ 		: out std_logic ;
    C440CPMWDIRPTREQ 		: out std_logic ;
    PPCCPMINTERCONNECTBUSY 		: out std_logic ;

-- Debug

    DBGC440DEBUGHALT 		: in std_logic ;
    DBGC440DEBUGHALTNEG 		: in std_logic ;
    DBGC440SYSTEMSTATUS 		: in std_logic_vector (0 to 4) ;
    DBGC440UNCONDDEBUGEVENT 		: in std_logic ;
    C440DBGSYSTEMCONTROL 		: out std_logic_vector (0 to 7) ;
    SPLB0_Error 		: out std_logic_vector (0 to 3) ;
    SPLB1_Error 		: out std_logic_vector (0 to 3) ;

-- DCR Bus Master

    DCRPPCDMACK 		: in std_logic ;
    DCRPPCDMDBUSIN 		: in std_logic_vector (0 to 31) ;
    DCRPPCDMTIMEOUTWAIT 		: in std_logic ;
    CPMDCRCLK 		: in std_logic ;
    PPCDMDCRREAD 		: out std_logic ;
    PPCDMDCRWRITE 		: out std_logic ;
    PPCDMDCRABUS 		: out std_logic_vector (0 to 9) ;
    PPCDMDCRDBUSOUT 		: out std_logic_vector (0 to 31) ;

-- DCR Bus Slave

    DCRPPCDSREAD 		: in std_logic ;
    DCRPPCDSWRITE 		: in std_logic ;
    DCRPPCDSABUS 		: in std_logic_vector (0 to 9) ;
    DCRPPCDSDBUSOUT 		: in std_logic_vector (0 to 31) ;
    PPCDSDCRACK 		: out std_logic ;
    PPCDSDCRDBUSIN 		: out std_logic_vector (0 to 31) ;
    PPCDSDCRTIMEOUTWAIT 		: out std_logic ;

-- Exceptions and Interrupts

    EICC440CRITIRQ 		: in std_logic ;
    EICC440EXTIRQ 		: in std_logic ;
    PPCEICINTERCONNECTIRQ 		: out std_logic ;

-- APU Interface (FCB Bus)

    FCMAPUCR 		: in std_logic_vector (0 to 3) ;
    FCMAPUDONE 		: in std_logic ;
    FCMAPUEXCEPTION 		: in std_logic ;
    FCMAPUFPSCRFEX 		: in std_logic ;
    FCMAPURESULT 		: in std_logic_vector (0 to 31) ;
    FCMAPURESULTVALID 		: in std_logic ;
    FCMAPUSLEEPNOTREADY 		: in std_logic ;
    FCMAPUCONFIRMINSTR 		: in std_logic ;
    FCMAPUSTOREDATA 		: in std_logic_vector (0 to 127) ;
    CPMFCMCLK  		: in std_logic ;
    APUFCMDECNONAUTON 		: out std_logic ;
    APUFCMDECFPUOP 		: out std_logic ;
    APUFCMDECLDSTXFERSIZE 		: out std_logic_vector (0 to 2) ;
    APUFCMDECLOAD 		: out std_logic ;
    APUFCMNEXTINSTRREADY 		: out std_logic ;
    APUFCMDECSTORE 		: out std_logic ;
    APUFCMDECUDI 		: out std_logic_vector (0 to 3) ;
    APUFCMDECUDIVALID 		: out std_logic ;
    APUFCMENDIAN 		: out std_logic ;
    APUFCMFLUSH 		: out std_logic ;
    APUFCMINSTRUCTION 		: out std_logic_vector (0 to 31) ;
    APUFCMINSTRVALID 		: out std_logic ;
    APUFCMLOADBYTEADDR 		: out std_logic_vector (0 to 3) ;
    APUFCMLOADDATA 		: out std_logic_vector (0 to 127) ;
    APUFCMLOADDVALID 		: out std_logic ;
    APUFCMOPERANDVALID 		: out std_logic ;
    APUFCMRADATA 		: out std_logic_vector (0 to 31) ;
    APUFCMRBDATA 		: out std_logic_vector (0 to 31) ;
    APUFCMWRITEBACKOK 		: out std_logic ;
    APUFCMMSRFE0 		: out std_logic ;
    APUFCMMSRFE1 		: out std_logic ;

-- JTAG

    JTGC440TCK 		: in std_logic ;
    JTGC440TDI 		: in std_logic ;
    JTGC440TMS 		: in std_logic ;
    JTGC440TRSTNEG 		: in std_logic ;
    C440JTGTDO 		: out std_logic ;
    C440JTGTDOEN 		: out std_logic ;

-- Memory Controller Bus

    MCMIREADDATA 		: in std_logic_vector (0 to 127) ;
    MCMIREADDATAVALID 		: in std_logic ;
    MCMIREADDATAERR 		: in std_logic ;
    MCMIADDRREADYTOACCEPT 		: in std_logic ;
    CPMMCCLK 		: in std_logic ;
    PPC440MCCLKOUT  		: out std_logic ;
    MIMCREADNOTWRITE 		: out std_logic ;
    MIMCADDRESS 		: out std_logic_vector (0 to 35) ;
    MIMCADDRESSVALID 		: out std_logic ;
    MIMCWRITEDATA 		: out std_logic_vector (0 to 127) ;
    MIMCWRITEDATAVALID 		: out std_logic ;
    MIMCBYTEENABLE 		: out std_logic_vector (0 to 15) ;
    MIMCBANKCONFLICT 		: out std_logic ;
    MIMCROWCONFLICT 		: out std_logic ;

-- Master PLB Bus

    PLBPPCMMBUSY 		: in std_logic ;
    PLBPPCMMIRQ 		: in std_logic ;
    PLBPPCMMRDERR 		: in std_logic ;
    PLBPPCMMWRERR 		: in std_logic ;
    PLBPPCMADDRACK  		: in std_logic ;
    PLBPPCMRDBTERM 		: in std_logic ;
    PLBPPCMRDDACK 		: in std_logic ;
    PLBPPCMRDDBUS 		: in std_logic_vector (0 to 127) ;
    PLBPPCMRDWDADDR 		: in std_logic_vector (0 to 3) ;
    PLBPPCMREARBITRATE 		: in std_logic ;
    PLBPPCMSSIZE  		: in std_logic_vector (0 to 1) ;
    PLBPPCMTIMEOUT  		: in std_logic ;
    PLBPPCMWRBTERM  		: in std_logic ;
    PLBPPCMWRDACK  		: in std_logic ;
    PLBPPCMRDPENDPRI 		: in std_logic_vector (0 to 1) ;
    PLBPPCMRDPENDREQ 		: in std_logic ;
    PLBPPCMREQPRI 		: in std_logic_vector (0 to 1) ;
    PLBPPCMWRPENDPRI 		: in std_logic_vector (0 to 1) ;
    PLBPPCMWRPENDREQ 		: in std_logic ;
    CPMPPCMPLBCLK 		: in std_logic ;
    PPCMPLBABORT 		: out std_logic ;
    PPCMPLBABUS  		: out std_logic_vector (0 to 31) ;
    PPCMPLBBE 		: out std_logic_vector (0 to 15) ;
    PPCMPLBBUSLOCK 		: out std_logic ;
    PPCMPLBLOCKERR 		: out std_logic ;
    PPCMPLBMSIZE 		: out std_logic_vector (0 to 1) ;
    PPCMPLBPRIORITY 		: out std_logic_vector (0 to 1) ;
    PPCMPLBRDBURST 		: out std_logic ;
    PPCMPLBREQUEST 		: out std_logic ;
    PPCMPLBRNW 		: out std_logic ;
    PPCMPLBSIZE  		: out std_logic_vector (0 to 3) ;
    PPCMPLBTATTRIBUTE 		: out std_logic_vector (0 to 15) ;
    PPCMPLBTYPE 		: out std_logic_vector (0 to 2) ;
    PPCMPLBUABUS  		: out std_logic_vector (0 to 31) ;
    PPCMPLBWRBURST 		: out std_logic ;
    PPCMPLBWRDBUS 		: out std_logic_vector (0 to 127) ;

-- Slave PLB Bus #0

    PLBPPCS0MASTERID 		: in std_logic_vector (0 to C_SPLB0_MID_WIDTH-1) ;
    PLBPPCS0PAVALID 		: in std_logic ;
    PLBPPCS0SAVALID  		: in std_logic ;
    PLBPPCS0RDPENDREQ  		: in std_logic ;
    PLBPPCS0WRPENDREQ  		: in std_logic ;
    PLBPPCS0RDPENDPRI  		: in std_logic_vector (0 to 1) ;
    PLBPPCS0WRPENDPRI 		: in std_logic_vector (0 to 1) ;
    PLBPPCS0REQPRI 		: in std_logic_vector (0 to 1) ;
    PLBPPCS0RDPRIM  		: in std_logic ;
    PLBPPCS0WRPRIM  		: in std_logic ;
    PLBPPCS0BUSLOCK 		: in std_logic ;
    PLBPPCS0ABORT 		: in std_logic ;
    PLBPPCS0RNW  		: in std_logic ;
    PLBPPCS0BE 		: in std_logic_vector (0 to 15) ;
    PLBPPCS0SIZE 		: in std_logic_vector (0 to 3) ;
    PLBPPCS0TYPE 		: in std_logic_vector (0 to 2) ;
    PLBPPCS0TATTRIBUTE 		: in std_logic_vector (0 to 15) ;
    PLBPPCS0LOCKERR 		: in std_logic ;
    PLBPPCS0MSIZE 		: in std_logic_vector (0 to 1) ;
    PLBPPCS0UABUS 		: in std_logic_vector (0 to 31) ;
    PLBPPCS0ABUS 		: in std_logic_vector (0 to 31) ;
    PLBPPCS0WRDBUS 		: in std_logic_vector (0 to 127) ;
    PLBPPCS0WRBURST 		: in std_logic ;
    PLBPPCS0RDBURST 		: in std_logic ;
    CPMPPCS0PLBCLK 		: in std_logic ;
    PPCS0PLBADDRACK  		: out std_logic ;
    PPCS0PLBWAIT  		: out std_logic ;
    PPCS0PLBREARBITRATE   		: out std_logic ;
    PPCS0PLBWRDACK 		: out std_logic ;
    PPCS0PLBWRCOMP 		: out std_logic ;
    PPCS0PLBRDDBUS 		: out std_logic_vector (0 to 127) ;
    PPCS0PLBRDWDADDR  		: out std_logic_vector (0 to 3) ;
    PPCS0PLBRDDACK 		: out std_logic ;
    PPCS0PLBRDCOMP 		: out std_logic ;
    PPCS0PLBRDBTERM 		: out std_logic ;
    PPCS0PLBWRBTERM 		: out std_logic ;
    PPCS0PLBMBUSY 		: out std_logic_vector (0 to C_SPLB0_NUM_MASTERS-1) ;
    PPCS0PLBMRDERR 		: out std_logic_vector (0 to C_SPLB0_NUM_MASTERS-1) ;
    PPCS0PLBMWRERR 		: out std_logic_vector (0 to C_SPLB0_NUM_MASTERS-1) ;
    PPCS0PLBMIRQ 		: out std_logic_vector (0 to C_SPLB0_NUM_MASTERS-1) ;
    PPCS0PLBSSIZE 		: out std_logic_vector (0 to 1) ;

-- Slave PLB Bus #1

    PLBPPCS1MASTERID 		: in std_logic_vector (0 to C_SPLB1_MID_WIDTH-1) ;
    PLBPPCS1PAVALID  		: in std_logic ;
    PLBPPCS1SAVALID  		: in std_logic ;
    PLBPPCS1RDPENDREQ  		: in std_logic ;
    PLBPPCS1WRPENDREQ  		: in std_logic ;
    PLBPPCS1RDPENDPRI  		: in std_logic_vector (0 to 1) ;
    PLBPPCS1WRPENDPRI 		: in std_logic_vector (0 to 1) ;
    PLBPPCS1REQPRI 		: in std_logic_vector (0 to 1) ;
    PLBPPCS1RDPRIM  		: in std_logic ;
    PLBPPCS1WRPRIM  		: in std_logic ;
    PLBPPCS1BUSLOCK 		: in std_logic ;
    PLBPPCS1ABORT 		: in std_logic ;
    PLBPPCS1RNW  		: in std_logic ;
    PLBPPCS1BE 		: in std_logic_vector (0 to 15) ;
    PLBPPCS1SIZE 		: in std_logic_vector (0 to 3) ;
    PLBPPCS1TYPE 		: in std_logic_vector (0 to 2) ;
    PLBPPCS1TATTRIBUTE 		: in std_logic_vector (0 to 15) ;
    PLBPPCS1LOCKERR 		: in std_logic ;
    PLBPPCS1MSIZE 		: in std_logic_vector (0 to 1) ;
    PLBPPCS1UABUS 		: in std_logic_vector (0 to 31) ;
    PLBPPCS1ABUS 		: in std_logic_vector (0 to 31) ;
    PLBPPCS1WRDBUS 		: in std_logic_vector (0 to 127) ;
    PLBPPCS1WRBURST 		: in std_logic ;
    PLBPPCS1RDBURST 		: in std_logic ;
    CPMPPCS1PLBCLK 		: in std_logic ;
    PPCS1PLBADDRACK  		: out std_logic ;
    PPCS1PLBWAIT  		: out std_logic ;
    PPCS1PLBREARBITRATE   		: out std_logic ;
    PPCS1PLBWRDACK 		: out std_logic ;
    PPCS1PLBWRCOMP 		: out std_logic ;
    PPCS1PLBRDDBUS 		: out std_logic_vector (0 to 127) ;
    PPCS1PLBRDWDADDR  		: out std_logic_vector (0 to 3) ;
    PPCS1PLBRDDACK 		: out std_logic ;
    PPCS1PLBRDCOMP 		: out std_logic ;
    PPCS1PLBRDBTERM 		: out std_logic ;
    PPCS1PLBWRBTERM 		: out std_logic ;
    PPCS1PLBMBUSY 		: out std_logic_vector (0 to C_SPLB1_NUM_MASTERS-1) ;
    PPCS1PLBMRDERR  		: out std_logic_vector (0 to C_SPLB1_NUM_MASTERS-1) ;
    PPCS1PLBMWRERR 		: out std_logic_vector (0 to C_SPLB1_NUM_MASTERS-1) ;
    PPCS1PLBMIRQ 		: out std_logic_vector (0 to C_SPLB1_NUM_MASTERS-1) ;
    PPCS1PLBSSIZE 		: out std_logic_vector (0 to 1) ;

-- DMA #0 LocalLink

    LLDMA0TXDSTRDYN 		: in std_logic ;
    LLDMA0RXD 		: in std_logic_vector (0 to 31) ;
    LLDMA0RXREM 		: in std_logic_vector (0 to 3) ;
    LLDMA0RXSOFN 		: in std_logic ;
    LLDMA0RXEOFN 		: in std_logic ;
    LLDMA0RXSOPN 		: in std_logic ;
    LLDMA0RXEOPN 		: in std_logic ;
    LLDMA0RXSRCRDYN 		: in std_logic ;
    LLDMA0RSTENGINEREQ 		: in std_logic ;
    CPMDMA0LLCLK 		: in std_logic ;
    DMA0LLTXD 		: out std_logic_vector (0 to 31) ;
    DMA0LLTXREM 		: out std_logic_vector (0 to 3) ;
    DMA0LLTXSOFN 		: out std_logic ;
    DMA0LLTXEOFN 		: out std_logic ;
    DMA0LLTXSOPN 		: out std_logic ;
    DMA0LLTXEOPN 		: out std_logic ;
    DMA0LLTXSRCRDYN 		: out std_logic ;
    DMA0LLRXDSTRDYN 		: out std_logic ;
    DMA0LLRSTENGINEACK 		: out std_logic ;
    DMA0TXIRQ 		: out std_logic ;
    DMA0RXIRQ 		: out std_logic ;

-- DMA #1 LocalLink

    LLDMA1TXDSTRDYN 		: in std_logic ;
    LLDMA1RXD 		: in std_logic_vector (0 to 31) ;
    LLDMA1RXREM 		: in std_logic_vector (0 to 3) ;
    LLDMA1RXSOFN 		: in std_logic ;
    LLDMA1RXEOFN 		: in std_logic ;
    LLDMA1RXSOPN 		: in std_logic ;
    LLDMA1RXEOPN 		: in std_logic ;
    LLDMA1RXSRCRDYN 		: in std_logic ;
    LLDMA1RSTENGINEREQ 		: in std_logic ;
    CPMDMA1LLCLK 		: in std_logic ;
    DMA1LLTXD 		: out std_logic_vector (0 to 31) ;
    DMA1LLTXREM 		: out std_logic_vector (0 to 3) ;
    DMA1LLTXSOFN 		: out std_logic ;
    DMA1LLTXEOFN 		: out std_logic ;
    DMA1LLTXSOPN 		: out std_logic ;
    DMA1LLTXEOPN 		: out std_logic ;
    DMA1LLTXSRCRDYN 		: out std_logic ;
    DMA1LLRXDSTRDYN 		: out std_logic ;
    DMA1LLRSTENGINEACK 		: out std_logic ;
    DMA1TXIRQ 		: out std_logic ;
    DMA1RXIRQ 		: out std_logic ;

-- DMA #2 LocalLink

    LLDMA2TXDSTRDYN 		: in std_logic ;
    LLDMA2RXD 		: in std_logic_vector (0 to 31) ;
    LLDMA2RXREM 		: in std_logic_vector (0 to 3) ;
    LLDMA2RXSOFN 		: in std_logic ;
    LLDMA2RXEOFN 		: in std_logic ;
    LLDMA2RXSOPN 		: in std_logic ;
    LLDMA2RXEOPN 		: in std_logic ;
    LLDMA2RXSRCRDYN 		: in std_logic ;
    LLDMA2RSTENGINEREQ 		: in std_logic ;
    CPMDMA2LLCLK 		: in std_logic ;
    DMA2LLTXD 		: out std_logic_vector (0 to 31) ;
    DMA2LLTXREM 		: out std_logic_vector (0 to 3) ;
    DMA2LLTXSOFN 		: out std_logic ;
    DMA2LLTXEOFN 		: out std_logic ;
    DMA2LLTXSOPN 		: out std_logic ;
    DMA2LLTXEOPN 		: out std_logic ;
    DMA2LLTXSRCRDYN 		: out std_logic ;
    DMA2LLRXDSTRDYN 		: out std_logic ;
    DMA2LLRSTENGINEACK 		: out std_logic ;
    DMA2TXIRQ 		: out std_logic ;
    DMA2RXIRQ 		: out std_logic ;

-- DMA #3 LocalLink

    LLDMA3TXDSTRDYN 		: in std_logic ;
    LLDMA3RXD 		: in std_logic_vector (0 to 31) ;
    LLDMA3RXREM 		: in std_logic_vector (0 to 3) ;
    LLDMA3RXSOFN 		: in std_logic ;
    LLDMA3RXEOFN 		: in std_logic ;
    LLDMA3RXSOPN 		: in std_logic ;
    LLDMA3RXEOPN 		: in std_logic ;
    LLDMA3RXSRCRDYN 		: in std_logic ;
    LLDMA3RSTENGINEREQ 		: in std_logic ;
    CPMDMA3LLCLK 		: in std_logic ;
    DMA3LLTXD 		: out std_logic_vector (0 to 31) ;
    DMA3LLTXREM 		: out std_logic_vector (0 to 3) ;
    DMA3LLTXSOFN 		: out std_logic ;
    DMA3LLTXEOFN 		: out std_logic ;
    DMA3LLTXSOPN 		: out std_logic ;
    DMA3LLTXEOPN 		: out std_logic ;
    DMA3LLTXSRCRDYN 		: out std_logic ;
    DMA3LLRXDSTRDYN 		: out std_logic ;
    DMA3LLRSTENGINEACK 		: out std_logic ;
    DMA3TXIRQ 		: out std_logic ;
    DMA3RXIRQ 		: out std_logic ;

-- Reset

    RSTC440RESETCORE 		: in std_logic ;
    RSTC440RESETCHIP 		: in std_logic ;
    RSTC440RESETSYSTEM 		: in std_logic ;
    C440RSTCORERESETREQ 		: out std_logic ;
    C440RSTCHIPRESETREQ 		: out std_logic ;
    C440RSTSYSTEMRESETREQ 		: out std_logic ;

-- Trace

    TRCC440TRACEDISABLE 		: in std_logic ;
    TRCC440TRIGGEREVENTIN 		: in std_logic ;
    C440TRCBRANCHSTATUS 		: out std_logic_vector (0 to 2) ;
    C440TRCCYCLE 		: out std_logic ;
    C440TRCEXECUTIONSTATUS 		: out std_logic_vector (0 to 4) ;
    C440TRCTRACESTATUS 		: out std_logic_vector (0 to 6) ;
    C440TRCTRIGGEREVENTOUT 		: out std_logic ;
    C440TRCTRIGGEREVENTTYPE 		: out std_logic_vector (0 to 13)
  );
end ppc440_virtex5;

architecture structure of ppc440_virtex5 is

--  attribute BOX_TYPE : string;
--  attribute BOX_TYPE of PPC440 : component is "PRIMITIVE";
  
--------------------------------------------------------------------------
-- Signal Declarations
----------------------------------------------------------------------------
  constant net_gnd0 	: std_logic 	:= '0' ;  
  constant net_vcc0 	: std_logic 	:= '1' ;
  constant net_gnd32 	: std_logic_vector (0 to 31) 	:= x"00000000" ;  
  constant net_vcc32 	: std_logic_vector (0 to 31) 	:= x"FFFFFFFF" ;
  constant bit_gnd32 	: bit_vector (0 to 31) 	:= x"00000000" ;
  constant bit_vcc32 	: bit_vector (0 to 31) 	:= x"FFFFFFFF" ;
  constant INTERCONNECT_TMPL_SEL_i 	: bit_vector (0 to 31) 	:= x"3FFFFFFF" ;
  signal PLBPPCS0MASTERID_i 	: std_logic_vector (0 to C_SPLB0_MID_WIDTH) ;
  signal PLBPPCS1MASTERID_i 	: std_logic_vector (0 to C_SPLB1_MID_WIDTH) ;
  signal PPCS0PLBMRDERR_i 	: std_logic_vector (0 to 3) ;
  signal PPCS0PLBMWRERR_i 	: std_logic_vector (0 to 3) ;
  signal PPCS0PLBMIRQ_i 	: std_logic_vector (0 to 3) ;
  signal PPCS1PLBMRDERR_i 	: std_logic_vector (0 to 3) ;
  signal PPCS1PLBMWRERR_i 	: std_logic_vector (0 to 3) ;
  signal PPCS1PLBMIRQ_i 	: std_logic_vector (0 to 3) ;
  signal PPCS0PLBMBUSY_i 	: std_logic_vector (0 to 3) ;
  signal PPCS1PLBMBUSY_i 	: std_logic_vector (0 to 3) ;
  signal PPCS0PLBMBUSY_reg 	: std_logic_vector (0 to C_SPLB0_NUM_MASTERS - 1) ;
  signal PPCS1PLBMBUSY_reg 	: std_logic_vector (0 to C_SPLB1_NUM_MASTERS - 1) ;
  signal CPMPPCS0PLBCLK_i 	: std_logic ;
  signal CPMPPCS1PLBCLK_i 	: std_logic ;
  signal DBGC440DEBUGHALT_i 	: std_logic ;

----------------------------------------------------------------------------
-- Functions used to derive PPC440 instance generics
----------------------------------------------------------------------------

  subtype bit3 is bit_vector (0 to 2) ;
  type bit3_array is array (0 to 7) of bit3 ;
  constant to_bit3 : bit3_array := ("000", "001", "010", "011", "100", "101", "110", "111") ;
  subtype bit2 is bit_vector (0 to 1) ;
  type bit2_array is array (0 to 3) of bit2 ;
  constant to_bit2 : bit2_array := ("00", "01", "10", "11") ;
  
  type thresh_array is array (0 to 16) of bit3 ;
  constant to_thresh : thresh_array := (1 => "000", 2 => "001", 4 => "010", 8 => "011",
    16 => "100", others => "000") ;

  function F_MemTemplate (baseaddr, highaddr : std_logic_vector; enable : boolean) return bit_vector is
    variable template : bit_vector (0 to 31) ;
    variable basepage, highpage : integer ;
  begin
    basepage := CONV_INTEGER(baseaddr(0 to 4));
    highpage := CONV_INTEGER(highaddr(0 to 4));
    for i in 0 to 31 loop
      if i >= basepage and i <= highpage and enable then
        template(i) := '1' ;
      else
        template(i) := '0' ;
      end if;
    end loop;
    return template ;
  end function ;

  function F_PPCS0_MemTemplate return bit_vector is
    variable template : bit_vector (0 to 31) ;
  begin
    template :=
         (F_MemTemplate(C_SPLB0_RNG_MC_BASEADDR, C_SPLB0_RNG_MC_HIGHADDR, TRUE) and
            F_MemTemplate(C_PPC440MC_ADDR_BASE, C_PPC440MC_ADDR_HIGH, TRUE)) or
         (F_MemTemplate(C_SPLB0_RNG0_MPLB_BASEADDR, C_SPLB0_RNG0_MPLB_HIGHADDR,
           (C_SPLB0_NUM_MPLB_ADDR_RNG * C_SPLB0_USE_MPLB_ADDR) >= 1) and
           not F_MemTemplate(C_PPC440MC_ADDR_BASE, C_PPC440MC_ADDR_HIGH, TRUE)) or
         (F_MemTemplate(C_SPLB0_RNG1_MPLB_BASEADDR, C_SPLB0_RNG1_MPLB_HIGHADDR,
           (C_SPLB0_NUM_MPLB_ADDR_RNG * C_SPLB0_USE_MPLB_ADDR) >= 2) and
           not F_MemTemplate(C_PPC440MC_ADDR_BASE, C_PPC440MC_ADDR_HIGH, TRUE)) or
         (F_MemTemplate(C_SPLB0_RNG2_MPLB_BASEADDR, C_SPLB0_RNG2_MPLB_HIGHADDR,
           (C_SPLB0_NUM_MPLB_ADDR_RNG * C_SPLB0_USE_MPLB_ADDR) >= 3) and
           not F_MemTemplate(C_PPC440MC_ADDR_BASE, C_PPC440MC_ADDR_HIGH, TRUE)) or
         (F_MemTemplate(C_SPLB0_RNG3_MPLB_BASEADDR, C_SPLB0_RNG3_MPLB_HIGHADDR,
           (C_SPLB0_NUM_MPLB_ADDR_RNG * C_SPLB0_USE_MPLB_ADDR) >= 4) and
           not F_MemTemplate(C_PPC440MC_ADDR_BASE, C_PPC440MC_ADDR_HIGH, TRUE)) ;
    return template ;
  end function ;

  function F_PPCS1_MemTemplate return bit_vector is
    variable template : bit_vector (0 to 31) ;
  begin
    template :=
         (F_MemTemplate(C_SPLB1_RNG_MC_BASEADDR, C_SPLB1_RNG_MC_HIGHADDR, TRUE) and
            F_MemTemplate(C_PPC440MC_ADDR_BASE, C_PPC440MC_ADDR_HIGH, TRUE)) or
         (F_MemTemplate(C_SPLB1_RNG0_MPLB_BASEADDR, C_SPLB1_RNG0_MPLB_HIGHADDR,
           (C_SPLB1_NUM_MPLB_ADDR_RNG * C_SPLB1_USE_MPLB_ADDR) >= 1) and
           not F_MemTemplate(C_PPC440MC_ADDR_BASE, C_PPC440MC_ADDR_HIGH, TRUE)) or
         (F_MemTemplate(C_SPLB1_RNG1_MPLB_BASEADDR, C_SPLB1_RNG1_MPLB_HIGHADDR,
           (C_SPLB1_NUM_MPLB_ADDR_RNG * C_SPLB1_USE_MPLB_ADDR) >= 2) and
           not F_MemTemplate(C_PPC440MC_ADDR_BASE, C_PPC440MC_ADDR_HIGH, TRUE)) or
         (F_MemTemplate(C_SPLB1_RNG2_MPLB_BASEADDR, C_SPLB1_RNG2_MPLB_HIGHADDR,
           (C_SPLB1_NUM_MPLB_ADDR_RNG * C_SPLB1_USE_MPLB_ADDR) >= 3) and
           not F_MemTemplate(C_PPC440MC_ADDR_BASE, C_PPC440MC_ADDR_HIGH, TRUE)) or
         (F_MemTemplate(C_SPLB1_RNG3_MPLB_BASEADDR, C_SPLB1_RNG3_MPLB_HIGHADDR,
           (C_SPLB1_NUM_MPLB_ADDR_RNG * C_SPLB1_USE_MPLB_ADDR) >= 4) and
           not F_MemTemplate(C_PPC440MC_ADDR_BASE, C_PPC440MC_ADDR_HIGH, TRUE)) ;
    return template ;
  end function ;

  function F_MI_ARBCONFIG return bit_vector is
    variable cntrl_reg : bit_vector (0 to 31) ;
  begin
    cntrl_reg := x"00000000" ;
    cntrl_reg(9 to 11) := to_bit3(C_PPC440MC_PRIO_ICU) ;
    cntrl_reg(13 to 15) := to_bit3(C_PPC440MC_PRIO_DCUW) ;
    cntrl_reg(17 to 19) := to_bit3(C_PPC440MC_PRIO_DCUR) ;
    cntrl_reg(21 to 23) := to_bit3(C_PPC440MC_PRIO_SPLB1) ;
    cntrl_reg(25 to 27) := to_bit3(C_PPC440MC_PRIO_SPLB0) ;
    cntrl_reg(30 to 31) := to_bit2(C_PPC440MC_ARB_MODE) ;
    return cntrl_reg ;
  end function ;

  function F_PPCM_ARBCONFIG return bit_vector is
    variable cntrl_reg : bit_vector (0 to 31) ;
  begin
    cntrl_reg := x"00000000" ;
    cntrl_reg(9 to 11) := to_bit3(C_MPLB_PRIO_ICU) ;
    cntrl_reg(13 to 15) := to_bit3(C_MPLB_PRIO_DCUW) ;
    cntrl_reg(17 to 19) := to_bit3(C_MPLB_PRIO_DCUR) ;
    cntrl_reg(21 to 23) := to_bit3(C_MPLB_PRIO_SPLB1) ;
    cntrl_reg(25 to 27) := to_bit3(C_MPLB_PRIO_SPLB0) ;
    if (C_MPLB_SYNC_TATTRIBUTE > 0) then cntrl_reg(29) := '1'; end if;
    cntrl_reg(30 to 31) := to_bit2(C_MPLB_ARB_MODE) ;
    return cntrl_reg ;
  end function ;

  function F_PPCM_CONTROL return bit_vector is
    variable cntrl_reg : bit_vector (0 to 31) ;
  begin
    cntrl_reg := x"00000000" ;
    cntrl_reg(0) := '1';  -- LOCK_SESR
--    if (C_MPLB_WDOG_ENABLE > 0) then cntrl_reg(23) := '1'; end if; -- Feature retracted
    cntrl_reg(24) := '1';  -- XBAR_PRIORITY_ENA
    cntrl_reg(26) := '0';  -- SL_ETERM_MODE
    if (C_MPLB_ALLOW_LOCK_XFER > 0) then cntrl_reg(27) := '1'; end if;
    if (C_MPLB_READ_PIPE_ENABLE > 0) then cntrl_reg(28) := '1'; end if;
    if (C_MPLB_WRITE_PIPE_ENABLE > 0) then cntrl_reg(29) := '1'; end if;
    if (C_MPLB_WRITE_POST_ENABLE > 0) then cntrl_reg(30) := '1'; end if;
    cntrl_reg(31) := '1';  -- ADDRACK_DLY
    return cntrl_reg ;
  end function ;

  function F_PPCS0_CONTROL return bit_vector is
    variable cntrl_reg : bit_vector (0 to 31) ;
  begin
    cntrl_reg := x"00000000" ;
    cntrl_reg(0) := '1';  -- LOCK_SESR
    if (C_NUM_DMA > 0) then cntrl_reg(3) := '1'; end if; -- DMA0_EN
    if (C_NUM_DMA > 1) then cntrl_reg(2) := '1'; end if; -- DMA1_EN
    cntrl_reg(4 to 5) := C_DMA0_PLB_PRIO ; -- DMA0 priority
    cntrl_reg(6 to 7) := C_DMA1_PLB_PRIO ; -- DMA1 priority
    cntrl_reg(9 to 11) := to_thresh(C_PPC440MC_MAX_BURST) ;
    cntrl_reg(13 to 15) := to_thresh(C_MPLB_MAX_BURST) ;
    cntrl_reg(17 to 19) := to_thresh(C_PPC440MC_MAX_BURST) ;
    cntrl_reg(21 to 23) := to_thresh(C_MPLB_MAX_BURST) ;
    if (C_SPLB0_ALLOW_LOCK_XFER > 0) then cntrl_reg(25) := '1'; end if;
    if (C_SPLB0_READ_PIPE_ENABLE > 0) then cntrl_reg(26) := '1'; end if;
    cntrl_reg(27) := '0';  -- WPIPE
  -- Write posting enable for SPLB must be the same as for MPLB.
    if (C_MPLB_WRITE_POST_ENABLE > 0) then cntrl_reg(28) := '1'; end if;  -- WPOST
    cntrl_reg(29) := '1';  -- ADDRACK_DLY
    return cntrl_reg ;
  end function ;

  function F_PPCS1_CONTROL return bit_vector is
    variable cntrl_reg : bit_vector (0 to 31) ;
  begin
    cntrl_reg := x"00000000" ;
    cntrl_reg(0) := '1';  -- LOCK_SESR
    if (C_NUM_DMA > 2) then cntrl_reg(3) := '1'; end if; -- DMA2_EN
    if (C_NUM_DMA > 3) then cntrl_reg(2) := '1'; end if; -- DMA3_EN
    cntrl_reg(4 to 5) := C_DMA2_PLB_PRIO ; -- DMA2 priority
    cntrl_reg(6 to 7) := C_DMA3_PLB_PRIO ; -- DMA3 priority
    cntrl_reg(9 to 11) := to_thresh(C_PPC440MC_MAX_BURST) ;
    cntrl_reg(13 to 15) := to_thresh(C_MPLB_MAX_BURST) ;
    cntrl_reg(17 to 19) := to_thresh(C_PPC440MC_MAX_BURST) ;
    cntrl_reg(21 to 23) := to_thresh(C_MPLB_MAX_BURST) ;
    if (C_SPLB1_ALLOW_LOCK_XFER > 0) then cntrl_reg(25) := '1'; end if;
    if (C_SPLB1_READ_PIPE_ENABLE > 0) then cntrl_reg(26) := '1'; end if;
    cntrl_reg(27) := '0';  -- WPIPE
  -- Write posting enable for SPLB must be the same as for MPLB.
    if (C_MPLB_WRITE_POST_ENABLE > 0) then cntrl_reg(28) := '1'; end if;  -- WPOST
    cntrl_reg(29) := '1';  -- ADDRACK_DLY
    return cntrl_reg ;
  end function ;

begin

----------------------------------------------------------------------------
-- Top Level Port Assigments
----------------------------------------------------------------------------
  PPC440MCCLKOUT <= CPMMCCLK ;
  PPCMPLBMSIZE <= "10" ;
  PLBPPCS0MASTERID_i 		<= '0' & PLBPPCS0MASTERID ;
  PLBPPCS1MASTERID_i 		<= '0' & PLBPPCS1MASTERID ;
  PPCS0PLBMRDERR 		<= PPCS0PLBMRDERR_i(0 to C_SPLB0_NUM_MASTERS - 1) ;
  PPCS0PLBMWRERR 		<= PPCS0PLBMWRERR_i(0 to C_SPLB0_NUM_MASTERS - 1) ;
  PPCS0PLBMIRQ  		<= PPCS0PLBMIRQ_i(0 to C_SPLB0_NUM_MASTERS - 1) 
    when (C_SPLB0_PROPAGATE_MIRQ = 1) 
    else net_gnd32(0 to C_SPLB0_NUM_MASTERS - 1) ;
  SPLB0_Error       <= PPCS0PLBMIRQ_i ;
  PPCS1PLBMRDERR 		<= PPCS1PLBMRDERR_i(0 to C_SPLB1_NUM_MASTERS - 1) ;
  PPCS1PLBMWRERR 		<= PPCS1PLBMWRERR_i(0 to C_SPLB1_NUM_MASTERS - 1) ;
  PPCS1PLBMIRQ  		<= PPCS1PLBMIRQ_i(0 to C_SPLB1_NUM_MASTERS - 1) 
    when (C_SPLB1_PROPAGATE_MIRQ = 1) 
    else net_gnd32(0 to C_SPLB1_NUM_MASTERS - 1) ;
  SPLB1_Error       <= PPCS1PLBMIRQ_i ;
  PPCMPLBUABUS      <= net_gnd32 ;
  DBGC440DEBUGHALT_i <= DBGC440DEBUGHALT or not DBGC440DEBUGHALTNEG;

  -- If SPLB* busif is unconnected (C_SPLB*_P2P = -1) and DMA is used, drive
  --   SPLB* clock input pin of ppc440 with MPLB clock signal.
  CPMPPCS0PLBCLK_i <= CPMPPCMPLBCLK when C_SPLB0_P2P =-1 and C_NUM_DMA > 0 else CPMPPCS0PLBCLK ;
  CPMPPCS1PLBCLK_i <= CPMPPCMPLBCLK when C_SPLB1_P2P =-1 and C_NUM_DMA > 2 else CPMPPCS1PLBCLK ;

  -- Pipeline trailing edge of PPCS*PLBMBUSY, only for connected pins

    process (CPMPPCS0PLBCLK) is begin
      if CPMPPCS0PLBCLK'event and CPMPPCS0PLBCLK = '1' then
        PPCS0PLBMBUSY_reg <= PPCS0PLBMBUSY_i(0 to C_SPLB0_NUM_MASTERS - 1);
      end if;
    end process;
    PPCS0PLBMBUSY <= PPCS0PLBMBUSY_reg or PPCS0PLBMBUSY_i(0 to C_SPLB0_NUM_MASTERS - 1);

    process (CPMPPCS1PLBCLK) is begin
      if CPMPPCS1PLBCLK'event and CPMPPCS1PLBCLK = '1' then
        PPCS1PLBMBUSY_reg <= PPCS1PLBMBUSY_i(0 to C_SPLB1_NUM_MASTERS - 1);
      end if;
    end process;
    PPCS1PLBMBUSY <= PPCS1PLBMBUSY_reg or PPCS1PLBMBUSY_i(0 to C_SPLB1_NUM_MASTERS - 1);
    
----------------------------------------------------------------------------
-- Instantiate PPC440 Processor Block Primitive
----------------------------------------------------------------------------
  PPC440_i : PPC440
    generic map (
       INTERCONNECT_IMASK 	=> C_INTERCONNECT_IMASK ,
       XBAR_ADDRMAP_TMPL0 	=> F_MemTemplate(C_PPC440MC_ADDR_BASE, C_PPC440MC_ADDR_HIGH, TRUE) ,
       XBAR_ADDRMAP_TMPL1 	=> bit_gnd32 ,
       XBAR_ADDRMAP_TMPL2 	=> bit_gnd32 ,
       XBAR_ADDRMAP_TMPL3 	=> bit_gnd32 ,
       INTERCONNECT_TMPL_SEL 	=> INTERCONNECT_TMPL_SEL_i ,
       CLOCK_DELAY  		=> TRUE ,

       APU_CONTROL 		=> C_APU_CONTROL ,
       APU_UDI0 		=> C_APU_UDI_0 ,
       APU_UDI1 		=> C_APU_UDI_1 ,
       APU_UDI2 		=> C_APU_UDI_2 ,
       APU_UDI3 		=> C_APU_UDI_3 ,
       APU_UDI4 		=> C_APU_UDI_4 ,
       APU_UDI5 		=> C_APU_UDI_5 ,
       APU_UDI6 		=> C_APU_UDI_6 ,
       APU_UDI7 		=> C_APU_UDI_7 ,
       APU_UDI8 		=> C_APU_UDI_8 ,
       APU_UDI9 		=> C_APU_UDI_9 ,
       APU_UDI10 		=> C_APU_UDI_10 ,
       APU_UDI11 		=> C_APU_UDI_11 ,
       APU_UDI12 		=> C_APU_UDI_12 ,
       APU_UDI13 		=> C_APU_UDI_13 ,
       APU_UDI14 		=> C_APU_UDI_14 ,
       APU_UDI15 		=> C_APU_UDI_15 ,

       MI_ROWCONFLICT_MASK 	=> C_PPC440MC_ROW_CONFLICT_MASK ,
       MI_BANKCONFLICT_MASK 	=> C_PPC440MC_BANK_CONFLICT_MASK ,
       MI_ARBCONFIG 	=> F_MI_ARBCONFIG ,
       MI_CONTROL 	=> C_PPC440MC_CONTROL(0 to 29) & "11" ,
       
       PPCM_CONTROL 	=> F_PPCM_CONTROL ,
       PPCM_COUNTER 	=> C_MPLB_COUNTER ,
       PPCM_ARBCONFIG 	=> F_PPCM_ARBCONFIG ,
       
       PPCS0_CONTROL 	=> F_PPCS0_CONTROL ,
       PPCS0_WIDTH_128N64 	=> TRUE ,
       PPCS0_ADDRMAP_TMPL0 	=> F_PPCS0_MemTemplate ,
       PPCS0_ADDRMAP_TMPL1 	=> bit_gnd32 ,
       PPCS0_ADDRMAP_TMPL2 	=> bit_gnd32 ,
       PPCS0_ADDRMAP_TMPL3 	=> bit_gnd32 ,
       
       PPCS1_CONTROL 	=> F_PPCS1_CONTROL ,
       PPCS1_WIDTH_128N64 	=> TRUE ,
       PPCS1_ADDRMAP_TMPL0 	=> F_PPCS1_MemTemplate ,
       PPCS1_ADDRMAP_TMPL1 	=> bit_gnd32 ,
       PPCS1_ADDRMAP_TMPL2 	=> bit_gnd32 ,
       PPCS1_ADDRMAP_TMPL3 	=> bit_gnd32 ,
       
       DMA0_TXCHANNELCTRL 	=> C_DMA0_TXCHANNELCTRL ,
       DMA0_RXCHANNELCTRL 	=> C_DMA0_RXCHANNELCTRL ,
       DMA0_CONTROL 	=> C_DMA0_CONTROL ,
       DMA0_TXIRQTIMER 	=> C_DMA0_TXIRQTIMER ,
       DMA0_RXIRQTIMER 	=> C_DMA0_RXIRQTIMER ,

       DMA1_TXCHANNELCTRL 	=> C_DMA1_TXCHANNELCTRL ,
       DMA1_RXCHANNELCTRL 	=> C_DMA1_RXCHANNELCTRL ,
       DMA1_CONTROL 	=> C_DMA1_CONTROL ,
       DMA1_TXIRQTIMER 	=> C_DMA1_TXIRQTIMER ,
       DMA1_RXIRQTIMER 	=> C_DMA1_RXIRQTIMER ,

       DMA2_TXCHANNELCTRL 	=> C_DMA2_TXCHANNELCTRL ,
       DMA2_RXCHANNELCTRL 	=> C_DMA2_RXCHANNELCTRL ,
       DMA2_CONTROL 	=> C_DMA2_CONTROL ,
       DMA2_TXIRQTIMER 	=> C_DMA2_TXIRQTIMER ,
       DMA2_RXIRQTIMER 	=> C_DMA2_RXIRQTIMER ,

       DMA3_TXCHANNELCTRL 	=> C_DMA3_TXCHANNELCTRL ,
       DMA3_RXCHANNELCTRL 	=> C_DMA3_RXCHANNELCTRL ,
       DMA3_CONTROL 	=> C_DMA3_CONTROL ,
       DMA3_TXIRQTIMER 	=> C_DMA3_TXIRQTIMER ,
       DMA3_RXIRQTIMER 	=> C_DMA3_RXIRQTIMER ,

       DCR_AUTOLOCK_ENABLE 	=> C_DCR_AUTOLOCK_ENABLE = 1 ,
       PPCDM_ASYNCMODE		=> C_PPCDM_ASYNCMODE = 1 ,
       PPCDS_ASYNCMODE		=> C_PPCDS_ASYNCMODE = 1 
    )

    port map (
       TIEC440ENDIANRESET 		=> C_ENDIAN_RESET ,
       TIEC440ERPNRESET 		=> net_gnd32(0 to 3) ,
       TIEC440PIR 		=> C_PIR ,
       TIEC440PVR 		=> net_gnd32(0 to 3) ,
       TIEC440USERRESET 		=> C_USER_RESET ,
       TIEC440ICURDFETCHPLBPRIO 		=> C_ICU_RD_FETCH_PLB_PRIO ,
       TIEC440ICURDSPECPLBPRIO 		=> C_ICU_RD_SPEC_PLB_PRIO ,
       TIEC440ICURDTOUCHPLBPRIO 		=> C_ICU_RD_TOUCH_PLB_PRIO ,
       TIEC440DCURDLDCACHEPLBPRIO 		=> C_DCU_RD_LD_CACHE_PLB_PRIO ,
       TIEC440DCURDNONCACHEPLBPRIO 		=> C_DCU_RD_NONCACHE_PLB_PRIO ,
       TIEC440DCURDTOUCHPLBPRIO 		=> C_DCU_RD_TOUCH_PLB_PRIO ,
       TIEC440DCURDURGENTPLBPRIO 		=> C_DCU_RD_URGENT_PLB_PRIO ,
       TIEC440DCUWRFLUSHPLBPRIO 		=> C_DCU_WR_FLUSH_PLB_PRIO ,
       TIEC440DCUWRSTOREPLBPRIO 		=> C_DCU_WR_STORE_PLB_PRIO ,
       TIEC440DCUWRURGENTPLBPRIO 		=> C_DCU_WR_URGENT_PLB_PRIO ,
       C440MACHINECHECK 		=> C440MACHINECHECK ,
          
       CPMC440CLK 		=> CPMC440CLK ,
       CPMC440CLKEN 		=> CPMC440CLKEN ,
       CPMINTERCONNECTCLK 		=> CPMINTERCONNECTCLK ,
       CPMINTERCONNECTCLKEN 		=> CPMINTERCONNECTCLKEN ,
       CPMINTERCONNECTCLKNTO1 		=> CPMINTERCONNECTCLKNTO1 ,
       CPMC440TIMERCLOCK 		=> CPMC440TIMERCLOCK ,
       CPMC440CORECLOCKINACTIVE 		=> CPMC440CORECLOCKINACTIVE ,
       C440CPMCORESLEEPREQ 		=> C440CPMCORESLEEPREQ ,
       C440CPMDECIRPTREQ 		=> C440CPMDECIRPTREQ ,
       C440CPMFITIRPTREQ 		=> C440CPMFITIRPTREQ ,
       C440CPMMSRCE 		=> C440CPMMSRCE ,
       C440CPMMSREE 		=> C440CPMMSREE ,
       C440CPMTIMERRESETREQ 		=> C440CPMTIMERRESETREQ ,
       C440CPMWDIRPTREQ 		=> C440CPMWDIRPTREQ ,
       PPCCPMINTERCONNECTBUSY 		=> PPCCPMINTERCONNECTBUSY ,
          
       DBGC440DEBUGHALT 		=> DBGC440DEBUGHALT_i ,
       DBGC440SYSTEMSTATUS 		=> DBGC440SYSTEMSTATUS ,
       DBGC440UNCONDDEBUGEVENT 		=> DBGC440UNCONDDEBUGEVENT ,
       C440DBGSYSTEMCONTROL 		=> C440DBGSYSTEMCONTROL ,
          
       DCRPPCDMACK 		=> DCRPPCDMACK ,
       DCRPPCDMDBUSIN 		=> DCRPPCDMDBUSIN ,
       DCRPPCDMTIMEOUTWAIT 		=> DCRPPCDMTIMEOUTWAIT ,
       CPMDCRCLK 		=> CPMDCRCLK ,
       TIEDCRBASEADDR 		=> C_IDCR_BASEADDR(0 to 1) ,
       PPCDMDCRREAD 		=> PPCDMDCRREAD ,
       PPCDMDCRWRITE 		=> PPCDMDCRWRITE ,
       PPCDMDCRABUS 		=> PPCDMDCRABUS ,
       PPCDMDCRUABUS 		=> open ,
       PPCDMDCRDBUSOUT 		=> PPCDMDCRDBUSOUT ,
          
       DCRPPCDSREAD 		=> DCRPPCDSREAD ,
       DCRPPCDSWRITE 		=> DCRPPCDSWRITE ,
       DCRPPCDSABUS 		=> DCRPPCDSABUS ,
       DCRPPCDSDBUSOUT 		=> DCRPPCDSDBUSOUT ,
       PPCDSDCRACK 		=> PPCDSDCRACK ,
       PPCDSDCRDBUSIN 		=> PPCDSDCRDBUSIN ,
       PPCDSDCRTIMEOUTWAIT 		=> PPCDSDCRTIMEOUTWAIT ,
          
       EICC440CRITIRQ 		=> EICC440CRITIRQ ,
       EICC440EXTIRQ 		=> EICC440EXTIRQ ,
       PPCEICINTERCONNECTIRQ  		=> PPCEICINTERCONNECTIRQ ,
          
       FCMAPUCR 		=> FCMAPUCR ,
       FCMAPUDONE 		=> FCMAPUDONE ,
       FCMAPUEXCEPTION 		=> FCMAPUEXCEPTION ,
       FCMAPUFPSCRFEX 		=> FCMAPUFPSCRFEX ,
       FCMAPURESULT 		=> FCMAPURESULT ,
       FCMAPURESULTVALID 		=> FCMAPURESULTVALID ,
       FCMAPUSLEEPNOTREADY 		=> FCMAPUSLEEPNOTREADY ,
       FCMAPUCONFIRMINSTR 		=> FCMAPUCONFIRMINSTR ,
       FCMAPUSTOREDATA 		=> FCMAPUSTOREDATA ,
       CPMFCMCLK 		=> CPMFCMCLK ,
       APUFCMDECNONAUTON 		=> APUFCMDECNONAUTON ,
       APUFCMDECFPUOP 		=> APUFCMDECFPUOP ,
       APUFCMDECLDSTXFERSIZE 		=> APUFCMDECLDSTXFERSIZE ,
       APUFCMDECLOAD 		=> APUFCMDECLOAD ,
       APUFCMNEXTINSTRREADY 		=> APUFCMNEXTINSTRREADY ,
       APUFCMDECSTORE 		=> APUFCMDECSTORE ,
       APUFCMDECUDI 		=> APUFCMDECUDI ,
       APUFCMDECUDIVALID 		=> APUFCMDECUDIVALID ,
       APUFCMENDIAN 		=> APUFCMENDIAN ,
       APUFCMFLUSH 		=> APUFCMFLUSH ,
       APUFCMINSTRUCTION 		=> APUFCMINSTRUCTION ,
       APUFCMINSTRVALID 		=> APUFCMINSTRVALID ,
       APUFCMLOADBYTEADDR 		=> APUFCMLOADBYTEADDR ,
       APUFCMLOADDATA 		=> APUFCMLOADDATA ,
       APUFCMLOADDVALID 		=> APUFCMLOADDVALID ,
       APUFCMOPERANDVALID 		=> APUFCMOPERANDVALID ,
       APUFCMRADATA 		=> APUFCMRADATA ,
       APUFCMRBDATA 		=> APUFCMRBDATA ,
       APUFCMWRITEBACKOK 		=> APUFCMWRITEBACKOK ,
       APUFCMMSRFE0 		=> APUFCMMSRFE0 ,
       APUFCMMSRFE1 		=> APUFCMMSRFE1 ,
          
       JTGC440TCK 		=> JTGC440TCK ,
       JTGC440TDI 		=> JTGC440TDI ,
       JTGC440TMS 		=> JTGC440TMS ,
       JTGC440TRSTNEG 		=> JTGC440TRSTNEG ,
       C440JTGTDO 		=> C440JTGTDO ,
       C440JTGTDOEN 		=> C440JTGTDOEN ,
          
       MCMIREADDATA 		=> MCMIREADDATA ,
       MCMIREADDATAVALID 		=> MCMIREADDATAVALID ,
       MCMIREADDATAERR 		=> MCMIREADDATAERR ,
       MCMIADDRREADYTOACCEPT 		=> MCMIADDRREADYTOACCEPT ,
       CPMMCCLK 		=> CPMMCCLK ,
       MIMCREADNOTWRITE 		=> MIMCREADNOTWRITE ,
       MIMCADDRESS 		=> MIMCADDRESS ,
       MIMCADDRESSVALID 		=> MIMCADDRESSVALID ,
       MIMCWRITEDATA 		=> MIMCWRITEDATA ,
       MIMCWRITEDATAVALID 		=> MIMCWRITEDATAVALID ,
       MIMCBYTEENABLE 		=> MIMCBYTEENABLE ,
       MIMCBANKCONFLICT 		=> MIMCBANKCONFLICT ,
       MIMCROWCONFLICT 		=> MIMCROWCONFLICT ,
          
       PLBPPCMMBUSY 		=> PLBPPCMMBUSY ,
       PLBPPCMMIRQ 		=> PLBPPCMMIRQ ,
       PLBPPCMMRDERR 		=> PLBPPCMMRDERR ,
       PLBPPCMMWRERR 		=> PLBPPCMMWRERR ,
       PLBPPCMADDRACK  		=> PLBPPCMADDRACK  ,
       PLBPPCMRDBTERM 		=> PLBPPCMRDBTERM ,
       PLBPPCMRDDACK 		=> PLBPPCMRDDACK ,
       PLBPPCMRDDBUS   		=> PLBPPCMRDDBUS   ,
       PLBPPCMRDWDADDR 		=> PLBPPCMRDWDADDR ,
       PLBPPCMREARBITRATE 		=> PLBPPCMREARBITRATE ,
       PLBPPCMSSIZE  		=> PLBPPCMSSIZE  ,
       PLBPPCMTIMEOUT  		=> PLBPPCMTIMEOUT  ,
       PLBPPCMWRBTERM  		=> PLBPPCMWRBTERM ,
       PLBPPCMWRDACK  		=> PLBPPCMWRDACK  ,
       PLBPPCMRDPENDPRI 		=> PLBPPCMRDPENDPRI ,
       PLBPPCMRDPENDREQ   		=> PLBPPCMRDPENDREQ   ,
       PLBPPCMREQPRI   		=> PLBPPCMREQPRI   ,
       PLBPPCMWRPENDPRI   		=> PLBPPCMWRPENDPRI   ,
       PLBPPCMWRPENDREQ   		=> PLBPPCMWRPENDREQ   ,
       CPMPPCMPLBCLK 		=> CPMPPCMPLBCLK ,
       PPCMPLBABORT   		=> PPCMPLBABORT   ,
       PPCMPLBABUS    		=> PPCMPLBABUS    ,
       PPCMPLBBE   		=> PPCMPLBBE   ,
       PPCMPLBBUSLOCK   		=> PPCMPLBBUSLOCK   ,
       PPCMPLBLOCKERR   		=> PPCMPLBLOCKERR   ,
       PPCMPLBPRIORITY 		=> PPCMPLBPRIORITY ,
       PPCMPLBRDBURST   		=> PPCMPLBRDBURST   ,
       PPCMPLBREQUEST   		=> PPCMPLBREQUEST   ,
       PPCMPLBRNW   		=> PPCMPLBRNW   ,
       PPCMPLBSIZE  		=> PPCMPLBSIZE  ,
       PPCMPLBTATTRIBUTE   		=> PPCMPLBTATTRIBUTE   ,
       PPCMPLBTYPE   		=> PPCMPLBTYPE   ,
       PPCMPLBUABUS    		=> open    ,
       PPCMPLBWRBURST   		=> PPCMPLBWRBURST   ,
       PPCMPLBWRDBUS   		=> PPCMPLBWRDBUS   ,
          
       PLBPPCS0MASTERID 	=> PLBPPCS0MASTERID_i(C_SPLB0_MID_WIDTH-1 to C_SPLB0_MID_WIDTH) ,
       PLBPPCS0PAVALID 		=> PLBPPCS0PAVALID ,
       PLBPPCS0SAVALID  		=> PLBPPCS0SAVALID  ,
       PLBPPCS0RDPENDREQ  		=> PLBPPCS0RDPENDREQ  ,
       PLBPPCS0WRPENDREQ  		=> PLBPPCS0WRPENDREQ  ,
       PLBPPCS0RDPENDPRI  		=> PLBPPCS0RDPENDPRI  ,
       PLBPPCS0WRPENDPRI   		=> PLBPPCS0WRPENDPRI   ,
       PLBPPCS0REQPRI   		=> PLBPPCS0REQPRI   ,
       PLBPPCS0RDPRIM  		=> PLBPPCS0RDPRIM  ,
       PLBPPCS0WRPRIM  		=> PLBPPCS0WRPRIM  ,
       PLBPPCS0BUSLOCK   		=> PLBPPCS0BUSLOCK   ,
       PLBPPCS0ABORT   		=> PLBPPCS0ABORT ,
       PLBPPCS0RNW  		=>  PLBPPCS0RNW  ,
       PLBPPCS0BE   		=>  PLBPPCS0BE   ,
       PLBPPCS0SIZE   		=> PLBPPCS0SIZE   ,
       PLBPPCS0TYPE   		=> PLBPPCS0TYPE   ,
       PLBPPCS0TATTRIBUTE   		=> PLBPPCS0TATTRIBUTE   ,
       PLBPPCS0LOCKERR   		=> PLBPPCS0LOCKERR   ,
       PLBPPCS0MSIZE 		=> PLBPPCS0MSIZE ,
       PLBPPCS0UABUS   		=> net_gnd32(0 to 3)   ,
       PLBPPCS0ABUS   		=> PLBPPCS0ABUS   ,
       PLBPPCS0WRDBUS 		=> PLBPPCS0WRDBUS ,
       PLBPPCS0WRBURST   		=> PLBPPCS0WRBURST   ,
       PLBPPCS0RDBURST   		=> PLBPPCS0RDBURST   ,
       CPMPPCS0PLBCLK 		=> CPMPPCS0PLBCLK_i ,
       PPCS0PLBADDRACK    		=> PPCS0PLBADDRACK    ,
       PPCS0PLBWAIT  		=> PPCS0PLBWAIT  ,
       PPCS0PLBREARBITRATE     		=> PPCS0PLBREARBITRATE     ,
       PPCS0PLBWRDACK   		=> PPCS0PLBWRDACK   ,
       PPCS0PLBWRCOMP   		=> PPCS0PLBWRCOMP   ,
       PPCS0PLBRDDBUS   		=> PPCS0PLBRDDBUS   ,
       PPCS0PLBRDWDADDR  		=> PPCS0PLBRDWDADDR  ,
       PPCS0PLBRDDACK   		=> PPCS0PLBRDDACK   ,
       PPCS0PLBRDCOMP   		=> PPCS0PLBRDCOMP   ,
       PPCS0PLBRDBTERM   		=> PPCS0PLBRDBTERM   ,
       PPCS0PLBWRBTERM   		=> PPCS0PLBWRBTERM   ,
       PPCS0PLBMBUSY 		=> PPCS0PLBMBUSY_i ,
       PPCS0PLBMRDERR 		=> PPCS0PLBMRDERR_i ,
       PPCS0PLBMWRERR 		=> PPCS0PLBMWRERR_i ,
       PPCS0PLBMIRQ 		=> PPCS0PLBMIRQ_i ,
       PPCS0PLBSSIZE   		=> PPCS0PLBSSIZE   ,
          
       PLBPPCS1MASTERID 	=> PLBPPCS1MASTERID_i(C_SPLB1_MID_WIDTH-1 to C_SPLB1_MID_WIDTH) ,
       PLBPPCS1PAVALID  		=> PLBPPCS1PAVALID  ,
       PLBPPCS1SAVALID  		=> PLBPPCS1SAVALID  ,
       PLBPPCS1RDPENDREQ  		=> PLBPPCS1RDPENDREQ  ,
       PLBPPCS1WRPENDREQ  		=> PLBPPCS1WRPENDREQ  ,
       PLBPPCS1RDPENDPRI  		=> PLBPPCS1RDPENDPRI  ,
       PLBPPCS1WRPENDPRI   		=> PLBPPCS1WRPENDPRI   ,
       PLBPPCS1REQPRI   		=> PLBPPCS1REQPRI   ,
       PLBPPCS1RDPRIM  		=> PLBPPCS1RDPRIM  ,
       PLBPPCS1WRPRIM  		=> PLBPPCS1WRPRIM  ,
       PLBPPCS1BUSLOCK   		=> PLBPPCS1BUSLOCK   ,
       PLBPPCS1ABORT   		=> PLBPPCS1ABORT ,
       PLBPPCS1RNW  		=>  PLBPPCS1RNW  ,
       PLBPPCS1BE   		=>  PLBPPCS1BE   ,
       PLBPPCS1SIZE   		=> PLBPPCS1SIZE   ,
       PLBPPCS1TYPE   		=> PLBPPCS1TYPE   ,
       PLBPPCS1TATTRIBUTE   		=> PLBPPCS1TATTRIBUTE   ,
       PLBPPCS1LOCKERR   		=> PLBPPCS1LOCKERR   ,
       PLBPPCS1MSIZE 		=> PLBPPCS1MSIZE ,
       PLBPPCS1UABUS   		=> net_gnd32(0 to 3)   ,
       PLBPPCS1ABUS   		=> PLBPPCS1ABUS   ,
       PLBPPCS1WRDBUS 		=> PLBPPCS1WRDBUS ,
       PLBPPCS1WRBURST   		=> PLBPPCS1WRBURST   ,
       PLBPPCS1RDBURST   		=> PLBPPCS1RDBURST   ,
       CPMPPCS1PLBCLK 		=> CPMPPCS1PLBCLK_i ,
       PPCS1PLBADDRACK    		=> PPCS1PLBADDRACK    ,
       PPCS1PLBWAIT  		=> PPCS1PLBWAIT  ,
       PPCS1PLBREARBITRATE     		=> PPCS1PLBREARBITRATE     ,
       PPCS1PLBWRDACK   		=> PPCS1PLBWRDACK   ,
       PPCS1PLBWRCOMP   		=> PPCS1PLBWRCOMP   ,
       PPCS1PLBRDDBUS   		=> PPCS1PLBRDDBUS   ,
       PPCS1PLBRDWDADDR  		=> PPCS1PLBRDWDADDR  ,
       PPCS1PLBRDDACK   		=> PPCS1PLBRDDACK   ,
       PPCS1PLBRDCOMP   		=> PPCS1PLBRDCOMP   ,
       PPCS1PLBRDBTERM   		=> PPCS1PLBRDBTERM   ,
       PPCS1PLBWRBTERM   		=> PPCS1PLBWRBTERM   ,
       PPCS1PLBMBUSY 		=> PPCS1PLBMBUSY_i ,
       PPCS1PLBMRDERR  		=> PPCS1PLBMRDERR_i  ,
       PPCS1PLBMWRERR 		=> PPCS1PLBMWRERR_i ,
       PPCS1PLBMIRQ 		=> PPCS1PLBMIRQ_i ,
       PPCS1PLBSSIZE   		=> PPCS1PLBSSIZE   ,
          
       LLDMA0TXDSTRDYN	 => 	LLDMA0TXDSTRDYN		 ,
       LLDMA0RXD	 => 	LLDMA0RXD		 ,
       LLDMA0RXREM	 => 	LLDMA0RXREM		 ,
       LLDMA0RXSOFN	 => 	LLDMA0RXSOFN		 ,
       LLDMA0RXEOFN	 => 	LLDMA0RXEOFN		 ,
       LLDMA0RXSOPN	 => 	LLDMA0RXSOPN		 ,
       LLDMA0RXEOPN	 => 	LLDMA0RXEOPN		 ,
       LLDMA0RXSRCRDYN	 => 	LLDMA0RXSRCRDYN		 ,
       LLDMA0RSTENGINEREQ	 => 	LLDMA0RSTENGINEREQ		 ,
       CPMDMA0LLCLK	 => 	CPMDMA0LLCLK		 ,
       DMA0LLTXD	 => 	DMA0LLTXD		 ,
       DMA0LLTXREM	 => 	DMA0LLTXREM		 ,
       DMA0LLTXSOFN	 => 	DMA0LLTXSOFN		 ,
       DMA0LLTXEOFN	 => 	DMA0LLTXEOFN		 ,
       DMA0LLTXSOPN	 => 	DMA0LLTXSOPN		 ,
       DMA0LLTXEOPN	 => 	DMA0LLTXEOPN		 ,
       DMA0LLTXSRCRDYN	 => 	DMA0LLTXSRCRDYN		 ,
       DMA0LLRXDSTRDYN	 => 	DMA0LLRXDSTRDYN		 ,
       DMA0LLRSTENGINEACK	 => 	DMA0LLRSTENGINEACK		 ,
       DMA0TXIRQ	 => 	DMA0TXIRQ		 ,
       DMA0RXIRQ	 => 	DMA0RXIRQ		 ,
          
       LLDMA1TXDSTRDYN	 => 	LLDMA1TXDSTRDYN		 ,
       LLDMA1RXD	 => 	LLDMA1RXD		 ,
       LLDMA1RXREM	 => 	LLDMA1RXREM		 ,
       LLDMA1RXSOFN	 => 	LLDMA1RXSOFN		 ,
       LLDMA1RXEOFN	 => 	LLDMA1RXEOFN		 ,
       LLDMA1RXSOPN	 => 	LLDMA1RXSOPN		 ,
       LLDMA1RXEOPN	 => 	LLDMA1RXEOPN		 ,
       LLDMA1RXSRCRDYN	 => 	LLDMA1RXSRCRDYN		 ,
       LLDMA1RSTENGINEREQ	 => 	LLDMA1RSTENGINEREQ		 ,
       CPMDMA1LLCLK	 => 	CPMDMA1LLCLK		 ,
       DMA1LLTXD	 => 	DMA1LLTXD		 ,
       DMA1LLTXREM	 => 	DMA1LLTXREM		 ,
       DMA1LLTXSOFN	 => 	DMA1LLTXSOFN		 ,
       DMA1LLTXEOFN	 => 	DMA1LLTXEOFN		 ,
       DMA1LLTXSOPN	 => 	DMA1LLTXSOPN		 ,
       DMA1LLTXEOPN	 => 	DMA1LLTXEOPN		 ,
       DMA1LLTXSRCRDYN	 => 	DMA1LLTXSRCRDYN		 ,
       DMA1LLRXDSTRDYN	 => 	DMA1LLRXDSTRDYN		 ,
       DMA1LLRSTENGINEACK	 => 	DMA1LLRSTENGINEACK		 ,
       DMA1TXIRQ	 => 	DMA1TXIRQ		 ,
       DMA1RXIRQ	 => 	DMA1RXIRQ		 ,
          
       LLDMA2TXDSTRDYN	 => 	LLDMA2TXDSTRDYN		 ,
       LLDMA2RXD	 => 	LLDMA2RXD		 ,
       LLDMA2RXREM	 => 	LLDMA2RXREM		 ,
       LLDMA2RXSOFN	 => 	LLDMA2RXSOFN		 ,
       LLDMA2RXEOFN	 => 	LLDMA2RXEOFN		 ,
       LLDMA2RXSOPN	 => 	LLDMA2RXSOPN		 ,
       LLDMA2RXEOPN	 => 	LLDMA2RXEOPN		 ,
       LLDMA2RXSRCRDYN	 => 	LLDMA2RXSRCRDYN		 ,
       LLDMA2RSTENGINEREQ	 => 	LLDMA2RSTENGINEREQ		 ,
       CPMDMA2LLCLK	 => 	CPMDMA2LLCLK		 ,
       DMA2LLTXD	 => 	DMA2LLTXD		 ,
       DMA2LLTXREM	 => 	DMA2LLTXREM		 ,
       DMA2LLTXSOFN	 => 	DMA2LLTXSOFN		 ,
       DMA2LLTXEOFN	 => 	DMA2LLTXEOFN		 ,
       DMA2LLTXSOPN	 => 	DMA2LLTXSOPN		 ,
       DMA2LLTXEOPN	 => 	DMA2LLTXEOPN		 ,
       DMA2LLTXSRCRDYN	 => 	DMA2LLTXSRCRDYN		 ,
       DMA2LLRXDSTRDYN	 => 	DMA2LLRXDSTRDYN		 ,
       DMA2LLRSTENGINEACK	 => 	DMA2LLRSTENGINEACK		 ,
       DMA2TXIRQ	 => 	DMA2TXIRQ		 ,
       DMA2RXIRQ	 => 	DMA2RXIRQ		 ,
          
       LLDMA3TXDSTRDYN	 => 	LLDMA3TXDSTRDYN		 ,
       LLDMA3RXD	 => 	LLDMA3RXD		 ,
       LLDMA3RXREM	 => 	LLDMA3RXREM		 ,
       LLDMA3RXSOFN	 => 	LLDMA3RXSOFN		 ,
       LLDMA3RXEOFN	 => 	LLDMA3RXEOFN		 ,
       LLDMA3RXSOPN	 => 	LLDMA3RXSOPN		 ,
       LLDMA3RXEOPN	 => 	LLDMA3RXEOPN		 ,
       LLDMA3RXSRCRDYN	 => 	LLDMA3RXSRCRDYN		 ,
       LLDMA3RSTENGINEREQ	 => 	LLDMA3RSTENGINEREQ		 ,
       CPMDMA3LLCLK	 => 	CPMDMA3LLCLK		 ,
       DMA3LLTXD	 => 	DMA3LLTXD		 ,
       DMA3LLTXREM	 => 	DMA3LLTXREM		 ,
       DMA3LLTXSOFN	 => 	DMA3LLTXSOFN		 ,
       DMA3LLTXEOFN	 => 	DMA3LLTXEOFN		 ,
       DMA3LLTXSOPN	 => 	DMA3LLTXSOPN		 ,
       DMA3LLTXEOPN	 => 	DMA3LLTXEOPN		 ,
       DMA3LLTXSRCRDYN	 => 	DMA3LLTXSRCRDYN		 ,
       DMA3LLRXDSTRDYN	 => 	DMA3LLRXDSTRDYN		 ,
       DMA3LLRSTENGINEACK	 => 	DMA3LLRSTENGINEACK		 ,
       DMA3TXIRQ	 => 	DMA3TXIRQ		 ,
       DMA3RXIRQ	 => 	DMA3RXIRQ		 ,
          
       RSTC440RESETCORE 		=> RSTC440RESETCORE ,
       RSTC440RESETCHIP 		=> RSTC440RESETCHIP ,
       RSTC440RESETSYSTEM 		=> RSTC440RESETSYSTEM ,
       C440RSTCORERESETREQ 		=> C440RSTCORERESETREQ ,
       C440RSTCHIPRESETREQ 		=> C440RSTCHIPRESETREQ ,
       C440RSTSYSTEMRESETREQ 		=> C440RSTSYSTEMRESETREQ ,
          
       TRCC440TRACEDISABLE 		=> TRCC440TRACEDISABLE ,
       TRCC440TRIGGEREVENTIN 		=> TRCC440TRIGGEREVENTIN ,
       C440TRCBRANCHSTATUS 		=> C440TRCBRANCHSTATUS ,
       C440TRCCYCLE 		=> C440TRCCYCLE ,
       C440TRCEXECUTIONSTATUS 		=> C440TRCEXECUTIONSTATUS ,
       C440TRCTRACESTATUS 		=> C440TRCTRACESTATUS ,
       C440TRCTRIGGEREVENTOUT 		=> C440TRCTRIGGEREVENTOUT ,
       C440TRCTRIGGEREVENTTYPE 		=> C440TRCTRIGGEREVENTTYPE 
    );
end structure;

