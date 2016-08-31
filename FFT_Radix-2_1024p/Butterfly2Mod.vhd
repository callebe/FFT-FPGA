LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY Butterfly2Mod IS
	GENERIC(NButterfly: INTEGER RANGE 0 TO 1024 := 2;
			  Layer: INTEGER RANGE 0 TO 512 := 2);
	PORT(Clock: IN STD_LOGIC;
		  reset: IN STD_LOGIC;
		  Input: IN ComplexVector(3 DOWNTO 0);
		  Output: OUT ComplexVector(3 DOWNTO 0));
END Butterfly2Mod;

ARCHITECTURE Logica OF Butterfly2Mod IS
	
	BEGIN
	
	G1: FOR i  IN 0 TO (NButterfly-1) GENERATE
		B1: Butterfly PORT MAP (Clock, reset, W(i*Layer), Input(i), Input((NButterfly*2-1)-i), Output(i), Output((NButterfly*2-1)-i));
	END GENERATE;
	
END Logica;