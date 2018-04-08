`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.02.2018 22:06:10
// Design Name: 
// Module Name: tb_sw_fifo_simple
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


module tb_sw_fifo_simple();

parameter X_LENGTH = 1024;
parameter Y_LENGTH = 1000;

reg clk, rst;

wire [1:0] seq_X[X_LENGTH-1:0];
wire [1:0] seq_Y[X_LENGTH-1:0];
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

initial
begin  
    $fread(seq_X, 
        $fopen("/home/vytas/INF4/Verilog/dnabinary", "rb"));
    $fread(seq_Y_bin, 
        $fopen("/home/vytas/INF4/Verilog/dnabinary_t", "rb"));
end

reg [11:0] counter;
reg [31:0] SR;

// Process
initial
begin
    // Global reset
    clk = 1'b0;
    rst = 1'b1;
    counter = 12'd15;
    
    fifo_wr_en = 1'b1;
    fifo_rd_en = 1'b0;
    fifo_din = seq_Y_bin[31:0];
    valid_r = 1'b1;
    Y_r = 2'd0;

    SR = 32'd0;
        
    #16 rst = 1'b0;
   
    #100000 $finish;
end

always
    #1 clk = !clk;
    
always @(posedge clk)
    begin
    counter <= counter + 1;
    
    if (counter < 12'd15)
        begin
        valid_r <= 1'b1;
        
        case (counter)
             12'd0: Y_r <=   SR[1:0];
             12'd1: Y_r <=   SR[3:2];
             12'd2: Y_r <=   SR[5:4];
             12'd3: Y_r <=   SR[7:6];
             12'd4: Y_r <=   SR[9:8];
             12'd5: Y_r <= SR[11:10];
             12'd6: Y_r <= SR[13:12];
             12'd7: Y_r <= SR[15:14];
             12'd8: Y_r <= SR[17:16];
             12'd9: Y_r <= SR[19:18];
            12'd10: Y_r <= SR[21:20];
            12'd11: Y_r <= SR[23:22];
            12'd12: Y_r <= SR[25:24];
            12'd13: Y_r <= SR[27:26];
            12'd14: Y_r <= SR[29:28];  
            12'd15: Y_r <= SR[31:30];          
        endcase
        end
    else if (counter == 12'd15)
        begin
        valid_r <= 1'b1;
        
        if (!fifo_full)
            begin
            fifo_wr_en <= 1'b1;
            fifo_rd_en <= 1'b0;
            
            fifo_din <= seq_Y_bin[31:0];
            seq_Y_bin <= seq_Y_bin >> 32;
            end
        end
     else if (counter == 12'd16)
        begin
        counter <= 12'd0;
        valid_r <= 1'b0;
        
        if (!fifo_empty)
            begin
            fifo_wr_en <= 1'b0;
            fifo_rd_en <= 1'b1;
            
            SR <= fifo_dout;
            end
        end
    end

endmodule
