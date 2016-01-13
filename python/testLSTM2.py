import numpy as np
import matplotlib.pyplot as plt
import time
import LSTMlayer

np.random.seed(5)

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
int2binary = {}
binary_dim = 8 

largest_number = pow(2,binary_dim)

# input variables
alpha = 0.1
input_dim = 2
hidden_dim = 4 
output_dim = 1

# initialize neural network weights
synapse_1        = 2*np.random.random(hidden_dim) - 1
synapse_1_update = 2*np.random.random(hidden_dim) - 1
y_prev = np.zeros((hidden_dim,binary_dim))
lstmLayer1 = LSTMlayer.LSTMlayer(input_dim, hidden_dim, alpha, binary_dim)
lstmLayerOut = LSTMlayer.LSTMlayer(hidden_dim, output_dim, alpha+0.05, binary_dim)
plt.axis([0, 30000, 0, 200000])
plt.ion()
plt.show()

total_error = 0
prev_total_error = 0
synapse_1_update = 0
layer_2 = np.ndarray((1,1))
layer_2_errors = np.ndarray((1, binary_dim))

# training logic
for j in range(100000):
    
    # generate a simple addition problem (a + b = c)
    a_int = np.random.randint(largest_number/2) # int version
    a = np.binary_repr(a_int, width=binary_dim)# binary encoding

    b_int = np.random.randint(largest_number/2) # int version
    b = np.binary_repr(b_int, width=binary_dim) # binary encoding

    # true answer
    c_int = a_int + b_int
    c = np.binary_repr(c_int, width=binary_dim) 
    
    # where we'll store our best guess (binary encoded)
    d = list()

    overallError = 0
    
    # -------------- THE FORWARD PROPAGATION STEP -------------- #
    for position in range(binary_dim):
        
        # generate input and output
        X = np.array([int(a[binary_dim - position - 1]), int(b[binary_dim - position - 1])]).T
        y = np.array([int(c[binary_dim - position - 1])]).T

        # Perform a forward propagation through the network
        tempIntermediateLayer = lstmLayer1.forwardPropagate(X)
        y_network   = lstmLayerOut.forwardPropagate(tempIntermediateLayer)
        
        # did we miss?... if so, by how much?
        layer_2_errors[:,position] = (y[0] - y_network)
    
        # decode estimate so we can print it out
        d.append(str(int(np.round(y_network))))
        overallError += np.abs(y - np.round(y_network))
        total_error += overallError
        
    future_layer_1_delta = np.zeros(hidden_dim)

    # -------------- THE BACKPROPAGATION STEP -------------- #
    
    # FOR THE LSTM LAYER
    delta_out_layer = lstmLayerOut.backPropagate_T(layer_2_errors)
    lstmLayer1.backPropagate_T(delta_out_layer)
    
    # print out progress
    if(j % 200 == 0):
        res = str()
        for i in reversed(range(len(d))):
            res += str(d[i])

        print("Error:" + str(overallError))
        print("Error Increase:" + str(total_error))
        print("Pred:" + res)
        print("True:" + str(c))
        print("Iteration:" + str(j))
        print(str(a_int) + " + " + str(b_int) + " = " + res )
        print("------------")
        plt.scatter(j, total_error, linestyle='-.')
        plt.draw()
        prev_total_error = total_error
