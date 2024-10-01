#!/bin/bash
instance_type=$(cat /sys/devices/virtual/dmi/id/product_name)
hostname=$(hostname)
echo "min, max, avg, stdev, hostname, instance_type" >>ssd_iops_latency.csv
sudo fio --name=bla --filesize=1000GB --filename=/dev/nvme1n1 --rw=randwrite --iodepth=16 --ioengine=libaio --direct=1 --blocksize=4096 --numjobs=32 --runtime=100 --group_reporting | grep "^   iops" | awk -F'[,=]' -v host="$hostname" -v inst_type="$instance_type" '{print $2","$4","$6","$8","host","inst_type}' >>ssd_iops_latency.csv
