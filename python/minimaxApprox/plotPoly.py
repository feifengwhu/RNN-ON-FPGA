import numpy as np
import matplotlib.pyplot as plt

# The fixed-point decimal precision

# The original optimal coefficients
sig1 = np.array([[ 0.20323428,  0.0717631,   0.00642858]])
sig2 = np.array([[ 0.50195831,  0.27269294,  0.04059181]])
sig3 = np.array([[ 0.49805785,  0.27266221, -0.04058115]])
sig4 = np.array([[ 0.7967568,   0.07175359, -0.00642671]])

tan1 = np.array([[-0.39814608,  0.46527859,  0.09007576]])
tan2 = np.array([[ 0.0031444,   1.08381219,  0.31592922]])
tan3 = np.array([[-0.00349517,  1.08538355, -0.31676793]])
tan4 = np.array([[ 0.39878032,  0.46509003, -0.09013554]])

# Converts the polynomial coefficients to the binary representation
sig1bin = np.round(sig1*(2**11)).astype(int)
sig2bin = np.round(sig2*(2**11)).astype(int)
sig3bin = np.round(sig3*(2**11)).astype(int)
sig4bin = np.round(sig4*(2**11)).astype(int)

tan1bin = np.round(tan1*(2**11)).astype(int)
tan2bin = np.round(tan2*(2**11)).astype(int)
tan3bin = np.round(tan3*(2**11)).astype(int)
tan4bin = np.round(tan4*(2**11)).astype(int)

fsig = open('sigmoid_coefs.hex', 'w')
ftan = open('tanh_coefs.hex', 'w')

for i in range(sig1bin.shape[1]): 
    if (sig1bin[0,i] >= 0) : 
        fsig.write('{0:018b}\n'.format(sig1bin[0,i]))
    else:
        fsig.write('{0:018b}\n'.format(2**18+sig1bin[0,i]))
for i in range(sig2bin.shape[1]): 
    if (sig2bin[0,i] >= 0) : 
        fsig.write('{0:018b}\n'.format(sig2bin[0,i]))
    else:
        fsig.write('{0:018b}\n'.format(2**18+sig2bin[0,i]))
for i in range(sig3bin.shape[1]): 
    if (sig3bin[0,i] >= 0) : 
        fsig.write('{0:018b}\n'.format(sig3bin[0,i]))
    else:
        fsig.write('{0:018b}\n'.format(2**18+sig3bin[0,i]))
for i in range(sig4bin.shape[1]): 
    if (sig4bin[0,i] >= 0) : 
        fsig.write('{0:018b}\n'.format(sig4bin[0,i]))
    else:
        fsig.write('{0:018b}\n'.format(2**18+sig4bin[0,i]))
fsig.close()

for i in range(tan1bin.shape[1]): 
    if (tan1bin[0,i] >= 0) : 
        ftan.write('{0:018b}\n'.format(tan1bin[0,i]))
    else:
        ftan.write('{0:018b}\n'.format(2**18+tan1bin[0,i]))
for i in range(tan2bin.shape[1]): 
    if (tan2bin[0,i] >= 0) : 
        ftan.write('{0:018b}\n'.format(tan2bin[0,i]))
    else:
        ftan.write('{0:018b}\n'.format(2**18+tan2bin[0,i]))
for i in range(tan3bin.shape[1]): 
    if (tan3bin[0,i] >= 0) : 
        ftan.write('{0:018b}\n'.format(tan3bin[0,i]))
    else:
        ftan.write('{0:018b}\n'.format(2**18+tan3bin[0,i]))
for i in range(tan4bin.shape[1]): 
    if (tan4bin[0,i] >= 0) : 
        ftan.write('{0:018b}\n'.format(tan4bin[0,i]))
    else:
        ftan.write('{0:018b}\n'.format(2**18+tan4bin[0,i]))
ftan.close()

# Converts them back to float, but now with limited precision
sig1 = sig1bin*(2**-11)
sig2 = sig2bin*(2**-11)
sig3 = sig3bin*(2**-11)
sig4 = sig4bin*(2**-11)

tan1 = tan1bin*(2**-11)
tan2 = tan2bin*(2**-11)
tan3 = tan3bin*(2**-11)
tan4 = tan4bin*(2**-11)

def sigmoidPoly(x):
    if (x <= -6) :
        return 0
    elif (x > -6) and (x <= -3):
        x = np.round((2**11)*x)
        return np.dot(sig1bin, np.array([[2**11, x, np.round((x**2)/(2**11))]]).T)/(2**11)
    elif (x > -3) and (x <= 0):
        x = np.round((2**11)*x)
        return np.dot(sig2bin, np.array([[2**11, x, np.round((x**2)/(2**11))]]).T)/(2**11)
    elif (x > 0) and (x <= 3):
        x = np.round((2**11)*x)
        return np.dot(sig3bin, np.array([[2**11, x, np.round((x**2)/(2**11))]]).T)/(2**11)
    elif (x > 3) and (x <= 6):
        x = np.round((2**11)*x)
        return np.dot(sig4bin, np.array([[2**11, x, np.round((x**2)/(2**11))]]).T)/(2**11)
    else:
        return (2**11)

def tanhPoly(x):
    if (x <= -3) :
        return -(2**11)
    elif (x > -3) and (x <= -1):
        x = np.round((2**11)*x)
        return np.dot(tan1bin, np.array([[2**11, x, np.round((x**2)/(2**11))]]).T)/(2**11)
    elif (x > -1) and (x <= 0):
        x = np.round((2**11)*x)
        return np.dot(tan2bin, np.array([[2**11, x, np.round((x**2)/(2**11))]]).T)/(2**11)
    elif (x > 0) and (x <= 1):
        x = np.round((2**11)*x)
        return np.dot(tan3bin, np.array([[2**11, x, np.round((x**2)/(2**11))]]).T)/(2**11)
    elif (x > 1) and (x <= 3):
        x = np.round((2**11)*x)
        return np.dot(tan4bin, np.array([[2**11, x, np.round((x**2)/(2**11))]]).T)/(2**11)
    else:
        return (2**11)

def sigmoid(x):
    return 1/(1+np.exp(-x))

t = np.arange(-10, 10, 2**-11)

# Writes to a file the golden input
fin = open('goldenIN.hex', 'w')
for i in range(len(t)):
    if (t[i] >= 0) : 
        fin.write('{0:018b}\n'.format(np.round(t[i]*(2**11)).astype(int)))
    else:
        fin.write('{0:018b}\n'.format(2**18+np.round(t[i]*(2**11)).astype(int)))
fin.close()

# Generates the output vector    
sigPoly  = np.array([sigmoidPoly(t[i]) for i in range(len(t))])/(2**11)
tanhPoly = np.array([tanhPoly(t[i])    for i in range(len(t))])/(2**11)

# Writes to a file the golden input
fout = open('sigmoid_goldenOUT.hex', 'w')
for i in range(len(sigPoly)):
    if (sigPoly[i] >= 0) : 
        fout.write('{0:018b}\n'.format(np.round(sigPoly[i]*(2**11)).astype(int)))
    else:
        fout.write('{0:018b}\n'.format(2**18+np.round(sigPoly[i]*(2**11)).astype(int)))
fout.close()

fout2 = open('tanh_goldenOUT.hex', 'w')
for i in range(len(sigPoly)):
    if (tanhPoly[i] >= 0) : 
        fout2.write('{0:018b}\n'.format(np.round(tanhPoly[i]*(2**11)).astype(int)))
    else:
        fout2.write('{0:018b}\n'.format(2**18+np.round(tanhPoly[i]*(2**11)).astype(int)))
fout2.close()

diffSig = abs(sigPoly  - sigmoid(t))
diffTan = abs(tanhPoly - np.tanh(t))

plt.figure(1)
plt.plot(t, sigPoly, t, sigmoid(t))
plt.figure(2)
plt.plot(t, tanhPoly, t, np.tanh(t))
plt.figure(3)
plt.plot(t, diffSig)
plt.figure(4)
plt.plot(t, diffTan)
plt.show()
