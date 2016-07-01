
create_clock -period 11.05 -name clock [get_ports -filter { NAME =~  "*clock*" && DIRECTION == "IN" }]
