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
    reg        fifo_32_Y_sren;
    wire       fifo_32_Y_dout_valid;
    wire [1:0] fifo_32_Y_dout;
    wire       fifo_32_Y_srempty;
    wire       fifo_32_Y_ffempty;
    
    fifo_shift_2x32 fifo_32_Y(
        .clk(bus_clk),
        .rst(quiesce),
        .sr_en(fifo_32_Y_sren),
        .data_in(user_w_write_32_data),
        .data_in_valid(user_w_write_32_wren),
        .data_out(fifo_32_Y_dout),
        .data_out_valid(fifo_32_Y_dout_valid),
        .fifo_full(user_w_write_32_full),
        .sr_empty(fifo_32_Y_srempty),
        .fifo_empty(fifo_32_Y_ffempty)
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
    
    wire fifo_32_score_out_full;
    reg fifo_32_score_out_wren;

    fifo_32x512 fifo_32_SC(
        .clk(bus_clk),
        .srst(!user_r_read_32_open && !user_w_write_32_open),
        .din({16'd0, score_out}),
        .wr_en(fifo_32_score_out_wren),
        .rd_en(user_r_read_32_rden),
        .dout(user_r_read_32_data),
        .full(fifo_32_score_out_full),
        .empty(user_r_read_32_empty)
    );
    
    // Preload X and Y
    integer j;
    initial
    begin
        for (j=0; j<SEQ_DEPTH; j=j+1)
            TB_seq_y_mem[j] = 2'b00;

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
        TB_seq_y_bin[17:16] = TB_seq_y_mem[8];
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
        
        TB_seq_y_bin[99:18] = 81'd0;
    end
    
    initial
    begin
        // Initial values
        bus_clk = 1'b0;
        quiesce = 1'b1;
        proc_en = {SEQ_DEPTH{1'b0}};
        proc_counter = 16'd0;
        proc_stage = 1'b0;
        fifo_32_Y_sren = 1'b0;
        Y_valid = 1'b0;

        stall_counter = 16'd0;
        user_r_read_32_eof = 1'b0;
        
        user_r_read_32_open = 1'b0;
        user_r_read_32_rden = 1'b0;
        
        user_w_write_32_open = 1'b0;
        user_w_write_32_wren = 1'b0;
        
        
        #10
        quiesce = 1'b0;
        
        #1000
        
        user_w_write_32_open = 1'b1;
//        #50 user_w_write_32_wren = 1'b1;
//        user_w_write_32_data = TB_seq_y_bin[31:0];
//        TB_seq_y_bin = TB_seq_y_bin >> 32;
//        #2 user_w_write_32_wren = 1'b0;
        
//        #1000

        TB_seq_y_bin[1:0] = 2'b11;
        TB_seq_y_bin[3:2] = 2'b01;
        TB_seq_y_bin[5:4] = 2'b11;
        TB_seq_y_bin[7:6] = 2'b01;
        TB_seq_y_bin[9:8] = 2'b01;
        TB_seq_y_bin[11:10] = 2'b00;
        TB_seq_y_bin[13:12] = 2'b01;
        TB_seq_y_bin[15:14] = 2'b01;
        TB_seq_y_bin[17:16] = 2'b00;
        TB_seq_y_bin[19:18] = 2'b01;
        TB_seq_y_bin[21:20] = 2'b00;
        TB_seq_y_bin[23:22] = 2'b11;
        TB_seq_y_bin[25:24] = 2'b01;
        TB_seq_y_bin[27:26] = 2'b01;
        TB_seq_y_bin[29:28] = 2'b00;
        TB_seq_y_bin[31:30] = 2'b11;
        
        user_w_write_32_wren = 1'b1;
        //user_w_write_32_data = TB_seq_y_bin[31:0];
        user_w_write_32_data = 32'b0;
        #2 user_w_write_32_wren = 1'b0;
        
        #4 user_w_write_32_open = 1'b0;
        
        #50000
        user_r_read_32_open = 1'b1;
        
        #5000
        while (!user_r_read_32_eof)
            begin
            user_r_read_32_rden = 1'b1;
            $display("%d",user_r_read_32_data);
            #2 user_r_read_32_rden = 1'b0;
            end

//        user_w_write_32_wren = 1'b1;
//        user_w_write_32_data = TB_seq_y_bin[31:0];
//        TB_seq_y_bin = TB_seq_y_bin >> 32;
//        #2 user_w_write_32_wren = 1'b0;
        
//        #5500
//        TB_seq_y_bin[1:0] = 2'b10;
//        TB_seq_y_bin[3:2] = 2'b11;
//        TB_seq_y_bin[5:4] = 2'b00;
//        TB_seq_y_bin[7:6] = 2'b10;
//        TB_seq_y_bin[9:8] = TB_seq_y_mem[4];
//        TB_seq_y_bin[11:10] = TB_seq_y_mem[5];
//        TB_seq_y_bin[13:12] = TB_seq_y_mem[6];
//        TB_seq_y_bin[15:14] = TB_seq_y_mem[7];
//        TB_seq_y_bin[17:16] = TB_seq_y_mem[8];
        
//        user_w_write_32_wren = 1'b1;
//        user_w_write_32_data = TB_seq_y_bin[31:0];
//        TB_seq_y_bin = TB_seq_y_bin >> 32;
//        #2 user_w_write_32_wren = 1'b0;
        
        #1000 $finish;
    end
    
    always
        #1 bus_clk = !bus_clk;

    reg [15:0] final_counter;
    reg final_flag;
    
    /* Y sequence stream process */
    always @(posedge bus_clk)
            begin
            if (user_r_read_32_open)
                begin
                /* 1. Enable reading off shift register */
                if (stall_counter == 16'd0)
                    begin
                    fifo_32_Y_sren         <= 1'b1;
                    fifo_32_score_out_wren <= 1'b0;
                    stall_counter          <= stall_counter + 1;
                    
                    if (user_r_read_32_empty && final_flag && final_counter == SEQ_DEPTH)
                        user_r_read_32_eof <= 1'b1;
                    end
                    
                /* 2. Read off shift register. */
                else if (stall_counter == 16'd1)
                    begin
                    fifo_32_Y_sren <= 1'b0;
                    stall_counter  <= stall_counter + 1;
                    end
                    
                /* 3. Enable processing element. */
                else if (stall_counter == 16'd2)
                    begin
                    if (!final_flag)
                        final_flag <= !user_w_write_32_open && fifo_32_Y_srempty && fifo_32_Y_ffempty;
                    
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
                        stall_counter     <= stall_counter + 1; 
                        end
                    else
                        begin
                        Y_valid          <= 1'b0;
                        stall_counter    <= 16'd0;
                        end
                    end
                
                /* 4. Process character */
                else if (stall_counter == 16'd3)
                    begin
                    Y_valid <= 1'b0;
                    stall_counter <= stall_counter + 1;
                    end
                    
                /* 5. If character processed, proceed writing scores.    */
                /* If score buffer full, hold until score FIFO frees up. */
                else
                    begin
                    if (!fifo_32_score_out_full)
                        begin
                        fifo_32_score_out_wren <= 1'b1;
                        score_out              <= score_pipe[stall_counter-4];
                        
                        if (stall_counter == SEQ_DEPTH + 3)
                            stall_counter <= 16'd0;
                        else
                            stall_counter <= stall_counter + 1;
                        end
                    else
                        fifo_32_score_out_wren <= 1'b0;
                    end
                end
            else
                begin
                proc_en            <= {SEQ_DEPTH{1'b0}};
                proc_counter       <= 16'd0;
                fifo_32_Y_sren     <=  1'b0;
                Y_valid            <=  1'b0;
                stall_counter      <= 16'd0;
                final_flag         <= 1'b0;
                user_r_read_32_eof <= 1'b0;
                final_counter      <= 16'd0;
                end
            end

endmodule