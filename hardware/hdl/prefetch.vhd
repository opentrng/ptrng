library ieee;
use ieee.std_logic_1164.all;

-- The prefetch block performs a read operation on the input port as soon as the first data is available. When the master read the prefetched data, this block prefetches the next one. This block can be used to prefetch data in a sync-read FIFO to emulate a show-ahead FIFO.
entity prefetch is
	port (
		-- Base clock
		clk: in std_logic;
		-- Asynchronous reset active to '1'
		reset: in std_logic;
		-- Synchronous clear active to '1'
		clear: in std_logic;
		-- Signal that a data is available to be prefetched
		input_available: in std_logic;
		-- Read enable to prefetch the data
		input_read_en: out std_logic;
		-- Data prefetched on the next clock cycle after the read enable
		input_data: in std_logic_vector;
		-- Prefetched data is ready
		output_ready: out std_logic;
		-- Read enable for the prefetched data
		output_read_en: in std_logic;
		-- Data is available on the same cycle as the read enable
		output_data: out std_logic_vector
	);
end entity;

-- RTL implementation of a simple prefetch state machine.
architecture rtl of prefetch is

	signal busy: std_logic;
	signal fetch: std_logic;	

begin

	-- Small FSM that reads in the FIFO when data is available and acts as a mailbox
	process (clk, reset)
	begin
		if reset = '1' then
			input_read_en <= '0';
			busy <= '0';
			fetch <= '0';
			output_ready <= '0';
		elsif rising_edge(clk) then
			if clear = '0' then
				if input_available = '1' and busy = '0' then
					input_read_en <= '1';
					busy <= '1';
				end if;
				if input_read_en = '1' then
					input_read_en <= '0';
				end if;
				fetch <= input_read_en;
				if fetch = '1' then
					output_data <= input_data;
					output_ready <= '1'; 
				end if;
				if output_read_en = '1' then
					busy <= '0';
					output_ready <= '0'; 
				end if;
			else
				input_read_en <= '0';
				busy <= '0';
				fetch <= '0';
				output_ready <= '0';
			end if;
		end if;
	end process;

end architecture;

