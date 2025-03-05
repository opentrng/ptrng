library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- This entity is a simple linear clock divider. The 'factor' input can be in another clock domain than 'original' clock but must be stable when 'changed' is low.
entity clkdivider is
	generic (
		-- Maximum division factor width (default 32 bits)
		FACTOR_WIDTH: natural := 32
	);
	port (
		-- Asynchronous reset
		reset: in std_logic;
		-- Input clock to be divided
		original: in std_logic;
		-- Division factor (1: no division, 2: division by 2,...)
		divider: in std_logic_vector (FACTOR_WIDTH-1 downto 0);
		-- Enable strobed when divisor factor changes
		changed: in std_logic;
		-- Divided output clock
		divided: out std_logic
	);
end entity;

-- The pulse divider can divide the clock by factors in interval [1, 2^FACTOR_WIDTH[ with a non balanced duty cycle.
architecture pulse of clkdivider is

	signal counter: std_logic_vector (FACTOR_WIDTH-1 downto 0);
	signal pulse: std_logic;

begin

	-- Create the pulse when counter is equal to 1
	process (original, reset, changed)
	begin
		if reset = '1' or changed = '1' then
			counter <= (others => '0');
			pulse <= '0';
		elsif rising_edge(original) then
			if divider = 2 then
				counter(0) <= not counter(0);
				pulse <= counter(0);
			elsif counter < divider-1 then
				counter <= counter + 1;
				if counter = 1 then
					pulse <= '1';
				else
					pulse <= '0';
				end if;
			else
				counter <= (others => '0');
				pulse <= '0';
			end if;
		end if;
	end process;

	-- Select the rehaped clock if the divided is a least 2, else the original signal
	divided <= '0' when divider = 0 else original when divider = 1 else pulse;

end architecture;
