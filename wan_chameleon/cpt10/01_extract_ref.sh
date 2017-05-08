#!/usr/bin/env bash
set -e
set -x
# Experience Parameters
LATENCIES='0 10 25 50 100'
LOSSES='0 0.1 1 10 25'

THROUGHPUT_FILE="throughput_ref.csv"
echo "latency(ms),loss(%),latency_observed(ms),throughput(MB/s)" > $THROUGHPUT_FILE

for LTY in $LATENCIES
do
  for LOSS in $LOSSES
  do
    printf "$LTY,$LOSS,%s,%s\n" $(cat cpt10-lat$LTY-los$LOSS/tcp_upload_enos-compute-9_enos-compute-1.stats | grep Mean | awk '{print b$2}') >> $THROUGHPUT_FILE
  done
done
