----------------------------------------------------------------------------------
--                         The Storage Unit (ROM)
--
--   ROM sequencial component
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


ENTITY ROM IS
    PORT(
        Clock : IN STD_LOGIC;
        Address : IN INTEGER RANGE 0 TO 7;
        Data : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
    );  
END ROM;

ARCHITECTURE Behavioral OF ROM IS
    
TYPE MEMORY IS ARRAY (7 DOWNTO 0) OF STD_LOGIC_VECTOR(10 DOWNTO 0);
CONSTANT ROMMEMORY : MEMORY := (0 => "00110100010", 
							 1 => "00110110100", 
							 2 => "11100000100", 
							 3 => "11001001000", 
							 4 => "00110100011", 
							 5 => "00110110101", 
							 6 => "11100000101", 
							 7 => "11001001001"); 
                              
BEGIN
    
    PROCESS(Clock)
    
    BEGIN 
    
        IF(Clock'EVENT AND Clock = '1') THEN
            Data <= ROMMEMORY(Address);
            
        END IF;
        
    END PROCESS;
    
    
    
  END Behavioral;
