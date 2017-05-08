import matplotlib.pyplot as plt

latencies   = [ l/2. for [l, _] in data ] # x
throughputs = [ b for [_, b] in data ]    # y
img = plt.figure()

plt.plot(latencies, throughputs, marker='+')
plt.xlabel("Latency (ms)")
plt.ylabel("Throughput (Mbits/s)")
plt.title("Throughput Expectations")

plt.show()
img.savefig('biterate-ref.png')
img.savefig('biterate-ref.pdf')
img.savefig('biterate-ref.svg')
return 'biterate-ref.svg'
