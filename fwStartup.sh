#!/bin/bash

ping -c 1 10.0.255.1 > ping.out

name=`echo "$hostname" | awk '{print tolower($0)}'`

sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost $name/g" /etc/hosts

echo "FW VNF properly started."

