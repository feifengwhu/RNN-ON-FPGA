
create_clock -period 10 -name clock [get_ports -filter { NAME =~  "*clock*" && DIRECTION == "IN" }]
