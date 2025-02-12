library ieee;
use ieee.std_logic_1164.all;

-- This entity describes the Elementary based Ring Oscillator entropy source. The signal generated by RO0/div is used to sample RO1. The ERO output data is synchronized with the output clock 'clk'.
entity ero is
	generic (
		-- Width for the configuration registers
		REG_WIDTH: natural
	);
	port (
		-- Asynchronous reset
		reset: in std_logic;
		-- Sampling ring-oscillator input
		ro0: in std_logic;
		-- Sampled ring-oscillator input
		ro1: in std_logic;
		-- Clock division factor for the second ringo
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

-- This architecture implements the RTL version of ERO.
architecture rtl of ero is

	signal ro0_div: std_logic;

begin

	-- Divide RO0 clock by the divider factor
	clkdivider: entity opentrng.clkdivider
	generic map (
		FACTOR_WIDTH => 32
	)
	port map (
		reset => reset,
		original => ro0,
		factor => divider,
		changed => changed,
		divided => ro0_div
	);

	-- Sample RO1 with RO0/div
	process (ro0_div)
	begin
		if rising_edge(ro0_div) then
			data <= ro1;
		end if;
	end process;

	-- Output data is syncrhonized with this clock
	clk <= ro0_div;
	valid <= '1';

end architecture;
