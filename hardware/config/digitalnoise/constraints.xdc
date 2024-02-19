# This file has been automatically generated with the command line:
# $ python generate.py -luts 1 -x 12 -y 102 -width 15 -height 22 -border 2 -ringwidth 2 -digitheight 2 -hpad 2 -vpad 2 -fmax 200e6 -len 20 21
# For more information look into the directory 'hardware/config/digitalnoise'.

# Constraints for the digital noise source

# Combinational loops for each ring-oscillator
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets top/ptrng/source/bank[0].ring/net[0]]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets top/ptrng/source/bank[1].ring/net[0]]

# Ring-oscillator maximal output frequency (for proper timing verifications)
create_clock -name ring0_clk -period 5.0 -waveform { 0.0 2.5 } -add [get_nets top/ptrng/source/bank[0].ring/net[0]]
create_clock -name ring1_clk -period 5.0 -waveform { 0.0 2.5 } -add [get_nets top/ptrng/source/bank[1].ring/net[0]]

# No timing check between system clock and ring clocks
set_false_path -from [get_clocks ring0_clk] -to [get_clocks sys_clk]
set_false_path -from [get_clocks sys_clk] -to [get_clocks ring0_clk]
set_false_path -from [get_clocks ring1_clk] -to [get_clocks sys_clk]
set_false_path -from [get_clocks sys_clk] -to [get_clocks ring1_clk]

# General pblock for the reserved area
create_pblock digitalnoise
	add_cells_to_pblock [get_pblocks digitalnoise] [get_cells top/ptrng/source]
	resize_pblock [get_pblocks digitalnoise] -add { SLICE_X12Y102:SLICE_X26Y123 }
	set_property CONTAIN_ROUTING 1 [get_pblocks digitalnoise]
	set_property EXCLUDE_PLACEMENT 1 [get_pblocks digitalnoise]

# Pblock for the DMZ
create_pblock dmz
	resize_pblock [get_pblocks dmz] -add { SLICE_X14Y104:SLICE_X24Y121 }
	set_property CONTAIN_ROUTING 1 [get_pblocks dmz]
	set_property EXCLUDE_PLACEMENT 1 [get_pblocks dmz]


# Pblock for ring-oscillator ring0
create_pblock ring0
	add_cells_to_pblock [get_pblocks ring0] [get_cells top/ptrng/source/bank[0].ring]
	resize_pblock [get_pblocks ring0] -add { SLICE_X16Y108:SLICE_X17Y118 }
	set_property CONTAIN_ROUTING 1 [get_pblocks ring0]
	set_property EXCLUDE_PLACEMENT 1 [get_pblocks ring0]

# Pblock for ring-oscillator ring1
create_pblock ring1
	add_cells_to_pblock [get_pblocks ring1] [get_cells top/ptrng/source/bank[1].ring]
	resize_pblock [get_pblocks ring1] -add { SLICE_X20Y108:SLICE_X21Y119 }
	set_property CONTAIN_ROUTING 1 [get_pblocks ring1]
	set_property EXCLUDE_PLACEMENT 1 [get_pblocks ring1]

# Ring-oscillator 0 manual placement into slices
set_property LOC SLICE_X16Y108 [get_cells top/ptrng/source/bank[0].ring/lut_nand]
set_property LOC SLICE_X16Y109 [get_cells top/ptrng/source/bank[0].ring/element[0].lut_buffer]
set_property LOC SLICE_X16Y110 [get_cells top/ptrng/source/bank[0].ring/element[1].lut_buffer]
set_property LOC SLICE_X16Y111 [get_cells top/ptrng/source/bank[0].ring/element[2].lut_buffer]
set_property LOC SLICE_X16Y112 [get_cells top/ptrng/source/bank[0].ring/element[3].lut_buffer]
set_property LOC SLICE_X16Y113 [get_cells top/ptrng/source/bank[0].ring/element[4].lut_buffer]
set_property LOC SLICE_X16Y114 [get_cells top/ptrng/source/bank[0].ring/element[5].lut_buffer]
set_property LOC SLICE_X16Y115 [get_cells top/ptrng/source/bank[0].ring/element[6].lut_buffer]
set_property LOC SLICE_X16Y116 [get_cells top/ptrng/source/bank[0].ring/element[7].lut_buffer]
set_property LOC SLICE_X16Y117 [get_cells top/ptrng/source/bank[0].ring/element[8].lut_buffer]
set_property LOC SLICE_X16Y118 [get_cells top/ptrng/source/bank[0].ring/element[9].lut_buffer]
set_property LOC SLICE_X17Y118 [get_cells top/ptrng/source/bank[0].ring/element[10].lut_buffer]
set_property LOC SLICE_X17Y117 [get_cells top/ptrng/source/bank[0].ring/element[11].lut_buffer]
set_property LOC SLICE_X17Y116 [get_cells top/ptrng/source/bank[0].ring/element[12].lut_buffer]
set_property LOC SLICE_X17Y115 [get_cells top/ptrng/source/bank[0].ring/element[13].lut_buffer]
set_property LOC SLICE_X17Y114 [get_cells top/ptrng/source/bank[0].ring/element[14].lut_buffer]
set_property LOC SLICE_X17Y113 [get_cells top/ptrng/source/bank[0].ring/element[15].lut_buffer]
set_property LOC SLICE_X17Y112 [get_cells top/ptrng/source/bank[0].ring/element[16].lut_buffer]
set_property LOC SLICE_X17Y111 [get_cells top/ptrng/source/bank[0].ring/element[17].lut_buffer]
set_property LOC SLICE_X17Y110 [get_cells top/ptrng/source/bank[0].ring/element[18].lut_buffer]
set_property LOC SLICE_X17Y109 [get_cells top/ptrng/source/bank[0].ring/element[19].lut_buffer]
set_property LOC SLICE_X17Y108 [get_cells top/ptrng/source/bank[0].ring/lut_and]

# Ring-oscillator 1 manual placement into slices
set_property LOC SLICE_X20Y108 [get_cells top/ptrng/source/bank[1].ring/lut_nand]
set_property LOC SLICE_X20Y109 [get_cells top/ptrng/source/bank[1].ring/element[0].lut_buffer]
set_property LOC SLICE_X20Y110 [get_cells top/ptrng/source/bank[1].ring/element[1].lut_buffer]
set_property LOC SLICE_X20Y111 [get_cells top/ptrng/source/bank[1].ring/element[2].lut_buffer]
set_property LOC SLICE_X20Y112 [get_cells top/ptrng/source/bank[1].ring/element[3].lut_buffer]
set_property LOC SLICE_X20Y113 [get_cells top/ptrng/source/bank[1].ring/element[4].lut_buffer]
set_property LOC SLICE_X20Y114 [get_cells top/ptrng/source/bank[1].ring/element[5].lut_buffer]
set_property LOC SLICE_X20Y115 [get_cells top/ptrng/source/bank[1].ring/element[6].lut_buffer]
set_property LOC SLICE_X20Y116 [get_cells top/ptrng/source/bank[1].ring/element[7].lut_buffer]
set_property LOC SLICE_X20Y117 [get_cells top/ptrng/source/bank[1].ring/element[8].lut_buffer]
set_property LOC SLICE_X20Y118 [get_cells top/ptrng/source/bank[1].ring/element[9].lut_buffer]
set_property LOC SLICE_X20Y119 [get_cells top/ptrng/source/bank[1].ring/element[10].lut_buffer]
set_property LOC SLICE_X21Y118 [get_cells top/ptrng/source/bank[1].ring/element[11].lut_buffer]
set_property LOC SLICE_X21Y117 [get_cells top/ptrng/source/bank[1].ring/element[12].lut_buffer]
set_property LOC SLICE_X21Y116 [get_cells top/ptrng/source/bank[1].ring/element[13].lut_buffer]
set_property LOC SLICE_X21Y115 [get_cells top/ptrng/source/bank[1].ring/element[14].lut_buffer]
set_property LOC SLICE_X21Y114 [get_cells top/ptrng/source/bank[1].ring/element[15].lut_buffer]
set_property LOC SLICE_X21Y113 [get_cells top/ptrng/source/bank[1].ring/element[16].lut_buffer]
set_property LOC SLICE_X21Y112 [get_cells top/ptrng/source/bank[1].ring/element[17].lut_buffer]
set_property LOC SLICE_X21Y111 [get_cells top/ptrng/source/bank[1].ring/element[18].lut_buffer]
set_property LOC SLICE_X21Y110 [get_cells top/ptrng/source/bank[1].ring/element[19].lut_buffer]
set_property LOC SLICE_X21Y109 [get_cells top/ptrng/source/bank[1].ring/element[20].lut_buffer]
set_property LOC SLICE_X21Y108 [get_cells top/ptrng/source/bank[1].ring/lut_and]


# Ring-oscillator manual routing
#TODO