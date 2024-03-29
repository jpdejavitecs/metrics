#!/bin/bash

yum install firewalld -y
systemctl start firewalld
systemctl enable firewalld
yum install wget unzip vim -y
yum install epel-release -y
yum install stress -y
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
tar -xvzf node_exporter-0.18.1.linux-amd64.tar.gz
useradd -rs /bin/false nodeusr
mv node_exporter-0.18.1.linux-amd64/node_exporter /usr/local/bin/
cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nodeusr
Group=nodeusr
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start node_exporter
firewall-cmd --zone=public --add-port=9100/tcp --permanent
firewall-cmd --reload
