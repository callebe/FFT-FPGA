LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.meuPacote.all;

ENTITY BasicSystemClock IS
PORT(Entrada: STD_LOGIC_VECTOR (7 DOWNTO 0);
	  Clock50MHz: IN STD_LOGIC;
	  ACLK: OUT STD_LOGIC;
	  MCLK: OUT STD_LOGIC;
	  SMCLK: OUT STD_LOGIC);
END BasicSystemClock;

ARCHITECTURE Logica OF BasicSystemClock IS 
	
	SIGNAL HFClk: STD_LOGIC;
	SIGNAL LFClk: STD_LOGIC;
	
	SIGNAL AuxACLK: STD_LOGIC;
	SIGNAL AuxMCLK: STD_LOGIC;
	SIGNAL AuxSMCLK: STD_LOGIC;
	SIGNAL AuxSelsSMCLK: STD_LOGIC;
	
	SIGNAL NCountACLK: INTEGER RANGE 0 TO 8;
	SIGNAL NCountMCLK: INTEGER RANGE 0 TO 8;
	SIGNAL NCountSMCLK: INTEGER RANGE 0 TO 8;
	
	BEGIN

	U1: GeradorClock GENERIC MAP (4) PORT MAP (Clock50MHz,HFClk);
	U2: GeradorClock GENERIC MAP (1526) PORT MAP (Clock50MHz,LFClk);
	U3: GeradorClockA PORT MAP (HFClk,AuxACLK,NCountACLK);
	U4: GeradorClockA PORT MAP (HFClk,AuxMCLK,NCountMCLK);
	U5: GeradorClockA PORT MAP (AuxSelsSMCLK,AuxSMCLK,NCountSMCLK);
	
	PROCESS(HFClk)
		VARIABLE Count: INTEGER RANGE 0 TO 8;
		VARIABLE Selec: STD_LOGIC_VECTOR(1 DOWNTO);
		
		BEGIN
		
		Selec(0) := Entrada(6);
		Selec(1) := Entrada(5);
		
		IF(HFClk'EVENT AND HFClk='1') THEN
			CASE Selec IS
				WHEN "00" => ACLK <= HFClk;
				WHEN "01" => NCountACLK <=2; ACLK <= AuxACLK;
				WHEN "10" => NCountACLK <=4; ACLK <= AuxACLK;
				WHEN OTHERS => NCountACLK <=8; ACLK <= AuxACLK;
			END CASE;
		END IF;
		
	END PROCESS;
	
	PROCESS(HFClk)
		VARIABLE Count: INTEGER RANGE 0 TO 8;
		VARIABLE Selec: STD_LOGIC_VECTOR(1 DOWNTO);
		
		BEGIN
		
		Selec(0) := Entrada(4);
		Selec(1) := Entrada(3);
		
		IF(HFClk'EVENT AND HFClk='1') THEN
			CASE Selec IS
				WHEN "00" => MCLK <= HFClk;
				WHEN "01" => NCountMCLK <=2; MCLK <= AuxMCLK;
				WHEN "10" => NCountMCLK <=4; MCLK <= AuxMCLK;
				WHEN OTHERS => NCountMCLK <=8; MCLK <= AuxMCLK;
			END CASE;
		END IF;
	END PROCESS;
	
	PROCESS(AuxSelsSMCLK)
		VARIABLE Count: INTEGER RANGE 0 TO 8;
		VARIABLE Selec: STD_LOGIC_VECTOR(1 DOWNTO);
		BEGIN
		
		Selec(0) := Entrada(1);
		Selec(1) := Entrada(0);
		
		IF(AuxSelsSMCLK'EVENT AND AuxSelsSMCLK='1') THEN
			CASE Selec IS
				WHEN "00" => SMCLK <= AuxSelsSMCLK;
				WHEN "01" => NCountSMCLK <=2; SMCLK <= AuxSMCLK;
				WHEN "10" => NCountSMCLK <=4; SMCLK <= AuxSMCLK;
				WHEN OTHERS => NCountSMCLK <=8; SMCLK <= AuxSMCLK;
			END CASE;
		END IF;
	END PROCESS;
	
	AuxSelsSMCLK <= HFClk WHEN Entrada(2)='1' ELSE
					    LFClk;
	
	
	
END Logica;
