onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_network/clock
add wave -noupdate /tb_network/reset
add wave -noupdate /tb_network/newSample
add wave -noupdate /tb_network/dataReady
add wave -noupdate /tb_network/LSTM_LAYER/beginCalc
add wave -noupdate /tb_network/inputVec
add wave -noupdate /tb_network/outputVec
add wave -noupdate /tb_network/LSTM_LAYER/inputVecSample
add wave -noupdate /tb_network/LSTM_LAYER/prevOutVecSample
add wave -noupdate /tb_network/LSTM_LAYER/colAddressRead_wZX
add wave -noupdate /tb_network/LSTM_LAYER/colAddressRead_wZY
add wave -noupdate /tb_network/LSTM_LAYER/state
add wave -noupdate /tb_network/LSTM_LAYER/NEXTstate
add wave -noupdate /tb_network/LSTM_LAYER/sigmoidEnable
add wave -noupdate /tb_network/LSTM_LAYER/tanhEnable
add wave -noupdate /tb_network/LSTM_LAYER/ZI_prod
add wave -noupdate /tb_network/LSTM_LAYER/CF_prod
add wave -noupdate /tb_network/LSTM_LAYER/layer_C
add wave -noupdate /tb_network/LSTM_LAYER/prev_C
add wave -noupdate /tb_network/LSTM_LAYER/prevLayerOut
add wave -noupdate /tb_network/LSTM_LAYER/elemWise_op1
add wave -noupdate /tb_network/LSTM_LAYER/elemWise_op2
add wave -noupdate /tb_network/LSTM_LAYER/elemWise_mult2
add wave -noupdate /tb_network/LSTM_LAYER/elemWise_mult2_FF
add wave -noupdate /tb_network/LSTM_LAYER/tanh_result
add wave -noupdate /tb_network/LSTM_LAYER/elemWise_mult1
add wave -noupdate /tb_network/LSTM_LAYER/elemWiseMult_out
add wave -noupdate /tb_network/LSTM_LAYER/gate_Z
add wave -noupdate /tb_network/LSTM_LAYER/gate_I
add wave -noupdate /tb_network/LSTM_LAYER/gate_F
add wave -noupdate /tb_network/LSTM_LAYER/gate_O
add wave -noupdate /tb_network/DSP48_PER_ROW_M
add wave -noupdate /tb_network/LSTM_LAYER/GATE_Z/gateOutput
add wave -noupdate /tb_network/LSTM_LAYER/z_ready
add wave -noupdate /tb_network/LSTM_LAYER/f_ready
add wave -noupdate /tb_network/LSTM_LAYER/y_ready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2179711922 ps} 0}
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
WaveRestoreZoom {2556090084 ps} {2556137364 ps}
