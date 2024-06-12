create_clock -name CLK -period 4.0 [get_ports clk]
set_clock_transition  0.4 [get_clocks CLK]
#set_clock_transition  0.4 [get_ports clk ]
set_input_delay -clock CLK 0.4 [get_ports rst]
set_input_delay -clock CLK 0.4 [get_ports alu_in1]
set_input_delay -clock CLK 0.4 [get_ports ff_pc_rst]
set_output_delay -clock CLK 0.2 [get_ports ff_zero]
set_output_delay -clock CLK 0.2 [get_ports ff_carry]
set_output_delay -clock CLK 0.2 [get_ports ff_negative]
set_output_delay -clock CLK 0.2 [get_ports alu_result]
set_load 1.0 [get_ports ff_zero]
set_load 1.0 [get_ports ff_carry]
set_load 1.0 [get_ports ff_negative]
set_load 1.0 [get_ports alu_result]

# Specify that the memory should be implemented using flip-flops
set_attribute -library SEQUENTIAL -design {mem[*]} ramstyle registers

# Optimize memory initialization process
set_attribute -name INIT -value "11'b10110010010" [get_cells -hierarchical -filter {name =~ "mem[*]"}]

# Set optimize_constant_1_flops to false
set_attribute -name optimize_constant_1_seq -value false [current_design]
# Set optimize_constant_1_flops to false
set_attribute -name optimize_constant_0_seq -value false [current_design]

# Set 'preserve' instance attribute to 'true'
set_attribute -instance * -name preserve true


