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
wmax = 10
numTrain = 1000
prevX = list()
outputGolden  = list()
outputVerilog = list()
outputPython  = list()
wrongBits = 0

f_X  = open("array_X.bin", "w")
f_w  = open("array_w.bin", "w")
f_y  = open("array_y.bin", "w")

X = (np.random.random((8,1)))*wmax
w = (np.random.random((8,1)))*wmax

"""
for i in range(hiddenSz):
	X[i,0] = i;
	w[i,0] = 1;
	f_X.write("{0:018b}\n".format(real_to_Qnm(X[i,0], QN, QM))) 
	f_w.write("{0:018b}\n".format(real_to_Qnm(1, QN, QM))) 

y = np.dot(X.T, w)
f_y.write("{0:018b}\n".format(real_to_Qnm(y, QN, QM)))
 
"""
for n in range(numTrain):
	X = (np.random.random((8,1)) - 0.5)*wmax
	w = (np.random.random((8,1)) - 0.5)*wmax
	y = np.dot(X.T,w)
	
	f_y.write("{0:018b}\n".format(real_to_Qnm(y, QN, QM))) 
	
	for i in range(hiddenSz):
		f_X.write("{0:018b}\n".format(real_to_Qnm(X[i,0], QN, QM))) 
		f_w.write("{0:018b}\n".format(real_to_Qnm(w[i,0], QN, QM))) 

	
f_X.close()
f_w.close()
f_y.close()

"""
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


for j in range(hiddenSz):
		line = fout.readline()

for n in range(numTrain):
	for i in range(numBits):
		line = fout.readline();
		outputNetwork = Qnm_to_real(int(line), QN,QM);

		# HDL Network output
		temp = layer.forwardPropagate(prevX[i+numBits*n])
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
