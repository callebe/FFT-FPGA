--
-- Gerador de sinal de 1 Hz a partir de
-- do clock de 50 MHz do kit Basys 2
--
-- 15/04/2015
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;


ENTITY GeradorClock IS
   GENERIC(freq: INTEGER := 50000000);
   PORT(mclk: IN STD_LOGIC;
		  clk: BUFFER STD_LOGIC);
END GeradorClock;


ARCHITECTURE logica OF GeradorClock IS

BEGIN

	PROCESS(mclk) 
		VARIABLE count: INTEGER RANGE 0 TO Freq/2 := 0;
	BEGIN
	
		IF(mclk'EVENT AND mclk = '1') THEN
			IF( count = Freq/2 ) THEN
				count := 0;
				clk <= clk XOR '1';
			ELSE
				count := count + 1;
			END IF;
		END IF;
	END PROCESS;
	
END logica;