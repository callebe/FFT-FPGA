----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.11.2018 09:24:48
-- Design Name: 
-- Module Name: Teste - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.MainPackage.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Teste is
    Port (
          Clock : in STD_LOGIC;
          FinishFFT : out STD_LOGIC;
          OutputFFT : out Array_Vector_16b(15 downto 0)
      );
end Teste;

architecture Behavioral of Teste is

    signal StartFFT : STD_LOGIC;
    constant InputFFT : Array_Vector_16b(15 downto 0) := (
        0  => "0000001101011001",
        1  => "0000010100000100",
        2  => "0000010110010100",
        3  => "0000011000111011",
        4  => "0000010011100000",
        5  => "0000010010011101",
        6  => "0000001100111111",
        7  => "0000001101001110",
        8  => "0000001100010111",
        9  => "0000001011101001",
        10 => "0000001011100000",
        11 => "0000000110011100",
        12 => "0000000110010101",
        13 => "0000000010100111",
        14 => "0000000111010011",
        15 => "0000001010101111"
        );
        
begin

    FFT : FFT16p Port Map (
            Clock => Clock,
            StartFFT => StartFFT,
            InputFFT => InputFFT,
            FinishFFT => FinishFFT,
            OutputFFT => OutputFFT
    );
    
    process(clock)
    
        variable counter : integer range 0 to 15 := 0;
        
    begin
    
        if(clock'event and clock = '1') then
            if(counter = 15) then
                StartFFT <= '1';
                
            else
                StartFFT <= '0';
                counter := counter + 1;
                
            end if;
            
        end if;
        
    end process;

end Behavioral;
