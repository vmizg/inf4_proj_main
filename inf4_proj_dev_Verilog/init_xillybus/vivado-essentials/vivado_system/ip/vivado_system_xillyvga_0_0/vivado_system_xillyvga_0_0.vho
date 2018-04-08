-- (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xillybus:xillybus:xillyvga:1.0
-- IP Revision: 1

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT vivado_system_xillyvga_0_0
  PORT (
    S_AXI_ACLK : IN STD_LOGIC;
    S_AXI_ARADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    S_AXI_ARESETN : IN STD_LOGIC;
    S_AXI_ARVALID : IN STD_LOGIC;
    S_AXI_AWADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    S_AXI_AWVALID : IN STD_LOGIC;
    S_AXI_BREADY : IN STD_LOGIC;
    S_AXI_RREADY : IN STD_LOGIC;
    S_AXI_WDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    S_AXI_WSTRB : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S_AXI_WVALID : IN STD_LOGIC;
    clk_in : IN STD_LOGIC;
    m_axi_aclk : IN STD_LOGIC;
    m_axi_aresetn : IN STD_LOGIC;
    m_axi_arready : IN STD_LOGIC;
    m_axi_awready : IN STD_LOGIC;
    m_axi_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_bvalid : IN STD_LOGIC;
    m_axi_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_rlast : IN STD_LOGIC;
    m_axi_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_rvalid : IN STD_LOGIC;
    m_axi_wready : IN STD_LOGIC;
    S_AXI_ARREADY : OUT STD_LOGIC;
    S_AXI_AWREADY : OUT STD_LOGIC;
    S_AXI_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S_AXI_BVALID : OUT STD_LOGIC;
    S_AXI_RDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    S_AXI_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S_AXI_RVALID : OUT STD_LOGIC;
    S_AXI_WREADY : OUT STD_LOGIC;
    dvi_clk_n : OUT STD_LOGIC;
    dvi_clk_p : OUT STD_LOGIC;
    dvi_d_n : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    dvi_d_p : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_arlen : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_arvalid : OUT STD_LOGIC;
    m_axi_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_awburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_awcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_awlen : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_awsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_awvalid : OUT STD_LOGIC;
    m_axi_bready : OUT STD_LOGIC;
    m_axi_rready : OUT STD_LOGIC;
    m_axi_wdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_wlast : OUT STD_LOGIC;
    m_axi_wstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_wvalid : OUT STD_LOGIC;
    vga_clk : OUT STD_LOGIC;
    vga_blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    vga_green : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    vga_hsync : OUT STD_LOGIC;
    vga_red : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    vga_vsync : OUT STD_LOGIC;
    vga_de : OUT STD_LOGIC
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : vivado_system_xillyvga_0_0
  PORT MAP (
    S_AXI_ACLK => S_AXI_ACLK,
    S_AXI_ARADDR => S_AXI_ARADDR,
    S_AXI_ARESETN => S_AXI_ARESETN,
    S_AXI_ARVALID => S_AXI_ARVALID,
    S_AXI_AWADDR => S_AXI_AWADDR,
    S_AXI_AWVALID => S_AXI_AWVALID,
    S_AXI_BREADY => S_AXI_BREADY,
    S_AXI_RREADY => S_AXI_RREADY,
    S_AXI_WDATA => S_AXI_WDATA,
    S_AXI_WSTRB => S_AXI_WSTRB,
    S_AXI_WVALID => S_AXI_WVALID,
    clk_in => clk_in,
    m_axi_aclk => m_axi_aclk,
    m_axi_aresetn => m_axi_aresetn,
    m_axi_arready => m_axi_arready,
    m_axi_awready => m_axi_awready,
    m_axi_bresp => m_axi_bresp,
    m_axi_bvalid => m_axi_bvalid,
    m_axi_rdata => m_axi_rdata,
    m_axi_rlast => m_axi_rlast,
    m_axi_rresp => m_axi_rresp,
    m_axi_rvalid => m_axi_rvalid,
    m_axi_wready => m_axi_wready,
    S_AXI_ARREADY => S_AXI_ARREADY,
    S_AXI_AWREADY => S_AXI_AWREADY,
    S_AXI_BRESP => S_AXI_BRESP,
    S_AXI_BVALID => S_AXI_BVALID,
    S_AXI_RDATA => S_AXI_RDATA,
    S_AXI_RRESP => S_AXI_RRESP,
    S_AXI_RVALID => S_AXI_RVALID,
    S_AXI_WREADY => S_AXI_WREADY,
    dvi_clk_n => dvi_clk_n,
    dvi_clk_p => dvi_clk_p,
    dvi_d_n => dvi_d_n,
    dvi_d_p => dvi_d_p,
    m_axi_araddr => m_axi_araddr,
    m_axi_arburst => m_axi_arburst,
    m_axi_arcache => m_axi_arcache,
    m_axi_arlen => m_axi_arlen,
    m_axi_arprot => m_axi_arprot,
    m_axi_arsize => m_axi_arsize,
    m_axi_arvalid => m_axi_arvalid,
    m_axi_awaddr => m_axi_awaddr,
    m_axi_awburst => m_axi_awburst,
    m_axi_awcache => m_axi_awcache,
    m_axi_awlen => m_axi_awlen,
    m_axi_awprot => m_axi_awprot,
    m_axi_awsize => m_axi_awsize,
    m_axi_awvalid => m_axi_awvalid,
    m_axi_bready => m_axi_bready,
    m_axi_rready => m_axi_rready,
    m_axi_wdata => m_axi_wdata,
    m_axi_wlast => m_axi_wlast,
    m_axi_wstrb => m_axi_wstrb,
    m_axi_wvalid => m_axi_wvalid,
    vga_clk => vga_clk,
    vga_blue => vga_blue,
    vga_green => vga_green,
    vga_hsync => vga_hsync,
    vga_red => vga_red,
    vga_vsync => vga_vsync,
    vga_de => vga_de
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

