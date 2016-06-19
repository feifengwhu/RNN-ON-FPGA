import matplotlib.pyplot as plt
from matplotlib import rc
import numpy as np
import math

rc('text', usetex=True);
rc('font', family='serif', serif='Times');

a       = np.arange(-6.0, 6.0, 0.1)
sigmoid = 1.0 / (1.0 + np.exp(-1.0*a))
tanh    = np.tanh(a)
step    = np.sign(a)



plt.plot(a, sigmoid, 'r', label=r"$f(a) = \sigma(a)$");
plt.plot(a, tanh, 'b', label=r"$f(a) = \tanh(a)$");
plt.plot(a, step, 'g', label=r"\rmfamily $f(a) = $ sign$(a)$");
plt.grid(True);
plt.xlabel(r"Activation $a$");
plt.ylabel(r"$f(a)$");
plt.legend(loc=2);
plt.savefig(filename='activFunc.eps', transparent=True);
plt.show();


