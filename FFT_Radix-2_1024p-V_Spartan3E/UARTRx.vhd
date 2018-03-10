--------------------------------------------------------------------
--------------------------------------------------------------------
--                                                                --
--                       Recepção UART                            --
--    O clock usado na recepção está a 153600 Hz, exatamente 16   --
-- vezes maior que a velocidade de transmissão (9600 Hz). Para    --
-- que assim possa notar as mudanças no sinal durante o ciclo do  --   
-- sinal de 9600 Hz com resolução de 16 pontos.                   --
--                                                                --
--       clk -> 153600 Hz                                         --
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

ENTITY UARTRx IS
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		Rx : IN STD_LOGIC;
		DataRx : OUT STD_LOGIC_VECTOR(7 downto 0);
		FinishRx : OUT STD_LOGIC);
END UARTRx;

ARCHITECTURE Logic OF UARTRx IS

	TYPE State IS (ResetRx, IdleRx, SendRx, StopRx);
	SIGNAL CurrentState : State := IdleRx;
	SIGNAL NextState : State := IdleRx;
	SIGNAL CounterData : INTEGER  RANGE 7 DOWNTO 0 := 0;
	SIGNAL BeginRx : STD_LOGIC := '1';
	
BEGIN

	--------------------------------------------------------------
	--                       Recepção de Bits                   --
	--------------------------------------------------------------
	UpdateState : PROCESS(clk, reset, CurrentState)
	
		VARIABLE Ping : INTEGER RANGE 15 DOWNTO 0 := 0;

	BEGIN
		
		
		IF(reset = '1') THEN
			Ping := 0;
			CounterData  <= 0;
			DataRx <= "00000000";
		
		ELSIF(clk = '0' AND clk'event) THEN
			IF(CurrentState = SendRx) THEN
				DataRx(CounterData) <=  Rx;
				CounterData <= CounterData + 1;
				
			ELSE
				CounterData <= 0;
				BeginRx <= Rx;
				
			END IF;
				
		END IF;
	 
	END PROCESS;

	---------------------------------------------------------------
	--                   Máquinas de Estados                     --
	---------------------------------------------------------------
	StateMachine : PROCESS(CurrentState, BeginRx, CounterData)
	
	BEGIN
	
		CASE CurrentState IS

			WHEN ResetRx =>
				FinishRx <= '0';
				NextState <= IdleRx;

			WHEN IdleRx =>
				FinishRx <= '0';
				IF(BeginRx = '0') THEN
					NextState <= SendRx;
				
				ELSE
					NextState <= IdleRx;
				
				END IF;

			WHEN SendRx =>
				FinishRx <= '0';
				IF(CounterData = 8) THEN
					NextState <= StopRx;
				
				ELSE
					NextState <= SendRx;
				
				END IF;

			WHEN StopRx =>
				FinishRx <= '1';
				IF(BeginRx = '1') THEN
					NextState <= IdleRx;
				
				ELSE
					NextState <= StopRx;
				
				END IF;

			WHEN OTHERS =>
				FinishRx <= '0';
				NextState <= ResetRx;

		END CASE;
	  
	END PROCESS;
	
	-- Atualização de Estados
	UpdateStatesRx : PROCESS(clk, reset)

	BEGIN
	
		IF(reset = '1') THEN
			CurrentState <= ResetRx;
		
		ELSIF (clk = '1' AND clk'event) THEN
			CurrentState <= NextState;
			
		END IF;
	
	END PROCESS;
	 
END Logic;