library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

-- get clocks from clock generator, create rst 

entity clk_reset is
  port (
    clk0_in         : in  std_logic;
    clk90_in	     : in  std_logic;
    clk200_in       : in  std_logic;
    clkdiv0_in      : in  std_logic;
    sys_rst_n       : in  std_logic;
    idelay_ctrl_rdy : in  std_logic;
    dcm_lock        : in  std_logic;
    clk0            : out std_logic;
    clk90           : out std_logic;
    clk200          : out std_logic;
    clkdiv0         : out std_logic;
    rst0            : out std_logic;
    rst90           : out std_logic;
    rst270          : out std_logic;
    rst200          : out std_logic;
    rstdiv0         : out std_logic
    );
end entity clk_reset;

architecture syn of clk_reset is

  -- # of clock cycles to delay deassertion of reset. Needs to be a fairly
  -- high number not so much for metastability protection, but to give time
  -- for reset (i.e. stable clock cycles) to propagate through all state
  -- machines and to all control signals (i.e. not all control signals have
  -- resets, instead they rely on base state logic being reset, and the effect
  -- of that reset propagating through the logic). Need this because we may not
  -- be getting stable clock cycles while reset asserted (i.e. since reset
  -- depends on DCM lock status)
  constant RST_SYNC_NUM  : integer := 25;

  signal rst0_sync_r    : std_logic_vector(RST_SYNC_NUM-1 downto 0);
  signal rst200_sync_r  : std_logic_vector(RST_SYNC_NUM-1 downto 0);
  signal rst90_sync_r   : std_logic_vector(RST_SYNC_NUM-1 downto 0);
  signal rst270_sync_r   : std_logic_vector(RST_SYNC_NUM-1 downto 0);
  signal rstdiv0_sync_r : std_logic_vector((RST_SYNC_NUM/2)-1 downto 0);
  signal rst_tmp        : std_logic;

  attribute max_fanout : string;
  attribute syn_maxfan : integer;
  attribute max_fanout of rst0_sync_r    : signal is "10";
  attribute syn_maxfan of rst0_sync_r    : signal is 10;
  attribute max_fanout of rst200_sync_r  : signal is "10";
  attribute syn_maxfan of rst200_sync_r  : signal is 10;  
  attribute max_fanout of rst90_sync_r   : signal is "10";
  attribute syn_maxfan of rst90_sync_r   : signal is 10;
  attribute max_fanout of rst270_sync_r  : signal is "10";
  attribute syn_maxfan of rst270_sync_r  : signal is 10;
  attribute max_fanout of rstdiv0_sync_r : signal is "10";
  attribute syn_maxfan of rstdiv0_sync_r : signal is 10;    

begin
  
 
  clk0    <= clk0_in;
  clk90   <= clk90_in;
  clk200  <= clk200_in;
  clkdiv0 <= clkdiv0_in;
  
 
  --***************************************************************************
  -- Reset synchronization
  -- NOTES:
  --   1. shut down the whole operation if the DCM hasn't yet locked (and by
  --      inference, this means that external SYS_RST_IN has been asserted -
  --      DCM deasserts DCM_LOCK as soon as SYS_RST_IN asserted)
  --   2. In the case of all resets except rst200, also assert reset if the
  --      IDELAY master controller is not yet ready
  --   3. asynchronously assert reset. This was we can assert reset even if
  --      there is no clock (needed for things like 3-stating output buffers).
  --      reset deassertion is synchronous.
  --***************************************************************************
  
  rst_tmp <= not(sys_rst_n) or not(idelay_ctrl_rdy);
  
  process (clk0_in, rst_tmp)
  begin
    if (rst_tmp = '1') then
      rst0_sync_r <= (others => '1');
    elsif (rising_edge(clk0_in)) then
      -- logical left shift by one (pads with 0)    
      rst0_sync_r <= rst0_sync_r(RST_SYNC_NUM-2 downto 0) & '0';
    end if;
  end process;

  process (clkdiv0_in, rst_tmp)
  begin
    if (rst_tmp = '1') then
      rstdiv0_sync_r <= (others => '1');
    elsif (rising_edge(clkdiv0_in)) then
      -- logical left shift by one (pads with 0)    
      rstdiv0_sync_r <= rstdiv0_sync_r((RST_SYNC_NUM/2)-2 downto 0) & '0';
    end if;
  end process;  

  process (clk90_in, rst_tmp)
  begin
    if (rst_tmp = '1') then
      rst90_sync_r <= (others => '1');
    elsif (rising_edge(clk90_in)) then      
      rst90_sync_r <= rst90_sync_r(RST_SYNC_NUM-2 downto 0) & '0';
    end if;
  end process;
  
  process (clk90_in, rst_tmp)
  begin
    if (rst_tmp = '1') then
      rst270_sync_r <= (others => '1');
    elsif (falling_edge(clk90_in)) then      
      rst270_sync_r <= rst270_sync_r(RST_SYNC_NUM-2 downto 0) & '0';
    end if;
  end process;

  -- make sure CLK200 doesn't depend on IDELAY_CTRL_RDY, else chicken n' egg
  process (clk200_in, dcm_lock)
  begin
    if ((not(dcm_lock)) = '1') then
      rst200_sync_r <= (others => '1');
    elsif (rising_edge(clk200_in)) then      
      rst200_sync_r <= rst200_sync_r(RST_SYNC_NUM-2 downto 0) & '0';
    end if;
  end process;
  
  rst0    <= rst0_sync_r(RST_SYNC_NUM-1);
  rst90   <= rst90_sync_r(RST_SYNC_NUM-1);
  rst270  <= rst270_sync_r(RST_SYNC_NUM-1);
  rst200  <= rst200_sync_r(RST_SYNC_NUM-1);
  rstdiv0 <= rstdiv0_sync_r((RST_SYNC_NUM/2)-1);
  
end architecture syn;


