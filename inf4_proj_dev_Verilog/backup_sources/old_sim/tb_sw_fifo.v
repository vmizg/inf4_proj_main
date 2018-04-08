`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.02.2018 22:06:10
// Design Name: 
// Module Name: tb_sw_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Works fully. Do not edit past this stage unless a newer version doesn't work out.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_sw_fifo();

parameter X_LENGTH = 25;
parameter Y_LENGTH = 50;

reg clk, rst;

wire [1:0] seq_X[X_LENGTH-1:0];
wire [1:0] seq_Y[X_LENGTH-1:0];
reg  [1:0] seq_Y_mem[Y_LENGTH-1:0];
reg [Y_LENGTH*2-1:0] seq_Y_bin;

wire [X_LENGTH-1:0] valid;
wire [15:0] scores[X_LENGTH-1:0];

reg valid_r;
reg [1:0] Y_r;

// 32 bit FIFO related signals
reg fifo_wr_en, fifo_rd_en;
reg [31:0] fifo_din;
wire [31:0] fifo_dout;
wire fifo_full, fifo_empty;

fifo_32x512 fifo_32(
  .clk(clk),
  .srst(rst),
  .wr_en(fifo_wr_en), // DONE: Step 1 - assert write enable, deassert read enable
  .din(fifo_din),     // DONE: Step 2 - load all data there is (preload) (WHILE !fifo_full or !eof)
  .rd_en(fifo_rd_en), // Step 3 - assert read enable, deassert write enable
  .dout(fifo_dout),
  .full(fifo_full),
  .empty(fifo_empty)
);

// Shifter
reg sr_en, sr_shift_en;
reg [31:0] sr_in;
wire [1:0] sr_out;
wire sr_empty, sr_near_empty;

shift_2x32 shift_2(
    .clk(clk),
    .rst(rst),
    .en(sr_en),
    .shift_en(sr_shift_en),
    .sr_in(sr_in),
    .sr_out(sr_out),
    .empty(sr_empty),
    .near_empty(sr_near_empty)
);

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
    for (i=1; i<X_LENGTH; i=i+1) begin : pe_
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

integer j;
initial
begin
    for (j=0; j<Y_LENGTH; j=j+1)
        seq_Y_mem[j] = 2'b00;
    
    $fread(seq_X, 
        $fopen("/home/vytas/INF4/Verilog/dnabinary_X", "rb"));
    $fread(seq_Y_mem, 
        $fopen("/home/vytas/INF4/Verilog/dnabinary_Y", "rb"));
    
    seq_Y_bin[1:0] = seq_Y_mem[0];
    seq_Y_bin[3:2] = seq_Y_mem[1];
    seq_Y_bin[5:4] = seq_Y_mem[2];
    seq_Y_bin[7:6] = seq_Y_mem[3];
    seq_Y_bin[9:8] = seq_Y_mem[4];
    seq_Y_bin[11:10] = seq_Y_mem[5];
    seq_Y_bin[13:12] = seq_Y_mem[6];
    seq_Y_bin[15:14] = seq_Y_mem[7];
    seq_Y_bin[17:16] = seq_Y_mem[8];
    seq_Y_bin[19:18] = seq_Y_mem[9];
    seq_Y_bin[21:20] = seq_Y_mem[10];
    seq_Y_bin[23:22] = seq_Y_mem[11];
    seq_Y_bin[25:24] = seq_Y_mem[12];
    seq_Y_bin[27:26] = seq_Y_mem[13];
    seq_Y_bin[29:28] = seq_Y_mem[14];
    seq_Y_bin[31:30] = seq_Y_mem[15];
    seq_Y_bin[33:32] = seq_Y_mem[16];
    seq_Y_bin[35:34] = seq_Y_mem[17];
    seq_Y_bin[37:36] = seq_Y_mem[18];
    seq_Y_bin[39:38] = seq_Y_mem[19];
    seq_Y_bin[41:40] = seq_Y_mem[20];
    seq_Y_bin[43:42] = seq_Y_mem[21];
    seq_Y_bin[45:44] = seq_Y_mem[22];
    seq_Y_bin[47:46] = seq_Y_mem[23];
    seq_Y_bin[49:48] = seq_Y_mem[24];
    
    seq_Y_bin[99:50] = 49'd0;
end


// Process
initial
begin
    // Global reset
    clk = 1'b0;
    rst = 1'b1;
    sr_en = 1'b0;
    sr_shift_en = 1'b0;
    valid_r = 1'b0;
        
    #10 rst = 1'b0;
    
    #10 sr_en = 1'b1; sr_in = seq_Y_bin[31:0]; seq_Y_bin = seq_Y_bin >> 32;
    #2 sr_en = 1'b0; sr_shift_en = 1'b1;
    #2 sr_en = 1'b1;
    
    while (!sr_empty)
        begin
        #2 valid_r = 1'b1; Y_r = sr_out;
        end
    
    valid_r = 1'b0; sr_en = 1'b0; sr_shift_en = 1'b0; sr_in = seq_Y_bin[31:0];
    
    #2 sr_en = 1'b1; sr_shift_en = 1'b0;
    #2 sr_shift_en = 1'b1;
   
    while (!sr_empty)
        begin
        #2 valid_r = 1'b1; Y_r = sr_out;
        end
   
    #10000 $finish;
end

always
    #1 clk = !clk;
    
always @(scores)
    $display(scores[5], scores[4], scores[3], scores[2], scores[1], scores[0]);
    

endmodule