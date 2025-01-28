library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Bloc responsible for online tests, which basically consists in calculating the moving cummulative sum of RRNs and comparing this cumsum to the average expected value +/- the drift.
entity onlinetest is
	generic (
		-- Width for the configuration registers
		REG_WIDTH: natural;
		-- Width for the RRN input
		RAND_WIDTH: natural;
		-- Depth for the cumulative sum
		DEPTH: natural
	);
	port (
		-- Base clock
		clk: in std_logic;
		-- Asynchronous reset active to '1'
		reset: in std_logic;
		-- Synchronous clear active to '1'
		clear: in std_logic;
		-- Raw Random Number input data (RRN)
		raw_random_number: in std_logic_vector (RAND_WIDTH-1 downto 0);
		-- RRN data input validation
		raw_random_valid: in std_logic;
		-- Average accepted value
		average: in std_logic_vector (REG_WIDTH/2-1 downto 0);
		-- Maximum deviation between accepted value and calculated value
		deviation: in std_logic_vector (REG_WIDTH/2-1 downto 0);
		-- Set to '1' when the total failure event is detected
		valid: out std_logic
	);
end entity;

-- RTL implementation of the online test
architecture rtl of onlinetest is

	constant MARGIN: natural := 8;

	signal fifo_in: std_logic_vector (RAND_WIDTH-1 downto 0);
	signal fifo_out: std_logic_vector (RAND_WIDTH-1 downto 0);
	signal fifo_write_en: std_logic;
	signal fifo_read_en: std_logic;
	signal fifo_almost_empty: std_logic;
	signal fifo_almost_full: std_logic;
	
	signal cumsum_value: std_logic_vector (REG_WIDTH+RAND_WIDTH-1 downto 0);
	signal cumsum_valid: std_logic;

begin

	-- Build the cumsum of all last RRNs
	accumulation: process (clk, reset) is
	begin
		if reset = '1' then
			cumsum_value <= (others => '0');
			cumsum_valid <= '0';
		elsif rising_edge(clk) then
			if clear = '1' then
				cumsum_valid <= '0';
			else
				if raw_random_valid = '1' then
					if fifo_read_en = '1' then
						cumsum_value <= (cumsum_value + fifo_in) - fifo_out;
						cumsum_valid <= '1';
					else
						cumsum_value <= cumsum_value + fifo_in;
					end if;
				else
				end if;
			end if;
		end if;
	end process;

	-- Write each incoming RRN into FIFO and read last RRN to be substracted from accumulator
	fifo_write_en <= raw_random_valid;
	fifo_in <= raw_random_number;
	fifo_read_en <= raw_random_valid when fifo_almost_full = '1' else '0';
	
	-- Averaging FIFO
	averaging_fifo: entity work.fifo
	generic map (
		SIZE => DEPTH+MARGIN,
		ALMOST_EMPTY_SIZE => MARGIN,
		ALMOST_FULL_SIZE => DEPTH,
		DATA_WIDTH => RAND_WIDTH
	)
	port map (
		clk => clk,
		reset => reset,
		clear => clear,
		data_in => fifo_in,
		wr => fifo_write_en,
		data_out => fifo_out,
		rd => fifo_read_en,
		almost_empty => fifo_almost_empty,
		almost_full => fifo_almost_full
	);

	-- Compare the cumsum to threshold for validation
	compare: process (clk, reset) is
	begin
		if reset = '1' then
			valid <= '1';
		elsif rising_edge(clk) then
			if clear = '1' then
				valid <= '1';
			else
				if cumsum_valid = '1' then
					if cumsum_value < average - deviation or cumsum_value > average + deviation then
						valid <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

end architecture;
