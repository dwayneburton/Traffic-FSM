## Switches
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports {i_maintenance}]

## Buttons
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {i_ped_buttons[0]}]
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports {i_ped_buttons[1]}]
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports {i_ped_buttons[2]}]
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports {i_ped_buttons[3]}]

## LEDs
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {o_light_ped}]

## RGBLEDs
set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports {o_light_ns[0]}] 
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {o_light_ns[1]}] 
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {o_light_ns[2]}] 
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {o_light_ew[0]}]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports {o_light_ew[1]}] 
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {o_light_ew[2]}]

# Clock 125 MHz
create_clock -period 8.0 -name clk clk
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports {clk}]