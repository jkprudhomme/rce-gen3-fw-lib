
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

package Ppc440RceG2Pkg is

  ----------------------------------
  -- Constants
  ----------------------------------

  ----------------------------------
  -- Types
  ----------------------------------
  subtype i2c_reg_type is bit_vector(0 to 31);
  type i2c_reg_vector is array (integer range<>) of i2c_reg_type;

  ----------------------------------
  -- Records
  ----------------------------------

  -- Write command. Signals from PPC.
  type ApuWriteFromPpcType is record
     regA   : std_logic_vector(0 to 31);
     regB   : std_logic_vector(0 to 31);
     enable : std_logic;
  end record;

  type ApuWriteFromPpcVector is array (integer range<>) of ApuWriteFromPpcType;

  constant ApuWriteFromPpcInit : ApuWriteFromPpcType := ( regA   => (others=>'0'), 
                                                          regB   => (others=>'0'), 
                                                          enable => '0');

  -- Write command. Signals to PPC.
  type ApuWriteToPpcType is record
     full   : std_logic;
  end record;

  type ApuWriteToPpcVector is array (integer range<>) of ApuWriteToPpcType;

  constant ApuWriteToPpcInit : ApuWriteToPpcType := ( full   => '0' );

  -- Read command. Signals from PPC.
  type ApuReadFromPpcType is record
     regA   : std_logic_vector(0 to 31);
     regB   : std_logic_vector(0 to 31);
     enable : std_logic;
  end record;

  type ApuReadFromPpcVector is array (integer range<>) of ApuReadFromPpcType;

  constant ApuReadFromPpcInit : ApuReadFromPpcType := ( regA   => (others=>'0'), 
                                                        regB   => (others=>'0'), 
                                                        enable => '0');

  -- Read command. Signals to PPC.
  type ApuReadToPpcType is record
     empty  : std_logic;
     result : std_logic_vector(0 to 31);
     status : std_logic_vector(0 to 3);
     ready  : std_logic;
  end record;

  type ApuReadToPpcVector is array (integer range<>) of ApuReadToPpcType;

  constant ApuReadToPpcInit : ApuReadToPpcType := ( empty  =>'1', 
                                                    result => (others=>'0'), 
                                                    ready => '1',
                                                    status => (others=>'0') );

  -- Load command. Signals from PPC.
  -- Size: 100 = Byte
  --       010 = Halfword
  --       001 = Word
  --       011 = Doubleword
  --       111 = Quadword
  type ApuLoadFromPpcType is record
     size   : std_logic_vector(0 to 2);
     data   : std_logic_vector(0 to 127);
     enable : std_logic;
  end record;

  type ApuLoadFromPpcVector is array (integer range<>) of ApuLoadFromPpcType;

  constant ApuLoadFromPpcInit : ApuLoadFromPpcType := ( size   => (others=>'0'), 
                                                        data   => (others=>'0'), 
                                                        enable => '0' );

  -- Load command. Signals to PPC.
  type ApuLoadToPpcType is record
     full   : std_logic;
  end record;

  type ApuLoadToPpcVector is array (integer range<>) of ApuLoadToPpcType;

  constant ApuLoadToPpcInit : ApuLoadToPpcType := ( full => '0' );


  -- Store command. Signals from PPC.
  -- Size: 100 = Byte
  --       010 = Halfword
  --       001 = Word
  --       011 = Doubleword
  --       111 = Quadword
  type ApuStoreFromPpcType is record
     size   : std_logic_vector(0 to 2);
     enable : std_logic;
  end record;

  type ApuStoreFromPpcVector is array (integer range<>) of ApuStoreFromPpcType;

  constant ApuStoreFromPpcInit : ApuStoreFromPpcType := ( size   => (others=>'0'), 
                                                          enable => '0' );

  -- Store command. Signals to PPC.
  type ApuStoreToPpcType is record
     data   : std_logic_vector(0 to 127);
     empty  : std_logic;
     ready  : std_logic;
  end record;

  type ApuStoreToPpcVector is array (integer range<>) of ApuStoreToPpcType;

  constant ApuStoreToPpcInit : ApuStoreToPpcType := ( data  => (others=>'0'),
                                                      ready => '1',
                                                      empty => '1' );

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
      cpuClk234_375Mhz           : out std_logic;
      cpuClk234_375MhzRst        : out std_logic;
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
      apuReadFromPpc             : out ApuReadFromPpcVector(0 to 3);
      apuReadToPpc               : in  ApuReadToPpcVector(0 to 3);
      apuWriteFromPpc            : out ApuWriteFromPpcVector(0 to 3);
      apuWriteToPpc              : in  ApuWriteToPpcVector(0 to 3);
      apuLoadFromPpc             : out ApuLoadFromPpcVector(0 to 15);
      apuLoadToPpc               : in  ApuLoadToPpcVector(0 to 15);
      apuStoreFromPpc            : out ApuStoreFromPpcVector(0 to 15);
      apuStoreToPpc              : in  ApuStoreToPpcVector(0 to 15);
      apuReset                   : out std_logic_vector(0 to 15);
      modScl                     : inout std_logic;
      modSda                     : inout std_logic;
      sdClk                      : out   std_logic;
      sdCmd                      : inout std_logic;
      sdData                     : inout std_logic_vector(3 downto 0)
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
      cpuClk234_375MhzAdj        : out std_logic;
      cpuClk200MhzAdj            : out std_logic;
      cpuClk312_5MhzRst          : out std_logic;
      cpuClk312_5MhzAdjRst       : out std_logic;
      cpuClk312_5Mhz90DegAdjRst  : out std_logic;
      cpuClk156_25MhzAdjRst      : out std_logic;
      cpuClk156_25MhzAdjRstPon   : out std_logic;
      cpuClk468_75MhzRst         : out std_logic;
      cpuClk234_375MhzAdjRst     : out std_logic;
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
      rst_i           : in  std_logic;
      rst_o           : out std_logic;
      clk32           : in  std_logic;
      apuClk          : in  std_logic;
      apuWriteFromPpc : in  ApuWriteFromPpcType;
      apuWriteToPpc   : out ApuWriteToPpcType;
      apuReadFromPpc  : in  ApuReadFromPpcType;
      apuReadToPpc    : out ApuReadToPpcType;
      iic_addr        : in  std_logic_vector(6 downto 0);
      iic_clki        : in  std_logic;
      iic_clko        : out std_logic;
      iic_clkt        : out std_logic;
      iic_datai       : in  std_logic;
      iic_datao       : out std_logic;
      iic_datat       : out std_logic;
      debug           : out std_logic_vector(15 downto 0)
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
      apuReadFromPpc             : out ApuReadFromPpcVector(0 to 7);
      apuReadToPpc               : in  ApuReadToPpcVector(0 to 7);
      apuWriteFromPpc            : out ApuWriteFromPpcVector(0 to 7);
      apuWriteToPpc              : in  ApuWriteToPpcVector(0 to 7);
      apuLoadFromPpc             : out ApuLoadFromPpcVector(0 to 31);
      apuLoadToPpc               : in  ApuLoadToPpcVector(0 to 31);
      apuStoreFromPpc            : out ApuStoreFromPpcVector(0 to 31);
      apuStoreToPpc              : in  ApuStoreToPpcVector(0 to 31);
      apuWriteFull               : out std_logic_vector(0 to 7);
      apuReadEmpty               : out std_logic_vector(0 to 7);
      apuLoadFull                : out std_logic_vector(0 to 31);
      apuStoreEmpty              : out std_logic_vector(0 to 31)
    );
  end component;

  component Ppc440RceG2Control is
    port (
      apuClk                     : in  std_logic;
      apuClkRst                  : in  std_logic;
      apuReadFromPpc             : in  ApuReadFromPpcType;
      apuReadToPpc               : out ApuReadToPpcType;
      apuWriteFromPpc            : in  ApuWriteFromPpcType;
      apuWriteToPpc              : out ApuWriteToPpcType;
      apuReset                   : out std_logic_vector(0 to 31);
      extInt                     : out std_logic;
      critInt                    : out std_logic;
      apuWriteFull               : in  std_logic_vector(0 to 7);
      apuReadEmpty               : in  std_logic_vector(0 to 7);
      apuLoadFull                : in  std_logic_vector(0 to 31);
      apuStoreEmpty              : in  std_logic_vector(0 to 31)
    );
  end component;

   component Ppc440RceG2uSd is
      port ( 
         cpuClk200MhzRst  : in  std_logic;
         cpuClk200Mhz     : in  std_logic;
         apuClk           : in  std_logic;
         apuClkRst        : in  std_logic;
         apuWriteFromPpc  : in  ApuWriteFromPpcType;
         apuWriteToPpc    : out ApuWriteToPpcType;
         apuReadFromPpc   : in  ApuReadFromPpcType;
         apuReadToPpc     : out ApuReadToPpcType;
         apuLoadFromPpc   : in  ApuLoadFromPpcType;
         apuLoadToPpc     : out ApuLoadToPpcType;
         apuStoreFromPpc  : in  ApuStoreFromPpcType;
         apuStoreToPpc    : out ApuStoreToPpcType;
         apuReset         : in    std_logic;
         sdClk            : out   std_logic;
         sdCmd            : inout std_logic;
         sdData           : inout std_logic_vector(3 downto 0)
      );
   end component;

end Ppc440RceG2Pkg;

