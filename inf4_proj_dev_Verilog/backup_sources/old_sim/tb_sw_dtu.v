`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.02.2018 11:22:18
// Design Name: 
// Module Name: tb_sw_dtu
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


module tb_sw_dtu();

reg clk, rst;

reg [1999:0] seq;

// DTU signal
reg dtu_en, dtu_in_valid;
reg [31:0] dtu_in;
wire dtu_out_valid, dtu_done;
wire [1:0] dtu_out;

dtu dtu(
    .clk(clk),
    .rst(rst),
    .en(dtu_en),
    .din(dtu_in),
    .din_valid(dtu_in_valid),
    .dout(dtu_out),
    .dout_valid(dtu_out_valid),
    .ready(dtu_done)
);

// Preload FIFO - step to be coordinated with the hosts
reg [10:0] counter;
initial
begin
    $fread(seq, 
        $fopen("/home/vytas/INF4/Verilog/dnabinary_t", "rb"));
end

// Process
initial
begin
    // Global reset
    clk = 1'b0;
    rst = 1'b1;
    dtu_en = 1'b0;
    counter = 11'd0;
    dtu_in = seq[31:0];
    
    #16 rst = 1'b0; dtu_en = 1'b1;
   
    #100000 $finish;
end

always
    #4 clk = !clk;
    
always @(posedge clk)
begin
    if (dtu_done)
        begin
        dtu_in <= seq[31:0];
        dtu_in_valid <= 1'b1;
        seq <= seq >> 32;
        end
    else
        dtu_in_valid <= 1'b0;
end

endmodule
