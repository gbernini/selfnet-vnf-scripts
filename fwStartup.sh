#!/bin/bash

name=`echo "$hostname" | awk '{print tolower($0)}'`

sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost $name/g" /etc/hosts

IP_DOWN="$fw_downstream/24"
IP_UP="$fw_upstream/24"

sed -i '2 i\FW_IP_DOWNSTREAM='"$IP_DOWN"'' /opt/firewall_server/init_config/config_ovs.sh
sed -i '2 i\FW_IP_UPSTREAM='"$IP_UP"'' /opt/firewall_server/init_config/config_ovs.sh
sed -i '2 i\FLOWT_MAC_UPSTREAM=''"'fa:be:af:d3:cb:b8'"''' /opt/firewall_server/init_config/config_ovs.sh
sed -i '2 i\FLOWT_MAC_DOWNSTREAM=''"'fa:be:af:a2:6c:ba'"''' /opt/firewall_server/init_config/config_ovs.sh
sed -i '2 i\FLOWT_IP_UPSTREAM=''"'172.12.0.7'"''' /opt/firewall_server/init_config/config_ovs.sh
sed -i '2 i\FLOWT_IP_DOWNSTREAM=''"'172.13.0.5'"''' /opt/firewall_server/init_config/config_ovs.sh

systemctl start firewall_server_ovs_init.service
systemctl start firewall_server.service

echo "FW VNF properly started."
