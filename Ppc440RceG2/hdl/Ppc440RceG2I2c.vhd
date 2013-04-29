-------------------------------------------------------------------------------
-- Ppc440RceG2I2c.vhd
--
--   APU command
--     udi0fcm %0,%1,%2 : reads from BRAM address %1 into CPU register %0
--     udi2fcm %0,%1,%2 : reads from BRAM address %1 into CPU register %0
--       (udi2 duplicates udi0 except that it also updates the condition register)
--
--   BRAM registers 0-511
--     register 0   : "RST" - reset
--     register 510 : "IOW" - interrupt on write address
--     register 511 : "RSP" - response register
--
--   I2C write to BRAM RST register initiates reset
--     Reset is asserted when I2C transaction is complete
--     Reset is held for 8 DCR clock cycles (8 is arbitrary)
--   I2C write to BRAM register 1-511 initiates interrupt
--     When I2C transaction is complete:
--       Register address (1B view) is recorded in BRAM IOW
--       BRAM RSP register is set
--       Interrupt is asserted
--     Interrupt is held until DCR access writes to BRAM RSP register
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

use work.Ppc440RceG2Pkg.all;
use work.i2cPkg.all;
use work.StdRtlPkg.all;

entity Ppc440RceG2I2c is
  generic (
    TPD_G      : time                   := 1 ns;
    I2C_ADDR_G : integer range 0 to 128 := 0);
  port (
    iicSysClk : in std_logic;
    iicSysRst : in std_logic;

    cpuReset : out std_logic;

    -- APU Interface
    apuClk          : in  std_logic;
    apuRst          : in  std_logic;
    apuWriteFromPpc : in  ApuWriteFromPpcType;
    apuWriteToPpc   : out ApuWriteToPpcType;
    apuReadFromPpc  : in  ApuReadFromPpcType;
    apuReadToPpc    : out ApuReadToPpcType;

    -- IIC Interface
    i2ci : in  i2c_in_type;
    i2co : out i2c_out_type);

end Ppc440RceG2I2c;

architecture IMP of Ppc440RceG2I2c is

  -- i2cSysClk domain signals
  signal i2cWrEn   : std_logic;
  signal i2cAddr   : std_logic_vector(15 downto 0);
  signal i2cWrData : std_logic_vector(7 downto 0);
  signal i2cRdData : std_logic_vector(7 downto 0);

  type StateType is (WAIT_WR_S, WR_DATA_S, WR_ADDR_S, WR_FF_S);
  type SysRegType is record
    startup   : sl;
    interrupt : slv(3 downto 0);
    cpuReset  : slv(7 downto 0);
    state     : StateType;
    addr      : slv(15 downto 0);
    wrEn      : sl;
    wrData    : slv(7 downto 0);
  end record SysRegType;

  signal sysR, sysRin : SysRegType;

  -- apuClk domain signals
  signal apu_bram_wr   : std_logic;
  signal apu_bram_addr : std_logic_vector(15 downto 0);
  signal apu_bram_dout : std_logic_vector(31 downto 0);
  signal apu_bram_din  : std_logic_vector(31 downto 0);

  type ApuRegType is record
    interrupt : slv(1 downto 0);
    empty     : sl;
  end record ApuRegType;

  signal apuR, apuRin : ApuRegType;
  
begin  -- IMP

  --------------------------------------------------------------------------------------------------
  -- I2C Register Slave
  --------------------------------------------------------------------------------------------------
  i2cRegSlave_1 : entity work.i2cRegSlave
    generic map (
      TENBIT_G             => 0,
      I2C_ADDR_G           => I2C_ADDR_G,  -- 1001001
      OUTPUT_EN_POLARITY_G => 0,           -- IOBUFs enabled with low T signal
      FILTER_G             => 4,
      ADDR_SIZE_G          => 2,
      DATA_SIZE_G          => 1,
      ENDIANNESS_G         => 0)
    port map (
      sRst   => '0',
      aRst   => iicSysRst,
      clk    => iicSysClk,
      addr   => i2cAddr,
      wrEn   => i2cWrEn,
      wrData => i2cWrData,
      rdEn   => open,
      rdData => i2cRdData,
      i2ci   => i2ci,
      i2co   => i2co);

  --------------------------------------------------------------------------------------------------
  -- iicSysClk Logic - Glue between i2cRegSlave and block RAM.
  -- Assert cpuReset upon startup and hold until address 0x8000 is written to over i2c.
  -- A write to 0x8000 causes cpuReset to be held high for 8 cycles and then dropped.
  -- A write over i2c to 0b1xxxxxxxxxxxxxxx (where x != 0) causes an interrupt.
  -- sysR.interrupt is held for 4 cycles so that it can be picked up an synchronized to the apuClk.
  --
  -- On an i2c write, in addition to the data be written at the specified address, the lower byte
  -- of the address is written to address 0x07F8 and 0xFF is written to address 0x7FC.
  --------------------------------------------------------------------------------------------------
  iicSysClkComb : process (sysR, i2cWrData, i2cWrEn, i2cAddr) is
    variable v : SysRegType;
  begin
    v := sysR;

    -- Interrupt and cpuReset
    v.interrupt := '0' & sysR.interrupt(3 downto 1);
    v.cpuReset  := sysR.startup & sysR.cpuReset(7 downto 1);
    if (i2cWrEn = '1' and i2cAddr(15) = '1') then
      if (i2cAddr(14 downto 0) = "000000000000000") then
        v.cpuReset := (others => '1');
        v.startup  := '0';
      else
        v.interrupt := (others => '1');
      end if;
    end if;

    -- Control writes to bram
    v.wrData := i2cWrData;
    v.wrEn   := '0';
    v.addr   := i2cAddr;
    case sysR.state is
      when WAIT_WR_S =>
        -- Upon I2C Write, first put wrData into bram at i2cAddr
        if (i2cWrEn = '1') then
          v.wrData := i2cWrData;
          v.wrEn   := '1';
          v.addr   := i2cAddr;
          v.state  := WR_ADDR_S;
        end if;
      when WR_ADDR_S =>
        -- Then write lower byte of address into bram at 0x07F8
        v.wrData := i2cAddr(7 downto 0);
        v.wrEn   := '1';
        v.addr   := X"07F8";
        v.state  := WR_FF_S;
      when WR_FF_S =>
        -- Then write 0xFF to bram at 0x07FC
        v.wrData := X"FF";
        v.wrEn   := '1';
        v.addr   := X"07FC";
        v.state  := WAIT_WR_S;
      when others => null;
    end case;

    sysRin <= v;

    cpuReset <= sysR.cpuReset(0);       -- Output cpuReset    
  end process iicSysClkComb;

  iicSysClkSeq : process (iicSysClk, iicSysRst) is
  begin
    if (iicSysRst = '1') then
      sysR.startup   <= '1'             after TPD_G;
      sysR.interrupt <= (others => '0') after TPD_G;
      sysR.cpuReset  <= (others => '1') after TPD_G;
      sysR.wrEn      <= '0'             after TPD_G;
    -- Other bram signals don't need reset
    elsif (rising_edge(iicSysClk)) then
      sysR <= sysRin after TPD_G;
    end if;
  end process;

  --------------------------------------------------------------------------------------------------
  -- Block Ram
  -- Side B: 8x2048 - I2C
  -- Side A: 32x512 - APU
  --------------------------------------------------------------------------------------------------
  bram_0 : RAMB16_S9_S36
    port map (
      DOB   => apu_bram_dout,
      DOPB  => open,
      ADDRB => apu_bram_addr(8 downto 0),
      CLKB  => apuClk,
      DIB   => apu_bram_din,
      DIPB  => x"0",
      ENB   => '1',
      SSRB  => '0',
      WEB   => apu_bram_wr,
      DOA   => i2cRdData,               -- connects directly to i2cRegSlave
      DOPA  => open,
      ADDRA => sysR.addr(10 downto 0),
      CLKA  => iicSysClk,
      DIA   => sysR.wrData,
      DIPA  => "0",
      ENA   => '1',
      SSRA  => '0',
      WEA   => sysR.wrEn);

  --------------------------------------------------------------------------------------------------
  -- apuClk Logic
  --------------------------------------------------------------------------------------------------
  apuClkComb : process (apuR, sysR, apu_bram_wr, apu_bram_addr) is
    variable v : ApuRegType;
  begin
    v := apuR;

    -- Synchronize interrupt to apuClk domain
    v.interrupt := sysR.interrupt(0) & apuR.interrupt(1);

    -- Set empty low when interrupt seen
    if (apuR.interrupt(0) = '1') then
      v.empty := '0';
    end if;

    -- Reset empty when addr "111111111" is written to
    if (apu_bram_wr = '1' and apu_bram_addr(8 downto 0) = X"111111111") then
      v.empty := '1';
    end if;

    apuRin <= v;
  end process apuClkComb;

  apuClkSeq : process (apuClk, apuRst) is
  begin
    if (apuRst = '1') then
      apuR.interrupt <= (others => '0') after TPD_G;
      apuR.empty     <= '1'             after TPD_G;
    elsif (rising_edge(apuClk)) then
      apuR <= apuRin after TPD_G;
    end if;
  end process apuClkSeq;

  -- APU IO
  apu_bram_wr         <= apuWriteFromPpc.enable;
  apu_bram_addr       <= apuWriteFromPpc.regA(16 to 31);
  apu_bram_din        <= apuWriteFromPpc.regB;
  apuWriteToPpc.full  <= '0';
  apuReadToPpc.result <= apu_bram_dout;
  apuReadToPpc.status <= (others => '0');
  apuReadToPpc.empty  <= apuR.empty;
  apuReadToPpc.ready  <= '1';

  






end IMP;

