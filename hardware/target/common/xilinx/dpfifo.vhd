library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

library UNIMACRO;
use unimacro.Vcomponents.all;

-- Show ahead Dual port FIFO for Xilinx series 7. Show ahead means that first data is always available on the output port, read fetches next.
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
		rd_en: out std_logic;
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

-- Instanciation of Xilinx dual clock macro
architecture xilinx of dpfifo is
begin

	-- FIFO_DUALCLOCK_MACRO: Dual-Clock First-In, First-Out (FIFO) RAM Buffer
	--                       7 Series
	-- Xilinx HDL Language Template, version 2021.2

	-- Note -  This Unimacro model assumes the port directions to be "downto".
	--         Simulation of this model with "to" in the port directions could lead to erroneous results.

	-----------------------------------------------------------------
	-- DATA_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width --
	-- ===========|===========|============|=======================--
	--   37-72    |  "36Kb"   |     512    |         9-bit         --
	--   19-36    |  "36Kb"   |    1024    |        10-bit         --
	--   19-36    |  "18Kb"   |     512    |         9-bit         --
	--   10-18    |  "36Kb"   |    2048    |        11-bit         --
	--   10-18    |  "18Kb"   |    1024    |        10-bit         --
	--    5-9     |  "36Kb"   |    4096    |        12-bit         --
	--    5-9     |  "18Kb"   |    2048    |        11-bit         --
	--    1-4     |  "36Kb"   |    8192    |        13-bit         --
	--    1-4     |  "18Kb"   |    4096    |        12-bit         --
	-----------------------------------------------------------------

	FIFO_DUALCLOCK_MACRO_inst : FIFO_DUALCLOCK_MACRO
	generic map (
		DEVICE => "7SERIES",             -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES"
		ALMOST_FULL_OFFSET => X"0008",   -- Sets almost full threshold
		ALMOST_EMPTY_OFFSET => X"0008",  -- Sets the almost empty threshold
		DATA_WIDTH => DATA_WIDTH,        -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
		FIFO_SIZE => "36Kb",             -- Target BRAM, "18Kb" or "36Kb"
		FIRST_WORD_FALL_THROUGH => TRUE) -- Sets the FIFO FWFT to TRUE or FALSE
	port map (
		ALMOSTEMPTY => almost_empty,  -- 1-bit output almost empty
		ALMOSTFULL => almost_full,    -- 1-bit output almost full
		DO => rd_data,                -- Output data, width defined by DATA_WIDTH parameter
		EMPTY => empty,               -- 1-bit output empty
		FULL => full,                 -- 1-bit output full
		--RDCOUNT => RDCOUNT,         -- Output read count, width determined by FIFO depth
		--RDERR => RDERR,             -- 1-bit output read error
		--WRCOUNT => WRCOUNT,         -- Output write count, width determined by FIFO depth
		--WRERR => WRERR,             -- 1-bit output write error
		DI => wr_data,                -- Input data, width defined by DATA_WIDTH parameter
		RDCLK => rd_clk,              -- 1-bit input read clock
		RDEN => rd_en,                -- 1-bit input read enable
		RST => reset,                 -- 1-bit input reset
		WRCLK => wr_clk,              -- 1-bit input write clock
		WREN => wr_en                 -- 1-bit input write enable
	);
	-- End of FIFO_DUALCLOCK_MACRO_inst instantiation

end architecture;

