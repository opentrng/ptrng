

create_pblock rings
add_cells_to_pblock [get_pblocks rings] [get_cells -quiet [list top/entropy/osc*]]
add_cells_to_pblock [get_pblocks rings] [get_cells -quiet [list top/entropy/freq]]
resize_pblock [get_pblocks rings] -add {SLICE_X0Y0:SLICE_X15Y24}
set_property CONTAIN_ROUTING 1 [get_pblocks rings]
set_property EXCLUDE_PLACEMENT 1 [get_pblocks rings]
