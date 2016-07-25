import numpy as np

def real_to_Qnm(real, n, m):
    if(real >= 0):
        return int(np.round(real*(2**m)).astype(int))
    else:
        return int(2**(n+m+1) + np.round(real*(2**m)).astype(int))
def Qnm_to_real(real, n, m):
    real = int(real) & int(2**(n+m+1)-1)
    if(real >= 2**(n+m)):
        return (real-2**(n+m+1))/(2**m)
    else:
        return real/(2**m)

def sign_ext(value, newSize, oldSize):
    if(value >= 2**(oldSize-1)):
        return value + 2**(newSize) - 2**(oldSize)
    else:
        return value

NUM_MATRICES = 100
NROW         = 16
NCOL         = 4
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
        fin_x.write("{0:018b}\n".format(int(xq[i,0])))

    for i in range(NROW) :
        for j in range(NCOL) :
            Wq[i,j] = real_to_Qnm(W[i,j],QN,QM)
            fin_W.write("{0:018b}\n".format(int(Wq[i,j])))

    y  = np.dot(W,x)
    yq = np.zeros_like(y)

    for i in range(NROW):
        for j in range(NCOL):
            yq[i,0] += (int(sign_ext(Wq[i,j], 2*(QN+QM)+1,QN+QM+1) * sign_ext(xq[j,0], 2*(QN+QM)+1,QN+QM+1)/(2**QM)) & int(2**(QN+QM+1)-1))

    #yq = np.dot(Wq,xq)
    yrec = np.zeros_like(yq)

    for i in range(NROW):
        #yq[i,0]   = int(yq[i,0]/(2**11)) & int(0x3ffff)
        yrec[i,0] = Qnm_to_real(yq[i,0],QN,QM)
        #fout.write("{0:018b}\n".format(int(yq[i,0]) & int(2**(QN+QM+1)-1)))
        fout.write("{0:018b}\n".format(real_to_Qnm(y[i,0],QN,QM)))

    quantError += sum(y-yrec)

print("Quantizaion Error: ", quantError/(NUM_MATRICES*NROW))
fin_W.close()
fin_x.close()
fout.close()
