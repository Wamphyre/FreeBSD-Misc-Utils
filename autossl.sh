#!/bin/bash

clear

echo "AutoSSL Installer"

sleep 1

echo ""

echo ; read -p "Dime dominio a instalar el certificado SSL: " DOMINIO;

echo ""

service varnishd stop

sed -ie 's/^\s*listen 8080/listen 80/' /usr/local/etc/nginx/nginx.conf

sed -ie 's/^\s*listen 8080/listen 80/' /usr/local/www/public_html/$DOMINIO.conf

service nginx restart

certbot-3.6 --nginx -d $DOMINIO

echo ""

service nginx restart

echo ""

certbot-3.6 enhance --hsts -d $DOMINIO

echo ""

service nginx restart

echo ""

sed -ie 's/^\s*listen 80/listen 8080/' /usr/local/etc/nginx/nginx.conf

sed -ie 's/^\s*listen 80/listen 8080/' /usr/local/www/public_html/$DOMINIO.conf

service nginx restart

service varnishd restart

echo "Completado. Espera unos minutos y revisa tu dominio"
