#!/bin/bash 


cd /tmp
echo "Downloading started"
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz

echo "Downloading ended"
echo " "
echo "Extracting archive file"
tar xvf node_exporter-0.18.1.linux-amd64.tar.gz

echo " "
echo "Moveing files to required directories"
mv node_exporter-0.18.1.linux-amd64 /opt/node_exporter

echo " "
echo "Change directory ownership"
chown -R node_exporter:node_exporter /opt/node_exporter

echo "Creating node-exporter.service config file"
cat << EOF > /lib/systemd/system/node-exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/opt/node_exporter/node_exporter --collector.systemd

[Install]
WantedBy=multi-user.target
EOF

echo "Doing daemon-reload"
systemctl daemon-reload

echo "Enableing node exporter"
systemctl enable node-exporter

echo "Starting node exporter"
systemctl start node-exporter

