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
    
    signal ROMCordic : AdressVector(15 downto 0);
    signal CordicStart : STD_LOGIC := '0';
    signal SelectOutButterFly : Complex(15 downto 0);
    signal CordicSelectIn : Complex(15 downto 0);
    signal SelectInSelectOut : Complex(15 downto 0);
    signal ButterflyCordic : Complex(15 downto 0);
    signal InputCordicX : SIGNED(31 downto 0) := ("00010110000000000000010110101100");
    signal InputCordicY : SIGNED(31 downto 0) := ("00010110000000000000010110101100");
    signal resetRomCordic : STD_LOGIC := '0';
    signal ChangeROMAdress : STD_LOGIC := '0';
    signal ControlSelectIn : STD_LOGIC := '0';
    signal ControlSelectOut : STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
        
begin
    
    --Control Unit
    CU : UCFFT16 Port Map (Clock => Clock, StartFFT => StartFFT, FinishFFT => FinishFFT, StartCORDIC => CordicStart, ChangeROMAdress => ChangeROMAdress, ControlSelectIn => ControlSelectIn, ControlSelectOut => ControlSelectOut);
    
    --Select In
    SI : SelectInFFT16p Port Map(ControlSelectIn => ControlSelectIn, InputSelectIn =>  CordicSelectIn, InputDemux => InputFFT, OutputSelectIn => SelectInSelectOut);
        
    --Select Out
    SO : SelectOutFFT16p Port Map (ControlSelectOut => ControlSelectOut, InputSelectOut => SelectInSelectOut, OutputSelectOut => SelectOutButterFly); 
   
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
    ROM0  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => resetRomCordic, Data => ROMCordic(0));
    ROM1  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => resetRomCordic, Data => ROMCordic(1));
    ROM2  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => resetRomCordic, Data => ROMCordic(2));
    ROM3  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => resetRomCordic, Data => ROMCordic(3));
    ROM4  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => resetRomCordic, Data => ROMCordic(4));
    ROM5  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => resetRomCordic, Data => ROMCordic(5));
    ROM6  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => resetRomCordic, Data => ROMCordic(6));
    ROM7  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => resetRomCordic, Data => ROMCordic(7));
       
    --Cordic
    C0 : CordicMSR Port Map (Ain => ButterflyCordic(0),  Bin => ButterflyCordic(1),  Control => ROMCordic(0), Clock => Clock, Start => CordicStart, Aout => CordicSelectIn(0), Bout => CordicSelectIn(1));
    C1 : CordicMSR Port Map (Ain => ButterflyCordic(2),  Bin => ButterflyCordic(3),  Control => ROMCordic(1), Clock => Clock, Start => CordicStart, Aout => CordicSelectIn(2), Bout => CordicSelectIn(3));
    C2 : CordicMSR Port Map (Ain => ButterflyCordic(4),  Bin => ButterflyCordic(5),  Control => ROMCordic(2), Clock => Clock, Start => CordicStart, Aout => CordicSelectIn(4), Bout => CordicSelectIn(5));
    C3 : CordicMSR Port Map (Ain => ButterflyCordic(6),  Bin => ButterflyCordic(7),  Control => ROMCordic(3), Clock => Clock, Start => CordicStart, Aout => CordicSelectIn(6), Bout => CordicSelectIn(7));
    C4 : CordicMSR Port Map (Ain => ButterflyCordic(8),  Bin => ButterflyCordic(9),  Control => ROMCordic(4), Clock => Clock, Start => CordicStart, Aout => CordicSelectIn(8), Bout => CordicSelectIn(9));
    C5 : CordicMSR Port Map (Ain => ButterflyCordic(10), Bin => ButterflyCordic(11), Control => ROMCordic(5), Clock => Clock, Start => CordicStart, Aout => CordicSelectIn(10), Bout => CordicSelectIn(11));
    C6 : CordicMSR Port Map (Ain => ButterflyCordic(12), Bin => ButterflyCordic(13), Control => ROMCordic(6), Clock => Clock, Start => CordicStart, Aout => CordicSelectIn(12), Bout => CordicSelectIn(13));
    C7 : CordicMSR Port Map (Ain => ButterflyCordic(14), Bin => ButterflyCordic(15), Control => ROMCordic(7), Clock => Clock, Start => CordicStart, Aout => CordicSelectIn(14), Bout => CordicSelectIn(15));
                
end Behavioral;
