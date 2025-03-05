library ieee;
use ieee.std_logic_1164.all;

library opentrng;

-- This entity describes the Multi Ring Oscillator entropy source. The signal generated by RO0/div is used to sample each ROs from RO1 to ROt. The MURO output data is synchronized with the output clock 'clk'.
entity muro is
	generic (
		-- Width for the configuration registers
		REG_WIDTH: natural;
		-- Number of ROs
		t: natural
	);
	port (
		-- Asynchronous reset
		reset: in std_logic;
		-- Sampling ring-oscillator input
		ro0: in std_logic;
		-- Sampled ring-oscillators input
		rox: in std_logic_vector (t downto 1);
		-- Clock division factor for the sampling ringo
		divider: in std_logic_vector (REG_WIDTH-1 downto 0);
		-- Enable strobed when divider value changes
		changed: in std_logic;
		-- Clock output (equal to ro0/div)
		clk: out std_logic;
		-- Entropy source data output
		data: out std_logic;
		-- Valid signal for 'data'
		valid: out std_logic
	);
end entity;

-- This architecture implements the RTL version of the MURO.
architecture rtl of muro is

	signal ro0_div: std_logic := '0';
	signal sampled: std_logic_vector (t downto 1);

begin

	-- Divide RO0 clock by the divider factor
	clkdivider: entity opentrng.clkdivider
	generic map (
		FACTOR_WIDTH => 32
	)
	port map (
		reset => reset,
		original => ro0,
		divider => divider,
		changed => changed,
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
	valid <= '1';

end architecture;
