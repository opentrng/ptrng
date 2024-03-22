library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Do the clock-domain crossing for a vector
entity clockdomain is
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
		-- Cross to this clock
		clk_to: in std_logic;
		-- Ouput data, sync to 'clk_to'
		data_out: out std_logic_vector (DATA_WIDTH-1 downto 0);
		-- Valid signal for 'data_out'
		data_en: out std_logic
	);
end entity;

-- RTL implemenation of cdc for std_logic_vector
architecture rtl of clockdomain is

	signal digit_clk_tap: std_logic_vector (7 downto 0);

begin

	-- Resynchronize the input clock
	process (clk_to, reset)
	begin
		if reset = '1' then
			digit_clk_tap <= (others => '0');
		elsif rising_edge(clk_to) then
			digit_clk_tap <= digit_clk_tap(digit_clk_tap'Length-2 downto 0) & clk_from;
		end if;
	end process;

	-- Sample the vector
	process (clk_to, reset)
	begin
		if reset = '1' then
			data_en <= '0';
		elsif rising_edge(clk_to) then
			if digit_clk_tap(3) = '0' and digit_clk_tap(2) = '1' then
				data_out <= data_in;
				data_en <= '1';
			else
				data_en <= '0';
			end if;
		end if;
	end process;

end architecture;
