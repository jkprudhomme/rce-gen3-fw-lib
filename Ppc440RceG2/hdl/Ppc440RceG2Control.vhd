
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.Ppc440RceG2Pkg.all;
use work.Version.all;

-- Address Map
--    0x00      = Version (read only)
--    0x01      = Reset   (write only)
--    0x02      = Timer   (read only)
--    0x10      = Enable  - Crit Interrupt
--    0x11      = Status  - Crit Interrupt
--    0x12      = Enable  - Ext Interrupt 0
--    0x13      = Status  - Ext Interrupt 0
--    0x14      = Enable  - Ext Interrupt 1
--    0x15      = Status  - Ext Interrupt 1
--    0x16      = Enable  - Ext Interrupt 2
--    0x17      = Status  - Ext Interrupt 2
--    0x18      = Enable  - Ext Interrupt 3
--    0x19      = Status  - Ext Interrupt 3
--    0x1A      = Enable  - Ext Interrupt 4
--    0x1B      = Status  - Ext Interrupt 4
--    0x1C      = Enable  - Ext Interrupt 5
--    0x1D      = Status  - Ext Interrupt 5
--    0x1E      = Enable  - Ext Interrupt 6
--    0x1F      = Status  - Ext Interrupt 6

entity Ppc440RceG2Control is
  port (

    -- Clock & Reset Inputs
    apuClk                     : in  std_logic;
    apuClkRst                  : in  std_logic;

    -- APU Interface
    apuReadFromPpc             : in  ApuReadFromPpcType;
    apuReadToPpc               : out ApuReadToPpcType;

    -- Write instructions
    apuWriteFromPpc            : in  ApuWriteFromPpcType;
    apuWriteToPpc              : out ApuWriteToPpcType;

    -- Reset
    apuReset                   : out std_logic_vector(0 to 31);
    extInt                     : out std_logic;
    critInt                    : out std_logic;

    -- Full/Empty Bits
    apuWriteFull               : in  std_logic_vector(0 to 7);
    apuReadEmpty               : in  std_logic_vector(0 to 7);
    apuLoadFull                : in  std_logic_vector(0 to 31);
    apuStoreEmpty              : in  std_logic_vector(0 to 31)
  );
end Ppc440RceG2Control;

architecture structure of Ppc440RceG2Control is

   -- Local type
   subtype CNTL_WORD16 is STD_LOGIC_VECTOR (0 to 15);
   type cntl_word16_array is array ( NATURAL range <> ) of CNTL_WORD16;

   -- Local signals
   signal intMapping  : cntl_word16_array(0 to 7);
   signal intIncoming : cntl_word16_array(0 to 7);
   signal intStatus   : cntl_word16_array(0 to 7);
   signal intEnable   : cntl_word16_array(0 to 7);
   signal readAddr    : std_logic_vector(0 to 4);
   signal writeAddr   : std_logic_vector(0 to 4);
   signal writeData   : std_logic_vector(0 to 31);
   signal intOutput   : std_logic_vector(0 to 7);
   signal iextInt     : std_logic;
   signal icritInt    : std_logic;
   signal itimer      : std_logic_vector(0 to 15);

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin

   -- Unused
   apuReadToPpc.status <= (others=>'0');
   apuWriteToPpc.full  <= '0';
   apuReadToPpc.empty  <= '1';
   apuReadToPpc.ready  <= '1';
   -- apuReadFromPpc.regB
   -- apuReadFromPpc.enable

   -- Read Address
   readAddr  <= apuReadFromPpc.regA(27 to 31);
   writeAddr <= apuWriteFromPpc.regA(27 to 31);
   writeData <= apuWriteFromPpc.regB;
  
   -- Connect incoming signals
   intMapping(0) <= (not apuReadEmpty) & apuWriteFull;   -- 0x10, 0x11 Critical
   intMapping(1) <= (not apuReadEmpty) & apuWriteFull;   -- 0x12, 0x13 External 0
   intMapping(2) <= apuLoadFull(16 to 31);               -- 0x14, 0x15 External 1
   intMapping(3) <= apuLoadFull(0  to 15);               -- 0x16, 0x17 External 2
   intMapping(4) <= not apuStoreEmpty(16 to 31);         -- 0x18, 0x19 External 3
   intMapping(5) <= not apuStoreEmpty(0  to 15);         -- 0x1A, 0x1B External 4
   intMapping(6) <= (others=>'0');                       -- 0x1C, 0x1D External 5
   intMapping(7) <= (others=>'0');                       -- 0x1E, 0x1F External 6

   -- Register incoming signals
   IN_GEN : for i in 0 to 7 generate
      process (apuClk, apuClkRst ) begin
         if apuClkRst = '1' then
            intIncoming(i) <= (others=>'0') after tpd;
         elsif rising_edge(apuClk) then
            intIncoming(i) <= intMapping(i) after tpd;
         end if;
      end process;
   end generate;

   -- Register readback
   apuReadToPpc.result <= 

      -- FPGA Version Read, 0x00
      FpgaVersion when readAddr = 0 else 

      -- Timer Read, 0x02
      FpgaVersion when readAddr = 2 else 

      -- Interrupt enable register, 0x10, 0x12, 0x14, 0x16, 0x18, 0x1A, 0x1C, 0x1E
      itimer & intEnable(conv_integer(readAddr(1 to 3))) when readAddr(0) = '1' and readAddr(4) = '0' else

      -- Interrupt status register, 0x11, 0x13, 0x15, 0x17, 0x19, 0x1B, 0x1D, 0x1F
      itimer & intStatus(conv_integer(readAddr(1 to 3))) when readAddr(0) = '1' and readAddr(4) = '1' else

      -- Other addresses
      x"00000000";


   -- Interrupt control
   WR_GEN : for i in 0 to 7 generate
      process (apuClk, apuClkRst ) begin
         if apuClkRst = '1' then
            intStatus(i) <= (others=>'0') after tpd;
            intEnable(i) <= (others=>'0') after tpd;
            intOutput(i) <= '0'           after tpd;
         elsif rising_edge(apuClk) then

            -- Gated interrupt status
            intStatus(i) <= intEnable(i) and intIncoming(i) after tpd;

            -- Enable signals: (current and !mask) or (mask and set)
            -- writeData(0  to 15) = mask
            -- writeData(16 to 31) = set
            if apuWriteFromPpc.enable = '1' and writeAddr(0) = '1' and writeAddr(4) = '0' and writeAddr(1 to 3) = i then
               intEnable(i) <= (intEnable(i) and (not writeData(0 to 15))) or (writeData(0 to 15) and writeData(16 to 31));
            end if;

            -- Interrupt
            if intStatus(i) = 0 then
               intOutput(i) <= '0' after tpd;
            else 
               intOutput(i) <= '1' after tpd;
            end if;
         end if;
      end process;
   end generate;

   -- Outgoing interrupt signal
   process (apuClk, apuClkRst ) begin
      if apuClkRst = '1' then
         iextInt  <= '0' after tpd;
         icritInt <= '0' after tpd;
      elsif rising_edge(apuClk) then

         -- External interrupt
         if intOutput(1 to 7) = 0 then
            iextInt <= '0' after tpd;
         else
            iextInt <= '1' after tpd;
         end if;

         -- Critical interrupt
         icritInt <= intOutput(0) after tpd;

      end if;
   end process;

   -- Outgoing interrupt
   extInt  <= iextInt;
   critInt <= icritInt;

   -- Generate reset pulse
   process (apuClk, apuClkRst ) begin
      if apuClkRst = '1' then
         apuReset <= (others=>'0') after tpd;
         itimer   <= (others=>'0') after tpd;
      elsif rising_edge(apuClk) then
         itimer <= itimer + 1 after tpd;
         if apuWriteFromPpc.enable = '1' and writeAddr(0 to 4) = 1 then
            apuReset <= writeData after tpd;
         else
            apuReset <= (others=>'0') after tpd;
         end if;
      end if;
   end process;

   -- sythesis translate_off
   process (iextInt, icritInt) begin
      if rising_edge(iextInt) then
         report "External Interrupt asserted!";
      end if;
      if rising_edge(icritInt) then
         report "Critical Interrupt asserted!";
      end if;
   end process;
   -- sythesis translate_on

end architecture;

