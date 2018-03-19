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
        ControlSelectIn : OUT STD_LOGIC;
        StartCordic : OUT STD_LOGIC;
        ControlSelectOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        FinishFFT : OUT STD_LOGIC
    );
END ControlFFT;

ARCHITECTURE Behavioral OF ControlFFT IS

    TYPE State IS (Idle, ProcessingFirstStage, ProcessingNStage, FinishStage);
    SIGNAL CurrentState : State := Idle;
    SIGNAL NextState : State := Idle;
    SIGNAL CounterCycles : INTEGER RANGE 0 TO (NLevels);
    SIGNAL StartProcess : STD_LOGIC;

BEGIN

    
    

    ---------------------------------------------------------------
    --                  Center Control Process                   --
    ---------------------------------------------------------------
    -- State Machine
    StateMachine : PROCESS(CurrentState, Start, CounterCycles, Reset)
    
    BEGIN
    
        CASE CurrentState IS
            
            WHEN Idle =>
                ControlSelectIn <= '0';
                StartProcess <= '0';
                FinishFFT <= '0';
                IF(Start = '1') THEN
                    NextState <= ProcessingFirstStage;

                ELSE
                    NextState <= Idle;

                END IF;
                
            WHEN ProcessingFirstStage =>
                ControlSelectIn <= '0';
                StartProcess <= '1';
                FinishFFT <= '0';
                IF(CounterCycles = 1) THEN
                    NextState <= ProcessingNStage;

                ELSE
                    NextState <= ProcessingFirstStage;

                END IF; 
                
            WHEN ProcessingNStage =>
                ControlSelectIn <= '0';
                StartProcess <= '1';
                FinishFFT <= '0';
                IF(CounterCycles = NLevels) THEN
                    NextState <= FinishStage ;

                ELSE
                    NextState <= ProcessingNStage;

                END IF;
            

            WHEN FinishStage =>
                ControlSelectIn <= '0';
                StartProcess <= '0';
                FinishFFT <= '1';
                IF(Reset = '1') THEN
                    NextState <= Idle ;

                ELSE
                    NextState <= FinishStage;

                END IF;
                
            WHEN OTHERS =>
                ControlSelectIn <= '0';
                StartProcess <= '0';
                FinishFFT <= '0';
                
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
	Timer : PROCESS (Clock, Reset, StartProcess)

        VARIABLE CounterClock : INTEGER RANGE 0 TO (TimeLapseCordic + 4);
        VARIABLE AuxControlSelectOut : STD_LOGIC_VECTOR(3 DOWNTO 0);

    BEGIN
        
        ControlSelectOut <= AuxControlSelectOut;
        
        IF(Reset = '1') THEN
            CounterClock := 0;
            StartCordic <= '0';
            AuxControlSelectOut := "0000";
            CounterCycles <= 0;

        ELSIF(Clock'EVENT AND Clock = '1') THEN
            IF(StartProcess = '1') THEN
                CounterClock := CounterClock + 1;
                IF(CounterClock = 3) THEN
                    StartCordic <= '1';

                ELSE
                    StartCordic <= '0';
                    IF(CounterClock = 5) THEN
                        AuxControlSelectOut := AuxControlSelectOut + 1;


                    ELSIF(CounterClock = 0) THEN
                        CounterCycles <= CounterCycles + 1;

                    END IF;

                END IF;

            END IF;

        END IF;

    END PROCESS;    
    
END Behavioral;