----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Callebe S. Barbosa
-- 
-- Create Date: 06.10.2018 17:44:00
-- Design Name: 
-- Module Name: RAMFFT
-- Project Name: FFT1024p
-- Target Devices: ZynqBerry-7010 (XC7Z010-1CLG225C)
-- Tool Versions: Vivado 2017.4
-- Description: Modulo Memory RAM for FFT1024p
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
library UNISIM;
use UNISIM.VComponents.all;

entity RAMFFT is
  Port (
     Adress : in AdressVector(31 downto 0);
     WE : in STD_LOGIC;
     Input : in Complex(31 downto 0);
     Output : out Complex(31 downto 0)
  );
end RAMFFT;

architecture Behavioral of RAMFFT is

    signal RAM : Complex(1023 downto 0);
    
begin

    -- Write Enable Process
    process(WE)
    
    begin
        
        if(WE'event and WE = '1') then
            RAM(to_integer(signed(Adress(0)))) <= Input(0);
            RAM(to_integer(signed(Adress(1)))) <= Input(1);
            RAM(to_integer(signed(Adress(2)))) <= Input(2);
            RAM(to_integer(signed(Adress(3)))) <= Input(3);
            RAM(to_integer(signed(Adress(4)))) <= Input(4);
            RAM(to_integer(signed(Adress(5)))) <= Input(5);
            RAM(to_integer(signed(Adress(6)))) <= Input(6);
            RAM(to_integer(signed(Adress(7)))) <= Input(7);
            RAM(to_integer(signed(Adress(8)))) <= Input(8);
            RAM(to_integer(signed(Adress(9)))) <= Input(9);
            RAM(to_integer(signed(Adress(10)))) <= Input(10);
            RAM(to_integer(signed(Adress(11)))) <= Input(11);
            RAM(to_integer(signed(Adress(12)))) <= Input(12);
            RAM(to_integer(signed(Adress(13)))) <= Input(13);
            RAM(to_integer(signed(Adress(14)))) <= Input(14);
            RAM(to_integer(signed(Adress(15)))) <= Input(15);
            RAM(to_integer(signed(Adress(16)))) <= Input(16);
            RAM(to_integer(signed(Adress(17)))) <= Input(17);
            RAM(to_integer(signed(Adress(18)))) <= Input(18);
            RAM(to_integer(signed(Adress(19)))) <= Input(19);
            RAM(to_integer(signed(Adress(20)))) <= Input(20);
            RAM(to_integer(signed(Adress(21)))) <= Input(21);
            RAM(to_integer(signed(Adress(22)))) <= Input(22);
            RAM(to_integer(signed(Adress(23)))) <= Input(23);
            RAM(to_integer(signed(Adress(24)))) <= Input(24);
            RAM(to_integer(signed(Adress(25)))) <= Input(25);
            RAM(to_integer(signed(Adress(26)))) <= Input(26);
            RAM(to_integer(signed(Adress(27)))) <= Input(27);
            RAM(to_integer(signed(Adress(28)))) <= Input(28);
            RAM(to_integer(signed(Adress(29)))) <= Input(29);
            RAM(to_integer(signed(Adress(30)))) <= Input(30);
            RAM(to_integer(signed(Adress(31)))) <= Input(31);
                        
        end if;
        
    end process;

    -- Reading
    process(WE)
        
    begin
        
        if(WE'event and WE = '0') then
            Output(0) <= RAM(to_integer(signed(Adress(0))));
            Output(1) <= RAM(to_integer(signed(Adress(1))));
            Output(2) <= RAM(to_integer(signed(Adress(2))));
            Output(3) <= RAM(to_integer(signed(Adress(3))));
            Output(4) <= RAM(to_integer(signed(Adress(4))));
            Output(5) <= RAM(to_integer(signed(Adress(5))));
            Output(6) <= RAM(to_integer(signed(Adress(6))));
            Output(7) <= RAM(to_integer(signed(Adress(7))));
            Output(8) <= RAM(to_integer(signed(Adress(8))));
            Output(9) <= RAM(to_integer(signed(Adress(9))));
            Output(10) <= RAM(to_integer(signed(Adress(10))));
            Output(11) <= RAM(to_integer(signed(Adress(11))));
            Output(12) <= RAM(to_integer(signed(Adress(12))));
            Output(13) <= RAM(to_integer(signed(Adress(13))));
            Output(14) <= RAM(to_integer(signed(Adress(14))));
            Output(15) <= RAM(to_integer(signed(Adress(15))));
            Output(16) <= RAM(to_integer(signed(Adress(16))));
            Output(17) <= RAM(to_integer(signed(Adress(17))));
            Output(18) <= RAM(to_integer(signed(Adress(18))));
            Output(19) <= RAM(to_integer(signed(Adress(19))));
            Output(20) <= RAM(to_integer(signed(Adress(20))));
            Output(21) <= RAM(to_integer(signed(Adress(21))));
            Output(22) <= RAM(to_integer(signed(Adress(22))));
            Output(23) <= RAM(to_integer(signed(Adress(23))));
            Output(24) <= RAM(to_integer(signed(Adress(24))));
            Output(25) <= RAM(to_integer(signed(Adress(25))));
            Output(26) <= RAM(to_integer(signed(Adress(26))));
            Output(27) <= RAM(to_integer(signed(Adress(27))));
            Output(28) <= RAM(to_integer(signed(Adress(28))));
            Output(29) <= RAM(to_integer(signed(Adress(29))));
            Output(30) <= RAM(to_integer(signed(Adress(30))));
            Output(31) <= RAM(to_integer(signed(Adress(31))));            
                            
        end if;
        
    end process;
    
end Behavioral;
