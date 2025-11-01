`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2024 04:06:09 PM
// Design Name: 
// Module Name: ALU
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
`include "param_def.vh"

module ALU(
    input clk,
    input rst_n,
    input [7:0] curr_cnt,
    input micro_en,
    input [63:0] micro_code,
    input [7:0] micro_type,
    input [3:0] micro_cond,
    input [7:0] micro_it,
    input [15:0] micro_register_rn,
    input [15:0] micro_register_rt,
    input [15:0] micro_register_rm,
    input [15:0] micro_register_rd,
    input [15:0] micro_registers,
    input [31:0] micro_data,
    input [31:0] sp_r13,
    input [31:0] pc_r15,
    input [31:0] register_rn,
    input [31:0] register_rt,
    input [31:0] register_rm,
    input [31:0] register_rd,
    input [31:0] d_data,
    input micro_set_flag,
    input micro_carry,
    input micro_index,
    input micro_add,
    input micro_wback,
    input apsr_n,
    input apsr_z,
    input apsr_c,
    input apsr_v,
    input apsr_q,
    output reg [31:0] d_bus_addr,
    output reg [15:0] register_set_code,
    output reg [31:0] register_set_data,
    output reg [31:0] psr_set_code,
    output reg [31:0] psr_set_data,
    output reg [15:0] write_register,
    output reg micro_done,
    output reg update_pc,
    output reg write_en
    );
    reg [31:0] register_set_data_hi;
    reg [15:0] register_index;
    reg u_divisor_tvalid;
    reg u_dividend_tvalid;
    reg [31:0] u_dividend_tdata;
    reg [31:0] u_divisor_tdata;
    wire u_dout_tvalid;
    wire [63:0] u_dout_tdata;
    
    reg s_divisor_tvalid;
    reg s_dividend_tvalid;
    reg [31:0] s_dividend_tdata;
    reg [31:0] s_divisor_tdata;
    wire s_dout_tvalid;
    wire [63:0] s_dout_tdata;
    
    reg [31:0] umult_a;
    reg [31:0] umult_b;
    wire [63:0] umult_p;
    
    reg alu_error;
    
    wire [31:0] next_align_pc;
    wire [31:0] next_pc;
    
    assign next_align_pc = {pc_r15[31:2], 2'b0}+ 32'h4;
    assign next_pc = pc_r15 + 32'h4;
    
    udiv u_udiv(.aclk(clk),
        .s_axis_divisor_tvalid(u_divisor_tvalid),
        .s_axis_divisor_tdata(u_divisor_tdata),
        .s_axis_dividend_tvalid(u_dividend_tvalid),
        .s_axis_dividend_tdata(u_dividend_tdata),
        .m_axis_dout_tvalid(u_dout_tvalid),
        .m_axis_dout_tdata(u_dout_tdata));
        
    sdiv s_sdiv(.aclk(clk),
        .s_axis_divisor_tvalid(s_divisor_tvalid),
        .s_axis_divisor_tdata(s_divisor_tdata),
        .s_axis_dividend_tvalid(s_dividend_tvalid),
        .s_axis_dividend_tdata(s_dividend_tdata),
        .m_axis_dout_tvalid(s_dout_tvalid),
        .m_axis_dout_tdata(s_dout_tdata));
        
    umult u_umult(.CLK(clk),
         .A(umult_a),
         .B(umult_b),
         .P(umult_p));
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            d_bus_addr <= 32'b0;
            register_set_code <= 16'b0;
            register_set_data <= 32'b0;
            register_set_data_hi <= 32'b0;
            psr_set_code <= 32'b0;
            psr_set_data <= 32'b0;
            write_register <= 16'b0;
            register_index <= 16'b0;
            micro_done <= 1'b0;
            update_pc <= 1'b0;
            write_en <= 1'b0;
            u_divisor_tvalid <= 1'b0;
            u_dividend_tdata <= 32'b0;
            u_dividend_tvalid <= 1'b0;
            u_divisor_tdata <= 32'b0;
            s_divisor_tvalid <= 1'b0;
            s_dividend_tdata <= 32'b0;
            s_dividend_tvalid <= 1'b0;
            s_divisor_tdata <= 32'b0;
            umult_a <= 32'b0;
            umult_b <= 32'b0;
            alu_error <= 1'b0;
        end
        else if(micro_en) begin
            micro_done <= 1'b0;
            register_set_code <= 16'b0;
            psr_set_code <= 32'b0;
            write_register <= 16'b0;
            write_en <= 1'b0;
            register_index <= 16'b0;
            u_divisor_tvalid <= 1'b0;
            u_dividend_tdata <= 32'b0;
            u_dividend_tvalid <= 1'b0;
            u_divisor_tdata <= 32'b0;
            s_divisor_tvalid <= 1'b0;
            s_dividend_tdata <= 32'b0;
            s_dividend_tvalid <= 1'b0;
            s_divisor_tdata <= 32'b0;
            alu_error <= 1'b0;
            if(curr_cnt==8'h0) begin
                update_pc <= 1'b1;
            end
            case(micro_code)
                //转移指令
                64'b1 << `MICRO_CODE_B: begin
                    if(condition_pass(micro_cond, apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            register_set_data <= next_pc + micro_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_PC;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_BX: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            register_set_data <= register_rm;
                            register_set_code <= 16'b1<<`REGISTER_CODE_PC;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_BL: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            register_set_data <= {next_pc[31:1],1'b1};
                            register_set_code <= 16'b1<<`REGISTER_CODE_LR;
                        end
                        else if(curr_cnt==8'h1) begin
                            register_set_data <= next_pc + micro_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_PC;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_BLX: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            register_set_data <= pc_r15 + 32'h3;
                            register_set_code <= 16'b1<<`REGISTER_CODE_LR;
                        end
                        else if(curr_cnt==8'h2) begin
                            register_set_data <= register_rm;
                            register_set_code <= 16'b1<<`REGISTER_CODE_PC;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_TBB: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            d_bus_addr <= register_rn + register_rm;
                        end
                        else if(curr_cnt==8'h2) begin
                            case(d_bus_addr[1:0])
                                2'b00:register_set_data <= next_pc + {23'b0, d_data[7:0], 1'b0};
                                2'b01:register_set_data <= next_pc + {23'b0, d_data[15:8], 1'b0};
                                2'b10:register_set_data <= next_pc + {23'b0, d_data[23:16], 1'b0};
                                2'b11:register_set_data <= next_pc + {23'b0, d_data[31:24], 1'b0};
                            endcase
                            register_set_code <= 16'b1<<`REGISTER_CODE_PC;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_CBNZ_CBZ: begin
                    if(curr_cnt==8'h0) begin
                        if(micro_index!=(register_rn==32'b0)) begin
                            register_set_data <= next_pc + micro_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_PC;
                        end
                        micro_done <= 1'b1;
                    end
                end
                64'b1<<`MICRO_CODE_IT: begin
                    if(curr_cnt==8'h0) begin
                        micro_done <= 1'b1;
                    end
                end
                
                //数据传送指令
                64'b1 << `MICRO_CODE_LDR: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= register_rn + micro_data;
                                    register_set_data <= register_rn + micro_data;
                                end
                                else begin
                                    d_bus_addr <= register_rn - micro_data;
                                    register_set_data <= register_rn - micro_data;
                                end
                                if(!micro_index) begin
                                    d_bus_addr <= register_rn;
                                end
                                if(micro_wback) begin
                                    register_set_code <= micro_register_rn;
                                end
                            end
                            else if(curr_cnt==8'h2) begin
                                register_set_data <= d_data;
                                register_set_code <= micro_register_rt;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_LITERAL]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= next_align_pc + micro_data;
                                end
                                else begin
                                    d_bus_addr <= next_align_pc - micro_data;
                                end
                            end
                            else if(curr_cnt==8'h2) begin
                                register_set_data <= d_data;
                                register_set_code <= micro_register_rt;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= shift_c(register_rm, `SRTYPE_LSL, micro_data[1:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                if(micro_add) begin
                                    d_bus_addr <= register_rn + register_set_data;
                                    register_set_data <= register_rn + register_set_data;
                                end
                                else begin
                                    d_bus_addr <= register_rn - register_set_data;
                                    register_set_data <= register_rn - register_set_data;
                                end
                                if(!micro_index) begin
                                    d_bus_addr <= register_rn;
                                end
                                if(micro_wback) begin
                                    register_set_code <= micro_register_rn;
                                end
                            end
                            else if(curr_cnt==8'h3) begin
                                register_set_data <= d_data;
                                register_set_code <= micro_register_rt;
                                micro_done <= 1'b1;
                            end
                        end
                        else begin
                            //此处兼容初始化SP和PC初始化
                            if(curr_cnt==8'h0) begin
                                d_bus_addr <= micro_data;
                            end
                            else if(curr_cnt==8'h2) begin
                                register_set_data <= d_data;
                                register_set_code <= micro_register_rt;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_LDRH: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= register_rn + micro_data;
                                    register_set_data <= register_rn + micro_data;
                                end
                                else begin
                                    d_bus_addr <= register_rn - micro_data;
                                    register_set_data <= register_rn - micro_data;
                                end
                                if(!micro_index) begin
                                    d_bus_addr <= register_rn;
                                end
                                if(micro_wback) begin
                                    register_set_code <= micro_register_rn;
                                end
                            end
                            else if(curr_cnt==8'h2) begin
                                case(d_bus_addr[1])
                                    1'b0:register_set_data <= {12'b0, d_data[15:0]};
                                    1'b1:register_set_data <= {12'b0, d_data[23:16]};
                                endcase
                                register_set_code <= micro_register_rt;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_LITERAL]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= next_align_pc + micro_data;
                                end
                                else begin
                                    d_bus_addr <= next_align_pc - micro_data;
                                end
                            end
                            else if(curr_cnt==8'h2) begin
                                case(d_bus_addr[1])
                                    1'b0:register_set_data <= {12'b0, d_data[15:0]};
                                    1'b1:register_set_data <= {12'b0, d_data[23:16]};
                                endcase
                                register_set_code <= micro_register_rt;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= shift_c(register_rm, `SRTYPE_LSL, micro_data[1:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                if(micro_add) begin
                                    d_bus_addr <= register_rn + register_set_data;
                                    register_set_data <= register_rn + register_set_data;
                                end
                                else begin
                                    d_bus_addr <= register_rn - register_set_data;
                                    register_set_data <= register_rn - register_set_data;
                                end
                                if(!micro_index) begin
                                    d_bus_addr <= register_rn;
                                end
                                if(micro_wback) begin
                                    register_set_code <= micro_register_rn;
                                end
                            end
                            else if(curr_cnt==8'h3) begin
                                case(d_bus_addr[1])
                                    1'b0:register_set_data <= {12'b0, d_data[15:0]};
                                    1'b1:register_set_data <= {12'b0, d_data[23:16]};
                                endcase
                                register_set_code <= micro_register_rt;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_LDRB: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= register_rn + micro_data;
                                    register_set_data <= register_rn + micro_data;
                                end
                                else begin
                                    d_bus_addr <= register_rn - micro_data;
                                    register_set_data <= register_rn - micro_data;
                                end
                                if(!micro_index) begin
                                    d_bus_addr <= register_rn;
                                end
                                if(micro_wback) begin
                                    register_set_code <= micro_register_rn;
                                end
                            end
                            else if(curr_cnt==8'h2) begin
                                case(d_bus_addr[1:0])
                                    2'b00:register_set_data <= {24'b0, d_data[7:0]};
                                    2'b01:register_set_data <= {24'b0, d_data[15:8]};
                                    2'b10:register_set_data <= {24'b0, d_data[23:16]};
                                    2'b11:register_set_data <= {24'b0, d_data[31:24]};
                                endcase
                                register_set_code <= micro_register_rt;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_LITERAL]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= next_align_pc + micro_data;
                                end
                                else begin
                                    d_bus_addr <= next_align_pc - micro_data;
                                end
                            end
                            else if(curr_cnt==8'h2) begin
                                case(d_bus_addr[1:0])
                                    2'b00:register_set_data <= {24'b0, d_data[7:0]};
                                    2'b01:register_set_data <= {24'b0, d_data[15:8]};
                                    2'b10:register_set_data <= {24'b0, d_data[23:16]};
                                    2'b11:register_set_data <= {24'b0, d_data[31:24]};
                                endcase
                                register_set_code <= micro_register_rt;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= shift_c(register_rm, `SRTYPE_LSL, micro_data[1:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                if(micro_add) begin
                                    d_bus_addr <= register_rn + register_set_data;
                                    register_set_data <= register_rn + register_set_data;
                                end
                                else begin
                                    d_bus_addr <= register_rn - register_set_data;
                                    register_set_data <= register_rn - register_set_data;
                                end
                                if(!micro_index) begin
                                    d_bus_addr <= register_rn;
                                end
                                if(micro_wback) begin
                                    register_set_code <= micro_register_rn;
                                end
                            end
                            else if(curr_cnt==8'h3) begin
                                case(d_bus_addr[1:0])
                                    2'b00:register_set_data <= {24'b0, d_data[7:0]};
                                    2'b01:register_set_data <= {24'b0, d_data[15:8]};
                                    2'b10:register_set_data <= {24'b0, d_data[23:16]};
                                    2'b11:register_set_data <= {24'b0, d_data[31:24]};
                                endcase
                                register_set_code <= micro_register_rt;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_LDRSB: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= register_rn + micro_data;
                                    register_set_data <= register_rn + micro_data;
                                end
                                else begin
                                    d_bus_addr <= register_rn - micro_data;
                                    register_set_data <= register_rn - micro_data;
                                end
                                if(!micro_index) begin
                                    d_bus_addr <= register_rn;
                                end
                                if(micro_wback) begin
                                    register_set_code <= register_rn;
                                end
                            end
                            else if(curr_cnt==8'h2) begin
                                case(d_bus_addr[1:0])
                                    2'b00:register_set_data <= {{24{d_data[7]}},d_data[7:0]};
                                    2'b01:register_set_data <= {{24{d_data[15]}},d_data[15:8]};
                                    2'b10:register_set_data <= {{24{d_data[23]}},d_data[23:16]};
                                    2'b11:register_set_data <= {{24{d_data[31]}},d_data[31:24]};
                                endcase
                                register_set_code <= micro_register_rt;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_LITERAL]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= next_align_pc + micro_data;
                                end
                                else begin
                                    d_bus_addr <= next_align_pc - micro_data;
                                end
                            end
                            else if(curr_cnt==8'h2) begin
                                case(d_bus_addr[1:0])
                                    2'b00:register_set_data <= {{24{d_data[7]}},d_data[7:0]};
                                    2'b01:register_set_data <= {{24{d_data[15]}},d_data[15:8]};
                                    2'b10:register_set_data <= {{24{d_data[23]}},d_data[23:16]};
                                    2'b11:register_set_data <= {{24{d_data[31]}},d_data[31:24]};
                                endcase
                                register_set_code <= micro_register_rt;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                d_bus_addr <= shift_c(register_rm, `SRTYPE_LSL, micro_data[1:0], apsr_c);
                            end
                            else if(curr_cnt==8'h2) begin
                                case(d_bus_addr[1:0])
                                    2'b00:register_set_data <= {{24{d_data[7]}},d_data[7:0]};
                                    2'b01:register_set_data <= {{24{d_data[15]}},d_data[15:8]};
                                    2'b10:register_set_data <= {{24{d_data[23]}},d_data[23:16]};
                                    2'b11:register_set_data <= {{24{d_data[31]}},d_data[31:24]};
                                endcase
                                register_set_code <= micro_register_rt;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_LDRD: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= register_rn + micro_data;
                                    register_set_data <= register_rn + micro_data;
                                end
                                else begin
                                    d_bus_addr <= register_rn - micro_data;
                                    register_set_data <= register_rn - micro_data;
                                end
                                if(!micro_index) begin
                                    d_bus_addr <= register_rn;
                                end
                                if(micro_wback) begin
                                    register_set_code <= micro_register_rn;
                                end
                            end
                            else if(curr_cnt==8'h1) begin
                                d_bus_addr <= d_bus_addr + 32'h4;
                            end
                            else if(curr_cnt==8'h2) begin
                                register_set_data <= d_data;
                                register_set_code <= micro_register_rt;
                            end
                            else if(curr_cnt==8'h3) begin
                                register_set_data <= d_data;
                                register_set_code <= micro_register_rm;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_LITERAL]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= next_pc + micro_data;
                                end
                                else begin
                                    d_bus_addr <= next_pc - micro_data;
                                end
                            end
                            else if(curr_cnt==8'h1) begin
                                d_bus_addr <= d_bus_addr + 32'h4;
                            end
                            else if(curr_cnt==8'h2) begin
                                register_set_data <= d_data;
                                register_set_code <= micro_register_rt;
                            end
                            else if(curr_cnt==8'h3) begin
                                register_set_data <= d_data;
                                register_set_code <= micro_register_rm;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_STR: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= register_rn + micro_data;
                                    register_set_data <= register_rn + micro_data;
                                end
                                else begin
                                    d_bus_addr <= register_rn - micro_data;
                                    register_set_data <= register_rn - micro_data;
                                end
                                if(!micro_index) begin
                                    d_bus_addr <= register_rn;
                                end
                                if(micro_wback) begin
                                    register_set_code <= micro_register_rn;
                                end
                                write_register <= micro_register_rt;
                                write_en <= 1'b1;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= shift_c(register_rm, `SRTYPE_LSL, micro_data[1:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                d_bus_addr <= register_rn + register_set_data;
                                write_register <= micro_register_rt;
                                write_en <= 1'b1;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_STRH: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= register_rn + micro_data;
                                    register_set_data <= register_rn + micro_data;
                                end
                                else begin
                                    d_bus_addr <= register_rn - micro_data;
                                    register_set_data <= register_rn - micro_data;
                                end
                                if(!micro_index) begin
                                    d_bus_addr <= register_rn;
                                end
                                if(micro_wback) begin
                                    register_set_code <= micro_register_rn;
                                end
                            end
                            else if(curr_cnt==8'h2) begin
                                if(d_bus_addr[1]) begin
                                    register_set_data <= {register_rt[15:0], d_data[15:0]};
                                end
                                else begin
                                    register_set_data <= {d_data[31:16], register_rt[15:0]};
                                end
                                write_en <= 1'b1;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= shift_c(register_rm, `SRTYPE_LSL, micro_data[1:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                d_bus_addr <= register_rn + register_set_data;
                            end
                            else if(curr_cnt==8'h3) begin
                                if(d_bus_addr[1]) begin
                                    register_set_data <= {register_rt[15:0], d_data[15:0]};
                                end
                                else begin
                                    register_set_data <= {d_data[31:16], register_rt[15:0]};
                                end
                                write_en <= 1'b1;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_STRB: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= register_rn + micro_data;
                                    register_set_data <= register_rn + micro_data;
                                end
                                else begin
                                    d_bus_addr <= register_rn - micro_data;
                                    register_set_data <= register_rn - micro_data;
                                end
                                if(!micro_index) begin
                                    d_bus_addr <= register_rn;
                                end
                                if(micro_wback) begin
                                    register_set_code <= micro_register_rn;
                                end
                            end
                            else if(curr_cnt==8'h2) begin
                                case(d_bus_addr[1:0])
                                    2'b00:register_set_data <= {d_data[31:8], register_rt[7:0]};
                                    2'b01:register_set_data <= {d_data[31:16], register_rt[7:0], d_data[7:0]};
                                    2'b10:register_set_data <= {d_data[31:24], register_rt[7:0], d_data[15:0]};
                                    2'b11:register_set_data <= {register_rt[7:0], d_data[23:0]};
                                endcase
                                write_en <= 1'b1;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= shift_c(register_rm, `SRTYPE_LSL, micro_data[1:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                d_bus_addr <= register_rn + register_set_data;
                            end
                            else if(curr_cnt==8'h3) begin
                                case(d_bus_addr[1:0])
                                    2'b00:register_set_data <= {d_data[31:8], register_rt[7:0]};
                                    2'b01:register_set_data <= {d_data[31:16], register_rt[7:0], d_data[7:0]};
                                    2'b10:register_set_data <= {d_data[31:24], register_rt[7:0], d_data[15:0]};
                                    2'b11:register_set_data <= {register_rt[7:0], d_data[23:0]};
                                endcase
                                write_en <= 1'b1;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_STRD: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_add) begin
                                    d_bus_addr <= register_rn + micro_data;
                                    register_set_data <= register_rn + micro_data;
                                end
                                else begin
                                    d_bus_addr <= register_rn - micro_data;
                                    register_set_data <= register_rn - micro_data;
                                end
                                if(!micro_index) begin
                                    d_bus_addr <= register_rn;
                                end
                                if(micro_wback) begin
                                    register_set_code <= micro_register_rn;
                                end
                                write_register <= micro_register_rt;
                                write_en <= 1'b1;
                            end
                            else if(curr_cnt==8'h1) begin
                                d_bus_addr <= d_bus_addr + 32'h4;
                                write_register <= micro_register_rm;
                                write_en <= 1'b1;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_STMIA: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            d_bus_addr <= register_rn;
                        end 
                        else begin
                            d_bus_addr <= d_bus_addr + 32'h4;
                        end
                        
                        if(micro_registers[`REGISTER_CODE_R0] && curr_cnt[7:0]==8'h0) begin
                            write_register[`REGISTER_CODE_R0] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R0;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R1] && (curr_cnt[7:0]==8'h0||(|register_index[`REGISTER_CODE_R0:0]))) begin
                            write_register[`REGISTER_CODE_R1] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R1;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R2] && (curr_cnt[7:0]==8'h0||(|register_index[`REGISTER_CODE_R1:0]))) begin
                            write_register[`REGISTER_CODE_R2] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R2;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R3] && (curr_cnt[7:0]==8'h0||(|register_index[`REGISTER_CODE_R2:0]))) begin
                            write_register[`REGISTER_CODE_R3] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R3;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R4] && (curr_cnt[7:0]==8'h0||(|register_index[`REGISTER_CODE_R3:0]))) begin
                            write_register[`REGISTER_CODE_R4] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R4;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R5] && (curr_cnt[7:0]==8'h0||(|register_index[`REGISTER_CODE_R4:0]))) begin
                            write_register[`REGISTER_CODE_R5] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R5;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R6] && (curr_cnt[7:0]==8'h0||(|register_index[`REGISTER_CODE_R5:0]))) begin
                            write_register[`REGISTER_CODE_R6] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R6;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R7] && (curr_cnt[7:0]==8'h0||(|register_index[`REGISTER_CODE_R6:0]))) begin
                            write_register[`REGISTER_CODE_R7] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R7;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R8] && (curr_cnt[7:0]==8'h0||(|register_index[`REGISTER_CODE_R7:0]))) begin
                            write_register[`REGISTER_CODE_R8] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R8;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R9] && (curr_cnt[7:0]==8'h0||(|register_index[`REGISTER_CODE_R8:0]))) begin
                            write_register[`REGISTER_CODE_R9] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R9;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R10] && (curr_cnt[7:0]==8'h0||(|register_index[`REGISTER_CODE_R9:0]))) begin
                            write_register[`REGISTER_CODE_R10] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R10;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R11] && (curr_cnt[7:0]==8'h0||(|register_index[`REGISTER_CODE_R10:0]))) begin
                            write_register[`REGISTER_CODE_R11] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R11;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R12] && (curr_cnt[7:0]==8'h0||(|register_index[`REGISTER_CODE_R11:0]))) begin
                            write_register[`REGISTER_CODE_R12] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R12;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_LR] && (curr_cnt[7:0]==8'h0||(|register_index[`REGISTER_CODE_R12:0]))) begin
                            write_register[`REGISTER_CODE_LR] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_LR;
                            write_en <= 1'b1;
                        end
                        else if(|register_index) begin
                            if(micro_wback) begin
                                register_set_data <= d_bus_addr + 32'h4;
                                register_set_code <= micro_register_rn;
                            end
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_LDMIA: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            d_bus_addr <= register_rn;
                        end 
                        else begin
                            d_bus_addr <= d_bus_addr + 32'h4;
                        end
                        
                        if(micro_registers[`REGISTER_CODE_R0] && curr_cnt[7:0]==8'h2) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R0;
                            register_index <= 16'b1<<`REGISTER_CODE_R0;
                        end
                        else if(micro_registers[`REGISTER_CODE_R1] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R0:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R1;
                            register_index <= 16'b1<<`REGISTER_CODE_R1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R2] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R1:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R2;
                            register_index <= 16'b1<<`REGISTER_CODE_R2;
                        end
                        else if(micro_registers[`REGISTER_CODE_R3] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R2:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R3;
                            register_index <= 16'b1<<`REGISTER_CODE_R3;
                        end
                        else if(micro_registers[`REGISTER_CODE_R4] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R3:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R4;
                            register_index <= 16'b1<<`REGISTER_CODE_R4;
                        end
                        else if(micro_registers[`REGISTER_CODE_R5] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R4:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R5;
                            register_index <= 16'b1<<`REGISTER_CODE_R5;
                        end
                        else if(micro_registers[`REGISTER_CODE_R6] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R5:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R6;
                            register_index <= 16'b1<<`REGISTER_CODE_R6;
                        end
                        else if(micro_registers[`REGISTER_CODE_R7] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R6:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R7;
                            register_index <= 16'b1<<`REGISTER_CODE_R7;
                        end
                        else if(micro_registers[`REGISTER_CODE_R8] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R7:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R8;
                            register_index <= 16'b1<<`REGISTER_CODE_R8;
                        end
                        else if(micro_registers[`REGISTER_CODE_R9] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R8:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R9;
                            register_index <= 16'b1<<`REGISTER_CODE_R9;
                        end
                        else if(micro_registers[`REGISTER_CODE_R10] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R9:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R10;
                            register_index <= 16'b1<<`REGISTER_CODE_R10;
                        end
                        else if(micro_registers[`REGISTER_CODE_R11] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R10:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R11;
                            register_index <= 16'b1<<`REGISTER_CODE_R11;
                        end
                        else if(micro_registers[`REGISTER_CODE_R12] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R11:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R12;
                            register_index <= 16'b1<<`REGISTER_CODE_R12;
                        end
                        else if(micro_registers[`REGISTER_CODE_LR] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R12:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_LR;
                            register_index <= 16'b1<<`REGISTER_CODE_LR;
                        end
                        else if(micro_registers[`REGISTER_CODE_PC] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_LR:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_PC;
                            register_index <= 16'b1<<`REGISTER_CODE_PC;
                            update_pc <= 1'b0;
                        end
                        else if(|register_index) begin
                            if(micro_wback) begin
                                register_set_data <= d_bus_addr - 32'h4;
                                register_set_code <= micro_register_rn;
                            end
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_PUSH: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            d_bus_addr <= sp_r13 - 32'h4;
                        end 
                        else begin
                            d_bus_addr <= d_bus_addr - 32'h4;
                        end
                        
                        if(micro_registers[`REGISTER_CODE_LR] && curr_cnt[7:0]==8'h0) begin
                            write_register[`REGISTER_CODE_LR] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_LR;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R12] && (curr_cnt[7:0]==8'h0||(|register_index[15:`REGISTER_CODE_SP]))) begin
                            write_register[`REGISTER_CODE_R12] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R12;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R11] && (curr_cnt[7:0]==8'h0||(|register_index[15:`REGISTER_CODE_R12]))) begin
                            write_register[`REGISTER_CODE_R11] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R11;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R10] && (curr_cnt[7:0]==8'h0||(|register_index[15:`REGISTER_CODE_R11]))) begin
                            write_register[`REGISTER_CODE_R10] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R10;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R9] && (curr_cnt[7:0]==8'h0||(|register_index[15:`REGISTER_CODE_R10]))) begin
                            write_register[`REGISTER_CODE_R9] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R9;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R8] && (curr_cnt[7:0]==8'h0||(|register_index[15:`REGISTER_CODE_R9]))) begin
                            write_register[`REGISTER_CODE_R8] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R8;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R7] && (curr_cnt[7:0]==8'h0||(|register_index[15:`REGISTER_CODE_R8]))) begin
                            write_register[`REGISTER_CODE_R7] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R7;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R6] && (curr_cnt[7:0]==8'h0||(|register_index[15:`REGISTER_CODE_R7]))) begin
                            write_register[`REGISTER_CODE_R6] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R6;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R5] && (curr_cnt[7:0]==8'h0||(|register_index[15:`REGISTER_CODE_R6]))) begin
                            write_register[`REGISTER_CODE_R5] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R5;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R4] && (curr_cnt[7:0]==8'h0||(|register_index[15:`REGISTER_CODE_R5]))) begin
                            write_register[`REGISTER_CODE_R4] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R4;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R3] && (curr_cnt[7:0]==8'h0||(|register_index[15:`REGISTER_CODE_R4]))) begin
                            write_register[`REGISTER_CODE_R3] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R3;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R2] && (curr_cnt[7:0]==8'h0||(|register_index[15:`REGISTER_CODE_R3]))) begin
                            write_register[`REGISTER_CODE_R2] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R2;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R1] && (curr_cnt[7:0]==8'h0||(|register_index[15:`REGISTER_CODE_R2]))) begin
                            write_register[`REGISTER_CODE_R1] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R1;
                            write_en <= 1'b1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R0] && (curr_cnt[7:0]==8'h0||(|register_index[15:`REGISTER_CODE_R1]))) begin
                            write_register[`REGISTER_CODE_R0] <= 1'b1;
                            register_index <= 16'b1<<`REGISTER_CODE_R0;
                            write_en <= 1'b1;
                        end
                        else if(|register_index) begin
                            register_set_data <= d_bus_addr;
                            register_set_code <= 16'b1<<`REGISTER_CODE_SP;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_POP: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            d_bus_addr <= sp_r13;
                        end 
                        else begin
                            d_bus_addr <= d_bus_addr + 32'h4;
                        end
                        
                        if(micro_registers[`REGISTER_CODE_R0] && curr_cnt[7:0]==8'h2) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R0;
                            register_index <= 16'b1<<`REGISTER_CODE_R0;
                        end
                        else if(micro_registers[`REGISTER_CODE_R1] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R0:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R1;
                            register_index <= 16'b1<<`REGISTER_CODE_R1;
                        end
                        else if(micro_registers[`REGISTER_CODE_R2] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R1:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R2;
                            register_index <= 16'b1<<`REGISTER_CODE_R2;
                        end
                        else if(micro_registers[`REGISTER_CODE_R3] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R2:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R3;
                            register_index <= 16'b1<<`REGISTER_CODE_R3;
                        end
                        else if(micro_registers[`REGISTER_CODE_R4] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R3:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R4;
                            register_index <= 16'b1<<`REGISTER_CODE_R4;
                        end
                        else if(micro_registers[`REGISTER_CODE_R5] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R4:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R5;
                            register_index <= 16'b1<<`REGISTER_CODE_R5;
                        end
                        else if(micro_registers[`REGISTER_CODE_R6] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R5:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R6;
                            register_index <= 16'b1<<`REGISTER_CODE_R6;
                        end
                        else if(micro_registers[`REGISTER_CODE_R7] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R6:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R7;
                            register_index <= 16'b1<<`REGISTER_CODE_R7;
                        end
                        else if(micro_registers[`REGISTER_CODE_R8] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R7:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R8;
                            register_index <= 16'b1<<`REGISTER_CODE_R8;
                        end
                        else if(micro_registers[`REGISTER_CODE_R9] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R8:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R9;
                            register_index <= 16'b1<<`REGISTER_CODE_R9;
                        end
                        else if(micro_registers[`REGISTER_CODE_R10] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R9:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R10;
                            register_index <= 16'b1<<`REGISTER_CODE_R10;
                        end
                        else if(micro_registers[`REGISTER_CODE_R11] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R10:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R11;
                            register_index <= 16'b1<<`REGISTER_CODE_R11;
                        end
                        else if(micro_registers[`REGISTER_CODE_R12] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R11:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_R12;
                            register_index <= 16'b1<<`REGISTER_CODE_R12;
                        end
                        else if(micro_registers[`REGISTER_CODE_LR] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_R12:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_LR;
                            register_index <= 16'b1<<`REGISTER_CODE_LR;
                        end
                        else if(micro_registers[`REGISTER_CODE_PC] && (curr_cnt[7:0]==8'h2||(|register_index[`REGISTER_CODE_LR:0]))) begin
                            register_set_data <= d_data;
                            register_set_code <= 16'b1<<`REGISTER_CODE_PC;
                            register_index <= 16'b1<<`REGISTER_CODE_PC;
                            update_pc <= 1'b0;
                        end
                        else if(|register_index) begin
                            register_set_data <= d_bus_addr - 32'h4;
                            register_set_code <= 16'b1<<`REGISTER_CODE_SP;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_ASR: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                {psr_set_data[31:29], register_set_data} <= shift_c(register_rm, `SRTYPE_ASR, micro_data[5:0], apsr_c);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                {psr_set_data[31:29], register_set_data} <= shift_c(register_rn, `SRTYPE_ASR, register_rm[7:0], apsr_c);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_LSL: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                {psr_set_data[31:29], register_set_data} <= shift_c(register_rm, `SRTYPE_LSL, micro_data[5:0], apsr_c);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                {psr_set_data[31:29], register_set_data} <= shift_c(register_rn, `SRTYPE_LSL, register_rm[7:0], apsr_c);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_LSR: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                {psr_set_data[31:29], register_set_data} <= shift_c(register_rm, `SRTYPE_LSR, micro_data[5:0], apsr_c);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                {psr_set_data[31:29], register_set_data} <= shift_c(register_rn, `SRTYPE_LSR, register_rm[7:0], apsr_c);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_RRX: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            if(micro_set_flag) begin
                                psr_set_code[31:29] <= 3'b111;
                            end
                            {psr_set_data[31:29], register_set_data} <= shift_c(register_rm, `SRTYPE_RRX, 1'b1, apsr_c);
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_ROR: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                {psr_set_data[31:29], register_set_data} <= shift_c(register_rm, `SRTYPE_ROR, micro_data[5:0], apsr_c);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                {psr_set_data[31:29], register_set_data} <= shift_c(register_rn, `SRTYPE_ROR, register_rm[7:0], apsr_c);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_AND: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= register_rn & micro_data;
                                register_set_code <= micro_register_rd;
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                psr_set_data[31:29] <= {register_rn[31] & micro_data[31], (register_rn & micro_data) == 32'b0, micro_carry};
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                {psr_set_data[29], register_set_data} <= shift_c(register_rm, micro_data[10:8], micro_data[5:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                register_set_data <= register_rn & register_set_data;
                                register_set_code <= micro_register_rd;
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                psr_set_data[31:30] <= {register_rn[31] & register_set_data[31], (register_rn & register_set_data) == 32'b0};
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_BIC: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= register_rn & (~micro_data);
                                register_set_code <= micro_register_rd;
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                psr_set_data[31:29] <= {register_rn[31] & (!micro_data[31]), (register_rn & (~micro_data)) == 32'b0, micro_carry};
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                {psr_set_data[29], register_set_data} <= shift_c(register_rm, micro_data[10:8], micro_data[5:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                register_set_data <= register_rn & (~register_set_data);
                                register_set_code <= micro_register_rd;
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                psr_set_data[31:30] <= {register_rn[31] & (!register_set_data[31]), (register_rn ^ register_set_data) == 32'b0};
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_EOR: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= register_rn ^ micro_data;
                                register_set_code <= micro_register_rd;
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                psr_set_data[31:29] <= {register_rn[31] ^ micro_data[31], (register_rn ^ micro_data) == 32'b0, micro_carry};
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                {psr_set_data[29], register_set_data} <= shift_c(register_rm, micro_data[10:8], micro_data[5:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                register_set_data <= register_rn ^ register_set_data;
                                register_set_code <= micro_register_rd;
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                psr_set_data[31:30] <= {register_rn[31] ^ register_set_data[31], (register_rn ^ register_set_data) == 32'b0};
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_ORR: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= register_rn | micro_data;
                                register_set_code <= micro_register_rd;
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                psr_set_data[31:29] <= {register_rn[31] | micro_data[31], (register_rn | micro_data) == 32'b0, micro_carry};
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                {psr_set_data[29], register_set_data} <= shift_c(register_rm, micro_data[10:8], micro_data[5:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                register_set_data <= register_rn | register_set_data;
                                register_set_code <= micro_register_rd;
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                psr_set_data[31:30] <= {register_rn[31] | register_set_data[31], (register_rn | register_set_data) == 32'b0};
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_MVN: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= ~micro_data;
                                register_set_code <= micro_register_rd;
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                psr_set_data[31:29] <= {~micro_data[31], ~micro_data == 32'b0, micro_carry};
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                {psr_set_data[29], register_set_data} <= shift_c(register_rm, micro_data[10:8], micro_data[5:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                register_set_data <= ~register_set_data;
                                register_set_code <= micro_register_rd;
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                psr_set_data[31:30] <= {!register_set_data[31], (~register_set_data) == 32'b0};
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_TST: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                psr_set_code[31:29] <= 3'b111;
                                psr_set_data[31:29] <= {register_rn[31] & micro_data[31], (register_rn&micro_data) == 32'b0, micro_carry};
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                {psr_set_data[29], register_set_data} <= shift_c(register_rm, micro_data[10:8], micro_data[5:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                psr_set_code[31:29] <= 3'b111;
                                psr_set_data[31:30] <= {register_rn[31] & register_set_data[31], (register_rn & register_set_data) == 32'b0};
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_TEQ: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= register_rn ^ micro_data;
                                psr_set_code[31:29] <= 3'b111;
                                psr_set_data[31:29] <= {register_rn[31] ^ micro_data[31], (register_rn ^ micro_data) == 32'b0, micro_carry};
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                {psr_set_data[29], register_set_data} <= shift_c(register_rm, micro_data[10:8], micro_data[5:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                register_set_data <= register_rn ^ register_set_data;
                                psr_set_code[31:29] <= 3'b111;
                                psr_set_data[31:30] <= {register_rn[31] ^ register_set_data[31], (register_rn ^ register_set_data) == 32'b0};
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_ADD: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:28] <= 4'b1111;
                                end
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(register_rn,micro_data,1'b0);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= shift_c(register_rm, micro_data[10:8], micro_data[5:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:28] <= 4'b1111;
                                end
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(register_rn,register_set_data,1'b0);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_ADC: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:28] <= 4'b1111;
                                end
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(register_rn, micro_data, apsr_c);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= shift_c(register_rm, micro_data[10:8], micro_data[5:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:28] <= 4'b1111;
                                end
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(register_rn, register_set_data, apsr_c);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_SUB: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:28] <= 4'b1111;
                                end
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(register_rn,~micro_data,1'b1);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= shift_c(register_rm, micro_data[10:8], micro_data[5:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:28] <= 4'b1111;
                                end
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(register_rn, ~register_set_data, 1'b1);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_SBC: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:28] <= 4'b1111;
                                end
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(register_rn,~micro_data,apsr_c);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= shift_c(register_rm, micro_data[10:8], micro_data[5:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:28] <= 4'b1111;
                                end
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(register_rn, ~register_set_data, apsr_c);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_RSB: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:28] <= 4'b1111;
                                end
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(~register_rn,micro_data,1'b1);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= shift_c(register_rm, micro_data[10:8], micro_data[5:0], apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                if(micro_set_flag) begin
                                    psr_set_code[31:28] <= 4'b1111;
                                end
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(~register_rn, register_set_data, 1'b1);
                                register_set_code <= micro_register_rd;
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_BFC: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            register_set_data <= {register_rn};
                        end
                        else if(curr_cnt==8'h1) begin
                            if(micro_data[12:8]>=0 && micro_data[4:0]<=0) begin
                                register_set_data[0] <= 1'b0;
                            end
                            if(micro_data[12:8]>=1 && micro_data[4:0]<=1) begin
                                register_set_data[1] <= 1'b0;
                            end
                            if(micro_data[12:8]>=2 && micro_data[4:0]<=2) begin
                                register_set_data[2] <= 1'b0;
                            end
                            if(micro_data[12:8]>=3 && micro_data[4:0]<=3) begin
                                register_set_data[3] <= 1'b0;
                            end
                            if(micro_data[12:8]>=4 && micro_data[4:0]<=4) begin
                                register_set_data[4] <= 1'b0;
                            end
                            if(micro_data[12:8]>=5 && micro_data[4:0]<=5) begin
                                register_set_data[5] <= 1'b0;
                            end
                            if(micro_data[12:8]>=6 && micro_data[4:0]<=6) begin
                                register_set_data[6] <= 1'b0;
                            end
                            if(micro_data[12:8]>=7 && micro_data[4:0]<=7) begin
                                register_set_data[7] <= 1'b0;
                            end
                            if(micro_data[12:8]>=8 && micro_data[4:0]<=8) begin
                                register_set_data[8] <= 1'b0;
                            end
                            if(micro_data[12:8]>=9 && micro_data[4:0]<=9) begin
                                register_set_data[9] <= 1'b0;
                            end
                            if(micro_data[12:8]>=10 && micro_data[4:0]<=10) begin
                                register_set_data[10] <= 1'b0;
                            end
                            if(micro_data[12:8]>=11 && micro_data[4:0]<=11) begin
                                register_set_data[11] <= 1'b0;
                            end
                            if(micro_data[12:8]>=12 && micro_data[4:0]<=12) begin
                                register_set_data[12] <= 1'b0;
                            end
                            if(micro_data[12:8]>=13 && micro_data[4:0]<=13) begin
                                register_set_data[13] <= 1'b0;
                            end
                            if(micro_data[12:8]>=14 && micro_data[4:0]<=14) begin
                                register_set_data[14] <= 1'b0;
                            end
                            if(micro_data[12:8]>=15 && micro_data[4:0]<=15) begin
                                register_set_data[15] <= 1'b0;
                            end
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_CMN: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                psr_set_code[31:28] <= 4'b1111;
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(register_rn,micro_data,1'b0);
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= shift_c(register_rm,micro_data[10:8],micro_data[5:0],apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                psr_set_code[31:28] <= 4'b1111;
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(register_rn,register_set_data,1'b0);
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_CMP: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                psr_set_code[31:28] <= 4'b1111;
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(register_rn,~micro_data,1'b1);
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= shift_c(register_rm,micro_data[10:8],micro_data[5:0],apsr_c);
                            end
                            else if(curr_cnt==8'h1) begin
                                psr_set_code[31:28] <= 4'b1111;
                                {psr_set_data[31:28], register_set_data} <= add_with_carry(register_rn,~register_set_data,1'b1);
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_MUL: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            umult_a <= register_rn;
                            umult_b <= register_rm;
                        end
                        else if(curr_cnt==8'h2) begin
                            register_set_data <= umult_p[31:0];
                            register_set_code <= micro_register_rd;
                            if(micro_set_flag) begin
                                psr_set_code[31:30] <= 2'b11;
                            end
                            psr_set_data[31:30] <= {umult_p[31], umult_p[31:0] == 32'b0};
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_UMLAL: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            umult_a <= register_rn;
                            umult_b <= register_rm;
                        end
                        else if(curr_cnt==8'h2) begin
                            {register_set_data_hi,register_set_data} <= {register_rd, register_rt}+umult_p;
                        end
                        else if(curr_cnt==8'h3) begin
                            register_set_code <= micro_register_rt;
                        end
                        else if(curr_cnt==8'h4) begin
                            register_set_data <= register_set_data_hi;
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_UMULL: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            umult_a <= register_rn;
                            umult_b <= register_rm;
                        end
                        else if(curr_cnt==8'h2) begin
                            register_set_data <= umult_p[31:0];
                            register_set_code <= micro_register_rt;
                        end
                        else if(curr_cnt==8'h3) begin
                            register_set_data <= umult_p[63:32];
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_MLA: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            umult_a <= register_rn;
                            umult_b <= register_rm;
                        end
                        else if(curr_cnt==8'h2) begin
                            register_set_data <= register_rt + umult_p[31:0];
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_MLS: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            umult_a <= register_rn;
                            umult_b <= register_rm;
                        end
                        else if(curr_cnt==8'h2) begin
                            register_set_data <= register_rt - umult_p[31:0];
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_UDIV: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt<8'h8) begin
                            u_divisor_tvalid <= 1'b1;
                            u_dividend_tvalid <= 1'b1;
                            u_dividend_tdata <= register_rn;
                            u_divisor_tdata <= register_rm;
                        end
                        else if(u_dout_tvalid) begin
                            register_set_data <= u_dout_tdata[63:32];
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_SDIV: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt<8'h8) begin
                            s_divisor_tvalid <= 1'b1;
                            s_dividend_tvalid <= 1'b1;
                            s_dividend_tdata <= register_rn;
                            s_divisor_tdata <= register_rm;
                        end
                        else if(s_dout_tvalid) begin
                            register_set_data <= s_dout_tdata[63:32];
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_UXTB: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            register_set_data <= ror_c(register_rm, micro_data[4:0]);
                        end
                        else if(curr_cnt==8'h1) begin
                            register_set_data <= {24'b0, register_set_data[7:0]};
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_SXTB: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            register_set_data <= ror_c(register_rm, micro_data[4:0]);
                        end
                        else if(curr_cnt==8'h1) begin
                            register_set_data <= {{24{register_set_data[7]}}, register_set_data[7:0]};
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_ADR: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            if(micro_add) begin
                                register_set_data <= next_align_pc + micro_data;
                            end
                            else begin
                                register_set_data <= next_align_pc - micro_data;
                            end
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_CLZ: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            register_set_data <= count_leading_zero_bits(register_rm);
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_MOV: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(micro_type[`MICRO_TYPE_IMMEDIATE]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= micro_data;
                                register_set_code <= micro_register_rd;
                                if(micro_set_flag) begin
                                    psr_set_code[31:29] <= 3'b111;
                                end
                                psr_set_data[31:29] <= {micro_data[31], micro_data == 32'b0, micro_carry};
                                micro_done <= 1'b1;
                            end
                        end
                        else if(micro_type[`MICRO_TYPE_REGISTER]) begin
                            if(curr_cnt==8'h0) begin
                                register_set_data <= register_rm;
                                register_set_code <= micro_register_rd;
                                if(micro_set_flag) begin
                                    psr_set_code[31:30] <= 2'b11;
                                end
                                psr_set_data[31:30] <= {register_rm[31], register_rm == 32'b0};
                                micro_done <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_MOVT: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            register_set_data <= {micro_data[15:0], register_rm[15:0]};
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1<<`MICRO_CODE_UBFX: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            register_set_data <= register_rn << micro_data[20:16];
                        end
                        else if(curr_cnt==8'h1) begin
                            register_set_data <= register_set_data >> micro_data[28:24];
                            register_set_code <= micro_register_rd;
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
                64'b1 << `MICRO_CODE_NOP: begin
                    if(condition_pass(current_cond(micro_it), apsr_n, apsr_z, apsr_c, apsr_v)) begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                    else begin
                        if(curr_cnt==8'h0) begin
                            micro_done <= 1'b1;
                        end
                    end
                end
            endcase
        end
    end
    
    function [5:0] count_leading_zero_bits(input [31:0] x);
        begin
            if(x[31]==1'b1) begin
                count_leading_zero_bits = 6'd0;
            end
            else if(x[31:30]==1'b1) begin
                count_leading_zero_bits = 6'd1;
            end
            else if(x[31:29]==1'b1) begin
                count_leading_zero_bits = 6'd2;
            end
            else if(x[31:28]==1'b1) begin
                count_leading_zero_bits = 6'd3;
            end
            else if(x[31:27]==1'b1) begin
                count_leading_zero_bits = 6'd4;
            end
            else if(x[31:26]==1'b1) begin
                count_leading_zero_bits = 6'd5;
            end
            else if(x[31:25]==1'b1) begin
                count_leading_zero_bits = 6'd6;
            end
            else if(x[31:24]==1'b1) begin
                count_leading_zero_bits = 6'd7;
            end
            else if(x[31:23]==1'b1) begin
                count_leading_zero_bits = 6'd8;
            end
            else if(x[31:22]==1'b1) begin
                count_leading_zero_bits = 6'd9;
            end
            else if(x[31:21]==1'b1) begin
                count_leading_zero_bits = 6'd10;
            end
            else if(x[31:20]==1'b1) begin
                count_leading_zero_bits = 6'd11;
            end
            else if(x[31:19]==1'b1) begin
                count_leading_zero_bits = 6'd12;
            end
            else if(x[31:18]==1'b1) begin
                count_leading_zero_bits = 6'd13;
            end
            else if(x[31:17]==1'b1) begin
                count_leading_zero_bits = 6'd14;
            end
            else if(x[31:16]==1'b1) begin
                count_leading_zero_bits = 6'd15;
            end
            else if(x[31:15]==1'b1) begin
                count_leading_zero_bits = 6'd16;
            end
            else if(x[31:14]==1'b1) begin
                count_leading_zero_bits = 6'd17;
            end
            else if(x[31:13]==1'b1) begin
                count_leading_zero_bits = 6'd18;
            end
            else if(x[31:12]==1'b1) begin
                count_leading_zero_bits = 6'd19;
            end
            else if(x[31:11]==1'b1) begin
                count_leading_zero_bits = 6'd20;
            end
            else if(x[31:10]==1'b1) begin
                count_leading_zero_bits = 6'd21;
            end
            else if(x[31:9]==1'b1) begin
                count_leading_zero_bits = 6'd22;
            end
            else if(x[31:8]==1'b1) begin
                count_leading_zero_bits = 6'd23;
            end
            else if(x[31:7]==1'b1) begin
                count_leading_zero_bits = 6'd24;
            end
            else if(x[31:6]==1'b1) begin
                count_leading_zero_bits = 6'd25;
            end
            else if(x[31:5]==1'b1) begin
                count_leading_zero_bits = 6'd26;
            end
            else if(x[31:4]==1'b1) begin
                count_leading_zero_bits = 6'd27;
            end
            else if(x[31:3]==1'b1) begin
                count_leading_zero_bits = 6'd28;
            end
            else if(x[31:2]==1'b1) begin
                count_leading_zero_bits = 6'd29;
            end
            else if(x[31:1]==1'b1) begin
                count_leading_zero_bits = 6'd30;
            end
            else if(x[31:0]==1'b1) begin
                count_leading_zero_bits = 6'd31;
            end
            else begin
                count_leading_zero_bits = 6'd32;
            end
        end
    endfunction
    
    function [3:0] current_cond(input [7:0] micro_it);
        begin
            if(micro_it[3:0]!=4'b0) begin
                current_cond = micro_it[7:4];
            end
            else begin
                current_cond = 4'b1110;
            end
        end
    endfunction
    
    function condition_pass(input [3:0] micro_cond, apsr_n, apsr_z, apsr_c, apsr_v);
        begin
            case (micro_cond)
                4'b0000: condition_pass = apsr_z;
                4'b0001: condition_pass = !apsr_z;
                4'b0010: condition_pass = apsr_c;
                4'b0011: condition_pass = !apsr_c;
                4'b0100: condition_pass = apsr_n;
                4'b0101: condition_pass = !apsr_n;
                4'b0110: condition_pass = apsr_v;
                4'b0111: condition_pass = !apsr_v;
                4'b1000: condition_pass = apsr_c && !apsr_z;
                4'b1001: condition_pass = !apsr_c || apsr_z;
                4'b1010: condition_pass = apsr_n == apsr_v;
                4'b1011: condition_pass = apsr_n != apsr_v;
                4'b1100: condition_pass = apsr_n == apsr_v && !apsr_z;
                4'b1101: condition_pass = apsr_n != apsr_v || apsr_z;
                4'b1110: condition_pass = 1'b1;
                4'b1111: condition_pass = 1'b1;
            endcase
        end
    endfunction
    
    function [35:0] add_with_carry(input [31:0] x, input [31:0] y, input carry_in);
        reg signed [31:0] x_sign;
        reg signed [31:0] y_sign;
        reg [32:0] unsigned_sum;
        reg [32:0] signed_sum;
        reg [31:0] result;
        reg nagative;
        reg zero;
        reg carry_out;
        reg overflow;
        begin
            x_sign = x;
            y_sign = y;
            unsigned_sum = {{1'b0, x} + {1'b0, y} + {32'b0, carry_in}};
            signed_sum = {{x_sign[31], x_sign}+{y_sign[31], y_sign} + {32'b0, carry_in}};
            result = unsigned_sum[31:0];
            nagative = result[31];
            zero = result == 32'b0;
            carry_out = unsigned_sum[32];
            overflow = signed_sum[32] != result[31];
            add_with_carry = {nagative, zero, carry_out, overflow, result};
        end
    endfunction

`include "function.vh"
endmodule
