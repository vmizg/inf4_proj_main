    /********************************************/
    /* SMITH WATERMAN SEQUENCE COMPARISON LOGIC */
    /********************************************/
   
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
    
    // Processing element temporary registers
    wire [15:0] score_pipe[SEQ_DEPTH-1:0];
    wire [1:0]  Y_pipe[SEQ_DEPTH-1:0];
    wire [SEQ_DEPTH-1:0] Y_valid_pipe;
    
    // Temporary score register
    reg [15:0] score_out;
    
    reg [1:0] Y_r;
    reg Y_valid;
    
    reg [15:0] stall_counter;
   
    reg [SEQ_DEPTH-1:0] proc_en;
    reg [15:0] proc_counter;
   
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
    
    ///////////////////////////////////////////////
    //  FIFO shifter for incoming Y sequence stream
    //  Using the "xillybus_write_32" interface
    //  for the host -> FPGA stream of sequence Y:
    //  host input:  user_w_stream_dna_y_wren
    //  FPGA output: user_w_stream_dna_y_full
    //  host input:  user_w_stream_dna_y_data [31:0]
    //  host input:  user_r_stream_score_out_open
    ///////////////////////////////////////////////
    
    reg        fifo_32_Y_sren;
    wire       fifo_32_Y_dout_valid;
    wire [1:0] fifo_32_Y_dout;
    wire       fifo_32_Y_srempty;
    wire       fifo_32_Y_ffempty;
    
    fifo_shift_2x32 fifo_32_Y(
        .clk(bus_clk),
        .rst(!user_r_stream_score_out_open && !user_w_stream_dna_y_open),
        .sr_en(fifo_32_Y_sren),
        .data_in(user_w_stream_dna_y_data),
        .data_in_valid(user_w_stream_dna_y_wren),
        .data_out(fifo_32_Y_dout),
        .data_out_valid(fifo_32_Y_dout_valid),
        .fifo_full(user_w_stream_dna_y_full),
        .sr_empty(fifo_32_Y_srempty),
        .fifo_empty(fifo_32_Y_ffempty)
    );
    
    /////////////////////////////////////////////
    //  FIFO for outgoing stream of results.
    //  Using the "xillybus_read_32" interface
    //  for the FPGA -> host stream of results:
    //  host input:  user_r_stream_score_out_rden
    //  FPGA output: user_r_stream_score_out_empty
    //  FPGA output: user_r_stream_score_out_data [31:0]
    //  FPGA output: user_r_stream_score_out_eof
    //  host input:  user_r_stream_score_out_open
    /////////////////////////////////////////////
    
    wire fifo_32_score_out_full;
    reg fifo_32_score_out_wren;

    fifo_32x512 fifo_32_SC(
        .clk(bus_clk),
        .srst(!user_r_stream_score_out_open && !user_w_stream_dna_y_open),
        .din({16'd0, score_out}),
        .wr_en(fifo_32_score_out_wren),
        .rd_en(user_r_stream_score_out_rden),
        .dout(user_r_stream_score_out_data),
        .full(fifo_32_score_out_full),
        .empty(user_r_stream_score_out_empty)
    );
    
    /********************************************/
    /* SSD DISPLAY LOGIC                        */
    /* Borrowed from INF3 Computer Design       */
    /* Coursework templates                     */
    /* (c) Nigel Topham                         */
    /********************************************/
    
    wire [7:0] ssd_input;
    
    ssd_driver u_ssd_driver (
        .clk        (bus_clk),   // clock input
        .reset      (quiesce),   // reset input
        .ssd_input  (ssd_input), // value to display, 8-bit integer
        .ssd_a      (ssd_a),     // 7-bit unary code to drive display
        .ssd_c      (ssd_c)      // control signal to switch between digits
    );
    
    reg [15:0] final_counter;
    reg final_flag;
    
    assign ssd_input = {2'b0,
            !user_r_stream_score_out_open && !user_w_stream_dna_y_open,
            final_counter == SEQ_DEPTH,
            user_r_stream_score_out_open,
            user_w_stream_dna_y_open,
            final_flag,
            user_r_stream_score_out_eof};
            
    /* Y sequence stream (host -> FPGA) process */
    always @(posedge bus_clk)
    begin
    // Read side open acts as a spark -
    // the write side operates no matter what by writing the data to the buffer
    // and waiting if the buffer is full until results have been read off
    if (user_r_stream_score_out_open)
        begin
        /* 1. Enable reading off shift register */
        if (stall_counter == 16'd0)
            begin
            fifo_32_Y_sren         <= 1'b1;
            fifo_32_score_out_wren <= 1'b0;
            stall_counter          <= stall_counter + 1;
            
            if (user_r_stream_score_out_empty && final_flag && final_counter == SEQ_DEPTH)
                user_r_stream_score_out_eof <= 1'b1;
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
        final_counter      <= 16'd0;
        final_flag         <=  1'b0;
        user_r_stream_score_out_eof <=  1'b0;
        end
    end
    
    /*******************************************/
