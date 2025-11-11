#!/bin/bash
set -e
MASTER_IP=$1

echo "🚀 Instalando MySQL Server (Replica)..."
sudo apt update -y
sudo DEBIAN_FRONTEND=noninteractive apt install -y mysql-server

sudo systemctl enable mysql
sudo systemctl start mysql

echo "Configurando MySQL Replica..."
sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
echo "server-id=$((RANDOM % 1000 + 2))" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "relay-log=/var/log/mysql/mysql-relay-bin.log" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "read_only=ON" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "gtid_mode=ON" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "enforce_gtid_consistency=ON" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf

sudo systemctl restart mysql

mysql -u root <<EOF
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='$MASTER_IP',
  SOURCE_USER='repl',
  SOURCE_PASSWORD='replpass',
  SOURCE_AUTO_POSITION=1;
START REPLICA;
EOF

echo "✅ Replica conectada a $MASTER_IP"
