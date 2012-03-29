


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


entity Ppc440RceG2 is
   port (

      -- Clock inputs
      cpuClk156_25Mhz           : in  std_logic;
      cpuClk312_50Mhz           : in  std_logic;
      cpuClk468_75Mhz           : in  std_logic;

      -- Resets
      cpuRstCore                : in  std_logic;
      cpuRstChip                : in  std_logic;
      cpuRstSystem              : in  std_logic;
      cpuRstCoreReq             : out std_logic;
      cpuRstChipReq             : out std_logic;
      cpuRstSystemReq           : out std_logic;

      -- Memory Controller
      mcmiReadData              : in  std_logic_vector(0 to 127);
      mcmiReadDataValid         : in  std_logic;
      mcmiReadDataErr           : in  std_logic;
      mcmiAddrReadyToAccept     : in  std_logic;
      mcmiReadNotWrite          : out std_logic;
      mcmiAddress               : out std_logic_vector(0 to 35);
      mcmiAddressValid          : out std_logic;
      mcmiWriteData             : out std_logic_vector(0 to 127);
      mcmiWriteDataValid        : out std_logic;
      mcmiByteEnable            : out std_logic_vector(0 to 15);
      mcmiBankConflict          : out std_logic;
      mcmiRowConflict           : out std_logic

   );
end Ppc440RceG2;

architecture structure of Ppc440RceG2 is

   -- Boot ram
   component Ppc440Boot is
      port (
         cpuClk156_25Mhz           : in  std_logic;
         cpuRstChip                : in  std_logic;
         plbPpcmMBusy              : out std_logic;
         plbPpcmAddrAck            : out std_logic;
         plbPpcmRdDack             : out std_logic;
         plbPpcmRdDbus             : out std_logic(0 to 127);
         plbPpcmRdWdAddr           : out std_logic(0 to 3);
         plbPpcmTimeout            : out std_logic;
         plbPpcmWrDack             : out std_logic;
         ppcMplbAbus               : in  std_logic(0 to 31);
         ppcMplbBe                 : in  std_logic;
         ppcMplbRequest            : in  std_logic;
         ppcMplbRnW                : in  std_logic;
         ppcMplbSize               : in  std_logic(0 to 1);
         ppcMplbWrDBus             : in  std_logic(0 to 127)
      );
   end component;

   -- Local signals
   signal jtgC440Tck        : std_logic;
   signal jtgC440Tdi        : std_logic;
   signal jtgC440Tms        : std_logic;
   signal c440JtgTdo        : std_logic;
   signal plbPpcmMBusy      : std_logic;
   signal plbPpcmAddrAck    : std_logic;
   signal plbPpcmRdDack     : std_logic;
   signal plbPpcmRdDbus     : std_logic(0 to 127);
   signal plbPpcmRdWdAddr   : std_logic(0 to 3);
   signal plbPpcmTimeout    : std_logic;
   signal plbPpcmWrDack     : std_logic;
   signal ppcMplbAbus       : std_logic(0 to 31);
   signal ppcMplbBe         : std_logic;
   signal ppcMplbRequest    : std_logic;
   signal ppcMplbRnW        : std_logic;
   signal ppcMplbSize       : std_logic(0 to 1);
   signal ppcMplbWrDBus     : std_logic(0 to 127);

begin

   ----------------------------------------------------------------------------
   -- Instantiate PPC440 Processor Block Primitive
   ----------------------------------------------------------------------------
   U_PPC440 : PPC440
      generic map (
         INTERCONNECT_IMASK    => x"FFFFFFFF",
         XBAR_ADDRMAP_TMPL0    => x"0000FFFF",
         XBAR_ADDRMAP_TMPL1    => (others=>'0'),
         XBAR_ADDRMAP_TMPL2    => (others=>'0'),
         XBAR_ADDRMAP_TMPL3    => (others=>'0'),
         INTERCONNECT_TMPL_SEL => x"3FFFFFFF",
         CLOCK_DELAY           => TRUE,
         APU_CONTROL           => B"00010000000000000",
         APU_UDI_0             => B"000000000000000000000000",
         APU_UDI_1             => B"000000000000000000000000",
         APU_UDI_2             => B"000000000000000000000000",
         APU_UDI_3             => B"000000000000000000000000",
         APU_UDI_4             => B"000000000000000000000000",
         APU_UDI_5             => B"000000000000000000000000",
         APU_UDI_6             => B"000000000000000000000000",
         APU_UDI_7             => B"000000000000000000000000",
         APU_UDI_8             => B"000000000000000000000000",
         APU_UDI_9             => B"000000000000000000000000",
         APU_UDI_10            => B"000000000000000000000000",
         APU_UDI_11            => B"000000000000000000000000",
         APU_UDI_12            => B"000000000000000000000000",
         APU_UDI_13            => B"000000000000000000000000",
         APU_UDI_14            => B"000000000000000000000000",
         APU_UDI_15            => B"000000000000000000000000",
         MI_ROWCONFLICT_MASK   => X"00FFFE00",
         MI_BANKCONFLICT_MASK  => X"07000000",
         MI_ARBCONFIG          => X"00432010",
         MI_CONTROL            => X"F820008F" & "11",
         PPCM_CONTROL          => X"8000009F";
         PPCM_COUNTER          => X"00000500",
         PPCM_ARBCONFIG        => X"00432010",
         PPCS0_CONTROL         => x"8033336C",
         PPCS0_WIDTH_128N64    => TRUE ,
         PPCS0_ADDRMAP_TMPL0   => (others=>'0'),
         PPCS0_ADDRMAP_TMPL1   => (others=>'0'),
         PPCS0_ADDRMAP_TMPL2   => (others=>'0'),
         PPCS0_ADDRMAP_TMPL3   => (others=>'0'),
         PPCS1_CONTROL         => x"8033336C",
         PPCS1_WIDTH_128N64    => TRUE ,
         PPCS1_ADDRMAP_TMPL0   => (others=>'0'),
         PPCS1_ADDRMAP_TMPL1   => (others=>'0'),
         PPCS1_ADDRMAP_TMPL2   => (others=>'0'),
         PPCS1_ADDRMAP_TMPL3   => (others=>'0'),
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
         DCR_AUTOLOCK_ENABLE   => 1,
         PPCDM_ASYNCMODE       => 0,
         PPCDS_ASYNCMODE       => 0
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
         PLBPPCMRDPENDREQ            => open,
         PLBPPCMREQPRI               => "00",
         PLBPPCMWRPENDPRI            => "00",
         PLBPPCMWRPENDREQ            => open,
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
         PPCMPLBWRDBUS               => ppcMplbWrDBus

         -- SPLB 0
         PLBPPCS0MASTERID            => "0",
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
         PLBPPCS0SIZE                => "00",
         PLBPPCS0TYPE                => "000",
         PLBPPCS0TATTRIBUTE          => x"0000",
         PLBPPCS0LOCKERR             => '0',
         PLBPPCS0MSIZE               => "00",
         PLBPPCS0UABUS               => x"00000000",
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
         PLBPPCS1MASTERID            => "0",
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
         PLBPPCS1SIZE                => "00",
         PLBPPCS1TYPE                => "000",
         PLBPPCS1TATTRIBUTE          => x"0000",
         PLBPPCS1LOCKERR             => '0',
         PLBPPCS1MSIZE               => "00",
         PLBPPCS1UABUS               => x"00000000",
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
         CPMINTERCONNECTCLK          => cpuClk312_5Mhz,
         CPMINTERCONNECTCLKEN        => '1',
         CPMINTERCONNECTCLKNTO1      => '0',
         PPCCPMINTERCONNECTBUSY      => open,
         CPMC440CLK                  => cpuClk468_75Mhz,
         CPMDCRCLK                   => '1',
         CPMFCMCLK                   => '1',
         CPMMCCLK                    => cpuClk312_5Mhz,
         CPMPPCS1PLBCLK              => '1',
         CPMPPCS0PLBCLK              => '1',
         CPMPPCMPLBCLK               => cpuClk156_25Mhz,
         CPMDMA0LLCLK                => '1',
         CPMDMA1LLCLK                => '1',
         CPMDMA2LLCLK                => '1',
         CPMDMA3LLCLK                => '1',
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
         DCRPPCDMACK                 => '0',
         DCRPPCDMDBUSIN              => x"00000000",
         DCRPPCDMTIMEOUTWAIT         => '0',
         TIEDCRBASEADDR              => B"0000000000",
         PPCDMDCRREAD                => open,
         PPCDMDCRWRITE               => open,
         PPCDMDCRABUS                => open,
         PPCDMDCRUABUS               => open,
         PPCDMDCRDBUSOUT             => open,

         -- Interupt Controller
         EICC440CRITIRQ              => '0',
         EICC440EXTIRQ               => '0',
         PPCEICINTERCONNECTIRQ       => open,

         -- JTAG Interface
         JTGC440TCK                  => JTGC440TCK,
         JTGC440TDI                  => JTGC440TDI,
         JTGC440TMS                  => JTGC440TMS,
         JTGC440TRSTNEG              => '1',
         C440JTGTDO                  => C440JTGTDO,
         C440JTGTDOEN                => '0',

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
         FCMAPUCR                    => "0000",
         FCMAPUDONE                  => '0',
         FCMAPUEXCEPTION             => '0',
         FCMAPUFPSCRFEX              => '0',
         FCMAPURESULT                => x"00000000",
         FCMAPURESULTVALID           => '0',
         FCMAPUSLEEPNOTREADY         => '0',
         FCMAPUCONFIRMINSTR          => '0',
         FCMAPUSTOREDATA             => x"00000000000000000000000000000000",
         APUFCMDECNONAUTON           => open,
         APUFCMDECFPUOP              => open,
         APUFCMDECLDSTXFERSIZE       => open,
         APUFCMDECLOAD               => open,
         APUFCMNEXTINSTRREADY        => open,
         APUFCMDECSTORE              => open,
         APUFCMDECUDI                => open,
         APUFCMDECUDIVALID           => open,
         APUFCMENDIAN                => open,
         APUFCMFLUSH                 => open,
         APUFCMINSTRUCTION           => open,
         APUFCMINSTRVALID            => open,
         APUFCMLOADBYTEADDR          => open,
         APUFCMLOADDATA              => open,
         APUFCMLOADDVALID            => open,
         APUFCMOPERANDVALID          => open,
         APUFCMRADATA                => open,
         APUFCMRBDATA                => open,
         APUFCMWRITEBACKOK           => open,
         APUFCMMSRFE0                => open,
         APUFCMMSRFE1                => open,

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
          
         -- DMA Controller 3 
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
         DMA3RXIRQ                   => open,
      );


   -- JTAG Controller
   U_JTAGPPC440 : JTAGPPC440 
      port map (
         TCK      => jtgC440Tck,
         TDIPPC   => jtgC440Tdi,
         TMS      => jtgC440Tms,
         TDOPPC   => c440JtgTdo 
      );

   -- Boot Ram
   U_Ppc440Boot : Ppc440Boot 
      port map (
         bramClk           => cpuClk156_25Mhz,
         bramClkRst        => cpuRstChip,
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

end Ppc440RceG2;

