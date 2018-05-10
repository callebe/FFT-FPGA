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
    GENERIC(
        NFFT : INTEGER
    );
    PORT(
        Reset : IN STD_LOGIC;
        Clock : IN STD_LOGIC;
        Start : IN STD_LOGIC;
        InputDemuxFFT : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        OutputDemuxFFT : OUT ArrayVector ((NFFT-1) DOWNTO 0)
    );
END DemuxFFT;

ARCHITECTURE Behavioral OF DemuxFFT IS 
    
    SIGNAL Counter : INTEGER RANGE 0 TO (NFFT-1) := 0;
    
BEGIN  
    
    CounterDemux : PROCESS(Reset, Clock, Start)
    
    BEGIN
    
        IF(Reset = '1') THEN
           Counter <= 0;     
        
        ELSIF(Clock'EVENT AND Clock = '1') THEN
            IF(Start = '1') THEN
                IF(Counter < (NFFT-1)) THEN
                    Counter <= Counter + 1;
                    
                END IF;
                
            END IF;
        
        END IF;
    
    END PROCESS;
    
    S1: FOR k  IN 0 TO (NFFT-1) GENERATE
        OutputDemuxFFT(k) <= ('1' & InputDemuxFFT) WHEN (Counter = k) ELSE
                             (OTHERS => '0');
            
    END GENERATE;                                 

END Behavioral;