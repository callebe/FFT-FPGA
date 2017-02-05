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
USE work.MainPackage.ALL;

ENTITY BaudRate IS
	GENERIC(clkIN, BaudRateOut: INTEGER);
	PORT(clk: IN STD_LOGIC;
		clkOut: BUFFER STD_LOGIC);
END BaudRate;


ARCHITECTURE Logic OF BaudRate IS

	CONSTANT MaxCounter : NATURAL := clkIN / BaudRateOut / 2;
	CONSTANT CounterBits : NATURAL := NumberOfBits(MaxCounter);
	SIGNAL Counter: unsigned(CounterBits - 1 DOWNTO 0) := (OTHERS => '0');

BEGIN
  
  PROCESS(clk)
  
  BEGIN
    
	 IF(clk'EVENT AND clk = '1') THEN
      IF(Counter = MaxCounter) THEN
        Counter <= TO_UNSIGNED(0, CounterBits);
        clkOut <= NOT clkOut;
      
		ELSE
        Counter <= Counter + 1;
      
		END IF;
    
	 END IF;
  
  END PROCESS;

END Logic;