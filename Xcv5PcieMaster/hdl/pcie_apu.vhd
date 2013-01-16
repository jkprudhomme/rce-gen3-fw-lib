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

use work.Ppc440RceG2Pkg.all;

entity pcie_debug is
  port ( rst             : in  std_logic;
         -- APU Interface
         apuClk          : in  std_logic;
         apuClkRst       : in  std_logic;
         apuReadFromPpc  : in  ApuReadFromPpcType;
         apuReadToPpc    : out ApuReadToPpcType;
         apuWriteFromPpc : in  ApuWriteFromPpcType;
         apuWriteToPpc   : out ApuWriteToPpcType;
         apuLoadFromPpc  : in  ApuLoadFromPpcType;
         apuLoadToPpc    : out ApuLoadToPpcType;
         apuStoreFromPpc : in  ApuStoreFromPpcType;
         apuStoreToPpc   : out ApuStoreToPpcType;
         -- PCIE Interface
         pcie_clk    : in  std_logic;
         pcie_clkout : out std_logic;
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

   COMPONENT pcie_fifo
     PORT (
       rst : IN STD_LOGIC;
       wr_clk : IN STD_LOGIC;
       rd_clk : IN STD_LOGIC;
       din : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
       wr_en : IN STD_LOGIC;
       rd_en : IN STD_LOGIC;
       dout : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
       full : OUT STD_LOGIC;
       empty : OUT STD_LOGIC;
       valid : OUT STD_LOGIC;
       wr_data_count : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
     );
   END COMPONENT;

--  component endpoint_blk_plus_v1_15  port (
  component endpoint_blk_plus_v1_14  port (
    pci_exp_rxn : in std_logic_vector((1 - 1) downto 0);
    pci_exp_rxp : in std_logic_vector((1 - 1) downto 0);
    pci_exp_txn : out std_logic_vector((1 - 1) downto 0);
    pci_exp_txp : out std_logic_vector((1 - 1) downto 0);

    sys_clk : in STD_LOGIC;
    sys_reset_n : in STD_LOGIC;
    refclkout         : out std_logic;
    pll_lock : out std_logic;

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

  signal trn_clk, trn_rst_n       : std_logic;
  signal trn_td                   : std_logic_vector( 63 downto 0);
  signal trn_tsof_n               : std_logic;
  signal trn_teof_n               : std_logic;
  signal trn_tsrc_rdy_n           : std_logic;
  signal trn_tsrc_dsc_n           : std_logic;
  signal trn_tdst_rdy_n           : std_logic;
  signal trn_tdst_dsc_n           : std_logic;
  signal trn_trem_n               : std_logic_vector(7 downto 0);
  signal trn_lnk_up_n : std_logic;
  signal trn_rerrfwd_n : std_logic;
  signal cfg_pcie_link_state_n : std_logic_vector(2 downto 0);
  
  signal trn_rd         : std_logic_vector(63 downto 0);
  signal trn_rsof_n     : std_logic;
  signal trn_reof_n     : std_logic;
  signal trn_rsrc_rdy_n : std_logic;
  signal trn_rsrc_dsc_n : std_logic;
  signal trn_rbar_hit_n : std_logic_vector(6 downto 0);
  signal trn_rdst_rdy_n : std_logic;
  signal trn_rrem_n     : std_logic_vector(7 downto 0);

  signal gt_loopback, gt_loopback_next, gt_loopback_reg : std_logic_vector(2 downto 0);
  
  signal cfg_bus_number           : std_logic_vector(7 downto 0);
  signal cfg_device_number        : std_logic_vector(4 downto 0);
  signal cfg_function_number      : std_logic_vector(2 downto 0);

  type Tx_State is (Empty, Word0, Word1);
  signal txState, txState_next : Tx_State;
  
  signal csr_value, csr_value1, csr_value2 : std_logic_vector(31 downto 0);
  signal csr_rst, csr_rst_next,csr_rst_reg : std_logic;

  signal rst_n : std_logic;
  signal pcie_clkout_b : std_logic;
  signal pcie_clkcnt : std_logic_vector(3 downto 0);
  signal trn_clkcnt : std_logic_vector(3 downto 0);
  signal pcie_plllock : std_logic;

  signal txFifoWrEn1  : std_logic;
  signal txFifoWrEn2  : std_logic;
  signal txFifoDin1   : std_logic_vector(127 downto 0);
  signal txFifoDin2   : std_logic_vector(127 downto 0);
  signal txFifoEmpty1 : std_logic;
  signal txFifoEmpty2 : std_logic;
  signal txFifoRdEn   : std_logic;
  signal txFifoValid  : std_logic;
  signal txFifoDout   : std_logic_vector(127 downto 0);
  signal rxFifoWrEn1  : std_logic;
  signal rxFifoWrEn2  : std_logic;
  signal rxFifoDin1   : std_logic_vector(127 downto 0);
  signal rxFifoDin2   : std_logic_vector(127 downto 0);
  signal rxFifoRdEn   : std_logic;
  signal rxFifoValid  : std_logic;
  signal rxFifoDout   : std_logic_vector(127 downto 0);
  signal rxFifoCount  : std_logic_vector(3 downto 0);
  signal rxFifoAFull  : std_logic;
 
begin  -- IMP

  -- Transmit FIFO
  process (apuClk, apuClkRst)
  begin 
    if apuClkRst='1' then
      txFifoWrEn1  <= '0';
      txFifoWrEn2  <= '0';
      txFifoDin1   <= (others=>'0');
      txFifoDin2   <= (others=>'0');
      txFifoEmpty2 <= '0';
    elsif rising_edge(apuClk) then
      txFifoWrEn1  <= apuLoadFromPpc.enable;
      txFifoWrEn2  <= txFifoWrEn1;
      txFifoDin1   <= apuLoadFromPpc.data;
      txFifoDin2   <= txFifoDin1;
      txFifoEmpty2 <= txFifoEmpty1;
    end if;
  end process;

   U_tx_fifo : pcie_fifo
      PORT MAP (
         rst           => apuClkRst,
         wr_clk        => apuClk,
         rd_clk        => trn_clk,
         din           => txFifoDin2,
         wr_en         => txFifoWrEn2,
         rd_en         => txFifoRdEn,
         dout          => txFifoDout,
         full          => open,
         empty         => txFifoEmpty1,
         valid         => txFifoValid,
         wr_data_count => open
      );

  apuLoadToPpc.full <= not txFifoEmpty2;

  rst_n <= not rst;

  txState_next <= Word0 when (txState=Empty and txFifoValid ='1') else
                  Word1 when (txState=Word0 and trn_tsrc_rdy_n='0' and trn_tdst_rdy_n='0') else
                  Empty when (txState=Word1 and trn_tsrc_rdy_n='0' and trn_tdst_rdy_n='0') else
                  txState;

  txFifoRdEn <= '1' when (txState=Word1 and trn_tsrc_rdy_n='0' and trn_tdst_rdy_n='0') else '0';

  trn_tsrc_rdy_n <= '1' when txState=Empty else '0';
  trn_teof_n     <= '0' when txState=Word1 else '1';
  trn_tsof_n     <= '0' when txState=Word0 else '1';
  trn_trem_n     <= x"00" when (txState=Word1 and txFifoDout(126 downto 125)="10") else x"0F";
  trn_tsrc_dsc_n <= '1';
  trn_td         <= txFifoDout( 63 downto  0) when txState=Word1 else txFifoDout(127 downto 64);

 
  -- Receive FIFO
  apuStoreToPpc.data  <= rxFifoDout;
  apuStoreToPpc.ready <= '1';
  rxFifoRdEn          <= apuStoreFromPpc.enable;

   U_rx_fifo : pcie_fifo
      PORT MAP (
         rst           => apuClkRst,
         wr_clk        => trn_clk,
         rd_clk        => apuClk,
         din           => rxFifoDin2,
         wr_en         => rxFifoWrEn2,
         rd_en         => rxFifoRdEn,
         dout          => rxFifoDout,
         full          => open,
         empty         => open,
         valid         => rxFifoValid,
         wr_data_count => rxFifoCount
      );

  process (trn_clk, rst)
  begin
    if rst='1' then
       rxFifoAFull  <= '0';
       rxFifoWrEn1  <= '0';
       rxFifoWrEn2  <= '0';
       rxFifoDin1   <= (others=>'0');
       rxFifoDin2   <= (others=>'0');
    elsif rising_edge(trn_clk) then

       if rxFifoCount = 0 then
          rxFifoAFull <= '0';
       else
          rxFifoAFull <= '1';
       end if;

      if trn_rsrc_rdy_n='0' and trn_rdst_rdy_n='0' then
         if trn_rsof_n = '0' then
            rxFifoDin1(127 downto 64) <= trn_rd;
            rxFifoWrEn1               <= '0';
         elsif trn_reof_n = '0' then
            rxFifoDin1(63 downto 0)   <= trn_rd;
            rxFifoWrEn1               <= '1';
         else
            rxFifoWrEn1  <= '0';
         end if;
      else
         rxFifoWrEn1  <= '0';
      end if;

      rxFifoWrEn2  <= rxFifoWrEn1;
      rxFifoDin2   <= rxFifoDin1;

    end if;
  end process;

  trn_rdst_rdy_n <= rxFifoAFull;

  -- Control/Status
  csr_value1(31 downto 16) <= rst & trn_rst_n & trn_lnk_up_n & trn_rerrfwd_n &
                              trn_tdst_rdy_n  & trn_tsrc_rdy_n & trn_rdst_rdy_n  & trn_rsrc_rdy_n &
                              pcie_plllock & cfg_pcie_link_state_n &
                              (not rxFifoValid) & '0' & txFifoEmpty1 & '0';
  csr_value1(15 downto  0) <= pcie_clkcnt &
                              trn_clkcnt &
                              x"0" &
                              gt_loopback & csr_rst;

  csr_rst_next  <= apuWriteFromPpc.regB(31) when (apuWriteFromPpc.enable='1') else
                   csr_rst_reg;
  
  gt_loopback_next <= apuWriteFromPpc.regB(28 to 30) when (apuWriteFromPpc.enable='1') else
                      gt_loopback;
  
  fcm_clk_p: process (apuClk, apuClkRst)
  begin 
    if apuClkRst='1' then
      csr_rst           <= '0';
      csr_rst_reg       <= '0';
      gt_loopback       <= "000";
      gt_loopback_reg   <= "000";
      csr_value2        <= (others=>'0');
      csr_value         <= (others=>'0');
    elsif rising_edge(apuClk) then
      csr_rst_reg       <= csr_rst_next;
      csr_rst           <= csr_rst_reg;
      gt_loopback_reg   <= gt_loopback_next;
      gt_loopback       <= gt_loopback_reg;
      csr_value2        <= csr_value1;
      csr_value         <= csr_value2;
    end if;
  end process fcm_clk_p;


  trn_clk_p: process (trn_clk, rst)
  begin
    if rst='1' then
      txState <= Empty;
      trn_clkcnt <= (others=>'0');
    elsif rising_edge(trn_clk) then
      txState <= txState_next;
      trn_clkcnt <= trn_clkcnt+1;
    end if;
  end process trn_clk_p;

  pcie_clk_p: process(pcie_clkout_b, rst)
  begin
    if rst='1' then
      pcie_clkcnt <= (others=>'0');
    elsif rising_edge(pcie_clkout_b) then
      pcie_clkcnt <= pcie_clkcnt+1;
    end if;
  end process pcie_clk_p;
  
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
               trn_trem_n     => trn_trem_n,
               trn_tsof_n     => trn_tsof_n,
               trn_teof_n     => trn_teof_n,
               trn_tsrc_rdy_n => trn_tsrc_rdy_n,
               trn_tdst_rdy_n => trn_tdst_rdy_n,
               trn_tdst_dsc_n => trn_tdst_dsc_n,
               trn_tsrc_dsc_n => trn_tsrc_dsc_n,
               trn_terrfwd_n  => '1',
               trn_tbuf_av    => open,
               
               trn_rd         => trn_rd,
               trn_rrem_n     => trn_rrem_n,
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
               gt_debug      => open,
               refclkout   => pcie_clkout_b,
               sys_clk     => pcie_clk,
               sys_reset_n => rst_n,
               pll_lock    => pcie_plllock );

  debug <= (others=>'0');

  pcie_rst_n <= not csr_rst;
  pcie_clkout <= pcie_clkout_b;
  
  -- Interface
  apuWriteToPpc.full   <= '0';
  apuReadToPpc.result  <= csr_value;
  apuReadToPpc.status  <= x"0";
  apuReadToPpc.ready   <= '1';
  
end IMP;
