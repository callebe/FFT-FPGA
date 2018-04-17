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

    XOutput.r <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(XInput.r)) + to_integer(signed(YInput.r)), Complex.r'LENGTH));
    XOutput.i <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(XInput.i)) + to_integer(signed(YInput.i)), Complex.r'LENGTH)); 
    YOutput.r <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(XInput.r)) - to_integer(signed(YInput.r)), Complex.r'LENGTH));
    YOutput.i <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(XInput.i)) - to_integer(signed(YInput.i)), Complex.r'LENGTH));
    
END Behavioral;