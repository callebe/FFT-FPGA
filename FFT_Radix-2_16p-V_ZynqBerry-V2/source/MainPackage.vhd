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
    TYPE AdressVector IS ARRAY (NATURAL range <>) OF  STD_LOGIC_VECTOR(20 downto 0);  
    ------------------------------------------------
    
    ------------------------------------------------
    TYPE Complex IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0);
    ------------------------------------------------
    
    ------------------------------------------------
    TYPE Array_Vector_16b IS ARRAY (NATURAL range <>) OF signed(15 downto 0);
    ------------------------------------------------
    
    ------------------------------------------------
    TYPE DemuxInputFFT IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0);
    ------------------------------------------------
                   
    ------------------------------------------------
	TYPE ROMCordicVector IS ARRAY (NATURAL range <>) OF STD_LOGIC_VECTOR(20 DOWNTO 0);
	------------------------------------------------
                       
    ------------------------------------------------
	component SelectInFFT16p is
        PORT(
            ControlSelectIn : IN STD_LOGIC; 
            InputSelectIn : IN Complex(15 downto 0);
            InputDemux : IN Array_Vector_16b(15 downto 0);
            OutputSelectIn : OUT Complex(15 downto 0)
            );
    end component;
	------------------------------------------------
                   
    ------------------------------------------------
    component SelectOutFFT16p is
        PORT(
            ControlSelectOut : IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
            InputSelectOut : IN Complex(15 DOWNTO 0);
            OutputSelectOut : OUT Complex(15 DOWNTO 0)
            );
    end component;
    ------------------------------------------------
                       
    ------------------------------------------------
    component FFT16p is
      Port (
            Clock : in STD_LOGIC;
            StartFFT : in STD_LOGIC;
            InputFFT : in Array_Vector_16b(15 downto 0);
            FinishFFT : out STD_LOGIC;
            OutputFFT : out Array_Vector_16b(15 downto 0)
      );
    end component;
    ------------------------------------------------
                       
    ------------------------------------------------
	component Butterfly is
        PORT( 
            XInput : IN signed(31 downto 0);
            YInput : IN signed(31 downto 0);
            XOutput : OUT signed(31 downto 0);
            YOutput : OUT signed(31 downto 0)
        );
    end component;
	------------------------------------------------
	           
    ------------------------------------------------
    component AdressRAM is
      Port (
        Adress : in STD_LOGIC;
        reset : in STD_LOGIC;
        OutputAdress : buffer AdressVector(31 downto 0)
      );
    end component;
    ------------------------------------------------
                       
    ------------------------------------------------
    component UCFFT16 is
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
    end component;
    ------------------------------------------------
                   
    ------------------------------------------------
    component RAMFFT is
      Port (
         Adress : in AdressVector(31 downto 0);
         WE : in STD_LOGIC;
         Input : in Complex(31 downto 0);
         Output : out Complex(31 downto 0)
      );
    end component;
    ------------------------------------------------
                   
    ------------------------------------------------
    component BarrelShifter1In3Out is
        Port(
            Input : in SIGNED (15 downto 0);
            Output1 : out SIGNED (15 downto 0);
            Output2 : out SIGNED (15 downto 0);
            Output3 : out SIGNED (15 downto 0);
            S1 : in STD_LOGIC_VECTOR (3 downto 0);
            S2 : in STD_LOGIC_VECTOR (3 downto 0);
            S3 : in STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;
    ------------------------------------------------
                   
    ------------------------------------------------
	component ROMFFT0 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT1 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT2 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT3 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
	component ROMFFT4 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT5 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT6 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT7 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT160 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT161 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT162 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT163 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
            
    ------------------------------------------------
    component ROMFFT164 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT165 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT166 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT167 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
            
    ------------------------------------------------
    component CordicMSR is
        Port ( 
            Ain : in SIGNED (31 downto 0);
            Bin : in SIGNED (31 downto 0);
            Control : in STD_LOGIC_VECTOR (20 downto 0);
            Clock : in STD_LOGIC;
            Start : in STD_LOGIC;
            Aout : out SIGNED (31 downto 0);
            Bout : out SIGNED (31 downto 0)
        );
    end component;

END MainPackage;
------------------------------------------------


------------------------------------------------
PACKAGE BODY MainPackage IS
	

END MainPackage;
------------------------------------------------