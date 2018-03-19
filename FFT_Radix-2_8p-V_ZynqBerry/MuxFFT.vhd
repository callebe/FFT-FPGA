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
        RefreshMuxFFT : IN STD_LOGIC;
        Reset : IN  STD_LOGIC; 
        InputMuxFFT : IN ComplexVector((NFFT/2-1) DOWNTO 0);
        OutputMuxFFT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END MuxFFT;

ARCHITECTURE Behavioral OF MuxFFT IS

BEGIN

    --Process for store Send Data of Input
    WriteOutput : PROCESS(RefreshMuxFFT, Reset)

        VARIABLE Flip : STD_LOGIC := '0';
        VARIABLE Index : INTEGER RANGE 0 TO (NFFT/2 -1) := 0;
        
    BEGIN
        
        IF(Reset = '1') THEN
            Flip := '0';
            Index := 0;
            
        ELSIF(RefreshMuxFFT'EVENT AND RefreshMuxFFT = '1') THEN
            Flip := Flip XOR '1';
            IF (Flip = '1') THEN
                OutputMuxFFT <= InputMuxFFT(Index).r;
            
            ELSE
                OutputMuxFFT <= InputMuxFFT(Index).i;
                Index := Index + 1;
                
            END IF;
        END IF;
            
    END PROCESS;

END Behavioral;