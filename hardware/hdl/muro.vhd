library ieee;
use ieee.std_logic_1164.all;

-- This entity describes the Multi Ring Oscillator entropy source. The signal generated by RO0/div is used to sample each ROs from RO1 to ROt. The MURO output data is synchronized with the output clock 'clk'.
entity muro is
	generic (
		-- Number of ROs
		t: natural
	);
	port (
		-- Sampling ring-oscillator input
		ro0: in std_logic;
		-- Sampled ring-oscillators input
		rox: in std_logic_vector (t downto 1);
		-- Clock division factor for the second ringo
		div: in std_logic_vector (31 downto 0);
		-- Clock output (equal to ro0/div)
		clk: out std_logic;
		-- Entropy source data output
		data: out std_logic
	);
end entity;

-- This architecture implements the RTL version of the MURO.
architecture rtl of muro is

	signal ro0_div: std_logic := '0';
	signal sampled: std_logic_vector (t downto 1) := (others => '0');

begin

	-- Divide RO0 clock by the divider factor
	divider: entity work.clkdiv
	generic map (
		FACTOR_WIDTH => 32
	)
	port map (
		original => ro0,
		factor => div,
		divided => ro0_div
	);

	-- Sample RO1 with RO0/div
	process (ro0_div)
	begin
		if rising_edge(ro0_div) then
			sampled <= rox;
		end if;
	end process;

	-- Output data is syncrhonized with this clock
	clk <= ro0_div;
	data <= xor sampled;

end architecture;
