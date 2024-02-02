library ieee;
use ieee.std_logic_1164.all;

package settings is
	constant T: natural := 1;
	type len_array is array (0 to T) of natural;
	constant RO_LEN: len_array := (20, 20);
end package;
