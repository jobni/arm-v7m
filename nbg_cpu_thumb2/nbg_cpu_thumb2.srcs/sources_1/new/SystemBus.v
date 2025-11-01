`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/15 06:44:57
// Design Name: 
// Module Name: SystemBus
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


module SystemBus(
    input clk,
    input sys_rst_n,
    input wea,
    input [17:0] addra,
    input [31:0] dina,
    input uart_rxd,
    input [1:0] key,
    output cpu_rst_n,
    output uart_txd,
    output reg [31:0] douta,
    output reg [14:0] flash_i_write_addr,
    output reg [31:0] flash_i_write_data,
    (*mark_debug = "true"*) output reg update_flash,
    output reg [2:0] led,
    output reg [7:0] signal
    );
    
    parameter UART_BPGS = 115200;
    parameter TICK_COUNT = 16'd50000;
    reg [7:0] uart_tx_data;
    reg uart_tx_en;
    reg [31:0] system_tick;
    reg [15:0] tick_cnt;
    reg uart_rx_finish;
    reg [1:0] key_d1;
    wire [7:0] uart_rx_data;
    wire uart_rx_done;
    reg [22:0] led_cnt0;
    reg [22:0] led_cnt1;
    wire uart_tx_busy;
    reg [31:0] flash_write_count;
    
    //K0下降沿清零地址，准备接收信号
    assign key0_neg = ~key[0] && key_d1[0];
    //K0上升沿清，程序软起动
    assign key0_pos = key[0] && ~key_d1[0];
    //K0作为软重启开关
    assign cpu_rst_n = key[0] & sys_rst_n;
    
    uart_rx #(.UART_BPGS(UART_BPGS))
        u_uart_rx
        (
        .clk(clk),
        .rst_n(sys_rst_n),
        .uart_rxd(uart_rxd),
        .uart_rx_done(uart_rx_done),
        .uart_rx_data(uart_rx_data)
    );
    
    uart_tx #(.UART_BPGS(UART_BPGS))
        u_uart_tx(
        .clk(clk),
        .rst_n(sys_rst_n),
        .uart_tx_en(uart_tx_en),
        .uart_tx_data(uart_tx_data),
        .uart_txd(uart_txd),
        .uart_tx_busy(uart_tx_busy)
    );
    
    always @(posedge clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            tick_cnt <= 16'b0;
            system_tick <= 32'b0;
        end
        else begin
            if(tick_cnt == TICK_COUNT-1'b1) begin
                tick_cnt <= 16'b0;
                system_tick <= system_tick + 32'b1;
            end
            else begin
                tick_cnt <= tick_cnt + 16'b1;
            end
        end
    end
    
    always @(posedge clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            douta <= 32'b0;
            uart_tx_data <= 8'b0;
            uart_tx_en <= 1'b0;
            uart_rx_finish <= 1'b0;
            signal <= 8'b0;
        end
        else begin
            if(uart_rx_done) begin
                uart_rx_finish <= 1'b1;
            end
            
            uart_tx_en <= 1'b0;
            if(addra == `SYSTEM_TICK>>2) begin
                douta <= system_tick;
            end
            else if(addra == `SYSTEM_SIGNAL>>2) begin
                if(wea) begin
                    signal <= dina[7:0];
                end
                else begin
                    douta <= {24'b0, signal};
                end
            end
            else if(addra == `UART1_SR>>2) begin
                if(wea) begin
                    uart_rx_finish <= 1'b0;
                end
                else begin
                    douta <= {25'b0, !uart_tx_busy, uart_rx_finish, 5'b0};
                end
            end
            else if(addra == `UART1_DR>>2) begin
                if(wea) begin
                    uart_tx_data <= dina[7:0];
                    uart_tx_en <= 1'b1;
                end
                else begin
                    douta <= {24'b0, uart_rx_data};
                end
            end
            else if(addra == `FLASH_WRITE_ADDR>>2) begin
                douta <= flash_i_write_addr;
            end
            else if(addra == `FLASH_WRITE_COUNT>>2) begin
                douta <= flash_write_count;
            end
            else if(addra == `CPU_STATUS>>2) begin
                douta <= 32'h20250202;
                //douta <= 32'h20250201;
            end
        end
    end
    
    always @(posedge clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            led_cnt0 <= 1'b0;
            led_cnt1 <= 1'b0;
        end
        else begin
            led_cnt0 <= led_cnt0 +1'b1;
            led_cnt1 <= led_cnt1 +1'b1;
        end
    end
    
    always @(posedge clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            led <= 3'b0;
        end
        else begin
            if(uart_tx_en) begin
                led[0] <= 1'b1;
            end
            else if(led_cnt0==1'b0) begin
                led[0] <= 1'b0;
            end
            if(uart_rx_done) begin
                led[1] <= 1'b1;
            end
            else if(led_cnt1==1'b0)begin
                led[1] <= 1'b0;
            end
            if(!key[1]) begin
                led[1:0] <= 2'b11;
            end
            led[2] <= ~cpu_rst_n;
        end
    end
    
    always @(posedge clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            key_d1 <= 2'b0;
        end
        else begin
            key_d1 <= key;
        end
    end
    
    always @(posedge clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            flash_i_write_addr <= 12'b0;
            flash_i_write_data <= 32'b0;
            flash_write_count <= 32'b0;
            update_flash <= 1'b0;
        end
        else begin
            update_flash <= 1'b0;
            if(key0_neg) begin
                flash_i_write_addr <= 15'h7FFC;
                flash_i_write_data <= 32'b0;
            end
            if(key0_pos) begin
                flash_write_count <= flash_write_count+32'b1;
            end
            if(!key[0]) begin
                if(uart_rx_done && !key[0]) begin
                    flash_i_write_addr <= flash_i_write_addr+12'b1;
                    case(flash_i_write_addr[1:0])
                        2'b11: flash_i_write_data[31:24] <= uart_rx_data;
                        2'b10: flash_i_write_data[23:16] <= uart_rx_data;
                        2'b01: flash_i_write_data[15:8] <= uart_rx_data;
                        2'b00: flash_i_write_data[7:0] <= uart_rx_data;
                    endcase
                    if(flash_i_write_addr[1:0]==2'b11) begin
                        update_flash <= 1'b1;
                    end
                end
            end
        end
    end
endmodule
