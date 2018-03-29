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
        SelectDemux : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        InputDemuxFFT : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        OutputDemuxFFT : OUT ArrayVector ((NFFT-1) DOWNTO 0)
    );
END DemuxFFT;

ARCHITECTURE Behavioral OF DemuxFFT IS
    
    SIGNAL SelectDemuxAux : INTEGER RANGE 0 TO 255;
    
BEGIN
   
    SelectDemuxAux <=  to_integer(signed(SelectDemux));
    
    S1: FOR k  IN 0 TO (NFFT-1) GENERATE
		OutputDemuxFFT(k) <=  '1' & InputDemuxFFT(11 DOWNTO 0) WHEN SelectDemuxAux = k  ELSE
					          (OTHERS => '0');
					          
	END GENERATE;
    

END Behavioral;