library ieee;
use ieee.std_logic_1164.all;

-- 
entity murowrapper is
	generic (
		T: integer := 6
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

-- 
architecture rtl of murowrapper is

	signal rox: std_logic_vector (T-1 downto 1);

begin

	rox <= ro5 & ro4 & ro3 & ro2 & ro1;

	wrapped: entity work.muro
	generic map (
		T => T
	)
	port map (
		ro0 => ro0,
		rox => rox,
		div => div,
		clk => clk,
		data => data
	);

end architecture;
