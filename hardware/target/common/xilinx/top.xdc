# Constraints related to generic top
set_false_path -from [get_cells top/cmd_uart/rxd_d_reg[0]] -to [get_clocks sys_clk]
set_false_path -from [get_clocks sys_clk] -to [get_cells top/cmd_uart/rxd_d_reg[0]]
