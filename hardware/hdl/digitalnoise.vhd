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
	signal mon_en: std_logic_vector (T downto 0);
	signal mon_osc: std_logic_vector (T downto 0);

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
			mon_en => mon_en(I),
			mon_osc => mon_osc(I)
		);

		-- Enable for the RO monitoring output
		process (clk, reset)
		begin
			if reset = '1' then
				mon_en(I) <= '0';
			elsif rising_edge(clk) then
				if freq_select = I then
					mon_en(I) <= freq_en;
				else
					mon_en(I) <= '0';
				end if;
			end if;
		end process;
	end generate;

	-- One frequency counter for all ROs
	freq: entity work.freqcounter
	generic map (
		W => freq_value'Length,
		N => 1_000_000
	)
	port map (
		clk => clk,
		reset => reset,
		source => mon_osc(conv_integer(freq_select)),
		enable => freq_en,
		start => freq_start,
		done => freq_done,
		overflow => freq_overflow,
		result => freq_value
	);

	-- Sampling

	-- CDC

end architecture;
