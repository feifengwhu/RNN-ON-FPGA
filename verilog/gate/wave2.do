onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_gate/GATE/prevLayerOut
add wave -noupdate /tb_gate/GATE/weightMem_X
add wave -noupdate /tb_gate/GATE/weightMem_Y
add wave -noupdate /tb_gate/GATE/biasVec
add wave -noupdate /tb_gate/GATE/beginCalc
add wave -noupdate /tb_gate/GATE/clock
add wave -noupdate /tb_gate/GATE/reset
add wave -noupdate /tb_gate/GATE/colAddress_X
add wave -noupdate /tb_gate/GATE/colAddress_Y
add wave -noupdate /tb_gate/GATE/dataReady_gate
add wave -noupdate /tb_gate/GATE/inputVec
add wave -noupdate /tb_gate/GATE/outputVec_X
add wave -noupdate /tb_gate/GATE/outputVec_Y
add wave -noupdate /tb_gate/GATE/adder_X
add wave -noupdate /tb_gate/GATE/gateOutput
add wave -noupdate /tb_gate/GATE/dataReady_X
add wave -noupdate /tb_gate/GATE/dataReady_Y
add wave -noupdate /tb_gate/GATE/state
add wave -noupdate /tb_gate/GATE/enable_dotprodX
add wave -noupdate /tb_gate/GATE/enable_dotprodY
add wave -noupdate /tb_gate/ROM_goldenOut
add wave -noupdate /tb_gate/GATE/DOTPROD_X/dataReady
add wave -noupdate /tb_gate/GATE/DOTPROD_X/dataReadyF
add wave -noupdate /tb_gate/GATE/DOTPROD_X/colAddress
add wave -noupdate /tb_gate/GATE/DOTPROD_X/inputVector
add wave -noupdate /tb_gate/GATE/DOTPROD_X/inputVectorPipe
add wave -noupdate /tb_gate/GATE/DOTPROD_X/inputVectorPipe2
add wave -noupdate /tb_gate/GATE/DOTPROD_X/weightRow
add wave -noupdate /tb_gate/GATE/DOTPROD_X/weightMAC
add wave -noupdate /tb_gate/GATE/DOTPROD_X/outputMAC
add wave -noupdate /tb_gate/GATE/DOTPROD_X/outputVector
add wave -noupdate /tb_gate/GATE/DOTPROD_X/rowMux
add wave -noupdate /tb_gate/GATE/DOTPROD_X/rowMuxP
add wave -noupdate /tb_gate/GATE/DOTPROD_X/rowMuxP2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5328000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 363
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
WaveRestoreZoom {5320108 ps} {5357858 ps}
