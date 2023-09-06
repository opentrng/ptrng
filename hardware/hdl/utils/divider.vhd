library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- This entity is a simple clock divider, it comes with two architectures: shift and linear.
entity divider is
	generic (
		-- Maximum division factor width (default 32 bits)
		MAX_WIDTH: integer := 32
	);
	port (
		-- Input clock to be divided
		original: in std_logic;
		-- Division factor (1: no division, 2: division by 2,...)
		factor: std_logic_vector (MAX_WIDTH-1 downto 0);
		-- Divided output clock
		divided: out std_logic
	);
end entity;

-- The divider pow2 architecture can divide the clock by power of 2 by shifting the LSB of the counter.
architecture pow2 of divider is

	signal metastable: std_logic_vector (MAX_WIDTH-1 downto 0) := (others => '0');
	signal stable: std_logic_vector (MAX_WIDTH-1 downto 0) := (others => '0');
	signal counter: std_logic_vector (MAX_WIDTH-1 downto 0) := (others => '0');

begin

	process (original)
	begin
		if rising_edge(original) then
			metastable <= factor;
			stable <= metastable;
			counter <= counter + 1;
		end if;
	end process;

	divided <= original when stable = 0 else counter(conv_integer(stable-1));

end architecture;

-- The divider linear architecture can divide the clock by factors in interval [1, 2^MAX_WIDTH[.
architecture linear of divider is

	signal resync: std_logic_vector(MAX_WIDTH-1 downto 0) := (others => '0');
	signal stable: std_logic_vector (MAX_WIDTH-1 downto 0) := (others => '0');
	signal counter: std_logic_vector (MAX_WIDTH-1 downto 0) := (others => '0');
	signal reshaped: std_logic;

begin

	process (original)
	begin
		if rising_edge(original) then
			resync <= factor;
			stable <= resync;
			if counter < stable-1 then
				counter <= counter + 1;
				if counter > stable(MAX_WIDTH-1 downto 1)-1 then
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

	divided <= '0' when stable = 0 else original when stable = 1 else counter(0) when stable = 2 else reshaped;

end architecture;
