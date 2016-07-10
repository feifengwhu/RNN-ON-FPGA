# -*- coding: utf-8 -*-
"""
LSTM Layer Class
@author: José Pedro Castro Fonseca, University of Porto, PORTUGAL
"""
import numpy as np
import time
import pickle

# Defines the seed for random() as the current time in seconds
np.random.seed(round(time.time()))

# Evaluates the Sigmoid Function
def sigmoid(x):
    output = 1/(1+np.exp(-x))
    return output

# Evaluates the derivative of the Sigmoid Func, based on a previous sigmoid() call
def sigmoidPrime(output):
    return output*(1-output)

# Evaluates the derivative of the TanH Func, based on a previous np.tanh() call
def tanhPrime(output):
    return (1-output**2)

def relu(x):
    return np.amax(np.concatenate((np.zeros_like(x), x), axis=1), axis=1, keepdims=True)


class LSTMlayer :

    def __init__(self, inputUnits, hiddenUnits, outputUnits, learnRate, learnMethod, beta, wmax, T):
        # The Network Parameters, passed by the user
        self.inputUnits  = inputUnits
        self.hiddenUnits = hiddenUnits
        self.learnRate   = learnRate
        self.learnMethod = learnMethod
        self.beta        = beta
        self.T           = T
        self.t           = 0
        self.wmax        = wmax

        # Initializing the matrix weights
        #LSTM Block
        self.Wz = np.random.random((hiddenUnits, inputUnits)) + 0.5
        self.Wi = np.random.random((hiddenUnits, inputUnits)) + 0.5
        self.Wf = np.random.random((hiddenUnits, inputUnits)) + 0.5
        self.Wo = np.random.random((hiddenUnits, inputUnits)) + 0.5

        self.Rz = np.random.random((hiddenUnits, hiddenUnits))+ 0.5
        self.Ri = np.random.random((hiddenUnits, hiddenUnits))+ 0.5
        self.Rf = np.random.random((hiddenUnits, hiddenUnits))+ 0.5
        self.Ro = np.random.random((hiddenUnits, hiddenUnits))+ 0.5

        self.pi = np.random.random((hiddenUnits, 1))- 0.5
        self.pf = np.random.random((hiddenUnits, 1))- 0.5
        self.po = np.random.random((hiddenUnits, 1))- 0.5

        self.bz = np.random.random((hiddenUnits, 1))+0.5
        self.bi = np.random.random((hiddenUnits, 1))+0.5
        self.bo = np.random.random((hiddenUnits, 1))+0.5
        self.bf = np.random.random((hiddenUnits, 1))+0.5

        # Updates
        self.Wz_update = np.zeros_like(self.Wz)
        self.Wi_update = np.zeros_like(self.Wi)
        self.Wf_update = np.zeros_like(self.Wf)
        self.Wo_update = np.zeros_like(self.Wo)

        self.Rz_update = np.zeros_like(self.Rz)
        self.Ri_update = np.zeros_like(self.Ri)
        self.Rf_update = np.zeros_like(self.Rf)
        self.Ro_update = np.zeros_like(self.Ro)

        self.po_update = np.zeros_like(self.po)
        self.pf_update = np.zeros_like(self.pf)
        self.pi_update = np.zeros_like(self.pi)

        self.bz_update = np.zeros_like(self.bz)
        self.bi_update = np.zeros_like(self.bi)
        self.bf_update = np.zeros_like(self.bf)
        self.bo_update = np.zeros_like(self.bo)

        # State vars
        if (self.learnMethod == 'BPTT'):
            self.y_prev = np.zeros((hiddenUnits,self.T))
            self.x_prev = np.zeros((inputUnits,self.T))
            self.o_prev = np.zeros((hiddenUnits,self.T))
            self.f_prev = np.zeros((hiddenUnits,self.T))
            self.c_prev = np.zeros((hiddenUnits,self.T))
            self.z_prev = np.zeros((hiddenUnits,self.T))
            self.i_prev = np.zeros((hiddenUnits,self.T))

            self.future_y = np.zeros_like(self.y_prev[:,1])
            self.future_c = np.zeros_like(self.c_prev[:,1])


            self.delta_y_list = np.zeros((hiddenUnits,self.T))
            self.delta_o_list = np.zeros((hiddenUnits,self.T))
            self.delta_c_list = np.zeros((hiddenUnits,self.T))
            self.delta_f_list = np.zeros((hiddenUnits,self.T))
            self.delta_i_list = np.zeros((hiddenUnits,self.T))
            self.delta_z_list = np.zeros((hiddenUnits,self.T))

            # Delta vectors for a previous layer
            self.delta_x = np.zeros((inputUnits,self.T))

        elif (self.learnMethod == 'SPSA'):
            # The LSTM variables
            self.y = np.zeros((hiddenUnits,1))
            self.x = np.zeros((inputUnits,1))
            self.o = np.zeros((hiddenUnits,1))
            self.f = np.zeros((hiddenUnits,1))
            self.c = np.zeros((hiddenUnits,1))
            self.z = np.zeros((hiddenUnits,1))
            self.i = np.zeros((hiddenUnits,1))
            self.prev_y = np.zeros((hiddenUnits,1))
            self.prev_c = np.zeros((hiddenUnits,1))
            self.prev_y_p = np.zeros((hiddenUnits,1))
            self.prev_c_p = np.zeros((hiddenUnits,1))

            f = open("layer.pickle", "rb")
            lC = pickle.load(f)

            # The MLP Variables and Weights
            self.activOut = np.random.random((outputUnits,1)) - 0.5
            self.outW = lC.outW #np.random.random((outputUnits, hiddenUnits)) - 0.5
            self.deltaO   = np.random.random((outputUnits,1)) - 0.5
            self.deltaH   = np.random.random((hiddenUnits,1)) - 0.5
            self.returnVal = np.zeros((self.T,1))

            # The perturbation weights
            self.Wz_p = np.random.random((hiddenUnits, inputUnits)) - 0.5
            self.Wi_p = np.random.random((hiddenUnits, inputUnits)) - 0.5
            self.Wf_p = np.random.random((hiddenUnits, inputUnits)) - 0.5
            self.Wo_p = np.random.random((hiddenUnits, inputUnits)) - 0.5

            self.Rz_p = np.random.random((hiddenUnits, hiddenUnits)) - 0.5
            self.Ri_p = np.random.random((hiddenUnits, hiddenUnits)) - 0.5
            self.Rf_p = np.random.random((hiddenUnits, hiddenUnits))  - 0.5
            self.Ro_p = np.random.random((hiddenUnits, hiddenUnits))  - 0.5

            self.pi_p = np.random.random((hiddenUnits, 1)) - 0.5
            self.pf_p = np.random.random((hiddenUnits, 1)) - 0.5
            self.po_p = np.random.random((hiddenUnits, 1)) - 0.5

            self.bz_p =  np.random.random((hiddenUnits, 1)) - 0.5
            self.bi_p =  np.random.random((hiddenUnits, 1)) - 0.5
            self.bo_p =  np.random.random((hiddenUnits, 1)) - 0.5
            self.bf_p =  np.random.random((hiddenUnits, 1)) - 0.5

            self.outW_p = lC.outW #np.random.random((outputUnits, hiddenUnits)) - 0.5
            self.outW_update = np.random.random((outputUnits, hiddenUnits)) - 0.5

    def forwardPropagate(self, X):
        #The LM layers
        self.z = np.tanh( np.dot(self.Wz, X) + np.dot(self.Rz, self.prev_y) + self.bz)
        self.i = sigmoid( np.dot(self.Wi,X) + np.dot(self.Ri,self.prev_y) + self.bi )
        self.f = sigmoid( np.dot(self.Wf,X) + np.dot(self.Rf,self.prev_y) + self.bf )
        self.c = np.multiply(self.z, self.i) + np.multiply(self.prev_c, self.f)
        self.o = sigmoid( np.dot(self.Wo,X) + np.dot(self.Ro,self.prev_y) + self.bo )
        self.y = np.multiply(np.tanh(self.c), self.o)

        #The Perceptron Layer
        self.activOut = np.dot(self.outW, self.y)

        #The total layer output
        return sigmoid(self.activOut)

    def forwardPropagate_SPSA(self, X):
        #The LM layers
        self.z = np.tanh( np.dot(self.Wz_p,X) + np.dot(self.Rz_p, self.prev_y) + self.bz_p )
        self.i = sigmoid( np.dot(self.Wi_p,X) + np.dot(self.Ri_p, self.prev_y) + self.bi_p )
        self.f = sigmoid( np.dot(self.Wf_p,X) + np.dot(self.Rf_p,self.prev_y) + self.bf_p )
        self.c_p = np.multiply(self.z, self.i) + np.multiply(self.prev_c, self.f)
        self.o = sigmoid( np.dot(self.Wo_p,X) + np.dot(self.Ro_p,self.prev_y) + self.bo_p )
        self.y_p = np.multiply(np.tanh(self.c_p), self.o)

        #The Perceptron Layer
        self.activOut = np.dot(self.outW_p, self.y_p)

        self.prev_c = self.c
        self.prev_y = self.y

        #The total layer output
        return sigmoid(self.activOut)

    def resetNetwork(self):

        self.prev_c = np.zeros_like(self.c)
        self.prev_y = np.zeros_like(self.y)

    def trainNetwork_SPSA(self, X, target):


        # Performing the weight perturbations
        self.Wz_update = self.beta*np.sign(np.random.random(np.shape(self.Wz)) - 0.5)
        self.Wi_update = self.beta*np.sign(np.random.random(np.shape(self.Wi)) - 0.5)
        self.Wf_update = self.beta*np.sign(np.random.random(np.shape(self.Wf)) - 0.5)
        self.Wo_update = self.beta*np.sign(np.random.random(np.shape(self.Wo)) - 0.5)

        self.Wz_p = self.Wz + self.Wz_update
        self.Wi_p = self.Wi + self.Wi_update
        self.Wf_p = self.Wf + self.Wf_update
        self.Wo_p = self.Wo + self.Wo_update
        #print("Wz: ", self.Wz, "update: ", self.Wz_update, "Wz_p:", self.Wz_p)
        self.Rz_update = self.beta*np.sign(np.random.random(np.shape(self.Rz)) - 0.5)
        self.Ri_update = self.beta*np.sign(np.random.random(np.shape(self.Ri)) - 0.5)
        self.Rf_update = self.beta*np.sign(np.random.random(np.shape(self.Rf)) - 0.5)
        self.Ro_update = self.beta*np.sign(np.random.random(np.shape(self.Ro)) - 0.5)

        self.Rz_p = self.Rz + self.Rz_update
        self.Ri_p = self.Ri + self.Ri_update
        self.Rf_p = self.Rf + self.Rf_update
        self.Ro_p = self.Ro + self.Ro_update
        """
        self.pi_update = self.beta*np.sign(np.random.random(np.shape(self.pi)) - 0.5)
        self.pf_update = self.beta*np.sign(np.random.random(np.shape(self.pf)) - 0.5)
        self.po_update = self.beta*np.sign(np.random.random(np.shape(self.po)) - 0.5)

        self.pi_p = self.pi + self.pi_update
        self.pf_p = self.pf + self.pf_update
        self.po_p = self.po + self.po_update
        """
        self.bz_update = self.beta*np.sign(np.random.random(np.shape(self.bi)) - 0.5)
        self.bi_update = self.beta*np.sign(np.random.random(np.shape(self.bi)) - 0.5)
        self.bo_update = self.beta*np.sign(np.random.random(np.shape(self.bo)) - 0.5)
        self.bf_update = self.beta*np.sign(np.random.random(np.shape(self.bf)) - 0.5)

        self.bz_p = self.bz + self.bz_update
        self.bi_p = self.bi + self.bi_update
        self.bo_p = self.bo + self.bo_update
        self.bf_p = self.bf + self.bf_update

        """
        self.outW_update = self.beta*np.sign(np.random.random(np.shape(self.outW)) - 0.5)
        self.outW_p = self.outW + self.outW_update
        """

        # Forward Propagation, WITHOUT weight perturbation. J is the cost function
        self.returnVal = self.forwardPropagate(X)
        J = (self.returnVal - target)**2

        # Forward Propagation, WITH weight perturbation
        Jpert = (self.forwardPropagate_SPSA(X) - target)**2

        # The Cost Function evaluation for this perturbation
        cost = float(np.sum(Jpert-J))
        #print("Cost: ", J, "PertCost:", Jpert, "Diff: ", cost, "DiffUp: ", cost*self.learnRate/self.beta)
        #print("Before: ", self.Wz.item(0,0))
        # ****TRAINING**** The LSTM Layer
        #print("Gradient Check: ", np.divide(cost, self.Wz_update))
        for i in range(self.Wz.shape[0]):
            for j in range(self.Wz.shape[1]):
                if (self.Wz.item(i,j) - self.learnRate*(cost/ self.Wz_update.item(i,j)) > self.wmax):
                    self.Wz.itemset((i,j), self.wmax)
                elif (self.Wz.item(i,j) - self.learnRate*(cost/ self.Wz_update.item(i,j)) < -self.wmax):
                    self.Wz.itemset((i,j), -self.wmax)
                else :
                    self.Wz.itemset((i,j), self.Wz.item(i,j) - self.learnRate*(cost/ self.Wz_update.item(i,j)))

                if (self.Wi.item(i,j) - self.learnRate*(cost/ self.Wi_update.item(i,j)) > self.wmax):
                    self.Wi.itemset((i,j), self.wmax)
                elif (self.Wi.item(i,j) - self.learnRate*(cost/ self.Wi_update.item(i,j)) < -self.wmax):
                    self.Wi.itemset((i,j), -self.wmax)
                else :
                    self.Wi.itemset((i,j), self.Wi.item(i,j) - self.learnRate*(cost/ self.Wi_update.item(i,j)))

                if (self.Wf.item(i,j) - self.learnRate*(cost/ self.Wf_update.item(i,j)) > self.wmax):
                    self.Wf.itemset((i,j), self.wmax)
                elif (self.Wf.item(i,j) - self.learnRate*(cost/ self.Wf_update.item(i,j)) < -self.wmax):
                    self.Wf.itemset((i,j), -self.wmax)
                else :
                    self.Wf.itemset((i,j), self.Wf.item(i,j) - self.learnRate*(cost/ self.Wf_update.item(i,j)))

                if (self.Wo.item(i,j) - self.learnRate*(cost/ self.Wo_update.item(i,j)) > self.wmax):
                    self.Wo.itemset((i,j), self.wmax)
                elif (self.Wo.item(i,j) - self.learnRate*(cost/ self.Wo_update.item(i,j)) < -self.wmax):
                    self.Wo.itemset((i,j), -self.wmax)
                else :
                    self.Wo.itemset((i,j), self.Wo.item(i,j) - self.learnRate*(cost/ self.Wo_update.item(i,j)))

        for i in range(self.Rz.shape[0]):
            for j in range(self.Rz.shape[1]):
                if (self.Rz.item(i,j) - self.learnRate*(cost/ self.Rz_update.item(i,j)) > self.wmax):
                    self.Rz.itemset((i,j), self.wmax)
                elif (self.Rz.item(i,j) - self.learnRate*(cost/ self.Rz_update.item(i,j)) < -self.wmax):
                    self.Rz.itemset((i,j), -self.wmax)
                else :
                    self.Rz.itemset((i,j), self.Rz.item(i,j) - self.learnRate*(cost/ self.Rz_update.item(i,j)))

                if (self.Ri.item(i,j) - self.learnRate*(cost/ self.Ri_update.item(i,j)) > self.wmax):
                    self.Ri.itemset((i,j), self.wmax)
                elif (self.Ri.item(i,j) - self.learnRate*(cost/ self.Ri_update.item(i,j)) < -self.wmax):
                    self.Ri.itemset((i,j), -self.wmax)
                else :
                    self.Ri.itemset((i,j), self.Ri.item(i,j) - self.learnRate*(cost/ self.Ri_update.item(i,j)))

                if (self.Rf.item(i,j) - self.learnRate*(cost/ self.Rf_update.item(i,j)) > self.wmax):
                    self.Rf.itemset((i,j), self.wmax)
                elif (self.Rf.item(i,j) - self.learnRate*(cost/ self.Rf_update.item(i,j)) < -self.wmax):
                    self.Rf.itemset((i,j), -self.wmax)
                else :
                    self.Rf.itemset((i,j), self.Rf.item(i,j) - self.learnRate*(cost/ self.Rf_update.item(i,j)))

                if (self.Ro.item(i,j) - self.learnRate*(cost/ self.Ro_update.item(i,j)) > self.wmax):
                    self.Ro.itemset((i,j), self.wmax)
                elif (self.Ro.item(i,j) - self.learnRate*(cost/ self.Ro_update.item(i,j)) < -self.wmax):
                    self.Ro.itemset((i,j), -self.wmax)
                else :
                    self.Ro.itemset((i,j), self.Ro.item(i,j) - self.learnRate*(cost/ self.Ro_update.item(i,j)))

        for i in range(self.bz.shape[0]):
            if (self.bz.item(i) - self.learnRate*(cost/ self.bz_update.item(i)) > self.wmax):
                self.bz.itemset(i, self.wmax)
            elif (self.bz.item(i) - self.learnRate*(cost/ self.bz_update.item(i)) < -self.wmax):
                self.bz.itemset(i, -self.wmax)
            else :
                self.bz.itemset(i,self.bz.item(i) - self.learnRate*(cost/ self.bz_update.item(i)))

            if (self.bi.item(i) - self.learnRate*(cost/ self.bi_update.item(i)) > self.wmax):
                self.bi.itemset(i, self.wmax)
            elif (self.bi.item(i) - self.learnRate*(cost/ self.bi_update.item(i)) < -self.wmax):
                self.bi.itemset(i, -self.wmax)
            else :
                self.bi.itemset(i,self.bi.item(i) - self.learnRate*(cost/ self.bi_update.item(i)))

            if (self.bf.item(i) - self.learnRate*(cost/ self.bf_update.item(i)) > self.wmax):
                self.bf.itemset(i, self.wmax)
            elif (self.bf.item(i) - self.learnRate*(cost/ self.bf_update.item(i)) < -self.wmax):
                self.bf.itemset(i, -self.wmax)
            else :
                self.bf.itemset(i,self.bf.item(i) - self.learnRate*(cost/ self.bf_update.item(i)))

            if (self.bo.item(i) - self.learnRate*(cost/ self.bo_update.item(i)) > self.wmax):
                self.bo.itemset(i, self.wmax)
            elif (self.bo.item(i) - self.learnRate*(cost/ self.bo_update.item(i)) < -self.wmax):
                self.bo.itemset(i, -self.wmax)
            else :
                self.bo.itemset(i,self.bo.item(i) - self.learnRate*(cost/ self.bo_update.item(i)))

        #print("After: ",self.Wz.item(0,0))
        # ****TRAINING**** The Perceptron Layer
        """
        for i in range(self.outW.shape[0]):
            for j in range(self.outW.shape[1]):
                if (self.outW[i,j] - self.learnRate*np.divide(cost, self.outW_update[i,j]) > self.wmax) :
                    self.outW[i,j] = self.wmax
                elif (self.outW[i,j] - self.learnRate*np.divide(cost, self.outW_update[i,j]) < -self.wmax) :
                    self.outW[i,j] = -self.wmax
                else :
                    self.outW[i,j] = self.outW[i,j] - self.learnRate*np.divide(cost, self.outW_update[i,j])
        """
        return self.returnVal

    def forwardPropagate_BPTT(self, X):

        # Note that in a list, accessing [-1] corresponds to the last element appended. so y_prev[-1] == y^(t-1)
        if (self.t != 0):
            self.z_prev[:,self.t] = np.tanh( np.dot(self.Wz,X) + np.dot(self.Rz,self.y_prev[:,self.t-1]) + self.bz.T )
            self.i_prev[:,self.t] = sigmoid( np.dot(self.Wi,X) + np.dot(self.Ri,self.y_prev[:,self.t-1]) + np.multiply(self.pi,self.c_prev[:,self.t-1]) + self.bi.T )
            self.f_prev[:,self.t] = sigmoid( np.dot(self.Wf,X) + np.dot(self.Rf,self.y_prev[:,self.t-1]) + np.multiply(self.pf,self.c_prev[:,self.t-1]) + self.bf.T )
            self.c_prev[:,self.t] = np.multiply(self.z_prev[:,self.t],self.i_prev[:,self.t]) + np.multiply(self.c_prev[:,self.t-1],self.f_prev[:,self.t])
            self.o_prev[:,self.t] = sigmoid( np.dot(self.Wo,X) + np.dot(self.Ro,self.y_prev[:,self.t-1]) + np.multiply(self.po,self.c_prev[:,self.t]) + self.bo.T )
            self.y_prev[:,self.t] = np.multiply(np.tanh(self.c_prev[:,self.t]), self.o_prev[:,self.t])
        else:
            self.z_prev[:,self.t] = np.tanh( np.dot(self.Wz,X) + np.dot(self.Rz,self.future_y) + self.bz.T )
            self.i_prev[:,self.t] = sigmoid( np.dot(self.Wi,X) + np.dot(self.Ri,self.future_y) + self.bi.T )
            self.f_prev[:,self.t] = sigmoid( np.dot(self.Wf,X) + np.dot(self.Rf,self.future_y) + self.bf.T )
            self.c_prev[:,self.t] = np.multiply(self.z_prev[:,self.t],self.i_prev[:,self.t]) + np.multiply(self.future_c,self.f_prev[:,self.t])
            self.o_prev[:,self.t] = sigmoid( np.dot(self.Wo,X) + np.dot(self.Ro,self.future_y) + np.multiply(self.po, self.c_prev[:,self.t]) + self.bo.T )
            self.y_prev[:,self.t] = np.multiply(np.tanh(self.c_prev[:,self.t]), self.o_prev[:,self.t])

        self.x_prev[:,self.t] = X

        if (self.t == self.T-1) :
            self.future_y = self.y_prev[:,self.t]  # Saving the state of these variables between iterations, otherwise y_prev will be zero!
            self.future_c = self.c_prev[:,self.t]
            self.t = 0                             # Reset the time pointer within time frame
            return self.y_prev[:,self.T-1]
        else:
            self.t += 1
            return self.y_prev[:,self.t-1]

    def backPropagate_BPTT(self, upperLayerDeltas):
        # EVALUATING THE DELTAS
        for t in reversed(range(self.T)):
            if (t == self.T-1):
                self.delta_y_list[:,t] = (upperLayerDeltas[:,t])
                self.delta_o_list[:,t] = (np.multiply( np.multiply(upperLayerDeltas[:,t],np.tanh(self.c_prev[:,t])), sigmoidPrime(self.o_prev[:,t])))
                self.delta_c_list[:,t] = (np.multiply(np.multiply(self.delta_y_list[:,t],tanhPrime(np.tanh(self.c_prev[:,t]))), self.o_prev[:,t]))
            else:
                self.delta_y_list[:,t] = (upperLayerDeltas[:,t] + np.dot(self.Rz,self.delta_z_list[:,t+1]) + np.dot(self.Ri,self.delta_i_list[:,t+1]) + np.dot(self.Rf,self.delta_f_list[:,t+1]) + np.dot(self.Ro,self.delta_o_list[:,t+1]))
                self.delta_o_list[:,t] = (np.multiply( np.multiply(upperLayerDeltas[:,t],np.tanh(self.c_prev[:,t])), sigmoidPrime(self.o_prev[:,t])))
                self.delta_c_list[:,t] = (np.multiply(np.multiply(self.delta_y_list[:,t],tanhPrime(np.tanh(self.c_prev[:,t]))), self.o_prev[:,t]) + np.multiply(self.delta_c_list[:,t+1],self.f_prev[:,t+1]))

            if (t != 0) :
                self.delta_f_list[:,t] = (np.multiply(np.multiply(self.delta_c_list[:,t],self.c_prev[:,t-1]), sigmoidPrime(self.f_prev[:,t])))

            self.delta_i_list[:,t] = (np.multiply( np.multiply(self.delta_c_list[:,t],self.z_prev[:,t]), sigmoidPrime(self.i_prev[:,t])))
            self.delta_z_list[:,t] = (np.multiply( np.multiply(self.delta_c_list[:,t],self.i_prev[:,t]), tanhPrime(self.z_prev[:,t])))
            self.delta_x[:,t] = np.dot(self.Wz.T,self.delta_z_list[:,t]) + np.dot(self.Wi.T,self.delta_i_list[:,t]) + np.dot(self.Wf.T,self.delta_f_list[:,t]) + np.dot(self.Wo.T,self.delta_o_list[:,t])

        # EVALUATING THE UPDATES
        for t in range(self.T):
            self.Wz += self.learnRate * np.outer(self.delta_z_list[:,t],self.x_prev[:,t])
            self.Wi += self.learnRate * np.outer(self.delta_i_list[:,t],self.x_prev[:,t])
            self.Wf += self.learnRate * np.outer(self.delta_f_list[:,t],self.x_prev[:,t])
            self.Wo += self.learnRate * np.outer(self.delta_o_list[:,t],self.x_prev[:,t])
            self.po += self.learnRate * np.multiply(self.c_prev[:,t],self.delta_o_list[:,t])
            self.bz += self.learnRate * self.delta_z_list[:,t]
            self.bi += self.learnRate * self.delta_i_list[:,t]
            self.bf += self.learnRate * self.delta_f_list[:,t]
            self.bo += self.learnRate * self.delta_o_list[:,t]

            if(t < self.T-1):
                self.Rz += self.learnRate * np.outer(self.delta_z_list[:,t+1],self.y_prev[:,t])
                self.Ri += self.learnRate * np.outer(self.delta_i_list[:,t+1],self.y_prev[:,t])
                self.Rf += self.learnRate * np.outer(self.delta_f_list[:,t+1],self.y_prev[:,t])
                self.Ro += self.learnRate * np.outer(self.delta_o_list[:,t+1],self.y_prev[:,t])
                self.pi += self.learnRate * np.multiply(self.c_prev[:,t],self.delta_i_list[:,t+1])
                self.pf += self.learnRate * np.multiply(self.c_prev[:,t],self.delta_f_list[:,t+1])

        return  self.delta_x
