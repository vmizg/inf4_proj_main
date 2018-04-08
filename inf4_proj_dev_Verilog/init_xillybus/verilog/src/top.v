module top
  (
  input  clk_100,
  input  otg_oc,   
  inout [47:0] PS_GPIO,
  output [6:0] ssd_a,
  output ssd_c,
  output [3:0] GPIO_LED,
  output [4:0] vga4_blue,
  output [5:0] vga4_green,
  output [4:0] vga4_red,
  output  vga_hsync,
  output  vga_vsync,
  output  hdmi_clk_p,
  output  hdmi_clk_n,
  output [2:0] hdmi_d_p,
  output [2:0] hdmi_d_n,
  output  hdmi_out_en,
  output  audio_mclk,
  output  audio_dac,
  input  audio_adc,
  input  audio_bclk,
  input  audio_adc_lrclk,
  input  audio_dac_lrclk,
  output  audio_mute,
  inout  smb_sclk,
  inout  smb_sdata   
  );
  
    // Clock and quiesce
  wire  bus_clk;
  wire  quiesce;


  // Wires related to /dev/xillybus_stream_dna_x
  wire  user_w_stream_dna_x_wren;
  wire  user_w_stream_dna_x_full;
  wire [31:0] user_w_stream_dna_x_data;
  wire  user_w_stream_dna_x_open;

  // Wires related to /dev/xillybus_stream_dna_y
  wire  user_w_stream_dna_y_wren;
  wire  user_w_stream_dna_y_full;
  wire [31:0] user_w_stream_dna_y_data;
  wire  user_w_stream_dna_y_open;

  // Wires related to /dev/xillybus_stream_score_out
  wire  user_r_stream_score_out_rden;
  wire  user_r_stream_score_out_empty;
  wire [31:0] user_r_stream_score_out_data;
  wire  user_r_stream_score_out_eof;
  wire  user_r_stream_score_out_open;

  // Wires related to Xillybus Lite
  wire  user_clk;
  wire  user_wren;
  wire  user_rden;
  wire [3:0] user_wstrb;
  wire [31:0] user_addr;
  wire [31:0] user_rd_data;
  wire [31:0] user_wr_data;
  wire  user_irq;
  
  // No interrupts
  assign user_irq = 0;


  xillybus xillybus_ins (

    // Ports related to /dev/xillybus_stream_dna_x
    // CPU to FPGA signals:
    .user_w_stream_dna_x_wren(user_w_stream_dna_x_wren),
    .user_w_stream_dna_x_full(user_w_stream_dna_x_full),
    .user_w_stream_dna_x_data(user_w_stream_dna_x_data),
    .user_w_stream_dna_x_open(user_w_stream_dna_x_open),


    // Ports related to /dev/xillybus_stream_dna_y
    // CPU to FPGA signals:
    .user_w_stream_dna_y_wren(user_w_stream_dna_y_wren),
    .user_w_stream_dna_y_full(user_w_stream_dna_y_full),
    .user_w_stream_dna_y_data(user_w_stream_dna_y_data),
    .user_w_stream_dna_y_open(user_w_stream_dna_y_open),


    // Ports related to /dev/xillybus_stream_score_out
    // FPGA to CPU signals:
    .user_r_stream_score_out_rden(user_r_stream_score_out_rden),
    .user_r_stream_score_out_empty(user_r_stream_score_out_empty),
    .user_r_stream_score_out_data(user_r_stream_score_out_data),
    .user_r_stream_score_out_eof(user_r_stream_score_out_eof),
    .user_r_stream_score_out_open(user_r_stream_score_out_open),


    // Ports related to Xillybus Lite
    .user_clk(user_clk),
    .user_wren(user_wren),
    .user_rden(user_rden),
    .user_wstrb(user_wstrb),
    .user_addr(user_addr),
    .user_rd_data(user_rd_data),
    .user_wr_data(user_wr_data),
    .user_irq(user_irq),


    // General signals
    .clk_100(clk_100),
    .otg_oc(otg_oc),
    .PS_GPIO(PS_GPIO),
    .GPIO_LED(GPIO_LED),
    .bus_clk(bus_clk),
    .hdmi_clk_n(hdmi_clk_n),
    .hdmi_clk_p(hdmi_clk_p),
    .hdmi_d_n(hdmi_d_n),
    .hdmi_d_p(hdmi_d_p),
    .hdmi_out_en(hdmi_out_en),
    .quiesce(quiesce),
    .vga4_blue(vga4_blue),
    .vga4_green(vga4_green),
    .vga4_red(vga4_red),
    .vga_hsync(vga_hsync),
    .vga_vsync(vga_vsync)
  );
  
  // Smith-Waterman processor
  sw_proc u_sw_proc(
      .clk(bus_clk),
      .rst(quiesce),
  
      // Sequence X 32bit preload interface
      .user_w_stream_dna_x_wren(user_w_stream_dna_x_wren),
      .user_w_stream_dna_x_full(user_w_stream_dna_x_full),
      .user_w_stream_dna_x_data(user_w_stream_dna_x_data),
      .user_w_stream_dna_x_open(user_w_stream_dna_x_open),

      // Sequence Y 32bit FIFO interface to a shifter
      .user_w_stream_dna_y_wren(user_w_stream_dna_y_wren),
      .user_w_stream_dna_y_full(user_w_stream_dna_y_full),
      .user_w_stream_dna_y_data(user_w_stream_dna_y_data),
      .user_w_stream_dna_y_open(user_w_stream_dna_y_open),

      // Score out 32bit FIFO interface
      .user_r_stream_score_out_rden(user_r_stream_score_out_rden),
      .user_r_stream_score_out_empty(user_r_stream_score_out_empty),
      .user_r_stream_score_out_data(user_r_stream_score_out_data),
      .user_r_stream_score_out_eof(user_r_stream_score_out_eof),
      .user_r_stream_score_out_open(user_r_stream_score_out_open),
  
      // SSD display debug signals
      .ssd_a(ssd_a),
      .ssd_c(ssd_c)
  );

endmodule