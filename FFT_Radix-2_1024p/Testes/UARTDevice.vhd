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
	TYPE State IS (Resetx, Idlex, Sendx);
	SIGNAL CurrentStateTx : State := Idlex;
	SIGNAL NextStateTx : State := Idlex;
	-- Variaveis de Buffer de Transmissão e Recepção
	SIGNAL DataTxBuffer: STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111111";
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
	SIGNAL CounterDataTx :  INTEGER RANGE 7 DOWNTO 0 := 0;
	SIGNAL UpdateDataTx : STD_LOGIC := '0';
	SIGNAL BreakTx : STD_LOGIC := '0';
	-- Variaveis de controle de recepção de Conjunto de Bytes
	SIGNAL CounterDataRx :  INTEGER RANGE 8 DOWNTO 0 := 0;
		
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
	StateMachine : PROCESS(CurrentStateTx, BeginTx, BreakTx)
	
	BEGIN
	
		CASE CurrentStateTx IS
			
			WHEN ResetX =>
				EndTx <= '1';
				NextStateTx <= Idlex;
				
			WHEN Idlex =>
				EndTx <= '1';
				IF(BeginTx = '1') THEN
					NextStateTx <= Sendx;
				ELSE 
					NextStateTx <= Idlex;
				END IF;	
				
			WHEN Sendx =>
				EndTx <= '0';
				IF(BreakTx = '1') THEN
					NextStateTx <= Idlex;
					
				ELSE
					NextStateTx <= Sendx;
					
				END IF;
			
			WHEN OTHERS =>
				EndTx <= '1';
				NextStateTx <= Idlex;
				
		END CASE;
	
	END PROCESS;
	
	-- Atualização de Estados
	UpdateStates : PROCESS(clk, reset)

	BEGIN
	
		IF(reset = '1') THEN
			CurrentStateTx <= Resetx;
		
		ELSIF (clk = '1' AND clk'event) THEN
			CurrentStateTx <= NextStateTx;
		
		END IF;
	
	END PROCESS;
	
	---------------------------------------------------------------
	--               Processo de Envio de Dados                  --
	---------------------------------------------------------------
	SendData: PROCESS (reset, FinishTx, BreakTx, EndTx, CounterDataTx)
	
		VARIABLE Counter: INTEGER RANGE 7 DOWNTO 0;
		VARIABLE Initializar : STD_LOGIC := '0';
		
	BEGIN
		
		IF(reset = '1') THEN 
			DataTxBuffer <= "00000000";
			Counter := 0;
			CounterDataTx <= 0;
			UpdateDataTx <= '0';
			BreakTx <= '0';
			
		ELSIF(clk9600 = '1' AND clk9600'EVENT) THEN
			IF(EndTx = '0') THEN
				IF(Initializar = '0') THEN
					Initializar := '1';
					Counter := 0;
					CounterDataTx <= 0;
					UpdateDataTx <= '1';
					BreakTx <= '0';
					
				
				ELSE
					DataTxBuffer <= DataTx(Counter);
					IF (FinishTx = '1') THEN
						IF(Counter = 7) THEN
							Counter := 0;
							IF(CounterDataTx = 7) THEN
								CounterDataTx <= 0;
								UpdateDataTx <= '0';
								BreakTx <= '1';
								
							ELSE
								CounterDataTx <= CounterDataTx + 1;
								UpdateDataTx <= '1';
								BreakTx <= '0';
						
							END IF;
							
						ELSE
							Counter := Counter + 1;
							UpdateDataTx <= '0';
							BreakTx <= '0';
							
						END IF;
					
					END IF;
					
				END IF;
			
			ELSE
				DataTxBuffer <= "00000000";
				Counter := 0;
				CounterDataTx <= 0;
				UpdateDataTx <= '0';
				BreakTx <= '0';
			END IF;
			
		END IF;
		
	END PROCESS;
	
	---------------------------------------------------------------
	--         Gatilho de Acionamento do Transmissão             --
	---------------------------------------------------------------
	ActiveTx <=  FinishTx AND (not EndTx) AND (not reset);
	
		
	---------------------------------------------------------------
	--          Processo de Devisão de Dados Para Envio          --
	---------------------------------------------------------------
	SplitDataSend : PROCESS(reset, UpdateDataTx)
		
		VARIABLE BuffTxVector : STD_LOGIC_VECTOR(31 DOWNTO 0);
		VARIABLE BuffTxBVector : STD_LOGIC_VECTOR(31 DOWNTO 0);
		VARIABLE AuxNum : INTEGER RANGE INTEGER'LOW TO INTEGER'HIGH;
		VARIABLE AuxNumB : INTEGER RANGE INTEGER'LOW TO INTEGER'HIGH;
		
	BEGIN
		
		IF(reset = '1') THEN
			DataTx <= ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000");
			AuxNum := 0;
			AuxNumB := 0;
		
		ELSIF(clk'EVENT AND clk = '1') THEN
			IF(UpdateDataTx = '1') THEN
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
			
			END IF;
			
		END IF;
		
	END PROCESS;
	
	---------------------------------------------------------------
	--              Processo de Controle da Recepção             --
	---------------------------------------------------------------
	PROCESS (reset, clk)
	
		VARIABLE Counter : INTEGER RANGE 0 TO 8 := 0;
		VARIABLE Aux : INTEGER RANGE INTEGER'LOW TO INTEGER'HIGH := 0;
		VARIABLE AuxExp : INTEGER RANGE 0 TO 63 := 0;
			
	BEGIN
	
		IF(reset = '1') THEN
			Counter := 0;
			CounterDataRx := 0;
			
		ELSIF(clk'EVENT AND clk = '1') THEN
			IF(BeginRx = '1') THEN
				IF(FinishRx = '1') THEN
					Aux := TO_INTEGER(signed(DataRxBuffer));
					IF(Counter < 4) THEN
						AuxExp := Counter*8;
						DataUARTRx(CounterDataRx).r <= Aux * (2**(AuxExp));
						
					ELSE
						AuxExp := (Counter-4)*8;
						DataUARTRx(CounterDataRx).i <= Aux * (2**(AuxExp));
					
					END IF;
					Counter := Counter + 1;
					IF(Counter = 8) THEN
						Counter := 0;
						CounterDataRx <= CounterDataRx + 1;
						IF(CounterDataRx = 8) THEN
							EndRx <= '1';
							
						ELSE
							EndRx <= '0';
							
						END IF;
						
					END IF;
					
				END IF;
				
			END IF; 
			
		END IF;
	
	END PROCESS;
									  
END Logica;
