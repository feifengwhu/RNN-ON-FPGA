rm *.bin
python3 genData.py
vlog *.v
vsim -c -do "run -all" tb_dot_prod
