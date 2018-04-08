`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.02.2018 10:40:48
// Design Name: 
// Module Name: tb_final
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


module tb_final();
    
    reg bus_clk, quiesce;
    
    // FROM XILLYBUS
    // Wires related to /dev/xillybus_write_32
    reg        user_w_write_32_wren;
    wire       user_w_write_32_full;
    reg [31:0] user_w_write_32_data;
    reg        user_w_write_32_open;
    
    // Wires related to /dev/xillybus_read_32
    reg        user_r_read_32_rden;
    wire       user_r_read_32_empty;
    wire [31:0] user_r_read_32_data;
    reg         user_r_read_32_eof;
    reg         user_r_read_32_open;

    // Define the length of processing element array
    parameter SEQ_DEPTH = 50;
    
    // TODO! X sequence preloading
    wire [1:0] seq_X[0:SEQ_DEPTH-1] = {
        {2'd3}, {2'd1}, {2'd2}, {2'd3},
        {2'd1}, {2'd2}, {2'd2}, {2'd1},
        {2'd2}, {2'd1}, {2'd3}, {2'd2},
        {2'd2}, {2'd2}, {2'd3}, {2'd1},
        {2'd3}, {2'd0}, {2'd2}, {2'd3},
        {2'd3}, {2'd1}, {2'd1}, {2'd1},
        {2'd0}, {2'd1}, {2'd3}, {2'd0},
        {2'd0}, {2'd2}, {2'd3}, {2'd3},
        {2'd1}, {2'd3}, {2'd1}, {2'd0},
        {2'd2}, {2'd1}, {2'd0}, {2'd0},
        {2'd0}, {2'd2}, {2'd2}, {2'd3},
        {2'd2}, {2'd0}, {2'd3}, {2'd3},
        {2'd2}, {2'd1} };
    
    // TB Y sequence memory
    reg  [1:0] TB_seq_y_mem[0:8];
    reg [99:0] TB_seq_y_bin;
    
    // Processing element temporary registers
    wire [15:0] score_pipe[SEQ_DEPTH-1:0];
    wire [1:0]  Y_pipe[SEQ_DEPTH-1:0];
    wire [SEQ_DEPTH-1:0] Y_valid_pipe;
    
    // Temporary score register
    reg [15:0] score_out;
    reg score_out_valid;
    
    reg [1:0] Y_r;
    reg Y_valid;
    
    reg [15:0] stall_counter;
    reg stall;
    
    // Y sequence 32x2 bit shifter signals
    reg         sr_seq_y_en;
    reg        sr_seq_y_valid;
    wire       sr_seq_y_valid_out;
    reg  [31:0] sr_seq_y_din;
    wire  [1:0] sr_seq_y_dout;
    wire        sr_seq_y_empty;
    wire        sr_seq_y_nempty;
    
    shift_2x32_v2 shift_Y(
        .clk(bus_clk),
        .rst(quiesce),
        .valid(sr_seq_y_valid),
        .en(sr_seq_y_en),
        .sr_in(sr_seq_y_din),
        .sr_out(sr_seq_y_dout),
        .valid_out(sr_seq_y_valid_out),
        .empty(sr_seq_y_empty),
        .near_empty(sr_seq_y_nempty)
    );
    
    reg [SEQ_DEPTH-1:0] proc_en;
    reg [15:0] proc_counter;
    reg proc_stage;
    
    sw_pe pe_init(
        .clk(bus_clk),
        .rst(!proc_en[0]),
        .X_i(seq_X[0]),
        .Y_i(Y_r),
        .valid_i(Y_valid),
        .top_i(16'd0),
        .score_o(score_pipe[0]),
        .Y_o(Y_pipe[0]),
        .valid_o(Y_valid_pipe[0])
    );
    
    genvar i;
    generate
       for (i=1; i<SEQ_DEPTH; i=i+1) begin : pe_
         sw_pe pe(
           .clk(bus_clk),
           .rst(!proc_en[i]),
           .X_i(seq_X[i]),
           .Y_i(Y_pipe[i-1]),
           .valid_i(Y_valid),
           .top_i(score_pipe[i-1]),
           .score_o(score_pipe[i]),
           .Y_o(Y_pipe[i]),
           .valid_o(Y_valid_pipe[i])
         );
       end
    endgenerate
    
    reg        fifo_rden;
    wire       fifo_empty;
    wire [31:0] fifo_data;
    
    fifo_32x512 fifo_32_Y(
        .clk(bus_clk),
        .srst(!user_w_write_32_open && !user_r_read_32_open),
        .din(user_w_write_32_data),
        .wr_en(user_w_write_32_wren),
        .rd_en(fifo_rden),
        .dout(fifo_data),
        .full(user_w_write_32_full),
        .empty(fifo_empty)
    );
    
    wire fifo_out_full;
    reg fifo_out_wren;

    fifo_32x512 fifo_32_SC(
        .clk(bus_clk),
        .srst(!user_r_read_32_open && !user_w_write_32_open),
        .din({16'd0, score_out}),
        .wr_en(fifo_out_wren),
        .rd_en(user_r_read_32_rden),
        .dout(user_r_read_32_data),
        .full(fifo_out_full),
        .empty(user_r_read_32_empty)
    );
    
    // Preload X and Y
    integer j;
    initial
    begin
        for (j=0; j<SEQ_DEPTH; j=j+1)
            TB_seq_y_mem[j] = 2'b00;
        
//         $fread(seq_X, 
//            $fopen("/home/vytas/INF4/Verilog/dnabinary_X_small", "rb"));
        $fread(TB_seq_y_mem, 
            $fopen("/home/vytas/INF4/Verilog/dnabinary_Y_small", "rb"));
        
        TB_seq_y_bin[1:0] = TB_seq_y_mem[0];
        TB_seq_y_bin[3:2] = TB_seq_y_mem[1];
        TB_seq_y_bin[5:4] = TB_seq_y_mem[2];
        TB_seq_y_bin[7:6] = TB_seq_y_mem[3];
        TB_seq_y_bin[9:8] = TB_seq_y_mem[4];
        TB_seq_y_bin[11:10] = TB_seq_y_mem[5];
        TB_seq_y_bin[13:12] = TB_seq_y_mem[6];
        TB_seq_y_bin[15:14] = TB_seq_y_mem[7];
//        TB_seq_y_bin[17:16] = TB_seq_y_mem[8];
//        TB_seq_y_bin[19:18] = TB_seq_y_mem[9];
//        TB_seq_y_bin[21:20] = TB_seq_y_mem[10];
//        TB_seq_y_bin[23:22] = TB_seq_y_mem[11];
//        TB_seq_y_bin[25:24] = TB_seq_y_mem[12];
//        TB_seq_y_bin[27:26] = TB_seq_y_mem[13];
//        TB_seq_y_bin[29:28] = TB_seq_y_mem[14];
//        TB_seq_y_bin[31:30] = TB_seq_y_mem[15];
//        TB_seq_y_bin[33:32] = TB_seq_y_mem[16];
//        TB_seq_y_bin[35:34] = TB_seq_y_mem[17];
//        TB_seq_y_bin[37:36] = TB_seq_y_mem[18];
//        TB_seq_y_bin[39:38] = TB_seq_y_mem[19];
//        TB_seq_y_bin[41:40] = TB_seq_y_mem[20];
//        TB_seq_y_bin[43:42] = TB_seq_y_mem[21];
//        TB_seq_y_bin[45:44] = TB_seq_y_mem[22];
//        TB_seq_y_bin[47:46] = TB_seq_y_mem[23];
//        TB_seq_y_bin[49:48] = TB_seq_y_mem[24];
        
        TB_seq_y_bin[99:16] = 83'd0;
    end
    
    reg [31:0] cnt = 32'd0;
    
    // Set values
    initial
    begin
        // Initial values
        bus_clk = 1'b0;
        quiesce = 1'b1;
        proc_en = {SEQ_DEPTH{1'b0}};
        proc_counter = 16'd0;
        proc_stage = 1'b0;
        sr_seq_y_en = 1'b0;
        Y_valid = 1'b0;

        stall = 1'b0;
        stall_counter = 16'd0;
       
        #10
        quiesce = 1'b0;
        user_w_write_32_open = 1'b1;
        
        user_w_write_32_wren = 1'b1;
        user_w_write_32_data = TB_seq_y_bin[31:0];
        TB_seq_y_bin = TB_seq_y_bin >> 32;
        #2 user_w_write_32_wren = 1'b0;
        
        user_w_write_32_wren = 1'b1;
        user_w_write_32_data = TB_seq_y_bin[31:0];
        TB_seq_y_bin = TB_seq_y_bin >> 32;
        #2 user_w_write_32_wren = 1'b0;
        
        user_w_write_32_wren = 1'b1;
        user_w_write_32_data = TB_seq_y_bin[31:0];
        TB_seq_y_bin = TB_seq_y_bin >> 32;
        #2 user_w_write_32_wren = 1'b0;
        
        user_w_write_32_open = 1'b0;
        
        user_r_read_32_open = 1'b1;
        user_r_read_32_rden = 1'b1;
        
        while (cnt < SEQ_DEPTH + 12)
            begin
            if (!user_r_read_32_empty)
                $display(user_r_read_32_data);
            
            #2 if (user_r_read_32_empty)
                begin
                $display(user_r_read_32_data);
                $display("%b", 8'b11111111);
                cnt = cnt + 1;
                end
            end
       
        #500 $finish;
    end
    
    always
        #1 bus_clk = !bus_clk;
        
    reg toggle_y_load = 1'b0;
    
    /* Y sequence stream process */
    always @(posedge bus_clk)
            begin
            user_r_read_32_eof <= !user_w_write_32_open && 
                                  sr_seq_y_empty && fifo_empty &&
                                  user_r_read_32_open &&
                                  user_r_read_32_empty;
            if (!stall)
                begin
                fifo_out_wren <= 1'b0;
                if (sr_seq_y_empty)
                    begin
                    sr_seq_y_din <= fifo_data;
                    sr_seq_y_valid <= 1'b1;
                    end
                else
                    sr_seq_y_valid <= 1'b0;
                
                if (proc_stage == 1'b0)
                    begin
                    sr_seq_y_en <= 1'b1;
                    
                    if (sr_seq_y_valid_out)
                        begin
                        Y_valid         <= 1'b1;
                        score_out_valid <= 1'b1;
                        end
                    else
                        begin
                        Y_valid         <= 1'b0;
                        score_out_valid <= 1'b0;
                        end
                    
                    Y_r         <= sr_seq_y_dout;
                    stall       <= 1'b0;
                    proc_stage  <= 1'b1;
                    end
                else
                    begin
                    sr_seq_y_en  <= 1'b0;
                    Y_valid      <= 1'b0;
                    
                    if (proc_counter > 16'd0)
                        proc_en[proc_counter-1] <= 1'b1;
                    
                    if (proc_counter < SEQ_DEPTH)
                        proc_counter <= proc_counter + 1;

                    stall        <= 1'b1;
                    proc_stage   <= 1'b0;
                    end
                end
            else
                begin
                if (toggle_y_load)
                    begin
                    fifo_rden <= 1'b0;
                    end
                else if (sr_seq_y_empty && !fifo_empty)
                    begin
                    fifo_rden <= 1'b1;
                    toggle_y_load <= 1'b1;
                    end        
                
                if (!fifo_out_full)
                    begin
                    if (sr_seq_y_valid_out && score_out_valid)
                        begin
                        fifo_out_wren <= 1'b1;
                        score_out     <= score_pipe[stall_counter];
                        end
                    stall_counter <= stall_counter + 1;
                    end
                
                if (stall_counter == SEQ_DEPTH - 1)
                    begin                    
                    stall_counter <= 16'd0;
                    stall <= 1'b0;
                    toggle_y_load <= 1'b0;
                    end
                end
            end

endmodule
