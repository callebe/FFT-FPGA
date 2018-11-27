----------------------------------------------------------------------------------
-- Select In FFT
-- 
-- Create Date: 06.10.2018 16:35:06
-- Design Name: Callebe Barbosa 
-- Module Name: SelectInFFT16p
-- Project Name: FFT16p
-- Target Devices: ZynqBerry-7010 (XC7Z010-1CLG225C)
-- Tool Versions: Vivado 2017.4
-- Description: Control Unit for FFT with 16 point
-- 
-- Dependencies: 
-- 
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE work.MainPackage.all;

ENTITY SelectInFFT16p IS
    PORT(
        ControlSelectIn : IN STD_LOGIC; 
        InputSelectIn : IN Complex(15 downto 0);
        InputDemux : IN Array_Vector_16b(15 downto 0);
        OutputSelectIn : OUT Complex(15 downto 0)
        );
END SelectInFFT16p;

ARCHITECTURE Behavioral OF SelectInFFT16p IS

BEGIN
	
	S1: FOR k  IN 0 TO (NFFT-1) GENERATE
		OutputSelectIn(k)(31 downto 16) <=  InputSelectIn(k)(31 downto 16) WHEN ControlSelectIn = '0' ELSE
					            InputDemux(k);
					            
        OutputSelectIn(k)(15 downto 0) <= InputSelectIn(k)(15 downto 0) WHEN ControlSelectIn = '0' ELSE
                                       (others => '0');
	END GENERATE;

END Behavioral;