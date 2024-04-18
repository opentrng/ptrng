library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- OpenTRNG's PTRNG base entity.
entity ptrng is
	generic (
		-- Width for the configuration registers
		REG_WIDTH: natural;
		-- Width for the random output
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
		freqcount_value: out std_logic_vector (REG_WIDTH-5-4-1 downto 0);
		-- Sampling clock divider (applies on RO0 for ERO and MURO)
		freqdivider: in std_logic_vector (REG_WIDTH-1 downto 0);
		-- Length of the entropy accumulator
		--accumulator: in std_logic_vector (31 downto 0);
		-- Enable the raw signal conditionner
		--conditioning: in std_logic;
		-- Total failure alarm
		--fail: out std_logic;
		-- Low entropy alarm
		--low: out std_logic;
		-- Entropy estimation
		--estimator: out std_logic_vector (31 downto 0);
		-- When 'packbits' is pulled to '1', LSB from IRN are packed into 32bits word before being outputed to 'data' port
		packbits: in std_logic;
		-- Random data output
		data: out std_logic_vector (RAND_WIDTH-1 downto 0);
		-- Random data output valid
		valid: out std_logic
	);
end entity;

-- RTL description of OpenTRNG's PTRNG
architecture rtl of ptrng is

	-- RRN from entropy source
	signal raw_random_number: std_logic_vector (RAND_WIDTH-1 downto 0);
	signal raw_random_valid: std_logic;

	-- IRN from entropy source
	signal intermediate_random_number: std_logic_vector (RAND_WIDTH-1 downto 0);
	signal intermediate_random_valid: std_logic;

	-- Packed data bits
	signal packed_data: std_logic_vector (RAND_WIDTH-1 downto 0);
	signal packed_valid: std_logic;

begin

	-- Digital noise source (no signal syncrhonized to rings outside of this block)
	source: entity work.digitalnoise
	generic map (
		REG_WIDTH => REG_WIDTH,
		RAND_WIDTH => RAND_WIDTH
	)
	port map (
		clk => clk,
		reset => reset,
		ring_en => ring_en,
		freqcount_en => freqcount_en,
		freqcount_select => freqcount_select,
		freqcount_start => freqcount_start,
		freqcount_done => freqcount_done,
		freqcount_overflow => freqcount_overflow,
		freqcount_value => freqcount_value,
		freqdivider => freqdivider,
		data => raw_random_number,
		valid => raw_random_valid
	);

	-- Total failure test
	-- TODO

	-- Online test
	-- TODO

	-- Conditioner
	-- TODO
	intermediate_random_number <= raw_random_number;
	intermediate_random_valid <= raw_random_valid;

	-- LSB packing into words
	bitpacker: entity work.bitpacker
	generic map (
		N => 5
	)
	port map (
		clk => clk,
		reset => reset,
		data_in => intermediate_random_number(0),
		valid_in => intermediate_random_valid,
		data_out => packed_data,
		valid_out => packed_valid
	);

	-- Output selection
	data <= intermediate_random_number when packbits = '0' else packed_data;
	valid <= intermediate_random_valid when packbits = '0' else packed_valid;

end architecture;
