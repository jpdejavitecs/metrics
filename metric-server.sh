#!/bin/bash

#----> PROMETHEUS

yum update -y
yum install firewalld -y
systemctl start firewalld
systemctl enable firewalld
yum install wget unzip vim -y
useradd --no-create-home --shell /bin/false prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.11.1/prometheus-2.11.1.linux-amd64.tar.gz
tar -xvf prometheus-2.11.1.linux-amd64.tar.gz
mv prometheus-2.11.1.linux-amd64 prometheus-files
cp prometheus-files/prometheus /usr/local/bin/
cp prometheus-files/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
cp -r prometheus-files/consoles /etc/prometheus
cp -r prometheus-files/console_libraries /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
cat << EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 10s
 
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    scrape_interval: 5s
    static_configs:
      - targets: ['174.138.50.147:9100']
EOF
chown prometheus:prometheus /etc/prometheus/prometheus.yml
cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
 
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
 
[Install]
WantedBy=multi-user.target
EOF
firewall-cmd --permanent --add-port=9090/tcp
firewall-cmd --permanent --add-port=9090/udp
firewall-cmd --reload
systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus

#----> GRAFANA

wget https://dl.grafana.com/oss/release/grafana-6.2.5-1.x86_64.rpm 
yum localinstall grafana-6.2.5-1.x86_64.rpm -y
firewall-cmd --permanent --add-port=3000/tcp
firewall-cmd --permanent --add-port=3000/udp
firewall-cmd --reload
sed -i '/;domain = localhost/c\domain = 0.0.0.0' /etc/grafana/grafana.ini
systemctl start grafana-server
systemctl enable grafana-server
