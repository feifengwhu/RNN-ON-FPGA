import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rc

rc('text', usetex=True);
rc('font', family='serif', serif='Times');

py = 1/np.array([65e-6, 72e-6, 96e-6, 185e-6])/(1e6)
x_py = np.array([2, 3, 4, 5])

k2 = 1/np.array([259.12e-9, 317.52e-9, 461.336e-9])/(1e6)
x_k2 = np.array([2,3,4])

k4 = 1/np.array([309.68e-9, 421.12e-9, 738.17e-9, 1.5858e-6])/(1e6)
x_k4 = np.array([2,3,4,5])

k8 = 1/np.array([793.46e-9, 1.4973e-6])/(1e6)
x_k8 = np.array([3,4])

fig = plt.figure()
ax = fig.add_subplot(1,1,1)
plt.plot(x_py, py, 'yo-', label="Python")
plt.plot(x_k2, k2, 'ro-', label="Hardware $K_G = 2$")
plt.plot(x_k4, k4, 'go-', label="Hardware $K_G = 4$")
plt.plot(x_k8, k8, 'bo-', label="Hardware $K_G = 8$")
ax.set_xticks([2,3,4,5])
plt.axis([1.8,5.2,-0.2,4.5])
plt.grid(True);
plt.xlabel(r"$\log_2(N)$");
plt.ylabel(r"Million Classifications per Second");
plt.legend(loc=1);
plt.savefig(filename='Mclass-psec.eps', transparent=True);
plt.show()
