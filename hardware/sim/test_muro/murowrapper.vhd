library ieee;
use ieee.std_logic_1164.all;

-- The MURO wrapper converts the std_logic_vector input ports for RO1-ROt to an entity with t=5 RO inputs (RO0-RO5).
entity murowrapper is
	generic (
		t: integer := 5
	);
	port (
		ro0: in std_logic;
		ro1: in std_logic;
		ro2: in std_logic;
		ro3: in std_logic;
		ro4: in std_logic;
		ro5: in std_logic;
		div: in std_logic_vector (31 downto 0);
		clk: out std_logic;
		data: out std_logic
	);
end entity;

-- This architecture implements the RTL version of MURO's wrapper.
architecture rtl of murowrapper is

	signal rox: std_logic_vector (t downto 1);

begin

	-- Compose the input vector for RO1 to ROT
	rox <= ro5 & ro4 & ro3 & ro2 & ro1;

	-- Wrapping the MURO with fixed generic
	wrapped: entity work.muro
	generic map (
		t => t
	)
	port map (
		ro0 => ro0,
		rox => rox,
		div => div,
		clk => clk,
		data => data
	);

end architecture;
