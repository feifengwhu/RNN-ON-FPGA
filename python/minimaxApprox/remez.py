import numpy as np

# The target approximation function
def f(x):
    return 1/(1+np.exp(-x))

# Nber of iterations
numIter = 10

# Approximation Interval
b = 4
a = -b

# Polynomial Degree
n = 3

# Initial set of points
x = np.array([(a+b)/2+(b-a)/2*np.cos(i*np.pi/(n+1)) for i in reversed(range(n+2))])

# The numerical matrices
A = np.zeros((n+2, n+2))
A[:,0] = 1
for i in range(n+2): A[i,n+1] = (-1)**(i+1)

b = np.zeros((n+2,1))
for i in range(n+2): b[i] = f(x[i])

# The algorithm iterations
for it in range(numIter):
    # Compute the A matrix    
    
