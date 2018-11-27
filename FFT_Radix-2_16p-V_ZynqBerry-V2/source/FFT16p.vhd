----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.10.2018 23:35:53
-- Design Name: 
-- Module Name: Teste - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.MainPackage.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FFT16p is
  Port (
        Clock : in STD_LOGIC;
        StartFFT : in STD_LOGIC;
        InputFFT : in Array_Vector_16b(15 downto 0);
        FinishFFT : out STD_LOGIC;
        OutputFFT : out Array_Vector_16b(15 downto 0)
  );
end FFT16p;

architecture Behavioral of FFT16p is
    
    signal ROMCordic : AdressVector(15 downto 0) := (others => (others => '0'));
    signal CordicStart : STD_LOGIC := '0';
    signal SelectOutButterFly : Complex(15 downto 0) := (others => (others => '0'));
    signal SelectOutButterFlyR : Array_Vector_16b(15 downto 0) := (others => (others => '0'));
    signal SelectOutButterFlyI : Array_Vector_16b(15 downto 0) := (others => (others => '0'));
    signal CordicSelectIn : Complex(15 downto 0) := (others => (others => '0'));
    signal CordicSelectInI : Array_Vector_16b(15 downto 0) := (others => (others => '0'));
    signal SelectInSelectOut : Complex(15 downto 0) := (others => (others => '0'));
    signal ButterflyCordic : Complex(15 downto 0) := (others => (others => '0'));
    signal ButterflyCordicR : Array_Vector_16b(15 downto 0) := (others => (others => '0'));
    signal ButterflyCordicI : Array_Vector_16b(15 downto 0) := (others => (others => '0'));
    signal resetRom : STD_LOGIC := '0';
    signal ChangeROMAdress : STD_LOGIC := '0';
    signal ControlSelectIn : STD_LOGIC := '0';
    signal ControlSelectOut : STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
    signal ClockCordic : STD_LOGIC := '0';
        
begin
    
    --Control Unit
    CU : UCFFT16 Port Map (
        Clock => Clock, 
        StartFFT => StartFFT, 
        FinishFFT => FinishFFT, 
        StartCORDIC => CordicStart, 
        resetRomCordic => resetRom, 
        ClockCordic => ClockCordic, 
        ChangeROMAdress => ChangeROMAdress,
        ControlSelectIn => ControlSelectIn, 
        ControlSelectOut => ControlSelectOut
    );
    
    --Select In
    SI : SelectInFFT16p Port Map(
        ControlSelectIn => ControlSelectIn, 
        InputSelectIn =>  CordicSelectIn, 
        InputDemux => InputFFT, 
        OutputSelectIn => SelectInSelectOut
    );
        
    --Select Out
    SO : SelectOutFFT16p Port Map (
        ControlSelectOut => "00", 
        InputSelectOut => SelectInSelectOut, 
        OutputSelectOut => SelectOutButterFly
    ); 
   
   --Butterfly
    B0 : Butterfly Port Map(XInput =>  SelectOutButterFly(0),  YInput => SelectOutButterFly(1),  XOutput => ButterflyCordic(0),  YOutput => ButterflyCordic(1));
    B1 : Butterfly Port Map(XInput =>  SelectOutButterFly(2),  YInput => SelectOutButterFly(3),  XOutput => ButterflyCordic(2),  YOutput => ButterflyCordic(3));
    B2 : Butterfly Port Map(XInput =>  SelectOutButterFly(4),  YInput => SelectOutButterFly(5),  XOutput => ButterflyCordic(4),  YOutput => ButterflyCordic(5));
    B3 : Butterfly Port Map(XInput =>  SelectOutButterFly(6),  YInput => SelectOutButterFly(7),  XOutput => ButterflyCordic(6),  YOutput => ButterflyCordic(7));
    B4 : Butterfly Port Map(XInput =>  SelectOutButterFly(8),  YInput => SelectOutButterFly(9),  XOutput => ButterflyCordic(8),  YOutput => ButterflyCordic(9));
    B5 : Butterfly Port Map(XInput =>  SelectOutButterFly(10), YInput => SelectOutButterFly(11), XOutput => ButterflyCordic(10), YOutput => ButterflyCordic(11));
    B6 : Butterfly Port Map(XInput =>  SelectOutButterFly(12), YInput => SelectOutButterFly(13), XOutput => ButterflyCordic(12), YOutput => ButterflyCordic(13));
    B7 : Butterfly Port Map(XInput =>  SelectOutButterFly(14), YInput => SelectOutButterFly(15), XOutput => ButterflyCordic(14), YOutput => ButterflyCordic(15));
    
    --ROM for Cordic Twiddle Factors
    ROM0  : ROMFFT160  Port Map(Adress => ChangeROMAdress, reset => resetRom, Data => ROMCordic(0));
    ROM1  : ROMFFT161  Port Map(Adress => ChangeROMAdress, reset => resetRom, Data => ROMCordic(1));
    ROM2  : ROMFFT162  Port Map(Adress => ChangeROMAdress, reset => resetRom, Data => ROMCordic(2));
    ROM3  : ROMFFT163  Port Map(Adress => ChangeROMAdress, reset => resetRom, Data => ROMCordic(3));
    ROM4  : ROMFFT164  Port Map(Adress => ChangeROMAdress, reset => resetRom, Data => ROMCordic(4));
    ROM5  : ROMFFT165  Port Map(Adress => ChangeROMAdress, reset => resetRom, Data => ROMCordic(5));
    ROM6  : ROMFFT166  Port Map(Adress => ChangeROMAdress, reset => resetRom, Data => ROMCordic(6));    
    ROM7  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => resetRom, Data => ROMCordic(7));
       
    --Cordic
    C0 : CordicMSR Port Map (Ain => ButterflyCordic(0),  Bin => ButterflyCordic(1),  Control => ROMCordic(0), Clock => ClockCordic, Start => CordicStart, Aout => CordicSelectIn(0), Bout => CordicSelectIn(1));
    C1 : CordicMSR Port Map (Ain => ButterflyCordic(2),  Bin => ButterflyCordic(3),  Control => ROMCordic(1), Clock => ClockCordic, Start => CordicStart, Aout => CordicSelectIn(2), Bout => CordicSelectIn(3));
    C2 : CordicMSR Port Map (Ain => ButterflyCordic(4),  Bin => ButterflyCordic(5),  Control => ROMCordic(2), Clock => ClockCordic, Start => CordicStart, Aout => CordicSelectIn(4), Bout => CordicSelectIn(5));
    C3 : CordicMSR Port Map (Ain => ButterflyCordic(6),  Bin => ButterflyCordic(7),  Control => ROMCordic(3), Clock => ClockCordic, Start => CordicStart, Aout => CordicSelectIn(6), Bout => CordicSelectIn(7));
    C4 : CordicMSR Port Map (Ain => ButterflyCordic(8),  Bin => ButterflyCordic(9),  Control => ROMCordic(4), Clock => ClockCordic, Start => CordicStart, Aout => CordicSelectIn(8), Bout => CordicSelectIn(9));
    C5 : CordicMSR Port Map (Ain => ButterflyCordic(10), Bin => ButterflyCordic(11), Control => ROMCordic(5), Clock => ClockCordic, Start => CordicStart, Aout => CordicSelectIn(10), Bout => CordicSelectIn(11));
    C6 : CordicMSR Port Map (Ain => ButterflyCordic(12), Bin => ButterflyCordic(13), Control => ROMCordic(6), Clock => ClockCordic, Start => CordicStart, Aout => CordicSelectIn(12), Bout => CordicSelectIn(13));
    C7 : CordicMSR Port Map (Ain => ButterflyCordic(14), Bin => ButterflyCordic(15), Control => ROMCordic(7), Clock => ClockCordic, Start => CordicStart, Aout => CordicSelectIn(14), Bout => CordicSelectIn(15));
    
    OutputFFT(0) <= CordicSelectIn(0)(31 downto 16);
    OutputFFT(1) <= CordicSelectIn(1)(31 downto 16);
    OutputFFT(2) <= CordicSelectIn(2)(31 downto 16);
    OutputFFT(3) <= CordicSelectIn(3)(31 downto 16);
    OutputFFT(4) <= CordicSelectIn(4)(31 downto 16);
    OutputFFT(5) <= CordicSelectIn(5)(31 downto 16);
    OutputFFT(6) <= CordicSelectIn(6)(31 downto 16);
    OutputFFT(7) <= CordicSelectIn(7)(31 downto 16);
    OutputFFT(8) <= CordicSelectIn(8)(31 downto 16);
    OutputFFT(9) <= CordicSelectIn(9)(31 downto 16);
    OutputFFT(10) <= CordicSelectIn(10)(31 downto 16);
    OutputFFT(11) <= CordicSelectIn(11)(31 downto 16);
    OutputFFT(12) <= CordicSelectIn(12)(31 downto 16);
    OutputFFT(13) <= CordicSelectIn(13)(31 downto 16);
    OutputFFT(14) <= CordicSelectIn(14)(31 downto 16);
    OutputFFT(15) <= CordicSelectIn(15)(31 downto 16);
    
    SelectOutButterFlyR(0) <= SelectOutButterFly(0)(31 downto 16);
    SelectOutButterFlyR(1) <= SelectOutButterFly(1)(31 downto 16);
    SelectOutButterFlyR(2) <= SelectOutButterFly(2)(31 downto 16);
    SelectOutButterFlyR(3) <= SelectOutButterFly(3)(31 downto 16);
    SelectOutButterFlyR(4) <= SelectOutButterFly(4)(31 downto 16);
    SelectOutButterFlyR(5) <= SelectOutButterFly(5)(31 downto 16);
    SelectOutButterFlyR(6) <= SelectOutButterFly(6)(31 downto 16);
    SelectOutButterFlyR(7) <= SelectOutButterFly(7)(31 downto 16);
    SelectOutButterFlyR(8) <= SelectOutButterFly(8)(31 downto 16);
    SelectOutButterFlyR(9) <= SelectOutButterFly(9)(31 downto 16);
    SelectOutButterFlyR(10) <= SelectOutButterFly(10)(31 downto 16);
    SelectOutButterFlyR(11) <= SelectOutButterFly(11)(31 downto 16);
    SelectOutButterFlyR(12) <= SelectOutButterFly(12)(31 downto 16);
    SelectOutButterFlyR(13) <= SelectOutButterFly(13)(31 downto 16);
    SelectOutButterFlyR(14) <= SelectOutButterFly(14)(31 downto 16);
    SelectOutButterFlyR(15) <= SelectOutButterFly(15)(31 downto 16);
    SelectOutButterFlyI(0) <= SelectOutButterFly(0)(15 downto 0);
    SelectOutButterFlyI(1) <= SelectOutButterFly(1)(15 downto 0);
    SelectOutButterFlyI(2) <= SelectOutButterFly(2)(15 downto 0);
    SelectOutButterFlyI(3) <= SelectOutButterFly(3)(15 downto 0);
    SelectOutButterFlyI(4) <= SelectOutButterFly(4)(15 downto 0);
    SelectOutButterFlyI(5) <= SelectOutButterFly(5)(15 downto 0);
    SelectOutButterFlyI(6) <= SelectOutButterFly(6)(15 downto 0);
    SelectOutButterFlyI(7) <= SelectOutButterFly(7)(15 downto 0);
    SelectOutButterFlyI(8) <= SelectOutButterFly(8)(15 downto 0);
    SelectOutButterFlyI(9) <= SelectOutButterFly(9)(15 downto 0);
    SelectOutButterFlyI(10) <= SelectOutButterFly(10)(15 downto 0);
    SelectOutButterFlyI(11) <= SelectOutButterFly(11)(15 downto 0);
    SelectOutButterFlyI(12) <= SelectOutButterFly(12)(15 downto 0);
    SelectOutButterFlyI(13) <= SelectOutButterFly(13)(15 downto 0);
    SelectOutButterFlyI(14) <= SelectOutButterFly(14)(15 downto 0);
    SelectOutButterFlyI(15) <= SelectOutButterFly(15)(15 downto 0);
        
        
    
    ButterflyCordicR(0) <= ButterflyCordic(0)(31 downto 16);
    ButterflyCordicR(1) <= ButterflyCordic(1)(31 downto 16);
    ButterflyCordicR(2) <= ButterflyCordic(2)(31 downto 16);
    ButterflyCordicR(3) <= ButterflyCordic(3)(31 downto 16);
    ButterflyCordicR(4) <= ButterflyCordic(4)(31 downto 16);
    ButterflyCordicR(5) <= ButterflyCordic(5)(31 downto 16);
    ButterflyCordicR(6) <= ButterflyCordic(6)(31 downto 16);
    ButterflyCordicR(7) <= ButterflyCordic(7)(31 downto 16);
    ButterflyCordicR(8) <= ButterflyCordic(8)(31 downto 16);
    ButterflyCordicR(9) <= ButterflyCordic(9)(31 downto 16);
    ButterflyCordicR(10) <= ButterflyCordic(10)(31 downto 16);
    ButterflyCordicR(11) <= ButterflyCordic(11)(31 downto 16);
    ButterflyCordicR(12) <= ButterflyCordic(12)(31 downto 16);
    ButterflyCordicR(13) <= ButterflyCordic(13)(31 downto 16);
    ButterflyCordicR(14) <= ButterflyCordic(14)(31 downto 16);
    ButterflyCordicR(15) <= ButterflyCordic(15)(31 downto 16);
    ButterflyCordicI(0) <= ButterflyCordic(0)(15 downto 0);
    ButterflyCordicI(1) <= ButterflyCordic(1)(15 downto 0);
    ButterflyCordicI(2) <= ButterflyCordic(2)(15 downto 0);
    ButterflyCordicI(3) <= ButterflyCordic(3)(15 downto 0);
    ButterflyCordicI(4) <= ButterflyCordic(4)(15 downto 0);
    ButterflyCordicI(5) <= ButterflyCordic(5)(15 downto 0);
    ButterflyCordicI(6) <= ButterflyCordic(6)(15 downto 0);
    ButterflyCordicI(7) <= ButterflyCordic(7)(15 downto 0);
    ButterflyCordicI(8) <= ButterflyCordic(8)(15 downto 0);
    ButterflyCordicI(9) <= ButterflyCordic(9)(15 downto 0);
    ButterflyCordicI(10) <= ButterflyCordic(10)(15 downto 0);
    ButterflyCordicI(11) <= ButterflyCordic(11)(15 downto 0);
    ButterflyCordicI(12) <= ButterflyCordic(12)(15 downto 0);
    ButterflyCordicI(13) <= ButterflyCordic(13)(15 downto 0);
    ButterflyCordicI(14) <= ButterflyCordic(14)(15 downto 0);
    ButterflyCordicI(15) <= ButterflyCordic(15)(15 downto 0);
    
    CordicSelectInI (0) <= CordicSelectIn(0)(15 downto 0);
    CordicSelectInI (1) <= CordicSelectIn(1)(15 downto 0);
    CordicSelectInI (2) <= CordicSelectIn(2)(15 downto 0);
    CordicSelectInI (3) <= CordicSelectIn(3)(15 downto 0);
    CordicSelectInI (4) <= CordicSelectIn(4)(15 downto 0);
    CordicSelectInI (5) <= CordicSelectIn(5)(15 downto 0);
    CordicSelectInI (6) <= CordicSelectIn(6)(15 downto 0);
    CordicSelectInI (7) <= CordicSelectIn(7)(15 downto 0);
    CordicSelectInI (8) <= CordicSelectIn(8)(15 downto 0);
    CordicSelectInI (9) <= CordicSelectIn(9)(15 downto 0);
    CordicSelectInI (10) <= CordicSelectIn(10)(15 downto 0);
    CordicSelectInI (11) <= CordicSelectIn(11)(15 downto 0);
    CordicSelectInI (12) <= CordicSelectIn(12)(15 downto 0);
    CordicSelectInI (13) <= CordicSelectIn(13)(15 downto 0);
    CordicSelectInI (14) <= CordicSelectIn(14)(15 downto 0);
    CordicSelectInI (15) <= CordicSelectIn(15)(15 downto 0);
         
end Behavioral;
