// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module top(clk_100, otg_oc, PS_GPIO, ssd_a, ssd_c, GPIO_LED, vga4_blue, vga4_green, vga4_red, vga_hsync, vga_vsync, hdmi_clk_p, hdmi_clk_n, hdmi_d_p, hdmi_d_n, hdmi_out_en, audio_mclk, audio_dac, audio_adc, audio_bclk, audio_adc_lrclk, audio_dac_lrclk, audio_mute, smb_sclk, smb_sdata);
  input clk_100;
  input otg_oc;
  inout [47:0]PS_GPIO;
  output [6:0]ssd_a;
  output ssd_c;
  output [3:0]GPIO_LED;
  output [4:0]vga4_blue;
  output [5:0]vga4_green;
  output [4:0]vga4_red;
  output vga_hsync;
  output vga_vsync;
  output hdmi_clk_p;
  output hdmi_clk_n;
  output [2:0]hdmi_d_p;
  output [2:0]hdmi_d_n;
  output hdmi_out_en;
  output audio_mclk;
  output audio_dac;
  input audio_adc;
  input audio_bclk;
  input audio_adc_lrclk;
  input audio_dac_lrclk;
  output audio_mute;
  inout smb_sclk;
  inout smb_sdata;
endmodule
