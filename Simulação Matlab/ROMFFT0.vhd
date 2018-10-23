library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ROMFFT0 is
	Port(
		Adress : in STD_LOGIC;
		reset : in STD_LOGIC;
		Data : out STD_LOGIC_VECTOR (20 downto 0)
		);
end ROMFFT0;

architecture Behavioral of ROMFFT0 is

	type ROM is array (863 downto 0) of std_logic_vector(20 downto 0) ;
	-- ROM 1 
	constant ROM_tb : ROM := (
		0 => "111000010100001010000",
		1 => "111000010100001010000",
		2 => "111000010100001010000",
