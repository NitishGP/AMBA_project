vlog list.svh\
+incdir+/home/tools/mentor/MENTOR_INSTALL/qustsim_2024.3/questasim/verilog_src/uvm-1.2/src/
vsim top -sv_lib /home/tools/mentor/MENTOR_INSTALL/qustsim_2024.3/questasim/uvm-1.2/linux_x86_64/uvm_dpi\
+UVM_VERBOSITY=UVM_MEDIUM
#add wave -position insertpoint sim:/top/pif/*
do wave.do
run -all
