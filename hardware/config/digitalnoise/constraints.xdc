# This file has been automatically generated with the command line:
# $ python generate.py -luts 1 -x 12 -y 102 -width 15 -height 22 -colwidth 2 -freqheight 4 -digitheight 2 -hpad 2 -vpad 2 -fmax 200e6 -len 20 21
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
	# add_cells_to_pblock [get_pblocks digitalnoise] [get_cells top/ptrng/source]
	resize_pblock [get_pblocks digitalnoise] -add { SLICE_X12Y102:SLICE_X26Y123 }
	set_property CONTAIN_ROUTING 1 [get_pblocks digitalnoise]
	set_property EXCLUDE_PLACEMENT 1 [get_pblocks digitalnoise]

# Pblock for the frequency counter
create_pblock freq
	add_cells_to_pblock [get_pblocks freq] [get_cells top/ptrng/source/freq]
	resize_pblock [get_pblocks freq] -add { SLICE_X12Y102:SLICE_X26Y105 }
	set_property CONTAIN_ROUTING 1 [get_pblocks freq]
	set_property EXCLUDE_PLACEMENT 1 [get_pblocks freq]


# Pblock for ring-oscillator ring0
create_pblock ring0
	add_cells_to_pblock [get_pblocks ring0] [get_cells top/ptrng/source/bank[0].ring]
	resize_pblock [get_pblocks ring0] -add { SLICE_X14Y110:SLICE_X15Y120 }
	set_property CONTAIN_ROUTING 1 [get_pblocks ring0]
	set_property EXCLUDE_PLACEMENT 1 [get_pblocks ring0]

# Pblock for ring-oscillator ring1
create_pblock ring1
	add_cells_to_pblock [get_pblocks ring1] [get_cells top/ptrng/source/bank[1].ring]
	resize_pblock [get_pblocks ring1] -add { SLICE_X18Y110:SLICE_X19Y121 }
	set_property CONTAIN_ROUTING 1 [get_pblocks ring1]
	set_property EXCLUDE_PLACEMENT 1 [get_pblocks ring1]

# Ring-oscillator 0 manual placement into slices
set_property LOC SLICE_X14Y110 [get_cells top/ptrng/source/bank[0].ring/lut_nand]
set_property LOC SLICE_X14Y111 [get_cells top/ptrng/source/bank[0].ring/element[0].lut_buffer]
set_property LOC SLICE_X14Y112 [get_cells top/ptrng/source/bank[0].ring/element[1].lut_buffer]
set_property LOC SLICE_X14Y113 [get_cells top/ptrng/source/bank[0].ring/element[2].lut_buffer]
set_property LOC SLICE_X14Y114 [get_cells top/ptrng/source/bank[0].ring/element[3].lut_buffer]
set_property LOC SLICE_X14Y115 [get_cells top/ptrng/source/bank[0].ring/element[4].lut_buffer]
set_property LOC SLICE_X14Y116 [get_cells top/ptrng/source/bank[0].ring/element[5].lut_buffer]
set_property LOC SLICE_X14Y117 [get_cells top/ptrng/source/bank[0].ring/element[6].lut_buffer]
set_property LOC SLICE_X14Y118 [get_cells top/ptrng/source/bank[0].ring/element[7].lut_buffer]
set_property LOC SLICE_X14Y119 [get_cells top/ptrng/source/bank[0].ring/element[8].lut_buffer]
set_property LOC SLICE_X14Y120 [get_cells top/ptrng/source/bank[0].ring/element[9].lut_buffer]
set_property LOC SLICE_X15Y120 [get_cells top/ptrng/source/bank[0].ring/element[10].lut_buffer]
set_property LOC SLICE_X15Y119 [get_cells top/ptrng/source/bank[0].ring/element[11].lut_buffer]
set_property LOC SLICE_X15Y118 [get_cells top/ptrng/source/bank[0].ring/element[12].lut_buffer]
set_property LOC SLICE_X15Y117 [get_cells top/ptrng/source/bank[0].ring/element[13].lut_buffer]
set_property LOC SLICE_X15Y116 [get_cells top/ptrng/source/bank[0].ring/element[14].lut_buffer]
set_property LOC SLICE_X15Y115 [get_cells top/ptrng/source/bank[0].ring/element[15].lut_buffer]
set_property LOC SLICE_X15Y114 [get_cells top/ptrng/source/bank[0].ring/element[16].lut_buffer]
set_property LOC SLICE_X15Y113 [get_cells top/ptrng/source/bank[0].ring/element[17].lut_buffer]
set_property LOC SLICE_X15Y112 [get_cells top/ptrng/source/bank[0].ring/element[18].lut_buffer]
set_property LOC SLICE_X15Y111 [get_cells top/ptrng/source/bank[0].ring/element[19].lut_buffer]
set_property LOC SLICE_X15Y110 [get_cells top/ptrng/source/bank[0].ring/lut_and]

# Ring-oscillator 1 manual placement into slices
set_property LOC SLICE_X18Y110 [get_cells top/ptrng/source/bank[1].ring/lut_nand]
set_property LOC SLICE_X18Y111 [get_cells top/ptrng/source/bank[1].ring/element[0].lut_buffer]
set_property LOC SLICE_X18Y112 [get_cells top/ptrng/source/bank[1].ring/element[1].lut_buffer]
set_property LOC SLICE_X18Y113 [get_cells top/ptrng/source/bank[1].ring/element[2].lut_buffer]
set_property LOC SLICE_X18Y114 [get_cells top/ptrng/source/bank[1].ring/element[3].lut_buffer]
set_property LOC SLICE_X18Y115 [get_cells top/ptrng/source/bank[1].ring/element[4].lut_buffer]
set_property LOC SLICE_X18Y116 [get_cells top/ptrng/source/bank[1].ring/element[5].lut_buffer]
set_property LOC SLICE_X18Y117 [get_cells top/ptrng/source/bank[1].ring/element[6].lut_buffer]
set_property LOC SLICE_X18Y118 [get_cells top/ptrng/source/bank[1].ring/element[7].lut_buffer]
set_property LOC SLICE_X18Y119 [get_cells top/ptrng/source/bank[1].ring/element[8].lut_buffer]
set_property LOC SLICE_X18Y120 [get_cells top/ptrng/source/bank[1].ring/element[9].lut_buffer]
set_property LOC SLICE_X18Y121 [get_cells top/ptrng/source/bank[1].ring/element[10].lut_buffer]
set_property LOC SLICE_X19Y120 [get_cells top/ptrng/source/bank[1].ring/element[11].lut_buffer]
set_property LOC SLICE_X19Y119 [get_cells top/ptrng/source/bank[1].ring/element[12].lut_buffer]
set_property LOC SLICE_X19Y118 [get_cells top/ptrng/source/bank[1].ring/element[13].lut_buffer]
set_property LOC SLICE_X19Y117 [get_cells top/ptrng/source/bank[1].ring/element[14].lut_buffer]
set_property LOC SLICE_X19Y116 [get_cells top/ptrng/source/bank[1].ring/element[15].lut_buffer]
set_property LOC SLICE_X19Y115 [get_cells top/ptrng/source/bank[1].ring/element[16].lut_buffer]
set_property LOC SLICE_X19Y114 [get_cells top/ptrng/source/bank[1].ring/element[17].lut_buffer]
set_property LOC SLICE_X19Y113 [get_cells top/ptrng/source/bank[1].ring/element[18].lut_buffer]
set_property LOC SLICE_X19Y112 [get_cells top/ptrng/source/bank[1].ring/element[19].lut_buffer]
set_property LOC SLICE_X19Y111 [get_cells top/ptrng/source/bank[1].ring/element[20].lut_buffer]
set_property LOC SLICE_X19Y110 [get_cells top/ptrng/source/bank[1].ring/lut_and]


# Ring-oscillator manual routing
#TODO