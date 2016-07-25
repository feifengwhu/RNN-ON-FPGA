import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rc

rc('text', usetex=True);
rc('font', family='serif', serif='Times');

f = np.array([65e-6, 72e-6, 96e-6, 185e-6])/(1e6)
N = np.array([2, 3, 4, 5])

fig = plt.figure()
ax = fig.add_subplot(1,1,1)
plt.plot(f, N, 'yo-', label="$N=4$")
ax.set_xticks([2,3,4,5])
plt.axis([0.8,3.2,90,160])
plt.grid(True);
plt.xlabel(r"$\log_2(N$)");
plt.ylabel(r"Clock Speed in MHz");
plt.legend(loc=1);
plt.savefig(filename='maxfreq-virtx7.eps', transparent=True);
plt.show()

