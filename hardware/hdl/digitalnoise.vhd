library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library opentrng;
use opentrng.settings.all;

-- The digital noise block generates the raw random numbers (RRN). This block contains the ring-oscillators, their sampling architecture and the clock domain crossing to the system clock in order the RRN to be used in the upper design.
entity digitalnoise is
	generic (
		-- Width for the configuration registers
		REG_WIDTH: natural;
		-- Width for the RRN output
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
		-- Clear the synchronizer data pipeline
		synchronizer_clear: in std_logic;
		-- Raw Random Number output data (RRN)
		data: out std_logic_vector (RAND_WIDTH-1 downto 0);
		-- RRN data output valid
		valid: out std_logic
	);
end entity;

-- RTL implementation of digital noise
architecture rtl of digitalnoise is

	-- Ring oscillators
	signal osc: std_logic_vector (T downto 0);
	signal mon: std_logic_vector (T downto 0);
	signal mon_en: std_logic_vector (T downto 0);
	signal selected_mon: std_logic;

	-- Digitizer
	signal digit_clk: std_logic;
	signal digit_data: std_logic_vector (RAND_WIDTH-1 downto 0);
	signal digit_valid: std_logic;
	
	-- CDC
	signal cdc_fifo_empty: std_logic;
	signal cdc_fifo_read: std_logic;
	signal cdc_fifo_data: std_logic_vector (RAND_WIDTH-1 downto 0);

begin

	-- Instantiate ring-oscillators from 0 to T with their respective frequency monitor enable
	bank: for I in 0 to T generate
	
		-- Each RO of the bank (or system clock bypass for tests)
		ring: entity opentrng.ring
		generic map (
			N => RO_LEN(I)
		)
		port map (
			enable => ring_en(I),
			osc => osc(I),
			mon_en => mon_en(I),
			mon => mon(I)
		);

		-- Enable for the RO monitoring output
		process (clk, reset)
		begin
			if reset = '1' then
				mon_en(I) <= '0';
			elsif rising_edge(clk) then
				if freqcount_select = I then
					mon_en(I) <= freqcount_en;
				else
					mon_en(I) <= '0';
				end if;
			end if;
		end process;
	end generate;

	-- One frequency counter for all ROs
	freqcounter: entity opentrng.freqcounter
	generic map (
		REG_WIDTH => REG_WIDTH,
		N => 10_000_000
	)
	port map (
		clk => clk,
		reset => reset,
		clear => clear,
		source => selected_mon,
		enable => freqcount_en,
		start => freqcount_start,
		done => freqcount_done,
		overflow => freqcount_overflow,
		result => freqcount_value
	);

	selected_mon <= mon(conv_integer(freqcount_select));

	-- Digitizer 
	digitizer: entity opentrng.digitizer
	generic map (
		REG_WIDTH => REG_WIDTH,
		RAND_WIDTH => RAND_WIDTH
	)
	port map (
		reset => reset,
		osc => osc,
		freqdivider_value => freqdivider_value,
		freqdivider_en => freqdivider_en,
		digit_clk => digit_clk,
		digit_data => digit_data,
		digit_valid => digit_valid
		
	);

	-- Clock domain crossing from osc(0) to system clock (clk)
	cdc: entity opentrng.synchronizer
	generic map (
		DATA_WIDTH => RAND_WIDTH
	)
	port map (
		reset => reset,
		clk_from => digit_clk,
		data_in => digit_data,
		data_in_en => digit_valid,
		clk_to => clk,
		clear => clear or synchronizer_clear,
		data_out => data,
		data_out_en => valid
	);

end architecture;
