onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format literal -group Inputs /passive_top_tb/rst_n
add wave -noupdate -format literal -group Inputs /passive_top_tb/clk
add wave -noupdate -format literal -radix decimal -group Inputs /passive_top_tb/ALPHA
add wave -noupdate -format literal -radix decimal -group Inputs /passive_top_tb/Z_in
add wave -noupdate -format literal -radix decimal -group Inputs /passive_top_tb/Z
add wave -noupdate -format literal -radix decimal -group Soft-Threshold /passive_top_tb/PASSIVE_ALG/Z_1
add wave -noupdate -format literal -radix decimal -group Soft-Threshold /passive_top_tb/PASSIVE_ALG/Z_1

add wave -noupdate -format literal -radix decimal -group Soft-Threshold /passive_top_tb/x_soft_ref
add wave -noupdate -format literal -radix decimal -group Soft-Threshold /passive_top_tb/PASSIVE_ALG/x_soft
add wave -noupdate -format literal -radix decimal -group Soft-Threshold /passive_top_tb/PASSIVE_ALG/x_soft_1

add wave -noupdate -format literal -radix decimal -group Norm /passive_top_tb/norm_sq_ref
add wave -noupdate -format literal -radix decimal -group Norm /passive_top_tb/PASSIVE_ALG/U_L2/norm
add wave -noupdate -format literal -radix decimal -group Norm /passive_top_tb/rsqrt_ref
add wave -noupdate -format literal -radix decimal -group Norm /passive_top_tb/PASSIVE_ALG/U_L2/r_sqrt

add wave -noupdate -format literal -radix decimal -group Outputs /passive_top_tb/x_ref
add wave -noupdate -format literal -radix decimal -group Outputs /passive_top_tb/x

configure wave -namecolwidth 252
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1

