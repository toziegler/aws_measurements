N=$1
for ((n = 0; n < N; n++)); do
    core_id=$((n + 3))
    numactl -C $core_id ./sockperf/sockperf tp -p $((50000 + n)) -i 172.31.6.255 -m 1472 -t 1000 &
done
