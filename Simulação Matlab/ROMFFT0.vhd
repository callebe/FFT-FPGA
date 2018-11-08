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

	type ROM is array (11 downto 0) of std_logic_vector(20 downto 0) ;
	-- ROM 1 
	constant ROM_tb : ROM := (
		0 => "111000010100001010000",
		1 => "111000111100101110010",
		2 => "011000000100000010000",
		3 => "111000010100001010000",
		4 => "111000111100101110010",
		5 => "011000000100000010000",
		6 => "111000010100001010000",
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

		elsif(Adress'event and Adress = '1') then
			Counter := Counter + 1;

		end if;

	end process;

end Behavioral;