
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

package Ppc440RceG2Pkg is

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
      modScl                     : inout std_logic;
      modSda                     : inout std_logic
    );
  end component;

  component Ppc440RceG2Boot is
    port (
      bramClk                   : in  std_logic;
      bramClkRst                : in  std_logic;
      resetReq                  : out std_logic;
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

  type APUFCM_440 is record
    decudi        : std_logic_vector(0 to 3);
    decudivalid   : std_logic;
    decfpu        : std_logic;            -- FPU op decoded
    decldstxfersz : std_logic_vector(0 to 2);  -- decoded load/store xfersz
    decload       : std_logic;          -- decoded load
    decnonauton   : std_logic;          -- decoded nonautonomous instr
    decstore      : std_logic;          -- decoded store instr
    instrvalid    : std_logic;
    instruction   : std_logic_vector(0 to 31);
    nextinstrrdy  : std_logic;
    radata        : std_logic_vector(0 to 31);
    rbdata        : std_logic_vector(0 to 31);
    opervalid     : std_logic;    -- operand valid
    endian        : std_logic;    -- little endian
    writebackok   : std_logic;     -- commit
    flush         : std_logic;     -- no commit
    loaddvalid    : std_logic;
    loaddata      : std_logic_vector(0 to 127);
    loadbyteaddr  : std_logic_vector(0 to 3);
    msrfe0        : std_logic;           -- MSR(FE0)
    msrfe1        : std_logic;           -- MSR(FE1)
  end record;

  type FCMAPU_440 is record
    confirminstr  : std_logic;          -- no exception (nonauton instr w/late
    result        : std_logic_vector(0 to 31);   -- result data
    storedata     : std_logic_vector(0 to 127);  -- store data
    done          : std_logic;    -- instr execution done
    sleepnrdy     : std_logic;    -- CPU cannot sleep
    resultvalid   : std_logic;
    cr            : std_logic_vector(0 to 3);  -- cond reg bits
    exc           : std_logic;    -- generate program exception
    fpscrexc      : std_logic;    -- generate FPSCR(FEX) exception
  end record;

  type APU_UDI_CFG_Type is array (0 to 7) of std_logic_vector(0 to 23);

  subtype reg_type is bit_vector(0 to 31);
  type reg_vector is array (integer range<>) of reg_type;

  component Ppc440RceG2I2c is
    generic ( REG_INIT     : reg_vector(4 to 511) := (others=>x"00000000") );
    port (
      rst_i       : in  std_logic;
      rst_o       : out std_logic;
      interrupt   : out std_logic;
      clk32       : in  std_logic;
      fcm_clk     : in  std_logic;
      apu_fcm     : in  APUFCM_440;
      fcm_apu     : out FCMAPU_440;
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

end Ppc440RceG2Pkg;

