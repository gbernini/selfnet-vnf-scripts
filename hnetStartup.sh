#!/bin/bash

interface=ens3

echo "GETTING HONEYNET NIC ... "
for iface in `ls /sys/class/net`; do
        ip=`ifconfig $iface | grep "inet" | grep -v inet6 | awk -F ":" '/addr/ {print $2}'`
        ipSecco=`echo $ip | awk '{print $1}'`
        if [[ ${selfnet_apps} == $ipSecco ]]; then
                interface=$iface
        fi
done
echo "HONEYNET NIC: ${interface}"

ping -c 1 -I $interface 10.0.255.1 > ping.out

name=`echo "$hostname" | awk '{print tolower($0)}'`

sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost $name/g" /etc/hosts

echo "HNet VNF properly started."

