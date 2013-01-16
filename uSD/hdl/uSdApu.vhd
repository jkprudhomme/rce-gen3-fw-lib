
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Ppc440RceG2Pkg.all;

entity uSdApu is
   port ( 
      cpuClk200MhzRst  : in  std_logic;
      cpuClk200Mhz     : in  std_logic;
      apuClk           : in  std_logic;
      apuClkRst        : in  std_logic;
      apuWriteFromPpc  : in  ApuWriteFromPpcType;
      apuWriteToPpc    : out ApuWriteToPpcType;
      apuReadFromPpc   : in  ApuReadFromPpcType;
      apuReadToPpc     : out ApuReadToPpcType;
      apuLoadFromPpc   : in  ApuLoadFromPpcType;
      apuLoadToPpc     : out ApuLoadToPpcType;
      apuStoreFromPpc  : in  ApuStoreFromPpcType;
      apuStoreToPpc    : out ApuStoreToPpcType;
      apuReset         : in    std_logic;
      sdClk            : out   std_logic;
      sdCmd            : inout std_logic;
      sdData           : inout std_logic_vector(3 downto 0)
   );
end uSdApu;

architecture uSdApu of uSdApu is

   component uSDTop is 
      port (
         apuClk              : in    std_logic; 
         cmdFifoData         : in    std_logic_vector(71 downto 0);
         cmdFifoWrEn         : in    std_logic;
         resultFifoRdEn      : in    std_logic;
         writeFifoData       : in    std_logic_vector(71 downto 0);
         writeFifoWrEn       : in    std_logic;
         readFifoRdEn        : in    std_logic;
         sysClk200           : in    std_logic;
         sysRstN             : in    std_logic;
         chipScopeSel        : in    std_logic;
         resultFifoData      : out   std_logic_vector(35 downto 0);         
         readFifoData        : out   std_logic_vector(71 downto 0);         
         sdClk               : out   std_logic;
         cmdRdyRd            : out   std_logic; 
         cmdRdyWr            : out   std_logic;
         resultPending       : out   std_logic;
         cmdFifoFull         : out   std_logic;
         writeFifoFull       : out   std_logic;
         readFifoEmpty       : out   std_logic;
         sdCmd               : inout std_logic;
         sdData              : inout std_logic_vector(3 downto 0);
         sdDebug             : in    std_logic_vector(31 downto 0);
         apuReset            : in    std_logic
      );
   end component;

   -- Signals
   signal sdCmdFifoData              : std_logic_vector(71 downto 0);
   signal sdCmdFifoWrEn              : std_logic;
   signal sdResultFifoData           : std_logic_vector(35 downto 0);
   signal sdResultFifoRdEn           : std_logic;
   signal sdWriteFifoData            : std_logic_vector(71 downto 0);
   signal sdWriteFifoWrEn            : std_logic;
   signal sdReadFifoData             : std_logic_vector(71 downto 0);
   signal sdReadFifoRdEn             : std_logic;
   signal sdCmdRdyRd                 : std_logic;
   signal sdCmdRdyWr                 : std_logic;
   signal sdResultPending            : std_logic;
   signal sdSysRstN                  : std_logic;
   signal sdDebug                    : std_logic_vector(31 downto 0);
   signal sdCmdFifoFull              : std_logic;
   signal sdWriteFifoFull            : std_logic;
   signal sdReadFifoEmpty            : std_logic;

begin

   -- SD Test here
   U_microSd : uSDTop 
      port map (
         apuClk              => cpuClk234_375Mhz,
         cmdFifoData         => sdCmdFifoData,
         cmdFifoWrEn         => sdCmdFifoWrEn,
         resultFifoRdEn      => sdResultFifoRdEn,
         writeFifoData       => sdWriteFifoData,
         writeFifoWrEn       => sdWriteFifoWrEn,         
         readFifoRdEn        => sdReadFifoRdEn,
         sysClk200           => cpuClk200Mhz,
         sysRstN             => sdSysRstN,
         chipScopeSel        => chipScopeSel,        
         resultFifoData      => sdResultFifoData,
         readFifoData        => sdReadFifoData,
         sdClk               => sdClk, 
         cmdRdyRd            => sdCmdRdyRd,
         cmdRdyWr            => sdCmdRdyWr,
         resultPending       => sdResultPending,
         cmdFifoFull         => sdCmdFifoFull,
         writeFifoFull       => sdWriteFifoFull,
         readFifoEmpty       => sdReadFifoEmpty,
         sdCmd               => sdCmd,
         sdData              => sdData,
         sdDebug             => sdDebug,
         apuReset            => apuReset(0)
      );

   sdDebug   <= (others=>'0');
   sdSysRstN <= not cpuClk200MhzRst;

   sdCmdFifoData(71 downto 64)     <= (others=>'0');
   sdCmdFifoData(63 downto  0)     <= apuWriteFromPpc.regA & apuWriteFromPpc.regB;
   sdCmdFifoWrEn                   <= apuWriteFromPpc.enable;

   apuWriteToPpc.full              <= sdCmdFifoFull;

   apuReadToPpc.result             <= sdResultFifoData(31 downto 0);
   apuReadToPpc.status             <= "000" & sdResultPending;
   apuReadToPpc.empty              <= not sdResultPending;
   apuReadToPpc.ready              <= '1';
   sdResultFifoRdEn                <= apuReadFromPpc.enable;

   sdWriteFifoData(71 downto 64)   <= (others=>'0');
   sdWriteFifoData(63 downto  0)   <= apuLoadFromPpc.data(0 to 63);
   sdWriteFifoWrEn                 <= apuLoadFromPpc.enable;
   apuLoadToPpc.full               <= sdWriteFifoFull;

   apuStoreToPpc.data              <= sdReadFifoData(63 downto 0) & x"0000000000000000";
   sdReadFifoRdEn                  <= apuStoreFromPpc.enable;
   apuStoreToPpc.empty             <= sdReadFifoEmpty;
   apuStoreToPpc.ready             <= '1';

   --sdCmdRdyRd
   --sdCmdRdyWr

end uSdApu;
