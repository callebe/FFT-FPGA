----------------------------------------------------------------------------------
--                                    The Mux
--
--   Sequential component for select each input of butterfly.
--   
--   Input -- 
--   Output -- 
--   Control -- Select Input
--
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY mux IS
    PORT(
        Control : IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
        Input : IN ComplexVector(15 DOWNTO 0);
        Output : OUT ComplexVector(15 DOWNTO 0)
        );
END mux;

ARCHITECTURE Behavioral OF mux IS

BEGIN

    Output(0) <= Input(0);
    Output(1) <= Input(8) WHEN Control = "0000" ELSE
                 Input(8) WHEN Control = "0001" ELSE
                 Input(4) WHEN Control = "0010" ELSE
                 Input(2);
    Output(2) <= Input(1) WHEN Control = "0000" ELSE
                 Input(2) WHEN Control = "0001" ELSE
                 Input(2) WHEN Control = "0010" ELSE
                 Input(1);
    Output(3) <= Input(9) WHEN Control = "0000" ELSE
                 Input(10) WHEN Control = "0001" ELSE
                 Input(6) WHEN Control = "0010" ELSE
                 Input(3);
    Output(4) <= Input(2) WHEN Control = "0000" ELSE
                 Input(4) WHEN Control = "0001" ELSE
                 Input(1) WHEN Control = "0010" ELSE
                 Input(4);
    Output(5) <= Input(10) WHEN Control = "0000" ELSE
                 Input(12) WHEN Control = "0001" ELSE
                 Input(5) WHEN Control = "0010" ELSE
                 Input(6);
    Output(6) <= Input(3) WHEN Control = "0000" ELSE
                 Input(6) WHEN Control = "0001" ELSE
                 Input(3) WHEN Control = "0010" ELSE
                 Input(5);
    Output(7) <= Input(11) WHEN Control = "0000" ELSE
                 Input(14) WHEN Control = "0001" ELSE
                 Input(7) WHEN Control = "0010" ELSE
                 Input(7);
    Output(8) <= Input(4) WHEN Control = "0000" ELSE
                 Input(1) WHEN Control = "0001" ELSE
                 Input(8) WHEN Control = "0010" ELSE
                 Input(8);
    Output(9) <= Input(12) WHEN Control = "0000" ELSE
                 Input(9) WHEN Control = "0001" ELSE
                 Input(12) WHEN Control = "0010" ELSE
                 Input(10);
    Output(10) <= Input(5) WHEN Control = "0000" ELSE
                 Input(3) WHEN Control = "0001" ELSE
                 Input(10) WHEN Control = "0010" ELSE
                 Input(9);
    Output(11) <= Input(13) WHEN Control = "0000" ELSE
                 Input(11) WHEN Control = "0001" ELSE
                 Input(14) WHEN Control = "0010" ELSE
                 Input(11);
    Output(12) <= Input(6) WHEN Control = "0000" ELSE
                 Input(5) WHEN Control = "0001" ELSE
                 Input(9) WHEN Control = "0010" ELSE
                 Input(12);
    Output(13) <= Input(14) WHEN Control = "0000" ELSE
                 Input(13) WHEN Control = "0001" ELSE
                 Input(13) WHEN Control = "0010" ELSE
                 Input(14);
    Output(14) <= Input(7) WHEN Control = "0000" ELSE
                 Input(7) WHEN Control = "0001" ELSE
                 Input(11) WHEN Control = "0010" ELSE
                 Input(13);
    Output(15) <= Input(15);

END Behavioral;