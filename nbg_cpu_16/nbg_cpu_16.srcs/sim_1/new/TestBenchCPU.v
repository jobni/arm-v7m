`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2024 08:54:09 AM
// Design Name: 
// Module Name: TestBenchCPU
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


module TestBenchCPU();

parameter CLK_PERIOD = 20;

reg sys_clk;
reg sys_rst_n;
reg [0:1] in_key;
reg [7:0] uart_tx_data;
reg uart_tx_en;
reg [7:0] tx_cnt;
reg tx_start1;
reg tx_start2;
wire [7:0] signal;
    
uart_tx #(.UART_BPGS(500000))
    u_uart_tx(
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .uart_tx_en(uart_tx_en),
    .uart_tx_data(uart_tx_data),
    .uart_txd(uart_rxd),
    .uart_tx_busy(uart_tx_busy)
);

always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

ProcesserCoreSystem #(.UART_BPGS(500000),.TICK_COUNT(10),.CNT_MAX(5))
    u_processer_core_system(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .uart_rxd(uart_rxd),
    .in_key(in_key),
    .signal(signal)
);

initial begin
    sys_clk = 1'b0;
    sys_rst_n = 1'b0;
    in_key = 2'b11;
    tx_cnt = 8'b0;
    tx_start1 = 1'b0;
    tx_start2 = 1'b0;
    #55
    sys_rst_n = 1'b1;
    #1000
    in_key[1] = 1'b0;
    #5000
    in_key[1] = 1'b1;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        tx_cnt <= 8'b0;
        uart_tx_en <= 8'b0;
        uart_tx_data <= 8'b0;
    end
    else begin
        uart_tx_en <= 1'b0;
        if(signal==8'h1)begin
            tx_start1<=1'b1;
        end
        else if(signal==8'h2)begin
            tx_start2<=1'b1;
        end
        if(tx_start1) begin
            if(tx_cnt<8'h8) begin
                if(!uart_tx_en && !uart_tx_busy) begin
                    tx_cnt <= tx_cnt +1'b1;
                    if(tx_cnt==8'h0) begin
                        uart_tx_data <= "1";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h1) begin
                        uart_tx_data <= "5";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h2) begin
                        uart_tx_data <= "*";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h3) begin
                        uart_tx_data <= "2";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h4) begin
                        uart_tx_data <= "1";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h5) begin
                        uart_tx_data <= "=";
                        uart_tx_en <= 1'b1;
                    end
                end
             end
             else begin
                tx_start1 <= 1'b0;
                tx_cnt <= 1'b0;
             end
        end
        else if(tx_start2) begin
            if(tx_cnt<8'hC) begin
                if(!uart_tx_en && !uart_tx_busy) begin
                    tx_cnt <= tx_cnt +1'b1;
                    if(tx_cnt==8'h0) begin
                        uart_tx_data <= "1";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h1) begin
                        uart_tx_data <= ".";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h2) begin
                        uart_tx_data <= "2";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h3) begin
                        uart_tx_data <= "3";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h4) begin
                        uart_tx_data <= "4";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h5) begin
                        uart_tx_data <= "/";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h6) begin
                        uart_tx_data <= "4";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h7) begin
                        uart_tx_data <= ".";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h8) begin
                        uart_tx_data <= "3";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'h9) begin
                        uart_tx_data <= "2";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'hA) begin
                        uart_tx_data <= "1";
                        uart_tx_en <= 1'b1;
                    end
                    if(tx_cnt==8'hB) begin
                        uart_tx_data <= "=";
                        uart_tx_en <= 1'b1;
                    end
                end
            end
            else begin
                tx_start2 <= 1'b0;
                tx_cnt <= 1'b0;
            end 
        end
    end
end
endmodule
