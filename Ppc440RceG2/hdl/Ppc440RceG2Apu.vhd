-- UDI Command Mapping:
-- read  port 0 = APU_udi0fcm
-- write port 0 = APU_udi1fcm
-- read  port 1 = APU_udi2fcm
-- write port 1 = APU_udi3fcm
-- read  port 2 = APU_udi4fcm
-- write port 2 = APU_udi5fcm
-- read  port 3 = APU_udi6fcm
-- write port 3 = APU_udi7fcm
-- read  port 4 = APU_udi8fcm
-- write port 4 = APU_udi9fcm
-- read  port 5 = APU_udi10fcm
-- write port 5 = APU_udi11fcm
-- read  port 6 = APU_udi12fcm
-- write port 6 = APU_udi13fcm
-- read  port 7 = APU_udi14fcm
-- write port 7 = APU_udi15fcm

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

    -- Read  instructions
    apuReadFromPpc             : out ApuReadFromPpcVector(0 to 7);
    apuReadToPpc               : in  ApuReadToPpcVector(0 to 7);

    -- Write instructions
    apuWriteFromPpc            : out ApuWriteFromPpcVector(0 to 7);
    apuWriteToPpc              : in  ApuWriteToPpcVector(0 to 7);

    -- Load instructions
    apuLoadFromPpc             : out ApuLoadFromPpcVector(0 to 31);
    apuLoadToPpc               : in  ApuLoadToPpcVector(0 to 31);

    -- Store instructions
    apuStoreFromPpc            : out ApuStoreFromPpcVector(0 to 31);
    apuStoreToPpc              : in  ApuStoreToPpcVector(0 to 31);

    -- Full/Empty Bits
    apuWriteFull               : out std_logic_vector(0 to 7);
    apuReadEmpty               : out std_logic_vector(0 to 7);
    apuLoadFull                : out std_logic_vector(0 to 31);
    apuStoreEmpty              : out std_logic_vector(0 to 31)
  );
end Ppc440RceG2Apu;

architecture structure of Ppc440RceG2Apu is

  -- Local signals
  signal dec_read             : std_logic_vector(7  downto 0);
  signal dec_write            : std_logic_vector(7  downto 0);
  signal read_done            : std_logic_vector(7  downto 0);
  signal write_done           : std_logic_vector(7  downto 0);
  signal read_done_next       : std_logic_vector(7  downto 0);
  signal write_done_next      : std_logic_vector(7  downto 0);
  signal dec_load             : std_logic_vector(31 downto 0);
  signal dec_store            : std_logic_vector(31 downto 0);
  signal load_done            : std_logic_vector(31 downto 0);
  signal store_done           : std_logic_vector(31 downto 0);
  signal load_done_next       : std_logic_vector(31 downto 0);
  signal store_done_next      : std_logic_vector(31 downto 0);
  signal iapuReadFromPpc      : ApuReadFromPpcVector(0 to 7);
  signal iapuWriteFromPpc     : ApuWriteFromPpcVector(0 to 7);
  signal iapuLoadFromPpc      : ApuLoadFromPpcVector(0 to 31);
  signal iapuStoreFromPpc     : ApuStoreFromPpcVector(0 to 31);
  signal ifcmApuConfirmInstr  : std_logic;
  signal ifcmApuCr            : std_logic_vector(0 to 3);
  signal ifcmApuDone          : std_logic;
  signal ifcmApuException     : std_logic;
  signal ifcmApuFpsCrFex      : std_logic;
  signal ifcmApuResult        : std_logic_vector(0 to 31);
  signal ifcmApuResultValid   : std_logic;
  signal ifcmApuSleepNotReady : std_logic;
  signal ifcmApuStoreData     : std_logic_vector(0 to 127);
  signal apuWriteFullIn       : std_logic_vector(0 to 7);
  signal apuReadEmptyIn       : std_logic_vector(0 to 7);
  signal apuLoadFullIn        : std_logic_vector(0 to 31);
  signal apuStoreEmptyIn      : std_logic_vector(0 to 31);

  -- Register delay for simulation
  constant tpd:time := 0.5 ns;

begin

  -- Outputs
  apuReadFromPpc      <= iapuReadFromPpc;
  apuWriteFromPpc     <= iapuWriteFromPpc;
  apuLoadFromPpc      <= iapuLoadFromPpc;
  apuStoreFromPpc     <= iapuStoreFromPpc;
  fcmApuConfirmInstr  <= ifcmApuConfirmInstr;
  fcmApuCr            <= ifcmApuCr;
  fcmApuDone          <= ifcmApuDone;
  fcmApuException     <= ifcmApuException;
  fcmApuFpsCrFex      <= ifcmApuFpsCrFex;
  fcmApuResult        <= ifcmApuResult;
  fcmApuResultValid   <= ifcmApuResultValid;
  fcmApuSleepNotReady <= ifcmApuSleepNotReady;
  fcmApuStoreData     <= ifcmApuStoreData;

  -- Pass along status
  process ( apuClkRst, apuClk )
  begin
    if apuClkRst='1' then
       apuWriteFull  <= (others=>'0') after tpd;
       apuReadEmpty  <= (others=>'0') after tpd;
       apuLoadFull   <= (others=>'0') after tpd;
       apuStoreEmpty <= (others=>'0') after tpd;
    elsif rising_edge(apuClk) then
       apuWriteFull  <= apuWriteFullIn  after tpd;
       apuReadEmpty  <= apuReadEmptyIn  after tpd;
       apuLoadFull   <= apuLoadFullIn   after tpd;
       apuStoreEmpty <= apuStoreEmptyIn after tpd;
    end if;
  end process;

  -- UDI Instructions
  GenInst : for i in 0 to 7 generate

    -- Read Decode
    dec_read(i) <= '1' when apuFcmDecUdiValid    = '1' and 
                            apuFcmDecUdi(3)      = '0' and 
                            apuFcmDecUdi(0 to 2) = i   and
                            apuFcmOperandValid   = '1' and 
                            read_done(i) = '0' else '0';

    -- Read Done
    read_done_next(i) <= '1' when dec_read(i) = '1' and apuFcmFlush = '0' else '0';

    -- Read Signals
    iapuReadFromPpc(i).enable <= read_done(i);
    iapuReadFromPpc(i).regA   <= apuFcmRaData;
    iapuReadFromPpc(i).regB   <= apuFcmRbData;

    -- Write Decode
    dec_write(i) <= '1' when apuFcmDecUdiValid    = '1' and 
                             apuFcmDecUdi(3)      = '1' and 
                             apuFcmDecUdi(0 to 2) = i   and
                             apuFcmOperandValid   = '1' and 
                             write_done(i) = '0' else '0';

    -- Write Done
    write_done_next(i) <= '1' when (dec_write(i) = '1' and apuFcmFlush = '0') else '0';

    -- Write Signals
    iapuWriteFromPpc(i).enable <= dec_write(i);
    iapuWriteFromPpc(i).regA   <= apuFcmRaData;
    iapuWriteFromPpc(i).regB   <= apuFcmRbData;

    -- Full/Empty Status
    apuWriteFullIn(i) <= apuWriteToPpc(i).full;
    apuReadEmptyIn(i) <= apuReadToPpc(i).empty;

  end generate;

  -- Cycle completion
  ifcmApuDone        <= '0' when read_done = 0 and write_done = 0 and load_done = 0 and store_done = 0 else '1';
  ifcmApuResultValid <= '0' when read_done = 0 and store_done = 0 else '1';

  -- Status & Result Mux
  ifcmApuResult <= apuReadToPpc(conv_integer(apuFcmDecUdi(0 to 2))).result when read_done /= 0 else (others=>'0');
  ifcmApuCr     <= apuReadToPpc(conv_integer(apuFcmDecUdi(0 to 2))).status when read_done /= 0 else (others=>'0');

  -- Read/Write States 
  fcm_p : process ( apuClkRst, apuClk )
  begin
    if apuClkRst='1' then
      read_done      <= (others=>'0') after tpd;
      write_done     <= (others=>'0') after tpd;
    elsif rising_edge(apuClk) then
      read_done      <= read_done_next   after tpd;
      write_done     <= write_done_next  after tpd;
    end if;
  end process fcm_p;

  -- Load/Store
  GenLs : for i in 0 to 31 generate

    -- Load Decode
    dec_load(i) <= '1' when apuFcmInstrValid           = '1' and 
                            apuFcmInstruction(6 to 10) = i   and 
                            apuFcmDecLoad              = '1' and
                            apuFcmLoadDValid           = '1' and
                            load_done(i) = '0' else '0';

    -- Load Done
    load_done_next(i) <= '1' when dec_load(i) = '1' and apuFcmFlush = '0' else '0';

    -- Load data
    iapuLoadFromPpc(i).enable <= dec_load(i);
    iapuLoadFromPpc(i).data   <= apuFcmLoadData                                               when apuFcmLoadByteAddr  = "0000" else
                                 apuFcmLoadData(8   to 127) & x"00"                           when apuFcmLoadByteAddr  = "0001" else
                                 apuFcmLoadData(16  to 127) & x"0000"                         when apuFcmLoadByteAddr  = "0010" else
                                 apuFcmLoadData(24  to 127) & x"000000"                       when apuFcmLoadByteAddr  = "0011" else
                                 apuFcmLoadData(32  to 127) & x"00000000"                     when apuFcmLoadByteAddr  = "0100" else
                                 apuFcmLoadData(40  to 127) & x"0000000000"                   when apuFcmLoadByteAddr  = "0101" else
                                 apuFcmLoadData(48  to 127) & x"000000000000"                 when apuFcmLoadByteAddr  = "0110" else
                                 apuFcmLoadData(56  to 127) & x"00000000000000"               when apuFcmLoadByteAddr  = "0111" else
                                 apuFcmLoadData(64  to 127) & x"0000000000000000"             when apuFcmLoadByteAddr  = "1000" else
                                 apuFcmLoadData(72  to 127) & x"000000000000000000"           when apuFcmLoadByteAddr  = "1001" else
                                 apuFcmLoadData(80  to 127) & x"00000000000000000000"         when apuFcmLoadByteAddr  = "1010" else
                                 apuFcmLoadData(88  to 127) & x"0000000000000000000000"       when apuFcmLoadByteAddr  = "1011" else
                                 apuFcmLoadData(96  to 127) & x"000000000000000000000000"     when apuFcmLoadByteAddr  = "1100" else
                                 apuFcmLoadData(104 to 127) & x"00000000000000000000000000"   when apuFcmLoadByteAddr  = "1101" else
                                 apuFcmLoadData(112 to 127) & x"0000000000000000000000000000" when apuFcmLoadByteAddr  = "1110" else
                                 apuFcmLoadData(120 to 127) & x"000000000000000000000000000000";

    -- Sizes
    iapuLoadFromPpc(i).size  <= apuFcmDecLdsTxferSize;
    iapuStoreFromPpc(i).size <= apuFcmDecLdsTxferSize;

    -- Store Decode
    dec_store(i) <= '1' when apuFcmInstrValid           = '1' and 
                             apuFcmInstruction(6 to 10) = i   and 
                             apuFcmDecStore             = '1' and
                             store_done(i) = '0' else '0';

    -- Store Done
    store_done_next(i) <= '1' when dec_store(i) = '1' and apuFcmFlush = '0' else '0';

    -- Store data
    iapuStoreFromPpc(i).enable <= store_done(i);

    -- Full/Empty Status
    apuLoadFullIn(i)   <= apuLoadToPpc(i).full;
    apuStoreEmptyIn(i) <= apuStoreToPpc(i).empty;

  end generate;

  -- Data MUX
  ifcmApuStoreData <= apuStoreToPpc(conv_integer(apuFcmInstruction(6 to 10))).data;

  -- Load/Store States 
  ls_p : process ( apuClkRst, apuClk )
  begin
    if apuClkRst='1' then
      load_done  <= (others=>'0') after tpd;
      store_done <= (others=>'0') after tpd;
    elsif rising_edge(apuClk) then
      load_done  <= load_done_next   after tpd;
      store_done <= store_done_next  after tpd;
    end if;
  end process ls_p;

  -- APU unused
  ifcmApuConfirmInstr  <= '0';
  ifcmApuException     <= '0';
  ifcmApuFpsCrFex      <= '0';
  ifcmApuSleepNotReady <= '0';
  --apuFcmDecFpuOp             : in  std_logic;
  --apuFcmDecNonAuton          : in  std_logic;
  --apuFcmEndian               : in  std_logic;
  --apuFcmMsrFe0               : in  std_logic;
  --apuFcmMsrFe1               : in  std_logic;
  --apuFcmNextInstrReady       : in  std_logic;
  --apuFcmWriteBackOk          : in  std_logic;

end architecture;

