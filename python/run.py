from Bio import SeqIO
import numpy as np
import LSTMlayer

AminoAcid_2_index = dict(A=0,C=1, D=2, E=3, F=4, G=5, H=6, I=7, K=8, L=9, M=10, N=11, P=12, Q=13, R=14, S=15, T=16, V=17, W=18, Y=19, X=int(np.random.randint(20)), Z=int(np.random.randint(20)), B=int(np.random.randint(20)) )  

def loadAAsequence(filename):
    i = 0
    j = 0

    maxlen  = 0
    numseqs = 0
    for seq_rec in SeqIO.parse(filename, "fasta"):
        if(len(seq_rec.seq.tostring()) > maxlen) : maxlen =  len(seq_rec.seq.tostring())
        numseqs += 1

    #print(maxlen, numseqs)
    aaMat = np.zeros((20,maxlen+1,numseqs), dtype=np.int)
    
    for seq_rec in SeqIO.parse(filename, "fasta"):
        #print(seq_rec.seq)
        aaMat[:,0,j] = len(seq_rec.seq.tostring())
        for i in range(len(seq_rec.seq.tostring())):
            aaMat[AminoAcid_2_index[seq_rec.seq[i]],i+1,j] = 1
            i += 1
        j += 1
    
    return aaMat

# Simulation Parameters 
windowLen = 0
memCells  = 13
numEpochs = 20
trainPerEpoch = 5

# Loads the Positive Test Set
posTest = loadAAsequence("pos-test.1.27.1.1.fasta")

# Loads the Negative Test Set
negTest = loadAAsequence("neg-test.1.27.1.1.fasta")

# Loads the Positive Train Set
posTrain = loadAAsequence("pos-train.1.27.1.1.fasta")

# Loads the Negative Train Set
negTrain = loadAAsequence("neg-train.1.27.1.1.fasta")

# Prints the simulation parameters
print("Negative TEST  Seqs: ", negTest.shape[2])
print("Positive TEST  Seqs: ", posTest.shape[2])
print("Negative TRAIN Seqs: ", negTrain.shape[2])
print("Positive TRAIN Seqs: ", posTrain.shape[2])


# Builds the LSTM layer object
lstmLayer = LSTMlayer.LSTMlayer(20, memCells, 1, 0.001953125, 'SPSA', 0.0625, 4, 500)

# Trains the network for a specified number of epochs
for testEpoch in range(numEpochs):

    for epoch in range(trainPerEpoch):
        true  = 0
        error = 0
        print("TRAIN Epoch {0}".format(epoch))    
        # Positive Training Patterns
        for seqNum in range(posTrain.shape[2]):
            currSeqLen = posTrain[0,0,seqNum]
            for seqPos in range(1, currSeqLen):
                prediction = lstmLayer.trainNetwork_SPSA(np.reshape(posTrain[:,seqPos,seqNum], (20,1)), 1)
                
            lstmLayer.resetNetwork()
            
            if(prediction > 0.8) : true += 1
            if(prediction < 0.2) : error += 1

        print("True Positive Rate: {0:.4} ".format(true/seqNum))
        print("False Negative Rate: {0:.4} ".format(error/seqNum))
       
        true  = 0
        error = 0
     
        # Negative Training Patterns
        for seqNum in range(negTrain.shape[2]):
            currSeqLen = negTrain[0,0,seqNum]
            for seqPos in range(1, currSeqLen):
                prediction = lstmLayer.trainNetwork_SPSA(np.reshape(negTrain[:,seqPos,seqNum], (20,1)), 0)
            lstmLayer.resetNetwork()

            if(prediction > 0.8) : error += 1
            if(prediction < 0.2) : true  += 1

        print("True Negative Rate: {0:.4} ".format(true/seqNum))
        print("False Positive Rate: {0:.4} ".format(error/seqNum))
    
    true  = 0
    error = 0

    print("TESTING Epoch {0}".format(testEpoch))

    # Test on the datasets
    for seqNum in range(posTest.shape[2]):
        currSeqLen = posTest[0,0,seqNum]

        for seqPos in range(1, currSeqLen):
            prediction = lstmLayer.forwardPropagate(np.reshape(posTest[:,seqPos,seqNum], (20,1)))
            lstmLayer.prev_c = lstmLayer.c
            lstmLayer.prev_y = lstmLayer.y
        
        lstmLayer.resetNetwork()
        print(prediction)
        
        if(prediction > 0.8) : true += 1
        if(prediction < 0.2) : error += 1

        print("True Positive Rate: {0:.4} ".format(true/seqNum))
        print("False Negative Rate: {0:.4} ".format(error/seqNum))

    true  = 0
    error = 0

    # Negative Testing Patterns
    for seqNum in range(negTest.shape[2]):
        currSeqLen = negTest[0,0,seqNum]

        for seqPos in range(1, currSeqLen):
            prediction = lstmLayer.forwardPropagate(np.reshape(negTest[:,seqPos,seqNum], (20,1)))
            lstmLayer.prev_c = lstmLayer.c
            lstmLayer.prev_y = lstmLayer.y
        print(prediction)
        lstmLayer.resetNetwork()
        if(prediction > 0.8) : error += 1
        if(prediction < 0.2) : true  += 1

        print("True Negative Rate: {0:.4} ".format(true/seqNum))
        print("False Positive Rate: {0:.4} ".format(error/seqNum))

    print("***********************************")
    # Print the progress
