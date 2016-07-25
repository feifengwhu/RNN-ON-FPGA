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
add wave -noupdate /tb_network/LSTM_LAYER/gateReady_Z
add wave -noupdate /tb_network/LSTM_LAYER/gate_Z
add wave -noupdate /tb_network/LSTM_LAYER/elemWiseMult_out
add wave -noupdate /tb_network/LSTM_LAYER/elemWise_op1
add wave -noupdate /tb_network/LSTM_LAYER/elemWise_op2
add wave -noupdate /tb_network/LSTM_LAYER/elemWise_mult1
add wave -noupdate /tb_network/LSTM_LAYER/elemWise_mult2
add wave -noupdate /tb_network/LSTM_LAYER/elemWise_mult2_FF
add wave -noupdate /tb_network/LSTM_LAYER/tanh_result
add wave -noupdate /tb_network/LSTM_LAYER/tanhEnable
add wave -noupdate /tb_network/LSTM_LAYER/GATE_Z/beginCalc
add wave -noupdate /tb_network/LSTM_LAYER/GATE_Z/DOTPROD_X/colAddress
add wave -noupdate /tb_network/LSTM_LAYER/GATE_Z/DOTPROD_X/inputVector
add wave -noupdate /tb_network/LSTM_LAYER/GATE_Z/DOTPROD_X/inputVectorPipe
add wave -noupdate /tb_network/LSTM_LAYER/WRAM_Z_X/RAM_matrix
add wave -noupdate /tb_network/LSTM_LAYER/GATE_Z/DOTPROD_X/weightRow
add wave -noupdate /tb_network/LSTM_LAYER/GATE_Z/DOTPROD_X/weightMAC
add wave -noupdate /tb_network/LSTM_LAYER/GATE_Z/DOTPROD_X/outputMAC
add wave -noupdate /tb_network/LSTM_LAYER/z_ready
add wave -noupdate /tb_network/LSTM_LAYER/f_ready
add wave -noupdate /tb_network/LSTM_LAYER/y_ready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {890376812500 fs} 0} {{Cursor 2} {2863463400000 fs} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {2863315334116 fs} {2863938769364 fs}
