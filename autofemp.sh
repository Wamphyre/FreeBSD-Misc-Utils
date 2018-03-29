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

touch nginx.conf;

echo 'user  www;
worker_processes  1;

# This default error log path is compiled-in to make sure configuration parsing
# errors are logged somewhere, especially during unattended boot when stderr
# isn't normally logged anywhere. This path will be touched on every nginx
# start regardless of error log location configured here. See
# https://trac.nginx.org/nginx/ticket/147 for more info. 
#
error_log  /var/log/nginx/error.log;
#

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx//access.log;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    gzip  on;

    server {
        listen       8080;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   /usr/local/www/nginx;
            index  index.php index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/local/www/nginx-dist;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000

location ~ \.php$ {
root	/usr/local/www/nginx;
fastcgi_pass   127.0.0.1:9000;
fastcgi_index  index.php;
fastcgi_param SCRIPT_FILENAME $request_filename;    
include        fastcgi_params;
}
        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

include /usr/local/etc/nginx/vhost/*;

}
' >> nginx.conf;

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
