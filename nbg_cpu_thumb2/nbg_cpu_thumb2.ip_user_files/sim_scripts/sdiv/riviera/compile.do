transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../../../../../../../../Xilinx/2025.2.1/Vivado/data/rsb/busdef" -l xpm \
"C:/Xilinx/2025.2.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \


vlog -work xil_defaultlib \
"glbl.v"

