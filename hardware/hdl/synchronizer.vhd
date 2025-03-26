library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library opentrng;

-- Vector clock domain crossing. Resynchronize a vector from source clock to destination clock with an dual port FIFO.
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

	signal almost_empty: std_logic;
	signal ready: std_logic;
	signal read_en: std_logic;

begin

	-- Dual port FIFO
	dpfifo: entity opentrng.dpfifo
	generic map (
		DATA_WIDTH => DATA_WIDTH
	)
	port map (
		reset => reset or clear,
		wr_clk => clk_from,
		wr_data => data_in,
		wr_en => data_in_en,
		rd_clk => clk_to,
		rd_data => data_out,
		rd_en => read_en,
		almost_empty => almost_empty
	);
	
	ready <= not almost_empty;
	
	-- TODO generate a sychronizer error when FIFO is full

	-- Read the FIFO is there is any available data
	process (clk_to, reset)
	begin
		if reset = '1' then
			read_en <= '0';
		elsif rising_edge(clk_to) then
			if ready = '1' then
				read_en <= '1';
			else
				read_en <= '0';
			end if;
		end if;
	end process;
	
	data_out_en <= read_en;

end architecture;
