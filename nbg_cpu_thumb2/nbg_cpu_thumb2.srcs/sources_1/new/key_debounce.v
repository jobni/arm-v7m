`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/13 11:42:21
// Design Name: 
// Module Name: key_debounce
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


module key_debounce(
    input clk,
    input rst_n,
    input [1:0] in_key,
    output reg [1:0] out_key
    );

parameter CNT_MAX = 20'd1000000;
reg [1:0] key_d0;
reg [1:0] key_d1;
reg [19:0] cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key_d0 <= 2'b11;
        key_d1 <= 2'b11;
    end
    else begin
        key_d0<=in_key;
        key_d1<=key_d0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 20'd0;
    end
    else if(key_d0 != key_d1)
        cnt <= CNT_MAX;
    else if(cnt>20'd0)
        cnt <= cnt -20'd1;
    else
        cnt <=20'd0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_key <= 2'b11;
    end
    else if(cnt == 20'd1)
        out_key <= key_d1;
    else
        out_key <= out_key;
end
endmodule
