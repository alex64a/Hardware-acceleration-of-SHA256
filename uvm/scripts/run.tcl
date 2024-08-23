cd ..
set root_dir [pwd]
cd scripts
set resultDir ../uvm_project

file mkdir $resultDir

create_project sha256_verif $resultDir 



# Ukljucivanje svih izvornih i simulacionih fajlova u projekat

add_files -norecurse ../dut/controlpath.vhd
add_files -norecurse ../dut/datapath.vhd
add_files -norecurse ../dut/SHA256_TOP.vhd
update_compile_order -fileset sources_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/Agent/sha256_agent_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/Configurations/configurations_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/Sequences/sha256_seq_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/sha256_test_pkg.sv
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../verif/sha256_verif_top.sv

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1


# Ukljucivanje uvm biblioteke

set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.xsim.more_options} -value {-testplusarg UVM_TESTNAME=test_simple -testplusarg UVM_VERBOSITY=UVM_LOW} -objects [get_filesets sim_1]
