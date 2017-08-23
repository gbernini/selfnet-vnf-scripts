#!/bin/bash

if [ -z ${CID} ]; then
        (>&2 echo "Missing CID parameter")
        exit 1
fi

#check if it is not DELETE operation
if [ -z ${DELETE} ]; then
	if [ -z ${ZOMBIEIP} ]; then
        	(>&2 echo "Missing ZOMBIEIP parameter")
        	exit 1
	fi

	if [ -z ${CCIP} ]; then
        	(>&2 echo "Missing CCIP parameter")
        	exit 1
	fi

	if [ -z ${CCPORT} ]; then
        	(>&2 echo "Missing CCPORT parameter")
        	exit 1
	fi

	if [ -z ${MESSAGE} ]; then
        	(>&2 echo "Missing MESSAGE parameter")
        	exit 1
	fi

	if [ -z ${PARAMS} ]; then
        	(>&2 echo "Missing PARAMS parameter")
        	exit 1
	fi

	rule=`echo "alert tcp ${ZOMBIEIP} any -> ${CCIP} ${CCPORT} (msg:\"${MESSAGE}\";content:\"GET\"; content:\"${PARAMS}\"; nocase; sid:${CID};)"`

	echo "Adding new signature to Snort:"
	echo $rule

	echo $rule >> /etc/snort/rules/selfnet.rules
else
	#it is delete operation
	echo "Removing signature with sid ${CID} to Snort:"
	sed -i "/sid:${CID};/d" /etc/snort/rules/selfnet.rules

fi

service snort restart

echo "Snort re-configured successfully."
