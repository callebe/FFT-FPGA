LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.meuPacote.all;

ENTITY ShiftRegister IS
	GENERIC(NBits: INTEGER RANGE 0 TO 8 := 8);
	PORT(Entrada: IN STD_LOGIC_VECTOR ((NBits-1) DOWNTO 0);
		  Saida: BUFFER STD_LOGIC_VECTOR ((NBits-1) DOWNTO 0);
		  Direction: IN STD_LOGIC;
		  clk: IN STD_LOGIC);
END ShiftRegister;


ARCHITECTURE Logica OF ShiftRegister IS 
	SIGNAL Buff: STD_LOGIC_VECTOR ((NBits-1) DOWNTO 0);
BEGIN
	
	PROCESS(clk)
	
	BEGIN
		IF(clk'EVENT AND clk = '1') THEN
			IF(Direction = '1') THEN
				Buff(0) <= Entrada(1);
				Buff(1) <= Entrada(2);
				Buff(2) <= Entrada(3);
				Buff(3) <= Entrada(4);
				Buff(4) <= Entrada(5);
				Buff(5) <= Entrada(6);
				Buff(6) <= Entrada(7);
				Buff(7) <= Entrada(0);
			ELSE
				Buff(0) <= Entrada(7);
				Buff(1) <= Entrada(0);
				Buff(2) <= Entrada(1);
				Buff(3) <= Entrada(2);
				Buff(4) <= Entrada(3);
				Buff(5) <= Entrada(4);
				Buff(6) <= Entrada(5);
				Buff(7) <= Entrada(6);
			END IF;
			Saida <= Buff;
		END IF;
	END PROCESS;
END Logica;