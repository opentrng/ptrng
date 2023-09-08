library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- This entity describes the Elementary based Ring Oscillator entropy source. The clock of the second ringo is divided by the factor div and it samples the first ringo. The ERO has a data and a clock output (one data each clk rising edge).
entity ero is
	port (
		-- First ring oscillaor input
		ro1: in std_logic;
		-- Second ring oscillaor input
		ro2: in std_logic;
		-- Clock division factor for the second ringo
		div: in std_logic_vector (31 downto 0);
		-- Clock output (equal to ro2/div)
		clk: out std_logic;
		-- Entropy source data output
		data: out std_logic
	);
end entity;

-- This architecture implements the RTL version of ERO.
architecture rtl of ero is

	signal ro2_div: std_logic;
	--signal metastable: std_logic;
	--signal stable: std_logic;

begin

	-- Takes RO2 through the clock divider
	divider: entity work.divider(linear)
	generic map (
		MAX_WIDTH => 32
	)
	port map (
		original => ro2,
		factor => div,
		divided => ro2_div
	);

	-- Sample RO1 with RO2/div
	process (ro2_div)
	begin
		if rising_edge(ro2_div) then
			data <= ro1;
			--metastable <= ro1;
			--stable <= metastable;
			--data <= stable;
		end if;
	end process;

	-- Output data is syncrhonized with this clock
	clk <= ro2_div;

end architecture;
