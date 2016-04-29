onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_dot_prod/DOTPROD/inputVector
add wave -noupdate /tb_dot_prod/DOTPROD/clk
add wave -noupdate /tb_dot_prod/DOTPROD/reset
add wave -noupdate /tb_dot_prod/DOTPROD/dataReady
add wave -noupdate /tb_dot_prod/DOTPROD/colAddress
add wave -noupdate /tb_dot_prod/DOTPROD/outputVector
add wave -noupdate /tb_dot_prod/DOTPROD/rowMux
add wave -noupdate /tb_dot_prod/DOTPROD/weightMAC
add wave -noupdate /tb_dot_prod/DOTPROD/state
add wave -noupdate /tb_dot_prod/DOTPROD/NEXTstate
add wave -noupdate /tb_dot_prod/DOTPROD/outputEn
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
