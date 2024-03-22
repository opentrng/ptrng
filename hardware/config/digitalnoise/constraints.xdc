# This file has been automatically generated with the command line:
# $ python generate.py -vendor xilinx -luts 4 -x 12 -y 102 -maxwidth 15 -maxheight 22 -border 2 -digittype COSO -digitheight 8 -ringwidth 2 -hpad 2 -vpad 2 -fmax 220e6 -len 20 21
# For more information look into the directory 'hardware/config/digitalnoise'.

# Constraints for the digital noise source

# Combinational loops for each ring-oscillator
set_property ALLOW_COMBINATORIAL_LOOPS true [get_nets top/ptrng/source/bank[0].ring/net[0]]
set_property ALLOW_COMBINATORIAL_LOOPS true [get_nets top/ptrng/source/bank[1].ring/net[0]]

# Avoid any timing warnings into the ring-oscillators
#set_disable_timing -from I0 -to O -objects [get_cells top/ptrng/source/bank[0].ring/element_0_lut_nand]
#set_disable_timing -from I0 -to O -objects [get_cells top/ptrng/source/bank[1].ring/element_0_lut_nand]

# Ring-oscillator maximal output frequency (for proper timing verifications on ROs clock output)
create_clock -name ring0_clk -period 4.545454545454546 -waveform { 0.0 2.272727272727273 } -add [get_nets top/ptrng/source/bank[0].ring/net[0]]
create_clock -name ring1_clk -period 4.545454545454546 -waveform { 0.0 2.272727272727273 } -add [get_nets top/ptrng/source/bank[1].ring/net[0]]

# No timing check between system clock and ring clocks
set_clock_groups -name asynchronous_clocks -asynchronous -group [get_clocks sys_clk] -group [get_clocks ring0_clk] -group [get_clocks ring1_clk]

# General pblock for the reserved area
create_pblock digitalnoise
	resize_pblock [get_pblocks digitalnoise] -add { SLICE_X12Y102:SLICE_X25Y120 }
	set_property CONTAIN_ROUTING false [get_pblocks digitalnoise]
	set_property EXCLUDE_PLACEMENT true [get_pblocks digitalnoise]

# Pblock for the digitizer
create_pblock digitizer
	add_cells_to_pblock [get_pblocks digitizer] [get_cells top/ptrng/source/digitizer]
	add_cells_to_pblock [get_pblocks digitizer] [get_cells top/ptrng/source/cdc]
	resize_pblock [get_pblocks digitizer] -add { SLICE_X14Y104:SLICE_X23Y111 }
	set_property CONTAIN_ROUTING false [get_pblocks digitizer]
	set_property EXCLUDE_PLACEMENT true [get_pblocks digitizer]

# Pblock for the empty area all around the ROs
create_pblock bank
	resize_pblock [get_pblocks bank] -add { SLICE_X14Y112:SLICE_X23Y118 }
	set_property CONTAIN_ROUTING false [get_pblocks bank]
	set_property EXCLUDE_PLACEMENT true [get_pblocks bank]


# Pblock for ring0
create_pblock ring0
	add_cells_to_pblock [get_pblocks ring0] [get_cells top/ptrng/source/bank[0].ring]
	resize_pblock [get_pblocks ring0] -add { SLICE_X16Y114:SLICE_X17Y116 }
	set_property CONTAIN_ROUTING true [get_pblocks ring0]
	set_property EXCLUDE_PLACEMENT true [get_pblocks ring0]

# Pblock for ring1
create_pblock ring1
	add_cells_to_pblock [get_pblocks ring1] [get_cells top/ptrng/source/bank[1].ring]
	resize_pblock [get_pblocks ring1] -add { SLICE_X20Y114:SLICE_X21Y116 }
	set_property CONTAIN_ROUTING true [get_pblocks ring1]
	set_property EXCLUDE_PLACEMENT true [get_pblocks ring1]

# Ring-oscillator 0 manual placement into slices
set_property BEL A6LUT [get_cells top/ptrng/source/bank[0].ring/element_0_lut_nand]
set_property LOC SLICE_X16Y114 [get_cells top/ptrng/source/bank[0].ring/element_0_lut_nand]
set_property BEL B6LUT [get_cells top/ptrng/source/bank[0].ring/element[1].lut_buffer]
set_property LOC SLICE_X16Y114 [get_cells top/ptrng/source/bank[0].ring/element[1].lut_buffer]
set_property BEL C6LUT [get_cells top/ptrng/source/bank[0].ring/element[2].lut_buffer]
set_property LOC SLICE_X16Y114 [get_cells top/ptrng/source/bank[0].ring/element[2].lut_buffer]
set_property BEL D6LUT [get_cells top/ptrng/source/bank[0].ring/element[3].lut_buffer]
set_property LOC SLICE_X16Y114 [get_cells top/ptrng/source/bank[0].ring/element[3].lut_buffer]
set_property BEL A6LUT [get_cells top/ptrng/source/bank[0].ring/element[4].lut_buffer]
set_property LOC SLICE_X16Y115 [get_cells top/ptrng/source/bank[0].ring/element[4].lut_buffer]
set_property BEL B6LUT [get_cells top/ptrng/source/bank[0].ring/element[5].lut_buffer]
set_property LOC SLICE_X16Y115 [get_cells top/ptrng/source/bank[0].ring/element[5].lut_buffer]
set_property BEL C6LUT [get_cells top/ptrng/source/bank[0].ring/element[6].lut_buffer]
set_property LOC SLICE_X16Y115 [get_cells top/ptrng/source/bank[0].ring/element[6].lut_buffer]
set_property BEL D6LUT [get_cells top/ptrng/source/bank[0].ring/element[7].lut_buffer]
set_property LOC SLICE_X16Y115 [get_cells top/ptrng/source/bank[0].ring/element[7].lut_buffer]
set_property BEL A6LUT [get_cells top/ptrng/source/bank[0].ring/element[8].lut_buffer]
set_property LOC SLICE_X16Y116 [get_cells top/ptrng/source/bank[0].ring/element[8].lut_buffer]
set_property BEL B6LUT [get_cells top/ptrng/source/bank[0].ring/element[9].lut_buffer]
set_property LOC SLICE_X16Y116 [get_cells top/ptrng/source/bank[0].ring/element[9].lut_buffer]
set_property BEL C6LUT [get_cells top/ptrng/source/bank[0].ring/element[10].lut_buffer]
set_property LOC SLICE_X16Y116 [get_cells top/ptrng/source/bank[0].ring/element[10].lut_buffer]
set_property BEL B6LUT [get_cells top/ptrng/source/bank[0].ring/element[11].lut_buffer]
set_property LOC SLICE_X17Y116 [get_cells top/ptrng/source/bank[0].ring/element[11].lut_buffer]
set_property BEL A6LUT [get_cells top/ptrng/source/bank[0].ring/element[12].lut_buffer]
set_property LOC SLICE_X17Y116 [get_cells top/ptrng/source/bank[0].ring/element[12].lut_buffer]
set_property BEL D6LUT [get_cells top/ptrng/source/bank[0].ring/element[13].lut_buffer]
set_property LOC SLICE_X17Y115 [get_cells top/ptrng/source/bank[0].ring/element[13].lut_buffer]
set_property BEL C6LUT [get_cells top/ptrng/source/bank[0].ring/element[14].lut_buffer]
set_property LOC SLICE_X17Y115 [get_cells top/ptrng/source/bank[0].ring/element[14].lut_buffer]
set_property BEL B6LUT [get_cells top/ptrng/source/bank[0].ring/element[15].lut_buffer]
set_property LOC SLICE_X17Y115 [get_cells top/ptrng/source/bank[0].ring/element[15].lut_buffer]
set_property BEL A6LUT [get_cells top/ptrng/source/bank[0].ring/element[16].lut_buffer]
set_property LOC SLICE_X17Y115 [get_cells top/ptrng/source/bank[0].ring/element[16].lut_buffer]
set_property BEL D6LUT [get_cells top/ptrng/source/bank[0].ring/element[17].lut_buffer]
set_property LOC SLICE_X17Y114 [get_cells top/ptrng/source/bank[0].ring/element[17].lut_buffer]
set_property BEL C6LUT [get_cells top/ptrng/source/bank[0].ring/element[18].lut_buffer]
set_property LOC SLICE_X17Y114 [get_cells top/ptrng/source/bank[0].ring/element[18].lut_buffer]
set_property BEL B6LUT [get_cells top/ptrng/source/bank[0].ring/element[19].lut_buffer]
set_property LOC SLICE_X17Y114 [get_cells top/ptrng/source/bank[0].ring/element[19].lut_buffer]
set_property BEL A6LUT [get_cells top/ptrng/source/bank[0].ring/monitor_lut_and]
set_property LOC SLICE_X17Y114 [get_cells top/ptrng/source/bank[0].ring/monitor_lut_and]

# Ring-oscillator 1 manual placement into slices
set_property BEL A6LUT [get_cells top/ptrng/source/bank[1].ring/element_0_lut_nand]
set_property LOC SLICE_X20Y114 [get_cells top/ptrng/source/bank[1].ring/element_0_lut_nand]
set_property BEL B6LUT [get_cells top/ptrng/source/bank[1].ring/element[1].lut_buffer]
set_property LOC SLICE_X20Y114 [get_cells top/ptrng/source/bank[1].ring/element[1].lut_buffer]
set_property BEL C6LUT [get_cells top/ptrng/source/bank[1].ring/element[2].lut_buffer]
set_property LOC SLICE_X20Y114 [get_cells top/ptrng/source/bank[1].ring/element[2].lut_buffer]
set_property BEL D6LUT [get_cells top/ptrng/source/bank[1].ring/element[3].lut_buffer]
set_property LOC SLICE_X20Y114 [get_cells top/ptrng/source/bank[1].ring/element[3].lut_buffer]
set_property BEL A6LUT [get_cells top/ptrng/source/bank[1].ring/element[4].lut_buffer]
set_property LOC SLICE_X20Y115 [get_cells top/ptrng/source/bank[1].ring/element[4].lut_buffer]
set_property BEL B6LUT [get_cells top/ptrng/source/bank[1].ring/element[5].lut_buffer]
set_property LOC SLICE_X20Y115 [get_cells top/ptrng/source/bank[1].ring/element[5].lut_buffer]
set_property BEL C6LUT [get_cells top/ptrng/source/bank[1].ring/element[6].lut_buffer]
set_property LOC SLICE_X20Y115 [get_cells top/ptrng/source/bank[1].ring/element[6].lut_buffer]
set_property BEL D6LUT [get_cells top/ptrng/source/bank[1].ring/element[7].lut_buffer]
set_property LOC SLICE_X20Y115 [get_cells top/ptrng/source/bank[1].ring/element[7].lut_buffer]
set_property BEL A6LUT [get_cells top/ptrng/source/bank[1].ring/element[8].lut_buffer]
set_property LOC SLICE_X20Y116 [get_cells top/ptrng/source/bank[1].ring/element[8].lut_buffer]
set_property BEL B6LUT [get_cells top/ptrng/source/bank[1].ring/element[9].lut_buffer]
set_property LOC SLICE_X20Y116 [get_cells top/ptrng/source/bank[1].ring/element[9].lut_buffer]
set_property BEL C6LUT [get_cells top/ptrng/source/bank[1].ring/element[10].lut_buffer]
set_property LOC SLICE_X20Y116 [get_cells top/ptrng/source/bank[1].ring/element[10].lut_buffer]
set_property BEL C6LUT [get_cells top/ptrng/source/bank[1].ring/element[11].lut_buffer]
set_property LOC SLICE_X21Y116 [get_cells top/ptrng/source/bank[1].ring/element[11].lut_buffer]
set_property BEL B6LUT [get_cells top/ptrng/source/bank[1].ring/element[12].lut_buffer]
set_property LOC SLICE_X21Y116 [get_cells top/ptrng/source/bank[1].ring/element[12].lut_buffer]
set_property BEL A6LUT [get_cells top/ptrng/source/bank[1].ring/element[13].lut_buffer]
set_property LOC SLICE_X21Y116 [get_cells top/ptrng/source/bank[1].ring/element[13].lut_buffer]
set_property BEL D6LUT [get_cells top/ptrng/source/bank[1].ring/element[14].lut_buffer]
set_property LOC SLICE_X21Y115 [get_cells top/ptrng/source/bank[1].ring/element[14].lut_buffer]
set_property BEL C6LUT [get_cells top/ptrng/source/bank[1].ring/element[15].lut_buffer]
set_property LOC SLICE_X21Y115 [get_cells top/ptrng/source/bank[1].ring/element[15].lut_buffer]
set_property BEL B6LUT [get_cells top/ptrng/source/bank[1].ring/element[16].lut_buffer]
set_property LOC SLICE_X21Y115 [get_cells top/ptrng/source/bank[1].ring/element[16].lut_buffer]
set_property BEL A6LUT [get_cells top/ptrng/source/bank[1].ring/element[17].lut_buffer]
set_property LOC SLICE_X21Y115 [get_cells top/ptrng/source/bank[1].ring/element[17].lut_buffer]
set_property BEL D6LUT [get_cells top/ptrng/source/bank[1].ring/element[18].lut_buffer]
set_property LOC SLICE_X21Y114 [get_cells top/ptrng/source/bank[1].ring/element[18].lut_buffer]
set_property BEL C6LUT [get_cells top/ptrng/source/bank[1].ring/element[19].lut_buffer]
set_property LOC SLICE_X21Y114 [get_cells top/ptrng/source/bank[1].ring/element[19].lut_buffer]
set_property BEL B6LUT [get_cells top/ptrng/source/bank[1].ring/element[20].lut_buffer]
set_property LOC SLICE_X21Y114 [get_cells top/ptrng/source/bank[1].ring/element[20].lut_buffer]
set_property BEL A6LUT [get_cells top/ptrng/source/bank[1].ring/monitor_lut_and]
set_property LOC SLICE_X21Y114 [get_cells top/ptrng/source/bank[1].ring/monitor_lut_and]


# Ring-oscillator manual routing
#TODO
