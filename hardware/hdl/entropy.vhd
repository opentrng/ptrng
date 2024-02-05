library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.settings.all;

-- OpenTRNG entropy base entity.
entity entropy is
	generic (
		-- Width of the source output randomness
		DATA_WIDTH: natural := 32
	);
	port (
		-- Base clock
		clk: in std_logic;
		-- Asynchronous reset active to '1'
		reset: in std_logic;
		-- Ring-oscillator enable signal
		ring_enable: in std_logic_vector (31 downto 0);
		freqcount_en: in std_logic;
		freqcount_select: in std_logic_vector (4 downto 0);
		freqcount_start: in std_logic;
		freqcount_done: out std_logic;
		freqcount_overflow: out std_logic;
		freqcount_result: out std_logic_vector (22 downto 0)
		-- Sampling clock divider (applies on RO0)
		--divider: in std_logic_vector (31 downto 0);
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
		--valid: out std_logic
	);
end entity;

-- RTL description of OpenTRNG entropy source
architecture rtl of entropy is

	signal ro: std_logic_vector (T downto 0);
	signal monitor: std_logic_vector (T downto 0);

begin

	-- Instantiate ring-oscillators from 0 to T
	osc: for I in 0 to T generate
		ring: entity work.ring
		generic map (
			LEN => RO_LEN(I)
		)
		port map (
			enable => ring_enable(I),
			osc => ro(I),
			mon => monitor(I)
		);
	end generate;

	-- Frequency counters
	freq: entity work.freqcounter
	generic map (
		W => freqcount_result'Length,
		N => 1_000_000
	)
	port map (
		clk => clk,
		reset => reset,
		source => monitor(conv_integer(freqcount_select)),
		enable => freqcount_en,
		start => freqcount_start,
		done => freqcount_done,
		overflow => freqcount_overflow,
		result => freqcount_result
	);

	-- SOURCE ero/muro/coso

	-- CDC

	-- TOTAL FAILURE

	-- ONLINE TESTS

	-- CONDITIONER

end architecture;
