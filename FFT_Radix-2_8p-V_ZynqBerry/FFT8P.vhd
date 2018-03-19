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

ENTITY FFT IS
    PORT(
        Reset : STD_LOGIC;
    	Clock : IN STD_LOGIC;
        Start : IN STD_LOGIC;
    	RefreshMuxDemuxFFT : IN STD_LOGIC;
        InputFFT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        FinishFFT : OUT STD_LOGIC;
        OutputFFT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END FFT;

ARCHITECTURE Behavioral OF FFT IS
    
    -- Defines
    CONSTANT NLevels : INTEGER := 512;
    CONSTANT NFFT : INTEGER := (2**NLevels);
    CONSTANT TimeLapseCordic : INTEGER := 4;
    --Interconect Signals
    SIGNAL InputFFT_InputDemux : Complex;
    SIGNAL DemuxFFT_SelectIn : ComplexVector((NFFT-1) DOWNTO 0);
    SIGNAL SelectIn_Butterfly : ComplexVector((NFFT-1) DOWNTO 0);
    SIGNAL Butterfly_DLCO : ComplexVector((NFFT-1) DOWNTO 0);
    SIGNAL FinishCordic_RefreshDelayLogic : STD_LOGIC_VECTOR((NFFT/2-1) DOWNTO 0);
    SIGNAL DLCO_SelectOut : ComplexVector((NFFT-1) DOWNTO 0);
    SIGNAL SelectOut_ButterflyMod : ComplexVector((NFFT-1) DOWNTO 0);
    SIGNAL ButterflyMod_Mux : ComplexVector((NFFT/2-1) DOWNTO 0);
    SIGNAL Mux_OutputFFT : Complex;
    --Control Signals
    SIGNAL ControlSelectIn : STD_LOGIC;
    SIGNAL StartCordic : STD_LOGIC;
    SIGNAL ControlSelectOut : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
    
    ---------------------------------------------------------------
    --                     Central Control                       --
    --------------------------------------------------------------- 
    Control : ControlFFT GENERIC MAP (NLevels => NLevels, TimeLapseCordic => TimeLapseCordic) PORT MAP (Reset => Reset, Clock => Clock, Start => Start, ControlSelectIn => ControlSelectIn, StartCordic => StartCordic,  ControlSelectOut => ControlSelectOut, FinishFFT => FinishFFT);
    
	---------------------------------------------------------------
    --                      Demux of Input                       --
    ---------------------------------------------------------------
    Demux : DemuxFFT GENERIC MAP (NFFT => NFFT) PORT MAP(RefreshDemuxFFT => RefreshMuxDemuxFFT, Reset => Reset, InputDemuxFFT => InputFFT , OutputDemuxFFT => DemuxFFT_SelectIn);

    ---------------------------------------------------------------
    --                Select Input of Each Butterfly             --
    ---------------------------------------------------------------
    SelectInput : SelectIn GENERIC MAP (NFFT => NFFT) PORT MAP(ControlSelectIn => ControlSelectIn, InputSelectIn => DemuxFFT_SelectIn, Feedback => SelectOut_ButterflyMod, OutputSelectIn => SelectIn_Butterfly);

    ---------------------------------------------------------------
    --                         Butterflies                       --
    ---------------------------------------------------------------
    B: FOR k  IN 0 TO (NFFT/2-1) GENERATE
        Bk :  Butterfly PORT MAP (XInput => SelectIn_Butterfly(2*k), YInput => SelectIn_Butterfly(2*k+1), XOutput => Butterfly_DLCO(2*k), YOutput => Butterfly_DLCO(2*k+1));
        DLk : DelayLogic PORT MAP (RefreshDelayLogic => FinishCordic_RefreshDelayLogic(k), InputDelayLogic => Butterfly_DLCO(2*k), OutputDelayLogic => DLCO_SelectOut(2*k));
        COk : CordicV1 PORT MAP (Clock => Clock, StartCordic => StartCordic, InputCordic => Butterfly_DLCO(2*k+1), FinishCordic => FinishCordic_RefreshDelayLogic(k), OutputCordic => DLCO_SelectOut(2*k+1)); 

    END GENERATE;

    ---------------------------------------------------------------
    --                Select Output of Each Butterfly            --
    ---------------------------------------------------------------
    SelectOutput : SelectOut GENERIC MAP (NFFT) PORT MAP (ControlSelectOut => ControlSelectOut, InputSelectOut => DLCO_SelectOut, OutputSelectOut => SelectOut_ButterflyMod);

    ---------------------------------------------------------------
    --                      Half Butterflies                     --
    ---------------------------------------------------------------
    BH: FOR k  IN 0 TO (NFFT/2-1) GENERATE
        BHk :  ButterflyHalf PORT MAP (XInput => SelectOut_ButterflyMod(2*k), YInput => SelectOut_ButterflyMod(2*k+1), XOutput => ButterflyMod_Mux(k));

    END GENERATE;
        
    ---------------------------------------------------------------
    --                       Mux  of Input                       --
    ---------------------------------------------------------------
    Mux : MuxFFT GENERIC MAP(NFFT => NFFT) PORT MAP(RefreshMuxFFT => RefreshMuxDemuxFFT, Reset => Reset, InputMuxFFT => ButterflyMod_Mux, OutputMuxFFT => OutputFFT);

END Behavioral;