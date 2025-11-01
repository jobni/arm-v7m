`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2024 09:19:55 AM
// Design Name: 
// Module Name: ProcesserCoreSystem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

 module ProcesserCoreSystem(
    input sys_clk,
    input sys_rst_n,
    input uart_rxd,
    input[1:0] in_key,
    output uart_txd,
    output [2:0] led,
    output [7:0] signal
    );
    parameter UART_BPGS = 115200;
    parameter TICK_COUNT = 50000;
    parameter CNT_MAX = 20'd1000000;
    
    wire cpu_rst_n;
    wire [1:0] out_key;
    wire [15:0] ir_A;
    wire [15:0] ir_B;
    wire [31:0] ar;
    wire [31:0] dr;
    wire [31:0] sp_r13;
    wire [31:0] pc_r15;
    wire [31:0] i_bus_addr;
    wire [31:0] i_data;
    wire [31:0] d_bus_addr;
    wire [31:0] d_data;
    wire [31:0] register_rn;
    wire [31:0] register_rt;
    wire [31:0] register_rm;
    wire [31:0] register_rd;
    wire [2:0] decode_mode;
    wire [15:0] register_set_code;
    wire [31:0] register_set_data;
    wire [31:0] psr_set_code;
    wire [31:0] psr_set_data;
    wire [63:0] micro_code;
    wire [7:0] micro_type;
    wire [3:0] micro_cond;
    wire [7:0] micro_it;
    wire [15:0] micro_register_rn;
    wire [15:0] micro_register_rt;
    wire [15:0] micro_register_rm;
    wire [15:0] micro_register_rd;
    wire [15:0] micro_registers;
    wire [31:0] micro_data;
    wire micro_set_flag;
    wire micro_carry;
    wire micro_thumb32;
    wire [7:0] curr_done;
    wire [7:0] curr_st;
    wire [7:0] curr_cnt;
    wire [7:0] if_cnt;
    wire write_en;
    wire [15:0] write_register;
    wire [31:0] write_data;
    wire apsr_c;
    
    assign if_en     = curr_st[`CPU_ST_IF];
    assign decode_en = curr_st[`CPU_ST_DECODE];
    assign micro_en  = curr_st[`CPU_ST_MICRO];
    
    assign curr_done = {5'b0, micro_done, decode_done, if_done};
    
    key_debounce #(.CNT_MAX(CNT_MAX))
        u_key_debounce(
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .in_key(in_key),
        .out_key(out_key)
    );
    
    RegisterBank u_register_bank(
        .clk(sys_clk),
        .rst_n(cpu_rst_n),
        .micro_register_rn(micro_register_rn),
        .micro_register_rt(micro_register_rt),
        .micro_register_rm(micro_register_rm),
        .micro_register_rd(micro_register_rd),
        .register_set_code(register_set_code),
        .register_set_data(register_set_data),
        .psr_set_code(psr_set_code),
        .psr_set_data(psr_set_data),
        .write_register(write_register),
        .micro_thumb32(micro_thumb32),
        .micro_done(micro_done),
        .update_pc(update_pc),
        .if_cnt(if_cnt),
        .sp_r13(sp_r13),
        .pc_r15(pc_r15),
        .register_rn(register_rn),
        .register_rt(register_rt),
        .register_rm(register_rm),
        .register_rd(register_rd),
        .write_data(write_data),
        .apsr_n(apsr_n),
        .apsr_z(apsr_z),
        .apsr_c(apsr_c),
        .apsr_v(apsr_v),
        .apsr_q(apsr_q)
    );
    
    ALU u_alu(
        .clk(sys_clk),
        .rst_n(cpu_rst_n),
        .curr_cnt(curr_cnt),
        .micro_en(micro_en),
        .micro_code(micro_code),
        .micro_type(micro_type),
        .micro_cond(micro_cond),
        .micro_it(micro_it),
        .micro_register_rn(micro_register_rn),
        .micro_register_rt(micro_register_rt),
        .micro_register_rm(micro_register_rm),
        .micro_register_rd(micro_register_rd),
        .micro_registers(micro_registers),
        .micro_data(micro_data),
        .sp_r13(sp_r13),
        .pc_r15(pc_r15),
        .register_rn(register_rn),
        .register_rt(register_rt),
        .register_rm(register_rm),
        .register_rd(register_rd),
        .d_data(d_data),
        .micro_set_flag(micro_set_flag),
        .micro_carry(micro_carry),
        .micro_index(micro_index),
        .micro_add(micro_add),
        .micro_wback(micro_wback),
        .apsr_n(apsr_n),
        .apsr_z(apsr_z),
        .apsr_c(apsr_c),
        .apsr_v(apsr_v),
        .apsr_q(apsr_q),
        .d_bus_addr(d_bus_addr),
        .register_set_code(register_set_code),
        .register_set_data(register_set_data),
        .psr_set_code(psr_set_code),
        .psr_set_data(psr_set_data),
        .write_register(write_register),
        .micro_done(micro_done),
        .update_pc(update_pc),
        .write_en(write_en)
    );
    
    Decoder u_decoder(
        .clk(sys_clk),
        .rst_n(cpu_rst_n),
        .decode_en(decode_en),
        .if_cnt(if_cnt),
        .ir_A(ir_A),
        .ir_B(ir_B),
        .micro_done(micro_done),
        .apsr_c(apsr_c),
        .micro_code(micro_code),
        .micro_type(micro_type),
        .micro_cond(micro_cond),
        .micro_it(micro_it),
        .micro_register_rn(micro_register_rn),
        .micro_register_rt(micro_register_rt),
        .micro_register_rm(micro_register_rm),
        .micro_register_rd(micro_register_rd),
        .micro_registers(micro_registers),
        .micro_data(micro_data),
        .micro_thumb32(micro_thumb32),
        .micro_set_flag(micro_set_flag),
        .micro_carry(micro_carry),
        .micro_index(micro_index),
        .micro_add(micro_add),
        .micro_wback(micro_wback),
        .decode_done(decode_done)
    );
    
    InstructionFetch u_instruction_fetch(
        .clk(sys_clk),
        .rst_n(cpu_rst_n),
        .if_en(if_en),
        .curr_cnt(curr_cnt),
        .i_data(i_data),
        .pc_r15(pc_r15),
        .i_bus_addr(i_bus_addr),
        .ir_A(ir_A),
        .ir_B(ir_B),
        .if_done(if_done),
        .if_cnt(if_cnt)
    );
    
    MemoryInterface #(.UART_BPGS(UART_BPGS),
                .TICK_COUNT(TICK_COUNT))
        u_memory_interface(
        .clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .write_en(write_en),
        .write_data(write_data),
        .i_bus_addr(i_bus_addr),
        .d_bus_addr(d_bus_addr),
        .key(out_key),
        .uart_rxd(uart_rxd),
        .cpu_rst_n(cpu_rst_n),
        .uart_txd(uart_txd),
        .i_data(i_data),
        .d_data(d_data),
        .led(led),
        .signal(signal)
    );
    
    OperationController u_operation_controller(
        .clk(sys_clk),
        .rst_n(cpu_rst_n),
        .curr_done(curr_done),
        .curr_st(curr_st),
        .curr_cnt(curr_cnt)
    );
 endmodule
