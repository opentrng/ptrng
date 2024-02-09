library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.settings.all;

-- 
entity digitalnoise is
	generic (
		-- Size of the configuration registers
		REG_WIDTH: natural
	);
	port (
		-- Base clock
		clk: in std_logic;
		-- Asynchronous reset active to '1'
		reset: in std_logic;
		-- Ring-oscillator enable signal (bit index i enables ROi)
		ring_en: in std_logic_vector (REG_WIDTH-1 downto 0);
		-- Enable the all the frequency counters
		freq_en: in std_logic;
		-- Select the RO number for frequency measurement
		freq_select: in std_logic_vector (4 downto 0);
		-- Pulse '1' to start the frequency measure (for the selected ROs)
		freq_start: in std_logic;
		-- Flag set to '1' when the result is ready (for the selected ROs)
		freq_done: out std_logic;
		-- Flag set to '1' if an overflow occured (for the selected ROs)
		freq_overflow: out std_logic;
		-- Frequency estimation output (for the selected ROs)
		freq_value: out std_logic_vector (REG_WIDTH-5-4-1 downto 0);
		-- Sampling clock divider (applies on RO0 for ERO and MURO)
		divider: in std_logic_vector (REG_WIDTH-1 downto 0)
	);
end entity;

-- 
architecture rtl of digitalnoise is

	signal osc: std_logic_vector (T downto 0);
	signal mon: std_logic_vector (T downto 0);
	signal done: std_logic_vector (T downto 0);
	signal overflow: std_logic_vector (T downto 0);
	type array_of_values is array (0 to T) of std_logic_vector (freq_value'Length-1 downto 0); 
	signal value: array_of_values;

begin

	-- Instantiate ring-oscillators from 0 to T and their respective frequency counter
	bank: for I in 0 to T generate

		-- Each RO of the bank
		ring: entity work.ring
		generic map (
			N => RO_LEN(I)
		)
		port map (
			enable => ring_en(I),
			osc => osc(I),
			mon => mon(I)
		);

		-- One frequency counter per RO
		freq: entity work.freqcounter
		generic map (
			W => freq_value'Length,
			N => 1_000_000
		)
		port map (
			clk => clk,
			reset => reset,
			source => mon(I),
			enable => freq_en,
			start => freq_start and ring_en(conv_integer(freq_select)),
			done => done(I),
			overflow => overflow(I),
			result => value(I)
		);

	end generate;

	-- Registering the frequency counter output multiplexer
	process (clk, reset)
	begin
		if reset = '1' then
			freq_done <= '0';
			freq_overflow <= '0';
		elsif rising_edge(clk) then
			if freq_en = '1' then
				freq_done <= done(conv_integer(freq_select));
				freq_value <= value(conv_integer(freq_select));
				freq_overflow <= overflow(conv_integer(freq_select));
			else
				freq_done <= '0';
				freq_overflow <= '0';
			end if;
		end if;
	end process;

	-- Sampling

	-- CDC

end architecture;
