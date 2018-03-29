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
    GENERIC(NLevels : INTEGER;
            TimeLapseCordic: INTEGER
            );
    PORT(
    	Reset : IN STD_LOGIC;
    	Clock : IN STD_LOGIC;
        Start : IN STD_LOGIC;
        StartCordic : OUT STD_LOGIC;
        ControlSelectIn : OUT STD_LOGIC;
        ControlSelectOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SetInputData : OUT STD_LOGIC;
        FinishFFT : OUT STD_LOGIC
    );
END ControlFFT;

ARCHITECTURE Behavioral OF ControlFFT IS

    TYPE State IS (Idle, LoadingData, ProcessingNStage, FinishStage);
    SIGNAL CurrentState : State := Idle;
    SIGNAL NextState : State := Idle;
    SIGNAL CounterCycles : INTEGER RANGE 0 TO (NLevels);
    SIGNAL AuxControlSelectOut : INTEGER RANGE 0 TO (2*NLevels-1);
    SIGNAL CounterClock : INTEGER RANGE 0 TO 10 := 0;
    
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
                IF(CounterCycles = NLevels) THEN
                    NextState <= FinishStage ;
                
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
        
        ELSIF (Clock'EVENT AND Clock = '0') THEN
            CurrentState <= NextState;
            
        END IF;
    
    END PROCESS;


    ---------------------------------------------------------------
    --                       Timer Control                       --
    ---------------------------------------------------------------
	Timer : PROCESS (Clock, Reset, CurrentState, CounterClock)

        
        
    BEGIN
        
        IF(Reset = '1') THEN
            CounterClock <= 0;
            StartCordic <= '0';
            AuxControlSelectOut <= 0;
            CounterCycles <= 0;

        ELSIF(Clock'EVENT AND Clock = '1') THEN
            IF(CurrentState = ProcessingNStage) THEN
                CASE CounterClock IS
                    WHEN 10 =>
                        StartCordic <= '0';
                        AuxControlSelectOut <= AuxControlSelectOut;
                        CounterCycles <= CounterCycles + 1;
                        CounterClock <= 0;
                    
                    WHEN 3 =>
                        StartCordic <= '1';
                        AuxControlSelectOut <= AuxControlSelectOut;
                        CounterCycles <= CounterCycles;
                        CounterClock <= CounterClock + 1;
                        
                    WHEN 5 =>
                        StartCordic <= '0';
                        AuxControlSelectOut <= AuxControlSelectOut + 1;
                        CounterCycles <= CounterCycles;
                        CounterClock <= CounterClock + 1;
                         
                    WHEN OTHERS =>
                        StartCordic <= '0';
                        AuxControlSelectOut <= AuxControlSelectOut;
                        CounterCycles <= CounterCycles;
                        CounterClock <= CounterClock + 1;

                END CASE; 
                
            ELSE
                StartCordic <= '0';
                AuxControlSelectOut <= 0;
                CounterCycles <= 0;
                CounterClock <= 0;
            
            END IF;

        END IF;

    END PROCESS;    
    
END Behavioral;