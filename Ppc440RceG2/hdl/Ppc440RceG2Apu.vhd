

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.Ppc440RceG2Pkg.all;

entity Ppc440RceG2Apu is
  port (

    -- Clock & Reset Inputs
    apuClk                     : in  std_logic;
    apuClkRst                  : in  std_logic;

    -- PPC440 APU Interface
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

    -- APU Components
    apuFromPpc                 : out ApuFromPpcVector(0 to ApuCount-1);
    apuToPpc                   : in  ApuToPpcVector(0 to ApuCount-1)
  );
end Ppc440RceG2Apu;

architecture structure of Ppc440RceG2Apu is

  -- Local signals
  signal dec_read        : std_logic;
  signal dec_write       : std_logic;
  signal read_done       : std_logic;
  signal write_done      : std_logic;
  signal read_done_next  : std_logic;
  signal write_done_next : std_logic;

  -- Register delay for simulation
  constant tpd:time := 0.5 ns;

begin

  -- Out to I2c controller
  apuFromPpc(0).writeData  <= x"0000000000000000" & apuFcmRaData & apuFcmRbData;
  apuFromPpc(0).writeEn(0) <= dec_write;
  apuFromPpc(0).readEn(0)  <= read_done;

  -- Command decode
  dec_read <= '1' when (apuFcmDecUdiValid  = '1' and (apuFcmDecUdi = "0000" or apuFcmDecUdi = "0010") and
                        apuFcmOperandValid = '1' and read_done = '0') else '0';

  read_done_next  <= '1' when (dec_read='1' and apuFcmFlush = '0') else '0';
  
  dec_write <= '1' when (apuFcmDecUdiValid = '1' and apuFcmDecUdi = "0001" and 
                         apuFcmOperandValid = '1' and write_done = '0') else '0';

  write_done_next <= '1' when (dec_write='1' and apuFcmFlush = '0') else '0';
 
  -- States 
  fcm_p : process ( apuClkRst, apuClk )
  begin
    if apuClkRst='1' then
      read_done  <= '0';
      write_done <= '0';
    elsif rising_edge(apuClk) then
      read_done  <= read_done_next;
      write_done <= write_done_next;
    end if;
  end process fcm_p;

  -- APU return
  fcmApuConfirmInstr         <= '0';
  fcmApuCr                   <= ApuFcmRaData(28 to 31);
  fcmApuDone                 <= read_done or write_done;
  fcmApuException            <= '0';
  fcmApuFpsCrFex             <= '0';
  fcmApuResult               <= apuToPpc(0).readData(96 to 127);
  fcmApuResultValid          <= read_done;
  fcmApuSleepNotReady        <= '0';
  fcmApuStoreData            <= (others=>'0');

end architecture;

