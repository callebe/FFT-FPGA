library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ROMFFT16p_1 is
	Port(
		Adress : in STD_LOGIC;
		reset : in STD_LOGIC;
		Data : out STD_LOGIC_VECTOR (20 downto 0)
		);
end ROMFFT16p_1;

architecture Behavioral of ROMFFT16p_1 is

	type ROM is array (11 downto 0) of std_logic_vector(20 downto 0) ;
	-- ROM 2 
	constant ROM_tb : ROM := (
		0 => "011001111101101010000",
		1 => "011000111100001010011",
		2 => "001000010111011011111",
		3 => "111001011101011010000",
		4 => "011000000111101110000",
		5 => "011011001110110010000",
		6 => "011000000100000010000",
		7 => "111000111100101110010",
		8 => "011000000100000010000",
		9 => "111000010100001010000",
		10 => "111000111100101110010",
		11 => "011000000100000010000");

	begin
		--Process to acess Data
		process(Adress, reset)

			variable Counter : integer range 11 downto 0 := 0;

		begin

		Data <= Rom_tb(Counter);
		if(reset = '1')then
			Counter := 0;

		elsif(Adress'event and Adress = '0') then
			Counter := Counter + 1;

		end if;

	end process;

end Behavioral;