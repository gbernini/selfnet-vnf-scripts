#!/bin/bash

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

java -jar /home/nextworks/ZombieBot.jar -type ${TYPE} -freq ${FREQ} -bot ${BOT} -uid ${ZOMBIEUID} -port ${LOCALPORT} -v ${VERBOSE} ${CCIP} &

sleep 1

zombie=`pgrep -f "ZombieBot.jar -type ${TYPE} -freq ${FREQ} -bot ${BOT} -uid ${ZOMBIEUID} -port ${LOCALPORT} -v ${VERBOSE} ${CCIP}"`

if [ -z ${zombie} ]; then
 	(>&2 echo "HNet app configuration failure.")
	exit 1
fi
