
library IEEE;
use IEEE.STD_LOGIC_1164.all;

ENTITY debounce4Switch IS
	GENERIC(NDebounce : INTEGER := 4);
	PORT(clk: IN STD_LOGIC;
	     rst: IN STD_LOGIC;
	     Entrada: IN STD_LOGIC_VECTOR((NDebounce-1) DOWNTO 0);
		  Saida: BUFFER STD_LOGIC_VECTOR((NDebounce-1) DOWNTO 0));
END debounce4Switch;

ARCHITECTURE logic OF debounce4Switch is
	SIGNAL auxSaida: STD_LOGIC_VECTOR((NDebounce-1) DOWNTO 0) := "0000";
	SIGNAL DebounceBloqueado: BOOLEAN := False;
	SIGNAL rst1: STD_LOGIC := '0';
	
BEGIN

	--------------------------------------------
	PROCESS(rst, clk)
	-- t-2ms
	-- contagens = 50M*0,002 = 100000
	VARIABLE count: INTEGER RANGE 0 TO 100000 := 0;
	BEGIN 
		IF (rst = '1') THEN count := 0; DebounceBloqueado <= True;
		ELSIF (clk'event AND clk = '1') THEN
			IF(count = 100000) THEN	count := 0;	DebounceBloqueado <= False;
			ELSE count := count + 1;
			END IF;
		END IF;	
	END PROCESS;
	--------------------------------------------
	
	--------------------------------------------
	PROCESS(clk)
	BEGIN 
		IF(clk'EVENT and clk = '1') THEN
			IF (Entrada(0) /= auxSaida(0)) THEN
				IF(DebounceBloqueado) THEN rst1 <= '0';
				ELSE rst1 <= '1'; auxSaida(0) <= Entrada(0) AND (not rst); 
				END IF;
			
			ELSIF (Entrada(1) /= auxSaida(1)) THEN
				IF(DebounceBloqueado) THEN rst1 <= '0';
				ELSE rst1 <= '1'; auxSaida(1) <= Entrada(1) AND (not rst);
				END IF;
			
			ELSIF (Entrada(2) /= auxSaida(2)) THEN
				IF(DebounceBloqueado) THEN rst1 <= '0';
				ELSE rst1 <= '1'; auxSaida(2) <= Entrada(2) AND (not rst);
				END IF;
			
			ELSIF (Entrada(3) /= auxSaida(3)) THEN
				IF(DebounceBloqueado) THEN rst1 <= '0';
				ELSE rst1 <= '1'; auxSaida(3) <= Entrada(3) AND (not rst);
				END IF;
			END IF;
		END IF;
	END PROCESS;
	--------------------------------------------
	
	--------------------------------------------
	PROCESS(auxSaida(0))
	
	BEGIN
	
		IF(auxSaida(0)'EVENT and auxSaida(0) = '1') THEN Saida(0) <= Saida(0) XOR '1';
		END IF;
		IF(rst = '1') THEN Saida(0) <='0';
		END IF;
	END PROCESS;
	--------------------------------------------
	
	--------------------------------------------
	PROCESS(auxSaida(1))
	
	BEGIN
	
		IF(auxSaida(1)'EVENT and auxSaida(1) = '1') THEN Saida(1) <= Saida(1) XOR '1';
		END IF;
		IF(rst = '1') THEN Saida(1) <='0';
		END IF;
	END PROCESS;
	
	PROCESS(auxSaida(2))
	--------------------------------------------
	
	--------------------------------------------
	BEGIN
	
		IF(auxSaida(2)'EVENT and auxSaida(2) = '1') THEN Saida(2) <= Saida(2) XOR '1';
		END IF;
		IF(rst = '1') THEN Saida(2) <='0';
		END IF;
	END PROCESS;
	
	PROCESS(auxSaida(3))
	--------------------------------------------
	
	--------------------------------------------
	BEGIN
	
		IF(auxSaida(3)'EVENT and auxSaida(3) = '1') THEN Saida(3) <= Saida(3) XOR '1';
		END IF;
		IF(rst = '1') THEN Saida(3) <='0';
		END IF;
	END PROCESS;
	--------------------------------------------
	
	
END logic;