import numpy as np
import matplotlib.pyplot as plt
import time
import LSTMlayer

np.random.seed(int(time.time()%100))

# compute sigmoid nonlinearity
def sigmoid(x):
    output = 1/(1+np.exp(-x))
    return output

# convert output of sigmoid function to its derivative
def sigmoid_output_to_derivative(output):
    return output*(1-output)

def sigmoidPrime(output):
    return output*(1-output)

def tanhPrime(output):
    return (1-output**2)

# training dataset generation
binary_dim = 8 

largest_number = pow(2,binary_dim)

# input variables
pert = 0.0015
alpha = 0.05
wmax  = 7
input_dim = 2
hidden_dim = 5
output_dim = 1
maxIter    = 100000
# initialize neural network weights
lstmLayer1 = LSTMlayer.LSTMlayer(input_dim, hidden_dim, output_dim, alpha, 'SPSA', pert, wmax, binary_dim)
plt.axis([0, maxIter, 0, 500000*4])
plt.ion()
plt.show()

total_error = 0

# training logic
for j in range(maxIter):
    
    # generate a simple addition problem (a + b = c)
    a_int = np.random.randint(largest_number/2) # int version
    a = np.binary_repr(a_int, width=binary_dim) # binary encoding

    b_int = np.random.randint(largest_number/2) # int version
    b = np.binary_repr(b_int, width=binary_dim) # binary encoding

    # true answer
    c_int = a_int + b_int
    c = np.binary_repr(c_int, width=binary_dim) 
    
    overallError = 0
    
    d = list()

    """
    # Build the input vector for this training epoch
    X = np.array([ [int(a[i]) for i in range(binary_dim)], [int(b[i]) for i in range(binary_dim)] ])
    y = np.array([ [int(c[i]) for i in range(binary_dim)] ])
    
    # Train the network for one epoch, and fetch the prediction output
    y_pred = lstmLayer1.trainNetwork_SPSA(X, y)
 
    # decode estimate so we can print it out
    overallError += np.sum(np.abs(y - np.round(y_pred).T))
    total_error += overallError
    """
    # -------------- THE FORWARD PROPAGATION STEP -------------- #
    for position in range(binary_dim):
        
        # generate input and output
        X = np.array([[int(a[binary_dim - position - 1]), int(b[binary_dim - position - 1])]]).T
        y = np.array([int(c[binary_dim - position - 1])]).T

        # Perform a forward propagation through the network
        y_pred = lstmLayer1.trainNetwork_SPSA(X, y)
        
        # decode estimate so we can print it out
        d.append(str(int(np.round(y_pred))))
        overallError += np.abs(y - np.round(y_pred))
        total_error += overallError
        lstmLayer1.resetNetwork()

    # print out progress
    if(j % 200 == 0):
        res = str()
        for i in reversed(range(len(d))):
            res += str(d[i])

        print("Error:" + str(overallError))
        print("Error Increase:" + str(total_error))
        print("Pred:" + res)
        print("True:" + str(c))
        #print(a, "+", b, "=", c)
        print("Iteration:" + str(j))
        #print(str(a_int) + " + " + str(b_int) + " = " + res )
        print("------------")
        plt.scatter(j, total_error, linestyle='-.')
        plt.draw()
        prev_total_error = total_error
