import numpy as np
import matplotlib.pyplot as plt

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
sig1bin = np.round(sig1*(2**10)).astype(int)
sig2bin = np.round(sig2*(2**10)).astype(int)
sig3bin = np.round(sig3*(2**10)).astype(int)
sig4bin = np.round(sig4*(2**10)).astype(int)

tan1bin = np.round(tan1*(2**10)).astype(int)
tan2bin = np.round(tan2*(2**10)).astype(int)
tan3bin = np.round(tan3*(2**10)).astype(int)
tan4bin = np.round(tan4*(2**10)).astype(int)

# Converts them back to float, but now with limited precision
sig1 = sig1bin*(2**-10)
sig2 = sig2bin*(2**-10)
sig3 = sig3bin*(2**-10)
sig4 = sig4bin*(2**-10)

tan1 = tan1bin*(2**-10)
tan2 = tan2bin*(2**-10)
tan3 = tan3bin*(2**-10)
tan4 = tan4bin*(2**-10)

def sigmoidPoly(x):
    if (x <= -6) :
        return 0
    elif (x > -6) and (x <= -3):
        return np.dot(sig1, np.array([[1, x, x**2]]).T)
    elif (x > -3) and (x <= 0):
        return np.dot(sig2, np.array([[1, x, x**2]]).T)
    elif (x > 0) and (x <= 3):
        return np.dot(sig3, np.array([[1, x, x**2]]).T)
    elif (x > 3) and (x <= 6):
        return np.dot(sig4, np.array([[1, x, x**2]]).T)
    else:
        return 1

def tanhPoly(x):
    if (x <= -3) :
        return -1
    elif (x > -3) and (x <= -1):
        return np.dot(tan1, np.array([[1, x, x**2]]).T)
    elif (x > -1) and (x <= 0):
        return np.dot(tan2, np.array([[1, x, x**2]]).T)
    elif (x > 0) and (x <= 1):
        return np.dot(tan3, np.array([[1, x, x**2]]).T)
    elif (x > 1) and (x <= 3):
        return np.dot(tan4, np.array([[1, x, x**2]]).T)
    else:
        return 1

def sigmoid(x):
    return 1/(1+np.exp(-x))

t = np.arange(-10, 10, 2**-10)
sigPoly  = np.array([sigmoidPoly(t[i]) for i in range(len(t))])
tanhPoly = np.array([tanhPoly(t[i]) for i in range(len(t))])
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
