// (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.

// IP VLNV: xillybus:xillybus:xillyvga:1.0
// IP Revision: 1

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
vivado_system_xillyvga_0_0 your_instance_name (
  .S_AXI_ACLK(S_AXI_ACLK),        // input wire S_AXI_ACLK
  .S_AXI_ARADDR(S_AXI_ARADDR),    // input wire [31 : 0] S_AXI_ARADDR
  .S_AXI_ARESETN(S_AXI_ARESETN),  // input wire S_AXI_ARESETN
  .S_AXI_ARVALID(S_AXI_ARVALID),  // input wire S_AXI_ARVALID
  .S_AXI_AWADDR(S_AXI_AWADDR),    // input wire [31 : 0] S_AXI_AWADDR
  .S_AXI_AWVALID(S_AXI_AWVALID),  // input wire S_AXI_AWVALID
  .S_AXI_BREADY(S_AXI_BREADY),    // input wire S_AXI_BREADY
  .S_AXI_RREADY(S_AXI_RREADY),    // input wire S_AXI_RREADY
  .S_AXI_WDATA(S_AXI_WDATA),      // input wire [31 : 0] S_AXI_WDATA
  .S_AXI_WSTRB(S_AXI_WSTRB),      // input wire [3 : 0] S_AXI_WSTRB
  .S_AXI_WVALID(S_AXI_WVALID),    // input wire S_AXI_WVALID
  .clk_in(clk_in),                // input wire clk_in
  .m_axi_aclk(m_axi_aclk),        // input wire m_axi_aclk
  .m_axi_aresetn(m_axi_aresetn),  // input wire m_axi_aresetn
  .m_axi_arready(m_axi_arready),  // input wire m_axi_arready
  .m_axi_awready(m_axi_awready),  // input wire m_axi_awready
  .m_axi_bresp(m_axi_bresp),      // input wire [1 : 0] m_axi_bresp
  .m_axi_bvalid(m_axi_bvalid),    // input wire m_axi_bvalid
  .m_axi_rdata(m_axi_rdata),      // input wire [31 : 0] m_axi_rdata
  .m_axi_rlast(m_axi_rlast),      // input wire m_axi_rlast
  .m_axi_rresp(m_axi_rresp),      // input wire [1 : 0] m_axi_rresp
  .m_axi_rvalid(m_axi_rvalid),    // input wire m_axi_rvalid
  .m_axi_wready(m_axi_wready),    // input wire m_axi_wready
  .S_AXI_ARREADY(S_AXI_ARREADY),  // output wire S_AXI_ARREADY
  .S_AXI_AWREADY(S_AXI_AWREADY),  // output wire S_AXI_AWREADY
  .S_AXI_BRESP(S_AXI_BRESP),      // output wire [1 : 0] S_AXI_BRESP
  .S_AXI_BVALID(S_AXI_BVALID),    // output wire S_AXI_BVALID
  .S_AXI_RDATA(S_AXI_RDATA),      // output wire [31 : 0] S_AXI_RDATA
  .S_AXI_RRESP(S_AXI_RRESP),      // output wire [1 : 0] S_AXI_RRESP
  .S_AXI_RVALID(S_AXI_RVALID),    // output wire S_AXI_RVALID
  .S_AXI_WREADY(S_AXI_WREADY),    // output wire S_AXI_WREADY
  .dvi_clk_n(dvi_clk_n),          // output wire dvi_clk_n
  .dvi_clk_p(dvi_clk_p),          // output wire dvi_clk_p
  .dvi_d_n(dvi_d_n),              // output wire [2 : 0] dvi_d_n
  .dvi_d_p(dvi_d_p),              // output wire [2 : 0] dvi_d_p
  .m_axi_araddr(m_axi_araddr),    // output wire [31 : 0] m_axi_araddr
  .m_axi_arburst(m_axi_arburst),  // output wire [1 : 0] m_axi_arburst
  .m_axi_arcache(m_axi_arcache),  // output wire [3 : 0] m_axi_arcache
  .m_axi_arlen(m_axi_arlen),      // output wire [3 : 0] m_axi_arlen
  .m_axi_arprot(m_axi_arprot),    // output wire [2 : 0] m_axi_arprot
  .m_axi_arsize(m_axi_arsize),    // output wire [2 : 0] m_axi_arsize
  .m_axi_arvalid(m_axi_arvalid),  // output wire m_axi_arvalid
  .m_axi_awaddr(m_axi_awaddr),    // output wire [31 : 0] m_axi_awaddr
  .m_axi_awburst(m_axi_awburst),  // output wire [1 : 0] m_axi_awburst
  .m_axi_awcache(m_axi_awcache),  // output wire [3 : 0] m_axi_awcache
  .m_axi_awlen(m_axi_awlen),      // output wire [3 : 0] m_axi_awlen
  .m_axi_awprot(m_axi_awprot),    // output wire [2 : 0] m_axi_awprot
  .m_axi_awsize(m_axi_awsize),    // output wire [2 : 0] m_axi_awsize
  .m_axi_awvalid(m_axi_awvalid),  // output wire m_axi_awvalid
  .m_axi_bready(m_axi_bready),    // output wire m_axi_bready
  .m_axi_rready(m_axi_rready),    // output wire m_axi_rready
  .m_axi_wdata(m_axi_wdata),      // output wire [31 : 0] m_axi_wdata
  .m_axi_wlast(m_axi_wlast),      // output wire m_axi_wlast
  .m_axi_wstrb(m_axi_wstrb),      // output wire [3 : 0] m_axi_wstrb
  .m_axi_wvalid(m_axi_wvalid),    // output wire m_axi_wvalid
  .vga_clk(vga_clk),              // output wire vga_clk
  .vga_blue(vga_blue),            // output wire [7 : 0] vga_blue
  .vga_green(vga_green),          // output wire [7 : 0] vga_green
  .vga_hsync(vga_hsync),          // output wire vga_hsync
  .vga_red(vga_red),              // output wire [7 : 0] vga_red
  .vga_vsync(vga_vsync),          // output wire vga_vsync
  .vga_de(vga_de)                // output wire vga_de
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

