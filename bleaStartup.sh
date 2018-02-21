#!/bin/bash

interface=ens4

echo "GETTING BLEA NIC ... "
for iface in `ls /sys/class/net`; do
        ip=`ifconfig $iface | grep "inet" | grep -v inet6 | awk -F ":" '/addr/ {print $2}'`
        ipSecco=`echo $ip | awk '{print $1}'`
        if [[ ${selfnet_apps} == $ipSecco ]]; then
                interface=$iface
        fi
done
echo "BLEA NIC: ${interface}"

name=`echo "$hostname" | awk '{print tolower($0)}'`

sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost $name/g" /etc/hosts

#set hostname for kafka bus VM
echo "10.255.255.151 selfnetmont-dev-evl-kafka.ptin.corppt.com" >> /etc/hosts

#set hostname for Kafka bus VM into kafka publishing app configuration
echo -n "selfnetmont-dev-evl-kafka.ptin.corppt.com" >> /home/nextworks/kafkaServer.cfg

ping -c 1 -I $interface 10.0.255.1 >> ping.out

python3 /home/nextworks/url_sniffer/thread_url_sniffer.py --iface $interface &

echo "BLEA VNF properly started."
