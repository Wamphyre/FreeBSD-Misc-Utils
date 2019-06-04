#!/bin/bash

echo ; read -p "Dime nombre de usuario a crear zona ZFS: " USUARIO;

echo ; read -p "Dime tamaño de la zona ZFS (ej:2G): " CUOTA;

zfs create -o quota=$CUOTA zroot/usr/local/www/$USUARIO

df -h | grep $USUARIO

echo "Zona ZFS creada"

echo "Creando directorio public_html para $USUARIO"

mkdir /usr/local/www/$USUARIO/public_html

echo "Reparando permisos del directorio..."

chown -R www:www /usr/local/www/$USUARIO/public_html/
chown -R www:www /usr/local/www/$USUARIO/public_html/*

cd /usr/local/www/$USUARIO/public_html/

find . -type f -exec chmod 664 {} +
find . -type d -exec chmod 775 {} +

echo "Directorio public_html para $USUARIO creado"

echo "No olvides crear ahora el usuario y su cuenta FTP"

echo "Añade también su dominio principal creando su server block"

echo "Crea un usuario SQL"
