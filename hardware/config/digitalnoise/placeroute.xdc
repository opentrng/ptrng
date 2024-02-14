# This file has been automatically generated, for more information look into the directory 'hardware/config/digitalnoise'.

# Combinational loops for each ring-oscillator
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets top/ptrng/source/bank[0].ring/loopback/in0[0]]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets top/ptrng/source/bank[1].ring/loopback/in0[0]]

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
	resize_pblock [get_pblocks digitalnoise] -add { SLICE_X0Y0:SLICE_X13Y27 }
	set_property CONTAIN_ROUTING 1 [get_pblocks digitalnoise]
	set_property EXCLUDE_PLACEMENT 1 [get_pblocks digitalnoise]


# Pblock for each freq
create_pblock freq0
	add_cells_to_pblock [get_pblocks freq0] [get_cells top/ptrng/source/bank[0].freq]
	resize_pblock [get_pblocks freq0] -add { SLICE_X2Y2:SLICE_X5Y11 }
	set_property CONTAIN_ROUTING 1 [get_pblocks freq0]
	set_property EXCLUDE_PLACEMENT 1 [get_pblocks freq0]
create_pblock freq1
	add_cells_to_pblock [get_pblocks freq1] [get_cells top/ptrng/source/bank[1].freq]
	resize_pblock [get_pblocks freq1] -add { SLICE_X8Y2:SLICE_X11Y11 }
	set_property CONTAIN_ROUTING 1 [get_pblocks freq1]
	set_property EXCLUDE_PLACEMENT 1 [get_pblocks freq1]

# Pblock for each ring
create_pblock ring0
	add_cells_to_pblock [get_pblocks ring0] [get_cells top/ptrng/source/bank[0].ring]
	resize_pblock [get_pblocks ring0] -add { SLICE_X2Y12:SLICE_X5Y13 }
	set_property CONTAIN_ROUTING 1 [get_pblocks ring0]
	set_property EXCLUDE_PLACEMENT 1 [get_pblocks ring0]
create_pblock ring1
	add_cells_to_pblock [get_pblocks ring1] [get_cells top/ptrng/source/bank[1].ring]
	resize_pblock [get_pblocks ring1] -add { SLICE_X8Y12:SLICE_X11Y13 }
	set_property CONTAIN_ROUTING 1 [get_pblocks ring1]
	set_property EXCLUDE_PLACEMENT 1 [get_pblocks ring1]


# Ring-oscillator manual placement into slices
#TODO

# Ring-oscillator manual routing
#TODO