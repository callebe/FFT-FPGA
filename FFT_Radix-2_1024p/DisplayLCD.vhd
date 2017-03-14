--------------------------------------------------------------------
--------------------------------------------------------------------
--                                                                --
--                     Dispositivo de Display                     --
--    Componente responsável por printar no LCD do Kit o Status   --
-- do Processo da FFT.                                            --   
--                                                                --
--       clk -> 50MHz                                             --
--			reset -> Sinal de Reset padrão                           --
--       Update -> Sinal de Atualização do Estado                 --
--       DATA -> Dados a serem printados                          --
--       LCD_E, LCD_RS, LCD_RW  -> Todos Sinais de Controle       --
--       do Display.                                              --
--       SF_D -> Sinais de Dados do Display.                      --
--                                                                --
--------------------------------------------------------------------
--------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.ALL;

ENTITY DisplayLCD IS
	PORT(clk : IN STD_LOGIC;
		  reset : IN STD_LOGIC;
		  Update : IN STD_LOGIC;
		  DATA: IN INFO;
		  DataLCD : OUT STD_LOGIC_VECTOR(3 downto 0);
		  LCD_E: OUT STD_LOGIC;
		  LCD_RS: OUT STD_LOGIC;
		  LCD_RW: OUT STD_LOGIC);
END DisplayLCD;

ARCHITECTURE Logica OF DisplayLCD IS
	
	TYPE tx_sequence IS (high_setup, high_hold, oneus, low_setup, low_hold, fortyus, done);
	SIGNAL tx_state : tx_sequence := done;
	SIGNAL tx_byte : STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL tx_init : STD_LOGIC := '0';
	SIGNAL tx_DATA: STD_LOGIC_VECTOR(7 downto 0);
	
	TYPE init_sequence IS (idle, fIFteenms, one, two, three, four, five, six, seven, eight, done);
	SIGNAL init_state : init_sequence := idle;
	SIGNAL init_init, init_done : STD_LOGIC := '0';
	
	SIGNAL i2 : integer range 0 to 2000 := 0;
	
	SIGNAL SF_D0, SF_D1 : STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL LCD_E0, LCD_E1 : STD_LOGIC;
	SIGNAL mux : STD_LOGIC;
	
	TYPE dISplay_state IS (init, function_set, entry_set, set_dISplay, clr_dISplay, pause, set_addr0, set_addr1, tx_info0, tx_info1, done);
	SIGNAL cur_state : dISplay_state := init;
	
	BEGIN
	
	--Apenas Escrever
	LCD_RW <= '0';
	
	--Seleção de Trasmissão (Ou dados ou Comandos)
	WITH cur_state SELECT
		tx_init <= '0' WHEN init | pause | done,
					  '1' WHEN others;
	
	--Controle de Barramento
	WITH cur_state SELECT
		mux <= '1' WHEN init,
				 '0' WHEN others;
	
	--Controle de sequencia de Inicialização
	WITH cur_state SELECT
		init_init <= '1' WHEN init,
						 '0' WHEN others;
	
	--Controle do Barramento
	WITH cur_state SELECT
		LCD_RS <= '0' WHEN function_set|entry_set|set_dISplay|clr_dISplay|set_addr0|set_addr1,
					 '1' WHEN others;
	
	--Seleção de Transmissão
	WITH cur_state SELECT
		tx_byte <= "00101000" WHEN function_set,
						"00000110" WHEN entry_set,
						"00001100" WHEN set_dISplay,
						"00000001" WHEN clr_dISplay,
						"10000000" WHEN set_addr0,
						"11000000" WHEN set_addr1,
						tx_DATA WHEN tx_info0,
						tx_DATA WHEN tx_info1,
						"00000000" WHEN others;
	
	-- Mux de seleção entre a trasmissão e a Inicialização
	WITH mux SELECT
		DataLCD <= SF_D0 WHEN '0', 
				     SF_D1 WHEN others; 
	
	WITH mux SELECT
		LCD_E <= LCD_E0 WHEN '0', --transmit
					LCD_E1 WHEN others; --initialize
					
	--main state machine
	Display: PROCESS(clk, reset)
	VARIABLE Position: INTEGER RANGE 0 TO 32 := 1;
	
		VARIABLE Counter : INTEGER RANGE 0 TO 82000 := 0;
	
	BEGIN
		IF(reset='1') THEN
			cur_state <= set_addr1;
			
		ELSIF(clk='1' and clk'event) THEN
			CASE cur_state IS
				--refer to intialize state machine below
				WHEN init =>
					IF(init_done = '1') THEN
						cur_state <= function_set;
					ELSE
						cur_state <= init;
					END IF;
				
				--every other state but pause uses the transmit state machine
				WHEN function_set =>
					IF(i2 = 2000) THEN
						cur_state <= entry_set;
					ELSE
						cur_state <= function_set;
					END IF;
				
				WHEN entry_set =>
					IF(i2 = 2000) THEN
						cur_state <= set_dISplay;
					ELSE
						cur_state <= entry_set;
					END IF;
				
				WHEN set_dISplay =>
					IF(i2 = 2000) THEN
						cur_state <= clr_dISplay;
					ELSE
						cur_state <= set_dISplay;
					END IF;
				
				WHEN clr_dISplay =>
					Counter := 0;
					IF(i2 = 2000) THEN
						cur_state <= pause;
					ELSE
						cur_state <= clr_dISplay;
					END IF;
				
				WHEN pause =>
					IF(Counter = 82000) THEN
						cur_state <= set_addr0;
						Counter := 0;
					ELSE
						cur_state <= pause;
						Counter := Counter + 1;
					END IF;
				
				WHEN set_addr0 =>
					IF(i2 = 2000) THEN
						cur_state <= tx_info0;
						tx_DATA <= DATA(0);
					ELSE
						cur_state <= set_addr0;
					END IF;
				
				WHEN tx_info0 =>
					IF(i2 = 2000) THEN
						IF(Position = 16) THEN
							Position := 1;
							cur_state <= set_addr1;
						ELSE
							tx_DATA <= DATA(Position);
							Position := Position + 1;
						END IF;
					ELSE
						cur_state <= tx_info0;
					END IF;
				
				WHEN set_addr1 =>
					IF(i2 = 2000) THEN
						cur_state <= tx_info1;
						tx_DATA <= DATA(16);
						Position := 17;
					ELSE
						cur_state <= set_addr1;
					END IF;
					
				WHEN tx_info1 =>
					IF(i2 = 2000) THEN
						IF(Position = 32) THEN
							Position := 17;
							cur_state <= done;
						ELSE
							tx_DATA <= DATA(Position);
							Position := Position + 1;
						END IF;
					ELSE
						cur_state <= tx_info1;
					END IF;
					
				WHEN done =>
					IF(Update = '1') THEN
						cur_state <= set_addr1;
						
					ELSE
						cur_state <= done;
						
					END IF;
					
		
			END CASE;
		
		END IF;
		
	END PROCESS Display;
	
	--Processo de Transmissao de acordo com Datasheet
	Transmissao : PROCESS(clk, reset, tx_init)
	BEGIN
	
		IF(reset='1') THEN
			tx_state <= done;
		ELSIF(clk='1' and clk'event) THEN
			CASE tx_state IS
				WHEN high_setup => --40ns
					LCD_E0 <= '0';
					SF_D0 <= tx_byte(7 downto 4);
					IF(i2 = 2) THEN
						tx_state <= high_hold;
						i2 <= 0;
					ELSE
						tx_state <= high_setup;
						i2 <= i2 + 1;
					END IF;
				
				WHEN high_hold => --230ns
					LCD_E0 <= '1';
					SF_D0 <= tx_byte(7 downto 4);
					IF(i2 = 12) THEN
						tx_state <= oneus;
						i2 <= 0;
					ELSE
						tx_state <= high_hold;
						i2 <= i2 + 1;
					END IF;
				
				WHEN oneus =>
					LCD_E0 <= '0';
					IF(i2 = 50) THEN
						tx_state <= low_setup;
						i2 <= 0;
					ELSE
						tx_state <= oneus;
						i2 <= i2 + 1;
					END IF;
				
				WHEN low_setup =>
					LCD_E0 <= '0';
					SF_D0 <= tx_byte(3 downto 0);
					IF(i2 = 2) THEN
						tx_state <= low_hold;
						i2 <= 0;
					ELSE
						tx_state <= low_setup;
						i2 <= i2 + 1;
					END IF;
				
				WHEN low_hold =>
					LCD_E0 <= '1';
					SF_D0 <= tx_byte(3 downto 0);
					IF(i2 = 12) THEN
						tx_state <= fortyus;
						i2 <= 0;
					ELSE
						tx_state <= low_hold;
						i2 <= i2 + 1;
					END IF;
				
				WHEN fortyus =>
					LCD_E0 <= '0';
					IF(i2 = 2000) THEN
						tx_state <= done;
						i2 <= 0;
					ELSE
						tx_state <= fortyus;
						i2 <= i2 + 1;
					END IF;
				
				WHEN done =>
					LCD_E0 <= '0';
					IF(tx_init = '1') THEN
						tx_state <= high_setup;
						i2 <= 0;
					ELSE
						tx_state <= done;
						i2 <= 0;
				END IF;
			
			END CASE;
		
		END IF;
	
	END PROCESS Transmissao;
	
	--Process para Inicialização especificada pelo fabricante
	ProcessoDeInicializao: PROCESS(clk, reset, init_init) 
	
		VARIABLE Counter : INTEGER RANGE 0 TO  750000 := 0;
	
	BEGIN
		
		IF(reset='1') THEN
			init_state <= idle;
			init_done <= '0';
		
		ELSIF(clk='1' and clk'event) THEN
			CASE init_state IS
				
				WHEN idle =>
					init_done <= '0';
					IF(init_init = '1') THEN
						init_state <= fIFteenms;
						Counter := 0;
						
					ELSE
						init_state <= idle;
						Counter := Counter + 1;
						
					END IF;
				
				WHEN fIFteenms =>
					init_done <= '0';
					IF(Counter = 750000) THEN
						init_state <= one;
						Counter := 0;
						
					ELSE
						init_state <= fIFteenms;
						Counter := Counter + 1;
						
					END IF;
				
				WHEN one =>
					SF_D1 <= "0011";
					LCD_E1 <= '1';
					init_done <= '0';
					IF(Counter = 11) THEN
						init_state<=two;
						Counter := 0;
						
					ELSE
						init_state<=one;
						Counter := Counter + 1;
						
					END IF;
				
				WHEN two =>
					LCD_E1 <= '0';
					init_done <= '0';
					IF(Counter = 205000) THEN
						init_state<=three;
						Counter := 0;
						
					ELSE
						init_state<=two;
						Counter := Counter + 1;
						
					END IF;
				
				WHEN three =>
					SF_D1 <= "0011";
					LCD_E1 <= '1';
					init_done <= '0';
					IF(Counter = 11) THEN
						init_state<=four;
						Counter := 0;
						
					ELSE
						init_state<=three;
						Counter := Counter + 1;
						
					END IF;
				
				WHEN four =>
					LCD_E1 <= '0';
					init_done <= '0';
					IF(Counter = 5000) THEN
						init_state<=five;
						Counter := 0;
						
					ELSE
						init_state<=four;
						Counter := Counter + 1;
						
					END IF;
				
				WHEN five =>
					SF_D1 <= "0011";
					LCD_E1 <= '1';
					init_done <= '0';
					IF(Counter = 11) THEN
						init_state<=six;
						Counter := 0;
						
					ELSE
						init_state<=five;
						Counter := Counter + 1;
						
					END IF;
				
				WHEN six =>
					LCD_E1 <= '0';
					init_done <= '0';
					IF(Counter = 2000) THEN
						init_state<=seven;
						Counter := 0;
						
					ELSE
						init_state<=six;
						Counter := Counter + 1;
						
					END IF;
				
				WHEN seven =>
					SF_D1 <= "0010";
					LCD_E1 <= '1';
					init_done <= '0';
					IF(Counter = 11) THEN
						init_state<=eight;
						Counter := 0;
						
					ELSE
						init_state<=seven;
						Counter := Counter + 1;
						
					END IF;
				
				WHEN eight =>
					LCD_E1 <= '0';
					init_done <= '0';
					IF(Counter = 2000) THEN
						init_state<=done;
						Counter := 0;
					ELSE
						init_state<=eight;
						Counter := Counter + 1;
					END IF;
				
				WHEN done =>
					init_state <= done;
					init_done <= '1';
			
			END CASE;
		
		END IF;
		
	END PROCESS ProcessoDeInicializao;
	
END Logica;