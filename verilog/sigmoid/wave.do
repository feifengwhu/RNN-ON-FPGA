onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sigmoid/SIGMOID01/clk
add wave -noupdate /tb_sigmoid/SIGMOID01/reset
add wave -noupdate /tb_sigmoid/SIGMOID01/result
add wave -noupdate /tb_sigmoid/SIGMOID01/p2_i1
add wave -noupdate /tb_sigmoid/SIGMOID01/p1_i1
add wave -noupdate /tb_sigmoid/SIGMOID01/p0_i1
add wave -noupdate /tb_sigmoid/SIGMOID01/p2_i2
add wave -noupdate /tb_sigmoid/SIGMOID01/p1_i2
add wave -noupdate /tb_sigmoid/SIGMOID01/p0_i2
add wave -noupdate /tb_sigmoid/SIGMOID01/p2_i3
add wave -noupdate /tb_sigmoid/SIGMOID01/p1_i3
add wave -noupdate /tb_sigmoid/SIGMOID01/p0_i3
add wave -noupdate /tb_sigmoid/SIGMOID01/p2_i4
add wave -noupdate /tb_sigmoid/SIGMOID01/p1_i4
add wave -noupdate /tb_sigmoid/SIGMOID01/p0_i4
add wave -noupdate /tb_sigmoid/SIGMOID01/p2
add wave -noupdate /tb_sigmoid/SIGMOID01/p1
add wave -noupdate /tb_sigmoid/SIGMOID01/p0
add wave -noupdate /tb_sigmoid/SIGMOID01/state
add wave -noupdate /tb_sigmoid/SIGMOID01/outputInt
add wave -noupdate /tb_sigmoid/SIGMOID01/multiplierMux
add wave -noupdate /tb_sigmoid/SIGMOID01/adderMux
add wave -noupdate /tb_sigmoid/SIGMOID01/operand
add wave -noupdate /tb_sigmoid/SIGMOID01/operandPipe1
add wave -noupdate /tb_sigmoid/SIGMOID01/operandPipe2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 438
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
WaveRestoreZoom {0 ns} {8267 ns}
