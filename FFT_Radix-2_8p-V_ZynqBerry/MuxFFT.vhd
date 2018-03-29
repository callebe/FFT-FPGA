----------------------------------------------------------------------------------
--                        Mux Basic Component
--   Sequential components for UART comunication
--   
--   Input -- Input 31Bits
--   Output -- Even Output Vector of NFFT*31 Bits
--
----------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY MuxFFT IS
    GENERIC(NFFT : INTEGER);
    PORT(
        SelectMux : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        InputMuxFFT : IN ComplexVector((NFFT/2-1) DOWNTO 0);
        OutputMuxFFT : OUT STD_LOGIC_VECTOR(25 DOWNTO 0)
    );
END MuxFFT;

ARCHITECTURE Behavioral OF MuxFFT IS
    
BEGIN
    
    OutputMuxFFT(25 DOWNTO 13) <= InputMuxFFT(0).r WHEN SelectMux = "00000000" ELSE
                     InputMuxFFT(1).r WHEN SelectMux = "00000001" ELSE
                     InputMuxFFT(2).r WHEN SelectMux = "00000010" ELSE
                     InputMuxFFT(3).r WHEN SelectMux = "00000011" ELSE
                     InputMuxFFT(4).r WHEN SelectMux = "00000100" ELSE
                     InputMuxFFT(5).r WHEN SelectMux = "00000101" ELSE
                     InputMuxFFT(6).r WHEN SelectMux = "00000110" ELSE
                     InputMuxFFT(7).r;
    
    
    OutputMuxFFT(12 DOWNTO 0) <= InputMuxFFT(0).i WHEN SelectMux = "00000000" ELSE
                     InputMuxFFT(1).i WHEN SelectMux = "00000001" ELSE
                     InputMuxFFT(2).i WHEN SelectMux = "00000010" ELSE
                     InputMuxFFT(3).i WHEN SelectMux = "00000011" ELSE
                     InputMuxFFT(4).i WHEN SelectMux = "00000100" ELSE
                     InputMuxFFT(5).i WHEN SelectMux = "00000101" ELSE
                     InputMuxFFT(6).i WHEN SelectMux = "00000110" ELSE
                     InputMuxFFT(7).i;

    

END Behavioral;