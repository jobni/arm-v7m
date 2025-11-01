transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xpm
vlib activehdl/blk_mem_gen_v8_4_10
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap blk_mem_gen_v8_4_10 activehdl/blk_mem_gen_v8_4_10
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 -l xpm -l blk_mem_gen_v8_4_10 -l xil_defaultlib \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vlog -work blk_mem_gen_v8_4_10  -v2k5 -l xpm -l blk_mem_gen_v8_4_10 -l xil_defaultlib \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 -l xpm -l blk_mem_gen_v8_4_10 -l xil_defaultlib \
"../../../../nbg_cpu_16.gen/sources_1/ip/blk_flash/sim/blk_flash.v" \


vlog -work xil_defaultlib \
"glbl.v"

