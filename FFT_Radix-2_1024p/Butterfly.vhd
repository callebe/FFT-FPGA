LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY Butterfly IS
	PORT(Clock: IN STD_LOGIC;
		  reset: IN STD_LOGIC;
		  W: IN Complex;
		  EvenInput: IN Complex;
		  OddInput: IN Complex;
		  EvenOutput: OUT Complex;
		  OddOutput: OUT Complex);
END Butterfly;

ARCHITECTURE Logica OF Butterfly IS
	
	BEGIN
	
	PROCESS(Clock, reset)
		
		VARIABLE Aux: Complex;
		
	BEGIN
	
		IF(reset = '1') THEN
			EvenOutput <= (0,0);
			OddOutput <= (0,0);
			
		ELSIF(Clock'EVENT AND Clock='1') THEN
			Aux := Mult(W,OddInput);
			EvenOutput <= Sum(EvenInput,Aux);
			OddOutput <= Sub(EvenInput,Aux);
			
		END IF;
		
	END PROCESS;
	
END Logica;