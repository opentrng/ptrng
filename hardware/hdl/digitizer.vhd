library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.settings.all;

library extras;
use extras.synchronizing.all;

-- The digitizer takes the ring-oscillator signals as input and instanciante the sampling architecture specified in 'settings.vhd'. It outputs the sampling clock and the sampled data.
entity digitizer is
	generic (
		-- Width for the RRN output
		RAND_WIDTH: natural
	);
	port (
		-- Ring-oscillator inputs
		osc: std_logic_vector (T downto 0);
		-- Sampling clock (osc(0))
		digit_clk: out std_logic;
		-- Sampled data
		digit_data: out std_logic_vector (RAND_WIDTH-1 downto 0)
	);
end entity;

-- RTL implementation of the digitizer
architecture rtl of digitizer is
begin

	-- TEST digitizer is a 32bit counter clocked at osc(0)/2^(25+1)
	gen: if DIGITIZER_GEN = TEST generate
		signal clkdiv: std_logic_vector (31 downto 0);
		signal counter: std_logic_vector (RAND_WIDTH-1 downto 0);
	begin
		process (osc(0))
		begin
			if rising_edge(osc(0)) then
				clkdiv <= clkdiv + 1;
			end if;
		end process;
		digit_clk <= clkdiv(25);
		process (digit_clk)
		begin
			if rising_edge(clkdiv(25)) then
				digit_data <= digit_data + 1;
			end if;
		end process;

	-- Instanciate the ERO
	elsif DIGITIZER_GEN = ERO generate
		digit_clk <= '0';
		digit_data <= (others => '0');

	-- Instanciate the MURO
	elsif DIGITIZER_GEN = MURO generate
		digit_clk <= '0';
		digit_data <= (others => '0');

	-- Instanciate the COSO
	elsif DIGITIZER_GEN = COSO generate
		coso: entity work.coso
		generic map (
			DATA_WIDTH => 16
		)
		port map (
			ro0 => osc(0),
			ro1 => osc(1),
			clk => digit_clk,
			data => digit_data(15 downto 0)
		);

	-- Stub for inactive digitizer
	else generate
		digit_clk <= '0';
		digit_data <= (others => '0');
	end generate;

end architecture;
