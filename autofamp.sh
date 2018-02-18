#!/bin/bash
echo AutoFAMP by Wamphyre
echo Version 1.0

test $? -eq 0 || exit 1 "Necesitas ser root para ejecutar este script"

echo Bienvenido al script de instalación AutoFAMP.
sleep 1

echo ¡¡ADVERTENCIA¡¡ Este Script debe ejecutarse en un sistema FreeBSD recien instalado y limpio.
echo "Se recomienda utilizar FreeBSD 11.1"
echo Vamos a actualizar los repositorios de FreeBSD...
echo "Tienes 10 segundos para comenzar el proceso o cancelarlo pulsando ctrl+c"
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

portsnap fetch extract

echo Arbol de ports actualizado.
sleep 1

echo Comenzando instalacion de Stack AutoFAMP...Ten paciencia.
sleep 3

pkg install -y nano curl htop wget git nginx apache24 mariadb102-client mariadb102-server php71-pdo php71-xml php71-filter php71-posix php71-bcmath php71-zip php71 php71-mysqli mod_php71 php71-mbstring php71-gd php71-json php71-mcrypt php71-zlib php71-curl php71-session;

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
mv /usr/local/etc/php.ini-production /usr/local/etc/php.ini.original

cd /usr/local/etc/

wget nekromancerecords.tk/php.zip

unzip php.zip

rm -rf *.zip

echo Comenzando configuración de NGINX como proxy inverso de APACHE...
sleep 3

mv /usr/local/etc/apache24/httpd.conf /usr/local/etc/apache24/httpd.conf.original

cd /usr/local/etc/apache24/

wget nekromancerecords.tk/httpd.zip

unzip httpd.zip

rm -rf *.zip

cd /usr/local/etc/nginx/
mv nginx.conf nginx.conf.original
touch nginx.conf

echo 'user  www;
worker_processes  1;
error_log  /var/log/nginx/error.log;

events {
worker_connections  1024;
}

http {
include       mime.types;
default_type  application/octet-stream;

log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
'$status $body_bytes_sent "$http_referer" '
'"$http_user_agent" "$http_x_forwarded_for"';
access_log /var/log/nginx/access.log;

sendfile        on;
keepalive_timeout  65;

# Nginx cache configuration
proxy_cache_path    /var/nginx/cache levels=1:2 keys_zone=my-cache:8m max_size=1000m inactive=600m;
proxy_temp_path     /var/nginx/cache/tmp;
proxy_cache_key     "$scheme$host$request_uri";

gzip  on;

server {
#listen       80;
server_name  _;

location /nginx_status {

stub_status on;
access_log off;
}

# redirect server error pages to the static page /50x.html
#
error_page   500 502 503 504  /50x.html;
location = /50x.html {
root   /usr/local/www/nginx-dist;
}

# proxy the PHP scripts to Apache listening on 127.0.0.1:8080
#
location ~ \.php$ {
proxy_pass   http://127.0.0.1:8080;
include /usr/local/etc/nginx/proxy.conf;
}
}

include /usr/local/etc/nginx/vhost/*;

}' >> nginx.conf

touch proxy.conf

echo 'proxy_buffering         on;
proxy_redirect          off;
proxy_set_header        Host            $host;
proxy_set_header        X-Real-IP       $remote_addr;
proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
client_max_body_size    10m;
client_body_buffer_size 128k;
proxy_connect_timeout   90;
proxy_send_timeout      90;
proxy_read_timeout      90;
proxy_buffers           100 8k;
add_header              X-Cache $upstream_cache_status;' >> proxy.conf

mkdir -p /var/nginx/cache

cd /usr/local/etc/nginx/
mkdir vhost
cd vhost/

echo "Creando VHOST NGINX dominio principal..."

sleep 2

touch vhost_first.conf

echo 'server {
# Replace with your FreeBSD Server IP
listen 127.0.0.1:80;

# Document Root
root /usr/local/www/apache24/data/;
index index.php index.html index.htm;

# Domain
server_name www.mydomain.com mydomain.com;

# Error and Access log file
error_log  /var/log/nginx/mydomain-error.log;
access_log /var/log/nginx/mydomain-access.log main;

# Reverse Proxy Configuration
location ~ \.php$ {
proxy_pass http://127.0.0.1:8080;
include /usr/local/etc/nginx/proxy.conf;

# Cache configuration
proxy_cache my-cache;
proxy_cache_valid 10s;
proxy_no_cache $cookie_PHPSESSID;
proxy_cache_bypass $cookie_PHPSESSID;
proxy_cache_key "$scheme$host$request_uri";

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

}' >> vhost_first.conf

mkdir -p /var/log/nginx/

sleep 2

sysrc nginx_enable=yes
service nginx start
service apache24 restart
service nginx restart

echo Configuracion NGINX como proxy inverso de APACHE finalizada.

echo Instalando Varnish...

pkg install -y varnish5
sysrc varnishd_enable=YES
sysrc varnishd_listen=":10000"
sysrc varnishd_backend="localhost:8080"
sysrc varnishd_storage="malloc,512M"
sysrc varnishd_admin=":8081"
/usr/local/etc/rc.d/varnishd start

echo Instalando phpmyadmin...

cd /usr/local/www/apache24/data/
wget https://files.phpmyadmin.net/phpMyAdmin/4.7.7/phpMyAdmin-4.7.7-all-languages.zip
unzip phpMyAdmin-4.7.7-all-languages.zip
rm -rf *.zip
mv phpMyAdmin-4.7.7-all-languages phpmyadmin
cd

echo Añadiendo y corrigiendo permisos para usuario www...
sleep 3

chown -R www:www /usr/local/www/apache24/data/
chown -R www:www /usr/local/www/apache24/data/*
service apache24 restart

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
echo Tu servidor FAMP ya está instalado, configurado y securizado.
sleep 2

echo ¡¡¡¡NOTAS IMPORTANTES¡¡¡¡
echo Recuerda que tus webs se almacenarán por defecto en /usr/local/www/apache24/data/
echo Puedes modificar el fichero httpd.conf en /usr/local/etc/apache24/httpd.conf
echo Modifica el fichero nginx.conf con la IP de tu servidor
echo "No olvides revisar el fichero /usr/local/etc/nginx/vhost/vhost_test.conf para configurar correctamente tus webs usando NGINX como proxy inverso de APACHE"
echo Puedes modificar php.ini en /usr/local/etc/php.ini
echo Puedes ver los logs del sistema en /var/log
echo Puedes añadir tus propias reglas al Firewall en /etc/pf.conf
echo "Tienes Varnish funcionando en el puerto 10000 configura tus plugins de cache compatibles por este puerto"
sleep 10

echo Reinicia el equipo para disfrutar de tu nuevo servidor FAMP
echo "Ejecuta luego el siguiente comando /usr/local/bin/mysql_secure_installation"

echo COMPLETADO
