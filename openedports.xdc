# Clock signal
#set_property PACKAGE_PIN W5 [get_ports clk]							
#	set_property IOSTANDARD LVCMOS33 [get_ports clk]
#	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]


## Clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports  clk ]; #IO_L12P_T1_MRCC_35 Sch=clk100mhz
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk];
	
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { LED[0] }]; #IO_L18P_T2_A24_15 Sch=led[0]	
###VGA Connector
#set_property PACKAGE_PIN G19 [get_ports {RED_O[0]}]                
#set_property IOSTANDARD LVCMOS33 [get_ports {RED_O[0]}]
#set_property PACKAGE_PIN H19 [get_ports {RED_O[1]}]                
#set_property IOSTANDARD LVCMOS33 [get_ports {RED_O[1]}]
#set_property PACKAGE_PIN J19 [get_ports {RED_O[2]}]                
#set_property IOSTANDARD LVCMOS33 [get_ports {RED_O[2]}]
#set_property PACKAGE_PIN N19 [get_ports {RED_O[3]}]                
#set_property IOSTANDARD LVCMOS33 [get_ports {RED_O[3]}]
#set_property PACKAGE_PIN N18 [get_ports {BLUE_O[0]}]                
#set_property IOSTANDARD LVCMOS33 [get_ports {BLUE_O[0]}]
#set_property PACKAGE_PIN L18 [get_ports {BLUE_O[1]}]                
#set_property IOSTANDARD LVCMOS33 [get_ports {BLUE_O[1]}]
#set_property PACKAGE_PIN K18 [get_ports {BLUE_O[2]}]                
#set_property IOSTANDARD LVCMOS33 [get_ports {BLUE_O[2]}]
#set_property PACKAGE_PIN J18 [get_ports {BLUE_O[3]}]                
#set_property IOSTANDARD LVCMOS33 [get_ports {BLUE_O[3]}]
#set_property PACKAGE_PIN J17 [get_ports {GREEN_O[0]}]                
#set_property IOSTANDARD LVCMOS33 [get_ports {GREEN_O[0]}]
#set_property PACKAGE_PIN H17 [get_ports {GREEN_O[1]}]                
#set_property IOSTANDARD LVCMOS33 [get_ports {GREEN_O[1]}]
#set_property PACKAGE_PIN G17 [get_ports {GREEN_O[2]}]                
#set_property IOSTANDARD LVCMOS33 [get_ports {GREEN_O[2]}]
#set_property PACKAGE_PIN D17 [get_ports {GREEN_O[3]}]                
#set_property IOSTANDARD LVCMOS33 [get_ports {GREEN_O[3]}]
#set_property PACKAGE_PIN P19 [get_ports HSYNC_O]                        
#set_property IOSTANDARD LVCMOS33 [get_ports HSYNC_O]
#set_property PACKAGE_PIN R19 [get_ports VSYNC_O]                        
#set_property IOSTANDARD LVCMOS33 [get_ports VSYNC_O] 




##VGA Connector
set_property -dict { PACKAGE_PIN A3    IOSTANDARD LVCMOS33 } [get_ports { RED_O[0] }]; #IO_L8N_T1_AD14N_35 Sch=vga_r[0]
set_property -dict { PACKAGE_PIN B4    IOSTANDARD LVCMOS33 } [get_ports { RED_O[1] }]; #IO_L7N_T1_AD6N_35 Sch=vga_r[1]
set_property -dict { PACKAGE_PIN C5    IOSTANDARD LVCMOS33 } [get_ports { RED_O[2] }]; #IO_L1N_T0_AD4N_35 Sch=vga_r[2]
set_property -dict { PACKAGE_PIN A4    IOSTANDARD LVCMOS33 } [get_ports { RED_O[3] }]; #IO_L8P_T1_AD14P_35 Sch=vga_r[3]
set_property -dict { PACKAGE_PIN C6    IOSTANDARD LVCMOS33 } [get_ports { GREEN_O[0] }]; #IO_L1P_T0_AD4P_35 Sch=vga_g[0]
set_property -dict { PACKAGE_PIN A5    IOSTANDARD LVCMOS33 } [get_ports { GREEN_O[1] }]; #IO_L3N_T0_DQS_AD5N_35 Sch=vga_g[1]
set_property -dict { PACKAGE_PIN B6    IOSTANDARD LVCMOS33 } [get_ports { GREEN_O[2] }]; #IO_L2N_T0_AD12N_35 Sch=vga_g[2]
set_property -dict { PACKAGE_PIN A6    IOSTANDARD LVCMOS33 } [get_ports { GREEN_O[3] }]; #IO_L3P_T0_DQS_AD5P_35 Sch=vga_g[3]
set_property -dict { PACKAGE_PIN B7    IOSTANDARD LVCMOS33 } [get_ports { BLUE_O[0] }]; #IO_L2P_T0_AD12P_35 Sch=vga_b[0]
set_property -dict { PACKAGE_PIN C7    IOSTANDARD LVCMOS33 } [get_ports { BLUE_O[1] }]; #IO_L4N_T0_35 Sch=vga_b[1]
set_property -dict { PACKAGE_PIN D7    IOSTANDARD LVCMOS33 } [get_ports { BLUE_O[2] }]; #IO_L6N_T0_VREF_35 Sch=vga_b[2]
set_property -dict { PACKAGE_PIN D8    IOSTANDARD LVCMOS33 } [get_ports { BLUE_O[3] }]; #IO_L4P_T0_35 Sch=vga_b[3]
set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { HSYNC_O }]; #IO_L4P_T0_15 Sch=vga_hs
set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS33 } [get_ports { VSYNC_O }]; #IO_L3N_T0_DQS_AD1N_15 Sch=vga_vs



##Pmod Headers
##Pmod Header JA
set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports { JA[1] }]; #IO_L20N_T3_A19_15 Sch=ja[1]
#set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { JA[2] }]; #IO_L21N_T3_DQS_A18_15 Sch=ja[2]
#set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { JA[3] }]; #IO_L21P_T3_DQS_15 Sch=ja[3]
#set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { JA[4] }]; #IO_L18N_T2_A23_15 Sch=ja[4]
#set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { JA[7] }]; #IO_L16N_T2_A27_15 Sch=ja[7]
#set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { JA[8] }]; #IO_L16P_T2_A28_15 Sch=ja[8]
#set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { JA[9] }]; #IO_L22N_T3_A16_15 Sch=ja[9]
#set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { JA[10] }]; #IO_L22P_T3_A17_15 Sch=ja[10]

##Pmod Header JB
#set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { JB[1] }]; #IO_L1P_T0_AD0P_15 Sch=jb[1]
#set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports { JB[2] }]; #IO_L14N_T2_SRCC_15 Sch=jb[2]
#set_property -dict { PACKAGE_PIN G16   IOSTANDARD LVCMOS33 } [get_ports { JB[3] }]; #IO_L13N_T2_MRCC_15 Sch=jb[3]
#set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS33 } [get_ports { JB[4] }]; #IO_L15P_T2_DQS_15 Sch=jb[4]
#set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { JB[7] }]; #IO_L11N_T1_SRCC_15 Sch=jb[7]
#set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { JB[8] }]; #IO_L5P_T0_AD9P_15 Sch=jb[8]
#set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { JB[9] }]; #IO_0_15 Sch=jb[9]
#set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { JB[10] }]; #IO_L13P_T2_MRCC_15 Sch=jb[10]