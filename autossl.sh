#!/bin/bash

clear

echo "AutoSSL Installer"

sleep 1

echo ""

echo ; read -p "Dime dominio a instalar el certificado SSL: " DOMINIO;

echo ""

certbot-3.6 --nginx -d $DOMINIO

echo ""

service nginx restart

echo ""

certbot-3.6 enhance --hsts -d $DOMINIO

echo ""

service nginx restart

echo ""

echo "Completado. Espera unos minutos y revisa tu dominio"
