library ieee;
use ieee.std_logic_1164.all;

-- This file has been generated, for more information
-- look into the directory 'hardware/config/digitalnoise'.
package settings is
	constant T: natural := 3;
	type len_array is array (0 to T) of natural;
	constant RO_LEN: len_array := (22, 21, 19, 22);
end package;