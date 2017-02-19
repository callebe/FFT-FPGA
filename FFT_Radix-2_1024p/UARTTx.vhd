--------------------------------------------------------------------
--------------------------------------------------------------------
--                                                                --
--                     Trasmissão UART                            --
--    O clock usado na trasmissão está a 9600 Hz, para transmitir --
-- a 9600 bps, a atualização é feita a cada 16 ciclos no processo --
-- 'UpdateStates'.                                                --   
--                                                                --
--       clk -> 9600 Hz                                          --
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

ENTITY UARTTx IS
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ActiveTx : IN STD_LOGIC;
		DataTx  : IN STD_LOGIC_VECTOR(7 downto 0);
		Tx : OUT STD_LOGIC;
		FinishTx : OUT STD_LOGIC);
END ENTITY;


ARCHITECTURE Logic OF UARTTx IS

	SIGNAL CounterTx : INTEGER RANGE 0 TO 7 := 0;
	TYPE State IS (ResetTx, IdleTx, StartTx, SendTx, StopTx);
	SIGNAL CurrentState: State := IdleTx;
	SIGNAL NextState : State := IdleTx;
	
BEGIN

	---------------------------------------------------------------
	--                   Atualização de Estatos                  --
	---------------------------------------------------------------
	UpdateStates : PROCESS(clk, reset)

	BEGIN
	
		IF(reset = '1') THEN
			CurrentState <= ResetTx;
			CounterTx   <= 0;
		
		ELSIF (clk = '1' AND clk'event) THEN
			CurrentState <= NextState;
			IF (CurrentState = SendTx) THEN
			  CounterTx  <= CounterTx  + 1;
			ELSE
			  CounterTx  <= 0;
			END if;
		END if;
	
	END PROCESS;

	---------------------------------------------------------------
	--                   Máquinas de Estados                     --
	---------------------------------------------------------------
	StateMachine : PROCESS(CurrentState, ActiveTx, CounterTx)
	
	BEGIN
	
		CASE CurrentState IS
			
			WHEN ResetTx =>
				FinishTx <= '0';
				Tx <= '1';
				NextState <= IdleTx;
			
			WHEN IdleTx =>
				FinishTx <= '1';
				Tx <= '1';
				IF(ActiveTx = '1') THEN
					NextState <= StartTx;
				ELSE
					NextState <= IdleTx;
				END if;
			
			WHEN StartTx =>
				FinishTx <= '0';
				Tx <= '0';
				NextState <= SendTx;

			WHEN SendTx =>
				FinishTx <= '0';
				Tx <= DataTx(CounterTx);
				IF(CounterTX = 7) THEN
					NextState <= StopTx;
				ELSE
					NextState <= SendTx;
				END if;
				
			WHEN StopTx =>
				FinishTx <= '0';
				Tx <= '1';
				NextState <= IdleTx;
			
			WHEN OTHERS =>
				FinishTx <= '0';
				Tx <= '1';
				NextState <= ResetTx;
		
		END CASE;
		
	END PROCESS;
	 
END Logic;