-------------------------------------------------------------------------------
-- Title         : 10G MAC / Import PIC Interface
-- Project       : RCE 10G-bit MAC
-------------------------------------------------------------------------------
-- File          : XMacImport.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 02/11/2008
-------------------------------------------------------------------------------
-- Description:
-- PIC Import block for 10G MAC core for the RCE.
-------------------------------------------------------------------------------
-- Copyright (c) 2008 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 02/11/2008: created.
-- 02/23/2008: Fixed error which occurs when receiving back to back packets with
--             an idle charactor removal. crcShift4 had not cleared in time.
-- 02/29/2008: Incoming data is now ignored when phy is not ready. Byte order
--             is swapped at PIC interface. 
-- 06/06/2008: Removed header/payload re-alignment. Added automated pause frame
--             reception and transmission.
-- 08/05/2008: Added extra stages to frameShift shift register and added 
--             end detect shift register. These two shift registers replace
--             the function of crcShift register lines that are always asserted
--             in some back to back frame cases.
-------------------------------------------------------------------------------

LIBRARY ieee;
use work.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity XMacImport is 
   generic (
      FreeList : natural := 1   -- Free List For MAC
   );
   port ( 

      -- Clock & Reset
      macClk                          : in  std_logic;
      macClk2X                        : in  std_logic;
      macRst                          : in  std_logic;
      
      -- Import Interface
      Import_Clock                    : out std_logic;
      Import_Core_Reset               : in  std_logic;
      Import_Free_List                : out std_logic_vector( 3 downto 0);
      Import_Data_Valid               : out std_logic;
      Import_Data_Last_Line           : out std_logic;
      Import_Data_Last_Valid_Byte     : out std_logic_vector( 2 downto 0);
      Import_Data                     : out std_logic_vector(63 downto 0);
      Import_Data_Pipeline_Full       : in  std_logic;
      Import_Pause                    : in  std_logic;

      -- XAUI Interface
      phyRxd                          : in  std_logic_vector(63 downto 0);
      phyRxc                          : in  std_logic_vector(7  downto 0);
      phyReady                        : in  std_logic;

      -- CRC Interface
      rxCrcIn                         : out std_logic_vector(63 downto 0); 
      rxCrcDataWidth                  : out std_logic_vector(2  downto 0); 
      rxCrcDataValid                  : out std_logic; 
      rxCrcInit                       : out std_logic; 
      rxCrcReset                      : out std_logic; 
      rxCrcOut                        : in  std_logic_vector(31 downto 0); 

      -- Pause Counter Set
      rxPauseSet                      : out std_logic;
      rxPauseValue                    : out std_logic_vector(15 downto 0);

      -- Configuration
      appendCRC                       : in  std_logic
   );
end XMacImport;


-- Define architecture
architecture XMacImport of XMacImport is

   -- CRC delay FIFO
   component xmac_fifo_64x16 port (
      clk:   IN  std_logic;
      din:   IN  std_logic_VECTOR(63 downto 0);
      rd_en: IN  std_logic;
      rst:   IN  std_logic;
      wr_en: IN  std_logic;
      dout:  OUT std_logic_VECTOR(63 downto 0);
      empty: OUT std_logic;
      full:  OUT std_logic);
   end component;

   -- Local Signals
   signal frameShift0    : std_logic;
   signal frameShift1    : std_logic;
   signal frameShift2    : std_logic;
   signal frameShift3    : std_logic;
   signal frameShift4    : std_logic;
   signal frameShift5    : std_logic;
   signal rxdAlign       : std_logic;
   signal dlyRxd         : std_logic_vector(31 downto 0);
   signal crcDataWidth   : std_logic_vector(2  downto 0);
   signal locRst         : std_logic;
   signal nxtCrcWidth    : std_logic_vector(2  downto 0);
   signal nxtCrcValid    : std_logic;
   signal crcDataValid   : std_logic;
   signal fifoWr         : std_logic;
   signal fifoDin        : std_logic_vector(63 downto 0);
   signal crcFifoIn      : std_logic_vector(63 downto 0);
   signal crcFifoOut     : std_logic_vector(63 downto 0);
   signal phyRxcDly      : std_logic_vector(7  downto 0);
   signal crcWidthDly0   : std_logic_vector(2  downto 0);
   signal crcWidthDly1   : std_logic_vector(2  downto 0);
   signal crcWidthDly2   : std_logic_vector(2  downto 0);
   signal crcWidthDly3   : std_logic_vector(2  downto 0);
   signal crcShift0      : std_logic;
   signal crcShift1      : std_logic;
   signal endDetect      : std_logic;
   signal endShift0      : std_logic;
   signal endShift1      : std_logic;
   signal pauseShift2    : std_logic;
   signal pauseShift3    : std_logic;
   signal crcGood        : std_logic;
   signal impError       : std_logic;
   signal intLastLine    : std_logic;
   signal intStatus      : std_logic;
   signal intAdvance     : std_logic;
   signal lastSOF        : std_logic;
   signal pauseDet       : std_logic;
   signal dlyPause       : std_logic;
   signal intPause       : std_logic;

   -- These appear in bits 7:3, bit 7 should never be set, bit 0 will be set externally
   constant ERR_BAD_PACKET : std_logic_vector(4 downto 0) := "00011"; -- 0x19
   constant ERR_OVERRUN    : std_logic_vector(4 downto 0) := "01111"; -- 0x79
   
   -- Register delay for simulation
   constant tpd:time := 0.1 ns;

begin

   -- Output import clock
   Import_Clock <= macClk;

   -- Generate local reset
   locRst <= Import_Core_Reset or macRst;

   -- CRC Input
   rxCrcDataWidth        <= crcDataWidth;
   rxCrcDataValid        <= crcDataValid;
   rxCrcReset            <= locRst or not phyReady;
   rxCrcIn(63 downto 56) <= crcFifoIn(7  downto  0);
   rxCrcIn(55 downto 48) <= crcFifoIn(15 downto  8);
   rxCrcIn(47 downto 40) <= crcFifoIn(23 downto 16);
   rxCrcIn(39 downto 32) <= crcFifoIn(31 downto 24);
   rxCrcIn(31 downto 24) <= crcFifoIn(39 downto 32);
   rxCrcIn(23 downto 16) <= crcFifoIn(47 downto 40);
   rxCrcIn(15 downto  8) <= crcFifoIn(55 downto 48);
   rxCrcIn(7  downto  0) <= crcFifoIn(63 downto 56);

   -- Detect good CRC
   crcGood <= '1' when rxCrcOut = X"E320BBDE" else '0';

   -- Import interface
   Import_Free_List      <= conv_std_logic_vector(FreeList,4);
   Import_Data_Last_Line <= intLastLine;
   Import_Data_Valid     <= intAdvance;


   -- Logic to dermine CRC width and valid clear timing.
   process ( phyRxc, rxdAlign, phyRxcDly, crcDataWidth, crcDataValid ) begin

      -- Non shifted data
      if rxdAlign = '0' then
         case phyRxc is
            when x"00"  => nxtCrcWidth <= "111"; nxtCrcValid <= '1'; 
            when x"FE"  => nxtCrcWidth <= "000"; nxtCrcValid <= '1'; 
            when x"FC"  => nxtCrcWidth <= "001"; nxtCrcValid <= '1';
            when x"F8"  => nxtCrcWidth <= "010"; nxtCrcValid <= '1';
            when x"F0"  => nxtCrcWidth <= "011"; nxtCrcValid <= '1';
            when x"E0"  => nxtCrcWidth <= "100"; nxtCrcValid <= '1';
            when x"C0"  => nxtCrcWidth <= "101"; nxtCrcValid <= '1';
            when x"80"  => nxtCrcWidth <= "110"; nxtCrcValid <= '1';
            when x"FF"  => nxtCrcWidth <= "000"; nxtCrcValid <= '0';
            when others => nxtCrcWidth <= "000"; nxtCrcValid <= '0';
         end case;

      -- Shifted data
      else 

         -- Some widths look at the shifted control output
         case phyRxcDly is 
            when x"E0"  => nxtCrcWidth <= "000"; nxtCrcValid <= '1';
            when x"C0"  => nxtCrcWidth <= "001"; nxtCrcValid <= '1';
            when x"80"  => nxtCrcWidth <= "010"; nxtCrcValid <= '1';
            when x"F0"  => nxtCrcWidth <= "000"; nxtCrcValid <= '0';
            when x"FF"  => nxtCrcWidth <= "000"; nxtCrcValid <= '0';
            when x"00"  =>

               -- other widths look at the direct control output
               case phyRxc is
                  when x"FF"  => nxtCrcWidth <= "011";        nxtCrcValid <= '1';
                  when x"FE"  => nxtCrcWidth <= "100";        nxtCrcValid <= '1';
                  when x"FC"  => nxtCrcWidth <= "101";        nxtCrcValid <= '1';
                  when x"F8"  => nxtCrcWidth <= "110";        nxtCrcValid <= '1';
                  when others => nxtCrcWidth <= crcDataWidth; nxtCrcValid <= crcDataValid;
               end case;
            when others => nxtCrcWidth <= "000"; nxtCrcValid <= '0';
         end case;
      end if;
   end process;


   -- Delay stages and input to CRC block   
   process ( macClk, macRst ) begin
      if macRst = '1' then
         frameShift0    <= '0'           after tpd;
         frameShift1    <= '0'           after tpd;
         frameShift2    <= '0'           after tpd;
         frameShift3    <= '0'           after tpd;
         frameShift4    <= '0'           after tpd;
         frameShift5    <= '0'           after tpd;
         rxdAlign       <= '0'           after tpd;
         lastSOF        <= '0'           after tpd;
         dlyRxd         <= (others=>'0') after tpd;
         rxCrcInit      <= '0'           after tpd;
         crcDataValid   <= '0'           after tpd;
         crcDataWidth   <= "000"         after tpd;
         endDetect      <= '0'           after tpd;
         crcFifoIn      <= (others=>'0') after tpd;
         phyRxcDly      <= (others=>'0') after tpd;
         pauseDet       <= '0'           after tpd;
         rxPauseValue   <= (others=>'0') after tpd;
      elsif rising_edge(macClk) then

         -- Delayed copy of control signals
         phyRxcDly <= phyRxc after tpd;

         -- Detect SOF in shifted position
         if phyRxC(4) = '1' and phyRxd(39 downto 32) = x"FB" then
            lastSOF <= '1' after tpd;
         else
            lastSOF <= '0' after tpd;
         end if;

         -- Detect start of frame
         -- normal alignment
         if phyRxC(0) = '1' and phyRxd(7 downto 0) = x"FB" and phyReady = '1' then
            frameShift0 <= '1' after tpd;
            rxdAlign    <= '0' after tpd;

         -- shifted aligment
         elsif lastSOF = '1' and phyReady = '1' then
            frameShift0 <= '1' after tpd;
            rxdAlign    <= '1' after tpd;

         -- Detect end of frame
         elsif phyRxc /= 0 and frameShift0 = '1' then
            frameShift0 <= '0' after tpd;
         end if;

         -- Frame shift register
         frameShift1 <= frameShift0 after tpd;
         frameShift2 <= frameShift1 after tpd;
         frameShift3 <= frameShift2 after tpd;
         frameShift4 <= frameShift3 after tpd;
         frameShift5 <= frameShift4 after tpd;

         -- Delayed copy of upper data
         dlyRxd <= phyRxd(63 downto 32) after tpd;

         -- CRC Valid Signal
         if frameShift0 = '1' and frameShift1 = '0' then
            rxCrcInit    <= '1'   after tpd;
            crcDataValid <= '1'   after tpd;
            crcDataWidth <= "111" after tpd;
         else
            rxCrcInit <= '0' after tpd;

            -- Clear valid when width is not zero
            if crcDataWidth /= 7 then
               crcDataValid <= '0'           after tpd;
               crcDataWidth <= (others=>'0') after tpd;
            else
               crcDataValid <= nxtCrcValid after tpd;
               crcDataWidth <= nxtCrcWidth after tpd;
            end if;
         end if;

         -- End Detection
         if (crcDataWidth /= 7 or nxtCrcValid = '0') and crcDataValid = '1' then
            endDetect <= '1' after tpd;
         else
            endDetect <= '0' after tpd;
         end if;

         -- CRC & FIFO Input data
         if rxdAlign = '0' then
            crcFifoIn <= phyRxd after tpd;
         else
            crcFifoIn(63 downto 32) <= phyRxd(31 downto 0) after tpd;
            crcFifoIn(31 downto  0) <= dlyRxd              after tpd;
         end if;

         -- Pause frame detection
         if frameShift2 = '1' and frameShift3 = '0' and crcFifoIn(63 downto 32) = x"01000888" then
            pauseDet <= '1' after tpd;
         else
            pauseDet <= '0' after tpd;
         end if;

         -- Pause frame value
         if pauseDet = '1' then
            rxPauseValue <= (crcFifoIn(7 downto 0) & crcFifoIn(15 downto 8)) after tpd;
         end if;

      end if;
   end process;


   -- CRC Delay FIFO
   U_CrcFifo: xmac_fifo_64x16 port map (
      clk    => macClk,
      din    => crcFifoIn,
      rd_en  => crcShift1,
      rst    => macRst,
      wr_en  => crcDataValid,
      dout   => crcFifoOut,
      empty  => open,
      full   => open
   );


   -- Delay stages for output of CRC delay chain
   process ( macClk, macRst ) begin
      if macRst = '1' then
         Import_Data_Last_Valid_Byte  <= (others=>'0') after tpd;
         Import_Data                  <= (others=>'0') after tpd;
         crcShift0                    <= '0'           after tpd;
         crcShift1                    <= '0'           after tpd;
         endShift0                    <= '0'           after tpd;
         endShift1                    <= '0'           after tpd;
         pauseShift2                  <= '0'           after tpd;
         pauseShift3                  <= '0'           after tpd;
         crcWidthDly0                 <= (others=>'0') after tpd;
         crcWidthDly1                 <= (others=>'0') after tpd;
         crcWidthDly2                 <= (others=>'0') after tpd;
         crcWidthDly3                 <= (others=>'0') after tpd;
         impError                     <= '0'           after tpd;
         intLastLine                  <= '0'           after tpd;
         intAdvance                   <= '0'           after tpd;
         dlyPause                     <= '0'           after tpd;
         intPause                     <= '0'           after tpd;
         rxPauseSet                   <= '0'           after tpd;
      elsif rising_edge(macClk) then

         -- CRC output shift stages
         crcShift0 <= crcDataValid after tpd;
         crcShift1 <= crcShift0    after tpd;

         -- CRC Width Delay Stages
         crcWidthDly0 <= crcDataWidth after tpd;
         crcWidthDly1 <= crcWidthDly0 after tpd;
         crcWidthDly2 <= crcWidthDly1 after tpd;
         crcWidthDly3 <= crcWidthDly2 after tpd;

         -- Last Data Shift
         endShift0    <= endDetect after tpd;
         endShift1    <= endShift0 after tpd;

         -- Pause Detection Delay Stages
         pauseShift2 <= pauseDet or (pauseShift2 and frameShift3) after tpd;
         pauseShift3 <= pauseShift2                               after tpd;

         -- Output data
         -- Converting from Big Endian to little
         Import_Data(63 downto 56) <= crcFifoOut(7  downto  0) after tpd;
         Import_Data(55 downto 48) <= crcFifoOut(15 downto  8) after tpd;
         Import_Data(47 downto 40) <= crcFifoOut(23 downto 16) after tpd;
         Import_Data(39 downto 32) <= crcFifoOut(31 downto 24) after tpd;
         Import_Data(31 downto 24) <= crcFifoOut(39 downto 32) after tpd;
         Import_Data(23 downto 16) <= crcFifoOut(47 downto 40) after tpd;
         Import_Data(15 downto  8) <= crcFifoOut(55 downto 48) after tpd;
         Import_Data( 7 downto  0) <= crcFifoOut(63 downto 56) after tpd;

--          Import_Data(63 downto 56) <= crcFifoOut(39 downto 32) after tpd;
--          Import_Data(55 downto 48) <= crcFifoOut(47 downto 40) after tpd;
--          Import_Data(47 downto 40) <= crcFifoOut(55 downto 48) after tpd;
--          Import_Data(39 downto 32) <= crcFifoOut(63 downto 56) after tpd;
--          Import_Data(31 downto 24) <= crcFifoOut( 7 downto  0) after tpd;
--          Import_Data(23 downto 16) <= crcFifoOut(15 downto  8) after tpd;
--          Import_Data(15 downto  8) <= crcFifoOut(23 downto 16) after tpd;
--          Import_Data( 7 downto  0) <= crcFifoOut(31 downto 24) after tpd;

         -- Pause Frame Received, assert for two clocks
         intPause   <= intLastLine and crcGood and (pauseShift2 or pauseShift3) after tpd;
         dlyPause   <= intPause after tpd;
         rxPauseSet <= intPause or dlyPause after tpd;

         -- Detect import error
         if intAdvance = '0' then
            impError <= '0' after tpd;
         elsif Import_Data_Pipeline_Full = '1' then
            impError <= '1' after tpd;
         end if;

         -- Determine when data is output
         if frameShift4 = '1' and frameShift5 = '0' and pauseShift2 = '0' then
            intAdvance <= '1' after tpd;
         elsif intLastLine = '1' then
            intAdvance <= '0' after tpd;
         end if;

         -- Determine Last Line
         -- CRC Not Appended
         if appendCRC = '0' then
            if endShift0 = '1' and crcWidthDly1 = 0 then
               Import_Data_Last_Valid_Byte <= "100" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift0 = '1' and crcWidthDly1 = 1 then
               Import_Data_Last_Valid_Byte <= "101" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift0 = '1' and crcWidthDly1 = 2 then
               Import_Data_Last_Valid_Byte <= "110" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift0 = '1' and crcWidthDly1 = 3 then
               Import_Data_Last_Valid_Byte <= "111" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift1 = '1' and crcWidthDly2 = 4 then
               Import_Data_Last_Valid_Byte <= "000" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift1 = '1' and crcWidthDly2 = 5 then
               Import_Data_Last_Valid_Byte <= "001" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift1 = '1' and crcWidthDly2 = 6 then
               Import_Data_Last_Valid_Byte <= "010" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift1 = '1' and crcWidthDly2 = 7 then
               Import_Data_Last_Valid_Byte <= "011" after tpd;
               intLastLine                 <= '1'   after tpd;
            else
               Import_Data_Last_Valid_Byte <= "000" after tpd;
               intLastLine                 <= '0'   after tpd;
            end if;

         -- CRC Appended
         else 
            if endShift1 = '1' and crcWidthDly2 = 0 then
               Import_Data_Last_Valid_Byte <= "000" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift1 = '1' and crcWidthDly2 = 1 then
               Import_Data_Last_Valid_Byte <= "001" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift1 = '1' and crcWidthDly2 = 2 then
               Import_Data_Last_Valid_Byte <= "010" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift1 = '1' and crcWidthDly2 = 3 then
               Import_Data_Last_Valid_Byte <= "011" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift1 = '1' and crcWidthDly2 = 4 then
               Import_Data_Last_Valid_Byte <= "100" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift1 = '1' and crcWidthDly2 = 5 then
               Import_Data_Last_Valid_Byte <= "101" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift1 = '1' and crcWidthDly2 = 6 then
               Import_Data_Last_Valid_Byte <= "110" after tpd;
               intLastLine                 <= '1'   after tpd;
            elsif endShift1 = '1' and crcWidthDly2 = 7 then
               Import_Data_Last_Valid_Byte <= "111" after tpd;
               intLastLine                 <= '1'   after tpd;
            else
               Import_Data_Last_Valid_Byte <= "000" after tpd;
               intLastLine                 <= '0'   after tpd;
            end if;
         end if;
      end if;
   end process;

end XMacImport;

