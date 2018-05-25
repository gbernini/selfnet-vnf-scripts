#!/bin/bash

#get gw
FIRST_S=$(echo $selfnet_apps| cut -d'.' -f 1)
SECOND_S=$(echo $selfnet_apps| cut -d'.' -f 2)
THIRD_S=$(echo $selfnet_apps| cut -d'.' -f 3)

GW_DFLT=$FIRST_S.$SECOND_S.$THIRD_S.1

#set ip for ens4 -> selfnet_apps
echo "Setting IP to ens4 interface: $selfnet_apps"

sed -i "s/auto ens4/#auto ens4/g" /etc/network/interfaces

echo "auto ens4" >> /etc/network/interfaces
echo "iface ens4 inet static" >> /etc/network/interfaces
echo "address ${selfnet_apps}" >> /etc/network/interfaces
echo "netmask 255.255.255.0" >> /etc/network/interfaces
echo "gateway ${GW_DFLT}" >> /etc/network/interfaces
ifdown ens4
ifup ens4

#set default route to selfnet_apps
GW_VM=$(ip route | grep "default" | awk ' {print $3}')

echo "Setting default route to gateway: $GW_DFLT"

if [ "$GW_DFLT" != "$GW_VM" ] ; then
	ip route del default
	ip route add default via $GW_DFLT
	service ems restart
fi

echo "Done."
