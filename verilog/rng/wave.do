onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /tb_prng/RandomGen/shiftReg
add wave -noupdate /tb_prng/RandomGen/next_SR_Bit
add wave -noupdate /tb_prng/RandomGen/celAut
add wave -noupdate /tb_prng/clock
add wave -noupdate /tb_prng/reset
add wave -noupdate /tb_prng/enablePRNG
add wave -noupdate /tb_prng/fetchNewSample
add wave -noupdate /tb_prng/randomArray
add wave -noupdate /tb_prng/initSeed
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 240
configure wave -valuecolwidth 40
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
WaveRestoreZoom {3937 ns} {4049 ns}
