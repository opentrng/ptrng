library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Wrapper entity for top on target board Digilent Arty A7 35T.
entity target is
	port (
		-- Main oscillator at 100MHz
		CLK100MHZ: in std_logic;
		-- Poweron/switch reset
		ck_rst: in std_logic;
		-- UART to PC
		uart_rxd_out: out std_logic;
		-- UART from PC
		uart_txd_in: in std_logic;
		-- Debug header JA
		ja: out std_logic_vector (7 downto 0);
		-- Debug header JB
		jb: out std_logic_vector (7 downto 0)
	);
end;

-- RTL architecture of A7-35T top
architecture rtl of target is

	signal starter: std_logic_vector (7 downto 0) := (others => '0');
	signal hw_reset: std_logic;

begin

	-- Wrap the top
	top: entity work.top
	generic map (
		CLK_REF => 100_000_000
	)
	port map (
		clk	=> CLK100MHZ,
		hw_reset => hw_reset,
		uart_rxd => uart_rxd_out,
		uart_txd => uart_txd_in
	);

	-- Generate a poweron reset
	process (CLK100MHZ) is
	begin
		if rising_edge(CLK100MHZ) then
			if starter < 2**starter'Length-1 then
				starter <= starter + 1;
			end if;
		 	if starter = 16 then
		 		hw_reset <= '1';
		 	else
		 		hw_reset <= '0';
		 	end if;
		end if;
	end process;

	-- Placeholders
	ja <= (others => '0');
	jb <= (others => '0');

end;
