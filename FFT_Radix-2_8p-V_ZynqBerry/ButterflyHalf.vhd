----------------------------------------------------------------------------------
--                         Butterfly Half Basic Component
--   Concurrent components for building butterfly operation in last stage
--   
--   XInput -- Even Input 
--   YInput -- Odd Input
--   XOutput -- (X + Y) 
--
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY ButterflyHalf IS
    PORT( 
        XInput : IN Complex;
        YInput : IN Complex;
        XOutput : OUT Complex
    );
END ButterflyHalf;

ARCHITECTURE Behavioral OF ButterflyHalf IS

BEGIN

    XOutput.r <= XInput.r + YInput.r;
    XOutput.i <= XInput.i + YInput.i; 
    
END Behavioral;
