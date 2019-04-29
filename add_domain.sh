#!/bin/bash

clear

echo "Vamos a crear un nuevo VHOST"

echo ""

sleep 1

echo ; read -p "Dime dominio a añadir: " DOMINIO

cd /usr/local/etc/nginx/conf.d && touch $DOMINIO.conf

mkdir /usr/local/www/public_html/$DOMINIO

chown -R www:www /usr/local/www/public_html/$DOMINIO

echo ""

echo "

server {
listen 8080;
listen [::]:8080;

server_name $DOMINIO;

root /usr/local/www/public_html/$DOMINIO;
index index.php index.html;
    
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
gzip_vary on;
gzip_min_length 1024;
gzip_proxied expired no-cache no-store private auth;
gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml;
gzip_disable "MSIE [1-6]\.";

        location / {
                # This is cool because no php is touched for static content.
                # include the "$is_args$args" so non-default permalinks doesn't break when using query string
                try_files $uri $uri/ /index.php$is_args$args;
        }

    # no logging for favicon

    location ~ favicon.ico$ {
        access_log off;
    }

        location ~ \.php$ {
        root	/usr/local/www/public_html/$DOMINIO;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param SCRIPT_FILENAME \$request_filename;    
        include        fastcgi_params;
        	}

    # expires of assets (per extension)

    location ~ .(jpeg|gif|png|webp|ico|css|js|zip|tgz|gz|rar|bz2|7z|tar|pdf|txt|mp4|m4v|webm|flv|wav|swf)$ {
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

service php-fpm restart

echo ""

echo "Completado"
