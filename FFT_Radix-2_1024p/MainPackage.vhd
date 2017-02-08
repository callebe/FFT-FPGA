LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

------------------------------------------------
PACKAGE MainPackage IS
	
	------------------------------------------------
	TYPE Complex IS
		RECORD
			r: INTEGER RANGE INTEGER'LOW TO INTEGER'HIGH;
			i: INTEGER RANGE INTEGER'LOW TO INTEGER'HIGH;
		END RECORD;
	------------------------------------------------
	
	------------------------------------------------
	TYPE ComplexVector IS ARRAY (NATURAL range <>) OF Complex;
	------------------------------------------------
	
	------------------------------------------------
	TYPE Wn IS ARRAY (0 TO 5) OF Complex;
	------------------------------------------------
	
	------------------------------------------------
	CONSTANT W: Wn := ((1024,0),(724,-724),(0,-1024),(-724,-724),(-1024,0),(-724,724));
	------------------------------------------------
	
	------------------------------------------------
	TYPE INFO IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION Sum (ValueA, ValueB: Complex) RETURN Complex;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION Sub (ValueA, ValueB: Complex) RETURN Complex;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION Mult (ValueA, ValueB: Complex) RETURN Complex;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION Div (ValueA, ValueB: Complex) RETURN Complex;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION NumberOfBits(n: natural) RETURN NATURAL;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION convStdToInteger (SIGNAL entrada: STD_LOGIC_VECTOR) RETURN INTEGER ;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION NextStageUpdate (SIGNAL ActualState: INTEGER RANGE 0 TO 20) RETURN INTEGER;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION convIntegerToStd (SIGNAL entrada: INTEGER; CONSTANT NBits: INTEGER RANGE 0 TO 8) RETURN STD_LOGIC_VECTOR;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION BCD_7_segmentos (SIGNAL Entrada: INTEGER RANGE 0 TO 15) RETURN STD_LOGIC_VECTOR;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION Shifter (SIGNAL Entrada: STD_LOGIC_VECTOR; CONSTANT NShifters: INTEGER; CONSTANT Direction: STD_LOGIC) RETURN STD_LOGIC_VECTOR;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION ConvIntegerToDisplay (Entrada: INTEGER RANGE 0 TO INTEGER'HIGH) RETURN STD_LOGIC_VECTOR;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT UARTTx IS
		PORT(clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			ActiveTx : IN STD_LOGIC;
			DataTx  : IN STD_LOGIC_VECTOR(7 downto 0);
			Tx : OUT STD_LOGIC;
			FinishTx : OUT STD_LOGIC);
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT UARTRx IS
		PORT(clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			Rx : IN STD_LOGIC;
			DataRx : OUT STD_LOGIC_VECTOR(7 downto 0);
			FinishRx : OUT STD_LOGIC);
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT BaudRate IS
		GENERIC(clkIN, BaudRateOut: INTEGER);
		PORT(clk: IN STD_LOGIC;
			clkOut: BUFFER STD_LOGIC);
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT debounce4Switch IS
		GENERIC(NDebounce : INTEGER := 4);
		PORT(clk: IN STD_LOGIC;
			  rst: IN STD_LOGIC;
			  Entrada: IN STD_LOGIC_VECTOR((NDebounce-1) DOWNTO 0);
			  Saida: BUFFER STD_LOGIC_VECTOR((NDebounce-1) DOWNTO 0));
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT DisplayMod IS
		PORT(Clock: IN STD_LOGIC;
			  reset: IN STD_LOGIC;
			  Saida: IN ComplexVector(7 DOWNTO 0);
			  SF_D : OUT STD_LOGIC_VECTOR(3 downto 0);
			  LCD_E: OUT STD_LOGIC;
			  LCD_RS: OUT STD_LOGIC;
			  LCD_RW: OUT STD_LOGIC);
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT DisplayLCD IS
		PORT(clk : IN STD_LOGIC;
			  reset : IN STD_LOGIC;
			  DATA: IN INFO;
			  SF_D : OUT STD_LOGIC_VECTOR(3 downto 0);
			  LCD_E: OUT STD_LOGIC;
			  LCD_RS: OUT STD_LOGIC;
			  LCD_RW: OUT STD_LOGIC);
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT Butterfly IS
		PORT(Clock: IN STD_LOGIC;
			  reset: IN STD_LOGIC;
			  W: IN Complex;
			  EvenInput: IN Complex;
			  OddInput: IN Complex;
			  EvenOutput: OUT Complex;
			  OddOutput: OUT Complex);
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT Butterfly2Mod IS
		GENERIC(NButterfly: INTEGER RANGE 0 TO 1024 := 2;
				  Layer: INTEGER RANGE 0 TO 512 := 4);
		PORT(Clock: IN STD_LOGIC;
		  reset: IN STD_LOGIC;
		  Input: IN ComplexVector(3 DOWNTO 0);
		  Output: OUT ComplexVector(3 DOWNTO 0));
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT Butterfly4Mod IS
		GENERIC(NButterfly: INTEGER RANGE 0 TO 1024 := 4;
				  Layer: INTEGER RANGE 0 TO 512 := 2);
		PORT(Clock: IN STD_LOGIC;
			  reset: IN STD_LOGIC;
			  Input: IN ComplexVector(7 DOWNTO 0);
			  Output: OUT ComplexVector(7 DOWNTO 0));
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT Butterfly8Mod IS
		GENERIC(NButterfly: INTEGER RANGE 0 TO 1024 := 8;
				  Layer: INTEGER RANGE 0 TO 512 := 1);
		PORT(Clock: IN STD_LOGIC;
			  reset: IN STD_LOGIC;
			  Input: IN ComplexVector(15 DOWNTO 0);
			  Output: OUT ComplexVector(15 DOWNTO 0));
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT debounce3Switch IS
		GENERIC(NDebounce : INTEGER := 3);
		PORT(clk: IN STD_LOGIC;
			  rst: IN STD_LOGIC;
			  Entrada: IN STD_LOGIC_VECTOR((NDebounce-1) DOWNTO 0);
			  Saida: BUFFER STD_LOGIC_VECTOR((NDebounce-1) DOWNTO 0));
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT debounce IS
		PORT(clk: IN STD_LOGIC;
			  rst: IN STD_LOGIC;
			  Entrada: IN STD_LOGIC;
			  Saida: BUFFER STD_LOGIC);
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT ShiftRegister IS
		GENERIC(NBits: INTEGER RANGE 0 TO 8 := 8);
		PORT(Entrada: IN STD_LOGIC_VECTOR ((NBits-1) DOWNTO 0);
			  Saida: BUFFER STD_LOGIC_VECTOR ((NBits-1) DOWNTO 0);
			  Direction: IN STD_LOGIC;
			  clk: IN STD_LOGIC);
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT GeradorClock IS
		GENERIC(freq: INTEGER := 50000000);
		PORT(mclk: IN STD_LOGIC;
			  clk: BUFFER STD_LOGIC);
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT GeradorClockA IS
	PORT(mclk: IN STD_LOGIC;
		  clk: BUFFER STD_LOGIC;
		  freq: IN INTEGER);
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT BasicSystemClock IS
	PORT(Entrada: STD_LOGIC_VECTOR (7 DOWNTO 0);
		  Clock50MHz: IN STD_LOGIC;
		  ACLK: OUT STD_LOGIC;
		  MCLK: OUT STD_LOGIC;
		  SMCLK: OUT STD_LOGIC);
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	
END MainPackage;
------------------------------------------------




PACKAGE BODY MainPackage IS

	------------------------------------------------
	
	------------------------------------------------
	FUNCTION NumberOfBits(n: natural) RETURN NATURAL IS

	BEGIN

		IF n > 0 THEN
			RETURN 1 + NumberOfBits(n / 2);

		ELSE
			RETURN 1;

		END IF;

	END NumberOfBits;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION Sum (ValueA, ValueB: Complex) RETURN Complex IS
		VARIABLE Result: Complex;
		
	BEGIN
		Result.r := ValueA.r + ValueB.r;
		Result.i := ValueA.i + ValueB.i;
		RETURN Result;
	END Sum;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION Sub (ValueA, ValueB: Complex) RETURN Complex IS
		VARIABLE Result: Complex;
		
	BEGIN
		Result.r := ValueA.r - ValueB.r;
		Result.i := ValueA.i - ValueB.i;
		RETURN Result;
	END Sub;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION Mult (ValueA, ValueB: Complex) RETURN Complex IS
		VARIABLE Result: Complex;
		
	BEGIN
		Result.r := (ValueA.r*ValueB.r - ValueA.i*ValueB.i);
		Result.i := (ValueA.r*ValueB.i + ValueA.i*ValueB.r);
		RETURN Result;
	END Mult;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION Div (ValueA, ValueB: Complex) RETURN Complex IS
		VARIABLE Result: Complex;
			
	BEGIN
		Result.r := (ValueA.r*ValueB.r + ValueA.i*ValueB.i)/(ValueB.r*ValueB.r + ValueB.i*ValueB.i);
		Result.i := (ValueA.i*ValueB.r - ValueA.r*ValueB.i)/(ValueB.r*ValueB.r + ValueB.i*ValueB.i);
		RETURN Result;
	END Div;
	------------------------------------------------

	------------------------------------------------
	FUNCTION convStdToInteger (SIGNAL entrada: STD_LOGIC_VECTOR) RETURN INTEGER IS 
		VARIABLE result: INTEGER RANGE 0 TO 2**entrada'LENGTH-1;
		
	BEGIN

		IF (entrada(entrada'HIGH)='1') THEN result := 1;
		ELSE result := 0;
		END IF;
		
		FOR i IN (entrada'HIGH-1) DOWNTO (entrada'LOW) LOOP
			result := result*2;
			IF(entrada(i)='1') THEN result := result + 1;
			END IF;
		END LOOP;

		RETURN result;
	END convStdToInteger;
	------------------------------------------------
	
	------------------------------------------------
	
	FUNCTION convIntegerToStd (SIGNAL entrada: INTEGER; CONSTANT NBits: INTEGER RANGE 0 TO 8) RETURN STD_LOGIC_VECTOR IS
		VARIABLE result: STD_LOGIC_VECTOR (NBits-1 DOWNTO 0);
		VARIABLE aux: INTEGER RANGE 0 TO 2**(NBits-1):= entrada;
	BEGIN
	
		FOR i IN (NBits-1) DOWNTO (0) LOOP
			IF ((aux/(2**i)) = 1) THEN result(i) := '1';
			END IF;
			aux := aux rem 2**(i);
		END LOOP;

		RETURN result;
	END convIntegerToStd;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION BCD_7_segmentos (SIGNAL Entrada: INTEGER RANGE 0 TO 15) RETURN STD_LOGIC_VECTOR IS
		VARIABLE display_OUT: STD_LOGIC_VECTOR (6 DOWNTO 0);
	BEGIN 
		
		CASE Entrada IS
			WHEN 0 => display_OUT := (not "0111111");
			WHEN 1 => display_OUT := (not "0000110");
			WHEN 2 => display_OUT := (not "1011011");
			WHEN 3 => display_OUT := (not "1001111"); 
			WHEN 4 => display_OUT := (not "1100110");
			WHEN 5 => display_OUT := (not "1101101");
			WHEN 6 => display_OUT := (not "1111101");
			WHEN 7 => display_OUT := (not "0000111");
			WHEN 8 => display_OUT := (not "1111111");
			WHEN 9 => display_OUT := (not "1101111");
			WHEN 10 => display_OUT := (not "1110111");
			WHEN 11 => display_OUT := (not "1111100");
			WHEN 12 => display_OUT := (not "0111001");
			WHEN 13 => display_OUT := (not "1011110");
			WHEN 14 => display_OUT := (not "1111001");
			WHEN OTHERS => display_OUT :=	(not "1110001");
		END CASE;
			
			RETURN display_OUT;
	END BCD_7_segmentos;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION Shifter (SIGNAL Entrada: STD_LOGIC_VECTOR; CONSTANT NShifters: INTEGER; CONSTANT Direction: STD_LOGIC) RETURN STD_LOGIC_VECTOR IS
		VARIABLE Saida: STD_LOGIC_VECTOR(Entrada'RANGE);
	BEGIN
	
			CASE Direction IS
				WHEN '0' => FOR i IN Entrada'HIGH DOWNTO NShifters LOOP
									Saida(i) := Entrada(i-NShifters);
								END LOOP;
								FOR i IN 0 TO (NShifters-1) LOOP
									Saida(i) := Entrada(Entrada'HIGH-i);
								END LOOP;
								
				WHEN OTHERS => FOR i IN 0 TO (Entrada'HIGH-NShifters) LOOP
										Saida(i) := Entrada(i+NShifters);
									END LOOP;--DIREITA
									FOR i IN (Entrada'HIGH-NShifters+1) TO (Entrada'HIGH) LOOP
										Saida(i) := '0';
									END LOOP;
									
			END CASE;
		
		RETURN Saida;
		
	END Shifter;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION ConvIntegerToDisplay (Entrada: INTEGER RANGE 0 TO INTEGER'HIGH) RETURN STD_LOGIC_VECTOR IS
		VARIABLE Saida: STD_LOGIC_VECTOR(7 DOWNTO 0);
	BEGIN
		
		CASE Entrada IS
		  WHEN 0 => Saida := "00110000";
		  WHEN 1 => Saida := "00110001";
		  WHEN 2 => Saida := "00110010"; 
		  WHEN 3 => Saida := "00110011";
		  WHEN 4 => Saida := "00110100";
		  WHEN 5 => Saida := "00110101";
		  WHEN 6 => Saida := "00110110";
		  WHEN 7 => Saida := "00110111";
		  WHEN 8 => Saida := "00111000";
		  WHEN 9 => Saida := "00111001";
		  WHEN OTHERS => Saida := "00110000";
		END CASE;
		
		RETURN Saida;
		
	END ConvIntegerToDisplay;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION NextStageUpdate (SIGNAL ActualState: INTEGER RANGE 0 TO 20) RETURN INTEGER IS
		VARIABLE NextStage: INTEGER RANGE 0 TO 20;
	BEGIN
		
		NextStage := ActualState;
		
		RETURN NextStage;
	END NextStageUpdate;
	------------------------------------------------
	
	------------------------------------------------
	

END MainPackage;
------------------------------------------------