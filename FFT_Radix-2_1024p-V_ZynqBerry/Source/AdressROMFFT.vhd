----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.10.2018 22:42:14
-- Design Name: 
-- Module Name: AdressROMFFT - Behavioral
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

entity AdressROMFFT is
  Port (
    Adress : in STD_LOGIC;
    reset : in STD_LOGIC;
    OutputAdress : buffer AdressVector(31 downto 0)
  );
end AdressROMFFT;

architecture Behavioral of AdressROMFFT is
    constant TotalCordic : STD_LOGIC_VECTOR(9 downto 0) := "1000000000";
    signal LimitOfDFT : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal LengthDFT : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal Carry : AdressVector(16 downto 0) := (others=>"0000000000");
    signal NCordic : AdressVector(16 downto 0) := (others=>"0000000000");
    signal Level : integer range 0 to 9 := 0;
    signal CounterCicles : integer RANGE 0 TO 31 := 0;
   
begin

    -- Odd and Even Outputs
    Outputs : for i in 0 to 15 generate
        Carry(i + 1) <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(Carry(i))) + to_integer(signed(LengthDFT & '0')), Carry(1)'length)) when LimitOfDFT = NCordic(i) else
                    Carry(i);
        NCordic(i+1)        <=  (others => '0') when LimitOfDFT = NCordic(i) else
                                STD_LOGIC_VECTOR(to_signed((to_integer(signed(NCordic(i))) + 1), NCordic(0)'length));
        OutputAdress(2*i)   <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(NCordic(i))) + to_integer(signed(Carry(i))), OutputAdress(0)'length));
        OutputAdress(2*i+1) <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(OutputAdress(2*i))) + to_integer(signed(LengthDFT)), OutputAdress(0)'length));
        
    end generate Outputs;
    
    --Limit of DFT per Layer (Needs change Manual)
    LimitOfDFT <= STD_LOGIC_VECTOR(to_signed(to_integer(signed(LengthDFT)) - 1, LimitOfDFT'length));
    with Level Select
        LengthDFT <= TotalCordic when 0,
                      "0" & TotalCordic(9 downto 1) when 1,
                      "00" & TotalCordic(9 downto 2) when 2,
                      "000" & TotalCordic(9 downto 3) when 3,
                      "0000" & TotalCordic(9 downto 4) when 4,
                      "00000" & TotalCordic(9 downto 5) when 5,
                      "000000" & TotalCordic(9 downto 6) when 6,
                      "0000000" & TotalCordic(9 downto 7) when 7,
                      "00000000" & TotalCordic(9 downto 8) when 8,
                      "000000000" & TotalCordic(9) when 9,
                      "0000000000" when others;
                          
    --Control Flow
    FlowControl : process(Adress, reset, CounterCicles)
        
        variable MemoNcordic : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
        variable MemoCarry : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
        
    begin
    
        NCordic(0) <= MemoNcordic;
        Carry(0) <= MemoCarry;
        if(reset = '1') then
            MemoNcordic := (others => '0');
            MemoCarry := (others => '0');
            
        elsif(Adress'event and Adress = '1') then
            if(CounterCicles = 31) then
                MemoNcordic := (others => '0');
                MemoCarry := (others => '0');
                            
            else
                MemoNcordic := NCordic(16);
                MemoCarry := Carry(16);
                
            end if;
            
        end if;
    
    end process;
    
    --Control Level
    LevelControl : process(Adress, reset, Level, CounterCicles)
    
        
       
    begin
    
        if(reset = '1') then
            CounterCicles <= 0;
            Level <= 0;
            
        elsif(Adress'event and Adress = '0') then
            if(CounterCicles = 31) then
                if(Level < 9) then
                    Level <= Level + 1;
                    CounterCicles <= 0;
                    
                end if;
                
            else
                CounterCicles <= CounterCicles + 1;
                    
            end if;
            
        end if;
    
    end process;

end Behavioral;
