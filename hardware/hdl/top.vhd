library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library opentrng;

-- Top for testing the PTRNG by writing configuration registers and reading data into a FIFO through an UART.
entity top is
	generic (
		-- Frequency (Hz) of the oscillator (clk)
		CLK_REF: natural;
		-- Size of the FIFO to store generated number before read to from UART
		FIFO_SIZE: natural;
		-- Size of the data frame sent to the PC through the UART (FIFO size must be at least 2x bigger)
		BURST_SIZE: natural
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

	-- Constants
	constant DATA_WIDTH: natural := 32;
	constant ADDR_WIDTH: natural := 16;

	-- UART interface
	signal tx_data: std_logic_vector (7 downto 0);
	signal tx_req: std_logic;
	signal tx_busy: std_logic;
	signal rx_data: std_logic_vector (7 downto 0);
	signal rx_data_valid: std_logic;
	signal rx_brk: std_logic;
	signal rx_err: std_logic;

	-- Command processor
	signal rd_data: std_logic_vector (DATA_WIDTH-1 downto 0);
	signal wr_data: std_logic_vector (DATA_WIDTH-1 downto 0);
	signal address: std_logic_vector (ADDR_WIDTH-1 downto 0);
	signal read_req: std_logic;
	signal write_req: std_logic;

	-- Register map
	signal ptrng_reset: std_logic;
	signal analog_en: std_logic;
	signal analog_temperature: std_logic_vector (11 downto 0);
	signal analog_voltage: std_logic_vector (11 downto 0);
	signal ring_en: std_logic_vector (DATA_WIDTH-1 downto 0);
	signal freqcount_en: std_logic;
	signal freqcount_start: std_logic;
	signal freqcount_done: std_logic;
	signal freqcount_overflow: std_logic;
	signal freqcount_select: std_logic_vector (4 downto 0);
	signal freqcount_value: std_logic_vector (DATA_WIDTH-1 downto 0);
	signal freqdivider_value: std_logic_vector (DATA_WIDTH-1 downto 0);
	signal freqdivider_en: std_logic;
	signal alarm_threshold: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal alarm_detected: std_logic;
	signal onlinetest_clear: std_logic;
	signal onlinetest_valid: std_logic;
	signal onlinetest_average: std_logic_vector(15 downto 0);
	signal onlinetest_deviation: std_logic_vector(15 downto 0);
	signal conditioning: std_logic;
	signal nopacking: std_logic;
	
	-- PTRNG
	signal ptrng_data: std_logic_vector (DATA_WIDTH-1 downto 0);
	signal ptrng_valid: std_logic;

	-- FIFO
	signal fifo_clear: std_logic;
	signal fifo_empty: std_logic;
	signal fifo_full: std_logic;
	signal fifo_almost_empty: std_logic;
	signal fifo_almost_full: std_logic;
	signal fifo_read_en: std_logic;
	signal fifo_data_read: std_logic_vector (DATA_WIDTH-1 downto 0);
	
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
		ADDR_SIZE => ADDR_WIDTH,
		DATA_SIZE => DATA_WIDTH
	)
	port map (
		clk => clk,
		reset => rx_brk or rx_err, --hw_reset or rx_brk or rx_err,
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
	regmap: entity opentrng.regmap
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
		csr_analog_temperature_in => analog_temperature,
		csr_analog_voltage_in => analog_voltage,
		csr_analog_en_out => analog_en,
		csr_ring_en_out => ring_en,
		csr_freqctrl_en_out => freqcount_en,
		csr_freqctrl_start_out => freqcount_start,
		csr_freqctrl_done_in => freqcount_done,
		csr_freqctrl_select_out => freqcount_select,
		csr_freqctrl_overflow_in => freqcount_overflow,
		csr_freqvalue_value_in => freqcount_value,
		csr_freqdivider_value_out => freqdivider_value,
		csr_freqdivider_value_waccess => freqdivider_en,
		csr_alarm_threshold_out => alarm_threshold,
		csr_monitoring_alarm_in => alarm_detected,
		csr_monitoring_clear_out => onlinetest_clear,
		csr_monitoring_valid_in => onlinetest_valid,
		csr_onlinetest_average_out => onlinetest_average,
		csr_onlinetest_deviation_out => onlinetest_deviation,
		csr_fifoctrl_clear_out => fifo_clear,
		csr_fifoctrl_nopacking_out => nopacking,
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

	-- Internal temperature and voltage sensor
	analog: entity opentrng.analog
	port map (
		clk => clk,
		reset => hw_reset,
		enable => analog_en,
		temperature => analog_temperature,
		voltage => analog_voltage
	);

	-- Physical True Random Number Generator wrapped on the register map
	ptrng: entity opentrng.ptrng
	generic map (
		REG_WIDTH => DATA_WIDTH,
		RAND_WIDTH => DATA_WIDTH
	)
	port map (
		clk => clk,
		reset => hw_reset,
		clear => ptrng_reset,
		ring_en => ring_en,
		freqcount_en => freqcount_en,
		freqcount_select => freqcount_select,
		freqcount_start => freqcount_start,
		freqcount_done => freqcount_done,
		freqcount_overflow => freqcount_overflow,
		freqcount_value => freqcount_value,
		freqdivider_value => freqdivider_value,
		freqdivider_en => freqdivider_en,
		alarm_threshold => alarm_threshold,
		alarm_detected => alarm_detected,
		onlinetest_clear => onlinetest_clear,
		onlinetest_average => onlinetest_average,
		onlinetest_deviation => onlinetest_deviation,
		onlinetest_valid => onlinetest_valid,
		conditioning => conditioning,
		nopacking => nopacking,
		data => ptrng_data,
		valid => ptrng_valid
	);

	-- FIFO
	fifo_to_uart: entity opentrng.fifo
	generic map (
		SIZE => FIFO_SIZE,
		ALMOST_EMPTY_SIZE => BURST_SIZE,
		ALMOST_FULL_SIZE => FIFO_SIZE-BURST_SIZE,
		DATA_WIDTH => DATA_WIDTH
	)
	port map (
		clk => clk,
		reset => hw_reset,
		clear => ptrng_reset or fifo_clear,
		data_in => ptrng_data,
		wr => ptrng_valid,
		data_out => fifo_data_read,
		rd => fifo_read_en,
		empty => fifo_empty,
		full => fifo_full,
		almost_empty => fifo_almost_empty,
		almost_full => fifo_almost_full
	);

end architecture;
