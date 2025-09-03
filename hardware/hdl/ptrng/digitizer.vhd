library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.constants.all;
use work.settings.all;

-- The digitizer takes the ring-oscillator signals as input and instanciante the sampling architecture specified in 'settings.vhd'. It outputs the sampling clock and the sampled data.
entity digitizer is
	generic (
		-- Width for the configuration registers
		REG_WIDTH: natural;
		-- Width for the RRN output
		RAND_WIDTH: natural
	);
	port (
		-- Asynchronous reset
		reset: in std_logic;
		-- Synchronous clear active to '1'
		clear: in std_logic;
		-- Ring-oscillator inputs
		osc: in std_logic_vector (T downto 0);
		-- Sampling clock divider value (applies on RO0 for ERO and MURO)
		freqdivider_value: in std_logic_vector (REG_WIDTH-1 downto 0);
		-- Enable strobing when frequency divider changes
		freqdivider_en: in std_logic;
		-- Sampling clock (osc(0))
		digit_clk: out std_logic;
		-- Sampled data
		digit_data: out std_logic_vector (RAND_WIDTH-1 downto 0);
		-- Valid signal for 'digit_data'
		digit_valid: out std_logic
	);
end entity;

-- RTL implementation of the digitizer
architecture rtl of digitizer is
begin

	-- TEST digitizer is a 32bit counter clocked at osc(0)/freqdivider
	gen: if DIGITIZER_GEN = TEST generate
		signal counter: std_logic_vector (RAND_WIDTH-1 downto 0) := (others => '0');
	begin
		clkdivider: entity work.clkdivider
		generic map (
			FACTOR_WIDTH => 32
		)
		port map (
			reset => reset,
			original => osc(0),
			divider => freqdivider_value,
			changed => freqdivider_en,
			divided => digit_clk
		);
		process (reset, clear, digit_clk)
		begin
			if reset = '1' or clear = '1' then
				counter <= (others => '0');
			elsif rising_edge(digit_clk) then
				counter <= counter + 1;
			end if;
		end process;
		digit_data <= counter;
		digit_valid <= '1';

	-- Instantiate the ERO
	elsif DIGITIZER_GEN = ERO generate
		ero: entity work.ero
		generic map (
			REG_WIDTH => REG_WIDTH
		)
		port map (
			reset => reset,
			ro0 => osc(0),
			ro1 => osc(1),
			divider => freqdivider_value,
			changed => freqdivider_en,
			clk => digit_clk,
			data => digit_data(0),
			valid => digit_valid
		);

	-- Instantiate the MURO
	elsif DIGITIZER_GEN = MURO generate
		muro: entity work.muro
		generic map (
			REG_WIDTH => REG_WIDTH,
			t => T
		)
		port map (
			reset => reset,
			ro0 => osc(0),
			rox => osc(T downto 1),
			divider => freqdivider_value,
			changed => freqdivider_en,
			clk => digit_clk,
			data => digit_data(0),
			valid => digit_valid
		);

	-- Instantiate the COSO
	elsif DIGITIZER_GEN = COSO generate
		coso: entity work.coso
		generic map (
			DATA_WIDTH => 16
		)
		port map (
			ro0 => osc(0),
			ro1 => osc(1),
			clk => digit_clk,
			data => digit_data(15 downto 0),
			valid => digit_valid
		);
		
		digit_data(RAND_WIDTH-1 downto 16) <= (others => '0');

	-- Stub for inactive digitizer
	else generate
		digit_clk <= '0';
		digit_data <= (others => '0');
		digit_valid <= '0';
	end generate;

end architecture;
