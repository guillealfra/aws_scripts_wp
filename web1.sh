
#!/bin/bash

echo "--------------------------------------"
echo "---- APROVISIONANDO SERVIDOR WEB1 ----"
echo "--------------------------------------"

# Cambiar hostname
sudo hostnamectl set-hostname web1GuilleAlv

# Actualizar e instalar paquetes
sudo apt update
sudo apt install apache2 php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip nfs-common mariadb-client -y

# Crear directorio
sudo mkdir -p /var/www/html

# Configurar VirtualHost
sudo cat <<EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/wordpress_error.log
    CustomLog \${APACHE_LOG_DIR}/wordpress_access.log combined
</VirtualHost>
EOF

# Habilitar mod_rewrite
sudo a2enmod rewrite
sudo a2enmod ssl

# Activar sitio
sudo a2dissite 000-default.conf
sudo a2ensite wordpress.conf

# Reiniciar Apache
sudo systemctl restart apache2

# Montar NFS
sudo mount 10.0.2.24:/var/www/html /var/www/html

# Agregar a fstab para montaje automático
echo "10.0.2.24:/var/www/html  /var/www/html  nfs  defaults,_netdev  0  0" | sudo tee -a /etc/fstab
