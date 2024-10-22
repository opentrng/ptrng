library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library extras;
use extras.fifos.all;

-- Top for testing the PTRNG by writing configuration registers and reading data into a FIFO through an UART.
entity top is
	generic (
		-- Frequency (Hz) of the oscillator (clk)
		CLK_REF: natural := 100_000_000
	);
	port (
		-- Oscillator input
		clk: in std_logic;
		-- Asynchronous hardware reset active to '1'
		hw_reset: in std_logic;
		-- UART signal from PC
		uart_txd: in std_logic;
		-- UART signal to PC
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
	signal ptrng_reset: std_logic;
	signal ring_en: std_logic_vector (31 downto 0);
	signal freqcount_en: std_logic;
	signal freqcount_start: std_logic;
	signal freqcount_done: std_logic;
	signal freqcount_overflow: std_logic;
	signal freqcount_select: std_logic_vector (4 downto 0);
	signal freqcount_value: std_logic_vector (22 downto 0);
	signal freqdivider: std_logic_vector (31 downto 0);
	signal alarm_threshold: std_logic_vector(15 downto 0);
	signal alarm_detected: std_logic;
	signal onlinetest_average: std_logic_vector(15 downto 0);
	signal onlinetest_drift: std_logic_vector(13 downto 0);
	signal onlinetest_valid: std_logic;
	signal onlinetest_clear: std_logic;
	signal conditioning: std_logic;
	signal packbits: std_logic;
	
	-- PTRNG
	signal ptrng_data: std_logic_vector (31 downto 0);
	signal ptrng_valid: std_logic;

	-- FIFO
	constant BURST_SIZE: natural := 512;
	constant FIFO_SIZE: natural := 4*BURST_SIZE;
	constant FIFO_ALMOSTEMPTY: natural := BURST_SIZE;
	constant FIFO_ALMOSTFULL: natural := BURST_SIZE;
	signal fifo_clear: std_logic;
	signal fifo_empty: std_logic;
	signal fifo_full: std_logic;
	signal fifo_almost_empty: std_logic;
	signal fifo_almost_full: std_logic;
	signal fifo_read_en: std_logic;
	signal fifo_write_en: std_logic;
	signal fifo_data_read: std_logic_vector (31 downto 0);
	signal fifo_data_write: std_logic_vector (31 downto 0);
	
	-- FIFO PREFETCHER
	signal fifo_prefetch_read: std_logic;
	signal fifo_prefetch_data: std_logic_vector (31 downto 0);
	
	signal counter: std_logic_vector (31 downto 0);
	
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
		csr_control_reset_out => ptrng_reset,
		csr_control_conditioning_out => conditioning,
		csr_ring_en_out => ring_en,
		csr_freqcount_en_out => freqcount_en,
		csr_freqcount_start_out => freqcount_start,
		csr_freqcount_done_in => freqcount_done,
		csr_freqcount_select_out => freqcount_select,
		csr_freqcount_value_in => freqcount_value,
		csr_freqcount_overflow_in => freqcount_overflow,
		csr_freqdivider_value_out => freqdivider,
		csr_alarm_threshold_out => alarm_threshold,
		csr_alarm_detected_in => alarm_detected,
		csr_onlinetest_clear_out => onlinetest_clear,
		csr_onlinetest_average_out => onlinetest_average,
		csr_onlinetest_drift_out => onlinetest_drift,
		csr_onlinetest_valid_in => onlinetest_valid,
		csr_fifoctrl_clear_out => fifo_clear,
		csr_fifoctrl_packbits_out => packbits,
		csr_fifoctrl_empty_in => fifo_empty,
		csr_fifoctrl_full_in => fifo_full,
		csr_fifoctrl_almostempty_in => fifo_almost_empty,
		csr_fifoctrl_almostfull_in => fifo_almost_full,
		csr_fifoctrl_rdburstavailable_in => not fifo_almost_empty,
		csr_fifoctrl_burstsize_in => std_logic_vector(to_unsigned(BURST_SIZE, 16)),
		csr_fifodata_data_rvalid => '1', -- Useless since rvalid is not used
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
		reset => ptrng_reset,
		ring_en => ring_en,
		freqcount_en => freqcount_en,
		freqcount_select => freqcount_select,
		freqcount_start => freqcount_start,
		freqcount_done => freqcount_done,
		freqcount_overflow => freqcount_overflow,
		freqcount_value => freqcount_value,
		freqdivider => freqdivider,
		alarm_threshold => alarm_threshold,
		alarm_detected => alarm_detected,
		onlinetest_clear => onlinetest_clear,
		onlinetest_average => onlinetest_average,
		onlinetest_drift => onlinetest_drift,
		onlinetest_valid => onlinetest_valid,
		conditioning => conditioning,
		packbits => packbits,
		data => ptrng_data,
		valid => ptrng_valid
	);

	-- FIFO
	fifo_to_uart: entity extras.simple_fifo
	generic map (
		MEM_SIZE => FIFO_SIZE,
		SYNC_READ => true -- use BRAM instead of registers
	)
	port map (
		clock => clk,
		reset => hw_reset or fifo_clear,
		wr_data => fifo_data_write,
		we => fifo_write_en,
		rd_data => fifo_prefetch_data,
		re => fifo_prefetch_read,
		empty => fifo_empty,
		full => fifo_full,
		almost_empty_thresh => FIFO_ALMOSTEMPTY,
		almost_full_thresh => FIFO_ALMOSTFULL,
		almost_empty => fifo_almost_empty,
		almost_full => fifo_almost_full
	);
	
	-- Do not write when FIFO is full
	process (clk, hw_reset)
	begin
		if hw_reset = '1' then
			fifo_write_en <= '0';
		elsif rising_edge(clk) then
			if fifo_full = '1' then
				fifo_write_en <= '0';
			else
				fifo_write_en <= ptrng_valid;
			end if;
			fifo_data_write <= ptrng_data;
		end if;
	end process;

	-- Synchronous FIFO requires an extra clock cycle for read data to be
	-- available, always prefetch the first data from FIFO into a register
	fifo_prefetcher: entity work.prefetch
	port map (
		clk => clk,
		reset => hw_reset,
		clear => fifo_clear,
		input_available => not fifo_empty,
		input_read_en => fifo_prefetch_read,
		input_data => fifo_prefetch_data,
		output_read_en => fifo_read_en,
		output_data => fifo_data_read
	);

end architecture;
