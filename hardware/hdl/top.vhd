library ieee;
use ieee.std_logic_1164.all;

entity top is
	generic (
		CLK_REF: natural
	);
	port (
		clk: in std_logic;
		hwreset: in std_logic;
		uart_txd: in std_logic;
		uart_rxd: out std_logic
	);
end;

-- 
architecture rtl of top is

	-- UART interface
	signal tx_data: std_logic_vector (7 downto 0);
	signal tx_req: std_logic;
	signal tx_busy: std_logic;
	signal rx_data: std_logic_vector (7 downto 0);
	signal rx_data_valid: std_logic;
	signal rx_brk: std_logic;
	signal rx_err: std_logic;

	-- Command processor
	signal rd_data: std_logic_vector (31 downto 0);
	signal wr_data: std_logic_vector (31 downto 0);
	signal address: std_logic_vector (15 downto 0);
	signal read_req: std_logic;
	signal write_req: std_logic;

	-- Registers
	signal reset: std_logic;
	signal ring_enable: std_logic_vector (31 downto 0);
	signal freqcount_en: std_logic;
	signal freqcount_start: std_logic;
	signal freqcount_done: std_logic;
	signal freqcount_overflow: std_logic;
	signal freqcount_select: std_logic_vector (4 downto 0);
	signal freqcount_result: std_logic_vector (23 downto 0)

begin

	-- UART
	cmd_uart: entity work.fluart
	generic map(
		CLK_FREQ => CLK_REF,
		SER_FREQ => 115_200,
		BRK_LEN => 10
	)
	port map (
		clk	=> clk,
		reset => hwreset,
		txd	=> uart_txd,
		rxd	=> uart_rxd,
		tx_data => tx_data,
		tx_req => tx_req,
		tx_busy => tx_busy,
		rx_data => rx_data,
		rx_data_valid => rx_data_valid,
		rx_brk => rx_brk,
		rx_err => rx_err
	);

	-- Command processor
	cmd_proc: entity work.cmd_proc
	generic map (
		ADDR_SIZE => 16,
		DATA_SIZE => 32
	)
	port map (
		clk => clk,
		reset => hwreset or rx_brk or rx_err,
		rx_data => rx_data,
		rx_data_valid => rx_data_valid,
		tx_data => tx_data,
		tx_req => tx_req,
		tx_busy => tx_busy,
		address => address,
		rd_data => rd_data,
		wr_data => wr_data,
		read_req => read_req,
		write_req => write_req
	);

	-- Register map
	registers: entity work.registers
	generic map (
		ADDR_W => 16,
		DATA_W => 32,
		STRB_W => 4
	)
	port map (
		clk => clk,
		rst => hwreset,

		-- Local Bus
		waddr => address,--  : in  std_logic_vector(ADDR_W-1 downto 0);
		wdata => wr_data,--  : in  std_logic_vector(DATA_W-1 downto 0);
		wen => write_req,--    : in  std_logic;
		wstrb => "1111",--  : in  std_logic_vector(STRB_W-1 downto 0);
		--wready : out std_logic;
		raddr => address,--  : in  std_logic_vector(ADDR_W-1 downto 0);
		ren => read_req,--    : in  std_logic;
		rdata => rd_data,--  : out std_logic_vector(DATA_W-1 downto 0);
		--rvalid : out std_logic;

		csr_global_reset_out => reset,
		csr_ring_enable_out => ring_enable,
		csr_freqcount_en_out => freqcount_en,
		csr_freqcount_start_out => freqcount_start,
		csr_freqcount_done_in => freqcount_done,
		csr_freqcount_select_out => freqcount_select,
		csr_freqcount_result_in => freqcount_result,
		csr_freqcount_overflow_in => freqcount_overflow
	);

	-- ENTROPY
	entropy: entity work.entropy
	generic map (
		DATA_WIDTH => 32
	)
	port map (
		clk => clk,
		rst => hwreset,
		reset => reset,
		enable => enable,
		freqcount_en => freqcount_en,
		freqcount_select => freqcount_select,
		freqcount_start => freqcount_start,
		freqcount_done => freqcount_done,
		freqcount_overflow => freqcount_overflow,
		freqcount_result => freqcount_result
	);

	-- FIFO

end architecture;
