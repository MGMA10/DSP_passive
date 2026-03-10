vlib work
if {[catch {vlog -suppress 2583 -svinputport=net -f run_list.txt  }  ]} { return }
if {[catch {vsim -voptargs=+acc work.passive_top_tb -l sim.log } ]} { quit -sim } 
do wave.do
# add wave *
# add wave -position insertpoint  \
# sim:/passive_top_tb/Z \
# sim:/passive_top_tb/Z_in \
# sim:/passive_top_tb/x \
# sim:/passive_top_tb/x_ref \
# sim:/passive_top_tb/x_soft_ref \
# sim:/passive_top_tb/PASSIVE_ALG/x_soft
# configure wave -namecolwidth 252
# configure wave -valuecolwidth 100
# configure wave -justifyvalue left
# configure wave -signalnamewidth 1
run -all
