vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xil_defaultlib

vmap xpm modelsim_lib/msim/xpm
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../../../../../../../../../Xilinx/2025.2.1/Vivado/data/rsb/busdef" \
"C:/Xilinx/2025.2.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \


vlog -work xil_defaultlib \
"glbl.v"

