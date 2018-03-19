----------------------------------------------------------------------------------
--                        Demux Basic Component
--   Sequential components for UART comunication
--   
--   RefreshDemuxFFT -- 
--   Reset --
--   InputDemuxFFT -- Input 31Bits
--   OutputDemuxFFT -- Even Output Vector of NFFT*31 Bits
--
----------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY DemuxFFT IS
    GENERIC(NFFT : INTEGER);
    PORT(
        RefreshDemuxFFT : IN STD_LOGIC;
        Reset : IN  STD_LOGIC; 
        InputDemuxFFT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        OutputDemuxFFT : OUT ComplexVector((NFFT-1) DOWNTO 0)
    );
END DemuxFFT;

ARCHITECTURE Behavioral OF DemuxFFT IS

BEGIN
    

    --Process for store Data of Input
    WriteIn : PROCESS(RefreshDemuxFFT, Reset)
        
        VARIABLE Inverter : INTEGER RANGE 0 TO 1 := 0;
        VARIABLE Counter : INTEGER RANGE 0 TO (NFFT -1) := 0;
        
    BEGIN
        
        IF(Reset = '1') THEN
            Inverter := 0;
            Counter := 0;

        ELSIF(RefreshDemuxFFT'EVENT AND RefreshDemuxFFT = '1') THEN
            Inverter := Inverter + 1; 
            IF (Inverter = 1) THEN
                OutputDemuxFFT(Counter).r <= InputDemuxFFT;
            
            ELSE
                OutputDemuxFFT(Counter).i <= InputDemuxFFT;
                Counter := Counter + 1;
                
            END IF;
        END IF;
            
    END PROCESS;

END Behavioral;