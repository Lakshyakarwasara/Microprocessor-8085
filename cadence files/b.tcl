# 1. Here we are setting all the necessary files (All the inputs)
# 2. Sanity Check before floorplaning
# 3. Floor Planing
# 4. Power Planing
# 5. Global Routing
# 6. Sanity Check for Scan Chain of DFT
# 7. Generating Reports for Before_Physical_Design
# 8. Placement
# 9. Clock Tree Synthesis
# 10. CTS optimization
# 11. Global and Detailed Routing
# 12. Generating GDS

#creating directories for report
file mkdir placement_reports/report
file mkdir placement_reports/timing
file mkdir placement_reports/area
file mkdir placement_reports/gates
file mkdir placement_reports/power
file mkdir placement_reports/GDS
file mkdir placement_reports/netlist
file mkdir placement_reports/incremental_placement_report
file mkdir cts_reports/timing
file mkdir cts_reports/area
file mkdir optimised_cts_reports/timing
file mkdir optimised_cts_reports/area
file mkdir ctsrepairreports/area
file mkdir ctsrepairreports/timing
file mkdir post_route_reports/timing
file mkdir post_route_reports/area


set report_dir placement_reports

set init_gnd_net GND
#set init_io_file PinLocation.io
set init_lef_file gsclib090_translated_ref.lef
set init_mmmc_file Default.view
set init_pwr_net VDD
set init_top_cell top8_module
set init_verilog HDL_tight_Netlist.v

init_design

setDesignMode -process 90 -flowEffort standard

#/* Sanity check before Floorplanning*/	
checkDesign -physicalLibrary; #Sanity check of physical library -lef file
checkDesign -timingLibrary; #Sanity check of timing library 
checkDesign -netlist; #Sanity check of dft netlist
check_timing; #Sanity check of timing reports of min and max path

#/Floorplanning/
getIoFlowFlag
setIoFlowFlag 0
#floorplanning die siting according to Innovus LRM
#floorPlan -site gsclib090site -r 1 0.8 4.06 4.06 4.06 4.06
#floorPlan -site gsclib090site -r 1 0.8 4.06 4.06 4.06 4.06
floorPlan -site gsclib090site -r 1 0.8 4.06 4.06 4.06 4.06



#/Power Planning to be done by voltus tool/
# Adding Rings
addRing -skip_via_on_wire_shape Noshape -skip_via_on_pin Standardcell -center 1 -stacked_via_top_layer Metal9 -type core_rings -jog_distance 0.435 -threshold 0.435 -nets {GND VDD} -follow core -stacked_via_bottom_layer Metal1 -layer {bottom Metal8 top Metal8 right Metal9 left Metal9} -width 1.25 -spacing 0.4

# Adding Stripes
addStripe -skip_via_on_wire_shape Noshape -block_ring_top_layer_limit Metal9 -max_same_layer_jog_length 0.88 -padcore_ring_bottom_layer_limit Metal7 -number_of_sets 10 -skip_via_on_pin Standardcell -stacked_via_top_layer Metal9 -padcore_ring_top_layer_limit Metal9 -spacing 0.4 -merge_stripes_value 0.435 -layer Metal8 -block_ring_bottom_layer_limit Metal7 -width 0.44 -nets {VDD GND} -stacked_via_bottom_layer Metal1

#set_ccopt_mode -cts_buffer_cells {CLKBUFX3 CLKBUFX2  CLKBUFX8 CLKBUFX12 CLKBUFX16 CLKBUFX20} -cts_opt_priority all
#create_ccopt_clock_tree_spec -file ccopt_new.spec -keep_all_sdc_clocks -views {view1}


