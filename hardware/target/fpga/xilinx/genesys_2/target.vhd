library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.settings.all;

library UNISIM;
use UNISIM.vcomponents.all;

-- Wrapper entity for top on target board Digilent Genesys 2 (xc7k325tffg900-2).
entity target is
	port (
		-- Main oscillator at 200MHz (diff neg)
		sysclk_n: in std_logic;
		-- Main oscillator at 200MHz (diff pos)
		sysclk_p: in std_logic;
		-- Poweron/switch reset
		cpu_resetn: in std_logic;
		-- UART to PC
		uart_rx_out: out std_logic;
		-- UART from PC
		uart_tx_in: in std_logic;
		-- Debug header JA
		ja: out std_logic_vector (7 downto 0);
		-- Debug header JB
		jb: in std_logic_vector (7 downto 0)
	);
end;

-- RTL architecture of Genesys 2 top
architecture rtl of target is

	signal sysclk: std_logic;
	signal clk: std_logic;
	signal debounce: std_logic_vector (31 downto 0);
	signal hw_reset: std_logic;

begin

	-- Differential clock input
	IBUFDS_inst : IBUFDS
	generic map (
	   DIFF_TERM => FALSE, -- Differential Termination
	   IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
	   IOSTANDARD => "DEFAULT")
	port map (
	   I => sysclk_p,  -- Diff_p buffer input (connect directly to top-level port)
	   IB => sysclk_n, -- Diff_n buffer input (connect directly to top-level port)
	   O => sysclk     -- Buffer output
	);

	-- System clock source
	source: if SYSCLK_VCO = True generate
		clk <= sysclk;
	else generate
		clk <= jb(2);
	end generate;

	-- Wrap the top
	top: entity work.top
	generic map (
		CLK_REF => 200_000_000,
		FIFO_SIZE => 512*64,
		BURST_SIZE => 512
	)
	port map (
		clk	=> clk,
		hw_reset => hw_reset,
		uart_rxd => uart_rx_out,
		uart_txd => uart_tx_in
	);

	-- Generate a poweron reset
	process (clk, cpu_resetn) is
	begin
		if cpu_resetn = '0' then
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
