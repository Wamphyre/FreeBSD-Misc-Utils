#!/bin/bash
echo AutoFEMP by Wamphyre
echo Version 1.0

echo 'Bienvenido al script de instalación de AutoFEMP';

echo 'Esto instalará NGINX, PHP 7.1, PHP-FPM, MariaDB, Varnish y phpmyadmin en tu máquina';

echo 'Tienes 10 segundos para cancelar la instalación...';

sleep 10;

pkg update && pkg upgrade -y;

pkg install -y htop nano wget curl zip unzip;

pkg install -y nginx mariadb102-client mariadb102-server php71-pdo php71-pdo_mysql php71-xml php71-filter php71-posix php71-bcmath php71-zip php71 php71-mysqli mod_php71 php71-mbstring php71-gd php71-json php71-mcrypt php71-zlib php71-curl php71-session;

cp /usr/local/etc/php-fpm.d/www.conf{,.backup}

mv /usr/local/etc/php.ini-production /usr/local/etc/php.ini.original;

cd /usr/local/etc/;

wget nekromancerecords.tk/php.zip;

unzip php.zip;

rm -rf *.zip;

cd /usr/local/etc/nginx;

mv nginx.conf nginx.conf_original;

wget nekromancerecords.tk/nginx.zip;

unzip nginx.zip;

rm -rf *.zip;

mkdir -p /var/nginx/cache;
mkdir -p /var/log/nginx/;
cd /usr/local/etc/nginx/;
mkdir vhost;
cd vhost;
touch vhost_test.conf;

echo 'server {
        listen       127.0.0.1:8080;
        server_name  www.mydomain.com mydomain.com;
        location / {
        root /usr/local/www/nginx/;
        index  index.php index.html index.htm;
        error_log  /var/log/nginx/mydomain-error.log;
        access_log /var/log/nginx/mydomain-access.log main;
        }
}' >> vhost_test.conf;

cd;

echo 'Instalando Varnish';

sleep 2

pkg install -y varnish5;

sysrc varnishd_enable=YES
sysrc varnishd_listen=":80"
sysrc varnishd_backend="localhost:8080"
sysrc varnishd_storage="malloc,512M"
sysrc varnishd_admin=":8081"

sysrc mysql_enable="YES"
sysrc mysql_args="--bind-address=127.0.0.1"
sysrc php_fpm_enable="YES"
sysrc nginx_enable="YES"

service mysql-server start 
service varnishd start
service php-fpm start
service nginx start
service php-fpm restart

echo 'Instalando phpmyadmin';
sleep 3

cd /usr/local/www/nginx/;
wget https://files.phpmyadmin.net/phpMyAdmin/4.7.7/phpMyAdmin-4.7.7-all-languages.zip;
unzip phpMyAdmin-4.7.7-all-languages.zip;
rm -rf *.zip;
mv phpMyAdmin-4.7.7-all-languages phpmyadmin;
cd;

echo 'Corrigiendo permisos';

sleep 1

chown -R www:www /usr/local/www/nginx/
chown -R www:www /usr/local/www/nginx/*

echo 'Optimizando sistema...';

sleep 2

sysrc pf_enable="YES"
sysrc pflog_enable="YES"
sysrc clear_tmp_enable="YES"
sysrc syslogd_flags="-ss"
sysrc sendmail_enable="NONE"
sysrc dumpdev="NO"
sysrc powerd_enable="YES"
sysrc powerd_flags="-a hiadaptive"
sysrc ntpd_enable="YES"
sysrc ntpdate_enable="YES"

echo 'Securizando sistema...';

sleep 2

echo 'kern.elf64.nxstack=1' >> /etc/sysctl.conf;
echo 'sysctl security.bsd.map_at_zero=0' >> /etc/sysctl.conf;
echo 'security.bsd.see_other_uids=0' >> /etc/sysctl.conf;
echo 'security.bsd.see_other_gids=0' >> /etc/sysctl.conf;
echo 'security.bsd.unprivileged_read_msgbuf=0' >> /etc/sysctl.conf;
echo 'security.bsd.unprivileged_proc_debug=0' >> /etc/sysctl.conf;
echo 'kern.randompid=1000' >> /etc/sysctl.conf;
echo 'security.bsd.stack_guard_page=1' >> /etc/sysctl.conf;
echo 'net.inet.udp.blackhole=1' >> /etc/sysctl.conf;
echo 'net.inet.tcp.blackhole=2' >> /etc/sysctl.conf;

echo 'Revisando y limpiando archivos temporales...';

pkg update && pkg upgrade -y;
pkg clean;
pkg audit -F;

echo 'FINALIZADO';

echo 'Tu servidor FEMP con Varnish y phpmyadmin ya está instalado';

echo 'Ejecuta ahora el comando /usr/local/bin/mysql_secure_installation';

echo 'Reinicia el equipo en cuanto te sea posible';
