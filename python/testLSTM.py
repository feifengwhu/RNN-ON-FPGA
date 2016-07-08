import numpy as np
import matplotlib.pyplot as plt
import time
import sys
import pickle
import LSTMlayer

np.random.seed(round(time.time()))

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

# Simulation Parameters
pert  = float(sys.argv[1])
alpha = float(sys.argv[2])
wmax  = float(sys.argv[3])
samplesPerEpoch = 500
input_dim  = 2
hidden_dim = int(sys.argv[4])
output_dim = 1
maxEpoch   = 100 
trainSamp  = 5000
testSamp   = 100

# initialize neural network weights
lstmLayer1 = LSTMlayer.LSTMlayer(input_dim, hidden_dim, output_dim, alpha, 'SPSA', pert, wmax, binary_dim)
plt.axis([0, maxEpoch, 0, binary_dim])
plt.title("Alpha={0} -- Perturbation={1} -- Wmax={2}".format(alpha, pert, wmax))
plt.ion()
plt.show()

epochError = 0
correct    = 0
# training logic
for i in range(maxEpoch):
   
    print("Training Epoch: ", i)

    for j in range(trainSamp):
        # generate a simple addition problem (a + b = c)
        a_int = np.random.randint(largest_number/2) # int version
        a = np.binary_repr(a_int, width=binary_dim) # binary encoding

        b_int = np.random.randint(largest_number/2) # int version
        b = np.binary_repr(b_int, width=binary_dim) # binary encoding

        # true answer
        c_int = a_int + b_int
        c = np.binary_repr(c_int, width=binary_dim) 

        # -------------- THE FORWARD PROPAGATION STEP -------------- #
        for position in range(binary_dim):
            
            # generate input and output
            X = np.array([[int(a[binary_dim - position - 1]), int(b[binary_dim - position - 1])]]).T
            y = np.array([int(c[binary_dim - position - 1])]).T

            # Perform a forward propagation through the network
            y_pred = lstmLayer1.trainNetwork_SPSA(X, y)

        lstmLayer1.resetNetwork()    

    for j in range(testSamp):
        # generate a simple addition problem (a + b = c)
        a_int = np.random.randint(largest_number/2) # int version
        a = np.binary_repr(a_int, width=binary_dim) # binary encoding

        b_int = np.random.randint(largest_number/2) # int version
        b = np.binary_repr(b_int, width=binary_dim) # binary encoding

        # true answer
        c_int = a_int + b_int
        c = np.binary_repr(c_int, width=binary_dim) 

        # -------------- THE FORWARD PROPAGATION STEP -------------- #
        for position in range(binary_dim):
            
            # generate input and output
            X = np.array([[int(a[binary_dim - position - 1]), int(b[binary_dim - position - 1])]]).T
            y = np.array([int(c[binary_dim - position - 1])]).T

            # Perform a forward propagation through the network
            y_pred = lstmLayer1.forwardPropagate(X)
            lstmLayer1.prev_c = lstmLayer1.c            
            lstmLayer1.prev_y = lstmLayer1.y           

            # decode estimate so we can print it out
            epochError += int(np.abs(y - np.round(y_pred)))

        lstmLayer1.resetNetwork()    

    if (epochError/testSamp  == 0):
        correct += 1
        if(correct == 2):
            print("Convergence Acheived in {0} epochs".format(i-2))
            break
    else:
        correct = 0 
    
    
    print("Average Error:", epochError/testSamp)
    print("Weight: ", lstmLayer1.Wz.item(0,0))
    #plt.scatter(i, epochError/testSamp, linestyle='-.')
    #plt.draw()
    epochError = 0

with open('objs.pickle', 'wb') as f:
    pickle.dump([lstmLayer1.Wz, lstmLayer1.Wi, lstmLayer1.Wf, lstmLayer1.Wo, lstmLayer1.Rz, lstmLayer1.Ri, lstmLayer1.Rf, lstmLayer1.Ro, lstmLayer1.bz, lstmLayer1.bi, lstmLayer1.bf, lstmLayer1.bo,], f)

with open('layer.pickle', 'wb') as f:
    pickle.dump(lstmLayer1, f)

print("Epochs: {0}".format(i+1))
wait = input("PRESS ENTER TO CONTINUE.")
