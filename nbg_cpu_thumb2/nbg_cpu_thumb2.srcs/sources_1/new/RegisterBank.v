`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2024 09:11:56 AM
// Design Name: 
// Module Name: RegisterBank
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

module RegisterBank(
    input clk,
    input rst_n,
    input [15:0] micro_register_rn,
    input [15:0] micro_register_rt,
    input [15:0] micro_register_rm,
    input [15:0] micro_register_rd,
    input [15:0] register_set_code,
    input [31:0] register_set_data,
    input [31:0] psr_set_code,
    input [31:0] psr_set_data,
    input [15:0] write_register,
    input micro_thumb32,
    input micro_done,
    input update_pc,
    input [7:0] if_cnt,
    output reg [31:0] sp_r13,
    output reg [31:0] pc_r15,
    output reg [31:0] register_rn,
    output reg [31:0] register_rt,
    output reg [31:0] register_rm,
    output reg [31:0] register_rd,
    output reg [31:0] write_data,
    output apsr_n,
    output apsr_z,
    output apsr_c,
    output apsr_v,
    output apsr_q
    );
    
    reg [31:0] r0;
    reg [31:0] r1;
    reg [31:0] r2;
    reg [31:0] r3;
    reg [31:0] r4;
    reg [31:0] r5;
    reg [31:0] r6;
    reg [31:0] r7;
    reg [31:0] r8;
    reg [31:0] r9;
    reg [31:0] r10;
    reg [31:0] r11;
    reg [31:0] r12;
    reg [31:0] lr_r14;
    reg [31:0] psr;
    
    assign {apsr_n, apsr_z, apsr_c, apsr_v, apsr_q} = psr[31:27];
    
    always @(*)begin
        case(micro_register_rn)
            16'b1<<`REGISTER_CODE_R0:register_rn=r0;
            16'b1<<`REGISTER_CODE_R1:register_rn=r1;
            16'b1<<`REGISTER_CODE_R2:register_rn=r2;
            16'b1<<`REGISTER_CODE_R3:register_rn=r3;
            16'b1<<`REGISTER_CODE_R4:register_rn=r4;
            16'b1<<`REGISTER_CODE_R5:register_rn=r5;
            16'b1<<`REGISTER_CODE_R6:register_rn=r6;
            16'b1<<`REGISTER_CODE_R7:register_rn=r7;
            16'b1<<`REGISTER_CODE_R8:register_rn=r8;
            16'b1<<`REGISTER_CODE_R9:register_rn=r9;
            16'b1<<`REGISTER_CODE_R10:register_rn=r10;
            16'b1<<`REGISTER_CODE_R11:register_rn=r11;
            16'b1<<`REGISTER_CODE_R12:register_rn=r12;
            16'b1<<`REGISTER_CODE_SP:register_rn=sp_r13;
            16'b1<<`REGISTER_CODE_LR:register_rn=lr_r14;
            16'b1<<`REGISTER_CODE_PC:register_rn=pc_r15 + 32'h4;
            default:register_rn=32'b0;
        endcase
    end
    
    always @(*)begin
        case(micro_register_rt)
            16'b1<<`REGISTER_CODE_R0:register_rt=r0;
            16'b1<<`REGISTER_CODE_R1:register_rt=r1;
            16'b1<<`REGISTER_CODE_R2:register_rt=r2;
            16'b1<<`REGISTER_CODE_R3:register_rt=r3;
            16'b1<<`REGISTER_CODE_R4:register_rt=r4;
            16'b1<<`REGISTER_CODE_R5:register_rt=r5;
            16'b1<<`REGISTER_CODE_R6:register_rt=r6;
            16'b1<<`REGISTER_CODE_R7:register_rt=r7;
            16'b1<<`REGISTER_CODE_R8:register_rt=r8;
            16'b1<<`REGISTER_CODE_R9:register_rt=r9;
            16'b1<<`REGISTER_CODE_R10:register_rt=r10;
            16'b1<<`REGISTER_CODE_R11:register_rt=r11;
            16'b1<<`REGISTER_CODE_R12:register_rt=r12;
            16'b1<<`REGISTER_CODE_SP:register_rt=sp_r13;
            16'b1<<`REGISTER_CODE_LR:register_rt=lr_r14;
            16'b1<<`REGISTER_CODE_PC:register_rt=pc_r15 + 32'h4;
            default:register_rt=32'b0;
        endcase
    end
    
    always @(*)begin
        case(micro_register_rm)
            16'b1<<`REGISTER_CODE_R0:register_rm=r0;
            16'b1<<`REGISTER_CODE_R1:register_rm=r1;
            16'b1<<`REGISTER_CODE_R2:register_rm=r2;
            16'b1<<`REGISTER_CODE_R3:register_rm=r3;
            16'b1<<`REGISTER_CODE_R4:register_rm=r4;
            16'b1<<`REGISTER_CODE_R5:register_rm=r5;
            16'b1<<`REGISTER_CODE_R6:register_rm=r6;
            16'b1<<`REGISTER_CODE_R7:register_rm=r7;
            16'b1<<`REGISTER_CODE_R8:register_rm=r8;
            16'b1<<`REGISTER_CODE_R9:register_rm=r9;
            16'b1<<`REGISTER_CODE_R10:register_rm=r10;
            16'b1<<`REGISTER_CODE_R11:register_rm=r11;
            16'b1<<`REGISTER_CODE_R12:register_rm=r12;
            16'b1<<`REGISTER_CODE_SP:register_rm=sp_r13;
            16'b1<<`REGISTER_CODE_LR:register_rm=lr_r14;
            16'b1<<`REGISTER_CODE_PC:register_rm=pc_r15 + 32'h4;
            default:register_rm=32'b0;
        endcase
    end
    
    always @(*)begin
        case(micro_register_rd)
            16'b1<<`REGISTER_CODE_R0:register_rd=r0;
            16'b1<<`REGISTER_CODE_R1:register_rd=r1;
            16'b1<<`REGISTER_CODE_R2:register_rd=r2;
            16'b1<<`REGISTER_CODE_R3:register_rd=r3;
            16'b1<<`REGISTER_CODE_R4:register_rd=r4;
            16'b1<<`REGISTER_CODE_R5:register_rd=r5;
            16'b1<<`REGISTER_CODE_R6:register_rd=r6;
            16'b1<<`REGISTER_CODE_R7:register_rd=r7;
            16'b1<<`REGISTER_CODE_R8:register_rd=r8;
            16'b1<<`REGISTER_CODE_R9:register_rd=r9;
            16'b1<<`REGISTER_CODE_R10:register_rd=r10;
            16'b1<<`REGISTER_CODE_R11:register_rd=r11;
            16'b1<<`REGISTER_CODE_R12:register_rd=r12;
            16'b1<<`REGISTER_CODE_SP:register_rd=sp_r13;
            16'b1<<`REGISTER_CODE_LR:register_rd=lr_r14;
            16'b1<<`REGISTER_CODE_PC:register_rd=pc_r15 + 32'h4;
            default:register_rd=32'b0;
        endcase
    end
    
    always @(*)begin
        case(write_register)
            16'b1<<`REGISTER_CODE_R0:write_data=r0;
            16'b1<<`REGISTER_CODE_R1:write_data=r1;
            16'b1<<`REGISTER_CODE_R2:write_data=r2;
            16'b1<<`REGISTER_CODE_R3:write_data=r3;
            16'b1<<`REGISTER_CODE_R4:write_data=r4;
            16'b1<<`REGISTER_CODE_R5:write_data=r5;
            16'b1<<`REGISTER_CODE_R6:write_data=r6;
            16'b1<<`REGISTER_CODE_R7:write_data=r7;
            16'b1<<`REGISTER_CODE_R8:write_data=r8;
            16'b1<<`REGISTER_CODE_R9:write_data=r9;
            16'b1<<`REGISTER_CODE_R10:write_data=r10;
            16'b1<<`REGISTER_CODE_R11:write_data=r11;
            16'b1<<`REGISTER_CODE_R12:write_data=r12;
            16'b1<<`REGISTER_CODE_SP:write_data=sp_r13;
            16'b1<<`REGISTER_CODE_LR:write_data=lr_r14;
            16'b1<<`REGISTER_CODE_PC:write_data=pc_r15 + 32'h4;
            default:write_data=register_set_data;
        endcase
    end
                         
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            r0 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_R0]) begin
                r0 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            r1 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_R1]) begin
                r1 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            r2 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_R2]) begin
                r2 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            r3 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_R3]) begin
                r3 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            r4 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_R4]) begin
                r4 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            r5 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_R5]) begin
                r5 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            r6 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_R6]) begin
                r6 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            r7 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_R7]) begin
                r7 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            r8 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_R8]) begin
                r8 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            r9 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_R9]) begin
                r9 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            r10 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_R10]) begin
                r10 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            r11 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_R11]) begin
                r11 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            r12 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_R12]) begin
                r12 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            sp_r13 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_SP]) begin
                sp_r13 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            lr_r14 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_LR]) begin
                lr_r14 <= register_set_data;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            pc_r15 <= 32'b0;
        end
        else begin
            if(register_set_code[`REGISTER_CODE_PC]) begin
                pc_r15 <= {register_set_data[31:1], 1'b0};
            end
            else if(micro_done && if_cnt > 8'h1 && update_pc) begin
                if(micro_thumb32) begin
                    pc_r15 <= pc_r15 + 32'h4;
                end
                else begin
                    pc_r15 <= pc_r15 + 32'h2;
                end
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            psr <= 32'b0;
        end
        else begin
            psr[24] <= 1'b1;
            if(psr_set_code[31]) begin
                psr[31] <= psr_set_data[31];
            end
            if(psr_set_code[30]) begin
                psr[30] <= psr_set_data[30];
            end
            if(psr_set_code[29]) begin
                psr[29] <= psr_set_data[29];
            end
            if(psr_set_code[28]) begin
                psr[28] <= psr_set_data[28];
            end
            if(psr_set_code[27]) begin
                psr[27] <= psr_set_data[27];
            end
        end
    end
endmodule
