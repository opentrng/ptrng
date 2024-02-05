library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Counter to estimate 'osc' signal frequency. Returns the number of periods of 'osc' during 'N' periods of 'clk'.
entity freqcounter is
	generic (
		-- Width of the result (and internal counters) in bits
		W: natural;
		-- Number of periods of 'clk' to count
		N: natural
	);
	port (
		-- Reference clock
		clk: in std_logic;
		-- Asynchronous reset
		reset: in std_logic;
		-- Signal to estimate its frequency
		osc: in std_logic;
		-- Global enable for the entity
		enable: in std_logic;
		-- Pulse '1' to start the frequency measure
		start: in std_logic;
		-- Flag set to '1' when the result is ready
		done: out std_logic;
		-- Flag set to '1' if an overflow occured (in the counter and for duration signal)
		overflow: out std_logic;
		-- Frequency estimation output
		result: out std_logic_vector (W-1 downto 0)
	);
end entity;

-- RTL architecture for the frequency counter.
architecture rtl of freqcounter is

	constant MAX: natural := 2**W-1;
	signal counting: std_logic := '0';
	signal counter: std_logic_vector (W-1 downto 0) := (others => '0');
	signal busy: std_logic := '0';
	signal finished: std_logic := '0';
	signal duration: std_logic_vector (W-1 downto 0) := (others => '0');

begin

	-- Count the number of periods of 'osc'
	process (osc, start)
	begin
		if start = '1' then
			counter <= (others => '0');
		elsif rising_edge(osc) then
			if enable = '1' and counting = '1' then
				if counter < MAX then
					counter <= counter + 1;
				end if;
			end if;
		end if;
	end process;

	-- State machine to manage the measurement operation
	process (clk, reset)
	begin
		if reset = '1' then
			duration <= (others => '0');
			busy <= '0';
			counting <= '0';
			finished <= '0';
			done <= '0';
			overflow <= '0';
		elsif rising_edge(clk) then
			if enable = '1' then
				if busy = '0' then
					if start = '1' then
						duration <= (others => '0');
						busy <= '1';
						counting <= '1';
						finished <= '0';
						done <= '0';
						overflow <= '0';
					end if;
				else
					if finished = '0' then
						if duration >= N or N >= MAX then
							counting <= '0';
							finished <= '1';
						else
							duration <= duration + 1;
						end if;
					else
						busy <= '0';
						finished <= '0';
						done <= '1';
						result <= counter;
						if counter >= MAX or duration > N or N >= MAX then
							overflow <= '1';
						end if;
					end if;
				end if;
			else
				duration <= (others => '0');
				busy <= '0';
				counting <= '0';
				finished <= '0';
				done <= '0';
				overflow <= '0';
			end if;
		end if;
	end process;

end architecture;
