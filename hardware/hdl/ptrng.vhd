library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- OpenTRNG's PTRNG base entity.
entity ptrng is
	generic (
		-- Size of the configuration registers
		REG_WIDTH: natural;
		-- Output width for the randomness
		RAND_WIDTH: natural
	);
	port (
		-- Base clock
		clk: in std_logic;
		-- Asynchronous reset active to '1'
		reset: in std_logic;
		-- Ring-oscillator enable signal (bit index i enables ROi)
		ring_en: in std_logic_vector (REG_WIDTH-1 downto 0);
		-- Enable the all the frequency counters
		freqcount_en: in std_logic;
		-- Select the RO number for frequency measurement
		freqcount_select: in std_logic_vector (4 downto 0);
		-- Pulse '1' to start the frequency measure (for the selected ROs)
		freqcount_start: in std_logic;
		-- Flag set to '1' when the result is ready (for the selected ROs)
		freqcount_done: out std_logic;
		-- Flag set to '1' if an overflow occured (for the selected ROs)
		freqcount_overflow: out std_logic;
		-- Frequency estimation output (for the selected ROs)
		freqcount_result: out std_logic_vector (REG_WIDTH-5-4-1 downto 0);
		-- Sampling clock divider (applies on RO0 for ERO and MURO)
		divider: in std_logic_vector (REG_WIDTH-1 downto 0);
		-- Lenght of the entropy accumulator
		--accumulator: in std_logic_vector (31 downto 0);
		-- Enable the raw signal conditionner
		--conditioning: in std_logic;
		-- Total failure alarm
		--fail: out std_logic;
		-- Low entropy alarm
		--low: out std_logic;
		-- Entropy estimation
		--estimator: out std_logic_vector (31 downto 0);
		-- Entropy source randomness output
		--data: out std_logic_vector (DATA_WIDTH-1 downto 0);
		-- Output valid (active when a new random word is available on 'data' port)
		valid: out std_logic
	);
end entity;

-- RTL description of OpenTRNG's PTRNG
architecture rtl of ptrng is

	-- Digital noise source (no signal syncrhonized to rings outside of this block)
	source: entity work.digitalnoise
	generic map (
		REG_WIDTH => REG_WIDTH
	)
	port map (
		clk => clk,
		reset => reset,
		ring_en => ring_en,
		freq_en => freq_en,
		freq_start => freq_start,
		freq_done => freq_done,
		freq_overflow => freq_overflow,
		freq_result => freq_result
	);

	-- TOTAL FAILURE

	-- ONLINE TESTS

	-- CONDITIONER

end architecture;
