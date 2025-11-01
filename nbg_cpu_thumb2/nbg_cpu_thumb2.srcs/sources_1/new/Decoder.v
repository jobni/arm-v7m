`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2024 09:17:37 AM
// Design Name: 
// Module Name: Decoder
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

module Decoder(
    input clk,
    input rst_n,
    input decode_en,
    input [7:0] if_cnt,
    input [15:0] ir_A,
    input [15:0] ir_B,
    input micro_done,
    input apsr_c,
    output reg [63:0] micro_code,
    output reg [7:0]  micro_type,
    output reg [3:0] micro_cond,
    output reg [7:0] micro_it,
    output reg [15:0] micro_register_rn,
    output reg [15:0] micro_register_rt,
    output reg [15:0] micro_register_rm,
    output reg [15:0] micro_register_rd,
    output reg [15:0] micro_registers,
    output reg [31:0] micro_data,
    output reg micro_thumb32,
    output reg micro_set_flag,
    output reg micro_carry,
    output reg micro_index,
    output reg micro_add,
    output reg micro_wback,
    output decode_done
    );
    
    wire thumb32;
    reg decode_error;
    reg [7:0] error_code;
    
    assign thumb32 = (ir_A[15:11] == 5'b11101)||(ir_A[15:12] == 4'b1111);
    assign decode_done = decode_en;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            micro_code <= 64'b0;
            micro_type <= 8'b0;
            micro_cond <= 4'b0;
            micro_register_rn <= 16'b0;
            micro_register_rt <= 16'b0;
            micro_register_rm <= 16'b0;
            micro_register_rd <= 16'b0;
            micro_registers <= 16'b0;
            micro_data <= 32'b0;
            micro_it <= 8'b0;
            micro_thumb32 <= 1'b0;
            micro_set_flag <= 1'b0;
            micro_carry <= 1'b0;
            micro_index <= 1'b0;
            micro_add <= 1'b0;
            micro_wback <= 1'b0;
            decode_error <= 1'b0;
            error_code <= 8'b0;
        end
        else if(decode_en) begin
            micro_code <= 64'b0;
            micro_type <= 8'b0;
            micro_cond <= 4'b1111;
            micro_register_rn <= 16'b0;
            micro_register_rt <= 16'b0;
            micro_register_rm <= 16'b0;
            micro_register_rd <= 16'b0;
            micro_registers <= 16'b0;
            micro_data <= 32'b0;
            micro_thumb32 <= 1'b0;
            micro_set_flag <= 1'b0;
            micro_carry <= 1'b0;
            micro_index <= 1'b0;
            micro_add <= 1'b0;
            micro_wback <= 1'b0;
            error_code <= 8'b0;
            if(if_cnt == 8'h1) begin
                micro_code[`MICRO_CODE_LDR] <= 1'b1;
                micro_register_rt[`REGISTER_CODE_SP] <= 1'b1;
                micro_data <= 32'h08000000;
                if(micro_done) begin
                    micro_code <= 64'b0;
                end
            end
            else if(if_cnt == 8'h2) begin
                micro_code[`MICRO_CODE_LDR] <= 1'b1;
                micro_register_rt[`REGISTER_CODE_PC] <= 1'b1;
                micro_data <= 32'h08000004;
                if(micro_done) begin
                    micro_code <= 64'b0;
                end
            end
            else if(!thumb32) begin
                if(ir_A[15:14] == 2'b00) begin
                    //Shift , add, subtract, move, and compare
                    if(ir_A[13:11] == 3'b000) begin
                        if(ir_A[10:6]==5'b00000) begin
                            //MOV (register) T2
                            micro_code[`MICRO_CODE_MOV] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= 1'b1;
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                        end
                        else begin
                            //LSL (immediate) T1
                            micro_code[`MICRO_CODE_LSL] <= 1'b1;
                            micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                            micro_data <= {24'b0, decode_imm_shift_n(`SRTYPE_LSL, ir_A[10:6])};
                        end
                    end
                    else if(ir_A[13:11] == 3'b001) begin
                        //LSR (immediate) T1
                        micro_code[`MICRO_CODE_LSR] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_set_flag <= !in_it_block(micro_it);
                        micro_register_rm <= convert_3_8(ir_A[5:3]);
                        micro_register_rd <= convert_3_8(ir_A[2:0]);
                        micro_data <= {24'b0, decode_imm_shift_n(`SRTYPE_LSR, ir_A[10:6])};
                    end
                    else if(ir_A[13:11] == 3'b010) begin
                        //ASR (immediate) T1
                        micro_code[`MICRO_CODE_ASR] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_set_flag <= !in_it_block(micro_it);
                        micro_register_rm <= convert_3_8(ir_A[5:3]);
                        micro_register_rd <= convert_3_8(ir_A[2:0]);
                        micro_data <= {24'b0, decode_imm_shift_n(`SRTYPE_ASR, ir_A[10:6])};
                    end
                    else if(ir_A[13:9] == 5'b01100) begin
                        //ADD (register) T1
                        micro_code[`MICRO_CODE_ADD] <= 1'b1;
                        micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                        micro_set_flag <= !in_it_block(micro_it);
                        micro_register_rd <= convert_3_8(ir_A[2:0]);
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rm <= convert_3_8(ir_A[8:6]);
                        micro_data <= {20'b0, `SRTYPE_LSL, 8'b0};
                    end
                    else if(ir_A[13:9] == 5'b01101) begin
                        //SUB (register) T1
                        micro_code[`MICRO_CODE_SUB] <= 1'b1;
                        micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                        micro_set_flag <= !in_it_block(micro_it);
                        micro_register_rm <= convert_3_8(ir_A[8:6]);
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rd <= convert_3_8(ir_A[2:0]);
                        micro_data <= {20'b0, `SRTYPE_LSL, 8'b0};
                    end
                    else if(ir_A[13:9] == 5'b01110) begin
                        //ADD (immediate) T1
                        micro_code[`MICRO_CODE_ADD] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_set_flag <= !in_it_block(micro_it);
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rd <= convert_3_8(ir_A[2:0]);
                        micro_data <= {29'b0, ir_A[8:6]};
                    end
                    else if(ir_A[13:9] == 5'b01111) begin
                        //SUB (immediate) T1
                        micro_code[`MICRO_CODE_SUB] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_set_flag <= !in_it_block(micro_it);
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rd <= convert_3_8(ir_A[2:0]);
                        micro_data <= {29'b0, ir_A[8:6]};
                    end
                    else if(ir_A[13:11] == 3'b100) begin
                        //MOV (immediate) T1
                        micro_code[`MICRO_CODE_MOV] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_set_flag <= !in_it_block(micro_it);
                        micro_register_rd <= convert_3_8(ir_A[10:8]);
                        micro_carry <= apsr_c;
                        micro_data <= {24'b0, ir_A[7:0]};
                    end
                    else if(ir_A[13:11] == 3'b101) begin
                        //CMP (immediate) T1
                        micro_code[`MICRO_CODE_CMP] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_register_rn <= convert_3_8(ir_A[10:8]);
                        micro_data <= {24'b0, ir_A[7:0]};
                    end
                    else if(ir_A[13:11] == 3'b110) begin
                        //ADD (immediate) T2
                        micro_code[`MICRO_CODE_ADD] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_set_flag <= !in_it_block(micro_it);
                        micro_register_rn <= convert_3_8(ir_A[10:8]);
                        micro_register_rd <= convert_3_8(ir_A[10:8]);
                        micro_data <= {24'b0, ir_A[7:0]};
                    end
                    else if(ir_A[13:11] == 3'b111) begin
                        //SUB (immediate) T2
                        micro_code[`MICRO_CODE_SUB] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_set_flag <= !in_it_block(micro_it);
                        micro_register_rn <= convert_3_8(ir_A[10:8]);
                        micro_register_rd <= convert_3_8(ir_A[10:8]);
                        micro_data <= {24'b0, ir_A[7:0]};
                    end
                    else begin
                        decode_error <= 1'b1;
                    end
                end
                else if(ir_A[15:10] == 6'b010000) begin
                    //Data processing
                    case(ir_A[9:6])
                        4'b0000:begin
                            //AND (register) T1
                            micro_code[`MICRO_CODE_AND] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_register_rn <= convert_3_8(ir_A[2:0]);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                        end
                        4'b0001:begin
                            //EOR (register) T1
                            micro_code[`MICRO_CODE_EOR] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_register_rn <= convert_3_8(ir_A[2:0]);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                        end
                        4'b0010:begin
                            //LSL (register) T1
                            micro_code[`MICRO_CODE_LSL] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                            micro_register_rn <= convert_3_8(ir_A[2:0]);
                        end
                        4'b0011:begin
                            //LSR (register) T1
                            micro_code[`MICRO_CODE_LSR] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                            micro_register_rn <= convert_3_8(ir_A[2:0]);
                        end
                        4'b0100:begin
                            //ASR (register) T1
                            micro_code[`MICRO_CODE_ASR] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                            micro_register_rn <= convert_3_8(ir_A[2:0]);
                        end
                        4'b0101:begin
                            //ADC (register) T1
                            micro_code[`MICRO_CODE_ADC] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_register_rn <= convert_3_8(ir_A[2:0]);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                        end
                        4'b0110:begin
                            //SBC (register) T1
                            micro_code[`MICRO_CODE_SBC] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                            micro_register_rn <= convert_3_8(ir_A[2:0]);
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_data <= {20'b0, `SRTYPE_LSL, 8'b0};
                        end
                        4'b0111:begin
                            //ROR (register)
                            micro_code[`MICRO_CODE_ROR] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                            micro_register_rn <= convert_3_8(ir_A[2:0]);
                        end
                        4'b1000:begin
                            //TST (register) T1
                            micro_code[`MICRO_CODE_TST] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_register_rn <= convert_3_8(ir_A[2:0]);
                        end
                        4'b1001:begin
                            //RSB (immediate) T1
                            micro_code[`MICRO_CODE_RSB] <= 1'b1;
                            micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rn <= convert_3_8(ir_A[5:3]);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                        end
                        4'b1010:begin
                            //CMP (register) T1
                            micro_code[`MICRO_CODE_CMP] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_register_rn <= convert_3_8(ir_A[2:0]);
                            micro_data <= {20'b0, `SRTYPE_LSL, 8'b0};
                        end
                        4'b1011:begin
                            //CMN (register) T1
                            micro_code[`MICRO_CODE_CMN] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_register_rn <= convert_3_8(ir_A[2:0]);
                            micro_data <= {20'b0, `SRTYPE_LSL, 8'b0};
                        end
                        4'b1100:begin
                            //ORR (register) T1
                            micro_code[`MICRO_CODE_ORR] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_register_rn <= convert_3_8(ir_A[2:0]);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                        end
                        4'b1101:begin
                            //MUL T1
                            micro_code[`MICRO_CODE_MUL] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rn <= convert_3_8(ir_A[5:3]);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                            micro_register_rm <= convert_3_8(ir_A[2:0]);
                        end
                        4'b1110:begin
                            //BIC (register) T1
                            micro_code[`MICRO_CODE_BIC] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                            micro_register_rn <= convert_3_8(ir_A[2:0]);
                        end
                        4'b1111:begin
                            //MVN (register) T1
                            micro_code[`MICRO_CODE_MVN] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= !in_it_block(micro_it);
                            micro_register_rd <= convert_3_8(ir_A[2:0]);
                            micro_register_rm <= convert_3_8(ir_A[5:3]);
                            micro_data <= {20'b0, `SRTYPE_LSL, 8'h0};
                        end
                        default:decode_error <= 1'b1;
                    endcase
                end
                else if(ir_A[15:10] == 6'b010001) begin
                    //ADD,CMP,MOV,BX,BLX
                    if(ir_A[9:8]==2'b00) begin
                        if(ir_A[6:3]==4'b1101) begin
                            //ADD (SP plus register) T1
                            micro_code[`MICRO_CODE_ADD] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_register_rn <= convert_4_16(4'b1101);
                            micro_register_rd <= convert_4_16({ir_A[7],ir_A[2:0]});
                            micro_register_rm <= convert_4_16({ir_A[7],ir_A[2:0]});
                            micro_data <= {20'b0, `SRTYPE_LSL, 8'b0};
                        end
                        else if(ir_A[7] && ir_A[3:0]==3'b101) begin
                            //ADD (SP plus register) T2
                            micro_code[`MICRO_CODE_ADD] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_register_rd <= convert_4_16(4'b1101);
                            micro_register_rn <= convert_4_16(4'b1101);
                            micro_register_rm <= convert_4_16(ir_A[6:3]);
                            micro_data <= {20'b0, `SRTYPE_LSL, 8'b0};
                        end
                        else begin
                            //ADD (register) T2
                            micro_code[`MICRO_CODE_ADD] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_register_rd <= convert_4_16({ir_A[7],ir_A[2:0]});
                            micro_register_rn <= convert_4_16({ir_A[7],ir_A[2:0]});
                            micro_register_rm <= convert_4_16(ir_A[6:3]);
                            micro_data <= {20'b0, `SRTYPE_LSL, 8'b0};
                        end
                    end
                    else if(ir_A[9:6]==4'b0101 || ir_A[9:7]==3'b011) begin
                        //CMP (register) T2
                        micro_code[`MICRO_CODE_CMP] <= 1'b1;
                        micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                        micro_register_rm <= convert_4_16(ir_A[6:3]);
                        micro_register_rn <= convert_4_16({ir_A[7], ir_A[2:0]});
                        micro_data <= {20'b0, `SRTYPE_LSL, 8'b0};
                    end
                    else if(ir_A[9:8]==2'b10) begin
                        //MOV (register) T1
                        micro_code[`MICRO_CODE_MOV] <= 1'b1;
                        micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                        micro_register_rd <= convert_4_16({ir_A[7], ir_A[2:0]});
                        micro_register_rm <= convert_4_16(ir_A[6:3]);
                    end
                    else if(ir_A[9:7]==3'b110) begin
                        //BX T1
                        micro_code[`MICRO_CODE_BX] <= 1'b1;
                        micro_register_rm <= convert_4_16(ir_A[6:3]);
                    end
                    else if(ir_A[9:7]==3'b111) begin
                        //BLX (register) T1
                        micro_code[`MICRO_CODE_BLX] <= 1'b1;
                        micro_register_rm <= convert_4_16(ir_A[6:3]);
                    end
                    else begin
                        decode_error <= 1'b1;
                    end
                end
                else if(ir_A[15:11] == 5'b01001) begin
                    //LDR (literal) T1
                    micro_code[`MICRO_CODE_LDR] <= 1'b1;
                    micro_type[`MICRO_TYPE_LITERAL] <= 1'b1;
                    micro_add <= 1'b1;
                    micro_register_rt <= convert_3_8(ir_A[10:8]);
                    micro_data <= {22'b0, ir_A[7:0], 2'b0};
                end
                else if(ir_A[15:12] == 4'b0101 || ir_A[15:13] == 3'b011 || ir_A[15:13] == 3'b100) begin
                    //Load/store single data item
                    if(ir_A[15:9] == 7'b0101000) begin
                        //STR (register) T1
                        micro_code[`MICRO_CODE_STR] <= 1'b1;
                        micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                        micro_index <= 1'b1;
                        micro_add <= 1'b1;
                        micro_register_rm <= convert_3_8(ir_A[8:6]);
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rt <= convert_3_8(ir_A[2:0]);
                    end
                    else if(ir_A[15:9] == 7'b0101001) begin
                        //STRH (register) T1
                        micro_code[`MICRO_CODE_STRH] <= 1'b1;
                        micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                        micro_index <= 1'b1;
                        micro_add <= 1'b1;
                        micro_register_rm <= convert_3_8(ir_A[8:6]);
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rt <= convert_3_8(ir_A[2:0]);
                    end
                    else if(ir_A[15:9] == 7'b0101010) begin
                        //STRB (register) T1
                        micro_code[`MICRO_CODE_STRB] <= 1'b1;
                        micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                        micro_register_rm <= convert_3_8(ir_A[8:6]);
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rt <= convert_3_8(ir_A[2:0]);
                        micro_index <= 1'b1;
                        micro_add <= 1'b1;
                    end
                    else if(ir_A[15:9] == 7'b0101011) begin
                        //LDRSB (register) T1
                        micro_code[`MICRO_CODE_LDRSB] <= 1'b1;
                        micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                        micro_register_rt <= convert_3_8(ir_A[3:0]);
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rm <= convert_3_8(ir_A[8:6]);
                        micro_index <= 1'b1;
                        micro_add <= 1'b1;
                    end
                    else if(ir_A[15:9] == 7'b0101100) begin
                        //LDR (register) T1
                        micro_code[`MICRO_CODE_LDR] <= 1'b1;
                        micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                        micro_register_rm <= convert_3_8(ir_A[8:6]);
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rt <= convert_3_8(ir_A[2:0]);
                        micro_index <= 1'b1;
                        micro_add <= 1'b1;
                    end
                    else if(ir_A[15:9] == 7'b0101101) begin
                        //LDRH (register) T1
                        micro_code[`MICRO_CODE_LDRH] <= 1'b1;
                        micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                        micro_register_rm <= convert_3_8(ir_A[8:6]);
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rt <= convert_3_8(ir_A[2:0]);
                        micro_index <= 1'b1;
                        micro_add <= 1'b1;
                    end
                    else if(ir_A[15:9] == 7'b0101110) begin
                        //LDRB (register) T1
                        micro_code[`MICRO_CODE_LDRB] <= 1'b1;
                        micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                        micro_register_rm <= convert_3_8(ir_A[8:6]);
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rt <= convert_3_8(ir_A[2:0]);
                        micro_index <= 1'b1;
                        micro_add <= 1'b1;
                    end
                    else if(ir_A[15:9] == 7'b0101111) begin
                        //LDRSH (register)
                        decode_error <= 1'b1;
                    end
                    else if(ir_A[15:11] == 5'b01100) begin
                        //STR (immediate) T1
                        micro_code[`MICRO_CODE_STR] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_add <= 1'b1;
                        micro_index <= 1'b1;
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rt <= convert_3_8(ir_A[2:0]);
                        micro_data <= {25'b0, ir_A[10:6], 2'b0};
                    end
                    else if(ir_A[15:11] == 5'b01101) begin
                        //LDR (immediate) T1
                        micro_code[`MICRO_CODE_LDR] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rt <= convert_3_8(ir_A[2:0]);
                        micro_data <= {25'b0, ir_A[10:6], 2'b0};
                        micro_index <= 1'b1;
                        micro_add <= 1'b1;
                    end
                    else if(ir_A[15:11] == 5'b01110) begin
                        //STRB (immediate) T1
                        micro_code[`MICRO_CODE_STRB] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_add <= 1'b1;
                        micro_index <= 1'b1;
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rt <= convert_3_8(ir_A[2:0]);
                        micro_data <= {27'b0, ir_A[10:6]};
                    end
                    else if(ir_A[15:11] == 5'b01111) begin
                        //LDRB (immediate) T1
                        micro_code[`MICRO_CODE_LDRB] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rt <= convert_3_8(ir_A[2:0]);
                        micro_data <= {27'b0, ir_A[10:6]};
                        micro_index <= 1'b1;
                        micro_add <= 1'b1;
                    end
                    else if(ir_A[15:11] == 5'b10000) begin
                        //STRH (immediate) T1
                        micro_code[`MICRO_CODE_STRH] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_index <= 1'b1;
                        micro_add <= 1'b1;
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rt <= convert_3_8(ir_A[2:0]);
                        micro_data <= {24'b0, ir_A[10:6], 1'b0};
                    end
                    else if(ir_A[15:11] == 5'b10001) begin
                        //LDRH (immediate) T1
                        micro_code[`MICRO_CODE_LDRH] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_register_rn <= convert_3_8(ir_A[5:3]);
                        micro_register_rt <= convert_3_8(ir_A[2:0]);
                        micro_data <= {26'b0, ir_A[10:6],1'b0};
                        micro_index <= 1'b1;
                        micro_add <= 1'b1;
                    end
                    else if(ir_A[15:11] == 5'b10010) begin
                        //STR (immediate) T2
                        micro_code[`MICRO_CODE_STR] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_add <= 1'b1;
                        micro_index <= 1'b1;
                        micro_register_rn <= convert_4_16(4'd13);
                        micro_register_rt <= convert_3_8(ir_A[10:8]);
                        micro_data <= {22'b0, ir_A[7:0], 2'b0};
                    end
                    else if(ir_A[15:11] == 5'b10011) begin
                        //LDR (immediate) T2
                        micro_code[`MICRO_CODE_LDR] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_register_rn[`REGISTER_CODE_SP] <= 1'b1;
                        micro_register_rt <= convert_3_8(ir_A[10:8]);
                        micro_data <= {22'b0, ir_A[7:0], 2'b0};
                        micro_index <= 1'b1;
                        micro_add <= 1'b1;
                    end
                    else begin
                        decode_error <= 1'b1;
                    end
                end
                else if(ir_A[15:11] == 5'b10100) begin
                    //ADR T1
                    micro_code[`MICRO_CODE_ADR] <= 1'b1;
                    micro_add <= 1'b1;
                    micro_register_rd <= convert_3_8(ir_A[10:8]);
                    micro_data <= {22'b0, ir_A[7:0], 2'b0};
                end
                else if(ir_A[15:11] == 5'b10101) begin
                    //ADD (SP plus immediate) T1
                    micro_code[`MICRO_CODE_ADD] <= 1'b1;
                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                    micro_register_rn <= convert_4_16(4'b1101);
                    micro_register_rd <= convert_3_8(ir_A[10:8]);
                    micro_data <= {22'b0, ir_A[7:0], 2'b0};
                end
                else if(ir_A[15:12] == 4'b1011) begin
                    //Miscellaneous 16-bit instructions
                    if(ir_A[11:5] == 7'b0110011) begin
                        //CPS
                        decode_error <= 1'b1;
                    end
                    else if(ir_A[11:7] ==5'b00000) begin
                        //ADD (SP plus immediate) T2
                        micro_code[`MICRO_CODE_ADD] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_register_rn <= convert_4_16(4'b1101);
                        micro_register_rd <= convert_4_16(4'b1101);
                        micro_data <= {23'b0, ir_A[6:0], 2'b0};
                    end
                    else if(ir_A[11:7] ==5'b00001) begin
                        //SUB (SP minus immediate) T1
                        micro_code[`MICRO_CODE_SUB] <= 1'b1;
                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                        micro_register_rn <= convert_4_16(4'b1101);
                        micro_register_rd <= convert_4_16(4'b1101);
                        micro_data <= {23'b0, ir_A[6:0], 2'b0};
                    end
                    else if(!ir_A[10] && ir_A[8]) begin
                        //CBNZ, CBZ T1
                        micro_code[`MICRO_CODE_CBNZ_CBZ] <= 1'b1;
                        micro_index <= ir_A[11];
                        micro_register_rn <= convert_3_8(ir_A[2:0]);
                        micro_data <= {25'b0, ir_A[9], ir_A[7:3], 1'b0};
                    end
                    else if(ir_A[11:6] ==6'b001000) begin
                        //SXTH
                        decode_error <= 1'b1;
                    end
                    else if(ir_A[11:6] ==6'b001001) begin
                        //SXTB T1
                        micro_code[`MICRO_CODE_SXTB] <= 1'b1;
                        micro_register_rm <= convert_3_8(ir_A[5:3]);
                        micro_register_rd <= convert_3_8(ir_A[2:0]);
                    end
                    else if(ir_A[11:6] == 6'b001010) begin
                        //UXTH
                        decode_error <= 1'b1;
                    end
                    else if(ir_A[11:6] == 6'b001011) begin
                        //UXTB T1
                        micro_code[`MICRO_CODE_UXTB] <= 1'b1;
                        micro_register_rm <= convert_3_8(ir_A[5:3]);
                        micro_register_rd <= convert_3_8(ir_A[2:0]);
                    end
                    else if(ir_A[11:9] == 3'b010) begin
                        //PUSH T1
                        micro_code[`MICRO_CODE_PUSH] <= 1'b1;
                        micro_registers <= {1'b0, ir_A[8], 6'b0, ir_A[7:0]};
                    end
                    else if(ir_A[11:6] == 6'b101000) begin
                        //REV
                        decode_error <= 1'b1;
                    end
                    else if(ir_A[11:6] == 6'b101001) begin
                        //REV16
                        decode_error <= 1'b1;
                    end
                    else if(ir_A[11:6] == 6'b101011) begin
                        //REVSH
                        decode_error <= 1'b1;
                    end
                    else if(ir_A[11:9] == 3'b110) begin
                        //POP T1
                        micro_code[`MICRO_CODE_POP] <= 1'b1;
                        micro_registers <= {ir_A[8], 7'b0, ir_A[7:0]};
                    end
                    else if(ir_A[11:8] == 4'b1110) begin
                        //BKPT
                        decode_error <= 1'b1;
                    end
                    else if(ir_A[11:8] == 4'b1111) begin
                        //If-Then and hints
                        if(ir_A[3:0]!=4'b0) begin
                            //IT T1
                            micro_code[`MICRO_CODE_IT] <= 1'b1;
                            micro_it <= ir_A[7:0];
                        end
                        else begin
                            if(ir_A[7:4]==4'b0) begin
                                //NOP T1
                                micro_code[`MICRO_CODE_NOP] <= 1'b1;
                            end
                            else if(ir_A[7:4]==4'b0001) begin
                                //YIELD
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[7:4]==4'b0010) begin
                                //WFE
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[7:4]==4'b0011) begin
                                //WFI
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[7:4]==4'b0100) begin
                                //SEV
                                decode_error <= 1'b1;
                            end
                        end
                    end
                    else begin
                        decode_error <= 1'b1;
                    end
                end
                else if(ir_A[15:11] == 5'b11000) begin
                    //STM, STMIA, STMEA
                    micro_code[`MICRO_CODE_STMIA] <= 1'b1;
                    micro_register_rn <= convert_3_8(ir_A[10:8]);
                    micro_registers <= {8'b0, ir_A[7:0]};
                    micro_wback <= 1'b1;
                end
                else if(ir_A[15:11] == 5'b11001) begin
                    //LDM, LDMIA, LDMFD T1
                    micro_code[`MICRO_CODE_LDMIA] <= 1'b1;
                    micro_register_rn <= convert_3_8(ir_A[10:8]);
                    micro_registers <= {8'b0, ir_A[7:0]};
                    micro_wback <= !ir_A[ir_A[10:8]];
                end
                else if(ir_A[15:12] == 4'b1101) begin
                    //B,UDF,SVC
                    if(ir_A[11:8]==4'b1110) begin
                        //UDF
                        decode_error <= 1'b1;
                    end if(ir_A[11:8]==4'b1111) begin
                        //SVC
                        decode_error <= 1'b1;
                    end
                    else begin
                        //B T1
                        micro_code[`MICRO_CODE_B] <= 1'b1;
                        micro_cond <= ir_A[11:8];
                        micro_data <= {{23{ir_A[7]}}, ir_A[7:0], 1'b0};
                    end
                end
                else if(ir_A[15:11] == 5'b11100) begin
                    //B T2
                    micro_code[`MICRO_CODE_B] <= 1'b1;
                    micro_data <= {{20{ir_A[10]}}, ir_A[10:0], 1'b0};
                end
                else begin
                    decode_error <= 1'b1;
                end
            end
            else begin
                micro_thumb32 <= 1'b1;
                if(ir_A[12:11]==2'b01) begin
                    if(ir_A[10:9] == 2'b00 && ir_A[6] == 1'b0) begin
                        //Load Multiple and Store Multiple
                        if(ir_A[8:7] == 2'b01) begin
                            if(ir_A[4]) begin
                                if(ir_A[5] && ir_A[3:0]==4'b1101) begin
                                    //POP T2
                                    micro_code[`MICRO_CODE_POP] <= 1'b1;
                                    micro_registers <= {ir_B[15:14], 1'b0, ir_B[12:0]};
                                end
                                else begin
                                    //LDM, LDMIA, LDMFD T2
                                    micro_code[`MICRO_CODE_LDMIA] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_registers <= {ir_B[15:14], 1'b0, ir_B[12:0]};
                                    micro_wback <= ir_A[5];
                                end
                            end
                            else begin
                                //STM, STMIA, STMEA
                                micro_code[`MICRO_CODE_STMIA] <= 1'b1;
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_registers <= {1'b0, ir_B[14], 1'b0, ir_B[12:0]};
                                micro_wback <= ir_A[5];
                            end
                        end
                        else if(ir_A[8:7] == 2'b10) begin
                            if(ir_A[4]) begin
                                //LDMDB, LDMEA
                                decode_error <= 1'b1;
                            end
                            else begin
                                if(ir_A[5] && ir_A[3:0]==4'b1101) begin
                                    //PUSH T2
                                    micro_code[`MICRO_CODE_PUSH] <= 1'b1;
                                    micro_registers <= {1'b0, ir_B[14], 1'b0, ir_B[12:0]};
                                end
                                else begin
                                    //STMDB, STMFD
                                    decode_error <= 1'b1;
                                end
                            end
                        end
                        else begin
                            decode_error <= 1'b1;
                        end
                    end
                    else if(ir_A[10:9] == 2'b00 && ir_A[6] == 1'b1) begin
                        //Load/store dual or exclusive, table branch
                        if(ir_A[8:7]==2'b00 && ir_A[5:4]==2'b00) begin
                            //STREX
                            decode_error <= 1'b1;
                        end
                        else if(ir_A[8:7]==2'b00 && ir_A[5:4]==2'b01) begin
                            //LDREX
                            decode_error <= 1'b1;
                        end
                        else if((!ir_A[8] && ir_A[5:4]==2'b10) || (ir_A[8] && !ir_A[4])) begin
                            //STRD (immediate)
                            micro_code[`MICRO_CODE_STRD] <= 1'b1;
                            micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rt <= convert_4_16(ir_B[15:12]);
                            micro_register_rm <= convert_4_16(ir_B[11:8]);
                            micro_data <= {22'b0, ir_B[7:0], 2'b0};
                            micro_index <= ir_A[8];
                            micro_add <= ir_A[7];
                            micro_wback <= ir_A[5];
                        end
                        else if((!ir_A[8] && ir_A[5:4]==2'b11) || (ir_A[8] && ir_A[4])) begin
                            if(ir_A[3:0]==4'b1111) begin
                                //LDRD (literal) T1
                                micro_code[`MICRO_CODE_LDRD] <= 1'b1;
                                micro_type[`MICRO_TYPE_LITERAL] <= 1'b1;
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_register_rm <= convert_4_16(ir_B[11:8]);
                                micro_data <= {22'b0, ir_B[7:0], 2'b0};
                                micro_add <= ir_A[7];
                            end
                            else begin
                                //LDRD (immediate) T1
                                micro_code[`MICRO_CODE_LDRD] <= 1'b1;
                                micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_register_rm <= convert_4_16(ir_B[11:8]);
                                micro_data <= {22'b0, ir_B[7:0], 2'b0};
                                micro_index <= ir_A[8];
                                micro_add <= ir_A[7];
                                micro_wback <= ir_A[5];
                            end
                        end
                        else if(ir_A[8:7]==2'b01 && ir_A[5:4]==2'b00 && ir_B[7:4]==4'b0100) begin
                            //STREXB
                            decode_error <= 1'b1;
                        end
                        else if(ir_A[8:7]==2'b01 && ir_A[5:4]==2'b00 && ir_B[7:4]==4'b0101) begin
                            //STREXH
                            decode_error <= 1'b1;
                        end
                        else if(ir_A[8:7]==2'b01 && ir_A[5:4]==2'b01 && ir_B[7:4]==4'b0000) begin
                            //TBB
                            micro_code[`MICRO_CODE_TBB] <= 1'b1;
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                        end
                        else if(ir_A[8:7]==2'b01 && ir_A[5:4]==2'b01 && ir_B[7:4]==4'b0001) begin
                            //TBH
                            decode_error <= 1'b1;
                        end
                        else if(ir_A[8:7]==2'b01 && ir_A[5:4]==2'b01 && ir_B[7:4]==4'b0100) begin
                            //LDREXB
                            decode_error <= 1'b1;
                        end
                        else if(ir_A[8:7]==2'b01 && ir_A[5:4]==2'b01 && ir_B[7:4]==4'b0100) begin
                            //LDREXH
                            decode_error <= 1'b1;
                        end
                        else begin
                            decode_error <= 1'b1;
                        end
                    end
                    else if(ir_A[10:9] == 2'b01) begin
                        //Data processing (shifted register)
                        if(ir_A[8:5]==4'b0000) begin
                            if(ir_B[11:8]!=4'b1111) begin
                                //AND (register) T2
                                micro_code[`MICRO_CODE_AND] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_set_flag <= ir_A[4];
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                            end
                            else if(ir_A[4]) begin
                                //TST (register) T2
                                micro_code[`MICRO_CODE_TST] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[8:5]==4'b0001) begin
                            //BIC (register) T2
                            micro_code[`MICRO_CODE_BIC] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= ir_A[4];
                            micro_register_rd <= convert_4_16(ir_B[11:8]);
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                            micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                        end
                        else if(ir_A[8:5]==4'b0010) begin
                            if(ir_A[3:0]!=4'b1111) begin
                                //ORR (register) T2
                                micro_code[`MICRO_CODE_ORR] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_set_flag <= ir_A[4];
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                            end
                            else begin
                                //Move register and immediate shifts
                                if(ir_B[5:4]==2'b00) begin
                                    if(ir_B[14:12]==3'b000 && ir_B[7:6]==2'b00) begin
                                        //MOV (register) T3
                                        micro_code[`MICRO_CODE_MOV] <= 1'b1;
                                        micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                        micro_set_flag <= ir_A[4];
                                        micro_register_rd <= convert_4_16(ir_B[11:8]);
                                        micro_register_rm <= convert_4_16(ir_B[3:0]);
                                    end
                                    else begin
                                        //LSL (immediate) T2
                                        micro_code[`MICRO_CODE_LSL] <= 1'b1;
                                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                        micro_set_flag <= ir_A[4];
                                        micro_register_rm <= convert_4_16(ir_B[3:0]);
                                        micro_register_rd <= convert_4_16(ir_B[11:8]);
                                        micro_data <= {24'b0, decode_imm_shift_n(`SRTYPE_LSL, {ir_B[14:12], ir_B[7:6]})};
                                    end
                                end
                                else if(ir_B[5:4]==2'b01) begin
                                    //LSR (immediate) T2
                                    micro_code[`MICRO_CODE_LSR] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_set_flag <= ir_A[4];
                                    micro_register_rm <= convert_4_16(ir_B[3:0]);
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_data <= {24'b0, decode_imm_shift_n(`SRTYPE_LSR, {ir_B[14:12], ir_B[7:6]})};
                                end
                                else if(ir_B[5:4]==2'b10) begin
                                    //ASR (immediate) T2
                                    micro_code[`MICRO_CODE_ASR] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_set_flag <= ir_A[4];
                                    micro_register_rm <= convert_4_16(ir_B[3:0]);
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_data <= {24'b0, decode_imm_shift_n(`SRTYPE_ASR, {ir_B[14:12], ir_B[7:6]})};
                                end
                                else if(ir_B[5:4]==2'b11) begin
                                    if(ir_B[14:12]==3'b000 && ir_B[7:6]==2'b00) begin
                                        //RRX T1
                                        micro_code[`MICRO_CODE_RRX] <= 1'b1;
                                        micro_set_flag <= ir_A[4];
                                        micro_register_rm <= convert_4_16(ir_B[3:0]);
                                        micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    end
                                    else begin
                                        //ROR (immediate) T1
                                        micro_code[`MICRO_CODE_ROR] <= 1'b1;
                                        micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                        micro_set_flag <= ir_A[4];
                                        micro_register_rm <= convert_4_16(ir_B[3:0]);
                                        micro_register_rd <= convert_4_16(ir_B[11:8]);
                                        micro_data <= {24'b0, decode_imm_shift_n(`SRTYPE_ROR, {ir_B[14:12], ir_B[7:6]})};
                                    end
                                end
                                else begin
                                    decode_error <= 1'b1;
                                end
                            end
                        end
                        else if(ir_A[8:5]==4'b0011) begin
                            if(ir_A[3:0]!=4'b1111) begin
                                //ORN (register) T1
                                decode_error <= 1'b1;
                            end
                            else begin
                                //MVN (register) T2
                                micro_code[`MICRO_CODE_MVN] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_set_flag <= ir_A[4];
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                            end
                        end
                        else if(ir_A[8:5]==4'b0100) begin
                            if(ir_B[11:8]!=4'b1111) begin
                                //EOR (register) T2
                                micro_code[`MICRO_CODE_EOR] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_set_flag <= ir_A[4];
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                            end
                            else if(ir_A[4]) begin
                                //TEQ (register) T1
                                micro_code[`MICRO_CODE_TEQ] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[8:5]==4'b0110) begin
                            //PKHBT, PKHTB T1
                            decode_error <= 1'b1;
                        end
                        else if(ir_A[8:5]==4'b1000) begin
                            if(ir_B[11:8]==4'b1111 && ir_A[4]) begin
                                //CMN (register) T2
                                micro_code[`MICRO_CODE_CMP] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                            end
                            else if(ir_A[3:0]==4'b1101) begin
                                //ADD (SP plus register) T3
                                micro_code[`MICRO_CODE_ADD] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_set_flag <= ir_A[4];
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                            end
                            else begin
                                //ADD (register) T3
                                micro_code[`MICRO_CODE_ADD] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_set_flag <= ir_A[4];
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                            end
                        end
                        else if(ir_A[8:5]==4'b1010) begin
                            //ADC (register) T2
                            micro_code[`MICRO_CODE_ADC] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= ir_A[4];
                            micro_register_rd <= convert_4_16(ir_B[11:8]);
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                            micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                        end
                        else if(ir_A[8:5]==4'b1011) begin
                            //SBC (register) T2
                            micro_code[`MICRO_CODE_SBC] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= ir_A[4];
                            micro_register_rd <= convert_4_16(ir_B[11:8]);
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                            micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                        end
                        else if(ir_A[8:5]==4'b1101) begin
                            if(ir_B[11:8]==4'b1111 && ir_A[4]) begin
                                //CMP (register) T3
                                micro_code[`MICRO_CODE_CMP] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                            end
                            else if(ir_A[3:0]==4'b1101) begin
                                //SUB (SP minus register) T1
                                micro_code[`MICRO_CODE_SUB] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_set_flag <= ir_A[4];
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12], ir_B[7:6]})};
                            end
                            else begin
                                //SUB (register) T2
                                micro_code[`MICRO_CODE_SUB] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_set_flag <= ir_A[4];
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4], {ir_B[14:12],ir_B[7:6]})};
                            end
                        end
                        else if(ir_A[8:5]==4'b1110) begin
                            //RSB (register) T1
                            micro_code[`MICRO_CODE_RSB] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= ir_A[4];
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rd <= convert_4_16(ir_B[11:8]);
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                            micro_data <= {21'b0, decode_imm_shift_tn(ir_B[5:4],{ir_B[14:12],ir_B[7:6]})};
                        end
                        else begin
                            decode_error <= 1'b1;
                        end
                    end
                    else if(ir_A[10]) begin
                        //Coprocessor instructions on page
                        decode_error <= 1'b1;
                    end
                    else begin
                        decode_error <= 1'b1;
                    end
                end
                else if(ir_A[12:11] == 2'b10) begin
                    if(!ir_B[15]) begin
                        if(!ir_A[9]) begin
                            //Data processing (modified immediate)
                            if(ir_A[8:5]==4'b0000) begin
                                if(ir_B[11:8]!=4'b1111) begin
                                    //AND (immediate) T1
                                    micro_code[`MICRO_CODE_AND] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_set_flag <= ir_A[4];
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    {micro_carry, micro_data} <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                                end
                                else begin
                                    //TST (immediate)
                                    micro_code[`MICRO_CODE_TST] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    {micro_carry, micro_data} <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                                end
                            end
                            else if(ir_A[8:5]==4'b0001) begin
                                //BIC (immediate)
                                micro_code[`MICRO_CODE_BIC] <= 1'b1;
                                micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                micro_set_flag <= ir_A[4];
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                {micro_carry, micro_data} <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                            end
                            else if(ir_A[8:5]==4'b0010) begin
                                if(ir_A[3:0]!=4'b1111) begin
                                    //ORR (immediate) T1
                                    micro_code[`MICRO_CODE_ORR] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_set_flag <= ir_A[4];
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    {micro_carry, micro_data} <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                                end
                                else begin
                                    //MOV (immediate) T2
                                    micro_code[`MICRO_CODE_MOV] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_set_flag <= ir_A[4];
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    {micro_carry, micro_data} <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                                end
                            end
                            else if(ir_A[8:5]==4'b0011) begin
                                if(ir_A[3:0]!=4'b1111) begin
                                    //ORN (immediate)
                                    decode_error <= 1'b1;
                                end
                                else begin
                                    //MVN (immediate) T1
                                    micro_code[`MICRO_CODE_MVN] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_set_flag <= ir_A[4];
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    {micro_carry, micro_data}  <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                                end
                            end
                            else if(ir_A[8:5]==4'b0100) begin
                                if(ir_B[11:8]!=4'b1111) begin
                                    //EOR (immediate)
                                    micro_code[`MICRO_CODE_EOR] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_set_flag <= ir_A[4];
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    {micro_carry, micro_data} <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                                end
                                else begin
                                    //TEQ (immediate) T1
                                    micro_code[`MICRO_CODE_TEQ] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    {micro_carry, micro_data} <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                                end
                            end
                            else if(ir_A[8:5]==4'b1000) begin
                                if(ir_B[11:8]==4'b1111) begin
                                    //CMN (immediate) T1
                                    micro_code[`MICRO_CODE_CMN] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_data <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                                end
                                else if(ir_A[3:0]==4'b1101) begin
                                    //ADD (SP plus immediate) T3
                                    micro_code[`MICRO_CODE_ADD] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_set_flag <= ir_A[4];
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_data <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                                end
                                else begin
                                    //ADD (immediate) T3
                                    micro_code[`MICRO_CODE_ADD] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_set_flag <= ir_A[4];
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_data <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                                end
                            end
                            else if(ir_A[8:5]==4'b1010) begin
                                //ADC (immediate) T1
                                micro_code[`MICRO_CODE_ADC] <= 1'b1;
                                micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                micro_set_flag <= ir_A[4];
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                            end
                            else if(ir_A[8:5]==4'b1011) begin
                                //SBC (immediate)
                                micro_code[`MICRO_CODE_SBC] <= 1'b1;
                                micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                micro_set_flag <= ir_A[4];
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                            end
                            else if(ir_A[8:5]==4'b1101) begin
                                if(ir_B[11:8]==4'b1111 && ir_A[4]) begin
                                    //CMP (immediate) T2
                                    micro_code[`MICRO_CODE_CMP] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_data <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                                end
                                else if(ir_A[3:0]==4'b1101) begin
                                    //SUB (SP minus immediate) T2
                                    micro_code[`MICRO_CODE_SUB] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_set_flag <= ir_A[4];
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_data <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                                end
                                else begin
                                    //SUB (immediate) T3
                                    micro_code[`MICRO_CODE_SUB] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_set_flag <= ir_A[4];
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_data <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                                end
                            end
                            else if(ir_A[8:5]==4'b1110) begin
                                //RSB (immediate) T2
                                micro_code[`MICRO_CODE_RSB] <= 1'b1;
                                micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                micro_set_flag <= ir_A[4];
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= thumb_expand_imm_c({ir_A[10], ir_B[14:12], ir_B[7:0]}, apsr_c);
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else begin
                            //Data processing (modified immediate)
                            if(ir_A[8:4]==5'b00000) begin
                                if(ir_A[3:0]==4'b1111) begin
                                    //ADR T3
                                    micro_code[`MICRO_CODE_ADR] <= 1'b1;
                                    micro_add <= 1'b1;
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_data <= {20'b0, ir_A[10], ir_B[14:12], ir_B[7:0]};
                                end
                                else if(ir_A[3:0]==4'b1101) begin
                                    //ADD (SP plus immediate) T4
                                    micro_code[`MICRO_CODE_ADD] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_data <= {20'b0, ir_A[10], ir_B[14:12], ir_B[7:0]};
                                end
                                else begin
                                    //ADD (immediate) T4
                                    micro_code[`MICRO_CODE_ADD] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_data <= {20'b0, ir_A[10], ir_B[14:12], ir_B[7:0]};
                                end
                            end
                            else if(ir_A[8:4]==5'b00100) begin
                                //MOV (immediate) T3
                                micro_code[`MICRO_CODE_MOV] <= 1'b1;
                                micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= {16'b0, ir_A[3:0], ir_A[10], ir_B[14:12], ir_B[7:0]};
                            end
                            else if(ir_A[8:4]==5'b01010) begin
                                if(ir_A[3:0]==4'b1111) begin
                                    //ADR T2
                                    micro_code[`MICRO_CODE_ADR] <= 1'b1;
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_data <= {20'b0, ir_A[10], ir_B[14:12], ir_B[7:0]};
                                end
                                else if(ir_A[3:0]==4'b1101) begin
                                    //SUB (SP minus immediate) T3
                                    micro_code[`MICRO_CODE_SUB] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_data <= {20'b0, ir_A[10], ir_B[14:12], ir_B[7:0]};
                                end
                                else begin
                                    //SUB (immediate) T4
                                    micro_code[`MICRO_CODE_SUB] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_data <= {20'b0, ir_A[10], ir_B[14:12], ir_B[7:0]};
                                end
                            end
                            else if(ir_A[8:4]==5'b01100) begin
                                //MOVT T1
                                micro_code[`MICRO_CODE_MOVT] <= 1'b1;
                                micro_register_rm <= convert_4_16(ir_B[11:8]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= {16'b0, ir_A[3:0], ir_A[10], ir_B[14:12], ir_B[7:0]};
                            end
                            else if(ir_A[8:4]==5'b10000 || ir_A[8:4]==5'b10010) begin
                                //SSAT
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8:4]==5'b10010) begin
                                //SSAT16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8:4]==5'b10100) begin
                                //SBFX
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8:4]==5'b10110) begin
                                if(ir_A[3:0]!=4'b1111) begin
                                    //BFI
                                    decode_error <= 1'b1;
                                end
                                else begin
                                    //BFC T1
                                    micro_code[`MICRO_CODE_BFC] <= 1'b1;
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_register_rn <= convert_4_16(ir_B[11:8]);
                                    micro_data[7:0] <= {3'b0, ir_B[14:12], ir_B[7:6]};
                                    micro_data[15:8] <= {3'b0, ir_B[4:0]};
                                    micro_data[31:16] <= {11'b0,ir_B[4:0] - {ir_B[14:12], ir_B[7:6]}};
                                end
                            end
                            else if(ir_A[8:4]==5'b11000 || ir_A[8:4]==5'b11010) begin
                                //USAT
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8:4]==5'b11010) begin
                                //USAT16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8:4]==5'b11100) begin
                                //UBFX
                                micro_code[`MICRO_CODE_UBFX] <= 1'b1;
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data[7:0] <= {3'b0, ir_B[14:12], ir_B[7:6]};
                                micro_data[15:8] <= {3'b0, ir_B[4:0]} + 8'b1;
                                micro_data[23:16] <= 32'd31 - ({ir_B[14:12], ir_B[7:6]} + ir_B[4:0]);
                                micro_data[31:24] <= 32'd31 - ir_B[4:0];
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                    end
                    else begin
                        if(!ir_B[14] && !ir_B[12] && ir_A[9:7]!=3'b111) begin
                            //B T3
                            micro_code[`MICRO_CODE_B] <= 1'b1;
                            micro_cond <= ir_A[9:6];
                            micro_data <= {{12{ir_A[10]}},ir_B[11],ir_B[13],ir_A[5:0],ir_B[10:0],1'b0};
                        end
                        else if(!ir_B[14] && !ir_B[12] && ir_A[10:5]==6'b011100) begin
                            //MSR
                            decode_error <= 1'b1;
                        end
                        else if(!ir_B[14] && !ir_B[12] && ir_A[10:4]==7'b0111010) begin
                            //Hint instructions
                            if(ir_B[10:8]==3'b0) begin
                                if(ir_B[7:0]==8'b00000000) begin
                                    //NOP T2
                                    micro_code[`MICRO_CODE_NOP] <= 1'b1;
                                end
                                else if(ir_B[7:0]==8'b00000001) begin
                                    //YIELD
                                    decode_error <= 1'b1;
                                end
                                else if(ir_B[7:0]==8'b00000010) begin
                                    //WFE
                                    decode_error <= 1'b1;
                                end
                                else if(ir_B[7:0]==8'b00000011) begin
                                    //WFI
                                    decode_error <= 1'b1;
                                end
                                else if(ir_B[7:0]==8'b00000100) begin
                                    //SEV
                                    decode_error <= 1'b1;
                                end
                                else if(ir_B[7:0]==8'b00010100) begin
                                    //CSDB
                                    decode_error <= 1'b1;
                                end
                                else if(ir_B[7:4]==4'b1111) begin
                                    //DBG
                                    decode_error <= 1'b1;
                                end
                                else begin
                                    decode_error <= 1'b1;
                                end
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(!ir_B[14] && !ir_B[12] && ir_A[10:4]==7'b0111011) begin
                            //Miscellaneous control instructions
                            if(ir_B[7:4]==4'b0010) begin
                                //CLREX
                                decode_error <= 1'b1;
                            end
                            else if(ir_B[7:4]==4'b0100) begin
                                if(ir_B[3:0]==4'b0000) begin
                                    //SSBB
                                    decode_error <= 1'b1;
                                end
                                else if(ir_B[3:0]==4'b0100) begin
                                    //PSSBB
                                    decode_error <= 1'b1;
                                end
                                else begin
                                    //CLREX
                                    decode_error <= 1'b1;
                                end
                            end
                            else if(ir_B[7:4]==4'b0101) begin
                                //DMB
                                decode_error <= 1'b1;
                            end
                            else if(ir_B[7:4]==4'b0110) begin
                                //ISB
                                decode_error <= 1'b1;
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(!ir_B[14] && !ir_B[12] && ir_A[10:5]==6'b011111) begin
                            //MRS
                            decode_error <= 1'b1;
                        end
                        else if(ir_B[14:12]==3'b010 && ir_A[10:4]==7'b1111111) begin
                            //UDF
                            decode_error <= 1'b1;
                        end
                        else if(!ir_B[14] && ir_B[12]) begin
                            //B T4
                            micro_code[`MICRO_CODE_B] <= 1'b1;
                            micro_data <= {{8{ir_A[10]}},!(ir_B[13]^ir_A[10]),!(ir_B[11]^ir_A[10]),ir_A[9:0],ir_B[10:0],1'b0};
                        end
                        else if(ir_B[14] && ir_B[12]) begin
                            //BL T1
                            micro_code[`MICRO_CODE_BL] <= 1'b1;
                            micro_data <= {{8{ir_A[10]}},!(ir_B[13]^ir_A[10]),!(ir_B[11]^ir_A[10]),ir_A[9:0],ir_B[10:0],1'b0};
                        end
                        else begin
                            decode_error <= 1'b1;
                        end
                    end
                end
                else if(ir_A[12:11] == 2'b11) begin
                    if(ir_A[10:8]==3'b000 && !ir_A[4]) begin
                        //Store single data item
                        if(ir_A[7:5]==3'b100) begin
                            //STRB (immediate) T2
                            micro_code[`MICRO_CODE_STRB] <= 1'b1;
                            micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                            micro_add <= 1'b1;
                            micro_index <= 1'b1;
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rt <= convert_4_16(ir_B[15:12]);
                            micro_data <= {20'b0, ir_B[11:0]};
                        end
                        else if(ir_A[7:5]==3'b000&&ir_B[11]) begin
                            //STRB (immediate) T3
                            micro_code[`MICRO_CODE_STRB] <= 1'b1;
                            micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                            micro_index <= ir_B[10];
                            micro_add <= ir_B[9];
                            micro_wback <= ir_B[8];
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rt <= convert_4_16(ir_B[15:12]);
                            micro_data <= {24'b0, ir_B[7:0]};
                        end
                        else if(ir_A[7:5]==3'b000&&!ir_B[11]) begin
                            //STRB (register) T2
                            micro_code[`MICRO_CODE_STRB] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_index <= 1'b1;
                            micro_add <= 1'b1;
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rt <= convert_4_16(ir_B[15:12]);
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                            micro_data <= {ir_B[5:4]};
                        end
                        else if(ir_A[7:5]==3'b101) begin
                            //STRH (immediate) T2
                            micro_code[`MICRO_CODE_STRH] <= 1'b1;
                            micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                            micro_index <= 1'b1;
                            micro_add <= 1'b1;
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rt <= convert_4_16(ir_B[15:12]);
                            micro_data <= {20'b0, ir_B[11:0]};
                        end
                        else if(ir_A[7:5]==3'b001&&ir_B[11]) begin
                            //STRH (immediate) T3
                            micro_code[`MICRO_CODE_STRH] <= 1'b1;
                            micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                            micro_index <= ir_B[10];
                            micro_add <= ir_B[9];
                            micro_wback <= ir_B[8];
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rt <= convert_4_16(ir_B[15:12]);
                            micro_data <= {24'b0, ir_B[7:0]};
                        end
                        else if(ir_A[7:5]==3'b001&&!ir_B[11]) begin
                            //STRH (register) T2
                            micro_code[`MICRO_CODE_STRH] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_index <= 1'b1;
                            micro_add <= 1'b1;
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rt <= convert_4_16(ir_B[15:12]);
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                            micro_data <= {ir_B[5:4]};
                        end
                        else if(ir_A[7:5]==3'b110) begin
                            //STR (immediate) T3
                            micro_code[`MICRO_CODE_STR] <= 1'b1;
                            micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                            micro_add <= 1'b1;
                            micro_index <= 1'b1;
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rt <= convert_4_16(ir_B[15:12]);
                            micro_data <= {20'b0, ir_B[11:0]};
                        end
                        else if(ir_A[7:5]==3'b010&&ir_B[11]) begin
                            if(ir_B[7:0]==8'b00000100) begin
                                //PUSH T3
                                micro_code[`MICRO_CODE_PUSH] <= 1'b1;
                                micro_registers <= convert_4_16(ir_B[15:12]);
                            end
                            else begin
                                //STR (immediate) T4
                                micro_code[`MICRO_CODE_STR] <= 1'b1;
                                micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                micro_index <= ir_B[10];
                                micro_add <= ir_B[9];
                                micro_wback <= ir_B[8];
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_data <= {24'b0, ir_B[7:0]};
                            end
                        end
                        else if(ir_A[7:5]==3'b010&&!ir_B[11]) begin
                            //STR (register) T2
                            micro_code[`MICRO_CODE_STR] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rt <= convert_4_16(ir_B[15:12]);
                            micro_data <= {30'b0, ir_B[5:4]};
                        end
                        else begin
                            decode_error <= 1'b1;
                        end
                    end
                    else if(ir_A[10:9]==2'b00 && ir_A[6:4]==3'b001) begin
                        //Load byte, memory hints
                        if(ir_A[3:0]==4'b1111 && ir_B[15:12]!=4'b1111) begin
                            if(!ir_A[8]) begin
                                //LDRB (literal) T1
                                micro_code[`MICRO_CODE_LDRB] <= 1'b1;
                                micro_type[`MICRO_TYPE_LITERAL] <= 1'b1;
                                micro_add <= ir_A[7];
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_data <=  {20'b0, ir_B[11:0]};
                            end
                            else if(ir_A[8]) begin
                                //LDRSB (literal) T1
                                micro_code[`MICRO_CODE_LDRSB] <= 1'b1;
                                micro_type[`MICRO_TYPE_LITERAL] <= 1'b1;
                                micro_add<=ir_A[7];
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_data <= {20'b0, ir_B[11:0]};
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[3:0]!=4'b1111 && ir_B[15:12]!=4'b1111) begin
                            if(ir_A[8:7]==2'b01) begin
                                //LDRB (immediate) T2
                                micro_code[`MICRO_CODE_LDRB] <= 1'b1;
                                micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_data <= {20'b0, ir_B[11:0]};
                                micro_index <= 1'b1;
                                micro_add <= 1'b1;
                            end
                            else if(ir_A[8:7]==2'b00 && ((ir_B[11] && ir_B[8]) || ir_B[11:8]==4'b1100)) begin
                                //LDRB (immediate) T3
                                micro_code[`MICRO_CODE_LDRB] <= 1'b1;
                                micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_data <= {24'b0, ir_B[7:0]};
                                micro_index <= ir_B[10];
                                micro_add <= ir_B[9];
                                micro_wback <= ir_B[8];
                            end
                            else if(ir_A[8:7]==2'b00 && ir_B[11:8]==4'b1110) begin
                                //LDRBT
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8:7]==2'b00 && ir_B[11:6]==6'b000000) begin
                                //LDRB (register) T2
                                micro_code[`MICRO_CODE_LDRB] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_data <= ir_B[5:4];
                                micro_index <= 1'b1;
                                micro_add <= 1'b1;
                            end
                            else if(ir_A[8:7] == 2'b11) begin
                                //LDRSB (immediate) T1
                                micro_code[`MICRO_CODE_LDRSB] <= 1'b1;
                                micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                micro_index<=1'b1;
                                micro_add<=1'b1;
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_data <= {20'b0, ir_B[11:0]};
                            end
                            else if(ir_A[8:7] == 2'b10 && ((ir_B[11] && ir_B[8]) || ir_B[11:8]==4'b1100)) begin
                                //LDRSB (immediate) T2
                                micro_code[`MICRO_CODE_LDRSB] <= 1'b1;
                                micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                micro_index<=ir_B[10];
                                micro_add<=ir_B[9];
                                micro_wback<=ir_B[8];
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_data <= {24'b0, ir_B[7:0]};
                            end
                            else if(ir_A[8:7]==2'b10 && ir_B[11:8]==4'b1110) begin
                                //LDRSBT
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8:7]==2'b10 && ir_B[11:6]==6'b000000) begin
                                //LDRSB (register) T2
                                micro_code[`MICRO_CODE_LDRSB] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_data <= {30'b0, ir_B[5:4]};
                                micro_index <= 1'b1;
                                micro_add <= 1'b1;
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[3:0]==4'b1111 && ir_B[15:12]==4'b1111) begin
                            if(!ir_A[8]) begin
                                //PLD (literal)
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8]) begin
                                //PLI (immediate, literal) T3
                                decode_error <= 1'b1;
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[3:0]!=4'b1111 && ir_B[15:12]==4'b1111) begin
                            if(ir_A[8:7]==2'b00 && ir_B[11:8]==4'b1100) begin
                                //PLD (immediate) T2
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8:7]==2'b01) begin
                                //PLD (immediate) T1
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8:7]==2'b00 && ir_B[11:6]==6'b000000) begin
                                //PLD (register)
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8:7]==2'b11) begin
                                //PLI (immediate, literal)
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8:7]==2'b10 && ir_B[11:8]==4'b1100) begin
                                //PLI (immediate, literal)
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8:7]==2'b10 && ir_B[11:6]==6'b000000) begin
                                //PLI (register)
                                decode_error <= 1'b1;
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else begin
                            decode_error <= 1'b1;
                        end
                    end
                    else if(ir_A[10:9]==2'b00 && ir_A[6:4]==3'b011) begin
                        //Load halfword, memory hints
                        if(ir_B[15:12]!=4'b1111) begin
                            if(ir_A[3:0]!=4'b1111) begin
                                if(!ir_A[8] && ir_A[3:0]==4'b1111) begin
                                    // LDRH (literal) T1
                                    micro_code[`MICRO_CODE_LDRH] <= 1'b1;
                                    micro_type[`MICRO_TYPE_LITERAL] <= 1'b1;
                                    micro_register_rt <= convert_4_16(ir_B[15:12]);
                                    micro_data <= {20'b0, ir_A[11:0]};
                                    micro_add <= 1'b1;
                                end
                                else if(ir_A[8:7]==2'b01) begin
                                    // LDRH (immediate) T2
                                    micro_code[`MICRO_CODE_LDRH] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_register_rt <= convert_4_16(ir_B[15:12]);
                                    micro_data <= {20'b0, ir_A[11:0]};
                                    micro_index <= 1'b1;
                                    micro_add <= 1'b1;
                                end
                                else if(ir_A[8:7]==2'b00 && ((ir_B[11] && ir_B[8])||ir_B[11:8]==4'b1100)) begin
                                    // LDRH (immediate) T3
                                    micro_code[`MICRO_CODE_LDRH] <= 1'b1;
                                    micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_register_rt <= convert_4_16(ir_B[15:12]);
                                    micro_data <= {24'b0, ir_A[7:0]};
                                    micro_index <= ir_B[10];
                                    micro_add <= ir_B[9];
                                    micro_wback <= ir_B[8];
                                end
                                else if(ir_A[8:7]==2'b00 && ir_B[11:6]==6'b0) begin
                                    // LDRH (register) T2
                                    micro_code[`MICRO_CODE_LDRH] <= 1'b1;
                                    micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_register_rt <= convert_4_16(ir_B[15:12]);
                                    micro_register_rm <= convert_4_16(ir_B[3:0]);
                                    micro_data <= ir_B[5:4];
                                    micro_index <= 1'b1;
                                    micro_add <= 1'b1;
                                end
                                else if(ir_A[8:7]==2'b00 && ir_B[11:8]==4'b1110) begin
                                    // LDRHT
                                end
                                else if(ir_A[8:7]==2'b10 && ((ir_B[11] && ir_B[8])||ir_B[11:8]==4'b1100)) begin
                                    // LDRSH (immediate) T2
                                end
                                else if(ir_A[8:7]==2'b11) begin
                                    // LDRSH (immediate) T1
                                end
                                else if(ir_A[8:7]==2'b10 && ir_B[11:6]==6'b0) begin
                                    // LDRSH (register)
                                end
                                else if(ir_A[8:7]==2'b10 && ir_B[11:8]==4'b1110) begin
                                    // LDRSHT
                                end
                                else begin
                                    decode_error <= 1'b1;
                                end
                            end
                            else if(ir_A[3:0]==4'b1111) begin
                                if(ir_A[8]) begin
                                    // LDRSH (literal)
                                end
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else begin
                            decode_error <= 1'b1;
                        end
                    end
                    else if(ir_A[10:9]==2'b00 && ir_A[6:4]==3'b101) begin
                        //Load word
                        if(ir_A[3:0]!=4'b1111) begin
                            if(ir_A[8:0]==9'b001011101 && ir_B[11:0] == 12'b101100000100) begin
                                //POP T3
                                micro_code[`MICRO_CODE_POP] <= 1'b1;
                                micro_registers <= convert_4_16(ir_B[15:12]);
                            end
                            else if(ir_A[8:7] == 2'b01) begin
                                //LDR (immediate) T3
                                micro_code[`MICRO_CODE_LDR] <= 1'b1;
                                micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_data <= {20'b0, ir_B[11:0]};
                                micro_index <= 1'b1;
                                micro_add <= 1'b1;
                            end
                            else if(ir_A[8:7]==2'b00 && ((ir_B[11]&&ir_B[8])||(ir_B[11:8]==4'b1100))) begin
                                //LDR (immediate) T4
                                micro_code[`MICRO_CODE_LDR] <= 1'b1;
                                micro_type[`MICRO_TYPE_IMMEDIATE] <= 1'b1;
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_data <= {24'b0, ir_B[7:0]};
                                micro_index <= ir_B[10];
                                micro_add <= ir_B[9];
                                micro_wback <= ir_B[8];
                            end
                            else if(ir_A[8:7]==2'b00 && ir_B[11:8]==4'b1110)begin
                                //LDRT
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[8:7]==2'b00 && ir_B[11:6]==6'b000000)begin
                                //LDR (register) T2
                                micro_code[`MICRO_CODE_LDR] <= 1'b1;
                                micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_data <= ir_B[5:4];
                                micro_index <= 1'b1;
                                micro_add <= 1'b1;
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else begin
                            if(!ir_A[8]) begin
                                //LDR (literal) T2
                                micro_code[`MICRO_CODE_LDR] <= 1'b1;
                                micro_type[`MICRO_TYPE_LITERAL] <= 1'b1;
                                micro_add <= ir_A[7];
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                                micro_data <=  {20'b0, ir_B[11:0]};
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                    end
                    else if(ir_A[10:8]==3'b010) begin
                        //Data processing (register)
                        if(ir_A[7:5]==3'b000 && ir_B[7:4]==4'b0000) begin
                            //LSL (register) T2
                            micro_code[`MICRO_CODE_LSL] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= ir_A[4];
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                            micro_register_rd <= convert_4_16(ir_B[11:8]);
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                        end
                        else if(ir_A[7:5]==3'b001 && ir_B[7:4]==4'b0000) begin
                            //LSR (register) T2
                            micro_code[`MICRO_CODE_LSR] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= ir_A[4];
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                            micro_register_rd <= convert_4_16(ir_B[11:8]);
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                        end
                        else if(ir_A[7:5]==3'b010 && ir_B[7:4]==4'b0000) begin
                            //ASR (register) T2
                            micro_code[`MICRO_CODE_ASR] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= ir_A[4];
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                            micro_register_rd <= convert_4_16(ir_B[11:8]);
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                        end
                        else if(ir_A[7:5]==3'b011 && ir_B[7:4]==4'b0000) begin
                            //ROR (register) T2
                            micro_code[`MICRO_CODE_ROR] <= 1'b1;
                            micro_type[`MICRO_TYPE_REGISTER] <= 1'b1;
                            micro_set_flag <= ir_A[4];
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                            micro_register_rd <= convert_4_16(ir_B[11:8]);
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                        end
                        else if(ir_A[7:4]==4'b0000 && ir_B[7]) begin
                            if(ir_A[3:0]!=4'b1111) begin
                                //SXTAH
                                decode_error <= 1'b1;
                            end
                            else begin
                                //SXTH
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[7:4]==4'b0001 && ir_B[7]) begin
                            if(ir_A[3:0]!=4'b1111) begin
                                //UXTAH
                                decode_error <= 1'b1;
                            end
                            else begin
                                //UXTH
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[7:4]==4'b0010 && ir_B[7]) begin
                            if(ir_A[3:0]!=4'b1111) begin
                                //SXTAB16
                                decode_error <= 1'b1;
                            end
                            else begin
                                //SXTB16
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[7:4]==4'b0011 && ir_B[7]) begin
                            if(ir_A[3:0]!=4'b1111) begin
                                //UXTAB16
                                decode_error <= 1'b1;
                            end
                            else begin
                                //UXTB16
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[7:4]==4'b0100 && ir_B[7]) begin
                            if(ir_A[3:0]!=4'b1111) begin
                                //SXTAB
                                decode_error <= 1'b1;
                            end
                            else begin
                                //SXTB T2
                                micro_code[`MICRO_CODE_SXTB] <= 1'b1;
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= {27'b0, ir_B[5:4],3'b0};
                            end
                        end
                        else if(ir_A[7:4]==4'b0101 && ir_B[7]) begin
                            if(ir_A[3:0]!=4'b1111) begin
                                //UXTAB
                                decode_error <= 1'b1;
                            end
                            else begin
                                //UXTB T2
                                micro_code[`MICRO_CODE_UXTB] <= 1'b1;
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_data <= {27'b0, ir_B[5:4],3'b0};
                            end
                        end
                        else if(ir_A[7] && ir_B[7:6]==2'b00) begin
                            //Parallel addition and subtraction, signed
                            if(ir_A[6:4]==3'b001 && ir_B[5:4]==2'b00) begin
                                //SADD16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b010 && ir_B[5:4]==2'b00) begin
                                //SASX
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b110 && ir_B[5:4]==2'b00) begin
                                //SSAX
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b101 && ir_B[5:4]==2'b00) begin
                                //SSUB16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b000 && ir_B[5:4]==2'b00) begin
                                //SADD8
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b100 && ir_B[5:4]==2'b00) begin
                                //SSUB8
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b001 && ir_B[5:4]==2'b01) begin
                                //QADD16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b010 && ir_B[5:4]==2'b01) begin
                                //QASX
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b110 && ir_B[5:4]==2'b01) begin
                                //QSAX
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b101 && ir_B[5:4]==2'b01) begin
                                //QSUB16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b000 && ir_B[5:4]==2'b01) begin
                                //QADD8
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b100 && ir_B[5:4]==2'b01) begin
                                //QSUB8
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b001 && ir_B[5:4]==2'b10) begin
                                //SHADD16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b010 && ir_B[5:4]==2'b10) begin
                                //SHASX
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b110 && ir_B[5:4]==2'b10) begin
                                //SHSAX
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b101 && ir_B[5:4]==2'b10) begin
                                //SHSUB16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b000 && ir_B[5:4]==2'b10) begin
                                //SHADD8
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b100 && ir_B[5:4]==2'b10) begin
                                //SHSUB8
                                decode_error <= 1'b1;
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[7] && ir_B[7:6]==2'b01) begin
                            //Parallel addition and subtraction, unsigned
                            if(ir_A[6:4]==3'b001 && ir_B[5:4]==2'b00) begin
                                //UADD16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b010 && ir_B[5:4]==2'b00) begin
                                //UASX
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b110 && ir_B[5:4]==2'b00) begin
                                //USAX
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b101 && ir_B[5:4]==2'b00) begin
                                //USUB16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b000 && ir_B[5:4]==2'b00) begin
                                //UADD8
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b100 && ir_B[5:4]==2'b00) begin
                                //USUB8
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b001 && ir_B[5:4]==2'b01) begin
                                //UQADD16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b010 && ir_B[5:4]==2'b01) begin
                                //UQASX
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b110 && ir_B[5:4]==2'b01) begin
                                //UQSAX
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b101 && ir_B[5:4]==2'b01) begin
                                //UQSUB16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b000 && ir_B[5:4]==2'b01) begin
                                //UQADD8
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b100 && ir_B[5:4]==2'b01) begin
                                //UQSUB8
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b001 && ir_B[5:4]==2'b10) begin
                                //UHADD16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b010 && ir_B[5:4]==2'b10) begin
                                //UHASX
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b110 && ir_B[5:4]==2'b10) begin
                                //UHSAX
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b101 && ir_B[5:4]==2'b10) begin
                                //UHSUB16
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b000 && ir_B[5:4]==2'b10) begin
                                //UHADD8
                                decode_error <= 1'b1;
                            end
                            else if(ir_A[6:4]==3'b100 && ir_B[5:4]==2'b10) begin
                                //UHSUB8
                                decode_error <= 1'b1;
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[7:6]==2'b10 && ir_B[7:6]==2'b10) begin
                            //Miscellaneous operations
                            if(ir_A[5:4]==2'b00) begin
                                if(ir_B[5:4]==2'b00) begin
                                    //QADD
                                    decode_error <= 1'b1;
                                end
                                else if(ir_B[5:4]==2'b01) begin
                                    //QDADD
                                    decode_error <= 1'b1;
                                end
                                else if(ir_B[5:4]==2'b10) begin
                                    //QSUB
                                    decode_error <= 1'b1;
                                end
                                else if(ir_B[5:4]==2'b11) begin
                                    //QDSUB
                                    decode_error <= 1'b1;
                                end
                                else begin
                                    decode_error <= 1'b1;
                                end
                            end
                            else if(ir_A[5:4]==2'b01) begin
                                if(ir_B[5:4]==2'b00) begin
                                    //REV
                                    decode_error <= 1'b1;
                                end
                                else if(ir_B[5:4]==2'b01) begin
                                    //REV16
                                    decode_error <= 1'b1;
                                end
                                else if(ir_B[5:4]==2'b10) begin
                                    //RBIT
                                    decode_error <= 1'b1;
                                end
                                else if(ir_B[5:4]==2'b11) begin
                                    //REVSH
                                    decode_error <= 1'b1;
                                end
                                else begin
                                    decode_error <= 1'b1;
                                end
                            end
                            else if(ir_A[5:4]==2'b10) begin
                                if(ir_B[5:4]==2'b00) begin
                                    //SEL
                                    decode_error <= 1'b1;
                                end
                                else begin
                                    decode_error <= 1'b1;
                                end
                            end
                            else if(ir_A[5:4]==2'b11) begin
                                if(ir_B[5:4]==2'b00) begin
                                    //CLZ T1
                                    micro_code[`MICRO_CODE_CLZ] <= 1'b1;
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_register_rm <= convert_4_16(ir_B[3:0]);
                                end
                                else begin
                                    decode_error <= 1'b1;
                                end
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                    end
                    else if(ir_A[10:7]==3'b0110) begin
                        //Multiply, multiply accumulate, and absolute difference
                        if(ir_A[6:4]==3'b000) begin
                            if(ir_B[5:4]==2'b00)begin
                                if(ir_B[15:12]!=4'b1111) begin
                                    //MLA T1
                                    micro_code[`MICRO_CODE_MLA] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_register_rm <= convert_4_16(ir_B[3:0]);
                                    micro_register_rt <= convert_4_16(ir_B[15:12]);
                                end
                                else begin
                                    //MUL T2
                                    micro_code[`MICRO_CODE_MUL] <= 1'b1;
                                    micro_register_rn <= convert_4_16(ir_A[3:0]);
                                    micro_register_rd <= convert_4_16(ir_B[11:8]);
                                    micro_register_rm <= convert_4_16(ir_B[3:0]);
                                end
                            end
                            else if(ir_B[5:4]==2'b01)begin
                                //MLS
                                micro_code[`MICRO_CODE_MLS] <= 1'b1;
                                micro_register_rn <= convert_4_16(ir_A[3:0]);
                                micro_register_rd <= convert_4_16(ir_B[11:8]);
                                micro_register_rm <= convert_4_16(ir_B[3:0]);
                                micro_register_rt <= convert_4_16(ir_B[15:12]);
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[6:4]==3'b001) begin
                            if(ir_B[15:12]!=4'b1111) begin
                                //SMLABB, SMLABT, SMLATB, SMLATT
                                decode_error <= 1'b1;
                            end
                            else begin
                                //SMULBB, SMULBT, SMULTB, SMULTT
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[6:4]==3'b010) begin
                            if(!ir_B[5])begin
                                if(ir_B[15:12]!=4'b1111) begin
                                    //SMLAD, SMLADX
                                    decode_error <= 1'b1;
                                end
                                else begin
                                    //SMUAD, SMUADX
                                    decode_error <= 1'b1;
                                end
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[6:4]==3'b011) begin
                            if(!ir_B[5])begin
                                if(ir_B[15:12]!=4'b1111) begin
                                    //SMLAWB, SMLAWT
                                    decode_error <= 1'b1;
                                end
                                else begin
                                    //SMULWB, SMULWT
                                    decode_error <= 1'b1;
                                end
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[6:4]==3'b100) begin
                            if(!ir_B[5])begin
                                if(ir_B[15:12]!=4'b1111) begin
                                    //SMLSD, SMLSDX
                                    decode_error <= 1'b1;
                                end
                                else begin
                                    //SMUSD, SMUSDX
                                    decode_error <= 1'b1;
                                end
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[6:4]==3'b101) begin
                            if(!ir_B[5])begin
                                if(ir_B[15:12]!=4'b1111) begin
                                    //SMMLA, SMMLAR
                                    decode_error <= 1'b1;
                                end
                                else begin
                                    //SMMUL, SMMULR
                                    decode_error <= 1'b1;
                                end
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[6:4]==3'b110) begin
                            if(!ir_B[5])begin
                                //SMMLS, SMMLSR
                                decode_error <= 1'b1;
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else if(ir_A[6:4]==3'b111) begin
                            if(ir_B[5:4]==2'b00)begin
                                if(ir_B[15:12]!=4'b1111) begin
                                    //USAD8
                                    decode_error <= 1'b1;
                                end
                                else begin
                                    //USADA8
                                    decode_error <= 1'b1;
                                end
                            end
                            else begin
                                decode_error <= 1'b1;
                            end
                        end
                        else begin
                            decode_error <= 1'b1;
                        end
                    end
                    else if(ir_A[10:7]==3'b0111) begin
                        //Long multiply, long multiply accumulate, and divide
                        if(ir_A[6:4]==3'b000 && ir_B[7:4]==4'b0000) begin
                            //SMULL
                            decode_error <= 1'b1;
                        end
                        else if(ir_A[6:4]==3'b001 && ir_B[7:4]==4'b1111) begin
                            //SDIV T1
                            micro_code[`MICRO_CODE_SDIV] <= 1'b1;
                            micro_register_rd <= convert_4_16(ir_B[11:8]);
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                        end
                        else if(ir_A[6:4]==3'b010 && ir_B[7:4]==4'b0000) begin
                            //UMULL T1
                            micro_code[`MICRO_CODE_UMULL] <= 1'b1;
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                            micro_register_rt <= convert_4_16(ir_B[15:12]);
                            micro_register_rd <= convert_4_16(ir_B[11:8]);
                        end
                        else if(ir_A[6:4]==3'b011 && ir_B[7:4]==4'b1111) begin
                            //UDIV
                            micro_code[`MICRO_CODE_UDIV] <= 1'b1;
                            micro_register_rd <= convert_4_16(ir_B[11:8]);
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                        end
                        else if(ir_A[6:4]==3'b100 && ir_B[7:4]==4'b0000) begin
                            //SMLAL
                            decode_error <= 1'b1;
                        end
                        else if(ir_A[6:4]==3'b100 && ir_B[7:6]==2'b10) begin
                            //SMLALBB, SMLALBT, SMLALTB, SMLALTT
                            decode_error <= 1'b1;
                        end
                        else if(ir_A[6:4]==3'b100 && ir_B[7:5]==3'b110) begin
                            //SMLALD, SMLALDX
                            decode_error <= 1'b1;
                        end
                        else if(ir_A[6:4]==3'b101 && ir_B[7:5]==3'b110) begin
                            //SMLSLD, SMLSLDX
                            decode_error <= 1'b1;
                        end
                        else if(ir_A[6:4]==3'b110 && ir_B[7:4]==4'b0000) begin
                            //UMLAL T1
                            micro_code[`MICRO_CODE_UMLAL] <= 1'b1;
                            micro_register_rn <= convert_4_16(ir_A[3:0]);
                            micro_register_rm <= convert_4_16(ir_B[3:0]);
                            micro_register_rt <= convert_4_16(ir_B[15:12]);
                            micro_register_rd <= convert_4_16(ir_B[11:8]);
                        end
                        else if(ir_A[6:4]==3'b110 && ir_B[7:4]==4'b0110) begin
                            //UMAAL
                            decode_error <= 1'b1;
                        end
                        else begin
                            decode_error <= 1'b1;
                        end
                    end
                    else if(ir_A[10]) begin
                        //Coprocessor instructions
                        decode_error <= 1'b1;
                    end
                    else begin
                        decode_error <= 1'b1;
                    end
                end
                else begin
                    decode_error <= 1'b1;
                end
            end
        end
        else begin
            decode_error <= 1'b0;
            if(micro_done && !micro_code[`MICRO_CODE_IT]) begin
                if(micro_it[2:0]==3'b0) begin
                    micro_it <= 8'b0;
                end
                else begin
                    micro_it[4:0] <= {micro_it[3:0], 1'b0};
                end
            end
        end
    end
    
    function in_it_block(input [7:0] micro_it);
        begin
            in_it_block = micro_it[3:0]!=4'b0;
        end
    endfunction
    
    function last_in_it_block(input [7:0] micro_it);
        begin
            last_in_it_block = micro_it[3:0]==4'b1000;
        end
    endfunction

`include "function.vh"

endmodule
