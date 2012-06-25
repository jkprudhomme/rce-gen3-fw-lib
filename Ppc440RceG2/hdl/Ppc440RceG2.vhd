
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.Ppc440RceG2Pkg.all;

entity Ppc440RceG2 is
   port (

      -- Clock & Reset Inputs
      refClk125Mhz               : in  std_logic;
      powerOnReset               : in  std_logic;
      pllLocked                  : out std_logic;

      -- Clock & Reset Outputs
      cpuClk312_5Mhz             : out std_logic;
      cpuClk312_5MhzRst          : out std_logic;
      cpuClk312_5Mhz90Deg        : out std_logic;
      cpuClk312_5Mhz90DegRst     : out std_logic;
      cpuClk156_25Mhz            : out std_logic;
      cpuClk156_25MhzRst         : out std_logic;
      cpuClk200Mhz               : out std_logic;
      cpuClk200MhzRst            : out std_logic;
      cpuClk234_375Mhz           : out std_logic;
      cpuClk234_375MhzRst        : out std_logic;

      -- Memory Controller
      mcmiReadData               : in  std_logic_vector(0 to 127);
      mcmiReadDataValid          : in  std_logic;
      mcmiReadDataErr            : in  std_logic;
      mcmiAddrReadyToAccept      : in  std_logic;
      mcmiReadNotWrite           : out std_logic;
      mcmiAddress                : out std_logic_vector(0 to 35);
      mcmiAddressValid           : out std_logic;
      mcmiWriteData              : out std_logic_vector(0 to 127);
      mcmiWriteDataValid         : out std_logic;
      mcmiByteEnable             : out std_logic_vector(0 to 15);
      mcmiBankConflict           : out std_logic;
      mcmiRowConflict            : out std_logic;
      memReady                   : in  std_logic;

      -- DCR Master Port
      dcrPpcDmAck                : in  std_logic;
      dcrppcDmDbusIn             : in  std_logic_vector(0 to 31);
      dcrPpcDmTimeoutWait        : in  std_logic;
      ppcDmDcrRead               : out std_logic;
      ppcDmDcrWrite              : out std_logic;
      ppcDmDcrAbus               : out std_logic_vector(0 to 9);
      ppcDmDcrUAbus              : out std_logic_vector(20 to 21);
      ppcDmDcrDbusOut            : out std_logic_vector(0 to 31);

      -- APU Components
      apuReadFromPpc             : out ApuReadFromPpcVector(0 to 3);
      apuReadToPpc               : in  ApuReadToPpcVector(0 to 3);
      apuWriteFromPpc            : out ApuWriteFromPpcVector(0 to 3);
      apuWriteToPpc              : in  ApuWriteToPpcVector(0 to 3);
      apuLoadFromPpc             : out ApuLoadFromPpcVector(0 to 15);
      apuStoreFromPpc            : out ApuStoreFromPpcVector(0 to 15);
      apuStoreToPpc              : in  ApuStoreToPpcVector(0 to 15);

      -- I2C
      modScl                     : inout std_logic;
      modSda                     : inout std_logic
   );
end Ppc440RceG2;

architecture structure of Ppc440RceG2 is

   -- Local signals
   signal jtgC440Tck                   : std_logic;
   signal jtgC440Tdi                   : std_logic;
   signal jtgC440Tms                   : std_logic;
   signal c440JtgTdo                   : std_logic;
   signal plbPpcmMBusy                 : std_logic;
   signal plbPpcmAddrAck               : std_logic;
   signal plbPpcmRdDack                : std_logic;
   signal plbPpcmRdDbus                : std_logic_vector(0 to 127);
   signal plbPpcmRdWdAddr              : std_logic_vector(0 to 3);
   signal plbPpcmTimeout               : std_logic;
   signal plbPpcmWrDack                : std_logic;
   signal ppcMplbAbus                  : std_logic_vector(0 to 31);
   signal ppcMplbBe                    : std_logic_vector(0 to 15);
   signal ppcMplbRequest               : std_logic;
   signal ppcMplbRnW                   : std_logic;
   signal ppcMplbSize                  : std_logic_vector(0 to 3);
   signal ppcMplbWrDBus                : std_logic_vector(0 to 127);
   signal cpuRstCore                   : std_logic;
   signal cpuRstChip                   : std_logic;
   signal cpuRstSystem                 : std_logic;
   signal cpuRstCoreReq                : std_logic;
   signal cpuRstChipReq                : std_logic;
   signal cpuRstSystemReq              : std_logic;
   signal intClk312_5MhzAdj            : std_logic;
   signal intClk312_5Mhz90DegAdj       : std_logic;
   signal intClk156_25MhzAdj           : std_logic;
   signal intClk200MhzAdj              : std_logic;
   signal intClk312_5Mhz               : std_logic;
   signal intClk468_75Mhz              : std_logic;
   signal intClk234_375MhzAdj          : std_logic;
   signal intClk312_5MhzAdjRst         : std_logic;
   signal intClk312_5Mhz90DegAdjRst    : std_logic;
   signal intClk156_25MhzAdjRst        : std_logic;
   signal intClk156_25MhzAdjRstPon     : std_logic;
   signal intClk200MhzAdjRst           : std_logic;
   signal intClk312_5MhzRst            : std_logic;
   signal intClk468_75MhzRst           : std_logic;
   signal intClk234_375MhzAdjRst       : std_logic;
   signal iicClkO                      : std_logic;
   signal iicClkI                      : std_logic;
   signal iicClkT                      : std_logic; 
   signal iicDataO                     : std_logic;
   signal iicDataI                     : std_logic;
   signal iicDataT                     : std_logic; 
   signal extIrq                       : std_logic;
   signal resetReq                     : std_logic;
   signal fcmApuConfirmInstr           : std_logic;
   signal fcmApuCr                     : std_logic_vector(0 to 3);
   signal fcmApuDone                   : std_logic;
   signal fcmApuException              : std_logic;
   signal fcmApuFpsCrFex               : std_logic;
   signal fcmApuResult                 : std_logic_vector(0 to 31);
   signal fcmApuResultValid            : std_logic;
   signal fcmApuSleepNotReady          : std_logic;
   signal fcmApuStoreData              : std_logic_vector(0 to 127);
   signal apuFcmDecFpuOp               : std_logic;
   signal apuFcmDecLdsTxferSize        : std_logic_vector(0 to 2);
   signal apuFcmDecLoad                : std_logic;
   signal apuFcmDecNonAuton            : std_logic;
   signal apuFcmDecStore               : std_logic;
   signal apuFcmDecUdi                 : std_logic_vector(0 to 3);
   signal apuFcmDecUdiValid            : std_logic;
   signal apuFcmEndian                 : std_logic;
   signal apuFcmFlush                  : std_logic;
   signal apuFcmInstruction            : std_logic_vector(0 to 31);
   signal apuFcmInstrValid             : std_logic;
   signal apuFcmLoadByteAddr           : std_logic_vector(0 to 3);
   signal apuFcmLoadData               : std_logic_vector(0 to 127);
   signal apuFcmLoadDValid             : std_logic;
   signal apuFcmMsrFe0                 : std_logic;
   signal apuFcmMsrFe1                 : std_logic;
   signal apuFcmNextInstrReady         : std_logic;
   signal apuFcmOperandValid           : std_logic;
   signal apuFcmRaData                 : std_logic_vector(0 to 31);
   signal apuFcmRbData                 : std_logic_vector(0 to 31);
   signal apuFcmWriteBackOk            : std_logic;
   signal iapuReadFromPpc              : ApuReadFromPpcVector(0 to 7);
   signal iapuReadToPpc                : ApuReadToPpcVector(0 to 7);
   signal iapuWriteFromPpc             : ApuWriteFromPpcVector(0 to 7);
   signal iapuWriteToPpc               : ApuWriteToPpcVector(0 to 7);
   signal iapuLoadFromPpc              : ApuLoadFromPpcVector(0 to 31);
   signal iapuStoreFromPpc             : ApuStoreFromPpcVector(0 to 31);
   signal iapuStoreToPpc               : ApuStoreToPpcVector(0 to 31);
   signal apuReadStatus                : std_logic_vector(0 to 31);
   signal apuWriteStatus               : std_logic_vector(0 to 31);

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- Connect output clocks, drop adj flag when going external
   cpuClk312_5Mhz             <= intClk312_5MhzAdj;
   cpuClk312_5MhzRst          <= intClk312_5MhzAdjRst;
   cpuClk312_5Mhz90Deg        <= intClk312_5Mhz90DegAdj;
   cpuClk312_5Mhz90DegRst     <= intClk312_5Mhz90DegAdjRst;
   cpuClk156_25Mhz            <= intClk156_25MhzAdj;
   cpuClk156_25MhzRst         <= intClk156_25MhzAdjRst;
   cpuClk200Mhz               <= intClk200MhzAdj;
   cpuClk200MhzRst            <= intClk200MhzAdjRst;
   cpuClk234_375Mhz           <= intClk234_375MhzAdj;
   cpuClk234_375MhzRst        <= intClk234_375MhzAdjRst;

   -- External APU interfaces
   apuReadFromPpc          <= iapuReadFromPpc(0 to 3);
   iapuReadToPpc(0 to 3)   <= apuReadToPpc;
   apuWriteFromPpc         <= iapuWriteFromPpc(0 to 3);
   iapuWriteToPpc(0 to 3)  <= apuWriteToPpc;
   apuLoadFromPpc          <= iapuLoadFromPpc(0 to 15);
   apuStoreFromPpc         <= iapuStoreFromPpc(0 to 15);
   iapuStoreToPpc(0 to 15) <= apuStoreToPpc;

   ----------------------------------------------------------------------------
   -- Instantiate PPC440 Processor Block Primitive
   ----------------------------------------------------------------------------
   U_PPC440 : PPC440
      generic map (
         INTERCONNECT_IMASK    => x"FFFFFFFF",
         XBAR_ADDRMAP_TMPL0    => x"FFFF0000",
         XBAR_ADDRMAP_TMPL1    => x"00000000",
         XBAR_ADDRMAP_TMPL2    => x"00000000",
         XBAR_ADDRMAP_TMPL3    => x"00000000",
         INTERCONNECT_TMPL_SEL => x"3FFFFFFF",
         CLOCK_DELAY           => TRUE,
         APU_CONTROL           => B"00010000000100001",

--LD/ST Decode Disable               5 0     0
--UDI Decode Disable                 6 1     0
--Force UDI Non-auton, late confirm  7 2     0
--FPU Decode Disable                 8 3     1

--FPU Complex Arith. Disable         9 4     0
--FPU Convert Disable               10 5     0
--FPU Estimate/Select Disable       11 6     0
--FPU Single Precision Disable      12 7     0

--FPU Double Precision Disable      13 8     0
--FPU FPSCR Disable                 14 9     0
--Force FPU Non-auton, late confirm 15 10    0
--Store WriteBack OK                16 11    1

--Ld/St Priv. Op                    17 12    0
--Force Align                       20 13    0
--LE Trap                           21 14    0
--BE Trap                           22 15    0

--FCM Enable                        31 16    1

         APU_UDI0              => x"C06781", -- UDI0  read, cr en, non-auto, early confirm
         APU_UDI1              => x"C47609", -- UDI1  write, autonomous
         APU_UDI2              => x"C86781", -- UDI2  read, cr en, non-auto, early confirm
         APU_UDI3              => x"CC7609", -- UDI3  write, autonomous
         APU_UDI4              => x"D06781", -- UDI4  read, cr en, non-auto, early confirm
         APU_UDI5              => x"D47609", -- UDI5  write, autonomous
         APU_UDI6              => x"D86781", -- UDI6  read, cr en, non-auto, early confirm
         APU_UDI7              => x"DC7609", -- UDI7  write, autonomous
         APU_UDI8              => x"E06781", -- UDI8  read, cr en, non-auto, early confirm
         APU_UDI9              => x"E47609", -- UDI9  write, autonomous
         APU_UDI10             => x"E86781", -- UDI10 read, cr en, non-auto, early confirm
         APU_UDI11             => x"EC7609", -- UDI11 write, autonomous
         APU_UDI12             => x"F06781", -- UDI12 read, cr en, non-auto, early confirm
         APU_UDI13             => x"F47609", -- UDI13 write, autonomous
         APU_UDI14             => x"F86781", -- UDI14 read, cr en, non-auto, early confirm
         APU_UDI15             => x"FC7609", -- UDI15 write, autonomous
         MI_ROWCONFLICT_MASK   => X"00FFFE00",
         MI_BANKCONFLICT_MASK  => X"07000000",
         MI_ARBCONFIG          => X"00432010",
         MI_CONTROL            => X"F820008F",
         PPCM_CONTROL          => X"8000009F",
         PPCM_COUNTER          => X"00000500",
         PPCM_ARBCONFIG        => X"00432010",
         PPCS0_CONTROL         => x"8033336C",
         PPCS0_WIDTH_128N64    => TRUE ,
         PPCS0_ADDRMAP_TMPL0   => x"00000000",
         PPCS0_ADDRMAP_TMPL1   => x"00000000",
         PPCS0_ADDRMAP_TMPL2   => x"00000000",
         PPCS0_ADDRMAP_TMPL3   => x"00000000",
         PPCS1_CONTROL         => x"8033336C",
         PPCS1_WIDTH_128N64    => TRUE ,
         PPCS1_ADDRMAP_TMPL0   => x"00000000",
         PPCS1_ADDRMAP_TMPL1   => x"00000000",
         PPCS1_ADDRMAP_TMPL2   => x"00000000",
         PPCS1_ADDRMAP_TMPL3   => x"00000000",
         DMA0_TXCHANNELCTRL    => X"01010000",
         DMA0_RXCHANNELCTRL    => X"01010000",
         DMA0_CONTROL          => B"00000000",
         DMA0_TXIRQTIMER       => B"1111111111",
         DMA0_RXIRQTIMER       => B"1111111111",
         DMA1_TXCHANNELCTRL    => X"01010000",
         DMA1_RXCHANNELCTRL    => X"01010000",
         DMA1_CONTROL          => B"00000000",
         DMA1_TXIRQTIMER       => B"1111111111",
         DMA1_RXIRQTIMER       => B"1111111111",
         DMA2_TXCHANNELCTRL    => X"01010000",
         DMA2_RXCHANNELCTRL    => X"01010000",
         DMA2_CONTROL          => B"00000000",
         DMA2_TXIRQTIMER       => B"1111111111",
         DMA2_RXIRQTIMER       => B"1111111111",
         DMA3_TXCHANNELCTRL    => X"01010000",
         DMA3_RXCHANNELCTRL    => X"01010000",
         DMA3_CONTROL          => B"00000000",
         DMA3_TXIRQTIMER       => B"1111111111",
         DMA3_RXIRQTIMER       => B"1111111111",
         DCR_AUTOLOCK_ENABLE   => TRUE,
         PPCDM_ASYNCMODE       => FALSE,
         PPCDS_ASYNCMODE       => FALSE
      )
      port map (

         -- TIE
         TIEC440ENDIANRESET          => '0',
         TIEC440ERPNRESET            => (others=>'0'),
         TIEC440PIR                  => B"1111",
         TIEC440PVR                  => (others=>'0'),
         TIEC440USERRESET            => B"0000",
         TIEC440ICURDFETCHPLBPRIO    => B"00",
         TIEC440ICURDSPECPLBPRIO     => B"00",
         TIEC440ICURDTOUCHPLBPRIO    => B"00",
         TIEC440DCURDLDCACHEPLBPRIO  => B"00",
         TIEC440DCURDNONCACHEPLBPRIO => B"00",
         TIEC440DCURDTOUCHPLBPRIO    => B"00",
         TIEC440DCURDURGENTPLBPRIO   => B"00",
         TIEC440DCUWRFLUSHPLBPRIO    => B"00",
         TIEC440DCUWRSTOREPLBPRIO    => B"00",
         TIEC440DCUWRURGENTPLBPRIO   => B"00",
         TIEDCRBASEADDR              => "11",

         -- Control
         C440MACHINECHECK            => open,
          
         -- MPLB 
         PLBPPCMMBUSY                => plbPpcmMBusy,
         PLBPPCMMIRQ                 => '0',
         PLBPPCMMRDERR               => '0',
         PLBPPCMMWRERR               => '0',
         PLBPPCMADDRACK              => plbPpcmAddrAck,
         PLBPPCMRDBTERM              => '0',
         PLBPPCMRDDACK               => plbPpcmRdDack,
         PLBPPCMRDDBUS               => plbPpcmRdDbus,
         PLBPPCMRDWDADDR             => plbPpcmRdWdAddr,
         PLBPPCMREARBITRATE          => '0',
         PLBPPCMSSIZE                => "01",
         PLBPPCMTIMEOUT              => plbPpcmTimeout,
         PLBPPCMWRBTERM              => '0',
         PLBPPCMWRDACK               => plbPpcmWrDack,
         PLBPPCMRDPENDPRI            => "00",
         PLBPPCMRDPENDREQ            => '0',
         PLBPPCMREQPRI               => "00",
         PLBPPCMWRPENDPRI            => "00",
         PLBPPCMWRPENDREQ            => '0',
         PPCMPLBABORT                => open,
         PPCMPLBABUS                 => ppcMplbAbus,
         PPCMPLBBE                   => ppcMplbBe,
         PPCMPLBBUSLOCK              => open,
         PPCMPLBLOCKERR              => open,
         PPCMPLBPRIORITY             => open,
         PPCMPLBRDBURST              => open,
         PPCMPLBREQUEST              => ppcMplbRequest,
         PPCMPLBRNW                  => ppcMplbRnW,
         PPCMPLBSIZE                 => ppcMplbSize,
         PPCMPLBTATTRIBUTE           => open,
         PPCMPLBTYPE                 => open,
         PPCMPLBUABUS                => open,
         PPCMPLBWRBURST              => open,
         PPCMPLBWRDBUS               => ppcMplbWrDBus,

         -- SPLB 0
         PLBPPCS0MASTERID            => "00",
         PLBPPCS0PAVALID             => '0',
         PLBPPCS0SAVALID             => '0',
         PLBPPCS0RDPENDREQ           => '0',
         PLBPPCS0WRPENDREQ           => '0',
         PLBPPCS0RDPENDPRI           => "00",
         PLBPPCS0WRPENDPRI           => "00",
         PLBPPCS0REQPRI              => "00",
         PLBPPCS0RDPRIM              => '0',
         PLBPPCS0WRPRIM              => '0',
         PLBPPCS0BUSLOCK             => '0',
         PLBPPCS0ABORT               => '0',
         PLBPPCS0RNW                 => '0',
         PLBPPCS0BE                  => x"0000",
         PLBPPCS0SIZE                => "0000",
         PLBPPCS0TYPE                => "000",
         PLBPPCS0TATTRIBUTE          => x"0000",
         PLBPPCS0LOCKERR             => '0',
         PLBPPCS0MSIZE               => "00",
         PLBPPCS0UABUS               => "0000",
         PLBPPCS0ABUS                => x"00000000",
         PLBPPCS0WRDBUS              => x"00000000000000000000000000000000",
         PLBPPCS0WRBURST             => '0',
         PLBPPCS0RDBURST             => '0',
         PPCS0PLBADDRACK             => open,
         PPCS0PLBWAIT                => open,
         PPCS0PLBREARBITRATE         => open,
         PPCS0PLBWRDACK              => open,
         PPCS0PLBWRCOMP              => open,
         PPCS0PLBRDDBUS              => open,
         PPCS0PLBRDWDADDR            => open,
         PPCS0PLBRDDACK              => open,
         PPCS0PLBRDCOMP              => open,
         PPCS0PLBRDBTERM             => open,
         PPCS0PLBWRBTERM             => open,
         PPCS0PLBMBUSY               => open,
         PPCS0PLBMRDERR              => open,
         PPCS0PLBMWRERR              => open,
         PPCS0PLBMIRQ                => open,
         PPCS0PLBSSIZE               => open,
          
         -- SPLB 1
         PLBPPCS1MASTERID            => "00",
         PLBPPCS1PAVALID             => '0',
         PLBPPCS1SAVALID             => '0',
         PLBPPCS1RDPENDREQ           => '0',
         PLBPPCS1WRPENDREQ           => '0',
         PLBPPCS1RDPENDPRI           => "00",
         PLBPPCS1WRPENDPRI           => "00",
         PLBPPCS1REQPRI              => "00",
         PLBPPCS1RDPRIM              => '0',
         PLBPPCS1WRPRIM              => '0',
         PLBPPCS1BUSLOCK             => '0',
         PLBPPCS1ABORT               => '0',
         PLBPPCS1RNW                 => '0',
         PLBPPCS1BE                  => x"0000",
         PLBPPCS1SIZE                => "0000",
         PLBPPCS1TYPE                => "000",
         PLBPPCS1TATTRIBUTE          => x"0000",
         PLBPPCS1LOCKERR             => '0',
         PLBPPCS1MSIZE               => "00",
         PLBPPCS1UABUS               => "0000",
         PLBPPCS1ABUS                => x"00000000",
         PLBPPCS1WRDBUS              => x"00000000000000000000000000000000",
         PLBPPCS1WRBURST             => '0',
         PLBPPCS1RDBURST             => '0',
         PPCS1PLBADDRACK             => open,
         PPCS1PLBWAIT                => open,
         PPCS1PLBREARBITRATE         => open,
         PPCS1PLBWRDACK              => open,
         PPCS1PLBWRCOMP              => open,
         PPCS1PLBRDDBUS              => open,
         PPCS1PLBRDWDADDR            => open,
         PPCS1PLBRDDACK              => open,
         PPCS1PLBRDCOMP              => open,
         PPCS1PLBRDBTERM             => open,
         PPCS1PLBWRBTERM             => open,
         PPCS1PLBMBUSY               => open,
         PPCS1PLBMRDERR              => open,
         PPCS1PLBMWRERR              => open,
         PPCS1PLBMIRQ                => open,
         PPCS1PLBSSIZE               => open,

         -- Memory Controller
         MCMIREADDATA                => mcmiReadData,
         MCMIREADDATAVALID           => mcmiReadDataValid,
         MCMIREADDATAERR             => mcmiReadDataErr,
         MCMIADDRREADYTOACCEPT       => mcmiAddrReadyToAccept,
         MIMCREADNOTWRITE            => mcmiReadNotWrite,
         MIMCADDRESS                 => mcmiAddress,
         MIMCADDRESSVALID            => mcmiAddressValid,
         MIMCWRITEDATA               => mcmiWriteData,
         MIMCWRITEDATAVALID          => mcmiWriteDataValid,
         MIMCBYTEENABLE              => mcmiByteEnable,
         MIMCBANKCONFLICT            => mcmiBankConflict,
         MIMCROWCONFLICT             => mcmiRowConflict,
 
         -- Resets, Clocks & Power Management
         RSTC440RESETCORE            => cpuRstCore,
         RSTC440RESETCHIP            => cpuRstChip,
         RSTC440RESETSYSTEM          => cpuRstSystem,
         C440RSTCORERESETREQ         => cpuRstCoreReq,
         C440RSTCHIPRESETREQ         => cpuRstChipReq,
         C440RSTSYSTEMRESETREQ       => cpuRstSystemReq,
         CPMC440CLKEN                => '1',
         CPMC440CORECLOCKINACTIVE    => '0',
         CPMC440TIMERCLOCK           => '1',
         CPMINTERCONNECTCLK          => intClk312_5Mhz,
         CPMINTERCONNECTCLKEN        => '1',
         CPMINTERCONNECTCLKNTO1      => '0',
         PPCCPMINTERCONNECTBUSY      => open,
         CPMC440CLK                  => intClk468_75Mhz,
         CPMDCRCLK                   => intClk156_25MhzAdj,
         CPMFCMCLK                   => intClk234_375MhzAdj,
         CPMMCCLK                    => intClk312_5MhzAdj,
         CPMPPCS1PLBCLK              => '1',
         CPMPPCS0PLBCLK              => '1',
         CPMPPCMPLBCLK               => intClk156_25MhzAdj,
         CPMDMA0LLCLK                => '1',
         CPMDMA1LLCLK                => '1',
         CPMDMA2LLCLK                => '1',
         CPMDMA3LLCLK                => '0',
         C440CPMCORESLEEPREQ         => open,
         C440CPMDECIRPTREQ           => open,
         C440CPMFITIRPTREQ           => open,
         C440CPMMSRCE                => open,
         C440CPMMSREE                => open,
         C440CPMTIMERRESETREQ        => open,
         C440CPMWDIRPTREQ            => open,

         -- DCR Slave Port
         DCRPPCDSREAD                => '0',
         DCRPPCDSWRITE               => '0',
         DCRPPCDSABUS                => "0000000000",
         DCRPPCDSDBUSOUT             => x"00000000",
         PPCDSDCRACK                 => open,
         PPCDSDCRDBUSIN              => open,
         PPCDSDCRTIMEOUTWAIT         => open,

         -- DCR Master Port
         DCRPPCDMACK                 => dcrPpcDmAck,
         DCRPPCDMDBUSIN              => dcrppcDmDbusIn,
         DCRPPCDMTIMEOUTWAIT         => dcrPpcDmTimeoutWait,
         PPCDMDCRREAD                => ppcDmDcrRead,
         PPCDMDCRWRITE               => ppcDmDcrWrite,
         PPCDMDCRABUS                => ppcDmDcrAbus,
         PPCDMDCRUABUS               => ppcDmDcrUAbus,
         PPCDMDCRDBUSOUT             => ppcDmDcrDbusOut,

         -- Interupt Controller
         EICC440CRITIRQ              => '0',
         EICC440EXTIRQ               => extIrq,
         PPCEICINTERCONNECTIRQ       => open,

         -- JTAG Interface
         JTGC440TCK                  => jtgC440Tck,
         JTGC440TDI                  => jtgC440Tdi,
         JTGC440TMS                  => jtgC440Tms,
         JTGC440TRSTNEG              => '1',
         C440JTGTDO                  => c440JtgTdo,
         C440JTGTDOEN                => open,

         -- Debug Interface 
         DBGC440DEBUGHALT            => '0',
         DBGC440SYSTEMSTATUS         => "00000",
         DBGC440UNCONDDEBUGEVENT     => '0',
         C440DBGSYSTEMCONTROL        => open,
         
         -- Trace Interface
         TRCC440TRACEDISABLE         => '0',
         TRCC440TRIGGEREVENTIN       => '0',
         C440TRCBRANCHSTATUS         => open,
         C440TRCCYCLE                => open,
         C440TRCEXECUTIONSTATUS      => open,
         C440TRCTRACESTATUS          => open,
         C440TRCTRIGGEREVENTOUT      => open,
         C440TRCTRIGGEREVENTTYPE     => open,

         -- APU Interface
         FCMAPUCONFIRMINSTR          => fcmApuConfirmInstr,
         FCMAPUCR                    => fcmApuCr,
         FCMAPUDONE                  => fcmApuDone,
         FCMAPUEXCEPTION             => fcmApuException,
         FCMAPUFPSCRFEX              => fcmApuFpsCrFex,
         FCMAPURESULT                => fcmApuResult,
         FCMAPURESULTVALID           => fcmApuResultValid,
         FCMAPUSLEEPNOTREADY         => fcmApuSleepNotReady,
         FCMAPUSTOREDATA             => fcmApuStoreData,
         APUFCMDECFPUOP              => apuFcmDecFpuOp,
         APUFCMDECLDSTXFERSIZE       => apuFcmDecLdsTxferSize,
         APUFCMDECLOAD               => apuFcmDecLoad,
         APUFCMDECNONAUTON           => apuFcmDecNonAuton,
         APUFCMDECSTORE              => apuFcmDecStore,
         APUFCMDECUDI                => apuFcmDecUdi,
         APUFCMDECUDIVALID           => apuFcmDecUdiValid,
         APUFCMENDIAN                => apuFcmEndian,
         APUFCMFLUSH                 => apuFcmFlush,
         APUFCMINSTRUCTION           => apuFcmInstruction,
         APUFCMINSTRVALID            => apuFcmInstrValid,
         APUFCMLOADBYTEADDR          => apuFcmLoadByteAddr,
         APUFCMLOADDATA              => apuFcmLoadData,
         APUFCMLOADDVALID            => apuFcmLoadDValid,
         APUFCMMSRFE0                => apuFcmMsrFe0,
         APUFCMMSRFE1                => apuFcmMsrFe1,
         APUFCMNEXTINSTRREADY        => apuFcmNextInstrReady,
         APUFCMOPERANDVALID          => apuFcmOperandValid,
         APUFCMRADATA                => apuFcmRaData,
         APUFCMRBDATA                => apuFcmRbData,
         APUFCMWRITEBACKOK           => apuFcmWriteBackOk,

         -- DMA Controller 0
         LLDMA0TXDSTRDYN             => '1',
         LLDMA0RXD                   => x"00000000",
         LLDMA0RXREM                 => "0000",
         LLDMA0RXSOFN                => '1',
         LLDMA0RXEOFN                => '1',
         LLDMA0RXSOPN                => '1',
         LLDMA0RXEOPN                => '1',
         LLDMA0RXSRCRDYN             => '1',
         LLDMA0RSTENGINEREQ          => '0',
         DMA0LLTXD                   => open,
         DMA0LLTXREM                 => open,
         DMA0LLTXSOFN                => open,
         DMA0LLTXEOFN                => open,
         DMA0LLTXSOPN                => open,
         DMA0LLTXEOPN                => open,
         DMA0LLTXSRCRDYN             => open,
         DMA0LLRXDSTRDYN             => open,
         DMA0LLRSTENGINEACK          => open,
         DMA0TXIRQ                   => open,
         DMA0RXIRQ                   => open,
          
         -- DMA Controller 1 
         LLDMA1TXDSTRDYN             => '1',
         LLDMA1RXD                   => x"00000000",
         LLDMA1RXREM                 => "0000",
         LLDMA1RXSOFN                => '1',
         LLDMA1RXEOFN                => '1',
         LLDMA1RXSOPN                => '1',
         LLDMA1RXEOPN                => '1',
         LLDMA1RXSRCRDYN             => '1',
         LLDMA1RSTENGINEREQ          => '0',
         DMA1LLTXD                   => open,
         DMA1LLTXREM                 => open,
         DMA1LLTXSOFN                => open,
         DMA1LLTXEOFN                => open,
         DMA1LLTXSOPN                => open,
         DMA1LLTXEOPN                => open,
         DMA1LLTXSRCRDYN             => open,
         DMA1LLRXDSTRDYN             => open,
         DMA1LLRSTENGINEACK          => open,
         DMA1TXIRQ                   => open,
         DMA1RXIRQ                   => open,
          
         -- DMA Controller 2 
         LLDMA2TXDSTRDYN             => '1',
         LLDMA2RXD                   => x"00000000",
         LLDMA2RXREM                 => "0000",
         LLDMA2RXSOFN                => '1',
         LLDMA2RXEOFN                => '1',
         LLDMA2RXSOPN                => '1',
         LLDMA2RXEOPN                => '1',
         LLDMA2RXSRCRDYN             => '1',
         LLDMA2RSTENGINEREQ          => '0',
         DMA2LLTXD                   => open,
         DMA2LLTXREM                 => open,
         DMA2LLTXSOFN                => open,
         DMA2LLTXEOFN                => open,
         DMA2LLTXSOPN                => open,
         DMA2LLTXEOPN                => open,
         DMA2LLTXSRCRDYN             => open,
         DMA2LLRXDSTRDYN             => open,
         DMA2LLRSTENGINEACK          => open,
         DMA2TXIRQ                   => open,
         DMA2RXIRQ                   => open,
         
         -- DMA Controller 3 
         LLDMA3TXDSTRDYN             => '1',
         LLDMA3RXD                   => x"00000000",
         LLDMA3RXREM                 => "0000",
         LLDMA3RXSOFN                => '1',
         LLDMA3RXEOFN                => '1',
         LLDMA3RXSOPN                => '1',
         LLDMA3RXEOPN                => '1',
         LLDMA3RXSRCRDYN             => '1',
         LLDMA3RSTENGINEREQ          => '0',
         DMA3LLTXD                   => open,
         DMA3LLTXREM                 => open,
         DMA3LLTXSOFN                => open,
         DMA3LLTXEOFN                => open,
         DMA3LLTXSOPN                => open,
         DMA3LLTXEOPN                => open,
         DMA3LLTXSRCRDYN             => open,
         DMA3LLRXDSTRDYN             => open,
         DMA3LLRSTENGINEACK          => open,
         DMA3TXIRQ                   => open,
         DMA3RXIRQ                   => open
      );


   -- JTAG Controller
   U_JTAGPPC440 : JTAGPPC440 
      port map (
         TCK      => jtgC440Tck,
         TDIPPC   => jtgC440Tdi,
         TMS      => jtgC440Tms,
         TDOPPC   => c440JtgTdo 
      );

   ----------------------------------------------------------------------------
   -- Boot block ram control
   ----------------------------------------------------------------------------
   U_Ppc440RceG2Boot : Ppc440RceG2Boot 
      port map (
         bramClk           => intClk156_25MhzAdj,
         bramClkRst        => intClk156_25MhzAdjRst,
         plbPpcmMBusy      => plbPpcmMBusy,
         plbPpcmAddrAck    => plbPpcmAddrAck,
         plbPpcmRdDack     => plbPpcmRdDack,
         plbPpcmRdDbus     => plbPpcmRdDbus,
         plbPpcmRdWdAddr   => plbPpcmRdWdAddr,
         plbPpcmTimeout    => plbPpcmTimeout,
         plbPpcmWrDack     => plbPpcmWrDack,
         ppcMplbAbus       => ppcMplbAbus,
         ppcMplbBe         => ppcMplbBe,
         ppcMplbRequest    => ppcMplbRequest,
         ppcMplbRnW        => ppcMplbRnW,
         ppcMplbSize       => ppcMplbSize,
         ppcMplbWrDBus     => ppcMplbWrDBus
      );


   ----------------------------------------------------------------------------
   -- Reset and clock generation
   ----------------------------------------------------------------------------
   U_Ppc440RceG2Clk : Ppc440RceG2Clk port map (
      refClk125Mhz               => refClk125Mhz,
      powerOnReset               => powerOnReset,
      --masterReset                => resetReq,
      masterReset                => powerOnReset,
      memReady                   => memReady,
      pllLocked                  => pllLocked,
      cpuClk312_5Mhz             => intClk312_5Mhz,
      cpuClk312_5MhzAdj          => intClk312_5MhzAdj,
      cpuClk312_5Mhz90DegAdj     => intClk312_5Mhz90DegAdj,
      cpuClk156_25MhzAdj         => intClk156_25MhzAdj,
      cpuClk468_75Mhz            => intClk468_75Mhz,
      cpuClk234_375MhzAdj        => intClk234_375MhzAdj,
      cpuClk200MhzAdj            => intClk200MhzAdj,
      cpuClk312_5MhzRst          => intClk312_5MhzRst,
      cpuClk312_5MhzAdjRst       => intClk312_5MhzAdjRst,
      cpuClk312_5Mhz90DegAdjRst  => intClk312_5Mhz90DegAdjRst,
      cpuClk156_25MhzAdjRst      => intClk156_25MhzAdjRst,
      cpuClk156_25MhzAdjRstPon   => intClk156_25MhzAdjRstPon,
      cpuClk468_75MhzRst         => intClk468_75MhzRst,
      cpuClk234_375MhzAdjRst     => intClk234_375MhzAdjRst,
      cpuClk200MhzAdjRst         => intClk200MhzAdjRst,
      cpuRstCore                 => cpuRstCore,
      cpuRstChip                 => cpuRstChip,
      cpuRstSystem               => cpuRstSystem,
      cpuRstCoreReq              => cpuRstCoreReq,
      cpuRstChipReq              => cpuRstChipReq,
      cpuRstSystemReq            => cpuRstSystemReq
   );

   ----------------------------------------------------------------------------
   -- I2C Slave
   ----------------------------------------------------------------------------
   U_Ppc440RceG2I2c : Ppc440RceG2I2c port map (
      rst_i           => intClk156_25MhzAdjRstPon,
      rst_o           => resetReq,
      interrupt       => extIrq,
      clk32           => intClk156_25MhzAdj,
      apuClk          => intClk234_375MhzAdj,
      apuWriteFromPpc => iapuWriteFromPpc(7),
      apuWriteToPpc   => iapuWriteToPpc(7),
      apuReadFromPpc  => iapuReadFromPpc(7),
      apuReadToPpc    => iapuReadToPpc(7),
      iic_addr        => "1001001",
      iic_clki        => iicClkI,
      iic_clko        => iicClkO,
      iic_clkt        => iicClkT,
      iic_datai       => iicDataI,
      iic_datao       => iicDataO,
      iic_datat       => iicDataT,
      debug           => open 
   );

   U_I2cScl : IOBUF port map ( IO => modScl,
                               I  => iicClkO,
                               O  => iicClkI,
                               T  => iicClkT);

   U_I2cSda : IOBUF port map ( IO => modSda,
                               I  => iicDataO,
                               O  => iicDataI,
                               T  => iicDataT);

   ----------------------------------------------------------------------------
   -- APU Interface
   ----------------------------------------------------------------------------
   U_Ppc440RceG2Apu : Ppc440RceG2Apu port map (
      apuClk                => intClk234_375MhzAdj,
      apuClkRst             => intClk234_375MhzAdjRst,
      fcmApuConfirmInstr    => fcmApuConfirmInstr,
      fcmApuCr              => fcmApuCr,
      fcmApuDone            => fcmApuDone,
      fcmApuException       => fcmApuException,
      fcmApuFpsCrFex        => fcmApuFpsCrFex,
      fcmApuResult          => fcmApuResult,
      fcmApuResultValid     => fcmApuResultValid,
      fcmApuSleepNotReady   => fcmApuSleepNotReady,
      fcmApuStoreData       => fcmApuStoreData,
      apuFcmDecFpuOp        => apuFcmDecFpuOp,
      apuFcmDecLdsTxferSize => apuFcmDecLdsTxferSize,
      apuFcmDecLoad         => apuFcmDecLoad,
      apuFcmDecNonAuton     => apuFcmDecNonAuton,
      apuFcmDecStore        => apuFcmDecStore,
      apuFcmDecUdi          => apuFcmDecUdi,
      apuFcmDecUdiValid     => apuFcmDecUdiValid,
      apuFcmEndian          => apuFcmEndian,
      apuFcmFlush           => apuFcmFlush,
      apuFcmInstruction     => apuFcmInstruction,
      apuFcmInstrValid      => apuFcmInstrValid,
      apuFcmLoadByteAddr    => apuFcmLoadByteAddr,
      apuFcmLoadData        => apuFcmLoadData,
      apuFcmLoadDValid      => apuFcmLoadDValid,
      apuFcmMsrFe0          => apuFcmMsrFe0,
      apuFcmMsrFe1          => apuFcmMsrFe1,
      apuFcmNextInstrReady  => apuFcmNextInstrReady,
      apuFcmOperandValid    => apuFcmOperandValid,
      apuFcmRaData          => apuFcmRaData,
      apuFcmRbData          => apuFcmRbData,
      apuFcmWriteBackOk     => apuFcmWriteBackOk,
      apuReadFromPpc        => iapuReadFromPpc,
      apuReadToPpc          => iapuReadToPpc,
      apuWriteFromPpc       => iapuWriteFromPpc,
      apuWriteToPpc         => iapuWriteToPpc,
      apuLoadFromPpc        => iapuLoadFromPpc,
      apuStoreFromPpc       => iapuStoreFromPpc,
      apuStoreToPpc         => iapuStoreToPpc,
      apuReadStatus         => apuReadStatus,
      apuWriteStatus        => apuWriteStatus
   );

   -- Unused APU interfaces
   iapuReadToPpc(4 to 6)    <= (others=>ApuReadToPpcInit);
   iapuWriteToPpc(4 to 6)   <= (others=>ApuWriteToPpcInit);
   iapuStoreToPpc(16 to 31) <= (others=>ApuStoreToPpcInit);

end architecture structure;

