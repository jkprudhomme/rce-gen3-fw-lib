
LIBRARY ieee;
use work.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity EthMac1GCore is 
   port (

      -- System clock, reset & control
      gtxClk          : in  std_logic;
      gtxClkDiv       : in  std_logic;
      gtxClkOut       : out std_logic;
      gtxClkRef       : in  std_logic;
      gtxClkRst       : in  std_logic;

      -- Frame Receive 
      emacRxData      : out std_logic_vector(7  downto 0);
      emacRxValid     : out std_logic;
      emacRxGoodFrame : out std_logic;
      emacRxBadFrame  : out std_logic;

      -- Frame Transmit
      emacTxData      : in  std_logic_vector(7  downto 0);
      emacTxValid     : in  std_logic;
      emacTxAck       : out std_logic;
      emacTxFirst     : in  std_logic;

      -- GTX Signals
      gtxRxN          : in  std_logic;
      gtxRxP          : in  std_logic;
      gtxTxN          : out std_logic;
      gtxTxP          : out std_logic
   );

end EthMac1GCore;

-- Define architecture
architecture EthMac1GCore of EthMac1GCore is

   -- GTX Signals
   signal gtxRxCharIsK      : std_logic_vector(3  downto 0);
   signal gtxRxCharIsComma  : std_logic_vector(3  downto 0);
   signal locGtxRxCharIsK   : std_logic_vector(3  downto 0);
   signal gtxRxDispErr      : std_logic_vector(3  downto 0);
   signal gtxRxNotInTable   : std_logic_vector(3  downto 0);
   signal gtxRxRunDisp      : std_logic_vector(3  downto 0);
   signal locGtxRxRunDisp   : std_logic_vector(3  downto 0);
   signal gtxRxData         : std_logic_vector(31 downto 0);
   signal locGtxRxData      : std_logic_vector(31 downto 0);
   signal gtxTxData         : std_logic_vector(31 downto 0);
   signal gtxRxClkCorCnt    : std_logic_vector(2 downto 0);
   signal gtxRxElecIdle     : std_logic;
   signal gtxRxBuffStatus   : std_logic_vector(2  downto 0);
   signal gtxLockDetect     : std_logic;
   signal gtxRstDone        : std_logic;
   signal gtxTxBuffStatus   : std_logic_vector(1  downto 0);
   
   -- EMAC Signals
   signal emacRxFrameDrop      : std_logic;
   signal emacRxStats          : std_logic_vector(6  downto 0);
   signal emacRxStatsValid     : std_logic;
   signal emacRxStatsByteValid : std_logic;
   signal emacRxReset          : std_logic;
   signal emacTxReset          : std_logic;
   signal emacPowerDown        : std_logic;
   signal emacCommaAlign       : std_logic;
   signal emacLoopBack         : std_logic;
   signal emacSignalDetect     : std_logic;
   signal emacTxCharIsK        : std_logic_vector(3  downto 0);
   signal emacTxCharDispVal    : std_logic_vector(3  downto 0);
   signal emacTxCharDispMode   : std_logic;
   signal emacRst              : std_logic;
   signal reset_r              : std_logic_vector(3 downto 0);
   signal zeros             : std_logic_vector(31 downto 0);

   -- Constants
   constant EMAC0_LINKTIMERVAL : bit_vector := x"13D";
   
   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin     

   zeros <= (others=>'0');
 
   -- Connect GTX Electrical Idle to EMAC Signal Detect
   emacSignalDetect <= not gtxRxElecIdle after tpd;

   -- Asserting the reset of the EMAC for four clock cycles
   process(gtxClk, gtxClkRst)
   begin
       if (gtxClkRst = '1') then
           reset_r <= "1111";
       elsif rising_edge(gtxClk) then
         if (gtxLockDetect = '1') then
           reset_r <= reset_r(2 downto 0) & gtxClkRst;
         end if;
       end if;
   end process;

   -- The reset pulse is now several clock cycles in duration
   emacRst <= reset_r(3);

   ----------------------------- GTX DUAL Instance  --------------------------   
   U_GTX:GTX_DUAL
    generic map
    (

        --_______________________ Simulation-Only Attributes ___________________
        SIM_RECEIVER_DETECT_PASS_0  =>       TRUE,
        SIM_RECEIVER_DETECT_PASS_1  =>       TRUE,
        SIM_MODE                    =>       "FAST",
        SIM_GTXRESET_SPEEDUP        =>       0,
        SIM_PLL_PERDIV2             =>       x"190",

        --___________________________ Shared Attributes ________________________

        -------------------------- Tile and PLL Attributes ---------------------

        CLK25_DIVIDER               =>       5, 
        CLKINDC_B                   =>       TRUE,
        CLKRCV_TRST                 =>       TRUE,
        OOB_CLK_DIVIDER             =>       4,
        OVERSAMPLE_MODE             =>       FALSE,
        PLL_COM_CFG                 =>       x"21680a",
        PLL_CP_CFG                  =>       x"00",
        PLL_DIVSEL_FB               =>       4, -- 2
        PLL_DIVSEL_REF              =>       1,
        PLL_FB_DCCEN                =>       FALSE,
        PLL_LKDET_CFG               =>       "101",
        PLL_TDCC_CFG                =>       "000",
        PMA_COM_CFG                 =>       x"000000000000000000",

        --____________________ Transmit Interface Attributes ___________________

        ------------------- TX Buffering and Phase Alignment -------------------   

        TX_BUFFER_USE_0             =>       TRUE,
        TX_XCLK_SEL_0               =>       "TXOUT",
        TXRX_INVERT_0               =>       "011",        

        TX_BUFFER_USE_1             =>       TRUE,
        TX_XCLK_SEL_1               =>       "TXOUT",
        TXRX_INVERT_1               =>       "011",        

        --------------------- TX Gearbox Settings -----------------------------

        GEARBOX_ENDEC_0             =>       "000", 
        TXGEARBOX_USE_0             =>       FALSE,

        GEARBOX_ENDEC_1             =>       "000", 
        TXGEARBOX_USE_1             =>       FALSE,

        --------------------- TX Serial Line Rate settings ---------------------   

        PLL_TXDIVSEL_OUT_0          =>       4,

        PLL_TXDIVSEL_OUT_1          =>       4,

        --------------------- TX Driver and OOB signalling --------------------  

        CM_TRIM_0                   =>       "10",
        PMA_TX_CFG_0                =>       x"80082",
        TX_DETECT_RX_CFG_0          =>       x"1832",
        TX_IDLE_DELAY_0             =>       "010",
        CM_TRIM_1                   =>       "10",
        PMA_TX_CFG_1                =>       x"80082",
        TX_DETECT_RX_CFG_1          =>       x"1832",
        TX_IDLE_DELAY_1             =>       "010",

        ------------------ TX Pipe Control for PCI Express/SATA ---------------

        COM_BURST_VAL_0             =>       "1111",

        COM_BURST_VAL_1             =>       "1111",
        --_______________________ Receive Interface Attributes ________________

        ------------ RX Driver,OOB signalling,Coupling and Eq,CDR -------------  

        AC_CAP_DIS_0                =>       TRUE,
        OOBDETECT_THRESHOLD_0       =>       "111",
        PMA_CDR_SCAN_0              =>       x"640403a",
        PMA_RX_CFG_0                =>       x"0f44088",
        RCV_TERM_GND_0              =>       FALSE,
        RCV_TERM_VTTRX_0            =>       TRUE,
        TERMINATION_IMP_0           =>       50,

        AC_CAP_DIS_1                =>       TRUE,
        OOBDETECT_THRESHOLD_1       =>       "111",
        PMA_CDR_SCAN_1              =>       x"640403a",
        PMA_RX_CFG_1                =>       x"0f44088",  
        RCV_TERM_GND_1              =>       FALSE,
        RCV_TERM_VTTRX_1            =>       TRUE,
        TERMINATION_IMP_1           =>       50,
        TERMINATION_CTRL            =>       "10100",
        TERMINATION_OVRD            =>       FALSE,

        ---------------- RX Decision Feedback Equalizer(DFE)  ----------------  

        DFE_CFG_0                   =>       "1001111011",
        DFE_CFG_1                   =>       "1001111011",
        DFE_CAL_TIME                =>       "00110",

        --------------------- RX Serial Line Rate Attributes ------------------   

        PLL_RXDIVSEL_OUT_0          =>       4,
        PLL_SATA_0                  =>       FALSE,

        PLL_RXDIVSEL_OUT_1          =>       4,
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

        --------------------- RX Gearbox Settings -----------------------------

        RXGEARBOX_USE_0             =>       FALSE,
        RXGEARBOX_USE_1             =>       FALSE,

        -------------- RX Elastic Buffer and Phase alignment Attributes -------   

        PMA_RXSYNC_CFG_0            =>       x"00",
        RX_BUFFER_USE_0             =>       TRUE,
        RX_XCLK_SEL_0               =>       "RXREC",
        PMA_RXSYNC_CFG_1            =>       x"00",
        RX_BUFFER_USE_1             =>       TRUE,
        RX_XCLK_SEL_1               =>       "RXREC",                   

        ------------------------ Clock Correction Attributes ------------------   

        CLK_CORRECT_USE_0           =>       TRUE,
        CLK_COR_ADJ_LEN_0           =>       2,
        CLK_COR_DET_LEN_0           =>       2,
        CLK_COR_INSERT_IDLE_FLAG_0  =>       FALSE,
        CLK_COR_KEEP_IDLE_0         =>       FALSE,
        CLK_COR_MAX_LAT_0           =>       20,
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
        CLK_COR_MAX_LAT_1           =>       20,
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
        CB2_INH_CC_PERIOD_0         =>       8,
        CHAN_BOND_KEEP_ALIGN_0      =>       FALSE,
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
     
        CB2_INH_CC_PERIOD_1         =>       8,
        CHAN_BOND_KEEP_ALIGN_1      =>       FALSE,
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

        -------- RX Attributes to Control Reset after Electrical Idle  ------

        RX_EN_IDLE_HOLD_DFE_0       =>       TRUE,
        RX_EN_IDLE_RESET_BUF_0      =>       TRUE,
        RX_IDLE_HI_CNT_0            =>       "1000",
        RX_IDLE_LO_CNT_0            =>       "0000",
        RX_EN_IDLE_HOLD_DFE_1       =>       TRUE,
        RX_EN_IDLE_RESET_BUF_1      =>       TRUE,
        RX_IDLE_HI_CNT_1            =>       "1000",
        RX_IDLE_LO_CNT_1            =>       "0000",
        CDR_PH_ADJ_TIME             =>       "01010",
        RX_EN_IDLE_RESET_FR         =>       TRUE,
        RX_EN_IDLE_HOLD_CDR         =>       FALSE,
        RX_EN_IDLE_RESET_PH         =>       TRUE,

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
        TRANS_TIME_FROM_P2_0        =>       x"003c",
        TRANS_TIME_NON_P2_0         =>       x"0019",
        TRANS_TIME_TO_P2_0          =>       x"0064",

        RX_STATUS_FMT_1             =>       "PCIE",
        SATA_BURST_VAL_1            =>       "100",
        SATA_IDLE_VAL_1             =>       "100",
        SATA_MAX_BURST_1            =>       9,
        SATA_MAX_INIT_1             =>       27,
        SATA_MAX_WAKE_1             =>       9,
        SATA_MIN_BURST_1            =>       5,
        SATA_MIN_INIT_1             =>       15,
        SATA_MIN_WAKE_1             =>       5,
        TRANS_TIME_FROM_P2_1        =>       x"003c",
        TRANS_TIME_NON_P2_1         =>       x"0019",
        TRANS_TIME_TO_P2_1          =>       x"0064"
    ) 
    port map 
    (
        ------------------------ Loopback and Powerdown Ports ----------------------
        LOOPBACK0(0)                    =>      '0',
        LOOPBACK0(1)                    =>      '0', -- Loopback
        LOOPBACK0(2)                    =>      '0',
        LOOPBACK1                       =>      "000",
        RXPOWERDOWN0(1)                 =>      emacPowerDown,
        RXPOWERDOWN0(0)                 =>      emacPowerDown,
        RXPOWERDOWN1                    =>      (others => '0'),
        TXPOWERDOWN0(1)                 =>      emacPowerDown,
        TXPOWERDOWN0(0)                 =>      emacPowerDown,
        TXPOWERDOWN1                    =>      (others => '0'),
        -------------- Receive Ports - 64b66b and 64b67b Gearbox Ports -------------
        RXDATAVALID0                    =>      open,
        RXDATAVALID1                    =>      open,
        RXGEARBOXSLIP0                  =>      '0',
        RXGEARBOXSLIP1                  =>      '0',
        RXHEADER0                       =>      open,
        RXHEADER1                       =>      open,
        RXHEADERVALID0                  =>      open,
        RXHEADERVALID1                  =>      open,
        RXSTARTOFSEQ0                   =>      open,
        RXSTARTOFSEQ1                   =>      open,
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        RXCHARISCOMMA0                  =>      gtxRxCharIsComma,
        RXCHARISCOMMA1                  =>      open,
        RXCHARISK0                      =>      locGtxRxCharIsK,
        RXCHARISK1                      =>      open,
        RXDEC8B10BUSE0                  =>      '1',
        RXDEC8B10BUSE1                  =>      '1',
        RXDISPERR0                      =>      gtxRxDispErr,
        RXDISPERR1                      =>      open,
        RXNOTINTABLE0                   =>      gtxRxNotInTable,
        RXNOTINTABLE1                   =>      open,
        RXRUNDISP0                      =>      locGtxRxRunDisp,
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
        RXCLKCORCNT0                    =>      gtxRxClkCorCnt,
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
        RXDATA0                         =>      locGtxRxData,
        RXDATA1                         =>      open,
        RXDATAWIDTH0                    =>      "00",
        RXDATAWIDTH1                    =>      "00",
        RXRECCLK0                       =>      open,
        RXRECCLK1                       =>      open,
        RXRESET0                        =>      emacRxReset,
        RXRESET1                        =>      '0',
        RXUSRCLK0                       =>      gtxClkDiv,
        RXUSRCLK1                       =>      '0',
        RXUSRCLK20                      =>      gtxClk,
        RXUSRCLK21                      =>      '0',
        ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        DFECLKDLYADJ0                   =>      (others=>'0'),
        DFECLKDLYADJ1                   =>      (others=>'0'),
        DFECLKDLYADJMONITOR0            =>      open,
        DFECLKDLYADJMONITOR1            =>      open,
        DFEEYEDACMONITOR0               =>      open,
        DFEEYEDACMONITOR1               =>      open,
        DFESENSCAL0                     =>      open,
        DFESENSCAL1                     =>      open,
        DFETAP10                        =>      (others=>'0'),
        DFETAP11                        =>      (others=>'0'),
        DFETAP1MONITOR0                 =>      open,
        DFETAP1MONITOR1                 =>      open,
        DFETAP20                        =>      (others=>'0'),
        DFETAP21                        =>      (others=>'0'),
        DFETAP2MONITOR0                 =>      open,
        DFETAP2MONITOR1                 =>      open,
        DFETAP30                        =>      (others=>'0'),
        DFETAP31                        =>      (others=>'0'),
        DFETAP3MONITOR0                 =>      open,
        DFETAP3MONITOR1                 =>      open,
        DFETAP40                        =>      (others=>'0'),
        DFETAP41                        =>      (others=>'0'),
        DFETAP4MONITOR0                 =>      open,
        DFETAP4MONITOR1                 =>      open,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        RXCDRRESET0                     =>      '0',
        RXCDRRESET1                     =>      '0',
        RXELECIDLE0                     =>      gtxRxElecIdle,
        RXELECIDLE1                     =>      open,
        RXENEQB0                        =>      '1',
        RXENEQB1                        =>      '1',
        RXEQMIX0                        =>      (others => '0'),
        RXEQMIX1                        =>      (others => '0'),
        RXEQPOLE0                       =>      (others => '0'),
        RXEQPOLE1                       =>      (others => '0'),
        RXN0                            =>      gtxRxN,
        RXN1                            =>      '1',
        RXP0                            =>      gtxRxP,
        RXP1                            =>      '0',
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        RXBUFRESET0                     =>      emacRxReset,
        RXBUFRESET1                     =>      '0',
        RXBUFSTATUS0                    =>      gtxRxBuffStatus,
        RXBUFSTATUS1                    =>      open,
        RXCHANISALIGNED0                =>      open,
        RXCHANISALIGNED1                =>      open,
        RXCHANREALIGN0                  =>      open,
        RXCHANREALIGN1                  =>      open,
        RXENPMAPHASEALIGN0              =>      '0',
        RXENPMAPHASEALIGN1              =>      '0',
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
        CLKIN                           =>      gtxClkRef,
        GTXRESET                        =>      gtxClkRst,
        GTXTEST                         =>      (others => '0'),
        INTDATAWIDTH                    =>      '1',
        PLLLKDET                        =>      gtxLockDetect,
        PLLLKDETEN                      =>      '1',
        PLLPOWERDOWN                    =>      '0',
        REFCLKOUT                       =>      gtxClkOut,
        REFCLKPWRDNB                    =>      '1',
        RESETDONE0                      =>      gtxRstDone,
        RESETDONE1                      =>      open,
        -------------- Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
        TXGEARBOXREADY0                 =>      open,
        TXGEARBOXREADY1                 =>      open,
        TXHEADER0                       =>      (others=>'0'),
        TXHEADER1                       =>      (others=>'0'),
        TXSEQUENCE0                     =>      (others=>'0'),
        TXSEQUENCE1                     =>      (others=>'0'),
        TXSTARTSEQ0                     =>      '0',
        TXSTARTSEQ1                     =>      '0',
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        TXBYPASS8B10B0                  =>      (others => '0'),
        TXBYPASS8B10B1                  =>      (others => '0'),
        TXCHARDISPMODE0(3)              =>      '0',
        TXCHARDISPMODE0(2)              =>      '0',
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
        TXBUFSTATUS0                    =>      gtxTxBuffStatus,
        TXBUFSTATUS1                    =>      open,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        TXDATA0                         =>      gtxTxData,
        TXDATA1                         =>      (others => '0'),
        TXDATAWIDTH0                    =>      "00",
        TXDATAWIDTH1                    =>      "00",
        TXOUTCLK0                       =>      open,
        TXOUTCLK1                       =>      open,
        TXRESET0                        =>      emacTxReset,
        TXRESET1                        =>      '0',
        TXUSRCLK0                       =>      gtxClkDiv,
        TXUSRCLK1                       =>      '0',
        TXUSRCLK20                      =>      gtxClk,
        TXUSRCLK21                      =>      '0',
        --------------- Transmit Ports - TX Driver and OOB signalling --------------
        TXBUFDIFFCTRL0                  =>      "000",
        TXBUFDIFFCTRL1                  =>      "000",
        TXDIFFCTRL0                     =>      "000",
        TXDIFFCTRL1                     =>      "000",
        TXINHIBIT0                      =>      '0',
        TXINHIBIT1                      =>      '0',
        TXN0                            =>      gtxTxN,
        TXN1                            =>      open,
        TXP0                            =>      gtxTxP,
        TXP1                            =>      open,
        TXPREEMPHASIS0                  =>      "0000",
        TXPREEMPHASIS1                  =>      "0000",
        -------- Transmit Ports - TX Elastic Buffer and Phase Alignment Ports ------
        TXENPMAPHASEALIGN0              =>      '0',
        TXENPMAPHASEALIGN1              =>      '0',
        TXPMASETPHASE0                  =>      '0',
        TXPMASETPHASE1                  =>      '0',
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
        EMAC0_TXIFGADJUST_ENABLE        => TRUE,
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
        CLIENTEMAC0RXCLIENTCLKIN        => gtxClk,
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
        CLIENTEMAC0TXCLIENTCLKIN        => gtxClk,
        CLIENTEMAC0TXD(15 downto 8)     => zeros(15 downto 8),
        CLIENTEMAC0TXD(7  downto 0)     => emacTxData,
        CLIENTEMAC0TXDVLD               => emacTxValid,
        CLIENTEMAC0TXDVLDMSW            => '0',
        EMAC0CLIENTTXACK                => emacTxAck,
        CLIENTEMAC0TXFIRSTBYTE          => emacTxFirst,
        CLIENTEMAC0TXUNDERRUN           => '0',
        EMAC0CLIENTTXCOLLISION          => open,
        EMAC0CLIENTTXRETRANSMIT         => open,
        CLIENTEMAC0TXIFGDELAY           => x"FF",
        EMAC0CLIENTTXSTATS              => open,
        EMAC0CLIENTTXSTATSVLD           => open,
        EMAC0CLIENTTXSTATSBYTEVLD       => open,

        CLIENTEMAC0PAUSEREQ             => '0',
        CLIENTEMAC0PAUSEVAL             => (others => '0'),

        PHYEMAC0GTXCLK                  => gtxClk,
        PHYEMAC0TXGMIIMIICLKIN          => '0',
        EMAC0PHYTXGMIIMIICLKOUT         => open,
        PHYEMAC0RXCLK                   => '0',
        PHYEMAC0MIITXCLK                => '0',
        PHYEMAC0RXD                     => gtxRxData(7 downto 0),
        PHYEMAC0RXDV                    => '0',
        PHYEMAC0RXER                    => '0',
        EMAC0PHYTXCLK                   => open,
        EMAC0PHYTXD                     => gtxTxData(7 downto 0),
        EMAC0PHYTXEN                    => open,
        EMAC0PHYTXER                    => open,
        PHYEMAC0COL                     => '0',
        PHYEMAC0CRS                     => '0',
        CLIENTEMAC0DCMLOCKED            => gtxLockDetect,
        EMAC0CLIENTANINTERRUPT          => open,
        PHYEMAC0SIGNALDET               => emacSignalDetect,
        PHYEMAC0PHYAD                   => (OTHERS => '1'),
        EMAC0PHYENCOMMAALIGN            => emacCommaAlign,
        EMAC0PHYLOOPBACKMSB             => emacLoopBack,
        EMAC0PHYMGTRXRESET              => emacRxReset,
        EMAC0PHYMGTTXRESET              => emacTxReset,
        EMAC0PHYPOWERDOWN               => emacPowerDown,
        EMAC0PHYSYNCACQSTATUS           => open,
        PHYEMAC0RXCLKCORCNT             => gtxRxClkCorCnt,
        PHYEMAC0RXBUFSTATUS(1)          => gtxRxBuffStatus(2),
        PHYEMAC0RXBUFSTATUS(0)          => '0',
        PHYEMAC0RXBUFERR                => '0',
        PHYEMAC0RXCHARISCOMMA           => gtxRxCharIsComma(0),
        PHYEMAC0RXCHARISK               => gtxRxCharIsK(0),
        PHYEMAC0RXCHECKINGCRC           => '0',
        PHYEMAC0RXCOMMADET              => '0',
        PHYEMAC0RXDISPERR               => gtxRxDispErr(0),
        PHYEMAC0RXLOSSOFSYNC            => (OTHERS => '0'),
        PHYEMAC0RXNOTINTABLE            => gtxRxNotInTable(0),
        PHYEMAC0RXRUNDISP               => gtxRxRunDisp(0),
        PHYEMAC0TXBUFERR                => gtxTxBuffStatus(1),
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

   gtxTxData(31 downto 8)        <= (others=>'0');
   emacTxCharIsK(3 downto 1)     <= "000";
   emacTxCharDispVal(3 downto 1) <= "000";
   
   -------------------------------------------------------------------------------
   -- EMAC0 to GTX logic shim
   -------------------------------------------------------------------------------

   -- When the RXNOTINTABLE condition is detected, the Virtex5 RocketIO
   -- GTX outputs the raw 10B code in a bit swapped order to that of the
   -- Virtex-II Pro RocketIO.
   process (gtxRxNotInTable, locGtxRxCharIsK, locGtxRxData, locGtxRxRunDisp) begin
      if gtxRxNotInTable(0) = '1' then
         gtxRxData(0)     <= locGtxRxCharIsK(0);
         gtxRxData(1)     <= locGtxRxRunDisp(0);
         gtxRxData(2)     <= locGtxRxData(7); 
         gtxRxData(3)     <= locGtxRxData(6); 
         gtxRxData(4)     <= locGtxRxData(5); 
         gtxRxData(5)     <= locGtxRxData(4); 
         gtxRxData(6)     <= locGtxRxData(3); 
         gtxRxData(7)     <= locGtxRxData(2); 
         gtxRxRunDisp(0)  <= locGtxRxData(1);    
         gtxRxCharIsK(0)  <= locGtxRxData(0);    
      else
         gtxRxData        <= locGtxRxData;
         gtxRxRunDisp     <= locGtxRxRunDisp;
         gtxRxCharIsK     <= locGtxRxCharIsK;
      end if;
   end process;

end EthMac1GCore;

