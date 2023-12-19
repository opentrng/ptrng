library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- This entity defines the Coherent Sampling Ring Oscillator entropy source, where the first ring oscillator samples the second one, resulting in the generation of a beat signal. A counter, incremented by the second ring oscillator (RO2), measures the (half or full) period of the beat signal. The COSO's random output is derived from the least significant bit (LSB) of the counter and is accessible through the 'lsb' port. Additionally, the resampled internal counter signal is available through the 'raw' port, and both of these signals are synchronized with the output clock ('clk').
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

-- This architecture implements the RTL version of COSO measuring half period of beat signal with counter reset when beat is high ('1').
architecture original of coso is

	signal beat: std_logic;
	signal counter: std_logic_vector (31 downto 0) := (others => '0');

begin

	-- Sample RO1 with RO2 to create the beat signal
	process (ro2)
	begin
		if rising_edge(ro2) then
			beat <= ro1;
		end if;
	end process;

	-- Count the half period of the beat in steps of RO2
	process (ro2, beat)
	begin
		if beat = '1' then
			counter <= (others => '0');
		elsif rising_edge(ro2) then
			counter <= counter + 1;
		end if;
	end process;

	-- Resample the LSB and the raw value of the counter
	process (beat)
	begin
		if rising_edge(beat) then
			lsb <= counter(0);
			raw <= counter;
		end if;
	end process;
	
	-- LSB and raw are synchronized with the beat signal
	clk <= beat;

end architecture;

-- This architecture implements the RTL version of COSO measuring full period of beat signal with counter reset on beat signal rising edges.
architecture full of coso is

	signal beat: std_logic;
	signal counter: std_logic_vector (31 downto 0) := (others => '0');

begin

	-- Sample RO1 with RO2 to create the beat signal
	process (ro2)
	begin
		if rising_edge(ro2) then
			beat <= ro1;
		end if;
	end process;

	-- Count the ful period of the beat in steps of RO2
	process (ro2, beat)
	begin
		if rising_edge(beat) then
			counter <= (others => '0');
		elsif rising_edge(ro2) then
			counter <= counter + 1;
		end if;
	end process;

	-- Resample the LSB and the raw value of the counter
	process (beat)
	begin
		if rising_edge(beat) then
			lsb <= counter(0);
			raw <= counter;
		end if;
	end process;
	
	-- LSB and raw are synchronized with the beat signal
	clk <= beat;

end architecture;
