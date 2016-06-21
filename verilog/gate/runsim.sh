rm *.bin
python3 genData.py
vlog *.v
vsim -voptargs=+acc -c -do "run -all" tb_gate

