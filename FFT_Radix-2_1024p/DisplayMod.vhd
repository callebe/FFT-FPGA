LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY DisplayMod IS
	PORT(Clock: IN STD_LOGIC;
		  reset: IN STD_LOGIC;
		  Saida: IN ComplexVector(7 DOWNTO 0);
		  SF_D : OUT STD_LOGIC_VECTOR(3 downto 0);
		  LCD_E: OUT STD_LOGIC;
		  LCD_RS: OUT STD_LOGIC;
		  LCD_RW: OUT STD_LOGIC);
END DisplayMod;

ARCHITECTURE Logica OF DisplayMod IS
	
	SIGNAL DATA: INFO := ("10100000","10100000","00101000","00100000","00100000","00100000","00100000","00101011","01101001","00100000","00100000","00100000","00100000","00101001","10100000","10100000","10100000","10100000","00101000","00100000","00100000","00100000","00100000","00101011","01101001","00100000","00100000","00100000","00100000","00101001","10100000","10100000");
	                   --(  BLANK       BLANK        (          0         0         0          0           +           i         0         0           0          0           )        BLANK     BLANK       BLANK     BLANK       (          0         0         0          0           +           i           0         0           0          0           )         BLANK       BLANK 
							 --(     1          2          3          4          5          6         7          8          9          10         11          12        13        14          15         16         17         18         19         20         21         22         23        24           25       26         27          28         29       30         31             32  
	
	BEGIN
	
	---------------------------------------------------------------
	--               Dispositivo de Print na tela                --
	---------------------------------------------------------------	
	Display: DisplayLCD PORT MAP(Clock,reset,DATA,SF_D,LCD_E,LCD_RS,LCD_RW);	
	
	
		
	---------------------------------------------------------------
	-- Processo para Printar no LCD os dois primeiros resultados --
	---------------------------------------------------------------
	DisplayInfo: PROCESS(reset,Clock)
		
		VARIABLE Aux: INTEGER RANGE 0 TO INTEGER'HIGH := 0;
		VARIABLE AuxB: INTEGER RANGE 0 TO INTEGER'HIGH		:= 0;
	
	BEGIN
		
		IF(reset = '1') THEN
			DATA <= ("10100000","10100000","00101000","00100000","00100000","00100000","00100000","00101011","01101001","00100000","00100000","00100000","00100000","00101001","10100000","10100000","10100000","10100000","00101000","00100000","00100000","00100000","00100000","00101011","01101001","00100000","00100000","00100000","00100000","00101001","10100000","10100000");
	            --(  BLANK       BLANK        (          0         0         0          0           +           i         0         0           0          0           )        BLANK     BLANK       BLANK     BLANK       (          0         0         0          0           +           i           0         0           0          0           )         BLANK       BLANK 
		
		ELSIF(Clock'EVENT AND Clock = '1') THEN
			 
			----------------------------------
			IF(Saida(0).r > 0) THEN
				AuxB := Saida(0).r;			
				Aux := Saida(0).r*131;
				DATA(2) <= "00101000";
				DATA(1) <= "10100000";
			ELSE
				AuxB := -1*Saida(0).r;			
				Aux := -1*Saida(0).r*131;
				DATA(2) <= "00101101";
				DATA(1) <= "00101000";
			END IF;
			
			Aux := Aux/(2**17);
			DATA(3) <= ConvIntegerToDisplay(Aux);
			
			Aux := AuxB - Aux*1000;
			AuxB := Aux;
			Aux := Aux*1311;
			Aux := Aux/2**17;
			DATA(4) <= ConvIntegerToDisplay(Aux);
			
			Aux := AuxB - Aux*100;
			
			AuxB := Aux;
			Aux := Aux*13107;
			Aux := Aux/2**17;
			DATA(5) <= ConvIntegerToDisplay(Aux);
			
			Aux := AuxB - Aux*10;
			
			DATA(6) <= ConvIntegerToDisplay(Aux);
			
			----------------------------------
			IF(Saida(0).i > 0) THEN
				AuxB := Saida(0).i;			
				Aux := Saida(0).i*131;
				DATA(7) <= "00101011";
			ELSE
				AuxB := -1*Saida(0).i;			
				Aux := -1*Saida(0).i*131;
				DATA(7) <= "00101101";
			END IF;
		
			Aux := Aux/(2**17);
			DATA(9) <= ConvIntegerToDisplay(Aux);
			
			Aux := AuxB - Aux*1000;
			AuxB := Aux;
			Aux := Aux*1311;
			Aux := Aux/2**17;
			DATA(10) <= ConvIntegerToDisplay(Aux);
			
			Aux := AuxB - Aux*100;
			
			AuxB := Aux;
			Aux := Aux*13107;
			Aux := Aux/2**17;
			DATA(11) <= ConvIntegerToDisplay(Aux);
			
			Aux := AuxB - Aux*10;
			
			DATA(12) <= ConvIntegerToDisplay(Aux);
			
			----------------------------------
			IF(Saida(1).r > 0) THEN
				AuxB := Saida(1).r;			
				Aux := Saida(1).r*131;
				DATA(18) <= "00101000";
				DATA(17) <= "10100000";
			ELSE
				AuxB := -1*Saida(1).r;			
				Aux := -1*Saida(1).r*131;
				DATA(18) <= "00101101";
				DATA(17) <= "00101000";
			END IF;
			
			Aux := Aux/(2**17);
			DATA(19) <= ConvIntegerToDisplay(Aux);
			
			Aux := AuxB - Aux*1000;
			AuxB := Aux;
			Aux := Aux*1311;
			Aux := Aux/2**17;
			DATA(20) <= ConvIntegerToDisplay(Aux);
			
			Aux := AuxB - Aux*100;
			
			AuxB := Aux;
			Aux := Aux*13107;
			Aux := Aux/2**17;
			DATA(21) <= ConvIntegerToDisplay(Aux);
			
			Aux := AuxB - Aux*10;
			
			DATA(22) <= ConvIntegerToDisplay(Aux);
			
			----------------------------------
			IF(Saida(1).i > 0) THEN
				AuxB := Saida(1).i;			
				Aux := Saida(1).i*131;
				DATA(23) <="00101011";
			ELSE
				AuxB := -1*Saida(1).i;			
				Aux := -1*Saida(1).i*131;
				DATA(23) <= "00101101";
			END IF;
			
			Aux := Aux/(2**17);
			DATA(25) <= ConvIntegerToDisplay(Aux);
			
			Aux := AuxB - Aux*1000;
			AuxB := Aux;
			Aux := Aux*1311;
			Aux := Aux/2**17;
			DATA(26) <= ConvIntegerToDisplay(Aux);
			
			Aux := AuxB - Aux*100;
			
			AuxB := Aux;
			Aux := Aux*13107;
			Aux := Aux/2**17;
			DATA(27) <= ConvIntegerToDisplay(Aux);
			
			Aux := AuxB - Aux*10;
			
			DATA(28) <= ConvIntegerToDisplay(Aux);
			
		END IF;
		
	END PROCESS;
	
	
END Logica;
