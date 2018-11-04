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

echo "upstream php {
    server  unix:/var/run/php-wordpress.sock;
}
# HTTP (port 80) default server used only to redirect all requests to HTTPS version
server {
    # listening socket that will bind to port 80 on all available IPv4 addresses
    listen                     80 default_server;
    # listening socket that will bind to port 80 on all available IPv6 addresses
    listen                     [::]:80 default_server;
    # HTTP redirection to HTTPS
    return                     301 https://\$host\$request_uri;
}
# HTTPS (port 443) server - our website
server {
    # listening socket that will bind to port 443 on all available IPv4 addresses
    listen                     443 ssl;
    # listening socket that will bind to port 443 on all available IPv6 addresses
    listen                     [::]:443 ssl;
    # brotli and gzip compression configuration
    include                    compression.conf;
    root                       /usr/local/www/public_html/$DOMINIO;
    index                      index.php;
    # change this to your domain name (domain.com) or host name (blog.domain.com)
    server_name                $DOMINIO;   
    # handle weird requests in a rude manner
    if (\$host != \$server_name) {
         return                418;
    }
    # DNS resolver - you may want to change it to some other provider,
    # e.g. OpenDNS: 208.67.222.222
    # or Google: 8.8.8.8
    # (9.9.9.9 is https://quad9.net )
    resolver                   1.1.1.1;
    # allow POSTs to static pages
    error_page                 405    =200 \$uri;
    access_log                 /var/log/nginx/$DOMINIO-access.log;
    error_log                  /var/log/nginx/$DOMINIO-error.log;
    location / {
        ModSecurityEnabled     on;
        ModSecurityConfig      modsecurity.conf;
        # permalinks
        try_files              \$uri \$uri/ /index.php?\$args;
        location /wp-admin {
            ModSecurityEnabled          off;
            # admin-ajax.php and load-styles.php under wp-admin are allowed
            location ~ /wp-admin/(admin-ajax|load-styles)\.php {
                fastcgi_pass            php;
                include                 fastcgi.conf;
            }
        }
        
        }
        # deny access to xmlrpc.php which allows brute-forcing at a higher rates
        # than wp-login.php; this may break some functionality, like WordPress
        # iOS/Android app posting 
        location ~* /xmlrpc\.php {
            deny                        all;
        }
        # cache binary and SVG files for one month, don't log these requests
        location ~* \.(eot|gif|ico|jpg|png|jpeg|otf|pdf|swf|ttf|woff|woff2|mp4|svg)$ {
            expires                     1M;
            add_header                  Cache-Control public;
            access_log                  off;
        }
        # don't log requests to robots.txt and ads.txt
        location ~ /(robots|ads)\.txt {
            allow                       all;
            log_not_found               off;
            access_log                  off;
        }
        # handle PHP scripts
        location ~ .php$ {
	    fastcgi_pass                php;
            fastcgi_index               index.php;
            include                     fastcgi.conf;
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
