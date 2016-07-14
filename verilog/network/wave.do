onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_network/clock
add wave -noupdate /tb_network/reset
add wave -noupdate /tb_network/newSample
add wave -noupdate /tb_network/dataReady
add wave -noupdate /tb_network/LSTM_LAYER/beginCalc
add wave -noupdate /tb_network/inputVec
add wave -noupdate /tb_network/outputVec
add wave -noupdate /tb_network/dataReadyP
add wave -noupdate /tb_network/enPerceptron
add wave -noupdate /tb_network/networkOutput
add wave -noupdate /tb_network/PERCEPTRON/Adder1
add wave -noupdate /tb_network/PERCEPTRON/finalResult
add wave -noupdate /tb_network/PERCEPTRON/outputMAC
add wave -noupdate /tb_network/PERCEPTRON/rowMux
add wave -noupdate /tb_network/LSTM_LAYER/GATE_I/DOTPROD_X/weightMAC
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {890376812500 fs} 0} {{Cursor 2} {890745537500 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 450
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
configure wave -timelineunits ns
update
WaveRestoreZoom {3265150156500 fs} {3265906636500 fs}
