-------------------------------------------------------------------------------
-- Title         : Pretty Good Protocol, V2, GTP Wrapper
-- Project       : General Purpose Core
-------------------------------------------------------------------------------
-- File          : EthClientGtp.vhd
-- Author        : Raghuveer Ausoori, ausoori@slac.stanford.edu
-- Created       : 10/26/2010
-------------------------------------------------------------------------------
-- Description:
-- VHDL source file containing the PGP, GTP and CRC blocks.
-- This module also contains the logic to control the reset of the GTP.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 by Raghuveer Ausoori. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 10/26/2010: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
use work.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.EthClientPackage.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;


entity EthClientGtp is 
   generic (
      UdpPort      : integer := 8192         -- Enable short non-EOF cells
   );
   port (

      -- System clock, reset & control
      gtpClk       : in  std_logic;          -- 125Mhz master clock
      gtpClkOut    : out std_logic;          -- 125Mhz gtp clock out
      gtpClkRef    : in  std_logic;          -- 125Mhz reference clock
      gtpClkRst    : in  std_logic;          -- Synchronous reset input

      -- Ethernet Constants
      ipAddr       : in  IPAddrType;
      macAddr      : in  MacAddrType;

      -- UDP Transmit interface
      udpTxValid   : in  std_logic;
      udpTxEOF     : in  std_logic;
      udpTxReady   : out std_logic;
      udpTxData    : in  std_logic_vector(63 downto 0);
      udpTxLength  : in  std_logic_vector(15 downto 0);

      -- UDP Receive interface
      udpRxValid   : out std_logic;
      udpRxSOF     : out std_logic;
      udpRxEOF     : out std_logic;
      udpRxWidth   : out std_logic;
      udpRxData    : out std_logic_vector(63 downto 0);
      udpRxGood    : out std_logic;
      udpRxError   : out std_logic;

      -- GTP Signals
      gtpRxN       : in  std_logic;          -- GTP Serial Receive Negative
      gtpRxP       : in  std_logic;          -- GTP Serial Receive Positive
      gtpTxN       : out std_logic;          -- GTP Serial Transmit Negative
      gtpTxP       : out std_logic;          -- GTP Serial Transmit Positive

      -- Debug
      cScopeCtrl1  : inout std_logic_vector(35 downto 0);
      cScopeCtrl2  : inout std_logic_vector(35 downto 0)
   );

end EthClientGtp;


-- Define architecture
architecture EthClientGtp of EthClientGtp is

   -- Local Signals
   
   -- GTP Signals
   signal gtpRxCharIsK      : std_logic_vector(1  downto 0);
   signal gtpRxCharIsComma  : std_logic_vector(1  downto 0);
   signal locGtpRxCharIsK   : std_logic_vector(1  downto 0);
   signal gtpRxDispErr      : std_logic_vector(1  downto 0);
   signal gtpRxNotInTable   : std_logic_vector(1  downto 0);
   signal gtpRxRunDisp      : std_logic_vector(1  downto 0);
   signal locGtpRxRunDisp   : std_logic_vector(1  downto 0);
   signal gtpRxData         : std_logic_vector(15 downto 0);
   signal locGtpRxData      : std_logic_vector(15 downto 0);
   signal gtpTxData         : std_logic_vector(15 downto 0);
   signal gtpRxClkCorCnt    : std_logic_vector(2 downto 0);
   signal gtpPhyRxReAlign   : std_logic;
   signal intRxRecClk       : std_logic;
   signal gtpRxElecIdle     : std_logic;
   signal gtpRxBuffStatus   : std_logic_vector(2  downto 0);
   signal gtpLockDetect     : std_logic;
   signal gtpRstDone        : std_logic;
   signal gtpTxBuffStatus   : std_logic_vector(1  downto 0);
   signal gtpLoopback       : std_logic;
   
   -- EMAC Signals
   signal emacRxData        : std_logic_vector(7  downto 0);
   signal emacRxValid       : std_logic;
   signal emacRxGoodFrame   : std_logic;
   signal emacRxBadFrame    : std_logic;
   signal emacRxFrameDrop   : std_logic;
   signal emacRxStats       : std_logic_vector(6  downto 0);
   signal emacRxStatsValid  : std_logic;
   signal emacRxStatsByteValid: std_logic;
   signal emacRxReset       : std_logic;
   signal emacTxReset       : std_logic;
   signal emacTxData        : std_logic_vector(7  downto 0);
   signal emacTxValid       : std_logic;
   signal emacTxAck         : std_logic;
   signal emacTxFirst       : std_logic;
   signal emacGtxClk        : std_logic;
   signal emacPowerDown     : std_logic;
   signal emacCommaAlign    : std_logic;
   signal emacLoopBack      : std_logic;
   signal emacSignalDetect  : std_logic;
   signal emacTxCharIsK     : std_logic_vector(1  downto 0);
   signal emacTxCharDispVal : std_logic_vector(1  downto 0);
   signal emacTxCharDispMode: std_logic;
   constant EMAC0_LINKTIMERVAL : bit_vector := x"13D";
   signal emacRst           : std_logic;
   signal reset_r           : std_logic_vector(3 downto 0);
   
   -- Debug
   signal   cScopeTrig   : std_logic_vector(63 downto 0);
   signal locEmacTxData  : std_logic_vector(7 downto 0);
   constant enChipScope  : std_logic := '0';

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;
   

begin     
          
   
   -----------------------------
   -- Chipscope for debug
   -----------------------------

   -- Debug Signals
--    cScopeTrig (63 downto 62) <= emacTxCharDispVal;
--    cScopeTrig (61 downto 60) <= (OTHERS => '0');
--    cScopeTrig (59 downto 58) <= emacTxCharIsK;
--    cScopeTrig (57 downto 50) <= gtpTxData(7 downto 0);
--    cScopeTrig (49)           <= emacTxFirst;
--    cScopeTrig (48)           <= emacTxAck;
--    cScopeTrig (47)           <= emacTxValid;
-- --    cScopeTrig (46 downto 39) <= emacTxData;
--    cScopeTrig (46)           <= '0';
--    cScopeTrig (45 downto 39) <= emacRxStats;
--    cScopeTrig (38)           <= emacRxGoodFrame;
--    cScopeTrig (37)           <= emacRxBadFrame;
--    cScopeTrig (36)           <= emacRxValid;
--    cScopeTrig (35 downto 28) <= emacRxData;
--    cScopeTrig (27 downto 26) <= gtpRxCharIsComma;
--    cScopeTrig (25)           <= emacRxStatsByteValid;
--    cScopeTrig (24)           <= emacRxFrameDrop;
--    cScopeTrig (23)           <= emacRxStatsValid;
--    cScopeTrig (22 downto 21) <= gtpTxBuffStatus;
--    cScopeTrig (20 downto 19) <= gtpClkRst & emacRst;
--    cScopeTrig (18 downto 16) <= gtpRxBuffStatus;
--    cScopeTrig (15 downto 14) <= gtpRxDispErr;
--    cScopeTrig (13 downto 12) <= gtpRxNotInTable;
--    cScopeTrig (11 downto 10) <= gtpRxRunDisp;
--    cScopeTrig (9  downto 8)  <= gtpRxCharIsK;
--    cScopeTrig (7  downto 0)  <= gtpRxData(7 downto 0);
   
   -- Chipscope logic analyzer
   chipscope : if (enChipScope = '1') generate
   U_EthClientGtp_ila : v5_Ila port map ( control => cScopeCtrl1,
                                          clk     => gtpClkRef,
                                          trig0   => cscopeTrig);
   end generate chipscope;

   -- Connect GTP Electrical Idle to EMAC Signal Detect
   emacSignalDetect <= not gtpRxElecIdle after tpd;
   
   -- Asserting the reset of the EMAC for four clock cycles
   process(gtpClkRef, gtpClkRst)
   begin
       if (gtpClkRst = '1') then
           reset_r <= "1111";
       elsif rising_edge(gtpClkRef) then
         if (gtpLockDetect = '1') then
           reset_r <= reset_r(2 downto 0) & gtpClkRst;
         end if;
       end if;
   end process;

   -- The reset pulse is now several clock cycles in duration
   emacRst <= reset_r(3);
   
   ----------------------------- GTP_DUAL Instance  --------------------------   
   U_GTP:GTP_DUAL
    generic map
    (

        --_______________________ Simulation-Only Attributes ___________________
        SIM_RECEIVER_DETECT_PASS0   =>       TRUE,
        SIM_RECEIVER_DETECT_PASS1   =>       TRUE,
        SIM_GTPRESET_SPEEDUP        =>       0,
        SIM_PLL_PERDIV2             =>       x"190",
        SIM_MODE                    =>       "FAST",

        --___________________________ Shared Attributes ________________________

        -------------------------- Tile and PLL Attributes ---------------------

        CLK25_DIVIDER               =>       5, 
        CLKINDC_B                   =>       TRUE,
        OOB_CLK_DIVIDER             =>       4,
        OVERSAMPLE_MODE             =>       FALSE,
        PLL_DIVSEL_FB               =>       2,
        PLL_DIVSEL_REF              =>       1,
        PLL_TXDIVSEL_COMM_OUT       =>       1,
        TX_SYNC_FILTERB             =>       1,   


        --____________________ Transmit Interface Attributes ___________________

        ------------------- TX Buffering and Phase Alignment -------------------   

        TX_BUFFER_USE_0             =>       TRUE,
        TX_XCLK_SEL_0               =>       "TXOUT",
        TXRX_INVERT_0               =>       "00000",        

        TX_BUFFER_USE_1             =>       TRUE,
        TX_XCLK_SEL_1               =>       "TXOUT",
        TXRX_INVERT_1               =>       "00000",        

        --------------------- TX Serial Line Rate settings ---------------------   

        PLL_TXDIVSEL_OUT_0          =>       2,

        PLL_TXDIVSEL_OUT_1          =>       2,

        --------------------- TX Driver and OOB signalling --------------------  

        TX_DIFF_BOOST_0             =>       TRUE,

        TX_DIFF_BOOST_1             =>       TRUE,

        ------------------ TX Pipe Control for PCI Express/SATA ---------------

        COM_BURST_VAL_0             =>       "1111",

        COM_BURST_VAL_1             =>       "1111",
        --_______________________ Receive Interface Attributes ________________

        ------------ RX Driver,OOB signalling,Coupling and Eq,CDR -------------  

        AC_CAP_DIS_0                =>       TRUE,
        OOBDETECT_THRESHOLD_0       =>       "001",
        PMA_CDR_SCAN_0              =>       x"6c07640",
        PMA_RX_CFG_0                =>       x"09f0088",
        RCV_TERM_GND_0              =>       FALSE,
        RCV_TERM_MID_0              =>       FALSE,
        RCV_TERM_VTTRX_0            =>       FALSE,
        TERMINATION_IMP_0           =>       50,

        AC_CAP_DIS_1                =>       TRUE,
        OOBDETECT_THRESHOLD_1       =>       "001",
        PMA_CDR_SCAN_1              =>       x"6c07640",
        PMA_RX_CFG_1                =>       x"09f0088",  
        RCV_TERM_GND_1              =>       FALSE,
        RCV_TERM_MID_1              =>       FALSE,
        RCV_TERM_VTTRX_1            =>       FALSE,
        TERMINATION_IMP_1           =>       50,

        PCS_COM_CFG                 =>       x"1680a0e",
        TERMINATION_CTRL            =>       "10100",
        TERMINATION_OVRD            =>       FALSE,

        --------------------- RX Serial Line Rate Attributes ------------------   

        PLL_RXDIVSEL_OUT_0          =>       2,
        PLL_SATA_0                  =>       FALSE,

        PLL_RXDIVSEL_OUT_1          =>       2,
        PLL_SATA_1                  =>       FALSE,

        ----------------------- PRBS Detection Attributes ---------------------  

        PRBS_ERR_THRESHOLD_0        =>       x"00000001",

        PRBS_ERR_THRESHOLD_1        =>       x"00000001",

        ---------------- Comma Detection and Alignment Attributes -------------  

        ALIGN_COMMA_WORD_0          =>       1,
        COMMA_10B_ENABLE_0          =>       "0001111111",
        COMMA_DOUBLE_0              =>       FALSE,
        DEC_MCOMMA_DETECT_0         =>       TRUE,
        DEC_PCOMMA_DETECT_0         =>       TRUE,
        DEC_VALID_COMMA_ONLY_0      =>       FALSE,
        MCOMMA_10B_VALUE_0          =>       "1010000011",
        MCOMMA_DETECT_0             =>       TRUE,
        PCOMMA_10B_VALUE_0          =>       "0101111100",
        PCOMMA_DETECT_0             =>       TRUE,
        RX_SLIDE_MODE_0             =>       "PCS",

        ALIGN_COMMA_WORD_1          =>       1,
        COMMA_10B_ENABLE_1          =>       "0001111111",
        COMMA_DOUBLE_1              =>       FALSE,
        DEC_MCOMMA_DETECT_1         =>       TRUE,
        DEC_PCOMMA_DETECT_1         =>       TRUE,
        DEC_VALID_COMMA_ONLY_1      =>       FALSE,
        MCOMMA_10B_VALUE_1          =>       "1010000011",
        MCOMMA_DETECT_1             =>       TRUE,
        PCOMMA_10B_VALUE_1          =>       "0101111100",
        PCOMMA_DETECT_1             =>       TRUE,
        RX_SLIDE_MODE_1             =>       "PCS",

        ------------------ RX Loss-of-sync State Machine Attributes -----------  

        RX_LOSS_OF_SYNC_FSM_0       =>       FALSE,
        RX_LOS_INVALID_INCR_0       =>       8,
        RX_LOS_THRESHOLD_0          =>       128,

        RX_LOSS_OF_SYNC_FSM_1       =>       FALSE,
        RX_LOS_INVALID_INCR_1       =>       8,
        RX_LOS_THRESHOLD_1          =>       128,

        -------------- RX Elastic Buffer and Phase alignment Attributes -------   

        RX_BUFFER_USE_0             =>       TRUE,
        RX_XCLK_SEL_0               =>       "RXREC",

        RX_BUFFER_USE_1             =>       TRUE,
        RX_XCLK_SEL_1               =>       "RXREC",                   

        ------------------------ Clock Correction Attributes ------------------   

        CLK_CORRECT_USE_0           =>       TRUE,
        CLK_COR_ADJ_LEN_0           =>       2,
        CLK_COR_DET_LEN_0           =>       2,
        CLK_COR_INSERT_IDLE_FLAG_0  =>       FALSE,
        CLK_COR_KEEP_IDLE_0         =>       FALSE,
        CLK_COR_MAX_LAT_0           =>       18,
        CLK_COR_MIN_LAT_0           =>       16,
        CLK_COR_PRECEDENCE_0        =>       TRUE,
        CLK_COR_REPEAT_WAIT_0       =>       0,
        CLK_COR_SEQ_1_1_0           =>       "0110111100",
        CLK_COR_SEQ_1_2_0           =>       "0001010000",
        CLK_COR_SEQ_1_3_0           =>       "0000000000",
        CLK_COR_SEQ_1_4_0           =>       "0000000000",
        CLK_COR_SEQ_1_ENABLE_0      =>       "0011",
        CLK_COR_SEQ_2_1_0           =>       "0110111100",
        CLK_COR_SEQ_2_2_0           =>       "0010110101",
        CLK_COR_SEQ_2_3_0           =>       "0000000000",
        CLK_COR_SEQ_2_4_0           =>       "0000000000",
        CLK_COR_SEQ_2_ENABLE_0      =>       "0011",
        CLK_COR_SEQ_2_USE_0         =>       TRUE,
        RX_DECODE_SEQ_MATCH_0       =>       TRUE,

        CLK_CORRECT_USE_1           =>       TRUE,
        CLK_COR_ADJ_LEN_1           =>       2,
        CLK_COR_DET_LEN_1           =>       2,
        CLK_COR_INSERT_IDLE_FLAG_1  =>       FALSE,
        CLK_COR_KEEP_IDLE_1         =>       FALSE,
        CLK_COR_MAX_LAT_1           =>       18,
        CLK_COR_MIN_LAT_1           =>       16,
        CLK_COR_PRECEDENCE_1        =>       TRUE,
        CLK_COR_REPEAT_WAIT_1       =>       0,
        CLK_COR_SEQ_1_1_1           =>       "0110111100",
        CLK_COR_SEQ_1_2_1           =>       "0001010000",
        CLK_COR_SEQ_1_3_1           =>       "0000000000",
        CLK_COR_SEQ_1_4_1           =>       "0000000000",
        CLK_COR_SEQ_1_ENABLE_1      =>       "0011",
        CLK_COR_SEQ_2_1_1           =>       "0110111100",
        CLK_COR_SEQ_2_2_1           =>       "0010110101",
        CLK_COR_SEQ_2_3_1           =>       "0000000000",
        CLK_COR_SEQ_2_4_1           =>       "0000000000",
        CLK_COR_SEQ_2_ENABLE_1      =>       "0011",
        CLK_COR_SEQ_2_USE_1         =>       TRUE,
        RX_DECODE_SEQ_MATCH_1       =>       TRUE,

        ------------------------ Channel Bonding Attributes -------------------   

        CHAN_BOND_1_MAX_SKEW_0      =>       7,
        CHAN_BOND_2_MAX_SKEW_0      =>       7,
        CHAN_BOND_LEVEL_0           =>       0,
        CHAN_BOND_MODE_0            =>       "OFF",
        CHAN_BOND_SEQ_1_1_0         =>       "0000000000",
        CHAN_BOND_SEQ_1_2_0         =>       "0000000000",
        CHAN_BOND_SEQ_1_3_0         =>       "0000000000",
        CHAN_BOND_SEQ_1_4_0         =>       "0000000000",
        CHAN_BOND_SEQ_1_ENABLE_0    =>       "0000",
        CHAN_BOND_SEQ_2_1_0         =>       "0000000000",
        CHAN_BOND_SEQ_2_2_0         =>       "0000000000",
        CHAN_BOND_SEQ_2_3_0         =>       "0000000000",
        CHAN_BOND_SEQ_2_4_0         =>       "0000000000",
        CHAN_BOND_SEQ_2_ENABLE_0    =>       "0000",
        CHAN_BOND_SEQ_2_USE_0       =>       FALSE,  
        CHAN_BOND_SEQ_LEN_0         =>       1,
        PCI_EXPRESS_MODE_0          =>       FALSE,   
     
        CHAN_BOND_1_MAX_SKEW_1      =>       7,
        CHAN_BOND_2_MAX_SKEW_1      =>       7,
        CHAN_BOND_LEVEL_1           =>       0,
        CHAN_BOND_MODE_1            =>       "OFF",
        CHAN_BOND_SEQ_1_1_1         =>       "0000000000",
        CHAN_BOND_SEQ_1_2_1         =>       "0000000000",
        CHAN_BOND_SEQ_1_3_1         =>       "0000000000",
        CHAN_BOND_SEQ_1_4_1         =>       "0000000000",
        CHAN_BOND_SEQ_1_ENABLE_1    =>       "0000",
        CHAN_BOND_SEQ_2_1_1         =>       "0000000000",
        CHAN_BOND_SEQ_2_2_1         =>       "0000000000",
        CHAN_BOND_SEQ_2_3_1         =>       "0000000000",
        CHAN_BOND_SEQ_2_4_1         =>       "0000000000",
        CHAN_BOND_SEQ_2_ENABLE_1    =>       "0000",
        CHAN_BOND_SEQ_2_USE_1       =>       FALSE,  
        CHAN_BOND_SEQ_LEN_1         =>       1,
        PCI_EXPRESS_MODE_1          =>       FALSE,

        ------------------ RX Attributes for PCI Express/SATA ---------------

        RX_STATUS_FMT_0             =>       "PCIE",
        SATA_BURST_VAL_0            =>       "100",
        SATA_IDLE_VAL_0             =>       "100",
        SATA_MAX_BURST_0            =>       9,
        SATA_MAX_INIT_0             =>       27,
        SATA_MAX_WAKE_0             =>       9,
        SATA_MIN_BURST_0            =>       5,
        SATA_MIN_INIT_0             =>       15,
        SATA_MIN_WAKE_0             =>       5,
        TRANS_TIME_FROM_P2_0        =>       x"0060",
        TRANS_TIME_NON_P2_0         =>       x"0025",
        TRANS_TIME_TO_P2_0          =>       x"0100",

        RX_STATUS_FMT_1             =>       "PCIE",
        SATA_BURST_VAL_1            =>       "100",
        SATA_IDLE_VAL_1             =>       "100",
        SATA_MAX_BURST_1            =>       9,
        SATA_MAX_INIT_1             =>       27,
        SATA_MAX_WAKE_1             =>       9,
        SATA_MIN_BURST_1            =>       5,
        SATA_MIN_INIT_1             =>       15,
        SATA_MIN_WAKE_1             =>       5,
        TRANS_TIME_FROM_P2_1        =>       x"0060",
        TRANS_TIME_NON_P2_1         =>       x"0025",
        TRANS_TIME_TO_P2_1          =>       x"0100"
    ) 
    port map 
    (
        ------------------------ Loopback and Powerdown Ports ----------------------
        LOOPBACK0(0)                    =>      emacLoopback,
        LOOPBACK0(1)                    =>      '0',
        LOOPBACK0(2)                    =>      '0',
        LOOPBACK1                       =>      "000",
        RXPOWERDOWN0(1)                 =>      emacPowerDown,
        RXPOWERDOWN0(0)                 =>      emacPowerDown,
        RXPOWERDOWN1                    =>      (others => '0'),
        TXPOWERDOWN0(1)                 =>      emacPowerDown,
        TXPOWERDOWN0(0)                 =>      emacPowerDown,
        TXPOWERDOWN1                    =>      (others => '0'),
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        RXCHARISCOMMA0                  =>      gtpRxCharIsComma,
        RXCHARISCOMMA1                  =>      open,
        RXCHARISK0                      =>      locGtpRxCharIsK,
        RXCHARISK1                      =>      open,
        RXDEC8B10BUSE0                  =>      '1',
        RXDEC8B10BUSE1                  =>      '1',
        RXDISPERR0                      =>      gtpRxDispErr,
        RXDISPERR1                      =>      open,
        RXNOTINTABLE0                   =>      gtpRxNotInTable,
        RXNOTINTABLE1                   =>      open,
        RXRUNDISP0                      =>      locGtpRxRunDisp,
        RXRUNDISP1                      =>      open,
        ------------------- Receive Ports - Channel Bonding Ports ------------------
        RXCHANBONDSEQ0                  =>      open,
        RXCHANBONDSEQ1                  =>      open,
        RXCHBONDI0                      =>      (others => '0'),
        RXCHBONDI1                      =>      (others => '0'),
        RXCHBONDO0                      =>      open,
        RXCHBONDO1                      =>      open,
        RXENCHANSYNC0                   =>      '0',
        RXENCHANSYNC1                   =>      '0',
        ------------------- Receive Ports - Clock Correction Ports -----------------
        RXCLKCORCNT0                    =>      gtpRxClkCorCnt,
        RXCLKCORCNT1                    =>      open,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        RXBYTEISALIGNED0                =>      open,
        RXBYTEISALIGNED1                =>      open,
        RXBYTEREALIGN0                  =>      open,
        RXBYTEREALIGN1                  =>      open,
        RXCOMMADET0                     =>      open,
        RXCOMMADET1                     =>      open,
        RXCOMMADETUSE0                  =>      '1',
        RXCOMMADETUSE1                  =>      '1',
        RXENMCOMMAALIGN0                =>      emacCommaAlign,
        RXENMCOMMAALIGN1                =>      '0',
        RXENPCOMMAALIGN0                =>      emacCommaAlign,
        RXENPCOMMAALIGN1                =>      '0',
        RXSLIDE0                        =>      '0',
        RXSLIDE1                        =>      '0',
        ----------------------- Receive Ports - PRBS Detection ---------------------
        PRBSCNTRESET0                   =>      '0',
        PRBSCNTRESET1                   =>      '0',
        RXENPRBSTST0                    =>      (others => '0'),
        RXENPRBSTST1                    =>      (others => '0'),
        RXPRBSERR0                      =>      open,
        RXPRBSERR1                      =>      open,
        ------------------- Receive Ports - RX Data Path interface -----------------
        RXDATA0                         =>      locGtpRxData,
        RXDATA1                         =>      open,
        RXDATAWIDTH0                    =>      '0',
        RXDATAWIDTH1                    =>      '0',
        RXRECCLK0                       =>      open,
        RXRECCLK1                       =>      open,
        RXRESET0                        =>      emacRxReset,
        RXRESET1                        =>      '0',
        RXUSRCLK0                       =>      gtpClkRef,
        RXUSRCLK1                       =>      '0',
        RXUSRCLK20                      =>      gtpClkRef,
        RXUSRCLK21                      =>      '0',
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        RXCDRRESET0                     =>      '0',
        RXCDRRESET1                     =>      '0',
        RXELECIDLE0                     =>      gtpRxElecIdle,
        RXELECIDLE1                     =>      open,
        RXELECIDLERESET0                =>      '0',
        RXELECIDLERESET1                =>      '0',
        RXENEQB0                        =>      '1',
        RXENEQB1                        =>      '1',
        RXEQMIX0                        =>      (others => '0'),
        RXEQMIX1                        =>      (others => '0'),
        RXEQPOLE0                       =>      (others => '0'),
        RXEQPOLE1                       =>      (others => '0'),
        RXN0                            =>      gtpRxN,
        RXN1                            =>      '1',
        RXP0                            =>      gtpRxP,
        RXP1                            =>      '0',
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        RXBUFRESET0                     =>      emacRxReset,
        RXBUFRESET1                     =>      '0',
        RXBUFSTATUS0                    =>      gtpRxBuffStatus,
        RXBUFSTATUS1                    =>      open,
        RXCHANISALIGNED0                =>      open,
        RXCHANISALIGNED1                =>      open,
        RXCHANREALIGN0                  =>      open,
        RXCHANREALIGN1                  =>      open,
        RXPMASETPHASE0                  =>      '0',
        RXPMASETPHASE1                  =>      '0',
        RXSTATUS0                       =>      open,
        RXSTATUS1                       =>      open,
        --------------- Receive Ports - RX Loss-of-sync State Machine --------------
        RXLOSSOFSYNC0                   =>      open,
        RXLOSSOFSYNC1                   =>      open,
        ---------------------- Receive Ports - RX Oversampling ---------------------
        RXENSAMPLEALIGN0                =>      '0',
        RXENSAMPLEALIGN1                =>      '0',
        RXOVERSAMPLEERR0                =>      open,
        RXOVERSAMPLEERR1                =>      open,
        -------------- Receive Ports - RX Pipe Control for PCI Express -------------
        PHYSTATUS0                      =>      open,
        PHYSTATUS1                      =>      open,
        RXVALID0                        =>      open,
        RXVALID1                        =>      open,
        ----------------- Receive Ports - RX Polarity Control Ports ----------------
        RXPOLARITY0                     =>      '0',
        RXPOLARITY1                     =>      '0',
        ------------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        DADDR                           =>      (others => '0'),
        DCLK                            =>      '0',
        DEN                             =>      '0',
        DI                              =>      (others => '0'),
        DO                              =>      open,
        DRDY                            =>      open,
        DWE                             =>      '0',
        --------------------- Shared Ports - Tile and PLL Ports --------------------
        CLKIN                           =>      gtpClk,
        GTPRESET                        =>      gtpClkRst,
        GTPTEST                         =>      (others => '0'),
        INTDATAWIDTH                    =>      '1',
        PLLLKDET                        =>      gtpLockDetect,
        PLLLKDETEN                      =>      '1',
        PLLPOWERDOWN                    =>      '0',
        REFCLKOUT                       =>      gtpClkOut,
        REFCLKPWRDNB                    =>      '1',
        RESETDONE0                      =>      gtpRstDone,
        RESETDONE1                      =>      open,
        RXENELECIDLERESETB              =>      '1',
        TXENPMAPHASEALIGN               =>      '0',
        TXPMASETPHASE                   =>      '0',
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        TXBYPASS8B10B0                  =>      (others => '0'),
        TXBYPASS8B10B1                  =>      (others => '0'),
        TXCHARDISPMODE0(1)              =>      '0',
        TXCHARDISPMODE0(0)              =>      emacTxCharDispMode,
        TXCHARDISPMODE1                 =>      (others => '0'),
        TXCHARDISPVAL0                  =>      emacTxCharDispVal,
        TXCHARDISPVAL1                  =>      (others => '0'),
        TXCHARISK0                      =>      emacTxCharIsK,
        TXCHARISK1                      =>      (others => '0'),
        TXENC8B10BUSE0                  =>      '1',
        TXENC8B10BUSE1                  =>      '1',
        TXKERR0                         =>      open,
        TXKERR1                         =>      open,
        TXRUNDISP0                      =>      open,
        TXRUNDISP1                      =>      open,
        ------------- Transmit Ports - TX Buffering and Phase Alignment ------------
        TXBUFSTATUS0                    =>      gtpTxBuffStatus,
        TXBUFSTATUS1                    =>      open,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        TXDATA0                         =>      gtpTxData,
        TXDATA1                         =>      (others => '0'),
        TXDATAWIDTH0                    =>      '0',
        TXDATAWIDTH1                    =>      '0',
        TXOUTCLK0                       =>      open,
        TXOUTCLK1                       =>      open,
        TXRESET0                        =>      emacTxReset,
        TXRESET1                        =>      '0',
        TXUSRCLK0                       =>      gtpClkRef,
        TXUSRCLK1                       =>      '0',
        TXUSRCLK20                      =>      gtpClkRef,
        TXUSRCLK21                      =>      '0',
        --------------- Transmit Ports - TX Driver and OOB signalling --------------
        TXBUFDIFFCTRL0                  =>      "000",
        TXBUFDIFFCTRL1                  =>      "000",
        TXDIFFCTRL0                     =>      "000",
        TXDIFFCTRL1                     =>      "000",
        TXINHIBIT0                      =>      '0',
        TXINHIBIT1                      =>      '0',
        TXN0                            =>      gtpTxN,
        TXN1                            =>      open,
        TXP0                            =>      gtpTxP,
        TXP1                            =>      open,
        TXPREEMPHASIS0                  =>      "000",
        TXPREEMPHASIS1                  =>      "000",
        --------------------- Transmit Ports - TX PRBS Generator -------------------
        TXENPRBSTST0                    =>      (others => '0'),
        TXENPRBSTST1                    =>      (others => '0'),
        -------------------- Transmit Ports - TX Polarity Control ------------------
        TXPOLARITY0                     =>      '0',
        TXPOLARITY1                     =>      '0',
        ----------------- Transmit Ports - TX Ports for PCI Express ----------------
        TXDETECTRX0                     =>      '0',
        TXDETECTRX1                     =>      '0',
        TXELECIDLE0                     =>      '0',
        TXELECIDLE1                     =>      '0',
        --------------------- Transmit Ports - TX Ports for SATA -------------------
        TXCOMSTART0                     =>      '0',
        TXCOMSTART1                     =>      '0',
        TXCOMTYPE0                      =>      '0',
        TXCOMTYPE1                      =>      '0'

    );

    ----------------------------------------------------------------------------
    -- Instantiate the Virtex-5 Embedded Ethernet EMAC
    ----------------------------------------------------------------------------
    v5_emac : TEMAC
    generic map (
        EMAC0_1000BASEX_ENABLE          => TRUE,
        EMAC0_ADDRFILTER_ENABLE         => FALSE,
        EMAC0_BYTEPHY                   => FALSE,
        EMAC0_CONFIGVEC_79              => TRUE,
        EMAC0_DCRBASEADDR               => X"00",
        EMAC0_GTLOOPBACK                => FALSE,
        EMAC0_HOST_ENABLE               => FALSE,
        EMAC0_LINKTIMERVAL              => EMAC0_LINKTIMERVAL(3 to 11),
        EMAC0_LTCHECK_DISABLE           => FALSE,
        EMAC0_MDIO_ENABLE               => TRUE,
        EMAC0_PAUSEADDR                 => x"FFEEDDCCBBAA",
        EMAC0_PHYINITAUTONEG_ENABLE     => FALSE,
        EMAC0_PHYISOLATE                => FALSE,
        EMAC0_PHYLOOPBACKMSB            => FALSE,
        EMAC0_PHYPOWERDOWN              => FALSE,
        EMAC0_PHYRESET                  => FALSE,
        EMAC0_RGMII_ENABLE              => FALSE,
        EMAC0_RX16BITCLIENT_ENABLE      => FALSE,
        EMAC0_RXFLOWCTRL_ENABLE         => FALSE,
        EMAC0_RXHALFDUPLEX              => FALSE,
        EMAC0_RXINBANDFCS_ENABLE        => FALSE,
        EMAC0_RXJUMBOFRAME_ENABLE       => TRUE,
        EMAC0_RXRESET                   => FALSE,
        EMAC0_RXVLAN_ENABLE             => FALSE,
        EMAC0_RX_ENABLE                 => TRUE,
        EMAC0_SGMII_ENABLE              => FALSE,
        EMAC0_SPEED_LSB                 => FALSE,
        EMAC0_SPEED_MSB                 => TRUE,
        EMAC0_TX16BITCLIENT_ENABLE      => FALSE,
        EMAC0_TXFLOWCTRL_ENABLE         => FALSE,
        EMAC0_TXHALFDUPLEX              => FALSE,
        EMAC0_TXIFGADJUST_ENABLE        => FALSE,
        EMAC0_TXINBANDFCS_ENABLE        => FALSE,
        EMAC0_TXJUMBOFRAME_ENABLE       => TRUE,
        EMAC0_TXRESET                   => FALSE,
        EMAC0_TXVLAN_ENABLE             => FALSE,
        EMAC0_TX_ENABLE                 => TRUE,
        EMAC0_UNICASTADDR               => x"000000000000",
        EMAC0_UNIDIRECTION_ENABLE       => FALSE,
        EMAC0_USECLKEN                  => FALSE,
        EMAC1_LINKTIMERVAL              => "000000000"
)
    port map (
        RESET                           => emacRst,

        -- EMAC0
        EMAC0CLIENTRXCLIENTCLKOUT       => open,
        CLIENTEMAC0RXCLIENTCLKIN        => gtpClkRef,
        EMAC0CLIENTRXD(15 downto 8)     => open,
        EMAC0CLIENTRXD(7  downto 0)     => emacRxData,
        EMAC0CLIENTRXDVLD               => emacRxValid,
        EMAC0CLIENTRXDVLDMSW            => open,
        EMAC0CLIENTRXGOODFRAME          => emacRxGoodFrame,
        EMAC0CLIENTRXBADFRAME           => emacRxBadFrame,
        EMAC0CLIENTRXFRAMEDROP          => emacRxFrameDrop,
        EMAC0CLIENTRXSTATS              => emacRxStats,
        EMAC0CLIENTRXSTATSVLD           => emacRxStatsValid,
        EMAC0CLIENTRXSTATSBYTEVLD       => emacRxStatsByteValid,

        EMAC0CLIENTTXCLIENTCLKOUT       => open,
        CLIENTEMAC0TXCLIENTCLKIN        => gtpClkRef,
        CLIENTEMAC0TXD(15 downto 8)     => (OTHERS => '0'),
        CLIENTEMAC0TXD(7  downto 0)     => emacTxData,
        CLIENTEMAC0TXDVLD               => emacTxValid,
        CLIENTEMAC0TXDVLDMSW            => '0',
        EMAC0CLIENTTXACK                => emacTxAck,
        CLIENTEMAC0TXFIRSTBYTE          => emacTxFirst,
        CLIENTEMAC0TXUNDERRUN           => '0',
        EMAC0CLIENTTXCOLLISION          => open,
        EMAC0CLIENTTXRETRANSMIT         => open,
        CLIENTEMAC0TXIFGDELAY           => x"00",
        EMAC0CLIENTTXSTATS              => open,
        EMAC0CLIENTTXSTATSVLD           => open,
        EMAC0CLIENTTXSTATSBYTEVLD       => open,

        CLIENTEMAC0PAUSEREQ             => '0',
        CLIENTEMAC0PAUSEVAL             => (others => '0'),

        PHYEMAC0GTXCLK                  => gtpClkRef,
        PHYEMAC0TXGMIIMIICLKIN          => '0',
        EMAC0PHYTXGMIIMIICLKOUT         => open,
        PHYEMAC0RXCLK                   => '0',
        PHYEMAC0MIITXCLK                => '0',
        PHYEMAC0RXD                     => gtpRxData(7 downto 0),
        PHYEMAC0RXDV                    => '0',
        PHYEMAC0RXER                    => '0',
        EMAC0PHYTXCLK                   => open,
        EMAC0PHYTXD                     => gtpTxData(7 downto 0),
        EMAC0PHYTXEN                    => open,
        EMAC0PHYTXER                    => open,
        PHYEMAC0COL                     => '0',
        PHYEMAC0CRS                     => '0',
        CLIENTEMAC0DCMLOCKED            => gtpLockDetect,
        EMAC0CLIENTANINTERRUPT          => open,
        PHYEMAC0SIGNALDET               => emacSignalDetect,
        PHYEMAC0PHYAD                   => (OTHERS => '1'),
        EMAC0PHYENCOMMAALIGN            => emacCommaAlign,
        EMAC0PHYLOOPBACKMSB             => emacLoopBack,
        EMAC0PHYMGTRXRESET              => emacRxReset,
        EMAC0PHYMGTTXRESET              => emacTxReset,
        EMAC0PHYPOWERDOWN               => emacPowerDown,
        EMAC0PHYSYNCACQSTATUS           => open,
        PHYEMAC0RXCLKCORCNT             => gtpRxClkCorCnt,
        PHYEMAC0RXBUFSTATUS(1)          => gtpRxBuffStatus(2),
        PHYEMAC0RXBUFSTATUS(0)          => open,
        PHYEMAC0RXBUFERR                => '0',
        PHYEMAC0RXCHARISCOMMA           => gtpRxCharIsComma(0),
        PHYEMAC0RXCHARISK               => gtpRxCharIsK(0),
        PHYEMAC0RXCHECKINGCRC           => '0',
        PHYEMAC0RXCOMMADET              => '0',
        PHYEMAC0RXDISPERR               => gtpRxDispErr(0),
        PHYEMAC0RXLOSSOFSYNC            => (OTHERS => '0'),
        PHYEMAC0RXNOTINTABLE            => gtpRxNotInTable(0),
        PHYEMAC0RXRUNDISP               => gtpRxRunDisp(0),
        PHYEMAC0TXBUFERR                => gtpTxBuffStatus(1),
        EMAC0PHYTXCHARDISPMODE          => emacTxCharDispMode,
        EMAC0PHYTXCHARDISPVAL           => emacTxCharDispVal(0),
        EMAC0PHYTXCHARISK               => emacTxCharIsK(0),

        EMAC0PHYMCLKOUT                 => open,
        PHYEMAC0MCLKIN                  => '0',
        PHYEMAC0MDIN                    => '1',
        EMAC0PHYMDOUT                   => open,
        EMAC0PHYMDTRI                   => open,
        EMAC0SPEEDIS10100               => open,

        -- EMAC1 Unused
        EMAC1CLIENTRXCLIENTCLKOUT       => open,
        CLIENTEMAC1RXCLIENTCLKIN        => '0',
        EMAC1CLIENTRXD                  => open,
        EMAC1CLIENTRXDVLD               => open,
        EMAC1CLIENTRXDVLDMSW            => open,
        EMAC1CLIENTRXGOODFRAME          => open,
        EMAC1CLIENTRXBADFRAME           => open,
        EMAC1CLIENTRXFRAMEDROP          => open,
        EMAC1CLIENTRXSTATS              => open,
        EMAC1CLIENTRXSTATSVLD           => open,
        EMAC1CLIENTRXSTATSBYTEVLD       => open,

        EMAC1CLIENTTXCLIENTCLKOUT       => open,
        CLIENTEMAC1TXCLIENTCLKIN        => '0',
        CLIENTEMAC1TXD                  => (OTHERS => '0'),
        CLIENTEMAC1TXDVLD               => '0',
        CLIENTEMAC1TXDVLDMSW            => '0',
        EMAC1CLIENTTXACK                => open,
        CLIENTEMAC1TXFIRSTBYTE          => '0',
        CLIENTEMAC1TXUNDERRUN           => '0',
        EMAC1CLIENTTXCOLLISION          => open,
        EMAC1CLIENTTXRETRANSMIT         => open,
        CLIENTEMAC1TXIFGDELAY           => (OTHERS => '0'),
        EMAC1CLIENTTXSTATS              => open,
        EMAC1CLIENTTXSTATSVLD           => open,
        EMAC1CLIENTTXSTATSBYTEVLD       => open,

        CLIENTEMAC1PAUSEREQ             => '0',
        CLIENTEMAC1PAUSEVAL             => (OTHERS => '0'),

        PHYEMAC1GTXCLK                  => '0',
        PHYEMAC1TXGMIIMIICLKIN          => '0',
        EMAC1PHYTXGMIIMIICLKOUT         => open,

        PHYEMAC1RXCLK                   => '0',
        PHYEMAC1RXD                     => (OTHERS => '0'),
        PHYEMAC1RXDV                    => '0',
        PHYEMAC1RXER                    => '0',
        PHYEMAC1MIITXCLK                => '0',
        EMAC1PHYTXCLK                   => open,
        EMAC1PHYTXD                     => open,
        EMAC1PHYTXEN                    => open,
        EMAC1PHYTXER                    => open,
        PHYEMAC1COL                     => '0',
        PHYEMAC1CRS                     => '0',

        CLIENTEMAC1DCMLOCKED            => '1',
        EMAC1CLIENTANINTERRUPT          => open,

        PHYEMAC1SIGNALDET               => '0',
        PHYEMAC1PHYAD                   => (OTHERS => '0'),
        EMAC1PHYENCOMMAALIGN            => open,
        EMAC1PHYLOOPBACKMSB             => open,
        EMAC1PHYMGTRXRESET              => open,
        EMAC1PHYMGTTXRESET              => open,
        EMAC1PHYPOWERDOWN               => open,
        EMAC1PHYSYNCACQSTATUS           => open,
        PHYEMAC1RXCLKCORCNT             => (OTHERS => '0'),
        PHYEMAC1RXBUFSTATUS             => (OTHERS => '0'),
        PHYEMAC1RXBUFERR                => '0',
        PHYEMAC1RXCHARISCOMMA           => '0',
        PHYEMAC1RXCHARISK               => '0',
        PHYEMAC1RXCHECKINGCRC           => '0',
        PHYEMAC1RXCOMMADET              => '0',
        PHYEMAC1RXDISPERR               => '0',
        PHYEMAC1RXLOSSOFSYNC            => (OTHERS => '0'),
        PHYEMAC1RXNOTINTABLE            => '0',
        PHYEMAC1RXRUNDISP               => '0',
        PHYEMAC1TXBUFERR                => '0',
        EMAC1PHYTXCHARDISPMODE          => open,
        EMAC1PHYTXCHARDISPVAL           => open,
        EMAC1PHYTXCHARISK               => open,

        EMAC1PHYMCLKOUT                 => open,
        PHYEMAC1MCLKIN                  => '0',
        PHYEMAC1MDIN                    => '0',
        EMAC1PHYMDOUT                   => open,
        EMAC1PHYMDTRI                   => open,

        EMAC1SPEEDIS10100               => open,

        -- Host Interface 
        HOSTCLK                         => '0',
 
        HOSTOPCODE                      => (OTHERS => '0'),
        HOSTREQ                         => '0',
        HOSTMIIMSEL                     => '0',
        HOSTADDR                        => (OTHERS => '0'),
        HOSTWRDATA                      => (OTHERS => '0'),
        HOSTMIIMRDY                     => open,
        HOSTRDDATA                      => open,
        HOSTEMAC1SEL                    => '0',

        -- DCR Interface
        DCREMACCLK                      => '0',
        DCREMACABUS                     => (OTHERS => '0'),
        DCREMACREAD                     => '0',
        DCREMACWRITE                    => '0',
        DCREMACDBUS                     => (OTHERS => '0'),
        EMACDCRACK                      => open,
        EMACDCRDBUS                     => open,
        DCREMACENABLE                   => '0',
        DCRHOSTDONEIR                   => open
        );

   
   -------------------------------------------------------------------------------
   -- EMAC0 to GTP logic shim
   -------------------------------------------------------------------------------

   -- When the RXNOTINTABLE condition is detected, the Virtex5 RocketIO
   -- GTP outputs the raw 10B code in a bit swapped order to that of the
   -- Virtex-II Pro RocketIO.
   process (gtpRxNotInTable, locGtpRxCharIsK, locGtpRxData, locGtpRxRunDisp) begin
      if gtpRxNotInTable(0) = '1' then
         gtpRxData(0)     <= locGtpRxCharIsK(0);
         gtpRxData(1)     <= locGtpRxRunDisp(0);
         gtpRxData(2)     <= locGtpRxData(7); 
         gtpRxData(3)     <= locGtpRxData(6); 
         gtpRxData(4)     <= locGtpRxData(5); 
         gtpRxData(5)     <= locGtpRxData(4); 
         gtpRxData(6)     <= locGtpRxData(3); 
         gtpRxData(7)     <= locGtpRxData(2); 
         gtpRxRunDisp(0)  <= locGtpRxData(1);    
         gtpRxCharIsK(0)  <= locGtpRxData(0);    
      else
         gtpRxData        <= locGtpRxData;
         gtpRxRunDisp     <= locGtpRxRunDisp;
         gtpRxCharIsK     <= locGtpRxCharIsK;
      end if;
   end process;

   -- Ethernet core
   U_EthClient : EthClient generic map ( UdpPort => UdpPort )
   port map (
      emacClk         => gtpClkRef,
      emacClkRst      => gtpClkRst,
      emacRxData      => emacRxData,
      emacRxValid     => emacRxValid,
      emacRxGoodFrame => emacRxGoodFrame,
      emacRxBadFrame  => emacRxBadFrame,
      emacTxData      => emacTxData,
      emacTxValid     => emacTxValid,
      emacTxAck       => emacTxAck,
      emacTxFirst     => emacTxFirst,
      ipAddr          => ipAddr,
      macAddr         => macAddr,
      udpTxValid      => udpTxValid,
      udpTxEOF        => udpTxEOF,
      udpTxReady      => udpTxReady,
      udpTxData       => udpTxData,
      udpTxLength     => udpTxLength,
      udpRxValid      => udpRxValid,
      udpRxSOF        => udpRxSOF,
      udpRxEOF        => udpRxEOF,
      udpRxWidth      => udpRxWidth,
      udpRxData       => udpRxData,
      udpRxGood       => udpRxGood,
      udpRxError      => udpRxError,
      cScopeCtrl1     => cScopeCtrl1,
      cScopeCtrl2     => cScopeCtrl2
   );

end EthClientGtp;

