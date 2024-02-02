library ieee;
use ieee.std_logic_1164.all;

-- Wrapper entity for top on target board Digilent Arty A7 35T.
entity supertop is
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
architecture rtl of supertop is
begin

	-- Wrap the top
	top: entity work.top
	generic map (
		CLK_REF => 100_000_000
	)
	port map (
		clk	=> CLK100MHZ,
		hw_reset => ck_rst,
		uart_rxd => uart_rxd_out,
		uart_txd => uart_txd_in
	);

end;
