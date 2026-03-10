# ---------------------------------------------------------
# Cleanup and Initialization
# ---------------------------------------------------------
quit -sim
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# ---------------------------------------------------------
# Compilation
# ---------------------------------------------------------
# Compile the Design Under Test (DUT)
# REPLACE 'system_top.sv' with the actual path/name of your RTL file
vlog -sv -work work system_top.sv

# Compile the Testbench
vlog -sv -work work system_top_tb.sv

# ---------------------------------------------------------
# Simulation Setup
# ---------------------------------------------------------
# -voptargs=+acc ensures full visibility of signals for debugging
vsim -voptargs=+acc work.system_top_tb

# ---------------------------------------------------------
# Waveform Configuration
# ---------------------------------------------------------
# 1. Clock and Reset
add wave -noupdate -divider "Control"
add wave -noupdate -color "white" /system_top_tb/clk
add wave -noupdate -color "cyan"  /system_top_tb/rst_n

# 2. Test Status Variables
add wave -noupdate -divider "Test Status"
add wave -noupdate -radix unsigned /system_top_tb/frame_id
add wave -noupdate -radix unsigned /system_top_tb/passed
add wave -noupdate -radix unsigned /system_top_tb/failed

# 3. Inputs (y_sign)
# Grouping them keeps the wave window clean
add wave -noupdate -divider "Inputs"
add wave -noupdate -group "y_sign Input" /system_top_tb/y_sign

# 4. Outputs (x_out)
# Setting radix to decimal helps view the signed values
add wave -noupdate -divider "Outputs"
add wave -noupdate -group "x_out Result" -radix decimal /system_top_tb/x_out

# 5. Expected Data (for comparison)
add wave -noupdate -group "Expected Data" -radix decimal /system_top_tb/x_frames

# ---------------------------------------------------------
# Formatting
# ---------------------------------------------------------
configure wave -namecolwidth 200
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

# ---------------------------------------------------------
# Run
# ---------------------------------------------------------
run -all
wave zoom full