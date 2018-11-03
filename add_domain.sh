#!/bin/bash

clear

echo "Vamos a crear un nuevo VHOST"

echo ""

sleep 1

echo ; read -p "Dime dominio a añadir: " DOMINIO

cd /usr/local/etc/nginx/vhost && touch $DOMINIO.conf

mkdir /usr/local/www/public_html/$DOMINIO

chown -R www:www /usr/local/www/public_html/$DOMINIO

echo ""

IP=$(curl ifconfig.me)

echo ""

echo "server {
# Replace with your freebsd IP
listen $IP:80;
# Document Root
root /usr/local/www/public_html/$DOMINIO;
index index.php index.html index.htm;
# Domain
server_name www.$DOMINIO $DOMINIO;
# Error and Access log file
error_log  /var/log/nginx/$DOMINIO-error.log;
access_log /var/log/nginx/$DOMINIO-access.log main;
# Reverse Proxy Configuration
location ~ \.php$ {
proxy_pass http://127.0.0.1:81;
include /usr/local/etc/nginx/proxy.conf;
# Cache configuration
proxy_cache my-cache;
proxy_cache_valid 10s;
proxy_no_cache \$cookie_PHPSESSID;
proxy_cache_bypass \$cookie_PHPSESSID;
proxy_cache_key "\$scheme\$host\$request_uri";
}
# Disable Cache for the file type html, json
location ~* .(?:manifest|appcache|html?|xml|json)$ {
expires -1;
}
# Enable Cache the file 30 days
location ~* .(jpg|png|gif|jpeg|css|mp3|wav|swf|mov|doc|pdf|xls|ppt|docx|pptx|xlsx)$ {
proxy_cache_valid 200 120m;
expires 30d;
proxy_cache my-cache;
access_log off;
}
}" >> $DOMINIO.conf

echo "VHOST para $DOMINIO creado correctamente"

echo ""

echo "Reiniciando NGINX"

sleep 2

service nginx restart

echo ""

echo "Completado"
