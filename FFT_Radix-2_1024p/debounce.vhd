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
	SIGNAL deb_out: STD_LOGIC;
	
BEGIN

	PROCESS(rst,clk,Entrada)
	--
	-- t-2ms
	-- contagens = 50M*0,002 = 100000
	VARIABLE count: INTEGER RANGE 0 TO 100000 := 0;
	BEGIN 
		IF (rst = '1') THEN
			count := 0;
		ELSIF (clk'event AND clk = '1') THEN
			IF(Entrada /=  deb_out) THEN
				count := count +1;
				IF(count = 100000) THEN	deb_out <= Entrada AND (not rst);
				END IF;
			END IF;
		END IF;
		
	END PROCESS;
	
	PROCESS(deb_OUT,rst)
	BEGIN 
		IF(deb_out'EVENT and deb_out = '1') THEN
			Saida <= Saida XOR '1';
		END IF;
		
		IF(rst = '1') THEN Saida <= '0';
		END IF;
	END PROCESS;

END logica;