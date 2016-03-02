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
binary_dim = 32 

largest_number = pow(2,binary_dim)

# input variables
pert = 0.015
alpha = 0.02
wmax  = 2
input_dim = 2
hidden_dim = 18 
output_dim = 1

# initialize neural network weights
y_prev = np.zeros((hidden_dim,binary_dim))
lstmLayer1 = LSTMlayer.LSTMlayer(input_dim, hidden_dim, output_dim, alpha, 'SPSA', pert, wmax, 1)
plt.axis([0, 30000, 0, 1000000])
plt.ion()
plt.show()

total_error = 0
prev_total_error = 0
synapse_1_update = 0
layer_2 = np.ndarray((1,1))

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
    
    layer_2_deltas = np.zeros((hidden_dim,binary_dim))
    layer_1_values = list()
    layer_1_values.append(np.zeros(hidden_dim))


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
    
    # print out progress
    if(j % 50 == 0):
        res = str()
        for i in reversed(range(len(d))):
            res += str(d[i])

        print("Error:" + str(overallError))
        print("Error Increase:" + str(total_error))
        print("Pred:" + res)
        print("True:" + str(c))
        print("Iteration:" + str(j))
        #print(str(a_int) + " + " + str(b_int) + " = " + res )
        print("------------")
        plt.scatter(j, total_error, linestyle='-.')
        plt.draw()
        prev_total_error = total_error
