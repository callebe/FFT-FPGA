LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

------------------------------------------------
PACKAGE MainPackage IS

    -- Defines
    CONSTANT NLevels : INTEGER := 4;
    CONSTANT NFFT : INTEGER := (2**NLevels);
    CONSTANT NumberOfCordicInteractions : INTEGER := 10;
    ------------------------------------------------
	
	------------------------------------------------
    TYPE MuxVector IS ARRAY (NATURAL range <>) OF STD_LOGIC_VECTOR((25-(NLevels-1)*2) DOWNTO 0);
	------------------------------------------------
	
	------------------------------------------------
	TYPE Complex IS 
		RECORD
			r: STD_LOGIC_VECTOR(12 DOWNTO 0);
			i: STD_LOGIC_VECTOR(12 DOWNTO 0);
		END RECORD;
    ------------------------------------------------
    
    ------------------------------------------------
    TYPE ArrayVector IS ARRAY (NATURAL range <>) OF STD_LOGIC_VECTOR(12 DOWNTO 0);
	------------------------------------------------
	
	------------------------------------------------
	TYPE ComplexVector IS ARRAY (NATURAL range <>) OF Complex;
	------------------------------------------------
	           
    ------------------------------------------------
    COMPONENT ROM IS
        PORT(
            Clock : IN STD_LOGIC;
            Address : IN INTEGER RANGE 0 TO 7;
            Data : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
        );  
    END COMPONENT;
    ------------------------------------------------
                    
    ------------------------------------------------
    COMPONENT FFT16p IS
        PORT(
            Reset : IN STD_LOGIC;
            Clock : IN STD_LOGIC;
            Start : IN STD_LOGIC;
            SelectInputOutput : IN STD_LOGIC;
            Input : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            Output : OUT STD_LOGIC_VECTOR (25 DOWNTO 0);
            FinishFFT : OUT STD_LOGIC
        );
    END COMPONENT;
    ------------------------------------------------
                    
    ------------------------------------------------
    COMPONENT ControlFFT IS
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
    END COMPONENT;
    ------------------------------------------------
            
    ------------------------------------------------
    COMPONENT MuxFFT IS
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
    END COMPONENT;
    ------------------------------------------------
        
    ------------------------------------------------
    COMPONENT DemuxFFT IS
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
    END COMPONENT;
	------------------------------------------------
        
    ------------------------------------------------
	COMPONENT CordicV1 IS
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
    END COMPONENT;
	------------------------------------------------
        
    ------------------------------------------------
	COMPONENT SelectIn IS
	   GENERIC(
            NFFT : INTEGER
        );
        PORT(
            ControlSelectIn : IN STD_LOGIC; 
            InputSelectIn : IN ComplexVector((NFFT-1) DOWNTO 0);
            InputDemux : IN ArrayVector((NFFT-1) DOWNTO 0);
            OutputSelectIn : OUT ComplexVector((NFFT-1) DOWNTO 0)
            );
    END COMPONENT;
    ------------------------------------------------
    
	------------------------------------------------
	COMPONENT Butterfly IS
        PORT( 
            XInput : IN Complex;
            YInput : IN Complex;
            XOutput : OUT Complex;
            YOutput : OUT Complex
        );
    END COMPONENT;
    ------------------------------------------------
    
	------------------------------------------------
	COMPONENT SelectOut IS
        GENERIC(NFFT : INTEGER);
        PORT(
            ControlSelectOut : IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
            InputSelectOut : IN ComplexVector((NFFT-1) DOWNTO 0);
            OutputSelectOut : OUT ComplexVector((NFFT-1) DOWNTO 0)
        );
    END COMPONENT;
    ------------------------------------------------
    
	------------------------------------------------
	COMPONENT BaudRate IS
		GENERIC(clkIN, BaudRateOut: INTEGER);
		PORT(clk: IN STD_LOGIC;
			clkOut: BUFFER STD_LOGIC);
	END COMPONENT;
	------------------------------------------------

	------------------------------------------------
	COMPONENT debounce3Switch IS
		GENERIC(NDebounce : INTEGER := 3);
		PORT(clk: IN STD_LOGIC;
			  rst: IN STD_LOGIC;
			  Entrada: IN STD_LOGIC_VECTOR((NDebounce-1) DOWNTO 0);
			  Saida: BUFFER STD_LOGIC_VECTOR((NDebounce-1) DOWNTO 0)
	    );
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	COMPONENT debounce IS
		PORT(clk: IN STD_LOGIC;
			  rst: IN STD_LOGIC;
			  Entrada: IN STD_LOGIC;
			  Saida: BUFFER STD_LOGIC
	    );
	END COMPONENT;
	------------------------------------------------
	
	------------------------------------------------
	
END MainPackage;
------------------------------------------------




PACKAGE BODY MainPackage IS
	

END MainPackage;
------------------------------------------------