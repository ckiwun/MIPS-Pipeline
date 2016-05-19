
set sdc_version 1.2
current_design CHIP
create_clock [get_ports {clk}] -name clk -period 100 -waveform {0 50} 
set_clock_latency 2 [get_clocks {clk}]

set_input_delay     3 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay    3 -clock clk [all_outputs]

set_drive 0.1 [all_inputs]
set_load -pin_load 20 [all_outputs]

