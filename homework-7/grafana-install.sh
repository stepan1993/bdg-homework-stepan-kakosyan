#!/bin/bash 

echo "Install starting"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

apt install grafana

systemctl start grafana-server
