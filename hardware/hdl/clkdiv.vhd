library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- This entity is a simple linear clock divider. The 'factor' input can be in another clock domain than 'original' clock.
entity clkdiv is
	generic (
		-- Maximum division factor width (default 32 bits)
		FACTOR_WIDTH: integer := 32
	);
	port (
		-- Input clock to be divided
		original: in std_logic;
		-- Division factor (1: no division, 2: division by 2,...)
		factor: in std_logic_vector (FACTOR_WIDTH-1 downto 0);
		-- Divided output clock
		divided: out std_logic
	);
end entity;

-- The linear divider can divide the clock by factors in interval [1, 2^FACTOR_WIDTH[.
architecture rtl of clkdiv is

	signal resync: std_logic_vector (FACTOR_WIDTH-1 downto 0) := (others => '0');
	signal divider: std_logic_vector (FACTOR_WIDTH-1 downto 0) := (others => '0');
	signal counter: std_logic_vector (FACTOR_WIDTH-1 downto 0) := (others => '0');
	signal reshaped: std_logic;

begin

	-- Resynchronize the input signal to 'original' clock
	process (original)
	begin
		if rising_edge(original) then
			resync <= factor;
			divider <= resync;
		end if;
	end process;

	-- Reshape a new clock based on counter values ('1111' when counter<factor/2 '0000' when counter>factor/2)
	process (original)
	begin
		if rising_edge(original) then
			if counter < divider-1 then
				counter <= counter + 1;
				if counter > divider(FACTOR_WIDTH-1 downto 1)-1 then
					reshaped <= '0';
				else
					reshaped <= '1';
				end if;
			else
				counter <= (others => '0');
				reshaped <= '0';
			end if;
		end if;
	end process;

	-- Select the rehaped clock if the divided is a least 2, else the original signal
	divided <= '0' when divider = 0 else original when divider = 1 else counter(0) when divider = 2 else reshaped;

end architecture;
