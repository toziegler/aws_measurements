#!/bin/bash
instance_type=$(cat /sys/devices/virtual/dmi/id/product_name)
hostname=$(hostname)
echo "ts, packets, hostname, instance_type" >>packets.csv

N=10
for ((n = 0; n < N; n++)); do
    # Extract the current count of incoming UDP packets (InDatagrams)
    OLD=$(grep 'Udp:' /proc/net/snmp | awk 'NR==2 {print $2}')
    sleep 1
    NEW=$(grep 'Udp:' /proc/net/snmp | awk 'NR==2 {print $2}')

    # Calculate the difference (packets per second)
    if [[ -n "$OLD" && -n "$NEW" ]]; then
        echo $((NEW - OLD)) " UDP packets per second"
        echo "$n, $((NEW - OLD)), $hostname, $instance_type" >>packets.csv
    else
        echo "Error extracting UDP packet count."
    fi
done
