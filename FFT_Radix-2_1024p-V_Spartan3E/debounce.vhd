LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY debounce IS
		PORT(clk: IN STD_LOGIC;
			  rst: IN STD_LOGIC;
			  Entrada: IN STD_LOGIC;
			  Saida: OUT STD_LOGIC);
END debounce;

ARCHITECTURE logica OF debounce is
	
	SIGNAL Aux: STD_LOGIC := '0';
	SIGNAL AuxSaida : STD_LOGIC := '0';
	
BEGIN
	
	Saida <= AuxSaida;

	PROCESS(rst,clk,Entrada)
	
		VARIABLE count: INTEGER RANGE 0 TO 100000 := 0;
	
	BEGIN 
	
		IF (rst = '1') THEN
			count := 0;
			
		ELSIF (RISING_EDGE(clk)) THEN
			IF(Entrada /=  Aux) THEN
				count := count +1;
				IF(count = 100000) THEN	
					Aux <= Entrada AND (not rst);
					
				END IF;
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	PROCESS(rst, Aux)
		
	BEGIN 
		
		IF(rst = '1') THEN
			AuxSaida <= '0';
		
		ELSIF(RISING_EDGE(Aux)) THEN
			AuxSaida <= AuxSaida XOR '1';
		
		END IF;
	
	END PROCESS;

END logica;