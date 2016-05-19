
set sdc_version 1.2
current_design CHIP
create_clock [get_ports {clk}] -name clk -period 10 -waveform {0 5} 
set_case_analysis 0 [get_ports {test_se}]
set_max_fanout 20 [current_design]
set_max_transition 2.7 [current_design]

set_clock_latency 2 [get_clocks {clk}]

set_input_delay     1 -clock clk \
                      [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay    1 -clock clk [all_outputs]

set_drive 0.1 [all_inputs]
set_load -pin_load 1 [all_outputs]

set_false_path  -from [get_ports {rst}]  

