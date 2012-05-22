


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

      -- DCR Master Port
      dcrPpcDmAck                : in  std_logic;
      dcrppcDmDbusIn             : in  std_logic_vector(0 to 31);
      dcrPpcDmTimeoutWait        : in  std_logic;
      ppcDmDcrRead               : out std_logic;
      ppcDmDcrWrite              : out std_logic;
      ppcDmDcrAbus               : out std_logic_vector(0 to 9);
      ppcDmDcrUAbus              : out std_logic_vector(20 to 21);
      ppcDmDcrDbusOut            : out std_logic_vector(0 to 31);

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
   signal intClk312_5MhzAdjRst         : std_logic;
   signal intClk312_5Mhz90DegAdjRst    : std_logic;
   signal intClk156_25MhzAdjRst        : std_logic;
   signal intClk156_25MhzAdjRstPon     : std_logic;
   signal intClk200MhzAdjRst           : std_logic;
   signal intClk312_5MhzRst            : std_logic;
   signal intClk468_75MhzRst           : std_logic;
   signal iicClkO                      : std_logic;
   signal iicClkI                      : std_logic;
   signal iicClkT                      : std_logic; 
   signal iicDataO                     : std_logic;
   signal iicDataI                     : std_logic;
   signal iicDataT                     : std_logic; 
   signal fcmApu                       : FCMAPU_440;
   signal apuFcm                       : APUFCM_440;
   signal extIrq                       : std_logic;
   signal resetReq                     : std_logic;

   constant iicSlaveAddr               : std_logic_vector(6 downto 0) := "1001001"; 

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
         APU_CONTROL           => B"00010000000000000",
         APU_UDI0              => B"000000000000000000000000",
         APU_UDI1              => B"000000000000000000000000",
         APU_UDI2              => B"000000000000000000000000",
         APU_UDI3              => B"000000000000000000000000",
         APU_UDI4              => B"000000000000000000000000",
         APU_UDI5              => B"000000000000000000000000",
         APU_UDI6              => B"000000000000000000000000",
         APU_UDI7              => B"000000000000000000000000",
         APU_UDI8              => B"000000000000000000000000",
         APU_UDI9              => B"000000000000000000000000",
         APU_UDI10             => B"000000000000000000000000",
         APU_UDI11             => B"000000000000000000000000",
         APU_UDI12             => B"000000000000000000000000",
         APU_UDI13             => B"000000000000000000000000",
         APU_UDI14             => B"000000000000000000000000",
         APU_UDI15             => B"000000000000000000000000",
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
         CPMFCMCLK                   => intClk156_25MhzAdj,
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
         FCMAPUCR                    => fcmApu.cr,
         FCMAPUDONE                  => fcmApu.done,
         FCMAPUEXCEPTION             => fcmApu.exc,
         FCMAPUFPSCRFEX              => fcmApu.fpscrexc,
         FCMAPURESULT                => fcmApu.result,
         FCMAPURESULTVALID           => fcmApu.resultvalid,
         FCMAPUSLEEPNOTREADY         => fcmApu.sleepnrdy,
         FCMAPUCONFIRMINSTR          => fcmApu.confirminstr,
         FCMAPUSTOREDATA             => fcmApu.storedata,
         APUFCMDECNONAUTON           => apuFcm.decnonauton,
         APUFCMDECFPUOP              => apuFcm.decfpu,
         APUFCMDECLDSTXFERSIZE       => apuFcm.decldstxfersz,
         APUFCMDECLOAD               => apuFcm.decload,
         APUFCMNEXTINSTRREADY        => apuFcm.nextinstrrdy,
         APUFCMDECSTORE              => apuFcm.decstore,
         APUFCMDECUDI                => apuFcm.decudi,
         APUFCMDECUDIVALID           => apuFcm.decudivalid,
         APUFCMENDIAN                => apuFcm.endian,
         APUFCMFLUSH                 => apuFcm.flush,
         APUFCMINSTRUCTION           => apuFcm.instruction,
         APUFCMINSTRVALID            => apuFcm.instrvalid,
         APUFCMLOADBYTEADDR          => apuFcm.loadbyteaddr,
         APUFCMLOADDATA              => apuFcm.loaddata,
         APUFCMLOADDVALID            => apuFcm.loaddvalid,
         APUFCMOPERANDVALID          => apuFcm.opervalid,
         APUFCMRADATA                => apuFcm.radata,
         APUFCMRBDATA                => apuFcm.rbdata,
         APUFCMWRITEBACKOK           => apuFcm.writebackok,
         APUFCMMSRFE0                => apuFcm.msrfe0,
         APUFCMMSRFE1                => apuFcm.msrfe1,

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
      pllLocked                  => pllLocked,
      cpuClk312_5Mhz             => intClk312_5Mhz,
      cpuClk312_5MhzAdj          => intClk312_5MhzAdj,
      cpuClk312_5Mhz90DegAdj     => intClk312_5Mhz90DegAdj,
      cpuClk156_25MhzAdj         => intClk156_25MhzAdj,
      cpuClk468_75Mhz            => intClk468_75Mhz,
      cpuClk200MhzAdj            => intClk200MhzAdj,
      cpuClk312_5MhzRst          => intClk312_5MhzRst,
      cpuClk312_5MhzAdjRst       => intClk312_5MhzAdjRst,
      cpuClk312_5Mhz90DegAdjRst  => intClk312_5Mhz90DegAdjRst,
      cpuClk156_25MhzAdjRst      => intClk156_25MhzAdjRst,
      cpuClk156_25MhzAdjRstPon   => intClk156_25MhzAdjRstPon,
      cpuClk468_75MhzRst         => intClk468_75MhzRst,
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
      rst_i       => intClk156_25MhzAdjRstPon,
      rst_o       => resetReq,
      interrupt   => extIrq,
      clk32       => intClk156_25MhzAdj,
      fcm_clk     => intClk156_25MhzAdj,
      fcm_apu     => fcmApu,
      apu_fcm     => apuFcm,
      iic_addr    => iicSlaveAddr,
      iic_clki    => iicClkI,
      iic_clko    => iicClkO,
      iic_clkt    => iicClkT,
      iic_datai   => iicDataI,
      iic_datao   => iicDataO,
      iic_datat   => iicDataT,
      debug       => open 
   );

   U_I2cScl : IOBUF port map ( IO => modScl,
                               I  => iicClkO,
                               O  => iicClkI,
                               T  => iicClkT);

   U_I2cSda : IOBUF port map ( IO => modSda,
                               I  => iicDataO,
                               O  => iicDataI,
                               T  => iicDataT);

end architecture structure;







