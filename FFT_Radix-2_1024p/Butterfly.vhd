LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY Butterfly IS
	GENERIC(W: Complex := (0,1));
	PORT(Clock: IN STD_LOGIC;
		  reset: IN STD_LOGIC;
		  EvenInput: IN Complex;
		  OddInput: IN Complex;
		  EvenOutput: OUT Complex;
		  OddOutput: OUT Complex);
END Butterfly;

ARCHITECTURE Logica OF Butterfly IS
	
	BEGIN
	
	PROCESS(Clock, reset)
	
	BEGIN
		IF(reset = '1') THEN
			EvenOutput <= (0,0);
			OddOutput <= (0,0);
		ELSIF(Clock'EVENT AND Clock='1') THEN
			EvenOutput <= Sum(EvenInput(W,OddInput));
			OddOutput <= Sub(EvenInput,Mult(W,OddInput));
		END IF;
	END PROCESS;
	
END Logica;