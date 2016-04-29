import numpy as np

def real_to_Qnm(real, n, m):
    if(real >= 0):
        return int(np.round(real*(2**m)).astype(int)) & int(2**(n+m+1)-1)
    else:
        return int(2**(n+m+1) + np.round(real*(2**m)).astype(int)) & int(2**(n+m+1)-1)
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
NROW         = 32
NCOL         = 4
QN           = 6
QM           = 11
WMAX         = 7
fin_Wx  = open('goldenIn_Wx.bin', 'w')
fin_Wy  = open('goldenIn_Wy.bin', 'w')
fin_b   = open('goldenIn_b.bin', 'w')
fin_x   = open('goldenIn_x.bin', 'w')
fin_y   = open('goldenIn_y.bin', 'w')
fout    = open('goldenOut.bin' , 'w')

quantError = 0

out  = np.zeros( (NROW, 1) )

for n in range(NUM_MATRICES) :

    Wx  = (np.random.random( (NROW, NCOL) )-0.5)*WMAX
    Wxq = np.zeros_like(Wx)
    Wy  = (np.random.random( (NROW, NROW) )-0.5)*WMAX
    Wyq = np.zeros_like(Wy)
    x   = (np.random.random( (NCOL, 1) )-0.5 )*WMAX
    xq  = np.zeros_like(x)
    y   = ((np.random.random( (NROW, 1) ))-0.5)*WMAX
    yq  = np.zeros_like(y)
    b   = (np.random.random( (NROW, 1) )-0.5)*WMAX
    bq  = np.zeros_like(b)

    for i in range(NCOL):
        xq[i,0] = real_to_Qnm(x[i,0],QN,QM)
        fin_x.write("{0:018b}\n".format(int(xq[i,0])))

    for i in range(NROW) : 
        bq[i,0] = real_to_Qnm(b[i,0],QN,QM)
        yq[i,0] = real_to_Qnm(y[i,0],QN,QM)
        fin_b.write("{0:018b}\n".format(int(bq[i,0])))
        fin_y.write("{0:018b}\n".format(int(yq[i,0])))
        for j in range(NROW) :
            Wyq[i,j] = real_to_Qnm(Wy[i,j],QN,QM)
            fin_Wy.write("{0:018b}\n".format(int(Wyq[i,j])))
        for j in range(NCOL) :
            Wxq[i,j] = real_to_Qnm(Wx[i,j],QN,QM)
            fin_Wx.write("{0:018b}\n".format(int(Wxq[i,j])))

    out  = np.dot(Wx,x) + np.dot(Wy,y) + b    
    outq = np.zeros_like(out)

    for i in range(NROW):
        for j in range(NCOL):
            outq[i,0] += (int(sign_ext(Wxq[i,j], 2*(QN+QM+1)+1,QN+QM+1) * sign_ext(xq[j,0], 2*(QN+QM+1)+1,QN+QM+1)/(2**QM)) & int(2**(QN+QM+1)-1))
            outq[i,0] += (int(sign_ext(Wyq[i,j], 2*(QN+QM+1)+1,QN+QM+1) * sign_ext(yq[j,0], 2*(QN+QM+1)+1,QN+QM+1)/(2**QM)) & int(2**(QN+QM+1)-1))
            outq[i,0] += bq[i,0]

    #yq = np.dot(Wq,xq)
    outrec = np.zeros_like(outq)
 
    for i in range(NROW):
        #yq[i,0]   = int(yq[i,0]/(2**11)) & int(0x3ffff)
        outrec[i,0] = Qnm_to_real(outq[i,0],QN,QM)
        #fout.write("{0:018b}\n".format(int(yq[i,0]) & int(2**(QN+QM+1)-1)))
        fout.write("{0:018b}\n".format(real_to_Qnm(out[i,0],QN,QM)))
    
    quantError += sum(out-outrec)

print("Quantizaion Error: ", quantError/(NUM_MATRICES*NROW))

fin_Wx.close()
fin_Wy.close()
fin_x.close()
fin_b.close()
fin_y.close()
fout.close()
