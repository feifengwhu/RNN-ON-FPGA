onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_dot_prod/DOTPROD/clk
add wave -noupdate /tb_dot_prod/DOTPROD/reset
add wave -noupdate /tb_dot_prod/DOTPROD/NEXTstate
add wave -noupdate /tb_dot_prod/DOTPROD/state
add wave -noupdate /tb_dot_prod/DOTPROD/colAddress
add wave -noupdate /tb_dot_prod/DOTPROD/rowMux
add wave -noupdate /tb_dot_prod/DOTPROD/dataReady
add wave -noupdate /tb_dot_prod/DOTPROD/weightMAC
add wave -noupdate /tb_dot_prod/DOTPROD/inputVector
add wave -noupdate /tb_dot_prod/DOTPROD/weightRow
add wave -noupdate /tb_dot_prod/DOTPROD/outputMAC_interm
add wave -noupdate /tb_dot_prod/DOTPROD/outputVector
add wave -noupdate -subitemconfig {{/tb_dot_prod/WRAM/RAM_matrix[0]} -expand {/tb_dot_prod/WRAM/RAM_matrix[1]} -expand} /tb_dot_prod/WRAM/RAM_matrix
add wave -noupdate -subitemconfig {{/tb_dot_prod/ROM_weights[1]} {-height 17 -childformat {{{/tb_dot_prod/ROM_weights[1][0]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][1]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][2]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][3]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][4]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][5]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][6]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][7]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][8]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][9]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][10]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][11]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][12]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][13]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][14]} -radix hexadecimal} {{/tb_dot_prod/ROM_weights[1][15]} -radix hexadecimal}}} {/tb_dot_prod/ROM_weights[1][0]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][1]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][2]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][3]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][4]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][5]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][6]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][7]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][8]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][9]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][10]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][11]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][12]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][13]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][14]} {-height 17 -radix hexadecimal} {/tb_dot_prod/ROM_weights[1][15]} {-height 17 -radix hexadecimal}} /tb_dot_prod/ROM_weights
add wave -noupdate -radix binary /tb_dot_prod/weightMemInput
add wave -noupdate /tb_dot_prod/weightMemOutput
add wave -noupdate /tb_dot_prod/colAddressRead
add wave -noupdate /tb_dot_prod/colAddressWrite
add wave -noupdate /tb_dot_prod/writeEn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {112566 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 475
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
WaveRestoreZoom {33207 ps} {151295 ps}
