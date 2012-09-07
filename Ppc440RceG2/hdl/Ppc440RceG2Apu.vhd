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

    -- Store instructions
    apuStoreFromPpc            : out ApuStoreFromPpcVector(0 to 31);
    apuStoreToPpc              : in  ApuStoreToPpcVector(0 to 31);

    -- Status bits
    apuReadStatus              : out std_logic_vector(0 to 31);
    apuWriteStatus             : out std_logic_vector(0 to 31)
  );
end Ppc440RceG2Apu;

architecture structure of Ppc440RceG2Apu is

  -- Debug
--  component chipscope_icon
--    PORT (
--      CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
--    );
--  end component;

--  component chipscope_ila
--    PORT (
--      CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
--      CLK     : IN    STD_LOGIC;
--      TRIG0   : IN    STD_LOGIC_VECTOR(255 DOWNTO 0)
--    );
--  end component;

--  signal dbControl : std_logic_vector(35  downto 0);
--  signal dbDebug   : std_logic_vector(255 downto 0);

--  attribute syn_black_box : boolean;
--  attribute syn_noprune   : boolean;
--  attribute syn_black_box of chipscope_icon : component is TRUE;
--  attribute syn_noprune   of chipscope_icon : component is TRUE;
--  attribute syn_black_box of chipscope_ila  : component is TRUE;
--  attribute syn_noprune   of chipscope_ila  : component is TRUE;

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
  signal apuReadStatusIn      : std_logic_vector(0 to 31);
  signal apuWriteStatusIn     : std_logic_vector(0 to 31);
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
  signal storeTest            : std_logic_vector(0 to 3);

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

    -- Status combine
    apuReadStatusIn((7-i)*4 to (7-i)*4+3) <= apuReadToPpc(i).status;
    
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

    -- Status combine
    apuWriteStatusIn((7-i)*4 to (7-i)*4+3) <= apuWriteToPpc(i).status;

  end generate;

  -- Cycle completion
  ifcmApuDone        <= '0' when read_done = 0 and write_done = 0 and load_done = 0 and store_done = 0 else '1';
  ifcmApuResultValid <= '0' when read_done = 0 and store_done = 0 else '1';

  -- Status & Result Mux
  ifcmApuResult <= apuReadToPpc(conv_integer(apuFcmDecUdi(0 to 2))).result when read_done /= 0 else (others=>'0');
  ifcmApuCr     <= apuReadToPpc(conv_integer(apuFcmDecUdi(0 to 2))).status when read_done /= 0 else 
                   storeTest when store_done /= 0 else (others=>'0');

  -- Read/Write States 
  fcm_p : process ( apuClkRst, apuClk )
  begin
    if apuClkRst='1' then
      read_done      <= (others=>'0') after tpd;
      write_done     <= (others=>'0') after tpd;
      apuReadStatus  <= (others=>'0') after tpd;
      apuWriteStatus <= (others=>'0') after tpd;
    elsif rising_edge(apuClk) then
      read_done      <= read_done_next   after tpd;
      write_done     <= write_done_next  after tpd;
      apuReadStatus  <= apuReadStatusIn  after tpd;
      apuWriteStatus <= apuWriteStatusIn after tpd;
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

  end generate;

  ifcmApuStoreData <= apuStoreToPpc(conv_integer(apuFcmInstruction(6 to 10))).data;

  -- Load/Store States 
  ls_p : process ( apuClkRst, apuClk )
  begin
    if apuClkRst='1' then
      load_done  <= (others=>'0') after tpd;
      store_done <= (others=>'0') after tpd;
      storeTest  <= (others=>'0') after tpd;
    elsif rising_edge(apuClk) then
      load_done  <= load_done_next   after tpd;
      store_done <= store_done_next  after tpd;

      if ( store_done /= 0 ) then 
         storeTest <= storeTest + 1 after tpd;
      end if;

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

  --------------------------------
  -- Debug
  --------------------------------
  --U_Icon : chipscope_icon PORT map (
    --CONTROL0 => dbControl
  --);

  --U_Ila : chipscope_ila PORT map (
    --CONTROL => dbControl,
    --CLK     => apuClk,
    --TRIG0   => dbDebug
  --);

  --dbDebug(255 to 252)      <= (others=>'0');
  --dbDebug(251 downto 188)  <= iapuLoadFromPpc(0).data(0 to 63);
  --dbDebug(187)             <= dec_read(0);
  --dbDebug(186)             <= dec_write(0);
  --dbDebug(185)             <= read_done(0);
  --dbDebug(184)             <= write_done(0);
  --dbDebug(183)             <= read_done_next(0);
  --dbDebug(182)             <= write_done_next(0);
  --dbDebug(181)             <= dec_load(0);
  --dbDebug(180)             <= dec_store(0);
  --dbDebug(179)             <= load_done(0);
  --dbDebug(178)             <= store_done(0);
  --dbDebug(177)             <= load_done_next(0);
  --dbDebug(176)             <= store_done_next(0);
  --dbDebug(175)             <= dec_read(1);
  --dbDebug(174)             <= dec_write(1);
  --dbDebug(173)             <= read_done(1);
  --dbDebug(172)             <= write_done(1);
  --dbDebug(171)             <= read_done_next(1);
  --dbDebug(170)             <= write_done_next(1);
  --dbDebug(169)             <= dec_load(1);
  --dbDebug(168)             <= dec_store(1);
  --dbDebug(167)             <= load_done(1);
  --dbDebug(166)             <= store_done(1);
  --dbDebug(165)             <= load_done_next(1);
  --dbDebug(164)             <= store_done_next(1);
  --dbDebug(163)             <= ifcmApuConfirmInstr;
  --dbDebug(162)             <= ifcmApuDone;
  --dbDebug(161)             <= ifcmApuException;
  --dbDebug(160)             <= ifcmApuFpsCrFex;
  --dbDebug(159)             <= ifcmApuResultValid;
  --dbDebug(158)             <= ifcmApuSleepNotReady;
  --dbDebug(157)             <= apuFcmDecFpuOp;
  --dbDebug(156)             <= apuFcmDecLoad;
  --dbDebug(155)             <= apuFcmDecNonAuton;
  --dbDebug(153)             <= apuFcmDecStore;
  --dbDebug(152)             <= apuFcmDecUdiValid;
  --dbDebug(151)             <= apuFcmEndian;
  --dbDebug(150)             <= apuFcmFlush;
  --dbDebug(149)             <= apuFcmInstrValid;
  --dbDebug(148)             <= apuFcmLoadDValid;
  --dbDebug(147)             <= apuFcmMsrFe0;
  --dbDebug(146)             <= apuFcmMsrFe1;
  --dbDebug(145)             <= apuFcmNextInstrReady;
  --dbDebug(144)             <= apuFcmOperandValid;
  --dbDebug(143)             <= apuFcmWriteBackOk;
  --dbDebug(142 downto 139)  <= ifcmApuCr;
  --dbDebug(138 downto 136)  <= apuFcmDecLdsTxferSize;
  --dbDebug(135 downto 132)  <= apuFcmDecUdi;
  --dbDebug(131 downto 128)  <= apuFcmLoadByteAddr;
  --dbDebug(127 downto  96)  <= ifcmApuResult;
  --dbDebug( 95 downto  64)  <= apuFcmInstruction;
  --dbDebug( 63 downto  32)  <= apuFcmRaData;
  --dbDebug( 31 downto   0)  <= apuFcmRbData;

end architecture;

