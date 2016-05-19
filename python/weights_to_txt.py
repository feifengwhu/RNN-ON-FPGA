import pickle
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

INPUT_SZ  = 2
HIDDEN_SZ = 8
OUPUT_SZ  = 1
QN = 5
QM = 12


with open('objs.pickle', 'rb') as f:
    Wz, Wi, Wf, Wo, Rz, Ri, Rf, Ro, bz, bi, bf, bo = pickle.load(f)
    
fin_Wz  = open('goldenIn_Wz.bin', 'w')
for j in range(INPUT_SZ) :
	for i in range(HIDDEN_SZ) :
		fin_Wz.write("{0:018b}\n".format(int(real_to_Qnm(Wz[i,j],QN,QM))))
fin_Wz.close()

fin_Wi  = open('goldenIn_Wi.bin', 'w')
for j in range(INPUT_SZ) :
	for i in range(HIDDEN_SZ) :
		fin_Wi.write("{0:018b}\n".format(int(real_to_Qnm(Wi[i,j],QN,QM))))
fin_Wi.close()

fin_Wf  = open('goldenIn_Wf.bin', 'w')
for j in range(INPUT_SZ) :
	for i in range(HIDDEN_SZ) :
		fin_Wf.write("{0:018b}\n".format(int(real_to_Qnm(Wf[i,j],QN,QM))))
fin_Wf.close()

fin_Wo  = open('goldenIn_Wo.bin', 'w')
for j in range(INPUT_SZ) :
	for i in range(HIDDEN_SZ) :
		fin_Wo.write("{0:018b}\n".format(int(real_to_Qnm(Wo[i,j],QN,QM))))
fin_Wo.close()

fin_Rz  = open('goldenIn_Rz.bin', 'w')
for j in range(HIDDEN_SZ) :
	for i in range(HIDDEN_SZ) :
		fin_Rz.write("{0:018b}\n".format(int(real_to_Qnm(Rz[i,j],QN,QM))))
fin_Rz.close()

fin_Ri  = open('goldenIn_Ri.bin', 'w')
for j in range(HIDDEN_SZ) :
	for i in range(HIDDEN_SZ) :
		fin_Ri.write("{0:018b}\n".format(int(real_to_Qnm(Ri[i,j],QN,QM))))
fin_Ri.close()

fin_Rf  = open('goldenIn_Rf.bin', 'w')
for j in range(HIDDEN_SZ) :
	for i in range(HIDDEN_SZ) :
		fin_Rf.write("{0:018b}\n".format(int(real_to_Qnm(Rf[i,j],QN,QM))))
fin_Rf.close()

fin_Ro  = open('goldenIn_Ro.bin', 'w')
for j in range(HIDDEN_SZ) :
	for i in range(HIDDEN_SZ) :
		fin_Ro.write("{0:018b}\n".format(int(real_to_Qnm(Ro[i,j],QN,QM))))
fin_Ro.close()

fin_bz  = open('goldenIn_bz.bin', 'w')
for i in range(HIDDEN_SZ) :
	fin_bz.write("{0:018b}\n".format(int(real_to_Qnm(bz[i,0],QN,QM))))
fin_bz.close()

fin_bi  = open('goldenIn_bi.bin', 'w')
for i in range(HIDDEN_SZ) :
	fin_bi.write("{0:018b}\n".format(int(real_to_Qnm(bi[i,0],QN,QM))))
fin_bi.close()

fin_bf  = open('goldenIn_bf.bin', 'w')
for i in range(HIDDEN_SZ) :
	fin_bf.write("{0:018b}\n".format(int(real_to_Qnm(bf[i,0],QN,QM))))
fin_bf.close()

fin_bo  = open('goldenIn_bo.bin', 'w')
for i in range(HIDDEN_SZ) :
	fin_bo.write("{0:018b}\n".format(int(real_to_Qnm(bo[i,0],QN,QM))))
fin_bo.close()

