-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
  Port ( 
    clk_100 : in STD_LOGIC;
    otg_oc : in STD_LOGIC;
    PS_GPIO : inout STD_LOGIC_VECTOR ( 47 downto 0 );
    ssd_a : out STD_LOGIC_VECTOR ( 6 downto 0 );
    ssd_c : out STD_LOGIC;
    GPIO_LED : out STD_LOGIC_VECTOR ( 3 downto 0 );
    vga4_blue : out STD_LOGIC_VECTOR ( 4 downto 0 );
    vga4_green : out STD_LOGIC_VECTOR ( 5 downto 0 );
    vga4_red : out STD_LOGIC_VECTOR ( 4 downto 0 );
    vga_hsync : out STD_LOGIC;
    vga_vsync : out STD_LOGIC;
    hdmi_clk_p : out STD_LOGIC;
    hdmi_clk_n : out STD_LOGIC;
    hdmi_d_p : out STD_LOGIC_VECTOR ( 2 downto 0 );
    hdmi_d_n : out STD_LOGIC_VECTOR ( 2 downto 0 );
    hdmi_out_en : out STD_LOGIC;
    audio_mclk : out STD_LOGIC;
    audio_dac : out STD_LOGIC;
    audio_adc : in STD_LOGIC;
    audio_bclk : in STD_LOGIC;
    audio_adc_lrclk : in STD_LOGIC;
    audio_dac_lrclk : in STD_LOGIC;
    audio_mute : out STD_LOGIC;
    smb_sclk : inout STD_LOGIC;
    smb_sdata : inout STD_LOGIC
  );

end top;

architecture stub of top is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
begin
end;
