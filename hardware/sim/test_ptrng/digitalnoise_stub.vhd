library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity digitalnoise is
	generic (
		REG_WIDTH: natural;
		RAND_WIDTH: natural
	);
	port (
		clk: in std_logic;
		reset: in std_logic;
		clear: in std_logic;
		ring_en: in std_logic_vector (REG_WIDTH-1 downto 0);
		freqcount_en: in std_logic;
		freqcount_select: in std_logic_vector (4 downto 0);
		freqcount_start: in std_logic;
		freqcount_done: out std_logic;
		freqcount_overflow: out std_logic;
		freqcount_value: out std_logic_vector (REG_WIDTH-1 downto 0);
		freqdivider_value: in std_logic_vector (REG_WIDTH-1 downto 0);
		freqdivider_en: in std_logic;
		synchronizer_clear: in std_logic;
		data: out std_logic_vector (RAND_WIDTH-1 downto 0);
		valid: out std_logic
	);
end entity;

architecture rtl of digitalnoise is

begin

end architecture;
