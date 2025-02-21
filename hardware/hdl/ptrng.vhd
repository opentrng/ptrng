library ieee;
use ieee.std_logic_1164.all;

library opentrng;
use opentrng.settings.all;

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
		-- Synchronous clear active to '1'
		clear: in std_logic;
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
		freqcount_value: out std_logic_vector (REG_WIDTH-1 downto 0);
		-- Sampling clock divider value (applies on RO0 for ERO and MURO)
		freqdivider_value: in std_logic_vector (REG_WIDTH-1 downto 0);
		-- Enable strobing when frequency divider changes
		freqdivider_en: in std_logic;
		-- Threshold for triggering the total failure alarm
		alarm_threshold: in std_logic_vector(REG_WIDTH-1 downto 0);
		-- Total failure alarm, risen to '1' when total failure event is detected
		alarm_detected: out std_logic;
		-- Clear-to-set the online test
		onlinetest_clear: in std_logic;
		-- Expected average value for online test
		onlinetest_average: in std_logic_vector (REG_WIDTH/2-1 downto 0);
		-- Maximum deviation to expected value for online test to be valid
		onlinetest_deviation: in std_logic_vector (REG_WIDTH/2-1 downto 0);
		-- Set to '1' when the online test is valid (need to be cleared)
		onlinetest_valid: out std_logic;
		-- Enable the raw signal conditionner
		conditioning: in std_logic;
		-- When 'nopacking' is pulled to '1', IRN as written as entire words in FIFO instead of packing only LSB bits
		nopacking: in std_logic;
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
	signal conditioned_number: std_logic_vector (RAND_WIDTH-1 downto 0);
	signal conditioned_valid: std_logic;
	signal intermediate_random_number: std_logic_vector (RAND_WIDTH-1 downto 0);
	signal intermediate_random_valid: std_logic;

	-- Packed data bits
	signal packed_data: std_logic_vector (RAND_WIDTH-1 downto 0);
	signal packed_valid: std_logic;

begin

	-- Digital noise source (no signal syncrhonized to rings outside of this block)
	source: entity opentrng.digitalnoise
	generic map (
		REG_WIDTH => REG_WIDTH,
		RAND_WIDTH => RAND_WIDTH
	)
	port map (
		clk => clk,
		reset => reset,
		clear => clear,
		ring_en => ring_en,
		freqcount_en => freqcount_en,
		freqcount_select => freqcount_select,
		freqcount_start => freqcount_start,
		freqcount_done => freqcount_done,
		freqcount_overflow => freqcount_overflow,
		freqcount_value => freqcount_value,
		freqdivider_value => freqdivider_value,
		freqdivider_en => freqdivider_en,
		data => raw_random_number,
		valid => raw_random_valid
	);

	-- Total failure alarm
	alarm: entity opentrng.alarm
	generic map (
		REG_WIDTH => REG_WIDTH,
		RAND_WIDTH => RAND_WIDTH
	)
	port map (
		clk => clk,
		reset => reset,
		clear => clear,
		digitizer => DIGITIZER_GEN,
		raw_random_number => raw_random_number,
		raw_random_valid => raw_random_valid,
		threshold => alarm_threshold,
		detected => alarm_detected
	);

	-- Online test
	onlinetest: entity opentrng.onlinetest
	generic map (
		REG_WIDTH => REG_WIDTH,
		RAND_WIDTH => RAND_WIDTH,
		DEPTH => 64
	)
	port map (
		clk => clk,
		reset => reset,
		clear => clear or onlinetest_clear,
		raw_random_number => raw_random_number,
		raw_random_valid => raw_random_valid,
		average => onlinetest_average,
		deviation => onlinetest_deviation,
		valid => onlinetest_valid
	);

	-- Conditioning refers to algorithmic post-processing
	conditioner: entity opentrng.conditioner
	generic map (
		RAND_WIDTH => RAND_WIDTH
	)
	port map (
		clk => clk,
		reset => reset,
		clear => clear,
		enable => conditioning,
		raw_random_number => raw_random_number,
		raw_random_valid => raw_random_valid,
		conditioned_number => conditioned_number,
		conditioned_valid => conditioned_valid
	);

	-- Data to bypass the conditioner if disabled
	process (clk)
	begin
		if rising_edge(clk) then
			if conditioning = '1' then
				intermediate_random_number <=  conditioned_number;
			else
				intermediate_random_number <= raw_random_number;
			end if;
		end if;
	end process;
	
	-- Valid signal to bypass the conditioner if disabled
	process (clk, reset)
	begin
		if reset = '1' then
			intermediate_random_valid <= '0';
		elsif rising_edge(clk) then
			if clear = '1' then
				intermediate_random_valid <= '0';
			else
				if conditioning = '1' then
					intermediate_random_valid <= conditioned_valid;
				else
					intermediate_random_valid <= raw_random_valid;
				end if;
			end if;
		end if;
	end process;

	-- LSB packing into words
	bitpacker: entity opentrng.bitpacker
	generic map (
		W => REG_WIDTH
	)
	port map (
		clk => clk,
		reset => reset,
		clear => clear or nopacking,
		data_in => intermediate_random_number(0),
		valid_in => intermediate_random_valid,
		data_out => packed_data,
		valid_out => packed_valid
	);

	-- Data output selection
	process (clk)
	begin
		if rising_edge(clk) then
			if nopacking = '1' then
				data <= intermediate_random_number;
			else
				data <=  packed_data;
			end if;
		end if;
	end process;
	
	-- Valid output selection
	process (clk, reset)
	begin
		if reset = '1' then
			valid <= '0';
		elsif rising_edge(clk) then
			if clear = '1' then
				valid <= '0';
			else
				if nopacking = '1' then
					valid <= intermediate_random_valid;
				else
					valid <= packed_valid;
				end if;
			end if;
		end if;
	end process;

end architecture;
