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
	GENERIC()
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		Rx : IN STD_LOGIC;
		BeginTx : IN STD_LOGIC;
		BeginRx : IN STD_LOGIC;
		DataUARTTx : IN ComplexVector(7 DOWNTO 0);
		DataUARTRx : OUT ComplexVector(7 DOWNTO 0);
		Tx : OUT STD_LOGIC;
		EndTx : BUFFER STD_LOGIC;
		EndRx : BUFFER STD_LOGIC;
		ass : OUT STD_LOGIC);
END UARTDevice;

ARCHITECTURE Logica OF UARTDevice IS
	
	-- Variaveis de conversão de Complexo para STD_LOGIC
	TYPE DataOutput IS ARRAY((DataUARTTx'LENGTH*8-1) DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL DataTx: DataOutput;
	TYPE DataInput IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	-- Variaveis de Estado da Transmissão e Recepção
	TYPE StateTx IS (ResetTx, IdleTx, ProcessDataTx, SendTx, StopTx);
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
	SIGNAL BreakTx : STD_LOGIC := '0';
	-- Variaveis de processamento de Dados
	SIGNAL FinishProcessDataTx : STD_LOGIC := '0';
	-- Variaveis de controle de recepção de Conjunto de Bytes
	SIGNAL BreakRx : STD_LOGIC := '0';
		
BEGIN

	ass <= ActiveTx;
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
	UpdateStatesTx : PROCESS(clk, reset)

	BEGIN
	
		IF(reset = '1') THEN
			CurrentStateTx <= ResetTx;
		
		ELSIF (clk9600 = '1' AND clk9600'event) THEN
			CurrentStateTx <= NextStateTx;
		
		END IF;
	
	END PROCESS;
	
	---------------------------------------------------------------
	--               Processo de Envio de Dados                  --
	---------------------------------------------------------------
	SendData: PROCESS (reset, FinishTx, BreakTx)
	
		VARIABLE CounterByteTx: INTEGER RANGE 0 TO (DataUARTTx'LENGTH*8-1) := 0;
		
	BEGIN
		
		IF(reset = '1') THEN 
			DataTxBuffer <= "00000000";
			CounterByteTx := 0;
			BreakTx <= '0';
			
		ELSIF(clk9600 = '1' AND clk9600'EVENT) THEN
			IF(CurrentStateTx = SendTx AND BreakTx = '0') THEN
				IF (FinishTx = '1') THEN
					DataTxBuffer <= DataTx(CounterByteTx);
					IF(CounterByteTx = (DataUARTTx'LENGTH*8-1)) THEN
						BreakTx <= '1';
						CounterByteTx := 0;
						
					ELSE
						BreakTx <= '0';
						CounterByteTx := CounterByteTx + 1;
						
					END IF;
					
				END IF;
				
			ELSE
				CounterByteTx := 0;
				BreakTx <= '0';
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	---------------------------------------------------------------
	--               Processo de Preparação de Dados             --
	---------------------------------------------------------------
	ProcessTxFData : PROCESS(reset, CurrentStateTx)
		
		VARIABLE CounterA : INTEGER RANGE 0 TO INTEGER'HIGH;
		VARIABLE CounterB : INTEGER RANGE 0 TO INTEGER'HIGH;
		VARIABLE CounterC : INTEGER RANGE 0 TO INTEGER'HIGH;
		VARIABLE CounterD : INTEGER RANGE 0 TO INTEGER'HIGH;
		VARIABLE CounterE : INTEGER RANGE 0 TO INTEGER'HIGH;
		VARIABLE CounterF : INTEGER RANGE 0 TO INTEGER'HIGH;
		VARIABLE CounterG : INTEGER RANGE 0 TO INTEGER'HIGH;
		VARIABLE CounterH : INTEGER RANGE 0 TO INTEGER'HIGH;
		VARIABLE BuffTxVector : STD_LOGIC_VECTOR(31 DOWNTO 0);
		VARIABLE BuffTxBVector : STD_LOGIC_VECTOR(31 DOWNTO 0);
		
	BEGIN
	
		IF(reset = '1') THEN
			CounterA := 0;
				CounterB := 0;
				CounterC := 0;
				CounterD := 0;
				CounterE := 0;
				CounterF := 0;
				CounterG := 0;
				CounterH := 0;
				FinishProcessDataTx <= '0';
			
		ELSIF(CurrentStateTx = ProcessDataTx) THEN
			FOR i IN (DataUARTTx'LENGTH-1) DOWNTO (0) LOOP
				CounterA := i*8;
				CounterB := 1+i*8;
				CounterC := 2+i*8;
				CounterD := 3+i*8;
				CounterE := 4+i*8;
				CounterF := 5+i*8;
				CounterG := 6+i*8;
				CounterH := 7+i*8;
				BuffTxVector := convIntegerToStdSigned(DataUARTTx(i).r);
				BuffTxBVector := convIntegerToStdSigned(DataUARTTx(i).i);
				DataTx(CounterA)(7 DOWNTO 0) <= BuffTxVector(7 DOWNTO 0);
				DataTx(CounterB)(7 DOWNTO 0) <= BuffTxVector(15 DOWNTO 8);
				DataTx(CounterC)(7 DOWNTO 0) <= BuffTxVector(23 DOWNTO 16);
				DataTx(CounterD)(7 DOWNTO 0) <= BuffTxVector(31 DOWNTO 24);
				----------------------
				DataTx(CounterE)(7 DOWNTO 0) <= BuffTxBVector(7 DOWNTO 0);
				DataTx(CounterF)(7 DOWNTO 0) <= BuffTxBVector(15 DOWNTO 8);
				DataTx(CounterG)(7 DOWNTO 0) <= BuffTxBVector(23 DOWNTO 16);
				DataTx(CounterH)(7 DOWNTO 0) <= BuffTxBVector(31 DOWNTO 24);
				
			END LOOP;
			FinishProcessDataTx <= '1';
			
		ELSE	
			FinishProcessDataTx <= '0';
			
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
		
		ELSIF (clk9600 = '1' AND clk9600'event) THEN
			CurrentStateRx <= NextStateRx;
		
		END IF;
	
	END PROCESS;
	
	---------------------------------------------------------------
	--                  Processo de Recepção                     --
	---------------------------------------------------------------
	ReceptionControl : PROCESS (reset, clk, CurrentStateRx, FinishRx)
	
		VARIABLE Counter : INTEGER RANGE 0 TO 7 := 0;
		VARIABLE CounterDataRx :  INTEGER RANGE 0 TO  DataUARTTx'LENGTH := 0;
		VARIABLE Aux : DataInput;
			
	BEGIN
	
		IF(reset = '1') THEN
			Counter := 0;
			CounterDataRx := 0;
			BreakRx <= '0';
			
		ELSIF(clk9600'EVENT AND clk9600 = '1') THEN
			IF(CurrentStateRx = ReceiveRx) THEN
				IF(FinishRx = '1') THEN
					Aux(Counter) := DataRxBuffer;
					IF(Counter = 7) THEN
						Counter := 0;
						DataUARTRx(CounterDataRx).r <= convStdToIntegerSigned(Aux(3) & Aux(2) & Aux(1) & Aux(0));
						DataUARTRx(CounterDataRx).i <= convStdToIntegerSigned(Aux(7) & Aux(6) & Aux(5) & Aux(4));
						
						IF(CounterDataRx = DataUARTTx'LENGTH) THEN
							CounterDataRx := 0;
							BreakRx <= '1';
							
						ELSE
							CounterDataRx := CounterDataRx + 1;
							BreakRx <= '0';
							
						END IF;
						
					ELSE
						Counter := Counter + 1;
						BreakRx <= '0';
						
					END IF;
					
				END IF;
			
			ELSE
				Counter := 0;
				CounterDataRx := 0;
				BreakRx <= '0';
			
			END IF; 
			
		END IF;
	
	END PROCESS;
									  
END Logica;
