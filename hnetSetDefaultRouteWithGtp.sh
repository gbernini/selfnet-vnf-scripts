#!/bin/bash

FLOWT_IP="10.255.253.9"
FLOWT_MAC="fa:be:af:61:db:6a"

#get gw
FIRST_S=$(echo $selfnet_apps| cut -d'.' -f 1)
SECOND_S=$(echo $selfnet_apps| cut -d'.' -f 2)
THIRD_S=$(echo $selfnet_apps| cut -d'.' -f 3)

GW_APPS=$FIRST_S.$SECOND_S.$THIRD_S.1

#set ip for ens4 -> selfnet_apps
echo "Setting IP to ens4 interface: $selfnet_apps"

sed -i "s/auto ens4/#auto ens4/g" /etc/network/interfaces

echo "auto ens4" >> /etc/network/interfaces
echo "iface ens4 inet static" >> /etc/network/interfaces
echo "address ${selfnet_apps}" >> /etc/network/interfaces
echo "netmask 255.255.255.0" >> /etc/network/interfaces
echo "gateway ${GW_APPS}" >> /etc/network/interfaces
ifdown ens4
ifup ens4

#get mgmt gw
FIRST_G=$(echo $management| cut -d'.' -f 1)
SECOND_G=$(echo $management| cut -d'.' -f 2)
THIRD_G=$(echo $management| cut -d'.' -f 3)

GW_DFLT=$FIRST_G.$SECOND_G.$THIRD_G.1


#set default route to selfnet_apps
GW_VM=$(ip route | grep "default" | awk ' {print $3}')

echo "Setting default route to gateway: $GW_DFLT"

if [ "$GW_DFLT" != "$GW_VM" ] ; then
	ip route del default
	ip route add default via $GW_DFLT
	service ems restart
fi

echo "Setting flowT arp entry"

#add flowt arp entry (ips and mac on the selfnet_apps network)
#on selfnet_apps network
arp -s $FLOWT_IP $FLOWT_MAC

echo "Done."
