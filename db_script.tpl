#!/bin/bash
database_name = ${database_name}
database_user = ${database_user}
database_pass = ${database_pass}
remote_address = ${remote_address}
host_address = ${host_address}

sudo apt-get update -y
sudo apt install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb




sudo mariadb -e "CREATE DATABASE ${database_name}"
sudo mariadb -e "CREATE USER '${database_user}'@'${remote_address}' IDENTIFIED BY '${database_pass}';"
sudo mariadb -e "GRANT ALL PRIVILEGES ON ${database_name}.* TO '${database_user}'@'${remote_address}';"
sudo mariadb -e "FLUSH PRIVILEGES;"

sudo sed -i "s/.*bind-address.*/bind-address = ${host_address}/" /etc/mysql/mariadb.conf.d/50-server.cnf

sudo systemctl stop mariadb
sudo systemctl start mariadb
sudo systemctl enable mariadb