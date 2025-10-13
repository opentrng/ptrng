library ieee;
use ieee.std_logic_1164.all;

entity dpfifo is
	generic (
		-- With of data ports
		DATA_WIDTH: natural
	);
	port (
		-- Asynchronous reset
		reset: in std_logic;
		-- Write clock
		wr_clk: in std_logic;
		-- Input data, sync to 'wr_clk'
		wr_data: in std_logic_vector (DATA_WIDTH-1 downto 0);
		--Write enable
		wr_en: in std_logic;
		-- Read clock
		rd_clk: in std_logic;
		-- Ouput data, sync to 'rd_clk'
		rd_data: out std_logic_vector (DATA_WIDTH-1 downto 0);
		-- Read enable
		rd_en: in std_logic;
		-- Empty flag
		empty: out std_logic;
		-- Full flag
		full: out std_logic;
		-- Almost empty flag
		almost_empty: out std_logic;
		-- Almost full flag
		almost_full: out std_logic
	);
end entity;

architecture xilinx of dpfifo is
begin

end architecture;
