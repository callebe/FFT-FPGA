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
		ActiveTxButton : IN STD_LOGIC;
		ActiveRxButton : IN STD_LOGIC;
		Entrada : IN ComplexVector(7 DOWNTO 0);
		Saida : OUT ComplexVector(7 DOWNTO 0);
		Tx : OUT STD_LOGIC);
END UARTDevice;

ARCHITECTURE Logica OF UARTDevice IS
		
	TYPE DataInputOutput IS ARRAY(13 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL DataTx: DataInputOutput;
	SIGNAL DataRx: DataInputOutput;
	SIGNAL DataTxBuffer: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL DataRxBuffer: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL clk9600 : STD_LOGIC := '0';
	SIGNAL clk153600 : STD_LOGIC := '0';
	SIGNAL ActiveTx : STD_LOGIC := '0';
	SIGNAL FinishRx : STD_LOGIC := '0';
	SIGNAL FinishTx : STD_LOGIC := '0';
	SIGNAL CounterData :  INTEGER := 0;
	SIGNAL UpdateData : STD_LOGIC := '0';
	
BEGIN

	DataTx(12) <= "01101001"; -- caractere i, usado na sintax dos dados Tx
	DataTx(13) <= "00001101"; -- caractere \r, usado na sintax dos dados Tx
	DataTx(14) <= "00001110"; -- caractere \n, usado na sintax dos dados Tx
	
	---------------------------------------------------------------
	--                       Clocks para UART                    --
	---------------------------------------------------------------
	clkGen153600 : BaudRate GENERIC MAP (50000000, 153600) PORT MAP (clk, clk153600);
	clkGen9600 : BaudRate GENERIC MAP (50000000, 9600) PORT MAP (clk, clk9600);
	clkGen153600 : BaudRate GENERIC MAP (50000000, 153600) PORT MAP (clk, clk153600);
	clkGen9600 : BaudRate GENERIC MAP (50000000, 9600) PORT MAP (clk, clk9600);
	
	---------------------------------------------------------------
	--                       UART - Tx & Rx                      --
	---------------------------------------------------------------
	UART0Tx : UARTTx port map (clk9600, reset, ActiveTx, DataTxBuffer, tx, FinishTx);
	UART0Rx : UARTRx port map (clk153600, reset, rx, DataRxBuffer, FinishRx);
	
	---------------------------------------------------------------
	--          Processo de Devisão de Dados Para Envio          --
	---------------------------------------------------------------
	
	
	
	---------------------------------------------------------------
	--          Processo de Devisão de Dados Para Envio          --
	---------------------------------------------------------------
	SplitDataSend : PROCESS(reset, UpdateData)
		
		VARIABLE Aux: INTEGER RANGE 9 DOWNTO 0 := 0;
		VARIABLE AuxB: INTEGER RANGE 9 DOWNTO 0 := 0;
	
	BEGIN
		
		IF(reset = '1') THEN
			DataTx <= ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000");
		
		ELSIF(UpdateData'EVENT AND UpdateData = '1') THEN
			 
			----------------------------------
			IF(Saida(CounterData).r > 0) THEN
				AuxB := Saida(CounterData).r;			
				Aux := Saida(CounterData).r*1677;
				DataTx(0) <= "00101011"; -- caractere +
			
			ELSE
				AuxB := -1*Saida(CounterData).r;			
				Aux := -1*Saida(CounterData).r*1677;
				DataTx(0) <= "00101101"; -- caractere -
			
			END IF;
			
			Aux := Aux/(2**24);
			DataTx(1) <= ("0011" & to_unsigned(Aux, 4));
			
			Aux := AuxB - Aux*10000;
			AuxB := Aux;
			Aux := Aux*16777;
			Aux := Aux/2**24;
			DataTx(2) <= ("0011" & to_unsigned(Aux, 4));
			
			Aux := AuxB - Aux*1000;
			AuxB := Aux;
			Aux := Aux*167772;
			Aux := Aux/2**24;
			DataTx(3) <= ("0011" & to_unsigned(Aux, 4));
			
			Aux := AuxB - Aux*100;
			AuxB := Aux;
			Aux := Aux*1677721;
			Aux := Aux/2**24;
			DataTx(4) <= ("0011" & to_unsigned(Aux, 4));
			
			Aux := AuxB - Aux*10;
			AuxB := Aux;
			Aux := Aux*16777216;
			Aux := Aux/2**24;
			DataTx(5) <= ("0011" & to_unsigned(Aux, 4));
			
			----------------------------------
			IF(Saida(CounterData).i > 0) THEN
				AuxB := Saida(CounterData).i;			
				Aux := Saida(CounterData).i*1677;
				DataTx(6) <= "00101011"; -- caractere +
			
			ELSE
				AuxB := -1*Saida(CounterData).i;			
				Aux := -1*Saida(CounterData).i*1677;
				DataTx(6) <= "00101101"; -- caractere -
			
			END IF;
			
			Aux := Aux/(2**24);
			DataTx(7) <= ("0011" & to_unsigned(Aux, 4));
			
			Aux := AuxB - Aux*10000;
			AuxB := Aux;
			Aux := Aux*16777;
			Aux := Aux/2**24;
			DataTx(8) <= ("0011" & to_unsigned(Aux, 4));
			
			Aux := AuxB - Aux*1000;
			AuxB := Aux;
			Aux := Aux*167772;
			Aux := Aux/2**24;
			DataTx(9) <= ("0011" & to_unsigned(Aux, 4));
			
			Aux := AuxB - Aux*100;
			AuxB := Aux;
			Aux := Aux*1677721;
			Aux := Aux/2**24;
			DataTx(10) <= ("0011" & to_unsigned(Aux, 4));
			
			Aux := AuxB - Aux*10;
			AuxB := Aux;
			Aux := Aux*16777216;
			Aux := Aux/2**24;
			DataTx(11) <= ("0011" & to_unsigned(Aux, 4));
			
		END IF;
		
	END PROCESS;
		
	---------------------------------------------------------------
	--               Processo de Envio de Dados                  --
	---------------------------------------------------------------
	SendData: PROCESS (reset, FinishTx)
	
		VARIABLE Counter: INTEGER RANGE 13 DOWNTO 0;
		
	BEGIN
		
		IF(reset = '1') THEN 
			DataTx <= "00000000";
			
		ELSIF(FinishTx = '1' AND FinishTx'EVENT) THEN
			IF(ActiveTxButton = '1') THEN
				DataTxBuffer <= DataTx(Counter);
				Counter := Counter + 1;
				IF(Counter = 0) THEN
					CounterData <= CounterData + 1;
					UpdateData <= '1';
				
				ELSE
					UpdateData <= '0';
					
				END IF;
			
			ELSE
				Counter := 0;
				CounterData <= 0;
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	---------------------------------------------------------------
	--         Gatilho de Acionamento do Transmissão             --
	---------------------------------------------------------------
	TriggerTx: PROCESS (reset, clk) 
	
	BEGIN
		
		IF(reset = '1') THEN
			ActiveTx <= '0';
			
		ELSIF(clk = '1' AND clk'EVENT) THEN
			IF(ActiveTxButton = '1' AND FinishTx = '1') THEN
				ActiveTx <= '1';
			
			ELSE
				ActiveTx <= '0';
			
			END IF;
			
		END IF;
	
	END PROCESS;
									  
END Logica;
