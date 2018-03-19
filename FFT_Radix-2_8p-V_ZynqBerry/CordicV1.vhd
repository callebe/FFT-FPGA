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
USE work.MainPackage.all;


ENTITY CordicV1 IS
    PORT(
    	Clock : IN STD_LOGIC;
    	StartCordic : IN STD_LOGIC; 
        InputCordic : IN Complex;
        FinishCordic : OUT STD_LOGIC;
        OutputCordic : OUT Complex
    );
END CordicV1;

ARCHITECTURE Behavioral OF CordicV1 IS

BEGIN

	PROCESS(Clock, StartCordic)
        
        VARIABLE Aux: Complex;

    BEGIN
        
        OutputCordic <= Aux;
        IF(Clock'EVENT AND Clock = '1') THEN
            IF(StartCordic = '1') THEN
            	Aux := InputCordic;
                FinishCordic <= '1';
            END IF;

        END IF;
            
    END PROCESS;

END Behavioral;