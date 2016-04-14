onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_dot_prod/ROM_input
add wave -noupdate /tb_dot_prod/colAddress_X
add wave -noupdate /tb_dot_prod/colAddress_Y
add wave -noupdate /tb_dot_prod/weightMem_X
add wave -noupdate /tb_dot_prod/weightMem_Y
add wave -noupdate /tb_dot_prod/dataReady_gate
add wave -noupdate /tb_dot_prod/clock
add wave -noupdate /tb_dot_prod/reset
add wave -noupdate /tb_dot_prod/GATE/state
add wave -noupdate /tb_dot_prod/GATE/NEXTstate
add wave -noupdate /tb_dot_prod/GATE/adder_X
add wave -noupdate /tb_dot_prod/gateOutput
add wave -noupdate /tb_dot_prod/GATE/dataReady_X
add wave -noupdate /tb_dot_prod/GATE/dataReady_Y
add wave -noupdate /tb_dot_prod/GATE/enable_dotprodX
add wave -noupdate /tb_dot_prod/GATE/enable_dotprodY
add wave -noupdate /tb_dot_prod/GATE/outputVec_X
add wave -noupdate /tb_dot_prod/GATE/outputVec_Y
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {41594 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 318
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {135964 ps}
