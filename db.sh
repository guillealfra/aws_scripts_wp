#!/bin/bash

echo "--------------------------------------"
echo "---- APROVISIONANDO BASE DE DATOS ----"
echo "--------------------------------------"

# Cambiar hostname
sudo hostnamectl set-hostname dbGuilleAlv

# Actualizar e instalar MariaDB
sudo apt update
sudo apt install mariadb-server -y

# Configurar MariaDB para aceptar conexiones desde la red privada
sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

# Reiniciar MariaDB
sudo systemctl restart mariadb

# Crear base de datos y usuario para WordPress
sudo mysql -e "
DROP DATABASE IF EXISTS wordpress;
CREATE DATABASE wordpress CHARACTER SET utf8mb4;
CREATE USER IF NOT EXISTS 'wpuser'@'10.0.2.%' IDENTIFIED BY 'wpPass123';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'10.0.2.%';
FLUSH PRIVILEGES;
"
