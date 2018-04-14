----------------------------------------------------------------------------------
--                                The Control Module
--
--   Control component of FFT Module
--   
--
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY ControlFFT IS
    PORT(
    	Reset : IN STD_LOGIC;
    	Clock : IN STD_LOGIC;
        Start : IN STD_LOGIC;
        StartCordic : OUT STD_LOGIC;
        ControlSelectIn : OUT STD_LOGIC;
        ControlSelectOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        CounterClock : OUT INTEGER RANGE 0 TO (NumberOfCordicInteractions-1);
        ChangeROM : OUT STD_LOGIC;
        SetInputData : OUT STD_LOGIC;
        FinishFFT : OUT STD_LOGIC
    );
END ControlFFT;

ARCHITECTURE Behavioral OF ControlFFT IS

    TYPE State IS (Idle, LoadingData, ProcessingNStage, FinishStage);
    SIGNAL CurrentState : State := Idle;
    SIGNAL NextState : State := Idle;
    SIGNAL CounterCycles : INTEGER RANGE 0 TO (NLevels);
    SIGNAL CounterClockAux : INTEGER RANGE 0 TO (NumberOfCordicInteractions-1) := 0;
    SIGNAL AuxControlSelectOut : INTEGER RANGE 0 TO (2*NLevels-1);
    SIGNAL CounterCentral : INTEGER RANGE 0 TO (NumberOfCordicInteractions+2) := 0;
    
BEGIN

    
    ControlSelectOut <=  STD_LOGIC_VECTOR(TO_UNSIGNED(AuxControlSelectOut, NLevels));
    
    ---------------------------------------------------------------
    --                  Center Control Process                   --
    ---------------------------------------------------------------
    -- State Machine
    StateMachine : PROCESS(CurrentState, Start, CounterCycles, Reset)
    
        
    
    BEGIN
    
        CASE CurrentState IS
        
            WHEN Idle =>
                ControlSelectIn <= '0';
                FinishFFT <= '0';
                SetInputData <= '0';
                IF(Start = '1') THEN
                    NextState <= LoadingData;
            
                ELSE
                    NextState <= Idle;
                
                END IF;
            
            WHEN LoadingData =>
                ControlSelectIn <= '1';
                FinishFFT <= '0';
                SetInputData <= '1';
                IF(Start = '0') THEN
                    NextState <= ProcessingNStage;
                
                ELSE
                    NextState <= LoadingData;
                
                END IF; 
                    
            
            WHEN ProcessingNStage =>
                ControlSelectIn <= '0';
                FinishFFT <= '0';
                SetInputData <= '0';
                IF(CounterCycles = (NLevels-1)) THEN
                    NextState <= FinishStage;
                
                ELSE
                    NextState <= ProcessingNStage;
                
                END IF;
                
                                
            WHEN FinishStage =>
                ControlSelectIn <= '0';
                FinishFFT <= '1';
                SetInputData <= '0';
                IF(Reset = '1') THEN
                    NextState <= Idle ;
                
                ELSE
                    NextState <= FinishStage;
                
                END IF;
            
            WHEN OTHERS =>
                ControlSelectIn <= '0';
                FinishFFT <= '0';
                SetInputData <= '0';
        
        END CASE;
    
    END PROCESS;
    
    -- Refresh States
    UpdateStates : PROCESS(Clock, Reset)

    BEGIN
    
        IF(Reset = '1') THEN
            CurrentState <= Idle;
        
        ELSIF (Clock'EVENT AND Clock = '1') THEN
            CurrentState <= NextState;
            
        END IF;
    
    END PROCESS;

   
    ---------------------------------------------------------------
    --                       Timer Control                       --
    ---------------------------------------------------------------
	CounterClock <= CounterClockAux;
	-- Process 
	Timer : PROCESS (Clock, Reset, CurrentState)
    
    BEGIN
        
        IF(Reset = '1') THEN
            CounterCentral <= 0;
            CounterClockAux <= 0;
            StartCordic <= '0';
            AuxControlSelectOut <= 0;
            CounterCycles <= 0;
            ChangeROM <= '0';

        ELSIF(Clock'EVENT AND Clock = '1') THEN
            IF(CurrentState = ProcessingNStage) THEN
                CASE CounterCentral IS
                    WHEN 0 =>
                        CounterCentral <= CounterCentral + 1;
                        StartCordic <= '1';
                        CounterClockAux <= 0;
                        AuxControlSelectOut <= AuxControlSelectOut;
                        CounterCycles <= CounterCycles;
                        ChangeROM <= '0';
                    
                    WHEN 1 =>
                        CounterCentral <= CounterCentral + 1;
                        StartCordic <= '0';
                        CounterClockAux <= 0;
                        AuxControlSelectOut <= AuxControlSelectOut;
                        CounterCycles <= CounterCycles;
                        ChangeROM <= '0';
                    
                    WHEN 2 =>
                        CounterCentral <= CounterCentral + 1;
                        StartCordic <= '0';
                        CounterClockAux <= 0;
                        AuxControlSelectOut <= AuxControlSelectOut;
                        CounterCycles <= CounterCycles;
                        ChangeROM <= '0';
                                                                            
                    WHEN (NumberOfCordicInteractions+2) =>
                        CounterCentral <= 0;
                        StartCordic <= '0';
                        CounterClockAux <= 0;
                        AuxControlSelectOut <= AuxControlSelectOut+1;
                        CounterCycles <= CounterCycles+1;
                        ChangeROM <= '1';    
                         
                    WHEN OTHERS =>
                        CounterCentral <= CounterCentral + 1;
                        StartCordic <= '0';
                        CounterClockAux <= CounterClockAux + 1;
                        AuxControlSelectOut <= AuxControlSelectOut;
                        CounterCycles <= CounterCycles;
                        ChangeROM <= '0';

                END CASE; 
                
            END IF;

        END IF;

    END PROCESS;    
    
END Behavioral;