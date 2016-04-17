import numpy as np

def real_to_Qnm(real, n, m):
    if(real >= 0):
        return int(np.round(real*(2**m)).astype(int))
    else:
        return int(2**18 + np.round(real*(2**m)).astype(int))
def Qnm_to_real(real, n, m):
    if(real >= 2**(n+m)):
        return (real-2**(n+m+1))/(2**m)
    else:
        return real/(2**m)

NUM_MATRICES = 2
NROW         = 16
NCOL         = 8
QN           = 6
QM           = 11
WMAX         = 7
fin_W  = open('goldenIn_W.bin', 'w')
fin_x  = open('goldenIn_x.bin', 'w')
fout   = open('goldenOut.bin' , 'w')

quantError = 0

for n in range(NUM_MATRICES) :

    W  = (np.random.random( (NROW, NCOL) )-0.5)*WMAX
    Wq = np.zeros_like(W)
    x  = (np.random.random( (NCOL, 1) )-0.5)*WMAX
    xq = np.zeros_like(x)

    for i in range(NCOL):
        xq[i,0] = real_to_Qnm(x[i,0],QN,QM)

    for i in range(NROW) :
        for j in range(NCOL) :
            Wq[i,j] = real_to_Qnm(W[i,j],QN,QM)
            fin_W.write("{0:018b} ".format(int(Wq[i,j])))
        fin_W.write("\n")

    y  = np.dot(W,x)    
    yq = np.dot(Wq,xq)
    yrec = np.zeros_like(yq)
 
    for i in range(NROW):
        yq[i,0]   = int(yq[i,0]/(2**11)) & int(0x3ffff)
        yrec[i,0] = Qnm_to_real(yq[i,0],QN,QM)
        fout.write("{0:018b} ".format(int(yq[i,0])))
    
    fout.write("\n")
    quantError += sum(y-yrec)

print("Quantizaion Error: ", quantError/(NUM_MATRICES*NROW))
fin_W.close()
fout.close()
