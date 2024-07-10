library ieee;
use ieee.std_logic_1164.all;

-- This entity is a simple delay cell (from 0 -no delay- to LENGTH).
entity delay is
	generic (
		-- Duration of the delay (in clk cycle)
		LENGTH: natural;
		-- Default value of the output signal (after reset)
		VALUE: std_logic := '0'
	);
	port (
		-- Base clock
		clk: in std_logic;
		-- Asynchronous reset active to '1'
		reset: in std_logic;
		-- Input signal
		input: in std_logic;
		-- Delayed output signal
		output: out std_logic
	);
end entity;

-- RTL implementation of the delay based on a shift register.
architecture rtl of delay is

	signal shift: std_logic_vector (LENGTH-1 downto 0);

begin

	-- Store the input signal into the shift register
	process (clk, reset)
	begin
		if reset = '1' then
			shift <= (others => VALUE);
		elsif rising_edge(clk) then
			shift <= shift(LENGTH-2 downto 0) & input;
		end if;
	end process;

	-- Delayed output or direct output
	output <= shift(LENGTH-1) when LENGTH > 0 else input;

end architecture;

