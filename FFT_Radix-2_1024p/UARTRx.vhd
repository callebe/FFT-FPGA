--------------------------------------------------------------------
--------------------------------------------------------------------
--                                                                --
--                       Recepção UART                            --
--    O clock usado na recepção está a 153600 Hz, exatamente 16   --
-- vezes maior que a velocidade de transmissão (9600 Hz). Para    --
-- que assim possa notar as mudanças no sinal durante o ciclo do  --   
-- sinal de 9600 Hz com resolução de 16 pontos.                   --
--                                                                --
--       clk -> 153600 Hz                                           --
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
		DataRx : BUFFER STD_LOGIC_VECTOR(7 downto 0);
		FinishRx : OUT STD_LOGIC);
END UARTRx;

ARCHITECTURE Logic OF UARTRx IS

	SIGNAL Ping : INTEGER RANGE 15 DOWNTO 0 := 0;
	TYPE State IS (ResetRx, IdleRx, SendRx, StopRx);
	SIGNAL CurrentState : State := IdleRx;
	SIGNAL NextState : State := IdleRx;
	SIGNAL CounterData : INTEGER  RANGE 7 DOWNTO 0 := 0;
	SIGNAL FilterRx : STD_LOGIC := '1';
	SIGNAL CurrentStateRx : INTEGER  RANGE 3 DOWNTO 0 := 3;
	 
BEGIN

	---------------------------------------------------------------
	--              Filtro do Sinal de Entrada Rx                --
	---------------------------------------------------------------
	FilterStateMachine : PROCESS(clk, reset)
	
	BEGIN
	
		IF(reset = '1') THEN
			FilterRx <= '1';
			CurrentStateRx <= 3;
		
		ELSIF(clk = '1' AND clk'event) THEN
			IF(Rx = '0' AND CurrentStateRx /= 0) THEN
				IF(CurrentStateRx = 1) THEN
					FilterRx <= '0';
				
				END IF;
				CurrentStateRx <= CurrentStateRx - 1;
			
			ELSIF(Rx = '1' AND CurrentStateRx /= 3) then
				IF(CurrentStateRx = 2) THEN
					FilterRx <= '1';
			
				END IF;
				CurrentStateRx <= CurrentStateRx + 1;
			
			END IF;
		
		END IF;
	
	END PROCESS;
	
	---------------------------------------------------------------
	--                   Atualização de Estatos                  --
	---------------------------------------------------------------
	UpdateState : PROCESS(clk, reset)

	BEGIN
	
		IF(reset = '1') THEN
			Ping <= 0;
			CurrentState <= ResetRx;
			CounterData  <= 0;
			DataRx <= "00000000";
		
		ELSIF(clk = '1' AND clk'event) THEN
			IF(Ping = 15 OR (CurrentState = IdleRx AND NextState = SendRx AND Ping = 7) OR (CurrentState = IdleRx AND NextState = IdleRx)) THEN
				Ping <= 0;
				CurrentState <= NextState;
				
				IF(CurrentState = SendRx) THEN
					DataRx  <= FilterRx & DataRx(7 DOWNTO 1);
					CounterData <= CounterData + 1;
				
				ELSE
					DataRx  <= DataRx;
					CounterData <= 0;
				
				END IF;
			
			ELSE
				DataRx <= DataRx;
				CurrentState <= CurrentState;
				Ping <= Ping + 1;
			
			END IF;
		
		END IF;
	 
	END PROCESS;

	---------------------------------------------------------------
	--                   Máquinas de Estados                     --
	---------------------------------------------------------------
	StateMachine : PROCESS(CurrentState, FilterRx, CounterData)
	
	BEGIN
	
		CASE CurrentState IS

			WHEN ResetRx =>
				FinishRx <= '0';
				NextState <= IdleRx;

			WHEN IdleRx =>
				FinishRx <= 'X';
				IF(FilterRx = '0') THEN
					NextState <= SendRx;
				
				ELSE
					NextState <= IdleRx;
				
				END IF;

			WHEN SendRx =>
				FinishRx <= '0';
				IF(CounterData = 7) THEN
					NextState <= StopRx;
				
				ELSE
					NextState <= SendRx;
				
				END IF;

			WHEN StopRx =>
				FinishRx <= '1';
				IF(FilterRx = '1') THEN
					NextState <= IdleRx;
				
				ELSE
					NextState <= StopRx;
				
				END IF;

			WHEN OTHERS =>
				FinishRx <= '0';
				NextState <= ResetRx;

		END CASE;
	  
	END PROCESS;
	 
END Logic;
