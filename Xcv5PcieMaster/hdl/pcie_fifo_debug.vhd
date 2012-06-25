-------------------------------------------------------------------------------
-- pcie_debug.vhd
--
--  Implement PCIe interface debugging
--
--  Write to a FIFO and transmit queue to PCIe
--  Read from PCIe and queue to a FIFO
--
--  DCR registers:
--  0  CSR  - status of FIFO (R/W)
--  1  Data - Read from input FIFO / Write to output FIFO
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity pcie_debug is
  generic (
    BASEADDR : std_logic_vector(9 downto 0) := "1000000000");
  port (
    rst       : in  std_logic;
    -- PIC Interface (packet DMA)
    -- DCR Interface (registers)
    dcr_clk   : in  std_logic;
    dcr_wr    : in  std_logic;
    dcr_rd    : in  std_logic;
    dcr_addr  : in  std_logic_vector(9 downto 0);
    dcr_dbusi : in  std_logic_vector(31 downto 0);
    dcr_ack   : out std_logic;
    dcr_dbuso : out std_logic_vector(31 downto 0);
    -- Fulcrum Interface
    pcie_clk    : in  std_logic;
    pcie_rst_n  : out std_logic;
    pcie_tx_p   : out std_logic;
    pcie_tx_n   : out std_logic;
    pcie_rx_p   : in  std_logic;
    pcie_rx_n   : in  std_logic;
    --
    debug       : out std_logic_vector(31 downto 0)
    );
end pcie_debug;

architecture IMP of pcie_debug is

--  component endpoint_blk_plus_v1_15  port (
  component endpoint_blk_plus_v1_14  port (
    pci_exp_rxn : in std_logic_vector((1 - 1) downto 0);
    pci_exp_rxp : in std_logic_vector((1 - 1) downto 0);
    pci_exp_txn : out std_logic_vector((1 - 1) downto 0);
    pci_exp_txp : out std_logic_vector((1 - 1) downto 0);

    sys_clk : in STD_LOGIC;
    sys_reset_n : in STD_LOGIC;
    refclkout         : out std_logic;


    trn_clk : out STD_LOGIC; 
    trn_reset_n : out STD_LOGIC; 
    trn_lnk_up_n : out STD_LOGIC; 

    trn_td : in STD_LOGIC_VECTOR((64 - 1) downto 0);
    trn_trem_n: in STD_LOGIC_VECTOR (7 downto 0);
    trn_tsof_n : in STD_LOGIC;
    trn_teof_n : in STD_LOGIC;
    trn_tsrc_dsc_n : in STD_LOGIC;
    trn_tsrc_rdy_n : in STD_LOGIC;
    trn_tdst_dsc_n : out STD_LOGIC;
    trn_tdst_rdy_n : out STD_LOGIC;
    trn_terrfwd_n : in STD_LOGIC ;
    trn_tbuf_av : out STD_LOGIC_VECTOR (( 4 -1 ) downto 0 );

    trn_rd : out STD_LOGIC_VECTOR((64 - 1) downto 0);
    trn_rrem_n: out STD_LOGIC_VECTOR (7 downto 0);
    trn_rsof_n : out STD_LOGIC;
    trn_reof_n : out STD_LOGIC; 
    trn_rsrc_dsc_n : out STD_LOGIC; 
    trn_rsrc_rdy_n : out STD_LOGIC; 
    trn_rbar_hit_n : out STD_LOGIC_VECTOR ( 6 downto 0 );
    trn_rdst_rdy_n : in STD_LOGIC; 
    trn_rerrfwd_n : out STD_LOGIC; 
    trn_rnp_ok_n : in STD_LOGIC; 
    trn_rfc_npd_av : out STD_LOGIC_VECTOR ( 11 downto 0 ); 
    trn_rfc_nph_av : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    trn_rfc_pd_av : out STD_LOGIC_VECTOR ( 11 downto 0 ); 
    trn_rfc_ph_av : out STD_LOGIC_VECTOR ( 7 downto 0 );
    trn_rcpl_streaming_n      : in STD_LOGIC;

    cfg_do : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_rd_wr_done_n : out STD_LOGIC; 
    cfg_di : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
    cfg_byte_en_n : in STD_LOGIC_VECTOR ( 3 downto 0 ); 
    cfg_dwaddr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    cfg_wr_en_n : in STD_LOGIC;
    cfg_rd_en_n : in STD_LOGIC; 

    cfg_err_cor_n : in STD_LOGIC; 
    cfg_err_cpl_abort_n : in STD_LOGIC; 
    cfg_err_cpl_timeout_n : in STD_LOGIC; 
    cfg_err_cpl_unexpect_n : in STD_LOGIC; 
    cfg_err_ecrc_n : in STD_LOGIC; 
    cfg_err_posted_n : in STD_LOGIC; 
    cfg_err_tlp_cpl_header : in STD_LOGIC_VECTOR ( 47 downto 0 ); 
    cfg_err_ur_n : in STD_LOGIC;
    cfg_err_cpl_rdy_n : out STD_LOGIC;
    cfg_err_locked_n : in STD_LOGIC; 
    cfg_interrupt_n : in STD_LOGIC;
    cfg_interrupt_rdy_n : out STD_LOGIC;
    cfg_pm_wake_n : in STD_LOGIC;
    cfg_pcie_link_state_n : out STD_LOGIC_VECTOR ( 2 downto 0 ); 
    cfg_to_turnoff_n : out STD_LOGIC;
    cfg_interrupt_assert_n : in  STD_LOGIC;
    cfg_interrupt_di : in  STD_LOGIC_VECTOR(7 downto 0);
    cfg_interrupt_do : out STD_LOGIC_VECTOR(7 downto 0);
    cfg_interrupt_mmenable : out STD_LOGIC_VECTOR(2 downto 0);
    cfg_interrupt_msienable: out STD_LOGIC;

    cfg_trn_pending_n : in STD_LOGIC;
    cfg_bus_number : out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_device_number : out STD_LOGIC_VECTOR ( 4 downto 0 );
    cfg_function_number : out STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_status : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_command : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_dstatus : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_dcommand : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_lstatus : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_lcommand : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_dsn: in STD_LOGIC_VECTOR (63 downto 0 );

    fast_train_simulation_only : in STD_LOGIC;

    gt_loopback : in STD_LOGIC_VECTOR ( 2 downto 0 );
    gt_debug : out STD_LOGIC_VECTOR ( 43 downto 0 )

    );

  end component;


  -- ICON
  component v5_icon
    PORT (
      CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
      CONTROL1 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));
  end component;

  -- ILA
  component v5_ila
    PORT (
      CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
      CLK : IN STD_LOGIC;
      DATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      TRIG0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0));
  end component;

  -- VIO
  component v5_vio
    PORT (
      CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
      CLK : IN STD_LOGIC;
      SYNC_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      SYNC_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
  end component;

  -- Chipscope attributes
  attribute syn_black_box : boolean;
  attribute syn_noprune   : boolean;
  attribute syn_black_box of v5_icon : component is TRUE;
  attribute syn_noprune   of v5_icon : component is TRUE;
  attribute syn_black_box of v5_ila  : component is TRUE;
  attribute syn_noprune   of v5_ila  : component is TRUE;
  attribute syn_black_box of v5_vio  : component is TRUE;
  attribute syn_noprune   of v5_vio  : component is TRUE;

  signal csControl0       : std_logic_vector(35 downto 0);
  signal csControl1       : std_logic_vector(35 downto 0);
  signal csData           : std_logic_vector(63 downto 0);
  signal csCntrl          : std_logic_vector( 7 downto 0);
  signal csStat           : std_logic_vector( 7 downto 0);
  
  type tx_state_type is (TX_IDLE, TX_RUNNING);
  signal tx_state, tx_state_next : tx_state_type;
  signal tx_enable, tx_enable_next : std_logic;
  signal tx_busy  , tx_busy_next   : std_logic;
  signal trn_clk, trn_rst_n       : std_logic;
  signal trn_td                   : std_logic_vector( 63 downto 0);
  signal trn_tsof_n    , trn_tsof_n_next           : std_logic;
  signal trn_teof_n    , trn_teof_n_next           : std_logic;
  signal trn_tsrc_rdy_n           : std_logic;
  signal trn_tsrc_dsc_n           : std_logic;
  signal trn_tdst_rdy_n           : std_logic;
  signal trn_tdst_dsc_n           : std_logic;
  signal trn_done      , trn_done_next             : std_logic;
  signal trn_lnk_up_n : std_logic;
  signal trn_rerrfwd_n : std_logic;
  signal cfg_pcie_link_state_n : std_logic_vector(2 downto 0);
  
  type rx_state_type is (RX_IDLE, RX_RUNNING);
  signal rx_state, rx_state_next : rx_state_type;
  signal trn_rd         : std_logic_vector(63 downto 0);
  signal trn_rsof_n     : std_logic;
  signal trn_reof_n     : std_logic;
  signal trn_rsrc_rdy_n : std_logic;
  signal trn_rsrc_dsc_n : std_logic;
  signal trn_rbar_hit_n : std_logic_vector(6 downto 0);
  signal trn_rdst_rdy_n : std_logic;

  signal gt_loopback, gt_loopback_next : std_logic_vector(2 downto 0);
  signal gt_debug, gt_debug_r : std_logic_vector(43 downto 0);
  
  signal cfg_bus_number           : std_logic_vector(7 downto 0);
  signal cfg_device_number        : std_logic_vector(4 downto 0);
  signal cfg_function_number      : std_logic_vector(2 downto 0);

  --  FIFO signals
  signal pcie_write : std_logic;
  signal pcie_bram_raddr, pcie_bram_raddr_next,
         pcie_bram_waddr, pcie_bram_waddr_next : std_logic_vector(8 downto 0);
  signal cpu_bram_raddr , cpu_bram_raddr_next ,
         cpu_bram_waddr , cpu_bram_waddr_next  : std_logic_vector(9 downto 0);
  
  signal csr_value, bram_value_0, bram_value_1 : std_logic_vector(31 downto 0);
  signal rst_n : std_logic;
  signal tx_cmd : std_logic;
  signal tx_rem : std_logic;

  signal rx_rem_n : std_logic;
  signal trn_rst : std_logic;
  
  signal dcr_write, dcr_read : std_logic;
  signal dcr_reg : std_logic_vector(0 downto 0);
  signal dcr_ackb, dcr_ack_next : std_logic;
  
begin  -- IMP

  pcie_rst_n    <= rst_n;

  rst_n         <= not rst and not csCntrl(7);

  trn_rst       <= not trn_rst_n;
  
  dcr_ack   <= dcr_ackb;
  
  dcr_write <= dcr_wr when dcr_addr(9 downto 1)=BASEADDR(9 downto 1) else
               '0';

  dcr_read  <= dcr_rd when dcr_addr(9 downto 1)=BASEADDR(9 downto 1) else
               '0';

  dcr_reg(0) <= dcr_addr(0);

  dcr_ack_next <= dcr_wr or dcr_rd;
  
  tx_cmd <= not dcr_ackb when (dcr_write='1' and dcr_reg(0)='0' and dcr_dbusi(15)='1') else
            '0';

  dcr_dbuso     <= csr_value when dcr_reg(0)='0' else
                   bram_value_0 when cpu_bram_raddr(0)='0' else
                   bram_value_1;
  
  cpu_bram_raddr_next <= (cpu_bram_raddr+1) when (dcr_read='1' and dcr_reg(0)='1') else
                         (cpu_bram_raddr);

-- Erroneous advance here (trying to pad last write to 64 bits)
  cpu_bram_waddr_next <= (cpu_bram_waddr+1) when ((dcr_write='1' and dcr_reg(0)='1') or
                                                  (pcie_bram_raddr = cpu_bram_waddr(9 downto 1) and
                                                   cpu_bram_waddr(0)='1')) else
                         (cpu_bram_waddr);

  csr_value(31 downto 27) <= rst & trn_rst & trn_lnk_up_n & trn_rerrfwd_n & '0';
  csr_value(26 downto 25) <= (others=>'0');
  csr_value(24 downto 16) <= (pcie_bram_waddr - cpu_bram_raddr(9 downto 1) );
  csr_value(          15) <= tx_busy;
  csr_value(14 downto 12) <= gt_loopback;
  csr_value(11 downto  9) <= gt_debug_r(24) & gt_debug_r(20 downto 19);
  csr_value( 8 downto  0) <= (cpu_bram_waddr(9 downto 1)  - pcie_bram_raddr);

  tx_enable_next <= '0' when (tx_state=TX_RUNNING) else
                    '1' when (dcr_write='1' and dcr_reg(0)='0' and dcr_dbusi(15)='1') else
                    tx_enable;
  
  gt_loopback_next <= dcr_dbusi(14 downto 12) when (dcr_write='1' and dcr_reg(0)='0') else
                      (gt_loopback or csCntrl(6 downto 4));
  
  tx_busy_next <=   '1' when (tx_enable='1' or tx_state=TX_RUNNING) else
                    '0';
  
  dcr_clk_p: process (dcr_clk, rst)
  begin 
    if rst='1' then
      cpu_bram_raddr   <= (others=>'0');
      cpu_bram_waddr   <= (others=>'0');
      tx_enable        <= '0';
      tx_busy          <= '1';
      dcr_ackb         <= '0';
      gt_loopback      <= (others=>'0');
    elsif rising_edge(dcr_clk) then
      cpu_bram_raddr   <= cpu_bram_raddr_next;
      cpu_bram_waddr   <= cpu_bram_waddr_next;
      tx_enable        <= tx_enable_next;
      tx_busy          <= tx_busy_next;
      dcr_ackb         <= dcr_ack_next;
      gt_loopback      <= gt_loopback_next;
    end if;
  end process dcr_clk_p;

  -- pcie tx
  tx_rem        <= '1' when (pcie_bram_raddr = cpu_bram_waddr(9 downto 1) and
                             cpu_bram_waddr(0)='1') else
                   '0';

  tx_state_next <= TX_IDLE       when (trn_tdst_dsc_n='0' or
                                       (pcie_bram_raddr = cpu_bram_waddr(9 downto 1) and
                                        cpu_bram_waddr(0)='0')) else
                   tx_state      when (trn_tdst_rdy_n='1') else
                   TX_RUNNING    when (tx_state=TX_IDLE and tx_enable='1') else
                   tx_state;

  trn_tsof_n_next <= '0' when (tx_state       =TX_IDLE and
                               tx_state_next  =TX_RUNNING) else
                     '1';

  trn_teof_n_next <= '0' when (tx_state =TX_RUNNING and
                               pcie_bram_raddr_next=cpu_bram_waddr(9 downto 1)) else
                     '1';

  trn_tsrc_rdy_n <= '1' when (rst='1') else '0';
  trn_tsrc_dsc_n <= '1';

  trn_done_next  <= '1' when (tx_state_next = TX_IDLE) else
                    '0';

  pcie_bram_raddr_next <= (pcie_bram_raddr+1) when (tx_state=TX_RUNNING and trn_tdst_rdy_n='0') else
                          (pcie_bram_raddr);

  -- pcie_rx

  rx_state_next <= rx_state   when (trn_rsrc_rdy_n='1') else
                   RX_IDLE    when (trn_reof_n='0') else
                   RX_RUNNING when (trn_rsof_n='0') else
                   rx_state;

  trn_rdst_rdy_n <= rst;
  
  pcie_write <= '1' when (rx_state=RX_RUNNING and trn_rsrc_rdy_n='0') else
                '0';
                
  pcie_bram_waddr_next <= (pcie_bram_waddr+1) when (rx_state=RX_RUNNING and trn_rsrc_rdy_n='0') else
                          (pcie_bram_waddr);

  trn_clk_p: process (trn_clk, trn_rst_n)
  begin
    if trn_rst_n='0' then
      pcie_bram_raddr   <= (others=>'0');
      pcie_bram_waddr   <= (others=>'0');
      tx_state          <= TX_IDLE;
      trn_tsof_n        <= '1';
      trn_teof_n        <= '1';
      trn_done          <= '1';
      rx_state          <= RX_IDLE;
    elsif rising_edge(trn_clk) then
      pcie_bram_raddr   <= pcie_bram_raddr_next;
      pcie_bram_waddr   <= pcie_bram_waddr_next;
      tx_state          <= tx_state_next;
      trn_tsof_n        <= trn_tsof_n_next;
      trn_teof_n        <= trn_teof_n_next;
      trn_done          <= trn_done_next;
      rx_state          <= rx_state_next;
    end if;
  end process trn_clk_p;
  
  -- tx
  bram_tx_c : RAMB16_S36_S36
    port map ( DOB  => open,
               DOPB => open,
               ADDRB=> cpu_bram_cmd_waddr,
               CLKB => dcr_clk,
               DIB  => cpu_bram_cmd_wdata,
               DIPB => (others=>'0'),
               ENB  => '1',
               SSRB => rst,
               WEB  => cpu_bram_cmd_wr,
               DOA  => pcie_bram_cmd_rdata,
               ADDRA => pcie_bram_cmd_raddr,
               CLKA => trn_clk,
               DIA  => (others=>'0'),
               ENA  => '1',
               SSRA => trn_rst,
               WEA  => '0' );
  bram_tx_0 : RAMB16_S36_S36
    port map ( DOB  => open,
               DOPB => open,
               ADDRB=> cpu_bram_waddr(9 downto 1),
               CLKB => dcr_clk,
               DIB  => dcr_dbusi,
               DIPB => (others=>'0'),
               ENB  => not cpu_bram_waddr(0),
               SSRB => rst,
               WEB  => dcr_write,
               DOA  => trn_td(63 downto 32),
               ADDRA => pcie_bram_raddr,
               CLKA => trn_clk,
               DIA  => (others=>'0'),
               ENA  => '1',
               SSRA => trn_rst,
               WEA  => '0' );
  bram_tx_1 : RAMB16_S36_S36
    port map ( DOB  => open,
               DOPB => open,
               ADDRB=> cpu_bram_waddr(9 downto 1),
               CLKB => dcr_clk,
               DIB  => dcr_dbusi,
               DIPB => (others=>'0'),
               ENB  => cpu_bram_waddr(0),
               SSRB => rst,
               WEB  => dcr_write,
               DOA  => trn_td(31 downto 0),
               ADDRA => pcie_bram_raddr,
               CLKA => trn_clk,
               DIA  => (others=>'0'),
               ENA  => '1',
               SSRA => trn_rst,
               WEA  => '0' );

  -- rx
  bram_rx_0 : RAMB16_S36_S36
    port map ( DOB  => bram_value_0,
               DOPB => open,
               ADDRB=> cpu_bram_raddr(9 downto 1),
               CLKB => dcr_clk,
               DIB  => (others=>'0'),
               DIPB => (others=>'0'),
               ENB  => '1',
               SSRB => rst,
               WEB  => '0',
               DOA  => open,
               ADDRA => pcie_bram_waddr,
               CLKA => trn_clk,
               DIA  => trn_rd(63 downto 32),
               ENA  => '1',
               SSRA => trn_rst,
               WEA  => pcie_write );
  bram_rx_1 : RAMB16_S36_S36
    port map ( DOB  => bram_value_1,
               DOPB => open,
               ADDRB=> cpu_bram_raddr(9 downto 1),
               CLKB => dcr_clk,
               DIB  => (others=>'0'),
               DIPB => (others=>'0'),
               ENB  => '1',
               SSRB => rst,
               WEB  => '0',
               DOA  => open,
               ADDRA => pcie_bram_waddr,
               CLKA => trn_clk,
               DIA  => trn_rd(31 downto 0),
               ENA  => '1',
               SSRA => trn_rst,
               WEA  => pcie_write );

--  endpoint : endpoint_blk_plus_v1_15
  endpoint : endpoint_blk_plus_v1_14
    port map ( pci_exp_txp(0) => pcie_tx_p,
               pci_exp_txn(0) => pcie_tx_n,
               pci_exp_rxp(0) => pcie_rx_p,
               pci_exp_rxn(0) => pcie_rx_n,
               trn_clk        => trn_clk,
               trn_reset_n    => trn_rst_n,
               trn_lnk_up_n   => trn_lnk_up_n,
               
               trn_td         => trn_td,
               trn_trem_n(7 downto 4) => "0000",
               trn_trem_n(3)  => tx_rem,
               trn_trem_n(2)  => tx_rem,
               trn_trem_n(1)  => tx_rem,
               trn_trem_n(0)  => tx_rem,
               trn_tsof_n     => trn_tsof_n,
               trn_teof_n     => trn_teof_n,
               trn_tsrc_rdy_n => trn_tsrc_rdy_n,
               trn_tdst_rdy_n => trn_tdst_rdy_n,
               trn_tdst_dsc_n => trn_tdst_dsc_n,
               trn_tsrc_dsc_n => trn_tsrc_dsc_n,
               trn_terrfwd_n  => '1',
               trn_tbuf_av    => open,
               
               trn_rd         => trn_rd,
               trn_rrem_n(7 downto 1) => open,
               trn_rrem_n(0)  => rx_rem_n,
               trn_rsof_n     => trn_rsof_n,
               trn_reof_n     => trn_reof_n,
               trn_rsrc_rdy_n => trn_rsrc_rdy_n,
               trn_rsrc_dsc_n => trn_rsrc_dsc_n,
               trn_rdst_rdy_n => trn_rdst_rdy_n,
               trn_rerrfwd_n  => trn_rerrfwd_n,
               trn_rnp_ok_n   => '0',
               trn_rcpl_streaming_n => '0',
               trn_rbar_hit_n => trn_rbar_hit_n,
               trn_rfc_nph_av => open,
               trn_rfc_npd_av => open,
               trn_rfc_ph_av  => open,
               trn_rfc_pd_av  => open,
               
               cfg_do           => open,
               cfg_rd_wr_done_n => open,
               cfg_di           => (others=>'0'),
               cfg_byte_en_n    => x"F",
               cfg_dwaddr       => (others=>'0'),
               cfg_wr_en_n      => '1',
               cfg_rd_en_n      => '1',
               
               cfg_err_cor_n    => '1',
               cfg_err_ur_n     => '1',
               cfg_err_ecrc_n   => '1',
               cfg_err_cpl_timeout_n  => '1',
               cfg_err_cpl_abort_n    => '1',
               cfg_err_cpl_unexpect_n => '1',
               cfg_err_posted_n       => '1',
               cfg_err_tlp_cpl_header => (others=>'0'),
               cfg_err_cpl_rdy_n      => open,
               cfg_err_locked_n       => '1',
               
               cfg_interrupt_n        => '1',
               cfg_interrupt_rdy_n    => open,
               cfg_interrupt_assert_n => '1',
               cfg_interrupt_di       => (others=>'0'),
               cfg_interrupt_do       => open,
               cfg_interrupt_mmenable => open,
               cfg_interrupt_msienable => open,
               
               cfg_to_turnoff_n        => open,
               cfg_pm_wake_n           => '1',
               cfg_pcie_link_state_n   => cfg_pcie_link_state_n,
               cfg_trn_pending_n       => '1',
               cfg_bus_number      => cfg_bus_number,
               cfg_device_number   => cfg_device_number,
               cfg_function_number => cfg_function_number,
               cfg_dsn       => (others=>'0'),
               cfg_status    => open,
               cfg_command   => open,
               cfg_dstatus   => open,
               cfg_dcommand  => open,
               cfg_lstatus   => open,
               cfg_lcommand  => open,
               fast_train_simulation_only => '0',
               gt_loopback   => gt_loopback,
               gt_debug      => gt_debug,
               refclkout   => open,
               sys_clk     => pcie_clk,
               sys_reset_n => rst_n );

  debug <= (others=>'0');

   U_icon : v5_icon port map ( 
      CONTROL0 => csControl0,
      CONTROL1 => csControl1
   );

   U_ila : v5_ila port map (
      CONTROL => csControl0,
--      CLK     => trn_clk,
      CLK     => gt_debug(28),
      DATA    => csData,
      TRIG0   => csData(23 downto 16)
   );

   U_vio : v5_vio port map (
       CONTROL  => csControl1,
--       CLK      => dcr_clk,
       CLK      => gt_debug(28),
       SYNC_IN  => csStat,
       SYNC_OUT => csCntrl
   );

  with csCntrl(1 downto 0) select
    csData(63 downto 32) <= -- trn_td(63 downto 32) when "00",
                            -- trn_td(31 downto  0) when "01",
                            gt_debug_r(31 downto  0) when "00",
                        ( x"0000" &
                          pcie_bram_waddr(3 downto 0) &
                          pcie_bram_raddr(3 downto 0) &
                          cpu_bram_waddr (3 downto 0) &
                          cpu_bram_raddr (3 downto 0) ) when others;
--                             trn_rd(63 downto 32) when "10",
--                             trn_rd(31 downto  0) when others;

  csData(31 downto 16) <= x"0" & gt_debug_r(43 downto 32);
  
--   csData(31 downto 16) <= pcie_bram_waddr(3 downto 0) &
--                           pcie_bram_raddr(3 downto 0) &
--                           cpu_bram_waddr (3 downto 0) &
--                           cpu_bram_raddr (3 downto 0);

  csData(15 downto 10) <= trn_tdst_dsc_n & trn_tsrc_dsc_n & tx_rem & trn_done &
                          trn_rsrc_dsc_n & rx_rem_n;
  csData( 9 ) <= '1' when rx_state=RX_RUNNING else '0';
  csData( 8 ) <= '1' when tx_state=TX_RUNNING else '0';
  csData( 7 downto  0) <= trn_tsof_n & trn_teof_n & trn_tsrc_rdy_n & trn_tdst_rdy_n &
                          trn_rsof_n & trn_reof_n & trn_rsrc_rdy_n & trn_rdst_rdy_n;

  csStat <= rst &
            trn_rst &
            trn_lnk_up_n & 
            trn_rerrfwd_n &
            cfg_pcie_link_state_n &
            tx_busy;

  gt_d: block
    signal clkcnt0,clkcnt1,clkcnt2,clkcnt3 : std_logic_vector(3 downto 0);
  begin  -- block gt_d
    cnt0_p: process (gt_debug(28))
    begin  -- process cnt0_p
      if rising_edge(gt_debug(28)) then
        clkcnt0 <= clkcnt0+1;
      end if;
    end process cnt0_p;
    cnt1_p: process (gt_debug(29))
    begin  -- process cnt0_p
      if rising_edge(gt_debug(29)) then
        clkcnt1 <= clkcnt1+1;
      end if;
    end process cnt1_p;
    cnt2_p: process (gt_debug(30))
    begin  -- process cnt0_p
      if rising_edge(gt_debug(30)) then
        clkcnt2 <= clkcnt2+1;
      end if;
    end process cnt2_p;
    cnt3_p: process (gt_debug(31))
    begin  -- process cnt0_p
      if rising_edge(gt_debug(31)) then
        clkcnt3 <= clkcnt3+1;
      end if;
    end process cnt3_p;

    gt_r: process (trn_clk)
    begin  -- process gt_r
      if rising_edge(trn_clk) then
        gt_debug_r(27 downto 0)  <= gt_debug(27 downto 0);
        gt_debug_r(28) <= clkcnt0(3);
        gt_debug_r(29) <= clkcnt1(3);
        gt_debug_r(30) <= clkcnt2(3);
        gt_debug_r(31) <= clkcnt3(3);
        gt_debug_r(43 downto 32)  <= gt_debug(43 downto 32);
      end if;
    end process gt_r;
  end block gt_d;

end IMP;
