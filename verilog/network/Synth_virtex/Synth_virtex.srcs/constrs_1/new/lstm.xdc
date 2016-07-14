create_clock -period 7.1 -name clock [get_ports -filter { NAME =~  "*clock*" && DIRECTION == "IN" }]
