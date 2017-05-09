#!/usr/bin/env python

import glob
import json
import matplotlib
matplotlib.use('tkagg')
matplotlib.rcParams.update({'font.size': 16})
#                            'figure.figsize': [16.0, 12.0]})
#matplotlib.rcParams.update({'font.size': 20})
import matplotlib.pyplot as plt
import matplotlib.pyplot as plt
import numpy as np
import objectpath as op
import re
import operator


styles = {
    '0': {
        'marker': '+',
        'ls': '-',
        'color': '#ff3c00'
    },
    '0.1': {
        'marker': '+',
        'ls': ':',
        'color': 'red'
    },
    '1': {
        'marker': '+',
        'ls': ':',
        'color': 'blue'
    },
    '10': {
        'marker': '+',
        'ls': '-.',
        'color': 'green'
    },
    '25': {
        'marker': '+',
        'ls': '--',
        'color': 'black'
    },
}
def mk_results(results):
  durations = list(op.Tree(results).execute('$.duration'))
  errors = list(op.Tree(results).execute('$.error'))
  p_errors  = len(filter(operator.truth, errors)) / float(len(errors)) * 100.0
  mean = np.average(durations)
  std  = np.std(durations)
  return [mean, std, p_errors]

bds = glob.glob("cpt10*/root/rally_home/rally-boot-and-delete*.json")
results = []
losses = set()
latencies = set()
for bd in bds:
    print(bd)
    s = re.search('lat(\d+)-los(\d+(.\d)*)', bd).groups()
    lat = s[0]
    los = s[1]
    latencies.add(lat)
    losses.add(los)
    with open(bd) as f:
        results.append([lat, los] + mk_results(list(op.Tree(json.load(f)).execute('$..result'))))

results = np.asarray(results)
results = results.astype(np.float)
losses = sorted(list(losses))

f, (ax1, ax2) = plt.subplots(2, 1, sharex=True)
for loss in losses:
    times = results[results[:, 1] == np.float(loss)][:, [0, 2,3]]
    times = times[np.argsort(times[:, 0])]
    ax1.errorbar(times[:,0] ,times[:,1], yerr=times[:,2],
                ls=styles[loss]['ls'],
                lw=3,
                markersize=15,
                color=styles[loss]['color'],
                marker=styles[loss]['marker'],
                label="Loss %s%%" % loss )
    ax2.errorbar(times[:,0] ,times[:,1], yerr=times[:,2],
                ls=styles[loss]['ls'],
                lw=3,
                markersize=15,
                color=styles[loss]['color'],
                marker=styles[loss]['marker'],
                label="Loss %s%%" % loss )

ax2.set_ylim(10, 50)
ax1.set_ylim(110, 400)
ax1.set_xlim(-10,110)
ax2.spines['top'].set_visible(False)
ax1.spines['bottom'].set_visible(False)
ax2.tick_params(labeltop='off')  # don't put tick labels at the top
ax2.xaxis.tick_bottom()

d = .015  # how big to make the diagonal lines in axes coordinates
# arguments to pass plot, just so we don't keep repeating them
kwargs = dict(transform=ax1.transAxes, color='k', clip_on=False)
ax1.plot((-d, +d), (-d, +d), **kwargs)        # top-left diagonal
ax1.plot((1 - d, 1 + d), (-d, +d), **kwargs)  # top-right diagonal

kwargs.update(transform=ax2.transAxes)  # switch to the bottom axes
ax2.plot((-d, +d), (1 - d, 1 + d), **kwargs)  # bottom-left diagonal
ax2.plot((1 - d, 1 + d), (1 - d, 1 + d), **kwargs)  # bottom-right diagonal

plt.legend(bbox_to_anchor=(.52, 1.5), loc=2, borderaxespad=0.)
plt.xlabel("RTT Latency (ms)")
plt.ylabel("Execution Time (s)")
ax1.set_title('Rally boot and delete')
plt.show()
f.savefig('boot-delete.png')
f.savefig('boot-delete.pdf')
f.savefig('boot-delete.svg')
