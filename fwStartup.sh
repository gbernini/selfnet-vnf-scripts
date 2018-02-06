#!/bin/bash

export FLOWT_UPSTREAM='fa:be:af:d3:cb:b8'
export FLOWT_DOWNSTREAM='fa:be:af:a2:6c:ba'

ping -c 1 10.0.255.1 > ping.out

name=`echo "$hostname" | awk '{print tolower($0)}'`

sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost $name/g" /etc/hosts

echo "FW VNF properly started."

