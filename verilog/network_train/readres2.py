import pickle
import numpy as np
import os

def real_to_Qnm(real, n, m):
    if(real >= 0):
        return int(np.round(real*(2**m)).astype(int)) & int(2**(n+m+1)-1)
    else:
        return int(2**(n+m+1) + np.round(real*(2**m)).astype(int)) & int(2**(n+m+1)-1)
def Qnm_to_real(real, n, m):
    real = int(real) & int(2**(n+m+1)-1)
    if(real >= 2**(n+m)):
        return (real-2**(n+m+1))/(2**m)
    else:
        return real/(2**m)
def sigmoid(x):
	output = 1/(1+np.exp(-x))
	return output

numBits  = 8
binary_dim = numBits
largest_number = pow(2,binary_dim)
hiddenSz = 8
QN = 6
QM = 11
numTrain = 100000
prevX = list()
outputGolden  = list()
outputVerilog = list()
outputPython  = list()
wrongBits = 0
f_in   = open("goldenIn_x.bin", "w")
f_out  = open("goldenOut.bin", "w")

# Loads the pickled layer
f_pkl = open("layer.pickle", "rb")
layer = pickle.load(f_pkl);
layer.resetNetwork()

for i in range(numTrain):
	# Generates the golden input and output
	a_int = np.random.randint(largest_number/2) # int version
	a = np.binary_repr(a_int, width=binary_dim) # binary encoding

	b_int = np.random.randint(largest_number/2) # int version
	b = np.binary_repr(b_int, width=binary_dim) # binary encoding

	c_int = a_int + b_int
	c = np.binary_repr(c_int, width=binary_dim)
	
	for position in range(binary_dim):
		X  = np.array([[int(a[binary_dim - position - 1]), int(b[binary_dim - position - 1])]]).T
		y  = np.array([int(c[binary_dim - position - 1])]).T
		prevX.append(X)
		f_in.write("{0:018b}\n".format(real_to_Qnm(X[0,0], QN, QM))) 
		f_in.write("{0:018b}\n".format(real_to_Qnm(X[1,0], QN, QM)))

		y = layer.forwardPropagate(X); 
		f_out.write("{0}\n".format(int(np.round(y)), QN, QM))
		
		layer.prev_c = layer.c
		layer.prev_y = layer.y
		
	layer.resetNetwork()

f_in.close()
f_out.close()

# Compiles and runs the Verilog simulation
os.system("vlog *.v")
#os.system("vsim -c -novopt -do \"run -all\" tb_network")

"""
# Loads the pickled layer
f_pkl = open("layer.pickle", "rb")
layer = pickle.load(f_pkl);

# Loads the output values
layerOut = np.zeros((8,1));
fout = open("output.bin", "r");

layer.resetNetwork()

for n in range(numTrain):
	for i in range(numBits):
		line = fout.readline();
		outputNetwork = Qnm_to_real(int(line), QN,QM);

		# HDL Network output

		outputVerilog.append(int(np.round(sigmoid(outputNetwork))));
		outputPython.append(int(np.round(temp)));
	
		if(outputVerilog[i] ^ outputPython[i]) :
			print("Error: ", outputVerilog, " --> ", outputPython)
			print(sigmoid(outputNetwork), " --> ", temp)
			wrongBits += 1
		
		layer.prev_c = layer.c
		layer.prev_y = layer.y
	
	outputVerilog.reverse()
	outputPython.reverse()
	
	#print("Sample %d", n)
	#print(outputVerilog, "\n", outputPython);
	outputVerilog = list()
	outputPython = list()

	layer.resetNetwork()
	
print("% wrong bits: ", 100*wrongBits/(numTrain*numBits))
"""
