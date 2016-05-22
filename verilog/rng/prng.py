import numpy as np
import matplotlib.pyplot as plt

# System parameters
LFSR_size = 43
CA_size = 37
out_size = 32

# Simulation parameters
NUM_ITER = 1000

# Initializing the Shift Register
shiftReg = np.random.randint(2, size=LFSR_size)
prevLFSR = np.zeros((NUM_ITER, shiftReg.size))

# Initializing the Cellular Automata
celAut = np.random.randint(2, size=CA_size)
for i in range(CA_size):
	celAut[i] = 0
celAut[17] = 1
nextCA = np.random.randint(2, size=CA_size)
prevCA = np.zeros((NUM_ITER, celAut.size))

# Initializing the Combined Result
prngOut = np.random.randint(2, size=32)
prevPRNGout = np.zeros((NUM_ITER, 32))


for t in range(NUM_ITER):
	# Iterating the Shift Register
	prevLFSR[t] = shiftReg
	feedback    = (shiftReg[0] + shiftReg[19] + shiftReg[40] + shiftReg[42]) % 2
	shiftReg    = np.roll(shiftReg, 1)
	shiftReg[0] = feedback

	# Iterating the Cellular Automata
	prevCA[t] = celAut
	for k in range(CA_size):
		
		if (k == 28) :
			# Rule 150 for the cell site 28
			nextCA[k] = (celAut[k-1] + celAut[k] + celAut[k+1]) % 2
		elif (k == 0):
			# Null boundary condition LEFT
			nextCA[k] = celAut[k+1]
		elif (k == (CA_size - 1)):
			# Null boundary condition RIGHT
			nextCA[k] = celAut[k-1]
		else :
			# Rull 30 for the remaining cell sites
			nextCA[k] = (celAut[k-1] + celAut[k+1]) % 2

	celAut = nextCA		

	# Iterating the combined PRNG
	prevPRNGout[t] = celAut[0:32] ^ shiftReg[0:32] 

# Count the ones test
LFSR_ones = 0
CA_ones   = 0
PRNG_ones = 0
for i in range(NUM_ITER):
	for j in range(shiftReg.size):
		LFSR_ones += prevLFSR[i,j] 
	for j in range(celAut.size):
		CA_ones   += prevCA[i,j] 		
	for j in range(prngOut.size):
		PRNG_ones += prevPRNGout[i,j] 

print("* ----------- Ones Frequency ----------- *")
print("Shift Register    : ", LFSR_ones/(NUM_ITER*shiftReg.size))
print("Cellular Automata : ", CA_ones/(NUM_ITER*celAut.size))
print("Combined Output   : ", PRNG_ones/(NUM_ITER*prngOut.size))

plt.figure(1)	
plt.subplot(1,3,1)	
plt.imshow(prevLFSR,cmap=plt.cm.gray, interpolation='none', aspect=0.33)		
plt.subplot(1,3,2)
plt.imshow(prevCA,cmap=plt.cm.gray, interpolation='none', aspect=0.33)	
plt.subplot(1,3,3)
plt.imshow(prevPRNGout,cmap=plt.cm.gray,interpolation='none',  aspect=0.3)	

plt.show()
