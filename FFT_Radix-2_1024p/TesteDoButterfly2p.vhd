LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.ALL;

ENTITY TesteDoButterfly8p IS
	PORT(Clock : IN STD_LOGIC;
		  reset : IN STD_LOGIC;
		  StartBotton : IN STD_LOGIC; 
		  --DataLCD : OUT STD_LOGIC_VECTOR(3 downto 0);
		  --LCD_E : OUT STD_LOGIC;
		  --LCD_RS : OUT STD_LOGIC;
		  --LCD_RW : OUT STD_LOGIC;
		  Rx : IN STD_LOGIC;
		  Tx : OUT STD_LOGIC;
		  IdleIndicator : OUT STD_LOGIC;
		  ReceiveDataIndicator : OUT STD_LOGIC;
		  ProcessFFTIndicator : OUT STD_LOGIC;
		  SendDataIndicator : OUT STD_LOGIC);
END TesteDoButterfly8p;

ARCHITECTURE Logica OF TesteDoButterfly8p IS
	
	-- Constantes 
	CONSTANT NumberOfFFT : INTEGER := 8;
	SIGNAL DataSPITx: ComplexVector(7 DOWNTO 0);
	SIGNAL DataSPIRx: ComplexVector(7 DOWNTO 0);
	--SIGNAL DataUARTTx: ComplexVector(7 DOWNTO 0);
	--SIGNAL DataUARTRx: ComplexVector(7 DOWNTO 0);
	--SIGNAL SaidaA : ComplexVector(7 DOWNTO 0);
	--SIGNAL OutputSA : ComplexVector(3 DOWNTO 0);
	--SIGNAL OutputSB : ComplexVector(3 DOWNTO 0);
	--SIGNAL Output2A : ComplexVector(3 DOWNTO 0);
	--SIGNAL Output2B : ComplexVector(3 DOWNTO 0);
	SIGNAL BeginTx : STD_LOGIC := '0';   
	SIGNAL BeginRx : STD_LOGIC := '0';
	--SIGNAL Saida : ComplexVector(7 DOWNTO 0);
	SIGNAL EndTx : STD_LOGIC := '0';
	SIGNAL EndRx : STD_LOGIC := '0';
	SIGNAL StartBottonDebounce : STD_LOGIC := '0';
	SIGNAL resetDebounce : STD_LOGIC := '0';
	SIGNAL CurrentState : StateFFT := Idle;
	SIGNAL NextState : StateFFT := Idle;
	SIGNAL BeginFFT : STD_LOGIC := '0';
	SIGNAL EndFFT : STD_LOGIC := '0';
	SIGNAL clk1M : STD_LOGIC := '0';
	
	BEGIN
	
	---------------------------------------------------------------
	--                       Clocks para UART                    --
	---------------------------------------------------------------
	clkGen9600 : BaudRate GENERIC MAP (50000000, 1000000) PORT MAP (clock, clk1M);
	
	---------------------------------------------------------------
	--                   Debounce dos Botões                     --
	---------------------------------------------------------------
	SW : debounce PORT MAP (Clock, ResetDebounce, StartBotton, StartBottonDebounce);
	
	---------------------------------------------------------------
	--                     Modulo do Display                     --
	---------------------------------------------------------------
	--Display:DisplayMod PORT MAP(Clock,reset,CurrentState,DataLCD,LCD_E,LCD_RS,LCD_RW);
	
	---------------------------------------------------------------
	--    1 Modulo Butterfly com 4 Modulos Butterfly Simples     --
	---------------------------------------------------------------
--	SaidaA <= (Output2A & Output2B);
--	B4: Butterfly4Mod GENERIC MAP (4,1) PORT MAP (Clock,reset,SaidaA,Saida);
--	
--	---------------------------------------------------------------
--	--    2 Modulo Butterfly com 2 Modulos Butterfly Simples     --
--	---------------------------------------------------------------
--	B2A: Butterfly2Mod GENERIC MAP (2,2) PORT MAP (Clock,reset,OutputSA,Output2A);
--	B2B: Butterfly2Mod GENERIC MAP (2,2) PORT MAP (Clock,reset,OutputSB,Output2B);
--	
--	---------------------------------------------------------------
--	--                4 Modulos Butterfly Simples                --
--	---------------------------------------------------------------
--	BSA: Butterfly PORT MAP (Clock,reset,W(0),DataUARTRx(0),DataUARTRx(4),OutputSA(0),OutputSA(1));
--	BSB: Butterfly PORT MAP (Clock,reset,W(0),DataUARTRx(2),DataUARTRx(6),OutputSA(2),OutputSA(3));			 
--	BSC: Butterfly PORT MAP (Clock,reset,W(0),DataUARTRx(1),DataUARTRx(5),OutputSB(0),OutputSB(1));		 
--	BSD: Butterfly PORT MAP (Clock,reset,W(0),DataUARTRx(3),DataUARTRx(7),OutputSB(2),OutputSB(3));
	
	---------------------------------------------------------------
	--              Dispositivo de Comunicação UART              --
	---------------------------------------------------------------
	DataUARTTx <= DataUARTRx;
	--UART0 : UARTDevice GENERIC MAP (NumberOfFFT) PORT MAP (Clock, reset, Rx, BeginTx, BeginRx, DataUARTTx, DataUARTRx, Tx, EndTx, EndRx);	
	SPIDevice0 : SPIDevice GENERIC MAP (NumberOfFFT) PORT MAP (Clock, reset, Rx, BeginTx, BeginRx, DataSPITx, DataSPIRx, Tx, EndTx, EndRx); 
	---------------------------------------------------------------
	--               Processo de Controle da FFT                 --
	---------------------------------------------------------------
	-- Máquina de Estados
	StateMachine : PROCESS(CurrentState, StartBottonDebounce, EndRx, EndFFT, EndTx)
	
	BEGIN
	
		CASE CurrentState IS
		
			WHEN ResetFFT =>
				BeginTx <= '0';
				BeginRx <= '0';
				BeginFFT <= '0';
				NextState <= Idle;
				IdleIndicator <= '0';
				ReceiveDataIndicator <= '0';
				ProcessFFTIndicator <= '0';
				SendDataIndicator <= '0';
				ResetDebounce <= '1';
				
			WHEN Idle =>
				BeginTx <= '0';
				BeginRx <= '0';
				BeginFFT <= '0';
				IdleIndicator <= '1';
				ReceiveDataIndicator <= '0';
				ProcessFFTIndicator <= '0';
				SendDataIndicator <= '0';
				ResetDebounce <= '0';
				IF(StartBottonDebounce = '1') THEN
					NextState <= ReceiveData;
					
				ELSE
					NextState <= Idle;
					
				END IF;
				
			WHEN ReceiveData =>
				BeginTx <= '0';
				BeginRx <= '1';
				BeginFFT <= '0';
				IdleIndicator <= '0';
				ReceiveDataIndicator <= '1';
				ProcessFFTIndicator <= '0';
				SendDataIndicator <= '0';
				ResetDebounce <= '1';
				IF(EndRx = '1') THEN
					NextState <= ProcessData;
					
				ELSE
					NextState <= ReceiveData;
				
				END IF;
				
			WHEN ProcessData =>	
				BeginTx <= '0';
				BeginRx <= '0';
				BeginFFT <= '1';
				IdleIndicator <= '0';
				ReceiveDataIndicator <= '0';
				ProcessFFTIndicator <= '1';
				SendDataIndicator <= '0';
				ResetDebounce <= '1';
				IF(EndFFT = '1') THEN
					NextState <= TransmitData;
					
				ELSE
					NextState <= ProcessData;
				
				END IF;
				
			WHEN TransmitData =>
				BeginTx <= '1';
				BeginRx <= '0';
				BeginFFT <= '0';
				IdleIndicator <= '0';
				ReceiveDataIndicator <= '0';
				ProcessFFTIndicator <= '0';
				SendDataIndicator <= '1';
				ResetDebounce <= '1';
				IF(EndTx = '1') THEN
					NextState <= Idle;
					
				ELSE 
					NextState <= TransmitData;
					
				END IF;
				
			WHEN OTHERS =>
				BeginTx <= '0';
				BeginRx <= '0';
				BeginFFT <= '0';
				NextState <= Idle;
				IdleIndicator <= '0';
				ReceiveDataIndicator <= '0';
				ProcessFFTIndicator <= '0';
				SendDataIndicator <= '0';
				ResetDebounce <= '1';
				
		END CASE;
	
	END PROCESS;
	
	-- Atualização de Estados
	UpdateStates : PROCESS(clk1M, reset)
	
	BEGIN
	
		IF(reset = '1') THEN
			CurrentState <= ResetFFT;
		
		ELSIF(clk1M = '0' AND clk1M'EVENT) THEN
			CurrentState <= NextState;
			
		END IF;
	
	END PROCESS;
	
	---------------------------------------------------------------
	--          Processo de Espera para Calcular a FFT           --
	---------------------------------------------------------------
	-- Máquina de Estados
	LoopForFFT : PROCESS(reset, clk1M, BeginFFT)
	
		VARIABLE Count : INTEGER RANGE 0 TO (NumberOfFFT*5) := 0; 
	
	BEGIN
	
		IF(reset = '1') THEN
			Count := 0;
			EndFFT <= '0';
			
		ELSIF(clk1M'EVENT AND clk1M = '1') THEN
			IF(BeginFFT = '1') THEN
				IF(Count = (NumberOfFFT*5)) THEN
					EndFFT <= '1';
					Count := 0;
					
				ELSE
					EndFFT <= '0';
					Count := Count + 1;
					
				END IF;
				
			END IF;
			
		END IF;
	
	
	END PROCESS;
	
END Logica;