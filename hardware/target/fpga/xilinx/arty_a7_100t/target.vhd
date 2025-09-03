library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.settings.all;

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
		jb: in std_logic_vector (7 downto 0)
	);
end;

-- RTL architecture of A7-35T top
architecture rtl of target is

	signal clk: std_logic;
	signal debounce: std_logic_vector (31 downto 0);
	signal hw_reset: std_logic;

begin

	-- System clock source
	source: if SYSCLK_VCO = True generate
		clk <= CLK100MHZ;
	else generate
		clk <= jb(2);
	end generate;

	-- Wrap the top
	top: entity work.top
	generic map (
		CLK_REF => SYSCLK_FREQ,
		FIFO_SIZE => 512*64,
		BURST_SIZE => 512
	)
	port map (
		clk	=> clk,
		hw_reset => hw_reset,
		uart_rxd => uart_rxd_out,
		uart_txd => uart_txd_in
	);

	-- Generate a poweron reset
	process (clk, ck_rst) is
	begin
		if ck_rst = '0' then
			debounce <= (others => '0');
			hw_reset <= '1';
		elsif rising_edge(clk) then
			if debounce <= 10_000 then
				debounce <= debounce + 1;
				hw_reset <= '1';
			else
				hw_reset <= '0';
			end if;
		end if;
	end process;

	-- Output stubs
	ja <= (others => '0');

end;
