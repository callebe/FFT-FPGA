----------------------------------------------------------------------------------
--                         The FFT Module
--
--   Main component of FFT Module
--   
--
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY FFT8P IS
    PORT(
        Reset : STD_LOGIC;
    	Clock : IN STD_LOGIC;
    	Input : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
    	Output : OUT STD_LOGIC_VECTOR (26 DOWNTO 0)
        
    );
END FFT8P;

ARCHITECTURE Behavioral OF FFT8P IS
    
    -- Defines
    CONSTANT NLevels : INTEGER := 4;
    CONSTANT NFFT : INTEGER := (2**NLevels);
    CONSTANT TimeLapseCordic : INTEGER := 4;
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
    SIGNAL InputFFT : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL Start : STD_LOGIC;
    SIGNAL SelectDemuxMux : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL OutputFFT : STD_LOGIC_VECTOR(25 DOWNTO 0);
    SIGNAL FinishFFT : STD_LOGIC;
    SIGNAL SetInputData : STD_LOGIC;
    SIGNAL ClockCordic : STD_LOGIC;
    
BEGIN
    
    InputFFT <= Input(11 DOWNTO 0);
    Start <= Input(12);
    SelectDemuxMux <= Input(20 DOWNTO 13);
    Output(25 DOWNTO 0) <= OutputFFT;
    Output(26) <= FinishFFT;
    
    ---------------------------------------------------------------
    --                     Central Control                       --
    --------------------------------------------------------------- 
    CentralControl : ControlFFT GENERIC MAP (NLevels => NLevels, TimeLapseCordic => TimeLapseCordic) PORT MAP (Reset => Reset, Clock => Clock, Start => Start, ControlSelectIn => ControlSelectIn, StartCordic => StartCordic,  ControlSelectOut => ControlSelectOut, SetInputData => SetInputData, FinishFFT => FinishFFT);
    
    ---------------------------------------------------------------
    --                           Demux                           --
    ---------------------------------------------------------------
    Demux : DemuxFFT GENERIC MAP (NFFT => NFFT) PORT MAP(SelectDemux => SelectDemuxMux, InputDemuxFFT => InputFFT, OutputDemuxFFT => Demux_SelectIn);

    ---------------------------------------------------------------
    --                Select Input of Each Butterfly             --
    ---------------------------------------------------------------
    SelectInput : SelectIn GENERIC MAP (NFFT => NFFT) PORT MAP(ControlSelectIn => ControlSelectIn, InputSelectIn => Butterfly_SelectIn, InputDemux => Demux_SelectIn, OutputSelectIn => SelectIn_Cordic);

    ---------------------------------------------------------------
    --                         Cordic                            --
    ---------------------------------------------------------------
    ClockCordic <= Clock WHEN StartCordic = '1'  ELSE
                   '0'; 
                   
    Cordick: FOR k  IN 0 TO (NFFT/2-1) GENERATE
        Cordic : CordicV1 GENERIC MAP (NFFT => NFFT) PORT MAP (Clock => ClockCordic, Reset => SetInputData, XInputCordic => SelectIn_Cordic(2*k), YInputCordic => SelectIn_Cordic(2*k+1), XOutputCordic => Cordic_SelectOut(2*k), YOutputCordic => Cordic_SelectOut(2*k+1)); 
    
    END GENERATE;
    
    ---------------------------------------------------------------
    --                Select Output of Each Butterfly            --
    ---------------------------------------------------------------
    SelectOutput : SelectOut GENERIC MAP (NFFT) PORT MAP (ControlSelectOut => ControlSelectOut, InputSelectOut => Cordic_SelectOut, OutputSelectOut => SelectOut_Butterfly);

    ---------------------------------------------------------------
    --                         Butterflies                       --
    ---------------------------------------------------------------
    B: FOR k  IN 0 TO (NFFT/2-1) GENERATE
       Butter :  Butterfly PORT MAP (XInput => SelectOut_Butterfly(2*k), YInput => SelectOut_Butterfly(2*k+1), XOutput => Butterfly_SelectIn(2*k), YOutput => Butterfly_SelectIn(2*k+1));
       Butterfly_Mux(k) <= Butterfly_SelectIn(2*k);
    END GENERATE;
    ---------------------------------------------------------------
    --                             Mux                           --
    ---------------------------------------------------------------
    Mux : MuxFFT GENERIC MAP (NFFT => NFFT) PORT MAP(SelectMux => SelectDemuxMux, InputMuxFFT => Butterfly_Mux, OutputMuxFFT => OutputFFT(25 DOWNTO 0));
        
END Behavioral;