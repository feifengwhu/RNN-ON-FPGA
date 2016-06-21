onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_array/PERCEPTRON/clk
add wave -noupdate /tb_array/PERCEPTRON/state
add wave -noupdate /tb_array/PERCEPTRON/rowMux
add wave -noupdate /tb_array/PERCEPTRON/dataReady
add wave -noupdate /tb_array/PERCEPTRON/finalResult
add wave -noupdate /tb_array/PERCEPTRON/inputVector
add wave -noupdate /tb_array/PERCEPTRON/weightRow
add wave -noupdate /tb_array/PERCEPTRON/outputMAC
add wave -noupdate /tb_array/PERCEPTRON/Adder1
add wave -noupdate /tb_array/PERCEPTRON/reset
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 263
configure wave -valuecolwidth 248
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {12170 ps}
