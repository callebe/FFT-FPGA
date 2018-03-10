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
		  MultiResult : IN Complex;
		  EvenOutput: OUT Complex;
		  OddOutput: OUT Complex;
		  MultiA : OUT Complex;
		  MultiB : OUT Complex);
END Butterfly;

ARCHITECTURE Logica OF Butterfly IS
	
	BEGIN
	
	
	PROCESS(Clock, reset)
		
		VARIABLE Aux: Complex;
		
	BEGIN
	
		IF(reset = '1') THEN
			EvenOutput <= (0,0);
			OddOutput <= (0,0);
			MultiA.r <= 0;
			MultiB.r <= 0;
			MultiA.i <= 0;
			MultiB.i <= 0;
			
		ELSIF(Clock'EVENT AND Clock='1') THEN
			MultiA <= OddInput;
			MultiB <= W;
			Aux := MultiResult/(2**10);
			EvenOutput <= ComplexSum(EvenInput,Aux);
			OddOutput <= ComplexSub(EvenInput,Aux);
			
		END IF;
		
	END PROCESS;
	
END Logica;