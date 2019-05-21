#!/bin/bash

clear

echo "Vamos a crear un nuevo VHOST"

echo ""

sleep 1

echo ; read -p "Dime dominio a añadir: " DOMINIO

cd /usr/local/etc/nginx/conf.d && touch $DOMINIO.conf

mkdir /usr/local/www/public_html/$DOMINIO

ln -s /usr/local/www/phpMyAdmin/ /usr/local/www/public_html/$DOMINIO/phpmyadmin

chown -R www:www /usr/local/www/public_html/$DOMINIO

echo ""

echo "

server {
listen 8080;
listen [::]:8080;

server_name $DOMINIO;

root /usr/local/www/public_html/$DOMINIO;
index index.php index.html;
    
    # allow POSTs to static pages
    error_page                 405    =200 \$uri;
    access_log                 /var/log/nginx/$DOMINIO-access.log;
    error_log                  /var/log/nginx/$DOMINIO-error.log;

        location / {
                # This is cool because no php is touched for static content.
                # include the "\$is_args\$args" so non-default permalinks doesn't break when using query string
                try_files \$uri \$uri/ /index.php\$is_args\$args;
        }
	
        # deny access to xmlrpc.php which allows brute-forcing at a higher rates
        # than wp-login.php; this may break some functionality, like WordPress
        # iOS/Android app posting 
        location ~* /xmlrpc\.php {
            deny                        all;
        }	

# Media: images, icons, video, audio, HTC
location ~* \.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc)\$ {
	expires 1M;
	access_log off;
	add_header Cache-Control "public";
}

# CSS and Javascript
location ~* \.(?:css|js)\$ {
	expires 1y;
	access_log off;
	add_header Cache-Control "public";
}

location = ^/favicon.ico {
    access_log off;
    log_not_found off;
}

# robots noise...
location = ^/robots.txt {
    log_not_found off;
    access_log off;
    allow all;
}

# block access to hidden files (.htaccess per example)
location ~ /\. { access_log off; log_not_found off; deny all; }

        location ~ [^/]\.php(/|$) {
        root	/usr/local/www/public_html/$DOMINIO;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param SCRIPT_FILENAME \$request_filename;    
        include        fastcgi_params;
        	}
		
    location ~ \.php\$ {
    location ~* wp\-login\.php {
        limit_req   zone=reqlimit  burst=1 nodelay;
        limit_req_status 444;
    }
    }
    
           if (\$http_user_agent ~* "Mozilla/4\.0 \(compatible\; MSIE 6" ) {
           return 444;
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
