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
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.ALL;

ENTITY UARTRceived IS
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		Rx : IN STD_LOGIC;
		DataRx : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		FinishRx : OUT STD_LOGIC);
END UARTRceived;


ARCHITECTURE Logica OF uart_rx IS
    
	 TYPE StateTx IS (ResetState, IdleState, ReceiveState, StopState);
    SIGNAL ActualState, NextState : StateTx;
    SIGNAL CounterRx  : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Ticker : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL DataBuffer : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL RxFiltered : STD_LOGIC := '1';
    SIGNAL RxState : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
	 SIGNAL clk9600 : STD_LOGIC := '0';

BEGIN

	---------------------------------------------------------------
	--                       Clocks para UART                    --
	---------------------------------------------------------------
	clkGen9600 : BaudRate GENERIC MAP (153600, 9600) PORT MAP (clk, clk9600);
	
   DataRx <= DataBuffer;

   ---------------------------------------------------------------
	--                       Filtro 4 Níveis                     --
	---------------------------------------------------------------
	FiltroSinal : PROCESS(clk, reset)
	
	BEGIN
	
		IF(reset = '1') THEN
			RxFiltered <= '1';
			RxState    <= "11";

		ELSIF(clk = '1' AND clk'event) THEN
			IF(Rx = '0' AND RxState /= "00") THEN
				IF(RxState = "01") THEN
					RxFiltered <= '0';
				END IF;
				RxState <= RxState - 1;
			
			ELSIF(Rx = '1' AND RxState /= "11") THEN
				IF(RxState = "10") THEN
					RxFiltered <= '1';
				END IF;
				RxState <= RxState + 1;
				
			end if;
		end if;
		
	END PROCESS;

   ---------------------------------------------------------------
	--                  Autalização de Estados                   --
	---------------------------------------------------------------
	UpdateState : PROCESS(clk, reset)
	
	BEGIN
	
		IF(reset = '1') THEN
			Ticker <= (OTHERS => '0');
			CounterRx <= "000";
			DataBuffer <= (OTHERS => '0');
			
		ELSIF(clk = '1' AND clk'event) THEN
			IF(Ticker = 15 OR (ActualState = IdleState AND NextState = ReceiveState AND Ticker = 7) OR (ActualState = IdleState AND NextState = IdleState)) THEN
				Ticker  <= (OTHERS => '0');
				IF(ActualState = ReceiveState) THEN
					DataBuffer  <= RxFiltered & DataBuffer(7 DOWNTO 1);
					CounterRx <= CounterRx + 1;
					
				ELSE
					DataBuffer <= DataBuffer;
					CounterRx <= "000";
					
				END IF;
				
			ELSE
			
			DataBuffer <= DataBuffer;
			Ticker <= Ticker + 1;
			
			END IF;
			
		END IF;
		
	END PROCESS;
	
	---------------------------------------------------------------
	--                       Máquinas Estados                    --
	---------------------------------------------------------------
	StateMachine : PROCESS (ActualState, RxFiltered, CounterRx)
	
	BEGIN

		CASE ActualState IS
		
			WHEN ResetState =>
				FinishRx <= '0';
				NextState <= IdleState;
				
			WHEN IdleState =>
				FinishRx <= '0';
				IF (RxFiltered = '0') THEN
				  NextState <= ReceiveState;
				
				ELSE
				  NextState <= IdleState;
				
				END IF;
				
			WHEN ReceiveState =>
				FinishRx <= '0';
				IF(CounterRx = 7) THEN
				  NextState <= StopState;
				  
				ELSE
				  NextState <= ReceiveState;
				  
				end if;
				
			WHEN StopState =>
				FinishRx <= '1';
				IF(RxFiltered = '1') THEN
				  NextState <= IdleState;
				  
				ELSE
				  NextState <= StopState;
				  
				END IF;
				
			WHEN OTHERS =>
				FinishRx <= '0';
				NextState <= ResetState;
		
		END CASE;
		
	END PROCESS;
	
	-- Atualização de Estados
	UpdateStatesRx : PROCESS(clk9600, reset)

	BEGIN
	
		IF(reset = '1') THEN
			ActualState <= ResetState;
		
		ELSIF (clk9600 = '1' AND clk9600'EVENT) THEN
			ActualState <= NextState;
		
		END IF;
	
	END PROCESS;
	
END Logica;