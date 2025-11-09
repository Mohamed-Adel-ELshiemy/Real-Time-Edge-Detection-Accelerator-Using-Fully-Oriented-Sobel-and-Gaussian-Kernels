## This file is a general .xdc for the Zybo Z7 Rev. B
## It is compatible with the Zybo Z7-20 and Zybo Z7-10
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project
#####################################################################################################################################
#####################################################################################################################################
##Clock signal                                                                                                                    
set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports i_board_clk]                                                   
#####################################################################################################################################
#####################################################################################################################################


 set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_cam_pclk_IBUF] 
#####################################################################################################################################
#####################################################################################################################################
##Switches                                                                                                                         
set_property -dict { PACKAGE_PIN F22   IOSTANDARD LVCMOS33 } [get_ports { i_gaussian }]; #IO_L19N_T3_VREF_35 Sch=sw[0]            
set_property -dict { PACKAGE_PIN G22   IOSTANDARD LVCMOS33 } [get_ports { i_sobel }]; #IO_L24P_T3_34 Sch=sw[1]                    
set_property -dict { PACKAGE_PIN H22   IOSTANDARD LVCMOS33 } [get_ports { freeze }]; #IO_L4N_T0_34 Sch=sw[2]                    
#####################################################################################################################################
#####################################################################################################################################



#####################################################################################################################################
#####################################################################################################################################
##Buttons                                                                                                                          
set_property -dict {PACKAGE_PIN  P16 IOSTANDARD LVCMOS33} [get_ports i_rst]                                                        
set_property -dict {PACKAGE_PIN  R16 IOSTANDARD LVCMOS33} [get_ports i_mode]                                                     
set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { dec_sobel }]; #IO_L10P_T1_AD11P_35 Sch=btn[2]         
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { inc_sobel }]; #IO_L7P_T1_34 Sch=btn[3]                
#####################################################################################################################################
#####################################################################################################################################



#####################################################################################################################################
#####################################################################################################################################
##LEDs                                                                                                                             
set_property -dict {PACKAGE_PIN  T22 IOSTANDARD LVCMOS33} [get_ports {gaussian_on}]                                               
set_property -dict {PACKAGE_PIN  T21 IOSTANDARD LVCMOS33} [get_ports {sobel_on}]                                                  
set_property -dict { PACKAGE_PIN U22   IOSTANDARD LVCMOS33 } [get_ports { led_threshold}]; #IO_0_35 Sch=led[2]                     
set_property -dict { PACKAGE_PIN U21   IOSTANDARD LVCMOS33 } [get_ports { mode_on }]; #IO_L18N_T2_13 Sch=led5_r                   
#####################################################################################################################################
#####################################################################################################################################


#####################################################################################################################################
#####################################################################################################################################
##VGA                                                                                                                              
set_property   -dict    { PACKAGE_PIN Y21  IOSTANDARD LVCMOS33}   [get_ports {o_vga_b[0]}];  # "VGA-B1"                            
set_property   -dict    { PACKAGE_PIN Y20  IOSTANDARD LVCMOS33}   [get_ports {o_vga_b[1]}];  # "VGA-B2"                            
set_property   -dict    { PACKAGE_PIN AB20 IOSTANDARD LVCMOS33}   [get_ports {o_vga_b[2]}];  # "VGA-B3"                            
set_property   -dict    { PACKAGE_PIN AB19 IOSTANDARD LVCMOS33}   [get_ports {o_vga_b[3]}];  # "VGA-B4"                            
set_property   -dict    { PACKAGE_PIN AB22 IOSTANDARD LVCMOS33}   [get_ports {o_vga_g[0]}];  # "VGA-G1"                            
set_property   -dict    { PACKAGE_PIN AA22 IOSTANDARD LVCMOS33}   [get_ports {o_vga_g[1]}];  # "VGA-G2"                            
set_property   -dict    { PACKAGE_PIN AB21 IOSTANDARD LVCMOS33}   [get_ports {o_vga_g[2]}];  # "VGA-G3"                            
set_property   -dict    { PACKAGE_PIN AA21 IOSTANDARD LVCMOS33}   [get_ports {o_vga_g[3]}];  # "VGA-G4"                            
set_property   -dict    { PACKAGE_PIN AA19 IOSTANDARD LVCMOS33}   [get_ports {o_vga_hs}];    # "VGA-HS"                            
set_property   -dict    { PACKAGE_PIN V20  IOSTANDARD LVCMOS33}   [get_ports {o_vga_r[0]}];  # "VGA-R1"                            
set_property   -dict    { PACKAGE_PIN U20  IOSTANDARD LVCMOS33}   [get_ports {o_vga_r[1]}];  # "VGA-R2"                            
set_property   -dict    { PACKAGE_PIN V19  IOSTANDARD LVCMOS33}   [get_ports {o_vga_r[2]}];  # "VGA-R3"                            
set_property   -dict    { PACKAGE_PIN V18  IOSTANDARD LVCMOS33}   [get_ports {o_vga_r[3]}];  # "VGA-R4"                            
set_property   -dict    { PACKAGE_PIN Y19  IOSTANDARD LVCMOS33}   [get_ports {o_vga_vs}];    # "VGA-VS"                            
#####################################################################################################################################
#####################################################################################################################################


#####################################################################################################################################
#####################################################################################################################################
##Pmod Header JC -> OV7670 data in ## JA Pmod                                                                                      
set_property -dict {PACKAGE_PIN Y11  IOSTANDARD LVCMOS33} [get_ports {i_cam_data[0]}]                                              
set_property -dict {PACKAGE_PIN AA8  IOSTANDARD LVCMOS33} [get_ports {i_cam_data[1]}]                                              
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33} [get_ports {i_cam_data[2]}]                                              
set_property -dict {PACKAGE_PIN Y10  IOSTANDARD LVCMOS33} [get_ports {i_cam_data[3]}]                                              
set_property -dict {PACKAGE_PIN AA9  IOSTANDARD LVCMOS33} [get_ports {i_cam_data[4]}]                                              
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS33} [get_ports {i_cam_data[5]}]                                              
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33} [get_ports {i_cam_data[6]}]                                              
set_property -dict {PACKAGE_PIN AB9  IOSTANDARD LVCMOS33} [get_ports {i_cam_data[7]}]                                              
##Pmod Header JD -> OV7670 control   ## JB Pmod                                                                                    
set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVCMOS33} [get_ports o_cam_xclk]                                                    
set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVCMOS33} [get_ports o_cam_rstn]                                                    
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports i_cam_vsync]                                                   
set_property -dict {PACKAGE_PIN W8  IOSTANDARD LVCMOS33} [get_ports i_cam_href]                                                    
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports i_cam_pclk]                                                    
set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVCMOS33} [get_ports o_cam_pwdn]                                                    
set_property -dict {PACKAGE_PIN V9  IOSTANDARD LVCMOS33} [get_ports SCL]                                                           
set_property -dict {PACKAGE_PIN V8  IOSTANDARD LVCMOS33} [get_ports SDA]                                                           
#####################################################################################################################################
#####################################################################################################################################



#####################################################################################################################################
#####################################################################################################################################
create_clock -period 41.167 -name cam_pclk -waveform {0.000 20.584} -add [get_ports i_cam_pclk]                                     
set_false_path -from [get_clocks cam_pclk] -to [get_clocks -of_objects [get_pins dcm_i/inst/mmcm_adv_inst/CLKOUT0]]                
set_false_path -from [get_clocks cam_pclk] -to [get_clocks -of_objects [get_pins dcm_i/inst/mmcm_adv_inst/CLKOUT3]]                
set_max_delay -from [get_clocks cam_pclk] -to [get_clocks -of_objects [get_pins dcm_i/inst/mmcm_adv_inst/CLKOUT1]] 42.000          
set_max_delay -from [get_clocks cam_pclk] -to [get_clocks -of_objects [get_pins dcm_i/inst/mmcm_adv_inst/CLKOUT2]] 14.000          
set_false_path -from [get_clocks cam_pclk] -to [get_clocks -of_objects [get_pins dcm_i/inst/mmcm_adv_inst/CLKOUT1]]                
set_false_path -from [get_clocks cam_pclk] -to [get_clocks -of_objects [get_pins dcm_i/inst/mmcm_adv_inst/CLKOUT2]]                
set_max_delay -from [get_clocks -of_objects [get_pins dcm_i/inst/mmcm_adv_inst/CLKOUT2]] -to [get_clocks cam_pclk] 13.000          
set_max_delay -from [get_clocks -of_objects [get_pins dcm_i/inst/mmcm_adv_inst/CLKOUT3]] -to [get_clocks cam_pclk] 6.667           
#####################################################################################################################################
#####################################################################################################################################