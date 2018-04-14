----------------------------------------------------------------------------------
--                         The COrdic Processor
--
--   Sequencial component for rotate vector (X - Y) by twidle factor (W_N)^k
--   
--   YInput -- Odd Input
--   YOutput -- (X - Y) This output will multiplier by twiddle factor IN COrdic later
--
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.all;


ENTITY CordicV1 IS
    GENERIC(
            NumberOfCordicInteractions: INTEGER;
            NLevels : INTEGER;
            IndexFFT : INTEGER
    );
    PORT(
    	Clock : IN STD_LOGIC;
    	Reset : IN STD_LOGIC;
    	StartCordic : IN STD_LOGIC;
        XInputCordic : IN Complex;
        YInputCordic : IN Complex;
        CounterClock : IN INTEGER RANGE 0 TO (NumberOfCordicInteractions-1);
        ChangeROM : IN STD_LOGIC;
        XOutputCordic : OUT Complex;
        YOutputCordic : OUT Complex
    );
END CordicV1;

ARCHITECTURE Behavioral OF CordicV1 IS
     
    TYPE State IS (Idle, AdjustQuadrantProcess, TwidleProcess, FinishProcess);
    SIGNAL CurrentState : State := Idle;
    SIGNAL NextState : State := Idle;
    SIGNAL ResultReal : INTEGER RANGE 0 TO 8191 := 0;
    SIGNAL ResultImag : INTEGER RANGE 0 TO 8191 := 0;
    SIGNAL ResultRealNext : INTEGER RANGE 0 TO 8191 := 0;
    SIGNAL ResultImagNext : INTEGER RANGE 0 TO 8191 := 0;
    SIGNAL AuxXInput : Complex ;
    SIGNAL YAdjustInputR : INTEGER RANGE 0 TO 8191 := 0;
    SIGNAL YAdjustInputI : INTEGER RANGE 0 TO 8191 := 0;
    SIGNAL CounterLevel : INTEGER RANGE 0 TO  (2**(NLevels-1)-1):= 0;
    SIGNAL TwiddleVector : STD_LOGIC_VECTOR((NumberOfCordicInteractions) DOWNTO 0);
    SIGNAL CloseCycle : STD_LOGIC := '0'; 
    
BEGIN

    ---------------------------------------------------------------
    --                          Memory Unit                      --
    ---------------------------------------------------------------
    TwiddleMemory : ROM PORT MAP(Clock => Clock, Address => CounterLevel, Data => TwiddleVector); 
    
    ---------------------------------------------------------------
    --                  Center Control Process                   --
    ---------------------------------------------------------------
    -- State Machine
    StateMachine : PROCESS(CurrentState, Reset, StartCordic, CounterClock)
       
    BEGIN
    
        CASE CurrentState IS
        
            WHEN Idle =>
                IF(StartCordic = '1') THEN
                    NextState <= AdjustQuadrantProcess;
            
                ELSE
                    NextState <= Idle;
                
                END IF;    
            
            WHEN AdjustQuadrantProcess =>
                    NextState <= TwidleProcess;
                                
            WHEN TwidleProcess =>
                IF(CounterClock = (NumberOfCordicInteractions-1)) THEN
                    NextState <= FinishProcess ;
                
                ELSE
                    NextState <= TwidleProcess;
                
                END IF;
            
            WHEN FinishProcess =>
                   NextState <= Idle ; 
                
            WHEN OTHERS =>
                NextState <= Idle ;
        
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
    --                      Counter Level                        --
    ---------------------------------------------------------------
    -- Process
    CounterLevelProcess : PROCESS(ChangeROM, Reset)
       
    BEGIN
       
               
        IF(Reset = '1') THEN
            CounterLevel <= IndexFFT;
        
        ELSIF(ChangeROM'EVENT AND ChangeROM = '1') THEN
            CounterLevel <= TO_INTEGER(SHIFT_LEFT(TO_UNSIGNED(CounterLevel, NLevels-1), 1));
        
        END IF;
    
    END PROCESS;
    
    ---------------------------------------------------------------
    --                  FinishQuadrantAdjustment                 --
    ---------------------------------------------------------------
    QuadrantAdjustment : PROCESS(Clock, Reset, CurrentState)
        
    BEGIN
          
        IF(Reset = '1') THEN
            
        ELSIF(Clock'EVENT AND Clock = '0') THEN
            IF(CurrentState = AdjustQuadrantProcess) THEN
                IF(TwiddleVector(0) = '1') THEN
                    YAdjustInputR <=   TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.i), 1)) + TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.i), 3)) - TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.i), 6)) - TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.i), 9));
                    YAdjustInputI <= -(TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.r), 1)) + TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.r), 3)) - TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.r), 6)) - TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.r), 9)));
                    
                ELSE
                    YAdjustInputR <= TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.r), 1)) + TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.r), 3)) - TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.r), 6)) - TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.r), 9));
                    YAdjustInputI <= TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.i), 1)) + TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.i), 3)) - TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.i), 6)) - TO_INTEGER(SHIFT_RIGHT(SIGNED(YInputCordic.i), 9));
                
                END IF;
                AuxXInput <= XInputCordic;
                         
            END IF;     
                
        END IF;
    
    END PROCESS;
        
    ---------------------------------------------------------------
    --                        Process Cordic                     --
    --------------------------------------------------------------- 
    ResultReal <= ResultRealNext WHEN (CloseCycle = '1') ELSE
                  YAdjustInputR;
                  
    ResultImag <= ResultImagNext WHEN (CloseCycle = '1') ELSE
                  YAdjustInputI;              
                                                 
    -- Process Rising Edge Clock
    ProcessCordicRising : PROCESS(Clock, Reset, CurrentState, YInputCordic)
        
    BEGIN
        
        IF(Reset = '1') THEN
            CloseCycle <= '0';
            
        ELSIF(Clock'EVENT AND Clock = '0') THEN
            IF(CurrentState = TwidleProcess) THEN
                IF(TwiddleVector(CounterClock+1) = '1') THEN
                    ResultRealNext <= ResultReal - TO_INTEGER(SHIFT_RIGHT(TO_SIGNED(ResultImag,13), CounterClock));
                    ResultImagNext <= ResultImag + TO_INTEGER(SHIFT_RIGHT(TO_SIGNED(ResultReal,13), CounterClock));
                    
                ELSE
                    ResultRealNext <= ResultReal + TO_INTEGER(SHIFT_RIGHT(TO_SIGNED(ResultImag,13), CounterClock));
                    ResultImagNext <= ResultImag - TO_INTEGER(SHIFT_RIGHT(TO_SIGNED(ResultReal,13), CounterClock));
                    
                END IF;
                CloseCycle <= '1';
            
            ELSE
                CloseCycle <= '0';
            
            END IF;
                
        END IF;
    
    END PROCESS;
        
    ---------------------------------------------------------------
    --                        Print Output                       --
    ---------------------------------------------------------------    
	PrintOutput : PROCESS(Clock, Reset, XInputCordic.r(12), YInputCordic.r(12))    
    
        VARIABLE XReal : STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS => '0');
        VARIABLE YReal : STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS => '0');
        VARIABLE XImag : STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS => '0');
        VARIABLE YImag : STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS => '0');
        
    BEGIN
        
        XOutputCordic.r <= XReal;
        XOutputCordic.i <= XImag; 
        YOutputCordic.r <= YReal;
        YOutputCordic.i <= YImag;
        
        IF(Reset = '1') THEN
            IF(XInputCordic.r(12) = '1') THEN
                XReal(11 DOWNTO 0) := XInputCordic.r(11 DOWNTO 0);
                XReal(12) := XInputCordic.r(12);
                XImag := (OTHERS => '0'); 
                
            ELSIF(YInputCordic.r(12) = '1') THEN
                YReal(11 DOWNTO 0) := YInputCordic.r(11 DOWNTO 0);
                XReal(12) := XInputCordic.r(12);
                YImag := (OTHERS => '0'); 
                
            END IF;
           
        ELSIF(Clock'EVENT AND Clock = '0') THEN
            IF(CurrentState = FinishProcess) THEN
                XReal := AuxXInput.r;
                XImag := AuxXInput.i; 
                YReal := STD_LOGIC_VECTOR(TO_SIGNED(ResultRealNext, 13));
                YImag := STD_LOGIC_VECTOR(TO_SIGNED(ResultImagNext, 13));
                
            END IF;

        END IF;
            
    END PROCESS;

END Behavioral;