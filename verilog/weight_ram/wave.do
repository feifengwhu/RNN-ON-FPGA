onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_weightRAM/clock
add wave -noupdate /tb_weightRAM/WRAM01/address
add wave -noupdate /tb_weightRAM/WRAM01/rowOutput
add wave -noupdate -expand /tb_weightRAM/WRAM01/RAM_matrix
add wave -noupdate /tb_weightRAM/OUTPUT_PORT_BITWIDTH
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {275 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 289
configure wave -valuecolwidth 121
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
WaveRestoreZoom {0 ns} {1019 ns}
