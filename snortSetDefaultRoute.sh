#!/bin/bash

#get gw
FIRST_S=$(echo $ap_provider_net| cut -d'.' -f 1)
SECOND_S=$(echo $ap_provider_net| cut -d'.' -f 2)
THIRD_S=$(echo $ap_provider_net| cut -d'.' -f 3)

GW_DFLT=$FIRST_S.$SECOND_S.$THIRD_S.1

##check if /etc/network/interfaces has been already tweaked
if [ grep -Fxq "##DONE##" test.txt ]; then
	#do nothing
else
	#set ip for ens4 -> ap_provider_net
	echo "Setting IP to ens4 interface: $ap_provider_net"

	sed -i "s/auto ens4/#auto ens4/g" /etc/network/interfaces

	echo "auto ens4" >> /etc/network/interfaces
	echo "iface ens4 inet static" >> /etc/network/interfaces
	echo "address ${ap_provider_net}" >> /etc/network/interfaces
	echo "netmask 255.255.255.0" >> /etc/network/interfaces
	echo "gateway ${GW_DFLT}" >> /etc/network/interfaces
	echo "##DONE##" >> /etc/network/interfaces
	ifdown ens4
	ifup ens4
fi

#set ip for ens4 -> ap_provider_net
echo "Setting IP to ens4 interface: $ap_provider_net"

sed -i "s/auto ens4/#auto ens4/g" /etc/network/interfaces

echo "auto ens4" >> /etc/network/interfaces
echo "iface ens4 inet static" >> /etc/network/interfaces
echo "address ${ap_provider_net}" >> /etc/network/interfaces
echo "netmask 255.255.255.0" >> /etc/network/interfaces
echo "gateway ${GW_DFLT}" >> /etc/network/interfaces

ifdown ens4
ifup ens4

#set default route to snort_internal_net gw
GW_VM=$(ip route | grep "default" | awk ' {print $3}')

echo "Setting default route to gateway: $GW_DFLT"

if [ "$GW_DFLT" != "$GW_VM" ] ; then
	ip route del default
	ip route add default via $GW_DFLT
	service ems restart
fi

echo "Done."

#### set mgmt interface as default route
#compute cidr of remote management
FIRST=$(echo $management| cut -d'.' -f 1)
SECOND=$(echo $management| cut -d'.' -f 2)
THIRD=$(echo $management| cut -d'.' -f 3)
MGMT_NET_GW=$FIRST.$SECOND.$THIRD.1

echo "Setting route for Kafka bus and github to gateway: $MGMT_NET_GW"

ip route add 10.255.255.129/32 via $MGMT_NET_GW
#ip route add 192.30.252.0/22 via $MGMT_NET_GW
#ip route add 185.199.108.0/22 via $MGMT_NET_GW

echo "Done."

