--------------------------------------------------------------------
--------------------------------------------------------------------
--                                                                --
--               Dispositivo de Controle do Display               --
--    Componente responsável por printar no LCD do Kit            --   
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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY DisplayMod IS
	PORT(Clock: IN STD_LOGIC;
		  reset: IN STD_LOGIC;
		  CurrentState: IN StateFFT;
		  SF_D : OUT STD_LOGIC_VECTOR(3 downto 0);
		  LCD_E: OUT STD_LOGIC;
		  LCD_RS: OUT STD_LOGIC;
		  LCD_RW: OUT STD_LOGIC);
END DisplayMod;

ARCHITECTURE Logica OF DisplayMod IS
	
	CONSTANT RstDisplay : STD_LOGIC := '0';
	CONSTANT DATA: INFO := ("10100000","01000110","01000110","01010100","10100000","01010010","01000001","01000100","01001001","01011000","00101101","00110010","10100000","00111000","01010000","10100000","10100000","10100000","10100000","10100000","10100000","10100000","10100000","10100000","10100000","10100000","10100000","10100000","10100000","10100000","10100000","10100000");
	                   --(  BLANK        F          F          T        BLANK        R           A         D          I          X         -          2         BLANK        8           P       BLANK     BLANK        BLANK     BLANK       BLANK     BLANK        BLANK     BLANK     BLANK     BLANK        BLANK     BLANK       BLANK     BLANK        BLANK     BLANK     BLANK 
							 --(     1         2          3          4          5          6           7         8          9          10        11         12           13       14          15         16         17         18         19         20         21         22         23        24           25       26         27          28         29       30          31          32  
	
	BEGIN
	
	---------------------------------------------------------------
	--               Dispositivo de Print na tela                --
	---------------------------------------------------------------	
	Display: DisplayLCD PORT MAP(Clock,reset, RstDisplay, DATA, SF_D,LCD_E,LCD_RS,LCD_RW);	


END Logica;
