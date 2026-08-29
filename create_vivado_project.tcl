# Run from Vivado Tcl Console:
#   cd <path-to-unzipped-folder>
#   source create_vivado_project.tcl

set root [file normalize [file dirname [info script]]]
set proj_dir [file join $root vivado_project]

create_project riscv_fpga_cpu $proj_dir -part xc7a35tcpg236-1 -force

add_files -norecurse [glob [file join $root rtl *.sv]]
add_files -fileset constrs_1 -norecurse [file join $root constraints basys3.xdc]
add_files -norecurse [file join $root program demo.mem]
set_property file_type {Memory File} [get_files demo.mem]

add_files -fileset sim_1 -norecurse [file join $root sim tb_rv32_soc.sv]
set_property top basys3_top [get_filesets sources_1]
set_property top tb_rv32_soc [get_filesets sim_1]
set_property target_language Verilog [current_project]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Created project: $proj_dir"
puts "Top module: basys3_top"
puts "Next: Run Synthesis -> Run Implementation -> Generate Bitstream"
