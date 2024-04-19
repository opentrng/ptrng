library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.settings.all;

library extras;
use extras.synchronizing.all;

-- The digitizer takes the ring-oscillator signals as input and instanciante the sampling architecture specified in 'settings.vhd'. It outputs the sampling clock and the sampled data.
entity digitizer is
	generic (
		-- Width for the configuration registers
		REG_WIDTH: natural;
		-- Width for the RRN output
		RAND_WIDTH: natural
	);
	port (
		-- Ring-oscillator inputs
		osc: in std_logic_vector (T downto 0);
		-- Sampling clock divider (applies on RO0 for ERO and MURO)
		freqdivider: in std_logic_vector (REG_WIDTH-1 downto 0);
		-- Sampling clock (osc(0))
		digit_clk: out std_logic;
		-- Sampled data
		digit_data: out std_logic_vector (RAND_WIDTH-1 downto 0)
	);
end entity;

-- RTL implementation of the digitizer
architecture rtl of digitizer is
begin

	-- TEST digitizer is a 32bit counter clocked at osc(0)/freqdivider
	gen: if DIGITIZER_GEN = TEST generate
		signal counter: std_logic_vector (RAND_WIDTH-1 downto 0);
	begin
		process (osc(0))
		begin
			if rising_edge(osc(0)) then
				if counter < freqdivider-1 then
					counter <= counter + 1;
					digit_clk <= '0';
				else
					counter <= (others => '0');
					digit_data <= digit_data + 1;
					digit_clk <= '1';
				end if;
			end if;
		end process;

	-- Instantiate the ERO
	elsif DIGITIZER_GEN = ERO generate
		ero: entity work.ero
		port map (
			ro0 => osc(0),
			ro1 => osc(1),
			div => freqdivider,
			clk => digit_clk,
			data => digit_data(0)
		);

	-- Instantiate the MURO
	elsif DIGITIZER_GEN = MURO generate
		muro: entity work.muro
		generic map (
			t => T
		)
		port map (
			ro0 => osc(0),
			rox => osc(T downto 1),
			div => freqdivider,
			clk => digit_clk,
			data => digit_data(0)
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
			data => digit_data(15 downto 0)
		);

	-- Stub for inactive digitizer
	else generate
		digit_clk <= '0';
		digit_data <= (others => '0');
	end generate;

end architecture;
