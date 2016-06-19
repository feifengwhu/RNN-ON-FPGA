"""
Remez Algorithm for minimax polynomial approximation of transcendental functions

Jose Pedro Castro Fonseca, 2016

University of Porto, Portugal

"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import argrelmax

# The target approximation function
def f(x):
    return np.tanh(x)

# Nber of iterations
numIter = 8
 
# Approximation Interval
b = 3
a = 1

# Fixed-point system precision
prec = 2**(-10)
t = np.arange(a, b, prec)

# Polynomial Degree
n = 2 

# Initial set of points
x = np.zeros((n+2,1))
for i in reversed(range(n+2)): x[n+1-i,0] = (a+b)/2+(b-a)/2*np.cos(i*np.pi/(n+1)) 

# The numerical matrices
A = np.zeros((n+2, n+2))
A[:,0] = 1
for i in range(n+2): A[i,n+1] = (-1)**(i+1)

c = np.zeros((n+2,1))

# The algorithm iterations
for it in range(numIter):
    # Compute the A matrix    
    for i in range(1,n+1):
        A[:,i] = (x**i).T   
    # Compute the b matrix
    for i in range(n+2): c[i] = f(x[i])

    # Solve the system
    p = np.dot( np.linalg.inv(A), c )

    # Recompute the x point vector
    pol = np.poly1d(np.reshape(np.flipud(p[0:n+1]).T, (n+1)))
    diff = abs(pol(t) - f(t))

    extremaIndices = argrelmax(abs(diff), axis=0, mode='wrap')[0]
    if len(extremaIndices) < (n+2) : 
        extremaIndices = np.resize(extremaIndices, (1,n+2))
        if abs(diff[t[len(t)-1]]) > abs(diff[t[len(t)-2]]):
            extremaIndices[0,n+1] = len(t)-1
        else:
            extremaIndices = np.roll(extremaIndices, 1)
            extremaIndices[0,0] = 0
    
    x = t[extremaIndices].T
    #Prints Progress
    print("Error: ", max(abs(diff)))
    

print("*************************") 
print("Coefficients: ", p[0:n+1].T)
print("Error: ", max(abs(diff)))
#print(extremaIndices)
plt.figure(1)
plt.plot(t, pol(t), t, f(t))

plt.figure(2)
plt.plot(t, diff)
plt.show()
    
    

