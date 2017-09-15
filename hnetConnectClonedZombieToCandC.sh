#!/bin/bash

if [ -z ${CID} ]; then
        (>&2 echo "Missing CID parameter")
        exit 1
fi

#check if it is not DELETE operation
if [ -z ${DELETE} ]; then

	if [ -z ${TYPE} ]; then
		(>&2 echo "Missing TYPE parameter")
		exit 1
	fi

	if [ -z ${FREQ} ]; then
		(>&2 echo "Missing FREQ parameter")
		exit 1
	fi

	if [ -z ${BOT} ]; then
		(>&2 echo "Missing BOT parameter")
		exit 1
	fi

	if [ -z ${VERBOSE} ]; then
		VERBOSE=true
	fi

	if [ -z ${CCIP} ]; then
 		(>&2 echo "Missing CCIP parameter")
		exit 1
	fi

	if [ -z ${ZOMBIEUID} ]; then
 		(>&2 echo "Missing ZOMBIEUID parameter")
		exit 1
	fi

	if [ -z ${LOCALPORT} ]; then
        	LOCALPORT=0
	fi

	if [ -z ${CCSUB} ]; then
		echo "C&C server subnet not provided."
	else
		echo "C&C server subnet ${CCSUB} not needed. HNet VNF is running with a single vNIC"
	fi

	java -jar /home/nextworks/ZombieBot.jar -type ${TYPE} -freq ${FREQ} -bot ${BOT} -uid ${ZOMBIEUID} -laddress ${honeynet_internal_net} -lport ${LOCALPORT} -v ${VERBOSE} ${CCIP} &

	sleep 1

	zombie=`pgrep -f "ZombieBot.jar -type ${TYPE} -freq ${FREQ} -bot ${BOT} -uid ${ZOMBIEUID} -laddress ${honeynet_internal_net} -lport ${LOCALPORT} -v ${VERBOSE} ${CCIP}"`

	if [ -z ${zombie} ]; then
 		(>&2 echo "HNet app configuration failure.")
		exit 1
	fi

	echo "HNet app configured with success."
	echo "type ${TYPE} freq ${FREQ} bot ${BOT} uid ${ZOMBIEUID} laddress ${honeynet_internal_net} lport ${LOCALPORT} ccip ${CCIP}"

else
	#it is DELETE operation

        if [ -z ${VERBOSE} ]; then
                VERBOSE=true
        fi

        zombieD=`pgrep -f "ZombieBot.jar -type ${TYPE} -freq ${FREQ} -bot ${BOT} -uid ${ZOMBIEUID} -laddress ${honeynet_internal_net} -lport ${LOCALPORT} -v ${VERBOSE} ${CCIP}"`

        if [ -z ${zombieD} ]; then
                (>&2 echo "HNet app configuration was already deleted.")
                exit 0
        fi

        delete=`kill -9 $zombieD`

        echo "HNet app configuration deleted."
fi
