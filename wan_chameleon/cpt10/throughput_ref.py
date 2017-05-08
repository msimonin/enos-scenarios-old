#!/usr/bin/env python
import matplotlib
matplotlib.use('tkagg')
#matplotlib.rcParams.update({'font.size': 20})
import matplotlib.pyplot as plt

from numpy import genfromtxt
datas = genfromtxt('./throughput_ref.csv', delimiter=',', skip_header=1)

losses = [0, 0.1, 1, 10, 25]
styles = {
    0: {
        'marker': '+',
        'ls': '-',
        'color': '#ff3c00'
    },
    0.1: {
        'marker': '+',
        'ls': ':',
        'color': 'red'
    },
    1: {
        'marker': '+',
        'ls': ':',
        'color': 'blue'
    },
    10: {
        'marker': '+',
        'ls': '-.',
        'color': 'green'
    },
    25: {
        'marker': '+',
        'ls': '--',
        'color': 'black'
    },
}
latencies = []
throughputs = []
img = plt.figure()
plt.xlim([-20, 230])
plt.ylim([-300, 10000])
for loss in losses:
    latencies = datas[datas[:, 1] == loss][:, 0] * 2
    throughputs = datas[datas[:, 1] == loss][:, 3]
    plt.plot(latencies, throughputs,
                ls=styles[loss]['ls'],
                lw=1,
                color=styles[loss]['color'],
                marker=styles[loss]['marker'],
                label="Loss %s%%" % loss )

plt.xlabel("RTT Latency (ms)")
plt.ylabel("Throughput (Mbits/s)")
plt.title("Throughput Expectations")
#plt.legend(['Loss 0%', 'Loss 0.1%', 'Loss 1%', 'Loss 10%', 'Loss 25%'])
plt.legend()

plt.show()
img.savefig('biterate-ref.png')
img.savefig('biterate-ref.pdf')
img.savefig('biterate-ref.svg')
