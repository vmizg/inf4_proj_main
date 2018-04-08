`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.03.2018 16:09:02
// Design Name: 
// Module Name: fifo_shift_2x32
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


module fifo_shift_2x32 (
	input clk,
	input rst,
	input sr_en,
    input [31:0] data_in, // user_w_write_32_data
	input data_in_valid,
	output reg [1:0] data_out,
	output reg data_out_valid,
    output fifo_full,
    output reg sr_empty,
    output fifo_empty
);

wire [31:0] fifo_dout;
reg  [31:0] shift_reg;
reg  [4:0] shift_counter;
reg  [1:0] read_stage;

reg data_in_wren, data_in_rden;

reg data_ready;
reg need_data;

fifo_32x512 fifo_32(
    .clk(clk),
    .srst(rst),
    .din(data_in),
    .wr_en(data_in_wren),
    .rd_en(data_in_rden),
    .dout(fifo_dout),
    .full(fifo_full),
    .empty(fifo_empty)
);

// FIFO data preload
always @(posedge clk)
begin
    if (rst)
        begin
        data_in_wren <= 1'b0;
        data_in_rden <= 1'b0;
        data_ready   <= 1'b0;
        read_stage   <= 2'd0;
        end
    else
        begin
        // Always try to load values into FIFO
        if (!fifo_full && data_in_valid)
            data_in_wren <= 1'b1;
        else
            data_in_wren <= 1'b0;
            
        if (sr_en && need_data && !fifo_empty && read_stage == 2'd0)
            begin
            data_in_rden <= 1'b1;
            read_stage   <= 2'd1;
            end

        else if (read_stage == 2'd1)
            begin
            data_in_rden <= 1'b0;
            read_stage   <= 2'd2;
            end

        else if (read_stage == 2'd2)
            begin
            data_ready   <= 1'b1;
            read_stage   <= 2'd3;
            end
        
        else if (read_stage == 2'd3)
            begin
            data_ready   <= 1'b0;
            read_stage   <= 2'd0;
            end

        else
            begin
            data_ready   <= 1'b0;
            data_in_rden <= 1'b0;
            read_stage   <= 2'd0;
            end
        end
end

// Shift process
always @(posedge clk)
begin
    if (rst)
        begin
        shift_reg      <= 32'd0;
        shift_counter  <=  5'd0;
        sr_empty       <=  1'b1;
        data_out_valid <=  1'b0;
        need_data      <=  1'b0;
        end
    else
        begin
        if (sr_en)
            begin
            // If shift register is empty...
            if (sr_empty)
                begin
                // And fifo is empty, deassert data validity
                if (!data_ready)
                    begin
                    data_out_valid <= 1'b0;
                    need_data      <= 1'b1;
                    end
                // Otherwise, load data from fifo into shift register, shift data, assert data validity
                else
                    begin
                    data_out       <= fifo_dout[1:0];
                    data_out_valid <= 1'b1;
                    need_data      <= 1'b0;
                    shift_reg      <= {2'b0, fifo_dout[31:2]};
                    shift_counter  <= 5'd0;
                    sr_empty       <= 1'b0;
                    end
                end
            // If shift register is not empty, shift data, assert data validity
            else
                begin
                data_out       <= shift_reg[1:0];          // Assign out value from the main register
                data_out_valid <= 1'b1;
                shift_reg      <= {2'b0, shift_reg[31:2]}; // Shift main register
                shift_counter  <= shift_counter + 1;       // Count shifts up to 32
                
                if (shift_counter == 5'd14)
                    sr_empty   <= 1'b1;
                end
            end
        else
            data_out_valid <= 1'b0;
        end
end

endmodule
