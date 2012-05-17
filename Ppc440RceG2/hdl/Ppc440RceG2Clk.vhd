

library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.numeric_std.all;

library Unisim;
use Unisim.vcomponents.all;

entity Ppc440RceG2Clk is
   port (

      -- Inputs
      refClk125Mhz               : in  std_logic;
      masterReset                : in  std_logic;
      pllLocked                  : out std_logic;

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
   signal pll0Fb                     : std_logic;
   signal pll0Locked                 : std_logic;
   signal pll1Fb                     : std_logic;
   signal pll1Locked                 : std_logic;
   signal pllClk312_5Mhz             : std_logic;
   signal pllClk312_5MhzAdj          : std_logic;
   signal pllClk312_5Mhz90DegAdj     : std_logic;
   signal pllClk156_25MhzAdj         : std_logic;
   signal pllClk468_75Mhz            : std_logic;
   signal pllClk200MhzAdj            : std_logic;
   signal intClk312_5Mhz             : std_logic; 
   signal intClk312_5MhzAdj          : std_logic;
   signal intClk312_5Mhz90DegAdj     : std_logic;
   signal intClk156_25MhzAdj         : std_logic;
   signal intClk468_75Mhz            : std_logic;
   signal intClk200MhzAdj            : std_logic;
   signal asyncReset                 : std_logic;
   signal asyncResetCore             : std_logic;
   signal asyncResetChip             : std_logic;
   signal asyncResetSystem           : std_logic;
   signal intLocked                  : std_logic;
   signal cpuRstCoreReqD0            : std_logic;
   signal cpuRstChipReqD0            : std_logic;
   signal cpuRstSystemReqD0          : std_logic;
   signal cpuRstCoreReqD1            : std_logic;
   signal cpuRstChipReqD1            : std_logic;
   signal cpuRstSystemReqD1          : std_logic;
   signal cpuRstCoreReqD2            : std_logic;
   signal cpuRstChipReqD2            : std_logic;
   signal cpuRstSystemReqD2          : std_logic;
   signal cpuRstCoreReqEdge          : std_logic;
   signal cpuRstChipReqEdge          : std_logic;
   signal cpuRstSystemReqEdge        : std_logic;
   signal intClk312_5MhzRst          : std_logic;
   signal intClk312_5MhzAdjRst       : std_logic;
   signal intClk312_5Mhz90DegAdjRst  : std_logic;
   signal intClk156_25MhzAdjRst      : std_logic;
   signal intClk468_75MhzRst         : std_logic;
   signal intClk200MhzAdjRst         : std_logic;
   signal intNotReady                : std_logic;

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
   intLocked              <= pll0Locked or pll1Locked;
   pllLocked              <= intLocked;

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
         CLKFBOUT               => pll0Fb,
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
         CLKFBIN                => pll0Fb,
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
         CLKFBOUT               => pll1Fb,
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
         CLKFBIN                => pll1Fb,
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

   -- Clock buffer
   U_Pll1_CLK0_BUFF : BUFG port map (
      I => pllClk200MhzAdj,
      O => intClk200MhzAdj
   );


   -------------------------------------
   -- Reset Generation
   -------------------------------------
   cpuClk312_5MhzRst          <= intClk312_5MhzRst;
   cpuClk312_5MhzAdjRst       <= intClk312_5MhzAdjRst;
   cpuClk312_5Mhz90DegAdjRst  <= intClk312_5Mhz90DegAdjRst;
   cpuClk156_25MhzAdjRst      <= intClk156_25MhzAdjRst;
   cpuClk468_75MhzRst         <= intClk468_75MhzRst;
   cpuClk200MhzAdjRst         <= intClk200MhzAdjRst;
   asyncReset                 <= masterReset;
   intNotReady                <= intClk312_5MhzRst or intClk312_5MhzAdjRst or
                                 intClk312_5Mhz90DegAdjRst or intClk156_25MhzAdjRst or
                                 intClk468_75MhzRst or intClk200MhzAdjRst;
   asyncResetCore             <= masterReset or intNotReady or cpuRstCoreReqEdge;
   asyncResetChip             <= masterReset or intNotReady or cpuRstChipReqEdge;
   asyncResetSystem           <= masterReset or intNotReady or cpuRstSystemReqEdge;

   -- Edge detect core reset requests
   process ( intClk312_5Mhz ) begin
      if rising_edge( intClk312_5Mhz ) then

         cpuRstCoreReqD0      <= cpuRstCoreReq                                 after tpd;
         cpuRstCoreReqD1      <= cpuRstCoreReqD0                               after tpd;
         cpuRstCoreReqD2      <= cpuRstCoreReqD1                               after tpd;
         cpuRstCoreReqEdge    <= cpuRstCoreReqD1   and (not cpuRstCoreReqD2)   after tpd;

         cpuRstChipReqD0      <= cpuRstChipReq                                 after tpd;
         cpuRstChipReqD1      <= cpuRstChipReqD0                               after tpd;
         cpuRstChipReqD2      <= cpuRstChipReqD1                               after tpd;
         cpuRstChipReqEdge    <= cpuRstChipReqD1   and (not cpuRstChipReqD2)   after tpd;

         cpuRstSystemReqD0    <= cpuRstSystemReq                               after tpd;
         cpuRstSystemReqD1    <= cpuRstSystemReqD0                             after tpd;
         cpuRstSystemReqD2    <= cpuRstSystemReqD1                             after tpd;
         cpuRstSystemReqEdge  <= cpuRstSystemReqD1 and (not cpuRstSystemReqD2) after tpd;

      end if;
   end process;

   -- Reset block
   U_Rst0 :  Ppc440RceG2Rst port map (
      syncClk     => intClk312_5Mhz,
      asyncReset  => asyncReset,
      pllLocked   => intLocked,
      syncReset   => intClk312_5MhzRst
   );

   -- Reset block
   U_Rst1 :  Ppc440RceG2Rst port map (
      syncClk     => intClk312_5MhzAdj,
      asyncReset  => asyncReset,
      pllLocked   => intLocked,
      syncReset   => intClk312_5MhzAdjRst
   );

   -- Reset block
   U_Rst2 :  Ppc440RceG2Rst port map (
      syncClk     => intClk312_5Mhz90DegAdj,
      asyncReset  => asyncReset,
      pllLocked   => intLocked,
      syncReset   => intClk312_5Mhz90DegAdjRst
   );

   -- Reset block
   U_Rst3 :  Ppc440RceG2Rst port map (
      syncClk     => intClk156_25MhzAdj,
      asyncReset  => asyncReset,
      pllLocked   => intLocked,
      syncReset   => intClk156_25MhzAdjRst
   );

   -- Reset block
   U_Rst4 :  Ppc440RceG2Rst port map (
      syncClk     => intClk468_75Mhz,
      asyncReset  => asyncReset,
      pllLocked   => intLocked,
      syncReset   => intClk468_75MhzRst
   );

   -- Reset block
   U_Rst5 :  Ppc440RceG2Rst port map (
      syncClk     => intClk200MhzAdj,
      asyncReset  => asyncReset,
      pllLocked   => intLocked,
      syncReset   => intClk200MhzAdjRst
   );

   -- Reset block
   U_Rst6 :  Ppc440RceG2Rst port map (
      syncClk     => intClk312_5Mhz,
      asyncReset  => asyncResetCore,
      pllLocked   => intLocked,
      syncReset   => cpuRstCore
   );

   -- Reset block
   U_Rst7 :  Ppc440RceG2Rst port map (
      syncClk     => intClk312_5Mhz,
      asyncReset  => asyncResetChip,
      pllLocked   => intLocked,
      syncReset   => cpuRstChip
   );

   -- Reset block
   U_Rst8 :  Ppc440RceG2Rst port map (
      syncClk     => intClk312_5Mhz,
      asyncReset  => asyncResetSystem,
      pllLocked   => intLocked,
      syncReset   => cpuRstSystem
   );

end architecture STRUCTURE;

