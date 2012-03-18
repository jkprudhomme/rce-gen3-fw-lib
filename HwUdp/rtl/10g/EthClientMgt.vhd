-------------------------------------------------------------------------------
-- Title         : Ethernet Client, MGT Wrapper
-- Project       : General Purpose Core
-------------------------------------------------------------------------------
-- File          : EthClientMgt.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 10/18/2010
-------------------------------------------------------------------------------
-- Description:
-- MGT wrapper source code for general purpose firmware ethenet client.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 10/18/2010: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
use work.all;
use work.EthClientPackage.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

-- Wrapper
entity EthMgtWrap is 
   generic (
      UdpPort : integer := 8192
   );
   port (

      -- System clock, reset & control
      emacClk         : in  std_logic;
      emacClkRst      : in  std_logic;

      -- Ethernet Constants
      ipAddr          : in  IPAddrType;
      macAddr         : in  MacAddrType;

      -- UDP Transmit interface
      udpTxValid      : in  std_logic;
      udpTxReady      : out std_logic;
      udpTxData       : in  std_logic_vector(7  downto 0);
      udpTxLength     : in  std_logic_vector(15 downto 0);

      -- UDP Receive interface
      udpRxValid      : out std_logic;
      udpRxData       : out std_logic_vector(7 downto 0);
      udpRxGood       : out std_logic;
      udpRxError      : out std_logic;

      -- MGT Signals
      mgtRxN          : in  std_logic;
      mgtRxP          : in  std_logic;
      mgtTxN          : out std_logic;
      mgtTxP          : out std_logic;

      -- Debug
      cScopeCtrl1    : inout std_logic_vector(35 downto 0);
      cScopeCtrl2    : inout std_logic_vector(35 downto 0)
   );

end EthMgtWrap;


-- Define architecture
architecture EthMgtWrap of EthMgtWrap is

   -- Local Signals
   signal mgtRxReAlign      : std_logic;
   signal mgtTxRunDisp      : std_logic;
   signal mgtPowerDown      : std_logic;
   signal mgtTxCharDispMode : std_logic;
   signal mgtTxCharDispVal  : std_logic;
   signal mgtRxBuffErrorReg : std_logic;
   signal mgtRxCharIsComma  : std_logic;
   signal mgtRxStatus       : std_logic_vector(5 downto 0);
   signal emacClkCorCnt      : std_logic_vector(2 downto 0);
   signal mgtRxRunDisp      : std_logic;
   signal mgtRxRunDispMgt   : std_logic;
   signal mgtRxNotInTable   : std_logic;
   signal mgtRxDataMgt      : std_logic_vector(7 downto 0);
   signal mgtRxData         : std_logic_vector(7 downto 0);
   signal mgtRxDataK        : std_logic;
   signal mgtRxDataKMgt     : std_logic;
   signal mgtTxData         : std_logic_vector(7 downto 0);
   signal mgtTxDataK        : std_logic;
   signal mgtRxPmaReset     : std_logic;
   signal mgtTxPmaReset     : std_logic;
   signal mgtRxReset        : std_logic;
   signal mgtTxReset        : std_logic;
   signal mgtRxBuffError    : std_logic;
   signal mgtTxBuffError    : std_logic;
   signal mgtRxDispErr      : std_logic;
   signal mgtRxLock         : std_logic;
   signal mgtTxLock         : std_logic;
   signal mgtLoopBack       : std_logic;
   signal txPcsResetCnt     : std_logic_vector(3 downto 0);
   signal txPcsResetCntRst  : std_logic;
   signal txPcsResetCntEn   : std_logic;
   signal mgtEnCommaAlign   : std_logic;
   signal txStateCnt        : std_logic_vector(5 downto 0);
   signal txStateCntRst     : std_logic;
   signal rxPcsResetCnt     : std_logic_vector(3 downto 0);
   signal rxPcsResetCntRst  : std_logic;
   signal rxPcsResetCntEn   : std_logic;
   signal rxStateCnt        : std_logic_vector(13 downto 0);
   signal rxStateCntRst     : std_logic;
   signal intRxPmaReset     : std_logic;
   signal intTxPmaReset     : std_logic;
   signal intRxReset        : std_logic;
   signal intTxReset        : std_logic;
   signal txClockReady      : std_logic;
   signal rxClockReady      : std_logic;
   signal macConfig         : std_logic_vector(79 downto 0);
   signal locReset          : std_logic;
   signal emacRxData        : std_logic_vector(7 downto 0);
   signal emacRxValid       : std_logic;
   signal emacRxGoodFrame   : std_logic;
   signal emacRxBadFrame    : std_logic;
   signal emacRxFrameDrop   : std_logic;
   signal emacTxData        : std_logic_vector(7 downto 0);
   signal emacTxValid       : std_logic;
   signal emacTxAck         : std_logic;
   signal emacTxFirst       : std_logic;

   -- RX Reset State Machine
   constant RX_SYSTEM_RESET : std_logic_vector(2 downto 0) := "000";
   constant RX_PMA_RESET    : std_logic_vector(2 downto 0) := "001";
   constant RX_WAIT_LOCK    : std_logic_vector(2 downto 0) := "010";
   constant RX_PCS_RESET    : std_logic_vector(2 downto 0) := "011";
   constant RX_WAIT_PCS     : std_logic_vector(2 downto 0) := "100";
   constant RX_ALMOST_READY : std_logic_vector(2 downto 0) := "101";
   constant RX_READY        : std_logic_vector(2 downto 0) := "110";
   signal   curRxState      : std_logic_vector(2 downto 0);
   signal   nxtRxState      : std_logic_vector(2 downto 0);

   -- TX Reset State Machine
   constant TX_SYSTEM_RESET : std_logic_vector(2 downto 0) := "000";
   constant TX_PMA_RESET    : std_logic_vector(2 downto 0) := "001";
   constant TX_WAIT_LOCK    : std_logic_vector(2 downto 0) := "010";
   constant TX_PCS_RESET    : std_logic_vector(2 downto 0) := "011";
   constant TX_WAIT_PCS     : std_logic_vector(2 downto 0) := "100";
   constant TX_ALMOST_READY : std_logic_vector(2 downto 0) := "101";
   constant TX_DUMMY        : std_logic_vector(2 downto 0) := "110";
   constant TX_READY        : std_logic_vector(2 downto 0) := "111";
   signal   curTxState      : std_logic_vector(2 downto 0);
   signal   nxtTxState      : std_logic_vector(2 downto 0);

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- Local Reset
   locReset  <= emacClkRst or (not rxClockReady) or (not txClockReady);


    --------------------------- GT11 Instantiations  ---------------------------   
    U_MGT : GT11
    generic map
    (
    
    ---------- RocketIO MGT 64B66B Block Sync State Machine Attributes --------- 

        SH_CNT_MAX                 =>      64,
        SH_INVALID_CNT_MAX         =>      16,
        
    ----------------------- RocketIO MGT Alignment Atrributes ------------------   

        ALIGN_COMMA_WORD           =>      1,
        COMMA_10B_MASK             =>      x"07F",
        COMMA32                    =>      FALSE,
        DEC_MCOMMA_DETECT          =>      TRUE, 
        DEC_PCOMMA_DETECT          =>      TRUE, 
        DEC_VALID_COMMA_ONLY       =>      TRUE, 
        MCOMMA_32B_VALUE           =>      x"00000283",
        MCOMMA_DETECT              =>      TRUE,
        PCOMMA_32B_VALUE           =>      x"0000017c",
        PCOMMA_DETECT              =>      TRUE,
        PCS_BIT_SLIP               =>      FALSE,        
        
    ---- RocketIO MGT Atrributes Common to Clk Correction & Channel Bonding ----   

        CCCB_ARBITRATOR_DISABLE    =>      FALSE,
        CLK_COR_8B10B_DE           =>      TRUE,        

    ------------------- RocketIO MGT Channel Bonding Atrributes ----------------   
    
        CHAN_BOND_LIMIT            =>      16,
        CHAN_BOND_MODE             =>      "NONE",
        CHAN_BOND_ONE_SHOT         =>      FALSE,
        CHAN_BOND_SEQ_1_1          =>      "00000000000",
        CHAN_BOND_SEQ_1_2          =>      "00000000000",
        CHAN_BOND_SEQ_1_3          =>      "00000000000",
        CHAN_BOND_SEQ_1_4          =>      "00000000000",
        CHAN_BOND_SEQ_1_MASK       =>      "1111",
        CHAN_BOND_SEQ_2_1          =>      "00000000000",
        CHAN_BOND_SEQ_2_2          =>      "00000000000",
        CHAN_BOND_SEQ_2_3          =>      "00000000000",
        CHAN_BOND_SEQ_2_4          =>      "00000000000",
        CHAN_BOND_SEQ_2_MASK       =>      "1111",
        CHAN_BOND_SEQ_2_USE        =>      FALSE,
        CHAN_BOND_SEQ_LEN          =>      1,
 
    ------------------ RocketIO MGT Clock Correction Atrributes ----------------   

        CLK_COR_MAX_LAT            =>      48,
        CLK_COR_MIN_LAT            =>      36,
        CLK_COR_SEQ_1_1            =>      "00110111100",
        CLK_COR_SEQ_1_2            =>      "00001010000",
        CLK_COR_SEQ_1_3            =>      "00000000000",
        CLK_COR_SEQ_1_4            =>      "00000000000",
        CLK_COR_SEQ_1_MASK         =>      "1100",
        CLK_COR_SEQ_2_1            =>      "00110111100",
        CLK_COR_SEQ_2_2            =>      "00010110101",
        CLK_COR_SEQ_2_3            =>      "00000000000",
        CLK_COR_SEQ_2_4            =>      "00000000000",
        CLK_COR_SEQ_2_MASK         =>      "1100",
        CLK_COR_SEQ_2_USE          =>      FALSE,
        CLK_COR_SEQ_DROP           =>      FALSE,
        CLK_COR_SEQ_LEN            =>      2,
        CLK_CORRECT_USE            =>      TRUE,

-- Line Rate > 1.25G        

    ---------------------- RocketIO MGT Clocking Atrributes --------------------      
        RX_CLOCK_DIVIDER           =>      "10",
        RXASYNCDIVIDE              =>      "00",
        RXCLK0_FORCE_PMACLK        =>      TRUE,
        RXCLKMODE                  =>      "000011",
        RXOUTDIV2SEL               =>      4,
        RXPLLNDIVSEL               =>      20,
        RXPMACLKSEL                =>      "GREFCLK",
        RXRECCLK1_USE_SYNC         =>      FALSE,
        RXUSRDIVISOR               =>      1,
        TX_CLOCK_DIVIDER           =>      "10",
        TXABPMACLKSEL              =>      "GREFCLK",
        TXASYNCDIVIDE              =>      "00",
        TXCLK0_FORCE_PMACLK        =>      TRUE,
        TXCLKMODE                  =>      "0100",
        TXOUTCLK1_USE_SYNC         =>      FALSE,
        TXOUTDIV2SEL               =>      4,
        TXPHASESEL                 =>      FALSE, 
        TXPLLNDIVSEL               =>      20,

    ---------------- RocketIO MGT Digital Receiver Attributes ------------------   

        DIGRX_FWDCLK               =>      "10",
        DIGRX_SYNC_MODE            =>      FALSE,
        ENABLE_DCDR                =>      FALSE,
        RXBY_32                    =>      FALSE,
        RXDIGRESET                 =>      FALSE,
        RXDIGRX                    =>      FALSE,
        SAMPLE_8X                  =>      FALSE,

-- Line Rate < 1.25G, VC0 = 4 * 1.25gbs

    ---------------------- RocketIO MGT Clocking Atrributes --------------------      
        --RX_CLOCK_DIVIDER           =>      "00",
        --RXASYNCDIVIDE              =>      "00",
        --RXCLK0_FORCE_PMACLK        =>      TRUE,
        --RXCLKMODE                  =>      "000011",
        --RXOUTDIV2SEL               =>      1,
        --RXPLLNDIVSEL               =>      40,
        --RXPMACLKSEL                =>      "GREFCLK",
        --RXRECCLK1_USE_SYNC         =>      TRUE,
        --RXUSRDIVISOR               =>      1,
        --TX_CLOCK_DIVIDER           =>      "00",
        --TXABPMACLKSEL              =>      "GREFCLK",
        --TXASYNCDIVIDE              =>      "00",
        --TXCLK0_FORCE_PMACLK        =>      TRUE,
        --TXCLKMODE                  =>      "0100",
        --TXOUTCLK1_USE_SYNC         =>      FALSE,
        --TXOUTDIV2SEL               =>      8,
        --TXPHASESEL                 =>      FALSE, 
        --TXPLLNDIVSEL               =>      40,

    ---------------- RocketIO MGT Digital Receiver Attributes ------------------   

        --DIGRX_FWDCLK               =>      "10",
        --DIGRX_SYNC_MODE            =>      FALSE,
        --ENABLE_DCDR                =>      TRUE,
        --RXBY_32                    =>      FALSE,
        --RXDIGRESET                 =>      FALSE,
        --RXDIGRX                    =>      TRUE,
        --SAMPLE_8X                  =>      TRUE,

-- END

    -------------------------- RocketIO MGT CRC Atrributes ---------------------   

        RXCRCCLOCKDOUBLE           =>      FALSE,
        RXCRCENABLE                =>      FALSE,
        RXCRCINITVAL               =>      x"FFFFFFFF",
        RXCRCINVERTGEN             =>      FALSE,
        RXCRCSAMECLOCK             =>      TRUE,
        TXCRCCLOCKDOUBLE           =>      FALSE,
        TXCRCENABLE                =>      FALSE,
        TXCRCINITVAL               =>      x"FFFFFFFF",
        TXCRCINVERTGEN             =>      FALSE,
        TXCRCSAMECLOCK             =>      TRUE,
        
    --------------------- RocketIO MGT Data Path Atrributes --------------------   
    
        RXDATA_SEL                 =>      "00",
        TXDATA_SEL                 =>      "00",

    ----------------- Rocket IO MGT Miscellaneous Attributes ------------------     
        GT11_MODE                  =>      "SINGLE",
        OPPOSITE_SELECT            =>      FALSE,
        PMA_BIT_SLIP               =>      FALSE,
        REPEATER                   =>      FALSE,
        RX_BUFFER_USE              =>      TRUE,
        RXCDRLOS                   =>      "000000",
        RXDCCOUPLE                 =>      TRUE,
        RXFDCAL_CLOCK_DIVIDE       =>      "NONE",
        TX_BUFFER_USE              =>      TRUE,   
        TXFDCAL_CLOCK_DIVIDE       =>      "NONE",
        TXSLEWRATE                 =>      FALSE,

     ----------------- Rocket IO MGT Preemphasis and Equalization --------------
     
        RXAFEEQ                    =>       "000000000",
        RXEQ                       =>       x"4000FF0303030101",
        TXDAT_PRDRV_DAC            =>       "111",
        TXDAT_TAP_DAC              =>       "11011",  -- = TXPOST_TAP_DAC * 4
        TXHIGHSIGNALEN             =>       TRUE,
        TXPOST_PRDRV_DAC           =>       "111",
        TXPOST_TAP_DAC             =>       "00010",
        TXPOST_TAP_PD              =>       FALSE,
        TXPRE_PRDRV_DAC            =>       "111",
        TXPRE_TAP_DAC              =>       "00001",  -- = TXPOST_TAP_DAC / 2     
        TXPRE_TAP_PD               =>       TRUE,        
                                          
    ----------------------- Restricted RocketIO MGT Attributes -------------------  

    ---Note : THE FOLLOWING ATTRIBUTES ARE RESTRICTED. PLEASE DO NOT EDIT.

     ----------------------------- Restricted: Biasing -------------------------
     
        BANDGAPSEL                 =>       FALSE,
        BIASRESSEL                 =>       FALSE,    
        IREFBIASMODE               =>       "11",
        PMAIREFTRIM                =>       "0111",
        PMAVREFTRIM                =>       "0111",
        TXAREFBIASSEL              =>       TRUE, 
        TXTERMTRIM                 =>       "1100",
        VREFBIASMODE               =>       "11",

     ---------------- Restricted: Frequency Detector and Calibration -----------  
     
        CYCLE_LIMIT_SEL            =>       "00",
        FDET_HYS_CAL               =>       "010",
        FDET_HYS_SEL               =>       "001",
        FDET_LCK_CAL               =>       "101",
        FDET_LCK_SEL               =>       "111",
        LOOPCAL_WAIT               =>       "00",
        RXCYCLE_LIMIT_SEL          =>       "00",
        RXFDET_HYS_CAL             =>       "010",
        RXFDET_HYS_SEL             =>       "001",
        RXFDET_LCK_CAL             =>       "101",   
        RXFDET_LCK_SEL             =>       "100",
        RXLOOPCAL_WAIT             =>       "00",
        RXSLOWDOWN_CAL             =>       "00",
        SLOWDOWN_CAL               =>       "00",

     --------------------------- Restricted: PLL Settings ---------------------
     
        PMACLKENABLE               =>       TRUE,
        PMACOREPWRENABLE           =>       TRUE,
        PMAVBGCTRL                 =>       "00000",
        RXACTST                    =>       TRUE,          
        RXAFETST                   =>       TRUE,         
        RXCMADJ                    =>       "10",
        RXCPSEL                    =>       TRUE,
        RXCPTST                    =>       FALSE,
        RXCTRL1                    =>       x"200",
        RXFECONTROL1               =>       "10",  
        RXFECONTROL2               =>       "111",  
        RXFETUNE                   =>       "00", 
        RXLKADJ                    =>       "00000",
        RXLOOPFILT                 =>       "1111",
        RXPDDTST                   =>       FALSE,          
        RXRCPADJ                   =>       "011",   
        RXRIBADJ                   =>       "11",
        RXVCO_CTRL_ENABLE          =>       TRUE,
        RXVCODAC_INIT              =>       "0000101001",
        TXCPSEL                    =>       TRUE,
        TXCTRL1                    =>       x"200",
        TXLOOPFILT                 =>       "0101",   
        VCO_CTRL_ENABLE            =>       TRUE,
        VCODAC_INIT                =>       "0000101001",
        
    --------------------------- Restricted: Powerdowns ------------------------  
    
        POWER_ENABLE               =>       TRUE,
        RXAFEPD                    =>       FALSE,
        RXAPD                      =>       FALSE,
        RXLKAPD                    =>       FALSE,
        RXPD                       =>       FALSE,
        RXRCPPD                    =>       FALSE,
        RXRPDPD                    =>       FALSE,
        RXRSDPD                    =>       FALSE,
        TXAPD                      =>       FALSE,
        TXDIGPD                    =>       FALSE,
        TXLVLSHFTPD                =>       FALSE,
        TXPD                       =>       FALSE
    )
    port map
    (
        ------------------------------- CRC Ports ------------------------------  

        RXCRCCLK                   =>      '0',
        RXCRCDATAVALID             =>      '0',
        RXCRCDATAWIDTH             =>      (others=>'0'),
        RXCRCIN                    =>      (others=>'0'),
        RXCRCINIT                  =>      '0',
        RXCRCINTCLK                =>      '0',
        RXCRCOUT                   =>      open,
        RXCRCPD                    =>      '0',
        RXCRCRESET                 =>      '0',
        TXCRCCLK                   =>      '0',
        TXCRCDATAVALID             =>      '0',
        TXCRCDATAWIDTH             =>      (others=>'0'),
        TXCRCIN                    =>      (others=>'0'),
        TXCRCINIT                  =>      '0',
        TXCRCINTCLK                =>      '0',
        TXCRCOUT                   =>      open,
        TXCRCPD                    =>      '0',
        TXCRCRESET                 =>      '0',

         ---------------------------- Calibration Ports ------------------------   

        RXCALFAIL                  =>      open,
        RXCYCLELIMIT               =>      open,
        TXCALFAIL                  =>      open,
        TXCYCLELIMIT               =>      open,

        ------------------------------ Serial Ports ----------------------------   

        RX1N                       =>      mgtRxN,
        RX1P                       =>      mgtRxP,
        TX1N                       =>      mgtTxN,
        TX1P                       =>      mgtTxP,

        ------------------------------- PLL Lock -------------------------------   

        RXLOCK                     =>      mgtRxLock,
        TXLOCK                     =>      mgtTxLock,

        -------------------------------- Resets -------------------------------  

        RXPMARESET                 =>      mgtRxPmaReset,
        RXRESET                    =>      mgtRxReset,
        TXPMARESET                 =>      mgtTxPmaReset,
        TXRESET                    =>      mgtTxReset,

        ---------------------------- Synchronization ---------------------------   
                                
        RXSYNC                     =>      '0',
        TXSYNC                     =>      '0',
                                
        ---------------------------- Out of Band Signalling -------------------   

        RXSIGDET                   =>      open,                      
        TXENOOB                    =>      '0',
 
        -------------------------------- Status --------------------------------   

        RXBUFERR                   =>      mgtRxBuffError,
        RXCLKSTABLE                =>      '1',
        RXSTATUS                   =>      mgtRxStatus,
        TXBUFERR                   =>      mgtTxBuffError,
        TXCLKSTABLE                =>      '1',
  
        ---------------------------- Polarity Control Ports -------------------- 

        RXPOLARITY                 =>      '0',
        TXINHIBIT                  =>      '0',
        TXPOLARITY                 =>      '0',

        ------------------------------- Channel Bonding Ports ------------------   

        CHBONDI                    =>      (others=>'0'),
        CHBONDO                    =>      open,
        ENCHANSYNC                 =>      '0',
 
        ---------------------------- 64B66B Blocks Use Ports -------------------   

        RXBLOCKSYNC64B66BUSE       =>      '0',
        RXDEC64B66BUSE             =>      '0',
        RXDESCRAM64B66BUSE         =>      '0',
        RXIGNOREBTF                =>      '0',
        TXENC64B66BUSE             =>      '0',
        TXGEARBOX64B66BUSE         =>      '0',
        TXSCRAM64B66BUSE           =>      '0',

        ---------------------------- 8B10B Blocks Use Ports --------------------   

        RXDEC8B10BUSE              =>      '1',
        TXBYPASS8B10B(7 downto 0)  =>      (others=>'0'),
        TXENC8B10BUSE              =>      '1',
                                    
        ------------------------------ Transmit Control Ports ------------------   

        TXCHARDISPMODE(7 downto 1) =>      (others=>'0'),
        TXCHARDISPMODE(0)          =>      mgtTxCharDispMode,
        TXCHARDISPVAL(7 downto 1)  =>      (others=>'0'),
        TXCHARDISPVAL(0)           =>      mgtTxCharDispVal,
        TXCHARISK(7 downto 1)      =>      (others=>'0'),
        TXCHARISK(0)               =>      mgtTxDataK,
        TXKERR(7 downto 0)         =>      open,
        TXRUNDISP(7 downto 1)      =>      open,
        TXRUNDISP(0)               =>      mgtTxRunDisp,

        ------------------------------ Receive Control Ports -------------------   

        RXCHARISCOMMA(7 downto 1)  =>      open, 
        RXCHARISCOMMA(0)           =>      mgtRxCharIsComma,
        RXCHARISK(7 downto 1)      =>      open,
        RXCHARISK(0)               =>      mgtRxDataKMgt,
        RXDISPERR(7 downto 1)      =>      open,
        RXDISPERR(0)               =>      mgtRxDispErr,
        RXNOTINTABLE(7 downto 1)   =>      open,
        RXNOTINTABLE(0)            =>      mgtRxNotInTable,
        RXRUNDISP(7 downto 1)      =>      open,
        RXRUNDISP(0)               =>      mgtRxRunDispMgt,

        ------------------------------- Serdes Alignment -----------------------  

        ENMCOMMAALIGN              =>      mgtEnCommaAlign,
        ENPCOMMAALIGN              =>      mgtEnCommaAlign,
        RXCOMMADET                 =>      open,
        RXCOMMADETUSE              =>      '1',
        RXLOSSOFSYNC               =>      open,           
        RXREALIGN                  =>      mgtRxReAlign,
        RXSLIDE                    =>      '0',

        ----------- Data Width Settings - Internal and fabric interface -------- 

        RXDATAWIDTH                =>      "00",
        RXINTDATAWIDTH             =>      "11",
        TXDATAWIDTH                =>      "00",
        TXINTDATAWIDTH             =>      "11",

        ------------------------------- Data Ports -----------------------------    

        RXDATA(63 downto  8)       =>      open,
        RXDATA(7  downto  0)       =>      mgtRxDataMgt,
        TXDATA(63 downto  8)       =>      (others=>'0'),
        TXDATA(7  downto  0)       =>      mgtTxData,

         ------------------------------- User Clocks -----------------------------   

        RXMCLK                     =>      open, 
        RXPCSHCLKOUT               =>      open, 
        RXRECCLK1                  =>      open,
        RXRECCLK2                  =>      open,
        RXUSRCLK                   =>      '0', 
        RXUSRCLK2                  =>      emacClk,
        TXOUTCLK1                  =>      open,
        TXOUTCLK2                  =>      open,
        TXPCSHCLKOUT               =>      open,
        TXUSRCLK                   =>      '0', 
        TXUSRCLK2                  =>      emacClk,
   
         ---------------------------- Reference Clocks --------------------------   

        GREFCLK                    =>      emacClk,
        REFCLK1                    =>      '0',
        REFCLK2                    =>      '0',

        ---------------------------- Powerdown and Loopback Ports --------------  

        LOOPBACK(1)                =>      '0',
        LOOPBACK(0)                =>      mgtLoopBack,
        POWERDOWN                  =>      mgtPowerDown,

        ------------------- Dynamic Reconfiguration Port (DRP) ------------------

        DADDR                      =>      (others=>'0'),
        DCLK                       =>      '0',
        DEN                        =>      '1',
        DI                         =>      (others=>'0'),
        DO                         =>      open,
        DRDY                       =>      open,
        DWE                        =>      '0',

       --------------------- MGT Tile Communication Ports ------------------       

        COMBUSIN                   =>      (others=>'0'),
        COMBUSOUT                  =>      open
    );


   -- Ethernet Mac
   U_EMAC : EMAC port map (
      RESET                           => locReset,
      EMAC0CLIENTRXCLIENTCLKOUT       => open,
      CLIENTEMAC0RXCLIENTCLKIN        => emacClk,
      EMAC0CLIENTRXD(15 downto 8)     => open,
      EMAC0CLIENTRXD(7 downto 0)      => emacRxData,
      EMAC0CLIENTRXDVLD               => emacRxValid,
      EMAC0CLIENTRXDVLDMSW            => open,
      EMAC0CLIENTRXGOODFRAME          => emacRxGoodFrame,
      EMAC0CLIENTRXBADFRAME           => emacRxBadFrame,
      EMAC0CLIENTRXFRAMEDROP          => emacRxFrameDrop,
      EMAC0CLIENTRXDVREG6             => open,
      EMAC0CLIENTRXSTATS              => open,
      EMAC0CLIENTRXSTATSVLD           => open,
      EMAC0CLIENTRXSTATSBYTEVLD       => open,
      EMAC0CLIENTTXCLIENTCLKOUT       => open,
      CLIENTEMAC0TXCLIENTCLKIN        => emacClk,
      CLIENTEMAC0TXD(15 downto 8)     => (others=>'0'),
      CLIENTEMAC0TXD(7 downto 0)      => emacTxData,
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
      CLIENTEMAC0PAUSEVAL             => (others=>'0'),
      PHYEMAC0GTXCLK                  => emacClk,
      EMAC0CLIENTTXGMIIMIICLKOUT      => open,
      CLIENTEMAC0TXGMIIMIICLKIN       => '0',
      PHYEMAC0RXCLK                   => '0',
      PHYEMAC0MIITXCLK                => '0',
      PHYEMAC0RXD                     => mgtRxData,
      PHYEMAC0RXDV                    => mgtRxReAlign,
      PHYEMAC0RXER                    => '0',
      EMAC0PHYTXCLK                   => open,
      EMAC0PHYTXD                     => mgtTxData,
      EMAC0PHYTXEN                    => open,
      EMAC0PHYTXER                    => open,
      PHYEMAC0COL                     => mgtTxRunDisp,
      PHYEMAC0CRS                     => '0',
      CLIENTEMAC0DCMLOCKED            => '1',
      EMAC0CLIENTANINTERRUPT          => open,
      PHYEMAC0SIGNALDET               => '1',
      PHYEMAC0PHYAD                   => (others=>'0'),
      EMAC0PHYENCOMMAALIGN            => mgtEnCommaAlign,
      EMAC0PHYLOOPBACKMSB             => mgtLoopBack,
      EMAC0PHYMGTRXRESET              => open,
      EMAC0PHYMGTTXRESET              => open,
      EMAC0PHYPOWERDOWN               => mgtPowerDown,
      EMAC0PHYSYNCACQSTATUS           => open,
      PHYEMAC0RXCLKCORCNT             => emacClkCorCnt,
      PHYEMAC0RXBUFSTATUS(1)          => mgtRxBuffErrorReg,
      PHYEMAC0RXBUFSTATUS(0)          => '0',
      PHYEMAC0RXBUFERR                => mgtRxBuffError,
      PHYEMAC0RXCHARISCOMMA           => mgtRxCharIsComma,
      PHYEMAC0RXCHARISK               => mgtRxDataK,
      PHYEMAC0RXCHECKINGCRC           => '0',
      PHYEMAC0RXCOMMADET              => '0',
      PHYEMAC0RXDISPERR               => mgtRxDispErr,
      PHYEMAC0RXLOSSOFSYNC            => (others=>'0'),
      PHYEMAC0RXNOTINTABLE            => mgtRxNotInTable,
      PHYEMAC0RXRUNDISP               => mgtRxRunDisp,
      PHYEMAC0TXBUFERR                => mgtTxBuffError,
      EMAC0PHYTXCHARDISPMODE          => mgtTxCharDispMode,
      EMAC0PHYTXCHARDISPVAL           => mgtTxCharDispVal,
      EMAC0PHYTXCHARISK               => mgtTxDataK,
      EMAC0PHYMCLKOUT                 => open,
      PHYEMAC0MCLKIN                  => '0',
      PHYEMAC0MDIN                    => '1',
      EMAC0PHYMDOUT                   => open,
      EMAC0PHYMDTRI                   => open,
      TIEEMAC0CONFIGVEC               => macConfig,
      TIEEMAC0UNICASTADDR             => x"010203040506",

      -- MAC 1, Unused
      EMAC1CLIENTRXCLIENTCLKOUT       => open,
      CLIENTEMAC1RXCLIENTCLKIN        => '0',
      EMAC1CLIENTRXD                  => open,
      EMAC1CLIENTRXDVLD               => open,
      EMAC1CLIENTRXDVLDMSW            => open,
      EMAC1CLIENTRXGOODFRAME          => open,
      EMAC1CLIENTRXBADFRAME           => open,
      EMAC1CLIENTRXFRAMEDROP          => open,
      EMAC1CLIENTRXDVREG6             => open,
      EMAC1CLIENTRXSTATS              => open,
      EMAC1CLIENTRXSTATSVLD           => open,
      EMAC1CLIENTRXSTATSBYTEVLD       => open,
      EMAC1CLIENTTXCLIENTCLKOUT       => open,
      CLIENTEMAC1TXCLIENTCLKIN        => '0',
      CLIENTEMAC1TXD                  => (others=>'0'),
      CLIENTEMAC1TXDVLD               => '0',
      CLIENTEMAC1TXDVLDMSW            => '0',
      EMAC1CLIENTTXACK                => open,
      CLIENTEMAC1TXFIRSTBYTE          => '0',
      CLIENTEMAC1TXUNDERRUN           => '0',
      EMAC1CLIENTTXCOLLISION          => open,
      EMAC1CLIENTTXRETRANSMIT         => open,
      CLIENTEMAC1TXIFGDELAY           => (others=>'0'),
      EMAC1CLIENTTXSTATS              => open,
      EMAC1CLIENTTXSTATSVLD           => open,
      EMAC1CLIENTTXSTATSBYTEVLD       => open,
      CLIENTEMAC1PAUSEREQ             => '0',
      CLIENTEMAC1PAUSEVAL             => (others=>'0'),
      PHYEMAC1GTXCLK                  => '0',
      EMAC1CLIENTTXGMIIMIICLKOUT      => open,
      CLIENTEMAC1TXGMIIMIICLKIN       => '0',
      PHYEMAC1RXCLK                   => '0',
      PHYEMAC1RXD                     => (others=>'0'),
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
      PHYEMAC1PHYAD                   => (others=>'0'),
      EMAC1PHYENCOMMAALIGN            => open,
      EMAC1PHYLOOPBACKMSB             => open,
      EMAC1PHYMGTRXRESET              => open,
      EMAC1PHYMGTTXRESET              => open,
      EMAC1PHYPOWERDOWN               => open,
      EMAC1PHYSYNCACQSTATUS           => open,
      PHYEMAC1RXCLKCORCNT             => (others=>'0'),
      PHYEMAC1RXBUFSTATUS             => (others=>'0'),
      PHYEMAC1RXBUFERR                => '0',
      PHYEMAC1RXCHARISCOMMA           => '0',
      PHYEMAC1RXCHARISK               => '0',
      PHYEMAC1RXCHECKINGCRC           => '0',
      PHYEMAC1RXCOMMADET              => '0',
      PHYEMAC1RXDISPERR               => '0',
      PHYEMAC1RXLOSSOFSYNC            => (others=>'0'),
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
      TIEEMAC1CONFIGVEC               => (others => '0'),
      TIEEMAC1UNICASTADDR             => (others=>'0'),
      HOSTCLK                         => '0',
      HOSTOPCODE                      => (others=>'0'),
      HOSTREQ                         => '0',
      HOSTMIIMSEL                     => '0',
      HOSTADDR                        => (others=>'0'),
      HOSTWRDATA                      => (others=>'0'),
      HOSTMIIMRDY                     => open,
      HOSTRDDATA                      => open,
      HOSTEMAC1SEL                    => '0',
      DCREMACCLK                      => '0',
      DCREMACABUS                     => (others=>'0'),
      DCREMACREAD                     => '0',
      DCREMACWRITE                    => '0',
      DCREMACDBUS                     => (others=>'0'),
      EMACDCRACK                      => open,
      EMACDCRDBUS                     => open,
      DCREMACENABLE                   => '0',
      DCRHOSTDONEIR                   => open
   );


   -- Ethernet MAC Config
   macConfig(79)           <= '1';  -- Always Set As '1'
   macConfig(78)           <= '0';  -- PCS/PMA Reset
   macConfig(77)           <= '0';  -- PCS/PMA Auto-Negotiatin Enable
   macConfig(76)           <= '0';  -- PCS/PMA Isolate
   macConfig(75)           <= '0';  -- PCS/PMA Powerdown
   macConfig(74)           <= '0';  -- PCS/PMA Loopback
   macConfig(73)           <= '0';  -- MDIO Enable
   macConfig(72 downto 71) <= "10"; -- Speed
   macConfig(70)           <= '0';  -- RGMII
   macConfig(69)           <= '0';  -- SGMII
   macConfig(68)           <= '1';  -- Has GPCS
   macConfig(67)           <= '0';  -- Has Host
   macConfig(66)           <= '0';  -- TX Client 16
   macConfig(65)           <= '0';  -- RX Client 16
   macConfig(64)           <= '0';  -- Addr Filter Enable
   macConfig(63)           <= '0';  -- Rx Length/Type Check
   macConfig(62)           <= '1';  -- Rx Flow Control
   macConfig(61)           <= '1';  -- Tx Flow Control
   macConfig(60)           <= '0';  -- Transmitter Reset
   macConfig(59)           <= '1';  -- Transmitter Jumbo Frames
   macConfig(58)           <= '0';  -- Transmitter In-band FCS
   macConfig(57)           <= '1';  -- Transmitter Enabled
   macConfig(56)           <= '0';  -- Transmitter VLAN mode
   macConfig(55)           <= '0';  -- Transmitter Half Duplex mode
   macConfig(54)           <= '0';  -- Transmitter IFG Adjust
   macConfig(53)           <= '0';  -- Receiver Reset
   macConfig(52)           <= '1';  -- Receiver Jumbo Frames
   macConfig(51)           <= '0';  -- Receiver In-band FCS
   macConfig(50)           <= '1';  -- Receiver Enabled
   macConfig(49)           <= '0';  -- Receiver VLAN mode
   macConfig(48)           <= '0';  -- Receiver Half Duplex mode
   macConfig(47 downto 0)  <= x"010203040506"; -- Pause MAC Address

   ----------------------------------------------------------------------
   -- Generate Virtex-II Pro style "RXCLKCORCNT" signal from the Virtex4
   -- RXSTATUS signal
   ----------------------------------------------------------------------
   process ( emacClk ) begin
      if rising_edge(emacClk) then
         if mgtRxStatus(4) = '1' and mgtRxStatus(3) = '0' then
            if mgtRxStatus(0) = '1' then
               emacClkCorCnt <= "100";   -- An /I2/ has been inserted    
            else
               emacClkCorCnt <= "001";   -- An /I2/ has been removed
            end if; 
         else                           
            emacClkCorCnt <= "000";      -- Indicates no clock correction    
         end if;                
      end if;
   end process;


   ----------------------------------------------------------------------
   -- When the RXNOTINTABLE condition is detected, the Virtex4 RocketIO
   -- outputs the raw 10B code in a bit swapped order to that of the
   -- Virtex-II Pro RocketIO.
   ----------------------------------------------------------------------
   process (mgtRxNotInTable, mgtRxDataKMgt, mgtRxDataMgt, mgtRxRunDispMgt) begin
      if mgtRxNotInTable = '1' then
         mgtRxData(0)  <= mgtRxDataKMgt;
         mgtRxData(1)  <= mgtRxRunDispMgt;
         mgtRxData(2)  <= mgtRxDataMgt(7); 
         mgtRxData(3)  <= mgtRxDataMgt(6); 
         mgtRxData(4)  <= mgtRxDataMgt(5); 
         mgtRxData(5)  <= mgtRxDataMgt(4); 
         mgtRxData(6)  <= mgtRxDataMgt(3); 
         mgtRxData(7)  <= mgtRxDataMgt(2); 
         mgtRxRunDisp  <= mgtRxDataMgt(1);    
         mgtRxDataK    <= mgtRxDataMgt(0);    
      else
         mgtRxData     <= mgtRxDataMgt;
         mgtRxRunDisp  <= mgtRxRunDispMgt;
         mgtRxDataK    <= mgtRxDataKMgt;
      end if;
   end process;


   -- TX & RX State Machine Synchronous Logic
   process ( emacClk, emacClkRst ) begin
      if emacClkRst = '1' then
         curTxState        <= TX_SYSTEM_RESET after tpd;
         curRxState        <= RX_SYSTEM_RESET after tpd;
         txPcsResetCnt     <= (others=>'0')   after tpd;
         txStateCnt        <= (others=>'0')   after tpd;
         rxPcsResetCnt     <= (others=>'0')   after tpd;
         rxStateCnt        <= (others=>'0')   after tpd;
         mgtRxPmaReset     <= '1'             after tpd;
         mgtRxBuffErrorReg <= '0'             after tpd;
         mgtTxPmaReset     <= '1'             after tpd;
         mgtRxReset        <= '0'             after tpd;
         mgtTxReset        <= '0'             after tpd;
      elsif rising_edge(emacClk) then

         -- Pass on reset signals
         mgtRxPmaReset <= intRxPmaReset after tpd;
         mgtTxPmaReset <= intTxPmaReset after tpd;
         mgtRxReset    <= intRxReset    after tpd;
         mgtTxReset    <= intTxReset    after tpd;

         -- State
         curTxState <= nxtTxState after tpd;
         curRxState <= nxtRxState after tpd;

         -- Tx State Counter
         if txStateCntRst = '1' then
            txStateCnt <= (others=>'0') after tpd;
         else
            txStateCnt <= txStateCnt + 1 after tpd;
         end if;

         -- TX Loop Counter
         if txPcsResetCntRst = '1' then
            txPcsResetCnt <= (others=>'0') after tpd;
         elsif txPcsResetCntEn = '1' then
            txPcsResetCnt <= txPcsResetCnt + 1 after tpd;
         end if;

         -- Rx State Counter
         if rxStateCntRst = '1' then
            rxStateCnt <= (others=>'0') after tpd;
         else
            rxStateCnt <= rxStateCnt + 1 after tpd;
         end if;

         -- RX Loop Counter
         if rxPcsResetCntRst = '1' then
            rxPcsResetCnt <= (others=>'0') after tpd;
         elsif rxPcsResetCntEn = '1' then
            rxPcsResetCnt <= rxPcsResetCnt + 1 after tpd;
         end if;

         -- Register Buffer Status
         if mgtRxBuffError  = '1' then
            mgtRxBuffErrorReg <= '1' after tpd;
         elsif rxClockReady = '1' then
            mgtRxBuffErrorReg <= '0' after tpd;
         end if;
      end if;
   end process;


   -- Async TX State Logic
   process ( curTxState, txStateCnt, mgtTxLock, mgtTxBuffError, txPcsResetCnt ) begin
      case curTxState is 

         -- System Reset State
         when TX_SYSTEM_RESET =>
            txPcsResetCntRst <= '1';
            txPcsResetCntEn  <= '0';
            txStateCntRst    <= '1';
            intTxPmaReset    <= '0';
            intTxReset       <= '0';
            txClockReady     <= '0';
            nxtTxState       <= TX_PMA_RESET;

         -- PMA Reset State
         when TX_PMA_RESET =>
            txPcsResetCntRst <= '0';
            txPcsResetCntEn  <= '0';
            intTxPmaReset    <= '1';
            intTxReset       <= '0';
            txClockReady     <= '0';

            -- Wait for three clocks
            if txStateCnt = 3 then
               nxtTxState    <= TX_WAIT_LOCK;
               txStateCntRst <= '1';
            else
               nxtTxState    <= curTxState;
               txStateCntRst <= '0';
            end if;

         -- Wait for TX Lock
         when TX_WAIT_LOCK =>
            txPcsResetCntRst <= '0';
            txPcsResetCntEn  <= '0';
            intTxPmaReset    <= '0';
            intTxReset       <= '0';
            txStateCntRst    <= '1';
            txClockReady     <= '0';

            -- Wait for three clocks
            if mgtTxLock = '1' then
               nxtTxState <= TX_PCS_RESET;
            else
               nxtTxState <= curTxState;
            end if;
 
         -- Assert PCS Reset
         when TX_PCS_RESET =>
            txPcsResetCntRst <= '0';
            txPcsResetCntEn  <= '0';
            intTxPmaReset    <= '0';
            intTxReset       <= '1';
            txClockReady     <= '0';

            -- Loss of Lock
            if mgtTxLock = '0' then
               nxtTxState    <= TX_WAIT_LOCK;
               txStateCntRst <= '1';

            -- Wait for three clocks
            elsif txStateCnt = 3 then
               nxtTxState    <= TX_WAIT_PCS;
               txStateCntRst <= '1';
            else
               nxtTxState    <= curTxState;
               txStateCntRst <= '0';
            end if;

         -- Wait 5 clocks after PCS reset
         when TX_WAIT_PCS =>
            txPcsResetCntRst <= '0';
            txPcsResetCntEn  <= '0';
            intTxPmaReset    <= '0';
            intTxReset       <= '0';
            txClockReady     <= '0';

            -- Loss of Lock
            if mgtTxLock = '0' then
               nxtTxState    <= TX_WAIT_LOCK;
               txStateCntRst <= '1';

            -- Wait for three clocks
            elsif txStateCnt = 5 then
               nxtTxState    <= TX_ALMOST_READY;
               txStateCntRst <= '1';
            else
               nxtTxState    <= curTxState;
               txStateCntRst <= '0';
            end if;

         -- Almost Ready State
         when TX_ALMOST_READY =>
            intTxPmaReset    <= '0';
            intTxReset       <= '0';
            txClockReady     <= '0';

            -- Loss of Lock
            if mgtTxLock = '0' then
               nxtTxState       <= TX_WAIT_LOCK;
               txStateCntRst    <= '1';
               txPcsResetCntEn  <= '0';
               txPcsResetCntRst <= '0';

            -- TX Buffer Error
            elsif mgtTxBuffError = '1' then
               txStateCntRst   <= '1';
               txPcsResetCntEn <= '1';

               -- 16 Cycles have occured, reset PLL
               if txPcsResetCnt = 15 then
                  nxtTxState       <= TX_PMA_RESET;
                  txPcsResetCntRst <= '1';

               -- Go back to PCS Reset
               else
                  nxtTxState       <= TX_PCS_RESET;
                  txPcsResetCntRst <= '0';
               end if;

            -- Wait for 64 clocks
            elsif txStateCnt = 63 then
               nxtTxState       <= TX_DUMMY;
               txStateCntRst    <= '1';
               txPcsResetCntEn  <= '0';
               txPcsResetCntRst <= '0';
            else
               nxtTxState       <= curTxState;
               txStateCntRst    <= '0';
               txPcsResetCntEn  <= '0';
               txPcsResetCntRst <= '0';
            end if;

         -- Ready State
         when TX_DUMMY =>
            txPcsResetCntRst <= '1';
            txPcsResetCntEn  <= '0';
            intTxReset       <= '0';
            intTxPmaReset    <= '0';
            txStateCntRst    <= '1';
            txClockReady     <= '0';
            nxtTxState       <= TX_READY;

         -- Ready State
         when TX_READY =>
            txPcsResetCntRst <= '1';
            txPcsResetCntEn  <= '0';
            intTxPmaReset    <= '0';
            intTxReset       <= '0';
            txStateCntRst    <= '1';
            txClockReady     <= '1';

            -- Loss of Lock
            if mgtTxLock = '0' then
               nxtTxState <= TX_WAIT_LOCK;

            -- Buffer error has occured
            elsif mgtTxBuffError = '1' then
               nxtTxState <= TX_PCS_RESET;
            else
               nxtTxState <= curTxState;
            end if;

         -- Just in case
         when others =>
            txPcsResetCntRst <= '0';
            txPcsResetCntEn  <= '0';
            intTxPmaReset    <= '0';
            intTxReset       <= '0';
            txStateCntRst    <= '0';
            txClockReady     <= '0';
            nxtTxState       <= TX_SYSTEM_RESET;
      end case;
   end process;


   -- Async RX State Logic
   process ( curRxState, rxStateCnt, mgtRxLock, mgtRxBuffError, rxPcsResetCnt ) begin
      case curRxState is 

         -- System Reset State
         when RX_SYSTEM_RESET =>
            rxPcsResetCntRst <= '1';
            rxPcsResetCntEn  <= '0';
            rxStateCntRst    <= '1';
            intRxPmaReset    <= '0';
            intRxReset       <= '0';
            rxClockReady     <= '0';
            nxtRxState       <= RX_PMA_RESET;

         -- PMA Reset State
         when RX_PMA_RESET =>
            rxPcsResetCntRst <= '0';
            rxPcsResetCntEn  <= '0';
            intRxPmaReset    <= '1';
            intRxReset       <= '0';
            rxClockReady     <= '0';

            -- Wait for three clocks
            if rxStateCnt = 3 then
               nxtRxState    <= RX_WAIT_LOCK;
               rxStateCntRst <= '1';
            else
               nxtRxState    <= curRxState;
               rxStateCntRst <= '0';
            end if;

         -- Wait for RX Lock
         when RX_WAIT_LOCK =>
            rxPcsResetCntRst <= '0';
            rxPcsResetCntEn  <= '0';
            intRxPmaReset    <= '0';
            intRxReset       <= '0';
            rxStateCntRst    <= not mgtRxLock;
            rxClockReady     <= '0';

            -- Wait for rx to be locked for 16K clock cycles
            if rxStateCnt = "11111111111111" then
               nxtRxState <= RX_PCS_RESET;
            else
               nxtRxState <= curRxState;
            end if;
 
         -- Assert PCS Reset
         when RX_PCS_RESET =>
            rxPcsResetCntRst <= '0';
            rxPcsResetCntEn  <= '0';
            intRxPmaReset    <= '0';
            intRxReset       <= '1';
            rxClockReady     <= '0';

            -- Loss of Lock
            if mgtRxLock = '0' then
               nxtRxState    <= RX_WAIT_LOCK;
               rxStateCntRst <= '1';

            -- Wait for three clocks
            elsif rxStateCnt = 3 then
               nxtRxState    <= RX_WAIT_PCS;
               rxStateCntRst <= '1';
            else
               nxtRxState    <= curRxState;
               rxStateCntRst <= '0';
            end if;

         -- Wait 5 clocks after PCS reset
         when RX_WAIT_PCS =>
            rxPcsResetCntRst <= '0';
            rxPcsResetCntEn  <= '0';
            intRxPmaReset    <= '0';
            intRxReset       <= '0';
            rxClockReady     <= '0';

            -- Loss of Lock
            if mgtRxLock = '0' then
               nxtRxState    <= RX_WAIT_LOCK;
               rxStateCntRst <= '1';

            -- Wait for five clocks
            elsif rxStateCnt = 5 then
               nxtRxState    <= RX_ALMOST_READY;
               rxStateCntRst <= '1';
            else
               nxtRxState    <= curRxState;
               rxStateCntRst <= '0';
            end if;

         -- Almost Ready State
         when RX_ALMOST_READY =>
            intRxPmaReset    <= '0';
            intRxReset       <= '0';
            rxClockReady     <= '0';

            -- Loss of Lock
            if mgtRxLock = '0' then
               nxtRxState       <= RX_WAIT_LOCK;
               rxStateCntRst    <= '1';
               rxPcsResetCntEn  <= '0';
               rxPcsResetCntRst <= '0';

            -- RX Buffer Error
            elsif mgtRxBuffError = '1' then
               rxStateCntRst   <= '1';
               rxPcsResetCntEn <= '1';

               -- 16 Cycles have occured, reset PLL
               if rxPcsResetCnt = 15 then
                  nxtRxState       <= RX_PMA_RESET;
                  rxPcsResetCntRst <= '1';

               -- Go back to PCS Reset
               else
                  nxtRxState       <= RX_PCS_RESET;
                  rxPcsResetCntRst <= '0';
               end if;

            -- Wait for 64 clocks
            elsif rxStateCnt = 63 then
               nxtRxState       <= RX_READY;
               rxStateCntRst    <= '1';
               rxPcsResetCntEn  <= '0';
               rxPcsResetCntRst <= '0';
            else
               nxtRxState       <= curRxState;
               rxStateCntRst    <= '0';
               rxPcsResetCntEn  <= '0';
               rxPcsResetCntRst <= '0';
            end if;

         -- Ready State
         when RX_READY =>
            rxPcsResetCntRst <= '1';
            rxPcsResetCntEn  <= '0';
            intRxPmaReset    <= '0';
            intRxReset       <= '0';
            rxStateCntRst    <= '1';
            rxClockReady     <= '1';

            -- Loss of Lock
            if mgtRxLock = '0' then
               nxtRxState <= RX_WAIT_LOCK;

            -- Buffer error has occured
            elsif mgtRxBuffError = '1' then
               nxtRxState <= RX_PCS_RESET;
            else
               nxtRxState <= curRxState;
            end if;

         -- Just in case
         when others =>
            rxPcsResetCntRst <= '0';
            rxPcsResetCntEn  <= '0';
            intRxPmaReset    <= '0';
            intRxReset       <= '0';
            rxStateCntRst    <= '0';
            rxClockReady     <= '0';
            nxtRxState       <= RX_SYSTEM_RESET;
      end case;
   end process;


   -- Ethernet core
   U_EthClient : EthClient generic map ( UdpPort => UdpPort )
   port map (
      emacClk         => emacClk,
      emacClkRst      => locReset,
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
      udpTxReady      => udpTxReady,
      udpTxData       => udpTxData,
      udpTxLength     => udpTxLength,
      udpRxValid      => udpRxValid,
      udpRxData       => udpRxData,
      udpRxGood       => udpRxGood,
      udpRxError      => udpRxError,
      cScopeCtrl1     => cScopeCtrl1,
      cScopeCtrl2     => cScopeCtrl2
   );

end EthMgtWrap;

