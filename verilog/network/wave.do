onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_network/clock
add wave -noupdate /tb_network/reset
add wave -noupdate /tb_network/newSample
add wave -noupdate /tb_network/dataReady
add wave -noupdate /tb_network/inputVec
add wave -noupdate /tb_network/outputVec
add wave -noupdate /tb_network/LSTM_LAYER/WRAM_Z_X/RAM_matrix
add wave -noupdate /tb_network/LSTM_LAYER/WRAM_Z_Y/RAM_matrix
add wave -noupdate /tb_network/LSTM_LAYER/colAddressWrite_wZX
add wave -noupdate /tb_network/LSTM_LAYER/colAddressWrite_wZY
add wave -noupdate /tb_network/LSTM_LAYER/colAddressRead_wZX
add wave -noupdate /tb_network/LSTM_LAYER/colAddressRead_wZY
add wave -noupdate /tb_network/LSTM_LAYER/state
add wave -noupdate /tb_network/LSTM_LAYER/NEXTstate
add wave -noupdate /tb_network/LSTM_LAYER/sigmoidEnable
add wave -noupdate /tb_network/LSTM_LAYER/tanhEnable
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 234
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
WaveRestoreZoom {0 ps} {13750 ps}
