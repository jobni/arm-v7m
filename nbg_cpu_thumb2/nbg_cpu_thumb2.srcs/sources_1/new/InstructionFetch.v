`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2024 09:16:07 AM
// Design Name: 
// Module Name: InstructionFetch
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


module InstructionFetch(
    input clk,
    input rst_n,
    input if_en,
    input [7:0] curr_cnt,
    (*mark_debug = "true"*) input [31:0] i_data,
    input [31:0] pc_r15,
    output reg [31:0] i_bus_addr,
    output reg [15:0] ir_A,
    output reg [15:0] ir_B,
    output reg if_done,
    output reg [7:0] if_cnt
    );
    
    reg if_next;
    
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            ir_A <= 16'h0;
            ir_B <= 16'h0;
            if_done <= 1'b0;
            i_bus_addr <= 32'b0;
            if_next <= 1'b0;
            if_cnt <= 1'b0;
            
        end
        else begin
            if(if_en) begin
                if(if_cnt<8'h2) begin
                    if_done <= 1'b1;
                end
                else begin
                    if(curr_cnt == 8'h0) begin
                        i_bus_addr <= pc_r15;
                        if_next <= 1'b0;
                    end
                    if(curr_cnt == 8'h2) begin
                        if(!i_bus_addr[1]) begin
                            ir_A <= i_data[15:0];
                            if((i_data[15:11] == 5'b11101)||(i_data[15:12] == 4'b1111)) begin
                                ir_B <= i_data[31:16];
                            end
                            else begin
                                ir_B <= 16'b0;
                            end
                            if_done <= 1'b1;
                        end
                        else begin
                            ir_A <= i_data[31:16];
                            if((i_data[31:27] == 5'b11101)||(i_data[31:28] == 4'b1111)) begin
                                i_bus_addr <= pc_r15 + 32'd2;
                                if_next <= 1'b1;
                            end
                            else begin
                                ir_B <= 16'b0;
                                if_done <= 1'b1;
                            end
                        end
                    end
                    if(curr_cnt == 8'h4) begin
                        if(if_next) begin
                            ir_B <= i_data[15:0];
                            if_done <= 1'b1;
                        end
                    end
                end
            end
            
            if(if_done) begin
                if(if_cnt == 8'hff) begin
                    if_cnt <= 8'h3;
                end
                else begin
                    if_cnt <= if_cnt + 1'b1;
                end
                if_done <= 1'b0;
            end
        end
    end
endmodule
