library ieee;
use ieee.std_logic_1164.all;

library extras;
use extras.fifos.all;

-- Top for testing the PTRNG by writing configuration registers and reading data into a FIFO through an UART.
entity top is
	generic (
		CLK_REF: natural
	);
	port (
		clk: in std_logic;
		hw_reset: in std_logic;
		uart_txd: in std_logic;
		uart_rxd: out std_logic
	);
end;

-- RTL implementation of the FPGA test top
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

	-- Register map
	signal sw_reset: std_logic;
	signal ring_en: std_logic_vector (31 downto 0);
	signal freqcount_en: std_logic;
	signal freqcount_start: std_logic;
	signal freqcount_done: std_logic;
	signal freqcount_overflow: std_logic;
	signal freqcount_select: std_logic_vector (4 downto 0);
	signal freqcount_value: std_logic_vector (22 downto 0);
	signal freqdivider: std_logic_vector (31 downto 0);

	-- FIFO
	constant FIFO_SIZE: natural := 256;
	constant FIFO_SAFE: natural := 32;
	constant FIFO_ALMOSTEMPTY: natural := FIFO_SAFE;
	constant FIFO_ALMOSTFULL: natural := FIFO_SIZE-FIFO_SAFE;
	signal fifo_reset: std_logic;
	signal fifo_clear: std_logic;
	signal fifo_empty: std_logic;
	signal fifo_full: std_logic;
	signal fifo_almost_empty: std_logic;
	signal fifo_almost_full: std_logic;
	signal fifo_read_en: std_logic;
	signal fifo_read_valid: std_logic;
	signal fifo_write_en: std_logic;
	signal fifo_data_read: std_logic_vector (31 downto 0);
	signal fifo_data_write: std_logic_vector (31 downto 0);

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
		reset => hw_reset,
		txd	=> uart_rxd,
		rxd	=> uart_txd,
		tx_data => tx_data,
		tx_req => tx_req,
		tx_brk => '0',
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
		reset => hw_reset or rx_brk or rx_err,
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
	regmap: entity work.regmap
	port map (
		clk => clk,
		rst => hw_reset,

		-- Local Bus
		waddr => address,
		wdata => wr_data,
		wen => write_req,
		wstrb => "1111",
		--wready
		raddr => address,
		ren => read_req,
		rdata => rd_data,
		--rvalid

		-- Registers for the user
		csr_control_reset_out => sw_reset,
		csr_ring_en_out => ring_en,
		csr_freqcount_en_out => freqcount_en,
		csr_freqcount_start_out => freqcount_start,
		csr_freqcount_done_in => freqcount_done,
		csr_freqcount_select_out => freqcount_select,
		csr_freqcount_value_in => freqcount_value,
		csr_freqcount_overflow_in => freqcount_overflow,
		csr_freqdivider_value_out => freqdivider,
		csr_fifoctrl_clear_out => fifo_clear,
	    csr_fifoctrl_empty_in => fifo_empty,
	    csr_fifoctrl_full_in => fifo_full,
	    csr_fifoctrl_almostempty_in => fifo_almost_empty,
	    csr_fifoctrl_almostfull_in => fifo_almost_full,
		csr_fifodata_data_rvalid => fifo_read_valid,
		csr_fifodata_data_ren => fifo_read_en,
		csr_fifodata_data_in => fifo_data_read
	);

	-- Physical True Random Number Generator wrapped on the register map
	ptrng: entity work.ptrng
	generic map (
		REG_WIDTH => 32,
		RAND_WIDTH => 32
	)
	port map (
		clk => clk,
		reset => sw_reset,
		ring_en => ring_en,
		freqcount_en => freqcount_en,
		freqcount_select => freqcount_select,
		freqcount_start => freqcount_start,
		freqcount_done => freqcount_done,
		freqcount_overflow => freqcount_overflow,
		freqcount_value => freqcount_value,
		freqdivider => freqdivider,
		data => fifo_data_write,
		valid => fifo_write_en
	);

	-- FIFO
	fifo_to_uart: entity extras.simple_fifo
	generic map (
		MEM_SIZE => FIFO_SIZE,
		SYNC_READ => true
	)
	port map (
		clock => clk,
		reset => fifo_reset,
		wr_data => fifo_data_write,
		we => fifo_write_en,
		rd_data => fifo_data_read,
		re => fifo_read_en,
		empty => fifo_empty,
		full => fifo_full,
		almost_empty_thresh => FIFO_ALMOSTEMPTY,
		almost_full_thresh => FIFO_ALMOSTFULL,
		almost_empty => fifo_almost_empty,
		almost_full => fifo_almost_full
	);

	-- The FIFO is reseted on sw_reset and on clear
	fifo_reset <= sw_reset or fifo_clear;

	-- The data read from the FIFO is valid the cycle after the read request
	process (clk, fifo_reset)
	begin
		if fifo_reset = '1' then
			fifo_read_valid <= '0';
		elsif rising_edge(clk) then
			fifo_read_valid <= fifo_read_en;
		end if;
	end process;

end architecture;
