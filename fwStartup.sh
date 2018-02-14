#!/bin/bash

name=`echo "$hostname" | awk '{print tolower($0)}'`

sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost $name/g" /etc/hosts

IP_DOWN="$fw_downstream/24"
IP_UP="$fw_upstream/24"

export FW_IP_DOWNSTREAM="$IP_DOWN"
export FW_IP_UPSTREAM="$IP_UP"
export FLOWT_MAC_UPSTREAM='fa:be:af:d3:cb:b8'
export FLOWT_MAC_DOWNSTREAM='fa:be:af:a2:6c:ba'
export FLOWT_IP_UPSTREAM='172.12.0.7'
export FLOWT_IP_DOWNSTREAM='172.13.0.5'

systemctl start firewall_server_ovs_init.service
systemctl start firewall_server.service

echo "FW VNF properly started."

