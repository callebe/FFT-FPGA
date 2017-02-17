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
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		Rx : IN STD_LOGIC;
		BeginTx : IN STD_LOGIC;
		BeginRx : IN STD_LOGIC;
		DataUARTTx : IN ComplexVector(7 DOWNTO 0);
		DataUARTRx : OUT ComplexVector(7 DOWNTO 0);
		Tx : OUT STD_LOGIC;
		EndTx : BUFFER STD_LOGIC;
		EndRx : BUFFER STD_LOGIC);
END UARTDevice;

ARCHITECTURE Logica OF UARTDevice IS
	
	-- Variaveis de conversão de Complexo para STD_LOGIC
	TYPE DataInputOutput IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL DataTx: DataInputOutput;
	SIGNAL DataRx: DataInputOutput;
	-- Variaveis de Estado da Transmissão e Recepção
	TYPE StateTx IS (ResetTx, IdleTx, SendTx, StopTx);
	TYPE StateRx IS (ResetRx, IdleRx, ReceiveRx, StopRx);
	SIGNAL CurrentStateTx : StateTx := IdleTx;
	SIGNAL NextStateTx : StateTx := IdleTx;
	SIGNAL CurrentStateRx : StateRx := IdleRx;
	SIGNAL NextStateRx : StateRx := IdleRx;
	-- Variaveis de Buffer de Transmissão e Recepção
	SIGNAL DataTxBuffer: STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
	SIGNAL DataRxBuffer: STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
	-- Variaveis de Clock de Transmissão e Recepção
	SIGNAL clk9600 : STD_LOGIC := '0';
	SIGNAL clk153600 : STD_LOGIC := '0';
	-- Variaveis de controle da transmissão de Bytes
	SIGNAL ActiveTx : STD_LOGIC := '0';
	SIGNAL FinishTx : STD_LOGIC := '0';
	SIGNAL SendState : STD_LOGIC := '0';
	-- Variaveis de controle da recepção de Bytes
	SIGNAL FinishRx : STD_LOGIC := '0';
	-- Variaveis de controle de transmissão de Conjunto de Bytes
	SIGNAL CounterDataTx :  INTEGER RANGE 0 TO 9 := 0;
	-- Variaveis de controle de recepção de Conjunto de Bytes
	SIGNAL CounterDataRx :  INTEGER RANGE 0 TO 7 := 0;
	SIGNAL BreakRx : STD_LOGIC := '0';
		
BEGIN

	---------------------------------------------------------------
	--                       Clocks para UART                    --
	---------------------------------------------------------------
	clkGen153600 : BaudRate GENERIC MAP (50000000, 153600) PORT MAP (clk, clk153600);
	clkGen9600 : BaudRate GENERIC MAP (50000000, 9600) PORT MAP (clk, clk9600);
		
	---------------------------------------------------------------
	--                       UART - Tx & Rx                      --
	---------------------------------------------------------------
	UART0Tx : UARTTx port map (clk9600, reset, ActiveTx, DataTxBuffer, Tx, FinishTx);
	UART0Rx : UARTRx port map (clk153600, reset, Rx, DataRxBuffer, FinishRx);
	
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
				IF(CounterDataTx = 9) THEN
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
	UpdateStatesTx : PROCESS(clk, reset)

	BEGIN
	
		IF(reset = '1') THEN
			CurrentStateTx <= ResetTx;
		
		ELSIF (clk = '1' AND clk'event) THEN
			CurrentStateTx <= NextStateTx;
		
		END IF;
	
	END PROCESS;
	
	---------------------------------------------------------------
	--               Processo de Envio de Dados                  --
	---------------------------------------------------------------
	SendData: PROCESS (reset, FinishTx, CounterDataTx, CounterDataTx)
	
		VARIABLE AuxNum : INTEGER RANGE INTEGER'LOW TO INTEGER'HIGH;
		VARIABLE AuxNumB : INTEGER RANGE  INTEGER'LOW TO INTEGER'HIGH;
		VARIABLE BuffTxVector : STD_LOGIC_VECTOR(31 DOWNTO 0);
		VARIABLE BuffTxBVector : STD_LOGIC_VECTOR(31 DOWNTO 0);
		VARIABLE CounterByteTx: INTEGER RANGE 0 TO 7 := 0;
		
	BEGIN
		
		IF(reset = '1') THEN 
			DataTxBuffer <= "00000000";
			CounterByteTx := 0;
			CounterDataTx <= 0;
			
		ELSIF(clk9600 = '1' AND clk9600'EVENT) THEN
			IF(CurrentStateTx = SendTx) THEN
				IF (FinishTx = '1') THEN
					IF(CounterByteTx = 0) THEN
						AuxNum :=  DataUARTTx(CounterDataTx).r;
						AuxNumB := DataUARTTx(CounterDataTx).i;
						BuffTxVector := convIntegerToStdSigned(AuxNum);
						BuffTxBVector := convIntegerToStdSigned(AuxNumB);
						DataTx(3)(7 DOWNTO 0) <= BuffTxVector(7 DOWNTO 0);
						DataTx(2)(7 DOWNTO 0) <= BuffTxVector(15 DOWNTO 8);
						DataTx(1)(7 DOWNTO 0) <= BuffTxVector(23 DOWNTO 16);
						DataTx(0)(7 DOWNTO 0) <= BuffTxVector(31 DOWNTO 24);
						----------------------
						DataTx(7)(7 DOWNTO 0) <= BuffTxBVector(7 DOWNTO 0);
						DataTx(6)(7 DOWNTO 0) <= BuffTxBVector(15 DOWNTO 8);
						DataTx(5)(7 DOWNTO 0) <= BuffTxBVector(23 DOWNTO 16);
						DataTx(4)(7 DOWNTO 0) <= BuffTxBVector(31 DOWNTO 24);
						CounterDataTx <= CounterDataTx + 1;
						
					END IF;
					DataTxBuffer <= DataTx(CounterByteTx);
					CounterByteTx := CounterByteTx + 1;
					
				END IF;
				
			ELSE
				CounterByteTx := 0;
				CounterDataTx <= 0;
				
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
	UpdateStatesRx : PROCESS(clk, reset)

	BEGIN
	
		IF(reset = '1') THEN
			CurrentStateRx <= ResetRx;
		
		ELSIF (clk = '1' AND clk'event) THEN
			CurrentStateRx <= NextStateRx;
		
		END IF;
	
	END PROCESS;
	
	---------------------------------------------------------------
	--                  Processo de Recepção                     --
	---------------------------------------------------------------
	ReceptionControl : PROCESS (reset, clk, CurrentStateRx, FinishRx,CounterDataRx )
	
		VARIABLE Counter : INTEGER RANGE 0 TO 8 := 0;
		VARIABLE Aux : DataInputOutput;
		VARIABLE AuxB: STD_LOGIC_VECTOR(31 DOWNTO 0);
			
	BEGIN
	
		IF(reset = '1') THEN
			Counter := 0;
			CounterDataRx <= 0;
			BreakRx <= '0';
			
		ELSIF(clk9600'EVENT AND clk9600 = '1') THEN
			IF(CurrentStateRx = ReceiveRx) THEN
				IF(FinishRx = '1') THEN
					Aux(Counter) := DataRxBuffer;
					IF(Counter = 7) THEN
						Counter := 0;
						DataUARTRx(CounterDataRx).r <= convStdToIntegerSigned(Aux(0) & Aux(1) & Aux(2) & Aux(3));
						DataUARTRx(CounterDataRx).i <= convStdToIntegerSigned(Aux(4) & Aux(5) & Aux(6) & Aux(7));
						
						IF(CounterDataRx = 7) THEN
							CounterDataRx <= 0;
							BreakRx <= '1';
							
						ELSE
							CounterDataRx <= CounterDataRx + 1;
							BreakRx <= '0';
							
						END IF;
						
					ELSE
						Counter := Counter + 1;
						BreakRx <= '0';
						
					END IF;
					
				END IF;
			
			ELSE
				Counter := 0;
				CounterDataRx <= 0;
				BreakRx <= '0';
			
			END IF; 
			
		END IF;
	
	END PROCESS;
									  
END Logica;
