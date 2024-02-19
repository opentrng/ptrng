library ieee;
use ieee.std_logic_1164.all;

-- This file has been automatically generated with the command line:
-- $ python generate.py -vendor xilinx -luts 1 -x 12 -y 102 -width 15 -height 22 -border 2 -ringwidth 2 -digitheight 2 -hpad 2 -vpad 2 -fmax 200e6 -len 20 21
-- For more information look into the directory 'hardware/config/digitalnoise'.
package settings is
	constant T: natural := 1;
	type len_array is array (0 to T) of natural;
	constant RO_LEN: len_array := (20, 21);
end package;