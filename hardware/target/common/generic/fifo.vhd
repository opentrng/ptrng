library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

-- Show ahead FIFO that infers RAM blocks. Flags are updated at the next clock cycle. Show ahead means that first data is available on the output port, read fetches next.
entity fifo is
	generic (
		-- FIFO size (maximum number of elements)
		SIZE: natural;
		-- Threshold for almost empty
		ALMOST_EMPTY_SIZE: natural := 0;
		-- Threshold for almost full
		ALMOST_FULL_SIZE: natural := SIZE;
		-- Data path width
		DATA_WIDTH: natural
	);
	port (
		-- Main clock
		clk: in std_logic;
		-- Asynchronous reset
		reset: in std_logic;
		-- Synchronous clear
		clear: in std_logic;
		-- Data to be written in the FIFO
		data_in: in std_logic_vector (DATA_WIDTH-1 downto 0);
		-- Write signal (enable 'data_in' within the same clock cycle)
		wr: in std_logic;
		-- Show ahead data out (always showing the current data)
		data_out: out std_logic_vector (DATA_WIDTH-1 downto 0);
		-- Read signal, ask for a new data that will be available in next cycle
		rd: in std_logic;
		-- Rise next clock cycle after FIFO became emtpy
		empty: out std_logic;
		-- Rise next clock cycle after FIFO became full
		full: out std_logic;
		-- Rise next clock cycle after FIFO became almost emtpy
		almost_empty: out std_logic;
		-- Rise next clock cycle after FIFO became almost full
		almost_full: out std_logic
	);
end entity;

-- RTL implementation of the FIFO
architecture rtl of fifo is

	-- Constants
	constant ADDR_WIDTH: integer := integer(ceil(log2(real(SIZE))));
	constant MAX_SIZE: std_logic_vector (ADDR_WIDTH downto 0) := std_logic_vector(to_unsigned(2**ADDR_WIDTH, ADDR_WIDTH+1));

	-- Data array
	type mem is array (2**ADDR_WIDTH-1 downto 0) of std_logic_vector (DATA_WIDTH-1 downto 0);
	signal ram_block: mem;

	-- Read/write control
	signal write_address: std_logic_vector (ADDR_WIDTH-1 downto 0);
	signal read_address: std_logic_vector (ADDR_WIDTH-1 downto 0);
	signal count: std_logic_vector (ADDR_WIDTH downto 0);
	
begin

	control: process (clk, reset)
	begin
		if reset = '1' then
			write_address <= (others => '0');
			read_address <= (others => '0');
			count <= (others => '0');
		elsif rising_edge(clk) then
			if clear = '1' then
				write_address <= (others => '0');
				read_address <= (others => '0');
				count <= (others => '0');
			else
				if wr = '1' and rd = '1' and count > 0 and count <= MAX_SIZE then
					write_address <= write_address + 1;
					read_address <= read_address + 1;
				elsif wr = '1' and count < MAX_SIZE then
					write_address <= write_address + 1;
					count <= count + 1;
				elsif rd = '1' and count > 0 then
					read_address <= read_address + 1;
					count <= count - 1;
				end if;
			end if;
		end if;
	end process;
	
	data: process (clk)
	begin
		if rising_edge(clk) then
			if wr = '1' and rd = '1' and count > 0 and count <= MAX_SIZE then
				ram_block(conv_integer(write_address)) <= data_in;
			elsif wr = '1' and count < MAX_SIZE then
				ram_block(conv_integer(write_address)) <= data_in;
			end if;
		end if;
	end process;

	registered_putput: process (clk)
	begin
		if rising_edge(clk) then
			if rd = '1' then
				data_out <= ram_block(conv_integer(read_address+1));
			else
				data_out <= ram_block(conv_integer(read_address));
			end if;
		end if;
	end process;
	
	empty <= '1' when count = 0 else '0';
	almost_empty <= '1' when count <= ALMOST_EMPTY_SIZE else '0';

	full <= '1' when count >= MAX_SIZE else '0';
	almost_full <= '1' when count >= ALMOST_FULL_SIZE else '0';

end architecture;
