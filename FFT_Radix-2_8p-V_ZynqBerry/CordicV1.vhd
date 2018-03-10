----------------------------------------------------------------------------------
--                         The COrdic Processor
--
--   Sequencial component for rotate vector (X - Y) by twidle factor (W_N)^k
--   
--   YInput -- Odd Input
--   YOutput -- (X - Y) This output will multiplier by twiddle factor IN COrdic later
--
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CordicV1 IS
    PORT( 
        YInputR : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        YInputI : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        YOutputR : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        YOutputI : OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
END CordicV1;

ARCHITECTURE Behavioral OF CordicV1 IS

BEGIN

    YOutputR <= YInputR;
    YOutputI <= YInputI;

END Behavioral;