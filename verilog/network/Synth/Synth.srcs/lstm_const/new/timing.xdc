
create_clock -period 9.85 -name clock [get_ports -filter { NAME =~  "*clock*" && DIRECTION == "IN" }]
