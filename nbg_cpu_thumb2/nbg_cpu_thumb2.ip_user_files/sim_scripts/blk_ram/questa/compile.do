vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/blk_mem_gen_v8_4_12
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap blk_mem_gen_v8_4_12 questa_lib/msim/blk_mem_gen_v8_4_12
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../../../../../../../../../Xilinx/2025.2.1/Vivado/data/rsb/busdef" \
"C:/Xilinx/2025.2.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vlog -work blk_mem_gen_v8_4_12  -incr -mfcu  "+incdir+../../../../../../../../../../Xilinx/2025.2.1/Vivado/data/rsb/busdef" \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../../../../../../../Xilinx/2025.2.1/Vivado/data/rsb/busdef" \
"../../../../nbg_cpu_thumb2.gen/sources_1/ip/blk_ram/sim/blk_ram.v" \


vlog -work xil_defaultlib \
"glbl.v"

