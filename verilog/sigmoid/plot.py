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
        y[i] = eval(line)/(2**11)
        i += 1
absError = abs(y[1:len(t)+1] - 1/(1+np.exp(-t)))
print("Max Error: ", max(absError))

plt.plot(t, y[0:len(t)], 'r', label="Verilog Model Output")
plt.plot(t, 1/(1+np.exp(-t)), 'g', label=r"Numpy $\sigma(x)$")
plt.grid(True);
plt.xlabel(r"$x$");
plt.ylabel(r"$\sigma(x)$");
plt.legend(loc=2);
plt.savefig(filename='../../finalText/figures/nonlin-out.eps', transparent=True);
plt.show()
