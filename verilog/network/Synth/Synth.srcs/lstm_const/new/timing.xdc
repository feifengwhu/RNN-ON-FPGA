
create_clock -period 9.500 -name clock -waveform {0.000 4.800} [get_ports -filter { NAME =~  "*clock*" && DIRECTION == "IN" }]
