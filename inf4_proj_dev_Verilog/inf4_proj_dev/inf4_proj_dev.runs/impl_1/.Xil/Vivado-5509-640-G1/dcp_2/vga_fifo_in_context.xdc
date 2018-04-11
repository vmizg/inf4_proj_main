set_property -quiet CLOCK_PERIOD_OOC_TARGET 10.000 [get_ports -no_traverse -quiet rd_clk]
set_property -quiet CLOCK_PERIOD_OOC_TARGET 10.000 [get_ports -no_traverse -quiet wr_clk]
set_property -quiet IS_IP_OOC_CELL TRUE [get_cells -of [get_ports -no_traverse -quiet din[0]]]
