`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.02.2018 21:53:10
// Design Name: 
// Module Name: sw_pe
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


module sw_pe(
    input clk,
    input rst,
    input [1:0] X_i, // Base char
    input [1:0] Y_i, // Streaming char
    input valid_i,
    input signed [9:0] top_i, // Score from PE[i-1] at time T-1
    output reg signed [9:0] score_o, // Score output
    output reg [1:0] Y_o,
    output reg valid_o
    );

wire signed [2:0] gap, match, mismatch;
assign gap = 3'd1;
assign match = 3'd2;
assign mismatch = 3'd1;

reg valid_nxt;
reg [1:0] Y_nxt;
reg signed [9:0] top_r, top_nxt, left_r, left_nxt, diag_r, diag_nxt;
reg signed [9:0] ms_r, ms_nxt, i1_r, i1_nxt, i2_r, i2_nxt;
reg signed [9:0] score_nxt;

parameter [1:0] RUN1 = 2'b00,
                RUN2 = 2'b01,
                RUN3 = 2'b10,
                RUN4 = 2'b11;

reg [1:0] state_r, state_nxt;

always @(posedge clk)
    if (rst)
        begin
        state_r   <= RUN1;
        top_r     <= 10'd0;
        left_r    <= 10'd0;
        diag_r    <= 10'd0;
        score_o   <= 10'd0;
        Y_o       <=  2'd0;
        valid_o   <=  1'b0;
        ms_r      <= 10'd0;
        i1_r      <= 10'd0;
        i2_r      <= 10'd0;
        end
    else
        begin
        state_r   <= state_nxt;
        top_r     <= top_nxt;
        left_r    <= left_nxt;
        diag_r    <= diag_nxt;
        score_o   <= score_nxt;
        Y_o       <= Y_nxt;
        valid_o   <= valid_nxt;
        ms_r      <= ms_nxt;
        i1_r      <= i1_nxt;
        i2_r      <= i2_nxt;
        end

always @(*)
    begin
    state_nxt = state_r;
    Y_nxt = Y_o;
    top_nxt = top_r;
    left_nxt = left_r;
    diag_nxt = diag_r;
    score_nxt = score_o;
    ms_nxt = ms_r;
    i1_nxt = i1_r;
    i2_nxt = i2_r;
    valid_nxt = valid_o;
    
    case (state_nxt)
        RUN1:
            if (valid_i)
                begin
                valid_nxt = 1'b0;
                diag_nxt  = top_nxt;
                top_nxt   = top_i;
                Y_nxt     = Y_i;
                state_nxt = RUN2;
                end
        RUN2:
            begin
            i1_nxt    = left_nxt - gap;
            i2_nxt    = top_nxt - gap;
            ms_nxt    = (X_i == Y_nxt) ?
                        diag_nxt + match :
                        diag_nxt - mismatch;
            state_nxt = RUN3;
            end
        RUN3:
            begin
            ms_nxt = ms_nxt[9] ? 10'd0 : ms_nxt;
            
            if (i1_nxt >= i2_nxt && i1_nxt >= ms_nxt)
                score_nxt = i1_nxt;
            else if (i2_nxt >= i1_nxt && i2_nxt >= ms_nxt)
                score_nxt = i2_nxt;
            else
                score_nxt = ms_nxt;
            
            left_nxt  = score_nxt;
            valid_nxt = 1'b1;
            state_nxt = RUN1;
            end
    endcase
    end
 
endmodule