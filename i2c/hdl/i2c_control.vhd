-- i2c_control.vhd
--
-- Created: 12/30/99 ALS
--
-- 	This code implements the control of the i2c bus
--	created from code developed 6/99 - made minor changes
--	to reduce macrocell counts and changed system clock to 2Mhz
--	clock count only needs to be four bits since only counts half 
--	clock periods
--
-- Revised:	03/13/00 ALS
-- Revised:	06/29/00 ALS
-- Revised:	09/22/00 ALS


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity i2c_control is
  
  port(
	-- I2C bus signals
        sda_i	: in	std_logic;		
        sda_o	: out	std_logic;		
        sda_t	: out	std_logic;		
        scl_i	: in	std_logic;
        scl_o	: out	std_logic;
        scl_t	: out	std_logic;
	
	-- interface signals from uP interface
	txak		: in		std_logic;	-- value for acknowledge when xmit
	msta		: in		std_logic; 	-- master/slave select
	msta_rst	: out		std_logic;	-- resets MSTA bit if arbitration is lost
	rsta		: in		std_logic;	-- repeated start 
	rsta_rst	: out		std_logic;	-- repeated start reset
	mtx		: in		std_logic;	-- master read/write 
	mbdr_micro	: in		std_logic_vector(7 downto 0);	-- uP data to output on I2C bus
	madr		: in		std_logic_vector(7 downto 0); -- I2C slave address
	mbb		: out		std_logic;	-- bus busy
	mcf		: inout		std_logic;	-- data transfer
	maas		: inout		std_logic;	-- addressed as slave
	mal		: inout		std_logic;	-- arbitration lost
	srw		: inout		std_logic;	-- slave read/write
	mif		: out		std_logic; 	-- interrupt pending
	rxak		: out		std_logic;	-- received acknowledge
	mbdr_i2c	: inout		std_logic_vector(7 downto 0); -- I2C data for uP
	mbcr_wr		: in		std_logic;	-- indicates that MCBR register was written
	mif_bit_reset 	: in		std_logic;	-- indicates that the MIF bit should be reset
	mal_bit_reset 	: in		std_logic;	-- indicates that the MAL bit should be reset

      	sys_clk : in std_logic;
	reset : in std_logic);

end i2c_control;

library IEEE;
use IEEE.std_logic_1164.all;

architecture behave of i2c_control is

constant	CNT_100KHZ	:	std_logic_vector(4 downto 0) := "10100";-- number of 2MHz clocks in 100KHz
constant	HIGH_CNT	: 	std_logic_vector(3 downto 0) := "1000";	-- number of 2MHz clocks in half 
										-- 100KHz period -1 since count from 0
										-- and -1 for "edge" state
constant	LOW_CNT		:	std_logic_vector(3 downto 0) := "1000";	-- number of 2Mhz clocks in half 
										-- 100KHZ period -1 since count from 0
										-- and -1 for "edge" state
constant	HIGH_CNT_2	:	std_logic_vector(3 downto 0) := "0100";	-- half of HIGH_CNT 

constant	TBUF		:	std_logic_vector(3 downto 0) := "1001"; -- number of 2MHz clocks in 4.7uS
constant	DATA_HOLD	:	std_logic_vector(3 downto 0) := "0001";	-- number of 2MHz clocks in 300ns
constant	START_HOLD	:	std_logic_vector(3 downto 0) := "1000";	-- number of 2MHz clocks in 4.0uS
constant	CLR_REG		:     	std_logic_vector (7 downto 0) := "00000000";
constant	START_CNT   	: 	std_logic_vector (3 downto 0) := "0000";
constant	CNT_DONE    	: 	std_logic_vector (3 downto 0) := "0111";
constant	ZERO_CNT	: 	std_logic_vector (3 downto 0) := "0000";  
constant	ZERO		: 	std_logic := '0'; 
constant 	RESET_ACTIVE 	:	std_logic := '0';

-- 8-bit serial load/parallel shift register
component SHIFT8
	port(
	     clk          : in std_logic;                        -- Clock
	     clr          : in std_logic;                        -- Active low clear
	     data_ld      : in std_logic;                        -- Data load enable
	     data_in      : in std_logic_vector (7 downto 0);     -- 8-bit data to load
	     shift_in     : in std_logic;                        -- Serial data in
	     shift_en     : in std_logic;                        -- Shift enable
	     shift_out    : out std_logic;                       -- Bit to shift out
	     data_out     : out std_logic_vector (7 downto 0));  -- 8-bit parallel out
		
end component;

-- Up counter - 4 bit
component UPCNT4
	port(
	     data         : in std_logic_vector (3 downto 0);    -- Serial data in
	     cnt_en       : in std_logic;                        -- Count enable
	     load         : in std_logic;                        -- Load line enable
 	     clr          : in std_logic;                        -- Active low clear
	     clk          : in std_logic;                        -- Clock
	     qout         : inout std_logic_vector (3 downto 0));
		
end component;


type state_type is (IDLE, HEADER, ACK_HEADER, RCV_DATA, ACK_DATA, 
				XMIT_DATA, WAIT_ACK);
signal state 		: state_type;

type scl_state_type is (SCL_IDLE, START, SCL_LOW_EDGE, SCL_LOW, SCL_HIGH_EDGE, 
				SCL_HIGH, STOP_WAIT);
signal scl_state, next_scl_state 		: scl_state_type;

signal scl_in		: std_logic;	-- sampled version of scl
signal scl_out		: std_logic;	-- combinatorial scl output from scl generator state machine
signal scl_out_reg	: std_logic;	-- registered version of SCL_OUT
signal scl_not		: std_logic;	-- inverted version of SCL
signal sda_in		: std_logic;	-- sampled version of sda
signal sda_out		: std_logic;	-- combinatorial sda output from scl generator state machine
signal sda_out_reg	: std_logic;	-- registered version of SDA_OUT
signal sda_out_reg_d1	: std_logic;	-- delayed sda output for arbitration comparison
signal slave_sda		: std_logic;	-- sda value when slave
signal master_sda		: std_logic;	-- sda value when master

signal sda_oe		: std_logic;

signal master_slave	: std_logic;	-- 1 if master, 0 if slave

-- Shift Register and the controls	
signal shift_reg		: std_logic_vector(7 downto 0);	-- shift register that holds I2C data				
signal shift_out		: std_logic;
signal shift_reg_en, shift_reg_ld   : std_logic;
signal i2c_header		: std_logic_vector(7 downto 0);	-- shift register that holds I2C header
signal i2c_header_en, i2c_header_ld : std_logic;
signal i2c_shiftout	: std_logic;

-- Used to check slave address detected
signal addr_match  : std_logic;


signal arb_lost		: std_logic;	-- 1 if arbitration is lost
signal msta_d1		: std_logic;	-- delayed sample of msta

signal detect_start	: std_logic;	-- indicates that a START condition has been detected
signal detect_stop	: std_logic;	-- indicates that a STOP condition has been detected
signal sm_stop		: std_logic;	-- indicates that a STOP condition needs to be generated
							-- from state machine
signal bus_busy		: std_logic;	-- indicates that the bus is busy - set when START, cleared when STOP
signal bus_busy_d1	: std_logic;	-- delayed sample of bus busy used to determine MAL
signal gen_start		: std_logic;	-- indicates that the uP wants to generate a START
signal gen_stop		: std_logic;	-- indicates that the uP wants to generate a STOP
signal rep_start		: std_logic;	-- indicates that the uP wants to generate a repeated START
signal stop_scl		: std_logic;	-- signal in SCL state machine indicating a STOP
signal stop_scl_reg	: std_logic;	-- registered version of STOP_SCL

-- Bit counter 0 to 7
signal bit_cnt		: std_logic_vector(3 downto 0);
signal bit_cnt_ld, bit_cnt_en : std_logic; 

-- Clock Counter
signal clk_cnt		: std_logic_vector (3 downto 0);
signal clk_cnt_rst	: std_logic;
signal clk_cnt_en 	: std_logic;      

-- the following signals are only here because Viewlogic's VHDL compiler won't allow a constant
-- to be used in a component instantiation
signal reg_clr		: std_logic_vector(7 downto 0);	
signal zero_sig		: std_logic;
signal cnt_zero		: std_logic_vector(3 downto 0);
signal cnt_start		: std_logic_vector(3 downto 0);



begin

  -- set SDA and SCL
	sda_o <= '0';
        sda_t <= not sda_oe;
	scl_o <= '0';
        scl_t <= scl_out_reg;
	scl_not <= not(scl_i);

  -- sda_oe is set when master and arbitration is not lost and data to be output = 0 or
  -- when slave and data to be output is 0

	sda_oe <= '1' when ((master_slave = '1' and arb_lost = '0' and sda_out_reg = '0') or
				 (master_slave = '0' and slave_sda = '0')
				  or stop_scl_reg = '1') else '0';

 
-- the following signals are only here because Viewlogic's VHDL compiler won't allow a constant
-- to be used in a component instantiation
reg_clr <= CLR_REG;
zero_sig <= ZERO;
cnt_zero <= ZERO_CNT;
cnt_start <= START_CNT;


-- ************************  Arbitration Process ************************
-- This process checks the master's outgoing SDA with the incoming SDA to determine
-- if control of the bus has been lost. SDA is checked only when SCL is high
-- and during the states IDLE, HEADER, and XMIT_DATA to insure that START and STOP 
-- conditions are not set when the bus is busy. Note that this is only done when Master. 
-- When arbitration is lost, a reset is generated for the MSTA bit

-- Note that when arbitration is lost, the mode is switched to slave and SCL continues
-- to be generated until the byte transfer is complete

-- arb_lost stays set until scl state machine goes to IDLE state

arbitration: process (sys_clk, reset)
  begin
	if reset = RESET_ACTIVE then
		arb_lost <= '0';
		msta_rst <= '0';
    	elsif (sys_clk'event and sys_clk = '1') then
		if scl_state = SCL_IDLE then
			arb_lost <= '0';
			msta_rst <= '0';
      	elsif (master_slave = '1') then
			-- only need to check arbitration in master mode
        		-- check for SCL high before comparing data and insure that arb_lost is 
			-- not already set
			if (scl_in = '1' and scl_i = '1' and arb_lost = '0' 
				and (state = HEADER or	state = XMIT_DATA or state = IDLE)) then
				-- when master, will check bus in all states except ACK_HEADER and WAIT_ACK
				-- this will insure that arb_lost is set if a start or stop condition
				-- is set at the wrong time
				if sda_out_reg_d1 = sda_in then 
					arb_lost <= '0';
					msta_rst <= '0';
				else
					arb_lost <= '1';
					msta_rst <= '1';
				end if;
			else
				arb_lost <= arb_lost;
				msta_rst <= '0';
			end if;
		end if;
      
    	end if;

  end process;

-- ************************  SCL_Generator Process ************************
-- This process generates SCL and SDA when in Master mode. It generates the START
-- and STOP conditions. If arbitration is lost, SCL will be generated until the
-- end of the byte transfer.

scl_generator_comb: process (scl_state, arb_lost, sm_stop, gen_stop, rep_start, 
					bus_busy, gen_start, master_slave, stop_scl_reg, 
					clk_cnt, bit_cnt, scl_in, state, sda_out,
					sda_out_reg, master_sda)

begin

-- state machine defaults
	scl_out <= '1';
	sda_out <= sda_out_reg;
	stop_scl <= stop_scl_reg;
	clk_cnt_en <= '0';
	clk_cnt_rst <= '1';
	next_scl_state <= scl_state;
	rsta_rst <= not(RESET_ACTIVE);

		case scl_state is 
	
			when SCL_IDLE =>
				sda_out <= '1';
				stop_scl <= '0';
				-- leave IDLE state when master, bus is idle, and gen_start
				if master_slave = '1' and bus_busy = '0' and gen_start = '1' then
					next_scl_state <= START;
				end if;

			when START =>
				-- generate start condition
				clk_cnt_en <= '1';
				clk_cnt_rst <= '0';
				sda_out <= '0';
				stop_scl <= '0';
				-- generate reset for repeat start bit if repeat start condition
				if rep_start = '1' then
					rsta_rst <= RESET_ACTIVE;
				end if;
				if clk_cnt = START_HOLD then
					next_scl_state <= SCL_LOW_EDGE;
				else
					next_scl_state <= START;
				end if;
			
			when SCL_LOW_EDGE =>
				clk_cnt_rst <= '1';
				scl_out <= '0';
				next_scl_state <= SCL_LOW;
				stop_scl <= '0';


			when SCL_LOW =>
				clk_cnt_en <= '1';
				clk_cnt_rst <= '0';
				scl_out <= '0';
				
				-- set SDA_OUT based on control signals
				if arb_lost = '1' then
					stop_scl <= '0';
				elsif ((sm_stop = '1' or gen_stop = '1') and
					(state /= ACK_DATA and state /= ACK_HEADER and state /= WAIT_ACK)) then
					sda_out <= '0';
					stop_scl <= '1';
				elsif rep_start = '1' then
					sda_out <= '1';
					stop_scl <= '0';
				elsif clk_cnt = DATA_HOLD then
					sda_out <= master_sda;
					stop_scl <= '0';
				else
					stop_scl <= '0';
				end if;
			
				-- determine next state
				if clk_cnt = LOW_CNT then

					if bit_cnt = CNT_DONE and arb_lost = '1' then
						next_scl_state <= SCL_IDLE;
					else
						next_scl_state <= SCL_HIGH_EDGE;
					end if;
				else
					next_scl_state <= SCL_LOW;
				end if;
				
			when SCL_HIGH_EDGE =>
				clk_cnt_rst <= '1';
				scl_out <= '1';
				if ((sm_stop = '1' or gen_stop = '1') and
				   (state /= ACK_DATA and state /= ACK_HEADER and state /= WAIT_ACK)) then
					stop_scl <= '1';
				else
					stop_scl <= '0';
				end if;

				
				-- this state sets SCL high
				-- stay in this state until SCL_IN = 1
				-- this will hold the counter in reset until all SCL drivers
				-- have released SCL to 1
				if scl_in = '0' then
					next_scl_state <= SCL_HIGH_EDGE;
				else
					next_scl_state <= SCL_HIGH;
				end if;

			when SCL_HIGH =>
				-- now all SCL drivers have set SCL to '1'
				-- begin count for high time
				clk_cnt_en <= '1';
				clk_cnt_rst <= '0';
				scl_out <= '1';	
				-- check to see if a repeated start or a stop needs to be 
				-- generated. If so, only hold SCL high for half of the high time
				if clk_cnt = HIGH_CNT_2 then
					
					if rep_start = '1' then
						next_scl_state <= START;
						clk_cnt_rst <= '1';
					elsif stop_scl_reg = '1' then
						next_scl_state <= STOP_WAIT;
						clk_cnt_rst <= '1';
					end if;
				elsif clk_cnt = HIGH_CNT then 
					next_scl_state <= SCL_LOW_EDGE;
				else
					next_scl_state <= SCL_HIGH;
				end if;

			when STOP_WAIT =>
				--this state gives the required free time between stop and start
				--conditions
				clk_cnt_en <='1';
				clk_cnt_rst <= '0';
				sda_out <= '1';
				stop_scl <= '0';
				if clk_cnt = TBUF then
					next_scl_state <= SCL_IDLE;
				else
					next_scl_state <= STOP_WAIT;
				end if;
		
		end case;
end process;

scl_generator_regs: process (sys_clk, reset)
begin
	if reset = RESET_ACTIVE then
		scl_state <= SCL_IDLE;
		sda_out_reg <= '1';
		scl_out_reg <= '1';
		stop_scl_reg <= '0';
	elsif sys_clk'event and sys_clk='1' then
		scl_state <= next_scl_state;
		sda_out_reg <= sda_out;
		scl_out_reg <= scl_out;
		stop_scl_reg <= stop_scl;
	end if;
end process;

-- ************************  Clock Counter Implementation ************************
-- The following code implements the counter that divides the sys_clock for 
-- creation of SCL. Control lines for this counter are set in SCL state machine

	CLKCNT : UPCNT4
	  port map( data      => cnt_zero,
		      cnt_en    => clk_cnt_en,
		      load      => clk_cnt_rst,
		      clr       => reset,  
		      clk       => sys_clk, 
		      qout      => clk_cnt );
		




-- ************************  Input Registers Process ************************
-- This process samples the incoming SDA and SCL with the system clock

input_regs: process(sys_clk,reset)
begin
	if reset = RESET_ACTIVE then
		sda_in <= '1';
		scl_in <= '1';
		msta_d1 <= '0';
		sda_out_reg_d1 <= '1';
	
	elsif sys_clk'event and sys_clk = '1' then

		-- the following if, then, else clauses are used
		-- because scl may equal 'H' or '1'
		if scl_i = '0' then
			scl_in <= '0';
		else	
			scl_in <= '1';
		end if;
		if sda_i = '0' then
			sda_in <= '0';
		else
			sda_in <= '1';
		end if;
		sda_out_reg_d1 <= sda_out_reg;
		msta_d1 <= msta;
	end if;
end process;

-- ************************  START/STOP Detect Process ************************
-- This process detects the start and stop conditions.
-- by using SDA as a clock.
start_det: process(sda_i, reset, state)
begin
	if reset = RESET_ACTIVE or state = HEADER then
		detect_start <= '0';
	elsif sda_i'event and sda_i = '0' then
		if scl_i /= '0' then 
			detect_start <= '1';
		else
			detect_start <= '0';
		end if;
	end if;
end process;

stop_det: process(sda_i, reset, detect_start)
begin
	if reset = RESET_ACTIVE or detect_start = '1' then
		detect_stop <= '0';
	elsif sda_i'event and sda_i /= '0' then
		if scl_i /= '0' then
			detect_stop <= '1';
		else
			detect_stop <= '0';
		end if;
	end if;
end process;

-- ************************  Bus Busy Process ************************
-- This process detects the start and stop conditions and sets the bus busy bit
-- It also describes a delayed version of the bus busy bit which is used to determine
-- MAL. MAL should be set if a start is detected while the bus is busy, however, the code below
-- sets bus_busy as soon as START is detected which would always set MAL. Therefore, a delayed
-- version of bus_busy is generated and used to determine MAL.

set_bus_busy: process(sys_clk,reset)
begin
	if reset = RESET_ACTIVE then
		bus_busy <= '0';
		bus_busy_d1 <= '0';

	elsif sys_clk'event and sys_clk = '1' then
		
		bus_busy_d1 <= bus_busy;

			if detect_start = '1' then	
				bus_busy <= '1';
			end if;
			if detect_stop = '1' then				
				bus_busy <= '0';
			end if;
		end if;

end process;

-- ************************   uP Control Bits Process ************************
-- This process detects the rising and falling edges of MSTA and sets signals to
-- control generation of start and stop conditions
-- This process also sets the master slave bit based on MSTA if and only if it is not
-- in the middle of a cycle, i.e. bus_busy = '0'
control_bits: process (sys_clk,reset)
begin
	if reset = RESET_ACTIVE then
		gen_start <= '0';
		gen_stop <= '0';
		master_slave <= '0';
	elsif sys_clk'event and sys_clk = '1' then
		if msta_d1 = '0' and msta = '1' then
			-- rising edge of MSTA - generate start condition
			gen_start <= '1';
		elsif detect_start = '1' then
			gen_start <= '0';
		end if;
		if arb_lost = '0' and msta_d1 = '1' and msta = '0' then
			-- falling edge of MSTA - generate stop condition only
			-- if arbitration has not been lost
			gen_stop <= '1';
		elsif detect_stop = '1' then
			gen_stop <= '0';
		end if;
		if bus_busy = '0' then
			master_slave <= msta;
		else
			master_slave <= master_slave;
		end if;
	end if;
end process;

rep_start <= rsta;	-- repeat start signal is RSTA control bit

-- ************************  uP Status Register Bits Processes ************************
-- The following processes and assignments set the bits of the MBUS status register MBSR
-- 
-- MCF - Data transferring bit
-- While one byte of data is being transferred, this bit is cleared. It is set by the falling edge
-- of the 9th clock of a byte transfer and is not cleared at reset
mcf_bit: process(scl_i, reset)
begin
	if reset = RESET_ACTIVE then 
		mcf <= '0';
	elsif scl_i'event and scl_i = '0' then 
		if bit_cnt = CNT_DONE then
			mcf <= '1';
		else
			mcf <= '0';
		end if;
	end if;
end process;

-- MAAS - Addressed As Slave Bit
-- When its own specific address (MADR) matches the I2C Address, this bit is set. The CPU is 
-- interrupted provided the MIEN is set. Then the CPU needs to check the SRW bit and set its
-- TX-RX mode accordingly. Writing to the MBCR clears this bit
maas_bit: process(sys_clk, reset)
begin
	if reset = RESET_ACTIVE  then
		maas <= '0';
	elsif sys_clk'event and sys_clk = '1' then
		if mbcr_wr = '1' then
			maas <= '0';
		elsif state = ACK_HEADER then
			maas <= addr_match;	-- the signal address match compares MADR with I2_ADDR
		else
			maas <= maas;
		end if;
	end if;
end process;

-- MBB - Bus Busy Bit
-- This bit indicates the status of the bus. This bit is set when a START signal is detected and 
-- cleared when a stop signal is detected. It is also cleared on reset. This bit is identical to 
-- the signal bus_busy set in the process set_bus_busy.
mbb <= bus_busy;

-- MAL - Arbitration Lost Bit
-- This bit is set when the arbitration procedure is lost. Arbitration is lost when:
--	1. SDA is sampled low when the master drives high during addr or data transmit cycle
--	2. SDA is sampled low when the master drives high during the acknowledge bit of a 
--		data receive cycle
--	3. A start cycle is attempted when the bus is busy
--	4. A repeated start is requested in slave mode
--	5. A stop condition is detected that the master did not request it.
-- This bit is cleared upon reset and when the software writes a '0' to it
-- Conditions 1 & 2 above simply result in SDA_IN not matching SDA_OUT while SCL is high. This
-- design will not generate a START condition while the bus is busy. When a START is detected, this hardware
-- will set the bus busy bit and gen_start stays set until detect_start asserts, therefore will have
-- to compare with a delayed version of bus_busy. Condition 3 is really just 
-- a check on the uP software control registers as is condition 4. Condition 5 is also taken care
-- of by the fact that SDA_IN does not equal SDA_OUT, however, this process also tests for if a stop
-- condition has been detected when this master did not generate it
mal_bit: process(sys_clk, reset)
begin
	if reset = RESET_ACTIVE  then
		mal <= '0';
	elsif sys_clk'event and sys_clk = '1' then
		if mal_bit_reset = '1' then 
			mal <= '0';
		elsif master_slave = '1' then
			if (arb_lost = '1') or
		   	   (bus_busy_d1 = '1' and gen_start = '1') or
		   	   (detect_stop = '1' and gen_stop = '0' and sm_stop = '0') then
					mal <= '1';
			end if;
		elsif rsta = '1' then
			-- repeated start requested while slave
				mal <= '1';
		end if;
	end if;
end process;

-- SRW - Slave Read/Write Bit
-- When MAAS is set, SRW indicates the value of the R/W command bit of the calling address sent 
-- from the master. This bit is only valid when a complete transfer has occurred and no other 
-- transfers have been initiated. The CPU uses this bit to set the slave transmit/receive mode.
-- This bit is reset by reset
srw_bit: process(sys_clk, reset)
begin
	if reset = RESET_ACTIVE then
		srw <= '0';
	elsif sys_clk'event and sys_clk = '1' then
		if state = ACK_HEADER then
			srw <= i2c_header(0);
		else
			srw <= srw;
		end if;
	end if;
end process;

-- MIF - M-bus Interrupt
-- The MIF bit is set when an interrupt is pending, which causes a processor interrupt
-- request provided MIEN is set. MIF is set when:
--	1. Byte transfer is complete (set at the falling edge of the 9th clock
--	2. MAAS is set when in slave receive mode
--	3. Arbitration is lost
-- This bit is cleared by reset and software writting a '0'to it
mif_bit: process(sys_clk, reset)
begin
	if reset = RESET_ACTIVE then
		mif <= '0';
	elsif sys_clk'event and sys_clk = '1' then
		if mif_bit_reset = '1' then 
			mif <= '0';
		elsif mal = '1' or mcf = '1' or 
			(maas = '1' and i2c_header(0) = '0' and master_slave = '0') then
			mif <= '1';
		end if;
	end if;
end process;

-- RXAK - Received Acknowledge
-- RXAK contains the value of SDA during the acknowledge bit of a bus cycle. If =0, then 
-- an acknowledge signal has been received, if 1, then no acknowledge has been received.
-- This bit is not cleared at reset. The CPLD will reset this bit upon power-up
rxak_bit: process(scl_i)
begin
	if scl_i'event and scl_i = '0' then
		if state = ACK_HEADER or state = ACK_DATA or state = WAIT_ACK then
			rxak <= sda_in;
		end if;
	end if;
end process;

-- ************************  uP Data Register ************************
-- Register for uP interface MBDR_I2C
mbdr_i2c_proc: process(sys_clk, reset)
begin	
	if reset = RESET_ACTIVE then
		mbdr_i2c <= (others => '0');
	elsif sys_clk'event and sys_clk = '1' then
		if (state = ACK_DATA) or (state = WAIT_ACK) then
			mbdr_i2c <= shift_reg ;
		else
			mbdr_i2c <= mbdr_i2c;
		end if;
	end if;
end process;

-- ************************  uP Address Register ************************
	addr_match <= '1' when i2c_header(7 downto 1) = madr(7 downto 1) 
		          else '0';

-- ************************  Main State Machine Process ************************
-- The following process contains the main I2C state machine for both master and slave
-- modes. This state machine is clocked on the falling edge of SCL. DETECT_STOP must stay as
-- an asynchronous reset because once STOP has been generated, SCL clock stops.
state_machine: process (scl_i, reset, detect_stop)

begin

	if reset = RESET_ACTIVE or detect_stop = '1' then
		state <= IDLE;
		sm_stop <= '0';
	elsif scl_i'event and scl_i = '0'  then

		case state is
	
			------------- IDLE STATE -------------
			when IDLE => 
				if detect_start = '1' then
					state <= HEADER;
				end if;

			------------- HEADER STATE -------------	
			when HEADER =>
				if bit_cnt = CNT_DONE then
					state <= ACK_HEADER;
				end if;

			------------- ACK_HEADER STATE -------------
			when ACK_HEADER =>
				if arb_lost = '1' then
					state <= IDLE;
				elsif sda_in = '0' then
					-- ack has been received, check for master/slave
					if master_slave = '1' then
						-- master, so check mtx bit for direction
						if mtx = '0' then
							-- receive mode
							state <= RCV_DATA;
						else
							--transmit mode
							state <= XMIT_DATA;
						end if;
					else
						if addr_match = '1' then
						--if maas = '1' then
							-- addressed slave, so check I2C_HEADER(0) for direction
							if i2c_header(0) = '0' then
								-- receive mode
								state <= RCV_DATA;
							else
								-- transmit mode
								state <= XMIT_DATA;
							end if;
						else
							-- not addressed, go back to IDLE
							state <= IDLE;
						end if;
					end if;
				else
					-- no ack received, stop
					state <= IDLE;
					if master_slave = '1' then
						sm_stop <= '1';
					end if;
	
				end if;

		    ------------- RCV_DATA State --------------
		    when RCV_DATA =>
		      
		      -- check for repeated start
		      if (detect_start = '1') then
			   state <= HEADER;
		      elsif bit_cnt = CNT_DONE then
			   
                           -- Send an acknowledge
			   state <= ACK_DATA;		      
		      
		      end if;


		    ------------ XMIT_DATA State --------------
	            when XMIT_DATA =>

		      -- check for repeated start
		      if (detect_start = '1') then
			   state <= HEADER;

		      elsif bit_cnt = CNT_DONE then

			   -- Wait for acknowledge
			   state <= WAIT_ACK;

		      end if;


		    ------------- ACK_DATA State --------------
	            when ACK_DATA =>

		         state <= RCV_DATA;

		
                    ------------- WAIT_ACK State --------------
		    when WAIT_ACK =>
			if arb_lost = '1' then
					state <= IDLE;
		      elsif (sda_i = '0') then
			      state <= XMIT_DATA;
			 else
				-- no ack received, generate a stop and return
				-- to IDLE state
				if master_slave = '1' then 
					sm_stop <= '1';
				end if;
			      state <= IDLE;
			 end if;
		
		  end case;
		
		end if;
		
	end process;
	
-- ************************  Slave and Master SDA ************************
slv_mas_sda: process(reset, sys_clk)
begin
	if reset = RESET_ACTIVE then
		master_sda <= '1';
		slave_sda <= '1';
	elsif sys_clk'event and sys_clk = '1' then
		if state = HEADER or state = XMIT_DATA then
			master_sda <= shift_out;
		elsif state = ACK_DATA then
			master_sda <= TXAK;
		else
			master_sda <= '1';
		end if;

		-- For the slave SDA, address match (MAAS) only has to be checked when 
		-- state is ACK_HEADER because state
		-- machine will never get to state XMIT_DATA or ACK_DATA
		-- unless address match is a one. 

		if (maas = '1' and state = ACK_HEADER) or
		   (state = ACK_DATA) then
			slave_sda <= TXAK;
		elsif (state = XMIT_DATA) then
			slave_sda <= shift_out;
		else
			slave_sda <= '1';
		end if;
	end if;
end process; 


-- ************************  I2C Data Shift Register ************************
	I2CDATA_REG: SHIFT8
	  port map (  		      
		      clk       => scl_not,
		      clr       => reset, 
		      data_ld   => shift_reg_ld,
		      data_in   => mbdr_micro,
		      shift_in  => sda_in,
		      shift_en  => shift_reg_en,
		      shift_out => shift_out,
		      data_out  => shift_reg );

i2cdata_reg_ctrl: process(sys_clk, reset)

begin
	if reset = RESET_ACTIVE then
		shift_reg_en <= '0';
		shift_reg_ld <= '0';
	elsif sys_clk'event and sys_clk = '1' then

		if ((master_slave = '1' and state = HEADER)
		    or (state = RCV_DATA) or (state = XMIT_DATA)) then		
			shift_reg_en <= '1';
		else 
			shift_reg_en <= '0';
		end if;

		if ((master_slave = '1' and state = IDLE) or (state = WAIT_ACK)
	         or (state = ACK_HEADER and i2c_header(0) = '1' and master_slave = '0')
		 or (state = ACK_HEADER and mtx = '1' and master_slave = '1')
		 or (detect_start = '1')  ) then
				shift_reg_ld <= '1';
		else 
				shift_reg_ld <= '0';
		end if;
	end if;
end process;
	

	
-- ************************  I2C Header Shift Register ************************
	-- Header/Address Shift Register
	I2CHEADER_REG: SHIFT8
	  port map (  		      
		      clk       => scl_not,
		      clr       => reset,  
		      data_ld   => i2c_header_ld,
		      data_in   => reg_clr,
		      shift_in  => sda_in,
		      shift_en  => i2c_header_en,
		      shift_out => i2c_shiftout,
		      data_out  => i2c_header ); 

i2cheader_reg_ctrl: process(sys_clk, reset)

begin
	if reset = RESET_ACTIVE then
		i2c_header_en <= '0';
	elsif sys_clk'event and sys_clk = '1' then
		if (detect_start = '1') or (state = HEADER) then
			i2c_header_en <= '1';
		else 
			i2c_header_en <= '0';
		end if;
	end if;
end process;
	
	i2c_header_ld <= '0';

-- ************************  Bit Counter  ************************
	BITCNT : UPCNT4
	  port map(   data      => cnt_start,
		      cnt_en    => bit_cnt_en,
		      load      => bit_cnt_ld,
		      clr       => reset,  
		      clk       => scl_not, 
		      qout      => bit_cnt );

	-- Counter control lines
	bit_cnt_en <= '1' when (state = HEADER) or (state = RCV_DATA) 
		                or (state = XMIT_DATA) else '0';

	bit_cnt_ld <= '1' when (state = IDLE) or (state = ACK_HEADER) 
		                or (state = ACK_DATA)
		                or (state = WAIT_ACK) 
		                or (detect_start = '1') else '0';

		

end behave;
