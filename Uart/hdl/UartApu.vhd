
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Ppc440RceG2Pkg.all;

entity UartApu is
   port ( 

      apuClk           : in  std_logic;
      apuClkRst        : in  std_logic;
      apuWriteFromPpc  : in  ApuWriteFromPpcType;
      apuWriteToPpc    : out ApuWriteToPpcType;

      tx               : out std_logic
   );
end UartApu;

architecture UartApu of UartApu is

   COMPONENT uart_fifo_8x1024_fwft
      PORT (
         clk   : IN  STD_LOGIC;
         rst   : IN  STD_LOGIC;
         din   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
         wr_en : IN  STD_LOGIC;
         rd_en : IN  STD_LOGIC;
         dout  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
         full  : OUT STD_LOGIC;
         empty : OUT STD_LOGIC
       );
   END COMPONENT;

   component UART_core is
      generic (
         BAUD_RATE           : positive;
         CLOCK_FREQUENCY     : positive
      );
      port (  -- General
         CLOCK100M           :   in      std_logic;
         RESET               :   in      std_logic;    
         DATA_STREAM_IN      :   in      std_logic_vector(7 downto 0);
         DATA_STREAM_IN_STB  :   in      std_logic;
         DATA_STREAM_IN_ACK  :   out     std_logic := '0';
         DATA_STREAM_OUT     :   out     std_logic_vector(7 downto 0);
         DATA_STREAM_OUT_STB :   out     std_logic;
         DATA_STREAM_OUT_ACK :   in      std_logic;
         TX                  :   out     std_logic;
         RX                  :   in      std_logic
      );
   end component;

   -- Signals
   signal fifoDout  : std_logic_vector(7 downto 0);
   signal fifoEmpty : std_logic;
   signal fifoValid : std_logic;
   signal fifoRd    : std_logic;
   signal fifoFull  : std_logic;

begin

   U_UartFifo : uart_fifo_8x1024_fwft
      PORT MAP (
         clk   => apuClk,
         rst   => apuClkRst,
         din   => apuWriteFromPpc.regB(24 to 31),
         wr_en => apuWriteFromPpc.enable,
         rd_en => fifoRd,
         dout  => fifoDout,
         full  => fifoFull,
         empty => fifoEmpty
      );

   apuWriteToPpc.full           <= fifoFull;
   fifoValid                    <= not fifoEmpty;

   U_UartCore : UART_core 
      generic map (
         BAUD_RATE       => 9600,
         CLOCK_FREQUENCY => 156250000
         --CLOCK_FREQUENCY => 234375000
      )
      port map (
         CLOCK100M           => apuClk,
         RESET               => apuClkRst,
         DATA_STREAM_IN      => fifoDout,
         DATA_STREAM_IN_STB  => fifoValid,
         DATA_STREAM_IN_ACK  => fifoRd,
         DATA_STREAM_OUT     => open,
         DATA_STREAM_OUT_STB => open,
         DATA_STREAM_OUT_ACK => '0',
         TX                  => tx,
         RX                  => '0'
      );

end UartApu;
