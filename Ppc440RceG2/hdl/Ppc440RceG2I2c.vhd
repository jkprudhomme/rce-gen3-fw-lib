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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.Ppc440RceG2Pkg.all;

entity Ppc440RceG2I2c is
  generic ( REG_INIT     : i2c_reg_vector(4 to 511) := (others=>x"00000000") );
  port (
    rst_i     : in  std_logic;

    -- Client interface
    rst_o     : out std_logic;
    interrupt : out std_logic;
    clk32     : in  std_logic;

    -- APU Interface
    apuClk           : in  std_logic;
    apuWriteFromPpc  : in  ApuWriteFromPpcType;
    apuWriteToPpc    : out ApuWriteToPpcType;
    apuReadFromPpc   : in  ApuReadFromPpcType;
    apuReadToPpc     : out ApuReadToPpcType;

    -- IIC Interface
    iic_addr    : in  std_logic_vector(6 downto 0);
    iic_clki    : in  std_logic;
    iic_clko    : out std_logic;
    iic_clkt    : out std_logic;
    iic_datai   : in  std_logic;
    iic_datao   : out std_logic;
    iic_datat   : out std_logic;
    --
    debug       : out std_logic_vector(15 downto 0)
    );
end Ppc440RceG2I2c;

architecture IMP of Ppc440RceG2I2c is

  component i2c_block
  port (
    clk         : in    std_logic;
    rst_i       : in    std_logic;
    rrq         : out   std_logic;
    irq         : out   std_logic;
    -- I2C bus signals
    saddr       : in    std_logic_vector(6 downto 0);
    sda_i       : in    std_logic;
    sda_o       : out   std_logic;
    sda_t       : out   std_logic;
    scl_i       : in    std_logic;
    scl_o       : out   std_logic;
    scl_t       : out   std_logic;
    -- BRAM interface
    rclk        : out   std_logic;
    rden        : out   std_logic;
    wren        : out   std_logic;
    addr        : out   std_logic_vector(15 downto 0);
    datai       : in    std_logic_vector( 7 downto 0);
    datao       : out   std_logic_vector( 7 downto 0)
    );
  end component;
  
  signal iic_bram_clk  : std_logic;
  signal iic_bram_rd   : std_logic;
  signal iic_bram_wr   : std_logic;
  signal iic_bram_en   : std_logic;
  signal iic_bram_addr : std_logic_vector(15 downto 0);
  signal iic_bram_dout : std_logic_vector( 7 downto 0);
  signal iic_bram_din  : std_logic_vector( 7 downto 0);

  signal apu_bram_wr   : std_logic;
  signal apu_bram_addr : std_logic_vector(15 downto 0);
  signal apu_bram_dout : std_logic_vector(31 downto 0);
  signal apu_bram_din  : std_logic_vector(31 downto 0);
  
  constant REGADDR : std_logic_vector(apu_bram_addr'range) := std_logic_vector(conv_unsigned(-2,apu_bram_addr'length));
  constant RSPADDR : std_logic_vector(apu_bram_addr'range) := std_logic_vector(conv_unsigned(-1,apu_bram_addr'length));
  
  signal rrq : std_logic;
  signal rst_b : std_logic;
  signal rst_b_next : std_logic;

  function INIT_FN ( REG_INIT : i2c_reg_vector;
                     index    : unsigned(7 downto 0) )
    return bit_vector is
    variable i : integer := conv_integer(index & "000");
    variable y : bit_vector(0 to 255);
  begin 
    for j in 0 to 7 loop
      if (i+j)<REG_INIT'left then
        y(j*32 to j*32+31) := (others=>'0');
      elsif (i+j)>REG_INIT'right then
        y(j*32 to j*32+31) := (others=>'0');
      else
        y(j*32 to j*32+31) := REG_INIT(i+j);
      end if;
    end loop;  -- j
    return y;
  end function INIT_FN;
    
begin  -- IMP

  -- need logic to latch rst_o

  reset_b : block
    type Reset_State is (RInit, RWait, RCount, RIdle);
    signal resetState, resetState_next : Reset_State;
    
    signal rst_cnt, rst_cnt_next : unsigned(2 downto 0);
    constant TERM : unsigned(rst_cnt'range) := (others=>'0');
  begin
    rst_o <= rst_b;
  
    rst_b_next   <= '0' when resetState=RIdle else '1';
    
    rst_cnt_next <= (rst_cnt-1) when resetState_next=RCount else
                    (TERM     );

    resetState_next <= RWait  when (rrq='1') else
                       RCount when (resetState=RWait  and rrq='0') else
                       RIdle  when (resetState=RCount and rst_cnt=TERM) else
                       resetState;
    
    rst_p : process(rst_i, clk32)
    begin
      if rst_i='1' then
        rst_b      <= '1';
        rst_cnt    <= TERM;
        resetState <= RInit;
      elsif rising_edge(clk32) then
        rst_b      <= rst_b_next;
        rst_cnt    <= rst_cnt_next;
        resetState <= resetState_next;
      end if;
    end process rst_p;
  end block reset_b;
  
  bram_0 : RAMB16_S9_S36  generic map ( INIT_00 => INIT_FN( REG_INIT, X"00" ) )
                          port map ( DOB  => apu_bram_dout,
                                     DOPB => open,
                                     ADDRB=> apu_bram_addr(8 downto 0),
                                     CLKB => apuClk,
                                     DIB  => apu_bram_din,
                                     DIPB => x"0",
                                     ENB  => '1',
                                     SSRB => rst_i,
                                     WEB  => apu_bram_wr,
                                     DOA  => iic_bram_dout,
                                     DOPA => open,
                                     ADDRA => iic_bram_addr(10 downto 0),
                                     CLKA => iic_bram_clk,
                                     DIA  => iic_bram_din,
                                     DIPA => "0",
                                     ENA  => iic_bram_en,
                                     SSRA => rst_i,
                                     WEA  => iic_bram_wr );

  iic_bram_en <= iic_bram_rd or iic_bram_wr;

  i2c_b : i2c_block
--    generic map (CLK_FREQ_MHZ => CLK_FREQ_MHZ)
    port map (
      clk         => clk32,
      rst_i       => rst_i,
      rrq         => rrq,
      irq         => interrupt,
      -- I2C bus signals
      saddr       => iic_addr,
      sda_i       => iic_datai,
      sda_o       => iic_datao,
      sda_t       => iic_datat,
      scl_i       => iic_clki,
      scl_o       => iic_clko,
      scl_t       => iic_clkt,
      -- BRAM interface
      rclk        => iic_bram_clk,
      rden        => iic_bram_rd,
      wren        => iic_bram_wr,
      addr        => iic_bram_addr,
      datai       => iic_bram_dout,
      datao       => iic_bram_din );

  -- Interface
  apu_bram_wr          <= apuWriteFromPpc.enable;
  apu_bram_addr        <= apuWriteFromPpc.regA(16 to 31);
  apu_bram_din         <= apuWriteFromPpc.regB;
  apuWriteToPpc.full   <= '0';
  apuReadToPpc.result  <= apu_bram_dout;
  apuReadToPpc.status  <= (others=>'0');
  apuReadToPpc.empty   <= '0';

end IMP;

