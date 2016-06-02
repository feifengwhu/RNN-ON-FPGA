onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_network/LSTM_LAYER/PRNG_1/celAut
add wave -noupdate /tb_network/LSTM_LAYER/PRNG_1/clock
add wave -noupdate /tb_network/LSTM_LAYER/PRNG_1/enable
add wave -noupdate /tb_network/LSTM_LAYER/PRNG_1/extractedCA
add wave -noupdate /tb_network/LSTM_LAYER/PRNG_1/extractedSR
add wave -noupdate /tb_network/LSTM_LAYER/PRNG_1/fetchSample
add wave -noupdate /tb_network/LSTM_LAYER/PRNG_1/randomArray
add wave -noupdate /tb_network/LSTM_LAYER/PRNG_1/reset
add wave -noupdate /tb_network/LSTM_LAYER/PRNG_1/seed
add wave -noupdate /tb_network/LSTM_LAYER/PRNG_1/shiftReg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {1 ns}
