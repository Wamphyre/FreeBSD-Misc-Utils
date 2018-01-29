#!/bin/bash
echo AutoFAMP by Wamphyre
echo Version 1.0

test $? -eq 0 || exit 1 "Necesitas ser root para ejecutar este script"

echo Bienvenido al script de instalación AutoFAMP.
sleep 1

echo ¡¡ADVERTENCIA¡¡ Este Script debe ejecutarse en un sistema FreeBSD recien instalado y limpio.
echo Vamos a actualizar los repositorios de FreeBSD...
echo Tienes 10 segundos para comenzar el proceso o cancelarlo pulsando ctrl+c
sleep 10

echo Iniciando actualizacion...
pkg update && pkg upgrade -y

echo Repositorios y paquetes actualizados.
sleep 1

echo Comenzando actualización del sistema base...
sleep 3

freebsd-update fetch && freebsd-update install

echo Sistema Operativo actualizado
sleep 2

echo Actualizando y extrayendo el arbol de ports...
sleep 4

portsnap fetch auto

echo Arbol de ports actualizado.
sleep 1

echo Comenzando instalacion de Stack AutoFAMP...Ten paciencia.
sleep 3

pkg install -y nano curl htop wget git apache24 php71 php71-mysqli mod_php71 php71-mbstring php71-gd php71-json php71-mcrypt php71-zlib php71-curl mariadb102-client mariadb102-server

echo Comenzando configuracion post-instalacion...
sleep 3

sysrc powerd_enable="YES"
sysrc powerd_flags="-a hiadaptive"
sysrc ntpd_enable="YES"
sysrc ntpdate_enable="YES"
sysrc apache24_enable="YES"
service apache24 start
touch /usr/local/etc/apache24/Includes/php.conf
echo '<IfModule dir_module>
DirectoryIndex index.php index.html
<FilesMatch "\.php$">
SetHandler application/x-httpd-php
</FilesMatch>
<FilesMatch "\.phps$">
SetHandler application/x-httpd-php-source
</FilesMatch>
</IfModule>' >> /usr/local/etc/apache24/Includes/php.conf
service apache24 restart
sysrc mysql_enable="YES"
service mysql-server start
mv /usr/local/etc/php.ini-production /usr/local/etc/php.ini

echo Añadiendo y corrigiendo permisos para usuario www...
sleep 3

chown -R root:www /usr/local/www/apache24/data/
chmod -R 775 root:www /usr/local/www/apache24/data/

echo Permisos corregidos 
sleep 3

echo Aplicando parámetros de Hardening Paranóico...
sleep 3

pkg audit -F

sysrc pf_enable="YES"
sysrc pflog_enable="YES"
sysrc clear_tmp_enable="YES"
sysrc syslogd_flags="-ss"
sysrc sendmail_enable="NONE"
sysrc dumpdev="NO"

echo 'kern.elf64.nxstack=1' >> /etc/sysctl.conf
echo 'sysctl security.bsd.map_at_zero=0' >> /etc/sysctl.conf
echo 'security.bsd.see_other_uids=0' >> /etc/sysctl.conf
echo 'security.bsd.see_other_gids=0' >> /etc/sysctl.conf
echo 'security.bsd.unprivileged_read_msgbuf=0' >> /etc/sysctl.conf
echo 'security.bsd.unprivileged_proc_debug=0' >> /etc/sysctl.conf
echo 'kern.randompid=1000' >> /etc/sysctl.conf
echo 'security.bsd.stack_guard_page=1' >> /etc/sysctl.conf
echo 'net.inet.udp.blackhole=1' >> /etc/sysctl.conf
echo 'net.inet.tcp.blackhole=2' >> /etc/sysctl.conf

echo Hardening Paranóico completado.
sleep 3

echo Limpiando y comprobando el sistema...
sleep 4

pkg update && pkg upgrade -y
pkg clean -y

echo ¡Instalación finalizada!
echo Tu servidor FAMP ya está instalado, configurado por defecto y securizado.
sleep 2

echo ¡¡¡¡NOTAS IMPORTANTES¡¡¡¡
echo Recuerda que tus webs se almacenarán por defecto en /usr/local/www/apache24/data/
echo Puedes modificar el fichero httpd.conf en /usr/local/etc/apache24/httpd.conf
echo Puedes modificar php.ini en /usr/local/etc/php.ini
echo Puedes ver los logs del sistema en /var/log
echo Puedes añadir tus propias reglas al Firewall en /etc/pf.conf
sleep 2

echo Ejecuta ahora /usr/local/bin/mysql_secure_installation
echo a continuación, reinicia tu sistema para completar los cambios.

exit
