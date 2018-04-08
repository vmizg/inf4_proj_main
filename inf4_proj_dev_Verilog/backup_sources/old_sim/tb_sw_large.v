`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.02.2018 22:13:39
// Design Name: 
// Module Name: tb_sw_large
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


module tb_sw_large();

parameter PE_LENGTH = 1024;
parameter T_LENGTH = 1000;

reg clk, rst;

wire [1:0] seq_X[PE_LENGTH-1:0];
wire [1:0] seq_Y[T_LENGTH-1:0];
wire [1:0] seq_Y_bin[T_LENGTH-1:0];

wire [PE_LENGTH-1:0] valid;
wire [15:0] scores[PE_LENGTH-1:0];

reg valid_r;
reg [1:0] Y_r;

sw_pe pe_init(
  .clk(clk),
  .rst(rst),
  .X_i(seq_X[0]),
  .Y_i(Y_r),
  .valid_i(valid_r),
  .top_i(16'd0),
  .score_o(scores[0]),
  .Y_o(seq_Y[0]),
  .valid_o(valid[0])
);

genvar i;
generate
    for (i=1; i<PE_LENGTH; i=i+1) begin : pe_
      sw_pe pe(
        .clk(clk),
        .rst(rst),
        .X_i(seq_X[i]),
        .Y_i(seq_Y[i-1]),
        .valid_i(valid[i-1]),
        .top_i(scores[i-1]),
        .score_o(scores[i]),
        .Y_o(seq_Y[i]),
        .valid_o(valid[i])
      );
    end
endgenerate

initial
begin
    $fread(seq_X, 
        $fopen("/home/vytas/INF4/Verilog/dnabinary", "rb"));
    $fread(seq_Y_bin, 
        $fopen("/home/vytas/INF4/Verilog/dnabinary_t", "rb"));
end

integer j,k;

initial
begin
    // Global reset
    clk = 1'b0;
    rst = 1'b1;
    
    #4 rst = 1'b0;
    #4 Y_r = seq_Y_bin[0]; valid_r = 1'b1;
    
    // Shift Y through PEs and observe results
    for (j=1; j<T_LENGTH; j=j+1)
        #8 Y_r = seq_Y_bin[j];
   
    #100000 $finish;
end

always
    #4 clk = !clk;

endmodule