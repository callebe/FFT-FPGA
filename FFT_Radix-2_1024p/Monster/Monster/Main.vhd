LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.ALL;

ENTITY Main IS
	PORT(Clock : IN STD_LOGIC;
		  reset : IN STD_LOGIC;
		  StartBotton : IN STD_LOGIC; 
		  Rx : IN STD_LOGIC;
		  Tx : OUT STD_LOGIC;
		  IdleIndicator : OUT STD_LOGIC;
		  ReceiveDataIndicator : OUT STD_LOGIC;
		  SendDataIndicator : OUT STD_LOGIC);
END Main;

ARCHITECTURE Logica OF Main IS
	
	CONSTANT NumberOfFFT : INTEGER := 8;
	SIGNAL DataUARTTx: ComplexVector(7 DOWNTO 0);
	SIGNAL BeginTx : STD_LOGIC := '0';   
	SIGNAL BeginRx : STD_LOGIC := '0';
	SIGNAL EndTx : STD_LOGIC := '0';
	SIGNAL EndRx : STD_LOGIC := '0';
	SIGNAL StartBottonDebounce : STD_LOGIC := '0';
	SIGNAL resetDebounce : STD_LOGIC := '0';
	SIGNAL CurrentState : StateFFT := Idle;
	SIGNAL NextState : StateFFT := Idle;
	
	BEGIN
	
	---------------------------------------------------------------
	--                   Debounce dos Botões                     --
	---------------------------------------------------------------
	SW : debounce PORT MAP (Clock, ResetDebounce, StartBotton, StartBottonDebounce);
	
	---------------------------------------------------------------
	--                   Dispositivo UART                        --
	---------------------------------------------------------------
	UART0 : UARTDevice GENERIC MAP (NumberOfFFT) PORT MAP (Clock, reset, Rx, BeginTx, BeginRx, DataUARTTx, DataUARTTx, Tx, EndTx, EndRx);	
	
	---------------------------------------------------------------
	--               Processo de Controle da FFT                 --
	---------------------------------------------------------------
	-- Máquina de Estados
	StateMachine : PROCESS(CurrentState, StartBottonDebounce, EndRx, EndTx)
	
	BEGIN
	
		CASE CurrentState IS
		
			WHEN ResetFFT =>
				BeginTx <= '0';
				BeginRx <= '0';
				NextState <= Idle;
				IdleIndicator <= '0';
				ReceiveDataIndicator <= '0';
				SendDataIndicator <= '0';
				ResetDebounce <= '1';
				
			WHEN Idle =>
				BeginTx <= '0';
				BeginRx <= '0';
				IdleIndicator <= '1';
				ReceiveDataIndicator <= '0';
				SendDataIndicator <= '0';
				ResetDebounce <= '0';
				IF(StartBottonDebounce = '1') THEN
					NextState <= ReceiveData;
					
				ELSE
					NextState <= Idle;
					
				END IF;
				
			WHEN ReceiveData =>
				BeginTx <= '0';
				BeginRx <= '1';
				IdleIndicator <= '0';
				ReceiveDataIndicator <= '1';
				SendDataIndicator <= '0';
				ResetDebounce <= '1';
				IF(EndRx = '1') THEN
					NextState <= TransmitData;
					
				ELSE
					NextState <= ReceiveData;
				
				END IF;
				
			WHEN TransmitData =>
				BeginTx <= '1';
				BeginRx <= '0';
				IdleIndicator <= '0';
				ReceiveDataIndicator <= '0';
				SendDataIndicator <= '1';
				ResetDebounce <= '1';
				IF(EndTx = '1') THEN
					NextState <= Idle;
					
				ELSE 
					NextState <= TransmitData;
					
				END IF;
				
			WHEN OTHERS =>
				BeginTx <= '0';
				BeginRx <= '0';
				NextState <= Idle;
				IdleIndicator <= '0';
				ReceiveDataIndicator <= '0';
				SendDataIndicator <= '0';
				ResetDebounce <= '1';
				
		END CASE;
	
	END PROCESS;
	
	-- Atualização de Estados
	UpdateStates : PROCESS(Clock, reset)
	
	BEGIN
	
		IF(reset = '1') THEN
			CurrentState <= ResetFFT;
		
		ELSIF(Clock = '1' AND Clock'EVENT) THEN
			CurrentState <= NextState;
			
		END IF;
	
	END PROCESS;
	
	
END Logica;