`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.02.2018 21:54:47
// Design Name: 
// Module Name: shift_2x32_v2
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


module shift_2x32_v2 (
	input clk,
	input rst,
	input en,
	input valid,
	input  [31:0] sr_in,
	output reg [1:0] sr_out,
	output reg valid_out,
	output reg empty,
	output reg near_empty
);

reg [31:0] sr;
reg [4:0] counter;

always @(posedge clk or posedge rst)
begin
    if (rst)
        begin
        sr         <= 32'd0;
        counter    <= 5'd0;
        near_empty <= 1'b0;
        empty      <= 1'b1;
        valid_out  <= 1'b0;
        end
    else if (en)
        begin
        if (!empty)
            begin
            counter   <= counter + 1;      // Count shifts
            sr_out    <= sr[1:0];          // Assign out value from the main register
            sr        <= {2'b0, sr[31:2]}; // Shift main register
            valid_out <= 1'b1;
            
            if (counter == 5'd13)
                near_empty <= 1'b1;
            else if (counter == 5'd14)
                begin
                near_empty <= 1'b0;
                empty      <= 1'b1;
                end
            end
        else if (valid)
            begin
            counter   <= 5'd0;
            sr_out    <= sr_in[1:0];          // Assign out value ...
            sr        <= {2'b0, sr_in[31:2]}; // ... in parallel with reading new data off the input
            empty     <= 1'b0;
            valid_out <= 1'b1;
            end
        end
end

endmodule
