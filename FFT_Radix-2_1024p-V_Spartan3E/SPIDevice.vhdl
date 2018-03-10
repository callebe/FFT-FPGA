LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.ALL;

ENTITY SPIDevice IS
	GENERIC(NumberOfFFT : INTEGER RANGE 0 TO 1024);
	PORT(Clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		Rx : IN STD_LOGIC;
		BeginTx : IN STD_LOGIC;
		BeginRx : IN STD_LOGIC;
		DataSPITx : IN ComplexVector(7 DOWNTO 0);
		DataSPIRx : BUFFER ComplexVector(7 DOWNTO 0);
		Tx : OUT STD_LOGIC;
		EndTx : BUFFER STD_LOGIC;
		EndRx : BUFFER STD_LOGIC;
		ClockTx: OUT STD_LOGIC;
		ClockRx: IN STD_LOGIC);
END SPIDevice;

ARCHITECTURE Logica OF SPIDevice IS

	-- Variaveis de conversão de Complexo para STD_LOGIC
	TYPE DataInputOutput IS ARRAY((NumberOfFFT-1) DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	TYPE DataBufferTx IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	-- Variaveis de Estado da Transmissão e Recepção
	TYPE StateTx IS (ResetTx, IdleTx, SendTx, StopTx);
	TYPE StateRx IS (ResetRx, IdleRx, ReceiveRx, StopRx);
	SIGNAL CurrentStateTx : StateTx := IdleTx;
	SIGNAL NextStateTx : StateTx := IdleTx;
	SIGNAL CurrentStateRx : StateRx := IdleRx;
	SIGNAL NextStateRx : StateRx := IdleRx;
	-- Variaveis de Buffer de Transmissão e Recepção
	SIGNAL DataTxBuffer : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
	SIGNAL DataRxBuffer : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
	--Variaveis de Clock de Transmissão e Recepção
	SIGNAL clk9600 : STD_LOGIC := '0';
	SIGNAL clk153600 : STD_LOGIC := '0';
	SIGNAL clk1M : STD_LOGIC := '0';
	-- Variaveis de controle da transmissão de Bytes
	SIGNAL CounterDataTx : INTEGER RANGE 0 TO (NumberOfFFT) := 0;
	SIGNAL ActiveTx : STD_LOGIC := '0';
	SIGNAL FinishTx : STD_LOGIC := '0';
	-- Variaveis de controle da recepção de Byte
	SIGNAL CounterDataRx : INTEGER RANGE 0 TO (NumberOfFFT) := 0;
	SIGNAL FinishRx : STD_LOGIC := '0';
	
	
BEGIN

		
	---------------------------------------------------------------
	--                       Clocks para UART                    --
	---------------------------------------------------------------
	clkGen153600 : BaudRate GENERIC MAP (50000000, 153600) PORT MAP (clk, clk153600);
	clkGen9600 : BaudRate GENERIC MAP (50000000, 9600) PORT MAP (clk, clk9600);
	clkGen1M : BaudRate GENERIC MAP (50000000, 1000000) PORT MAP (clk, clk1M);
		
	---------------------------------------------------------------
	--                       UART - Tx & Rx                      --
	---------------------------------------------------------------
	UART0Tx : UARTTx PORT MAP (clk9600, reset, ActiveTx, DataTxBuffer, Tx, FinishTx);
	UART0Rx : UART_Rx PORT MAP (clk153600, reset, Rx, DataRxBuffer, FinishRx );
		
	---------------------------------------------------------------
	--           Processo de Controle da Transmissão             --
	---------------------------------------------------------------
	-- Máquina de Estados
	StateMachineTx : PROCESS(CurrentStateTx, BeginTx, CounterDataTx)
	
	BEGIN
	
		CASE CurrentStateTx IS
			
			WHEN ResetTx =>
				EndTx <= '0';
				ActiveTx <= '0';
				NextStateTx <= IdleTx;
				
			WHEN IdleTx =>
				EndTx <= '0';
				ActiveTx <= '0';
				IF(BeginTx = '1') THEN
					NextStateTx <= SendTx;
				ELSE 
					NextStateTx <= IdleTx;
				END IF;	
				
			WHEN SendTx =>
				EndTx <= '0';
				ActiveTx <= '1';
				IF(CounterDataTx = (NumberOfFFT)) THEN
					NextStateTx <= StopTx;
					
				ELSE
					NextStateTx <= SendTx;
					
				END IF;
			
			WHEN StopTx =>
				EndTx <= '1';
				ActiveTx <= '0';
				NextStateTx <= IdleTx;
				
			WHEN OTHERS =>
				EndTx <= '0';
				ActiveTx <= '0';
				NextStateTx <= IdleTx;
				
		END CASE;
	
	END PROCESS;
	
	-- Atualização de Estados
	UpdateStatesTx : PROCESS(clk1M, reset)

	BEGIN
	
		IF(reset = '1') THEN
			CurrentStateTx <= ResetTx;
		
		ELSIF (clk1M = '1' AND clk1M'event) THEN
			CurrentStateTx <= NextStateTx;
		
		END IF;
	
	END PROCESS;
	
	---------------------------------------------------------------
	--               Processo de Envio de Dados                  --
	---------------------------------------------------------------
	SendData: PROCESS (reset, FinishTx, clk9600, CurrentStateTx)
		
		VARIABLE Counter : INTEGER RANGE 0 TO 7:= 0;
		VARIABLE Aux : DataBufferTx := (OTHERS => "00000000");
		VARIABLE BuffTxVectorReal : STD_LOGIC_VECTOR(31 DOWNTO 0);
		VARIABLE BuffTxVectorImag : STD_LOGIC_VECTOR(31 DOWNTO 0);
		
	BEGIN
		
		IF(reset = '1') THEN 
			Counter := 0;
			CounterDataTx <= 0;
			
		ELSIF(clk9600 = '1' AND clk9600'EVENT) THEN
			IF(CurrentStateTx = SendTx) THEN
				IF (FinishTx = '1') THEN
					IF(Counter = 0) THEN
						BuffTxVectorReal := convIntegerToStdSigned(DataUARTTx(CounterDataTx).r);
						BuffTxVectorImag := convIntegerToStdSigned(DataUARTTx(CounterDataTx).i);
						Aux(0)(7 DOWNTO 0) := BuffTxVectorReal(7 DOWNTO 0);
						Aux(1)(7 DOWNTO 0) := BuffTxVectorReal(15 DOWNTO 8);
						Aux(2)(7 DOWNTO 0) := BuffTxVectorReal(23 DOWNTO 16);
						Aux(3)(7 DOWNTO 0) := BuffTxVectorReal(31 DOWNTO 24);
						Aux(4)(7 DOWNTO 0) := BuffTxVectorImag(7 DOWNTO 0);
						Aux(5)(7 DOWNTO 0) := BuffTxVectorImag(15 DOWNTO 8);
						Aux(6)(7 DOWNTO 0) := BuffTxVectorImag(23 DOWNTO 16);
						Aux(7)(7 DOWNTO 0) := BuffTxVectorImag(31 DOWNTO 24);
						CounterDataTx <= CounterDataTx;
						
					ELSIF(Counter = 7)	THEN
						CounterDataTx <= CounterDataTx + 1;
						
					END IF; 
					DataTxBuffer <= Aux(Counter);
					Counter := Counter + 1;
					
				END IF;
				
			ELSE
				Counter := 0;
				CounterDataTx <= 0;
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	---------------------------------------------------------------
	--           Processo de Controle da Recepção             --
	---------------------------------------------------------------
	-- Máquina de Estados
	StateMachineRx : PROCESS(CurrentStateRx, BeginRx, CounterDataRx)
	
	BEGIN
	
		CASE CurrentStateRx IS
			
			WHEN ResetRx =>
				EndRx <= '0';
				NextStateRx <= IdleRx;
				
			WHEN IdleRx =>
				EndRx <= '0';
				IF(BeginRx = '1') THEN
					NextStateRx <= ReceiveRx;
					
				ELSE 
					NextStateRx <= IdleRx;
					
				END IF;	
				
			WHEN ReceiveRx =>
				EndRx <= '0';
				IF(CounterDataRx = NumberOfFFT) THEN
					NextStateRx <= StopRx;
					
				ELSE
					NextStateRx <= ReceiveRx;
					
				END IF;
				
				
			WHEN StopRx =>
				EndRx <= '1';
				NextStateRx <= IdleRx;
					
			
			WHEN OTHERS =>
				EndRx <= '0';
				NextStateRx <= IdleRx;
				
		END CASE;
	
	END PROCESS;
	
	-- Atualização de Estados
	UpdateStatesRx : PROCESS(clk9600, reset)

	BEGIN
	
		IF(reset = '1') THEN
			CurrentStateRx <= ResetRx;
		
		ELSIF (clk9600 = '1' AND clk9600'event) THEN
			CurrentStateRx <= NextStateRx;
		
		END IF;
	
	END PROCESS;
	
	---------------------------------------------------------------
	--             Processo de Recepção de Dados                 --
	---------------------------------------------------------------
	ProcessTrasmitRx : PROCESS(reset, clk9600, CurrentStateRx, FinishRx)
		
		VARIABLE Counter : INTEGER RANGE 0 TO (NumberOfFFT) := 0;
		VARIABLE BufferRx: DataBufferTx;
		
	BEGIN
		
		IF(reset = '1') THEN
			Counter := 0;
			CounterDataRx <= 0;
			
		ELSIF(clk9600'EVENT AND clk9600 = '1') THEN
			IF(CurrentStateRx = ReceiveRx) THEN
				IF(FinishRx = '1') THEN
					BufferRx(Counter) := DataRxBuffer;
					IF(Counter = 7) THEN
						Counter := 0;
						DataUARTRx(CounterDataRx).r <= convStdToIntegerSigned(BufferRx(3) & BufferRx(2) & BufferRx(1) & BufferRx(0));
						DataUARTRx(CounterDataRx).i <= convStdToIntegerSigned(BufferRx(7) & BufferRx(6) & BufferRx(5) & BufferRx(4));
						CounterDataRx <= CounterDataRx + 1;
						
					END IF;
					
					Counter := Counter + 1;
					
				END IF;
				
			ELSE
				Counter := 0;
				CounterDataRx <= 0;
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
END Logica;