

library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.numeric_std.all;

library Unisim;
use Unisim.vcomponents.all;

entity Ppc440RceG2Clk is
   port (

      -- Inputs
      refClk125Mhz               : in std_logic;
      masterReset                : in std_logic;

      -- Clock Outputs
      cpuClk312_5Mhz             : out std_logic; 
      cpuClk312_5MhzAdj          : out std_logic;
      cpuClk312_5Mhz90DegAdj     : out std_logic;
      cpuClk156_25MhzAdj         : out std_logic;
      cpuClk468_75Mhz            : out std_logic;
      cpuClk200MhzAdj            : out std_logic;

      -- Sync Reset Outputs
      cpuClk312_5MhzRst          : out std_logic;
      cpuClk312_5MhzAdjRst       : out std_logic;
      cpuClk312_5Mhz90DegAdjRst  : out std_logic;
      cpuClk156_25MhzAdjRst      : out std_logic;
      cpuClk468_75MhzRst         : out std_logic;
      cpuClk200MhzAdjRst         : out std_logic;

      -- CPU Resets
      cpuRstCore                 : out std_logic;
      cpuRstChip                 : out std_logic;
      cpuRstSystem               : out std_logic;
      cpuRstCoreReq              : in  std_logic;
      cpuRstChipReq              : in  std_logic;
      cpuRstSystemReq            : in  std_logic
   );
end Ppc440RceG2Clk;

architecture STRUCTURE of Ppc440RceG2Clk is

   -- Reset block
   component Ppc440RceG2Rst 
      port (
         syncClk     : in std_logic;
         asyncReset  : in std_logic;
         pllLocked   : in std_logic;
         syncReset   : out std_logic
      );
   end component;

   -- Local signals
   signal pll0FbOut               : std_logic;
   signal pll0Locked              : std_logic;
   signal pll0FbIn                : std_logic;
   signal pll1FbOut               : std_logic;
   signal pll1Locked              : std_logic;
   signal pll1FbIn                : std_logic;
   signal pllClk312_5Mhz          : std_logic;
   signal pllClk312_5MhzAdj       : std_logic;
   signal pllClk312_5Mhz90DegAdj  : std_logic;
   signal pllClk156_25MhzAdj      : std_logic;
   signal pllClk468_75Mhz         : std_logic;
   signal pllClk200MhzAdj         : std_logic;
   signal intClk312_5Mhz          : std_logic; 
   signal intClk312_5MhzAdj       : std_logic;
   signal intClk312_5Mhz90DegAdj  : std_logic;
   signal intClk156_25MhzAdj      : std_logic;
   signal intClk468_75Mhz         : std_logic;
   signal intClk200MhzAdj         : std_logic;
   signal asyncReset              : std_logic;
   signal intClk312_5MhzRst       : std_logic;
   signal pllLocked               : std_logic;

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -------------------------------------
   -- Clock Generation
   -------------------------------------
   cpuClk312_5Mhz         <= intClk312_5Mhz;
   cpuClk312_5MhzAdj      <= intClk312_5MhzAdj;
   cpuClk312_5Mhz90DegAdj <= intClk312_5Mhz90DegAdj;
   cpuClk156_25MhzAdj     <= intClk156_25MhzAdj;
   cpuClk468_75Mhz        <= intClk468_75Mhz;
   cpuClk200MhzAdj        <= intClk200MhzAdj;

   -- PLL
   U_PLL_ADV0 : PLL_ADV
      generic map (
         BANDWIDTH              => "OPTIMIZED",
         CLKFBOUT_MULT          => 15,
         CLKFBOUT_PHASE         => 0.0,
         CLKIN1_PERIOD          => 8.0,
         CLKIN2_PERIOD          => 8.0,
         CLKOUT0_DIVIDE         => 3,
         CLKOUT0_DUTY_CYCLE     => 0.5,
         CLKOUT0_PHASE          => 0.0,
         CLKOUT1_DIVIDE         => 3,
         CLKOUT1_DUTY_CYCLE     => 0.5,
         CLKOUT1_PHASE          => 90.0,
         CLKOUT2_DIVIDE         => 3,
         CLKOUT2_DUTY_CYCLE     => 0.5,
         CLKOUT2_PHASE          => 0.0,
         CLKOUT3_DIVIDE         => 6,
         CLKOUT3_DUTY_CYCLE     => 0.5,
         CLKOUT3_PHASE          => 0.0,
         CLKOUT4_DIVIDE         => 2,
         CLKOUT4_DUTY_CYCLE     => 0.5,
         CLKOUT4_PHASE          => 0.0,
         CLKOUT5_DIVIDE         => 1,
         CLKOUT5_DUTY_CYCLE     => 0.5,
         CLKOUT5_PHASE          => 0.0,
         COMPENSATION           => "SYSTEM_SYNCHRONOUS",
         DIVCLK_DIVIDE          => 2,
         EN_REL                 => false,
         PLL_PMCD_MODE          => false,
         REF_JITTER             => 0.100,
         RESET_ON_LOSS_OF_LOCK  => false,
         SIM_DEVICE             => "VIRTEX5",
         RST_DEASSERT_CLK       => "CLKIN1",
         CLKOUT0_DESKEW_ADJUST  => "PPC",
         CLKOUT1_DESKEW_ADJUST  => "PPC",
         CLKOUT2_DESKEW_ADJUST  => "NONE",
         CLKOUT3_DESKEW_ADJUST  => "PPC",
         CLKOUT4_DESKEW_ADJUST  => "NONE",
         CLKOUT5_DESKEW_ADJUST  => "PPC",
         CLKFBOUT_DESKEW_ADJUST => "PPC"
      ) port map (
         CLKFBDCM               => open,
         CLKFBOUT               => pll0FbOut,
         CLKOUT0                => pllClk312_5Mhz,
         CLKOUT1                => pllClk312_5MhzAdj,
         CLKOUT2                => pllClk312_5Mhz90DegAdj,
         CLKOUT3                => pllClk156_25MhzAdj,
         CLKOUT4                => pllClk468_75Mhz,
         CLKOUT5                => open,
         CLKOUTDCM0             => open,
         CLKOUTDCM1             => open,
         CLKOUTDCM2             => open,
         CLKOUTDCM3             => open,
         CLKOUTDCM4             => open,
         CLKOUTDCM5             => open,
         DO                     => open,
         DRDY                   => open,
         LOCKED                 => pll0Locked,
         CLKFBIN                => pll0FbIn,
         CLKIN1                 => refClk125Mhz,
         CLKIN2                 => '0',
         CLKINSEL               => '1',
         DADDR                  => "00000",
         DCLK                   => '0',
         DEN                    => '0',
         DI                     => "0000000000000000",
         DWE                    => '0',
         REL                    => '0',
         RST                    => masterReset
      );

   -- Feedback buffer
   U_Pll0_FB_BUFF : BUFG port map (
      I => pll0FbOut,
      O => pll0FbIn
   );

   -- Clock buffer
   U_Pll0_CLK0_BUFF : BUFG port map (
      I => pllClk312_5Mhz,
      O => intClk312_5Mhz
   );

   -- Clock buffer
   U_Pll0_CLK1_BUFF : BUFG port map (
      I => pllClk312_5MhzAdj,
      O => intClk312_5MhzAdj
   );

   -- Clock buffer
   U_Pll0_CLK2_BUFF : BUFG port map (
      I => pllClk312_5Mhz90DegAdj,
      O => intClk312_5Mhz90DegAdj
   );

   -- Clock buffer
   U_Pll0_CLK3_BUFF : BUFG port map (
      I => pllClk156_25MhzAdj,
      O => intClk156_25MhzAdj
   );

   -- Clock buffer
   U_Pll0_CLK4_BUFF : BUFG port map (
      I => pllClk468_75Mhz,
      O => intClk468_75Mhz
   );


   -- PLL
   U_PLL_ADV1 : PLL_ADV
      generic map (
         BANDWIDTH              => "OPTIMIZED",
         CLKFBOUT_MULT          => 8,
         CLKFBOUT_PHASE         => 0.0,
         CLKIN1_PERIOD          => 8.0,
         CLKIN2_PERIOD          => 8.0,
         CLKOUT0_DIVIDE         => 5,
         CLKOUT0_DUTY_CYCLE     => 0.5,
         CLKOUT0_PHASE          => 0.0,
         CLKOUT1_DIVIDE         => 1,
         CLKOUT1_DUTY_CYCLE     => 0.5,
         CLKOUT1_PHASE          => 0.0,
         CLKOUT2_DIVIDE         => 1,
         CLKOUT2_DUTY_CYCLE     => 0.5,
         CLKOUT2_PHASE          => 0.0,
         CLKOUT3_DIVIDE         => 1,
         CLKOUT3_DUTY_CYCLE     => 0.5,
         CLKOUT3_PHASE          => 0.0,
         CLKOUT4_DIVIDE         => 1,
         CLKOUT4_DUTY_CYCLE     => 0.5,
         CLKOUT4_PHASE          => 0.0,
         CLKOUT5_DIVIDE         => 1,
         CLKOUT5_DUTY_CYCLE     => 0.5,
         CLKOUT5_PHASE          => 0.0,
         COMPENSATION           => "SYSTEM_SYNCHRONOUS",
         DIVCLK_DIVIDE          => 1,
         EN_REL                 => false,
         PLL_PMCD_MODE          => false,
         REF_JITTER             => 0.100,
         RESET_ON_LOSS_OF_LOCK  => false,
         SIM_DEVICE             => "VIRTEX5",
         RST_DEASSERT_CLK       => "CLKIN1",
         CLKOUT0_DESKEW_ADJUST  => "PPC",
         CLKOUT1_DESKEW_ADJUST  => "NONE",
         CLKOUT2_DESKEW_ADJUST  => "PPC",
         CLKOUT3_DESKEW_ADJUST  => "PPC",
         CLKOUT4_DESKEW_ADJUST  => "PPC",
         CLKOUT5_DESKEW_ADJUST  => "PPC",
         CLKFBOUT_DESKEW_ADJUST => "PPC"
      ) port map (
         CLKFBDCM               => open,
         CLKFBOUT               => pll1FbOut,
         CLKOUT0                => pllClk200MhzAdj,
         CLKOUT1                => open,
         CLKOUT2                => open,
         CLKOUT3                => open,
         CLKOUT4                => open,
         CLKOUT5                => open,
         CLKOUTDCM0             => open,
         CLKOUTDCM1             => open,
         CLKOUTDCM2             => open,
         CLKOUTDCM3             => open,
         CLKOUTDCM4             => open,
         CLKOUTDCM5             => open,
         DO                     => open,
         DRDY                   => open,
         LOCKED                 => pll1Locked,
         CLKFBIN                => pll1FbIn,
         CLKIN1                 => refClk125Mhz,
         CLKIN2                 => '0',
         CLKINSEL               => '1',
         DADDR                  => "00000",
         DCLK                   => '0',
         DEN                    => '0',
         DI                     => "0000000000000000",
         DWE                    => '0',
         REL                    => '0',
         RST                    => masterReset
      );

   -- Feedback buffer
   U_Pll1_FB_BUFF : BUFG port map (
      I => pll1FbOut,
      O => pll1FbIn
   );

   -- Clock buffer
   U_Pll1_CLK0_BUFF : BUFG port map (
      I => pllClk200MhzAdj,
      O => intClk200MhzAdj
   );


   -------------------------------------
   -- Reset Generation
   -------------------------------------
   asyncReset        <= masterReset or cpuRstCoreReq or cpuRstChipReq or cpuRstSystemReq;
   cpuRstCore        <= intClk312_5MhzRst;
   cpuRstChip        <= intClk312_5MhzRst;
   cpuRstSystem      <= intClk312_5MhzRst;
   cpuClk312_5MhzRst <= intClk312_5MhzRst;
   pllLocked         <= pll0Locked or pll1Locked;


   -- Reset block
   U_Rst0 :  Ppc440RceG2Rst port map (
      syncClk     => intClk312_5Mhz,
      asyncReset  => asyncReset,
      pllLocked   => pllLocked,
      syncReset   => intClk312_5MhzRst
   );

   -- Reset block
   U_Rst1 :  Ppc440RceG2Rst port map (
      syncClk     => intClk312_5MhzAdj,
      asyncReset  => asyncReset,
      pllLocked   => pllLocked,
      syncReset   => cpuClk312_5MhzAdjRst
   );

   -- Reset block
   U_Rst2 :  Ppc440RceG2Rst port map (
      syncClk     => intClk312_5Mhz90DegAdj,
      asyncReset  => asyncReset,
      pllLocked   => pllLocked,
      syncReset   => cpuClk312_5Mhz90DegAdjRst
   );

   -- Reset block
   U_Rst3 :  Ppc440RceG2Rst port map (
      syncClk     => intClk156_25MhzAdj,
      asyncReset  => asyncReset,
      pllLocked   => pllLocked,
      syncReset   => cpuClk156_25MhzAdjRst
   );

   -- Reset block
   U_Rst4 :  Ppc440RceG2Rst port map (
      syncClk     => intClk468_75Mhz,
      asyncReset  => asyncReset,
      pllLocked   => pllLocked,
      syncReset   => cpuClk468_75MhzRst
   );

   -- Reset block
   U_Rst5 :  Ppc440RceG2Rst port map (
      syncClk     => intClk200MhzAdj,
      asyncReset  => asyncReset,
      pllLocked   => pllLocked,
      syncReset   => cpuClk200MhzAdjRst
   );

end architecture STRUCTURE;

