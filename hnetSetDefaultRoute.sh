#!/bin/bash

FIRST=$(echo $honeynet_internal_net| cut -d'.' -f 1)
SECOND=$(echo $honeynet_internal_net| cut -d'.' -f 2)
THIRD=$(echo $honeynet_internal_net| cut -d'.' -f 3)

GW_DFLT=$FIRST.$SECOND.$THIRD.1
GW_VM=$(ip route | grep "default" | awk ' {print $3}')

if [ "$GW_DFLT" != "$GW_VM" ] ; then
	ip route del default
	ip route add default via $GW_DFLT
	service ems restart
fi

echo "Setting default route to gateway: $GW_DFLT"
echo "Done."
