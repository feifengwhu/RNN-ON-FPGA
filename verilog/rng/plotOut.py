import numpy as np
import matplotlib.pyplot as plt

NUM_ITER = 1000
prevPRNGout = np.zeros((NUM_ITER, 32))

fout = open("output.hex", "r")

for i in range(NUM_ITER):
	line = fout.readline()
	for j in range(len(line)-1):
			prevPRNGout[i,j] = int(line[j])

# Count the ones test
PRNG_ones = 0

for i in range(NUM_ITER):
	for j in range(32):
		PRNG_ones += prevPRNGout[i,j] 

print("* ----------- Ones Frequency ----------- *")
print("Combined Output   : ", PRNG_ones/(NUM_ITER*32))

plt.figure(1)	
plt.imshow(prevPRNGout,cmap=plt.cm.gray,interpolation='none',  aspect=0.2)	

plt.show()
