----------------------------------------------------------------------------------
-- Barrey Shifter
-- 
-- Create Date: 06.10.2018 16:35:06
-- Design Name: Callebe Barbosa 
-- Module Name: UCFFT16
-- Project Name: FFT16p
-- Target Devices: ZynqBerry-7010 (XC7Z010-1CLG225C)
-- Tool Versions: Vivado 2017.4
-- Description: Control Unit for FFT with 16 point
-- 
-- Dependencies: BarrelShifter1In4Out
-- 
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UCFFT16 is
  Port (
    Clock : in STD_LOGIC;
    StartFFT : in STD_LOGIC;
    FinishFFT : out STD_LOGIC;
    StartCORDIC : out STD_LOGIC;
    resetRomCordic : out STD_LOGIC;
    ClockCordic : out STD_LOGIC;
    ChangeROMAdress : out STD_LOGIC;
    ControlSelectIn : out STD_LOGIC;
    ControlSelectOut : out STD_LOGIC_VECTOR(1 downto 0)
  );
end UCFFT16;

architecture Behavioral of UCFFT16 is
    
    type State is (Idle, Level0, Level1, Level2, Level3, FishStage);
    signal CurrentState : State := Idle;
    signal NextState : State := Idle;
    signal CounterCycles : integer range 0 TO 3 := 0;
    signal ActiveChangeAdress : STD_LOGIC := '0';
    signal ActiveClockCordic : STD_LOGIC := '0';
    signal AuxControlSelectOut : STD_LOGIC_VECTOR(1 downto 0);

begin
    
    ---------------------------------------------------------------
    --                  Center Control Process                   --
    ---------------------------------------------------------------
    -- State Machine
    StateMachine : process(CurrentState, StartFFT, CounterCycles)
    
    BEGIN
    
        CASE CurrentState IS
        
            WHEN Idle =>
                FinishFFT <= '0';
                resetRomCordic <= '1';
                ActiveChangeAdress <= '0';
                ActiveClockCordic <= '0';
                IF(StartFFT = '1') THEN
                    NextState <= Level0;
            
                ELSE
                    NextState <= Idle;
                    
                
                END IF;
            
            WHEN Level0 =>
                resetRomCordic <= '0';
                FinishFFT <= '0';
                ActiveClockCordic <= '1';
                ActiveChangeAdress <= '1';
                IF(CounterCycles = 2) THEN
                    NextState <= Level1;
                
                ELSE
                    NextState <= Level0;
                    
                END IF; 
                    
            
            WHEN Level1 =>
                resetRomCordic <= '0';
                FinishFFT <= '0';
                ActiveChangeAdress <= '1';
                ActiveClockCordic <= '1';
                IF(CounterCycles = 2) THEN
                    NextState <= Level2;
                    
                ELSE
                    NextState <= Level1;
                    
                END IF;
                
            WHEN Level2 =>
                resetRomCordic <= '0';
                FinishFFT <= '0';
                ActiveChangeAdress <= '1';
                ActiveClockCordic <= '1';
                IF(CounterCycles = 2) THEN
                    NextState <= FishStage;          
                
                ELSE
                    NextState <= Level2;
                    
                END IF;
                                                    
            WHEN FishStage =>
                resetRomCordic <= '0';
                ActiveChangeAdress <= '0';
                FinishFFT <= '1';
                ActiveClockCordic <= '0';
                if(StartFFT = '0') then
                    NextState <= Idle;
                    
                else
                    NextState <= FishStage;
                    
                end if;                
        
            WHEN OTHERS =>
                resetRomCordic <= '1';
                ActiveChangeAdress <= '0';
                FinishFFT <= '0';
                ActiveClockCordic <= '0';
                NextState <= Idle ;
        
        END CASE;
    
    END PROCESS;
    
    -- Refresh States
    UpdateStates : PROCESS(Clock)

    BEGIN
    
        IF (Clock'EVENT AND Clock = '0') THEN
            CurrentState <= NextState;
            
        END IF;
    
    END PROCESS;
    
    --CounterProcess
    process(Clock, CurrentState)
    
    begin
    
        if(CurrentState = Idle or  CurrentState = FishStage) then
            CounterCycles <= 0;
            
        elsif(Clock'event and Clock = '0') then
            if(CounterCycles = 2) then
                CounterCycles <= 0;
            
            else
                CounterCycles <= CounterCycles + 1;
                
            end if;
            
        end if;
    
    end process;
    
    --Control Adress Rom
    ChangeROMAdress <= Clock when ActiveChangeAdress = '1' else
                       '0';

    --Control Cordic
    ClockCordic <= Clock when ActiveClockCordic = '1' else
                    '0';
    
    --Start Cordic
    StartCORDIC <= '1' when (CounterCycles = 0) else
                   '0';
    
    --Control Select In
    ControlSelectIn <= '1' when (CounterCycles = 0 and AuxControlSelectOut = "00") else
                       '1';
                       
    --ControlSelectOut
    ControlSelectOut <= AuxControlSelectOut;
    process(Clock)
    
        variable CounterControlSelectOut : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    
    begin
    
        AuxControlSelectOut <= CounterControlSelectOut; 
        if(Clock'event and Clock = '1')then
            if(CounterCycles = 1) then
                CounterControlSelectOut := std_logic_vector(to_unsigned(to_integer(unsigned(CounterControlSelectOut)) + 1,2));
                
            end if;
            
        end if;
    
    end process;
    
end Behavioral;
