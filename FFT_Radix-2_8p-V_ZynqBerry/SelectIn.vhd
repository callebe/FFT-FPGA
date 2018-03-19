----------------------------------------------------------------------------------
--                                    The Mux
--
--   Concorrent component for select Output betwen feed butterfly.
--   
--   Input -- 
-- 	 FeedBack --
--   Output -- 
--   Control -- Select Input
--
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY SelectIn IS
	GENERIC(NFFT : INTEGER);
    PORT(
        ControlSelectIn : IN STD_LOGIC; 
        InputSelectIn : IN ComplexVector((NFFT-1) DOWNTO 0);
        Feedback : IN ComplexVector((NFFT-1) DOWNTO 0);
        OutputSelectIn : OUT ComplexVector((NFFT-1) DOWNTO 0)
        );
END SelectIn;

ARCHITECTURE Behavioral OF SelectIn IS

BEGIN

	
	S1: FOR k  IN 0 TO (NFFT-1) GENERATE
		OutputSelectIn(k) <=  InputSelectIn(k) WHEN ControlSelectIn = '0' ELSE
					  Feedback(k);

	END GENERATE;

END Behavioral;