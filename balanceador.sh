#!/bin/bash

echo "--------------------------------------"
echo "---- APROVISIONANDO BALANCEADOR ----"
echo "--------------------------------------"

# Cambiar hostname
sudo hostnamectl set-hostname balanceadorGuilleAlv

# Actualizar e instalar Apache
sudo apt update
sudo apt install apache2 -y

# Habilitar módulos necesarios
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_balancer
sudo a2enmod lbmethod_byrequests
sudo a2enmod ssl
sudo a2enmod headers

# Generar certificado SSL autofirmado
sudo mkdir -p /etc/apache2/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/apache2/ssl/apache.key \
  -out /etc/apache2/ssl/apache.crt \
  -subj "/C=ES/ST=Extremadura/L=Merida/O=GuilleAlv/CN=balanceador"

# Configurar VirtualHost HTTP (puerto 80 - redirige a HTTPS)
sudo cat <<EOF > /etc/apache2/sites-available/balancer-http.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    
    Redirect permanent / https://balanceadorGuilleAlv/
    
    ErrorLog \${APACHE_LOG_DIR}/balancer_error.log
    CustomLog \${APACHE_LOG_DIR}/balancer_access.log combined
</VirtualHost>
EOF

# Configurar VirtualHost HTTPS (puerto 443)
# ademas agregar ServerName guillealfra.duckdns.org para que certbot funcione
sudo cat <<EOF > /etc/apache2/sites-available/balancer-https.conf
<VirtualHost *:443>
    ServerName guillealfra.duckdns.org
    ServerAdmin webmaster@localhost
    
    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/apache.crt
    SSLCertificateKeyFile /etc/apache2/ssl/apache.key
    
    <Proxy balancer://cluster_wordpress>
        BalancerMember http://10.0.2.45
        BalancerMember http://10.0.2.174
    </Proxy>
    
    ProxyPass / balancer://cluster_wordpress/
    ProxyPassReverse / balancer://cluster_wordpress/
    
    ErrorLog \${APACHE_LOG_DIR}/balancer_error.log
    CustomLog \${APACHE_LOG_DIR}/balancer_access.log combined
</VirtualHost>
EOF

# Activar sitios
sudo a2dissite 000-default.conf
sudo a2ensite balancer-http.conf
sudo a2ensite balancer-https.conf

# Reiniciar Apache
sudo apt install certbot python3-certbot-apache -y
sudo certbot --apache -d guillealfra.duckdns.org --agree-tos --email galvarezf04@iesalbarregas.es -n

# Reiniciar Apache
sudo systemctl restart apache2