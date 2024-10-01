#!/bin/bash
instance_type=$(cat /sys/devices/virtual/dmi/id/product_name)
hostname=$(hostname)
echo "min, max, avg, stdev, hostname, instance_type" >>ssd_write_latency.csv
sudo fio --name=bla --filesize=1000GB --filename=/dev/nvme1n1 --rw=write --iodepth=1 --ioengine=libaio --direct=1 --blocksize=4096 --numjobs=1 --runtime=10 | grep "^     lat " | awk -F'[,=]' -v host="$hostname" -v inst_type="$instance_type" '{print $2","$4","$6","$8","host","inst_type}' >>ssd_write_latency.csv
