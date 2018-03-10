----------------------------------------------------------------------------------
--                         Butterfly  Basic Component
--   Concurrent components for building butterfly operation, without clock or reset
--   
--   XInput -- Even Input 
--   YInput -- Odd Input
--   XOutput -- (X + Y) 
--   YOutput -- (X - Y) This output will multiplier by twiddle factor in COrdic later
--
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Butterfly IS
    PORT( 
        XInputR : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        XInputI : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        YInputR : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        YInputI : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        XOutputR : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        XOutputI : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        YOutputR : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        YOutputI : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END Butterfly;

ARCHITECTURE Behavioral OF Butterfly IS

BEGIN

    XOutputR <= XInputR + YInputR;
    XOutputI <= XInputI + YInputI; 
    YOutputR <= XInputR - YInputR;
    YOutputI <= XInputI - YInputI;
    
END Behavioral;