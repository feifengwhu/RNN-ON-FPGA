import numpy as np
import matplotlib.pyplot as plt

f = open("myout.hex", "r")

t = np.arange(-10, 10, 2**-11)
y = np.zeros(len(t)+100)
i = 0
for line in f:
    if( "x" not in line):  
        y[i] = (eval(line) - (2**18))/(2**11) if  eval(line) >= (2**17) else eval(line)/(2**11)
        i += 1

plt.plot(t, y[0:len(t)])
plt.show()
