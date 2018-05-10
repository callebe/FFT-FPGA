LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY ULA IS
	PORT(Clock: IN STD_LOGIC;
		  reset: IN STD_LOGIC;
		  A0: IN Complex;
		  A1 : IN Complex;
		  A2 : IN Complex;
		  A3 : IN Complex;
		  A4 : IN Complex;
		  A5 : IN Complex;
		  A6 : IN Complex;
		  A7 : IN Complex;
		  A8 : IN Complex;
		  A9 : IN Complex;
		  B0 : OUT Complex;
		  B1 : OUT Complex;
		  B2 : OUT Complex;
		  B3 : OUT Complex;
		  B4 : OUT Complex);
END ULA;

ARCHITECTURE Logica OF ULA IS
	
	BEGIN
	
	PROCESS(Clock, reset)
		
		
	BEGIN
	
		IF(reset = '1') THEN
			B0.r <= 0;
			B0.i <= 0;
			B1.r <= 0;
			B1.r <= 0;
			B2.r <= 0;
			B2.r <= 0;
			B3.r <= 0;
			B3.i <= 0;
			B4.r <= 0;
			B4.r <= 0;	
			
		ELSIF(Clock'EVENT AND Clock='1') THEN
			B0.r <= (A0.r*A1.r - A0.i*A1.i);
			B0.i <= (A0.r*A1.i + A0.i*A1.r);
			B1.r <= (A2.r*A3.r - A2.i*A3.i);
			B1.i <= (A2.r*A3.i + A2.i*A3.r);
			B2.r <= (A4.r*A5.r - A4.i*A5.i);
			B2.i <= (A4.r*A5.i + A4.i*A5.r);
			B3.r <= (A6.r*A7.r - A6.i*A7.i);
			B3.i <= (A6.r*A7.i + A6.i*A7.r);
			B4.r <= (A8.r*A9.r - A8.i*A9.i);
			B4.r <= (A8.r*A9.i + A8.i*A9.r);			
			
		END IF;
		
	END PROCESS;
	
END Logica;