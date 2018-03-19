----------------------------------------------------------------------------------
--                         Delay Logic Basic Component
--   Concurrent components for concurrent component for delaying output of butterfly
--   
--   RefreshDelayLogic 
--   InputDelayLogic -- Input of X 
--   OutputDelayLogic -- Outnput of X 
--
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY DelayLogic IS
    PORT(
        RefreshDelayLogic : IN STD_LOGIC;
        InputDelayLogic : IN Complex;
        OutputDelayLogic : OUT Complex
    );
END DelayLogic;

ARCHITECTURE Behavioral OF DelayLogic IS

BEGIN

    PROCESS(RefreshDelayLogic)
        
        VARIABLE Aux: Complex;

    BEGIN
        
        OutputDelayLogic <= Aux;
        IF(RefreshDelayLogic'EVENT AND RefreshDelayLogic = '1') THEN
            Aux := InputDelayLogic;

        END IF;
            
    END PROCESS;
    
END Behavioral;