----------------------------------------------------------------------------------
-- Select Out FFT
-- 
-- Create Date: 06.10.2018 16:35:06
-- Design Name: Callebe Barbosa 
-- Module Name: SelectOutFFT16p
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

ENTITY SelectOutFFT16p IS
    PORT(
        ControlSelectOut : IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
        InputSelectOut : IN Complex(15 DOWNTO 0);
        OutputSelectOut : OUT Complex(15 DOWNTO 0)
        );
END SelectOutFFT16p;

ARCHITECTURE Behavioral OF SelectOutFFT16p IS

BEGIN

OutputSelectOut(0) <= InputSelectOut(0);
OutputSelectOut(1) <= InputSelectOut(8) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(8) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(4) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(2);
OutputSelectOut(2) <= InputSelectOut(1) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(2) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(2) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(1);
OutputSelectOut(3) <= InputSelectOut(9) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(10) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(6) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(3);
OutputSelectOut(4) <= InputSelectOut(2) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(4) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(1) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(4);
OutputSelectOut(5) <= InputSelectOut(10) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(12) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(5) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(6);
OutputSelectOut(6) <= InputSelectOut(3) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(6) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(3) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(5);
OutputSelectOut(7) <= InputSelectOut(11) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(14) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(7) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(7);
OutputSelectOut(8) <= InputSelectOut(4) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(1) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(8) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(8);
OutputSelectOut(9) <= InputSelectOut(12) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(9) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(12) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(10);
OutputSelectOut(10) <= InputSelectOut(5) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(3) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(10) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(9);
OutputSelectOut(11) <= InputSelectOut(13) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(11) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(14) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(11);
OutputSelectOut(12) <= InputSelectOut(6) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(5) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(9) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(12);
OutputSelectOut(13) <= InputSelectOut(14) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(13) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(13) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(14);
OutputSelectOut(14) <= InputSelectOut(7) WHEN ControlSelectOut = "00" ELSE
			 InputSelectOut(7) WHEN ControlSelectOut = "01" ELSE
			 InputSelectOut(11) WHEN ControlSelectOut = "10" ELSE
			 InputSelectOut(13);
OutputSelectOut(15) <= InputSelectOut(15);


END Behavioral;