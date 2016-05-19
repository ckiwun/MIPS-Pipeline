#####################
# Read Design & Library
#####################
read_netlist MIPS_Pipeline_syn_dft.v
read_netlist tsmc13.v

#####################
# Build Model
#####################
run_build_model MIPS_Pipeline

#####################
# View violation
#####################
#report_violations -all

#####################
# DRC
#####################
run_drc MIPS_Pipeline_syn_dft.spf

#####################
# Set fault list
#####################
set_faults -model stuck
add_faults -all

#####################
# Run ATPG
#####################
set_atpg -abort_limit 100 -merge high
run_atpg -auto_compression
set_faults -fault_coverage

#####################
# Write Patterns
#####################
write_patterns MIPS_Pipeline_syn_ATPG.wgl -format wgl
write_patterns MIPS_Pipeline_syn_ATPG.stil -format stil
