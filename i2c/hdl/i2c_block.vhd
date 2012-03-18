-------------------------------------------------------------------------------
-- i2c_block.vhd
--
-- This I2C slave provides byte access to a block RAM.  Data to
-- be written is preceded by a 2-byte address into the RAM (LSB first).
-- Reads are addressed by first writing the 2-byte address to this slave.
-- The read address is cached and incremented on every byte read.  Thus,
-- a write of 2 bytes or less sets the read address pointer.  A write of
-- more than 2 bytes writes to RAM without modifying the read address
-- pointer.
-- 
-- The I2C slave IP core within this modules uses a microcontroller
-- register interface for control/access to the data on I2C.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity i2c_block is
  port (
    clk         : in    std_logic;
    rst_i       : in    std_logic;
    rrq         : out   std_logic;
    irq         : out   std_logic;
    -- I2C bus signals
    saddr       : in    std_logic_vector(6 downto 0);
    sda_i	: in	std_logic;		
    sda_o	: out	std_logic;		
    sda_t	: out	std_logic;		
    scl_i	: in	std_logic;
    scl_o	: out	std_logic;
    scl_t	: out	std_logic;
    -- BRAM interface
    rclk        : out   std_logic;
    rden        : out   std_logic;
    wren        : out   std_logic;
    addr        : out   std_logic_vector(15 downto 0);
    datai       : in    std_logic_vector( 7 downto 0);
    datao       : out   std_logic_vector( 7 downto 0)
    );
end i2c_block;

architecture IMP of i2c_block is

  component i2c
    generic (I2C_ADDRESS  : std_logic_vector(15 downto 0):= "0000000000000000" );
    port (
      -- I2C bus signals
      sda_i	: in	std_logic;		
      sda_o	: out	std_logic;		
      sda_t	: out	std_logic;		
      scl_i	: in	std_logic;
      scl_o	: out	std_logic;
      scl_t	: out	std_logic;

      -- uC interface signals
      addr_bus        : in            std_logic_vector(23 downto 0);
      data_bus        : inout         std_logic_vector(7 downto 0);
      as              : in            std_logic;      -- address strobe, active low
      ds              : in            std_logic;      -- data strobe, active low
      r_w             : in            std_logic;      -- read/write
      dtack           : out           std_logic;      -- data transfer acknowledge
      irq             : out           std_logic;      -- interrupt request

      mcf             : inout         std_logic;  -- temporary output for testing
      mbb             : out           std_logic;  -- added bus busy signal
      mal             : out           std_logic;  -- added bus busy signal
      -- clock and reset
      clk             : in            std_logic;
      reset           : in            std_logic
      );
  end component;

  -- I2C bus state
  --   'Init'                => I2C slave address on bus
  --   'RegAddr1'            => slave register address (LSB)
  --   'RegAddr2'            => slave register address (MSB)
  --   'RegDataR'            => register data word read
  --   'RegDataW'            => register data word written
  type I2C_Byte_State is (Init, RegAddr1, RegAddr2, RegDataR, RegDataW);
  signal iic_byte_state, iic_byte_state_next : I2C_Byte_State;

  signal uc_addr : std_logic_vector(23 downto 0);
  constant UCADDR   : std_logic_vector(15 downto 0) := (others=>'0');
  constant MADR_REG : std_logic_vector(23 downto 0) := UCADDR & x"8D";
  constant MBCR_REG : std_logic_vector(23 downto 0) := UCADDR & x"91";
  constant MBSR_REG : std_logic_vector(23 downto 0) := UCADDR & x"93";
  constant MBDR_REG : std_logic_vector(23 downto 0) := UCADDR & x"95";

  signal uc_data : std_logic_vector(7 downto 0);
  signal uc_rnw, uc_dtack, uc_irq, uc_mcf, u_uc_mcf : std_logic;
  signal uc_as, uc_as_next : std_logic;
  signal uc_ds, uc_ds_next : std_logic;

  signal uc_wrreq, uc_rdreq, uc_drdy : std_logic;
  signal uc_aas, uc_aas_next : std_logic;
  signal uc_srw, uc_srw_next : std_logic;
  signal uc_bsy, uc_bsyq : std_logic;

  --
  --  i2c 'microcontroller' bus state
  --
  type UcBusState is (IDLE, WRITE_AST, WRITE_ACK, READ_AST, READ_ACK);
  signal ucb_state, ucb_state_next : UcBusState;
  
  --
  --  state machine for reading/writing 'microcontroller' registers
  --
  type I2CState is (RESET, ENABLED, WAITCF, READSTAT, RWDATA, WAITNCF);
  signal iic_state, iic_state_next : I2CState;

  signal rst_n : std_logic;
    
  signal addr_la, addr_la_next : std_logic;
  signal addrb  , addrb_next   : std_logic_vector(addr'range);
  signal rdaddrb, rdaddrb_next : std_logic_vector(addr'range);
  signal rdenb, wrenb : std_logic;

  signal ist, ist_rst : std_logic;               -- I2C start detection

  constant REGRST   : std_logic_vector(addr'range) := std_logic_vector(conv_unsigned( 0,addr'length));
  constant REGBYTE1 : std_logic_vector(addr'range) := std_logic_vector(conv_unsigned(-8,addr'length));
  constant REGBYTE2 : std_logic_vector(addr'range) := std_logic_vector(conv_unsigned(-7,addr'length));
  constant REGRESP  : std_logic_vector(addr'range) := std_logic_vector(conv_unsigned(-4,addr'length));

  
  type wrState is (IDLE, WRITING, ADDR1, ADDR2, RESP, AST);
  signal write_state, write_state_next : wrState;
  signal wraddr, wraddr_next : std_logic_vector(addr'range);

begin  -- IMP

  rst_n   <= not rst_i;

  --  'microcontroller' register address
  uc_addr <= MBCR_REG when iic_state=RESET   else
             MADR_REG when iic_state=ENABLED else
             MBDR_REG when iic_state=RWDATA  else
             MBSR_REG;

  --  'microcontroller' register write data
  uc_data <= x"80"            when iic_state=RESET else
             (saddr & '0')    when iic_state=ENABLED else
             datai            when ucb_state=WRITE_AST else
             (others=>'Z');

  --  'microcontroller' address strobe
  uc_as_next <= '0' when (ucb_state_next=WRITE_AST or
                          ucb_state_next=READ_AST) else
                '1';       

  --  'microcontroller' data strobe
  uc_ds_next <= '0' when (ucb_state_next=WRITE_AST or
                          ucb_state_next=READ_AST) else
                '1';

  --  'microcontroller' read/~write
  uc_rnw <= '0' when (ucb_state_next=WRITE_AST or
                      ucb_state_next=WRITE_ACK) else
            '1'; 

  ucb_state_next <= IDLE      when ((ucb_state=WRITE_ACK or
                                     ucb_state=READ_ACK) and uc_dtack/='0') else
                    WRITE_ACK when (ucb_state=WRITE_AST and uc_dtack='0') else
                    READ_ACK  when (ucb_state=READ_AST  and uc_dtack='0') else
                    WRITE_AST when (ucb_state=IDLE and uc_wrreq='1') else
                    READ_AST  when (ucb_state=IDLE and uc_rdreq='1') else
                    ucb_state;
  
  iic_state_next <= iic_state when (ucb_state_next/=IDLE) else
                    ENABLED   when (iic_state=RESET) else
                    WAITCF    when (iic_state=ENABLED or
                                    (iic_state=WAITNCF and u_uc_mcf='0')) else
                    READSTAT  when (iic_state=WAITCF and u_uc_mcf='1') else
                    RWDATA    when (iic_state=READSTAT and uc_aas='1') else
                    WAITNCF   when (iic_state=RWDATA or
                                    (iic_state=READSTAT and uc_aas='0')) else
                    iic_state;

  -- 'microcontroller' write request to state machine
  uc_wrreq <= '1' when ((iic_state=RESET or
                         iic_state=ENABLED or
                         (iic_state=RWDATA and uc_srw='1')) and ucb_state=IDLE) else
              '0';

  -- 'microcontroller' read request to state machine
  uc_rdreq <= '1' when ((iic_state=READSTAT or
                         (iic_state=RWDATA and uc_srw='0')) and ucb_state=IDLE) else
              '0';

  -- 'microcontroller' data ready
  uc_drdy  <= '1' when ((ucb_state=READ_AST  and ucb_state_next=READ_ACK) or
                        (ucb_state=WRITE_AST and ucb_state_next=WRITE_ACK)) else
              '0';    

  -- i2c addressed as slave latch
  uc_aas_next <= uc_data(6) when (iic_state=READSTAT and uc_drdy='1') else
                 uc_aas;

  -- i2c slave read/~write latch
  uc_srw_next <= uc_data(2) when (iic_state=READSTAT and uc_drdy='1') else
                 uc_srw;

  seq_p: process (clk, rst_i)
  begin  -- process seq_p
    if rst_i = '1' then
      ucb_state <= IDLE;
      iic_state <= RESET;
      uc_as     <= '1';
      uc_ds     <= '1';
      uc_aas    <= '0';
      uc_srw    <= '1';
      addrb               <= (others=>'0');
      rdaddrb             <= (others=>'0');
      iic_byte_state      <= Init;
      ist_rst   <= '0';
      addr_la   <= '0';
      write_state <= IDLE;
      wraddr      <= (others=>'0');
      u_uc_mcf    <= '0';
    elsif rising_edge(clk) then
      ucb_state <= ucb_state_next;
      iic_state <= iic_state_next;
      uc_as     <= uc_as_next;
      uc_ds     <= uc_ds_next;
      uc_aas    <= uc_aas_next;
      uc_srw    <= uc_srw_next;
      addrb               <= addrb_next;
      rdaddrb             <= rdaddrb_next;
      iic_byte_state      <= iic_byte_state_next;
      ist_rst   <= ist;
      addr_la   <= addr_la_next;
      write_state <= write_state_next;
      wraddr      <= wraddr_next;
      u_uc_mcf    <= uc_mcf;
    end if;
  end process seq_p;

  --
  --  Need special start detection
  --    Repeated start marks end of a command
  --
  ist_p: process (sda_i, ist_rst)
  begin
    if ist_rst='1' then
      ist <= '0';
    elsif falling_edge(sda_i) then
      if scl_i='1' then
        ist <= '1';
      end if;
    end if;
  end process ist_p;
  
  iic : i2c
    port map (
      sda_i     => sda_i,
      sda_o     => sda_o,
      sda_t     => sda_t,
      scl_i     => scl_i,
      scl_o     => scl_o,
      scl_t     => scl_t,
      addr_bus  => uc_addr,
      data_bus  => uc_data,
      as        => uc_as,
      ds        => uc_ds,
      r_w       => uc_rnw,
      dtack     => uc_dtack,
      irq       => uc_irq,
      mcf       => uc_mcf,
      mbb       => uc_bsy,
      mal       => open,
      clk       => clk,
      reset     => rst_n
      );

  --  write the MBDR data to BRAM
  wrenb        <= '1' when (iic_state=RWDATA and uc_drdy='1' and
                            iic_byte_state=RegDataW and
                            uc_srw='0') else
                  '0';

  --  read the BRAM
  rdenb        <= '1' when (iic_state=READSTAT and uc_drdy='1' and 
                            uc_srw_next='1') else
                  '0';

  --  latch the address from the first two data words on an I2C write
  --  increment the address on a data word write
  --  reset the address to the read address pointer when idle
  addrb_next <= (x"00" & uc_data)             when (iic_state=RWDATA and uc_drdy='1' and
                                                    iic_byte_state=RegAddr1) else
                (uc_data & addrb(7 downto 0)) when (iic_state=RWDATA and uc_drdy='1' and
                                                    iic_byte_state=RegAddr2) else
                (addrb+1)                     when (wrenb='1') else
                (addrb);

  --  qualify the bus busy signal by clearing on a (repeated) start detection
  uc_bsyq <= uc_bsy and not ist_rst;


  --  latch on an address write or data read
  --  reset on a data word write or end of transaction
  addr_la_next <= '1' when (iic_byte_state=RegAddr1) else
                  '0' when (wrenb='1' or uc_bsyq='0') else
                  addr_la;

  --  latch the read address pointer when we complete an address write
  --  increment on a completed data word read
  rdaddrb_next <= (addrb)     when (uc_bsyq='0' and addr_la='1') else
                  (rdaddrb+1) when (rdenb='1' and iic_byte_state=RegDataR) else
                  (rdaddrb);

  iic_byte_state_next <= Init           when (uc_bsyq='0') else
                         iic_byte_state when (iic_state/=RWDATA or uc_drdy='0') else
                         RegDataR       when (uc_srw='1') else
                         RegAddr1       when (iic_byte_state=Init) else
                         RegAddr2       when (iic_byte_state=RegAddr1) else
                         RegDataW;
                         
                         
  write_state_next <= WRITING when (wrenb='1') else
                      ADDR1   when (write_state=WRITING and uc_bsyq='0') else
                      ADDR2   when (write_state=ADDR1) else
                      RESP    when (write_state=ADDR2) else
                      AST     when (write_state=RESP ) else
                      IDLE    when (write_state=AST  ) else
                      write_state;
  wraddr_next      <= addrb   when (write_state=IDLE and write_state_next=WRITING) else
                      wraddr;
  
  datao        <= (      wraddr( 7 downto 0)) when (write_state_next=ADDR1) else
                  ('0' & wraddr(14 downto 8)) when (write_state_next=ADDR2) else
                  (x"FF"                    ) when (write_state_next=RESP ) else
                  (uc_data);
  addr         <= REGBYTE1     when (write_state_next=ADDR1) else
                  REGBYTE2     when (write_state_next=ADDR2) else
                  REGRESP      when (write_state_next=RESP) else
                  rdaddrb_next when rdenb='1' else
                  addrb;
  rden         <= rdenb;
  wren         <= '1' when (wrenb='1' or
                            write_state_next=ADDR1 or
                            write_state_next=ADDR2 or
                            write_state_next=RESP ) else
                  '0';
                            
  rclk         <= clk;
  
  rrq          <= '1' when (write_state_next=AST and
                            wraddr(wraddr'left)='1' and
                            wraddr(wraddr'left-1 downto 0) =REGRST(wraddr'left-1 downto 0)) else '0';
  irq          <= '1' when (write_state_next=AST and
                            wraddr(wraddr'left)='1' and
                            wraddr(wraddr'left-1 downto 0)/=REGRST(wraddr'left-1 downto 0)) else
                  '0';
end IMP;
