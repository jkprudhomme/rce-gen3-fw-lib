-- File:     uC_interface.vhd
-- 
-- Author:   Jennifer Jenkins
--	     Philips Semiconductor
-- Purpose:  Description of an interface with a ucontroller/uprocessor 
--	     (i.e. Motorola 68000) parallel bus to internal module registers
--           to be used for control of an I2C bus as master/slave with
--           transmit and receive modes.
--
--
-- Created:  4-17-99 JLJ
-- Revised:  4-19-99 JLJ
-- Revised:  4-20-99 JLJ
-- Revised:  5-3-99 JLJ
-- Revised:  5-5-99 JLJ
-- Revised:  5-6-99 JLJ
-- Revised:  6-3-99 ALS
-- Revised:  6-9-99 ALS
-- Revised:  6-29-00 ALS
-- Revised:  2-21-02 JRH
-- Revised:  2-22-02 JRH

library IEEE;
use IEEE.std_logic_1164.all;


entity uC_interface is
	generic (UC_ADDRESS : std_logic_vector(15 downto 0):= "0000000000000000"  );
	port(
		-- 68000 parallel bus interface
		clk		: in STD_LOGIC;
		reset 	: in STD_LOGIC;	 
		
		addr_bus	: in STD_LOGIC_VECTOR (23 downto 0);
		data_bus	: inout STD_LOGIC_VECTOR (7 downto 0);
		as 		: in STD_LOGIC; 	-- Address strobe, active low	
		ds 		: in STD_LOGIC; 	-- Data strobe, active low
		
		-- Directional pins
		r_w		: in STD_LOGIC;	-- Active low write, 
							--  active high read
		dtack 	: out STD_LOGIC;	-- Data transfer acknowledge 
		irq		: out STD_LOGIC;	-- Interrupt request
	
		-- Internal I2C Bus Registers
		-- Address Register (Contains slave address)
		madr	      : inout STD_LOGIC_VECTOR(7 downto 0);
   
                -- Control Register		
		men             : inout STD_LOGIC;  -- I2C Enable bit
		mien            : inout STD_LOGIC;	-- interrupt enable
		msta            : inout STD_LOGIC;	-- Master/Slave bit
		mtx             : inout STD_LOGIC;	-- Master read/write
		txak            : inout STD_LOGIC;	-- acknowledge bit
		rsta            : inout STD_LOGIC;	-- repeated start
	
		mbcr_wr         : out STD_LOGIC;	-- indicates that the control reg has been written
		rsta_rst	: in  STD_LOGIC;	-- resets the repeated start bit in the 
							-- control register
                -- Status Register
		mcf             : in STD_LOGIC;	-- end of data transfer
		maas            : in STD_LOGIC;	-- addressed as slave
		mbb             : in STD_LOGIC;	-- bus busy
		mal             : in STD_LOGIC;	-- arbitration lost
		srw             : in STD_LOGIC;	-- slave read/write
		mif             : in STD_LOGIC;	-- interrupt pending
		rxak            : in STD_LOGIC;	-- received acknowledge

		mal_bit_reset   : out STD_LOGIC;	-- indicates that the MAL bit should be reset
		mif_bit_reset   : out STD_LOGIC;	-- indicates that the MIF bit should be reset
		msta_rst	    : in STD_LOGIC;	-- resets the MSTA bit if arbitration is lost
		

                -- Data Register 
		mbdr_micro      : inout STD_LOGIC_VECTOR (7 downto 0);
		mbdr_i2c        : in STD_LOGIC_VECTOR (7 downto 0);

		mbdr_read       : out STD_LOGIC
		
		);
		

end uC_interface;




architecture BEHAVIOUR of uC_interface is

-- Constant Declarations
constant RESET_ACTIVE : STD_LOGIC := '0';

-- Base Address for I2C Module (addr_bus[23:8])
constant MBASE	: STD_LOGIC_VECTOR(15 downto 0) := UC_ADDRESS;

-- Register Addresses (5 Total):
-- Address Register (MBASE + 8Dh)
constant MADR_ADDR 	: STD_LOGIC_VECTOR(7 downto 0) := "10001101";


-- Control Register (MBASE + 91h)
constant MBCR_ADDR 	: STD_LOGIC_VECTOR(7 downto 0) := "10010001";

-- Status Register (MBASE + 93h)
constant MBSR_ADDR 	: STD_LOGIC_VECTOR(7 downto 0) := "10010011";

-- Data I/O Register (MBASE + 95h)
constant MBDR_ADDR 	: STD_LOGIC_VECTOR(7 downto 0) := "10010101";

-- State Machine Signals
type STATE_TYPE is (IDLE, ADDR, DATA_TRS, ASSERT_DTACK);

-- Signal Declarations

-- Internal handshaking lines for microprocessor
signal as_int 	  : STD_LOGIC;
signal as_int_d1 	  : STD_LOGIC;
signal ds_int 	  : STD_LOGIC;
signal dtack_int,dtack_com,dtack_oe  : STD_LOGIC;
signal data_out	: std_logic_vector(7 downto 0); -- holds the data to be output on the data bus
signal data_in	: std_logic_vector(7 downto 0); -- holds the data to be input to the chip


-- State signals for target state machine
signal prs_state, next_state : STATE_TYPE;					

-- Address match
signal address_match	: std_logic;

-- Register Enable Lines
signal addr_en 		: std_logic;	-- i2c address register is selected
signal cntrl_en		: std_logic;	-- control register is selected
signal stat_en		: std_logic;	-- status register is selected
signal data_en		: std_logic;	-- data register is selected			



begin

        -- Interrupt signal to uProcessor
        irq <= '0' when (mien = '1') and (mif = '1') else 'Z';
	
	-- DTACK signal to uProcession
--	dtack <= dtack_int when (dtack_oe = '1') else 'Z';
	dtack <= dtack_int when (dtack_oe = '1') else '1';

	-- Bi-directional Data bus
	data_bus <= data_out when (r_w = '1' and dtack_oe = '1') else (others => 'Z');
	data_in <= data_bus when r_w = '0' else (others => '0');

	-- Process:   SYNCH_INPUTS
	-- Function:  To synchronize uProcessor asynchronous control lines to 
	--	      internal clock
	SYNCH_INPUTS: process(reset, clk)
	begin
		if reset = RESET_ACTIVE then
			as_int <= '1';
			as_int_d1 <= '1';
			ds_int <= '1';
			address_match <= '0';
			
		elsif clk'event and clk = '1' then
			as_int <= as;
			as_int_d1 <= as_int;
			ds_int <= ds;
			
			if (as = '0' and as_int_d1 = '1' and addr_bus(23 downto 8) = MBASE) then
				address_match <= '1';
			else
				address_match <= '0';
			end if;
	  
			
		end if;
	
	end process;

	
	-- Process:  SEQUENTIAL
	-- Function: Synchronize target state machine
	SEQUENTIAL: process (clk, reset)
	begin
		if reset = RESET_ACTIVE then
			prs_state <= IDLE;
			dtack_int <= '1';
			
		elsif clk'event and clk = '1' then
			prs_state <= next_state;
			dtack_int <= dtack_com;
			
		end if;
	
	end process;
	
	
	
	-- Process:   COMBINATIONAL
	-- Function:  Contains the synchronous target state machine to mediate 
	--	      the handshaking taking place with the uProc parallel bus
	COMBINATIONAL: process (prs_state, as, as_int_d1, ds_int, address_match)
	
	begin
	
	next_state <= prs_state;
	dtack_com <= '1';
	dtack_oe <= '0';
	
	
	case prs_state is
	
		------------- IDLE State (00) -------------
		when IDLE =>

		        -- Wait for falling edge of as
			if as_int_d1 = '1' and as = '0' then
				-- falling edge of AS
				next_state <= ADDR;
			end if;

		
		------------ ADDR State (01) --------------
		when ADDR =>
			
			-- Check that this module is being address
			if address_match = '1' then
		        -- Wait for ds to be asserted, active low
		        	if ds_int = '0' then
			        next_state <= DATA_TRS;
			  	else
				  next_state <= ADDR;
			  	end if;
			else
				-- this module is not being addressed
				  next_state <= IDLE;
			end if;
	
			
		---------- DATA_TRS State (10) ------------
		when DATA_TRS =>

		        -- Read or write from enabled register
		        next_state <= ASSERT_DTACK;
			  dtack_oe <= '1';
			  			
		-------- ASSERT_DTACK State (11) ----------
		when ASSERT_DTACK =>
		        
		        -- Assert dtack to uProcessor
		        dtack_com <= '0';
			  dtack_oe <= '1';
			  
			
			-- Wait for rising edge of as and ds
			if (as_int_d1 = '0') and (ds_int = '0') then
			  next_state <= ASSERT_DTACK;
			elsif (as_int_d1 = '1') and (ds_int = '1') then
			  next_state <= IDLE;
			end if;
		
	         end case;
		
	end process;


	-- Process:  ADDR_DECODE
	-- Function:  Mapping address from uProc to enable appropriate register
	ADDR_DECODE: process (reset, clk)
	begin
	        if reset = RESET_ACTIVE then
		  	addr_en <= '0';
			cntrl_en <= '0';
			stat_en <= '0';
			data_en <= '0';
		  
		-- Synchronize with rising edge of clock
		elsif clk'event and (clk = '1') then

		  -- I2C bus is specified by uProc and address is stable
		  if address_match = '1' then
		  
		    -- Check appropriate register address
		    case addr_bus(7 downto 0) is
		      
		      when MADR_ADDR =>  addr_en <= '1';
					   	cntrl_en <= '0';
					   	stat_en <= '0';
					   	data_en <= '0';

		      when MBCR_ADDR =>  cntrl_en <= '1';
						addr_en <= '0';
					   	stat_en <= '0';
					   	data_en <= '0';

		      when MBSR_ADDR =>  stat_en <= '1';
						addr_en <= '0';
					   	cntrl_en <= '0';
					   	data_en <= '0';

		      when MBDR_ADDR =>  data_en <= '1';
						addr_en <= '0';
					   	cntrl_en <= '0';
					   	stat_en <= '0';

		      when others => addr_en <= '0';
					   cntrl_en <= '0';
					   stat_en <= '0';
					   data_en <= '0';
				     
		    end case;
		  else
			-- this device is not addressed
			addr_en <= '0';
			cntrl_en <= '0';
			stat_en <= '0';
			data_en <= '0';
	
		  end if;
		  
		end if;
		
	end process;
	
	
	-- Process:  DATA_DIR
	-- Function: Read from or write to appropriate registers specified 
	--	     by uProc address
	DATA_DIR: process(clk, reset, msta_rst)
	begin

		-- Initialize all internal registers upon reset
		if reset = RESET_ACTIVE then
		
			-- Address Register
			madr <= (others => '0');
			
			-- Control Register
			men  <= '0';
			mien <= '0';
			msta <= '0';
			mtx  <= '0';
			txak <= '0';
			rsta <= '0';

			mbcr_wr <= '0';
			
			-- Status Register
			mal_bit_reset  <= '0';
			mif_bit_reset  <= '0';
			
			-- Data Register
			mbdr_micro <= (others => '0');
			mbdr_read <= '0';

			-- Initialize data bus
			data_out <= (others => '0');
	
		-- Check for rising edge of clock
		elsif clk'event and (clk = '1') then

		  if (prs_state = IDLE) then
			-- reset signals that indicate read from mbdr or write to mbcr
			mbcr_wr <= '0';
			mbdr_read <= '0';

		  -- Check for data transfer state
		  elsif (prs_state = DATA_TRS) then
		
		    	-- Address register
			if addr_en = '1' then						              
			  if r_w = '0' then
			
				-- uC write
				madr <= data_in(7 downto 1) & '0';
			    
			  else    
                         -- uC read
			       data_out <= madr;
			  
			  end if;
			end if;

		     	-- Control Register
		    	if cntrl_en = '1' then
			  if r_w = '0' then
				-- uC write		       
			       mbcr_wr <= '1';
			       men  <= data_in(7);
			       mien <= data_in(6);
			       msta <= data_in(5);
			       mtx  <= data_in(4);
			       txak <= data_in(3);
			       rsta <= data_in(2);
		       
			  else
				-- uC read
			       mbcr_wr <= '0';
			  	 data_out <= men & mien & msta & mtx & 
				       txak & rsta & "0" & "0";
			  
			  end if;
			else
				mbcr_wr <= '0';
			end if;

		    	-- Status Register
		    	if stat_en = '1' then
			  if r_w = '0' then
			       
                          -- uC write to these bits generates a reset
			       if data_in(4) = '0' then
				    mal_bit_reset <= '1';
			       end if;

			       if data_in(2) = '0' then
				    mif_bit_reset <= '1';
			       end if;
			  else
				-- uC read
			  	data_out <= mcf & maas & mbb & mal & 
				      "0" & srw & mif & rxak;
			       mal_bit_reset <= '0';
			       mif_bit_reset <= '0';

			  end if;
			end if;	    		

		    	-- Data Register
		    	if data_en = '1' then
		    		if r_w = '0' then
				    -- uC write
				     mbdr_read <= '0';
				     mbdr_micro <= data_in;
		    		else
				     -- uC Read
				     mbdr_read <= '1';
				     data_out <= mbdr_i2c;
		    		end if;
			else
				mbdr_read <= '0';
			end if;
			
		  end if;
		  
		  -- if arbitration is lost, the I2C Control component will generate a reset for the
		  -- MSTA bit to force the design to slave mode 
		  -- will do this reset synchronously

		  if msta_rst = '1' then
			msta <= '0';
		  end if;

		  if rsta_rst = RESET_ACTIVE then
			rsta <= '0';
		  end if;

		end if;
	
	end process;
	


end BEHAVIOUR;
  
