`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2018 09:42:00
// Design Name: 
// Module Name: sw_proc
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


module sw_proc(
        input clk,
        input rst,
        output [6:0]  ssd_a,
        output        ssd_c,
        input         user_w_stream_dna_x_wren,
        output        user_w_stream_dna_x_full,
        input [31:0]  user_w_stream_dna_x_data,
        input         user_w_stream_dna_x_open,
        input         user_w_stream_dna_y_wren,
        output        user_w_stream_dna_y_full,
        input [31:0]  user_w_stream_dna_y_data,
        input         user_w_stream_dna_y_open,
        input         user_r_stream_score_out_rden,
        output        user_r_stream_score_out_empty,
        output [31:0] user_r_stream_score_out_data,
        output reg    user_r_stream_score_out_eof = 1,
        input         user_r_stream_score_out_open
    );
    
     /********************************************/
     /* SMITH WATERMAN SEQUENCE COMPARISON LOGIC */
     /********************************************/
    
     // Define the length of processing element array
     parameter SEQ_DEPTH = 160;
     
     // Wires related to processing elements
     reg  [(SEQ_DEPTH*2)-1:0] X_pipe = {SEQ_DEPTH*2{1'b0}};
     wire [1:0]     Y_pipe[SEQ_DEPTH-1:0];
     wire [9:0] score_pipe[SEQ_DEPTH-1:0];
     wire [SEQ_DEPTH-1:0] Y_valid_pipe;
     reg            [1:0] Y_r;
     reg                  Y_valid;
     
     // Registers related to control logic
     reg [SEQ_DEPTH-1:0] proc_en       = {SEQ_DEPTH{1'b0}};
     reg          [10:0] proc_counter  = 11'd0;
     reg          [10:0] stall_counter = 11'd0;
     reg          [10:0] final_counter = 11'd0;
     reg                 final_flag    =  1'b1;
     
     // Temporary score register
     reg [9:0] score_out;
    
     /*****************************************************/
     /* PROCESSING ELEMENTS                               */
     /*****************************************************/
     
     sw_pe pe_init(
         .clk(clk),
         .rst(!proc_en[0]),
         .X_i(X_pipe[1:0]),
         .Y_i(Y_r),
         .valid_i(Y_valid),
         .top_i(10'd0),
         .score_o(score_pipe[0]),
         .Y_o(Y_pipe[0]),
         .valid_o(Y_valid_pipe[0])
     );
     
     genvar i;
     generate
         for (i=1; i<SEQ_DEPTH; i=i+1) begin : pe_
             sw_pe pe(
                 .clk(clk),
                 .rst(!proc_en[i]),
                 .X_i(X_pipe[(i*2)+1:(i*2)]),
                 .Y_i(Y_pipe[i-1]),
                 .valid_i(Y_valid),
                 .top_i(score_pipe[i-1]),
                 .score_o(score_pipe[i]),
                 .Y_o(Y_pipe[i]),
                 .valid_o(Y_valid_pipe[i])
             );
         end
     endgenerate
    
     /*****************************************************/
     /*  Logic for incoming X sequence preload.           */
     /*  Using the stream_dna_x 32-bit interface          */
     /*                                                   */
     /*  host input:  user_w_stream_dna_x_wren            */
     /*  FPGA output: user_w_stream_dna_x_full            */
     /*  host input:  user_w_stream_dna_x_data [31:0]     */
     /*  host input:  user_w_stream_dna_x_open            */
     /*****************************************************/
     
     reg   [3:0] X_load_counter;
     reg         X_load_ready;
     
     // Will never be full since will only fill to a maximum of 160 bases
     assign user_w_stream_dna_x_full = 1'b0;

     always @(posedge clk)
        begin
        if (user_r_stream_score_out_eof)
            begin
            X_pipe                   <= {SEQ_DEPTH{1'b0}};
            X_load_counter           <= 4'd0;
            X_load_ready             <= 1'b0;
            end
        else 
            begin
            if ((!user_w_stream_dna_x_open && X_load_counter > 4'd0) || X_load_counter == 4'd9)
                X_load_ready  = 1'b1;
            if (user_w_stream_dna_x_open && user_w_stream_dna_x_wren && !X_load_ready && X_load_counter < 4'd9)
                begin
                X_pipe         <= {X_pipe[(SEQ_DEPTH*2)-33:0], user_w_stream_dna_x_data};
                X_load_counter <= X_load_counter + 1;
                end
            end
        end
     
     /*****************************************************/
     /*  FIFO shifter for incoming Y sequence stream      */
     /*  Using the stream_dna_y 32-bit interface          */
     /*                                                   */
     /*  host input:  user_w_stream_dna_y_wren            */
     /*  FPGA output: user_w_stream_dna_y_full            */
     /*  host input:  user_w_stream_dna_y_data [31:0]     */
     /*  host input:  user_w_stream_dna_y_open            */
     /*****************************************************/
     
     reg        fifo_32_Y_sren;
     wire       fifo_32_Y_dout_valid;
     wire [1:0] fifo_32_Y_dout;
     wire       fifo_32_Y_srempty;
     wire       fifo_32_Y_ffempty;
     
     fifo_shift_2x32 fifo_32_Y(
         .clk(clk),
         .rst(final_flag), // Reset after sequence Y has passed through fully
         .sr_en(fifo_32_Y_sren),
         .data_in(user_w_stream_dna_y_data),
         .data_in_wren(user_w_stream_dna_y_wren),
         .data_out(fifo_32_Y_dout),
         .data_out_valid(fifo_32_Y_dout_valid),
         .fifo_full(user_w_stream_dna_y_full),
         .sr_empty(fifo_32_Y_srempty),
         .fifo_empty(fifo_32_Y_ffempty)
     );
     
     /*****************************************************/
     /*  FIFO for outgoing stream of results.             */
     /*  Using the stream_score_out 32-bit interface      */
     /*                                                   */
     /*  host input:  user_r_stream_score_out_rden        */
     /*  FPGA output: user_r_stream_score_out_empty       */
     /*  FPGA output: user_r_stream_score_out_data [31:0] */
     /*  FPGA output: user_r_stream_score_out_eof         */
     /*  host input:  user_r_stream_score_out_open        */
     /*****************************************************/
     
     wire fifo_32_score_out_full;
     reg fifo_32_score_out_wren;
 
     fifo_32x512 fifo_32_SC(
         .clk(clk),
         .srst(user_r_stream_score_out_eof), // After EOF, score fifo resets
         .din({22'd0, score_out}),
         .wr_en(fifo_32_score_out_wren),
         .rd_en(user_r_stream_score_out_rden),
         .dout(user_r_stream_score_out_data),
         .full(fifo_32_score_out_full),
         .empty(user_r_stream_score_out_empty)
     );
     
     /********************************************/
     /* SSD DISPLAY LOGIC (DEBUGGING)            */
     /* Borrowed from INF3 Computer Design       */
     /* Coursework templates                     */
     /* (c) Nigel Topham                         */
     /********************************************/

      wire [7:0] ssd_input;
     
      ssd_driver u_ssd_driver (
          .clk        (clk),   // clock input
          .reset      (rst),   // reset input
          .ssd_input  (ssd_input), // value to display, 8-bit integer
          .ssd_a      (ssd_a),     // 7-bit unary code to drive display
          .ssd_c      (ssd_c)      // control signal to switch between digits
      );
     
      assign ssd_input = {1'd0,
              user_r_stream_score_out_eof,
              fifo_32_score_out_full,
              user_r_stream_score_out_open,
              proc_counter,
              user_w_stream_dna_y_open,
              X_load_ready,
              user_w_stream_dna_x_open
              };
     
     /*****************************************************/       
     /* SEQUENCE ALIGNMENT CONTROL LOGIC                  */
     /* Read side open acts as a start light - the write  */
     /* side can operate at any point by writing the data */
     /* to the buffer and waiting if the buffer is full   */
     /* until results have been read off                  */
     /*****************************************************/
 
     always @(posedge clk)
     begin
     if (user_r_stream_score_out_open && X_load_ready)
         begin
         /* 1. Enable reading off shift register */
         if (stall_counter == 11'd0)
             begin
             fifo_32_Y_sren         <= 1'b1;
             fifo_32_score_out_wren <= 1'b0;
             stall_counter          <= stall_counter + 1;
             
             if (user_r_stream_score_out_empty && final_flag && final_counter == SEQ_DEPTH)
                 user_r_stream_score_out_eof <= 1'b1;
             end
             
         /* 2. Read off shift register. */
         else if (stall_counter == 11'd1)
             begin
             fifo_32_Y_sren <= 1'b0;
             stall_counter  <= stall_counter + 1;
             end
             
         /* 3. Enable processing element. */
         else if (stall_counter == 11'd2)
             begin
             if (!final_flag)
                 final_flag <= !user_w_stream_dna_y_open && fifo_32_Y_srempty && fifo_32_Y_ffempty;
                 
             if (fifo_32_Y_dout_valid && !final_flag)
                 begin
                 Y_r                   <= fifo_32_Y_dout;
                 Y_valid               <= 1'b1;
                 proc_en[proc_counter] <= 1'b1;
                 if (proc_counter < SEQ_DEPTH)
                     proc_counter <= proc_counter + 1;
                 
                 stall_counter    <= stall_counter + 1;
                 end
             else if (final_flag && final_counter < SEQ_DEPTH)
                 begin
                 Y_valid                <= 1'b1;
                 proc_en[final_counter] <= 1'b0;
                 proc_en[proc_counter]  <= 1'b1;
                 final_counter <= final_counter + 1;
                 if (proc_counter < SEQ_DEPTH)
                     proc_counter <= proc_counter + 1;
                 
                 stall_counter    <= stall_counter + 1; 
                 end
             else
                 begin
                 Y_valid       <= 1'b0;
                 stall_counter <= 11'd0;
                 end
             end
         
         /* 4. Process character */
         else if (stall_counter == 11'd3)
             begin
             Y_valid       <= 1'b0;
             stall_counter <= stall_counter + 1;
             end
             
         /* 5. If character processed, proceed writing scores.    */
         /* If score buffer full, hold until score FIFO frees up. */
         else
             begin
             // Y_valid_pipe == proc_en signals when all processing elements
             // that are enabled are done due to combinational FSM logic
             if (!fifo_32_score_out_full && Y_valid_pipe == proc_en)
                 begin
                 fifo_32_score_out_wren <= 1'b1;
                 score_out              <= score_pipe[stall_counter-4];
                 
                 if (stall_counter == SEQ_DEPTH + 3)
                     stall_counter <= 11'd0;
                 else
                     stall_counter <= stall_counter + 1;
                 end
             else
                 fifo_32_score_out_wren <= 1'b0;
             end
         end
     else
         begin
         proc_en                     <= {SEQ_DEPTH{1'b0}};
         proc_counter                <= 11'd0;
         stall_counter               <= 11'd0;
         final_counter               <= 11'd0;
         fifo_32_Y_sren              <=  1'b0;
         Y_valid                     <=  1'b0;
         final_flag                  <=  1'b0;
         user_r_stream_score_out_eof <=  1'b0;
         end
     end
     
     /*******************************************/
endmodule
