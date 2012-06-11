
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

package Ppc440RceG2Pkg is

  ----------------------------------
  -- Constants
  ----------------------------------
  constant ApuCount    : integer := 1;
  constant ApuSubCount : integer := 4;

  ----------------------------------
  -- Types
  ----------------------------------
  subtype i2c_reg_type is bit_vector(0 to 31);
  type i2c_reg_vector is array (integer range<>) of i2c_reg_type;

  ----------------------------------
  -- Records
  ----------------------------------
  type ApuFromPpcType is record
    writeData    : std_logic_vector(0 to 127);
    writeEn      : std_logic_vector(0 to ApuSubCount-1);
    readEn       : std_logic_vector(0 to ApuSubCount-1);
  end record;
  type ApuFromPpcVector is array (integer range<>) of ApuFromPpcType;

  type ApuToPpcType is record
    readData     : std_logic_vector(0 to 127);
    empty        : std_logic_vector(0 to ApuSubCount-1);
    almostEmpty  : std_logic_vector(0 to ApuSubCount-1);
    full         : std_logic_vector(0 to ApuSubCount-1);
    almostFull   : std_logic_vector(0 to ApuSubCount-1);
  end record;
  type ApuToPpcVector is array (integer range<>) of ApuToPpcType;

  ----------------------------------
  -- Components
  ----------------------------------

  component Ppc440RceG2 is
    port (
      refClk125Mhz               : in  std_logic;
      powerOnReset               : in  std_logic;
      pllLocked                  : out std_logic;
      cpuClk312_5Mhz             : out std_logic;
      cpuClk312_5MhzRst          : out std_logic;
      cpuClk312_5Mhz90Deg        : out std_logic;
      cpuClk312_5Mhz90DegRst     : out std_logic;
      cpuClk156_25Mhz            : out std_logic;
      cpuClk156_25MhzRst         : out std_logic;
      cpuClk200Mhz               : out std_logic;
      cpuClk200MhzRst            : out std_logic;
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
      dcrPpcDmAck                : in  std_logic;
      dcrppcDmDbusIn             : in  std_logic_vector(0 to 31);
      dcrPpcDmTimeoutWait        : in  std_logic;
      ppcDmDcrRead               : out std_logic;
      ppcDmDcrWrite              : out std_logic;
      ppcDmDcrAbus               : out std_logic_vector(0 to 9);
      ppcDmDcrUAbus              : out std_logic_vector(20 to 21);
      ppcDmDcrDbusOut            : out std_logic_vector(0 to 31);
      modScl                     : inout std_logic;
      modSda                     : inout std_logic
    );
  end component;

  component Ppc440RceG2Boot is
    port (
      bramClk                   : in  std_logic;
      bramClkRst                : in  std_logic;
      plbPpcmMBusy              : out std_logic;
      plbPpcmAddrAck            : out std_logic;
      plbPpcmRdDack             : out std_logic;
      plbPpcmRdDbus             : out std_logic_vector(0 to 127);
      plbPpcmRdWdAddr           : out std_logic_vector(0 to 3);
      plbPpcmTimeout            : out std_logic;
      plbPpcmWrDack             : out std_logic;
      ppcMplbAbus               : in  std_logic_vector(0 to 31);
      ppcMplbBe                 : in  std_logic_vector(0 to 15);
      ppcMplbRequest            : in  std_logic;
      ppcMplbRnW                : in  std_logic;
      ppcMplbSize               : in  std_logic_vector(0 to 3);
      ppcMplbWrDBus             : in  std_logic_vector(0 to 127)
    );
  end component;

  component Ppc440RceG2Bram is
    port (
      bramRstA : in std_logic;
      bramClkA : in std_logic;
      bramEnA : in std_logic;
      bramWenA : in std_logic_vector(0 to 7);
      bramAddrA : in std_logic_vector(0 to 31);
      bramDinA : out std_logic_vector(0 to 63);
      bramDoutA : in std_logic_vector(0 to 63);
      bramRstB : in std_logic;
      bramClkB : in std_logic;
      bramEnB : in std_logic;
      bramWenB : in std_logic_vector(0 to 7);
      bramAddrB : in std_logic_vector(0 to 31);
      bramDinB : out std_logic_vector(0 to 63);
      bramDoutB : in std_logic_vector(0 to 63)
    );
  end component;

  component Ppc440RceG2Clk is
    port (
      refClk125Mhz               : in  std_logic;
      powerOnReset               : in  std_logic;
      masterReset                : in  std_logic;
      pllLocked                  : out std_logic;
      memReady                   : in  std_logic;
      cpuClk312_5Mhz             : out std_logic; 
      cpuClk312_5MhzAdj          : out std_logic;
      cpuClk312_5Mhz90DegAdj     : out std_logic;
      cpuClk156_25MhzAdj         : out std_logic;
      cpuClk468_75Mhz            : out std_logic;
      cpuClk200MhzAdj            : out std_logic;
      cpuClk312_5MhzRst          : out std_logic;
      cpuClk312_5MhzAdjRst       : out std_logic;
      cpuClk312_5Mhz90DegAdjRst  : out std_logic;
      cpuClk156_25MhzAdjRst      : out std_logic;
      cpuClk156_25MhzAdjRstPon   : out std_logic;
      cpuClk468_75MhzRst         : out std_logic;
      cpuClk200MhzAdjRst         : out std_logic;
      cpuRstCore                 : out std_logic;
      cpuRstChip                 : out std_logic;
      cpuRstSystem               : out std_logic;
      cpuRstCoreReq              : in  std_logic;
      cpuRstChipReq              : in  std_logic;
      cpuRstSystemReq            : in  std_logic
    );
  end component;

  component Ppc440RceG2Rst is
    port (
      syncClk                    : in std_logic;
      asyncReset                 : in std_logic;
      pllLocked                  : in std_logic;
      syncReset                  : out std_logic
    );
  end component;

  component Ppc440RceG2I2c is
    generic ( REG_INIT     : i2c_reg_vector(4 to 511) := (others=>x"00000000") );
    port (
      rst_i       : in  std_logic;
      rst_o       : out std_logic;
      interrupt   : out std_logic;
      clk32       : in  std_logic;
      fcm_clk     : in  std_logic;
      apuFromPpc  : in  ApuFromPpcType;
      apuToPpc    : out ApuToPpcType;
      iic_addr    : in  std_logic_vector(6 downto 0);
      iic_clki    : in  std_logic;
      iic_clko    : out std_logic;
      iic_clkt    : out std_logic;
      iic_datai   : in  std_logic;
      iic_datao   : out std_logic;
      iic_datat   : out std_logic;
      debug       : out std_logic_vector(15 downto 0)
    );
  end component;

  component Ppc440RceG2Apu is
    port (
      apuClk                     : in  std_logic;
      apuClkRst                  : in  std_logic;
      fcmApuConfirmInstr         : out std_logic;
      fcmApuCr                   : out std_logic_vector(0 to 3);
      fcmApuDone                 : out std_logic;
      fcmApuException            : out std_logic;
      fcmApuFpsCrFex             : out std_logic;
      fcmApuResult               : out std_logic_vector(0 to 31);
      fcmApuResultValid          : out std_logic;
      fcmApuSleepNotReady        : out std_logic;
      fcmApuStoreData            : out std_logic_vector(0 to 127);
      apuFcmDecFpuOp             : in  std_logic;
      apuFcmDecLdsTxferSize      : in  std_logic_vector(0 to 2);
      apuFcmDecLoad              : in  std_logic;
      apuFcmDecNonAuton          : in  std_logic;
      apuFcmDecStore             : in  std_logic;
      apuFcmDecUdi               : in  std_logic_vector(0 to 3);
      apuFcmDecUdiValid          : in  std_logic;
      apuFcmEndian               : in  std_logic;
      apuFcmFlush                : in  std_logic;
      apuFcmInstruction          : in  std_logic_vector(0 to 31);
      apuFcmInstrValid           : in  std_logic;
      apuFcmLoadByteAddr         : in  std_logic_vector(0 to 3);
      apuFcmLoadData             : in  std_logic_vector(0 to 127);
      apuFcmLoadDValid           : in  std_logic;
      apuFcmMsrFe0               : in  std_logic;
      apuFcmMsrFe1               : in  std_logic;
      apuFcmNextInstrReady       : in  std_logic;
      apuFcmOperandValid         : in  std_logic;
      apuFcmRaData               : in  std_logic_vector(0 to 31);
      apuFcmRbData               : in  std_logic_vector(0 to 31);
      apuFcmWriteBackOk          : in  std_logic;
      apuFromPpc                 : out ApuFromPpcVector(0 to ApuCount-1);
      apuToPpc                   : in  ApuToPpcVector(0 to ApuCount-1)
    );
  end component;

end Ppc440RceG2Pkg;

