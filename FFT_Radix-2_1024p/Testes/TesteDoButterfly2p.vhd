LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.ALL;

ENTITY TESTE IS
	PORT(Clock: IN STD_LOGIC;
		  reset: IN STD_LOGIC;
		  SF_D : OUT STD_LOGIC_VECTOR(3 downto 0);
		  LCD_E: OUT STD_LOGIC;
		  LCD_RS: OUT STD_LOGIC;
		  LCD_RW: OUT STD_LOGIC);
END TESTE;

ARCHITECTURE Logica OF TESTE IS
	
	SIGNAL Entrada: ComplexVector(7 DOWNTO 0) := ((1000,0),(2000,0),(3000,0),(4000,0),(5000,0),(3000,0),(2000,0),(1000,0));
	SIGNAL Saida: ComplexVector(7 DOWNTO 0);
	SIGNAL SaidaA: ComplexVector(7 DOWNTO 0);
	SIGNAL OutputSA : ComplexVector(3 DOWNTO 0);
	SIGNAL OutputSB : ComplexVector(3 DOWNTO 0);
	SIGNAL Output2A : ComplexVector(3 DOWNTO 0);
	SIGNAL Output2B : ComplexVector(3 DOWNTO 0);
	
	BEGIN
	
	---------------------------------------------------------------
	--                     Modulo do Display                     --
	---------------------------------------------------------------
	Display:DisplayMod PORT MAP(Clock,reset,Saida,SF_D,LCD_E,LCD_RS,LCD_RW);
	
	---------------------------------------------------------------
	--    1 Modulo Butterfly com 4 Modulos Butterfly Simples     --
	---------------------------------------------------------------
	SaidaA <= (Output2A & Output2B);
	B4: Butterfly4Mod GENERIC MAP (4,1) PORT MAP (Clock,reset,SaidaA,Saida);
	
	---------------------------------------------------------------
	--    2 Modulo Butterfly com 2 Modulos Butterfly Simples     --
	---------------------------------------------------------------
	B2A: Butterfly2Mod GENERIC MAP (2,2) PORT MAP (Clock,reset,OutputSA,Output2A);
	B2B: Butterfly2Mod GENERIC MAP (2,2) PORT MAP (Clock,reset,OutputSB,Output2B);
	
	---------------------------------------------------------------
	--                4 Modulos Butterfly Simples                --
	---------------------------------------------------------------
	BSA: Butterfly PORT MAP (Clock,reset,W(0),Entrada(0),Entrada(4),OutputSA(0),OutputSA(1));
	BSB: Butterfly PORT MAP (Clock,reset,W(0),Entrada(2),Entrada(6),OutputSA(2),OutputSA(3));			 
	BSC: Butterfly PORT MAP (Clock,reset,W(0),Entrada(1),Entrada(5),OutputSB(0),OutputSB(1));		 
	BSD: Butterfly PORT MAP (Clock,reset,W(0),Entrada(3),Entrada(7),OutputSB(2),OutputSB(3));
		
	
END Logica;

