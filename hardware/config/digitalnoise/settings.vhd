library ieee;
use ieee.std_logic_1164.all;

-- This file has been automatically generated with the command line:
-- $ python generate.py -vendor xilinx -luts 4 -x 12 -y 102 -maxwidth 15 -maxheight 22 -border 2 -ringwidth 2 -digitheight 8 -hpad 2 -vpad 2 -fmax 220e6 -len 20 21
-- For more information look into the directory 'hardware/config/digitalnoise'.
package settings is

	-- Ring-oscillators settings
	constant T: natural := 1;
	type len_array is array (0 to T) of natural;
	constant RO_LEN: len_array := (20, 21);

	-- Digitizer settings
	constant ERO: natural := 1;
	constant MURO: natural := 2;
	constant COSO: natural := 3;
	constant DIGITIZER: natural := COSO;

end package;