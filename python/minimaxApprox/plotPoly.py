import numpy as np
import matplotlib.pyplot as plt

def sigmoidPoly(x):
    if (x <= -6) :
        return 0
    elif (x > -6) and (x <= -3):
        return 0.20323428 + 0.0717631*x   + 0.00642858*(x**2)
    elif (x > -3) and (x <= 0):
        return 0.50195831 + 0.27269294*x  + 0.04059181*(x**2)
    elif (x > 0) and (x <= 3):
        return 0.49805785 + 0.27266221*x  - 0.04058115*(x**2)
    elif (x > 3) and (x <= 6):
        return 0.7967568  + 0.07175359*x  - 0.00642671*(x**2)
    else:
        return 1

def tanhPoly(x):
    if (x <= -3) :
        return -1
    elif (x > -3) and (x <= -1):
        return -0.39814608 + 0.46527859*x + 0.09007576*(x**2)
    elif (x > -1) and (x <= 0):
        return 0.0031444 + 1.08381219*x + 0.31592922*(x**2)
    elif (x > 0) and (x <= 1):
        return -0.00349517 + 1.08538355*x -0.31676793*(x**2) 
    elif (x > 1) and (x <= 3):
        return 0.39814608 + 0.46527859*x - 0.09007576*(x**2)
    else:
        return 1

def sigmoid(x):
    return 1/(1+np.exp(-x))

t = np.arange(-6, 6, 2**-10)
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
