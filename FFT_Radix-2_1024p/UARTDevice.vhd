--------------------------------------------------------------------
--------------------------------------------------------------------
--                                                                --
--                     Dispositivo UART                           --
--    Componente responsável por transmitir e receber os dados da --
-- FFT, com uma velocidade de   9600 bps.                         --
-- 'UpdateStates'.                                                --   
--                                                                --
--       clk -> 98600 Hz                                          --
--			ActiveTx -> Sinal que aciona a trasmissão                --
--       DataTx -> Informação à transmitir                        --
--       Tx -> Bit de transmissão serial                          --
--       FinishTx -> Sinal que marca o fim da trasmissão          --
--                                                                --
--------------------------------------------------------------------
--------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.ALL;

ENTITY UARTDevice IS
	GENERIC(NumberOfFFT : INTEGER RANGE 0 TO 1024);
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		Rx : IN STD_LOGIC;
		BeginTx : IN STD_LOGIC;
		BeginRx : IN STD_LOGIC;
		DataUARTTx : IN ComplexVector(7 DOWNTO 0);
		DataUARTRx : BUFFER ComplexVector(7 DOWNTO 0);
		Tx : OUT STD_LOGIC;
		EndTx : BUFFER STD_LOGIC;
		EndRx : BUFFER STD_LOGIC);
END UARTDevice;

ARCHITECTURE Logica OF UARTDevice IS
	
	-- Variaveis de conversão de Complexo para STD_LOGIC
	TYPE DataInputOutput IS ARRAY((NumberOfFFT-1) DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DataBufferTxReal: DataInputOutput;
	SIGNAL DataBufferTxImag: DataInputOutput;
	--SIGNAL DataBufferRxReal: DataInputOutput;
	--SIGNAL DataBufferRxImag: DataInputOutput;
	--TYPE DataBufferRx IS ARRAY(3 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	TYPE DataBufferTx IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	-- Variaveis de Estado da Transmissão e Recepção
	TYPE StateTx IS (ResetTx, IdleTx, ProcessDataTx, SendTx, StopTx);
	TYPE StateRx IS (ResetRx, IdleRx, ReceiveRx, ProcessRx, StopRx);
	SIGNAL CurrentStateTx : StateTx := IdleTx;
	SIGNAL NextStateTx : StateTx := IdleTx;
	SIGNAL CurrentStateRx : StateRx := IdleRx;
	SIGNAL NextStateRx : StateRx := IdleRx;
	-- Variaveis de Buffer de Transmissão e Recepção
	SIGNAL DataTxBuffer : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
	SIGNAL DataRxBuffer : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
	-- Variaveis de Clock de Transmissão e Recepção
	SIGNAL clk9600 : STD_LOGIC := '0';
	SIGNAL clk153600 : STD_LOGIC := '0';
	-- Variaveis de controle da transmissão de Bytes
	SIGNAL ActiveTx : STD_LOGIC := '0';
	SIGNAL FinishTx : STD_LOGIC := '0';
	SIGNAL BreakTx : STD_LOGIC := '0';
	-- Variaveis de controle da recepção de Bytes
	SIGNAL FinishRx : STD_LOGIC := '0';
	SIGNAL BreakRx : STD_LOGIC := '0';
	-- Variaveis de processamento de Dados
	SIGNAL FinishProcessDataTx : STD_LOGIC := '0';
	
	
	
BEGIN

	---------------------------------------------------------------
	--                       Clocks para UART                    --
	---------------------------------------------------------------
	clkGen153600 : BaudRate GENERIC MAP (50000000, 1843200) PORT MAP (clk, clk153600);
	clkGen9600 : BaudRate GENERIC MAP (50000000, 115200) PORT MAP (clk, clk9600);
		
	---------------------------------------------------------------
	--                       UART - Tx & Rx                      --
	---------------------------------------------------------------
	UART0Tx : UARTTx PORT MAP (clk9600, reset, ActiveTx, DataTxBuffer, Tx, FinishTx);
	UART0Rx : UARTRx PORT MAP (clk153600, reset, Rx, DataRxBuffer, FinishRx );
	
	---------------------------------------------------------------
	--           Processo de Controle da Transmissão             --
	---------------------------------------------------------------
	-- Máquina de Estados
	StateMachineTx : PROCESS(CurrentStateTx, BeginTx, BreakTx, FinishProcessDataTx)
	
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
					NextStateTx <= ProcessDataTx;
				ELSE 
					NextStateTx <= IdleTx;
				END IF;	
				
			WHEN ProcessDataTx =>
				EndTx <= '0';
				ActiveTx <= '0';
				IF(FinishProcessDataTx = '1') THEN
					NextStateTx <= SendTx;
					
				ELSE 
					NextStateTx <= ProcessDataTx;
					
				END IF;	
				
			WHEN SendTx =>
				EndTx <= '0';
				ActiveTx <= '1';
				IF(BreakTx = '1') THEN
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
	UpdateStatesTx : PROCESS(clk9600, reset)

	BEGIN
	
		IF(reset = '1') THEN
			CurrentStateTx <= ResetTx;
		
		ELSIF (clk9600 = '1' AND clk9600'event) THEN
			CurrentStateTx <= NextStateTx;
		
		END IF;
	
	END PROCESS;
	
	---------------------------------------------------------------
	--       Processo de Preparação de Dados para Trasmissão     --
	---------------------------------------------------------------
	ProcessTxFData : PROCESS(reset, CurrentStateTx, clk9600)
		
		VARIABLE BuffTxVectorReal : STD_LOGIC_VECTOR(31 DOWNTO 0);
		VARIABLE BuffTxVectorImag : STD_LOGIC_VECTOR(31 DOWNTO 0);
		
	BEGIN
	
		IF(reset = '1') THEN
			FinishProcessDataTx <= '0';
			
		ELSIF(clk9600 = '1' AND clk9600'EVENT) THEN
			IF(CurrentStateTx = ProcessDataTx) THEN
				FOR i IN (NumberOfFFT-1) DOWNTO (0) LOOP
					BuffTxVectorReal := convIntegerToStdSigned(DataUARTTx(i).r);
					BuffTxVectorImag := convIntegerToStdSigned(DataUARTTx(i).i);
					DataBufferTxReal(i)(31 DOWNTO 0) <= BuffTxVectorReal(31 DOWNTO 0);
					DataBufferTxImag(i)(31 DOWNTO 0) <= BuffTxVectorImag(31 DOWNTO 0);
					
				END LOOP;
				FinishProcessDataTx <= '1';
				
			ELSE	
				FinishProcessDataTx <= '0';
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	---------------------------------------------------------------
	--               Processo de Envio de Dados                  --
	---------------------------------------------------------------
	SendData: PROCESS (reset, FinishTx, clk9600, CurrentStateTx)
		
		VARIABLE Counter : INTEGER RANGE 0 TO 7:= 0;
		VARIABLE CounterDataTx : INTEGER RANGE 0 TO NumberOfFFT := 0;
		VARIABLE Aux : DataBufferTx ;
		
	BEGIN
		
		IF(reset = '1') THEN 
			Counter := 0;
			CounterDataTx := 0;
			BreakTx <= '0';
			
		ELSIF(clk9600 = '1' AND clk9600'EVENT) THEN
			IF(CurrentStateTx = SendTx) THEN
				IF (FinishTx = '1') THEN
					IF(Counter = 0) THEN
						Aux(0)(7 DOWNTO 0) := DataBufferTxReal(CounterDataTx)(7 DOWNTO 0);
						Aux(1)(7 DOWNTO 0) := DataBufferTxReal(CounterDataTx)(15 DOWNTO 8);
						Aux(2)(7 DOWNTO 0) := DataBufferTxReal(CounterDataTx)(23 DOWNTO 16);
						Aux(3)(7 DOWNTO 0) := DataBufferTxReal(CounterDataTx)(31 DOWNTO 24);
						Aux(4)(7 DOWNTO 0) := DataBufferTxImag(CounterDataTx)(7 DOWNTO 0);
						Aux(5)(7 DOWNTO 0) := DataBufferTxImag(CounterDataTx)(15 DOWNTO 8);
						Aux(6)(7 DOWNTO 0) := DataBufferTxImag(CounterDataTx)(23 DOWNTO 16);
						Aux(7)(7 DOWNTO 0) := DataBufferTxImag(CounterDataTx)(31 DOWNTO 24);
						CounterDataTx := CounterDataTx + 1;
						
					END IF; 
					
					DataTxBuffer <= Aux(Counter);
					IF(CounterDataTx = NumberOfFFT AND Counter = 7) THEN
						Counter := 0;
						BreakTx <= '1';
						
					ELSE
						Counter := Counter + 1;
						BreakTx <= '0';
						
					END IF;
					
				END IF;
				
			ELSE
				Counter := 0;
				CounterDataTx := 0;
				BreakTx <= '0';
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	---------------------------------------------------------------
	--           Processo de Controle da Recepção             --
	---------------------------------------------------------------
	-- Máquina de Estados
	StateMachineRx : PROCESS(CurrentStateRx, BeginRx, BreakRx)
	
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
				IF(BreakRx = '1') THEN
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
		
		VARIABLE Counter : INTEGER RANGE 0 TO 7 := 0;
		VARIABLE CounterDataRx : INTEGER RANGE 0 TO NumberOfFFT := 0;
		VARIABLE BufferRx: DataBufferTx ;
		VARIABLE BufferRxA: STD_LOGIC_VECTOR(31 DOWNTO 0);
		VARIABLE BufferRxB: STD_LOGIC_VECTOR(31 DOWNTO 0);	
			
	BEGIN
		
		IF(reset = '1' OR (CurrentStateRx /= ReceiveRx)) THEN
			Counter := 0;
			CounterDataRx := 0;
			BreakRx  <= '0';
			
		ELSIF(rising_edge(FinishRx)) THEN
			IF(CurrentStateRx = ReceiveRx) THEN
				BufferRx(Counter) := DataRxBuffer;
				IF(Counter = 7) THEN
					Counter := 0;
					DataUARTRx(CounterDataRx).r <= convStdToIntegerSigned(BufferRx(3) & BufferRx(2) & BufferRx(1) & BufferRx(0));
					DataUARTRx(CounterDataRx).i <= convStdToIntegerSigned(BufferRx(7) & BufferRx(6) & BufferRx(5) & BufferRx(4));
					IF(CounterDataRx = (NumberOfFFT-1)) THEN
						CounterDataRx := 0;
						BreakRx  <= '1';
						
					ELSE
						CounterDataRx := CounterDataRx + 1;
						BreakRx  <= '0';
						
					END IF;
					
				ELSE
					Counter := Counter + 1;
					BreakRx  <= '0';
					
				END IF;
				
			ELSE
				Counter := 0;
				CounterDataRx := 0;
				BreakRx  <= '0';
				
			END IF;
			
		END IF;
		
	END PROCESS;

	
END Logica;
