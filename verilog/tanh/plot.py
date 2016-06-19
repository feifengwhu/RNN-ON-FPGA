import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rc

rc('text', usetex=True);
rc('font', family='serif', serif='Times');

f = open("myout.hex", "r")

t = np.arange(-10, 10, 2**-11)
y = np.zeros(len(t)+100)
i = 0
for line in f:
    if( "x" not in line):  
        y[i] = (int(line,2) - (2**18))/(2**11) if  int(line,2) >= (2**17) else int(line,2)/(2**11)
        i += 1

plt.plot(t, y[0:len(t)],'r', label="Verilog Model Output")
plt.plot(t, np.tanh(t), 'g', label=r"Numpy $\tanh(x)$")
plt.grid(True);
plt.xlabel(r"$x$");
plt.ylabel(r"$\tanh(x)$");
axes = plt.gca()
axes.set_xlim([-10,10])
axes.set_ylim([-1.02,1.02])
plt.legend(loc=2);
plt.savefig(filename='../../finalText/figures/nonlin-out-tanh.eps', transparent=True)
plt.show()

f.close()
