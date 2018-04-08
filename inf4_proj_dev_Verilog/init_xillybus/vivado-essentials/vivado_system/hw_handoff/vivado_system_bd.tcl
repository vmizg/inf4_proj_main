
################################################################
# This is a generated script based on design: vivado_system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source vivado_system_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z010clg400-1

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name vivado_system

# This script was generated for a remote BD.
set str_bd_folder /home/vytas/INF4/Verilog/init_xillybus/vivado-essentials
set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

# Check if remote design exists on disk
if { [file exists $str_bd_filepath ] == 1 } {
   puts "ERROR: The remote BD file path <$str_bd_filepath> already exists!\n"

   puts "INFO: Please modify the variable <str_bd_folder> to another path or modify the variable <design_name>."

   return 1
}

# Check if design exists in memory
set list_existing_designs [get_bd_designs -quiet $design_name]
if { $list_existing_designs ne "" } {
   puts "ERROR: The design <$design_name> already exists in this project!"
   puts "ERROR: Will not create the remote BD <$design_name> at the folder <$str_bd_folder>.\n"

   puts "INFO: Please modify the variable <design_name>."

   return 1
}

# Check if design exists on disk within project
set list_existing_designs [get_files */${design_name}.bd]
if { $list_existing_designs ne "" } {
   puts "ERROR: The design <$design_name> already exists in this project at location:"
   puts "   $list_existing_designs"
   puts "ERROR: Will not create the remote BD <$design_name> at the folder <$str_bd_folder>.\n"

   puts "INFO: Please modify the variable <design_name>."

   return 1
}

# Now can create the remote BD
create_bd_design -dir $str_bd_folder $design_name
current_bd_design $design_name

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set GPIO_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 GPIO_0 ]
  set USBIND_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:usbctrl_rtl:1.0 USBIND_0 ]
  set xillybus_M_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 xillybus_M_AXI ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {32} \
CONFIG.ARUSER_WIDTH {0} \
CONFIG.AWUSER_WIDTH {0} \
CONFIG.BUSER_WIDTH {0} \
CONFIG.CLK_DOMAIN {} \
CONFIG.DATA_WIDTH {64} \
CONFIG.FREQ_HZ {100000000} \
CONFIG.HAS_BRESP {1} \
CONFIG.HAS_BURST {1} \
CONFIG.HAS_CACHE {1} \
CONFIG.HAS_LOCK {1} \
CONFIG.HAS_PROT {1} \
CONFIG.HAS_QOS {1} \
CONFIG.HAS_REGION {1} \
CONFIG.HAS_RRESP {1} \
CONFIG.HAS_WSTRB {1} \
CONFIG.ID_WIDTH {0} \
CONFIG.MAX_BURST_LENGTH {16} \
CONFIG.NUM_READ_OUTSTANDING {1} \
CONFIG.NUM_WRITE_OUTSTANDING {1} \
CONFIG.PHASE {0.000} \
CONFIG.PROTOCOL {AXI3} \
CONFIG.READ_WRITE_MODE {READ_WRITE} \
CONFIG.RUSER_WIDTH {0} \
CONFIG.SUPPORTS_NARROW_BURST {1} \
CONFIG.WUSER_WIDTH {0} \
 ] $xillybus_M_AXI
  set xillybus_S_AXI [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 xillybus_S_AXI ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {32} \
CONFIG.DATA_WIDTH {32} \
CONFIG.PROTOCOL {AXI4LITE} \
 ] $xillybus_S_AXI

  # Create ports
  set clk_in [ create_bd_port -dir I clk_in ]
  set dvi_clk_n [ create_bd_port -dir O dvi_clk_n ]
  set dvi_clk_p [ create_bd_port -dir O dvi_clk_p ]
  set dvi_d_n [ create_bd_port -dir O -from 2 -to 0 dvi_d_n ]
  set dvi_d_p [ create_bd_port -dir O -from 2 -to 0 dvi_d_p ]
  set user_addr [ create_bd_port -dir O -from 31 -to 0 user_addr ]
  set user_clk [ create_bd_port -dir O user_clk ]
  set user_irq [ create_bd_port -dir I user_irq ]
  set user_rd_data [ create_bd_port -dir I -from 31 -to 0 user_rd_data ]
  set user_rden [ create_bd_port -dir O user_rden ]
  set user_wr_data [ create_bd_port -dir O -from 31 -to 0 user_wr_data ]
  set user_wren [ create_bd_port -dir O user_wren ]
  set user_wstrb [ create_bd_port -dir O -from 3 -to 0 user_wstrb ]
  set vga_blue [ create_bd_port -dir O -from 7 -to 0 vga_blue ]
  set vga_clk [ create_bd_port -dir O vga_clk ]
  set vga_de [ create_bd_port -dir O vga_de ]
  set vga_green [ create_bd_port -dir O -from 7 -to 0 vga_green ]
  set vga_hsync [ create_bd_port -dir O vga_hsync ]
  set vga_red [ create_bd_port -dir O -from 7 -to 0 vga_red ]
  set vga_vsync [ create_bd_port -dir O vga_vsync ]
  set xillybus_bus_clk [ create_bd_port -dir O xillybus_bus_clk ]
  set xillybus_bus_rst_n [ create_bd_port -dir O xillybus_bus_rst_n ]
  set xillybus_host_interrupt [ create_bd_port -dir I xillybus_host_interrupt ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {650.000000} \
CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.096154} \
CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {100.000000} \
CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {100.000000} \
CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} \
CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {50.000000} \
CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {108.333336} \
CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {108.333336} \
CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {108.333336} \
CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {108.333336} \
CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {108.333336} \
CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {108.333336} \
CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {50.000000} \
CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {108.333336} \
CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {650.000000} \
CONFIG.PCW_CLK0_FREQ {100000000} \
CONFIG.PCW_CLK1_FREQ {100000000} \
CONFIG.PCW_CLK3_FREQ {100000000} \
CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {50.000000} \
CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {1} \
CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_EN_CLK0_PORT {0} \
CONFIG.PCW_EN_CLK1_PORT {1} \
CONFIG.PCW_EN_EMIO_ENET0 {0} \
CONFIG.PCW_EN_EMIO_GPIO {1} \
CONFIG.PCW_EN_EMIO_I2C0 {0} \
CONFIG.PCW_EN_EMIO_WP_SDIO0 {1} \
CONFIG.PCW_EN_ENET0 {1} \
CONFIG.PCW_EN_GPIO {1} \
CONFIG.PCW_EN_I2C0 {0} \
CONFIG.PCW_EN_QSPI {1} \
CONFIG.PCW_EN_RST0_PORT {0} \
CONFIG.PCW_EN_RST1_PORT {1} \
CONFIG.PCW_EN_SDIO0 {1} \
CONFIG.PCW_EN_UART1 {1} \
CONFIG.PCW_EN_USB0 {1} \
CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {ARM PLL} \
CONFIG.PCW_FCLK_CLK1_BUF {true} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {100.000000} \
CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {100.000000} \
CONFIG.PCW_FPGA_FCLK1_ENABLE {1} \
CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_EMIO_GPIO_IO {48} \
CONFIG.PCW_GPIO_EMIO_GPIO_WIDTH {48} \
CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_IRQ_F2P_INTR {1} \
CONFIG.PCW_IRQ_F2P_MODE {REVERSE} \
CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_0_PULLUP {enabled} \
CONFIG.PCW_MIO_0_SLEW {slow} \
CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_10_PULLUP {enabled} \
CONFIG.PCW_MIO_10_SLEW {slow} \
CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_11_PULLUP {enabled} \
CONFIG.PCW_MIO_11_SLEW {slow} \
CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_12_PULLUP {enabled} \
CONFIG.PCW_MIO_12_SLEW {slow} \
CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_13_PULLUP {enabled} \
CONFIG.PCW_MIO_13_SLEW {slow} \
CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_14_PULLUP {enabled} \
CONFIG.PCW_MIO_14_SLEW {slow} \
CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_15_PULLUP {enabled} \
CONFIG.PCW_MIO_15_SLEW {slow} \
CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_16_PULLUP {enabled} \
CONFIG.PCW_MIO_16_SLEW {slow} \
CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_17_PULLUP {enabled} \
CONFIG.PCW_MIO_17_SLEW {slow} \
CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_18_PULLUP {enabled} \
CONFIG.PCW_MIO_18_SLEW {slow} \
CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_19_PULLUP {enabled} \
CONFIG.PCW_MIO_19_SLEW {slow} \
CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_1_PULLUP {enabled} \
CONFIG.PCW_MIO_1_SLEW {slow} \
CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_20_PULLUP {enabled} \
CONFIG.PCW_MIO_20_SLEW {slow} \
CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_21_PULLUP {enabled} \
CONFIG.PCW_MIO_21_SLEW {slow} \
CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_22_PULLUP {enabled} \
CONFIG.PCW_MIO_22_SLEW {slow} \
CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_23_PULLUP {enabled} \
CONFIG.PCW_MIO_23_SLEW {slow} \
CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_24_PULLUP {enabled} \
CONFIG.PCW_MIO_24_SLEW {slow} \
CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_25_PULLUP {enabled} \
CONFIG.PCW_MIO_25_SLEW {slow} \
CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_26_PULLUP {enabled} \
CONFIG.PCW_MIO_26_SLEW {slow} \
CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_27_PULLUP {enabled} \
CONFIG.PCW_MIO_27_SLEW {slow} \
CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_28_PULLUP {enabled} \
CONFIG.PCW_MIO_28_SLEW {slow} \
CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_29_PULLUP {enabled} \
CONFIG.PCW_MIO_29_SLEW {slow} \
CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_2_SLEW {slow} \
CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_30_PULLUP {enabled} \
CONFIG.PCW_MIO_30_SLEW {slow} \
CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_31_PULLUP {enabled} \
CONFIG.PCW_MIO_31_SLEW {slow} \
CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_32_PULLUP {enabled} \
CONFIG.PCW_MIO_32_SLEW {slow} \
CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_33_PULLUP {enabled} \
CONFIG.PCW_MIO_33_SLEW {slow} \
CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_34_PULLUP {enabled} \
CONFIG.PCW_MIO_34_SLEW {slow} \
CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_35_PULLUP {enabled} \
CONFIG.PCW_MIO_35_SLEW {slow} \
CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_36_PULLUP {enabled} \
CONFIG.PCW_MIO_36_SLEW {slow} \
CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_37_PULLUP {enabled} \
CONFIG.PCW_MIO_37_SLEW {slow} \
CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_38_PULLUP {enabled} \
CONFIG.PCW_MIO_38_SLEW {slow} \
CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_39_PULLUP {enabled} \
CONFIG.PCW_MIO_39_SLEW {slow} \
CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_3_SLEW {slow} \
CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_40_PULLUP {enabled} \
CONFIG.PCW_MIO_40_SLEW {slow} \
CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_41_PULLUP {enabled} \
CONFIG.PCW_MIO_41_SLEW {slow} \
CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_42_PULLUP {enabled} \
CONFIG.PCW_MIO_42_SLEW {slow} \
CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_43_PULLUP {enabled} \
CONFIG.PCW_MIO_43_SLEW {slow} \
CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_44_PULLUP {enabled} \
CONFIG.PCW_MIO_44_SLEW {slow} \
CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_45_PULLUP {enabled} \
CONFIG.PCW_MIO_45_SLEW {slow} \
CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_46_PULLUP {enabled} \
CONFIG.PCW_MIO_46_SLEW {slow} \
CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_47_PULLUP {enabled} \
CONFIG.PCW_MIO_47_SLEW {slow} \
CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_48_PULLUP {enabled} \
CONFIG.PCW_MIO_48_SLEW {slow} \
CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_49_PULLUP {enabled} \
CONFIG.PCW_MIO_49_SLEW {slow} \
CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_4_SLEW {slow} \
CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_50_PULLUP {enabled} \
CONFIG.PCW_MIO_50_SLEW {slow} \
CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_51_PULLUP {enabled} \
CONFIG.PCW_MIO_51_SLEW {slow} \
CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_52_PULLUP {enabled} \
CONFIG.PCW_MIO_52_SLEW {slow} \
CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_53_PULLUP {enabled} \
CONFIG.PCW_MIO_53_SLEW {slow} \
CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_5_SLEW {slow} \
CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_6_SLEW {slow} \
CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_7_SLEW {slow} \
CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_8_SLEW {slow} \
CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
CONFIG.PCW_MIO_9_PULLUP {enabled} \
CONFIG.PCW_MIO_9_SLEW {slow} \
CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#GPIO#Quad SPI Flash#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#USB Reset#SD 0#UART 1#UART 1#GPIO#GPIO#Enet 0#Enet 0} \
CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]#qspi0_sclk#gpio[7]#qspi_fbclk#gpio[9]#gpio[10]#gpio[11]#gpio[12]#gpio[13]#gpio[14]#gpio[15]#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#reset#cd#tx#rx#gpio[50]#gpio[51]#mdc#mdio} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.242} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.210} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.209} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.243} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.110} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {-0.053} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {-0.034} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.095} \
CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {1} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} \
CONFIG.PCW_QSPI_GRP_FBCLK_IO {MIO 8} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
CONFIG.PCW_SD0_GRP_CD_IO {MIO 47} \
CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
CONFIG.PCW_SD0_GRP_WP_IO {EMIO} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {32} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49} \
CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {525.000000} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.176} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.159} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.162} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.187} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {20.6} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {165} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {20.6} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {165} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {20.6} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {165} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {20.6} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {165} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {27.85} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {180} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {22.87} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {180} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {22.9} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {180} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {29.9} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {180} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {-0.073} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {-0.034} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {-0.03} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {-0.082} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {27} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {180} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {22.8} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {180} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {24} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {180} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {30.45} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {180} \
CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {525.000000} \
CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K128M16 JT-125} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_USB0_RESET_ENABLE {1} \
CONFIG.PCW_USB0_RESET_IO {MIO 46} \
CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
CONFIG.PCW_USE_DEFAULT_ACP_USER_VAL {1} \
CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
CONFIG.PCW_USE_S_AXI_ACP {1} \
CONFIG.PCW_USE_S_AXI_HP2 {1} \
 ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {4} \
 ] $processing_system7_0_axi_periph

  # Create instance: rst_processing_system7_0_100M, and set properties
  set rst_processing_system7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_100M ]

  # Create instance: xillybus_ip_0, and set properties
  set xillybus_ip_0 [ create_bd_cell -type ip -vlnv xillybus:xillybus:xillybus_ip:1.0 xillybus_ip_0 ]

  # Create instance: xillybus_lite_0, and set properties
  set xillybus_lite_0 [ create_bd_cell -type ip -vlnv xillybus:xillybus:xillybus_lite:1.0 xillybus_lite_0 ]

  # Create instance: xillyvga_0, and set properties
  set xillyvga_0 [ create_bd_cell -type ip -vlnv xillybus:xillybus:xillyvga:1.0 xillyvga_0 ]

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {16} \
 ] $xlconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_GPIO_0 [get_bd_intf_ports GPIO_0] [get_bd_intf_pins processing_system7_0/GPIO_0]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_USBIND_0 [get_bd_intf_ports USBIND_0] [get_bd_intf_pins processing_system7_0/USBIND_0]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI] [get_bd_intf_pins xillybus_ip_0/S_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M01_AXI [get_bd_intf_pins processing_system7_0_axi_periph/M01_AXI] [get_bd_intf_pins xillyvga_0/S_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M02_AXI [get_bd_intf_pins processing_system7_0_axi_periph/M02_AXI] [get_bd_intf_pins xillybus_lite_0/S_AXI]
  connect_bd_intf_net -intf_net xillybus_M_AXI_1 [get_bd_intf_ports xillybus_M_AXI] [get_bd_intf_pins xillybus_ip_0/xillybus_M_AXI]
  connect_bd_intf_net -intf_net xillybus_ip_0_m_axi [get_bd_intf_pins processing_system7_0/S_AXI_ACP] [get_bd_intf_pins xillybus_ip_0/m_axi]
  connect_bd_intf_net -intf_net xillybus_ip_0_xillybus_S_AXI [get_bd_intf_ports xillybus_S_AXI] [get_bd_intf_pins xillybus_ip_0/xillybus_S_AXI]
  connect_bd_intf_net -intf_net xillyvga_0_m_axi [get_bd_intf_pins processing_system7_0/S_AXI_HP2] [get_bd_intf_pins xillyvga_0/m_axi]

  # Create port connections
  connect_bd_net -net clk_in_1 [get_bd_ports clk_in] [get_bd_pins xillyvga_0/clk_in]
  connect_bd_net -net processing_system7_0_FCLK_CLK1 [get_bd_pins processing_system7_0/FCLK_CLK1] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_ACP_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP2_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/M01_ACLK] [get_bd_pins processing_system7_0_axi_periph/M02_ACLK] [get_bd_pins processing_system7_0_axi_periph/M03_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] [get_bd_pins rst_processing_system7_0_100M/slowest_sync_clk] [get_bd_pins xillybus_ip_0/S_AXI_ACLK] [get_bd_pins xillybus_ip_0/m_axi_aclk] [get_bd_pins xillybus_lite_0/S_AXI_ACLK] [get_bd_pins xillyvga_0/S_AXI_ACLK] [get_bd_pins xillyvga_0/m_axi_aclk]
  connect_bd_net -net processing_system7_0_FCLK_RESET1_N [get_bd_pins processing_system7_0/FCLK_RESET1_N] [get_bd_pins rst_processing_system7_0_100M/ext_reset_in]
  connect_bd_net -net rst_processing_system7_0_100M_interconnect_aresetn [get_bd_pins processing_system7_0_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_0_100M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_100M_peripheral_aresetn [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M01_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M02_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M03_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn] [get_bd_pins xillybus_ip_0/S_AXI_ARESETN] [get_bd_pins xillybus_ip_0/m_axi_aresetn] [get_bd_pins xillybus_lite_0/S_AXI_ARESETN] [get_bd_pins xillyvga_0/S_AXI_ARESETN] [get_bd_pins xillyvga_0/m_axi_aresetn]
  connect_bd_net -net user_irq_1 [get_bd_ports user_irq] [get_bd_pins xillybus_lite_0/user_irq]
  connect_bd_net -net user_rd_data_1 [get_bd_ports user_rd_data] [get_bd_pins xillybus_lite_0/user_rd_data]
  connect_bd_net -net xillybus_host_interrupt_1 [get_bd_ports xillybus_host_interrupt] [get_bd_pins xillybus_ip_0/xillybus_host_interrupt]
  connect_bd_net -net xillybus_ip_0_Interrupt [get_bd_pins xillybus_ip_0/Interrupt] [get_bd_pins xlconcat_0/In15]
  connect_bd_net -net xillybus_ip_0_xillybus_bus_clk [get_bd_ports xillybus_bus_clk] [get_bd_pins xillybus_ip_0/xillybus_bus_clk]
  connect_bd_net -net xillybus_ip_0_xillybus_bus_rst_n [get_bd_ports xillybus_bus_rst_n] [get_bd_pins xillybus_ip_0/xillybus_bus_rst_n]
  connect_bd_net -net xillybus_lite_0_host_interrupt [get_bd_pins xillybus_lite_0/host_interrupt] [get_bd_pins xlconcat_0/In14]
  connect_bd_net -net xillybus_lite_0_user_addr [get_bd_ports user_addr] [get_bd_pins xillybus_lite_0/user_addr]
  connect_bd_net -net xillybus_lite_0_user_clk [get_bd_ports user_clk] [get_bd_pins xillybus_lite_0/user_clk]
  connect_bd_net -net xillybus_lite_0_user_rden [get_bd_ports user_rden] [get_bd_pins xillybus_lite_0/user_rden]
  connect_bd_net -net xillybus_lite_0_user_wr_data [get_bd_ports user_wr_data] [get_bd_pins xillybus_lite_0/user_wr_data]
  connect_bd_net -net xillybus_lite_0_user_wren [get_bd_ports user_wren] [get_bd_pins xillybus_lite_0/user_wren]
  connect_bd_net -net xillybus_lite_0_user_wstrb [get_bd_ports user_wstrb] [get_bd_pins xillybus_lite_0/user_wstrb]
  connect_bd_net -net xillyvga_0_dvi_clk_n [get_bd_ports dvi_clk_n] [get_bd_pins xillyvga_0/dvi_clk_n]
  connect_bd_net -net xillyvga_0_dvi_clk_p [get_bd_ports dvi_clk_p] [get_bd_pins xillyvga_0/dvi_clk_p]
  connect_bd_net -net xillyvga_0_dvi_d_n [get_bd_ports dvi_d_n] [get_bd_pins xillyvga_0/dvi_d_n]
  connect_bd_net -net xillyvga_0_dvi_d_p [get_bd_ports dvi_d_p] [get_bd_pins xillyvga_0/dvi_d_p]
  connect_bd_net -net xillyvga_0_vga_blue [get_bd_ports vga_blue] [get_bd_pins xillyvga_0/vga_blue]
  connect_bd_net -net xillyvga_0_vga_clk [get_bd_ports vga_clk] [get_bd_pins xillyvga_0/vga_clk]
  connect_bd_net -net xillyvga_0_vga_de [get_bd_ports vga_de] [get_bd_pins xillyvga_0/vga_de]
  connect_bd_net -net xillyvga_0_vga_green [get_bd_ports vga_green] [get_bd_pins xillyvga_0/vga_green]
  connect_bd_net -net xillyvga_0_vga_hsync [get_bd_ports vga_hsync] [get_bd_pins xillyvga_0/vga_hsync]
  connect_bd_net -net xillyvga_0_vga_red [get_bd_ports vga_red] [get_bd_pins xillyvga_0/vga_red]
  connect_bd_net -net xillyvga_0_vga_vsync [get_bd_ports vga_vsync] [get_bd_pins xillyvga_0/vga_vsync]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins processing_system7_0/IRQ_F2P] [get_bd_pins xlconcat_0/dout]

  # Create address segments
  create_bd_addr_seg -range 0x1000 -offset 0x50000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs xillybus_ip_0/S_AXI/reg0] SEG_xillybus_ip_0_reg0
  create_bd_addr_seg -range 0x1000 -offset 0x50002000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs xillybus_lite_0/S_AXI/reg0] SEG_xillybus_lite_0_reg0
  create_bd_addr_seg -range 0x1000 -offset 0x50001000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs xillyvga_0/S_AXI/reg0] SEG_xillyvga_0_reg0
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces xillybus_ip_0/m_axi] [get_bd_addr_segs processing_system7_0/S_AXI_ACP/ACP_DDR_LOWOCM] SEG_processing_system7_0_ACP_DDR_LOWOCM
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces xillyvga_0/m_axi] [get_bd_addr_segs processing_system7_0/S_AXI_HP2/HP2_DDR_LOWOCM] SEG_processing_system7_0_HP2_DDR_LOWOCM
  create_bd_addr_seg -range 0x100000000 -offset 0x0 [get_bd_addr_spaces xillybus_M_AXI] [get_bd_addr_segs xillybus_ip_0/xillybus_M_AXI/reg0] SEG_xillybus_ip_0_reg0

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.8
#  -string -flagsOSRD
preplace port vga_hsync -pg 1 -y 350 -defaultsOSRD
preplace port vga_de -pg 1 -y 310 -defaultsOSRD
preplace port DDR -pg 1 -y 130 -defaultsOSRD
preplace port dvi_clk_p -pg 1 -y 40 -defaultsOSRD
preplace port xillybus_S_AXI -pg 1 -y 990 -defaultsOSRD
preplace port clk_in -pg 1 -y 410 -defaultsOSRD
preplace port GPIO_0 -pg 1 -y 110 -defaultsOSRD
preplace port user_clk -pg 1 -y 460 -defaultsOSRD
preplace port user_rden -pg 1 -y 500 -defaultsOSRD
preplace port vga_clk -pg 1 -y 290 -defaultsOSRD
preplace port xillybus_bus_clk -pg 1 -y 1030 -defaultsOSRD
preplace port xillybus_host_interrupt -pg 1 -y 1070 -defaultsOSRD
preplace port FIXED_IO -pg 1 -y 150 -defaultsOSRD
preplace port user_wren -pg 1 -y 480 -defaultsOSRD
preplace port xillybus_bus_rst_n -pg 1 -y 1050 -defaultsOSRD
preplace port user_irq -pg 1 -y 880 -defaultsOSRD
preplace port xillybus_M_AXI -pg 1 -y 970 -defaultsOSRD
preplace port vga_vsync -pg 1 -y 390 -defaultsOSRD
preplace port dvi_clk_n -pg 1 -y 20 -defaultsOSRD
preplace port USBIND_0 -pg 1 -y 190 -defaultsOSRD
preplace portBus vga_green -pg 1 -y 330 -defaultsOSRD
preplace portBus vga_red -pg 1 -y 370 -defaultsOSRD
preplace portBus user_wstrb -pg 1 -y 520 -defaultsOSRD
preplace portBus user_wr_data -pg 1 -y 540 -defaultsOSRD
preplace portBus vga_blue -pg 1 -y 270 -defaultsOSRD
preplace portBus dvi_d_n -pg 1 -y 60 -defaultsOSRD
preplace portBus user_addr -pg 1 -y 560 -defaultsOSRD
preplace portBus dvi_d_p -pg 1 -y 80 -defaultsOSRD
preplace portBus user_rd_data -pg 1 -y 610 -defaultsOSRD
preplace inst xillybus_lite_0 -pg 1 -lvl 4 -y 500 -defaultsOSRD
preplace inst rst_processing_system7_0_100M -pg 1 -lvl 1 -y 520 -defaultsOSRD
preplace inst xlconcat_0 -pg 1 -lvl 3 -y 680 -defaultsOSRD
preplace inst xillyvga_0 -pg 1 -lvl 3 -y 270 -defaultsOSRD
preplace inst processing_system7_0_axi_periph -pg 1 -lvl 2 -y 250 -defaultsOSRD
preplace inst processing_system7_0 -pg 1 -lvl 4 -y 180 -defaultsOSRD
preplace inst xillybus_ip_0 -pg 1 -lvl 3 -y 1010 -defaultsOSRD
preplace netloc processing_system7_0_DDR 1 4 1 NJ
preplace netloc xillyvga_0_vga_red 1 3 2 NJ 370 NJ
preplace netloc xillyvga_0_vga_green 1 3 2 NJ 330 NJ
preplace netloc processing_system7_0_axi_periph_M00_AXI 1 2 1 730
preplace netloc xillybus_lite_0_user_wstrb 1 4 1 NJ
preplace netloc xillyvga_0_vga_hsync 1 3 2 NJ 350 NJ
preplace netloc xillyvga_0_vga_blue 1 3 2 NJ 310 NJ
preplace netloc xillyvga_0_vga_vsync 1 3 2 NJ 360 NJ
preplace netloc processing_system7_0_M_AXI_GP0 1 1 4 390 10 NJ 10 NJ 10 1640
preplace netloc xillybus_lite_0_user_clk 1 4 1 NJ
preplace netloc xillybus_lite_0_user_addr 1 4 1 NJ
preplace netloc xillyvga_0_dvi_d_n 1 3 2 NJ 30 NJ
preplace netloc xillyvga_0_dvi_d_p 1 3 2 NJ 60 NJ
preplace netloc xillyvga_0_vga_de 1 3 2 NJ 320 NJ
preplace netloc processing_system7_0_axi_periph_M02_AXI 1 2 2 710 110 NJ
preplace netloc clk_in_1 1 0 3 NJ 400 NJ 430 NJ
preplace netloc xillyvga_0_vga_clk 1 3 2 NJ 300 NJ
preplace netloc xillyvga_0_dvi_clk_n 1 3 2 NJ 20 NJ
preplace netloc rst_processing_system7_0_100M_peripheral_aresetn 1 1 3 380 70 720 480 NJ
preplace netloc processing_system7_0_FCLK_RESET1_N 1 0 5 20 380 NJ 440 NJ 440 NJ 340 1630
preplace netloc processing_system7_0_USBIND_0 1 4 1 NJ
preplace netloc user_rd_data_1 1 0 4 NJ 420 NJ 470 NJ 470 NJ
preplace netloc xillybus_ip_0_Interrupt 1 2 2 770 890 1100
preplace netloc xlconcat_0_dout 1 3 1 1170
preplace netloc xillybus_ip_0_xillybus_bus_rst_n 1 3 2 NJ 1050 NJ
preplace netloc processing_system7_0_FIXED_IO 1 4 1 NJ
preplace netloc xillybus_ip_0_xillybus_S_AXI 1 3 2 NJ 990 NJ
preplace netloc user_irq_1 1 0 4 NJ 430 NJ 450 NJ 450 NJ
preplace netloc xillyvga_0_dvi_clk_p 1 3 2 NJ 40 NJ
preplace netloc xillybus_M_AXI_1 1 0 3 NJ 970 NJ 970 NJ
preplace netloc xillyvga_0_m_axi 1 3 1 N
preplace netloc processing_system7_0_GPIO_0 1 4 1 NJ
preplace netloc xillybus_ip_0_m_axi 1 3 1 1160
preplace netloc rst_processing_system7_0_100M_interconnect_aresetn 1 1 1 390
preplace netloc xillybus_lite_0_user_wren 1 4 1 NJ
preplace netloc xillybus_lite_0_user_wr_data 1 4 1 NJ
preplace netloc xillybus_lite_0_user_rden 1 4 1 NJ
preplace netloc xillybus_lite_0_host_interrupt 1 2 3 760 880 NJ 880 1630
preplace netloc processing_system7_0_FCLK_CLK1 1 0 5 10 350 360 50 750 50 1140 50 1630
preplace netloc processing_system7_0_axi_periph_M01_AXI 1 2 1 740
preplace netloc xillybus_ip_0_xillybus_bus_clk 1 3 2 NJ 1030 NJ
preplace netloc xillybus_host_interrupt_1 1 0 3 NJ 1070 NJ 1070 NJ
levelinfo -pg 1 -30 190 560 930 1420 1680 -top 0 -bot 1120
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


