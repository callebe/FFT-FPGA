--------------------------------------------------------------------
--------------------------------------------------------------------
--                                                                --
--                     Gerador de BaudRate                        --
--   Gerador de clock para a trasmissão de dados.                 --   
--                                                                --
--       clk -> 50 MHz                                            --
--			clkOut -> Sinal de Clock ou BaudRate                     --
--                                                                --
--------------------------------------------------------------------
--------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
Library UNISIM;
USE UNISIM.vcomponents.all;
USE work.MainPackage.ALL;

ENTITY BaudRate IS
	GENERIC(clkIN, BaudRateOut: INTEGER);
	PORT(clk: IN STD_LOGIC;
		clkOut: OUT STD_LOGIC);
END BaudRate;


ARCHITECTURE Logic OF BaudRate IS

	CONSTANT MaxCounter : NATURAL := clkIN / BaudRateOut / 2;
	CONSTANT CounterBits : NATURAL := NumberOfBits(MaxCounter);
	SIGNAL Counter: unsigned(CounterBits - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL clkAux : STD_LOGIC := '0';
	SIGNAL clkAuxT : STD_LOGIC := '0';

BEGIN

	---------------------------------------------------------------
	--         Intanciamento Manual da Entrada e Saída           --
	---------------------------------------------------------------
	BUFG_inst : BUFG PORT MAP(O=> clkOut, I => clkAuxT);
  
   clkAuxT <= clkAux;
  
  PROCESS(clk)
  
  BEGIN
    
	 IF(clk'EVENT AND clk = '1') THEN
      IF(Counter = MaxCounter) THEN
        Counter <= TO_UNSIGNED(0, CounterBits);
        clkAux <= NOT clkAux;
      
		ELSE
        Counter <= Counter + 1;
      
		END IF;
    
	 END IF;
  
  END PROCESS;

END Logic;