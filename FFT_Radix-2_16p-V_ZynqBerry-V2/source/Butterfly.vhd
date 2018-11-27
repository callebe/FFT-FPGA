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
USE work.MainPackage.all;

ENTITY Butterfly IS
    PORT( 
        XInput : IN signed(31 downto 0);
        YInput : IN signed(31 downto 0);
        XOutput : OUT signed(31 downto 0);
        YOutput : OUT signed(31 downto 0)
    );
END Butterfly;

ARCHITECTURE Behavioral OF Butterfly IS

BEGIN

    XOutput(31 downto 16) <= to_signed(to_integer(XInput(31 downto 16)) + to_integer(YInput(31 downto 16)), 16);
    XOutput(15 downto 0 ) <= to_signed(to_integer(XInput(15 downto 0 )) + to_integer(YInput(15 downto 0 )), 16); 
    YOutput(31 downto 16) <= to_signed(to_integer(XInput(31 downto 16)) - to_integer(YInput(31 downto 16)), 16);
    YOutput(15 downto 0 ) <= to_signed(to_integer(XInput(15 downto 0 )) - to_integer(YInput(15 downto 0 )), 16);
    
END Behavioral;