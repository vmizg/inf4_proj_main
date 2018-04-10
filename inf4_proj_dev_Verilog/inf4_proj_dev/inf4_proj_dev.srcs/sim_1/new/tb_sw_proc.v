`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2018 09:56:12
// Design Name: 
// Module Name: tb_sw_proc
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


module tb_sw_proc();
    
    reg clk;
    reg rst;
    reg [31:0] seq_y;
    
    reg  user_w_stream_dna_x_wren;
    wire  user_w_stream_dna_x_full;
    reg [31:0]  user_w_stream_dna_x_data;
    reg         user_w_stream_dna_x_open;
    
    reg         user_w_stream_dna_y_wren;
    wire        user_w_stream_dna_y_full;
    reg [31:0]  user_w_stream_dna_y_data;
    reg         user_w_stream_dna_y_open;
    
    reg         user_r_stream_score_out_rden;
    wire        user_r_stream_score_out_empty;
    wire [31:0] user_r_stream_score_out_data;
    wire        user_r_stream_score_out_eof;
    reg         user_r_stream_score_out_open;
    
    wire [6:0] ssd_a;
    wire       ssd_c;
    
    sw_proc u_sw_proc(
        .clk(clk),
        .rst(rst),
    
        .user_w_stream_dna_x_wren(user_w_stream_dna_x_wren),
        .user_w_stream_dna_x_full(user_w_stream_dna_x_full),
        .user_w_stream_dna_x_data(user_w_stream_dna_x_data),
        .user_w_stream_dna_x_open(user_w_stream_dna_x_open),
  
        .user_w_stream_dna_y_wren(user_w_stream_dna_y_wren),
        .user_w_stream_dna_y_full(user_w_stream_dna_y_full),
        .user_w_stream_dna_y_data(user_w_stream_dna_y_data),
        .user_w_stream_dna_y_open(user_w_stream_dna_y_open),
  
        .user_r_stream_score_out_rden(user_r_stream_score_out_rden),
        .user_r_stream_score_out_empty(user_r_stream_score_out_empty),
        .user_r_stream_score_out_data(user_r_stream_score_out_data),
        .user_r_stream_score_out_eof(user_r_stream_score_out_eof),
        .user_r_stream_score_out_open(user_r_stream_score_out_open),
    
        .ssd_a(ssd_a),
        .ssd_c(ssd_c)
    );

    integer i;
    initial
    begin
        // Initial values
        clk = 1'b0;
        rst = 1'b1;
        
        user_r_stream_score_out_open = 1'b0;
        user_r_stream_score_out_rden = 1'b0;
        
        user_w_stream_dna_y_open = 1'b0;
        user_w_stream_dna_y_wren = 1'b0;
        
        user_w_stream_dna_x_open = 1'b0;
        user_w_stream_dna_x_wren = 1'b0;
        
        #10
        rst = 1'b0;
        
        #200
        user_w_stream_dna_x_open = 1'b1;
        user_w_stream_dna_x_wren = 1'b1;
        user_w_stream_dna_x_data = {
            2'd0, 2'd1, 2'd3, 2'd3,
            2'd1, 2'd1, 2'd2, 2'd3,
            2'd1, 2'd1, 2'd0, 2'd1,
            2'd2, 2'd0, 2'd3, 2'd3};
        #2 user_w_stream_dna_x_wren = 1'b0;
        
        #200
        user_w_stream_dna_x_wren = 1'b1;
        user_w_stream_dna_x_data = {
            2'd0, 2'd1, 2'd3, 2'd3,
            2'd1, 2'd1, 2'd2, 2'd3,
            2'd1, 2'd1, 2'd0, 2'd1,
            2'd2, 2'd0, 2'd3, 2'd3};
        #2 user_w_stream_dna_x_wren = 1'b0;
        
//        11110010010001011110010111110100
        
//        01000011001000011011111000111110
//        01000111111111110101010010011001
                           
        #500 user_w_stream_dna_x_open = 1'b0;
        
        #1000
        seq_y[1:0] = 2'd1;
        seq_y[3:2] = 2'd0;
        seq_y[5:4] = 2'd0;
        seq_y[7:6] = 2'd3;
        seq_y[9:8] = 2'd0;
        seq_y[11:10] = 2'd2;
        seq_y[13:12] = 2'd0;
        seq_y[15:14] = 2'd1;
        seq_y[17:16] = 2'd2;
        seq_y[19:18] = 2'd3;
        seq_y[21:20] = 2'd3;
        seq_y[23:22] = 2'd2;
        seq_y[25:24] = 2'd0;
        seq_y[27:26] = 2'd3;
        seq_y[29:28] = 2'd3;
        seq_y[31:30] = 2'd2;
        
        user_w_stream_dna_y_open = 1'b1;
        user_w_stream_dna_y_wren = 1'b1;
        user_w_stream_dna_y_data = seq_y[31:0];
            
        #2
        seq_y[1:0] = 2'd1;
        seq_y[3:2] = 2'd0;
        seq_y[5:4] = 2'd1;
        seq_y[7:6] = 2'd3;
        seq_y[9:8] = 2'd3;
        seq_y[11:10] = 2'd3;
        seq_y[13:12] = 2'd3;
        seq_y[15:14] = 2'd3;
        seq_y[17:16] = 2'd1;
        seq_y[19:18] = 2'd1;
        seq_y[21:20] = 2'd1;
        seq_y[23:22] = 2'd0;
        seq_y[25:24] = 2'd2;
        seq_y[27:26] = 2'd1;
        seq_y[29:28] = 2'd2;
        seq_y[31:30] = 2'd1;
        
        user_w_stream_dna_y_wren = 1'b1;
        user_w_stream_dna_y_data = seq_y[31:0];
        
        #2 user_w_stream_dna_y_wren = 1'b0;
        #4 user_w_stream_dna_y_open = 1'b0;
        
        #5000
        user_r_stream_score_out_open = 1'b1;
        
        #500
        for (i=0; i<2000; i=i+1)
            begin
            user_r_stream_score_out_rden = 1'b1;
            $display("%d", user_r_stream_score_out_data);
            #2 user_r_stream_score_out_rden = 1'b0;
            end
        
        #500
        for (i=0; i<4000; i=i+1)
            begin
            user_r_stream_score_out_rden = 1'b1;
            $display("%d", user_r_stream_score_out_data);
            #2 user_r_stream_score_out_rden = 1'b0;
            end
        
    end
    
    always
        #1 clk = !clk;

endmodule
