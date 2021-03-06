'''
Plot Vec-BT, Vec-NBT, DSD-RW, DSD
8/1/2017, Anuththari Gamage

'''

import matplotlib.pyplot as plt
import numpy as np
import sys
import getopt
import pdb

# SBM parameter changed (out of N, K, c, lambda)
x_array =[2.0, 3.0, 4.0, 5.0, 6.0, 8.0, 10.0, 12.0, 15.0, 20.0] 
N = 1000

# parsing arguments to file
usage_str = '''plot_vec.py [-n <nodes>]'''

try:
    opts, _ = getopt.getopt(sys.argv[1:], "hn:")
except getopt.GetoptError:
    print usage_str
    sys.exit(2)
for opt, arg in opts:
    if opt=='h':
        print(usage_str)
    if opt == '-n':
        N = int(arg)

data_const = 'N{}'.format(N)
data_varied = 'C'

# Load data 
res = {}
algos = ['vec-bt', 'vec-nbt']
metrics = ['ccr', 'nmi']
rand_tests = 15

for r in range(rand_tests):
    res[r] = {}
    for name in algos:
        res[r][name] = {}
        for met in metrics:
            res[r][name][met] = np.empty((len(x_array)))

f = open('../results/vec_data/{}vs{}.txt'.format(data_const, data_varied), 'r')

for r in range(rand_tests):
    for a in algos:
        for m in metrics:
            line = f.readline().strip()
            res[r][a][m] = np.array(line.split(', '), dtype=float)

# Get nmi and ccr with mean and std. deviation
nmi_mean = {}
nmi_std = {}
ccr_mean = {}
ccr_std = {}

for a in algos:
    nm = np.zeros((len(x_array),))
    nstd = np.zeros((len(x_array),))
    cm = np.zeros((len(x_array),))
    cstd = np.zeros((len(x_array),))
    arr_ccr = np.zeros(rand_tests)
    arr_nmi = np.zeros(rand_tests)

    for x in range(len(x_array)):
        for r in range(rand_tests):
            arr_ccr[r] = res[r][a]['ccr'][x]
            arr_nmi[r] = res[r][a]['nmi'][x]
        cm[x] = np.mean(arr_ccr)
        cstd[x] = np.std(arr_ccr)
        nm[x] = np.mean(arr_nmi)
        nstd[x] = np.std(arr_nmi)

    nmi_mean[a] = nm
    nmi_std[a] = nstd
    ccr_mean[a] = cm
    ccr_std[a] = cstd
     
# Plot metrics
fig = plt.figure()
cmap = plt.get_cmap('Accent')
legend = []
linestyles = ['solid', 'dashed', 'dashdot', 'dotted']
i=0
ls = {}
for a in algos:
    ls[a] = linestyles[i]
    i+=1

# Plot CCR
color = cmap(float(1.5)/len(metrics))       #Red
for a in algos:
    plt.errorbar(x_array, ccr_mean[a], yerr=ccr_std[a], color=color, marker='.',
            capsize=5, linestyle=ls[a])
    legend = legend + ["ccr: %s" % a]

# Plot NMI
color = cmap(float(1)/len(metrics))       #Blue
for a in algos:
    plt.errorbar(x_array, nmi_mean[a], yerr=nmi_std[a], color=color, marker='.',
            capsize=5, linestyle=ls[a])
    legend = legend + ["nmi: %s" % a]

plt.legend(legend, loc=0)
plt.xlabel('c')
plt.ylim(-0.05, 1.05)
plt.xticks(np.arange(np.max(x_array)+1))
plt.title('N = {} vs {}'.format(N, data_varied))
plt.savefig('../results/vec_figs/{}vs{}.png'.format(data_const, data_varied))
plt.show()



