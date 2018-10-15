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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Teste is
  Port (
        Clock : in STD_LOGIC;
        reset : in STD_LOGIC;
        start : in STD_LOGIC;
        Input : in STD_LOGIC_VECTOR(15 downto 0);
        Output : out STD_LOGIC_VECTOR(15 downto 0)
  );
end Teste;

architecture Behavioral of Teste is
    
    signal WE : STD_LOGIC;
    signal AdressControl : STD_LOGIC;
    signal ROMCordic : ROMCordicVector(15 downto 0);
    signal OutputCordic : Complex(31 downto 0);
    signal InputCordic : Complex(31 downto 0);
    signal resetCordic : STD_LOGIC;
    signal CordicStart : STD_LOGIC;
    signal AuxAdress : AdressVector(15 downto 0);
    
begin
    
    --ROM for Cordic Twiddle Factors
    ROM0  : ROMFFT0  Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(0));
    ROM1  : ROMFFT1  Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(1));
    ROM2  : ROMFFT2  Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(2));
    ROM3  : ROMFFT3  Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(3));
    ROM4  : ROMFFT4  Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(4));
    ROM5  : ROMFFT5  Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(5));
    ROM6  : ROMFFT6  Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(6));
    ROM7  : ROMFFT7  Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(7));
    ROM8  : ROMFFT8  Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(8));
    ROM9  : ROMFFT9  Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(9));
    ROM10 : ROMFFT10 Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(10));
    ROM11 : ROMFFT11 Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(11));
    ROM12 : ROMFFT12 Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(12));
    ROM13 : ROMFFT13 Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(13));
    ROM14 : ROMFFT14 Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(14));
    ROM15 : ROMFFT15 Port Map(Adress => AdressControl, reset => resetCordic, Data => ROMCordic(15));
    
    --RAM for FFT
    RAM01 : RAMFFT Port Map (Adress => AuxAdress, WE =>WE, Input => OutputCordic, Output => InputCordic);
    --Cordic Processors 
    CORDIC: for i in 0 to 15 generate
        C1 : CordicMSR Port Map (Ain => InputCordic(2*i) , Bin=> InputCordic(2*i+1), Start => CordicStart, Control => ROMCordic(i), Clock => Clock, Aout => OutputCordic(2*i), Bout => OutputCordic(2*i+1));
        
    end generate;
        
end Behavioral;
