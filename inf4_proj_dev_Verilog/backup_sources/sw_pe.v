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
    input [1:0] X_i,           // Base char
    input [1:0] Y_i,           // Streaming char
    input valid_i,
    input [15:0] top_i,        // Score from PE[i-1] at time T-1
    output reg [15:0] score_o, // Score output
    output reg [1:0] Y_o,
    output reg valid_o
    );

wire [1:0] gap, match, mismatch;
assign gap = 2'd1;
assign match = 2'd2;
assign mismatch = 2'd1;

reg [15:0] diag;

always @(posedge clk)
    if (rst)
        begin
        diag      <= 16'd0;
        score_o   <= 16'd0;
        valid_o   <=  1'b0;
        Y_o       <=  2'd0;
        end
    else
        begin
        if (valid_i)
            begin
            Y_o <= Y_i;
            diag <= top_i;
            
            if (X_i == Y_i)
                begin
                if (score_o < gap && top_i < gap)
                    score_o <= diag + match;
                else if (score_o < gap && top_i >= gap)
                    score_o <= ((top_i - gap) >= diag + match) ? top_i - gap : diag + match;
                else if (score_o >= gap && top_i < gap)
                    score_o <= ((score_o - gap) >= diag + match) ? score_o - gap : diag + match;
                else if (score_o >= gap && top_i >= gap)
                    begin
                    if (score_o - gap >= diag + match && score_o - gap >= top_i - gap)
                        score_o <= score_o - gap;
                    else if (top_i - gap >= diag + match && top_i - gap >= score_o - gap)
                        score_o <= top_i - gap;
                    else if (diag + match >= score_o - gap && diag + match >= top_i - gap)
                        score_o <= diag + match;
                    end
                end
            else
                begin
                if (diag >= mismatch)
                    begin
                    if (score_o < gap && top_i < gap)
                        score_o <= diag - mismatch;
                    else if (score_o < gap && top_i >= gap)
                        score_o <= ((top_i - gap) > diag - mismatch) ? top_i - gap : diag - mismatch;
                    else if (score_o >= gap && top_i < gap)
                        score_o <= ((score_o - gap) > diag - mismatch) ? score_o - gap : diag - mismatch;
                    else if (score_o >= gap && top_i >= gap)
                        begin
                        if (score_o - gap >= diag - mismatch && score_o - gap >= top_i - gap)
                            score_o <= score_o - gap;
                        else if (top_i - gap >= diag - mismatch && top_i - gap >= score_o - gap)
                            score_o <= top_i - gap;
                        else if (diag - mismatch >= score_o - gap && diag - mismatch >= top_i - gap)
                            score_o <= diag - mismatch;
                        end
                    end
                else
                    begin
                    if (score_o < gap && top_i < gap)
                        score_o <= 16'd0;
                    else if (score_o < gap && top_i >= gap)
                        score_o <= top_i - gap;
                    else if (score_o >= gap && top_i < gap)
                        score_o <= score_o - gap;
                    else if (score_o >= gap && top_i >= gap)
                        begin
                        if (score_o - gap >= top_i - gap)
                            score_o <= score_o - gap;
                        else
                            score_o <= top_i - gap;
                        end
                    end
                 end
               
            valid_o <= 1'b1;
            end
        else
            valid_o <= 1'b0;
        end
 
endmodule