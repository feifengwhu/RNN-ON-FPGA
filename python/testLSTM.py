# -*- coding: utf-8 -*-
"""
LSTM Layer Class
@author: José Pedro Castro Fonseca, University of Porto, PORTUGAL
"""
import numpy as np
import time

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

class LSTMlayer :

    def __init__(self, inputUnits, hiddenUnits, learnRate, T):
        # The Network Parameters, passed by the user
        self.inputUnits  = inputUnits
        self.hiddenUnits = hiddenUnits
        self.learnRate   = learnRate
        self.T           = T
        self.t           = 0

        # Initializing the matrix weights
        #LSTM Block
        self.Wz = np.random.random((hiddenUnits, inputUnits)) - 0.5
        self.Wi = np.random.random((hiddenUnits, inputUnits)) - 0.5
        self.Wf = np.random.random((hiddenUnits, inputUnits)) - 0.5
        self.Wo = np.random.random((hiddenUnits, inputUnits)) - 0.5
        
        self.Rz = np.random.random((hiddenUnits, hiddenUnits)) - 0.5
        self.Ri = np.random.random((hiddenUnits, hiddenUnits)) - 0.5
        self.Rf = np.random.random((hiddenUnits, hiddenUnits)) - 0.5
        self.Ro = np.random.random((hiddenUnits, hiddenUnits)) - 0.5
        
        self.pi = np.random.random((hiddenUnits)) - 0.5
        self.pf = np.random.random((hiddenUnits)) - 0.5
        self.po = np.random.random((hiddenUnits)) - 0.5
        
        self.bz = np.random.random((hiddenUnits)) - 0.5
        self.bi = np.random.random((hiddenUnits)) - 0.5
        self.bo = np.random.random((hiddenUnits)) - 0.5
        self.bf = np.random.random((hiddenUnits)) - 0.5
        
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
        self.y_prev = np.zeros((hiddenUnits,self.T))
        self.x_prev = np.zeros((inputUnits,self.T))
        self.o_prev = np.zeros((hiddenUnits,self.T))
        self.f_prev = np.zeros((hiddenUnits,self.T))
        self.c_prev = np.zeros((hiddenUnits,self.T))
        self.z_prev = np.zeros((hiddenUnits,self.T))
        self.i_prev = np.zeros((hiddenUnits,self.T))
        
        self.delta_y_list = np.zeros((hiddenUnits,self.T))
        self.delta_o_list = np.zeros((hiddenUnits,self.T))
        self.delta_c_list = np.zeros((hiddenUnits,self.T))
        self.delta_f_list = np.zeros((hiddenUnits,self.T))
        self.delta_i_list = np.zeros((hiddenUnits,self.T))
        self.delta_z_list = np.zeros((hiddenUnits,self.T))
        
        self.future_y = np.zeros_like(self.y_prev[:,1])
        self.future_c = np.zeros_like(self.c_prev[:,1])
    
    def forwardPropagate(self, X):    

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
        
        
        
    def backPropagate_T(self, upperLayerDeltas):
        # EVALUATING THE DELTAS
        for t in reversed(range(self.T)):
            if (t == self.T-1):
                self.delta_y_list[:,t] = (upperLayerDeltas[t])
                self.delta_o_list[:,t] = (np.multiply( np.multiply(upperLayerDeltas[t],np.tanh(self.c_prev[:,t])), sigmoidPrime(self.o_prev[:,t])))
                self.delta_c_list[:,t] = (np.multiply(np.multiply(self.delta_y_list[:,t],tanhPrime(np.tanh(self.c_prev[:,t]))), self.o_prev[:,t]))
            else:
                self.delta_y_list[:,t] = (upperLayerDeltas[t] + np.dot(self.Rz,self.delta_z_list[:,t+1]) + np.dot(self.Ri,self.delta_i_list[:,t+1]) + np.dot(self.Rf,self.delta_f_list[:,t+1]) + np.dot(self.Ro,self.delta_o_list[:,t+1]))
                self.delta_o_list[:,t] = (np.multiply( np.multiply(upperLayerDeltas[t],np.tanh(self.c_prev[:,t])), sigmoidPrime(self.o_prev[:,t])))
                self.delta_c_list[:,t] = (np.multiply(np.multiply(self.delta_y_list[:,t],tanhPrime(np.tanh(self.c_prev[:,t]))), self.o_prev[:,t]) + np.multiply(self.delta_c_list[:,t+1],self.f_prev[:,t+1]))
            
            if (t != 0) :
                self.delta_f_list[:,t] = (np.multiply(np.multiply(self.delta_c_list[:,t],self.c_prev[:,t-1]), sigmoidPrime(self.f_prev[:,t])))
            
            self.delta_i_list[:,t] = (np.multiply( np.multiply(self.delta_c_list[:,t],self.z_prev[:,t]), sigmoidPrime(self.i_prev[:,t])))
            self.delta_z_list[:,t] = (np.multiply( np.multiply(self.delta_c_list[:,t],self.i_prev[:,t]), tanhPrime(self.z_prev[:,t])))
            
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

