LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

------------------------------------------------
PACKAGE MainPackage IS
	

	------------------------------------------------
	
	------------------------------------------------
	TYPE Complex IS
		RECORD
			r: STD_LOGIC_VECTOR(15 DOWNTO 0);
			i: STD_LOGIC_VECTOR(15 DOWNTO 0);
		END RECORD;
	------------------------------------------------
	
	------------------------------------------------
	TYPE StateFFT IS (ResetFFT, Idle, ReceiveData, ProcessData, TransmitData);
	------------------------------------------------
	
	------------------------------------------------
	TYPE ComplexVector IS ARRAY (NATURAL range <>) OF Complex;
	------------------------------------------------
	
	------------------------------------------------
	TYPE Wn IS ARRAY (0 TO 5) OF Complex;
	------------------------------------------------
	
	------------------------------------------------
	TYPE INFO IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION ComplexSum (ValueA, ValueB: Complex) RETURN Complex;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION ComplexSub (ValueA, ValueB: Complex) RETURN Complex;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION NumberOfBits(n: natural) RETURN NATURAL;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION convStdToInteger (entrada: STD_LOGIC_VECTOR) RETURN INTEGER ;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION NextStageUpdate (SIGNAL ActualState: INTEGER RANGE 0 TO 20) RETURN INTEGER;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION convIntegerToStd (entrada: INTEGER; CONSTANT NBits: INTEGER RANGE 0 TO 8) RETURN STD_LOGIC_VECTOR;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION convIntegerToStdSigned (entrada: INTEGER RANGE INTEGER'LOW TO INTEGER'HIGH) RETURN STD_LOGIC_VECTOR;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION convStdToIntegerSigned (entrada: STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN INTEGER;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION convStdToIntegerSigned8 (entrada: STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN INTEGER;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION BCD_7_segmentos (SIGNAL Entrada: INTEGER RANGE 0 TO 15) RETURN STD_LOGIC_VECTOR;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION Shifter (Entrada: STD_LOGIC_VECTOR; NShifters: INTEGER; Direction: STD_LOGIC) RETURN STD_LOGIC_VECTOR;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION ConvIntegerToDisplay (Entrada: INTEGER RANGE 0 TO INTEGER'HIGH) RETURN STD_LOGIC_VECTOR;
    ------------------------------------------------
                
    ------------------------------------------------
    COMPONENT ControlFFT IS
        GENERIC(NLevels : INTEGER;
                TimeLapseCordic: INTEGER
                );
        PORT(
            Reset : IN STD_LOGIC;
            Clock : IN STD_LOGIC;
            Start : IN STD_LOGIC;
            ControlSelectIn : OUT STD_LOGIC;
            StartCordic : OUT STD_LOGIC;
            ControlSelectOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            FinishFFT : OUT STD_LOGIC
        );
    END COMPONENT;
    ------------------------------------------------
            
    ------------------------------------------------
    COMPONENT MuxFFT IS
        GENERIC(NFFT : INTEGER);
        PORT(
            RefreshMuxFFT : IN STD_LOGIC;
            Reset : IN  STD_LOGIC; 
            InputMuxFFT : IN ComplexVector((NFFT/2-1) DOWNTO 0);
            OutputMuxFFT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;
    ------------------------------------------------
        
    ------------------------------------------------
	COMPONENT DemuxFFT IS
        GENERIC(NFFT : INTEGER);
        PORT(
            RefreshDemuxFFT : IN STD_LOGIC;
            Reset : IN  STD_LOGIC; 
            InputDemuxFFT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            OutputDemuxFFT : OUT ComplexVector((NFFT-1) DOWNTO 0)
        );
    END COMPONENT;
	------------------------------------------------
        
    ------------------------------------------------
	COMPONENT DelayLogic IS
        PORT(
            RefreshDelayLogic : IN STD_LOGIC;
            InputDelayLogic : IN Complex;
            OutputDelayLogic : OUT Complex
        );
    END COMPONENT;
	------------------------------------------------
        
    ------------------------------------------------
	COMPONENT CordicV1 IS
        PORT(
            Clock : IN STD_LOGIC;
            StartCordic : IN STD_LOGIC; 
            InputCordic : IN Complex;
            FinishCordic : OUT STD_LOGIC;
            OutputCordic : OUT Complex
        );
    END COMPONENT;
	------------------------------------------------
        
    ------------------------------------------------
	COMPONENT SelectIn IS
        GENERIC(NFFT : INTEGER);
        PORT(
            ControlSelectIn : IN STD_LOGIC; 
            InputSelectIn : IN ComplexVector((NFFT-1) DOWNTO 0);
            Feedback : IN ComplexVector((NFFT-1) DOWNTO 0);
            OutputSelectIn : OUT ComplexVector((NFFT-1) DOWNTO 0)
            );
    END COMPONENT;
    ------------------------------------------------
    
	------------------------------------------------
	COMPONENT Butterfly IS
        PORT( 
            XInput : IN Complex;
            YInput : IN Complex;
            XOutput : OUT Complex;
            YOutput : OUT Complex
        );
    END COMPONENT;
    ------------------------------------------------
    
	------------------------------------------------
	COMPONENT ButterflyHalf IS
        PORT( 
            XInput : IN Complex;
            YInput : IN Complex;
            XOutput : OUT Complex
            );
    END COMPONENT;
    ------------------------------------------------
    
	------------------------------------------------
	COMPONENT SelectOut IS
        GENERIC(NFFT : INTEGER);
        PORT(
            ControlSelectOut : IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
            InputSelectOut : IN ComplexVector((NFFT-1) DOWNTO 0);
            OutputSelectOut : OUT ComplexVector((NFFT-1) DOWNTO 0)
        );
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
			  CurrentState: IN StateFFT;
			  SF_D : OUT STD_LOGIC_VECTOR(3 downto 0);
			  LCD_E: OUT STD_LOGIC;
			  LCD_RS: OUT STD_LOGIC;
			  LCD_RW: OUT STD_LOGIC
	    );
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT DisplayLCD IS
		PORT(clk : IN STD_LOGIC;
		  reset : IN STD_LOGIC;
		  Update : IN STD_LOGIC;
		  DATA: IN INFO;
		  DataLCD : OUT STD_LOGIC_VECTOR(3 downto 0);
		  LCD_E: OUT STD_LOGIC;
		  LCD_RS: OUT STD_LOGIC;
		  LCD_RW: OUT STD_LOGIC
		);
	END COMPONENT;
	------------------------------------------------

	------------------------------------------------
	COMPONENT debounce3Switch IS
		GENERIC(NDebounce : INTEGER := 3);
		PORT(clk: IN STD_LOGIC;
			  rst: IN STD_LOGIC;
			  Entrada: IN STD_LOGIC_VECTOR((NDebounce-1) DOWNTO 0);
			  Saida: BUFFER STD_LOGIC_VECTOR((NDebounce-1) DOWNTO 0)
	    );
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT debounce IS
		PORT(clk: IN STD_LOGIC;
			  rst: IN STD_LOGIC;
			  Entrada: IN STD_LOGIC;
			  Saida: BUFFER STD_LOGIC
	    );
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
	PORT(Entrada: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
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
	FUNCTION ComplexSum (ValueA, ValueB: Complex) RETURN Complex IS
		
		VARIABLE Result : Complex;
		
	BEGIN
	
		Result.r := ValueA.r + ValueB.r;
		Result.i := ValueA.i + ValueB.i;
		
		RETURN Result;
		
	END ComplexSum;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION ComplexSub (ValueA, ValueB: Complex) RETURN Complex IS
		
		VARIABLE Result: Complex;
		
	BEGIN
	
		Result.r := ValueA.r - ValueB.r;
		Result.i := ValueA.i - ValueB.i;
		RETURN Result;
		
	END ComplexSub;
	------------------------------------------------

	------------------------------------------------
	FUNCTION convStdToInteger (entrada: STD_LOGIC_VECTOR) RETURN INTEGER IS 
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
	FUNCTION convIntegerToStd (entrada: INTEGER; CONSTANT NBits: INTEGER RANGE 0 TO 8) RETURN STD_LOGIC_VECTOR IS
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
	FUNCTION convIntegerToStdSigned (entrada: INTEGER RANGE INTEGER'LOW TO INTEGER'HIGH) RETURN STD_LOGIC_VECTOR IS
		
		VARIABLE result : STD_LOGIC_VECTOR (31 DOWNTO 0);
		VARIABLE aux : INTEGER RANGE 0 TO 2**(30):= entrada;
		
	BEGIN
	
		FOR i IN (30) DOWNTO (0) LOOP
			IF ((aux/(2**i)) = 1) THEN result(i) := '1';
			END IF;
			aux := aux rem 2**(i);
		END LOOP;
		
		IF(entrada < 0) THEN
			result(31) := '1';
		
		ELSE
			result(31) := '0';
			
		END IF;

		RETURN result;
	
	END convIntegerToStdSigned;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION convStdToIntegerSigned (entrada: STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN INTEGER IS
		
		VARIABLE Result : INTEGER RANGE INTEGER'LOW TO INTEGER'HIGH := 0;
		VARIABLE ResultA : INTEGER RANGE INTEGER'LOW TO INTEGER'HIGH := 0;
	
	BEGIN
		
		FOR i IN (30) DOWNTO (0) LOOP
			IF (entrada(i) = '1') THEN 
				Result := Result + 2**(i);
				
			END IF;
			
		END LOOP;
		
		IF(entrada(31) = '1') THEN
			Result := Result*(-1);
		END IF;

		ResultA := Result;
		
		RETURN resultA;
		
	
	END convStdToIntegerSigned;
	------------------------------------------------
	
	------------------------------------------------
	FUNCTION convStdToIntegerSigned8 (entrada: STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN INTEGER IS
		
		VARIABLE Result : INTEGER RANGE 0 TO 255 := 0;
	
	BEGIN
		
		IF(entrada(0) = '1') THEN
			Result := Result + 1;
		END IF;
		
		IF(entrada(1) = '1') THEN
			Result := Result + 2;
		END IF;
		
		IF(entrada(2) = '1') THEN
			Result := Result + 4;
		END IF;
		
		IF(entrada(3) = '1') THEN
			Result := Result + 8;
		END IF;
		
		IF(entrada(4) = '1') THEN
			Result := Result + 16;
		END IF;
		
		IF(entrada(5) = '1') THEN
			Result := Result + 32;
		END IF;
		
		IF(entrada(6) = '1') THEN
			Result := Result + 64;
		END IF;
		
		IF(entrada(7) = '1') THEN
			Result := Result + 128;
		END IF;
		
		RETURN Result;
		
	
	END convStdToIntegerSigned8;
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
	FUNCTION Shifter (Entrada: STD_LOGIC_VECTOR; NShifters: INTEGER; Direction: STD_LOGIC) RETURN STD_LOGIC_VECTOR IS
		VARIABLE Saida: STD_LOGIC_VECTOR(Entrada'RANGE) := (OTHERS => '0');
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