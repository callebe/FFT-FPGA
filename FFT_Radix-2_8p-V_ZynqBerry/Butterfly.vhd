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
        XInput : IN Complex;
        YInput : IN Complex;
        XOutput : OUT Complex;
        YOutput : OUT Complex
    );
END Butterfly;

ARCHITECTURE Behavioral OF Butterfly IS

BEGIN

    XOutput.r <= XInput.r + YInput.r;
    XOutput.i <= XInput.i + YInput.i; 
    YOutput.r <= XInput.r - YInput.r;
    YOutput.i <= XInput.i - YInput.i;
    
END Behavioral;