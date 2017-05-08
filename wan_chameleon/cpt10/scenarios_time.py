#!/usr/bin/env python

import glob
import json
import numpy as np
import objectpath as op
import re
import operator
from itertools import groupby
import os

def mk_results(results):
  durations = list(op.Tree(results).execute('$.duration'))
  errors = list(op.Tree(results).execute('$.error'))
  p_errors  = len(filter(operator.truth, errors)) / float(len(errors)) * 100.0
  mean = np.average(durations)
  std  = np.std(durations)
  return [mean, std, p_errors]

def pprint_measures(m):
      return "(%05.2f %05.2f %d)" % m

bds = glob.glob("cpt10*/root/rally_home/rally-*.json")
results = []
losses = set()
latencies = set()
for bd in bds:
    s = re.search('lat(\d+)-los(\d+(.\d)*)', bd).groups()
    lat = s[0]
    los = s[1]
    latencies.add(lat)
    losses.add(los)
    with open(bd) as f:
        scenario = json.load(f)
        results.append([scenario[0]['key']['name']] + [lat, los] + mk_results(list(op.Tree(scenario).execute('$..result'))))

results = np.asarray(results)

losses = sorted(list(losses))
for loss in losses:
    block = results[results[:, 2] == unicode(loss)]
    block = block[np.argsort(block[:, 1])]
    print("LOSSES = %s" % loss)
    for name,lat,los,m,s,e in block:
        print("%-60s %-4s %-4s %s" % (name,lat,los, pprint_measures((float(m),float(s),float(e)))))
