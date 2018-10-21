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
     clock : in STD_LOGIC;
     Adress : in AdressVector(3 downto 0);
     Input : in Complex(3 downto 0);
     Output : out Complex(3 downto 0)
  );
end RAMFFT;

architecture Behavioral of RAMFFT is

    signal RAM : Complex(1023 downto 0) := (others=>(others=>'0'));

begin

    Output(0) <= RAM(to_integer(unsigned(Adress(0))));
    Output(1) <= RAM(to_integer(unsigned(Adress(1))));
    Output(2) <= RAM(to_integer(unsigned(Adress(2))));
    Output(3) <= RAM(to_integer(unsigned(Adress(3))));
    
    process(Clock)
    
    begin
        if(clock'event and clock = '1')then
            if(Adress(0) = "00")then
              RAM(0) <= Input(0);         
            
            else
                if(Adress(1) = "00")then
                    RAM(0) <= Input(1);
                
                else
                     if(Adress(2) = "00")then
                        RAM(0) <= Input(2);
                     
                     else
                        RAM(0) <= Input(3);
                     
                     end if;
                end if;
                
            end if;
            
        end if;
        
    end process;

    process(Clock)
    
    begin
        if(clock'event and clock = '1')then
            if(Adress(0) = "01")then
              RAM(1) <= Input(0);         
            
            else
                if(Adress(1) = "01")then
                    RAM(1) <= Input(1);
                
                else
                     if(Adress(2) = "01")then
                        RAM(1) <= Input(2);
                     
                     else
                        RAM(1) <= Input(3);
                     
                     end if;
                end if;
                
            end if;
            
        end if;
        
    end process;
    
    process(Clock)
        
        begin
            if(clock'event and clock = '1')then
                if(Adress(0) = "11")then
                  RAM(3) <= Input(0);         
                
                else
                    if(Adress(1) = "11")then
                        RAM(3) <= Input(1);
                    
                    else
                         if(Adress(2) = "11")then
                            RAM(3) <= Input(2);
                         
                         else
                            RAM(3) <= Input(3);
                         
                         end if;
                    end if;
                    
                end if;
                
            end if;
            
        end process;
        
        process(Clock)
            
            begin
                if(clock'event and clock = '1')then
                    if(Adress(0) = "10")then
                      RAM(2) <= Input(0);         
                    
                    else
                        if(Adress(1) = "10")then
                            RAM(2) <= Input(1);
                        
                        else
                             if(Adress(2) = "10")then
                                RAM(2) <= Input(2);
                             
                             else
                                RAM(2) <= Input(3);
                             
                             end if;
                        end if;
                        
                    end if;
                    
                end if;
                
            end process;
            
            
--    -- Reading and Write Enable Process
--    process(clock, WE)
    
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(0)))) <= Input(0);
                
--            else
--                Output(0) <= RAM(to_integer(unsigned(Adress(0))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(1)))) <= Input(1);
                
--            else
--                Output(1) <= RAM(to_integer(unsigned(Adress(1))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(2)))) <= Input(2);
                
--            else
--                Output(2) <= RAM(to_integer(unsigned(Adress(2))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(3)))) <= Input(3);
                
--            else
--                Output(3) <= RAM(to_integer(unsigned(Adress(3))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(4)))) <= Input(4);
                
--            else
--                Output(4) <= RAM(to_integer(unsigned(Adress(4))));
                
--            end if;                
--        end if;
        
--    end process;              
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(5)))) <= Input(5);
                
--            else
--                Output(5) <= RAM(to_integer(unsigned(Adress(5))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(6)))) <= Input(6);
                
--            else
--                Output(6) <= RAM(to_integer(unsigned(Adress(6))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(7)))) <= Input(7);
                
--            else
--                Output(7) <= RAM(to_integer(unsigned(Adress(7))));
                
--            end if;                
--        end if;
        
--    end process;                            
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(8)))) <= Input(8);
                
--            else
--                Output(8) <= RAM(to_integer(unsigned(Adress(8))));
                
--            end if;                
--        end if;
        
--    end process;   
--     process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(9)))) <= Input(9);
                
--            else
--                Output(9) <= RAM(to_integer(unsigned(Adress(9))));
                
--            end if;                
--        end if;
        
--    end process;   
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(10)))) <= Input(10);
                
--            else
--                Output(10) <= RAM(to_integer(unsigned(Adress(10))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(11)))) <= Input(11);
                
--            else
--                Output(11) <= RAM(to_integer(unsigned(Adress(11))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(12)))) <= Input(12);
                
--            else
--                Output(12) <= RAM(to_integer(unsigned(Adress(12))));
                
--            end if;                
--        end if;
        
--    end process; 
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(13)))) <= Input(13);
                
--            else
--                Output(13) <= RAM(to_integer(unsigned(Adress(13))));
                
--            end if;                
--        end if;
        
--    end process; 
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(14)))) <= Input(14);
                
--            else
--                Output(14) <= RAM(to_integer(unsigned(Adress(14))));
                
--            end if;                
--        end if;
        
--    end process;         
--        process(clock, WE)
    
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(15)))) <= Input(15);
                
--            else
--                Output(15) <= RAM(to_integer(unsigned(Adress(15))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(16)))) <= Input(16);
                
--            else
--                Output(16) <= RAM(to_integer(unsigned(Adress(16))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(17)))) <= Input(17);
                
--            else
--                Output(17) <= RAM(to_integer(unsigned(Adress(1))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(18)))) <= Input(18);
                
--            else
--                Output(18) <= RAM(to_integer(unsigned(Adress(18))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(19)))) <= Input(19);
                
--            else
--                Output(19) <= RAM(to_integer(unsigned(Adress(19))));
                
--            end if;                
--        end if;
        
--    end process;              
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(20)))) <= Input(20);
                
--            else
--                Output(20) <= RAM(to_integer(unsigned(Adress(20))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(21)))) <= Input(21);
                
--            else
--                Output(21) <= RAM(to_integer(unsigned(Adress(21))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(22)))) <= Input(22);
                
--            else
--                Output(22) <= RAM(to_integer(unsigned(Adress(22))));
                
--            end if;                
--        end if;
        
--    end process;                            
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(23)))) <= Input(23);
                
--            else
--                Output(23) <= RAM(to_integer(unsigned(Adress(23))));
                
--            end if;                
--        end if;
        
--    end process;   
--     process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(24)))) <= Input(24);
                
--            else
--                Output(24) <= RAM(to_integer(unsigned(Adress(24))));
                
--            end if;                
--        end if;
        
--    end process;   
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(25)))) <= Input(25);
                
--            else
--                Output(25) <= RAM(to_integer(unsigned(Adress(25))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(26)))) <= Input(26);
                
--            else
--                Output(26) <= RAM(to_integer(unsigned(Adress(26))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(27)))) <= Input(27);
                
--            else
--                Output(27) <= RAM(to_integer(unsigned(Adress(27))));
                
--            end if;                
--        end if;
        
--    end process; 
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(28)))) <= Input(28);
                
--            else
--                Output(28) <= RAM(to_integer(unsigned(Adress(28))));
                
--            end if;                
--        end if;
        
--    end process; 
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(29)))) <= Input(29);
                
--            else
--                Output(29) <= RAM(to_integer(unsigned(Adress(29))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(30)))) <= Input(30);
                
--            else
--                Output(30) <= RAM(to_integer(unsigned(Adress(30))));
                
--            end if;                
--        end if;
        
--    end process;
--    process(clock, WE)
        
--    begin
--        if(clock'event and clock = '1')then
--            if( WE = '1') then
--                RAM(to_integer(unsigned(Adress(31)))) <= Input(31);
                
--            else
--                Output(31) <= RAM(to_integer(unsigned(Adress(31))));
                
--            end if;                
--        end if;
        
--    end process;
                
end Behavioral;
