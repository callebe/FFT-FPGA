----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.03.2018 02:01:29
-- Design Name: 
-- Module Name: Simulation - Behavioral
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


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Simulation is
    PORT( 
        Clock : IN STD_LOGIC;
        Start : IN STD_LOGIC;
        Output : OUT STD_LOGIC_VECTOR (25 DOWNTO 0)
    );
end Simulation;

architecture Behavioral of Simulation is

    SIGNAL SelectInputOutput : STD_LOGIC;
    SIGNAL Input : STD_LOGIC_VECTOR (11 DOWNTO 0);
    SIGNAL Counter : INTEGER RANGE 0 TO 15;
    SIGNAL StartAux : STD_LOGIC :=  '1';
    SIGNAL FinishFFT : STD_LOGIC :=  '1';
    TYPE MemoInput IS ARRAY (15 DOWNTO 0) OF STD_LOGIC_VECTOR(11 DOWNTO 0);
    CONSTANT Xin : MemoInput := (0 => "000001011101",
                                 1 => "000000111011",
                                 2 => "000000111100",
                                 3 => "000000111011",
                                 4 => "000001011101",
                                 5 => "000001111110",
                                 6 => "000001111110",
                                 7 => "000001111110",
                                 8 => "000001011100",
                                 9 => "000000111011",
                                 10 => "000000111100",
                                 11 => "000000111011",
                                 12 => "000001011101",
                                 13 => "000001111110",
                                 14 => "000001111110",
                                 15 => "000001111110");
    
begin

    F1 : FFT16p PORT MAP(Reset => '0', Clock => Clock, Start => StartAux, SelectInputOutput => SelectInputOutput, Input => Input, Output => Output, FinishFFT => FinishFFT);
    
    Input <= Xin(Counter);
    SelectInputOutput <= Clock;    
    
    PROCESS(Clock)
    
    BEGIN
        
        IF(Clock'EVENT AND Clock = '1') THEN
            IF(Start = '1') THEN
                IF(Counter = 15) THEN
                    StartAux <= '0'; 
                    
                ELSE
                    StartAux <= '1'; 
                    Counter <= Counter + 1;
                     
                    
                END IF;
                
            ELSE
                StartAux <= '0';
                Counter <= 0;
            
            END IF;
            
        END IF;
                
    END PROCESS;
    
   
        
end Behavioral;
