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
numTrain = 1000
prevX = list()
outputGolden  = list()
outputVerilog = list()
outputPython  = list()
wrongBits = 0
f_in = open("goldenIn_x.bin", "w")


 

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
		prevX.append(X)
		f_in.write("{0:018b}\n".format(real_to_Qnm(X[0,0], QN, QM))) 
		f_in.write("{0:018b}\n".format(real_to_Qnm(X[1,0], QN, QM))) 

f_in.close()

# Compiles and runs the Verilog simulation
os.system("vlog *.v")
os.system("vsim -c -do \"run -all\" tb_network")

# Loads the pickled layer
f_pkl = open("layer.pickle", "rb")
layer = pickle.load(f_pkl);

# Loads the output values
layerOut = np.zeros((8,1));
fout = open("output.bin", "r");

layer.resetNetwork()

"""
for j in range(hiddenSz):
		line = fout.readline()
"""
for n in range(numTrain):
	for i in range(numBits):
		for j in range(hiddenSz):
			line = fout.readline();
			layerOut[j,0] = Qnm_to_real(int(line), 6,11);
		
		# HDL Network output
		temp = layer.forwardPropagate(prevX[i+numBits*n])
		outputVerilog.append(int(np.round(sigmoid(np.dot(layer.outW, layerOut)))));
		outputPython.append(int(np.round(temp)));
	
		if(outputVerilog[i] ^ outputPython[i]) :
			print("Error: ", outputVerilog, " --> ", outputPython)
			print(sigmoid(np.dot(layer.outW, layerOut)), " --> ", temp)
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
	
print("Num wrong bits: ", wrongBits)
