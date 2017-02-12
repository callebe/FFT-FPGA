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
	SIGNAL DataRxBuffer: STD_LOGIC_VECTOR(7 DOWNTO 0);
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
	SIGNAL BreakTx: STD_LOGIC := '0';
	
BEGIN

	---------------------------------------------------------------
	--                       Clocks para UART                    --
	---------------------------------------------------------------
	clkGen153600 : BaudRate GENERIC MAP (50000000, 153600) PORT MAP (clk, clk153600);
	clkGen9600 : BaudRate GENERIC MAP (50000000, 9600) PORT MAP (clk, clk9600);
		
	---------------------------------------------------------------
	--                       UART - Tx & Rx                      --
	---------------------------------------------------------------
	UART0Tx : UARTTx port map (clk9600, reset, ActiveTx, DataTxBuffer, tx, FinishTx);
	UART0Rx : UARTRx port map (clk153600, reset, rx, DataRxBuffer, FinishRx);
	
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
		
		VARIABLE Aux : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		VARIABLE AuxB : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
		VARIABLE AuxNum : INTEGER RANGE INTEGER'LOW TO INTEGER'HIGH;
		VARIABLE AuxNumB : INTEGER RANGE INTEGER'LOW TO INTEGER'HIGH;
		
	BEGIN
		
		IF(reset = '1') THEN
			DataTx <= ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000");
		
		ELSIF(UpdateDataTx'EVENT AND UpdateDataTx = '1') THEN
			
			AuxNum := DataUARTTx(CounterDataTx).r;
			AuxNumB := DataUARTTx(CounterDataTx).i;
			Aux := STD_LOGIC_VECTOR(TO_UNSIGNED(AuxNum, Aux'length));
			AuxB :=STD_LOGIC_VECTOR(TO_UNSIGNED(AuxNumB, AuxB'length));
			DataTx(3)(0) <= Aux(0);
			DataTx(3)(1) <= Aux(1);
			DataTx(3)(2) <= Aux(2);
			DataTx(3)(3) <= Aux(3);
			DataTx(3)(4) <= Aux(4);
			DataTx(3)(5) <= Aux(5);
			DataTx(3)(6) <= Aux(6);
			DataTx(3)(7) <= Aux(7);
			DataTx(2)(0) <= Aux(8);
			DataTx(2)(1) <= Aux(9);
			DataTx(2)(2) <= Aux(10);
			DataTx(2)(3) <= Aux(11);
			DataTx(2)(4) <= Aux(12);
			DataTx(2)(5) <= Aux(13);
			DataTx(2)(6) <= Aux(14);
			DataTx(2)(7) <= Aux(15);
			DataTx(1)(0) <= Aux(16);
			DataTx(1)(1) <= Aux(17);
			DataTx(1)(2) <= Aux(18);
			DataTx(1)(3) <= Aux(19);
			DataTx(1)(4) <= Aux(20);
			DataTx(1)(5) <= Aux(21);
			DataTx(1)(6) <= Aux(22);
			DataTx(1)(7) <= Aux(23);
			DataTx(0)(0) <= Aux(24);
			DataTx(0)(1) <= Aux(25);
			DataTx(0)(2) <= Aux(26);
			DataTx(0)(3) <= Aux(27);
			DataTx(0)(4) <= Aux(28);
			DataTx(0)(5) <= Aux(29);
			DataTx(0)(6) <= Aux(30);
			DataTx(0)(7) <= Aux(31);
			----------------------
			DataTx(7)(0) <= AuxB(0);
			DataTx(7)(1) <= AuxB(1);
			DataTx(7)(2) <= AuxB(2);
			DataTx(7)(3) <= AuxB(3);
			DataTx(7)(4) <= AuxB(4);
			DataTx(7)(5) <= AuxB(5);
			DataTx(7)(6) <= AuxB(6);
			DataTx(7)(7) <= AuxB(7);
			DataTx(6)(0) <= AuxB(8);
			DataTx(6)(1) <= AuxB(9);
			DataTx(6)(2) <= AuxB(10);
			DataTx(6)(3) <= AuxB(11);
			DataTx(6)(4) <= AuxB(12);
			DataTx(6)(5) <= AuxB(13);
			DataTx(6)(6) <= AuxB(14);
			DataTx(6)(7) <= AuxB(15);
			DataTx(5)(0) <= AuxB(16);
			DataTx(5)(1) <= AuxB(17);
			DataTx(5)(2) <= AuxB(18);
			DataTx(5)(3) <= AuxB(19);
			DataTx(5)(4) <= AuxB(20);
			DataTx(5)(5) <= AuxB(21);
			DataTx(5)(6) <= AuxB(22);
			DataTx(5)(7) <= AuxB(23);
			DataTx(4)(0) <= AuxB(24);
			DataTx(4)(1) <= AuxB(25);
			DataTx(4)(2) <= AuxB(26);
			DataTx(4)(3) <= AuxB(27);
			DataTx(4)(4) <= AuxB(28);
			DataTx(4)(5) <= AuxB(29);
			DataTx(4)(6) <= AuxB(30);
			DataTx(4)(7) <= AuxB(31);
			
		END IF;
		
	END PROCESS;
									  
END Logica;
