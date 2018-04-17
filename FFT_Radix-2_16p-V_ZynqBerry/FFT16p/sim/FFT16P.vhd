----------------------------------------------------------------------------------
--                         The FFT Module
--
--   Main component of FFT Module
--   
--rsa\r43q ´Ç,M ~´[P,M ´´POIUGC765SZA1      '   ].,M 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY FFT16p IS
    PORT(
        Reset : IN STD_LOGIC;
    	Clock : IN STD_LOGIC;
    	Start : IN STD_LOGIC;
    	SelectInputOutput : IN STD_LOGIC;
    	Input : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
    	Output : OUT STD_LOGIC_VECTOR (25 DOWNTO 0);
    	FinishFFT : OUT STD_LOGIC
    );
END FFT16p;

ARCHITECTURE Behavioral OF FFT16p IS
   
    --Interconect Signals
    SIGNAL Butterfly_SelectIn : ComplexVector((NFFT -1) DOWNTO 0);
    SIGNAL Demux_SelectIn : ArrayVector((NFFT -1) DOWNTO 0);
    SIGNAL SelectIn_Cordic : ComplexVector((NFFT -1) DOWNTO 0);
    SIGNAL Cordic_SelectOut : ComplexVector((NFFT -1) DOWNTO 0);
    SIGNAL SelectOut_Butterfly : ComplexVector((NFFT -1) DOWNTO 0);
    SIGNAL Butterfly_Mux : ComplexVector((NFFT/2 -1) DOWNTO 0);
    --Control Signals
    SIGNAL ControlSelectIn : STD_LOGIC;
    SIGNAL StartCordic : STD_LOGIC;
    SIGNAL ControlSelectOut : STD_LOGIC_VECTOR(3 DOWNTO 0);
    --Input and Output Signals
    SIGNAL SetInputData : STD_LOGIC;
    SIGNAL CounterClock : INTEGER RANGE 0 TO (NumberOfCordicInteractions-1);
    SIGNAL ChangeROM : STD_LOGIC := '0';
    SIGNAL Butterfly_MuxFirst : STD_LOGIC_VECTOR((25-NLevels*2) DOWNTO 0);
    SIGNAL Butterfly_MuxOthers : MuxVector((NFFT/2 - 2) DOWNTO 0);
    SIGNAL FinishAux : STD_LOGIC;
    
BEGIN
   
    
    ---------------------------------------------------------------
    --                     Central Control                       --
    --------------------------------------------------------------- 
    CentralControl : ControlFFT PORT MAP (Reset => Reset, Clock => Clock, Start => Start, StartCordic => StartCordic, ControlSelectIn => ControlSelectIn, ControlSelectOut => ControlSelectOut, CounterClock => CounterClock, ChangeROM => ChangeROM, SetInputData => SetInputData, FinishFFT => FinishAux);
    
    ---------------------------------------------------------------
    --                           Demux                           --
    ---------------------------------------------------------------
    Demux : DemuxFFT GENERIC MAP(NFFT => NFFT) PORT MAP(Reset => Reset, Clock => SelectInputOutput, Start => Start, InputDemuxFFT => Input, OutputDemuxFFT => Demux_SelectIn);
    ---------------------------------------------------------------
    --                Select Input of Each Butterfly             --
    ---------------------------------------------------------------
    SelectInput : SelectIn GENERIC MAP (NFFT => NFFT) PORT MAP(ControlSelectIn => ControlSelectIn, InputSelectIn => Butterfly_SelectIn, InputDemux => Demux_SelectIn, OutputSelectIn => SelectIn_Cordic);

    ---------------------------------------------------------------
    --                         Cordic                            --
    ---------------------------------------------------------------
    Cordick: FOR k  IN 0 TO (NFFT/2-1) GENERATE
        Cordic : CordicV1 GENERIC MAP (NumberOfCordicInteractions => NumberOfCordicInteractions, NLevels =>NLevels, IndexFFT => k) PORT MAP (Clock => Clock, Reset => SetInputData, StartCordic => StartCordic, XInputCordic => SelectIn_Cordic(2*k), YInputCordic => SelectIn_Cordic(2*k+1), CounterClock => CounterClock, ChangeROM => ChangeROM, XOutputCordic => Cordic_SelectOut(2*k), YOutputCordic => Cordic_SelectOut(2*k+1)); 
    
    END GENERATE;
    
    ---------------------------------------------------------------
    --                Select Output of Each Butterfly            --
    ---------------------------------------------------------------
    SelectOutput : SelectOut GENERIC MAP (NFFT) PORT MAP (ControlSelectOut => ControlSelectOut, InputSelectOut => Cordic_SelectOut, OutputSelectOut => SelectOut_Butterfly);

    ---------------------------------------------------------------
    --                         Butterflies                       --
    ---------------------------------------------------------------
    Butter :  Butterfly PORT MAP (XInput => SelectOut_Butterfly(0), YInput => SelectOut_Butterfly(1), XOutput => Butterfly_SelectIn(0), YOutput => Butterfly_SelectIn(1));
    Butterfly_MuxFirst((25-NLevels*2) DOWNTO (13-NLevels)) <= Butterfly_SelectIn(0).r(12 DOWNTO (NLevels));
    Butterfly_MuxFirst((12-NLevels) DOWNTO 0) <= Butterfly_SelectIn(0).i(12 DOWNTO (NLevels));
    
    B: FOR k  IN 1 TO (NFFT/2-1) GENERATE
       Butter :  Butterfly PORT MAP (XInput => SelectOut_Butterfly(2*k), YInput => SelectOut_Butterfly(2*k+1), XOutput => Butterfly_SelectIn(2*k), YOutput => Butterfly_SelectIn(2*k+1));
       Butterfly_MuxOthers(k-1)((25-((NLevels-1)*2)) DOWNTO (13-(NLevels-1))) <= Butterfly_SelectIn(2*k).r(12 DOWNTO (NLevels-1));
       Butterfly_MuxOthers(k-1)((12-(NLevels-1)) DOWNTO 0) <= Butterfly_SelectIn(2*k).i(12 DOWNTO (NLevels-1));
       
    END GENERATE;
    ---------------------------------------------------------------
    --                             Mux                           --
    ---------------------------------------------------------------
    Mux : MuxFFT GENERIC MAP(NFFT => NFFT, NLevels => NLevels) PORT MAP(Reset => Reset, Clock => SelectInputOutput, FinishFFT => FinishAux, Butterfly_MuxFirst => Butterfly_MuxFirst, Butterfly_MuxOthers => Butterfly_MuxOthers,  OutputMuxFFT => Output);
    FinishFFT <= FinishAux;
        
END Behavioral;