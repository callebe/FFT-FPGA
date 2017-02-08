LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY TESTE IS
	PORT(Clock: IN STD_LOGIC;
		  reset: IN STD_LOGIC;
		  SF_D : OUT STD_LOGIC_VECTOR(3 downto 0);
		  LCD_E: OUT STD_LOGIC;
		  LCD_RS: OUT STD_LOGIC;
		  LCD_RW: OUT STD_LOGIC);
END TESTE;

ARCHITECTURE Logica OF TESTE IS
	
	SIGNAL Entrada: ComplexVector(7 DOWNTO 0) := ((1000,0),(2000,0),(3000,0),(4000,0),(5000,0),(3000,0),(2000,0),(1000,0));
	SIGNAL Saida: ComplexVector(7 DOWNTO 0);
	SIGNAL SaidaA: ComplexVector(7 DOWNTO 0);
	SIGNAL OutputSA : ComplexVector(3 DOWNTO 0);
	SIGNAL OutputSB : ComplexVector(3 DOWNTO 0);
	SIGNAL Output2A : ComplexVector(3 DOWNTO 0);
	SIGNAL Output2B : ComplexVector(3 DOWNTO 0);
	TYPE WORD IS ARRAY(5 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Mensage: WORD;
	SIGNAL clk9600 : std_logic := '0';
	SIGNAL clk153600 : std_logic := '0';
	SIGNAL DataTx : std_logic_vector(7 downto 0) := "01001110";
	SIGNAL DataRx : std_logic_vector(7 downto 0) := "00000000";
	SIGNAL ActiveTx : std_logic := '0';
	SIGNAL FinishRx : std_logic := '0';
	SIGNAL FinishTx : std_logic := '0';
	SIGNAL Saida: STD_LOGIC := '0';
	
	BEGIN
	
	---------------------------------------------------------------
	--    1 Modulo Butterfly com 4 Modulos Butterfly Simples     --
	---------------------------------------------------------------
	SaidaA <= (Output2A & Output2B);
	B4: Butterfly4Mod GENERIC MAP (4,1) PORT MAP (Clock,reset,SaidaA,Saida);
	
	---------------------------------------------------------------
	--    2 Modulo Butterfly com 2 Modulos Butterfly Simples     --
	---------------------------------------------------------------
	B2A: Butterfly2Mod GENERIC MAP (2,2) PORT MAP (Clock,reset,OutputSA,Output2A);
	B2B: Butterfly2Mod GENERIC MAP (2,2) PORT MAP (Clock,reset,OutputSB,Output2B);
	
	---------------------------------------------------------------
	--                4 Modulos Butterfly Simples                --
	---------------------------------------------------------------
	BSA: Butterfly PORT MAP (Clock,reset,W(0),Entrada(0),Entrada(4),OutputSA(0),OutputSA(1));
	BSB: Butterfly PORT MAP (Clock,reset,W(0),Entrada(2),Entrada(6),OutputSA(2),OutputSA(3));			 
	BSC: Butterfly PORT MAP (Clock,reset,W(0),Entrada(1),Entrada(5),OutputSB(0),OutputSB(1));		 
	BSD: Butterfly PORT MAP (Clock,reset,W(0),Entrada(3),Entrada(7),OutputSB(2),OutputSB(3));
	
	---------------------------------------------------------------
	--                       Chave de Partida                    --
	---------------------------------------------------------------
	SW : debounce PORT MAP (clk, reset, Entrada, Saida);
	
	---------------------------------------------------------------
	--                       Clocks para UART                    --
	---------------------------------------------------------------
	clkGen153600 : BaudRate GENERIC MAP (50000000, 153600) PORT MAP (clk, clk153600);
	clkGen9600 : BaudRate GENERIC MAP (50000000, 9600) PORT MAP (clk, clk9600);

	---------------------------------------------------------------
	--                       UART - Tx & Rx                      --
	---------------------------------------------------------------
	UART0Tx : UARTTx port map (clk9600, reset, ActiveTx, DataTx, tx, FinishTx);
	UART0Rx : UARTRx port map (clk153600, reset, rx, DataRx, FinishRx);
	
	---------------------------------------------------------------
	--                       Clocks para UART                    --
	---------------------------------------------------------------
	TRIGGER: PROCESS (reset, FinishTx)
	
		--VARIABLE Counter: INTEGER RANGE 0 TO 8;
		
	BEGIN
		
		IF(reset = '1') THEN 
			DataTx <= "00000000";
			
		ELSIF(FinishTx = '1' AND FinishTx'EVENT) THEN
			IF(Saida = '1') THEN
				DataTx <= DataRx;
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	TRIGGER2: PROCESS (reset, clk) 
	
	BEGIN
		
		IF(reset = '1') THEN
			ActiveTx <= '0';
			
		ELSIF(clk = '1' AND clk'EVENT) THEN
			IF(Saida = '1' AND FinishTx = '1') THEN
				ActiveTx <= '1';
			
			ELSE
				ActiveTx <= '0';
			
			END IF;
			
		END IF;
	
	END PROCESS;
	
END Logica;

