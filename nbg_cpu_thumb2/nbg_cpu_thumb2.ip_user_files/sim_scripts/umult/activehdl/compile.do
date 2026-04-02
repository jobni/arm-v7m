transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xpm
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../../../../../../../../Xilinx/2025.2.1/Vivado/data/rsb/busdef" -l xpm \
"C:/Xilinx/2025.2.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \


vlog -work xil_defaultlib \
"glbl.v"

