import numpy as np
import matplotlib.pyplot as plt

NUM_ITER = 2000
prevPRNGout = np.zeros((NUM_ITER, 32))
prevSRout = np.zeros((NUM_ITER, 43))
prevCAout = np.zeros((NUM_ITER, 37))

fout    = open("output.hex", "r")
fout_SR = open("output_SR.hex", "r")
fout_CA = open("output_CA.hex", "r")

for i in range(NUM_ITER):
	line = fout.readline()
	line_SR = fout_SR.readline()
	line_CA = fout_CA.readline()
	
	for j in range(len(line)-1):
		prevPRNGout[i,j] = int(line[j])
	for j in range(len(line_SR)-1):	
		prevSRout[i,j] = int(line_SR[j])
	for j in range(len(line_CA)-1):
		prevCAout[i,j] = int(line_CA[j])

# Count the ones test
PRNG_ones = 0
SR_ones = 0
CA_ones = 0

for i in range(NUM_ITER):
	for j in range(32):
		PRNG_ones += prevPRNGout[i,j] 
	for j in range(43):
		SR_ones += prevSRout[i,j] 
	for j in range(37):
		CA_ones += prevCAout[i,j] 

print("* ----------- Ones Frequency ----------- *")
print("Combined Output   : ", PRNG_ones/(NUM_ITER*32))
print("Combined Output   : ", SR_ones/(NUM_ITER*43))
print("Combined Output   : ", CA_ones/(NUM_ITER*37))

plt.figure(1)	
plt.subplot(1,3,1)	
plt.imshow(prevSRout,cmap=plt.cm.gray, interpolation='none', aspect=0.2)		
plt.subplot(1,3,2)
plt.imshow(prevCAout,cmap=plt.cm.gray, interpolation='none', aspect=0.2)	
plt.subplot(1,3,3)
plt.imshow(prevPRNGout,cmap=plt.cm.gray,interpolation='none',  aspect=0.2)	

plt.show()
