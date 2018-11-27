----------------------------------------------------------------------------------
-- Barrey Shifter
-- 
-- Create Date: 06.10.2018 16:35:06
-- Design Name: Callebe Barbosa 
-- Module Name: CordicMSR
-- Project Name: FFT1024p
-- Target Devices: ZynqBerry-7010 (XC7Z010-1CLG225C)
-- Tool Versions: Vivado 2017.4
-- Description: MSR Cordic Processor for FFT Module
-- 
-- Dependencies: BarrelShifter1In4Out
-- 
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use work.MainPackage.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CordicMSR is
    Port ( 
        Ain : in SIGNED (31 downto 0);
        Bin : in SIGNED (31 downto 0);
        Control : in STD_LOGIC_VECTOR (20 downto 0);
        Clock : in STD_LOGIC;
        Start : in STD_LOGIC;
        Aout : out SIGNED (31 downto 0);
        Bout : out SIGNED (31 downto 0)
    );
end CordicMSR;

architecture Behavioral of CordicMSR is
    
    signal Xin : SIGNED(15 downto 0) := (others => '0');
    signal Yin : SIGNED(15 downto 0) := (others => '0');
    signal XinSelect : SIGNED(15 downto 0) := (others => '0');
    signal YinSelect : SIGNED(15 downto 0) := (others => '0');
    signal FeedbackX : SIGNED(15 downto 0) := (others => '0');
    signal FeedbackY : SIGNED(15 downto 0) := (others => '0');
    signal AuxOutputX1 : SIGNED(15 downto 0) := (others => '0');
    signal AuxOutputX2 : SIGNED(15 downto 0) := (others => '0');
    signal AuxOutputX3 : SIGNED(15 downto 0) := (others => '0');
    signal AuxOutputY1 : SIGNED(15 downto 0) := (others => '0');
    signal AuxOutputY2 : SIGNED(15 downto 0) := (others => '0');
    signal AuxOutputY3 : SIGNED(15 downto 0) := (others => '0');
    signal SwitchX1 : SIGNED(15 downto 0) := (others => '0');
    signal SwitchX2 : SIGNED(15 downto 0) := (others => '0');
    signal SwitchX3 : SIGNED(15 downto 0) := (others => '0');
    signal SwitchY1 : SIGNED(15 downto 0) := (others => '0');
    signal SwitchY2 : SIGNED(15 downto 0) := (others => '0');
    signal SwitchY3 : SIGNED(15 downto 0) := (others => '0');
    signal X1 : SIGNED(15 downto 0) := (others => '0');
    signal X2 : SIGNED(15 downto 0) := (others => '0');
    signal X3 : SIGNED(15 downto 0) := (others => '0');
    signal Y1 : SIGNED(15 downto 0) := (others => '0');
    signal Y2 : SIGNED(15 downto 0) := (others => '0');
    signal Y3 : SIGNED(15 downto 0) := (others => '0');
        
begin
    
    -- Control 
    -- (20) - Switch S1
    -- (19 - 18) - mu1
    -- (17 - 14) - S1
    -- (13) - Switch S2
    -- (12 - 11) - mu2
    -- (10 - 7) - S2
    -- (6) - Switch S3
    -- (5-4) - mu3
    -- (3-0) - S3 
    BarrelShifterX : BarrelShifter1In3Out Port Map (Input => Xin, Output1 => AuxOutputX1, Output2 => AuxOutputX2, Output3 => AuxOutputX3, S1 => Control(17 downto 14), S2 => Control(10 downto 7), S3 => Control(3 downto 0));
    BarrelShifterY : BarrelShifter1In3Out Port Map (Input => Yin, Output1 => AuxOutputY1, Output2 => AuxOutputY2, Output3 => AuxOutputY3, S1 => Control(17 downto 14), S2 => Control(10 downto 7), S3 => Control(3 downto 0));
    
    --Switchs
    -- Input
    XinSelect <= Bin(31 downto 16) when Start = '1' else
                 FeedbackX;
                 
    YinSelect <= Bin(15 downto 0) when Start = '1' else
                 FeedbackY;
    -- X(n+1)
    SwitchX1 <= AuxOutputX1 when Control(20) = '0' else
                AuxOutputY1;
        
    SwitchX2 <= AuxOutputX2 when Control(13) = '0' else
                AuxOutputY2;
    
    SwitchX3 <= AuxOutputX3 when Control(6) = '0' else
                AuxOutputY3;
    -- Y(n+1)
    SwitchY1 <= AuxOutputY1 when Control(20) = '0' else
                AuxOutputX1;
          
    SwitchY2 <= AuxOutputY2 when Control(13) = '0' else
                AuxOutputX2;
    
    SwitchY3 <= AuxOutputY3 when Control(6) = '0' else
                AuxOutputX3;
                                  
    -- Sign Select
    X1 <= SwitchX1  when (Control(19 downto 18) = "11" and Control(20) = '1') else
          -SwitchX1 when (Control(19 downto 18) = "11" and Control(20) = '0') else
          -SwitchX1 when (Control(19 downto 18) = "01" and Control(20) = '1') else
          SwitchX1  when (Control(19 downto 18) = "01" and Control(20) = '0') else
          (others => '0');
    
    X2 <= SwitchX2 when Control(12 downto 11) = "11" and Control(13) = '1' else
          -SwitchX2 when Control(12 downto 11) = "11" and Control(13) = '0' else
          -SwitchX2 when Control(12 downto 11) = "01" and Control(13) = '1' else
          SwitchX2 when Control(12 downto 11) = "01" and Control(13) = '0' else
          (others => '0');
          
    X3 <= SwitchX3 when Control(5 downto 4) = "11" and Control(6) = '1' else
          -SwitchX3 when Control(5 downto 4) = "11" and Control(6) = '0' else
          -SwitchX3 when Control(5 downto 4) = "01" and Control(6) = '1' else
          SwitchX3 when Control(5 downto 4) = "01" and Control(6) = '0' else
          (others => '0');
   
    Y1 <= -SwitchY1 when Control(19 downto 18) = "11" else
          SwitchY1 when Control(19 downto 18) = "01" else
          (others => '0');
    
    Y2 <= -SwitchY2 when Control(12 downto 11) = "11" else
          SwitchY2 when Control(12 downto 11) = "01" else
          (others => '0');
          
    Y3 <= -SwitchY3 when Control(5 downto 4) = "11" else
          SwitchY3 when Control(5 downto 4) = "01" else
          (others => '0');
                    
    --Adders
    FeedbackX <= to_signed(to_integer(X1) + to_integer(X2) + to_integer(X3), FeedbackX'length);
    FeedbackY <= to_signed(to_integer(Y1) + to_integer(Y2) + to_integer(Y3), FeedbackX'length);
    
    --Output and Feedback
    Bout(31 downto 16) <= FeedbackX;
    Bout(15 downto 0) <= FeedbackY;
    
    --Bypass A
    process(Clock, Start)
    
    begin

        if(Clock'event and  Clock = '1') then
            if(Start = '1') then
                Aout <= Ain;
                
            end if;
        
        end if;
    
    end process;
    
    --Keeping Input Control                             
    process(Clock)
    
    begin

        if(Clock'event and Clock = '1') then
            Xin <= XinSelect;
            Yin <= YinSelect;
        
        end if;
    
    end process;
    
end Behavioral;