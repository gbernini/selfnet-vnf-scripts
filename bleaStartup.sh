#!/bin/bash

name=`echo "$hostname" | awk '{print tolower($0)}'`

sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost $name/g" /etc/hosts

#set hostname for kafka bus VM
echo "10.255.255.151 selfnetmont-dev-evl-kafka.ptin.corppt.com" >> /etc/hosts

#set hostname for Kafka bus VM into kafka publishing app configuration
echo -n "selfnetmont-dev-evl-kafka.ptin.corppt.com" >> /home/nextworks/kafkaServer.cfg

ping -c 1 -I $interface 10.0.255.1 >> ping.out

sudo python3 ~/url_sniffer/thread_url_sniffer.py --iface ens4 &

echo "BLEA VNF properly started."
