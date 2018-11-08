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

entity Teste is
  Port (
        Clock : in STD_LOGIC;
        StartFFT : in STD_LOGIC;
        OutputCordicX : out SIGNED(31 downto 0);
        OutputCordicY : out SIGNED(31 downto 0)
  );
end Teste;

architecture Behavioral of Teste is
    
    signal ROMCordic : AdressVector(15 downto 0);
    signal CordicStart : STD_LOGIC := '0';
    signal SelectInCordic : Complex(15 downto 0);
    signal CordicSelectOut : Complex(15 downto 0);
    signal SelectOutButterfly : Complex(15 downto 0);
    signal ButterflySelectIn : Complex(15 downto 0);
    signal InputCordicX : SIGNED(31 downto 0) := ("00010110000000000000010110101100");
    signal InputCordicY : SIGNED(31 downto 0) := ("00010110000000000000010110101100");
    signal reset : STD_LOGIC := '0';
    signal ChangeROMAdress : STD_LOGIC := '0';
        
begin
    
    --ROM for Cordic Twiddle Factors
    ROM0  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => reset, Data => ROMCordic(0));
    ROM1  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => reset, Data => ROMCordic(1));
    ROM2  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => reset, Data => ROMCordic(2));
    ROM3  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => reset, Data => ROMCordic(3));
    ROM4  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => reset, Data => ROMCordic(4));
    ROM5  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => reset, Data => ROMCordic(5));
    ROM6  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => reset, Data => ROMCordic(6));
    ROM7  : ROMFFT167  Port Map(Adress => ChangeROMAdress, reset => reset, Data => ROMCordic(7));
       
    --Cordic
    C0 : CordicMSR Port Map (Ain => SelectInCordic(0),  Bin => SelectInCordic(1),  Control => ROMCordic(0), Clock => Clock, Start => CordicStart, Aout => CordicSelectOut(0), Bout => CordicSelectOut(1));
    C1 : CordicMSR Port Map (Ain => SelectInCordic(2),  Bin => SelectInCordic(3),  Control => ROMCordic(1), Clock => Clock, Start => CordicStart, Aout => CordicSelectOut(2), Bout => CordicSelectOut(3));
    C2 : CordicMSR Port Map (Ain => SelectInCordic(4),  Bin => SelectInCordic(5),  Control => ROMCordic(2), Clock => Clock, Start => CordicStart, Aout => CordicSelectOut(4), Bout => CordicSelectOut(5));
    C3 : CordicMSR Port Map (Ain => SelectInCordic(6),  Bin => SelectInCordic(7),  Control => ROMCordic(3), Clock => Clock, Start => CordicStart, Aout => CordicSelectOut(6), Bout => CordicSelectOut(7));
    C4 : CordicMSR Port Map (Ain => SelectInCordic(8),  Bin => SelectInCordic(9),  Control => ROMCordic(4), Clock => Clock, Start => CordicStart, Aout => CordicSelectOut(8), Bout => CordicSelectOut(9));
    C5 : CordicMSR Port Map (Ain => SelectInCordic(10), Bin => SelectInCordic(11), Control => ROMCordic(5), Clock => Clock, Start => CordicStart, Aout => CordicSelectOut(10), Bout => CordicSelectOut(11));
    C6 : CordicMSR Port Map (Ain => SelectInCordic(12), Bin => SelectInCordic(13), Control => ROMCordic(6), Clock => Clock, Start => CordicStart, Aout => CordicSelectOut(12), Bout => CordicSelectOut(13));
    C7 : CordicMSR Port Map (Ain => SelectInCordic(14), Bin => SelectInCordic(15), Control => ROMCordic(7), Clock => Clock, Start => CordicStart, Aout => CordicSelectOut(14), Bout => CordicSelectOut(15));
      
    --Control Unit
    CU : UCFFT16 Port Map (Clock => Clock , reset =>  reset, StartFFT =>  StartFFT, StartCORDIC => CordicStart, ChangeROMAdress => ChangeROMAdress);
    
    --Select Out
    
    
    --Butterfly
    B0 : Butterfly Port Map(XInput =>  SelectOutButterfly(0),  YInput => SelectOutButterfly(1),  XOutput => ButterflySelectIn(0),  YOutput => ButterflySelectIn(1));
    B1 : Butterfly Port Map(XInput =>  SelectOutButterfly(2),  YInput => SelectOutButterfly(3),  XOutput => ButterflySelectIn(2),  YOutput => ButterflySelectIn(3));
    B2 : Butterfly Port Map(XInput =>  SelectOutButterfly(4),  YInput => SelectOutButterfly(5),  XOutput => ButterflySelectIn(4),  YOutput => ButterflySelectIn(5));
    B3 : Butterfly Port Map(XInput =>  SelectOutButterfly(6),  YInput => SelectOutButterfly(7),  XOutput => ButterflySelectIn(6),  YOutput => ButterflySelectIn(7));
    B4 : Butterfly Port Map(XInput =>  SelectOutButterfly(8),  YInput => SelectOutButterfly(9),  XOutput => ButterflySelectIn(8),  YOutput => ButterflySelectIn(9));
    B5 : Butterfly Port Map(XInput =>  SelectOutButterfly(10), YInput => SelectOutButterfly(11), XOutput => ButterflySelectIn(10), YOutput => ButterflySelectIn(11));
    B6 : Butterfly Port Map(XInput =>  SelectOutButterfly(12), YInput => SelectOutButterfly(13), XOutput => ButterflySelectIn(12), YOutput => ButterflySelectIn(13));
    B7 : Butterfly Port Map(XInput =>  SelectOutButterfly(14), YInput => SelectOutButterfly(15), XOutput => ButterflySelectIn(14), YOutput => ButterflySelectIn(15));
        
end Behavioral;
