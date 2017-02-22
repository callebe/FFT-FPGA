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
		DataUARTRx : OUT ComplexVector(7 DOWNTO 0);
		Tx : OUT STD_LOGIC;
		EndTx : BUFFER STD_LOGIC;
		EndRx : BUFFER STD_LOGIC;
		ass : OUT STD_LOGIC);
END UARTDevice;

ARCHITECTURE Logica OF UARTDevice IS
	
	-- Variaveis de conversão de Complexo para STD_LOGIC
	TYPE DataOutput IS ARRAY((NumberOfFFT*8-1) DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL DataSuperBuffer: DataOutput;
	TYPE DataInput IS ARRAY((NumberOfFFT*2-1) DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DataSuperBufferRx: DataInput;
	TYPE DataInputBuffer IS ARRAY(3 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	-- Variaveis de Estado da Transmissão e Recepção
	TYPE StateTx IS (ResetTx, IdleTx, ProcessDataTx, SendTx, StopTx);
	TYPE StateRx IS (ResetRx, IdleRx, ReceiveRx, ProcessRx, StopRx);
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
	-- Variaveis de controle da recepção de Bytes
	SIGNAL FinishRx : STD_LOGIC := '0';
	-- Variaveis de controle de transmissão de Conjunto de Bytes
	SIGNAL BreakTx : STD_LOGIC := '0';
	-- Variaveis de processamento de Dados
	SIGNAL FinishProcessDataTx : STD_LOGIC := '0';
	SIGNAL FinishProcessDataRx : STD_LOGIC := '1';
	-- Variaveis de controle de recepção de Conjunto de Bytes
	SIGNAL CounterDataRx : INTEGER RANGE 0 TO (NumberOfFFT*8) := 0;
	
	
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
	--               Processo de Envio de Dados                  --
	---------------------------------------------------------------
	SendData: PROCESS (reset, FinishTx, clk9600, CurrentStateTx, BreakTx)
	
		VARIABLE CounterByteTx: INTEGER RANGE 0 TO (DataUARTTx'LENGTH*8-1) := 0;
		
	BEGIN
		
		IF(reset = '1') THEN 
			DataTxBuffer <= "00000000";
			CounterByteTx := 0;
			BreakTx <= '0';
			
		ELSIF(clk9600 = '1' AND clk9600'EVENT) THEN
			IF(CurrentStateTx = SendTx AND BreakTx = '0') THEN
				IF (FinishTx = '1') THEN
					DataTxBuffer <= DataSuperBuffer(CounterByteTx);
					IF(CounterByteTx = (NumberOfFFT*8-1)) THEN
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
	--       Processo de Preparação de Dados para Trasmissão     --
	---------------------------------------------------------------
	ProcessTxFData : PROCESS(reset, CurrentStateTx, clk9600)
		
		VARIABLE BuffTxVectorReal : STD_LOGIC_VECTOR(31 DOWNTO 0);
		VARIABLE BuffTxVectorImag : STD_LOGIC_VECTOR(31 DOWNTO 0);
		VARIABLE CounterA : INTEGER RANGE 0 TO (NumberOfFFT*8-1);
		VARIABLE CounterB : INTEGER RANGE 0 TO (NumberOfFFT*8-1);
		VARIABLE CounterC : INTEGER RANGE 0 TO (NumberOfFFT*8-1);
		VARIABLE CounterD : INTEGER RANGE 0 TO (NumberOfFFT*8-1);
		VARIABLE CounterE : INTEGER RANGE 0 TO (NumberOfFFT*8-1);
		VARIABLE CounterF : INTEGER RANGE 0 TO (NumberOfFFT*8-1);
		VARIABLE CounterG : INTEGER RANGE 0 TO (NumberOfFFT*8-1);
		VARIABLE CounterH : INTEGER RANGE 0 TO (NumberOfFFT*8-1);
		VARIABLE CounterRx : INTEGER RANGE 0 TO (NumberOfFFT*8);
		
	BEGIN
	
		IF(reset = '1') THEN
			FinishProcessDataTx <= '0';
			CounterRx := 0;
			
		ELSIF(clk9600 = '1' AND clk9600'EVENT) THEN
			IF(CurrentStateTx = ProcessDataTx) THEN
				FOR i IN (NumberOfFFT-1) DOWNTO (0) LOOP
					CounterA := i*8;
					CounterB := 1+i*8;
					CounterC := 2+i*8;
					CounterD := 3+i*8;
					CounterE := 4+i*8;
					CounterF := 5+i*8;
					CounterG := 6+i*8;
					CounterH := 7+i*8;
					BuffTxVectorReal := convIntegerToStdSigned(DataUARTTx(i).r);
					BuffTxVectorImag := convIntegerToStdSigned(DataUARTTx(i).i);
					DataSuperBuffer(CounterA)(7 DOWNTO 0) <= BuffTxVectorReal(7 DOWNTO 0);
					DataSuperBuffer(CounterB)(7 DOWNTO 0) <= BuffTxVectorReal(15 DOWNTO 8);
					DataSuperBuffer(CounterC)(7 DOWNTO 0) <= BuffTxVectorReal(23 DOWNTO 16);
					DataSuperBuffer(CounterD)(7 DOWNTO 0) <= BuffTxVectorReal(31 DOWNTO 24);
					DataSuperBuffer(CounterE)(7 DOWNTO 0) <= BuffTxVectorImag(7 DOWNTO 0);
					DataSuperBuffer(CounterF)(7 DOWNTO 0) <= BuffTxVectorImag(15 DOWNTO 8);
					DataSuperBuffer(CounterG)(7 DOWNTO 0) <= BuffTxVectorImag(23 DOWNTO 16);
					DataSuperBuffer(CounterH)(7 DOWNTO 0) <= BuffTxVectorImag(31 DOWNTO 24);
					
				END LOOP;
				FinishProcessDataTx <= '1';
				
			ELSE	
				FinishProcessDataTx <= '0';
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	---------------------------------------------------------------
	--           Processo de Controle da Recepção             --
	---------------------------------------------------------------
	-- Máquina de Estados
	StateMachineRx : PROCESS(CurrentStateRx, BeginRx, CounterDataRx, FinishProcessDataRx)
	
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
				IF(CounterDataRx = (NumberOfFFT*2)) THEN
					NextStateRx <= ProcessRx;
					
				ELSE
					NextStateRx <= ReceiveRx;
					
				END IF;
				
			WHEN ProcessRx =>
				EndRx <= '0';
				IF(FinishProcessDataRx = '1') THEN
					NextStateRx <= StopRx;
					
				ELSE
					NextStateRx <= ProcessRx;
					
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
	ProcessTrasmitRx : PROCESS(reset, clk9600, FinishRx)
		
		VARIABLE Counter : INTEGER RANGE 0 TO 3 := 0;
		VARIABLE BuferrRx: DataInputBuffer ;
		
	BEGIN
	
		
		IF(reset = '1') THEN
			Counter := 0;
			CounterDataRx <= 0;
			BuferrRx := (OTHERS => "00000000");
			
		ELSIF(clk9600 = '1' AND clk9600'EVENT) THEN
			IF(CurrentStateRx = ReceiveRx) THEN
				IF(FinishRx = '1') THEN
					BuferrRx(Counter) := DataRxBuffer;
					IF(Counter = 3) THEN
						DataSuperBufferRx(CounterDataRx) <= (BuferrRx(3) & BuferrRx(2) & BuferrRx(1) & BuferrRx(0));
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
	

	---------------------------------------------------------------
	--           Processamento de Recepção de Dados              --
	---------------------------------------------------------------
	ProcessRxData : PROCESS(reset, CurrentStateRx, clk9600)
	
	
	BEGIN
	
		IF(reset = '1') THEN
			FinishProcessDataRx <= '0';
			
		ELSIF(clk9600 = '1' AND clk9600 = '1') THEN
			IF(CurrentStateRx = ProcessRx) THEN
					
				DataUARTRx(0).r <= to_integer(signed(DataSuperBufferRx(0)));
				DataUARTRx(0).i <= to_integer(signed(DataSuperBufferRx(1)));
				DataUARTRx(1).r <= to_integer(signed(DataSuperBufferRx(2)));
				DataUARTRx(1).i <= to_integer(signed(DataSuperBufferRx(3)));
				DataUARTRx(2).r <= to_integer(signed(DataSuperBufferRx(4)));
				DataUARTRx(2).i <= to_integer(signed(DataSuperBufferRx(5)));
				DataUARTRx(3).r <= to_integer(signed(DataSuperBufferRx(6)));
				DataUARTRx(3).i <= to_integer(signed(DataSuperBufferRx(7)));
				DataUARTRx(4).r <= to_integer(signed(DataSuperBufferRx(8)));
				DataUARTRx(4).i <= to_integer(signed(DataSuperBufferRx(9)));
				DataUARTRx(5).r <= to_integer(signed(DataSuperBufferRx(10)));
				DataUARTRx(5).i <= to_integer(signed(DataSuperBufferRx(11)));
				DataUARTRx(6).r <= to_integer(signed(DataSuperBufferRx(12)));
				DataUARTRx(6).i <= to_integer(signed(DataSuperBufferRx(13)));
				DataUARTRx(7).r <= to_integer(signed(DataSuperBufferRx(14)));
				DataUARTRx(7).i <= to_integer(signed(DataSuperBufferRx(15)));
				FinishProcessDataRx <= '1';
				
			ELSE
				FinishProcessDataRx <= '0';
				
			END IF;
			
		END IF;
		
	END PROCESS;

	
END Logica;
