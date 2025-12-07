#!/bin/bash

echo "--------------------------------------"
echo "---- APROVISIONANDO SERVIDOR NFS ----"
echo "--------------------------------------"

# Cambiar hostname
sudo hostnamectl set-hostname nfsGuilleAlv

# Actualizar e instalar paquetes
sudo apt update
sudo apt install nfs-kernel-server wget unzip mariadb-client -y

# Crear directorio
sudo mkdir -p /var/www/html

# Descargar WordPress
cd /tmp
wget https://wordpress.org/latest.zip
unzip latest.zip
sudo cp -r wordpress/* /var/www/html/

# Configurar wp-config.php
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i "s/database_name_here/wordpress/" /var/www/html/wp-config.php
sudo sed -i "s/username_here/wpuser/" /var/www/html/wp-config.php
sudo sed -i "s/password_here/wpPass123/" /var/www/html/wp-config.php
sudo sed -i "s/localhost/10.0.3.241/" /var/www/html/wp-config.php

# Permisos
sudo chown -R www-data:www-data /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

# Configurar exportación NFS
sudo cat <<EOF >> /etc/exports
/var/www/html   10.0.2.45(rw,sync,no_subtree_check,no_root_squash)
/var/www/html   10.0.2.174(rw,sync,no_subtree_check,no_root_squash)
EOF

# Aplicar exportación
sudo exportfs -ra

# Reiniciar NFS
sudo systemctl restart nfs-server

