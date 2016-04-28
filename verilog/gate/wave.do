onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_gate/colAddressWrite_X
add wave -noupdate /tb_gate/colAddressWrite_Y
add wave -noupdate /tb_gate/colAddressRead_X
add wave -noupdate /tb_gate/colAddressRead_Y
add wave -noupdate /tb_gate/weightMemInput_X
add wave -noupdate /tb_gate/weightMemOutput_X
add wave -noupdate /tb_gate/weightMemInput_Y
add wave -noupdate /tb_gate/weightMemOutput_Y
add wave -noupdate /tb_gate/gateOutput
add wave -noupdate /tb_gate/dataReady_gate
add wave -noupdate /tb_gate/clock
add wave -noupdate /tb_gate/reset
add wave -noupdate /tb_gate/beginCalc
add wave -noupdate /tb_gate/writeEn_X
add wave -noupdate /tb_gate/writeEn_Y
add wave -noupdate /tb_gate/inputVec
add wave -noupdate /tb_gate/prevOutVec
add wave -noupdate /tb_gate/biasVec
add wave -noupdate /tb_gate/GATE/reset_dotProd_X
add wave -noupdate /tb_gate/GATE/reset_dotProd_Y
add wave -noupdate /tb_gate/GATE/enable_dotprodX
add wave -noupdate /tb_gate/GATE/enable_dotprodY
add wave -noupdate /tb_gate/GATE/state
add wave -noupdate /tb_gate/GATE/outputVec_X
add wave -noupdate /tb_gate/GATE/outputVec_Y
add wave -noupdate /tb_gate/GATE/adder_X
add wave -noupdate /tb_gate/ROM_prevOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {159688 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 246
configure wave -valuecolwidth 63
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
WaveRestoreZoom {132261 ps} {188224 ps}
