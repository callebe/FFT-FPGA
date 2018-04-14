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
    GENERIC(
        NFFT : INTEGER;
        NLevels : INTEGER
    );
    PORT(
        Reset : IN STD_LOGIC;
        Clock : IN STD_LOGIC;
        FinishFFT : IN STD_LOGIC;
        Butterfly_MuxFirst : IN STD_LOGIC_VECTOR((25-NLevels*2) DOWNTO 0);
        Butterfly_MuxOthers : IN MuxVector((NFFT/2 - 2) DOWNTO 0);
        OutputMuxFFT : OUT STD_LOGIC_VECTOR(25 DOWNTO 0)
    );
END MuxFFT;

ARCHITECTURE Behavioral OF MuxFFT IS
    
    SIGNAL Counter : INTEGER RANGE 0 TO (NFFT/2-1) := 0;
    SIGNAL OutputMuxFFTAux : STD_LOGIC_VECTOR(25 DOWNTO 0);
    
BEGIN
    
    CounterMux : PROCESS(Reset, Clock, FinishFFT)
    
    BEGIN
    
        IF(Reset = '1') THEN
            Counter <= 0;     
        
        ELSIF(Clock'EVENT AND Clock = '1') THEN
            IF(FinishFFT = '1') THEN
                IF(Counter < (NFFT/2-1)) THEN
                    Counter <= Counter + 1;
                
                END IF;
                
            END IF;
        
        END IF;
    
    END PROCESS;
    
    OutputMuxFFT <= OutputMuxFFTAux;
    
    
    OutputMuxFFTAux(25 DOWNTO 23) <= (OTHERS => OutputMuxFFTAux(22));
    OutputMuxFFTAux(12 DOWNTO 10) <= (OTHERS => OutputMuxFFTAux(9));
    
    
    OutputMuxFFTAux(22 DOWNTO 13) <= Butterfly_MuxFirst(17) & Butterfly_MuxFirst(17 DOWNTO 9) WHEN Counter = 0 ELSE
                             Butterfly_MuxOthers(0)(19 DOWNTO 10) WHEN Counter = 4 ELSE
                             Butterfly_MuxOthers(1)(19 DOWNTO 10) WHEN Counter = 2 ELSE
                             Butterfly_MuxOthers(2)(19 DOWNTO 10) WHEN Counter = 6 ELSE
                             Butterfly_MuxOthers(3)(19 DOWNTO 10) WHEN Counter = 1 ELSE
                             Butterfly_MuxOthers(4)(19 DOWNTO 10) WHEN Counter = 5 ELSE
                             Butterfly_MuxOthers(5)(19 DOWNTO 10) WHEN Counter = 3 ELSE
                             Butterfly_MuxOthers(6)(19 DOWNTO 10);
                             
    OutputMuxFFTAux(9 DOWNTO 0) <= Butterfly_MuxFirst(8) & Butterfly_MuxFirst(8 DOWNTO 0) WHEN Counter = 0 ELSE
                             Butterfly_MuxOthers(0)(9 DOWNTO 0) WHEN Counter = 4 ELSE
                             Butterfly_MuxOthers(1)(9 DOWNTO 0) WHEN Counter = 2 ELSE
                             Butterfly_MuxOthers(2)(9 DOWNTO 0) WHEN Counter = 6 ELSE
                             Butterfly_MuxOthers(3)(9 DOWNTO 0) WHEN Counter = 1 ELSE
                             Butterfly_MuxOthers(4)(9 DOWNTO 0) WHEN Counter = 5 ELSE
                             Butterfly_MuxOthers(5)(9 DOWNTO 0) WHEN Counter = 3 ELSE
                             Butterfly_MuxOthers(6)(9 DOWNTO 0);

END Behavioral;