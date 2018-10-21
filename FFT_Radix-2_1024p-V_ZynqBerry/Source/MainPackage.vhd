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
    TYPE AdressVector IS ARRAY (NATURAL range <>) OF  STD_LOGIC_VECTOR(1 downto 0);  
    ------------------------------------------------
    
    ------------------------------------------------
    TYPE Complex IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0);
    ------------------------------------------------
    
    ------------------------------------------------
    TYPE DemuxInputFFT IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0);
    ------------------------------------------------
                   
    ------------------------------------------------
	TYPE ROMCordicVector IS ARRAY (NATURAL range <>) OF STD_LOGIC_VECTOR(20 DOWNTO 0);
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
    component ROMFFT8 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT9 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT10 is
        Port(
            Adress : in STD_LOGIC;
            reset : in STD_LOGIC;
            Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT11 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT12 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
    component ROMFFT13 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT14 is
        Port(
             Adress : in STD_LOGIC;
             reset : in STD_LOGIC;
             Data : out STD_LOGIC_VECTOR (20 downto 0)
        );
    end component;
    ------------------------------------------------
        
    ------------------------------------------------
    component ROMFFT15 is
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