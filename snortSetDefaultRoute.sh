#!/bin/bash

#set default route to snort_internal_net gw

FIRST_S=$(echo $ap_provider_net| cut -d'.' -f 1)
SECOND_S=$(echo $ap_provider_net| cut -d'.' -f 2)
THIRD_S=$(echo $ap_provider_net| cut -d'.' -f 3)

GW_DFLT=$FIRST_S.$SECOND_S.$THIRD_S.1
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

