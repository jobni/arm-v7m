transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr -l xpm -l xil_defaultlib \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vlog -work xil_defaultlib  -incr -v2k5 -l xpm -l xil_defaultlib \
"../../../../nbg_cpu_16.gen/sources_1/ip/umult/umult_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

