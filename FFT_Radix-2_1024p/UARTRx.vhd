--------------------------------------------------------------------
--------------------------------------------------------------------
--                                                                --
--                       Recepção UART                            --
--    O clock usado na recepção está a 153600 Hz, exatamente 16   --
-- vezes maior que a velocidade de transmissão (9600 Hz). Para    --
-- que assim possa notar as mudanças no sinal durante o ciclo do  --   
-- sinal de 9600 Hz com resolução de 16 pontos.                   --
--                                                                --
--       clk -> 9600 Hz                                           --
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
	
	SIGNAL CounterData : INTEGER  RANGE 7 TO 0 := 0;
	SIGNAL Ping : INTEGER RANGE 15 DOWNTO 0 := 0;
	SIGNAL data_buffer : std_logic_vector(7 downto 0);
	SIGNAL FilterRx : STD_LOGIC := '1';
	SIGNAL CurrentStateRx : INTEGER  RANGE 3 TO 0 := 3;
	SIGNAL NextStateRx : INTEGER  RANGE 3 TO 0 := 3;
	 
BEGIN
   
	DataRx <= data_buffer;

	---------------------------------------------------------------
	--              Filtro do Sinal de Entrada Rx                --
	---------------------------------------------------------------
	
	-- Atualização de Estados do Filtro
	FilterUpdateStates : PROCESS(clk, reset)
	
	BEGIN
	
		IF(reset = '1') THEN
			CurrentStateRx <= '3';
		
		ELSIF(clk = '1' and clk'event) THEN
			CurrentStateRx <= NextStateRx;
		
		END IF;
		
	END PROCESS;
	
	-- Máquina de Estado do Filtro
	FilterStateMachine : PROCESS(CurrentStateRx, Rx)
	
	BEGIN
				
		CASE CurrentStateRx IS
			
			WHEN 0 =>
				FilterRx <= '0';
				IF(Rx = '0') THEN
					NextStateRx <= 0;
					
				ELSE
					NextStateRx <= 1;
				END IF;
				
			WHEN 1 =>
				FilterRx <= '0';
				IF(Rx = '0') THEN
					NextStateRx <= 0;
					
				ELSE
					NextStateRx <= 2;
				END IF;
				
			WHEN 2 =>
				FilterRx <= '1';
				IF(Rx = '0') THEN
					NextStateRx <= 1;
					
				ELSE
					NextStateRx <= 3;
				END IF;
			
			WHEN 3 =>
				FilterRx <= '1';
				IF(Rx = '0') THEN
					NextStateRx <= 2;
					
				ELSE
					NextStateRx <= 3;
				END IF;
			
			WHEN OTHERS =>
				FilterRx <= '1';
				NextStateRx <= 3;
				
		END CASE;
			
	END PROCESS;

    -- Updates the states in the statemachine at a 115200 bps rate
    clkgen_115k2 : process(clk, reset)
    begin
        if (reset = '1') then
            Ping        <= 0;
            CurrentState <= ResetRx;
            CounterData  <= 0;
            data_buffer   <= (others => '0');
        elsif (clk = '1' and clk'event) then
            if (Ping = 15 or (CurrentState = IdleRx and NextState = SendRx and Ping = 7) or (CurrentState = IdleRx and NextState = IdleRx))  then
                Ping <= 0;
                CurrentState <= NextState;
                if (CurrentState = SendRx) then
                    data_buffer  <= FilterRx & data_buffer(7 downto 1);
                    CounterData <= CounterData + 1;
                else
                    data_buffer  <= data_buffer;
                    CounterData <= 0;
                end if;
            else
                data_buffer   <= data_buffer;
                CurrentState <= CurrentState;
                Ping <= Ping + 1;
            end if;
        end if;
    end process clkgen_115k2;

    rx_control : process (CurrentState, FilterRx, CounterData)
    begin
        case CurrentState is
		  
            when ResetRx =>
                FinishRx <= '0';
                NextState <= IdleRx;
            
				when IdleRx =>
                FinishRx <= 'X';
                if (FilterRx = '0') then
                    NextState <= SendRx;
                else
                    NextState <= IdleRx;
                end if;
            
				when SendRx =>
                FinishRx <= '0';
                if (CounterData = 7) then
                    NextState <= StopRx;
                else
                    NextState <= SendRx;
                end if;
            
				when StopRx =>
                FinishRx <= '1';
                if (FilterRx = '1') then
                    NextState <= IdleRx;
                else
                    NextState <= StopRx;
                end if;
            
				when others =>
                FinishRx <= '0';
                NextState <= ResetRx;
					 
        end case;
		  
    end process rx_control;
	 
END Logic;
