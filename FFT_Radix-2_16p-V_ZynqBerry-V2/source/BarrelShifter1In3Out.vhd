----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Callebe S. Barbosa
-- 
-- Create Date: 06.10.2018 17:44:00
-- Design Name: 
-- Module Name: BarrelShifter1In3Out
-- Project Name: FFT1024p
-- Target Devices: ZynqBerry-7010 (XC7Z010-1CLG225C)
-- Tool Versions: Vivado 2017.4
-- Description: Barrel Shifter for Cordic Processor
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BarrelShifter1In3Out is
    Port(
        Input : in SIGNED (15 downto 0);
        Output1 : out SIGNED (15 downto 0);
        Output2 : out SIGNED (15 downto 0);
        Output3 : out SIGNED (15 downto 0);
        S1 : in STD_LOGIC_VECTOR (3 downto 0);
        S2 : in STD_LOGIC_VECTOR (3 downto 0);
        S3 : in STD_LOGIC_VECTOR (3 downto 0)
    );
end BarrelShifter1In3Out;

architecture Behavioral of BarrelShifter1In3Out is

begin

    
    -- S1 Output
    with S1 Select
        Output1 <= Input when "0000",
                Input(15) & Input(15 downto 1) when "0001",
                Input(15) & Input(15) & Input(15 downto 2) when "0010",
                Input(15) & Input(15) & Input(15) & Input(15 downto 3) when "0011",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 4) when "0100",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 5) when "0101",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 6) when "0110",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 7) when "0111",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 8) when "1000",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 9) when "1001",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 10) when "1010",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 11) when "1011",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 12) when "1100",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 13) when "1101",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 14) when "1110",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) when others;    
                
    -- S2 Output
    with S2 Select
        Output2 <= Input when "0000",
                Input(15) & Input(15 downto 1) when "0001",
                Input(15) & Input(15) & Input(15 downto 2) when "0010",
                Input(15) & Input(15) & Input(15) & Input(15 downto 3) when "0011",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 4) when "0100",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 5) when "0101",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 6) when "0110",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 7) when "0111",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 8) when "1000",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 9) when "1001",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 10) when "1010",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 11) when "1011",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 12) when "1100",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 13) when "1101",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 14) when "1110",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) when others;

    -- S3 Output
    with S3 Select
        Output3 <= Input when "0000",
                Input(15) & Input(15 downto 1) when "0001",
                Input(15) & Input(15) & Input(15 downto 2) when "0010",
                Input(15) & Input(15) & Input(15) & Input(15 downto 3) when "0011",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 4) when "0100",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 5) when "0101",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 6) when "0110",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 7) when "0111",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 8) when "1000",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 9) when "1001",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 10) when "1010",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 11) when "1011",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 12) when "1100",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 13) when "1101",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15 downto 14) when "1110",
                Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) & Input(15) when others;     

end Behavioral;
