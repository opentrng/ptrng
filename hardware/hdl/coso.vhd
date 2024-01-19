library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- This entity defines the Coherent Sampling Ring Oscillator entropy source, where the first ring oscillator samples the second one, resulting in the generation of a beat signal. A counter, incremented by the second ring oscillator (RO2), measures the period of the beat signal. The COSO's random output is derived from the least significant bit (LSB) of the counter and is accessible through the 'lsb' port. Additionally, the resampled internal counter signal is available through the 'raw' port, and both of these signals are synchronized with the output clock ('clk').
entity coso is
	port (
		-- First ring oscillaor input
		ro1: in std_logic;
		-- Second ring oscillaor input
		ro2: in std_logic;
		-- Clock output (equal to ro2/div)
		clk: out std_logic;
		-- Entropy source data output (counter LSB)
		lsb: out std_logic;
		-- Raw value of the counter
		raw: out std_logic_vector (31 downto 0)
	);
end entity;

-- This architecture implements the RTL version of COSO measuring full period of beat signal with counter reset on beat signal rising edges.
architecture rtl of coso is

	signal beat: std_logic := '0';
	signal prev: std_logic := '0';
	signal reset: std_logic := '0';
	signal counter: std_logic_vector (31 downto 0) := (others => '0');
	signal value: std_logic_vector (31 downto 0) := (others => '0');

begin

	-- Sample RO1 with RO2 to create the beat signal
	process (ro2)
	begin
		if rising_edge(ro2) then
			beat <= ro1;
			prev <= beat;
		end if;
	end process;

	-- Detect beat rising edge to create counter reset
	reset <= '1' when beat = '1' and prev = '0' else '0';

	-- Count the full period of the beat in steps of RO2
	process (ro2, reset)
	begin
		if reset = '1' then
			counter <= (others => '0');
		elsif rising_edge(ro2) then
			counter <= counter + 1;
		end if;
	end process;

	-- Resample the value of the counter
	process (beat)
	begin
		if rising_edge(beat) then
			value <= counter;
		end if;
	end process;
	
	-- Output LSB and raw signals synchronized to the beat
	clk <= beat;
	lsb <= value(0);
	raw <= value;

end architecture;
