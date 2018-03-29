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
    GENERIC(
            NFFT : INTEGER
    );
    PORT(
    	Clock : IN STD_LOGIC;
    	Reset : IN STD_LOGIC;
        XInputCordic : IN Complex;
        YInputCordic : IN Complex;
        XOutputCordic : OUT Complex;
        YOutputCordic : OUT Complex
    );
END CordicV1;

ARCHITECTURE Behavioral OF CordicV1 IS
        
BEGIN
    
	PROCESS(Clock, Reset, XInputCordic.r(12), YInputCordic.r(12))    
    
        VARIABLE XReal : STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS => '0');
        VARIABLE YReal : STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS => '0');
        VARIABLE XImag : STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS => '0');
        VARIABLE YImag : STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS => '0');
        
    BEGIN
        
        XOutputCordic.r <= XReal;
        XOutputCordic.i <= XImag; 
        YOutputCordic.r <= YReal;
        YOutputCordic.i <= YImag;
        
        IF(Reset = '1') THEN
            IF(XInputCordic.r(12) = '1') THEN
                XReal(11 DOWNTO 0) := XInputCordic.r(11 DOWNTO 0);
                XReal(12) := XInputCordic.r(12);
                XImag := (OTHERS => '0'); 
                
            ELSIF(YInputCordic.r(12) = '1') THEN
                YReal(11 DOWNTO 0) := YInputCordic.r(11 DOWNTO 0);
                XReal(12) := XInputCordic.r(12);
                YImag := (OTHERS => '0'); 
                
            END IF;
           
        ELSIF(Clock'EVENT AND Clock = '1') THEN
            XReal := XInputCordic.r;
            XImag := XInputCordic.i; 
            YReal := YInputCordic.r;
            YImag := YInputCordic.i;

        END IF;
            
    END PROCESS;

END Behavioral;