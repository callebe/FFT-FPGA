LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY debounce IS
		PORT(clk: IN STD_LOGIC;
			  rst: IN STD_LOGIC;
			  Entrada: IN STD_LOGIC;
			  Saida: BUFFER STD_LOGIC);
END debounce;

ARCHITECTURE logica OF debounce is
	
	SIGNAL Aux: STD_LOGIC := '0';
	
BEGIN

	PROCESS(rst,clk,Entrada)
	
	VARIABLE count: INTEGER RANGE 0 TO 100000 := 0;
	
	BEGIN 
	
		IF (rst = '1') THEN
			count := 0;
			
		ELSIF (clk'event AND clk = '1') THEN
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
			Saida <= '0';
		
		ELSIF(Aux'EVENT AND Aux = '1') THEN
			Saida <= Saida XOR '1';
		
		END IF;
	
	END PROCESS;

END logica;