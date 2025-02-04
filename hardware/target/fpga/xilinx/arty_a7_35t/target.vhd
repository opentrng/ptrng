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

	signal debounce: std_logic_vector (31 downto 0);
	signal hw_reset: std_logic;

begin

	-- Wrap the top
	top: entity work.top
	generic map (
		CLK_REF => 100_000_000,
		FIFO_SIZE => 512*64,
		BURST_SIZE => 512
	)
	port map (
		clk	=> CLK100MHZ,
		hw_reset => hw_reset,
		uart_rxd => uart_rxd_out,
		uart_txd => uart_txd_in
	);

	-- Generate a poweron reset
	process (CLK100MHZ, ck_rst) is
	begin
		if ck_rst = '0' then
			debounce <= (others => '0');
			hw_reset <= '1';
		elsif rising_edge(CLK100MHZ) then
		 	if debounce <= 10_000 then
		 		debounce <= debounce + 1;
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
