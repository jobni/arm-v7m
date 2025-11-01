`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2024 09:18:41 AM
// Design Name: 
// Module Name: MemoryInterface
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


module MemoryInterface(
    input clk,
    input sys_rst_n,
    input write_en,
    input [31:0] write_data,
    input [31:0] i_bus_addr,
    input [31:0] d_bus_addr,
    input [1:0] key,
    input uart_rxd,
    output cpu_rst_n,
    output uart_txd,
    output [31:0] i_data,
    output reg [31:0] d_data,
    output [2:0] led,
    output [7:0] signal
    );
    parameter UART_BPGS = 115200;
    parameter TICK_COUNT = 16'd50000;
        
    wire [14:0] flash_i_write_addr;
    wire [31:0] flash_i_write_data;
    
    wire [12:0] rom_i_addr;
    wire [31:0] rom_i_data;
    wire [12:0] rom_d_addr;
    wire [31:0] rom_d_data;
    
    wire [12:0] flash_i_read_addr;
    wire [12:0] flash_i_addr;
    wire [31:0] flash_i_data;
    wire [12:0] flash_d_addr;
    wire [31:0] flash_d_data;
    
    wire [9:0] ram_d_addr;
    wire [31:0] ram_d_data;
    
    wire [17:0] system_d_addr;
    wire [31:0] system_d_data;
    
    wire ram_write_en;
    wire system_write_en;
    wire [31:0] write_flash_data;
    wire flash_i_write_en;
    
    assign flash_i_read_addr= (i_bus_addr[31:16] == 16'h0800) ? i_bus_addr[14:2] : 13'hFFF;
    assign flash_i_addr     = flash_i_write_en ? flash_i_write_addr[14:2] : flash_i_read_addr;
    assign rom_d_addr       = (d_bus_addr[31:16] == 16'h0800) ? d_bus_addr[14:2] : 13'hFFF;
    assign flash_d_addr     = (d_bus_addr[31:16] == 16'h0800) ? d_bus_addr[14:2] : 13'hFFF;
    assign flash_d_write_en = (d_bus_addr[31:16] == 16'h0800) ? write_en : 1'b0;
    assign ram_d_addr       = (d_bus_addr[31:16] == 16'h2000) ? d_bus_addr[11:2] : 10'h3FF;
    assign ram_write_en     = (d_bus_addr[31:16] == 16'h2000) ? write_en : 1'b0;
    assign system_d_addr    = (d_bus_addr[31:20] == 12'h400)  ? d_bus_addr[19:2] : 18'h3FFFF;
    assign system_write_en  = (d_bus_addr[31:20] == 12'h400)  ? write_en : 1'b0;
    assign i_data = flash_i_data;
    assign mem_test1 = i_bus_addr==32'h080044C0;
    assign mem_test2 = i_bus_addr==32'h080044d6;
    
    blk_flash u_blk_flash(
            .clka(clk),
            .rsta(!cpu_rst_n),
            .wea(flash_i_write_en),
            .addra(flash_i_addr),
            .dina(flash_i_write_data),
            .douta(flash_i_data),
            .clkb(clk),
            .rstb(!cpu_rst_n),
            .web(flash_d_write_en),
            .addrb(flash_d_addr),
            .dinb(write_data),
            .doutb(flash_d_data)
        );
    
    blk_ram u_blk_ram(
            .clka(clk),
            .wea(ram_write_en),
            .addra(ram_d_addr),
            .dina(write_data),
            .douta(ram_d_data)
        );
        
    SystemBus #(.UART_BPGS(UART_BPGS),
                .TICK_COUNT(TICK_COUNT))
            u_system_bus(
            .clk(clk),
            .sys_rst_n(sys_rst_n),
            .wea(system_write_en),
            .addra(system_d_addr),
            .dina(write_data),
            .key(key),
            .uart_rxd(uart_rxd),
            .cpu_rst_n(cpu_rst_n),
            .uart_txd(uart_txd),
            .douta(system_d_data),
            .flash_i_write_addr(flash_i_write_addr),
            .flash_i_write_data(flash_i_write_data),
            .update_flash(flash_i_write_en),
            .led(led),
            .signal(signal)
    );
    
    always @(*) begin
        if(!cpu_rst_n) begin
            d_data <= 32'b0;
        end
        else begin
            if(d_bus_addr[31:16] == 16'h2000) begin
                d_data <= ram_d_data;
            end
            else if(d_bus_addr[31:16] == 16'h0800) begin
                d_data <= flash_d_data;
            end
            else begin
                d_data <= system_d_data;
            end
        end
    end
endmodule
