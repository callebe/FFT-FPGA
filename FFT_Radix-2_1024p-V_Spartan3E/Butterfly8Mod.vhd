LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY Butterfly8Mod IS
		GENERIC(NButterfly: INTEGER RANGE 0 TO 1024 := 8;
				  Layer: INTEGER RANGE 0 TO 512 := 1);
		PORT(Clock: IN STD_LOGIC;
			  reset: IN STD_LOGIC;
			  Input: IN ComplexArray8;
			  Output: OUT ComplexArray8);
END Butterfly8Mod;

ARCHITECTURE Logica OF Butterfly8Mod IS
	
	BEGIN
	
	G1: FOR i  IN 0 TO (NButterfly-1) GENERATE
		B1: Butterfly PORT MAP (Clock, reset, W(i*Layer), Input(i), Input((NButterfly*2-1)-i), Output(i), Output((NButterfly*2-1)-i));
	END GENERATE;
	
END Logica;