library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ROMFFT3 is
	Port(
		Adress : in STD_LOGIC;
		reset : in STD_LOGIC;
		Data : out STD_LOGIC_VECTOR (20 downto 0)
		);
end ROMFFT3;

architecture Behavioral of ROMFFT3 is

	type ROM is array (11 downto 0) of std_logic_vector(20 downto 0) ;
	-- ROM 4 
	constant ROM_tb : ROM := (
		0 => "011001001101010010000",
		1 => "011000000111101110000",
		2 => "011011001110110010000",
		3 => "011001001101010010000",
		4 => "011000000111101110000",
		5 => "011011001110110010000",
		6 => "011001001101010010000",
		7 => "011000000111101110000",
		8 => "011011001110110010000",
		9 => "011001001101010010000",
		10 => "011000000111101110000",
		11 => "011011001110110010000");

	begin
		--Process to acess Data
		process(Adress, reset)

			variable Counter : integer range 11 downto 0 := 0;

		begin

		Data <= Rom_tb(Counter);
		if(reset = '1')then
			Counter := 0;

		elsif(Adress'event and Adress = '1') then
			Counter := Counter + 1;

		end if;

	end process;

end Behavioral;