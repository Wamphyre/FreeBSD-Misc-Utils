#!/bin/bash

clear

sysrc ftpd_enable="YES"

echo ""

service ftpd start

echo ""

echo ; read -p "Dime nombre de usuario FTP a crear: " USER;

echo ""

pw groupadd ftpgroup -g 2001
adduser -w random -g ftpgroup -u 2001 -g 2001 -s nologin -d /usr/local/www

echo ""

touch /etc/ftpchroot

echo "
$USER
@ftpgroup
$USER	/usr/local/www/$USER./public_html
@	public_html
" >> /etc/ftpchroot

echo "Usuario $USER creado"

echo ""

service ftpd restart

echo ""

echo "Guarda la contraseña a buen recaudo"
