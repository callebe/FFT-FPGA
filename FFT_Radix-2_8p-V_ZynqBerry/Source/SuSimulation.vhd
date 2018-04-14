----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.04.2018 19:38:51
-- Design Name: 
-- Module Name: SuSimulation - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SuSimulation is
--  Port ( );
end SuSimulation;

architecture Behavioral of SuSimulation is

    SIGNAL Clock : STD_LOGIC;
    SIGNAL Start : STD_LOGIC;
    SIGNAL Output : STD_LOGIC_VECTOR (25 DOWNTO 0);
    
    COMPONENT Simulation is
        PORT( 
            Clock : IN STD_LOGIC;
            Start : IN STD_LOGIC;
            Output : OUT STD_LOGIC_VECTOR (25 DOWNTO 0)
            );
              
    end COMPONENT;
    
begin

    N1 : Simulation PORT MAP(Clock => Clock, Start => Start, Output => Output);
    
    PROCESS
    
    BEGIN
    
        Start <= '0';
        wait for 1ns;
        Start <= '1';
        wait for 10us;
    
    END PROCESS;
    
    PROCESS
        
    BEGIN
    
        Clock <= '0';
        wait for 5ns;
        Clock <= '1';
        wait for 5ns;
        
    
    END PROCESS;
    
end Behavioral;
