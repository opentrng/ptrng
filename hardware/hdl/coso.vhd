library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- This entity defines the Coherent Sampling Ring Oscillator entropy source, where the first ring oscillator RO0 is used to sample RO1, resulting in the generation of a beat signal. A counter, incremented by RO0, measures the period of the beat signal. The COSO's random output bit is derived from the counter least significant bit (LSB). Additionally, the raw counter value is accessible on output port. Both of these signals are synchronized with the output clock 'clk'.
entity coso is
	generic (
		DATA_WIDTH : natural
	);
	port (
		-- Sampling ring-oscillator input
		ro0: in std_logic;
		-- Sampled ring-oscillator input
		ro1: in std_logic;
		-- Clock output (aka the beat signal)
		clk: out std_logic;
		-- Bit data output (LSB of the counter)
		lsb: out std_logic;
		-- Raw value of the counter
		data: out std_logic_vector (DATA_WIDTH-1 downto 0);
		-- Valid signal for 'data' and 'lsb'
		valid: out std_logic
	);
end entity;

-- This architecture implements the RTL version of COSO measuring full period of beat signal with counter reset on beat signal rising edges.
architecture rtl of coso is

	signal beat_d0, beat_d1: std_logic := '0';
	constant MAX: std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '1');
	signal counter: std_logic_vector (DATA_WIDTH-1 downto 0);
	signal value: std_logic_vector (DATA_WIDTH-1 downto 0);

begin

	-- Sample RO1 with RO0 to create the beat signal
	process (ro0)
	begin
		if rising_edge(ro0) then
			beat_d0 <= ro1;
			beat_d1 <= beat_d0;
		end if;
	end process;

	-- Count the full period of the beat in steps of RO0
	process (ro0)
	begin
		if rising_edge(ro0) then
			if beat_d0 = '1' and beat_d1 = '0' then
				counter <= (others => '0');
			else
				if counter < MAX then
					counter <= counter + 1;
				end if;
			end if;
		end if;
	end process;

	-- Resample the value of the counter
	process (ro0)
	begin
		if rising_edge(ro0) then
			if beat_d0 = '1' and beat_d1 = '0' then
				value <= counter;
			end if;
		end if;
	end process;
	
	-- Output LSB and raw signals synchronized to the beat
	clk <= beat_d0;
	lsb <= value(0);
	data <= value;
	valid <= '1';

end architecture;
