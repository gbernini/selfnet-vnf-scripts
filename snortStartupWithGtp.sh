#!/bin/bash

interface=ens3

FIRST_S=$(echo $selfnet_apps| cut -d'.' -f 1)
SECOND_S=$(echo $selfnet_apps| cut -d'.' -f 2)
THIRD_S=$(echo $selfnet_apps| cut -d'.' -f 3)
sniffNet=$FIRST_S.$SECOND_S.$THIRD_S.0

echo "GETTING SNIFFING NIC ... "
for iface in `ls /sys/class/net`; do
        ip=`ifconfig $iface | grep "inet" | grep -v inet6 | awk -F ":" '/addr/ {print $2}'`
        ipSecco=`echo $ip | awk '{print $1}'`

        FIRST=$(echo $ipSecco| cut -d'.' -f 1)
        SECOND=$(echo $ipSecco| cut -d'.' -f 2)
        THIRD=$(echo $ipSecco| cut -d'.' -f 3)
        ipSeccoNet=$FIRST.$SECOND.$THIRD.0
        # do the check among networks rather than IPs
        if [[ ${sniffNet} == $ipSeccoNet ]]; then
                interface=$iface
        fi
done
echo "SNIFFING NIC: ${interface}"

ethtool -K $interface gro off
ethtool -K $interface lro off

echo "GETTING CIDR ... "
CIDR=`ip addr show $interface | grep inet | grep -v inet6 | awk '{print $2}'`
echo "CIDR: ${CIDR} "
cp /etc/init.d/snort /home/nextworks/.
cp /etc/snort/snort.debian.conf /etc/snort/snort.debian.conf.backup
sed -i "s/DEBIAN_SNORT_HOME_NET=/#DEBIAN_SNORT_HOME_NET=/g" /etc/snort/snort.debian.conf
sed -i "s/DEBIAN_SNORT_INTERFACE=/#DEBIAN_SNORT_INTERFACE=/g" /etc/snort/snort.debian.conf
echo DEBIAN_SNORT_HOME_NET=$CIDR >> /etc/snort/snort.debian.conf
echo DEBIAN_SNORT_INTERFACE=$interface >> /etc/snort/snort.debian.conf
sed -i "s/DEBIAN_SNORT_HOME_NET=192.168.0.0\/16/DEBIAN_SNORT_HOME_NET=$CIDR/g" /home/nextworks/snort
sed -i "s/DEBIAN_SNORT_INTERFACE=ens3/DEBIAN_SNORT_INTERFACE=$interface/g" /home/nextworks/snort
service snort stop
rm -rf /etc/init.d/snort
cp /home/nextworks/snort /etc/init.d/.
systemctl daemon-reload
rm /home/nextworks/snort
service snort restart

snort=`ps axu | grep snort | grep ${CIDR}`

if [ -z ${snort} ]; then
	(>&2 echo "Failed to start Snort service")
	exit 1
fi

ping -c 1 -I $interface 10.255.253.1 > ping.out

#set Snort VM hostname
name=`echo "$hostname" | awk '{print tolower($0)}'`

sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost $name /g" /etc/hosts

#set hostname for kafka bus VM
echo "10.255.255.151 selfnetmont-dev-evl-kafka.ptin.corppt.com" >> /etc/hosts

#set hostname for Kafka bus VM into kafka publishing app configuration
echo -n "selfnetmont-dev-evl-kafka.ptin.corppt.com" >> /home/nextworks/kafkaServer.cfg

#set snort IP to be put in analyzerId field of IDMEF messages 
echo -n "${selfnet_apps}" >> /home/nextworks/snortIP.cfg

echo "SNORT VNF STARTED"
