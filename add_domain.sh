#!/bin/bash

clear

echo "Vamos a crear un nuevo VHOST"

echo ""

sleep 1

echo ; read -p "Dime dominio a añadir: " DOMINIO

cd /usr/local/etc/nginx/conf.d && touch $DOMINIO.conf

mkdir /usr/local/www/public_html/$DOMINIO

chown -R www:www /usr/local/www/public_html/$DOMINIO

ln -s /usr/local/www/phpMyAdmin/ /usr/local/www/public_html/$DOMINIO/phpmyadmin

echo ""

echo "

server {
listen 8080;
listen [::]:8080;

server_name $DOMINIO;

root /usr/local/www/public_html/$DOMINIO;
index index.php;
}

# HTTPS (port 443) server - our website
server {
    # listening socket that will bind to port 443 on all available IPv4 addresses
    listen                     443 ssl http2;

    # listening socket that will bind to port 443 on all available IPv6 addresses
    listen                     [::]:443 ssl;

    root                       /usr/local/www/public_html/$DOMINIO;
    index                      index.php;

    # change this to your domain name (domain.com) or host name (blog.domain.com)
    server_name                $DOMINIO;  
    
    # DNS resolver - you may want to change it to some other provider,
    # e.g. OpenDNS: 208.67.222.222
    # or Google: 8.8.8.8
    # (9.9.9.9 is https://quad9.net )
    resolver                   1.1.1.1;
    # allow POSTs to static pages
    error_page                 405    =200 \$uri;
    access_log                 /var/log/nginx/$DOMINIO-access.log;
    error_log                  /var/log/nginx/$DOMINIO-error.log;

    # gzip compression

    gzip on;
    gzip_disable "\msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

    # no logging for favicon

    location ~ favicon.ico$ {
        access_log off;
    }

    # deny access to .htaccess files
    
    location ~ /\.ht {
        deny all;
    }

    # expires of assets (per extension)

    location ~ .(jpe?g|gif|png|webp|ico|css|js|zip|tgz|gz|rar|bz2|7z|tar|pdf|txt|mp4|m4v|webm|flv|wav|swf)$ {
        if (\$args ~ [0-9]+) {
            expires 30d;
        } 
    }

    # expires of assets (per path)

    location ~ ^/(css|js|img|files) {
        if (\$args ~ [0-9]+) {
            expires 30d;
        } 
    }
}
" >> $DOMINIO.conf

echo "VHOST para $DOMINIO creado correctamente"

echo ""

echo "Reiniciando NGINX"

sleep 2

service nginx restart

echo ""

echo "Completado"
