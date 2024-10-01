N=$1
for ((n = 0; n < N; n++)); do
    core_id=$((n + 3))
    numactl -C $core_id ./sockperf/sockperf sr -p $((50000 + n)) &
done
