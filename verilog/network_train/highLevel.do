onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_network/clock
add wave -noupdate /tb_network/reset
add wave -noupdate /tb_network/newSample
add wave -noupdate /tb_network/dataReady
add wave -noupdate /tb_network/enPerceptron
add wave -noupdate /tb_network/inputVec
add wave -noupdate /tb_network/outputVec
add wave -noupdate /tb_network/networkOutput
add wave -noupdate /tb_network/modelOutput
add wave -noupdate /tb_network/roundOut
add wave -noupdate /tb_network/resetP
add wave -noupdate /tb_network/dataReadyP
add wave -noupdate /tb_network/costFunc
add wave -noupdate /tb_network/newCostFunc
add wave -noupdate /tb_network/J
add wave -noupdate /tb_network/Jpert
add wave -noupdate /tb_network/diffJ
add wave -noupdate /tb_network/Wperceptron
add wave -noupdate /tb_network/Wperceptron_IN
add wave -noupdate /tb_network/sign_outW
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {749000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 218
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
WaveRestoreZoom {33917881936 ps} {33918863056 ps}
