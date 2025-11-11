#!/bin/bash
set -e

echo "🚀 Instalando MySQL Server (Primary)..."
sudo apt update -y
sudo DEBIAN_FRONTEND=noninteractive apt install -y mysql-server

sudo systemctl enable mysql
sudo systemctl start mysql

echo "Configurando MySQL Primary..."
sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
echo "server-id=1" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "log_bin=/var/log/mysql/mysql-bin.log" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "binlog_do_db=mini_tienda" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "gtid_mode=ON" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "enforce_gtid_consistency=ON" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf

sudo systemctl restart mysql

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS mini_tienda;
CREATE USER IF NOT EXISTS 'app'@'%' IDENTIFIED BY 'apppass';
GRANT ALL PRIVILEGES ON mini_tienda.* TO 'app'@'%';
CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY 'replpass';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
EOF

echo "✅ MySQL Primary listo"
