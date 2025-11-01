`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/12 20:47:22
// Design Name: 
// Module Name: OperationController
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

module OperationController(
    input clk,
    input rst_n,
    input [7:0] curr_done,
    output reg [7:0] curr_st,
    output reg [7:0] curr_cnt
    );

 //当前状态
reg [6:0] next_st; //下一个状态

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        curr_st <= 8'b1 << `CPU_ST_IF;
        curr_cnt <= 8'b0;
    end
    else begin
        curr_st <= next_st;
        if(curr_st==next_st) begin
            curr_cnt <= curr_cnt + 8'b1;
        end
        else begin
            curr_cnt <= 8'b0;
        end
    end
end

always @(*) begin
    case(curr_st)
        8'b1 << `CPU_ST_IF: 
            if(curr_done == curr_st)
                next_st = 8'b1 << `CPU_ST_DECODE;
            else
                next_st = curr_st;
        8'b1 << `CPU_ST_DECODE: 
            if(curr_done == curr_st)
                next_st = 8'b1 << `CPU_ST_MICRO;
            else
                next_st = curr_st;
        8'b1 << `CPU_ST_MICRO: 
            if(curr_done == curr_st)
                next_st = 8'b1 << `CPU_ST_IF;
            else
                next_st = curr_st;
        default:
            next_st = 8'b1 << `CPU_ST_IF;
    endcase
end

endmodule
