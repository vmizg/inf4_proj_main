`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.03.2018 19:26:37
// Design Name: 
// Module Name: bram
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


module bram #(parameter ADDR_WIDTH = 16, DATA_WIDTH = 16, DEPTH = 200) (
    input clk,
    input [ADDR_WIDTH-1:0] addr_i, 
    input write_en,
    input [DATA_WIDTH-1:0] data_i,
    output reg [DATA_WIDTH-1:0] data_o 
    );

    reg [DATA_WIDTH-1:0] memory_array [0:DEPTH-1]; 

    always @(posedge clk)
    begin
        if(write_en)
            memory_array[addr_i] <= data_i;
        else
            data_o <= memory_array[addr_i];
    end
endmodule
