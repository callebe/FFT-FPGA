----------------------------------------------------------------------------------
--                                    The Mux
--
--   Sequential component for select each InputButterflySelectOut of butterfly.
--   
--   InputButterflySelectOut -- 
--   OutputButterfly -- 
--   Control -- Select InputButterfly
--
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY SelectOut IS
    GENERIC(NFFT : INTEGER);
    PORT(
        ControlSelectOut : IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
        InputSelectOut : IN ComplexVector((NFFT-1) DOWNTO 0);
        OutputSelectOut : OUT ComplexVector((NFFT-1) DOWNTO 0)
        );
END SelectOut;

ARCHITECTURE Behavioral OF SelectOut IS

BEGIN

OutputSelectOut(0) <= InputSelectOut(0);
OutputSelectOut(1) <= InputSelectOut(8) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(8) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(4) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(2);
OutputSelectOut(2) <= InputSelectOut(1) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(2) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(2) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(1);
OutputSelectOut(3) <= InputSelectOut(9) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(10) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(6) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(3);
OutputSelectOut(4) <= InputSelectOut(2) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(4) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(1) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(4);
OutputSelectOut(5) <= InputSelectOut(10) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(12) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(5) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(6);
OutputSelectOut(6) <= InputSelectOut(3) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(6) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(3) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(5);
OutputSelectOut(7) <= InputSelectOut(11) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(14) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(7) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(7);
OutputSelectOut(8) <= InputSelectOut(4) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(1) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(8) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(8);
OutputSelectOut(9) <= InputSelectOut(12) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(9) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(12) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(10);
OutputSelectOut(10) <= InputSelectOut(5) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(3) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(10) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(9);
OutputSelectOut(11) <= InputSelectOut(13) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(11) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(14) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(11);
OutputSelectOut(12) <= InputSelectOut(6) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(5) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(9) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(12);
OutputSelectOut(13) <= InputSelectOut(14) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(13) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(13) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(14);
OutputSelectOut(14) <= InputSelectOut(7) WHEN ControlSelectOut = "0000" ELSE
			 InputSelectOut(7) WHEN ControlSelectOut = "0001" ELSE
			 InputSelectOut(11) WHEN ControlSelectOut = "0010" ELSE
			 InputSelectOut(13);
OutputSelectOut(15) <= InputSelectOut(15);


END Behavioral;