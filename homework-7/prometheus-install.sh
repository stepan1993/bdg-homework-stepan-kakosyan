#!/bin/bash 

echo "Install Nginx"
apt install nginx

echo " "
echo "Start Nginx"
systemctl start nginx

echo "Create prometheus prome user"

useradd --no-create-home --shell /bin/false prome
echo " "

echo "Create usefull directories"
mkdir /etc/prometheus
mkdir /var/lib/prometheus
echo " "

echo "Downloading started"
wget https://github.com/prometheus/prometheus/releases/download/v2.0.0/prometheus-2.0.0.linux-amd64.tar.gz
echo " "

echo "Extracting archive file"
tar xvf prometheus-2.0.0.linux-amd64.tar.gz
echo " "

echo "Copying prometheus files"
cp prometheus-2.0.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.0.0.linux-amd64/promtool /usr/local/bin/
echo " "

echo "Change prometheus directory ownership"
chown prome:prome /usr/local/bin/prometheus
chown prome:prome /usr/local/bin/promtool
echo " "

echo "Copying console files"
cp -r prometheus-2.0.0.linux-amd64/consoles /etc/prometheus
cp -r prometheus-2.0.0.linux-amd64/console_libraries /etc/prometheus
echo " "

echo "Change console directory ownership"
chown -R prome:prome /etc/prometheus/consoles
chown -R prome:prome /etc/prometheus/console_libraries
echo " "

echo "Creating prometheus.yml yaml file"
cat << EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
EOF
echo " "

echo "Creating /etc/systemd/system/prometheus.service config file"
cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prome
Group=prome
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF
echo " "
chown prome:prome /var/lib/prometheus

echo "Doing daemon-reload"
systemctl daemon-reload

echo "Starting prometheus"
systemctl start prometheus
