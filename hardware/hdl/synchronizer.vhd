library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Vector clock domain crossing. Resynchronize a vector from source clock to destination clock. Takes 4 clock (clk_to) cycles, so input datarate must be 4 times slower than destination clock. Also, destination clock must be faster as the source clock.
entity synchronizer is
	generic (
		-- With of data ports
		DATA_WIDTH: natural
	);
	port (
		-- Asynchronous reset
		reset: in std_logic;
		-- Cross from this clock
		clk_from: in std_logic;
		-- Input data, sync to 'clk_from'
		data_in: in std_logic_vector (DATA_WIDTH-1 downto 0);
		-- Valid signal for 'data_in'
		data_in_en: in std_logic;
		-- Cross to this clock
		clk_to: in std_logic;
		-- Synchronous clear active to '1' (sync to 'clk_to')
		clear: in std_logic;
		-- Ouput data, sync to 'clk_to'
		data_out: out std_logic_vector (DATA_WIDTH-1 downto 0);
		-- Valid signal for 'data_out'
		data_out_en: out std_logic
	);
end entity;

-- RTL implemenation of the resynchronizer for a vector.
architecture rtl of synchronizer is

	signal digit_clk_tap: std_logic_vector (7 downto 0);
	signal data: std_logic_vector (DATA_WIDTH-1 downto 0);
	signal valid: std_logic := '0';

begin

	-- Resynchronize the input clock
	process (clk_to, reset)
	begin
		if reset = '1' then
			digit_clk_tap <= (others => '0');
		elsif rising_edge(clk_to) then
			digit_clk_tap <= digit_clk_tap(digit_clk_tap'Length-2 downto 0) & (clk_from and data_in_en);
		end if;
	end process;

	-- Sampling the data input
	process (clk_to, reset)
	begin
		if reset = '1' then
			valid <= '0';
		elsif rising_edge(clk_to) then
			if digit_clk_tap(1) = '0' and digit_clk_tap(0) = '1' then
				data <= data_in;
				valid <= '1';
			else
				valid <= '0';
			end if;
		end if;
	end process;
	
	-- Registering the output
	process (clk_to, reset)
	begin
		if reset = '1' then
			data_out_en <= '0';
		elsif rising_edge(clk_to) then
			if clear = '1' then
				data_out_en <= '0';
			else
				if valid = '1' then
					data_out <= data;
					data_out_en <= '1';
				else
					data_out_en <= '0';
				end if;
			end if;
		end if;
	end process;

end architecture;
